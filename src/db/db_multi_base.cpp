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
#include "u_zstream.h"
#include "u_misc.h"

#include "sys_time.h"
#include "sys_file.h"
#include "sys_utf8_codec.h"

#include "m_auto_ptr.h"
#include "m_utility.h"
#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;
using namespace util;

enum { ChunkSize = 65536 };


static unsigned
write(mstl::istream& src,
		mstl::ostream& dst,
		unsigned offset,
		unsigned size,
		Progress& progress,
		unsigned& reportAfter,
		unsigned frequency,
		unsigned count,
		unsigned numGames)
{
	char buf[ChunkSize];

	if (!src.seekg(offset, mstl::ios_base::beg))
		IO_RAISE(PgnFile, Corrupted, "unexpected end of file");

	unsigned bytesPerGame	= numGames ? (size + mstl::div2(size))/numGames : size;
	unsigned countBytes		= 0;
	unsigned counter			= count;

	while (size > 0)
	{
		if (reportAfter >= counter)
		{
			progress.update(counter);
			reportAfter += frequency;
		}

		unsigned bytes = mstl::min(size, unsigned(ChunkSize));

		if (!src.read(buf, bytes))
			IO_RAISE(PgnFile, Corrupted, "unexpected end of file");

		if (!dst.write(buf, bytes))
			IO_RAISE(PgnFile, Write_Failed, "error while writing PGN file");

		size -= bytes;
		countBytes += bytes;
		counter = countBytes/bytesPerGame;
	}

	count += numGames;

	if (reportAfter >= count)
	{
		progress.update(counter);
		reportAfter += frequency;
	}

	return count;
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


mstl::string const&
MultiBase::name() const
{
	return m_leader->name();
}


bool
MultiBase::isEmpty(unsigned variantIndex) const
{
	return m_bases[variantIndex] == 0 || m_bases[variantIndex]->countGames() == 0;
}


bool
MultiBase::descriptionHasChanged() const
{
	return m_leader->descriptionHasChanged();
}


bool
MultiBase::isUnsaved(unsigned variantIndex) const
{
	Database const* base = m_bases[variantIndex];
	return base != 0 && (base->hasChanged());
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
MultiBase::isUnsaved() const
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (isUnsaved(i))
			return true;
	}

	return false;
}


unsigned
MultiBase::countGames(Mode mode) const
{
	unsigned total = 0;

	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (Database const* base = m_bases[i])
		{
			switch (mode)
			{
				case Changed:	total += base->statistic().changed; break;
				case Added:		total += base->statistic().added; break;
				case Deleted:	total += base->statistic().deleted; break;
			}
		}
	}

	return total;
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
	mstl::string ext = util::misc::file::suffix(m_leader->name());
	bool isReadonly = true;

	if (ext == "pgn" || ext == "PGN" || ext == "gz")
	{
		isReadonly = !sys::file::access(m_leader->name(), sys::file::Writeable);
		delete m_fileOffsets;
		m_fileOffsets = fileOffsets;
	}

	m_leader->setReadonly(isReadonly);
	m_leader->setWritable(!isReadonly && m_fileOffsets != 0);
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
MultiBase::resetInitialSize()
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
	{
		if (Database* database = m_bases[i])
			database->resetInitialSize();
	}
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

					if (count)
						(*count)[i] = cnt;

					base->setEncodingFailed(producer.encodingFailed());
				}
			}
		}
	}

	return n;
}


void
MultiBase::save(util::Progress& progress)
{
	for (unsigned variant = 0; variant < variant::NumberOfVariants; ++variant)
	{
		if (Database* database = m_bases[variant])
			database->save(progress);
	}
}


file::State
MultiBase::save(mstl::string const& encoding, unsigned flags, util::Progress& progress)
{
	enum { Unchanged, Changed, Deleted, Added };

	M_REQUIRE(isTextFile());

	if (!isUnsaved())
		return file::IsUpTodate;

	M_ASSERT(m_fileOffsets);

	if (!sys::file::access(m_leader->name(), sys::file::Existence))
		return file::IsRemoved;

	if (!sys::file::access(m_leader->name(), sys::file::Writeable))
		return file::IsReadonly;

	if (!m_leader->checkFileTime())
		return file::HasChanged;

	unsigned changedGames	= 0;
	unsigned deletedGames	= 0;
	unsigned addedGames		= 0;

	for (unsigned variant = 0; variant < variant::NumberOfVariants; ++variant)
	{
		if (Database* database = m_bases[variant])
		{
			changedGames += database->statistic().changed;
			deletedGames += database->statistic().deleted;
			addedGames += database->statistic().added;
		}
	}

	unsigned totalGames = m_fileOffsets->countGames() + addedGames - deletedGames;

	mstl::auto_ptr<ZStream> ostrm;
	mstl::auto_ptr<PgnWriter> writer;
	mstl::string internalName(sys::file::internalName(m_leader->name()));
	mstl::auto_ptr<FileOffsets> newFileOffsets(new FileOffsets);
	mstl::string ext(misc::file::suffix(m_leader->name()));
	mstl::string myEncoding(encoding);
	ext.tolower();
	M_ASSERT(ext == "pgn" || ext == "gz");
	ZStream::Type fileType = ext == "gz" ? ZStream::GZip : ZStream::Text;

	unsigned nextIndex[variant::NumberOfVariants];
	::memset(nextIndex, 0, sizeof(nextIndex));

	bool newFile = changedGames > 0 || deletedGames > 0 || m_leader->descriptionHasChanged();
	unsigned numberOfGamesToWrite = newFile ? totalGames : addedGames;

	util::ProgressWatcher watcher(progress, numberOfGamesToWrite);

	unsigned frequency	= mstl::min(1000u, mstl::max(numberOfGamesToWrite/100, 1u));
	unsigned reportAfter	= frequency;
	unsigned count			= 0;

	if (ZStream::testByteOrderMark(internalName))
	{
		flags |= PgnWriter::Flag_Use_UTF8;
		myEncoding = sys::utf8::Codec::utf8();
	}
	else
	{
		flags &= ~PgnWriter::Flag_Use_UTF8;

		if (myEncoding == sys::utf8::Codec::utf8())
			myEncoding = sys::utf8::Codec::latin1();
	}

	PgnWriter::LineEnding lineEnding = PgnWriter::Unix;

	if (ZStream::isWindowsLineEnding(internalName))
		lineEnding = PgnWriter::Windows;

	if (newFile)
	{
		mstl::string tmpName(internalName + ".part");

		newFileOffsets.reset(new FileOffsets);
		newFileOffsets->reserve(m_fileOffsets->size() + addedGames - deletedGames);
		ostrm.reset(new ZStream(tmpName, fileType));

		if (!*ostrm)
			IO_RAISE(PgnFile, Create_Failed, "no permissions to create file");

		writer.reset(new PgnWriter(format::Scidb, *ostrm, encoding, lineEnding, flags));
		ZStream istrm(internalName);

		istrm.setBufsize(::ChunkSize);
		ostrm->setBufsize(::ChunkSize);

		if (m_leader->descriptionHasChanged())
		{
			if (unsigned n = m_leader->description().size())
			{
				mstl::string descr(m_leader->description());

				while (n > 78)
				{
					unsigned k = mstl::div2(n);

					while (k > 0 && !::isspace(descr[k]))
						--k;

					if (k == 0)
					{
						k = mstl::div2(n);
						while (k < n && !::isspace(descr[k]))
							++k;
					}

					ostrm->write("; ", 2);
					ostrm->writenl(descr.substr(0u, k));

					while (k < n && ::isspace(descr[k]))
						++k;
					descr.erase(mstl::string::size_type(0), mstl::string::size_type(k));
					n = descr.size();
				}

				if (n > 0)
				{
					ostrm->write("; ", 2);
					ostrm->writenl(descr);
				}

				ostrm->writenl(mstl::string::empty_string);
			}
		}
		else
		{
			FileOffsets::Offset const& offs = m_fileOffsets->get(0);

			if (offs.offset())
			{
				try
				{
					unsigned numGames = offs.isNumberOfSkippedGames() ? offs.skipped() : 0;

					count = ::write(	istrm,
											*ostrm,
											0,
											offs.offset(),
											progress,
											reportAfter,
											frequency,
											count,
											numGames);
				}
				catch (...)
				{
					sys::file::deleteIt(tmpName);
					throw;
				}
			}
		}

		unsigned n				= m_fileOffsets->size();
		unsigned lastIndex	= 0;
		unsigned nextState	= Added;

		if (n > 0)
		{
			FileOffsets::Offset const& offs = m_fileOffsets->get(0);

			if (!offs.isGameIndex())
				nextState = Unchanged;
			else if (m_bases[offs.variant()]->isDeleted(offs.gameIndex()))
				nextState = Deleted;
			else if (m_bases[offs.variant()]->hasChanged(offs.gameIndex()))
				nextState = Changed;
			else
				nextState = Unchanged;

			lastIndex = 1;
		}

		unsigned startIndex	= 0;
		unsigned prevState	= nextState;

		while (lastIndex <= n && nextState != Added)
		{
			if (lastIndex == n)
			{
				nextState = Added;
			}
			else
			{
				FileOffsets::Offset const& offs = m_fileOffsets->get(lastIndex);

				if (!offs.isGameIndex())
				{
					nextState = Unchanged;
				}
				else if (m_bases[offs.variant()]->isDeleted(offs.gameIndex()))
				{
					nextState = Deleted;
					nextIndex[offs.variant()] = offs.gameIndex() + 1;
				}
				else
				{
					nextState = m_bases[offs.variant()]->hasChanged(offs.gameIndex()) ? Changed : Unchanged;
					nextIndex[offs.variant()] = offs.gameIndex() + 1;
				}
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
						unsigned offs		= ostrm->tellp();
						unsigned numGames	= 0;

						FileOffsets::Offset const* currOffs = &m_fileOffsets->get(startIndex);

						newFileOffsets->append(offs, *currOffs);

						for (unsigned index = startIndex + 1; index < lastIndex; ++index)
						{
							FileOffsets::Offset const* nextOffs = &m_fileOffsets->get(index);
							offs += nextOffs->offset() - currOffs->offset();
							newFileOffsets->append(offs, *nextOffs);
							numGames += currOffs->gameCount();
							currOffs = nextOffs;
						}

						try
						{
							unsigned startOffs	= m_fileOffsets->get(startIndex).offset();
							unsigned endOffs		= m_fileOffsets->get(lastIndex).offset();

							count = ::write(	istrm,
													*ostrm,
													startOffs,
													endOffs - startOffs,
													progress,
													reportAfter,
													frequency,
													count,
													numGames);
						}
						catch (...)
						{
							sys::file::deleteIt(tmpName);
							throw;
						}
						break;
					}

					case Changed:
						for ( ; startIndex < lastIndex; ++startIndex)
						{
							if (reportAfter == count++)
							{
								progress.update(count);
								reportAfter += frequency;
							}

							FileOffsets::Offset const& offs = m_fileOffsets->get(startIndex);
							newFileOffsets->append(ostrm->tellp(), offs);
							Database* database = m_bases[offs.variant()];
							writer->setupVariant(variant::fromIndex(offs.variant()));
							database->exportGame(offs.gameIndex(), *writer); // always returning save::Ok
						}
						break;
				}

				startIndex = lastIndex++;
				prevState = nextState;
			}
		}

		istrm.close();
	}
	else
	{
		ostrm.reset(new ZStream(internalName, fileType, mstl::ofstream::app));
		writer.reset(new PgnWriter(format::Scidb, *ostrm, encoding, lineEnding, flags));
		ostrm->writenl(mstl::string::empty_string);
		newFileOffsets.reset(new FileOffsets(*m_fileOffsets));
	}

	for (unsigned variant = 0; variant < variant::NumberOfVariants; ++variant)
	{
		if (Database* database = m_bases[variant])
		{
			unsigned n = database->countGames();

			writer->setupVariant(variant::fromIndex(variant));

			for (unsigned index = nextIndex[variant]; index < n; ++index)
			{
				newFileOffsets->append(ostrm->tellp(), variant, index);
				database->exportGame(index, *writer); // always returning save::Ok
			}
		}
	}

	newFileOffsets->append(ostrm->tellp());
	ostrm->close();
	writer.release();
	if (ostrm->filename() != internalName)
		sys::file::rename(ostrm->filename(), m_leader->name());

	for (unsigned variant = 0; variant < variant::NumberOfVariants; ++variant)
	{
		if (Database* database = m_bases[variant])
			database->resetChangedStatus();
	}

	delete m_fileOffsets;
	m_fileOffsets = newFileOffsets.release();

	return file::Updated;
}

// vi:set ts=3 sw=3:
