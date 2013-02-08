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

#ifndef _cbf_decoder_position_included
#define _cbf_decoder_position_included

#include "db_board.h"
#include "db_move.h"

#include "m_stack.h"

namespace util { class ByteStream; }

namespace db {
namespace cbf {
namespace decoder {

class Position
{
public:

	Position();

	unsigned variationLevel() const;

	void setup();
	void setup(util::ByteStream& strm, Byte h10, Byte h11);

	void push();
	void pop();

	Board const& board() const;
	Board& board();

	::db::Move doMove(unsigned moveNumber);

private:

	struct Entry
	{
		Entry();

		Board	board;
		bool	epFake;
	};

	typedef mstl::stack<Entry> Stack;

	void reset();

	Stack m_stack;
};

} // namespace decoder
} // namespace cbf
} // namespace db

#include "cbf_decoder_position.ipp"

#endif // _cbf_decoder_position_included

// vi:set ts=3 sw=3:
