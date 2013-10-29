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

#ifndef _app_tree_admin_included
#define _app_tree_admin_included

#include "db_tree.h"

#include "sys_thread.h"

#include "m_ref_counted_ptr.h"

namespace db
{
	class Tree;
	class Game;
	class Board;
	class Database;
}

namespace util
{
	class PipedProgress;
}

namespace app {

class TreeAdmin
{
public:

	typedef mstl::ref_counted_ptr<db::Tree> TreeP;
	typedef db::Tree::Key Key;

	TreeAdmin();

	TreeP tree() const;
	sys::Thread& thread();

	bool isUpToDate(db::Database const& referenceBase, db::Game const& game, Key const& key) const;
	bool isRunning() const;

	bool startUpdate(	db::Database& referenceBase,
							db::Game& game,
							db::tree::Mode mode,
							db::rating::Type ratingType,
							util::PipedProgress& progress);

	bool finishUpdate(db::Database const* referenceBase,
							db::Game const& game,
							db::tree::Mode mode,
							db::rating::Type ratingType,
							db::attribute::tree::ID sortAttr);

	void stopUpdate();
	void cancelUpdate();

private:

	struct Runnable;

	void destroy();

	Runnable*	m_runnable;
	TreeP			m_currentTree;
	sys::Thread	m_thread;
};

} // namespace app

#include "app_tree_admin.ipp"

#endif // _app_tree_admin_included

// vi:set ts=3 sw=3:
