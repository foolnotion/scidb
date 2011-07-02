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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_database.h"
#include "db_database_codec.h"
#include "db_pgn_reader.h"
#include "db_exception.h"
#include "db_game_info.h"
#include "db_game.h"
#include "db_tag_set.h"
#include "db_consumer.h"
#include "db_producer.h"
#include "db_eco_table.h"
#include "db_tournament_table.h"
#include "db_filter.h"
#include "db_query.h"
#include "db_search.h"
#include "db_log.h"

#include "u_block_file.h"
#include "u_progress.h"
#include "u_misc.h"
#include "u_crc.h"

#include "sys_utf8_codec.h"
#include "sys_time.h"

#include "m_assert.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_ifstream.h"
#include "m_auto_ptr.h"
#include "m_stdio.h"

using namespace db;
using namespace util;

namespace file = util::misc::file;


namespace {

struct SingleProgress : public util::Progress
{
	SingleProgress() { setFrequency(1); }
	bool interrupted() { return true; }
};

} // namespace


static unsigned Counter = 0;


Database::Database(mstl::string const& name, mstl::string const& encoding, Storage storage, Type type)
	:DatabaseContent(type)
	,m_codec(DatabaseCodec::makeCodec(file::suffix(name)))
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encoding(encoding)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	M_ASSERT(m_codec);

	// NOTE: we assume normalized (unique) file names.

	m_type = type;
	m_memoryOnly = storage == MemoryOnly;
	m_created = sys::time::time();

	if (m_memoryOnly)
		m_codec->open(this, encoding);
	else
		m_codec->open(this, m_rootname, encoding);

	m_size = m_gameInfoList.size();
}


Database::Database(	mstl::string const& name,
							mstl::string const& encoding,
							Mode mode,
							Progress& progress)
	:m_codec(0)
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encoding(encoding)
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	M_REQUIRE(file::hasSuffix(name));

	// NOTE: we assume normalized (unique) file names.

	mstl::string ext = file::suffix(m_name);

	m_readOnly = mode == ReadOnly;
	m_codec = DatabaseCodec::makeCodec(ext);

	if (m_codec == 0)
	{
		if (ext.empty())
			DB_RAISE("no file suffix given");

		DB_RAISE("unknown file format (.%s)", ext.c_str());
	}

	m_codec->open(this, m_rootname, m_encoding, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


Database::Database(mstl::string const& name, Producer& producer, Progress& progress)
	:m_codec(0)
	,m_name(name)
	,m_rootname(name)
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encoding(producer.encoding())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	// NOTE: we assume normalized (unique) file names.

	m_created = sys::time::time();
	m_codec = DatabaseCodec::makeCodec();
	m_codec->open(this, sys::utf8::Codec::utf8(), producer, progress);
	m_size = m_gameInfoList.size();
	m_readOnly = true;
	setEncodingFailed(producer.encodingFailed());
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


void
Database::attach(mstl::string const& filename, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isMemoryOnly());
	M_REQUIRE(codec().extension() == file::suffix(filename));
	M_REQUIRE(!usingAsyncReader());

	// NOTE: we assume normalized (unique) file names.

	m_rootname = file::rootname(filename);
	m_codec->attach(m_rootname, progress);
	m_readOnly = false;
	m_memoryOnly = false;
}


void
Database::save(util::Progress& progress, unsigned start)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(start <= countGames());
	M_REQUIRE(!usingAsyncReader());

	if (isMemoryOnly())
		return;

	m_namebases.update();
	m_codec->reset();
	m_codec->save(m_rootname, start, progress);
	m_codec->updateHeader(m_rootname);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::close()
{
	if (m_codec)
	{
		if (!isMemoryOnly() && m_size != m_gameInfoList.size())		// should not happen
		{
			util::Progress progress;
			save(progress, m_size);
		}

		m_codec->close();
		delete m_codec;
		m_codec = 0;
	}
}


void
Database::getTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	tags.clear();
	m_gameInfoList[index]->setupTags(tags);

	for (unsigned i = 0; i < tag::ExtraTag; ++i)
		m_codec->filterTag(tags, tag::ID(i));
}


void
Database::clear()
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!usingAsyncReader());

	m_gameInfoList.clear();
	m_statistic.clear();
	m_namebases.clear();
	m_allocator.clear();
	m_encodingFailed = false;
	m_encodingOk = true;
	m_size = 0;
	m_lastChange = sys::time::timestamp();
	m_codec->reset();
	m_treeCache.clear();

	if (m_memoryOnly)
		m_codec->clear();
	else
		m_codec->clear(m_rootname);
}


void
Database::reopen(mstl::string const& encoding, Progress& progress)
{
	M_REQUIRE(file::hasSuffix(name()));
	M_REQUIRE(!isMemoryOnly());
	M_REQUIRE(!usingAsyncReader());

	m_gameInfoList.clear();
	m_namebases.clear();
	m_allocator.clear();
	m_treeCache.clear();
	m_encodingFailed = false;
	m_encodingOk = true;
	m_size = 0;
	m_lastChange = sys::time::timestamp();
	m_encoding = encoding;

	delete m_codec;

	mstl::string ext = file::suffix(name());

	m_codec = DatabaseCodec::makeCodec(ext);
	M_ASSERT(m_codec);
	m_codec->open(this, m_rootname, m_encoding, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


util::crc::checksum_t
Database::computeChecksum(unsigned index) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	GameInfo const& info = *m_gameInfoList[index];
	return m_codec->computeChecksum(/*DatabaseCodec::Decode_All, */info, info.computeChecksum());
}


bool
Database::loadGame(unsigned index, Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	GameInfo* info = m_gameInfoList[index];
	m_codec->reset();
	m_codec->decodeGame(/*DatabaseCodec::Decode_All, */game, *info);
	setEncodingFailed(m_codec->encodingFailed());
	game.moveToMainlineStart();
	bool ok = game.finishLoad();
	setupTags(index, game.m_tags);
	return ok;
}


save::State
Database::newGame(Game& game, GameInfo const& info)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(isMemoryOnly());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));
	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());
	save::State state = m_codec->addGame(strm, info);
	m_namebases.update();

	if (state == save::Ok)
	{
		m_lastChange = sys::time::timestamp();
		m_statistic.add(*m_gameInfoList.back());
	}

	return state;
}


save::State
Database::addGame(Game const& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	save::State state = m_codec->saveGame(strm, game.tags(), game);
	m_namebases.update();

	if (state == save::Ok)
	{
		if (!m_memoryOnly)
		{
			m_codec->update(m_rootname, m_gameInfoList.size() - 1, true);
			m_codec->updateHeader(m_rootname);
		}

		m_size = m_gameInfoList.size();
		m_lastChange = sys::time::timestamp();
		m_statistic.add(*m_gameInfoList.back());
		m_treeCache.setIncomplete();
	}

	return state;
}


save::State
Database::updateGame(Game const& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	save::State state = m_codec->saveGame(strm, game.tags(), game);

	m_namebases.update();

	if (state == save::Ok)
	{
		if (!m_memoryOnly)
			m_codec->update(m_rootname, game.index(), true);

		m_lastChange = sys::time::timestamp();
		m_treeCache.setIncomplete(game.index());

		// TODO: only an update is needed
		m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
									const_cast<GameInfoList const&>(m_gameInfoList).end(),
									Statistic::Reset);
	}

	return state;
}


save::State
Database::updateMoves(Game const& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	save::State state = m_codec->saveMoves(strm, game);

	if (state == save::Ok)
	{
		m_lastChange = sys::time::timestamp();
		m_treeCache.setIncomplete(game.index());
	}

	return state;
}


save::State
Database::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());

	save::State state = m_codec->updateCharacteristics(index, tags);

	m_namebases.update();

	if (state == save::Ok)
	{
		if (!m_memoryOnly)
			m_codec->update(m_rootname, index, true);

		m_gameInfoList[index]->setDirty(false);
		m_lastChange = sys::time::timestamp();

		// TODO: only an update is needed
		m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
									const_cast<GameInfoList const&>(m_gameInfoList).end(),
									Statistic::Reset);
	}

	return state;
}


save::State
Database::exportGame(unsigned index, Consumer& consumer)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	format::Type		format	= this->format();
	GameInfo const*	info		= m_gameInfoList[index];
	TagSet				tags;

	setupTags(index, tags);

	if (format == format::Scid3 || format == format::Scid4)
	{
		mstl::string s;
		mstl::string v;

		s = tags.value(tag::White);
		while (PgnReader::extractPlayerData(s, v) != PgnReader::None)
			;
		tags.set(tag::White, s);

		s = tags.value(tag::Black);
		while (PgnReader::extractPlayerData(s, v) != PgnReader::None)
			;
		tags.set(tag::Black, s);

		s = tags.value(tag::Site);
		PgnReader::extractCountryFromSite(s);
		tags.set(tag::Site, s);
	}

	save::State rc;

	m_codec->reset();
	consumer.setFlags(info->flags());

#ifdef DEBUG_SI4
	consumer.m_index = index;
#endif

	try
	{
		rc = m_codec->exportGame(consumer, tags, *info);
	}
	catch (DecodingFailedException const& exc)
	{
		rc = save::DecodingFailed;
	}

#ifdef DEBUG_SI4
//	if (	info->idn() == 518
//		&& m_codec->format() != format::ChessBase
//		&& (	consumer.sourceFormat() == format::Scid3
//			|| consumer.sourceFormat() == format::Scid4))
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
Database::exportGame(unsigned index, Database& destination)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(destination.isOpen());
	M_REQUIRE(	format() == format::Scid3
				|| format() == format::Scid4
				|| format() == format::Scidb);
	M_REQUIRE(format() == destination.format());
	M_REQUIRE(index < countGames());

	GameInfo const& info = *m_gameInfoList[index];
	ByteStream data(m_codec->getGame(info));
	return destination.codec().addGame(data, info);
}


unsigned
Database::importGame(Producer& producer, unsigned index)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());

	SingleProgress progress;

	m_codec->reset();
	unsigned n = m_codec->importGames(producer, progress, index);
	m_lastChange = sys::time::timestamp();
	m_namebases.update();
	setEncodingFailed(producer.encodingFailed() || m_codec->encodingFailed());
	m_statistic.add(*m_gameInfoList[index]);

	if (!isMemoryOnly())
	{
		m_codec->update(m_rootname, index, true);
		m_codec->updateHeader(m_rootname);
		m_size = m_gameInfoList.size();
	}

	if (n)
		m_treeCache.setIncomplete();

	return n;
}


unsigned
Database::importGames(Producer& producer, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(!usingAsyncReader());

	unsigned oldSize = m_gameInfoList.size();

	m_codec->reset();
	unsigned n = m_codec->importGames(producer, progress);
	m_lastChange = sys::time::timestamp();
	m_namebases.update();
	setEncodingFailed(producer.encodingFailed() || m_codec->encodingFailed());
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin() + oldSize,
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Continue);


	if (n)
		m_treeCache.setIncomplete();

	return n;
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

	m_codec->setEncoding(m_encoding = encoding);
	m_codec->reloadDescription(m_rootname);
	m_codec->reloadNamebases(m_rootname, progress);

	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::setupTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	gameInfo(index).setupTags(tags);
}


void
Database::deleteGame(unsigned index, bool flag)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(index < countGames());

	gameInfo(index).setDeleted(flag);

	if (!m_memoryOnly)
		m_codec->update(m_rootname, index, false);

	m_lastChange = sys::time::timestamp();
}


void
Database::setGameFlags(unsigned index, unsigned flags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(index < countGames());

	gameInfo(index).setFlags(flags);

	if (!m_memoryOnly)
		m_codec->update(m_rootname, index, false);
}


void
Database::setType(Type type)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());

	if (type != m_type)
	{
		m_type = type;

		if (!m_memoryOnly)
			m_codec->updateHeader(m_rootname);
	}
}


void
Database::setDescription(mstl::string const& description)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());

	if (m_description != description)
	{
		m_description = description;

		if (m_codec->maxDescriptionLength() < m_description.size())
			m_description.set_size(m_codec->maxDescriptionLength());

		if (!m_memoryOnly)
			m_codec->updateHeader(m_rootname);
	}
}


unsigned
Database::countAnnotators() const
{
	Namebase const& annotatorBase = m_namebases(Namebase::Annotator);

	if (annotatorBase.isEmpty())
		return 0;

	if (annotatorBase.entryAt(0)->name().empty())
		return annotatorBase.size() - 1;

	return annotatorBase.size();
}


NamebaseEntry const&
Database::annotator(unsigned index) const
{
	M_REQUIRE(index < countAnnotators());

	if (m_namebases(Namebase::Annotator).entryAt(0)->name().empty())
		++index;

	return *m_namebases(Namebase::Annotator).entryAt(index);
}


void
Database::openAsyncReader()
{
	M_REQUIRE(isOpen());

	if (!m_usingAsyncReader)
	{
		m_codec->useAsyncReader(true);
		m_usingAsyncReader = true;
	}
}


void
Database::closeAsyncReader()
{
	M_REQUIRE(isOpen());

	if (m_usingAsyncReader)
	{
		m_codec->useAsyncReader(false);
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

// vi:set ts=3 sw=3:
