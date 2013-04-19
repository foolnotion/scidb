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

#ifndef _cql_board_defined
#define _cql_board_defined

#include "m_types.h"

namespace cql {

struct Board
{
	struct Pieces
	{
		Pieces();

		void complete();

		uint64_t pawns;
		uint64_t knights;
		uint64_t bishops;
		uint64_t rooks;
		uint64_t queens;
		uint64_t kings;
		uint64_t any;
	};

	Board();

	void complete();

	Pieces	pieces[2];
	uint64_t	empty;
	uint64_t	any;
};

} // namespace cql

#include "cql_board.ipp"

#endif // _cql_board_defined

// vi:set ts=3 sw=3:
