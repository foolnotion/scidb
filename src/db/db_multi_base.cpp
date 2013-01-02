// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_multi_base.h"
#include "db_database.h"
#include "db_producer.h"

#include "sci_codec.h"
#include "sci_consumer.h"

#include "sys_time.h"

#include "m_auto_ptr.h"
#include "m_assert.h"

#include <string.h>

using namespace db;


MultiBase::MultiBase(mstl::string const& name,
							mstl::string const& encoding,
							variant::Type variant,
							storage::Type storage,
							Type type)
	:m_singleBase(variant != variant::Undetermined)
{
	M_REQUIRE(variant == variant::Undetermined || variant::isMainVariant(variant));

	::memset(m_bases, 0, sizeof(m_bases));

	if (variant == variant::Undetermined)
	{
		m_bases[variant::Index_Normal] = m_leader = new Database(
			name, encoding, storage, type, variant::Normal);
		m_bases[variant::Index_Crazyhouse] = new Database(
			name, encoding, storage, type, variant::Crazyhouse);
		m_bases[variant::Index_Bughouse] = new Database(
			name, encoding, storage, type, variant::Bughouse);
		m_bases[variant::Index_ThreeCheck] = new Database(
			name, encoding, storage, type, variant::ThreeCheck);
		m_bases[variant::Index_Antichess] = new Database(
			name, encoding, storage, type, variant::Antichess);
		m_bases[variant::Index_Losers] = new Database(
			name, encoding, storage, type, variant::Losers);
	}
	else
	{
		mstl::auto_ptr<Database> database(new Database(name, encoding, storage, type, variant));
		m_bases[variant::toIndex(variant)] = m_leader = database.release();
	}
}


MultiBase::MultiBase(mstl::string const& name,
							mstl::string const& encoding,
							permission::Mode mode,
							util::Progress& progress)
	:m_singleBase(true)
{
	::memset(m_bases, 0, sizeof(m_bases));
	mstl::auto_ptr<Database> database(new Database(name, encoding, mode, progress));
	m_bases[variant::toIndex(database->variant())] = m_leader = database.release();
}


MultiBase::~MultiBase()
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
		delete m_bases[i];
}


bool
MultiBase::isEmpty(unsigned variantIndex) const
{
	return m_bases[variantIndex] == 0 || m_bases[variantIndex]->countGames() == 0;
}


bool
MultiBase::isEmpty() const
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (!isEmpty(i))
			return false;
	}

	return true;
}


MultiBase::Format
MultiBase::format() const
{
	M_ASSERT(m_leader);
	return m_leader->format();
}


variant::Type
MultiBase::variant() const
{
	M_ASSERT(m_leader);
	return m_leader->variant();
}


unsigned
MultiBase::countGames(GameCount& result) const
{
	unsigned n = 0;

	::memset(result, 0, sizeof(result));

	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (Database* base = m_bases[i])
			n += result[i] = base->countGames();
	}

	return n;
}


unsigned
MultiBase::countGames() const
{
	unsigned n = 0;

	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (Database* base = m_bases[i])
			n += base->countGames();
	}

	return n;
}


void
MultiBase::close()
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (Database* db = m_bases[i])
			db->close();
	}
}


void
MultiBase::close(variant::Type variant)
{
	M_REQUIRE(variant::isMainVariant(variant));

	unsigned variantIndex = variant::toIndex(variant);

	if (m_bases[variantIndex])
	{
		m_bases[variantIndex]->close();
		delete m_bases[variantIndex];
		m_bases[variantIndex] = 0;
	}
}


void
MultiBase::changeVariant(variant::Type variant)
{
	M_REQUIRE(variant::isMainVariant(variant));
	M_REQUIRE(isEmpty());

	if (isSingleBase())
		m_leader->setVariant(variant);
}


unsigned
MultiBase::importGames(Producer& producer, util::Progress& progress, GameCount* count)
{
	unsigned n;

	if (count)
		::memset(*count, 0, sizeof(*count));

	// NOTE: Only PGN can provide multiple variants.

	if (m_singleBase || producer.format() != format::Pgn)
	{
		n = m_leader->importGames(producer, progress);
		if (count)
			(*count)[variant::toIndex(m_leader->variant())] = n;
	}
	else
	{
		M_ASSERT(m_leader->format() == format::Scidb);

		GameCount oldCount;
		sci::Consumer::Codecs codecs;

		::memset(oldCount, 0, sizeof(oldCount));

		for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
		{
			if (Database* base = m_bases[i])
			{
				oldCount[i] = base->countGames();
				codecs.add(&dynamic_cast<sci::Codec&>(base->codec()));
			}
		}

		M_ASSERT(!codecs.isEmpty());

		sci::Consumer consumer(format::Scidb, codecs, Consumer::TagBits(true), true);
		producer.setConsumer(&consumer);
		producer.process(progress);
		n = 0;

		for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
		{
			if (Database* base = m_bases[i])
			{
				unsigned cnt = base->countGames() - oldCount[i];

				if (cnt > 0)
				{
					n += cnt;
					base->finishImport(oldCount[i], producer.encodingFailed());

					if (count)
						(*count)[i] = cnt;
				}
			}
		}
	}

	return n;
}

// vi:set ts=3 sw=3:
