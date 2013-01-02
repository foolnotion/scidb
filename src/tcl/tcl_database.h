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

#ifndef _tcl_database_included
#define _tcl_database_included

#include "db_common.h"

#include "m_pair.h"

extern "C" { struct Tcl_Interp; }

namespace db { class Database; }
namespace db { class GameInfo; }
namespace db { class NamebasePlayer; }
namespace db { class TagSet; }

namespace tcl
{
	namespace db
	{
		typedef mstl::pair< ::db::rating::Type, ::db::rating::Type> Ratings;

		int getGameInfo(	::db::Database const& db,
								unsigned index,
								Ratings const& ratings);
		int getPlayerStats(::db::Database const& db, ::db::NamebasePlayer const& player);
		int getTags(::db::TagSet const& tags, bool userSuppliedOnly);

		char const* lookupType(::db::type::ID type);
	}
}

#endif // _tcl_database_included

// vi:set ts=3 sw=3:
