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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_player_included
#define _tcl_player_included

#include "db_common.h"

#include "m_pair.h"

extern "C" { struct Tcl_Interp; }

namespace db { class NamebasePlayer; }

namespace tcl
{
	namespace player
	{
		typedef mstl::pair< ::db::rating::Type, ::db::rating::Type> Ratings;
		int getInfo(::db::NamebasePlayer const& player, Ratings& ratings, bool info, bool idCard);
	}
}

#endif // _tcl_player_included

// vi:set ts=3 sw=3:
