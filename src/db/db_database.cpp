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
#include "db_pgn_reader.h"
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

#include "m_assert.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_ifstream.h"
#include "m_auto_ptr.h"
#include "m_stdio.h"
#include "m_map.h"

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


template
unsigned
Database::exportGames<Database>(	Database& destination,
											Filter const& gameFilter,
											Selector const& gameSelector,
											copy::Mode copyMode,
											Log& log,
											util::Progress& progress) const;
template
unsigned
Database::exportGames<Consumer>(	Consumer& destination,
											Filter const& gameFilter,
											Selector const& gameSelector,
											copy::Mode copyMode,
											Log& log,
											util::Progress& progress) const;


Database::Database(Database const& db, mstl::string const& name)
	:DatabaseContent(db)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::New))
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	if (m_memoryOnly)
		m_codec->open(this, m_encoding);
	else
		m_codec->open(this, m_rootname, m_encoding);
}


Database::Database(mstl::string const& name, mstl::string const& encoding)
	:DatabaseContent(encoding, type::Unspecific)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::Existing))
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	M_ASSERT(m_codec);

	// NOTE: we assume normalized (unique) file names.

	m_type = type::Unspecific;
	m_memoryOnly = false;
	m_temporary = true;
	m_created = sys::time::time();
	m_readOnly = true;
	m_writeable = false;
	m_size = m_codec->openProgressive(this, m_rootname, encoding);
	m_namebases.setModified(true);
}


Database::Database(	mstl::string const& name,
							mstl::string const& encoding,
							storage::Type storage,
							Type type,
							variant::Type variant)
	:DatabaseContent(encoding, type)
	,m_codec(DatabaseCodec::makeCodec(name, DatabaseCodec::New))
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	M_REQUIRE(storage != storage::Temporary);
	M_REQUIRE(variant::isMainVariant(variant));

	M_ASSERT(m_codec);

	// NOTE: we assume normalized (unique) file names.

	m_type = type;
	m_memoryOnly = storage == storage::MemoryOnly;
	m_temporary = false;
	m_created = sys::time::time();
	m_readOnly = m_temporary;

	switch (m_codec->format())
	{
		case format::Scidb:		m_variant = variant; break;
		case format::Scid3:		// fallthru
		case format::Scid4:		m_variant = variant::Normal; break;
		case format::ChessBase:	m_variant = variant::Normal; break;

		default: M_ASSERT(!"unexpected format");
	}

	if (!m_codec->isWriteable())
		m_writeable = false;

	if (m_memoryOnly)
		m_codec->open(this, encoding);
	else
		m_codec->open(this, m_rootname, encoding);

	m_size = m_gameInfoList.size();
	m_namebases.setModified(true);
}


Database::Database(	mstl::string const& name,
							mstl::string const& encoding,
							permission::Mode mode,
							util::Progress& progress)
	:DatabaseContent(encoding)
	,m_codec(0)
	,m_name(name)
	,m_rootname(file::rootname(name))
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	M_REQUIRE(file::hasSuffix(name));
	M_REQUIRE(file::suffix(m_name) == "sci" || mode == permission::ReadOnly);

	// NOTE: we assume normalized (unique) file names.

	mstl::string ext = file::suffix(m_name);

	m_readOnly = mode == permission::ReadOnly;
	m_codec = DatabaseCodec::makeCodec(m_name, DatabaseCodec::Existing);

	if (m_codec == 0)
	{
		if (ext.empty())
			DB_RAISE("no file suffix given");

		DB_RAISE("unknown file format (.%s)", ext.c_str());
	}

	if (!m_codec->isWriteable())
		m_writeable = false;

	m_codec->open(this, m_rootname, m_encoding, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


Database::Database(mstl::string const& name, Producer& producer, util::Progress& progress)
	:DatabaseContent(producer.encoding())
	,m_codec(0)
	,m_name(name)
	,m_rootname(name)
	,m_id(Counter++)
	,m_size(0)
	,m_lastChange(sys::time::timestamp())
	,m_encodingFailed(false)
	,m_encodingOk(true)
	,m_usingAsyncReader(false)
{
	// NOTE: we assume normalized (unique) file names.

	m_created = sys::time::time();
	m_codec = DatabaseCodec::makeCodec(name, DatabaseCodec::Existing);
	M_ASSERT(m_codec->isWriteable());
	m_codec->open(this, sys::utf8::Codec::utf8(), producer, progress);
	m_size = m_gameInfoList.size();
	m_readOnly = true;
	setEncodingFailed(producer.encodingFailed());
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin(),
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


Database::~Database() throw()
{
	delete m_codec;
}


unsigned
Database::count(table::Type type) const
{
	switch (type)
	{
		case table::Games:		return countGames();
		case table::Players:		return m_namebases(Namebase::Player).used();
		case table::Events:		return m_namebases(Namebase::Event).used();
		case table::Sites:		return m_namebases(Namebase::Site).used();
		case table::Annotators:	return m_namebases(Namebase::Annotator).used();
	}

	return 0; // satisifes the compiler
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
	M_ASSERT(m_codec->isWriteable());
	m_readOnly = false;
	m_memoryOnly = false;
}


void
Database::save(util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(!usingAsyncReader());

	if (m_size == m_gameInfoList.size())
		return;

	unsigned start = m_size;

	m_namebases.update();

	if (!isMemoryOnly())
	{
		m_codec->reset();
		m_codec->save(m_rootname, start, progress);
		m_codec->updateHeader(m_rootname);
		setEncodingFailed(m_codec->encodingFailed());
	}

	m_size = m_gameInfoList.size();
	m_lastChange = sys::time::timestamp();
	m_treeCache.setIncomplete(start);

	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin() + start,
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Reset);
}


void
Database::writeIndex(mstl::ostream& os, util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(!isMemoryOnly());

	m_namebases.update();
	m_codec->reset();
	m_codec->writeIndex(os, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::writeNamebases(mstl::ostream& os, util::Progress& progress)
{
	M_REQUIRE(format() == format::Scidb);
	M_REQUIRE(!isReadOnly());
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
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(!isMemoryOnly());

	m_namebases.update();
	m_codec->reset();
	m_codec->writeGames(os, progress);
	m_size = m_gameInfoList.size();
	setEncodingFailed(m_codec->encodingFailed());
}


void
Database::sync(util::Progress& progress)
{
	if (m_codec && !isMemoryOnly() && !m_readOnly && m_writeable)
	{
		if (m_size != m_gameInfoList.size())
			save(progress);

		m_codec->sync();
	}
}


void
Database::close()
{
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

	if (m_codec)
		m_codec->close(); // we don't need sync()

	if (!isMemoryOnly())
		m_codec->removeAllFiles(m_rootname);

	if (m_codec)
	{
		delete m_codec;
		m_codec = 0;
	}
}


bool
Database::shouldCompress() const
{
	return !isReadOnly() && format() == format::Scidb && (m_shouldCompress || m_statistic.deleted > 0);
}


void
Database::getInfoTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	tags.clear();
	setupTags(index, tags);
	m_codec->filterTags(tags, DatabaseCodec::InfoTags);
}


void
Database::getGameTags(unsigned index, TagSet& tags) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(index < countGames());

	tags.clear();
	setupTags(index, tags);
	m_codec->filterTags(tags, DatabaseCodec::GameTags);
}


void
Database::clear()
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());

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
Database::reopen(mstl::string const& encoding, util::Progress& progress)
{
	M_REQUIRE(file::hasSuffix(name()));
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
	m_lastChange = sys::time::timestamp();
	m_encoding = encoding;

	delete m_codec;

	m_codec = DatabaseCodec::makeCodec(m_name, DatabaseCodec::Existing);
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
		m_codec->decodeGame(game, *info, encoding);
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
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
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
		m_lastChange = sys::time::timestamp();
		m_statistic.add(*m_gameInfoList.back());
	}

	return state;
}


save::State
Database::addGame(Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	if (format() != format::Scidb)
		game.setFlags(game.flags() & ~(GameInfo::Flag_Illegal_Castling | GameInfo::Flag_Illegal_Move));

	save::State state = m_codec->saveGame(strm, game.tags(), game);
	m_namebases.update();

	if (save::isOk(state))
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
Database::updateGame(Game& game)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));
	GameInfo& info(*m_gameInfoList[game.index()]);

	if (format() == format::Scidb)
	{
		if (!variant::isAntichessExceptLosers(m_variant))
			info.setIllegalCastling(game.containsIllegalCastlings());

		info.setIllegalMove(game.containsIllegalMoves());
	}

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());
	game.setFlags(info.flags());

	save::State state = m_codec->saveGame(strm, game.tags(), game);

	m_namebases.update();

	if (save::isOk(state))
	{
		if (!m_memoryOnly)
			m_codec->update(m_rootname, game.index(), true);

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
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(0 <= game.index() && game.index() < int(countGames()));
	M_REQUIRE(variant::toMainVariant(game.variant()) == variant());
	M_REQUIRE(!usingAsyncReader());

	unsigned char buffer[8192];
	ByteStream strm(buffer, sizeof(buffer));

	m_codec->encodeGame(strm, game, game.getFinalBoard().signature());

	save::State state = m_codec->saveMoves(strm, game);

	if (save::isOk(state))
	{
		GameInfo& info = *m_gameInfoList[game.index()];

		if (format() == format::Scidb)
		{
			if (variant::isAntichessExceptLosers(m_variant))
			{
				bool illegalMoves = game.containsIllegalMoves();

				if (illegalMoves != info.containsIllegalMoves())
				{
					info.setIllegalMove(illegalMoves);

					if (!m_memoryOnly)
						m_codec->update(m_rootname, game.index(), false);
				}
			}
			else
			{
				bool illegalCastling	= game.containsIllegalCastlings();
				bool illegalMoves		= game.containsIllegalMoves();

				if (	illegalCastling != info.containsIllegalCastlings()
					|| illegalMoves != info.containsIllegalMoves())
				{
					info.setIllegalCastling(illegalCastling);
					info.setIllegalMove(illegalMoves);

					if (!m_memoryOnly)
						m_codec->update(m_rootname, game.index(), false);
				}
			}
		}

		game.setFlags(info.flags());
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
	M_REQUIRE(isWriteable());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());

	save::State state = m_codec->updateCharacteristics(index, tags);

	m_namebases.update();

	if (save::isOk(state))
	{
		if (!m_memoryOnly)
			m_codec->update(m_rootname, index, true);

		m_gameInfoList[index]->setDirty(false);
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
		PgnReader::Tag tag;

		mstl::string s;
		mstl::string v;

		s = tags.value(tag::White);
		while ((tag = PgnReader::extractPlayerData(s, v)) != PgnReader::None)
		{
			switch (tag)
			{
				case PgnReader::Country:
					tags.add(tag::WhiteCountry, country::fromString(v));
					break;

				case PgnReader::Title:
					tags.add(tag::WhiteTitle, title::toString(title::fromString(v)));
					break;

				case PgnReader::Human:
					tags.add(tag::WhiteType, species::toString(species::Human));
					break;

				case PgnReader::Program:
					tags.add(tag::WhiteType, species::toString(species::Program));
					break;

				case PgnReader::Sex:
					tags.add(tag::WhiteSex, sex::toString(sex::fromString(v)));
					break;

				case PgnReader::Elo:
					tags.add(tag::WhiteElo, v);
					break;

				case PgnReader::None:
					break;
			}
		}
		tags.set(tag::White, s);

		s = tags.value(tag::Black);
		while ((tag = PgnReader::extractPlayerData(s, v)) != PgnReader::None)
		{
			switch (tag)
			{
				case PgnReader::Country:
					tags.add(tag::BlackCountry, country::fromString(v));
					break;

				case PgnReader::Title:
					tags.add(tag::BlackTitle, title::toString(title::fromString(v)));
					break;

				case PgnReader::Human:
					tags.add(tag::BlackType, species::toString(species::Human));
					break;

				case PgnReader::Program:
					tags.add(tag::BlackType, species::toString(species::Program));
					break;

				case PgnReader::Sex:
					tags.add(tag::BlackSex, sex::toString(sex::fromString(v)));
					break;

				case PgnReader::Elo:
					tags.add(tag::BlackElo, v);
					break;

				case PgnReader::None:
					break;
			}
		}
		tags.set(tag::Black, s);

		s = tags.value(tag::Site);
		country::Code code = PgnReader::extractCountryFromSite(s);
		if (code != country::Unknown)
		{
			tags.add(tag::EventCountry, country::toString(code));
			tags.set(tag::Site, s);
		}
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
	M_REQUIRE(	format() == format::Scid3
				|| format() == format::Scid4
				|| format() == format::Scidb);
	M_REQUIRE(format() == destination.format());
	M_REQUIRE(index < countGames());

	GameInfo const& info = *m_gameInfoList[index];
	ByteStream data(m_codec->getGame(info));
	return destination.codec().addGame(data, info, DatabaseCodec::Alloc);
}


unsigned
Database::copyGames(	Database& destination,
							Filter const& gameFilter,
							Selector const& gameSelector,
							TagBits const& allowedTags,
							bool allowExtraTags,
							Log& log,
							util::Progress& progress) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(destination.isOpen());
	M_REQUIRE(destination.isWriteable());
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
		count = exportGames(destination, gameFilter, gameSelector, copyMode, log, progress);
	}
	else
	{
		if (dstFormat == format::Scidb)
		{
			sci::Consumer::Codecs codecs(&dynamic_cast<sci::Codec&>(destination.codec()));
			// XXX do we need the source encoding?
			sci::Consumer consumer(srcFormat, codecs, allowedTags, allowExtraTags);
			consumer.setupVariant(m_variant);
			count = exportGames(consumer, gameFilter, gameSelector, copyMode, log, progress);
		}
		else // dstFormat == format::Scid3 || dstFormat == format::Scid4
		{
			si3::Consumer consumer(	srcFormat,
											dynamic_cast<si3::Codec&>(destination.codec()),
											encoding(), // XXX do we need the source encoding?
											allowedTags,
											allowExtraTags);
			consumer.setupVariant(variant::Normal);
			count = exportGames(consumer, gameFilter, gameSelector, copyMode, log, progress);
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
								Log& log,
								util::Progress& progress) const
{
	M_REQUIRE(gameFilter.size() == size());
	M_REQUIRE(destination.variant() == variant());

	enum { MaxWarnings = 40 };

	if (size() == 0)
		return 0;

	unsigned frequency = progress.frequency(gameFilter.count());

	if (frequency == 0)
		frequency = mstl::min(1000u, mstl::max(gameFilter.count()/100, 1u));

	unsigned reportAfter = frequency;

	util::ProgressWatcher watcher(progress, gameFilter.count());

	unsigned count		= 0;
	unsigned numGames	= 0;
	unsigned warnings	= 0;

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

			if (destination.format() == format::Scidb && ::format::isScidFormat(format()))
			{
				unsigned unused;
				mstl::string const& round = static_cast<si3::Codec const&>(codec()).getRoundEntry(index);

				if (!PgnReader::parseRound(round, unused, unused))
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
	}

	return numGames;
}


unsigned
Database::importGame(Producer& producer, unsigned index)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(index < countGames());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(	producer.variant() == variant::Undetermined
				|| variant::toMainVariant(producer.variant()) == variant());

	SingleProgress progress;

	m_codec->reset();
	unsigned n = m_codec->importGames(producer, progress, index);

	if (n > 0)
	{
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

		m_treeCache.setIncomplete();
	}

	return n;
}


unsigned
Database::importGames(Producer& producer, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(	producer.variant() == variant::Undetermined
				|| variant::toMainVariant(producer.variant()) == variant());

	unsigned oldSize = m_gameInfoList.size();

	m_codec->reset();
	unsigned n = m_codec->importGames(producer, progress);

	if (n)
	{
		m_lastChange = sys::time::timestamp();
		finishImport(oldSize, producer.encodingFailed());
	}

	return n;
}


unsigned
Database::importGames(Database const& db, Log& log, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(!usingAsyncReader());
	M_REQUIRE(db.variant() == variant());

	unsigned oldSize = m_gameInfoList.size();

	m_codec->reset();

	Filter	filter(db.size());
	Selector	selector;
	TagBits	allowedTags(true);

	filter.set();

	unsigned n = db.copyGames(*this, filter, selector, allowedTags, true, log, progress);

	if (n > 0)
		finishImport(oldSize, db.encodingFailed());

	return n;
}


void
Database::finishImport(unsigned oldSize, bool encodingFailed)
{
	m_lastChange = sys::time::timestamp();
	m_namebases.update();
	m_statistic.compute(	const_cast<GameInfoList const&>(m_gameInfoList).begin() + oldSize,
								const_cast<GameInfoList const&>(m_gameInfoList).end(),
								Statistic::Continue);
	m_treeCache.setIncomplete();

	if (encodingFailed || m_codec->encodingFailed())
		setEncodingFailed(true);
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
Database::rename(mstl::string const& name)
{
// Not working in case of Clipbase.
//	M_REQUIRE(util::misc::file::suffix(name) == util::misc::file::suffix(this->name()));

	if (!isMemoryOnly())
		m_codec->rename(m_name, name);

	m_name = name;
	m_rootname = file::rootname(m_name);
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
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(index < countGames());

	if (gameInfo(index).isDeleted())
		--m_statistic.deleted;

	gameInfo(index).setDeleted(flag);

	if (flag)
		++m_statistic.deleted;

	if (!m_memoryOnly)
		m_codec->update(m_rootname, index, false);

	m_lastChange = sys::time::timestamp();
}


void
Database::setGameFlags(unsigned index, unsigned flags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
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
	M_REQUIRE(isWriteable());

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
	M_REQUIRE(isWriteable());

	if (m_description != description)
	{
		m_description = description;

		if (m_codec->maxDescriptionLength() < m_description.size())
			m_description.set_size(m_codec->maxDescriptionLength());

		if (!m_memoryOnly)
			m_codec->updateHeader(m_rootname);
	}
}


void
Database::setVariant(variant::Type variant)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());
	M_REQUIRE(isEmpty());
	M_REQUIRE(variant::isMainVariant(variant));

	if (m_variant != variant)
	{
		m_variant = variant;

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
	if (!isOpen())
		return;

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

// vi:set ts=3 sw=3:
