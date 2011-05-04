// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_position_included
#define _tcl_position_included

extern "C" { struct Tcl_Interp; }

namespace db	{ class Board; }
namespace mstl	{ class string; }

namespace tcl {
namespace pos {

void dumpBoard(::db::Board const& board, mstl::string& result);
void dumpFen(mstl::string const& position, mstl::string& result);
void resetMoveCache();

} // namespace pos
} // namespace tcl

#endif // _tcl_position_included

// vi:set ts=3 sw=3:
