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
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _si3_encoder_position_included
#define _si3_encoder_position_included

#include "db_common.h"

#include "m_stack.h"

namespace db {

class Board;
class Move;

namespace si3 {
namespace encoder {

class Position
{
public:

	class Lookup
	{
	private:

		typedef Byte		Numbers[64];
		typedef Square		Squares[2][16];
		typedef Byte		RookNumbers[4];
		typedef unsigned	Count[2];

		friend class Position;

		void set(Square square, unsigned pieceNum, color::ID color);

		Numbers		numbers;
		Squares		squares;
		RookNumbers	rookNumbers;
		Count			pieceCount;
		unsigned		capturedNum;
	};

	Position();

	void setup(Board const& board);
	void setup();
	void doMove(Move const& move);
	void undoMove(Move const& move);

	void push();
	void pop();

	Byte operator[](unsigned n) const;
	Lookup& lookup();

private:

	typedef mstl::stack<Lookup> Stack;

	Stack m_stack;
};

} // namespace encoder
} // namespace si3
} // namespace db

namespace mstl {

template <typename> struct is_pod;
template <> struct is_pod<db::si3::encoder::Position::Lookup> { enum { value = 1 }; };

} // namespace mstl

#include "si3_encoder_position.ipp"

#endif // _si3_encoder_position_included

// vi:set ts=3 sw=3:
