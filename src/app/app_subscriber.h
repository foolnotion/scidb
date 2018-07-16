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
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_subscriber_included
#define _app_subscriber_included

#include "db_common.h"

#include "m_ref_counted_ptr.h"
#include "m_ref_counter.h"

namespace mstl { class string; }

namespace app {

struct Subscriber : public mstl::ref_counter
{
	virtual ~Subscriber() = 0;

	void updateList(	unsigned id,
							mstl::string const& name,
							db::variant::Type variant);
	void updateList(	unsigned id,
							mstl::string const& name,
							db::variant::Type variant,
							unsigned view);

	virtual void updateList(db::table::Type type,
									unsigned id,
									mstl::string const& name,
									db::variant::Type variant) = 0;
	virtual void updateList(db::table::Type type,
									unsigned id,
									mstl::string const& name,
									db::variant::Type variant,
									unsigned view) = 0;
	virtual void updateList(db::table::Type type,
									unsigned id,
									mstl::string const& name,
									db::variant::Type variant,
									unsigned view,
									unsigned index) = 0;
#if 0
	virtual void updateOpeningTree(	mstl::string const& name,
												db::variant::Type variant,
												unsigned view) = 0;
#endif

	virtual void updateDatabaseInfo(mstl::string const& name, db::variant::Type variant) = 0;

	virtual void updateGameInfo(	mstl::string const& name,
											db::variant::Type variant,
											unsigned index) = 0;
	virtual void updateGameInfo(unsigned position) = 0;
	virtual void updateGameData(unsigned position, bool evenMainline) = 0;

	virtual void gameSwitched(unsigned oldPosition, unsigned newPosition) = 0;
	virtual void gameClosed(unsigned position) = 0;
	virtual void databaseSwitched(mstl::string const& name, db::variant::Type variant) = 0;
	virtual void closeDatabase(mstl::string const& name, db::variant::Type variant) = 0;
	virtual void updateTree(mstl::string const& name, db::variant::Type variant) = 0;
	virtual void invalidateTreeCache() = 0;
};

} // namespace app

#endif // _app_subscriber_included

// vi:set ts=3 sw=3:
