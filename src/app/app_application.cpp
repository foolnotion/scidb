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

#include "app_application.h"
#include "app_multi_cursor.h"
#include "app_cursor.h"
#include "app_view.h"
#include "app_engine.h"

#include "db_multi_base.h"
#include "db_database.h"
#include "db_database_codec.h"
#include "db_game.h"
#include "db_game_info.h"
#include "db_eco_table.h"
#include "db_tree.h"
#include "db_board.h"
#include "db_line.h"
#include "db_pgn_writer.h"
#include "db_latex_writer.h"
#include "db_producer.h"
#include "db_exception.h"

#include "u_misc.h"
#include "u_progress.h"
#include "u_zstream.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"
#include "sys_thread.h"

#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_algorithm.h"
#include "m_function.h"
#include "m_bitset.h"
#include "m_auto_ptr.h"
#include "m_limits.h"
#include "m_string.h"
#include "m_assert.h"
#include "m_stdio.h"

#include <string.h>

using namespace db;
using namespace app;
using namespace util;


Application* Application::m_instance = 0;

unsigned const Application::InvalidPosition;
unsigned const Application::ReservedPosition;

static unsigned undoLevel = 20;
static unsigned undoCombinePredecessingMoves = 9999;


namespace {

struct WriteGuard
{
	void release() { m_app.setIsWriting(); }

	WriteGuard(Application& app, Cursor const& cursor)
		:m_app(app)
	{
		if (!cursor.isMemoryOnly())
			m_app.setIsWriting(cursor.name());
	}

	~WriteGuard() { release(); }

	Application& m_app;
};

} // namespace

namespace app {

bool operator==(Cursor const* cursor, mstl::string const& name)
{
	return cursor->database().name() == name;
}

} // namespace app


Application::EditGame::Data::Data()
	:viewId(-1)
	,game(0)
	,backup(0)
	,refresh(0)
{
}


Application::EditGame::Data::~Data()
{
	delete game;
	delete backup;
}


Application::EditGame::Sink::Sink()
	:cursor(0)
	,index(0)
	,crcIndex(0)
	,crcMoves(0)
	,crcMainline(0)
{
}


Application::EditGame::Link::Link()
	:index(0)
	,crcIndex(0)
	,crcMoves(0)
{
}


Application::Subscriber::~Subscriber() {}


void
Application::Subscriber::updateList(unsigned id, mstl::string const& name, variant::Type variant)
{
	for (unsigned i = 0; i < table::LAST; ++i)
		updateList(table::Type(i), id, name, variant);
}


void
Application::Subscriber::updateList(unsigned id,
												mstl::string const& name,
												variant::Type variant,
												unsigned view)
{
	for (unsigned i = 0; i < table::LAST; ++i)
		updateList(table::Type(i), id, name, variant, view);
}


Application::Iterator::Iterator(CursorMap::const_iterator begin, CursorMap::const_iterator end)
	:m_current(begin)
	,m_end(end)
	,m_variant(0)
{
}


bool
Application::Iterator::operator!=(Iterator const& i) const
{
	return m_current != i.m_current;
}


Cursor*
Application::Iterator::operator->()
{
	M_ASSERT(m_current != m_end);
	M_ASSERT(m_variant < variant::NumberOfVariants);
	M_ASSERT(m_current->second->exists(m_variant));

	return (*m_current->second)[m_variant];
}


Cursor&
Application::Iterator::operator*()
{
	M_ASSERT(m_current != m_end);
	M_ASSERT(m_variant < variant::NumberOfVariants);
	M_ASSERT(m_current->second->exists(m_variant));

	return *(*m_current->second)[m_variant];
}


Application::Iterator&
Application::Iterator::operator++()
{
	M_ASSERT(m_current != m_end);

	do
	{
		if (++m_variant == variant::NumberOfVariants)
		{
			if (++m_current == m_end)
				return *this;

			m_variant = 0;
		}
	}
	while ((*m_current->second)[m_variant] == 0);

	return *this;
}


Application::Application()
	:m_current(0)
	,m_clipbase(0)
	,m_referenceBase(0)
	,m_switchReference(true)
	,m_isUserSet(false)
	,m_currentPosition(InvalidPosition)
	,m_fallbackPosition(InvalidPosition)
	,m_updateCount(0)
	,m_numEngines(0)
	,m_engineLog(0)
	,m_isClosed(false)
	,m_treeIsFrozen(false)
	,m_subscriber(0)
{
	M_REQUIRE(!hasInstance());

	m_instance = this;

	MultiCursor* clipbase		= new MultiCursor(*this, MultiCursor::Clipbase);
	MultiCursor* scratchbase	= new MultiCursor(*this, MultiCursor::Scratchbase);

	m_cursorMap[clipbase->name()].reset(clipbase);
	m_cursorMap[scratchbase->name()].reset(scratchbase);

	m_clipbase = (*clipbase)[variant::Index_Normal];
	setActiveBase(m_clipbase);
	setReferenceBase(0, false);
}


Application::~Application() throw()
{
	m_instance = 0;

	for (EngineList::iterator i = m_engineList.begin(); i != m_engineList.end(); ++i)
	{
		(*i)->deactivate();
		delete *i;
	}

	m_gameMap.clear();
}


Application::Iterator
Application::begin() const
{
	return Iterator(m_cursorMap.begin(), m_cursorMap.end());
}


Application::Iterator
Application::end() const
{
	return Iterator(m_cursorMap.end(), m_cursorMap.end());
}


mstl::string const& Application::clipbaseName()		{ return MultiCursor::clipbaseName(); }
mstl::string const& Application::scratchbaseName()	{ return MultiCursor::scratchbaseName(); }


Cursor*
Application::clipbase(unsigned variantIndex) const
{
	M_ASSERT(contains(scratchbaseName()));
	return (*m_cursorMap.find(clipbaseName())->second)[variantIndex];
}


Cursor*
Application::scratchbase(unsigned variantIndex) const
{
	M_ASSERT(contains(scratchbaseName()));
	return (*m_cursorMap.find(scratchbaseName())->second)[variantIndex];
}


Cursor*
Application::clipbase(variant::Type variant) const
{
	M_ASSERT(variant::isMainVariant(variant));
	return clipbase(variant::toIndex(variant));
}


Cursor*
Application::scratchbase(variant::Type variant) const
{
	M_ASSERT(variant::isMainVariant(variant));
	return scratchbase(variant::toIndex(variant));
}


void
Application::setActiveBase(Cursor* cursor)
{
	M_ASSERT(cursor);

	if (m_current != cursor)
	{
		if (m_current)
			m_current->setActive(false);

		(m_current = cursor)->setActive(true);
		m_clipbase = clipbase(cursor->database().variant());

		if (m_subscriber)
			m_subscriber->updateDatabaseInfo(cursor->name(), cursor->variant());
	}
}


unsigned
Application::countGames(mstl::string const& name) const
{
	M_REQUIRE(contains(name));
	return m_cursorMap[name]->countGames();

}


Application::Variants
Application::getAllVariants(mstl::string const& name) const
{
	M_REQUIRE(contains(name));

	Variants variants;
	MultiCursor const& cursor = *m_cursorMap[name];

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (cursor.exists(v))
			variants.set(v);
	}

	return variants;
}


Application::Variants
Application::getAllVariants() const
{
	Variants variants;
	variants.set(variant::Index_Normal);

	for (CursorMap::const_iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
	{
		if (!i->second->isScratchbase())
		{
			for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
			{
				if (i->second->exists(v) && (!i->second->isClipbase() || !i->second->isEmpty(v)))
					variants.set(v);
			}
		}
	}

	return variants;
}


Application::GameP
Application::insertGame(unsigned position)
{
	GameP& game = m_gameMap[position];
	game.reset(new EditGame);
	game->data.game = new Game;
	return game;
}


Application::GameP
Application::insertScratchGame(unsigned position, variant::Type variant)
{
	M_REQUIRE(variant != variant::Undetermined);
	M_REQUIRE(contains(scratchbaseName()));

	Cursor*		scratch	= scratchbase(variant::toMainVariant(variant));
	Database&	base		= scratch->base();
	GameP			gameP		= insertGame(position);
	EditGame&	game		= *gameP;

	unsigned index;

	IndexMap::const_iterator i = m_indexMap.find(position);
	if (i == m_indexMap.end())
	{
		GameInfo info;
		mstl::string const& empty = mstl::string::empty_string;

		Namebase::PlayerEntry*	player		= base.namebase(Namebase::Player).insertPlayer(empty);
		Namebase::SiteEntry*		site			= base.namebase(Namebase::Site).insertSite(empty);
		Namebase::EventEntry*	event			= base.namebase(Namebase::Event).insertEvent(empty, site);
		Namebase::Entry*			annotator	= base.namebase(Namebase::Annotator).insert(empty);

		info.setup(0, 0, player, player, event, annotator, base.namebases());
		base.namebases().update();
		game.data.game->finishLoad(variant);
		m_indexMap[position] = index = base.countGames();

		if (!save::isOk(base.newGame(*game.data.game, info)))
			M_RAISE("unexpected error: couldn't add new game to Scratchbase");
	}
	else
	{
		game.data.game->finishLoad(variant);
		index = i->second;
	}

	TagSet tags;
	base.getGameTags(index, tags);

	game.sink.cursor = scratch;
	game.sink.index = index;
	game.data.game->setUndoLevel(::undoLevel, ::undoCombinePredecessingMoves);
	game.sink.crcIndex = base.computeChecksum(index);
	game.sink.crcMoves = tags.computeChecksum(game.data.game->computeChecksum());
	game.sink.crcMainline = game.data.game->computeChecksumOfMainline();
	game.data.refresh = 0;
	game.data.encoding = sys::utf8::Codec::utf8();
	game.link.databaseName = base.name();
	game.link.index = index;
	game.link.crcIndex = game.sink.crcIndex;
	game.link.crcMoves = game.sink.crcMoves;

	return gameP;
}


bool
Application::initialize(mstl::string const& ecoPath)
{
	mstl::ifstream ecoStream(ecoPath, mstl::ios_base::in | mstl::ios_base::binary);

	if (!ecoStream)
		return false;

	EcoTable::specimen(variant::Index_Normal).load(ecoStream, variant::Normal);
	return true;
}


variant::Type
Application::currentVariant() const
{
	return m_current ? m_current->variant() : variant::Normal;
}


bool
Application::contains(Cursor& cursor) const
{
	return m_cursorMap.find(cursor.name()) != m_cursorMap.end();
}


bool
Application::contains(mstl::string const& name) const
{
	return m_cursorMap.find(name) != m_cursorMap.end();
}


bool
Application::contains(mstl::string const& name, variant::Type variant) const
{
	M_REQUIRE(variant == variant::Undetermined || variant::isMainVariant(variant));

	CursorMap::const_iterator i = m_cursorMap.find(name);
	if (i == m_cursorMap.end())
		return false;
	if (variant == variant::Undetermined)
		return true;
	return (*i->second)[variant];
}


bool
Application::contains(char const* name, variant::Type variant) const
{
	if (name == 0)
		return currentVariant() == variant;

	return contains(mstl::string(name), variant);
}


bool
Application::containsGameAt(unsigned position) const
{
	if (position == InvalidPosition)
		position = m_currentPosition;

	if (position == InvalidPosition)
		return false;

	return m_gameMap.find(position) != m_gameMap.end();
}


bool
Application::isScratchGame(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (!contains(scratchbaseName()))
		return false;

	if (position == InvalidPosition)
		position = m_currentPosition;

	EditGame const& g = *m_gameMap.find(position)->second;
	return g.sink.cursor == scratchbase(variant::toMainVariant(g.data.game->variant()));
}


bool
Application::hasTrialMode(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(m_currentPosition)->second->data.backup != 0;
}


unsigned
Application::countModifiedGames() const
{
	unsigned n = 0;

	for (GameMap::const_iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->data.game->isModified())
			++n;
	}

	return n;
}


bool
Application::isSingleBase(mstl::string const& name) const
{
	M_REQUIRE(contains(name));

	CursorMap::const_iterator i = m_cursorMap.find(name);
	M_ASSERT(i != m_cursorMap.end());
	return i->second->isSingleBase();
}


Cursor*
Application::findBase(mstl::string const& name)
{
	CursorMap::iterator i = m_cursorMap.find(name);
	if (i == m_cursorMap.end())
		return 0;
	return &i->second->cursor();
}


Cursor const*
Application::findBase(mstl::string const& name) const
{
	CursorMap::const_iterator i = m_cursorMap.find(name);
	if (i == m_cursorMap.end())
		return 0;
	return &i->second->cursor();
}


Cursor*
Application::findBase(mstl::string const& name, variant::Type variant)
{
	M_REQUIRE(variant == variant::Undetermined || variant::isMainVariant(variant));

	CursorMap::iterator i = m_cursorMap.find(name);
	if (i == m_cursorMap.end())
		return 0;
	return (*i->second)[variant];
}


Cursor const*
Application::findBase(mstl::string const& name, variant::Type variant) const
{
	M_REQUIRE(variant == variant::Undetermined || variant::isMainVariant(variant));

	CursorMap::const_iterator i = m_cursorMap.find(name);
	if (i == m_cursorMap.end())
		return 0;
	return (*i->second)[variant];
}


Application::EditGame*
Application::findGame(Cursor* cursor, unsigned index, unsigned* position)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		EditGame& game = *i->second;

		if (game.sink.cursor == cursor && game.sink.index == index)
		{
			if (position)
				*position = i->first;

			return &game;
		}
	}

	return 0;
}


mstl::string const&
Application::encoding(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->data.encoding;
}


Cursor*
Application::open(mstl::string const& name,
						mstl::string const& encoding,
						permission::ReadMode permission,
						process::Mode processMode,
						util::Progress& progress)
{
	// IMPORTANT NOTE:
	// -------------------------------------------------------------------------------------------
	// This function assumes:
	// -------------------------------------------------------------------------------------------
	// 1. the file name is resolved (no symbolic link)
	// 2. the file name is normalized
	// 3. it has a different inode than any other database (no link to an already opened database)
	// If these conditions do not fit the application may crash.

	if (m_cursorMap.find(name) != m_cursorMap.end())
		return 0;

	MultiBase* multiBase = new MultiBase(	name,
														encoding,
														permission,
														progress);
	MultiCursor* cursor = new MultiCursor(*this, multiBase);

	m_cursorMap[name] = cursor;
	moveGamesBackToDatabase(cursor->cursor());
	return &cursor->cursor();
}


Cursor*
Application::create(	mstl::string const& name,
							variant::Type variant,
							mstl::string const& encoding,
							type::ID type)
{
	M_REQUIRE(variant::isMainVariant(variant));

	if (m_cursorMap.find(name) != m_cursorMap.end())
		return 0;

	MultiBase*		multiBase	= new MultiBase(name, encoding, variant, storage::MemoryOnly, type);
	MultiCursor*	cursor		= new MultiCursor(*this, multiBase);

	m_cursorMap[name] = cursor;
	return &cursor->cursor();
}


unsigned
Application::create(	mstl::string const& name,
							type::ID type,
							Producer& producer,
							util::Progress& progress)
{
	M_REQUIRE(!contains(name));

	MultiCursor* cursor = new MultiCursor(*this, name, type, producer, progress);
	m_cursorMap[name] = cursor;
	return cursor->countGames();
}


void
Application::close()
{
	m_subscriber.reset(0);
	closeAll(Including_Clipbase);
	m_isClosed = true;
}


void
Application::close(mstl::string const& name)
{
	M_REQUIRE(contains(name));
	M_REQUIRE(name != clipbaseName());
	M_REQUIRE(name != scratchbaseName());

	CursorP multiCursor = m_cursorMap.find(name)->second;

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (multiCursor->exists(v))
		{
			if (m_subscriber)
				m_subscriber->closeDatabase(name, variant::fromIndex(v));

			Cursor* cursor = (*multiCursor)[v];

			moveGamesToScratchbase(*cursor);

			if (m_current == cursor)
				setActiveBase(m_clipbase);

			if (m_referenceBase == cursor)
				setReferenceBase(0, false);
		}
	}

	multiCursor->close();
	m_cursorMap.erase(name);
}


void
Application::closeAll(CloseMode mode)
{
	CursorMap map;
	Cursor* refBase = 0;

	setActiveBase(clipbase(variant::Normal));

	for (CursorMap::iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
	{
		if (i->second->isScratchbase())
		{
			map[scratchbaseName()] = i->second;
		}
		else if (i->second->isClipbase() && mode != Including_Clipbase)
		{
			map[clipbaseName()] = i->second;
		}
		else
		{
			for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
			{
				if (Cursor* cursor = (*i->second)[v])
				{
					moveGamesToScratchbase(*cursor);

					if (m_subscriber)
						m_subscriber->closeDatabase(cursor->name(), variant::fromIndex(v));

					if (cursor == m_referenceBase)
					{
						stopUpdateTree();

						if (mode != Including_Clipbase)
							refBase = clipbase(variant::Normal);
					}
				}
			}

			i->second->close();
		}
	}

	m_cursorMap.swap(map);

	if (refBase)
		setReferenceBase(refBase, false);
}


void
Application::closeAllGames(Cursor& cursor)
{
	M_REQUIRE(contains(cursor));

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->sink.cursor == &cursor)
		{
			unsigned		position	= i->first;
			EditGame&	game		= *i->second;

			if (game.sink.cursor->isScratchbase())
				m_indexMap.erase(position);

			stopAnalysis(game.data.game);
			i = m_gameMap.erase(i);

			if (m_currentPosition == position)
				m_currentPosition = InvalidPosition;
		}
	}

	if (m_referenceBase && m_referenceBase->variant() != variant::Normal)
		setReferenceBase(clipbase(variant::Normal));
}


GameInfo const&
Application::gameInfo(unsigned index, unsigned view) const
{
	return m_current->base().gameInfo(m_current->index(table::Games, index, view));
}


GameInfo const&
Application::gameInfoAt(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	EditGame const& game = *m_gameMap.find(position)->second;
	return game.sink.cursor->base().gameInfo(game.sink.index);
}


unsigned
Application::gameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->sink.index;
}


unsigned
Application::gameNumber(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	EditGame const& game = *m_gameMap.find(position)->second;
	return game.sink.cursor->index(table::Games, game.sink.index, 0);
}


Cursor const&
Application::getGameCursor(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));
	return *m_gameMap.find(position)->second->sink.cursor;
}


unsigned
Application::sourceIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->link.index;
}


Application::checksum_t
Application::sourceCrcIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->link.crcIndex;
}


Application::checksum_t
Application::sourceCrcMoves(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->link.crcMoves;
}


Database const&
Application::database(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->sink.cursor->database();
}


mstl::string const&
Application::databaseName(unsigned position) const
{
	return database(position).name();
}


mstl::string const&
Application::sourceName(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->link.databaseName;
}


variant::Type
Application::variant(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->sink.cursor->variant();
}


void
Application::setSource(	unsigned position,
								mstl::string const& name,
								unsigned index,
								checksum_t crcIndex,
								checksum_t crcMoves)
{
	M_REQUIRE(containsGameAt(position));

	EditGame& game = *m_gameMap.find(position)->second;
	game.link.databaseName = name;
	game.link.index = index;
	game.link.crcIndex = crcIndex;
	game.link.crcMoves = crcMoves;
}


void
Application::setReadonly(Cursor& cursor, bool flag)
{
	if (flag != cursor.base().isReadonly())
	{
		cursor.base().setReadonly(flag);

		if (m_subscriber)
			m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());
	}
}


::util::crc::checksum_t
Application::checksumIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->sink.crcIndex;
}


::util::crc::checksum_t
Application::checksumMoves(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return m_gameMap.find(position)->second->sink.crcMoves;
}


NamebasePlayer const&
Application::player(unsigned index, unsigned view) const
{
	return m_current->base().player(m_current->index(table::Players, index, view));
}


void
Application::setReferenceBase(Cursor* cursor, bool isUserSet)
{
	M_REQUIRE(cursor == 0 || !cursor->isScratchbase());
	M_REQUIRE(cursor == 0 || !format::isChessBaseFormat(cursor->format()));
	M_REQUIRE(cursor == 0 || cursor->variant() == variant::Normal);

	m_isUserSet = isUserSet;

	if (cursor != m_referenceBase)
	{
		if (m_referenceBase)
		{
			m_referenceBase->closeTreeView();
			m_referenceBase->setReferenceBase(false);
		}

		stopUpdateTree();
		m_referenceBase = cursor;

		if (m_referenceBase)
		{
			m_referenceBase->setReferenceBase(true);
			m_referenceBase->newTreeView();

			if (m_subscriber && !m_treeIsFrozen)
				m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
		}
		else if (m_subscriber && !m_treeIsFrozen)
		{
			m_subscriber->updateTree(mstl::string::empty_string, variant::Normal);
		}
	}
}


void
Application::setSubscriber(SubscriberP subscriber)
{
	m_subscriber = subscriber;
//	if ((m_subscriber = subscriber))
//	{
//		m_subscriber->updateGameList(m_updateCount++, cursor().name());
//
//		if (m_referenceBase)
//			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
//	}
}


void
Application::switchBase(Cursor& cursor)
{
	M_REQUIRE(contains(cursor));
	M_REQUIRE(!cursor.isScratchbase());

	setActiveBase(&cursor);

	if (	(m_switchReference || (!m_isUserSet && m_referenceBase->isClipbase()))
		&& !format::isChessBaseFormat(cursor.format())
		&& cursor.variant() == variant::Normal)
	{
		setReferenceBase(m_current, false);
	}

	if (m_subscriber)
	{
		m_subscriber->databaseSwitched(cursor.name(), cursor.variant());
		m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());
	}
}


void
Application::searchGames(Cursor& cursor, Query const& query, unsigned view, unsigned filter)
{
	View& v = cursor.view(view);

	v.searchGames(query);

	if (filter & Events)
	{
		v.filterOnGames(table::Events);
		v.updateSelector(table::Events);
	}

	if (filter & Players)
	{
		v.filterOnGames(table::Players);
		v.updateSelector(table::Players);
	}

	if (filter & Sites)
	{
		v.filterOnGames(table::Sites);
		v.updateSelector(table::Sites);
	}

	if (m_subscriber && m_current == &cursor)
	{
		m_subscriber->updateList(table::Games, m_updateCount, cursor.name(), cursor.variant(), view);

		if (filter & Players)
			m_subscriber->updateList(table::Players, m_updateCount, cursor.name(), cursor.variant(), view);

		if (filter & Events)
			m_subscriber->updateList(table::Events, m_updateCount, cursor.name(), cursor.variant(), view);

		if (filter & Sites)
			m_subscriber->updateList(table::Sites, m_updateCount, cursor.name(), cursor.variant(), view);
	}

	++m_updateCount;
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::game::ID attr,
						order::ID order,
						rating::Type ratingType)
{
	cursor.view(view).sort(attr, order, ratingType);
	cursor.view(view).updateSelector(table::Games);

	if (m_subscriber && m_current == &cursor)
		m_subscriber->updateList(table::Games, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::player::ID attr,
						order::ID order,
						rating::Type ratingType)
{
	cursor.view(view).sort(attr, order, ratingType);
	cursor.view(view).updateSelector(table::Players);

	if (m_subscriber)
		m_subscriber->updateList(table::Players, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::event::ID attr,
						order::ID order)
{
	cursor.view(view).sort(attr, order);
	cursor.view(view).updateSelector(table::Events);

	if (m_subscriber)
		m_subscriber->updateList(table::Events, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::site::ID attr,
						order::ID order)
{
	cursor.view(view).sort(attr, order);
	cursor.view(view).updateSelector(table::Sites);

	if (m_subscriber)
		m_subscriber->updateList(table::Sites, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::sort(Cursor& cursor, unsigned view, attribute::annotator::ID attr, order::ID order)
{
	cursor.view(view).sort(attr, order);
	cursor.view(view).updateSelector(table::Annotators);

	if (m_subscriber)
	{
		m_subscriber->updateList(	table::Annotators,
											m_updateCount++,
											cursor.name(),
											cursor.variant(),
											view);
	}
}


void
Application::reverseOrder(Cursor& cursor, unsigned view, table::Type type)
{
	cursor.view(view).reverseOrder(type);
	cursor.view(view).updateSelector(type);

	if (m_subscriber && m_current == &cursor)
		m_subscriber->updateList(type, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::resetOrder(Cursor& cursor, unsigned view, table::Type type)
{
	cursor.view(view).resetOrder(type);
	cursor.view(view).updateSelector(type);

	if (m_subscriber && m_current == &cursor)
		m_subscriber->updateList(type, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::recode(Cursor& cursor, mstl::string const& encoding, util::Progress& progress)
{
	Database& base = cursor.base();

	WriteGuard guard(*this, cursor);

	switch (base.format())
	{
		case format::Scidb:
			if (!base.isMemoryOnly())
				return;
			if (cursor.isReferenceBase())
				stopUpdateTree();
			// we have to use PGN reader
			base.reopen(encoding, progress);
			break;

		case format::Scid3:
		case format::Scid4:
		case format::ChessBase:
		case format::ChessBaseDOS:
			if (cursor.isReferenceBase())
				stopUpdateTree();
			if (base.namebases().isOriginal())
				base.recode(encoding, progress);
			else
				base.reopen(encoding, progress);
			break;

		case format::Pgn:
		case format::LaTeX:
			// cannot happen
			break;
	}

	guard.release();

	if (m_subscriber)
		m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());
}


load::State
Application::loadGame(	unsigned position,
								Cursor& cursor,
								unsigned index,
								mstl::string const* fen)
{
	M_REQUIRE(position != InvalidPosition);

	bool isNew = !containsGameAt(position);
	load::State state;

	try
	{
		Database& base	= cursor.base();
		EditGame& game	= *(isNew ? insertGame(position) : m_gameMap.find(position)->second);

		if (!isNew)
			game.data.game->resetForNextLoad();

		TagSet tags;
		base.getGameTags(index, tags);

		// TODO: compact scratch base (we need fast compact)

		game.data.game->setUndoLevel(::undoLevel, ::undoCombinePredecessingMoves);
		game.sink.cursor = &cursor;
		game.sink.index = index;

		state = base.loadGame(index, *game.data.game, game.data.encoding, fen);

		game.sink.crcIndex = base.computeChecksum(index);
		game.sink.crcMoves = tags.computeChecksum(game.data.game->computeChecksum());
		game.sink.crcMainline = game.data.game->computeChecksumOfMainline();
		game.link.databaseName = base.name();
		game.link.index = index;
		game.link.crcIndex = game.sink.crcIndex;
		game.link.crcMoves = game.sink.crcMoves;
		game.data.refresh = 0;

		if (position != ReservedPosition && !cursor.isScratchbase())
		{
			refreshGame(position);

			if (m_subscriber && !isNew)
				m_subscriber->updateGameInfo(position);
		}
	}
	catch (...)
	{
		if (isNew)
			releaseGame(position);

		throw;
	}

	return state;
}


load::State
Application::loadGame(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	EditGame const& game = *m_gameMap.find(position)->second;
	return loadGame(position, *game.sink.cursor, game.sink.index);
}


unsigned
Application::indexAt(unsigned position) const
{
	M_REQUIRE(position != InvalidPosition);
	M_REQUIRE(containsGameAt(position));

	return m_gameMap.find(position)->second->sink.index;
}


void
Application::newGame(unsigned position, variant::Type variant)
{
	M_REQUIRE(position != InvalidPosition);
	M_REQUIRE(!containsGameAt(position));

	insertScratchGame(position, variant);

	if (m_fallbackPosition == InvalidPosition)
		m_fallbackPosition = position;
}


void
Application::releaseGame(unsigned position)
{
	if (position == InvalidPosition)
		position = m_currentPosition;

	if (!containsGameAt(position))
		return;

	stopAnalysis(m_gameMap.find(position)->second->data.game);

	m_gameMap.erase(position);
	m_indexMap.erase(position);

	if (m_currentPosition == position)
		m_currentPosition = m_fallbackPosition;

	if (m_subscriber)
		m_subscriber->gameClosed(position);
}


void
Application::deleteGame(Cursor& cursor, unsigned index, unsigned view, bool flag)
{
	M_REQUIRE(!cursor.isReadonly());

	cursor.base().deleteGame(cursor.index(table::Games, index, view), flag);

	if (m_subscriber && m_current == &cursor)
	{
		for (unsigned i = 0; i < table::LAST; ++i)
		{
			m_subscriber->updateList(	table::Type(i),
												m_updateCount,
												cursor.name(),
												cursor.variant(),
												view,
												index);
		}

		++m_updateCount;
	}
}


void
Application::changeVariant(unsigned position, variant::Type variant)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(database(position).name() == scratchbaseName());
	M_REQUIRE(variant::isMainVariant(variant));

	EditGame& 		game					= *m_gameMap[position];
	variant::Type	originalVariant	= game.sink.cursor->variant();

	if (originalVariant != variant)
	{
		Cursor*				scratch		= scratchbase(variant::toMainVariant(variant));
		Database&			base			= scratch->base();
		GameInfo const&	info			= game.sink.cursor->base().gameInfo(game.sink.index);
		unsigned				index			= base.countGames();

		info.reallocate(base.namebases());
		base.namebases().update();
		game.data.game->finishLoad(variant);

		if (!save::isOk(base.newGame(*game.data.game, info)))
		{
			game.data.game->finishLoad(originalVariant);
			M_RAISE("unexpected error: couldn't add new game to Scratchbase");
		}

		TagSet tags;
		base.getGameTags(index, tags);

		m_indexMap[position] = index;

		game.sink.cursor = scratch;
		game.sink.index = index;
		game.sink.crcIndex = base.computeChecksum(index);
		game.sink.crcMoves = tags.computeChecksum(game.data.game->computeChecksum());
		game.sink.crcMainline = game.data.game->computeChecksumOfMainline();
		game.data.refresh = 0;
		game.link.databaseName = base.name();
		game.link.index = index;
		game.link.crcIndex = game.sink.crcIndex;
		game.link.crcMoves = game.sink.crcMoves;

		game.sink.cursor->base().deleteGame(game.sink.index, true);
		// TODO: compress database
	}
}


void
Application::swapGames(unsigned position1, unsigned position2)
{
	M_REQUIRE(containsGameAt(position1) || containsGameAt(position2));

	if (position1 == position2)
		return;

	if (!containsGameAt(position2))
		mstl::swap(position1, position2);

	if (!containsGameAt(position1))
	{
		GameP& copy = m_gameMap[position1];
		GameMap::iterator i = m_gameMap.find(position2);

		copy = i->second;
		m_gameMap.erase(i);

		IndexMap::iterator k = m_indexMap.find(position2);

		if (k != m_indexMap.end())
		{
			unsigned value = k->second;
			m_indexMap[position1] = value;
			m_indexMap.erase(m_indexMap.find(position2));
		}
	}
	else
	{
		mstl::swap(m_gameMap.find(position1)->second, m_gameMap.find(position2)->second);

		IndexMap::iterator j = m_indexMap.find(position1);
		IndexMap::iterator k = m_indexMap.find(position2);

		if (j != m_indexMap.end() && k != m_indexMap.end())
		{
			mstl::swap(j->second, k->second);
		}
		else if (j != m_indexMap.end())
		{
			unsigned value = j->second;
			m_indexMap[position2] = value;
			m_indexMap.erase(m_indexMap.find(position1));
		}
		else if (k != m_indexMap.end())
		{
			unsigned value = k->second;
			m_indexMap[position1] = value;
			m_indexMap.erase(m_indexMap.find(position2));
		}
	}

	if (m_currentPosition == position1)
		m_currentPosition = position2;
	else if (m_currentPosition == position2)
		m_currentPosition = position1;
}


void
Application::setGameFlags(Cursor& cursor, unsigned index, unsigned view, unsigned flags)
{
	M_REQUIRE(!cursor.isReadonly());

	cursor.base().setGameFlags(cursor.index(table::Games, index, view), flags);

	if (m_subscriber && m_current == &cursor)
	{
		m_subscriber->updateList(	table::Games,
											m_updateCount,
											cursor.name(),
											cursor.variant(),
											view,
											index);
	}
}


void
Application::setupGame(Board const& startPosition)
{
	M_REQUIRE(haveCurrentGame());

	EditGame& game = *m_gameMap[m_currentPosition];

	game.data.game->setup(startPosition);
	game.data.game->updateSubscriber(Game::UpdateBoard | Game::UpdatePgn);

	if (m_subscriber && m_referenceBase && !m_treeIsFrozen)
		m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
}


void
Application::clearGame(Board const* startPosition)
{
	M_REQUIRE(haveCurrentGame());

	EditGame& game = *m_gameMap[m_currentPosition];

	game.data.game->clear(startPosition);

	if (m_subscriber && m_referenceBase && !m_treeIsFrozen)
		m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
}


Application::GameP
Application::createIntermediateGame(GameP original)
{
	GameP scratchGame = insertScratchGame(ReservedPosition, original->data.game->variant());
	*scratchGame->data.game = *original->data.game;
	scratchGame->data.game->setIndex(scratchGame->sink.index);

	Database& database = scratchGame->sink.cursor->base();
	GameInfo info(scratchGame->sink.cursor->base().gameInfo(scratchGame->sink.index));

	info = original->sink.cursor->base().gameInfo(original->sink.index);
	info.reallocate(database.namebases());
	database.namebases().update();

	return scratchGame;
}


save::State
Application::writeGame(	unsigned position,
								mstl::string const& filename,
								mstl::string const& encoding,
								mstl::string const& comment,
								unsigned flags,
								FileMode fmode)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(	util::misc::file::suffix(filename) == "pgn"
				|| util::misc::file::suffix(filename) == "gz"
				|| util::misc::file::suffix(filename) == "zip");

	if (position == InvalidPosition)
		position = currentPosition();

	GameP g = m_gameMap.find(position)->second;
	mstl::string internalName(sys::file::internalName(filename));
	save::State state = save::Ok;

	if (isScratchGame(position))
	{
		g->data.game->setIndex(m_indexMap[position]);
	}
	else if (g->data.game->isModified())
	{
		g = createIntermediateGame(g);
		position = ReservedPosition;
	}
	else
	{
		g->data.game->setIndex(g->sink.index);
	}

	try
	{
		if (isScratchGame(position))
			state = g->sink.cursor->base().updateGame(*g->data.game);

		if (save::isOk(state))
		{
			util::ZStream::Type type;
			mstl::string ext = util::misc::file::suffix(filename);

			if (ext == "gz")			type = util::ZStream::GZip;
			else if (ext == "zip")	type = util::ZStream::Zip;
			else							type = util::ZStream::Text;

			mstl::ios_base::openmode mode = mstl::ios_base::out;

			if (fmode == Append)
			{
				if (type != util::ZStream::Zip)
				{
					mstl::ifstream strm(internalName, mstl::ios_base::in);

					if (strm)
					{
						char buf[3];

						mode |= mstl::ios_base::app;
						flags |= PgnWriter::Flag_Append_Games;

						if (strm.read(buf, 3) && ::memcmp(buf, "\xef\xbb\xbf", 3) == 0)
							flags |= PgnWriter::Flag_Use_UTF8;
						else
							flags &= ~PgnWriter::Flag_Use_UTF8;
					}
				}
			}
			else
			{
				mode = mstl::ios_base::trunc;
			}

			mstl::ofstream strm(internalName, mode);

			if (!strm)
				IO_RAISE(Unspecified, Write_Failed, "cannot open file '%s'", filename.c_str());

			mstl::string useEncoding;

			if (flags & PgnWriter::Flag_Use_UTF8)
				useEncoding = sys::utf8::Codec::utf8();
			else if (encoding == sys::utf8::Codec::utf8())
				useEncoding = sys::utf8::Codec::latin1();
			else
				useEncoding = encoding;

			PgnWriter writer(format::Scidb, strm, useEncoding, flags);
			writer.setupVariant(g->sink.cursor->variant());

			if (!comment.empty())
				writer.writeCommentLines(comment);

			state = g->sink.cursor->database().exportGame(g->data.game->index(), writer);
		}
	}
	catch (...)
	{
		releaseGame(ReservedPosition);
		throw;
	}

	if (position == ReservedPosition)
		releaseGame(ReservedPosition);

	return state;
}


void
Application::switchGame(unsigned position)
{
	M_REQUIRE(position != ReservedPosition);
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = currentPosition();

	stopUpdateTree();

	EditGame& game = *m_gameMap[position];

	m_currentPosition = position;

	if (game.data.refresh)
	{
		unsigned flags = Game::UpdateNewPosition;

		if (game.data.refresh == 2)
			flags |= Game::UpdateAll;
		else
			flags |= Game::UpdateNewPosition | Game::UpdatePgn | Game::UpdateOpening;

		game.data.game->refreshSubscriber(flags);
		game.data.refresh = 0;
	}
	else
	{
		game.data.game->updateSubscriber(Game::UpdateNewPosition);
	}

	if (m_subscriber)
	{
		m_subscriber->gameSwitched(position);

		if (m_referenceBase && !m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}
}


void
Application::startTrialMode()
{
	M_REQUIRE(!hasTrialMode());

	EditGame& game = *m_gameMap[m_currentPosition];

	game.data.backup = game.data.game;
	game.data.game = new Game(*game.data.backup);
	game.data.game->moveTo(game.data.backup->currentKey());
}


void
Application::endTrialMode()
{
	M_REQUIRE(hasTrialMode());

	EditGame& game = *m_gameMap[m_currentPosition];

	delete game.data.game;
	game.data.game = game.data.backup;
	game.data.game->moveTo(game.data.backup->currentKey());
	game.data.backup = 0;
}


void
Application::refreshGames()
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->sink.cursor->isScratchbase())
			i->second->data.refresh = 2;
	}
}


void
Application::refreshGame(unsigned position, bool immediate)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	EditGame& game = *m_gameMap.find(position)->second;

	if (position == m_currentPosition || immediate)
		game.data.game->refreshSubscriber(Game::UpdateAll | Game::UpdateNewPosition);
	else
		game.data.refresh = 2;
}


Game&
Application::game(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return *m_gameMap.find(position)->second->data.game;
}


Game const&
Application::game(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	return *m_gameMap.find(position)->second->data.game;
}


void
Application::moveGamesToScratchbase(Cursor& cursor, bool overtake)
{
	if (cursor.isScratchbase())
		return;

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		EditGame& game = *i->second;

		if (game.sink.cursor == &cursor)
		{
			Cursor*		scratch	= scratchbase(variant::toMainVariant(game.data.game->variant()));
			Database&	base		= scratch->base();

			unsigned index = base.countGames();

			m_indexMap[i->first] = index;

			GameInfo info(game.sink.cursor->base().gameInfo(game.sink.index));
			info.reallocate(base.namebases());
			base.namebases().update();

			if (base.newGame(*game.data.game, info) != save::Ok)
				M_RAISE("unexpected error: couldn't add new game to Scratchbase");

			game.sink.cursor = scratch;
			game.sink.index = index;

			if (overtake)
			{
				game.link.databaseName = scratch->name();
				game.link.index = index;
				game.link.crcIndex = game.sink.crcIndex;
				game.link.crcMoves = game.sink.crcMoves;
			}
		}
	}
}


void
Application::moveGamesBackToDatabase(Cursor& cursor)
{
	if (cursor.isScratchbase())
		return;

	mstl::string const& databaseName = cursor.base().name();

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		EditGame& game = *i->second;

		if (game.sink.cursor->isScratchbase() && game.link.databaseName == databaseName)
		{
			Database& base = cursor.base();

			if (game.link.index < base.countGames())
			{
				m_indexMap.erase(i->first);

				game.sink.cursor = &cursor;
				game.sink.index = game.link.index;
				game.sink.crcIndex = game.link.crcIndex;
				game.sink.crcMoves = game.link.crcMoves;
			}
		}
	}
}


void
Application::clearBase(MultiCursor& cursor)
{
	M_REQUIRE(!cursor.isReadonly());

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (Cursor* c = cursor[v])
			clearBase(*c);
	}
}


void
Application::clearBase(Cursor& cursor)
{
	M_REQUIRE(!cursor.isReadonly());
	M_REQUIRE(!cursor.isScratchbase());

	moveGamesToScratchbase(cursor);
	cursor.clearBase();

	if (m_subscriber)
	{
		m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());

		if (m_current == &cursor)
			m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());

		if (m_referenceBase == &cursor && !m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}
}


void
Application::compactBase(Cursor& cursor, util::Progress& progress)
{
	M_REQUIRE(!cursor.isReadonly());
	M_REQUIRE(!cursor.isScratchbase());

	if (cursor.isReferenceBase())
		cancelUpdateTree();

	if (cursor.compact(progress))
	{
		m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());

		if (m_current == &cursor)
			m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());

		if (cursor.isReferenceBase() && !m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}
}


bool
Application::treeIsUpToDate(Tree::Key const& key) const
{
	if (m_treeIsFrozen || m_referenceBase == 0 || !haveCurrentGame())
		return true;

	M_ASSERT(m_referenceBase->hasTreeView());
	return m_treeAdmin.isUpToDate(m_referenceBase->base(), game(), key);
}


bool
Application::updateTree(tree::Mode mode, rating::Type ratingType, PipedProgress& progress)
{
	if (m_referenceBase == 0 || !haveCurrentGame())
		return true;

	if (m_treeIsFrozen)
		return false;

	M_ASSERT(m_referenceBase->hasTreeView());
	return m_treeAdmin.startUpdate(m_referenceBase->base(), game(), mode, ratingType, progress);
}


Tree const*
Application::finishUpdateTree(tree::Mode mode, rating::Type ratingType, attribute::tree::ID sortAttr)
{
	Database const* base = m_referenceBase ? &m_referenceBase->base() : 0;

	if (m_treeAdmin.finishUpdate(base, game(), mode, ratingType, sortAttr))
	{
		M_ASSERT(m_referenceBase);
		M_ASSERT(m_treeAdmin.tree());

		if (m_referenceBase->hasTreeView())
		{
			M_ASSERT(m_referenceBase->database().id() == m_treeAdmin.tree()->database().id());
			M_ASSERT(m_treeAdmin.tree()->filter().size() == m_referenceBase->database().countGames());

			m_referenceBase->treeView().setGameFilter(m_treeAdmin.tree()->filter());

			if (m_subscriber)
			{
				m_subscriber->updateList(	table::Games,
													m_updateCount++,
													m_referenceBase->name(),
													m_referenceBase->variant(),
													m_referenceBase->treeViewIdentifier());
			}
		}
	}

	return m_treeAdmin.tree().get();
}


void
Application::stopUpdateTree()
{
	M_REQUIRE(hasInstance());
	m_treeAdmin.stopUpdate();
}


void
Application::cancelUpdateTree()
{
	M_REQUIRE(hasInstance());
	m_treeAdmin.cancelUpdate();
}


void
Application::startUpdateTree(Cursor& cursor)
{
	if (m_subscriber && cursor.isReferenceBase() && !m_treeIsFrozen)
		m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
}


void
Application::enumCursors(CursorList& list, variant::Type variant) const
{
	M_REQUIRE(variant::isMainVariant(variant));

	unsigned variantIndex  = variant::toIndex(variant);

	list.clear();

	for (CursorMap::const_iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
	{
		if (!i->second->isScratchbase() && !i->second->isClipbase())
		{
			if (i->second->exists(variantIndex))
				list.push_back((*i->second)[variantIndex]);
		}
	}
}


save::State
Application::saveGame(Cursor& cursor, bool replace)
{
	M_REQUIRE(cursor.isOpen());
	M_REQUIRE(!cursor.isReadonly());
	M_REQUIRE(haveCurrentGame());

	EditGame& g = *m_gameMap.find(m_currentPosition)->second;

	save::State	state;

	if (cursor.isReferenceBase())
	{
		if (g.data.game->isModified())
		{
			cancelUpdateTree();

			for (Iterator i = begin(), e = end(); i != e; ++i)
				Tree::clearCache(i->base());
		}
		else
		{
			stopUpdateTree();
		}
	}

	Database& db = cursor.base();

	if (replace)
	{
		M_ASSERT(&cursor == g.sink.cursor);
		g.data.game->setIndex(g.sink.index);
		// TODO: should be transaction save
		state = db.updateGame(*g.data.game);
	}
	else
	{
		g.sink.cursor = &cursor;
		g.data.game->setIndex(-1);
		// TODO: should be transaction save
		state = db.addGame(*g.data.game);
		g.data.game->setIndex(g.sink.index = db.countGames() - 1);
		g.link.databaseName = cursor.name();
	}

	cursor.updateViews();

	GameInfo& info	= cursor.base().gameInfo(g.sink.index);

	if (save::isOk(state))
	{
		checksum_t crcMainline	= g.sink.crcMainline;
		checksum_t crcMoves		= g.sink.crcMoves;

		TagSet tags;
		db.getGameTags(g.sink.index, tags);

		info.setDirty(false);
		g.data.game->setIsModified(false);
		g.sink.crcMainline = g.data.game->computeChecksumOfMainline();
		g.sink.crcMoves = g.link.crcMoves = tags.computeChecksum(g.data.game->computeChecksum());
		g.sink.crcIndex = g.link.crcIndex = cursor.base().computeChecksum(g.sink.index);
		g.link.index = g.data.game->index();

		if (m_subscriber)
		{
			m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());
			m_subscriber->updateGameInfo(m_currentPosition);

			if (g.sink.crcMoves != crcMoves || g.sink.crcMainline != crcMainline)
				m_subscriber->updateGameData(m_currentPosition, crcMainline != g.sink.crcMainline);

			if (m_current == &cursor)
			{
				for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
				{
					if (cursor.isViewOpen(i))
					{
						if (replace)
						{
							m_subscriber->updateList(	table::Games,
																m_updateCount,
																db.name(),
																db.variant(),
																i,
																g.data.game->index());
							m_subscriber->updateList(table::Players, m_updateCount, db.name(), db.variant(), i);
							m_subscriber->updateList(table::Events, m_updateCount, db.name(), db.variant(), i);
							m_subscriber->updateList(table::Sites, m_updateCount, db.name(), db.variant(), i);
							m_subscriber->updateList(	table::Annotators,
																m_updateCount,
																db.name(),
																db.variant(),
																i);
						}
						else
						{
							m_subscriber->updateList(m_updateCount, db.name(), db.variant(), i);
						}
					}
				}
			}

			++m_updateCount;
		}

		g.data.game->updateSubscriber(Game::UpdatePgn);
	}

	if (m_subscriber && cursor.isReferenceBase() && !m_treeIsFrozen)
		m_subscriber->updateTree(db.name(), db.variant());

	return state;
}


save::State
Application::updateMoves()
{
	M_REQUIRE(haveCurrentGame());
	M_REQUIRE(contains(sourceName()));
	M_REQUIRE(!cursor(sourceName()).isReadonly());

	EditGame& g = *m_gameMap.find(m_currentPosition)->second;

	if (!g.data.game->isModified())
		return save::Ok;

	Cursor& cursor = this->cursor(sourceName());

	if (cursor.isReferenceBase())
	{
		cancelUpdateTree();

		for (Iterator i = begin(), e = end(); i != e; ++i)
			Tree::clearCache(i->base());
	}

	g.data.game->setIndex(g.link.index);

	save::State state = cursor.base().updateMoves(*g.data.game);

	if (m_subscriber)
	{
		mstl::string const&	name		= cursor.name();
		variant::Type			variant	= cursor.variant();

		if (save::isOk(state))
		{
			checksum_t crcMainline	= g.sink.crcMainline;
			checksum_t crcMoves		= g.sink.crcMoves;

			TagSet tags;
			cursor.base().getGameTags(g.link.index, tags);

			g.data.game->setIsModified(false);
			g.sink.crcMoves = g.link.crcMoves = tags.computeChecksum(g.data.game->computeChecksum());
			g.sink.crcMainline = g.data.game->computeChecksumOfMainline();

			m_subscriber->updateDatabaseInfo(name, variant);
			m_subscriber->updateGameInfo(m_currentPosition); // because of changed checksums

			if (g.sink.crcMoves != crcMoves || g.sink.crcMainline != crcMainline)
				m_subscriber->updateGameData(m_currentPosition, crcMainline != g.sink.crcMainline);

			if (m_current == &cursor)
			{
				for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
				{
					if (cursor.isViewOpen(i))
						m_subscriber->updateList(table::Games, m_updateCount, name, variant, i, g.link.index);
				}

				++m_updateCount;
			}
		}

		if (cursor.isReferenceBase() && !m_treeIsFrozen)
			m_subscriber->updateTree(name, cursor.variant());
	}

	return state;
}


save::State
Application::updateCharacteristics(Cursor& cursor, unsigned index, TagSet const& tags)
{
	M_REQUIRE(cursor.isOpen());
	M_REQUIRE(!cursor.isReadonly());
	M_REQUIRE(index < cursor.count(table::Games));

	if (cursor.isReferenceBase())
		cancelUpdateTree();

	unsigned		position	= 0; // satisifes the compiler
	save::State	state		= cursor.base().updateCharacteristics(index, tags);
	EditGame*	game		= findGame(&cursor, index, &position);

	M_ASSERT(game == 0 || game->sink.index == index);

	if (game)
	{
		TagSet tags;
		cursor.base().setupTags(index, tags);
		game->data.game->setTags(tags);
		game->sink.crcIndex = game->link.crcIndex = cursor.base().computeChecksum(index);
	}

	cursor.updateViews();

	if (m_subscriber)
	{
		mstl::string const&	name		= cursor.name();
		variant::Type			variant	= cursor.variant();

		if (save::isOk(state))
		{
			m_subscriber->updateDatabaseInfo(name, variant);

			if (game)
				m_subscriber->updateGameInfo(position);
			else
				m_subscriber->updateGameInfo(cursor.name(), variant, index);

			if (m_current == &cursor)
			{
				for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
				{
					if (cursor.isViewOpen(i))
					{
						m_subscriber->updateList(table::Games, m_updateCount, name, variant, i, index);
						m_subscriber->updateList(table::Players, m_updateCount, name, variant, i);
						m_subscriber->updateList(table::Events, m_updateCount, name, variant, i);
						m_subscriber->updateList(table::Sites, m_updateCount, name, variant, i);
						m_subscriber->updateList(table::Annotators, m_updateCount, name, variant, i);
					}
				}

				m_updateCount++;
			}

			if (game)
				game->data.game->updateSubscriber(Game::UpdatePgn);
		}

		if (cursor.isReferenceBase() && !m_treeIsFrozen)
			m_subscriber->updateTree(name, variant);
	}

	return state;
}


unsigned
Application::findUnusedPosition() const
{
	mstl::bitset posSet(m_gameMap.size() + 1, true);

	for (GameMap::const_iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->first < m_gameMap.size())
			posSet.reset(i->first);
	}

	if (!posSet.none())
		return posSet.find_first();

	return m_gameMap.size() + 1;
}


load::State
Application::importGame(Producer& producer, unsigned position, bool trialMode)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(contains(scratchbaseName()));

	if (position == InvalidPosition)
		position = m_currentPosition;

	GameP game		= m_gameMap.find(position)->second;
	GameP myGame	= game;

	unsigned rememberPosition = position;

	if (!game->sink.cursor->isScratchbase())
	{
		position = findUnusedPosition();
		myGame = insertScratchGame(position, producer.variant());

		mstl::swap(myGame->data.game, game->data.game);
		mstl::swap(myGame->data.backup, game->data.backup);
	}

	Cursor* scratch = scratchbase(variant::toMainVariant(producer.variant()));
	unsigned count = scratch->base().importGame(producer, myGame->sink.index);
	load::State state = count ? load::Ok : load::None;

	if (count > 0 && !trialMode)
	{
		state = loadGame(position);
		myGame->data.game->setIsModified(true);
	}

	if (game->sink.cursor != scratch)
	{
		mstl::swap(myGame->data.game, game->data.game);
		mstl::swap(myGame->data.backup, game->data.backup);

		scratch->database().deleteGame(myGame->sink.index, true);
		releaseGame(position);
		// TODO: compress scratch base
	}

	game->data.game->setIsIrreversible(true);

	if (position != ReservedPosition && count > 0 && !trialMode && m_subscriber)
	{
		refreshGame(position);
		m_subscriber->updateGameInfo(rememberPosition);
	}

	return state;
}


void
Application::bindGameToDatabase(unsigned position, mstl::string const& name, unsigned index)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(isScratchGame(position));

	EditGame& game = *m_gameMap.find(position)->second;

	game.link.databaseName = name;
	game.link.index = index;

	if (m_subscriber)
		m_subscriber->updateGameInfo(position);
}


void
Application::bindGameToView(unsigned position, int viewId, Update updateMode)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(viewId == -1 || getGameCursor(position).isViewOpen(viewId));

	m_gameMap.find(position)->second->data.viewId = viewId;;

	if (updateMode == UpdateGameInfo && m_subscriber)
		m_subscriber->updateGameInfo(position);
}


void
Application::viewClosed(Cursor const& cursor, unsigned viewId)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->sink.cursor == &cursor && int(viewId) == i->second->data.viewId)
		{
			i->second->data.viewId = -1;

			if (m_subscriber)
				m_subscriber->updateGameInfo(i->first);
		}
	}
}


void
Application::setupGame(	unsigned linebreakThreshold,
								unsigned linebreakMaxLineLengthMain,
								unsigned linebreakMaxLineLengthVar,
								unsigned linebreakMinCommentLength,
								unsigned displayStyle,
								unsigned moveInfoTypes,
								move::Notation moveStyle)
{
	M_REQUIRE(displayStyle & (display::CompactStyle | display::ColumnStyle));
	M_REQUIRE((displayStyle & (display::CompactStyle | display::ColumnStyle))
					!= (display::CompactStyle | display::ColumnStyle));

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		i->second->data.game->setup(	linebreakThreshold,
												linebreakMaxLineLengthMain,
												linebreakMaxLineLengthVar,
												linebreakMinCommentLength,
												displayStyle,
												moveInfoTypes,
												moveStyle);

		i->second->data.refresh = 1;
	}
}


void
Application::setupGameUndo(unsigned undoLevel, unsigned combinePredecessingMoves)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
		i->second->data.game->setUndoLevel(undoLevel, combinePredecessingMoves);

	::undoLevel = undoLevel;
	::undoCombinePredecessingMoves = combinePredecessingMoves;
}


MultiBase&
Application::multiBase(mstl::string const& name)
{
	M_REQUIRE(contains(name));

	CursorP multiCursor = m_cursorMap.find(name)->second;

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (multiCursor->exists(v) && (*multiCursor)[v]->isReferenceBase())
			stopUpdateTree();
	}

	return multiCursor->multiBase();
}


MultiCursor&
Application::multiCursor(mstl::string const& name)
{
	M_REQUIRE(contains(name));
	return *m_cursorMap.find(name)->second;
}


Cursor const&
Application::cursor(unsigned databaseId) const
{
	for (Iterator i = begin(), e = end(); i != e; ++i)
	{
		if (i->database().id() == databaseId)
			return *i;
	}

	return cursor(); // fallback; should never be reached
}


void
Application::finalize()
{
	m_treeAdmin.thread().stop();

	for (Iterator i = begin(), e = end(); i != e; ++i)
		i->close();

	m_subscriber.release();
	m_gameMap.clear();
	m_cursorMap.clear();
}


bool
Application::engineExists(unsigned id) const
{
	M_REQUIRE(id < maxEngineId());
	return m_engineList[id];
}


unsigned
Application::addEngine(Engine* engine)
{
	M_REQUIRE(engine);

	EngineList::iterator i = mstl::find(m_engineList.begin(),
													m_engineList.end(),
													static_cast<Engine const*>(0));

	if (i == m_engineList.end())
		i = m_engineList.insert(i, 0);

	++m_numEngines;
	*i = engine;

	if (m_engineLog)
		engine->setLog(m_engineLog);

	return mstl::distance(m_engineList.begin(), i);
}


void
Application::removeEngine(unsigned id)
{
	M_REQUIRE(id < maxEngineId());

	if (m_engineList[id])
	{
		m_engineList[id]->deactivate();
		delete m_engineList[id];
		m_engineList[id] = 0;
		M_ASSERT(m_numEngines > 0);
		--m_numEngines;
	}
}


mstl::ostream*
Application::setEngineLog(mstl::ostream* strm)
{
	mstl::ostream* old = m_engineLog;

	m_engineLog = strm;

	for (unsigned i = 0; i < m_engineList.size(); ++i)
	{
		if (m_engineList[i])
			m_engineList[i]->setLog(strm);
	}

	return old;
}


bool
Application::startAnalysis(unsigned engineId)
{
	M_REQUIRE(engineExists(engineId));
	return engine(engineId)->startAnalysis(&game());
}


bool
Application::stopAnalysis(unsigned engineId)
{
	M_REQUIRE(engineExists(engineId));
	return engine(engineId)->stopAnalysis();
}


void
Application::stopAnalysis(Game const* game)
{
	for (unsigned i = 0; i < m_engineList.size(); ++i)
	{
		if (m_engineList[i] && m_engineList[i]->currentGame() == game)
			m_engineList[i]->removeGame();
	}
}


void
Application::save(mstl::string const& name, util::Progress& progress)
{
	M_REQUIRE(contains(name));
//	M_REQUIRE(!cursor(name).isReadonly());
//	M_REQUIRE(start <= cursor(name).countGames());

	MultiCursor& multiCursor = *m_cursorMap.find(name)->second;

	WriteGuard guard(*this, multiCursor.cursor());

	for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
	{
		if (Cursor* cursor = multiCursor[v])
		{
			Database& dst(cursor->database());	// is calling stopUpdateTree()

			dst.save(progress);
			cursor->updateViews();

			if (m_subscriber && m_referenceBase && !m_treeIsFrozen)
				m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());

			if (m_subscriber)
			{
				m_subscriber->updateDatabaseInfo(dst.name(), dst.variant());

				if (m_current == cursor)
				{
					for (unsigned i = 0; i < cursor->maxViewNumber(); ++i)
					{
						if (cursor->isViewOpen(i))
							m_subscriber->updateList(m_updateCount, dst.name(), dst.variant(), i);
					}
				}

				++m_updateCount;
			}
		}
	}
}


void
Application::changeVariant(mstl::string const& name, variant::Type variant)
{
	M_REQUIRE(contains(name));

	MultiCursor& multiCursor = *m_cursorMap.find(name)->second;

	if (multiCursor.cursor().variant() != variant)
	{
		Cursor* cursor = &multiCursor.cursor();
		bool isCurrent = cursor == m_current;

		cursor->closeAllViews();

		if (m_referenceBase == cursor)
			setReferenceBase(0, false);

		moveGamesToScratchbase(*cursor, true);
		multiCursor.changeVariant(variant);

		cursor = &multiCursor.cursor();
		cursor->updateViews();

		if (m_subscriber)
		{
			m_subscriber->updateDatabaseInfo(name, variant);

			if (isCurrent)
			{
				m_current = cursor;

				for (unsigned i = 0; i < cursor->maxViewNumber(); ++i)
				{
					if (cursor->isViewOpen(i))
						m_subscriber->updateList(m_updateCount, name, variant, i);
				}
			}

			++m_updateCount;
		}
	}
}


unsigned
Application::stripMoveInformation(View& view, unsigned types, Progress& progress, Update updateMode)
{
	if (types == 0)
		return 0;

	Cursor const& cursor = view.cursor();

	if (cursor.isReferenceBase())
		stopUpdateTree();

	unsigned numGames = view.stripMoveInformation(types, progress);

	if (numGames > 0 && updateMode == UpdateGameInfo)
		updateGameInfo(cursor, view.database());

	if (m_subscriber)
	{
		m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());
		m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());

		if (cursor.isReferenceBase() && !m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}

	return numGames;
}


unsigned
Application::stripTags(View& view, TagMap const& tags, util::Progress& progress, Update updateMode)
{
	if (tags.size() == 0)
		return 0;

	Cursor const& cursor = view.cursor();

	if (cursor.isReferenceBase())
		stopUpdateTree();

	unsigned numGames = view.stripTags(tags, progress);

	if (numGames > 0 && updateMode == UpdateGameInfo)
		updateGameInfo(cursor, view.database());

	if (m_subscriber)
	{
		m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());
		m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());

		if (cursor.isReferenceBase() && !m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}

	return numGames;
}


void
Application::updateGameInfo(Cursor const& cursor, Database& database)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		EditGame& game = *i->second;

		if (game.sink.cursor == &cursor)
		{
			TagSet	tags;
			Game		newGame;

			if (database.loadGame(game.sink.index, newGame) == load::Ok)
			{
				database.getGameTags(game.sink.index, tags);
				i->second->sink.crcMoves = tags.computeChecksum(newGame.computeChecksum());
				i->second->link.crcMoves = i->second->sink.crcMoves;

				if (m_subscriber)
					m_subscriber->updateGameInfo(i->first);
			}
		}
	}
}


int
Application::getViewId(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));
	return m_gameMap.find(position)->second->data.viewId;
}


int
Application::getNextGameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	EditGame const& game = *m_gameMap.find(position)->second;

	if (game.data.viewId == -1)
		return -1;

	return game.sink.cursor->view(game.data.viewId).nextIndex(table::Games, game.sink.index);
}


int
Application::getPrevGameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	EditGame const& game = *m_gameMap.find(position)->second;

	if (game.data.viewId == -1)
		return -1;

	return game.sink.cursor->view(game.data.viewId).prevIndex(table::Games, game.sink.index);
}


int
Application::getFirstGameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	EditGame const& game = *m_gameMap.find(position)->second;

	if (game.data.viewId == -1)
		return -1;

	return game.sink.cursor->view(game.data.viewId).firstIndex(table::Games);
}


int
Application::getLastGameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	EditGame const& game = *m_gameMap.find(position)->second;

	if (game.data.viewId == -1)
		return -1;

	return game.sink.cursor->view(game.data.viewId).lastIndex(table::Games);
}


int
Application::getRandomGameIndex(unsigned position) const
{
	EditGame const& game = *m_gameMap.find(position)->second;

	if (game.data.viewId == -1)
		return -1;

	return game.sink.cursor->view(game.data.viewId).randomGameIndex();
}


void
Application::exportGameToClipbase(unsigned position, copy::Source source)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(source == copy::OriginalSource || game(position).isModified());

	if (position == InvalidPosition)
		position = currentPosition();

	GameP					g				= m_gameMap.find(position)->second;
	Cursor&				destination	= *clipbase(variant::toMainVariant(g->data.game->variant()));
	Database&			database		= destination.base();
	save::State			state			= save::Ok;
	util::Progress		progress;

	if (m_referenceBase == &destination)
		stopUpdateTree();

	if (isScratchGame(position))
	{
		g->data.game->setIndex(m_indexMap[position]);
	}
	else if (source == copy::ModifiedVersion)
	{
		g = createIntermediateGame(g);
		position = ReservedPosition;
	}
	else
	{
		g->data.game->setIndex(g->sink.index);
	}

	try
	{
		if (isScratchGame(position))
			state = g->sink.cursor->base().updateGame(*g->data.game);

		if (state == save::Ok)
			state = g->sink.cursor->database().exportGame(g->data.game->index(), database);
	}
	catch (...)
	{
		releaseGame(ReservedPosition);
		throw;
	}

	M_ASSERT(state == save::Ok);
	database.save(progress);

	if (position == ReservedPosition)
		releaseGame(ReservedPosition);

	destination.updateViews();

	if (m_subscriber)
	{
		if (m_current == &destination)
			m_subscriber->updateList(m_updateCount++, destination.name(), destination.variant());

		m_subscriber->updateDatabaseInfo(destination.name(), destination.variant());

		if (!m_treeIsFrozen)
			m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
	}
}


save::State
Application::exportGame(unsigned position, mstl::ostream& strm, unsigned flags, copy::Source source)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(source == copy::OriginalSource || game(position).isModified());

	if (position == InvalidPosition)
		position = currentPosition();

	GameP			g		= m_gameMap.find(position)->second;
	save::State	state	= save::Ok;

	if (isScratchGame(position))
	{
		g->data.game->setIndex(m_indexMap[position]);
	}
	else if (source == copy::ModifiedVersion)
	{
		g = createIntermediateGame(g);
		position = ReservedPosition;
	}
	else
	{
		g->data.game->setIndex(g->sink.index);
	}

	try
	{
		if (isScratchGame(position))
			state = g->sink.cursor->base().updateGame(*g->data.game);

		if (state == save::Ok)
		{
			mstl::string encoding;

			if (flags & PgnWriter::Flag_Use_UTF8)
				encoding = sys::utf8::Codec::utf8();
			else
				encoding = sys::utf8::Codec::latin1();

			PgnWriter writer(format::Scidb, strm, encoding, flags);
			writer.setupVariant(g->sink.cursor->variant());
			state = g->sink.cursor->database().exportGame(g->data.game->index(), writer);
		}
	}
	catch (...)
	{
		releaseGame(ReservedPosition);
		throw;
	}

	if (position == ReservedPosition)
		releaseGame(ReservedPosition);

	return state;
}


void
Application::pasteGame(unsigned from, unsigned to)
{
	M_REQUIRE(containsGameAt(from));
	M_REQUIRE(containsGameAt(to));

	Game const&	src = game(from);
	Game&			dst = game(to);

	Game::SubscriberP subscriber = dst.releaseSubscriber();

	dst = src;
	dst.setSubscriber(subscriber);

	if (to != ReservedPosition)
	{
		if (m_subscriber)
			m_subscriber->updateGameInfo(to);

		refreshGame(to);
	}
}


void
Application::pasteLastClipbaseGame(unsigned position)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(position != ReservedPosition);
	M_REQUIRE(!cursor(clipbaseName(), variant::toMainVariant(game(position).variant())).isEmpty());

	variant::Type	variant	= variant::toMainVariant(game(position).variant());
	Cursor&			source	= *clipbase(variant);
	unsigned			index		= source.count(table::Games) - 1;
	unsigned			current	= m_currentPosition;
	load::State		state		__attribute__((unused));

	state = loadGame(ReservedPosition, source, index);
	M_ASSERT(state == load::Ok);
	swapGames(ReservedPosition, position);
	game(position).setSubscriber(game(ReservedPosition).releaseSubscriber());
	releaseGame(ReservedPosition);
	m_currentPosition = current; // swapGames() is modifying m_currentPosition

	if (m_subscriber)
		m_subscriber->updateGameInfo(position);

	refreshGame(position);
}


bool
Application::mergeGame(	unsigned primary,
								unsigned secondary,
								position::ID startPosition,
								move::Order moveOrder,
								unsigned variationDepth)
{
	M_REQUIRE(containsGameAt(primary));
	M_REQUIRE(containsGameAt(secondary));
	M_REQUIRE(primary != secondary);

	if (!game(primary).merge(game(secondary), startPosition, moveOrder, variationDepth))
		return false;

	if (primary != ReservedPosition)
	{
		if (m_subscriber)
			m_subscriber->updateGameInfo(primary);

		if (m_currentPosition != primary)
			refreshGame(primary);
	}

	return true;
}


bool
Application::mergeGame(	unsigned primary,
								unsigned secondary,
								unsigned destination,
								position::ID startPosition,
								move::Order moveOrder,
								unsigned variationDepth)
{
	M_REQUIRE(containsGameAt(primary));
	M_REQUIRE(containsGameAt(secondary));
	M_REQUIRE(containsGameAt(destination));
	M_REQUIRE(primary != secondary);

	if (!game(destination).merge(	game(primary),
											game(secondary),
											startPosition,
											moveOrder,
											variationDepth))
	{
		return false;
	}

	if (destination != ReservedPosition)
	{
		if (m_subscriber)
			m_subscriber->updateGameInfo(destination);

		if (m_currentPosition != destination)
			refreshGame(destination);
	}

	return true;
}


bool
Application::mergeLastClipbaseGame(	unsigned position,
												position::ID startPosition,
												move::Order moveOrder,
												unsigned variationDepth)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(position != ReservedPosition);
	M_REQUIRE(!cursor(clipbaseName(), variant::toMainVariant(game(position).variant())).isEmpty());

	variant::Type	variant	= variant::toMainVariant(game(position).variant());
	Cursor&			source	= *clipbase(variant);
	unsigned			index		= source.count(table::Games) - 1;
	load::State		state		__attribute__((unused));

	state = loadGame(ReservedPosition, source, index);
	M_ASSERT(state == load::Ok);

	bool rc = mergeGame(position, ReservedPosition, startPosition, moveOrder, variationDepth);

	if (m_currentPosition != position)
		refreshGame(position);

	releaseGame(ReservedPosition);
	return rc;
}


bool
Application::mergeLastClipbaseGame(	unsigned position,
												unsigned destination,
												position::ID startPosition,
												move::Order moveOrder,
												unsigned variationDepth)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(containsGameAt(destination));
	M_REQUIRE(position != ReservedPosition);
	M_REQUIRE(!cursor(clipbaseName(), variant::toMainVariant(game(position).variant())).isEmpty());

	variant::Type	variant	= variant::toMainVariant(game(position).variant());
	Cursor&			source	= *clipbase(variant);
	unsigned			index		= source.count(table::Games) - 1;
	load::State		state		__attribute__((unused));

	state = loadGame(ReservedPosition, source, index);
	M_ASSERT(state == load::Ok);

	bool rc = mergeGame(	position,
								ReservedPosition,
								destination,
								startPosition,
								moveOrder,
								variationDepth);

	if (destination != ReservedPosition)
	{
		if (m_subscriber)
			m_subscriber->updateGameInfo(destination);

		if (m_currentPosition != destination)
			refreshGame(destination);
	}

	releaseGame(ReservedPosition);
	return rc;
}


void
Application::printGame(	unsigned position,
								TeXt::Environment& environment,
								format::Type format,
								unsigned flags,
								unsigned options,
								NagMap const& nagMap,
								Languages const& languages,
								unsigned significantLanguages) const
{
	M_REQUIRE(containsGameAt(position));

	EditGame const& game = *m_gameMap.find(position)->second;

	// save changes in new scratch game before printing

	switch (int(format))
	{
		case format::LaTeX:
			{
				LaTeXWriter	writer(	game.sink.cursor->database().format(),
											flags,
											options,
											nagMap,
											languages,
											significantLanguages,
											environment);
				game.sink.cursor->database().exportGame(game.sink.index, writer);
			}
			break;

		default:
			M_RAISE("unsupported format");
	}
}


bool
Application::verifyGame(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_currentPosition;

	if (!contains(sourceName(position)))
		return false;

	EditGame const& g = *m_gameMap.find(position)->second;

	if (!g.sink.cursor->isScratchbase())
		return true;

	Cursor& source = cursor(g.link.databaseName);

	if (g.link.index >= source.database().countGames())
		return false;

	load::State state __attribute__((unused));
	state = loadGame(ReservedPosition, source, g.link.index);
	M_ASSERT(state == load::Ok);

	EditGame const& sg = *m_gameMap.find(ReservedPosition)->second;
	bool result = g.link.crcIndex == sg.sink.crcIndex && g.link.crcMoves == sg.sink.crcMoves;
	releaseGame(ReservedPosition);

	return result;
}

// vi:set ts=3 sw=3:
