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

#include "app_view.h"
#include "app_application.h"

#include "db_database.h"
#include "db_filter.h"
#include "db_game.h"
#include "db_pgn_writer.h"
#include "db_log.h"

#include "sci_codec.h"
#include "sci_consumer.h"

#include "si3_codec.h"
#include "si3_consumer.h"

#include "u_misc.h"
#include "u_zstream.h"
#include "u_progress.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"

#include "m_vector.h"
#include "m_assert.h"

using namespace db;
using namespace app;


inline
static Filter::ResizeMode
map(View::UpdateMode mode)
{
	return mode == View::AddNewGames ? Filter::AddNewIndices : Filter::LeaveEmpty;
}


template
unsigned
View::exportGames<Database>(	Database& destination,
										GameMode gameMode,
										db::Log& log,
										util::Progress& progress);
template
unsigned
View::exportGames<Consumer>(	Consumer& destination,
										GameMode gameMode,
										db::Log& log,
										util::Progress& progress);


View::View(Application& app, Database& db)
	:m_app(app)
	,m_db(db)
	,m_gameUpdateMode(AddNewGames)
	,m_playerUpdateMode(AddNewGames)
	,m_eventUpdateMode(AddNewGames)
	,m_annotatorUpdateMode(AddNewGames)
{
	initialize();
}


View::View(	Application& app,
				Database& db,
				UpdateMode gameUpdateMode,
				UpdateMode playerUpdateMode,
				UpdateMode eventUpdateMode,
				UpdateMode annotatorUpdateMode)
	:m_app(app)
	,m_db(db)
	,m_gameUpdateMode(gameUpdateMode)
	,m_playerUpdateMode(playerUpdateMode)
	,m_eventUpdateMode(eventUpdateMode)
	,m_annotatorUpdateMode(annotatorUpdateMode)
{
	initialize();
}


void
View::initialize()
{
	m_gameFilter.resize(m_db.countGames(), Filter::LeaveEmpty);
	m_gameFilter.set();

	m_eventFilter.resize(m_db.countEvents(), Filter::LeaveEmpty);
	m_eventFilter.set();

	m_playerFilter.resize(m_db.countPlayers(), Filter::LeaveEmpty);
	m_playerFilter.set();
}


void
View::update()
{
	m_gameFilter.resize(m_db.countGames(), ::map(m_gameUpdateMode));
	m_playerFilter.resize(m_db.countPlayers(), ::map(m_playerUpdateMode));
	m_eventFilter.resize(m_db.countEvents(), ::map(m_eventUpdateMode));

	m_gameSelector.update(m_db.countGames());
	m_playerSelector.update(m_db.countPlayers());
	m_eventSelector.update(m_db.countEvents());
	m_annotatorSelector.update(m_db.countAnnotators());
}


unsigned
View::countAnnotators() const
{
	return m_db.countAnnotators();
}


unsigned
View::totalAnnotators() const
{
	return m_db.countAnnotators();
}


unsigned
View::playerIndex(unsigned index) const
{
	return m_playerSelector.lookup(index);
}


unsigned
View::eventIndex(unsigned index) const
{
	return m_eventSelector.lookup(index);
}


unsigned
View::annotatorIndex(unsigned index) const
{
	return m_annotatorSelector.lookup(index);
}


unsigned
View::gameIndex(unsigned index) const
{
	M_REQUIRE(index < countGames());
	return m_gameSelector.lookup(index);
}


int
View::lookupGame(unsigned number) const
{
	M_REQUIRE(number < totalGames());
	return m_gameFilter.contains(number) ? int(m_gameSelector.find(number)) : -1;
}


int
View::lookupPlayer(mstl::string const& name) const
{
	return m_playerSelector.findPlayer(m_db, name);
}


int
View::lookupPlayer(unsigned number) const
{
	return m_playerFilter.contains(number) ? int(m_playerSelector.find(number)) : -1;
}


int
View::lookupEvent(mstl::string const& name) const
{
	return m_eventSelector.findEvent(m_db, name);
}


int
View::lookupEvent(unsigned number) const
{
	return m_eventFilter.contains(number) ? int(m_eventSelector.find(number)) : -1;
}


int
View::lookupAnnotator(mstl::string const& name) const
{
	return m_annotatorSelector.findAnnotator(m_db, name);
}


int
View::findPlayer(mstl::string const& name) const
{
	return m_playerSelector.searchPlayer(m_db, name);
}


int
View::findEvent(mstl::string const& title) const
{
	return m_eventSelector.searchEvent(m_db, title);
}


int
View::findAnnotator(mstl::string const& name) const
{
	return m_annotatorSelector.searchAnnotator(m_db, name);
}


void
View::sort(attribute::game::ID attr, order::ID order, rating::Type ratingType)
{
	m_gameSelector.sort(m_db, attr, order, ratingType);
	m_gameSelector.update(m_gameFilter);
}


void
View::sort(attribute::player::ID attr, order::ID order, rating::Type ratingType)
{
	m_playerSelector.sort(m_db,  attr, order, ratingType);
	m_playerSelector.update(m_playerFilter);
}


void
View::sort(db::attribute::event::ID attr, db::order::ID order)
{
	m_eventSelector.sort(m_db,  attr, order);
	m_eventSelector.update(m_eventFilter);
}


void
View::sort(attribute::annotator::ID attr, order::ID order)
{
	m_annotatorSelector.sort(m_db, attr, order);
	m_annotatorSelector.update();
}


void
View::reverse(attribute::game::ID)
{
	m_gameSelector.reverse(m_db);
	m_gameSelector.update(m_gameFilter);
}


void
View::reverse(attribute::player::ID)
{
	m_playerSelector.reverse(m_db);
	m_playerSelector.update(m_playerFilter);
}


void
View::reverse(attribute::event::ID)
{
	m_eventSelector.reverse(m_db);
	m_eventSelector.update(m_eventFilter);
}


void
View::reverse(attribute::annotator::ID)
{
	m_annotatorSelector.reverse(m_db);
	m_annotatorSelector.update();
}


void
View::searchGames(Query const& query)
{
	m_gameFilter.search(query, m_db.content());
	m_gameSelector.update(m_gameFilter);
}


void
View::filterPlayers()
{
	mstl::bitset f(m_db.namebase(Namebase::Player).nextId());

	m_playerFilter.reset();

	for (int i = m_gameFilter.next(); i != Filter::Invalid; i = m_gameFilter.next(i))
	{
		f.set(m_db.gameInfo(i).playerEntry(color::White)->id());
		f.set(m_db.gameInfo(i).playerEntry(color::Black)->id());
	}

	for (unsigned i = 0; i < m_db.countPlayers(); ++i)
	{
		if (f.test(m_db.player(i).id()))
			m_playerFilter.add(i);
	}

	m_playerSelector.update(m_playerFilter);
}


void
View::filterEvents()
{
	mstl::bitset f(m_db.namebase(Namebase::Event).nextId());

	m_eventFilter.reset();

	for (int i = m_gameFilter.next(); i != Filter::Invalid; i = m_gameFilter.next(i))
		f.set(m_db.gameInfo(i).eventEntry()->id());

	for (unsigned i = 0; i < m_db.countEvents(); ++i)
	{
		if (f.test(m_db.event(i).id()))
			m_eventFilter.add(i);
	}

	m_eventSelector.update(m_eventFilter);
}


void
View::setGameFilter(Filter const& filter)
{
	M_REQUIRE(filter.size() == m_db.countGames());

	m_gameFilter = filter;
	m_gameSelector.update(m_gameFilter);
}


db::TournamentTable*
View::makeTournamentTable() const
{
	return m_db.makeTournamentTable(m_gameFilter);
}


View::Result
View::dumpGame(unsigned index, mstl::string const& fen, mstl::string& result) const
{
	Game game;

	load::State state = m_db.loadGame(gameIndex(index), game);

	if (state != load::Ok)
		return Result(state, 0);

	if (!fen.empty())
		game.goToPosition(fen);

	return Result(state, game.dumpMoves(result));
}


View::Result
View::dumpGame(unsigned index,
					unsigned split,
					mstl::string const& fen,
					StringList& result,
					StringList& positions) const
{
	typedef mstl::vector<unsigned> LengthList;

	Game game;

	load::State state = m_db.loadGame(gameIndex(index), game);

	if (state != load::Ok)
		return Result(state, 0);

	if (!fen.empty())
		game.goToPosition(fen);

	unsigned		moves = game.countHalfMoves();
	unsigned		count	= 0;
	LengthList	lengths;

	if (moves == 0)
	{
		lengths.push_back(0);
		result.resize(1);
	}
	else if (!fen.empty() || game.startBoard().isStandardPosition())
	{
		unsigned	size	= mstl::min(moves, split);
		double	delta	= double(moves)/double(size);

		result.resize(size);
		lengths.resize(size);

		for (unsigned i = 0; i < size; ++i)
			count += (lengths[i] = game.dumpMoves(result[i], unsigned((i + 1)*delta + 0.5) - count));
	}
	else
	{
		unsigned	size	= mstl::min(moves + 1, split);
		double	delta	= double(moves)/double(mstl::min(moves, split - 1));

		result.resize(size);
		lengths.resize(size);

		lengths[0] = 0;

		for (unsigned i = 1; i < size; ++i)
			count += (lengths[i] = game.dumpMoves(result[i], unsigned(i*delta + 0.5) - count));
	}

	if (fen.empty())
		game.moveToMainlineStart();
	else
		game.goToPosition(fen);

	for (unsigned i = 0; i < lengths.size(); ++i)
	{
		game.forward(lengths[i]);
		positions.push_back();
		game.currentBoard().toFen(positions.back());
	}

	return Result(state, count);
}


template <class Destination>
unsigned
View::exportGames(Destination& destination, GameMode gameMode, db::Log& log, util::Progress& progress)
{
	unsigned frequency = progress.frequency(m_gameFilter.count());

	if (frequency == 0)
		frequency = mstl::min(10000u, mstl::max(m_gameFilter.count()/100, 1u));

	unsigned reportAfter = frequency;

	util::ProgressWatcher watcher(progress, m_gameFilter.count());

	unsigned count		= 0;
	unsigned numGames	= 0;

	for (int i = m_gameFilter.next(Filter::Invalid); i != Filter::Invalid; i = m_gameFilter.next(i))
	{
		if (reportAfter == count++)
		{
			progress.update(count);
			reportAfter += frequency;
		}

		if (gameMode == AllGames || !m_db.gameInfo(i).containsIllegalMoves())
		{
			save::State state = m_db.exportGame(i, destination);

			if (state == save::Ok)
				++numGames;
			else if (!log.error(state, m_gameSelector.map(i)))
				return numGames;
		}
	}

	return numGames;
}


unsigned
View::exportGames(mstl::string const& filename,
						mstl::string const& encoding,
						mstl::string const& description,
						type::ID type,
						unsigned flags,
						GameMode gameMode,
						TagBits const& allowedTags,
						bool allowExtraTags,
						Log& log,
						util::Progress& progress,
						FileMode fmode)
{
	M_REQUIRE(!application().contains(filename));

	typedef DatabaseCodec::Format Format;

	mstl::string	ext	= util::misc::file::suffix(filename);
	unsigned			count	= 0;

	if (ext == "sci")
	{
		Database destination(filename, sys::utf8::Codec::utf8(), Database::OnDisk);
		destination.setDescription(description);
		destination.setType(type);

		if (m_db.format() == format::Scidb && fmode != Upgrade)
		{
			count = exportGames(destination, gameMode, log, progress);
		}
		else
		{
			sci::Consumer consumer(	m_db.format(),
											dynamic_cast<sci::Codec&>(destination.codec()),
											allowedTags,
											allowExtraTags);
			count = exportGames(consumer, gameMode, log, progress);
		}

		destination.save(progress);
		destination.close();
	}
	else if (ext == "si3" || ext == "si4")
	{
		Database destination(filename, sys::utf8::Codec::utf8(), Database::OnDisk);
		destination.setDescription(description);
		destination.setType(type);

//		We do not use speed up because the scid bases created with the Scid application
//		may contain some broken data. The exporting will fix the data.
//		if (	m_db.format() == format::Scid
//			&& (ext == "si4" || dynamic_cast<si3::Codec&>(m_db.codec()).isFormat3()))
//		{
//			count = exportGames(destination, gameMode, log, progress);
//		}
//		else
		{
			format::Type format(ext == "si3" ? format::Scid3 : format::Scid4);
			si3::Consumer consumer(	format,
											dynamic_cast<si3::Codec&>(destination.codec()),
											encoding,
											allowedTags,
											allowExtraTags);
			count = exportGames(consumer, gameMode, log, progress);
		}

		destination.save(progress);
		destination.close();
	}
	else if (ext == "pgn" || ext == "gz" || ext == "zip")
	{
		util::ZStream::Type type;

		if (ext == "gz")			type = util::ZStream::GZip;
		else if (ext == "zip")	type = util::ZStream::Zip;
		else							type = util::ZStream::Text;

		mstl::ios_base::openmode mode = mstl::ios_base::out;

		if (fmode == Append)
		{
			int64_t size;

			if (size > 0 && type != util::ZStream::Zip && util::ZStream::size(filename, size))
				flags |= PgnWriter::Flag_Append_Games;

			mode |= mstl::ios_base::app;
		}

		util::ZStream strm(filename, type, mode);
		PgnWriter writer(format::Pgn, strm, encoding, flags);
		count = exportGames(writer, gameMode, log, progress);
	}
	else if (ext == "pdf")
	{
		// TODO
	}
	else if (ext == "tex")
	{
		// TODO
	}
	else if (ext == "htm" || ext == "html")
	{
		// TODO
	}
	else
	{
		M_RAISE("unsupported extension: %s", ext.c_str());
	}

	return count;
}

// vi:set ts=3 sw=3:
