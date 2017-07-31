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
// Copyright: (C) 2010-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_line.h"
#include "db_board.h"
#include "db_move.h"

#include "m_string.h"
#include "m_utility.h"
#include "m_stdio.h"
#include "m_assert.h"

using namespace db;


bool
Line::contains(uint16_t move) const
{
	for (unsigned i = 0; i < length; ++i)
	{
		if (moves[i] == move)
			return true;
	}

	return false;
}


Line&
Line::transpose(Line& dst) const
{
	M_REQUIRE(dst.length == length);

	for (unsigned i = 0; i < length; ++i)
	{
		Move m(moves[i]);
		m.transpose();
		const_cast<uint16_t*>(dst.moves)[i] = m.index();
	}

	return dst;
}


mstl::string&
Line::print(mstl::string& result,
				Board const& startBoard,
				variant::Type variant,
				unsigned firstPly,
				unsigned midPly,
				unsigned lastPly,
				move::Notation style,
				protocol::ID protocol,
				encoding::CharSet charSet) const
{
	M_REQUIRE(lastPly <= length);

	Board board(startBoard);

	for (unsigned i = 0; i < lastPly; ++i)
	{
		Move m = board.makeMove(moves[i]);

		if (i >= firstPly)
		{
			if (i > firstPly)
				result += ' ';
			if (i == midPly)
				result += '(';

			if (style != move::MAN)
			{
				unsigned plyNumber = board.plyNumber();

				if ((plyNumber & 1) == 0)
					result.format("%u.", mstl::div2(plyNumber) + 1);
				else if (i == firstPly)
					result.format("%u...", mstl::div2(plyNumber) + 1);
			}

			board.prepareForPrint(m, variant, Board::ExternalRepresentation);
			m.print(result, style, protocol, charSet);
		}

		board.doMove(m, variant);
	}

	if (midPly < lastPly)
		result += ')';

	return result;
}


mstl::string&
Line::print(	mstl::string& result,
					variant::Type variant,
					move::Notation style,
					protocol::ID protocol,
					encoding::CharSet charSet) const
{
	return print(result, Board::standardBoard(variant), variant, style, protocol, charSet);
}


void
Line::dump() const
{
	mstl::string result;
	::printf("%s\n", print(	result,
									Board::standardBoard(variant::Normal),
									variant::Normal,
									move::MAN,
									protocol::Standard).c_str());
}

// vi:set ts=3 sw=3:
