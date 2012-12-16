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

// ======================================================================
// This implementation is loosely based on chessx/src/database/bitboard.h
// ======================================================================

#include "m_utility.h"
#include "m_assert.h"

#include <string.h>

namespace db {

inline Board::Board() {}

inline void Board::Board::clear() { *this = m_emptyBoard; }

inline bool Board::isAttackedBy(unsigned color, Square square) const { return attacks(color, square);}

inline color::ID Board::sideToMove() const		{ return color::ID(m_stm); }
inline color::ID Board::notToMove() const			{ return color::ID(m_stm ^ 1); }

inline bool Board::isEmpty() const					{ return m_hash == 0; }
inline bool Board::isStandardPosition() const	{ return isEqualPosition(m_standardBoard); }
inline bool Board::whiteToMove() const				{ return color::isWhite(sideToMove()); }
inline bool Board::blackToMove() const				{ return color::isBlack(sideToMove()); }

inline Square Board::enPassantSquare() const		{ return m_epSquare; }

inline unsigned Board::halfMoveClock() const		{ return m_halfMoveClock; }
inline unsigned Board::plyNumber() const			{ return m_plyNumber; }
inline unsigned Board::moveNumber() const			{ return mstl::div2(m_plyNumber) + 1; }

inline Signature& Board::signature()											{ return *this; }
inline Signature const& Board::signature() const							{ return *this; }
inline board::Position const& Board::position() const						{ return *this; }
inline board::ExactPosition const& Board::exactPosition() const		{ return *this; }
inline board::UniquePosition const& Board::uniquePosition() const		{ return *this; }
inline material::Count Board::materialCount(color::ID color) const	{ return m_material[color]; }
inline unsigned Board::checksGiven(color::ID color) const				{ return m_checksGiven[color]; }
inline Board::Material Board::holding() const								{ return m_holding[m_stm]; }
inline Board::Material Board::holding(color::ID color) const			{ return m_holding[color]; }

inline uint64_t Board::whitePieces() const				{ return m_occupiedBy[color::White]; }
inline uint64_t Board::blackPieces() const				{ return m_occupiedBy[color::Black]; }
inline uint64_t Board::kings(color::ID side) const		{ return m_occupiedBy[side] & m_kings; }
inline uint64_t Board::queens(color::ID side) const	{ return m_occupiedBy[side] & m_queens; }
inline uint64_t Board::rooks(color::ID side) const		{ return m_occupiedBy[side] & m_rooks; }
inline uint64_t Board::bishops(color::ID side) const	{ return m_occupiedBy[side] & m_bishops; }
inline uint64_t Board::knights(color::ID side) const	{ return m_occupiedBy[side] & m_knights; }
inline uint64_t Board::pawns(color::ID side) const		{ return m_occupiedBy[side] & m_pawns; }
inline uint64_t Board::pieces(color::ID color) const	{ return m_occupiedBy[color]; }
inline uint64_t Board::hash() const							{ return m_hash; }
inline uint64_t Board::pawnHash() const					{ return m_pawnHash; }

inline Board const& Board::standardBoard()				{ return m_standardBoard; }
inline Board const& Board::emptyBoard()					{ return m_emptyBoard; }

inline void Board::setStandardPosition()					{ *this = m_standardBoard; }
inline void Board::destroyCastle(color::ID color)		{ m_castle &= ~castling::bothSides(color); }
inline void Board::setToMove(color::ID color)			{ m_stm = color; }
inline void Board::swapToMove()								{ m_stm ^= 1; }
inline void Board::setPlyNumber(unsigned number)		{ m_plyNumber = number; }
inline void Board::setEnPassantSquare(Square sq)		{ setEnPassantSquare(sideToMove(), sq); }
inline void Board::setEnPassantFyle(sq::Fyle fyle)		{ setEnPassantFyle(sideToMove(), fyle); }


inline
piece::Type
Board::piece(Square s) const
{
	M_ASSERT(s <= sq::h8);
	return piece::Type(m_piece[s]);
}


inline
sq::ID
Board::kingSq(color::ID side) const
{
	M_REQUIRE(kingOnBoard());
	return sq::ID(m_ksq[side]);
}


inline
uint64_t
Board::king(color::ID side) const
{
	M_REQUIRE(kingOnBoard());
	return uint64_t(1) << m_ksq[side];
}


inline
Square
Board::kingSquare(color::ID color) const
{
	M_REQUIRE(kingOnBoard());
	return m_ksq[color];
}


inline
bool
Board::kingOnBoard() const
{
	return kingOnBoard(color::White) && kingOnBoard(color::Black);
}


inline
bool
Board::isInCheck(color::ID color) const
{
	M_REQUIRE(kingOnBoard(color));
	return isAttackedBy(color ^ 1, m_ksq[color]);
}


inline
bool
Board::isInCheck() const
{
	M_REQUIRE(kingOnBoard());
	return isAttackedBy(m_stm ^ 1, m_ksq[m_stm]);
}


inline
bool
Board::isMate(variant::Type variant) const
{
	M_REQUIRE(kingOnBoard());
	return checkState(variant) & Checkmate;
}


inline
bool
Board::givesCheck() const
{
	M_REQUIRE(kingOnBoard(notToMove()));
	return isAttackedBy(m_stm, m_ksq[m_stm ^ 1]);
}


inline
bool
Board::isLegal() const
{
	M_REQUIRE(kingOnBoard(notToMove()));
	return !isAttackedBy(m_stm, m_ksq[m_stm ^ 1]);
}


inline
board::ExactZHPosition const&
Board::exactZHPosition() const
{
	return *this;
}


inline
bool
Board::isUnambiguous(castling::Index castling) const
{
	return m_unambiguous[castling];
}


inline
bool
board::Position::operator==(Position const& position) const
{
	return ::memcmp(this, &position, sizeof(Position)) == 0;
}


inline
bool
board::Position::operator!=(Position const& position) const
{
	return ::memcmp(this, &position, sizeof(Position)) != 0;
}


inline
bool
board::ExactPosition::operator==(ExactPosition const& position) const
{
	return ::memcmp(this, &position, sizeof(ExactPosition)) == 0;
}


inline
bool
board::ExactPosition::operator!=(ExactPosition const& position) const
{
	return ::memcmp(this, &position, sizeof(ExactPosition)) != 0;
}


inline
bool
board::ExactZHPosition::operator==(ExactZHPosition const& position) const
{
	return ::memcmp(this, &position, sizeof(ExactZHPosition)) == 0;
}


inline
bool
board::ExactZHPosition::operator!=(ExactZHPosition const& position) const
{
	return ::memcmp(this, &position, sizeof(ExactZHPosition)) != 0;
}


inline
Move
Board::makeNullMove() const
{
	Move m(Move::null());
	m.setColor(m_stm);
	return m;
}


inline
Move
Board::makeMove(uint16_t move) const
{
	if (move == 0)
		return Move::null();

	Move m(move);
	return makeMove(m.from(), m.to(), m.promoted());
}


inline
Square
Board::castlingRookSquare(castling::Index index) const
{
	return m_castleRookAtStart[index];
}


inline
bool
Board::enPassantMoveExists(Byte color) const
{
	return m_epSquare != sq::Null;
}


inline
void
Board::prepareUndo(Move& move) const
{
	move.setUndo(m_halfMoveClock, m_epSquare, m_epSquare != sq::Null, m_castle, m_capturePromoted);
}


inline
bool
Board::canCastle(color::ID color) const
{
	return m_castle & castling::bothSides(color);
}


inline
bool
Board::canCastleShort(color::ID color) const
{
	return m_castle & castling::kingSide(color);
}


inline
bool
Board::canCastleLong(color::ID color) const
{
	return m_castle & castling::queenSide(color);
}


inline
castling::Rights
Board::castlingRights() const
{
	return castling::Rights(m_castle);
}


inline
castling::Rights
Board::castlingRights(color::ID color) const
{
	return castling::Rights(m_castle & castling::bothSides(color));
}


inline
unsigned
Board::countPieces(color::ID color) const
{
	Material const& m = m_material[color];
	return m.queen + m.rook + m.bishop + m.knight + 1;
}


inline
Move
Board::parseMove(char const* algebraic, variant::Type variant, move::Constraint flag) const
{
	Move m;
	return parseMove(algebraic, m, variant, flag) ? m : Move::empty();
}


inline
Move
Board::parseLAN(char const* algebraic, move::Constraint flag) const
{
	Move m;
	return parseLAN(algebraic, m, flag) ? m : Move::empty();
}


inline
Move
Board::setMoveColor(Move move) const
{
	move.setColor(m_stm);
	return move;
}


inline
Move
Board::setLegalMove(Move move) const
{
	move.setLegalMove();
	return move;
}


inline
bool
Board::shortCastlingIsLegal() const
{
	return whiteToMove() ? shortCastlingWhiteIsLegal() : shortCastlingBlackIsLegal();
}


inline
bool
Board::longCastlingIsLegal() const
{
	return whiteToMove() ? longCastlingWhiteIsLegal() : longCastlingBlackIsLegal();
}


inline
bool
Board::shortCastlingIsPossible() const
{
	return whiteToMove() ? shortCastlingWhiteIsPossible() : shortCastlingBlackIsPossible();
}


inline
bool
Board::longCastlingIsPossible() const
{
	return whiteToMove() ? longCastlingWhiteIsPossible() : longCastlingBlackIsPossible();
}


inline
bool
Board::gameIsOver(variant::Type variant) const
{
	return bool(checkState(variant) & (Checkmate | ThreeChecks | Stalemate | Losing));
}

} // namespace db

// vi:set ts=3 sw=3:
