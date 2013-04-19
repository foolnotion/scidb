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

namespace cql {

inline
Board::Pieces::Pieces()
	:pawns(0)
	,knights(0)
	,bishops(0)
	,rooks(0)
	,queens(0)
	,kings(0)
	,any(0)
{
}


inline Board::Board() :empty(0) {}

inline void Board::Pieces::complete() { any = pawns | knights | bishops | rooks | queens | kings; }


inline
void
Board::complete()
{
	pieces[0].complete();
	pieces[1].complete();
	any = pieces[0].any | pieces[1].any;
}

} // namespace cql

// vi:set ts=3 sw=3:
