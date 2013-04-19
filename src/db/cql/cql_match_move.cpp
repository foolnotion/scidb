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

#include "cql_match_move.h"
#include "cql_designator.h"

#include "db_board.h"
#include "db_board_base.h"
#include "db_move.h"

using namespace cql;
using namespace cql::move;
using namespace db;
using namespace db::board;


Match::~Match() {}


bool
EnPassant::match(Board const& board, Move const& move)
{
	return move.isEnPassant();
}


bool
NoEnPassant::match(Board const& board, Move const& move)
{
	return !move.isEnPassant();
}


bool
IsCastling::match(Board const& board, Move const& move)
{
	return move.isCastling();
}


bool
MoveFrom::match(Board const& board, Move const& move)
{
	if (!move.isPieceDrop())
	{
		color::ID	color		= board.sideToMove();
		uint64_t		position	= setBit(move.from());

		switch (move.pieceMoved())
		{
			case piece::King:		return bool(position & m_designator.kings(color));
			case piece::Queen:	return bool(position & m_designator.queens(color));
			case piece::Rook:		return bool(position & m_designator.rooks(color));
			case piece::Bishop:	return bool(position & m_designator.bishops(color));
			case piece::Knight:	return bool(position & m_designator.knights(color));
			case piece::Pawn:		return bool(position & m_designator.pawns(color));
			case piece::None:		M_ASSERT(!"unexpected");
		}
	}

	return false;
}


bool
MoveTo::match(Board const& board, Move const& move)
{
	if (!move.isPieceDrop())
	{
		uint64_t pos = setBit(move.to());

		switch (move.captured())
		{
			case piece::King:		return bool(pos & m_designator.kings(board.notToMove()));
			case piece::Queen:	return bool(pos & m_designator.queens(board.notToMove()));
			case piece::Rook:		return bool(pos & m_designator.rooks(board.notToMove()));
			case piece::Bishop:	return bool(pos & m_designator.bishops(board.notToMove()));
			case piece::Knight:	return bool(pos & m_designator.knights(board.notToMove()));
			case piece::Pawn:		return bool(pos & m_designator.pawns(board.notToMove()));
			case piece::None:		return bool(pos & m_designator.empty());
		}
	}

	return false;
}


bool
PieceDrop::match(Board const& board, Move const& move)
{
	M_ASSERT(board.sideToMove() == move.color());

	if (move.isPieceDrop())
	{
		uint64_t		position	= setBit(move.to());
		color::ID	color		= board.sideToMove();

		switch (move.capturedOrDropped())
		{
			case piece::King:		return bool(position & m_designator.kings(color));
			case piece::Queen:	return bool(position & m_designator.queens(color));
			case piece::Rook:		return bool(position & m_designator.rooks(color));
			case piece::Bishop:	return bool(position & m_designator.bishops(color));
			case piece::Knight:	return bool(position & m_designator.knights(color));
			case piece::Pawn:		return bool(position & m_designator.pawns(color));
			case piece::None:		M_ASSERT(!"unexpected");
		}
	}

	return false;
}


bool
Promote::match(Board const& board, Move const& move)
{
	if (move.isPromotion())
	{
		uint64_t		position	= setBit(move.to());
		color::ID	color		= board.sideToMove();

		switch (move.promoted())
		{
			case piece::King:		return bool(position & m_designator.kings(color));
			case piece::Queen:	return bool(position & m_designator.queens(color));
			case piece::Rook:		return bool(position & m_designator.rooks(color));
			case piece::Bishop:	return bool(position & m_designator.bishops(color));
			case piece::Knight:	return bool(position & m_designator.knights(color));
			case piece::Pawn:		return bool(position & m_designator.pawns(color));
			case piece::None:		M_ASSERT(!"unexpected");
		}
	}

	return false;
}

// vi:set ts=3 sw=3:
