// ======================================================================
// Author : $Author$
// Version: $Revision: 569 $
// Date   : $Date: 2012-12-16 22:41:55 +0100 (Sun, 16 Dec 2012) $
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

extern "C" { struct Tcl_Obj; }

namespace tcl {
namespace compare {

int setMappingTable(Tcl_Obj* table);
int setAlphabeticList(Tcl_Obj* table);
Tcl_Obj* makeComparableObj(char const* s, bool skipPunct);
int compare(Tcl_Obj* lhs, Tcl_Obj* rhs);

} // namespace compare
} // namespace tcl

// vi:set ts=3 sw=3:
