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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _si3_decoder_position_included
#define _si3_decoder_position_included

#include "db_board.h"
#include "db_move.h"

#include "m_stack.h"

namespace db {
namespace si3 {
namespace decoder {

class Position
{
public:

	Position();

	void setup(char const* fen);
	void setup();

	void doMove(Move& move, unsigned pieceNum);
	void undoMove(Move const& move);
	void push();
	void pop();

	Board const& board() const;
	Board& board();

	Board const& startBoard() const;

	color::ID sideToMove() const;

	bool whiteToMove() const;
	bool blackToMove() const;

	piece::Type piece(Square s) const;

	Square operator[](int n) const;

	Move makeCastlingMove(Square from, Square to);
	Move makeKingMove(Square s, Square t) const;
	Move makeQueenMove(Square s, Square t) const;
	Move makeRookMove(Square s, Square t) const;
	Move makeBishopMove(Square s, Square t) const;
	Move makeKnightMove(Square s, Square t) const;

private:

	typedef Square	Squares[32];
	typedef Byte	Numbers[64];
	typedef Byte	RookNumbers[4];

	struct Lookup
	{
		Lookup();

		void set(unsigned pieceNum, Square square);

		Board			board;
		Squares		squares;
		Numbers		numbers;
		RookNumbers	rookNumbers;
		unsigned		pieceCount[2];
		unsigned		capturedNum;
	};

	typedef mstl::stack<Lookup> Stack;

	Stack m_stack;
};

} // namespace decoder
} // namespace si3
} // namespace db

namespace mstl {

template <typename> struct is_pod;

template <>
struct is_pod<db::si3::decoder::Position::Lookup> { enum { value = is_pod<db::Board>::value }; };

} // namespace mstl

#include "si3_decoder_position.ipp"

#endif // _si3_decoder_position_included

// vi:set ts=3 sw=3:
