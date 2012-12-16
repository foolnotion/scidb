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
// Copyright: (C) 2010-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_tree_included
#define _tcl_tree_included

#include "db_common.h"

extern "C" { struct Tcl_Interp; }
extern "C" { struct Tcl_Obj; }

namespace tcl {
namespace tree {

void referenceBaseChanged();
Tcl_Obj* variantToString(::db::variant::Type variant);

} // namespace tree
} // namespace tcl

#endif // _tcl_tree_included

// vi:set ts=3 sw=3:
