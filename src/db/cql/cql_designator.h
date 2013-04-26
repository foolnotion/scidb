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

#ifndef _cql_designator_defined
#define _cql_designator_defined

#include "cql_board.h"
#include "cql_common.h"

namespace db { class Board; }

namespace cql {

class Position;

// ------------------------------
// Piece type designators
// ------------------------------
// K white king
// Q white queen
// R white rook
// R white knight
// B white bishop
// P white pawn
// k black king
// q black queen
// r black rook
// r black knight
// b black bishop
// p black pawn
// A any white piece
// a any black piece
// M white major piece
// m black major piece
// I white minor piece
// i black minor piece
// U any piece at all
// . empty square
// ? any piece or an empty square

// Piece_Designator	::= Piece_Type ( Square_Designator )?
// Square_Designator	::= Squares | "[" ( Sequence )? "]"
// Sequence				::= ( Range | Squares ) [ "," Sequence ]
// Range					::= Square "-" Square
// Squares				::= ( Rank | "?" ) ( Fyle | "?" )
// Square				::= Rank Fyle
// Rank					::= "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h"
// Fyle					::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8"

class Designator
{
public:

	typedef bool (*MatchFunc)(cql::Board const& pos, db::Board const& board);
	typedef unsigned (*CountFunc)(cql::Board const& pos, db::Board const& board);
	typedef uint64_t (*FindFunc)(cql::Board const& pos, db::Board const& board);
	typedef unsigned (*DiffFunc)(cql::Board const& pos, db::Board const& p1, db::Board const& p2);
	typedef const int PieceValues[7];

	typedef error::Type Error;

	Designator();

	bool match(db::Board const& board) const;
	unsigned count(db::Board const& board) const;
	uint64_t find(db::Board const& board) const;
	unsigned different(db::Board const& p1, db::Board const& p2) const;
	unsigned same(db::Board const& p1, db::Board const& p2) const;

	uint64_t pieces(db::color::ID color) const;
	uint64_t pieces(db::Board const& board, db::color::ID color) const;
	uint64_t empty() const;

	uint64_t kings(db::color::ID color) const;
	uint64_t queens(db::color::ID color) const;
	uint64_t rooks(db::color::ID color) const;
	uint64_t bishops(db::color::ID color) const;
	uint64_t knights(db::color::ID color) const;
	uint64_t pawns(db::color::ID color) const;

	unsigned powerWhite(db::Board const& board, db::variant::Type variant);
	unsigned powerBlack(db::Board const& board, db::variant::Type variant);

	void flipdiagonal(Position& position) const;
	void flipoffdiagonal(Position& position) const;
	void flipvertical(Position& position) const;
	void fliphorizontal(Position& position) const;
	void flipdihedral(Position& position) const;

	void shifthorizontal(Position& position) const;
	void shiftvertical(Position& position) const;
	void shiftmaindiagonal(Position& position) const;
	void shiftoffdiagonal(Position& position) const;
	void shiftdiagonal(Position& position) const;
	void shift(Position& position) const;

	void flipcolor();
	void flipcolor(Designator& dest) const;

	char const* parse(char const* s, Error& error);
	void finish();

	static unsigned power(db::material::Count m, db::variant::Type variant);
	static int const* pieceValues(db::variant::Type variant);

private:

	typedef uint64_t (*Transform)(uint64_t);
	typedef bool (*Shift)(uint64_t&, int);

	void transform(Position& position, Transform func) const;
	void shift(Position& position, Shift func) const;

	char const* parseSequence(char const* s, Error& error, uint64_t& squares);
	char const* parseRange(char const* s, Error& error, uint64_t& squares);

	cql::Board	m_board;
	MatchFunc	m_match;
	CountFunc	m_count;
	FindFunc		m_find;
	DiffFunc		m_diff;
	DiffFunc		m_same;

	static int const* m_pieceValues[db::variant::NumberOfVariants];
};

} // namespace cql

#include "cql_designator.ipp"

#endif // _cql_designator_defined

// vi:set ts=3 sw=3:
