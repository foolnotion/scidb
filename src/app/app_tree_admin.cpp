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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "app_tree_admin.h"
#include "app_cursor.h"

#include "db_tree.h"
#include "db_database.h"
#include "db_game.h"
#include "db_line.h"
#include "db_exception.h"

#include "u_piped_progress.h"

using namespace app;
using namespace util;


struct TreeAdmin::Runnable
{
	Runnable(db::Tree::TreeP tree,
				db::Game& game,
				db::Database& database,
				db::tree::Method method,
				db::tree::Mode mode,
				db::rating::Type ratingType,
				PipedProgress& progress)
		:m_database(database)
		,m_progress(progress)
		,m_method(method)
		,m_mode(mode)
		,m_ratingType(ratingType)
		,m_currentLine(m_lineBuf)
		,m_hpsig(game.currentLine(m_currentLine))
		,m_idn(game.idn())
		,m_startPosition(game.startBoard())
		,m_currentPosition(game.currentBoard())
		,m_tree(tree)
	{
		game.currentLine(m_currentLine);
	}

	~Runnable() { close(); }

	void close()
	{
		m_database.closeAsyncTreeSearchReader();
	}

	void operator() ()
	{
		m_database.openAsyncTreeSearchReader();

		try
		{
			m_tree.reset(db::Tree::makeTree(	m_tree,
														m_idn,
														m_startPosition,
														m_currentPosition,
														m_currentLine,
														m_hpsig,
														m_database,
														m_method,
														m_mode,
														m_ratingType,
														m_progress));
		}
		catch (...)
		{
			close();
			throw;
		}

		close();
	}

	db::Database&			m_database;
	util::PipedProgress&	m_progress;
	db::tree::Method		m_method;
	db::tree::Mode			m_mode;
	db::rating::Type		m_ratingType;
	db::Line					m_currentLine;
	uint16_t					m_hpsig;
	unsigned					m_idn;
	db::Board				m_startPosition;
	db::Board				m_currentPosition;
	TreeP						m_tree;
	uint16_t					m_lineBuf[db::opening::Max_Line_Length];
};


TreeAdmin::TreeAdmin() :m_runnable(0) {}
TreeAdmin::~TreeAdmin() { delete m_runnable; }


bool
TreeAdmin::isUpToDate(Cursor const& cursor, db::Game const& game, Key const& key) const
{
	if (m_runnable)
		return false;

	TreeP tree(db::Tree::lookup(	cursor.database(),
											game.currentBoard(),
											key.method(),
											key.mode(),
											key.ratingType()));
	return tree ? tree->key() == key && tree->isComplete() : false;
}


void
TreeAdmin::destroy()
{
	stop();
	setWorkingOn();

	if (m_runnable)
	{
		if (m_runnable->m_tree)
		{
			m_runnable->m_tree->compressFilter();
			db::Tree::addToCache(m_runnable->m_tree.get());
		}

		delete m_runnable;
		m_runnable = 0;
	}
}


void
TreeAdmin::signal(Signal signal)
{
	stop();
	setWorkingOn();

	if (m_runnable)
	{
		if (signal == Stop)
		{
			TreeP tree = m_runnable->m_tree;

			if (tree)
			{
				tree->compressFilter();
				db::Tree::addToCache(tree.get());
			}
		}

		delete m_runnable;
		m_runnable = 0;
	}
}


bool
TreeAdmin::startUpdate(	Cursor& cursor,
								db::Game& game,
								db::tree::Method method,
								db::tree::Mode mode,
								db::rating::Type ratingType,
								PipedProgress& progress)
{
	db::Database& referenceBase(cursor.getDatabase()); // calls signal(Stop)
	TreeP tree(db::Tree::lookup(referenceBase, game.currentBoard(), method, mode, ratingType));

	if (tree)
	{
		if (tree->isComplete())
			return true;

		tree->uncompressFilter();
	}

	m_runnable = new Runnable(tree, game, referenceBase, method, mode, ratingType, progress);

	if (!start(mstl::function<void ()>(&Runnable::operator(), m_runnable)))
	{
		delete m_runnable;
		m_runnable = 0;
		IO_RAISE(Unspecified, Cannot_Create_Thread, "start of tree update failed");
	}

	setWorkingOn(&cursor);

	return false;
}


bool
TreeAdmin::finishUpdate(Cursor const* cursor,
								db::Game const& game,
								db::tree::Method method,
								db::tree::Mode mode,
								db::rating::Type ratingType,
								db::attribute::tree::ID sortAttr)
{
	bool updated = false;

	TreeP tree;

	stop();
	setWorkingOn();

	if (m_runnable)
	{
		tree = m_runnable->m_tree;

		if (tree)
		{
			db::Tree::addToCache(tree.get());

			db::Database const* referenceBase = cursor ? &cursor->database() : 0;

			if (	referenceBase == 0
				|| referenceBase->countGames() != tree->filter().size()
				|| !tree->isTreeFor(*referenceBase, game.currentBoard(), method, mode, ratingType))
			{
				tree->compressFilter();
				tree.reset(0);	// tree is incomplete or outdated
			}
		}

		delete m_runnable;
		m_runnable = 0;
	}

	if (cursor == 0)
	{
		m_currentTree.reset();
	}
	else
	{
		if (!tree)
		{
			db::Database const& referenceBase = cursor->database();

			tree.reset(db::Tree::lookup(referenceBase, game.currentBoard(), method, mode, ratingType));

			if (tree)
			{
				if (tree->filter().size() != referenceBase.countGames())
					tree->setIncomplete();

				if (!tree->isComplete())
					tree.reset(0);
			}
		}

		if (tree)
		{
			tree->uncompressFilter();

			if (tree && sortAttr != db::attribute::tree::LastColumn)
				tree->sort(sortAttr);

			if (!m_currentTree || tree->prevGameCount() != tree->countGames())
				updated = true;

			if (m_currentTree != tree)
			{
				if (m_currentTree)
				{
					m_currentTree->compressFilter();
					updated = true;
				}

				m_currentTree = tree;
			}
		}
		else
		{
			m_currentTree.reset();
		}
	}

	return updated;
}

// vi:set ts=3 sw=3:
