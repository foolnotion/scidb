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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_database.h"
#include "db_database_codec.h"
#include "db_reader.h"
#include "db_exception.h"
#include "db_game_info.h"
#include "db_game.h"
#include "db_tag_set.h"
#include "db_consumer.h"
#include "db_producer.h"
#include "db_eco_table.h"
#include "db_tournament_table.h"
#include "db_player_stats.h"
#include "db_filter.h"
#include "db_selector.h"
#include "db_query.h"
#include "db_search.h"
#include "db_log.h"

#include "si3_codec.h"
#include "si3_consumer.h"

#include "sci_codec.h"
#include "sci_consumer.h"

#include "u_block_file.h"
#include "u_progress.h"
#include "u_misc.h"
#include "u_crc.h"

#include "sys_utf8_codec.h"
#include "sys_time.h"
#include "sys_file.h"

#include "m_assert.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_ifstream.h"
#include "m_auto_ptr.h"
#include "m_stdio.h"
#include "m_map.h"

using namespace db;
using namespace sys;
using namespace util;


namespace {

struct SingleProgress : public util::Progress
{
	SingleProgress() { setFrequency(1); }
	bool interrupted() { return true; }
};

} // namespace


static unsigned Counter = 0;


template
unsigned
Database::exportGames<Database>(	Database& destination,
											Filter const& gameFilter,
											Selector const& gameSelector,
											copy::Mode copyMode,
											unsigned& illegalRejected,
											Log& log,
											util::Progress& progress) const;
template
unsigned
Database::exportGames<Consumer>(	Consumer& destination,
											Filter const& gameFilter,
											Selector const& gameSelector,
											copy::Mode copyMode,
											unsigned& illegalRejected,
											Log& log,
											util::Progress& progress) const;


Database::Database(Database const& db, mstl::string const& name)
	:DatabaseContent(name, db)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::New))
	,m_name(name)
	,m_id(Counter++)
	,m_size(0)
	,m_initialSize(0)
	,m_lastChange(sys::time::timestamp())
	,m_fileTime(0)
	,m_asyncReader(0)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_descriptionHasChanged(false)
	,m_usingAsyncReader(false)
{
	try
	{
		m_codec->open(this, m_encoding);
		::sys::file::changed(m_name, m_fileTime);
	}
	catch (mstl::ios_base::failure const& exc)
	{
		IO_RAISE(Unspecified, Create_Failed, "no permissions to create file");
	}
}


Database::Database(mstl::string const& name, mstl::string const& encoding)
	:DatabaseContent(name, encoding, type::Unspecific)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::Existing))
	,m_name(name)
	,m_id(Counter++)
	,m_size(0)
	,m_initialSize(0)
	,m_lastChange(sys::time::timestamp())
	,m_fileTime(0)
	,m_asyncReader(0)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_descriptionHasChanged(false)
	,m_usingAsyncReader(false)
{
	M_ASSERT(m_codec);

	// NOTE: we assume normalized (unique) file names.

	m_memoryOnly = false;
	m_temporary = true;
	m_created = sys::time::time();
	m_readOnly = true;
	m_writable = false;
	m_initialSize = m_size = m_codec->openProgressive(this, encoding);
	m_namebases.setModified(true);
}


Database::Database(	mstl::string const& name,
							mstl::string const& encoding,
							storage::Type storage,
							variant::Type variant,
							Type type)
	:DatabaseContent(name, encoding, type)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::New))
	,m_name(name)
	,m_id(Counter++)
	,m_size(0)
	,m_initialSize(0)
	,m_lastChange(sys::time::timestamp())
	,m_fileTime(0)
	,m_asyncReader(0)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_descriptionHasChanged(false)
	,m_usingAsyncReader(false)
{
	M_REQUIRE(storage != storage::Temporary);
	M_REQUIRE(variant::isMainVariant(variant));

	M_ASSERT(m_codec);

	// NOTE: we assume normalized (unique) file names.

	m_memoryOnly = storage == storage::MemoryOnly;
	m_temporary = false;
	m_created = sys::time::time();
	m_readOnly = m_temporary;

	switch (m_codec->format())
	{
		case format::Scidb:			m_variant = variant; break;
		case format::Scid3:			// fallthru
		case format::Scid4:			// fallthru
		case format::ChessBase:		// fallthru
		case format::ChessBaseDOS:	m_variant = variant::Normal; break;

		default: M_ASSERT(!"unexpected format");
	}

	if (!m_codec->isWritable())
		m_writable = false;

	try
	{
		m_codec->open(this, encoding);
	}
	catch (mstl::ios_base::failure const& exc)
	{
		IO_RAISE(Unspecified, Open_Failed, "create failed");
	}

	m_initialSize = m_size = m_gameInfoList.size();
	m_namebases.setModified(true);
	::sys::file::changed(m_name, m_fileTime);
}


Database::Database(	mstl::string const& name,
							mstl::string const& encoding,
							permission::ReadMode mode,
							util::Progress& progress)
	:DatabaseContent(name, encoding)
	,m_codec(0)
	,m_name(name)
	,m_id(Counter++)
	,m_size(0)
	,m_initialSize(0)
	,m_lastChange(sys::time::timestamp())
	,m_fileTime(0)
	,m_asyncReader(0)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_descriptionHasChanged(false)
	,m_usingAsyncReader(false)
{
	M_REQUIRE(misc::file::hasSuffix(name));
	M_REQUIRE(misc::file::suffix(m_name) == "sci" || mode == permission::ReadOnly);

	// NOTE: we assume normalized (unique) file names.

	m_readOnly = mode == permission::ReadOnly;
	m_codec = DatabaseCodec::makeCodec(m_name, DatabaseCodec::Existing);

	if (m_codec == 0)
	{
		if (m_suffix.empty())
			DB_RAISE("no file suffix given");

		DB_RAISE("unknown file format (.%s)", m_suffix.c_str());
	}

	if (!m_codec->isWritable())
		m_writable = false;

	try
	{
		m_codec->open(this, m_encoding, progress);
	}
	catch (mstl::ios_base::failure const& exc)
	{
		IO_RAISE(Unspecified, Open_Failed, "open failed");
	}

	m_initialSize = m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
	::sys::file::changed(m_name, m_fileTime);

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


Database::Database(mstl::string const& name, Producer& producer, util::Progress& progress)
	:DatabaseContent(name, producer.encoding())
	,m_codec(0)
	,m_name(name)
	,m_id(Counter++)
	,m_size(0)
	,m_initialSize(0)
	,m_lastChange(sys::time::timestamp())
	,m_fileTime(0)
	,m_asyncReader(0)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_descriptionHasChanged(false)
	,m_usingAsyncReader(false)
{
	// NOTE: we assume normalized (unique) file names.

	m_created = sys::time::time();
	m_codec = DatabaseCodec::makeCodec(name, DatabaseCodec::Existing);
	M_ASSERT(m_codec->isWritable());

	try
	{
		m_codec->open(this, sys::utf8::Codec::utf8(), producer, progress);
	}
	catch (mstl::ios_base::failure const& exc)
	{
		IO_RAISE(Unspecified, Open_Failed, "open failed");
	}

	m_initialSize = m_size = m_gameInfoList.size();
	m_readOnly = true;
	setEncodingFailed(producer.encodingFailed());
	::sys::file::changed(m_name, m_fileTime);

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


Database::~Database() throw()
{
	if (m_asyncReader)
		m_codec->closeAsyncReader(m_asyncReader);

	delete m_codec;
}


bool
Database::isDeleted(unsigned index) const
{
	return gameInfo(index).isDeleted();
}


bool
Database::hasChanged(unsigned index) const
{
	return gameInfo(index).isChanged();
}


bool
Database::hasChanged() const
{
	return	m_memoryOnly
			&& (	m_descriptionHasChanged
				|| m_statistic.deleted + m_statistic.changed + m_statistic.added > 0);
}


bool
Database::checkFileTime() const
{
	uint32_t fileTime;

	if (!::sys::file::changed(m_name, fileTime))
		return false;

	return fileTime == m_fileTime;
}


void
Database::resetChangedStatus()
{
	::sys::file::changed(m_name, m_fileTime);
	m_descriptionHasChanged = false;
	m_initialSize = m_size;

	for (unsigned i = 0; i < m_gameInfoList.size(); ++i)
		m_gameInfoList[i]->setUnchanged();

	m_statistic.added = 0;
	m_statistic.changed = 0;
}


void
Database::resetInitialSize(unsigned size)
{
	M_REQUIRE(size <= countGames());

	m_initialSize = size;
	m_statistic.added = m_size - size;
}


unsigned
Database::count(table::Type type) const
{
	switch (type)
	{
		case table::Games:		return countGames();
		case table::Annotators:	return countAnnotators();
		case table::Players:		return m_namebases(Namebase::Player).used();
		case table::Events:		return m_namebases(Namebase::Event).used();
		case table::Sites:		return m_namebases(Namebase::Site).used();
	}

	return 0; // satisifes the compiler
}


void
Database::attach(mstl::string const& filename, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly());
	M_REQUIRE(codec().extension() == misc::file::suffix(filename));
	M_REQUIRE(!usingAsyncReader());

	// NOTE: we assume normalized (unique) file names.

	m_rootname = misc::file::rootname(filename);
	m_codec->attach(progress);
	M_ASSERT(m_codec->isWritable());
	::sys::file::changed(m_name, m_fileTime);
	m_readOnly = false;
	m_memoryOnly = false;
}


void
Database::save(util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly() || !isReadonly());
	M_REQUIRE(isMemoryOnly() || isWritable());
	M_REQUIRE(!usingAsyncReader());

	if (m_size == m_gameInfoList.size())
		return;

	unsigned start = m_size;

	m_namebases.update();
	setEncodingFailed(m_codec->encodingFailed());

	if (!isMemoryOnly())
	{
		m_codec->reset();
		m_codec->save(start, progress);
		m_codec->updateHeader();
		::sys::file::changed(m_name, m_fileTime);
	}

	m_size = m_gameInfoList.size();
	m_lastChange = sys::time::timestamp();
	m_treeCache.setIncomplete(start);

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin() + start,
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								start == 0 ? Statistic::Reset : Statistic::Continue);
	m_statistic.added = m_size - m_initialSize;
}


void
Database::compact(Database &destination, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isMemoryOnly());

	unsigned numGames		= countGames();
	unsigned frequency	= progress.frequency(numGames, 5000);
	unsigned reportAfter	= frequency;

	util::ProgressWatcher watcher(progress, numGames);

	progress.start(numGames);

	for (unsigned i = 0; i < numGames; ++i)
	{
		if (reportAfter == i)
		{
			progress.update(i);
			reportAfter += frequency;
		}

		if (!m_gameInfoList[i]->isDeleted())
		{
			save::State state = exportGame(i, destination);

			if (!save::isOk(state))
			{
				// The following errors cannot happen, but we want to be sure:
				switch (state)
				{
					case save::Ok:
						break;

					case save::UnsupportedVariant:
					case save::DecodingFailed:
					case save::GameTooLong:
					case save::TooManyAnnotatorNames:
						// skip non-fatal errors
						break;

					case save::FileSizeExeeded:
					case save::TooManyGames:
					case save::TooManyPlayerNames:
					case save::TooManyEventNames:
					case save::TooManySiteNames:
					case save::TooManyRoundNames:
						M_THROW(Exception("Compression failed: save state %d", int(state)));
						break;
				}
			}
		}
	}

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}



void
Database::compact(util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly());
	M_REQUIRE(!isReadonly());

	unsigned numGames		= countGames();
	unsigned frequency	= progress.frequency(numGames, 20000);
	unsigned reportAfter	= frequency;

	M_ASSERT(dynamic_cast<sci::Codec*>(m_codec));
	static_cast<sci::Codec*>(m_codec)->compact(progress);

	util::ProgressWatcher watcher(progress, numGames);
	progress.start(numGames);

	GameInfoList newList;
	newList.reserve(numGames - m_statistic.deleted);

	for (unsigned i = 0; i < numGames; ++i)
	{
		if (reportAfter == i)
		{
			progress.update(i);
			reportAfter += frequency;
		}

		if (!m_gameInfoList[i]->isDeleted())
			newList.push_back(m_gameInfoList[i]);
	}

	m_gameInfoList.swap(newList);
	m_size = m_gameInfoList.size();
	m_statistic.deleted = 0;

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


void
Database::writeIndex(mstl::ostream& os, util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(!isReadonly());
	M_REQUIRE(!isMemoryOnly());

	m_namebases.update();
	m_codec->reset();
	m_codec->writeIndex(os, progress);
	::sys::file::changed(m_name, m_fileTime);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::writeNamebases(mstl::ostream& os, util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(!isReadonly());
	M_REQUIRE(!isMemoryOnly());

	m_namebases.update();
	m_codec->reset();
	m_codec->writeNamebases(os, progress);
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::writeGames(mstl::ostream& os, util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(!isReadonly());
	M_REQUIRE(!isMemoryOnly());
	M_REQUIRE(!usingAsyncReader());

	m_namebases.update();
	m_codec->reset();
	m_codec->writeGames(os, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::sync(util::Progress& progress)
{
	if (m_codec && !isMemoryOnly() && !m_readOnly && m_writable)
	{
		if (m_size != m_gameInfoList.size())
			save(progress);

		m_codec->sync();
	}
}


void
Database::close()
{
	M_REQUIRE(!usingAsyncReader());

	if (m_codec)
	{
		util::Progress progress;
		sync(progress);

		m_codec->close();
		delete m_codec;
		m_codec = 0;
	}
}


void
Database::remove()
{
	M_REQUIRE(format() == format::Scidb || format() == format::Scid3 || format() == format::Scid4);
	M_REQUIRE(!usingAsyncReader());

	if (m_codec)
		m_codec->close(); // we don't need sync()

	if (!isMemoryOnly())
		m_codec->removeAllFiles();

	if (m_codec)
	{
		delete m_codec;
		m_codec = 0;
	}
}


bool
Database::shouldCompact() const
{
	return !isReadonly() && format() == format::Scidb && (m_shouldCompact || m_statistic.deleted > 0);
}


void
Database::getTags(unsigned index, TagSet& tags, bool invert) const
{
	M_ASSERT(isOpen());
	M_ASSERT(index < countGames());

	tags.clear();
	setupTags(index, tags);

	GameInfo const& info = gameInfo(index);

	rating::Type whiteRatingType = info.ratingType(color::White);
	rating::Type blackRatingType = info.ratingType(color::Black);

	tag::TagSet infoTags = m_codec->tagFilter(
										invert ? DatabaseCodec::InfoTags : DatabaseCodec::GameTags,
										tags);

	if (whiteRatingType != rating::Any)
		infoTags.set(rating::toWhiteTag(whiteRatingType));
	if (blackRatingType != rating::Any)
		infoTags.set(rating::toBlackTag(blackRatingType));
	if (invert)
		infoTags.flip(0, tag::LastTag);

	tags.remove(infoTags);
}


void
Database::getInfoTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	return getTags(index, tags, true);
}


void
Database::getGameTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	return getTags(index, tags, false);
}


void
Database::clear()
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());

	m_gameInfoList.clear();
	m_statistic.clear();
	m_namebases.clear();
	m_allocator.clear();
	m_encodingFailed = false;
	m_encodingOk = true;
	m_size = 0;
	m_initialSize = 0;
	m_lastChange = sys::time::timestamp();
	m_codec->reset();
	m_treeCache.clear();
	m_codec->clear();
}


void
Database::reopen(mstl::string const& encoding, util::Progress& progress)
{
	M_REQUIRE(misc::file::hasSuffix(name()));
	M_REQUIRE(!isMemoryOnly());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(!hasTemporaryStorage());

	m_gameInfoList.clear();
	m_namebases.clear();
	m_allocator.clear();
	m_treeCache.clear();
	m_encodingFailed = false;
	m_encodingOk = true;
	m_size = 0;
	m_initialSize = 0;
	m_lastChange = sys::time::timestamp();
	m_encoding = encoding;

	delete m_codec;

	m_codec = DatabaseCodec::makeCodec(m_name, DatabaseCodec::Existing);
	M_ASSERT(m_codec);

	try
	{
		m_codec->open(this, m_encoding, progress);
	}
	catch (mstl::ios_base::failure const& exc)
	{
		IO_RAISE(Unspecified, Open_Failed, "re-open failed");
	}

	m_initialSize = m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
	::sys::file::changed(m_name, m_fileTime);
}


util::crc::checksum_t
Database::computeChecksum(unsigned index) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	GameInfo const& info = *m_gameInfoList[index];
	util::crc::checksum_t crc = m_codec->computeChecksum(info, info.computeChecksum());

	crc = ::util::crc::compute(crc, uint32_t(m_variant));

	if (format::isScidFormat(format()))
	{
		mstl::string const& round = static_cast<si3::Codec*>(m_codec)->getRoundEntry(index);
		crc = ::util::crc::compute(crc, round, round.size());
	}

	return crc;
}


load::State
Database::loadGame(unsigned index, Game& game, mstl::string* encoding, mstl::string const* fen)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	GameInfo* info = m_gameInfoList[index];
	m_codec->reset();

	if (encoding)
		*encoding = this->encoding();

	variant::Type variant;

	if (m_variant == variant::Antichess)
		variant = info->isGiveaway() ? variant::Giveaway : variant::Suicide;
	else
		variant = m_variant;

	try
	{
		m_codec->decodeGame(game, *info, index, encoding);
	}
	catch (DecodingFailedException const& exc)
	{
		return load::Failed;
	}
	catch (ByteStream::UnexpectedEndOfStreamException const& exc)
	{
		IO_RAISE(Game, Corrupted, exc.backtrace(), "unexpected end of stream");
//		return load::Corrupted;
	}

	setEncodingFailed(m_codec->encodingFailed());
	game.moveToMainlineStart();
	load::State state = game.finishLoad(variant, fen) ? load::Ok : load::Corrupted;
	setupTags(index, game.m_tags);

	return state;
}


save::State
Database::newGame(Game& game, GameInfo const& info)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(isMemoryOnly());
	M_REQUIRE(game.variant() != variant::Undetermined);
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));
	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());
	save::State state = m_codec->addGame(strm, info, DatabaseCodec::Hook);
	m_namebases.update();

	if (save::isOk(state))
	{
		GameInfo* info = m_gameInfoList.back();

		info->setDirty(true);

		m_lastChange = sys::time::timestamp();
		m_statistic.add(*m_gameInfoList.back());
		m_statistic.added = m_size - m_initialSize;
	}

	return state;
}


save::State
Database::addGame(Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	if (format() != format::Scidb)
		game.removeFlags(GameInfo::Flag_Illegal_Castling | GameInfo::Flag_Illegal_Move);

	save::State state = m_codec->saveGame(strm, game.tags(), game);
	m_namebases.update();

	if (save::isOk(state))
	{
		if (!m_memoryOnly)
		{
			m_codec->update(m_gameInfoList.size() - 1, true);
			m_codec->updateHeader();
			::sys::file::changed(m_name, m_fileTime);
		}

		GameInfo* info = m_gameInfoList.back();

		info->setDirty(true);

		m_size = m_gameInfoList.size();
		m_lastChange = sys::time::timestamp();
		m_statistic.add(*m_gameInfoList.back());
		m_statistic.added = m_size - m_initialSize;
		m_treeCache.setIncomplete();
	}

	return state;
}


save::State
Database::updateGame(Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];

	ByteStream	strm(buffer, sizeof(buffer));
	GameInfo&	info(*m_gameInfoList[game.index()]);
	unsigned		offset(info.gameOffset());

	if (format() == format::Scidb)
	{
		if (!variant::isAntichessExceptLosers(m_variant))
			info.setIllegalCastling(game.containsIllegalCastlings());

		info.setIllegalMove(game.containsIllegalMoves());
	}

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());
	game.setGameFlags(info.flags());

	save::State state = m_codec->saveGame(strm, game.tags(), game);

	m_namebases.update();

	if (save::isOk(state))
	{
		if (!m_memoryOnly)
			m_codec->update(game.index(), true);

		if (format() == format::Scidb && offset != info.gameOffset())
		{
			m_shouldCompact = true;

			if (!m_memoryOnly)
				m_codec->updateHeader();
		}

		if (!m_memoryOnly)
			::sys::file::changed(m_name, m_fileTime);

		if (unsigned(game.index()) < m_initialSize && !info.isChanged())
		{
			++m_statistic.changed;
			info.setChanged(true);
		}

		info.setDirty(false);
		game.setGameFlags(info.flags());
		m_lastChange = sys::time::timestamp();
		m_treeCache.setIncomplete(game.index());

		m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
									const_cast<GameInfoList const&>(m_gameInfoList).end(),
									Statistic::Reset);
	}

	return state;
}


save::State
Database::updateMoves(Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	GameInfo&	info		= *m_gameInfoList[game.index()];
	unsigned		offset	= info.gameOffset();
	save::State	state		= m_codec->saveMoves(strm, game);

	if (save::isOk(state))
	{
		if (format() == format::Scidb)
		{
			if (offset != info.gameOffset())
			{
				m_shouldCompact = true;

				if (!m_memoryOnly)
				{
					m_codec->updateHeader();
					::sys::file::changed(m_name, m_fileTime);
				}
			}

			bool illegalCastling	= game.containsIllegalCastlings();
			bool illegalMoves		= game.containsIllegalMoves();

			if (	illegalCastling != info.containsIllegalCastlings()
				|| illegalMoves != info.containsIllegalMoves())
			{
				info.setIllegalCastling(illegalCastling);
				info.setIllegalMove(illegalMoves);

				if (!m_memoryOnly)
					m_codec->update(game.index(), false);
			}
		}

		if (unsigned(game.index()) < m_initialSize && !info.isChanged())
		{
			++m_statistic.changed;
			info.setChanged(true);
		}

		info.setDirty(false);
		game.setGameFlags(info.flags());
		m_lastChange = sys::time::timestamp();
		m_treeCache.setIncomplete(game.index());
	}

	return state;
}


save::State
Database::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());

	save::State state = m_codec->updateCharacteristics(index, tags);

	m_namebases.update();

	if (save::isOk(state))
	{
		if (!m_memoryOnly)
		{
			m_codec->update(index, true);
			::sys::file::changed(m_name, m_fileTime);
		}

		GameInfo& info = *m_gameInfoList[index];

		if (index <= m_initialSize && !info.isChanged())
		{
			++m_statistic.changed;
			info.setChanged(true);
		}

		info.setDirty(false);
		m_lastChange = sys::time::timestamp();

		m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
									const_cast<GameInfoList const&>(m_gameInfoList).end(),
									Statistic::Reset);
	}

	return state;
}


save::State
Database::exportGame(unsigned index, Consumer& consumer) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());
	M_REQUIRE(consumer.variant() == variant());

	GameInfo const*	info = m_gameInfoList[index];
	TagSet				tags;

	setupTags(index, tags);

	if (!format::isScidFormat(consumer.format()) && format::isScidFormat(format()))
	{
		Reader::Tag tag;

		mstl::string s;
		mstl::string v;

		s = tags.value(tag::White);
		while ((tag = Reader::extractPlayerData(s, v)) != Reader::None)
		{
			switch (tag)
			{
				case Reader::Country:
					tags.add(tag::WhiteCountry, country::fromString(v));
					break;

				case Reader::Title:
					tags.add(tag::WhiteTitle, title::toString(title::fromString(v)));
					break;

				case Reader::Human:
					tags.add(tag::WhiteType, species::toString(species::Human));
					break;

				case Reader::Program:
					tags.add(tag::WhiteType, species::toString(species::Program));
					break;

				case Reader::Sex:
					tags.add(tag::WhiteSex, sex::toString(sex::fromString(v)));
					break;

				case Reader::Elo:
					tags.add(tag::WhiteElo, v);
					break;

				case Reader::None:
					break;
			}
		}
		tags.set(tag::White, s);

		s = tags.value(tag::Black);
		while ((tag = Reader::extractPlayerData(s, v)) != Reader::None)
		{
			switch (tag)
			{
				case Reader::Country:
					tags.add(tag::BlackCountry, country::fromString(v));
					break;

				case Reader::Title:
					tags.add(tag::BlackTitle, title::toString(title::fromString(v)));
					break;

				case Reader::Human:
					tags.add(tag::BlackType, species::toString(species::Human));
					break;

				case Reader::Program:
					tags.add(tag::BlackType, species::toString(species::Program));
					break;

				case Reader::Sex:
					tags.add(tag::BlackSex, sex::toString(sex::fromString(v)));
					break;

				case Reader::Elo:
					tags.add(tag::BlackElo, v);
					break;

				case Reader::None:
					break;
			}
		}
		tags.set(tag::Black, s);

		s = tags.value(tag::Site);
		country::Code code = Reader::extractCountryFromSite(s);
		if (code != country::Unknown)
		{
			tags.add(tag::EventCountry, country::toString(code));
			tags.set(tag::Site, s);
		}
	}

	save::State rc;

	m_codec->reset();
	consumer.setGameFlags(info->flags());

#ifdef DEBUG_SI4
	consumer.m_index = index;
#endif

	try
	{
		rc = m_codec->exportGame(consumer, tags, *info, index);
	}
	catch (DecodingFailedException const& exc)
	{
		rc = save::DecodingFailed;
	}

#ifdef DEBUG_SI4
//	if (	info->idn() == 518
//		&& !format::isChessBase(m_codec->format())
//		&& (format::isScidFormat/consumer.sourceFormat()))
//	{
//		Eco opening;
//		Eco eco = EcoTable::specimen().lookup(consumer.openingLine(), opening);
//
//		uint8_t myStoredLine = EcoTable::specimen().getStoredLine(info->ecoKey(), info->ecoOpening());
//		uint8_t storedLine = EcoTable::specimen().getStoredLine(eco, opening);
//
//		if (myStoredLine != storedLine)
//		{
//			mstl::string line;
//			consumer.openingLine().dump(line);
//
//			::fprintf(	stderr,
//							"WARNING(%u): unexpected stored line %u (%u is expected for line '%s')\n",
//							index,
//							unsigned(storedLine),
//							unsigned(myStoredLine),
//							line.c_str());
//		}
//	}
#endif

	setEncodingFailed(m_codec->encodingFailed());

	return rc;
}


save::State
Database::exportGame(unsigned index, Database& destination) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(destination.isOpen());
	M_REQUIRE(	destination.format() == format::Scidb
				|| destination.format() == format::Scid3
				|| destination.format() == format::Scid4);
	M_REQUIRE(index < countGames());

	GameInfo const&	info			= *m_gameInfoList[index];
	format::Type		srcFormat	= format();

	if (srcFormat == destination.format())
	{
		ByteStream data(m_codec->getGame(info));
		return destination.codec().addGame(data, info, DatabaseCodec::Alloc);
	}
	else
	{
		mstl::auto_ptr<Consumer> consumer(destination.codec().getConsumer(srcFormat));
		return exportGame(index, *consumer);
	}
}


unsigned
Database::copyGames(	Database& destination,
							Filter const& gameFilter,
							Selector const& gameSelector,
							TagBits const& allowedTags,
							bool allowExtraTags,
							unsigned& illegalRejected,
							Log& log,
							util::Progress& progress) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(destination.isOpen());
	M_REQUIRE(destination.isWritable());
	M_REQUIRE(!destination.usingAsyncReader());
	M_REQUIRE(	destination.format() == format::Scidb
				|| destination.format() == format::Scid3
				|| destination.format() == format::Scid4);
	M_REQUIRE(destination.variant() == variant());

	if (size() == 0)
		return 0;

	format::Type	dstFormat	= destination.format();
	format::Type	srcFormat	= format();
	bool				useConsumer	= true;
	copy::Mode		copyMode		= copy::AllGames;

	switch (int(dstFormat))
	{
		case format::Scid3:
		case format::Scid4:
			useConsumer = !format::isScidFormat(srcFormat);
			copyMode = copy::ExcludeIllegal;
			break;

		case format::Scidb:
			useConsumer = srcFormat != format::Scidb;
			copyMode = copy::AllGames;
			break;
	}

	unsigned count;

	if (!useConsumer && allowedTags.complete() && allowExtraTags)
	{
		// TODO: use this in any case (but !useConsumer), with
		// exportGames(..., allowedTags, allowExtraTags, ...)
		count = exportGames(	destination,
									gameFilter,
									gameSelector,
									copyMode,
									illegalRejected,
									log,
									progress);
	}
	else
	{
		if (dstFormat == format::Scidb)
		{
			sci::Consumer::Codecs codecs(&dynamic_cast<sci::Codec&>(destination.codec()));
			// XXX <we need the source encoding?
			sci::Consumer consumer(srcFormat, codecs, allowedTags, allowExtraTags);
			consumer.setupVariant(m_variant);
			count = exportGames(	consumer,
										gameFilter,
										gameSelector,
										copyMode,
										illegalRejected,
										log,
										progress);
		}
		else // dstFormat == format::Scid3 || dstFormat == format::Scid4
		{
			si3::Consumer consumer(	srcFormat,
											dynamic_cast<si3::Codec&>(destination.codec()),
											encoding(), // XXX do we need the source encoding?
											allowedTags,
											allowExtraTags);
			consumer.setupVariant(variant::Normal);
			count = exportGames(	consumer,
										gameFilter,
										gameSelector,
										copyMode,
										illegalRejected,
										log,
										progress);
		}
	}

	return count;
}


template <class Destination>
unsigned
Database::exportGames(	Destination& destination,
								Filter const& gameFilter,
								Selector const& gameSelector,
								copy::Mode copyMode,
								unsigned& illegalRejected,
								Log& log,
								util::Progress& progress) const
{
	M_REQUIRE(gameFilter.size() == size());
	M_REQUIRE(destination.variant() == variant());

	enum { MaxWarnings = 40 };

	if (size() == 0)
		return 0;

	format::Type dstFormat = destination.format();
	format::Type srcFormat = format();

	if (format::isScidFormat(dstFormat))
		copyMode = copy::ExcludeIllegal;

	unsigned frequency	= mstl::min(1000u, mstl::max(gameFilter.count()/100, 1u));
	unsigned reportAfter	= frequency;
	unsigned count			= 0;
	unsigned numGames		= 0;
	unsigned warnings		= 0;

	util::ProgressWatcher watcher(progress, gameFilter.count());

	for (	int index = gameFilter.next(Filter::Invalid);
			index != Filter::Invalid;
			index = gameFilter.next(index))
	{
		if (reportAfter == count++)
		{
			progress.update(count);

			if (progress.interrupted())
				return numGames;

			reportAfter += frequency;
		}

		int infoIndex;

		if (m_temporary)
		{
			m_codec->readIndexProgressive(index);
			infoIndex = 0;
		}
		else
		{
			infoIndex = index;
		}

		if (copyMode == copy::AllGames || !m_gameInfoList[infoIndex]->containsIllegalMoves())
		{
			save::State state = exportGame(infoIndex, destination);

			if (dstFormat == format::Scidb && ::format::isScidFormat(srcFormat))
			{
				unsigned unused;
				mstl::string const& round = static_cast<si3::Codec const&>(codec()).getRoundEntry(index);

				if (!Reader::parseRound(round, unused, unused))
				{
					log.warning(
						warnings++ >= MaxWarnings ? Log::MaximalWarningCountExceeded : Log::InvalidRoundTag,
						gameSelector.map(infoIndex));
				}
			}

			if (save::isOk(state))
				++numGames;
			else if (!log.error(state, gameSelector.map(infoIndex)))
				return numGames;
		}
		else
		{
			++illegalRejected;
		}
	}

	return numGames;
}


unsigned
Database::importGame(Producer& producer, unsigned index)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(	producer.variant() == variant::Undetermined
				|| variant::toMainVariant(producer.variant()) == variant());

	SingleProgress progress;

	m_codec->reset();
	unsigned n = m_codec->importGames(producer, progress, index);
	m_namebases.update();

	if (n > 0)
	{
		m_lastChange = sys::time::timestamp();
		setEncodingFailed(producer.encodingFailed() || m_codec->encodingFailed());
		m_statistic.add(*m_gameInfoList[index]);
		m_statistic.added = m_size - m_initialSize;

		if (!isMemoryOnly())
		{
			m_codec->update(index, true);
			m_codec->updateHeader();
			m_size = m_gameInfoList.size();
			::sys::file::changed(m_name, m_fileTime);
		}

		m_treeCache.setIncomplete();
	}

	return n;
}


unsigned
Database::importGames(Producer& producer, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(	producer.variant() == variant::Undetermined
				|| variant::toMainVariant(producer.variant()) == variant());

	return m_codec->importGames(producer, progress);
}


unsigned
Database::importGames(Database const& db, unsigned& illegalRejected, Log& log, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(db.variant() == variant());

	m_codec->reset();

	Filter	filter(db.size());
	Selector	selector;
	TagBits	allowedTags(true);

	filter.set();

	return db.copyGames(*this, filter, selector, allowedTags, true, illegalRejected, log, progress);
}


void
Database::recode(mstl::string const& encoding, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isMemoryOnly());
	M_REQUIRE(encoding != sys::utf8::Codec::utf8() || format() != format::Scidb);
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(namebases().isOriginal());

	if (encoding == m_encoding)
		return;

	m_encodingFailed = false;
	m_encodingOk = true;

	m_codec->setEncoding(m_encoding = encoding);
	m_codec->reloadDescription();
	m_codec->reloadNamebases(progress);

	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::rename(mstl::string const& name)
{
// Not working in case of Clipbase.
//	M_REQUIRE(util::misc::file::suffix(name) == util::misc::file::suffix(this->name()));

	if (!isMemoryOnly())
		m_codec->rename(m_name, name);

	m_name = name;
	m_rootname = misc::file::rootname(m_name);
	::sys::file::changed(m_name, m_fileTime);
}


void
Database::setupTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());

	gameInfo(index).setupTags(tags, m_variant);

	if (format::isScidFormat(format()))
		tags.set(tag::Round, static_cast<si3::Codec*>(m_codec)->getRoundEntry(index));
}


void
Database::deleteGame(unsigned index, bool flag)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(index < countGames());

	GameInfo& info = gameInfo(index);

	if (info.isDeleted() == flag)
		return;

	if (flag)
		++m_statistic.deleted;
	else
		--m_statistic.deleted;

	info.setDeleted(flag);

	if (!m_memoryOnly)
	{
		m_codec->update(index, false);
		::sys::file::changed(m_name, m_fileTime);
	}

	m_lastChange = sys::time::timestamp();
}


void
Database::setGameFlags(unsigned index, unsigned flags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(index < countGames());

	gameInfo(index).setFlags(flags);

	if (!m_memoryOnly)
	{
		m_codec->update(index, false);
		::sys::file::changed(m_name, m_fileTime);
	}
}


void
Database::setType(Type type)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());

	if (type != m_type)
	{
		m_type = type;

		if (!m_memoryOnly)
		{
			m_codec->updateHeader();
			::sys::file::changed(m_name, m_fileTime);
		}
	}
}


void
Database::updateDescription(mstl::string const& description)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly() || !isReadonly());
	M_REQUIRE(isMemoryOnly() || isWritable());

	if (m_description != description)
	{
		setupDescription(description);

		if (m_memoryOnly)
			m_descriptionHasChanged = true;
	}
}


void
Database::setupDescription(mstl::string const& description)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly() || !isReadonly());
	M_REQUIRE(isMemoryOnly() || isWritable());

	if (m_description != description)
	{
		m_description = description;

		if (m_codec->maxDescriptionLength() < m_description.size())
			m_description.set_size(m_codec->maxDescriptionLength());

		if (!m_memoryOnly)
		{
			m_codec->updateHeader();
			::sys::file::changed(m_name, m_fileTime);
		}
	}
}


void
Database::setVariant(variant::Type variant)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(isEmpty());
	M_REQUIRE(variant::isMainVariant(variant));

	if (m_variant != variant)
	{
		m_variant = variant;

		if (!m_memoryOnly)
		{
			m_codec->updateHeader();
			::sys::file::changed(m_name, m_fileTime);
		}
	}
}


unsigned
Database::countAnnotators() const
{
	Namebase const& annotatorBase = m_namebases(Namebase::Annotator);

	if (annotatorBase.isEmpty())
		return 0;

	unsigned count = annotatorBase.used();

	if (annotatorBase.entryAt(0)->name().empty() && annotatorBase.entryAt(0)->frequency() > 0)
		--count;

	return count;
}


NamebaseEntry const&
Database::annotator(unsigned index) const
{
	M_REQUIRE(index < countAnnotators());

	if (m_namebases(Namebase::Annotator).entryAt(0)->name().empty())
		++index;

	return *m_namebases(Namebase::Annotator).entryAt(index);
}


Move
Database::findExactPosition(unsigned index, Board const& position, bool skipVariations) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	return m_codec->findExactPosition(	*m_gameInfoList[index],
													position,
													skipVariations,
													m_asyncReader);
}


void
Database::openAsyncReader()
{
	M_REQUIRE(isOpen());

	if (m_asyncReader == 0)
	{
		m_asyncReader = m_codec->getAsyncReader();
		m_usingAsyncReader = true;
	}
}


void
Database::closeAsyncReader()
{
	if (m_usingAsyncReader)
	{
		m_codec->closeAsyncReader(m_asyncReader);
		m_asyncReader = 0;
		m_usingAsyncReader = false;
	}
}


TournamentTable*
Database::makeTournamentTable(Filter const& gameFilter) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!gameFilter.isEmpty());

	return new TournamentTable(*this, *(m_gameInfoList[gameFilter.next()]->eventEntry()), gameFilter);
}


unsigned
Database::countPlayers(NamebaseEvent const& event, unsigned& averageElo, unsigned& category) const
{
	typedef mstl::map<unsigned,uint16_t> EloSet;

	unsigned	eloCount	= 0;
	EloSet	eloSet;

	eloSet.reserve(200);
	averageElo = 0;
	category = 0;

	for (unsigned i = 0, n = m_gameInfoList.size(); i < n; ++i)
	{
		GameInfo const* info = m_gameInfoList[i];

		if (info->eventEntry() == &event)
		{
			for (unsigned side = 0; side < 2; ++side)
			{
				NamebasePlayer const* player = info->playerEntry(color::ID(side));
				EloSet::result_t res = eloSet.insert(EloSet::value_type(player->id(), 0));
				res.first->second = mstl::max(res.first->second, info->findElo(color::ID(side)));
			}
		}
	}

	for (EloSet::const_iterator i = eloSet.begin(); i != eloSet.end(); ++i)
	{
		if (unsigned elo = i->second)
		{
			averageElo += elo;
			++eloCount;
		}
	}

	if (eloCount)
	{
		averageElo = ((averageElo*10) + 5)/(eloCount*10);
		category = TournamentTable::fideCategory(averageElo);
	}

	return eloSet.size();
}


NamebasePlayer const&
Database::player(unsigned gameIndex, color::ID side) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(gameIndex < countGames());

	return *m_gameInfoList[gameIndex]->playerEntry(side);
}


NamebaseEvent const&
Database::event(unsigned index, Access access) const
{
	M_REQUIRE(access == MyIndex ? index < countEvents() : index < countGames());

	switch (access)
	{
		case MyIndex:
			return *m_namebases(Namebase::Event).event(index);

		case GameIndex:
			return *m_gameInfoList[index]->eventEntry();
	}

	return *m_namebases(Namebase::Event).event(0); // never reached
}


NamebaseSite const&
Database::site(unsigned index, Access access) const
{
	M_REQUIRE(access == MyIndex ? index < countSites() : index < countGames());

	switch (access)
	{
		case MyIndex:
			return *m_namebases(Namebase::Site).site(index);

		case GameIndex:
			return *m_gameInfoList[index]->eventEntry()->site();
	}

	return *m_namebases(Namebase::Event).site(0); // never reached
}


void
Database::emitPlayerCard(TeXt::Receptacle& receptacle, NamebasePlayer const& player) const
{
	PlayerStats stats;
	playerStatistic(player, stats);
	Player::emitPlayerCard(receptacle, player, stats);
}


void
Database::playerStatistic(NamebasePlayer const& player, PlayerStats& stats) const
{
	enum { Blank = 1 + color::White + color::Black };

	for (unsigned i = 0, n = m_gameInfoList.size(); i < n; ++i)
	{
		GameInfo const* info = m_gameInfoList[i];
		int side = Blank;

		if (info->playerEntry(color::White) == &player)
			side = color::White;
		else if (info->playerEntry(color::Black) == &player)
			side = color::Black;

		if (side != Blank)
		{
			color::ID		color			= color::ID(side);
			rating::Type	ratingType	= info->ratingType(color);

			if (ratingType != rating::Elo)
				stats.addRating(ratingType, info->rating(color));

			stats.addRating(rating::Elo, info->elo(color));
			stats.addDate(info->date());
			stats.addScore(color, info->result());
if (m_variant == variant::Normal) { // XXX
			if (info->idn() == variant::Standard)
				stats.addEco(color, info->eco());
}
		}
	}

	stats.finish();
}


unsigned
Database::stripMoveInformation(Filter const& filter, unsigned types, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(format() == format::Scidb);

	unsigned count			= filter.count();
	unsigned frequency	= progress.frequency(count, 5000);
	unsigned reportAfter	= frequency;
	unsigned number		= 0;
	unsigned numGames		= 0;

	util::ProgressWatcher watcher(progress, count);

	for (int index = filter.next(); index != Filter::Invalid; index = filter.next(index), number++)
	{
		if (reportAfter == number)
		{
			progress.update(number);
			reportAfter += frequency;
		}

		if (m_codec->stripMoveInformation(*m_gameInfoList[index], types))
			++numGames;
	}

	if (numGames > 0)
	{
		if (!m_shouldCompact)
		{
			m_shouldCompact = true;

			if (!isMemoryOnly())
			{
				m_codec->updateHeader();
				::sys::file::changed(m_name, m_fileTime);
			}
		}

		m_codec->sync();
	}

	return numGames;
}


unsigned
Database::stripTags(Filter const& filter, TagMap const& tags, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(format() == format::Scidb);

	unsigned count			= filter.count();
	unsigned frequency	= progress.frequency(count, 5000);
	unsigned reportAfter	= frequency;
	unsigned number		= 0;
	unsigned numGames		= 0;

	util::ProgressWatcher watcher(progress, count);

	for (int index = filter.next(); index != Filter::Invalid; index = filter.next(index), number++)
	{
		if (reportAfter == number)
		{
			progress.update(number);
			reportAfter += frequency;
		}

		if (m_codec->stripTags(*m_gameInfoList[index], tags))
			++numGames;
	}

	if (numGames > 0)
	{
		if (!m_shouldCompact)
		{
			m_shouldCompact = true;

			if (!isMemoryOnly())
			{
				m_codec->updateHeader();
				::sys::file::changed(m_name, m_fileTime);
			}
		}

		m_codec->sync();
	}

	return numGames;
}


void
Database::findTags(Filter const& filter, TagMap& tags, util::Progress& progress) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(format() == format::Scidb);

	unsigned count			= filter.count();
	unsigned frequency	= progress.frequency(count, 20000);
	unsigned reportAfter	= frequency;
	unsigned number		= 0;

	util::ProgressWatcher watcher(progress, count);

	for (int index = filter.next(); index != Filter::Invalid; index = filter.next(index), number++)
	{
		if (reportAfter == number)
		{
			progress.update(number);

			if (progress.interrupted())
				return;

			reportAfter += frequency;
		}

		m_codec->findTags(*m_gameInfoList[index], tags);
	}
}


bool
Database::setReadonly(bool flag)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!flag || isWritable());

	if (flag != m_readOnly)
	{
		if (!flag && !checkFileTime())
			return false;

		if (!m_readOnly && !m_memoryOnly)
			m_codec->sync();

		m_readOnly = flag;

		if (!m_readOnly && !m_memoryOnly)
			m_codec->setWritable();
	}

	return true;
}


void
Database::setWritable(bool flag)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!flag || codec().isWritable());

	m_writable = flag;
}


variant::Type
Database::variant(unsigned index) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	if (variant::isAntichessExceptLosers(m_variant))
		return m_gameInfoList[index]->isGiveaway() ? variant::Giveaway : variant::Suicide;

	return m_variant;
}

// vi:set ts=3 sw=3:
