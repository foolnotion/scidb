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

#include "app_thread.h"

#include "db_tree.h"

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

class Cursor;

class TreeAdmin : public Thread
{
public:

	typedef mstl::ref_counted_ptr<db::Tree> TreeP;
	typedef db::Tree::Key Key;

	TreeAdmin();
	~TreeAdmin();

	TreeP tree() const;

	bool isUpToDate(Cursor const& cursor, db::Game const& game, Key const& key) const;
	bool isRunning() const;

	bool startUpdate(	Cursor& cursor,
							db::Game& game,
							db::tree::Method method,
							db::tree::Mode mode,
							db::rating::Type ratingType,
							util::PipedProgress& progress);

	bool finishUpdate(Cursor const* cursor,
							db::Game const& game,
							db::tree::Method method,
							db::tree::Mode mode,
							db::rating::Type ratingType,
							db::attribute::tree::ID sortAttr);

	void signal(Signal signal) override;

private:

	struct Runnable;

	void destroy();

	Runnable*	m_runnable;
	TreeP			m_currentTree;
};

} // namespace app

#include "app_tree_admin.ipp"

#endif // _app_tree_admin_included

// vi:set ts=3 sw=3:
