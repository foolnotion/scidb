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

#ifndef _tcl_game_included
#define _tcl_game_included

#include "db_common.h"

extern "C" { struct Tcl_Obj; }

namespace db { class TagSet; }

namespace tcl {
namespace game {

typedef ::db::tag::ID Ratings[2];

int convertTags(	::db::TagSet& tags,
						Tcl_Obj* taglist,
						::db::tag::ID wrt = ::db::tag::ExtraTag,
						::db::tag::ID brt = ::db::tag::ExtraTag,
						Ratings const* ratings = 0);

::db::variant::Type variantFromObj(Tcl_Obj* obj);
::db::variant::Type variantFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
::db::move::Notation notationFromObj(Tcl_Obj* obj);
::db::move::Notation notationFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
Tcl_Obj* objFromVariant(::db::variant::Type variant);

} // namespace game
} // namespace tcl

#endif // _tcl_game_included

// vi:set ts=3 sw=3:
