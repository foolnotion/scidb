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
#include "db_producer.h"
#include "db_exception.h"

#include "u_piped_progress.h"

#include "sys_utf8_codec.h"
#include "sys_thread.h"

#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_algorithm.h"
#include "m_function.h"
#include "m_bitset.h"
#include "m_auto_ptr.h"
#include "m_ref_counted_ptr.h"
#include "m_limits.h"
#include "m_string.h"
#include "m_assert.h"
#include "m_stdio.h"

#include <string.h>

using namespace db;
using namespace app;
using namespace util;


Application* Application::m_instance = 0;

static unsigned undoLevel = 20;
static unsigned undoCombinePredecessingMoves = 9999;


namespace app {

bool operator==(Cursor const* cursor, mstl::string const& name)
{
	return cursor->database().name() == name;
}

} // namespace app


namespace {

struct Runnable
{
	typedef mstl::ref_counted_ptr<Tree> TreeP;
	typedef tree::Mode Mode;

	Runnable(TreeP tree,
				Game& game,
				Database& database,
				Mode mode,
				rating::Type ratingType,
				PipedProgress& progress)
		:m_database(database)
		,m_progress(progress)
		,m_mode(mode)
		,m_ratingType(ratingType)
		,m_currentLine(m_lineBuf)
		,m_hpsig(game.currentLine(m_currentLine))
		,m_idn(game.idn())
		,m_startPosition(game.startBoard())
		,m_currentPosition(game.currentBoard())
		,m_tree(tree)
	{
	}

	void operator() ()
	{
		m_database.openAsyncReader();

		try
		{
			m_tree.reset(Tree::makeTree(	m_tree,
													m_idn,
													m_startPosition,
													m_currentPosition,
													m_currentLine,
													m_hpsig,
													m_database,
													m_mode,
													m_ratingType,
													m_progress));
		}
		catch (...)
		{
			m_database.closeAsyncReader();
			throw;
		}

		m_database.closeAsyncReader();
	}

	Database&		m_database;
	PipedProgress&	m_progress;
	Mode				m_mode;
	rating::Type	m_ratingType;
	Line				m_currentLine;
	uint16_t			m_hpsig;
	unsigned			m_idn;
	Board				m_startPosition;
	Board				m_currentPosition;
	TreeP				m_tree;

	uint16_t m_lineBuf[opening::Max_Line_Length];
};

static Runnable* runnable = 0;

} // namespace


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


Application::EditGame::EditGame()
	:cursor(0)
	,index(0)
	,game(0)
	,backup(0)
	,crcIndex(0)
	,crcMoves(0)
	,refresh(0)
	,sourceIndex(0)
{
}


Application::EditGame::~EditGame()
{
	delete game;
	delete backup;
}


Application::Application()
	:m_current(0)
	,m_clipbase(0)
	,m_referenceBase(0)
	,m_switchReference(true)
	,m_isUserSet(false)
	,m_position(InvalidPosition)
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
	game->game = new Game;
	return game;
}


Application::GameP
Application::insertScratchGame(unsigned position, db::variant::Type variant)
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
		game.game->finishLoad(variant);
		m_indexMap[position] = index = base.countGames();

		if (!save::isOk(base.newGame(*game.game, info)))
			M_RAISE("unexpected error: couldn't add new game to Scratchbase");
	}
	else
	{
		index = i->second;
	}

	TagSet tags;
	base.getGameTags(index, tags);

	game.cursor = scratch;
	game.index = index;
	game.game->setUndoLevel(::undoLevel, ::undoCombinePredecessingMoves);
	game.crcIndex = base.computeChecksum(index);
	game.crcMoves = tags.computeChecksum(game.game->computeChecksum());
	game.sourceBase = base.name();
	game.sourceIndex = index;
	game.refresh = 0;
	game.encoding = sys::utf8::Codec::utf8();

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
Application::contains(mstl::string const& name, db::variant::Type variant) const
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
Application::contains(char const* name, db::variant::Type variant) const
{
	if (name == 0)
		return currentVariant() == variant;

	return contains(mstl::string(name), variant);
}


bool
Application::containsGameAt(unsigned position) const
{
	if (position == InvalidPosition)
		position = m_position;

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
		position = m_position;

	EditGame const& g = *m_gameMap.find(position)->second;
	return g.cursor == scratchbase(variant::toMainVariant(g.game->variant()));
}


bool
Application::hasTrialMode(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(m_position)->second->backup != 0;
}


unsigned
Application::countModifiedGames() const
{
	unsigned n = 0;

	for (GameMap::const_iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->game->isModified())
			++n;
	}

	return n;
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

		if (game.cursor == cursor && game.index == index)
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
		position = m_position;

	return m_gameMap.find(position)->second->encoding;
}


Cursor*
Application::open(mstl::string const& name,
						mstl::string const& encoding,
						bool readOnly,
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
														readOnly ? permission::ReadOnly : permission::ReadWrite,
														progress);
	MultiCursor* cursor = new MultiCursor(*this, multiBase);

	m_cursorMap[name] = cursor;
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
							db::type::ID type,
							db::Producer& producer,
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
		if (i->second->cursor == &cursor)
		{
			unsigned		position	= i->first;
			EditGame&	game		= *i->second;

			if (game.cursor->isScratchbase())
				m_indexMap.erase(position);

			stopAnalysis(game.game);
			i = m_gameMap.erase(i);

			if (m_position == position)
				m_position = InvalidPosition;
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
		position = m_position;

	EditGame const& g = *m_gameMap.find(position)->second;
	return g.cursor->base().gameInfo(g.index);
}


unsigned
Application::gameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second->index;
}


unsigned
Application::sourceIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second->sourceIndex;
}


Database const&
Application::database(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second->cursor->database();
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
		position = m_position;

	return m_gameMap.find(position)->second->sourceBase;
}


variant::Type
Application::variant(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second->cursor->variant();
}


void
Application::setSource(unsigned position, mstl::string const& name, unsigned index)
{
	M_REQUIRE(containsGameAt(position));

	EditGame& game = *m_gameMap.find(position)->second;
	game.sourceBase = name;
	game.sourceIndex = index;
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
		position = m_position;

	return m_gameMap.find(position)->second->crcIndex;
}


::util::crc::checksum_t
Application::checksumMoves(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second->crcMoves;
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
	M_REQUIRE(cursor == 0 || cursor->format() != format::ChessBase);
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
		&& cursor.format() != format::ChessBase
		&& cursor.variant() == variant::Normal)
	{
		setReferenceBase(m_current, false);
	}

	if (m_subscriber)
		m_subscriber->updateList(m_updateCount++, cursor.name(), cursor.variant());
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
						db::attribute::event::ID attr,
						db::order::ID order)
{
	cursor.view(view).sort(attr, order);
	cursor.view(view).updateSelector(table::Events);

	if (m_subscriber)
		m_subscriber->updateList(table::Events, m_updateCount++, cursor.name(), cursor.variant(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						db::attribute::site::ID attr,
						db::order::ID order)
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
			game.game->resetForNextLoad();

		TagSet tags;
		base.getGameTags(index, tags);

		// TODO: compact scratch base (we need fast compact)

		game.game->setUndoLevel(::undoLevel, ::undoCombinePredecessingMoves);
		game.cursor = &cursor;
		game.index = index;

		state = base.loadGame(index, *game.game, game.encoding, fen);

		game.crcIndex = base.computeChecksum(index);
		game.crcMoves = tags.computeChecksum(game.game->computeChecksum());
		game.sourceBase = base.name();
		game.sourceIndex = index;
		game.refresh = 0;

		if (!cursor.isScratchbase())
		{
			game.game->updateSubscriber(Game::UpdateAll);

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

	EditGame const& game = *m_gameMap.find(position)->second;
	return loadGame(position, *game.cursor, game.index);
}


unsigned
Application::indexAt(unsigned position) const
{
	M_REQUIRE(position != InvalidPosition);
	M_REQUIRE(containsGameAt(position));

	return m_gameMap.find(position)->second->index;
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
		position = m_position;

	if (!containsGameAt(position))
		return;

	stopAnalysis(m_gameMap.find(position)->second->game);

	m_gameMap.erase(position);
	m_indexMap.erase(position);

	if (m_position == position)
		m_position = m_fallbackPosition;
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
Application::changeVariant(unsigned position, db::variant::Type variant)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(database(position).name() == scratchbaseName());
	M_REQUIRE(variant::isMainVariant(variant));

	EditGame& 		game					= *m_gameMap[position];
	variant::Type	originalVariant	= game.cursor->variant();

	if (originalVariant != variant)
	{
		Cursor*				scratch		= scratchbase(variant::toMainVariant(variant));
		Database&			base			= scratch->base();
		GameInfo const&	info			= game.cursor->base().gameInfo(game.index);
		unsigned				index			= base.countGames();

		info.reallocate(base.namebases());
		base.namebases().update();
		game.game->finishLoad(variant);

		if (!save::isOk(base.newGame(*game.game, info)))
		{
			game.game->finishLoad(originalVariant);
			M_RAISE("unexpected error: couldn't add new game to Scratchbase");
		}

		TagSet tags;
		base.getGameTags(index, tags);

		m_indexMap[position] = index;

		game.cursor = scratch;
		game.index = index;
		game.crcIndex = base.computeChecksum(index);
		game.crcMoves = tags.computeChecksum(game.game->computeChecksum());
		game.sourceBase = base.name();
		game.sourceIndex = index;
		game.refresh = 0;

		game.cursor->base().deleteGame(game.index, true);
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
		GameP copy = m_gameMap[position1];
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

	if (m_position == position1)
		m_position = position2;
	else if (m_position == position2)
		m_position = position1;
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

	EditGame& game = *m_gameMap[m_position];

	game.game->setup(startPosition);
	game.game->updateSubscriber(Game::UpdateBoard | Game::UpdatePgn);

	if (m_subscriber && m_referenceBase && !m_treeIsFrozen)
		m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
}


void
Application::clearGame(Board const* startPosition)
{
	M_REQUIRE(haveCurrentGame());

	EditGame& game = *m_gameMap[m_position];

	game.game->clear(startPosition);
	game.game->updateSubscriber(Game::UpdateBoard);

	if (m_subscriber && m_referenceBase && !m_treeIsFrozen)
		m_subscriber->updateTree(m_referenceBase->name(), m_referenceBase->variant());
}


db::save::State
Application::writeGame(	unsigned position,
								mstl::string const& name,
								mstl::string const& encoding,
								mstl::string const& comment,
								unsigned flags) const
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(isScratchGame(position));

	if (position == InvalidPosition)
		position = currentPosition();

	EditGame const& game = *m_gameMap.find(position)->second;

	game.game->setIndex(m_indexMap[position]);
	Cursor* scratch = scratchbase(variant::toMainVariant(game.game->variant()));
	save::State state = scratch->base().updateGame(*game.game);
	if (!save::isOk(state))
		return state;

	mstl::ofstream strm(name, mstl::ios_base::out | mstl::ios_base::trunc);

	if (!strm)
		IO_RAISE(Unspecified, Write_Failed, "cannot open file '%s'", name.c_str());

	PgnWriter writer(format::Scidb, strm, encoding, flags);
	writer.setupVariant(scratch->variant());
	writer.writeCommnentLine(comment);

	return scratch->database().exportGame(game.game->index(), writer);
}


void
Application::switchGame(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = currentPosition();

	stopUpdateTree();

	EditGame& game = *m_gameMap[position];

	m_position = position;

	if (game.refresh)
	{
		if (game.refresh == 2)
			game.game->refreshSubscriber(Game::UpdateAll);
		else
			game.game->updateSubscriber(Game::UpdateBoard | Game::UpdatePgn | Game::UpdateOpening);

		game.refresh = 0;
	}
	else
	{
		game.game->updateSubscriber(Game::UpdateBoard);
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

	EditGame& game = *m_gameMap[m_position];

	game.backup = game.game;
	game.game = new Game(*game.backup);
	game.game->moveTo(game.backup->currentKey());
}


void
Application::endTrialMode()
{
	M_REQUIRE(hasTrialMode());

	EditGame& game = *m_gameMap[m_position];

	delete game.game;
	game.game = game.backup;
	game.game->moveTo(game.backup->currentKey());
	game.backup = 0;
}


void
Application::refreshGames()
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->cursor->isScratchbase())
			i->second->refresh = 2;
	}
}


void
Application::refreshGame(unsigned position, bool immediate)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	EditGame& game = *m_gameMap.find(position)->second;

	if (position == m_position || immediate)
		game.game->refreshSubscriber(Game::UpdateAll);
	else
		game.refresh = 2;
}


Game&
Application::game(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return *m_gameMap.find(position)->second->game;
}


Game const&
Application::game(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return *m_gameMap.find(position)->second->game;
}


void
Application::moveGamesToScratchbase(Cursor& cursor, bool overtake)
{
	if (cursor.isScratchbase())
		return;

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second->cursor == &cursor)
		{
			EditGame&	game		= *i->second;
			Cursor*		scratch	= scratchbase(variant::toMainVariant(game.game->variant()));
			Database&	base		= scratch->base();

			unsigned index = base.countGames();

			m_indexMap[i->first] = index;

			GameInfo info(game.cursor->base().gameInfo(game.index));
			info.reallocate(base.namebases());
			base.namebases().update();

			if (base.newGame(*game.game, info) != save::Ok)
				M_RAISE("unexpected error: couldn't add new game to Scratchbase");

			game.cursor = scratch;
			game.index = index;
			game.sourceBase = overtake ? scratch->name() : cursor.name();
			game.sourceIndex = index;
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

	EditGame const& g	= *m_gameMap.find(m_position)->second;
	Database& base		= m_referenceBase->base();

	Runnable::TreeP tree(Tree::lookup(base, g.game->currentBoard(), key.mode(), key.ratingType()));

	return tree ? tree->key() == key : false;
}


bool
Application::updateTree(tree::Mode mode, rating::Type ratingType, PipedProgress& progress)
{
	if (m_referenceBase == 0 || !haveCurrentGame())
		return true;

	if (m_treeIsFrozen)
		return false;

	M_ASSERT(m_referenceBase->hasTreeView());

	sys::thread::stop();

	EditGame const& g	= *m_gameMap.find(m_position)->second;
	Database& base		= m_referenceBase->base();

	if (::runnable)
	{
		::runnable->m_database.closeAsyncReader();

		if (Runnable::TreeP tree = ::runnable->m_tree)
		{
			tree->compressFilter();
			Tree::addToCache(tree.get());
		}

		delete ::runnable;
		::runnable = 0;
	}

	Runnable::TreeP tree(Tree::lookup(base, g.game->currentBoard(), mode, ratingType));

	if (tree)
	{
		if (tree->isComplete())
			return true;

		tree->uncompressFilter();
	}

	base.openAsyncReader();

	::runnable = new Runnable(tree, *g.game, base, mode, ratingType, progress);
	sys::thread::start(mstl::function<void ()>(&Runnable::operator(), ::runnable));

	return false;
}


Tree const*
Application::finishUpdateTree(tree::Mode mode, rating::Type ratingType, attribute::tree::ID sortAttr)
{
	Runnable::TreeP tree;

	sys::thread::stop();

	if (::runnable)
	{
		tree = ::runnable->m_tree;

		::runnable->m_database.closeAsyncReader();

		if (tree)
		{
			Tree::addToCache(tree.get());

			if (	m_referenceBase == 0
				|| m_referenceBase->base().countGames() != tree->filter().size()
				|| !tree->isTreeFor(m_referenceBase->base(), game().currentBoard(), mode, ratingType))
			{
				tree->compressFilter();
				tree.reset(0);	// tree is incomplete or outdated
			}
		}

		delete ::runnable;
		::runnable = 0;
	}

	if (m_referenceBase == 0)
	{
		m_currentTree.reset();
		tree.reset();
	}
	else
	{
		if (!tree)
		{
			tree.reset(Tree::lookup(m_referenceBase->base(), game().currentBoard(), mode, ratingType));

			if (tree)
			{
				if (tree->filter().size() != m_referenceBase->base().countGames())
					tree->setIncomplete();

				if (!tree->isComplete())
					tree.reset(0);
			}
		}

		if (tree)
		{
			tree->uncompressFilter();

			if (tree && sortAttr != attribute::tree::LastColumn)
				tree->sort(sortAttr);

			bool send = m_currentTree == 0;

			if (m_currentTree != tree)
			{
				if (m_currentTree)
				{
					m_currentTree->compressFilter();
					send = true;
				}

				m_currentTree = tree;
			}

			if (m_referenceBase->hasTreeView())
			{
				if (send)
				{
					M_ASSERT(m_referenceBase->database().id() == tree->database().id());
					M_ASSERT(tree->filter().size() == m_referenceBase->database().countGames());

					m_referenceBase->treeView().setGameFilter(tree->filter());

					if (m_subscriber && m_referenceBase->hasTreeView())
					{
						m_subscriber->updateList(	table::Games,
															m_updateCount++,
															m_referenceBase->name(),
															m_referenceBase->variant(),
															m_referenceBase->treeViewIdentifier());
					}
				}
			}
		}
		else
		{
			m_currentTree.reset();
		}
	}

	return tree.get();
}


void
Application::stopUpdateTree()
{
	M_REQUIRE(hasInstance());

	sys::thread::stop();

	if (::runnable)
	{
		Runnable::TreeP tree = ::runnable->m_tree;

		::runnable->m_database.closeAsyncReader();

		if (tree)
		{
			tree->compressFilter();
			Tree::addToCache(tree.get());
		}

		delete ::runnable;
		::runnable = 0;
	}
}


void
Application::cancelUpdateTree()
{
	M_REQUIRE(hasInstance());

	sys::thread::stop();

	if (::runnable)
		::runnable->m_database.closeAsyncReader();

	delete ::runnable;
	::runnable = 0;
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

	EditGame& g = *m_gameMap.find(m_position)->second;

	save::State	state;

	if (cursor.isReferenceBase())
	{
		if (g.game->isModified())
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
		M_ASSERT(&cursor == g.cursor);
		g.game->setIndex(g.index);
		// TODO: should be transaction save
		state = db.updateGame(*g.game);
	}
	else
	{
		g.cursor = &cursor;
		g.game->setIndex(-1);
		// TODO: should be transaction save
		state = db.addGame(*g.game);
		g.game->setIndex(g.index = db.countGames() - 1);
		g.sourceBase = cursor.name();
	}

	cursor.updateViews();

	GameInfo& info	= cursor.base().gameInfo(g.index);

	if (save::isOk(state))
	{
		TagSet tags;
		db.getGameTags(g.index, tags);

		info.setDirty(false);
		g.game->setIsModified(false);
		g.crcMoves = tags.computeChecksum(g.game->computeChecksum());
		g.crcIndex = cursor.base().computeChecksum(g.index);
		g.sourceIndex = g.game->index();

		if (m_subscriber)
		{
			m_subscriber->updateDatabaseInfo(cursor.name(), cursor.variant());
			m_subscriber->updateGameInfo(m_position);

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
																g.game->index());
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

		g.game->updateSubscriber(Game::UpdatePgn);
	}

	if (m_subscriber && cursor.isReferenceBase() && !m_treeIsFrozen)
		m_subscriber->updateTree(db.name(), db.variant());

	return state;
}


db::save::State
Application::updateMoves()
{
	M_REQUIRE(haveCurrentGame());
	M_REQUIRE(contains(sourceName()));
	M_REQUIRE(!cursor(sourceName()).isReadonly());

	EditGame& g = *m_gameMap.find(m_position)->second;

	if (!g.game->isModified())
		return save::Ok;

	Cursor& cursor = this->cursor(sourceName());

	if (cursor.isReferenceBase())
	{
		cancelUpdateTree();

		for (Iterator i = begin(), e = end(); i != e; ++i)
			Tree::clearCache(i->base());
	}

	g.game->setIndex(g.sourceIndex);

	save::State state = cursor.base().updateMoves(*g.game);

	if (m_subscriber)
	{
		mstl::string const&	name		= cursor.name();
		variant::Type			variant	= cursor.variant();

		if (save::isOk(state))
		{
			TagSet tags;
			cursor.base().getGameTags(g.sourceIndex, tags);

			g.game->setIsModified(false);
			g.crcMoves = tags.computeChecksum(g.game->computeChecksum());
			m_subscriber->updateDatabaseInfo(name, variant);
			m_subscriber->updateGameInfo(m_position); // because of changed checksums

			if (m_current == &cursor)
			{
				for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
				{
					if (cursor.isViewOpen(i))
						m_subscriber->updateList(table::Games, m_updateCount, name, variant, i, g.sourceIndex);
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

	M_ASSERT(game == 0 || game->index == index);

	if (game)
	{
		TagSet tags;
		cursor.base().setupTags(index, tags);
		game->game->setTags(tags);
		game->crcIndex = cursor.base().computeChecksum(index);
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
				game->game->updateSubscriber(Game::UpdatePgn);
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


db::load::State
Application::importGame(db::Producer& producer, unsigned position, bool trialMode)
{
	M_REQUIRE(containsGameAt(position));
	M_REQUIRE(contains(scratchbaseName()));

	if (position == InvalidPosition)
		position = m_position;

	GameP game	= m_gameMap.find(position)->second;
	GameP myGame	= game;

	unsigned rememberPosition = position;

	if (!game->cursor->isScratchbase())
	{
		position = findUnusedPosition();
		myGame = insertScratchGame(position, producer.variant());

		mstl::swap(myGame->game, game->game);
		mstl::swap(myGame->backup, game->backup);
	}

	Cursor* scratch = scratchbase(variant::toMainVariant(producer.variant()));
	unsigned count = scratch->base().importGame(producer, myGame->index);
	db::load::State state = count ? db::load::Ok : db::load::None;

	if (count > 0 && !trialMode)
	{
		state = loadGame(position);
		myGame->game->setIsModified(true);
	}

	if (game->cursor != scratch)
	{
		mstl::swap(myGame->game, game->game);
		mstl::swap(myGame->backup, game->backup);

		scratch->database().deleteGame(myGame->index, true);
		releaseGame(position);
		// TODO: compress scratch base
	}

	game->game->setIsIrreversible(true);

	if (count > 0 && !trialMode && m_subscriber)
	{
		game->game->updateSubscriber(Game::UpdateAll);
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

	game.sourceBase = name;
	game.sourceIndex = index;

	if (m_subscriber)
		m_subscriber->updateGameInfo(position);
}


void
Application::setupGame(	unsigned linebreakThreshold,
								unsigned linebreakMaxLineLengthMain,
								unsigned linebreakMaxLineLengthVar,
								unsigned linebreakMinCommentLength,
								unsigned displayStyle,
								move::Notation moveStyle)
{
	M_REQUIRE(displayStyle & (display::CompactStyle | display::ColumnStyle));
	M_REQUIRE((displayStyle & (display::CompactStyle | display::ColumnStyle))
					!= (display::CompactStyle | display::ColumnStyle));

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		i->second->game->setup(	linebreakThreshold,
										linebreakMaxLineLengthMain,
										linebreakMaxLineLengthVar,
										linebreakMinCommentLength,
										displayStyle,
										moveStyle);

		i->second->refresh = 1;
	}
}


void
Application::setupGameUndo(unsigned undoLevel, unsigned combinePredecessingMoves)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
		i->second->game->setUndoLevel(undoLevel, combinePredecessingMoves);

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
	sys::thread::stop();

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
Application::changeVariant(mstl::string const& name, ::db::variant::Type variant)
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

// vi:set ts=3 sw=3:
