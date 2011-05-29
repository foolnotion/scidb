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

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_database.h"
#include "db_game.h"
#include "db_game_info.h"
#include "db_eco_table.h"
#include "db_tree.h"
#include "db_board.h"
#include "db_line.h"

#include "u_piped_progress.h"

#include "sys_utf8_codec.h"
#include "sys_thread.h"

#include "m_ifstream.h"
#include "m_algorithm.h"
#include "m_function.h"
#include "m_auto_ptr.h"
#include "m_ref_counted_ptr.h"
#include "m_limits.h"
#include "m_assert.h"
#include "m_stdio.h"

#include <string.h>

using namespace db;
using namespace app;
using namespace util;


mstl::string Application::m_clipbaseName("Clipbase");
mstl::string Application::m_scratchbaseName("Scratchbase");

Application* Application::m_instance = 0;

static unsigned undoLevel = 20;


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
Application::Subscriber::updateList(mstl::string const& filename)
{
	updateGameList(filename);
	updatePlayerList(filename);
	updateEventList(filename);
	updateAnnotatorList(filename);
}


void
Application::Subscriber::updateList(mstl::string const& filename, unsigned view)
{
	updateGameList(filename, view);
	updatePlayerList(filename, view);
	updateEventList(filename, view);
	updateAnnotatorList(filename, view);
}


Application::Application()
	:m_current(0)
	,m_clipBase(0)
	,m_scratchBase(0)
	,m_referenceBase(0)
	,m_switchReference(true)
	,m_isUserSet(false)
	,m_position(InvalidPosition)
	,m_subscriber(0)
{
	M_REQUIRE(!hasInstance());

	m_instance = this;

	m_clipBase = new Cursor(
						*this,
						new Database(
							m_clipbaseName,
							sys::utf8::Codec::utf8(),
							Database::MemoryOnly,
							db::type::Clipbase));

	m_scratchBase = new Cursor(
							*this,
							new Database(
								m_scratchbaseName,
								sys::utf8::Codec::utf8(),
								Database::MemoryOnly,
								db::type::Clipbase));

	m_cursorMap[m_clipbaseName] = m_clipBase;
	m_cursorMap[m_scratchbaseName] = m_scratchBase;

	m_current = m_clipBase;
	setReferenceBase(m_current, false);
}


Application::~Application() throw()
{
	m_instance = 0;

	for (CursorMap::iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
		delete i->second;

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		delete i->second.game;
		delete i->second.backup;
	}
}


Application::EditGame&
Application::insertGame(unsigned position)
{
	EditGame& game = m_gameMap[position];
	::memset(&game, 0, sizeof(EditGame));
	game.game = new Game;
	return game;
}


Application::EditGame&
Application::insertScratchGame(unsigned position)
{
	Database& base = m_scratchBase->base();
	EditGame& game = insertGame(position);

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

		m_indexMap[position] = index = base.countGames();

		if (base.newGame(*game.game, info) != save::Ok)
			M_RAISE("unexpected error: couldn't add new game to Scratchbase");

		game.game->finishLoad();
	}
	else
	{
		index = i->second;
	}

	game.cursor = m_scratchBase;
	game.index = index;
	game.game->setUndoLevel(::undoLevel);
	game.crcIndex = base.gameInfo(index).computeChecksum();
	game.crcMoves = game.game->computeChecksum();
	game.sourceBase = base.name();
	game.sourceIndex = index;

	return game;
}


bool
Application::initialize(mstl::string const& ecoPath)
{
	mstl::ifstream ecoStream(ecoPath, mstl::ios_base::in | mstl::ios_base::binary);

	if (!ecoStream)
		return false;

	EcoTable::specimen().load(ecoStream);
	return true;
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
Application::containsGameAt(unsigned position) const
{
	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position) != m_gameMap.end();
}


bool
Application::hasTrialMode(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(m_position)->second.backup != 0;
}


Cursor*
Application::findBase(mstl::string const& name)
{
	CursorMap::iterator i = m_cursorMap.find(name);
	return i == m_cursorMap.end() ? 0 : i->second;
}


Cursor const*
Application::findBase(mstl::string const& name) const
{
	CursorMap::const_iterator i = m_cursorMap.find(name);
	return i == m_cursorMap.end() ? 0 : i->second;
}


Application::EditGame*
Application::findGame(Cursor* cursor, unsigned index)
{
	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		EditGame& game = i->second;

		if (game.cursor == cursor && game.index == index)
			return &game;
	}

	return 0;
}


Cursor*
Application::open(mstl::string const& filename,
						mstl::string const& encoding,
						bool readOnly,
						Progress& progress)
{
	if (m_cursorMap.find(filename) != m_cursorMap.end())
		return 0;

	return m_cursorMap[filename] = new Cursor(
												*this,
												new Database(
													filename,
													encoding,
													readOnly ? Database::ReadOnly : Database::ReadWrite,
													progress));
}


Cursor*
Application::create(mstl::string const& name, mstl::string const& encoding, type::ID type)
{
	if (m_cursorMap.find(name) != m_cursorMap.end())
		return 0;

	return m_cursorMap[name] = new Cursor(	*this,
														new Database(name, encoding, Database::MemoryOnly, type));
}


void
Application::close(Cursor& cursor)
{
	M_REQUIRE(contains(cursor));
	M_ASSERT(&cursor != m_scratchBase);

	moveGamesToScratchbase(cursor);

	if (m_current == &cursor)
		m_current = m_clipBase;

	if (m_referenceBase == &cursor)
		setReferenceBase(0, false);

	m_cursorMap.erase(cursor.name());
	cursor.close();
	delete &cursor;
}


void
Application::close(mstl::string const& name)
{
	M_REQUIRE(contains(name));

	if (m_subscriber)
		m_subscriber->closeDatabase(name);

	close(*findBase(name));
}


void
Application::closeAll(CloseMode mode)
{
	CursorMap map;

	for (CursorMap::iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
	{
		if (mode == Including_Clipbase || i->first != m_clipbaseName)
		{
			if (m_subscriber)
				m_subscriber->closeDatabase(i->second->name());

			i->second->close();
			delete i->second;
		}
		else
		{
			map[m_clipbaseName] = i->second;
		}
	}

	m_cursorMap.swap(map);
	setReferenceBase(mode == Including_Clipbase ? 0 : m_clipBase, false);
}


void
Application::closeAllGames(Cursor& cursor)
{
	M_REQUIRE(contains(cursor));

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second.cursor == &cursor)
		{
			unsigned		position	= i->first;
			EditGame&	game		= i->second;

			if (game.cursor == m_scratchBase)
				m_indexMap.erase(position);

			delete game.game;
			delete game.backup;

			i = m_gameMap.erase(i);

			if (m_position == position)
				m_position = InvalidPosition;
		}
	}
}


GameInfo const&
Application::gameInfo(unsigned index, unsigned view) const
{
	return m_current->base().gameInfo(m_current->gameIndex(index, view));
}


GameInfo const&
Application::gameInfoAt(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	EditGame const& g = m_gameMap.find(position)->second;
	return g.cursor->base().gameInfo(g.index);
}


unsigned
Application::gameIndex(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second.index;
}


mstl::string const&
Application::databaseName(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second.cursor->name();
}


uint32_t
Application::checksum(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return m_gameMap.find(position)->second.crcIndex;
}


NamebasePlayer const&
Application::player(unsigned index, unsigned view) const
{
	return m_current->base().player(m_current->playerIndex(index, view));
}


void
Application::setReferenceBase(Cursor* cursor, bool isUserSet)
{
	M_REQUIRE(cursor == 0 || cursor->base().format() != format::ChessBase);

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

			if (m_subscriber)
				m_subscriber->updateTree(m_referenceBase->name());
		}
		else if (m_subscriber)
		{
			m_subscriber->updateTree(mstl::string::empty_string);
		}
	}
}


void
Application::setSubscriber(SubscriberP subscriber)
{
	m_subscriber = subscriber;
//	if ((m_subscriber = subscriber))
//	{
//		m_subscriber->updateGameList(cursor().name());
//
//		if (m_referenceBase)
//			m_subscriber->updateTree(m_referenceBase->name());
//	}
}


void
Application::switchBase(Cursor& cursor)
{
	M_REQUIRE(contains(cursor));

	m_current = &cursor;

	if (	(m_switchReference || (!m_isUserSet && m_referenceBase == m_clipBase))
		&& cursor.base().format() != format::ChessBase)
	{
		setReferenceBase(m_current, false);
	}

	if (m_subscriber)
		m_subscriber->updateList(cursor.name());
}


void
Application::switchBase(mstl::string const& name)
{
	M_REQUIRE(contains(name));
	switchBase(*findBase(name));
}


void
Application::searchGames(Cursor& cursor, Query const& query, unsigned view, unsigned filter)
{
	View& v = cursor.view(view);

	v.searchGames(query);

	if (filter & Events)
		v.filterEvents();

	if (filter & Players)
		v.filterPlayers();

	if (m_subscriber)
	{
		m_subscriber->updateGameList(cursor.name(), view);

		if (filter & Players)
			m_subscriber->updatePlayerList(cursor.name(), view);

		if (filter & Events)
			m_subscriber->updateEventList(cursor.name(), view);
	}
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::game::ID attr,
						order::ID order,
						rating::Type ratingType)
{
	cursor.view(view).sort(attr, order, ratingType);

	if (m_subscriber)
		m_subscriber->updateGameList(cursor.name(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						attribute::player::ID attr,
						order::ID order,
						rating::Type ratingType)
{
	cursor.view(view).sort(attr, order, ratingType);

	if (m_subscriber)
		m_subscriber->updatePlayerList(cursor.name(), view);
}


void
Application::sort(Cursor& cursor,
						unsigned view,
						db::attribute::event::ID attr,
						db::order::ID order)
{
	cursor.view(view).sort(attr, order);

	if (m_subscriber)
		m_subscriber->updateEventList(cursor.name(), view);
}


void
Application::sort(Cursor& cursor, unsigned view, attribute::annotator::ID attr, order::ID order)
{
	cursor.view(view).sort(attr, order);

	if (m_subscriber)
		m_subscriber->updateAnnotatorList(cursor.name(), view);
}


void
Application::reverse(Cursor& cursor, unsigned view, attribute::game::ID attr)
{
	cursor.view(view).reverse(attr);

	if (m_subscriber)
		m_subscriber->updateGameList(cursor.name(), view);
}


void
Application::reverse(Cursor& cursor, unsigned view, attribute::player::ID attr)
{
	cursor.view(view).reverse(attr);

	if (m_subscriber)
		m_subscriber->updatePlayerList(cursor.name(), view);
}


void
Application::reverse(Cursor& cursor, unsigned view, attribute::event::ID attr)
{
	cursor.view(view).reverse(attr);

	if (m_subscriber)
		m_subscriber->updateEventList(cursor.name(), view);
}


void
Application::reverse(Cursor& cursor, unsigned view, attribute::annotator::ID attr)
{
	cursor.view(view).reverse(attr);

	if (m_subscriber)
		m_subscriber->updateAnnotatorList(cursor.name(), view);
}


void
Application::recode(Cursor& cursor, mstl::string const& encoding, Log& log)
{
	cursor.database().recode(encoding, log);

	if (m_subscriber)
		m_subscriber->updateList(cursor.name());
}


bool
Application::loadGame(unsigned position, Cursor& cursor, unsigned index)
{
	M_REQUIRE(position != InvalidPosition);

	bool isNew = !containsGameAt(position);

	Database& base = cursor.base();
	EditGame& game = isNew ? insertGame(position) : m_gameMap[position];

	if (!isNew)
		game.game->resetForNextLoad();

	GameInfo const& info = base.gameInfo(index);

	// TODO: compress scratch base (we need fast compress)

	game.game->setUndoLevel(::undoLevel);
	game.cursor = &cursor;
	game.index = index;
	bool ok = base.loadGame(index, *game.game);
	game.crcIndex = info.computeChecksum();
	game.crcMoves = game.game->computeChecksum();
	game.game->updateSubscriber(Game::UpdateAll);
	game.sourceBase = base.name();
	game.sourceIndex = index;

	if (m_subscriber && !isNew)
		m_subscriber->updateGameInfo(position);

	return ok;
}


bool
Application::loadGame(unsigned position)
{
	return loadGame(position, *m_scratchBase, indexAt(position));
}


unsigned
Application::indexAt(unsigned position) const
{
	M_REQUIRE(position != InvalidPosition);
	M_REQUIRE(containsGameAt(position));

	return m_gameMap.find(position)->second.index;
}


void
Application::newGame(unsigned position)
{
	M_REQUIRE(position != InvalidPosition);
	M_REQUIRE(!containsGameAt(position));

	insertScratchGame(position);
}


void
Application::releaseGame(unsigned position)
{
	if (position == InvalidPosition)
		position = m_position;

	if (!containsGameAt(position))
		return;

	EditGame& game = m_gameMap[position];

	if (game.cursor == m_scratchBase)
		m_indexMap.erase(position);

	delete game.game;
	delete game.backup;

	m_gameMap.erase(position);

	if (m_position == position)
		m_position = InvalidPosition;
}


void
Application::deleteGame(Cursor& cursor, unsigned index, unsigned view, bool flag)
{
	cursor.base().deleteGame(cursor.gameIndex(index, view), flag);

	if (m_subscriber)
	{
		m_subscriber->updateGameList(cursor.name(), view, index);
		m_subscriber->updatePlayerList(cursor.name(), view);
		m_subscriber->updateEventList(cursor.name(), view);
		m_subscriber->updateAnnotatorList(cursor.name(), view);
	}
}


void
Application::setGameFlags(Cursor& cursor, unsigned index, unsigned view, unsigned flags)
{
	cursor.base().setGameFlags(cursor.gameIndex(index, view), flags);

	if (m_subscriber)
		m_subscriber->updateGameList(cursor.name(), view, index);
}


void
Application::clearGame(Board const* startPosition)
{
	M_REQUIRE(haveCurrentGame());

	EditGame& game = m_gameMap[m_position];
	game.game->clear(startPosition);
	game.game->updateSubscriber(Game::UpdateBoard);

	if (m_subscriber && m_referenceBase)
		m_subscriber->updateTree(m_referenceBase->name());
}


void
Application::switchGame(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = currentPosition();

	stopUpdateTree();

	unsigned		flags	= Game::UpdateBoard;
	EditGame&	game	= m_gameMap[position];

	if (game.refresh)
	{
		flags |= Game::UpdatePgn | Game::UpdateOpening;
		game.refresh = false;
	}

	m_position = position;
	game.game->updateSubscriber(flags);

	if (m_subscriber && m_referenceBase)
		m_subscriber->updateTree(m_referenceBase->name());
}


void
Application::startTrialMode()
{
	M_REQUIRE(!hasTrialMode());

	EditGame& game = m_gameMap[m_position];

	game.backup = game.game;
	game.game = new Game(*game.backup);
	game.game->moveTo(game.backup->currentKey());
}


void
Application::endTrialMode()
{
	M_REQUIRE(hasTrialMode());

	EditGame& game = m_gameMap[m_position];

	delete game.game;
	game.game = game.backup;
	game.game->moveTo(game.backup->currentKey());
	game.backup = 0;
}


void
Application::refreshGame(bool radical) const
{
	M_REQUIRE(haveCurrentGame());

	Game* game = m_gameMap.find(m_position)->second.game;
	game->refreshSubscriber(radical);
}


Game&
Application::game(unsigned position)
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return *m_gameMap.find(position)->second.game;
}


Game const&
Application::game(unsigned position) const
{
	M_REQUIRE(containsGameAt(position));

	if (position == InvalidPosition)
		position = m_position;

	return *m_gameMap.find(position)->second.game;
}


void
Application::moveGamesToScratchbase(Cursor& cursor)
{
	if (&cursor == m_scratchBase)
		return;

	Database& base = m_scratchBase->base();

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		if (i->second.cursor == &cursor)
		{
			EditGame& game = i->second;

			unsigned index = base.countGames();

			m_indexMap[i->first] = index;

			GameInfo info(game.cursor->base().gameInfo(game.index));
			info.reallocate(base.namebases());
			base.namebases().update();

			if (base.newGame(*game.game, info) != save::Ok)
				M_RAISE("unexpected error: couldn't add new game to Scratchbase");

			game.cursor = m_scratchBase;
			game.index = index;
			game.sourceBase = cursor.name();
			game.sourceIndex = index;
		}
	}
}


void
Application::clearBase(Cursor& cursor)
{
	moveGamesToScratchbase(cursor);
	cursor.clearBase();

	if (m_subscriber)
	{
		m_subscriber->updateDatabaseInfo(cursor.name());
		m_subscriber->updateList(cursor.name());

		if (m_referenceBase == &cursor)
			m_subscriber->updateTree(m_referenceBase->name());
	}
}


bool
Application::updateTree(tree::Mode mode, rating::Type ratingType, PipedProgress& progress)
{
	M_REQUIRE(haveCurrentGame());

	if (m_referenceBase == 0)
		return false;

	M_ASSERT(m_referenceBase->hasTreeView());

	sys::thread::stop();

	EditGame const& g	= m_gameMap.find(m_position)->second;
	Database& base		= m_referenceBase->base();

	if (::runnable)
	{
		if (Runnable::TreeP tree = ::runnable->m_tree)
		{
			tree->compressFilter();
			Tree::addToCache(tree.get());
		}

		delete ::runnable;
		::runnable = 0;
	}

	base.openAsyncReader();

	Runnable::TreeP tree(Tree::lookup(base, g.game->currentBoard(), mode, ratingType));

	if (tree)
	{
		if (tree->isComplete())
			return true;

		tree->uncompressFilter();
	}

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
						m_subscriber->updateGameList(	m_referenceBase->name(),
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

	if (m_instance->m_referenceBase)
		m_instance->m_referenceBase->base().closeAsyncReader();

	if (::runnable)
	{
		Runnable::TreeP tree = ::runnable->m_tree;

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

	if (m_instance->m_referenceBase)
		m_instance->m_referenceBase->base().closeAsyncReader();

	delete ::runnable;
	::runnable = 0;
}


void
Application::enumCursors(CursorList& list) const
{
	list.clear();

	for (CursorMap::const_iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
	{
		if (i->second != m_scratchBase && i->second != m_clipBase)
			list.push_back(i->second);
	}
}


save::State
Application::saveGame(Cursor& cursor, bool replace)
{
	M_REQUIRE(cursor.isOpen());
	M_REQUIRE(haveCurrentGame());

	EditGame&	g(m_gameMap.find(m_position)->second);
	save::State	state;

	if (cursor.isReferenceBase())
	{
		uint64_t crc = g.game->computeChecksum();

		if (g.crcMoves != crc)
		{
			cancelUpdateTree();
			g.crcMoves = crc;

			for (CursorMap::iterator i = m_cursorMap.begin(); i != m_cursorMap.end(); ++i)
				Tree::clearCache(i->second->base());
		}
		else
		{
			stopUpdateTree();
		}
	}

	GameInfo* info	= &g.cursor->base().gameInfo(g.index);
	Database& db	= cursor.base();

	if (replace)
	{
		g.game->setFlags(info->flags());
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

		for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
		{
			if (cursor.isViewOpen(i))
				cursor.view(i).update(View::AddNewGames);
		}

		info = &g.cursor->base().gameInfo(g.index);
	}

	info->setIllegalMove(g.game->containsIllegalMoves());

	if (state == save::Ok)
	{
		info->setDirty(false);
		g.game->setIsModified(false);

		if (m_subscriber)
		{
			if (!replace)
				m_subscriber->updateDatabaseInfo(cursor.name());

			m_subscriber->updateGameInfo(m_position);

			for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
			{
				if (cursor.isViewOpen(i))
				{
					if (replace)
					{
						m_subscriber->updateGameList(db.name(), i, g.game->index());
						m_subscriber->updatePlayerList(db.name(), i);
						m_subscriber->updateEventList(db.name(), i);
						m_subscriber->updateAnnotatorList(db.name(), i);
					}
					else
					{
						m_subscriber->updateList(db.name(), i);
					}
				}
			}
		}

		g.game->updateSubscriber(Game::UpdatePgn);
	}

	if (m_subscriber && cursor.isReferenceBase())
		m_subscriber->updateTree(db.name());

	return state;
}


db::save::State
Application::updateMoves(Cursor& cursor, unsigned index)
{
	M_REQUIRE(cursor.isOpen());
	M_REQUIRE(index < cursor.countGames());
	M_REQUIRE(findGame(&cursor, index));

	if (cursor.isReferenceBase())
		cancelUpdateTree();

	EditGame* game = findGame(&cursor, index);

	game->game->setIndex(game->index);

	save::State state = cursor.base().updateMoves(*game->game);

	if (m_subscriber)
	{
		mstl::string const& name = cursor.name();

		if (state == save::Ok)
		{
			m_subscriber->updateDatabaseInfo(name);

			for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
			{
				if (cursor.isViewOpen(i))
					m_subscriber->updateGameList(name, i, game->index);
			}

			game->game->updateSubscriber(Game::UpdatePgn);
		}

		if (cursor.isReferenceBase())
			m_subscriber->updateTree(name);
	}

	return state;
}


save::State
Application::updateCharacteristics(Cursor& cursor, unsigned index, TagSet const& tags)
{
	M_REQUIRE(cursor.isOpen());
	M_REQUIRE(index < cursor.countGames());

	if (cursor.isReferenceBase())
		cancelUpdateTree();

	save::State state = cursor.base().updateCharacteristics(index, tags);

	if (m_subscriber)
	{
		mstl::string const& name = cursor.name();

		if (state == save::Ok)
		{
			EditGame* game = findGame(&cursor, index);

			m_subscriber->updateDatabaseInfo(name);

			for (unsigned i = 0; i < cursor.maxViewNumber(); ++i)
			{
				if (cursor.isViewOpen(i))
				{
					if (game)
						m_subscriber->updateGameList(name, i, game->index);

					m_subscriber->updatePlayerList(name, i);
					m_subscriber->updateEventList(name, i);
					m_subscriber->updateAnnotatorList(name, i);
				}
			}

			if (game)
				game->game->updateSubscriber(Game::UpdatePgn);
		}

		if (cursor.isReferenceBase())
			m_subscriber->updateTree(name);
	}

	return state;
}


void
Application::setupGame(	unsigned linebreakThreshold,
								unsigned linebreakMaxLineLengthMain,
								unsigned linebreakMaxLineLengthVar,
								unsigned linebreakMinCommentLength,
								unsigned displayStyle)
{
	M_REQUIRE(displayStyle & (display::CompactStyle | display::ColumnStyle));
	M_REQUIRE((displayStyle & (display::CompactStyle | display::ColumnStyle))
					!= (display::CompactStyle | display::ColumnStyle));

	for (GameMap::iterator i = m_gameMap.begin(); i != m_gameMap.end(); ++i)
	{
		i->second.game->setup(	linebreakThreshold,
										linebreakMaxLineLengthMain,
										linebreakMaxLineLengthVar,
										linebreakMinCommentLength,
										displayStyle);

		i->second.refresh = true;
	}
}

// vi:set ts=3 sw=3:
