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
#include "db_guess.h"
#include "db_move.h"

#include "m_utility.h"

using namespace cql;
using namespace cql::move;
using namespace db;
using namespace db::board;


Match::~Match() {}


bool
EnPassant::match(Board const& board, Move const& move, Variant variant)
{
	return move.isEnPassant();
}


bool
NoEnPassant::match(Board const& board, Move const& move, Variant variant)
{
	return !move.isEnPassant();
}


bool
ExchangeEvaluation::match(Board const& board, Move const& move, Variant variant)
{
	int score = board.staticExchangeEvaluator(move, Designator::pieceValues(variant));
	return mstl::is_between(score, m_minScore, m_maxScore);
}


bool
IsCastling::match(Board const& board, Move const& move, Variant variant)
{
	return move.isCastling();
}


bool
NoCastling::match(Board const& board, Move const& move, Variant variant)
{
	return !move.isCastling();
}


bool
MoveEvaluation::match(Board const& board, Move const& move, Variant variant)
{
	M_ASSERT(m_engine);

	float result = m_engine->evaluate(m_mode, m_arg, move);

	if (m_view == SideToMove && board.blackToMove())
		result = -result;

	return m_lower <= result && result <= m_upper;
}


bool
MoveFrom::match(Board const& board, Move const& move, Variant variant)
{
	if (!move.isPieceDrop())
	{
		color::ID	color		= board.sideToMove();
		uint64_t		position	= set1Bit(move.from());

		switch (move.pieceMoved())
		{
			case db::piece::King:	return bool(position & m_designator.kings(color));
			case db::piece::Queen:	return bool(position & m_designator.queens(color));
			case db::piece::Rook:	return bool(position & m_designator.rooks(color));
			case db::piece::Bishop:	return bool(position & m_designator.bishops(color));
			case db::piece::Knight:	return bool(position & m_designator.knights(color));
			case db::piece::Pawn:	return bool(position & m_designator.pawns(color));
			case db::piece::None:	M_ASSERT(!"unexpected");
		}
	}

	return false;
}


bool
MoveTo::match(Board const& board, Move const& move, Variant variant)
{
	if (!move.isPieceDrop())
	{
		uint64_t pos = set1Bit(move.to());

		switch (move.captured())
		{
			case db::piece::King:	return bool(pos & m_designator.kings(board.notToMove()));
			case db::piece::Queen:	return bool(pos & m_designator.queens(board.notToMove()));
			case db::piece::Rook:	return bool(pos & m_designator.rooks(board.notToMove()));
			case db::piece::Bishop:	return bool(pos & m_designator.bishops(board.notToMove()));
			case db::piece::Knight:	return bool(pos & m_designator.knights(board.notToMove()));
			case db::piece::Pawn:	return bool(pos & m_designator.pawns(board.notToMove()));
			case db::piece::None:	return bool(pos & m_designator.empty());
		}
	}

	return false;
}


bool
PieceDrop::match(Board const& board, Move const& move, Variant variant)
{
	M_ASSERT(board.sideToMove() == move.color());

	if (move.isPieceDrop())
	{
		uint64_t		position	= set1Bit(move.to());
		color::ID	color		= board.sideToMove();

		switch (move.capturedOrDropped())
		{
			case db::piece::King:	return bool(position & m_designator.kings(color));
			case db::piece::Queen:	return bool(position & m_designator.queens(color));
			case db::piece::Rook:	return bool(position & m_designator.rooks(color));
			case db::piece::Bishop:	return bool(position & m_designator.bishops(color));
			case db::piece::Knight:	return bool(position & m_designator.knights(color));
			case db::piece::Pawn:	return bool(position & m_designator.pawns(color));
			case db::piece::None:	M_ASSERT(!"unexpected");
		}
	}

	return false;
}


bool
Promote::match(Board const& board, Move const& move, Variant variant)
{
	M_ASSERT(board.sideToMove() == move.color());

	if (move.isPromotion())
	{
		uint64_t		position	= set1Bit(move.to());
		color::ID	color		= board.sideToMove();

		switch (move.promoted())
		{
			case db::piece::King:	return bool(position & m_designator.kings(color));
			case db::piece::Queen:	return bool(position & m_designator.queens(color));
			case db::piece::Rook:	return bool(position & m_designator.rooks(color));
			case db::piece::Bishop:	return bool(position & m_designator.bishops(color));
			case db::piece::Knight:	return bool(position & m_designator.knights(color));
			case db::piece::Pawn:	return bool(position & m_designator.pawns(color));
			case db::piece::None:	M_ASSERT(!"unexpected");
		}
	}

	return false;
}

// vi:set ts=3 sw=3:
