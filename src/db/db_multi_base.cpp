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
#include "db_pgn_writer.h"
#include "db_exception.h"

#include "sci_codec.h"
#include "sci_consumer.h"

#include "u_progress.h"

#include "sys_time.h"

#include "m_ofstream.h"
#include "m_ifstream.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;

enum { ChunkSize = 65536 };


static void
write(mstl::istream& src, mstl::ostream& dst, unsigned offset, unsigned size)
{
	char buf[ChunkSize];

	if (!src.seekg(offset, mstl::ios_base::beg))
		IO_RAISE(PgnFile, Corrupted, "unexpected end of file");

	while (size > 0)
	{
		unsigned bytes = mstl::min(size, unsigned(ChunkSize));

		if (!src.read(buf, bytes))
			IO_RAISE(PgnFile, Corrupted, "unexpected end of file");

		if (!dst.write(buf, bytes))
			IO_RAISE(PgnFile, Write_Failed, "error while writing PGN file");

		size -= bytes;
	}
}


MultiBase::MultiBase(mstl::string const& name,
							mstl::string const& encoding,
							variant::Type variant,
							storage::Type storage,
							Type type)
	:m_singleBase(variant != variant::Undetermined)
	,m_fileOffsets(0)
{
	M_REQUIRE(variant == variant::Undetermined || variant::isMainVariant(variant));

	::memset(m_bases, 0, sizeof(m_bases));

	if (variant == variant::Undetermined)
	{
		m_bases[variant::Index_Normal] = m_leader = new Database(
			name, encoding, storage, variant::Normal, type);
		m_bases[variant::Index_Crazyhouse] = new Database(
			name, encoding, storage, variant::Crazyhouse, type);
		m_bases[variant::Index_Bughouse] = new Database(
			name, encoding, storage, variant::Bughouse, type);
		m_bases[variant::Index_ThreeCheck] = new Database(
			name, encoding, storage, variant::ThreeCheck, type);
		m_bases[variant::Index_Antichess] = new Database(
			name, encoding, storage, variant::Antichess, type);
		m_bases[variant::Index_Losers] = new Database(
			name, encoding, storage, variant::Losers, type);
	}
	else
	{
		mstl::auto_ptr<Database> database(new Database(name, encoding, storage, variant, type));
		m_bases[variant::toIndex(variant)] = m_leader = database.get();
		database.release();
	}
}


MultiBase::MultiBase(mstl::string const& name,
							mstl::string const& encoding,
							permission::ReadMode mode,
							util::Progress& progress)
	:m_singleBase(true)
	,m_fileOffsets(0)
{
	::memset(m_bases, 0, sizeof(m_bases));
	mstl::auto_ptr<Database> database(new Database(name, encoding, mode, progress));
	m_bases[variant::toIndex(database->variant())] = m_leader = database.get();
	database.release();
}


MultiBase::~MultiBase()
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
		delete m_bases[i];

	delete m_fileOffsets;
}


bool
MultiBase::isEmpty(unsigned variantIndex) const
{
	return m_bases[variantIndex] == 0 || m_bases[variantIndex]->countGames() == 0;
}


bool
MultiBase::hasChanged(unsigned variantIndex) const
{
	return m_bases[variantIndex] != 0 && m_bases[variantIndex]->hasChanged();
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


bool
MultiBase::hasChanged() const
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (hasChanged(i))
			return true;
	}

	return false;
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
MultiBase::setup(FileOffsets* fileOffsets)
{
	delete m_fileOffsets;
	m_fileOffsets = fileOffsets;
	m_leader->setWritable(m_fileOffsets != 0);
}


void
MultiBase::changeVariant(variant::Type variant)
{
	M_REQUIRE(variant::isMainVariant(variant));
	M_REQUIRE(isEmpty());

	if (isSingleBase())
		m_leader->setVariant(variant);
}


void
MultiBase::replace(Database* database)
{
	M_REQUIRE(database);
	M_REQUIRE(exists(database->variant()));

	unsigned variantIndex = variant::toIndex(database->variant());

	if (m_leader == m_bases[variantIndex])
		m_leader = database;

	m_bases[variantIndex]->close();
	delete m_bases[variantIndex];

	m_bases[variantIndex] = database;
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


save::State
MultiBase::save(mstl::string const& encoding, unsigned flags, util::Progress& progress)
{
	enum { Unchanged, Changed, Deleted, New };

	M_REQUIRE(isTextFile());

	if (!hasChanged())
		return save::Ok;

	M_ASSERT(m_fileOffsets);

	if (!m_leader->checkFileTime())
		IO_RAISE(PgnFile, Not_Original_Version, "PGN file has changed");

	mstl::string tmpName(m_leader->name() + ".part");
	mstl::ofstream ostrm(tmpName);
	mstl::ifstream istrm(m_leader->name());
	mstl::auto_ptr<FileOffsets> newFileOffsets(new FileOffsets);

	istrm.set_bufsize(::ChunkSize);
	ostrm.set_bufsize(::ChunkSize);

	if (m_leader->descriptionHasChanged())
	{
		if (unsigned n = m_leader->description().size())
		{
			mstl::string descr(m_leader->description());

			while (n > 78)
			{
				unsigned k = n/2;

				while (k > 0 && !::isspace(descr[k]))
					--k;

				if (k == 0)
				{
					k = n/2;
					while (k < n && !::isspace(descr[k]))
						++k;
				}

				ostrm.write("; ", 2);
				ostrm.writenl(descr.substr(0u, k));

				while (k < n && ::isspace(descr[k]))
					++k;
				descr.erase(mstl::string::size_type(0), mstl::string::size_type(k));
				n = descr.size();
			}

			if (n > 0)
			{
				ostrm.write("; ", 2);
				ostrm.writenl(descr);
			}

			ostrm.writenl(mstl::string::empty_string);
		}
	}
	else if (unsigned n = m_fileOffsets->get(0).offset())
	{
		::write(istrm, ostrm, 0, n);
	}

	newFileOffsets->append(ostrm.tellp() + 1);

	unsigned n				= m_fileOffsets->size();
	unsigned lastIndex	= 0;
	unsigned prevState	= New;
	unsigned nextState	= New;

	if (n > 0)
	{
		FileOffsets::Offset const& offs = m_fileOffsets->get(0);

		if (!offs.isGameIndex())
			prevState = Unchanged;
		else if (m_bases[offs.variant()]->isDeleted(offs.gameIndex()))
			prevState = Deleted;
		else if (m_bases[offs.variant()]->hasChanged(offs.gameIndex()))
			prevState = Changed;
		else
			prevState = Unchanged;

		lastIndex = 1;
	}

	PgnWriter writer(format::Scidb, ostrm, encoding, flags);

	unsigned startIndex = 0;

	while (lastIndex <= n && nextState != New)
	{
		if (lastIndex == n)
		{
			nextState = New;
		}
		else
		{
			FileOffsets::Offset const& offs = m_fileOffsets->get(lastIndex);

			if (!offs.isGameIndex())
				nextState = Unchanged;
			else if (m_bases[offs.variant()]->isDeleted(offs.gameIndex()))
				nextState = Deleted;
			else if (m_bases[offs.variant()]->hasChanged(offs.gameIndex()))
				nextState = Changed;
			else
				nextState = Unchanged;
		}

		if (prevState == nextState)
		{
			++lastIndex;
		}
		else
		{
			switch (prevState)
			{
				case Unchanged:
				{
					unsigned startOffs = m_fileOffsets->get(startIndex).offset();
					unsigned endOffs = m_fileOffsets->get(lastIndex).offset();
					::write(istrm, ostrm, startOffs, endOffs - startOffs);
					startIndex = lastIndex;
					break;
				}

				case Changed:
					for ( ; startIndex < lastIndex; ++startIndex)
					{
						FileOffsets::Offset const& offs = m_fileOffsets->get(startIndex);
						Database* database = m_bases[offs.variant()];
						writer.setupVariant(variant::fromIndex(offs.variant()));
						save::State state = database->exportGame(offs.gameIndex(), writer);

						if (state != save::Ok)
						{
							// TODO: finish
							return state;
						}
					}
					break;

				case Deleted:
					startIndex = lastIndex;
					break;
			}

			prevState = nextState;
		}
	}

	// export new games

	return save::Ok;
}

// vi:set ts=3 sw=3:
