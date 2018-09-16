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
// Copyright: (C) 2012-2018 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "app_multi_cursor.h"
#include "app_cursor.h"
#include "app_application.h"

#include "db_multi_base.h"
#include "db_database.h"
#include "db_producer.h"

#include "sys_utf8_codec.h"
#include "sys_fam.h"

#include "m_map.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <string.h>

using namespace app;
using namespace db;


namespace {

struct WriteGuard
{
	void release() { m_app.setIsWriting(); }

	WriteGuard(Application& app, Database const& base)
		:m_app(app)
	{
		if (!base.isMemoryOnly())
			m_app.setIsWriting(base.name());
	}

	WriteGuard(Application& app, MultiCursor const& cursor)
		:m_app(app)
	{
		if (!cursor.cursor().isMemoryOnly())
			m_app.setIsWriting(cursor.name());
	}

	~WriteGuard() { release(); }

	Application& m_app;
};

} // namespace



mstl::string MultiCursor::m_clipbaseName("Clipbase");
mstl::string MultiCursor::m_scratchbaseName("Scratchbase");


MultiCursor::MultiCursor(Application& app, Type type)
	:m_app(app)
	,m_base(0)
	,m_leader(0)
	,m_isScratchbase(type == Scratchbase)
	,m_isClipbase(type == Clipbase)
{
	m_base = new MultiBase(	type == Clipbase ? m_clipbaseName : m_scratchbaseName,
									sys::utf8::Codec::utf8(),
									variant::Undetermined,
									storage::MemoryOnly,
									type::Clipbase);
	::memset(m_cursor, 0, sizeof(m_cursor));
	setup();
}


MultiCursor::MultiCursor(Application& app, MultiBase*  base)
	:m_app(app)
	,m_base(base)
	,m_leader(0)
	,m_isScratchbase(false)
	,m_isClipbase(false)
{
	M_REQUIRE(base);

	::memset(m_cursor, 0, sizeof(m_cursor));
	setup();
}


MultiCursor::MultiCursor(	Application& app,
									mstl::string const& name,
									db::type::ID type,
									db::Producer& producer,
									util::Progress& progress)
	:m_app(app)
	,m_base(0)
	,m_leader(0)
	,m_isScratchbase(false)
	,m_isClipbase(false)
{
	::memset(m_cursor, 0, sizeof(m_cursor));

	mstl::auto_ptr<MultiBase> base(new MultiBase(name,
																sys::utf8::Codec::utf8(),
																variant::Undetermined,
																storage::MemoryOnly,
																type));

	WriteGuard guard(m_app, *base->database());

	unsigned n = base->importGames(producer, progress);

	if (n)
		base->save(progress);

	base->resetInitialSize();
	guard.release();
	m_base = base.release();
	setup(&producer);
}


MultiCursor::~MultiCursor()
{
	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
		delete m_cursor[v];

	delete m_base;
}


void
MultiCursor::setup(db::Producer const* producer)
{
	m_leader = nullptr;

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (m_base->exists(v))
		{
			if (!m_cursor[v])
			{
				m_cursor[v] = new Cursor(*this, m_base->database(v));

				if (producer)
				{
					m_cursor[v]->base().setReadonly();

					if (producer->encoding() != sys::utf8::Codec::automatic())
						m_base->database(v)->setUsedEncoding(producer->encoding());
				}
			}

			if (!m_leader)
				m_leader = m_cursor[v];
		}
		else
		{
			delete m_cursor[v];
			m_cursor[v] = nullptr;
		}
	}
}


unsigned
MultiCursor::mapVariantIndex(unsigned variantIndex) const
{
	if (variantIndex == db::variant::Index_ThreeCheck && db::format::isScidFormat(cursor().format()))
		return db::variant::Index_Normal;

	return variantIndex;
}


db::variant::Type
MultiCursor::map(db::variant::Type variant) const
{
	if (variant == db::variant::ThreeCheck && db::format::isScidFormat(cursor().format()))
		return db::variant::Normal;

	return variant;
}


Cursor*
MultiCursor::operator[](db::variant::Type variant) const
{
	M_REQUIRE(variant == db::variant::Undetermined || db::variant::isMainVariant(variant));

	if (!isOpen())
		return nullptr;

	if (variant == db::variant::Undetermined)
		return m_leader;

	return m_cursor[db::variant::toIndex(map(variant))];
}


Cursor*
MultiCursor::operator[](unsigned variantIndex) const
{
	if (!isOpen())
		return nullptr;

	variantIndex = mapVariantIndex(variantIndex);

	if (!exists(variantIndex))
		return nullptr;

	return m_cursor[variantIndex];
}


bool
MultiCursor::isEmpty(unsigned variantIndex) const
{
	M_REQUIRE(isOpen());
	return m_base->isEmpty(mapVariantIndex(variantIndex));
}


bool
MultiCursor::isEmpty() const
{
	M_REQUIRE(isOpen());

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (!m_base->isEmpty(v))
			return false;
	}

	return true;
}


bool
MultiCursor::isSingleBase() const
{
	return m_base->isSingleBase();
}


bool
MultiCursor::isUnsaved() const
{
	return m_base->isUnsaved();
}


unsigned
MultiCursor::countGames() const
{
	return isOpen() ? m_base->countGames() : 0;
}


bool
MultiCursor::setReadonly(bool flag)
{
	if (!m_base->setReadonly(flag))
		return false;
	setup();
	return true;
}


void
MultiCursor::close()
{
	if (isOpen())
	{
		for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
		{
			if (m_cursor[v])
				m_cursor[v]->close();
		}

		m_base->close();
	}
}


unsigned
MultiCursor::copyGames(	MultiCursor& destination,
								GameCount& accepted,
								GameCount& rejected,
								TagBits const& allowedTags,
								bool allowExtraTags,
								unsigned* illegalRejected,
								db::Log& log,
								util::Progress& progress) const
{
	unsigned total = 0;

	WriteGuard guard(m_app, destination);

	for (unsigned v = 0; v < ::db::variant::NumberOfVariants; ++v)
	{
		if (m_cursor[v] && m_cursor[v]->count(table::Games) > 0)
		{
			unsigned count = 0;

			if (destination.m_cursor[v])
			{
				Cursor& cursor = *m_cursor[v];

				count = cursor.base().copyGames(
					destination.m_cursor[destination.mapVariantIndex(v)]->base(),
					cursor.view(0).filter(table::Games),
					cursor.view(0).selector(table::Games),
					allowedTags,
					allowExtraTags,
					illegalRejected,
					log,
					progress);

				accepted[v] += count;
				total += count;
			}

			rejected[v] += m_cursor[v]->count(table::Games) - count;
		}
	}

	if (	::db::format::isScidFormat(m_base->sourceFormat())
		&& !::db::format::isScidFormat(destination.m_base->sourceFormat())
		&& rejected[::db::variant::Index_Normal] > 0)
	{
		unsigned v = ::db::variant::Index_ThreeCheck;

		if (destination.m_cursor[v])
		{
			Cursor& cursor = *m_cursor[::db::variant::Index_Normal];
			unsigned count = cursor.base().copyGames(
										destination.m_cursor[v]->base(),
										cursor.view(0).filter(table::Games),
										cursor.view(0).selector(table::Games),
										allowedTags,
										allowExtraTags,
										illegalRejected,
										log,
										progress);
			accepted[v] += count;
			rejected[::db::variant::Index_Normal] -= count;
			total += count;
		}
	}

	return total;
}


void
MultiCursor::changeVariant(::db::variant::Type variant)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isEmpty());
	M_REQUIRE(!isScratchbase());
	M_REQUIRE(!isClipbase());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());

	if (m_leader->variant() != variant)
	{
		m_base->changeVariant(variant);
		setup();
		m_leader = m_cursor[variant::toIndex(variant)];
		M_ASSERT(m_leader);
	}
}


void
MultiCursor::replace(db::Database* database)
{
	m_base->replace(database);
}


void
MultiCursor::famChanged()
{
	// TODO
}


void
MultiCursor::famDeleted()
{
	// TODO
}

// vi:set ts=3 sw=3:
