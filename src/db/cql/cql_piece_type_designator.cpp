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

#include "cql_piece_type_designator.h"

using namespace cql;
using namespace cql::error;
using namespace cql::piece;


char const*
PieceTypeDesignator::parse(char const* s, Error& error)
{
	char const* p = s;
	char const* q = s;

	if (*q == '[')
	{
		for ( ; *q != ']'; ++q)
		{
			if (*q == '\0')
			{
				error = Unmatched_Bracket;
				return s;
			}
		}

		++p;
		--q;

		if (p == q)
		{
			error = Empty_Piece_Designator;
			return s;
		}
	}
	else
	{
		++q;
	}

	for ( ; p < q; ++p)
	{
		switch (*p)
		{
			case 'K': m_pieces.set(WK); break;
			case 'Q': m_pieces.set(WQ); break;
			case 'R': m_pieces.set(WR); break;
			case 'B': m_pieces.set(WB); break;
			case 'N': m_pieces.set(WN); break;
			case 'P': m_pieces.set(WP); break;
			case 'k': m_pieces.set(BK); break;
			case 'q': m_pieces.set(BQ); break;
			case 'r': m_pieces.set(BR); break;
			case 'b': m_pieces.set(BB); break;
			case 'n': m_pieces.set(BN); break;
			case 'p': m_pieces.set(BP); break;
			case '.': m_pieces.set(E);  break;
			case 'A': m_pieces.set(WK | WQ | WR | WB | WN | WP); break;
			case 'a': m_pieces.set(BK | BQ | BR | BB | BN | BP); break;
			case 'M': m_pieces.set(WQ | WR); break;
			case 'm': m_pieces.set(BQ | BR); break;
			case 'I': m_pieces.set(WB | WN); break;
			case 'i': m_pieces.set(BB | BN); break;
			case 'U': m_pieces.set(WK | WQ | WR | WB | WN | WP | BK | BQ | BR | BB | BN | BP); break;
			case '?': m_pieces.set(WK | WQ | WR | WB | WN | WP | BK | BQ | BR | BB | BN | BP | E); break;
		}
	}

	return q;
}

// vi:set ts=3 sw=3:
