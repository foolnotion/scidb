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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

// ======================================================================
// The implementation is loosely based on chessx/src/database/bitboard.cpp
//   (C) 2003 Sune Fischer
//   (C) 2005-2006 Marius Roets <roets.marius@gmail.com>
//   (C) 2005-2009 Michal Rudolf <mrudolf@kdewebdev.org>
// ======================================================================

#include "db_board.h"
#include "db_board_base.h"
#include "db_rand64.h"

#include "m_assert.h"
#include "m_bitfield.h"
#include "m_bit_functions.h"
#include "m_utility.h"
#include "m_stdio.h"

#ifdef CHECK_HASH_KEYS
# include "m_set.h"
#endif

#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <assert.h>

using namespace db;
using namespace db::sq;
using namespace db::color;
using namespace db::castling;
using namespace db::board;

namespace bf = mstl::bf;

#define LittleGame_Hash         UINT64_C(0x7bda5dadc845e3c6)
#define PawnsOn4thRank_Hash     UINT64_C(0x6741bdb0888a7d57)
#define Pyramid_Hash            UINT64_C(0x4bbf887a20755e7a)
#define KNNvsKP_Hash            UINT64_C(0xdcc896ced83a7ce4)
#define PawnsOnly_Hash          UINT64_C(0x3a4fd07c22f6a534)
#define KnightsOnly_Hash        UINT64_C(0x5dbe5ac131c561aa)
#define BishopsOnly_Hash        UINT64_C(0x41041e489635398e)
#define RooksOnly_Hash          UINT64_C(0x8f19a07fef9c6f66)
#define QueensOnly_Hash         UINT64_C(0x45537041bf95eb96)
#define NoQueens_Hash           UINT64_C(0x93a3e4f6486c3742)
#define WildFive_Hash           UINT64_C(0xe2272812749517d8)
#define KBNK_Hash               UINT64_C(0xa2f3dcd8a1b6ffed)
#define KBBK_Hash               UINT64_C(0x51be7cba98acb392)
#define Runaway_Hash            UINT64_C(0x548d1ba18e63df59)
#define QueenVsRooks_Hash       UINT64_C(0x0a4301a374bff9ae)
#define UpsideDown_Hash         UINT64_C(0xcfa9f03a9b87134d)

static uint64_t const DarkSquares	= A1 | C1 | E1 | G1
												| B2 | D2 | F2 | H2
												| A3 | C3 | E3 | G3
												| B4 | D4 | F4 | H4
												| A5 | C5 | E5 | G5
												| B6 | D6 | F6 | H6
												| A7 | C7 | E7 | G7
												| B8 | D8 | F8 | H8;

static uint64_t const LiteSquares	= B1 | D1 | F1 | H1
												| A2 | C2 | E2 | G2
												| B3 | D3 | F3 | H3
												| A4 | C4 | E4 | G4
												| B5 | D5 | F5 | G5
												| A6 | C6 | E6 | G6
												| B7 | D7 | F7 | H7
												| A8 | C8 | E8 | G8;

Board Board::m_standardBoard;
Board Board::m_antichessBoard;
Board Board::m_shuffleChessBoard;
Board Board::m_littleGame;
Board Board::m_pawnsOn4thRank;
Board Board::m_pyramid;
Board Board::m_KNNvsKP;
Board Board::m_pawnsOnly;
Board Board::m_knightsOnly;
Board Board::m_bishopsOnly;
Board Board::m_rooksOnly;
Board Board::m_queensOnly;
Board Board::m_noQueens;
Board Board::m_wildFive;
Board Board::m_kbnk;
Board Board::m_kbbk;
Board Board::m_runaway;
Board Board::m_queenVsRooks;
Board Board::m_upsideDown;
Board Board::m_emptyBoard;

static material::Count m_initialHolding;


inline static int mul8(int x)					{ return x << 3; }
inline static int mul16(int x)				{ return x << 4; }

inline static unsigned mul4(unsigned x)	{ return x << 2; }
inline static unsigned mul64(unsigned x)	{ return x << 6; }

inline static int fyle(int s) 				{ return s & 7; }
inline static int rank(int s) 				{ return s >> 3; }

inline static bool isFyle(char c)			{ return c >= 'a' && c <= 'h'; }
inline static bool isRank(char c)			{ return c >= '1' && c <= '8'; }

inline static char toFyle(char fyle)		{ return fyle - 'a'; }
inline static char toFYLE(char fyle)		{ return fyle - 'A'; }
inline static char toRank(char rank)		{ return rank - '1'; }

inline static unsigned flipRank(unsigned s)		{ return flipRank(sq::ID(s)); }

inline static Byte kingSideIndex(Byte color)		{ return castling::kingSideIndex(color::ID(color)); }
inline static Byte queenSideIndex(Byte color)	{ return castling::queenSideIndex(color::ID(color)); }


static void __attribute__((constructor)) initialize() { Board::initialize(); }


template <typename T>
inline static
T
flipFyle(T s)
{
	if (s == Null)
		return Null;

	return flipFyle(sq::ID(s));
}


inline
static piece::ID
toPiece(Byte type, Byte color)
{
	return piece::piece(piece::Type(type), color::ID(color));
}


inline
static uint64_t
epSquareHashKey(Square s)
{
	return rand64::EnPassant[s - (rank(s) == Rank3 ? a3 : a6)];
}


static char const*
skipPromotion(char const* s)
{
	char const* t = s;

	// skip promotion as in bc8Q, bxc8=Q, bxc8=(Q), bxc8(Q), bxc8/Q, or bxc8/(Q)

	if (*t == '=' || *t == '/')
		++s;

	char match = '\0';

	if (*t == '(')
	{
		match = ')';
		++t;
	}

	switch (::toupper(*t))
	{
		case 'Q': case 'R': case 'B': case 'N': ++t; break;
		default: return s;
	}

	if (match)
	{
		if (*t != match)
			return s;

		++t;
	}

	return t;
}


static uint64_t
transpose(uint64_t bf)
{
	uint64_t result	= bf;
	uint8_t* ranks		= reinterpret_cast<uint8_t*>(&result);

	ranks[0] = mstl::bf::reverse(ranks[0]);
	ranks[1] = mstl::bf::reverse(ranks[1]);
	ranks[2] = mstl::bf::reverse(ranks[2]);
	ranks[3] = mstl::bf::reverse(ranks[3]);
	ranks[4] = mstl::bf::reverse(ranks[4]);
	ranks[5] = mstl::bf::reverse(ranks[5]);
	ranks[6] = mstl::bf::reverse(ranks[6]);
	ranks[7] = mstl::bf::reverse(ranks[7]);

	return result;
}


uint64_t Board::knightAttacks(Square square) const	{ return KnightAttacks[square]; }
uint64_t Board::kingAttacks(Square square) const	{ return KingAttacks[square]; }


uint64_t
Board::rankAttacks(Square square, uint64_t occupied) const
{
	return RankAttacks[square][(occupied >> ((square & ~7) | 1)) & 63];
}


uint64_t
Board::fyleAttacks(Square square, uint64_t occupied) const
{
	return FyleAttacks[square][(occupied >> (((square & 7) << 3) | 1)) & 63];
}


uint64_t
Board::rankAttacks(Square square) const
{
	return rankAttacks(square, m_occupied);
}


uint64_t
Board::fyleAttacks(Square square) const
{
	return fyleAttacks(square, m_occupiedL90);
}


uint64_t
Board::diagA1H8Attacks(Square square) const
{
	return R45Attacks[square][(m_occupiedR45 >> ShiftR45[square]) & 63];
}


uint64_t
Board::diagH1A8Attacks(Square square) const
{
	return L45Attacks[square][(m_occupiedL45 >> ShiftL45[square]) & 63];
}


uint64_t
Board::bishopAttacks(Square square) const
{
	return diagA1H8Attacks(square) | diagH1A8Attacks(square);
}


uint64_t
Board::rookAttacks(Square square) const
{
	return rankAttacks(square) | fyleAttacks(square);
}


uint64_t
Board::queenAttacks(Square square) const
{
	return rookAttacks(square) | bishopAttacks(square);
}


uint64_t
Board::attacks(unsigned color, Square square) const
{
	uint64_t attackers =   (PawnAttacks[color ^ 1][square] & m_pawns)
								| (knightAttacks(square) & m_knights)
								| (bishopAttacks(square) & (m_bishops | m_queens))
								| (rookAttacks(square) & (m_rooks | m_queens))
								| (kingAttacks(square) & m_kings);

	return attackers & m_occupiedBy[color];
}


bool
Board::isAttackedBy(unsigned color, uint64_t squares) const
{
	while (squares)
	{
		if (isAttackedBy(color, Square(lsbClear(squares))))
			return true;
	}

	return false;
}


void
Board::pawnProgressMove(unsigned color, unsigned from, unsigned to)
{
	if (color == White)
		m_progress.side[White].move(from, to);
	else
		m_progress.side[Black].move(::flipRank(from), ::flipRank(to));
}


void
Board::pawnProgressRemove(unsigned color, unsigned at)
{
	if (color == White)
		m_progress.side[White].remove(at);
	else
		m_progress.side[Black].remove(::flipRank(at));
}


void
Board::pawnProgressAdd(unsigned color, unsigned at)
{
	if (color == White)
		m_progress.side[White].add(at);
	else
		m_progress.side[Black].add(::flipRank(at));
}


unsigned
Board::checkState(Move const& move, variant::Type variant) const
{
	Board peek(*this);
	peek.doMove(move, variant);
	return peek.checkState(variant);
}


bool
Board::isDoubleCheck() const
{
	M_REQUIRE(kingOnBoard());
	return count(attacks(m_stm ^ 1, m_ksq[m_stm])) > 1;
}


bool
Board::isSamePosition(Board const& target) const
{
	return ::memcmp(&target, this, sizeof(board::Position)) == 0;
}


bool
Board::isEqualPosition(Board const& target) const
{
	// NOTE: we cannot use ExactZHPosition, because the fen is not supporting pieces in hand
	// NOTE: do not use for Three-check Chess games
	return m_hash == target.m_hash && target.exactPosition() == exactPosition();
}


bool
Board::isEqualZHPosition(Board const& target) const
{
	return m_hash == target.m_hash && target.exactZHPosition() == exactZHPosition();
}


void
Board::hashPawn(Square s, piece::ID piece)
{
	M_ASSERT(piece::type(piece) == piece::Pawn);
	M_ASSERT(s <= sq::h8);

	uint64_t value = rand64::Pieces[::mul64(piece) + s];

	m_hash ^= value;
	m_pawnHash ^= value;
}


void
Board::hashPawn(Square s, Square t, piece::ID piece)
{
	M_ASSERT(piece::type(piece) == piece::Pawn);
	M_ASSERT(s <= sq::h8);
	M_ASSERT(t <= sq::h8);

	unsigned index = ::mul64(piece);
	uint64_t value = rand64::Pieces[index + s] ^ rand64::Pieces[index + t];

	m_hash ^= value;
	m_pawnHash ^= value;
}


void
Board::hashPiece(Square s, piece::ID piece)
{
	M_ASSERT(piece::type(piece) != piece::None);
	M_ASSERT(piece::type(piece) != piece::Pawn);
	M_ASSERT(s <= sq::h8);

	m_hash ^= rand64::Pieces[::mul64(piece) + s];
}


void
Board::hashPiece(Square s, Square t, piece::ID piece)
{
	M_ASSERT(piece::type(piece) != piece::None);
	M_ASSERT(piece::type(piece) != piece::Pawn);
	M_ASSERT(s <= sq::h8);
	M_ASSERT(t <= sq::h8);

	unsigned index = ::mul64(piece);

	m_hash ^= rand64::Pieces[index + s];
	m_hash ^= rand64::Pieces[index + t];
}


void
Board::hashPromotedPiece(Square s, piece::ID piece, variant::Type variant)
{
	M_ASSERT(piece::type(piece) != piece::None);
	M_ASSERT(piece::type(piece) != piece::Pawn);
	M_ASSERT(piece::type(piece) != piece::King);
	M_ASSERT(s <= sq::h8);

	if (variant::isZhouse(variant))
		m_hash ^= rand64::Promoted[::mul64(piece) + s];
	else
		hashPiece(s, piece);
}


void
Board::hashCastling(Index right)
{
	M_ASSERT(m_castleRookAtStart[right] != Null);
	M_ASSERT(rank(m_castleRookAtStart[right]) == Rank1 || rank(m_castleRookAtStart[right]) == Rank8);

	m_hash ^= rand64::Castling[right];

// we don't want to hash the castling rook square
//	m_hash ^= rand64::CastlingRook[m_castleRookAtStart[right]];
}


void Board::hashCastlingKingside(color::ID color)	{ hashCastling(kingSideIndex(color)); }
void Board::hashCastlingQueenside(color::ID color)	{ hashCastling(queenSideIndex(color)); }
void Board::hashToMove()									{ m_hash ^= *rand64::ToMove; }


void
Board::hashCastling(color::ID color)
{
	if (canCastleShort(color))
		hashCastlingKingside(color);
	if (canCastleLong(color))
		hashCastlingQueenside(color);
}


void
Board::hashChecksGiven(color::ID color, unsigned n)
{
	M_ASSERT(n < 3);

	uint64_t const* arr = rand64::ChecksGiven + ::mul4(color);

	if (n)
		m_hash ^= arr[n];

	m_hash ^= arr[n + 1];
}


void
Board::hashChecksGiven(unsigned white, unsigned black)
{
	M_ASSERT(white <= 3);
	M_ASSERT(black <= 3);

	if (white) m_hash ^= rand64::ChecksGiven[::mul4(White) + white];
	if (black) m_hash ^= rand64::ChecksGiven[::mul4(Black) + black];
}


void
Board::hashHolding(piece::ID piece, Byte count)
{
	M_ASSERT(piece != piece::Empty);
	M_ASSERT(piece::type(piece) != piece::King);
	M_ASSERT(count <= 8);

	if (count)
		m_hash ^= mstl::bf::rotate_left(rand64::Holding[piece], count - 1);
}


void
Board::hashHoldingChanged(piece::ID piece, Byte count)
{
	M_ASSERT(piece != piece::Empty);
	M_ASSERT(piece::type(piece) != piece::King);
	M_ASSERT(count <= 8);

	// NOTE: count is old count if one piece is added to holding
	// NOTE: count is new count if one piece is removed from holding

	if (count)
	{
		m_hash ^= mstl::bf::rotate_left(rand64::Holding[piece], count - 1);
		m_hash ^= mstl::bf::rotate_left(rand64::Holding[piece], count);
	}
	else
	{
		m_hash ^= mstl::bf::rotate_left(rand64::Holding[piece], count - 1);
	}
}


namespace db { // GCC will not compile without explicit namespace

template <>
inline
void
Board::incrMaterial<piece::Pawn>(unsigned color)
{
	m_matSig.part[color].pawn = (1 << ++m_material[color].pawn) - 1;
}


template <>
inline
void
Board::incrMaterial<piece::Knight>(unsigned color)
{
	m_matSig.part[color].knight = (1 << ++m_material[color].knight) - 1;
}


template <>
inline
void
Board::incrMaterial<piece::Bishop>(unsigned color)
{
	m_matSig.part[color].bishop = (1 << ++m_material[color].bishop) - 1;
}


template <>
inline
void
Board::incrMaterial<piece::Rook>(unsigned color)
{
	m_matSig.part[color].rook = (1 << ++m_material[color].rook) - 1;
}


template <>
inline
void
Board::incrMaterial<piece::Queen>(unsigned color)
{
	m_matSig.part[color].queen = (1 << ++m_material[color].queen) - 1;
}


template <>
inline
void
Board::incrMaterial<piece::King>(unsigned color)
{
	(color == White ? m_whiteKing : m_blackKing) = (1 << ++m_material[color].king) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::Pawn>(unsigned color)
{
	m_matSig.part[color].pawn = (1 << --m_material[color].pawn) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::Knight>(unsigned color)
{
	m_matSig.part[color].knight = (1 << --m_material[color].knight) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::Bishop>(unsigned color)
{
	m_matSig.part[color].bishop = (1 << --m_material[color].bishop) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::Rook>(unsigned color)
{
	m_matSig.part[color].rook = (1 << --m_material[color].rook) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::Queen>(unsigned color)
{
	m_matSig.part[color].queen = (1 << --m_material[color].queen) - 1;
}


template <>
inline
void
Board::decrMaterial<piece::King>(unsigned color)
{
	(color == White ? m_whiteKing : m_blackKing) = (1 << --m_material[color].king) - 1;
}


template <>
inline
void
Board::addToMyHolding<piece::Pawn>(variant::Type variant, unsigned color)
{
// catch GCC bug:
// "internal compiler error: in expand_expr_addr_expr_1, at expr.c:7597"
#if __GNUC_PREREQ(4,5)
	hashHoldingChanged(::toPiece(piece::Pawn, color), m_holding[color].pawn);
	++m_holding[color].pawn;
#else
	hashHoldingChanged(::toPiece(piece::Pawn, color), m_holding[color].pawn++);
#endif
}


template <>
inline
void
Board::addToMyHolding<piece::Knight>(variant::Type variant, unsigned color)
{
// catch GCC bug:
// "internal compiler error: in expand_expr_addr_expr_1, at expr.c:7597"
#if __GNUC_PREREQ(4,5)
	hashHoldingChanged(::toPiece(piece::Knight, color), m_holding[color].knight);
	++m_holding[color].knight;
#else
	hashHoldingChanged(::toPiece(piece::Knight, color), m_holding[color].knight++);
#endif
}


template <>
inline
void
Board::addToMyHolding<piece::Bishop>(variant::Type variant, unsigned color)
{
// catch GCC bug:
// "internal compiler error: in expand_expr_addr_expr_1, at expr.c:7597"
#if __GNUC_PREREQ(4,5)
	hashHoldingChanged(::toPiece(piece::Bishop, color), m_holding[color].bishop);
	++m_holding[color].bishop;
#else
	hashHoldingChanged(::toPiece(piece::Bishop, color), m_holding[color].bishop++);
#endif
}


template <>
inline
void
Board::addToMyHolding<piece::Rook>(variant::Type variant, unsigned color)
{
// catch GCC bug:
// "internal compiler error: in expand_expr_addr_expr_1, at expr.c:7597"
#if __GNUC_PREREQ(4,5)
	hashHoldingChanged(::toPiece(piece::Rook, color), m_holding[color].rook);
	++m_holding[color].rook;
#else
	hashHoldingChanged(::toPiece(piece::Rook, color), m_holding[color].rook++);
#endif
}


template <>
inline
void
Board::addToMyHolding<piece::Queen>(variant::Type variant, unsigned color)
{
// catch GCC bug:
// "internal compiler error: in expand_expr_addr_expr_1, at expr.c:7597"
#if __GNUC_PREREQ(4,5)
	hashHoldingChanged(::toPiece(piece::Queen, color), m_holding[color].queen);
	++m_holding[color].queen;
#else
	hashHoldingChanged(::toPiece(piece::Queen, color), m_holding[color].queen++);
#endif
}


template <>
inline
void
Board::addToHolding<piece::Pawn>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	addToMyHolding<piece::Pawn>(variant, color);
}


template <>
inline
void
Board::addToHolding<piece::Knight>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	addToMyHolding<piece::Knight>(variant, color);
}


template <>
inline
void
Board::addToHolding<piece::Bishop>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	addToMyHolding<piece::Bishop>(variant, color);
}


template <>
inline
void
Board::addToHolding<piece::Rook>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	addToMyHolding<piece::Rook>(variant, color);
}


template <>
inline
void
Board::addToHolding<piece::Queen>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	addToMyHolding<piece::Queen>(variant, color);
}


template <>
inline
void
Board::removeFromMyHolding<piece::Pawn>(variant::Type variant, unsigned color)
{
	M_ASSERT(m_holding[color].pawn > 0);
	hashHoldingChanged(::toPiece(piece::Pawn, color), --m_holding[color].pawn);
}


template <>
inline
void
Board::removeFromMyHolding<piece::Knight>(variant::Type variant, unsigned color)
{
	M_ASSERT(m_holding[color].knight > 0);
	hashHoldingChanged(::toPiece(piece::Knight, color), --m_holding[color].knight);
}


template <>
inline
void
Board::removeFromMyHolding<piece::Bishop>(variant::Type variant, unsigned color)
{
	M_ASSERT(m_holding[color].bishop > 0);
	hashHoldingChanged(::toPiece(piece::Bishop, color), --m_holding[color].bishop);
}


template <>
inline
void
Board::removeFromMyHolding<piece::Rook>(variant::Type variant, unsigned color)
{
	M_ASSERT(m_holding[color].rook > 0);
	hashHoldingChanged(::toPiece(piece::Rook, color), --m_holding[color].rook);
}


template <>
inline
void
Board::removeFromMyHolding<piece::Queen>(variant::Type variant, unsigned color)
{
	M_ASSERT(m_holding[color].queen > 0);
	hashHoldingChanged(::toPiece(piece::Queen, color), --m_holding[color].queen);
}


template <>
inline
void
Board::removeFromHolding<piece::Pawn>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	removeFromMyHolding<piece::Pawn>(variant, color);
}


template <>
inline
void
Board::removeFromHolding<piece::Knight>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	removeFromMyHolding<piece::Knight>(variant, color);
}


template <>
inline
void
Board::removeFromHolding<piece::Bishop>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	removeFromMyHolding<piece::Bishop>(variant, color);
}


template <>
inline
void
Board::removeFromHolding<piece::Rook>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	removeFromMyHolding<piece::Rook>(variant, color);
}


template <>
inline
void
Board::removeFromHolding<piece::Queen>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;
	removeFromMyHolding<piece::Queen>(variant, color);
}


template <piece::Type Piece>
inline
void
Board::addToHolding(uint64_t toMask, variant::Type variant, unsigned color)
{
	static_assert(Piece != piece::Pawn, "do not use for pawns");

	if (m_promoted[color] & toMask)
	{
		m_promoted[color] ^= toMask;
		m_partner->m_capturePromoted = true;
		m_partner->addToHolding<piece::Pawn>(variant, color);
	}
	else
	{
		m_partner->addToHolding<Piece>(variant, color);
	}
}


template <piece::Type Piece>
inline
void
Board::removeFromHolding(uint64_t fromMask, variant::Type variant, unsigned color)
{
	static_assert(Piece != piece::Pawn, "do not use for pawns");

	if (m_capturePromoted)
	{
		m_partner->m_promoted[color] ^= fromMask;
		m_partner->removeFromHolding<piece::Pawn>(variant, color);
	}
	else
	{
		m_partner->removeFromHolding<Piece>(variant, color);
	}
}


template <>
inline
void
Board::possiblyRemoveFromHolding<piece::Pawn>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;

	if (m_holding[color].pawn > 0)
		hashHoldingChanged(::toPiece(piece::Pawn, color), --m_holding[color].pawn);
}


template <>
inline
void
Board::possiblyRemoveFromHolding<piece::Knight>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;

	if (m_holding[color].knight > 0)
		hashHoldingChanged(::toPiece(piece::Knight, color), --m_holding[color].knight);
}


template <>
inline
void
Board::possiblyRemoveFromHolding<piece::Bishop>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;

	if (m_holding[color].bishop > 0)
		hashHoldingChanged(::toPiece(piece::Bishop, color), --m_holding[color].bishop);
}


template <>
inline
void
Board::possiblyRemoveFromHolding<piece::Rook>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;

	if (m_holding[color].rook > 0)
		hashHoldingChanged(::toPiece(piece::Rook, color), --m_holding[color].rook);
}


template <>
inline
void
Board::possiblyRemoveFromHolding<piece::Queen>(variant::Type variant, unsigned color)
{
	if (variant == variant::Crazyhouse)
		color ^= 1;

	if (m_holding[color].queen > 0)
		hashHoldingChanged(::toPiece(piece::Queen, color), --m_holding[color].queen);
}

} // namespace db


void
Board::hashEnPassant()
{
	M_ASSERT(m_epSquare != Null);
	m_hash ^= ::epSquareHashKey(m_epSquare);
}


bool
Board::kingOnBoard(color::ID color) const
{
	return (m_kings & m_occupiedBy[color]) == set1Bit(m_ksq[color]);
}


unsigned
Board::countChecks() const
{
	return count(attacks(m_stm ^ 1, m_ksq[m_stm]));
}


bool
Board::isIntoCheck(Move const& move, variant::Type variant) const
{
	M_REQUIRE(move);

	if (move.isNull())
		return false;

	Board peek(*this);
	peek.doMove(move, variant);
	return peek.givesCheck();
}


bool
Board::checkContactCheck() const
{
	// IMPORTANT NOTE: this function assumes that a check, but no double check, is given!

	sq::ID ksq = sq::ID(m_ksq[m_stm]);

	// a pawn is always giving contact check
	if (count(PawnAttacks[m_stm][ksq] & m_pawns))
		return true;

	// a knight is always giving contact check
	if (count(knightAttacks(ksq) & m_knights))
		return true;

	uint64_t attacks;

	attacks = rankAttacks(ksq) & (m_rooks | m_queens);

	if (attacks && sq::fyleDistance(sq::ID(lsb(attacks)), ksq) == 1)
		return true;

	attacks = fyleAttacks(ksq) & (m_rooks | m_queens);

	if (attacks && sq::rankDistance(sq::ID(lsb(attacks)), ksq) == 1)
		return true;

	attacks = bishopAttacks(ksq) & (m_bishops | m_queens);

	if (attacks)
	{
		sq::ID sq = sq::ID(lsb(attacks));

		if (sq::rankDistance(sq, ksq) + sq::fyleDistance(sq, ksq) == 2)
			return true;
	}

	return false;
}


bool
Board::isContactCheck() const
{
	if (!isInCheck())
		return false;

	sq::ID ksq = sq::ID(m_ksq[m_stm]);

	// a pawn is always giving contact check
	if (count(PawnAttacks[m_stm][ksq] & m_pawns))
		return true;

	// a knight is always giving contact check
	if (count(knightAttacks(ksq) & m_knights))
		return true;

	uint64_t attacks;

	attacks = rankAttacks(ksq) & (m_rooks | m_queens);

	while (attacks)
	{
		if (sq::rankDistance(sq::ID(lsbClear(attacks)), ksq) == 1)
			return true;
	}

	attacks = bishopAttacks(ksq) & (m_bishops | m_queens);

	while (attacks)
	{
		sq::ID sq = sq::ID(lsbClear(attacks));

		if (sq::rankDistance(sq, ksq) + sq::fyleDistance(sq, ksq) == 2)
			return true;
	}

	return false;
}


bool
Board::isUnblockableCheck(Move const& move, variant::Type variant) const
{
	Board peek(*this);
	peek.doMove(move, variant);

	if (peek.countChecks() > 1)
		return true; // double check is like a contact check

	return peek.isContactCheck();
}


bool
Board::checkNotBlockableWithPawn() const
{
	// IMPORTANT NOTE: this function assumes that no double check is given!
	return rankAttacks(m_ksq[m_stm]) & (m_rooks | m_queens) & (RankMask1 | RankMask8);
}


unsigned
Board::checkState(variant::Type variant) const
{
	unsigned state = NoCheck;

	if (variant::isAntichessExceptLosers(variant))
	{
		if (m_material[m_stm].total() == 0)
			state |= Losing;
		else if (!findAnyLegalMove(variant))
			state |= Stalemate;
	}
	else
	{
		M_ASSERT(kingOnBoard());

		if (variant == variant::Losers && m_material[m_stm].total() == 1)
			state |= Losing;

		switch (countChecks())
		{
			case 0:  break;
			case 1:  state |= Check; break;
			default: state |= Check | DoubleCheck; break;
		}

		if (m_checksGiven[m_stm ^ 1] >= 3)
			return state |= ThreeChecks;

		if (findAnyLegalMove(variant))
			return state;

		switch (variant)
		{
			case variant::Bughouse:
				if ((state & DoubleCheck) || ((state & Check) && checkContactCheck()))
					state |= Checkmate;
				break;

			case variant::Crazyhouse:
				if (state & DoubleCheck)
				{
					state |= Checkmate;
				}
				else if (state & Check)
				{
					if (	m_holding[m_stm].total() == 0
						|| (m_holding[m_stm].pieces() == 0 && checkNotBlockableWithPawn())
						|| checkContactCheck())
					{
						state |= Checkmate;
					}
				}
				else if (m_holding[m_stm].total() == 0)
				{
					state |= Stalemate;
				}
				break;

			default:
				state |= (state & Check) ? Checkmate : Stalemate;
				break;
		}
	}

	return state;
}


board::Status
Board::status(variant::Type variant) const
{
	unsigned state = checkState(variant);

	if (state & Losing)
		return board::Losing;
	if (state & Checkmate)
		return board::Checkmate;
	if (state & Stalemate)
		return board::Stalemate;
	if (state & ThreeChecks)
		return board::ThreeChecks;

	return board::None;
}


void
Board::swapToMove()
{
	m_stm ^= 1;
	hashToMove();
}


uint64_t
Board::hashNoEP() const
{
	return m_epSquare == Null ? m_hash : m_hash ^ ::epSquareHashKey(m_epSquare);
}


void
Board::setEnPassantSquare(color::ID color, Square sq)
{
	M_REQUIRE(sq != sq::Null);

// we don't want this check here
//	M_REQUIRE(sq::rank(sq) == (color::isWhite(color) ? sq::Rank6 : sq::Rank3));

	if (m_epSquare != sq::Null)
		hashEnPassant();

	if (PawnAttacks[color ^ 1][sq] & m_occupiedBy[color] & m_pawns)
	{
		m_epSquare = sq;
		hashEnPassant();
	}
	else
	{
		m_epSquare = Null;
	}
}


void
Board::setEnPassantSquare(Square sq)
{
	if (sq == Null)
	{
		if (m_epSquare != sq::Null)
			hashEnPassant();

		m_epSquare = Null;
	}
	else
	{
		setEnPassantSquare(sideToMove(), sq);
	}
}


Board::Board(Board const& board)
{
	::memcpy(this, &board, sizeof(board));
	m_partner = this;
}


Board&
Board::operator=(Board const& board)
{
	if (this != &board)
	{
		::memcpy(this, &board, sizeof(board));
		m_partner = this;
	}
	return *this;
}


void
Board::setEnPassantFyle(color::ID color, Fyle fyle)
{
	setEnPassantSquare(color, sq::make(fyle, EpRank[color]));
}


void
Board::removeIllegalFrom(Move move, uint64_t& b, variant::Type variant) const
{
	typedef mstl::bitfield<uint64_t> BitField;

	BitField squares(b);

	for (unsigned sq = squares.find_first(); sq != BitField::npos; sq = squares.find_next(sq))
	{
		move.setFrom(sq);

		if (isIntoCheck(move, variant))
			b &= ~set1Bit(sq);
	}
}


void
Board::removeIllegalTo(Move move, uint64_t& b, variant::Type variant) const
{
	typedef mstl::bitfield<uint64_t> BitField;

	BitField squares(b);

	for (unsigned sq = squares.find_first(); sq != BitField::npos; sq = squares.find_next(sq))
	{
		move.setTo(sq);

		if (isIntoCheck(move, variant))
			b &= ~set1Bit(sq);
	}
}


Move&
Board::prepareForPrint(Move& move, variant::Type variant, Representation representation) const
{
	M_REQUIRE(isValidMove(move, variant, move::AllowIllegalMove));

	if (!move.isPrintable())
	{
		if (!move.isNull() && !move.isCastling())
		{
			unsigned state = NoCheck;

			if (!variant::isAntichessExceptLosers(variant))
			{
				state |= checkState(move, variant);

				if (state & Check)
				{
					move.setCheck();

					if (state & DoubleCheck)
						move.setDoubleCheck();

					if (state & Checkmate)
						move.setMate();

					if (variant == variant::ThreeCheck)
						move.setChecksGiven(m_checksGiven[m_stm] + 1);
				}
			}

			int from	= move.from();
			int to	= move.to();

			if (m_piece[from] != piece::Pawn)
			{
				// we may need disambiguation
				uint64_t others = 0;

				switch (m_piece[from])
				{
					case piece::Knight:	others = m_knights & knightAttacks(to); break;
					case piece::Bishop:	others = m_bishops & bishopAttacks(to); break;
					case piece::Rook:		others = m_rooks & rookAttacks(to); break;
					case piece::Queen:	others = m_queens & queenAttacks(to); break;
					case piece::King:		others = m_kings & kingAttacks(to); break;
				}

				others ^= set1Bit(from);
				others &= m_occupiedBy[m_stm];

				if (others && representation == InternalRepresentation)
				{
					if (!variant::isAntichessExceptLosers(variant))
					{
						if (move.isLegal())
							removeIllegalFrom(move, others, variant);

						if (state & (Check | Checkmate))
						{
							uint64_t movers = 0;

							switch (m_piece[from])
							{
								case piece::Knight:	movers = m_knights; break;
								case piece::Rook:		movers = m_rooks; break;
								case piece::Queen:	movers = m_queens; break;
								case piece::King:		movers = m_kings; break;

								case piece::Bishop:
									movers = m_bishops;
									if (color::isWhite(sq::color(sq::ID(from))))
										movers &= ::LiteSquares;
									else
										movers &= ::DarkSquares;
									break;
							}

							if (others && count(movers & m_occupiedBy[m_stm]) == 1)
							{
								// this is confusing if more than one moving piece exists
								if (state & Checkmate)
									filterCheckmateMoves(move, others, variant);
								else
									filterCheckMoves(move, others, variant);
							}
						}
					}
				}

				if (others)
				{
					if (others & RankMask[::rank(from)])
						move.setNeedsFyle();

					if (others & FyleMask[::fyle(from)])
						move.setNeedsRank();
					else
						move.setNeedsFyle();
				}

				// we may need disambiguation of destination square
				if (move.isCapture())
				{
					// case 1: more than one piece of same type which can capture
					// case 2: this piece can capture more pieces of this type
					uint64_t others[2] = { 0, 0 }; // otherwise gcc will complain

					switch (m_piece[from])
					{
						case piece::Knight:
							others[0] = m_knights & knightAttacks(to);
							others[1] = knightAttacks(from);
							break;

						case piece::Bishop:
							others[0] = m_bishops & bishopAttacks(to);
							others[1] = bishopAttacks(from);
							break;

						case piece::Rook:
							others[0] = m_rooks & rookAttacks(to);
							others[1] = rookAttacks(from);
							break;

						case piece::Queen:
							others[0] = m_queens & queenAttacks(to);
							others[1] = queenAttacks(from);
							break;

						case piece::King:
							others[0] = m_kings & kingAttacks(to);
							others[1] = kingAttacks(from);
							break;
					}

					others[0] ^= set1Bit(from);
					others[0] &= m_occupiedBy[m_stm];

					others[1] ^= set1Bit(to);
					others[1] &= m_occupiedBy[m_stm ^ 1];

					switch (m_piece[to])
					{
						case piece::Pawn:		others[1] &= m_pawns; break;
						case piece::Knight:	others[1] &= m_knights; break;
						case piece::Bishop:	others[1] &= m_bishops; break;
						case piece::Rook:		others[1] &= m_rooks; break;
						case piece::Queen:	others[1] &= m_queens; break;
					}

					if (	representation == InternalRepresentation
						&& !variant::isAntichessExceptLosers(variant))
					{
						if (move.isLegal())
						{
							if (others[0])
								removeIllegalFrom(move, others[0], variant);

							if (others[1])
								removeIllegalTo(move, others[1], variant);
						}

						// this may be confusing if more than one of captured piece exists
						if (others[0] && (state & (Check | Checkmate)))
							filterCheckmateMoves(move, others[0], variant);
					}

					if (others[0] | others[1])
						move.setNeedsDestinationSquare();
				}
			}
			else if (m_piece[to] != piece::None || move.isEnPassant())
			{
				// we may need disambiguation of pawn captures
				if (pawnCapturesTo(to) ^ set1Bit(from))
					move.setNeedsFyle();
			}
		}

		move.setPrintable();
		move.setColor(m_stm);
	}

	return move;
}


void
Board::setMoveNumber(unsigned number)
{
	// allow move number 0, many FEN's do use this
	m_plyNumber = mstl::mul2(mstl::max(1u, number) - 1) + (m_stm == Black);
}


void
Board::setChecksGiven(unsigned white, unsigned black)
{
	M_REQUIRE(0 <= white && white <= 3);
	M_REQUIRE(0 <= black && black <= 3);
	M_REQUIRE(white < 3 || black < 3);

	hashChecksGiven(White, m_checksGiven[White]);
	hashChecksGiven(Black, m_checksGiven[Black]);

	hashChecksGiven(White, m_checksGiven[White] = white);
	hashChecksGiven(Black, m_checksGiven[Black] = black);
}


void
Board::setPromoted(Square sq, variant::Type variant)
{
	M_REQUIRE(piece(sq) != piece::None);
	M_REQUIRE(piece(sq) != piece::Pawn);
	M_REQUIRE(piece(sq) != piece::King);

	uint64_t		mask	= set1Bit(sq);
	unsigned		color	= m_occupiedBy[White] & mask ? White : Black;
	piece::ID	piece	= ::toPiece(this->piece(sq), color);

	m_promoted[color] |= mask;
	hashPiece(sq, piece);
	hashPromotedPiece(sq, piece, variant);
}


bool
Board::hasPromoted(Square sq) const
{
	uint64_t mask = set1Bit(sq);
	return m_promoted[m_occupiedBy[White] & mask ? White : Black] & mask;
}


piece::ID
Board::pieceAt(Square s) const
{
	uint64_t mask = set1Bit(s);

	if (!(m_occupied & mask))
		return piece::Empty;

	return ::toPiece(m_piece[s], m_occupiedBy[White] & mask ? White : Black);
}


bool
Board::setAt(Square s, piece::ID p, variant::Type variant)
{
	M_REQUIRE(variant != variant::Bughouse || hasPartnerBoard());

	piece::Type pt = piece::type(p);

	if (pt == piece::None)
		return true;

	uint64_t bit = set1Bit(s);

	if (m_occupied & bit)
		removeAt(s, variant);

	color::ID color = piece::color(p);

	switch (pt)
	{
		case piece::Pawn:
			if (rank(s) == Rank1 || rank(s) == Rank8)
				return false;
			hashPawn(s, p);
			m_pawns |= bit;
			incrMaterial<piece::Pawn>(color);
			pawnProgressAdd(color, s);
			if (variant::isZhouse(variant))
				m_partner->possiblyRemoveFromHolding<piece::Pawn>(variant, color);
			break;

		case piece::Knight:
			hashPiece(s, p);
			m_knights |= bit;
			incrMaterial<piece::Knight>(color);
			if (variant::isZhouse(variant))
				m_partner->possiblyRemoveFromHolding<piece::Knight>(variant, color);
			break;

		case piece::Bishop:
			hashPiece(s, p);
			m_bishops |= bit;
			incrMaterial<piece::Bishop>(color);
			if (variant::isZhouse(variant))
				m_partner->possiblyRemoveFromHolding<piece::Bishop>(variant, color);
			break;

		case piece::Rook:
			hashPiece(s, p);
			m_rooks |= bit;
			incrMaterial<piece::Rook>(color);
			if (variant::isZhouse(variant))
				m_partner->possiblyRemoveFromHolding<piece::Rook>(variant, color);
			break;

		case piece::Queen:
			hashPiece(s, p);
			m_queens |= bit;
			incrMaterial<piece::Queen>(color);
			if (variant::isZhouse(variant))
				m_partner->possiblyRemoveFromHolding<piece::Queen>(variant, color);
			break;

		case piece::King:
			M_ASSERT(::count(kings(color)) == 0 || variant::isAntichessExceptLosers(variant));
			hashPiece(s, p);
			m_kings |= bit;
			m_ksq[color] = s;
			if (variant::isAntichessExceptLosers(variant))
				incrMaterial<piece::King>(color);
			else
				++m_material[color].king;
			break;

		case piece::None:
			break; // cannot happen
	}

	m_piece[s] = pt;
	m_occupied ^= bit;
	m_occupiedBy[color] ^= bit;
	m_occupiedL90 ^= MaskL90[s];
	m_occupiedL45 ^= MaskL45[s];
	m_occupiedR45 ^= MaskR45[s];

	return true;
}


void
Board::removeAt(Square s, variant::Type variant)
{
	M_REQUIRE(piece(s) != piece::Pawn || (rank(s) != Rank1 && rank(s) != Rank8));
	M_REQUIRE(variant != variant::Bughouse || hasPartnerBoard());

	uint64_t bit = set1Bit(s);

	if (!(m_occupied & bit))
		return;

	color::ID color = m_occupiedBy[White] & bit ? White : Black;

	switch (m_piece[s])
	{
		case piece::Pawn:
			hashPiece(s, ::toPiece(piece::Pawn, color));
			m_pawns ^= bit;
			decrMaterial<piece::Pawn>(color);
			pawnProgressRemove(color, s);
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Pawn>(variant, color);
			break;

		case piece::Knight:
			hashPiece(s, ::toPiece(piece::Knight, color));
			m_knights ^= bit;
			decrMaterial<piece::Knight>(color);
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Knight>(variant, color);
			break;

		case piece::Bishop:
			hashPiece(s, ::toPiece(piece::Bishop, color));
			m_bishops ^= bit;
			decrMaterial<piece::Bishop>(color);
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Bishop>(variant, color);
			break;

		case piece::Rook:
			hashPiece(s, ::toPiece(piece::Rook, color));
			m_rooks ^= bit;
			decrMaterial<piece::Rook>(color);
			{
				Byte castling = m_destroyCastle[s];
				if (castling != 0xff)
				{
					if (m_castle & ~castling)
						hashCastling(Index(lsb(uint8_t(~castling))));
					m_castle &= castling;
				}
			}
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Rook>(variant, color);
			break;

		case piece::Queen:
			hashPiece(s, ::toPiece(piece::Queen, color));
			m_queens ^= bit;
			decrMaterial<piece::Queen>(color);
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Queen>(variant, color);
			break;

		case piece::King:
			hashPiece(s, ::toPiece(piece::King, color));
			m_kings ^= bit;
			m_ksq[color] = Null;
			hashCastling(color);
			destroyCastle(color);
			if (variant::isAntichessExceptLosers(variant))
				decrMaterial<piece::King>(color);
			else
				--m_material[color].king;
			break;

		case piece::None:
			break; // cannot happen
	}

	m_piece[s] = piece::None;
	m_occupied ^= bit;
	m_occupiedBy[color] ^= bit;
	m_occupiedL90 ^= MaskL90[s];
	m_occupiedL45 ^= MaskL45[s];
	m_occupiedR45 ^= MaskR45[s];
}


void
Board::transpose(variant::Type variant)
{
	Board board(m_emptyBoard);

	for (unsigned i = 0; i < 64; ++i)
	{
		piece::ID	piece		= pieceAt(i);
		unsigned		square	= flipFyle(sq::ID(i));

		if (piece != piece::Empty)
			board.setAt(square, piece, variant);

		board.m_destroyCastle[square] = m_destroyCastle[i];
	}

	board.m_stm = m_stm;
	board.m_epSquare = ::flipFyle(m_epSquare);
	board.m_halfMoveClock = m_halfMoveClock;
	board.m_plyNumber = m_plyNumber;
	board.m_castle = castling::transpose(m_castle);

	board.m_castleRookCurrent[WhiteKS] = ::flipFyle(m_castleRookCurrent[WhiteQS]);
	board.m_castleRookCurrent[WhiteQS] = ::flipFyle(m_castleRookCurrent[WhiteKS]);
	board.m_castleRookCurrent[BlackKS] = ::flipFyle(m_castleRookCurrent[BlackQS]);
	board.m_castleRookCurrent[BlackQS] = ::flipFyle(m_castleRookCurrent[BlackKS]);

	board.m_castleRookAtStart[WhiteKS] = ::flipFyle(m_castleRookAtStart[WhiteQS]);
	board.m_castleRookAtStart[WhiteQS] = ::flipFyle(m_castleRookAtStart[WhiteKS]);
	board.m_castleRookAtStart[BlackKS] = ::flipFyle(m_castleRookAtStart[BlackQS]);
	board.m_castleRookAtStart[BlackQS] = ::flipFyle(m_castleRookAtStart[BlackKS]);

	board.m_unambiguous[WhiteKS] = m_unambiguous[WhiteQS];
	board.m_unambiguous[WhiteQS] = m_unambiguous[WhiteKS];
	board.m_unambiguous[BlackKS] = m_unambiguous[BlackQS];
	board.m_unambiguous[BlackQS] = m_unambiguous[BlackKS];

	// TODO: how to hash promoted pieces?
	board.m_promoted[White] = ::transpose(m_promoted[White]);
	board.m_promoted[Black] = ::transpose(m_promoted[Black]);

	board.m_holding[White] = m_holding[White];
	board.m_holding[Black] = m_holding[Black];

	board.m_checksGiven[White] = m_checksGiven[White];
	board.m_checksGiven[Black] = m_checksGiven[Black];

	static_cast<Signature&>(board) = static_cast<Signature const&>(*this);
	static_cast<Signature&>(board).transpose();

	*this = board;

	if (blackToMove())
		hashToMove();
	if (m_epSquare != Null)
		hashEnPassant();
	hashCastling(White);
	hashCastling(Black);

	if (variant::isZhouse(variant))
		hashHolding(m_holding[White], m_holding[Black]);
	else if (variant == variant::ThreeCheck)
		hashChecksGiven(m_checksGiven[White], m_checksGiven[Black]);
}


bool
Board::shortCastlingWhiteIsLegal() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[WhiteKS] != Null);

	uint64_t king = set1Bit(m_ksq[White]);
	uint64_t rook = set1Bit(m_castleRookCurrent[WhiteKS]);
	uint64_t base = (B1 | C1 | D1 | E1 | F1 | G1) & ~(king - 1); // king...G1

	// king...G1 and F1 must be free
	if (m_occupied & (base | F1) & ~king & ~rook)
		return false;

	// king...G1 not attacked
	return !isAttackedBy(Black, base | king);
}


bool
Board::shortCastlingBlackIsLegal() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[BlackKS] != Null);

	uint64_t king = set1Bit(m_ksq[Black]);
	uint64_t rook = set1Bit(m_castleRookCurrent[BlackKS]);
	uint64_t base = (B8 | C8 | D8 | E8 | F8 | G8) & ~(king - 1); // king...G8

	// king...G8 and F8 must be free
	if (m_occupied & (base | F8) & ~king & ~rook)
		return false;

	// king...G8 not attacked
	return !isAttackedBy(White, base | king);
}


bool
Board::longCastlingWhiteIsLegal() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[WhiteQS] != Null);

	uint64_t king = set1Bit(m_ksq[White]);
	uint64_t rook = set1Bit(m_castleRookCurrent[WhiteQS]);
	uint64_t base = 0;

	if (king > C1)
	{
		base |= (C1 | D1 | E1 | F1 | G1) & (king - 1); // C1...king

		// C1...king not attacked
		if (isAttackedBy(Black, base | king))
			return false;
	}
	else
	{
		// king...C1 not attacked
		if (isAttackedBy(Black, king == B1 ? B1 | C1 : C1))
			return false;
	}

	if (rook < D1)
		base |= (A1 | B1 | C1 | D1) & ~(rook - 1); // rook...D1

	// rook...D1 and C1...king must be free
	return (m_occupied & base & ~king & ~rook) == 0;
}


bool
Board::longCastlingBlackIsLegal() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[BlackQS] != Null);

	uint64_t king = set1Bit(m_ksq[Black]);
	uint64_t rook = set1Bit(m_castleRookCurrent[BlackQS]);
	uint64_t base = 0;

	if (king > C8)
	{
		base |= (C8 | D8 | E8 | F8 | G8) & (king - 1); // C8...king

		// C8...king not attacked
		if (isAttackedBy(White, base | king))
			return false;
	}
	else
	{
		// king...C8 not attacked
		if (isAttackedBy(White, king == B8 ? B8 | C8 : C8))
			return false;
	}

	if (rook < D8)
		base |= (A8 | B8 | C8 | D8) & ~(rook - 1); // rook...D8

	// king...C8...king and rook..C8 must be free
	return (m_occupied & base & ~king & ~rook) == 0;
}


bool
Board::shortCastlingWhiteIsPossible() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[WhiteKS] != Null);

	uint64_t king = set1Bit(m_ksq[White]);
	uint64_t rook = set1Bit(m_castleRookCurrent[WhiteKS]);
	uint64_t base = (B1 | C1 | D1 | E1 | G1) & ~(king - 1); // king...G1

	// king...G1 and F1 must be free
	return (m_occupied & (base | F1) & ~king & ~rook) == 0;
}


bool
Board::shortCastlingBlackIsPossible() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[BlackKS] != Null);

	uint64_t king = set1Bit(m_ksq[Black]);
	uint64_t rook = set1Bit(m_castleRookCurrent[BlackKS]);
	uint64_t base = (B8 | C8 | D8 | E8 | G8) & ~(king - 1);	// king...G8

	// king...G8 and F8 must be free
	return (m_occupied & (base | F8) & ~king & ~rook) == 0;
}


bool
Board::longCastlingWhiteIsPossible() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[WhiteQS] != Null);

	uint64_t king = set1Bit(m_ksq[White]);
	uint64_t rook = set1Bit(m_castleRookCurrent[WhiteQS]);
	uint64_t base = 0;

	if (king > C1)
		base |= (C1 | D1 | E1 | F1 | G1) & (king - 1); // C1...king

	if (rook < D1)
		base |= (A1 | B1 | C1 | D1) & ~(rook - 1); // rook...D1

	// rook...D1 and C1...king must be free
	return (m_occupied & base & ~king & ~rook) == 0;
}


bool
Board::longCastlingBlackIsPossible() const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[BlackQS] != Null);

	uint64_t king = set1Bit(m_ksq[Black]);
	uint64_t rook = set1Bit(m_castleRookCurrent[BlackQS]);
	uint64_t base = 0;

	if (king > C8)
		base |= (C8 | D8 | E8 | F8 | G8) & (king - 1); // C8...king

	if (rook < D8)
		base |= (A8 | B8 | C8 | D8) & ~(rook - 1); // rook...D8

	// rook...D8 and D8...king must be free
	return (m_occupied & base & ~king & ~rook) == 0;
}


Board::SetupStatus
Board::validate(variant::Type variant, Handicap handicap, move::Constraint flag) const
{
	// Pawns on 1st or 8th (although it cannot happen)
	if (pawns(White) & RankMask8 || pawns(Black) & RankMask1)
		return PawnsOn18;

	if (variant::isZhouse(variant))
	{
		// No more than 8 pawns per side
		if (count(pawns(White)) + count(pawns(Black)) > 16)
			return count(pawns(White)) > 8 ? TooManyWhitePawns : TooManyBlackPawns;

		// Maximum 16 pieces per side
		if (count(pieces(White)) > 16) return TooManyWhite;
		if (count(pieces(Black)) > 16) return TooManyBlack;
	}
	else
	{
		// No more than 8 pawns per side
		if (count(pawns(White)) > 8) return TooManyWhitePawns;
		if (count(pawns(Black)) > 8) return TooManyBlackPawns;

		// Maximum 16 pieces per side
		if (count(pieces(White)) > 16) return TooManyWhite;
		if (count(pieces(Black)) > 16) return TooManyBlack;

		// Too many queens, rooks, bishops, or knights?
		if (	count(queens (White) | pawns(White)) > 9
			|| count(rooks  (White) | pawns(White)) > 10
			|| count(bishops(White) | pawns(White)) > 10
			|| count(knights(White) | pawns(White)) > 10)
		{
			return TooManyWhitePieces;
		}

		if (	count(queens(Black)  | pawns(Black)) > 9
			|| count(rooks (Black)  | pawns(Black)) > 10
			|| count(bishops(Black) | pawns(Black)) > 10
			|| count(knights(Black) | pawns(Black)) > 10)
		{
			return TooManyBlackPieces;
		}
	}

	if (variant::isAntichessExceptLosers(variant))
	{
		if (count(kings(White) | pawns(White)) > 9)
			return TooManyWhitePieces;
		if (count(kings(Black) | pawns(Black)) > 9)
			return TooManyWhitePieces;

		if (count(m_occupied) == 0)
			return EmptyBoard;

		if (m_material[notToMove()].total() == 0)
			return OppositeLosing;

		return Valid;
	}
	else if (variant == variant::Losers)
	{
		if (m_material[notToMove()].total() == 1)
			return OppositeLosing;
	}

	if (count(m_kings) > 2) return TooManyKings;

	// Exactly one king per side
	if (m_ksq[White] == Null) return NoWhiteKing;
	if (m_ksq[Black] == Null) return NoBlackKing;

	// Detect unreasonable ep square
	if (	m_epSquare != Null
		&& (	(m_stm == White && (m_epSquare < a6 || m_epSquare > h6))
			|| (m_stm == Black && (m_epSquare < a3 || m_epSquare > h3))
			|| m_occupied & set1Bit(m_epSquare)
			|| m_occupied & PawnF1[m_stm][m_epSquare]))
//			|| !enPassantMoveExists(m_stm)
//			|| !(PawnF1[m_stm ^ 1][m_epSquare] & m_pawns & m_occupiedBy[m_stm ^ 1]))
	{
		return InvalidEnPassant;
	}

	if (variant::isAntichessExceptLosers(variant))
		return Valid;

	// Bad checks
	if (givesCheck())
	{
		if (isInCheck())
			return BothInCheck;

		return OppositeCheck;
	}

	// Detect multi pawn checks.
	uint64_t attackers = countChecks();

	if (count(attackers & m_pawns) >= 2)
		return MultiPawnCheck;

	// Detect triple checks.
	if (count(attackers) >= 3)
		return TripleCheck;

	if (variant::isAntichessExceptLosers(variant))
		return Valid;

	// Can't castle if rook field is occupied by another piece
	// (in standard chess we allow castling with missing rook for historical reasons (handicap games))
	if (	(m_queens  & m_standardBoard.m_queens ) != m_queens
		|| (m_rooks   & m_standardBoard.m_rooks  ) != m_rooks
		|| (m_bishops & m_standardBoard.m_bishops) != m_bishops
		|| (m_knights & m_standardBoard.m_knights) != m_knights)
	{
		if (	(m_castle & WhiteQueenside)
			&& !(rooks(White) & RankMask1 & (king(White) - 1))
			&& m_piece[a1] != piece::None)
		{
			return BadCastlingRights;
		}
		if (	(m_castle & WhiteKingside)
			&& !(rooks(White) & RankMask1 & ~((king(White) - 1) << 1))
			&& m_piece[h1] != piece::None)
		{
			return BadCastlingRights;
		}
		if (	(m_castle & BlackQueenside)
			&& !(rooks(Black) & RankMask8 & (king(Black) - 1))
			&& m_piece[a8] != piece::None)
		{
			return BadCastlingRights;
		}
		if (	(m_castle & BlackKingside)
			&& !(rooks(Black) & RankMask8 & ~((king(Black) - 1) << 1))
			&& m_piece[h8] != piece::None)
		{
			return BadCastlingRights;
		}
	}

	// Can't castle if king has moved
	if (canCastle(White) && ::rank(m_ksq[White]) != Rank1)
		return BadCastlingRights;
	if (canCastle(Black) && ::rank(m_ksq[Black]) != Rank8)
		return BadCastlingRights;

	if (notDerivableFromChess960())
		return BadCastlingRights;

	// Detect unreasonable rook squares (for castling)
	// (in standard chess we allow castling with missing rook for historical reasons (handicap games))
	{
		if (	((m_castle & WhiteQueenside) && rank(m_castleRookCurrent[WhiteQS]) != Rank1)
			|| ((m_castle & WhiteKingside ) && rank(m_castleRookCurrent[WhiteKS]) != Rank1)
			|| ((m_castle & BlackQueenside) && rank(m_castleRookCurrent[BlackQS]) != Rank8)
			|| ((m_castle & BlackKingside ) && rank(m_castleRookCurrent[BlackKS]) != Rank8))
		{
			return InvalidCastlingRights;
		}

		if (	(m_castle & WhiteKingside)
			&& (m_castle & BlackKingside)
			&& fyle(m_castleRookCurrent[WhiteKS]) != fyle(m_castleRookCurrent[BlackKS]))
		{
			return InvalidCastlingRights;
		}

		if (	(m_castle & WhiteQueenside)
			&& (m_castle & BlackQueenside)
			&& fyle(m_castleRookCurrent[WhiteQS]) != fyle(m_castleRookCurrent[BlackQS]))
		{
			return InvalidCastlingRights;
		}

		uint64_t whiteKS = m_castleRookCurrent[WhiteKS] == Null ? 0 : set1Bit(m_castleRookCurrent[WhiteKS]);
		uint64_t whiteQS = m_castleRookCurrent[WhiteQS] == Null ? 0 : set1Bit(m_castleRookCurrent[WhiteQS]);
		uint64_t blackKS = m_castleRookCurrent[BlackKS] == Null ? 0 : set1Bit(m_castleRookCurrent[BlackKS]);
		uint64_t blackQS = m_castleRookCurrent[BlackQS] == Null ? 0 : set1Bit(m_castleRookCurrent[BlackQS]);

		uint64_t whiteRooks = rooks(White);
		uint64_t blackRooks = rooks(Black);

		if (handicap == DontAllowHandicap || notDerivableFromStandardChess())
		{
			// Cannot castle without rook
			if (	((m_castle & WhiteKingside ) && !(whiteKS & whiteRooks))
				|| ((m_castle & BlackKingside ) && !(blackKS & blackRooks))
				|| ((m_castle & WhiteQueenside) && !(whiteQS & whiteRooks))
				|| ((m_castle & BlackQueenside) && !(blackQS & blackRooks)))
			{
				return BadCastlingRights;
			}
		}
		else
		{
			if (mstl::bf::count_bits(whiteRooks) == 2 && mstl::bf::count_bits(pawns(White)) == 8)
			{
				if (	((m_castle & WhiteKingside ) && !(whiteKS & whiteRooks))
					|| ((m_castle & WhiteQueenside) && !(whiteQS & whiteRooks)))
				{
					return BadCastlingRights;	// cannot be a handicap game
				}
			}

			if (mstl::bf::count_bits(blackRooks) == 2 && mstl::bf::count_bits(pawns(Black)) == 8)
			{
				if (	((m_castle & BlackKingside ) && !(blackKS & blackRooks))
					|| ((m_castle & BlackQueenside) && !(blackQS & blackRooks)))
				{
					return BadCastlingRights;	// cannot be a handicap game
				}
			}
		}

//		if (isStartPosition() && !isChess960Position(variant) && m_castle)
//		{
//			// we do not allow start positions with castle rights except
//			// the start position is a Chess 960 position.
//			return InvalidStartPosition;
//		}

		uint64_t mask = set1Bit(m_ksq[White]) - 1;

		if (	rank(m_ksq[White]) == Rank1
			&& (	(	(m_castle & WhiteKingside)
					&& !m_unambiguous[WhiteKS]
					&& count(whiteRooks & ~mask & RankMask1) > 1)
				|| (	(m_castle & WhiteQueenside)
					&& !m_unambiguous[WhiteQS]
					&& count(whiteRooks & mask & RankMask1) > 1)))
		{
			return AmbiguousCastlingFyles;
		}

		mask = set1Bit(m_ksq[Black]) - 1;

		if (	rank(m_ksq[Black]) == Rank8
			&& (	(	(m_castle & BlackKingside)
					&& !m_unambiguous[BlackKS]
					&& count(blackRooks & ~mask & RankMask8) > 1)
				|| (	(m_castle & BlackQueenside)
					&& !m_unambiguous[BlackQS]
					&& count(blackRooks & mask & RankMask8) > 1)))
		{
			return AmbiguousCastlingFyles;
		}
	}

	if (variant::isZhouse(variant))
	{
		unsigned n;

		n = m_partner->m_holding[White].total()
		  + m_partner->m_holding[Black].total()
		  + m_material[White].total()
		  + m_material[Black].total();

		if (n > 32)
			return TooManyPiecesInHolding;

		if (n < 32)
			return TooFewPiecesInHolding;

		n = m_material[Black].pawn
		  + m_material[White].pawn
		  + m_partner->m_holding[Black].pawn
		  + m_partner->m_holding[White].pawn
		  + count(m_promoted[Black])
		  + count(m_promoted[White]);

		if (n > 16)
			return TooManyPromotedPieces;

		if (n < 16)
			return TooFewPromotedPieces;
	}
	else if (variant == variant::ThreeCheck)
	{
		if (	m_checksGiven[White] > 3
			|| m_checksGiven[Black] > 3
			|| (m_checksGiven[White] == 3 && m_checksGiven[Black] == 3)
			|| (m_checksGiven[White] == 3 && !isInCheck(Black))
			|| (m_checksGiven[Black] == 3 && !isInCheck(White)))
		{
			return IllegalCheckCount;
		}
	}

	return Valid;
}


bool
Board::isValidFen(char const* fen, variant::Type variant, Handicap handicap, move::Constraint flag)
{
	Board board;
	return board.setup(fen, variant) && board.validate(variant, handicap, flag) == Valid;
}


void
Board::setCastleShort(color::ID color, unsigned square)
{
	M_ASSERT(square != Null);
	M_ASSERT(sq::rank(square) == HomeRank[color]);

	Byte rights	= kingSide(color);
	Byte index	= ::kingSideIndex(color);

	m_castleRookCurrent[index] = m_castleRookAtStart[index] = square;
	m_destroyCastle[square] = ~rights;

	if (!(m_castle & rights))
	{
		m_castle |= rights;
		hashCastlingKingside(color);
	}
}


void
Board::setCastleLong(color::ID color, unsigned square)
{
	M_ASSERT(square != Null);
	M_ASSERT(sq::rank(square) == HomeRank[color]);

	Byte rights	= queenSide(color);
	Byte index	= ::queenSideIndex(color);

	m_castleRookCurrent[index] = m_castleRookAtStart[index] = square;
	m_destroyCastle[square] = ~rights;

	if (!(m_castle & rights))
	{
		m_castle |= rights;
		hashCastlingQueenside(color);
	}
}


void
Board::tryCastleShort(color::ID color)
{
	Byte rights = kingSide(color);

	if ((m_castling & rights) == 0)
	{
		Square sq = m_castleRookAtStart[::kingSideIndex(color)];

		if (sq != Null && m_piece[sq] == piece::Rook && (set1Bit(sq) & m_occupiedBy[m_stm]))
		{
			m_destroyCastle[sq] = ~rights;
			m_castleRookCurrent[::kingSideIndex(color)] = sq;

			if (!(m_castle & rights))
			{
				m_castle |= rights;
				hashCastlingKingside(color);
			}
		}
	}
}


void
Board::tryCastleLong(color::ID color)
{
	Byte rights = queenSide(color);

	if ((m_castling & rights) == 0)
	{
		Square sq = m_castleRookAtStart[::queenSideIndex(color)];

		if (sq != Null && m_piece[sq] == piece::Rook && (set1Bit(sq) & m_occupiedBy[m_stm]))
		{
			m_destroyCastle[sq] = ~rights;
			m_castleRookCurrent[::queenSideIndex(color)] = sq;

			if (!(m_castle & rights))
			{
				m_castle |= rights;
				hashCastlingQueenside(color);
			}
		}
	}
}


Square
Board::shortCastlingRook(color::ID color) const
{
	if (!kingOnBoard(color) || ::rank(m_ksq[color]) != HomeRank[color])
		return Null;

	uint64_t	rooks = this->rooks(color) & HomeRankMask[color];
	Square	square;

	if (rooks)
	{
		square = msb(rooks);

		if (square > m_ksq[color])
			return square;
	}

	if (::fyle(m_ksq[color]) != FyleE)
		return Null;

	// NOTE: in handicap games the rook is probably missing (only allowed in standard chess)
	square = color::isWhite(color) ? h1 : h8;
	return m_occupied & set1Bit(square) ? Null : square;
}


Square
Board::longCastlingRook(color::ID color) const
{
	if (!kingOnBoard(color) || ::rank(m_ksq[color]) != HomeRank[color])
		return Null;

	uint64_t	rooks = this->rooks(color) & HomeRankMask[color];
	Square	square;

	if (rooks)
	{
		square = lsb(rooks);

		if (square < m_ksq[color])
			return square;
	}

	if (::fyle(m_ksq[color]) != FyleE)
		return Null;

	// NOTE: in handicap games the rook is probably missing (only allowed in standard chess)
	square = color::isWhite(color) ? a1 : a8;
	return m_occupied & set1Bit(square) ? Null : square;
}


void
Board::setCastleShort(color::ID color)
{
	unsigned square = shortCastlingRook(color);

	if (square != Null)
		setCastleShort(color, square);
}


void
Board::setCastleLong(color::ID color)
{
	unsigned square = longCastlingRook(color);

	if (square != Null)
		setCastleLong(color, square);
}


void
Board::removeCastlingRights(castling::Index index)
{
	if (m_castle & (1 << index))
	{
		hashCastling(index);
		m_destroyCastle[m_castleRookCurrent[index]] = 0xff;
		m_castleRookCurrent[index] = Null;
		m_castleRookAtStart[index] = Null;
		m_unambiguous[index] = false;
		m_castle &= ~(1 << index);
	}
}


void
Board::removeCastlingRights(color::ID color)
{
	removeCastlingRights(kingSideIndex(color));
	removeCastlingRights(queenSideIndex(color));
}


void
Board::removeCastlingRights()
{
	removeCastlingRights(WhiteKS);
	removeCastlingRights(WhiteQS);
	removeCastlingRights(BlackKS);
	removeCastlingRights(BlackQS);
}


void
Board::removeCastlingRights(Square rook)
{
	M_REQUIRE(kingOnBoard());
	M_REQUIRE(piece(rook) == piece::Rook);

	Byte castling = m_destroyCastle[rook];

	if (m_castle & ~castling)
		removeCastlingRights(Index(lsb(uint8_t(~castling))));
}


void
Board::setCastlingRights(castling::Rights rights)
{
	// IMPORTANT NOTE:
	// This function is for validation only.
	// The board is now in an inconsistent state.

	m_castle |= rights;
}


void
Board::setCastlingFyle(color::ID color, Fyle fyle)
{
	M_REQUIRE(kingOnBoard());

	// IMPORTANT NOTE: This function is not updating the hash code.

	Square	sq	= sq::make(fyle, HomeRank[color]);
	Byte		i	= sq < m_ksq[color] ? queenSideIndex(color) : kingSideIndex(color);

	m_castleRookCurrent[i] = m_castleRookAtStart[i] = sq;
	m_destroyCastle[sq] = ~(1 << i);
	m_unambiguous[i] = true;
}


void
Board::fixBadCastlingRights()
{
	// NOTE: usable only for standard chess positions.
	// NOTE: mainly used to fix bad FEN's from Scid.

	if (m_ksq[White] != e1)
	{
		hashCastling(White);
		m_castle &= ~WhiteBothSides;
		m_destroyCastle[WhiteKS] = 0xff;
		m_destroyCastle[WhiteQS] = 0xff;
		m_castleRookCurrent[WhiteKS] = m_castleRookAtStart[WhiteKS] = Null;
		m_castleRookCurrent[WhiteQS] = m_castleRookAtStart[WhiteQS] = Null;
	}
	else
	{
		uint64_t whiteRooks = rooks(White);

		if (!(whiteRooks & H1))
		{
			if (m_castle & WhiteKingside)
			{
				unsigned nrooks	= count(whiteRooks);
				unsigned npawns	= count(pawns(White));
				unsigned npieces	= count(pieces(White));

				if ((nrooks == 2 && npawns == 8) || npieces + npawns >= 16)
				{
					// cannot be a handicap game
					m_castleRookAtStart[WhiteKS] = shortCastlingRook(White);
					hashCastlingKingside(White);
					m_castle &= ~WhiteKingside;
					m_destroyCastle[WhiteKS] = 0xff;
				}
			}

			m_castleRookCurrent[WhiteKS] = m_castleRookAtStart[WhiteKS] = Null;
		}

		if (!(whiteRooks & A1))
		{
			if (m_castle & WhiteQueenside)
			{
				unsigned nrooks	= count(whiteRooks);
				unsigned npawns	= count(pawns(White));
				unsigned npieces	= count(pieces(White));

				if ((nrooks == 2 && npawns == 8) || npieces + npawns >= 16)
				{
					// cannot be a handicap game
					m_castleRookAtStart[WhiteQS] = longCastlingRook(White);
					hashCastlingQueenside(White);
					m_castle &= ~WhiteQueenside;
					m_destroyCastle[WhiteQS] = 0xff;
				}
			}

			m_castleRookCurrent[WhiteQS] = m_castleRookAtStart[WhiteQS] = Null;
		}
	}

	if (m_ksq[Black] != e8)
	{
		hashCastling(Black);
		m_castle &= ~BlackBothSides;
		m_destroyCastle[BlackKS] = 0xff;
		m_destroyCastle[BlackQS] = 0xff;
		m_castleRookCurrent[BlackKS] = m_castleRookAtStart[BlackKS] = Null;
		m_castleRookCurrent[BlackQS] = m_castleRookAtStart[BlackQS] = Null;
	}
	else
	{
		uint64_t blackRooks = rooks(Black);

		if (!(blackRooks & H8))
		{
			if (m_castle & BlackKingside)
			{
				unsigned nrooks	= count(blackRooks);
				unsigned npawns	= count(pawns(Black));
				unsigned npieces	= count(pieces(Black));

				if ((nrooks == 2 && npawns == 8) || npieces + npawns >= 16)
				{
					// cannot be a handicap game
					m_castleRookAtStart[BlackKS] = shortCastlingRook(Black);
					hashCastlingKingside(Black);
					m_castle &= ~BlackKingside;
					m_destroyCastle[BlackKS] = 0xff;
				}
			}

			m_castleRookCurrent[BlackKS] = m_castleRookAtStart[BlackKS] = Null;
		}

		if (!(blackRooks & A8))
		{
			if (m_castle & BlackQueenside)
			{
				unsigned nrooks	= count(blackRooks);
				unsigned npawns	= count(pawns(Black));
				unsigned npieces	= count(pieces(Black));

				if ((nrooks == 2 && npawns == 8) || npieces + npawns >= 16)
				{
					// cannot be a handicap game
					m_castleRookAtStart[BlackQS] = longCastlingRook(Black);
					hashCastlingQueenside(Black);
					m_castle &= ~BlackQueenside;
					m_destroyCastle[BlackQS] = 0xff;
				}
			}

			m_castleRookCurrent[BlackQS] = m_castleRookAtStart[BlackQS] = Null;
		}
	}

	::memset(m_unambiguous, true, sizeof(m_unambiguous));
}


char const*
Board::parseHolding(char const* s)
{
	M_ASSERT(s);

	resetHolding();

	for ( ; ::isalpha(*s); ++s)
	{
		switch (*s)
		{
			case 'P': ++m_holding[White].pawn;		break;
			case 'N': ++m_holding[White].knight;	break;
			case 'B': ++m_holding[White].bishop;	break;
			case 'R': ++m_holding[White].rook;		break;
			case 'Q': ++m_holding[White].queen;		break;
			case 'p': ++m_holding[Black].pawn;		break;
			case 'n': ++m_holding[Black].knight;	break;
			case 'b': ++m_holding[Black].bishop;	break;
			case 'r': ++m_holding[Black].rook;		break;
			case 'q': ++m_holding[Black].queen;		break;
			default:  return 0;
		}
	}

	return s;
}


void
Board::hashHolding(Material white, Material black)
{
	hashHolding(piece::WhiteQueen,  white.queen);
	hashHolding(piece::WhiteRook,   white.rook);
	hashHolding(piece::WhiteBishop, white.bishop);
	hashHolding(piece::WhiteKnight, white.knight);
	hashHolding(piece::WhitePawn,   white.pawn);

	hashHolding(piece::BlackQueen,  black.queen);
	hashHolding(piece::BlackRook,   black.rook);
	hashHolding(piece::BlackBishop, black.bishop);
	hashHolding(piece::BlackKnight, black.knight);
	hashHolding(piece::BlackPawn,   black.pawn);
}


void
Board::setHolding(char const* pieces)
{
	M_REQUIRE(pieces);

	hashHolding(m_holding[White], m_holding[Black]);
	parseHolding(pieces);
	hashHolding(m_holding[White], m_holding[Black]);
}


void
Board::clearHolding()
{
	hashHolding(m_holding[White], m_holding[Black]);
	resetHolding();
}


void
Board::setupShortCastlingRook(color::ID color, char const* fen)
{
	// IMPORTANT NOTE: we assume a valid FEN

	if (canCastleShort(color))
		return;

	unsigned		s = 56;		// Piece position
	char const*	p = fen;

	Square rook = Null;

	for ( ; *p && *p != ' '; ++p)
	{
		if (*p == '/')
		{
			if (s == 8)
				return;

			s -= 16;
		}
		else if (::isdigit(*p))
		{
			s += *p - '0';
		}
		else
		{
			M_ASSERT(s < 64);

			switch (*p)
			{
				case 'R':
					if (	color == White
						&& ::rank(s) == Rank1
						&& pieceAt(s) == piece::WhiteRook
						&& s > m_ksq[White]
						&& (rook == Null || s < rook))
					{
						rook = s;
					}
					break;

				case 'r':
					if (	color == Black
						&& ::rank(s) == Rank8
						&& pieceAt(s) == piece::BlackRook
						&& s > m_ksq[Black]
						&& (rook == Null || s < rook))
					{
						rook = s;
					}
					break;
			}

			++s;
		}
	}

	if (rook != Null)
		setCastleShort(color, rook);
}


void
Board::setupLongCastlingRook(color::ID color, char const* fen)
{
	// IMPORTANT NOTE: we assume a valid FEN

	if (canCastleLong(color))
		return;

	unsigned		s = 56;		// Piece position
	char const*	p = fen;

	Square rook = Null;

	for ( ; *p && *p != ' '; ++p)
	{
		if (*p == '/')
		{
			if (s == 8)
				return;

			s -= 16;
		}
		else if (::isdigit(*p))
		{
			s += *p - '0';
		}
		else
		{
			M_ASSERT(s < 64);

			switch (*p)
			{
				case 'R':
					if (	color == White
						&& ::rank(s) == Rank1
						&& pieceAt(s) == piece::WhiteRook
						&& s < m_ksq[White]
						&& (rook == Null || s > rook))
					{
						rook = s;
					}
					break;

				case 'r':
					if (	color == Black
						&& ::rank(s) == Rank8
						&& pieceAt(s) == piece::BlackRook
						&& s < m_ksq[Black]
						&& (rook == Null || s > rook))
					{
						rook = s;
					}
					break;
			}

			++s;
		}
	}

	if (rook != Null)
		setCastleLong(color, rook);
}


char const*
Board::setup(char const* fen, variant::Type variant)
{
	// The FEN has some weakness:
	// ------------------------------------------------------------------------
	// 1) it does not provide information for detection of 3-fold repetition
	// 2) Three-Check: there is no information of given checks
	// 3) Crazyhouse: there exists no standard for the content of the holding
	// ------------------------------------------------------------------------
	// For case (2) we have our own extension: a trailing " +<n>+<n>" denotes the
	// numbers of checks given (white+black).
	// For case (3) we are using the BPGN definition: a trailing "/<pieces>"
	// denotes the pieces in holding; for example "/QQRbnp".

	unsigned		s = 56;		// Piece position
	char const*	p = fen;

	clear();

	if (variant::isZhouse(variant))
		m_holding[White] = m_holding[Black] = m_initialHolding;

	for ( ; *p && *p != ' '; ++p)
	{
		if (*p == '/')
		{
			if (s == 8)
			{
				if (isalpha(p[1]))
				{
					if (!variant::isZhouse(variant))
						return 0;

					if (!(p = parseHolding(p + 1)))
						return 0;

					--p;
				}
				else if (variant::isZhouse(variant))
				{
					resetHolding();
				}
				// else:
				// Some guys are ending the first part with a superfluous '/'.
			}
			else if (s < 16)
			{
				return 0;
			}
			else
			{
				s -= 16;
			}
		}
		else if (::isdigit(*p))
		{
			s += *p - '0';
		}
		else if (*p == '~')
		{
			// Zhouse: after piece denotes promoted piece
			if (p == fen || !::isalpha(p[-1]))
				return 0;

			if (variant::isZhouse(variant))
				setPromoted(s - 1, variant);
		}
		else if (s > 63)
		{
			return 0;
		}
		else
		{
			m_occupiedL90 |= MaskL90[s];
			m_occupiedL45 |= MaskL45[s];
			m_occupiedR45 |= MaskR45[s];

			switch (*p)
			{
				case 'p':
					if ((1 << ::rank(s)) & ((1 << Rank1) | (1 << Rank8)))
						return 0;
					hashPawn(s, piece::BlackPawn);
					m_piece[s] = piece::Pawn;
					m_pawns |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					incrMaterial<piece::Pawn>(Black);
					m_progress.side[Black].add(::flipRank(s));
					if (variant::isZhouse(variant) && m_partner->m_holding[White].pawn > 0)
						--m_partner->m_holding[White].pawn;
					break;

				case 'n':
					hashPiece(s, piece::BlackKnight);
					m_piece[s] = piece::Knight;
					m_knights |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					incrMaterial<piece::Knight>(Black);
					if (variant::isZhouse(variant) && m_partner->m_holding[White].knight)
						--m_partner->m_holding[White].knight;
					break;

				case 'b':
					hashPiece(s, piece::BlackBishop);
					m_piece[s] = piece::Bishop;
					m_bishops |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					incrMaterial<piece::Bishop>(Black);
					if (variant::isZhouse(variant) && m_partner->m_holding[White].bishop)
						--m_partner->m_holding[White].bishop;
					break;

				case 'r':
					hashPiece(s, piece::BlackRook);
					m_piece[s] = piece::Rook;
					m_rooks |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					incrMaterial<piece::Rook>(Black);
					if (variant::isZhouse(variant) && m_partner->m_holding[White].rook)
						--m_partner->m_holding[White].rook;
					break;

				case 'q':
					hashPiece(s, piece::BlackQueen);
					m_piece[s] = piece::Queen;
					m_queens |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					incrMaterial<piece::Queen>(Black);
					if (variant::isZhouse(variant) && m_partner->m_holding[White].queen)
						--m_partner->m_holding[White].queen;
					break;

				case 'k':
					hashPiece(s, piece::BlackKing);
					m_piece[s] = piece::King;
					m_kings |= set1Bit(s);
					m_occupiedBy[Black] |= set1Bit(s);
					m_ksq[Black] = s;
					if (variant::isAntichessExceptLosers(variant))
						incrMaterial<piece::King>(Black);
					else
						++m_material[Black].king;
					break;

				case 'P':
					if ((1 << ::rank(s)) & ((1 << Rank1) | (1 << Rank8)))
						return 0;
					hashPawn(s, piece::WhitePawn);
					m_piece[s] = piece::Pawn;
					m_pawns |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					incrMaterial<piece::Pawn>(White);
					m_progress.side[White].add(s);
					if (variant::isZhouse(variant) && m_partner->m_holding[Black].pawn > 0)
						--m_partner->m_holding[Black].pawn;
					break;

				case 'N':
					hashPiece(s, piece::WhiteKnight);
					m_piece[s] = piece::Knight;
					m_knights |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					incrMaterial<piece::Knight>(White);
					if (variant::isZhouse(variant) && m_partner->m_holding[Black].knight)
						--m_partner->m_holding[Black].knight;
					break;

				case 'B':
					hashPiece(s, piece::WhiteBishop);
					m_piece[s] = piece::Bishop;
					m_bishops |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					incrMaterial<piece::Bishop>(White);
					if (variant::isZhouse(variant) && m_partner->m_holding[Black].bishop)
						--m_partner->m_holding[Black].bishop;
					break;

				case 'R':
					hashPiece(s, piece::WhiteRook);
					m_piece[s] = piece::Rook;
					m_rooks |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					incrMaterial<piece::Rook>(White);
					if (variant::isZhouse(variant) && m_partner->m_holding[Black].rook)
						--m_partner->m_holding[Black].rook;
					break;

				case 'Q':
					hashPiece(s, piece::WhiteQueen);
					m_piece[s] = piece::Queen;
					m_queens |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					incrMaterial<piece::Queen>(White);
					if (variant::isZhouse(variant) && m_partner->m_holding[Black].queen)
						--m_partner->m_holding[Black].queen;
					break;

				case 'K':
					hashPiece(s, piece::WhiteKing);
					m_piece[s] = piece::King;
					m_kings |= set1Bit(s);
					m_occupiedBy[White] |= set1Bit(s);
					m_ksq[White] = s;
					if (variant::isAntichessExceptLosers(variant))
						incrMaterial<piece::King>(White);
					else
						++m_material[White].king;
					break;

				default:
					return 0;
			}

			++s;
		}
	}

	if (s != 8)
		return 0;

	if (variant::isZhouse(variant))
		m_partner->hashHolding(m_partner->m_holding[White], m_partner->m_holding[Black]);

	// Set remainder of board data appropriately
	m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];

	while (*p == ' ')
		++p;

	if (!*p)
		return variant == variant::Bughouse ? 0 : p;

	// Side to move
	switch (*p++)
	{
		case 'w':	m_stm = White; break;
		case 'b':	m_stm = Black; hashToMove(); break;
		default:		return 0;
	}

	while (*p == ' ')
		++p;

	if (!*p)
		return variant == variant::Bughouse ? 0 : p;

	// Castling Rights
	if (*p == '-')
	{
		++p;
	}
	else
	{
		for ( ; *p != ' '; ++p)
		{
			switch (*p)
			{
				case 'A' ... 'H':
				{
					if (m_ksq[White] == Null)
						return 0;

					Byte fyle	= ::toFYLE(*p);
					Byte square	= sq::make(fyle, Rank1);

					if (fyle < ::fyle(m_ksq[White]))
					{
						setCastleLong(White, square);
						m_unambiguous[WhiteQS] = true;
					}
					else
					{
						setCastleShort(White, square);
						m_unambiguous[WhiteKS] = true;
					}
					break;
				}

				case 'a' ... 'h':
				{
					if (m_ksq[Black] == Null)
						return 0;

					Byte fyle	= ::toFyle(*p);
					Byte square	= sq::make(fyle, Rank8);

					if (fyle < ::fyle(m_ksq[Black]))
					{
						setCastleLong(Black, square);
						m_unambiguous[BlackQS] = true;
					}
					else
					{
						setCastleShort(Black, square);
						m_unambiguous[BlackKS] = true;
					}
					break;
				}

				case 'K': setCastleShort(White); break;
				case 'k': setCastleShort(Black); break;
				case 'Q': setCastleLong(White);  break;
				case 'q': setCastleLong(Black);  break;

				default: return 0;
			}
		}
	}

	m_kingHasMoved[White] = ((m_castle & (WhiteQS | WhiteKS)) ? 0 : 1);
	m_kingHasMoved[Black] = ((m_castle & (BlackQS | BlackKS)) ? 0 : 1);

	while (*p == ' ')
		++p;

	if (!*p)
		return variant == variant::Bughouse ? 0 : p;

	// En Passant Square
	m_epSquare = Null;
	char c = ::tolower(*p++);

	if (c != '-')
	{
		if (!::isFyle(c) || !::isRank(*p))
			return 0;

		setEnPassantSquare(sq::make(::toFyle(c), ::toRank(*p++)));
	}

	while (*p == ' ')
		++p;

	if (variant == variant::Bughouse || !*p)
		return p;

	// Half move clock
	if (!::isdigit(*p))
		return 0;
	m_halfMoveClock = ::strtoul(p, const_cast<char**>(&p), 10);

	while (*p == ' ')
		++p;

	if (!*p)
		return p;

	// Move number
	if (!::isdigit(*p))
		return 0;
	unsigned moveNo = ::strtoul(p, const_cast<char**>(&p), 10);
	if (moveNo & (~unsigned(0) << 12))
		moveNo = 0;	// silently fix broken move numbers (Scid's sg3/sg4 may contain broken FEN's)
	setMoveNumber(moveNo);

	while (*p == ' ')
		++p;

	if (variant == variant::ThreeCheck)
	{
		char const* q = p;

		if (*p++ != '+')
			return q;

		if (!::isdigit(*p))
			return q;

		m_checksGiven[White] = ::strtoul(p, const_cast<char**>(&p), 10);

		if (*p++ != '+')
		{
			m_checksGiven[White] = 0;
			return q;
		}

		if (!::isdigit(*p))
			return q;

		m_checksGiven[Black] = ::strtoul(p, const_cast<char**>(&p), 10);

		if (	m_checksGiven[White] > 3
			|| m_checksGiven[Black] > 3
			|| (m_checksGiven[White] == 3 && m_checksGiven[Black] == 3))
		{
			m_checksGiven[White] = m_checksGiven[Black] = 0;
			return 0;
		}

		hashChecksGiven(m_checksGiven[White], m_checksGiven[Black]);

		while (*p == ' ')
			++p;
	}

	return p;
}


void
Board::setup(ExactZHPosition const& position)
{
	// IMPORTANT NOTE: The information in 'position' is not sufficient
	// to build a consistent board. The resulting board should not be
	// used for playing or validation. Especially the hash code is not
	// valid (missing promotion information).

	clear();

	for (unsigned color = 0; color < 2; ++color)
	{
		for (unsigned sq = 0; sq < 64; ++sq)
		{
			uint64_t mask = set1Bit(sq);

			if (position.m_occupiedBy[color] & mask)
			{
				piece::Type piece;

				if (position.m_pawns & mask)
					piece = piece::Pawn;
				else if (position.m_knights & mask)
					piece = piece::Knight;
				else if (position.m_bishops & mask)
					piece = piece::Bishop;
				else if (position.m_rooks & mask)
					piece = piece::Rook;
				else if (position.m_queens & mask)
					piece = piece::Queen;
				else
					piece = piece::King;

				setAt(sq, ::toPiece(piece, color), variant::Normal);
			}
		}
	}

	m_castleRookAtStart[castling::WhiteQS] = a1;
	m_castleRookAtStart[castling::WhiteKS] = h1;
	m_castleRookAtStart[castling::BlackQS] = a8;
	m_castleRookAtStart[castling::BlackKS] = h8;

	::memcpy(m_castleRookCurrent, position.m_castleRookCurrent, sizeof(m_castleRookCurrent));

	for (unsigned i = 0; i < 4; ++i)
	{
		Square sq = m_castleRookCurrent[i];

		M_ASSERT((sq == Null) == ((position.m_castle & (1 << i)) == 0));

		if (sq == sq::Null)
			hashCastling(Index(i));
		else
			m_castleRookAtStart[i] = sq;
	}

	::memset(m_unambiguous, true, sizeof(m_unambiguous));

	if ((m_stm = position.m_stm) == Black)
		hashToMove();

	if ((m_epSquare = position.m_epSquare) != Null)
		hashEnPassant();

	m_castle = position.m_castle;

	m_holding[White] = position.m_holding[White];
	m_holding[Black] = position.m_holding[Black];
	// TODO: how to hash promoted pieces?
	m_promoted[White] = position.m_promoted[White];
	m_promoted[Black] = position.m_promoted[Black];
	m_checksGiven[White] = position.m_checksGiven[White];
	m_checksGiven[Black] = position.m_checksGiven[Black];

	hashHolding(m_holding[White], m_holding[Black]);
	hashChecksGiven(m_checksGiven[White], m_checksGiven[Black]);
}


bool
Board::notDerivableFromStandardChess() const
{
	return	((m_castle & WhiteKingside ) && (m_ksq[White] != e1 || m_castleRookCurrent[WhiteKS] != h1))
			|| ((m_castle & BlackKingside ) && (m_ksq[Black] != e8 || m_castleRookCurrent[BlackKS] != h8))
			|| ((m_castle & WhiteQueenside) && (m_ksq[White] != e1 || m_castleRookCurrent[WhiteQS] != a1))
			|| ((m_castle & BlackQueenside) && (m_ksq[Black] != e8 || m_castleRookCurrent[BlackQS] != a8));
}


bool
Board::notDerivableFromChess960() const
{
	return	((m_castle & WhiteKingside ) && m_castleRookCurrent[WhiteKS] < m_ksq[White])
			|| ((m_castle & BlackKingside ) && m_castleRookCurrent[BlackKS] < m_ksq[Black])
			|| ((m_castle & WhiteQueenside) && m_castleRookCurrent[WhiteQS] > m_ksq[White])
			|| ((m_castle & BlackQueenside) && m_castleRookCurrent[BlackQS] > m_ksq[Black]);
}


bool
Board::checkShuffleChessPosition() const
{
	return		isStartPosition()
				// check whether all white and black pieces are in opposition
				&& knights(White) == (knights(Black) >> a8)
				&& bishops(White) == (bishops(Black) >> a8)
				&& rooks(White)   == (rooks(Black)   >> a8)
				&& queens(White)  == (queens(Black)  >> a8)
				// check whether the bishops have opposite colors
				&& hasBishopOnLite(White) && hasBishopOnDark(White);
}


bool
Board::isStandardPosition(variant::Type variant) const
{
	if (variant::isAntichessExceptLosers(variant))
		return isEqualPosition(m_antichessBoard);

	return isEqualPosition(m_standardBoard);
}


bool
Board::isStartPosition() const
{
	if (m_epSquare != Null || m_stm == Black)
		return false;

	return	// check material: KQRRBBNN
					m_material[White].value == m_shuffleChessBoard.m_material[White].value
				&& m_material[Black].value == m_shuffleChessBoard.m_material[Black].value
				// all white/black pawns are on 2nd/7th rank?
				&& pawns(White) == RankMask2
				&& pawns(Black) == RankMask7
				// all white/black pieces are on 1st/8th rank?
				&& (pieces(White) & ~m_pawns) == RankMask1
				&& (pieces(Black) & ~m_pawns) == RankMask8;
}


bool
Board::isChess960Position() const
{
	return	m_castle == AllRights
			&& checkShuffleChessPosition()
			// check whether king is between the rooks
			&& lsb(rooks(White)) < m_ksq[White] && m_ksq[White] < msb(rooks(White));
}


bool
Board::isChess960Position(variant::Type variant) const
{
	if (variant::isAntichessExceptLosers(variant))
		return checkShuffleChessPosition();

	return	m_castle == AllRights
			&& checkShuffleChessPosition()
			// check whether king is between the rooks
			&& lsb(rooks(White)) < m_ksq[White] && m_ksq[White] < msb(rooks(White));
}


bool
Board::isShuffleChessPosition(variant::Type variant) const
{
	if (!checkShuffleChessPosition())
		return false;

	if (variant::isAntichessExceptLosers(variant))
		return true;

	if (m_castle == NoRights)
		return true;

	return m_castle == AllRights
			// check whether king is between the rooks
			&& lsb(rooks(White)) < m_ksq[White] && m_ksq[White] < msb(rooks(White));
}


unsigned
Board::computeIdn(variant::Type variant) const
{
#define __ -1
	static int8_t const BishopTable[8][8] =
	{
		{ __,  0, __,  1, __,  2, __,  3 },
		{ __, __,  4, __,  8, __, 12, __ },
		{ __, __, __,  5, __,  6, __,  7 },
		{ __, __, __, __,  9, __, 13, __ },
		{ __, __, __, __, __, 10, __, 11 },
		{ __, __, __, __, __, __, 14, __ },
		{ __, __, __, __, __, __, __, 15 },
		{ __, __, __, __, __, __, __, __ },
	};
#undef __
#define _  -1
	static int8_t const N5NTable[5][5] =
	{
		{ _, 0, 1, 2, 3 },
		{ _, _, 4, 5, 6 },
		{ _, _, _, 7, 8 },
		{ _, _, _, _, 9 },
		{ _, _, _, _, _ },
	};
#undef _

	if (!variant::isAntichessExceptLosers(variant) && (!kingOnBoard(White) || !kingOnBoard(Black)))
		return 0;

	// firstly handle the most common case
	if (isStandardPosition(variant))
		return variant::Standard;

	unsigned idn = 0;

	if (isShuffleChessPosition(variant))
	{
		uint64_t bishops	= this->bishops(White);
		uint64_t knights	= this->knights(White);
		uint64_t queen		= this->queens(White);

		// 1. compute the bishops code
		int bCode = BishopTable[::lsb(bishops)][::msb(bishops)];

		M_ASSERT(0 <= bCode && bCode < 16);

		// 2. compute queen's position
		int qPos	= lsb(queen) - count(bishops & (queen - 1));

		M_ASSERT(0 <= qPos && qPos <= 5);

		// 3. compute knights position
		int k1Sq		= lsb(knights);
		int k2Sq		= msb(knights);
		int k1Pos	= k1Sq - count((bishops | queen) & (set1Bit(k1Sq) - 1));
		int k2Pos	= k2Sq - count((bishops | queen) & (set1Bit(k2Sq) - 1));

		M_ASSERT(0 <= k1Pos && k1Pos <= 3);
		M_ASSERT(0 <= k2Pos && k2Pos <= 4);

		int n5nCode = N5NTable[k1Pos][k2Pos];

		M_ASSERT(0 <= n5nCode && n5nCode <= 9);

		idn = bCode + ::mul16(qPos) + 96*n5nCode;

		M_ASSERT(0 <= idn && idn < 960);

		if (idn == 0)
			idn = 960;

		// 4. shift range depending on castling rights and rook positions
		uint64_t rooks = this->rooks(White);

		if (lsb(rooks) > m_ksq[White])
			idn += 2*960;
		else if (msb(rooks) < m_ksq[White])
			idn += 960;
		else if (m_castle == NoRights)
			idn += 3*960;
	}
	else if (!variant::isAntichessExceptLosers(variant))
	{
		switch (m_hash)
		{
			case LittleGame_Hash:
				if (m_littleGame.exactZHPosition() == exactZHPosition())
					idn = variant::LittleGame;
				break;

			case PawnsOn4thRank_Hash:
				if (m_pawnsOn4thRank.exactZHPosition() == exactZHPosition())
					idn = variant::PawnsOn4thRank;
				break;

			case Pyramid_Hash:
				if (m_pyramid.exactZHPosition() == exactZHPosition())
					idn = variant::Pyramid;
				break;

			case KNNvsKP_Hash:
				if (m_KNNvsKP.exactZHPosition() == exactZHPosition())
					idn = variant::KNNvsKP;
				break;

			case PawnsOnly_Hash:
				if (m_pawnsOnly.exactZHPosition() == exactZHPosition())
					idn = variant::PawnsOnly;
				break;

			case KnightsOnly_Hash:
				if (m_knightsOnly.exactZHPosition() == exactZHPosition())
					idn = variant::KnightsOnly;
				break;

			case BishopsOnly_Hash:
				if (m_bishopsOnly.exactZHPosition() == exactZHPosition())
					idn = variant::BishopsOnly;
				break;

			case RooksOnly_Hash:
				if (m_rooksOnly.exactZHPosition() == exactZHPosition())
					idn = variant::RooksOnly;
				break;

			case QueensOnly_Hash:
				if (m_queensOnly.exactZHPosition() == exactZHPosition())
					idn = variant::QueensOnly;
				break;

			case NoQueens_Hash:
				if (m_noQueens.exactZHPosition() == exactZHPosition())
					idn = variant::NoQueens;
				break;

			case WildFive_Hash:
				if (m_wildFive.exactZHPosition() == exactZHPosition())
					idn = variant::WildFive;
				break;

			case KBNK_Hash:
				if (m_kbnk.exactZHPosition() == exactZHPosition())
					idn = variant::KBNK;
				break;

			case KBBK_Hash:
				if (m_kbbk.exactZHPosition() == exactZHPosition())
					idn = variant::KBBK;
				break;

			case Runaway_Hash:
				if (m_runaway.exactZHPosition() == exactZHPosition())
					idn = variant::Runaway;
				break;

			case QueenVsRooks_Hash:
				if (m_queenVsRooks.exactZHPosition() == exactZHPosition())
					idn = variant::QueenVsRooks;
				break;

			case UpsideDown_Hash:
				if (m_upsideDown.exactZHPosition() == exactZHPosition())
					idn = variant::UpsideDown;
				break;
		}
	}

	return idn;
}


void
Board::setup(unsigned idn, variant::Type variant)
{
	M_REQUIRE(idn > 0);
	M_REQUIRE(idn <= 4*960 || variant == variant::Normal || variant == variant::ThreeCheck);

	if (idn > 4*960)
	{
		switch (idn)
		{
			case variant::LittleGame:			*this = m_littleGame; break;
			case variant::PawnsOn4thRank:		*this = m_pawnsOn4thRank; break;
			case variant::Pyramid:				*this = m_pyramid; break;
			case variant::KNNvsKP:				*this = m_KNNvsKP; break;
			case variant::PawnsOnly:			*this = m_pawnsOnly; break;
			case variant::KnightsOnly:			*this = m_knightsOnly; break;
			case variant::BishopsOnly:			*this = m_bishopsOnly; break;
			case variant::RooksOnly:			*this = m_rooksOnly; break;
			case variant::QueensOnly:			*this = m_queensOnly; break;
			case variant::NoQueens:				*this = m_noQueens; break;
			case variant::WildFive:				*this = m_wildFive; break;
			case variant::KBNK:					*this = m_kbnk; break;
			case variant::KBBK:					*this = m_kbbk; break;
			case variant::Runaway:				*this = m_runaway; break;
			case variant::QueenVsRooks:		*this = m_queenVsRooks; break;
			case variant::UpsideDown:			*this = m_upsideDown; break;
			default:									M_ASSERT(!"unexpected position number"); break;
		}
	}
	else
	{
		bool frcCastling;

		if (!variant::isAntichessExceptLosers(variant) && idn <= 960)
		{
			frcCastling = true;
		}
		else
		{
			frcCastling = false;

			if (idn > 3*960)
				idn -= 3*960;
		}

		*this = m_shuffleChessBoard;	// setup pawns, signature, and other stuff

		if (variant::isZhouse(variant))
			m_holding[White] = m_holding[Black] = m_initialHolding;

		char placement[8];
		::memcpy(placement, chess960::position(((idn - 1) % 960) + 1), 8);

		if (idn > 2*960)
		{
			char* r = ::strchr(placement, 'R');
			char* k = ::strchr(r + 1, 'K');

			mstl::swap(*r, *k);
		}
		else if (idn > 960)
		{
			char* k = ::strchr(placement, 'K');
			char* r = ::strchr(k + 1, 'R');

			mstl::swap(*r, *k);
		}

		for (unsigned i = 0; i < 8; ++i)
		{
			Square wSq = a1 + i;
			Square bSq = a8 + i;

			uint64_t whiteMask = set1Bit(wSq);
			uint64_t blackMask = set1Bit(bSq);

			m_occupiedBy[White] ^= whiteMask;
			m_occupiedBy[Black] ^= blackMask;
			m_occupiedL90 ^= MaskL90[wSq] | MaskL90[bSq];
			m_occupiedL45 ^= MaskL45[wSq] | MaskL45[bSq];
			m_occupiedR45 ^= MaskR45[wSq] | MaskR45[bSq];

			switch (placement[i])
			{
				case 'K':
					m_ksq[White] = wSq;
					m_ksq[Black] = bSq;
					m_kings |= whiteMask | blackMask;
					m_piece[wSq] = m_piece[bSq] = piece::King;
					hashPiece(wSq, piece::WhiteKing);
					hashPiece(bSq, piece::BlackKing);
					break;

				case 'Q':
					m_queens |= whiteMask | blackMask;
					m_piece[wSq] = m_piece[bSq] = piece::Queen;
					hashPiece(wSq, piece::WhiteQueen);
					hashPiece(bSq, piece::BlackQueen);
					break;

				case 'R':
					m_rooks |= whiteMask | blackMask;
					m_piece[wSq] = m_piece[bSq] = piece::Rook;
					hashPiece(wSq, piece::WhiteRook);
					hashPiece(bSq, piece::BlackRook);
					break;

				case 'B':
					m_bishops |= whiteMask | blackMask;
					m_piece[wSq] = m_piece[bSq] = piece::Bishop;
					hashPiece(wSq, piece::WhiteBishop);
					hashPiece(bSq, piece::BlackBishop);
					break;

				case 'N':
					m_knights |= whiteMask | blackMask;
					m_piece[wSq] = m_piece[bSq] = piece::Knight;
					hashPiece(wSq, piece::WhiteKnight);
					hashPiece(bSq, piece::BlackKnight);
					break;
			}
		}

		// set remainder of board data appropriately
		m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];

		if (frcCastling)
		{
			setCastleShort(White);
			setCastleShort(Black);
			setCastleLong(White);
			setCastleLong(Black);
		}

		// simple validation
		M_ASSERT(frcCastling ? isChess960Position(variant) : isShuffleChessPosition(variant));
		M_ASSERT(computeIdn(variant) == (idn <= 960 && !frcCastling) ? idn + 3*960 : idn);
	}
}


bool
Board::checkIfLegalMove(Move& move) const
{
	if (move.isLegal())
		return true;

	Board board(*this);
	board.doMove(move, variant::Normal);

	if (!board.isLegal())
		return false;

	move.setLegalMove();
	return true;
}


void
Board::filterLegalMoves(MoveList& result, variant::Type variant) const
{
	if (variant::isAntichessExceptLosers(variant))
	{
		for (unsigned i = 0; i < result.size(); ++i)
			result[i].setLegalMove();
	}
	else
	{
		unsigned k = 0;

		for (unsigned i = 0; i < result.size(); ++i)
		{
			Move& move = result[i];

			if (move.isLegal())
			{
				result[k++] = move;
			}
			else
			{
				Board peek(*this);
				peek.doMove(move, variant);

				if (peek.isLegal())
				{
					move.setLegalMove();
					result[k++] = move;
				}
			}
		}

		result.cut(k);
	}
}


bool
Board::containsAnyLegalMove(MoveList const& moves, variant::Type variant) const
{
	if (variant::isAntichessExceptLosers(variant))
		return !moves.isEmpty();

	for (unsigned i = 0; i < moves.size(); ++i)
	{
		Board peek(*this);
		peek.doMove(moves[i], variant);

		if (peek.isLegal())
			return true;
	}

	return false;
}


void
Board::filterCheckMoves(Move move, uint64_t& movers, variant::Type variant) const
{
	typedef mstl::bitfield<uint64_t> BitField;

	M_ASSERT(kingOnBoard());

	BitField squares(movers);

	for (unsigned sq = squares.find_first(); sq != BitField::npos; sq = squares.find_next(sq))
	{
		move.setFrom(sq);
		M_ASSERT(isValidMove(move, variant));

		Board peek(*this);
		peek.doMove(move, variant);

		if (!peek.isInCheck())
			movers &= ~set1Bit(sq);
	}
}


void
Board::filterCheckmateMoves(Move move, uint64_t& movers, variant::Type variant) const
{
	typedef mstl::bitfield<uint64_t> BitField;

	M_ASSERT(kingOnBoard());

	BitField squares(movers);

	for (unsigned sq = squares.find_first(); sq != BitField::npos; sq = squares.find_next(sq))
	{
		move.setFrom(sq);
		M_ASSERT(isValidMove(move, variant));

		Board peek(*this);
		peek.doMove(move, variant);

		if (!peek.isMate(variant))
			movers &= ~set1Bit(sq);
	}
}


void
Board::genCastleShort(MoveList& result, color::ID side) const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[::kingSideIndex(side)] != Null);

	Move m(Move::genCastling(m_ksq[side], m_castleRookCurrent[::kingSideIndex(side)]));
	m.setLegalMove();
	result.append(m);
}


void
Board::genCastleLong(MoveList& result, color::ID side) const
{
	M_ASSERT(kingOnBoard());
	M_ASSERT(m_castleRookCurrent[::queenSideIndex(side)] != Null);

	Move m(Move::genCastling(m_ksq[side], m_castleRookCurrent[::queenSideIndex(side)]));
	m.setLegalMove();
	result.append(m);
}


bool
Board::findAnyLegalMove(variant::Type variant) const
{
	MoveList moves;

	if (variant::isAntichess(variant))
	{
		generateCapturingPawnMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateCapturingPieceMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateNonCapturingPawnMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateNonCapturingPieceMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		if (variant == variant::Losers)
		{
			moves.clear();
			generateCastlingMoves(moves);
			if (containsAnyLegalMove(moves, variant))
				return true;
		}
	}
	else if (variant != variant::ThreeCheck || m_checksGiven[m_stm ^ 1] < 3)
	{
		moves.clear();
		generateNonCapturingPawnMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateNonCapturingPieceMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		generateCapturingPawnMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateCapturingPieceMoves(variant, moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		moves.clear();
		generateCastlingMoves(moves);
		if (containsAnyLegalMove(moves, variant))
			return true;

		if (variant::isZhouse(variant))
		{
			moves.clear();
			generatePieceDropMoves(moves);
			if (containsAnyLegalMove(moves, variant))
				return true;
		}
	}

	return false;
}


void
Board::generateMoves(variant::Type variant, MoveList& result) const
{
	if (variant::isAntichess(variant))
	{
		generateCapturingPawnMoves(variant, result);
		generateCapturingPieceMoves(variant, result);

		if (variant == variant::Losers)
			filterLegalMoves(result, variant);

		if (result.isEmpty())
		{
			generateNonCapturingPawnMoves(variant, result);
			generateNonCapturingPieceMoves(variant, result);

			if (variant == variant::Losers)
				generateCastlingMoves(result);
		}
	}
	else if (variant != variant::ThreeCheck || m_checksGiven[m_stm ^ 1] < 3)
	{
		generateCapturingPawnMoves(variant, result);
		generateNonCapturingPawnMoves(variant, result);
		generateCapturingPieceMoves(variant, result);
		generateNonCapturingPieceMoves(variant, result);
		generateCastlingMoves(result);

		if (variant::isZhouse(variant))
			generatePieceDropMoves(result);
	}
}


void
Board::generateCastlingMoves(MoveList& result) const
{
	if (m_stm == White)
	{
		if ((m_castle & WhiteKingside) && shortCastlingWhiteIsLegal())
			genCastleShort(result, White);
		if ((m_castle & WhiteQueenside) && longCastlingWhiteIsLegal())
			genCastleLong(result, White);
	}
	else
	{
		if ((m_castle & BlackKingside) && shortCastlingBlackIsLegal())
			genCastleShort(result, Black);
		if ((m_castle & BlackQueenside) && longCastlingBlackIsLegal())
			genCastleLong(result, Black);
	}
}


void
Board::generateNonCapturingPawnMoves(variant::Type variant, MoveList& result) const
{
	uint64_t moves;

	if (m_stm == White)
	{
		uint64_t movers = m_pawns & m_occupiedBy[White];

		// pawns 1 forward
		moves = ::shiftUp(movers) & ~m_occupied;
		movers = moves;

		while (moves)
		{
			unsigned to = lsbClear(moves);

			if (::rank(to) == Rank8)
			{
				result.append(Move::genPromote(to - 8, to, piece::Queen));
				result.append(Move::genPromote(to - 8, to, piece::Knight));
				result.append(Move::genPromote(to - 8, to, piece::Rook));
				result.append(Move::genPromote(to - 8, to, piece::Bishop));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genPromote(to - 8, to, piece::King));
			}
			else
			{
				result.append(Move::genOneForward(to - 8, to));
			}
		}

		// pawns 2 forward
		moves = ::shiftUp(movers) & RankMask4 & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genTwoForward(to - 16, to));
		}
	}
	else
	{
		uint64_t movers = m_pawns & m_occupiedBy[Black];

		// pawns 1 forward
		moves = ::shiftDown(movers) & ~m_occupied;
		movers = moves;

		while (moves)
		{
			unsigned to = lsbClear(moves);

			if (::rank(to) != 0)
			{
				result.append(Move::genOneForward(to + 8, to));
			}
			else
			{
				result.append(Move::genPromote(to + 8, to, piece::Queen));
				result.append(Move::genPromote(to + 8, to, piece::Knight));
				result.append(Move::genPromote(to + 8, to, piece::Rook));
				result.append(Move::genPromote(to + 8, to, piece::Bishop));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genPromote(to + 8, to, piece::King));
			}
		}

		// pawns 2 forward
		moves = ::shiftDown(movers) & RankMask5 & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genTwoForward(to + 16, to));
		}
	}
}


void
Board::generateNonCapturingPieceMoves(variant::Type variant, MoveList& result) const
{
	uint64_t occupiedBy = m_occupiedBy[m_stm];
	uint64_t movers;

	// knight moves
	movers = m_knights & occupiedBy;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = knightAttacks(from) & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genKnightMove(from, to, piece::None));
		}
	}

	// bishop moves
	movers = m_bishops & occupiedBy;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = bishopAttacks(from) & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genBishopMove(from, to, piece::None));
		}
	}

	// rook moves
	movers = m_rooks & occupiedBy;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = rookAttacks(from) & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genRookMove(from, to, piece::None));
		}
	}

	// queen moves
	movers = m_queens & occupiedBy;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = queenAttacks(from) & ~m_occupied;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genQueenMove(from, to, piece::None));
		}
	}

	// king moves
	if (variant::isAntichessExceptLosers(variant))
	{
		movers = m_kings & occupiedBy;

		while (movers)
		{
			unsigned from = lsbClear(movers);
			uint64_t moves = kingAttacks(from) & ~m_occupied;

			while (moves)
			{
				uint8_t to = lsbClear(moves);
				result.append(Move::genKingMove(from, to, piece::None));
			}
		}
	}
	else
	{
		uint64_t moves = kingAttacks(m_ksq[m_stm]) & ~m_occupiedBy[m_stm];

		while (moves)
		{
			uint8_t to = lsbClear(moves);

			if (!isAttackedBy(m_stm ^ 1, to))
				result.append(Move::genKingMove(m_ksq[m_stm], to, m_piece[to]));
		}
	}
}


void
Board::generateCapturingPawnMoves(variant::Type variant, MoveList& result) const
{
	if (m_stm == White)
	{
		// en passant moves
		uint64_t movers = m_pawns & m_occupiedBy[White];

		if (m_epSquare != Null)
		{
			uint64_t moves = PawnAttacks[Black][m_epSquare] & movers;

			while (moves)
				result.append(Move::genEnPassant(lsbClear(moves), m_epSquare));
		}

		uint64_t occupied = m_occupiedBy[Black];

		if (!variant::isAntichessExceptLosers(variant))
			occupied &= ~m_kings;

		// captures
		uint64_t moves = ::shiftUpRight(movers) & occupied;

		while (moves)
		{
			uint32_t to = lsbClear(moves);
			uint32_t captured = m_piece[to];

			if (::rank(to) == Rank8)
			{
				result.append(Move::genCapturePromote(to - 9, to, piece::Queen,  captured));
				result.append(Move::genCapturePromote(to - 9, to, piece::Knight, captured));
				result.append(Move::genCapturePromote(to - 9, to, piece::Rook,   captured));
				result.append(Move::genCapturePromote(to - 9, to, piece::Bishop, captured));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genCapturePromote(to - 9, to, piece::King, captured));
			}
			else
			{
				result.append(Move::genPawnCapture(to - 9, to, captured));
			}
		}

		moves = ::shiftUpLeft(movers) & occupied;

		while (moves)
		{
			uint32_t to = lsbClear(moves);
			uint32_t captured = m_piece[to];

			if (::rank(to) == Rank8)
			{
				result.append(Move::genCapturePromote(to - 7, to, piece::Queen,  captured));
				result.append(Move::genCapturePromote(to - 7, to, piece::Knight, captured));
				result.append(Move::genCapturePromote(to - 7, to, piece::Rook,   captured));
				result.append(Move::genCapturePromote(to - 7, to, piece::Bishop, captured));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genCapturePromote(to - 7, to, piece::King, captured));
			}
			else
			{
				result.append(Move::genPawnCapture(to - 7, to, captured));
			}
		}
	}
	else
	{
		// en passant moves
		uint64_t movers = m_pawns & m_occupiedBy[Black];

		if (m_epSquare != Null)
		{
			uint64_t moves = PawnAttacks[White][m_epSquare] & movers;

			while (moves)
				result.append(Move::genEnPassant(lsbClear(moves), m_epSquare));
		}

		uint64_t occupied = m_occupiedBy[White];

		if (!variant::isAntichessExceptLosers(variant))
			occupied &= ~m_kings;

		// captures
		uint64_t moves = ::shiftDownLeft(movers) & occupied;

		while (moves)
		{
			uint32_t to = lsbClear(moves);
			uint32_t captured = m_piece[to];

			if (::rank(to) == Rank1)
			{
				result.append(Move::genCapturePromote(to + 9, to, piece::Queen,  captured));
				result.append(Move::genCapturePromote(to + 9, to, piece::Knight, captured));
				result.append(Move::genCapturePromote(to + 9, to, piece::Rook,   captured));
				result.append(Move::genCapturePromote(to + 9, to, piece::Bishop, captured));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genCapturePromote(to + 9, to, piece::King, captured));
			}
			else
			{
				result.append(Move::genPawnCapture(to + 9, to, captured));
			}
		}

		moves = ::shiftDownRight(movers) & occupied;

		while (moves)
		{
			uint32_t to = lsbClear(moves);
			uint32_t captured = m_piece[to];

			if (::rank(to) == Rank1)
			{
				result.append(Move::genCapturePromote(to + 7, to, piece::Queen,  captured));
				result.append(Move::genCapturePromote(to + 7, to, piece::Knight, captured));
				result.append(Move::genCapturePromote(to + 7, to, piece::Rook,   captured));
				result.append(Move::genCapturePromote(to + 7, to, piece::Bishop, captured));
				if (variant::isAntichessExceptLosers(variant))
					result.append(Move::genCapturePromote(to + 7, to, piece::King, captured));
			}
			else
			{
				result.append(Move::genPawnCapture(to + 7, to, captured));
			}
		}
	}
}


void
Board::generateCapturingPieceMoves(variant::Type variant, MoveList& result) const
{
	uint64_t occupied	= m_occupiedBy[m_stm];
	uint64_t capture	= m_occupiedBy[m_stm ^ 1];
	uint64_t movers;

	// king moves
	if (variant::isAntichessExceptLosers(variant))
	{
		movers = m_kings & occupied;

		while (movers)
		{
			unsigned from = lsbClear(movers);
			uint64_t moves = kingAttacks(from) & capture;

			while (moves)
			{
				uint8_t to = lsbClear(moves);
				result.append(Move::genKingMove(from, to, m_piece[to]));
			}
		}
	}
	else
	{
		M_ASSERT(kingOnBoard());

		capture &= ~m_kings;

		uint64_t moves = kingAttacks(m_ksq[m_stm]) & capture;

		while (moves)
		{
			uint8_t to = lsbClear(moves);

			if (!isAttackedBy(m_stm ^ 1, to))
				result.append(Move::genKingMove(m_ksq[m_stm], to, m_piece[to]));
		}
	}

	// knight moves
	movers = m_knights & occupied;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = knightAttacks(from) & capture;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genKnightMove(from, to, m_piece[to]));
		}
	}

	// bishop moves
	movers = m_bishops & occupied;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = bishopAttacks(from) & capture;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genBishopMove(from, to, m_piece[to]));
		}
	}

	// rook moves
	movers = m_rooks & occupied;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = rookAttacks(from) & capture;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genRookMove(from, to, m_piece[to]));
		}
	}

	// queen moves
	movers = m_queens & occupied;

	while (movers)
	{
		unsigned from = lsbClear(movers);
		uint64_t moves = queenAttacks(from) & capture;

		while (moves)
		{
			unsigned to = lsbClear(moves);
			result.append(Move::genQueenMove(from, to, m_piece[to]));
		}
	}
}


void
Board::generatePieceDropMoves(MoveList& result) const
{
	Material inHand = m_holding[m_stm];

	uint64_t free = ~m_occupied;

	if (inHand.piece)
	{
		while (free)
		{
			uint8_t to = lsbClear(free);

			if (inHand.queen)		result.append(Move::genPieceDrop(to, piece::Queen));
			if (inHand.rook)		result.append(Move::genPieceDrop(to, piece::Rook));
			if (inHand.bishop)	result.append(Move::genPieceDrop(to, piece::Bishop));
			if (inHand.knight)	result.append(Move::genPieceDrop(to, piece::Knight));
		}
	}

	if (inHand.pawn)
	{
		free = ~m_occupied & ~RankMask1 & ~RankMask8;

		while (free)
		{
			uint8_t to = lsbClear(free);
			result.append(Move::genPieceDrop(to, piece::Pawn));
		}
	}
}


void
Board::filterMoves(MoveList& list, unsigned state, variant::Type variant) const
{
	MoveList ml;

	for (Move* m = list.begin(); m != list.end(); ++m)
	{
		if ((checkState(*m, variant) & state))
			ml.append(*m);
	}

	if (!ml.isEmpty())
		list = ml;
}


char const*
Board::parseMove(char const* algebraic, Move& move, variant::Type variant, move::Constraint flag) const
{
	M_REQUIRE(algebraic);

	char const*	s = algebraic;
	unsigned		type;

	switch (*s)
	{
		case '-':
			if (*++s != '-')
				return 0;
			if (s[1] == '-' && s[2] == '-')	// "----" null move used in LAN
				s += 2;
			move = makeNullMove();
			return ++s;		// "--" null move used in ChessBase

		case '@':
			if (s[1] != '@')
				return parsePieceDrop(s + 1, move, variant, piece::Pawn, m_holding[m_stm].pawn, flag);
			if (s[2] != '@' || s[3] != '@')
				return 0;
			return s + 4;	// "@@@@" null move used in WinBoard protocol

		case 'n':
			if (s[1] != 'u' || s[2] != 'l' || s[3] != 'l')
				return 0;
			return s + 4;	// "null" null move used in WinBoard protocol

		case 'p':
			if (s[1] != 'a' || s[2] != 's' || s[3] != 's')
				return 0;
			return s + 4;	// "pass" null move used in WinBoard protocol

		case '0':
			if (s[1] != '0' || s[2] != '0' || s[3] != '0')
				return 0;
			move = makeNullMove();
			return s + 4;	// "0000" null move used in UCI protocol

		case 'O':	// Castling
			if (!variant::isAntichessExceptLosers(variant))
			{
				if (s[1] == '-' && s[2] == 'O')
				{
					M_ASSERT(kingOnBoard());

					unsigned index;

					if (s[3] == '-' && s[4] == 'O')
					{
						index = ::queenSideIndex(m_stm);
						s += 5;
					}
					else
					{
						index = ::kingSideIndex(m_stm);
						s += 3;
					}

					unsigned rook = m_castleRookCurrent[index];

					if (rook != Null)
					{
						move = prepareMove(m_ksq[m_stm], rook, variant, flag);
						return s;
					}
				}
			}
			return 0;

		// Piece

		case 'K':
			type = piece::King;
			++s;
			break;

		case 'Q':
			if (*++s == '@')
				return parsePieceDrop(s + 1, move, variant, piece::Queen, m_holding[m_stm].queen, flag);
			type = piece::Queen;
			break;

		case 'R':
			if (*++s == '@')
				return parsePieceDrop(s + 1, move, variant, piece::Rook, m_holding[m_stm].rook, flag);
			type = piece::Rook;
			break;

		case 'B':
			if (*++s == '@')
				return parsePieceDrop(s + 1, move, variant, piece::Bishop, m_holding[m_stm].bishop, flag);
			type = piece::Bishop;
			break;

		case 'N':
			if (*++s == '@')
				return parsePieceDrop(s + 1, move, variant, piece::Knight, m_holding[m_stm].knight, flag);
			type = piece::Knight;
			break;

		case 'P':
			if (*++s == '@')
				return parsePieceDrop(s + 1, move, variant, piece::Pawn, m_holding[m_stm].pawn, flag);
			type = piece::Pawn;
			break;

		default:
			type = piece::Pawn;
			break;
	}

	int fromSquare	= -1;
	int toSquare	= -1;
	int fromFyle	= -1;
	int fromRank	= -1;

	// Check for disambiguation
	if (::isFyle(*s))
	{
		fromFyle = ::toFyle(*s++);

		if (::isRank(*s))
		{
			fromSquare = ::mul8(::toRank(*s++)) + fromFyle;
			fromFyle = -1;
		}
	}
	else if (::isRank(*s))
	{
		fromRank = ::toRank(*s++);
	}

	// Capture indicator; dash in the case of a LAN move; colon is the german capture indicator
	if ((*s == 'x' || *s == '-' || *s == ':') && ::isFyle(s[1]))
		++s;

	// Destination square
	if (::isFyle(*s))
	{
		int toFyle = ::toFyle(*s++);

		if (::isRank(*s))
		{
			toSquare = ::mul8(::toRank(*s++)) + toFyle;
		}
		else
		{
			if (type != piece::Pawn)
				return 0;

			if (fromSquare < 0)	// handle pawn captures like 'ed'
			{
				M_ASSERT(fromFyle != -1);

				char const* t = ::skipPromotion(s);

				MoveList moveList;
				MoveList validList;
				generateCapturingPawnMoves(variant, moveList);

				for (Move* m = moveList.begin(); m != moveList.end(); ++m)
				{
					if (	::fyle(m->from()) == fromFyle
						&& ::fyle(m->to()) == toFyle
						&& (flag != move::DontAllowIllegalMove || checkIfLegalMove(*m)))
					{
						validList.push(*m);
					}
				}

				if (validList.isEmpty())
					return 0;

				if (!variant::isAntichessExceptLosers(variant))
				{
					if (validList.size() > 1)
					{
						if (*t == '#')
							filterMoves(validList, Checkmate, variant);

						if (validList.size() > 1)
						{
							if (t[0] == '+' && t[1] == '+')
								filterMoves(validList, DoubleCheck, variant);

							if (validList.size() > 1)
							{
								if (*t == '#' || *t == '+')
									filterMoves(validList, Check | Checkmate, variant);
							}
						}
					}
				}

				Move* m = validList.begin();

				fromSquare = m->from();
				toSquare = m->to();
			}
			else						// handle pawn captures like 'e4d'
			{
				int toSq1 = -1, toSq2 = -1;

				if (::fyle(fromSquare) > FyleA)
				{
					toSq1 = fromSquare + (m_stm == White ? +7 : -9);

					if (toSq1 >= 0)
					{
						Move move = prepareMove(fromSquare, toSq1, variant, flag);

						if (!move)
							toSq1 = -1;
					}
				}

				if (::fyle(fromSquare) < FyleH)
				{
					toSq2 = fromSquare + (m_stm == White ? +9 : -7);

					if (toSq2 >= 0)
					{
						Move move = prepareMove(fromSquare, toSq2, variant, flag);

						if (!move)
							toSq2 = -1;
					}
				}

				if ((toSquare = toSq1 == -1 ? toSq2 : toSq1) == -1)
					return 0;
			}
		}
	}
	else
	{
		toSquare = fromSquare;
		fromSquare = -1;
	}

	if (toSquare < 0)
		return 0;

	if (type == piece::Pawn)
	{
		if (fromSquare < 0)
		{
			int base = (m_stm == White ? -8 : 8);

			if (fromFyle < 0)
			{
				fromSquare = toSquare + base;

				if (!(m_occupiedBy[m_stm] & set1Bit(fromSquare)))
					fromSquare += base;
			}
			else if (fromFyle <= int(::fyle(toSquare)))
			{
				fromSquare = toSquare + base - 1;
			}
			else
			{
				fromSquare = toSquare + base + 1;
			}
		}

		move = prepareMove(fromSquare, toSquare, variant, flag);

		if (move.isPromotion())
		{
			// Promotion as in bc8Q, bxc8=Q, bxc8=(Q), bxc8(Q), bxc8/Q, or bxc8/(Q)
			if (*s == '=' || *s == '/')
				++s;

			if (*s == '(')
			{
				if (s[1] && s[2] == ')')
				{
					++s;
				}
				else
				{
					move.setPromoted(piece::Queen);
					if (s[-1] == '=')
						--s;
					return s;
				}
			}

			switch (*s++)
			{
				case 'Q': case 'q': move.setPromoted(piece::Queen);  break;
				case 'R': case 'r': move.setPromoted(piece::Rook);   break;
				case 'B': case 'b': move.setPromoted(piece::Bishop); break;
				case 'N': case 'n': move.setPromoted(piece::Knight); break;

				case 'K': case 'k':
					if (variant::isAntichessExceptLosers(variant))
					{
						move.setPromoted(piece::King);
					}
					else
					{
						if (s[-2] == '(')
							--s;
						return s[-2] == '=' ? s - 2 : s - 1;
					}
					break;

				default:
					move.setPromoted(piece::Queen);
					if (s[-2] == '(')
						--s;
					return s[-2] == '=' ? s - 2 : s - 1;
			}
		}

		if (s[-2] == '(')
			++s;

		return s;
	}

	if (fromSquare < 0)
	{
		uint64_t match;

		switch (type)
		{
			case piece::Queen:	match = queenAttacks(toSquare) & m_queens; break;
			case piece::Rook:		match = rookAttacks(toSquare) & m_rooks; break;
			case piece::Bishop:	match = bishopAttacks(toSquare) & m_bishops; break;
			case piece::Knight:	match = knightAttacks(toSquare) & m_knights; break;
			case piece::King:		match = kingAttacks(toSquare) & m_kings; break;
			default:					return 0;
		}

		match &= m_occupiedBy[m_stm];

		if (fromRank >= 0)
			match &= RankMask[fromRank];
		else if (fromFyle >= 0)
			match &= FyleMask[fromFyle];

		if (!variant::isAntichessExceptLosers(variant))
		{
			// If not yet fully disambiguated, all but one move must be illegal.
			// Cycle through them, and pick the first legal move.

			// Only mating moves will be regarded.
			if (*s == '#')
			{
				uint64_t m = match;

				while (m)
				{
					fromSquare = lsbClear(m);

					M_ASSERT(type == m_piece[fromSquare]);

					move = prepareMove(fromSquare, toSquare, variant, flag);

					if (move.isLegal() && (checkState(move, variant) & Checkmate))
						return s;
				}
			}

			// Only double checking moves will be regarded.
			if (s[0] == '+' && s[1] == '+')
			{
				uint64_t m = match;

				while (m)
				{
					fromSquare = lsbClear(m);

					M_ASSERT(type == m_piece[fromSquare]);

					move = prepareMove(fromSquare, toSquare, variant, flag);

					if (move.isLegal())
					{
						Board peek(*this);
						peek.doMove(move, variant);

						if (peek.countChecks() > 1)
							return s;
					}
				}
			}

			// Only checking moves will be regarded.
			if (*s == '#' || *s == '+')
			{
				uint64_t m = match;

				while (m)
				{
					fromSquare = lsbClear(m);

					M_ASSERT(type == m_piece[fromSquare]);

					move = prepareMove(fromSquare, toSquare, variant, flag);

					if (move.isLegal())
					{
						Board peek(*this);
						peek.doMove(move, variant);

						if (peek.countChecks() > 0)
							return s;
					}
				}
			}
		}

		// All moves will be regarded.
		while (match)
		{
			fromSquare = lsbClear(match);

			M_ASSERT(type == m_piece[fromSquare]);

			move = prepareMove(fromSquare, toSquare, variant, flag);

			if (move.isLegal())
				return s;
		}

		// probably a castling move is desired
		if (type == piece::King)
		{
			if (canCastleShort(color::ID(m_stm)) && toSquare == m_castleRookCurrent[::kingSideIndex(m_stm)])
			{
				M_ASSERT(kingOnBoard());
				move = prepareMove(m_ksq[m_stm], toSquare, variant, flag);
				return s;
			}

			if (canCastleLong(color::ID(m_stm)) && toSquare == m_castleRookCurrent[::queenSideIndex(m_stm)])
			{
				M_ASSERT(kingOnBoard());
				move = prepareMove(m_ksq[m_stm], toSquare, variant, flag);
				return s;
			}

			switch (toSquare)
			{
				case c1:
					if (whiteToMove() && canCastleLong(White))
					{
						M_ASSERT(kingOnBoard());
						move = prepareMove(	m_ksq[White],
													m_castleRookCurrent[::queenSideIndex(White)],
													variant,
													flag);
						return s;
					}
					break;

				case g1:
					if (whiteToMove() && canCastleShort(White))
					{
						M_ASSERT(kingOnBoard());
						move = prepareMove(	m_ksq[White],
													m_castleRookCurrent[::kingSideIndex(White)],
													variant,
													flag);
						return s;
					}
					break;

				case c8:
					if (blackToMove() && canCastleLong(Black))
					{
						M_ASSERT(kingOnBoard());
						move = prepareMove(	m_ksq[Black],
													m_castleRookCurrent[::queenSideIndex(Black)],
													variant,
													flag);
						return s;
					}
					break;

				case g8:
					if (blackToMove() && canCastleShort(Black))
					{
						M_ASSERT(kingOnBoard());
						move = prepareMove(	m_ksq[Black],
													m_castleRookCurrent[::kingSideIndex(Black)],
													variant,
													flag);
						return s;
					}
					break;
			}
		}

		return s;
	}

	if (type == m_piece[fromSquare])
		move = prepareMove(fromSquare, toSquare, variant, flag);

	return s;
}


char const*
Board::parsePieceDrop(	char const* s,
								Move& move,
								variant::Type variant,
								piece::Type pieceType,
								unsigned count,
								move::Constraint flag) const
{
	M_ASSERT(	pieceType == piece::Queen
				|| pieceType == piece::Rook
				|| pieceType == piece::Bishop
				|| pieceType == piece::Knight
				|| pieceType == piece::Pawn);

	if (!variant::isZhouse(variant))
		return 0;

	if (!isFyle(*s))
		return 0;

	int fromFyle = ::toFyle(*s++);

	if (!isRank(*s))
		return 0;

	int to = ::mul8(::toRank(*s++)) + fromFyle;

	if (m_occupied & set1Bit(to))
		return 0;

	move = Move::genPieceDrop(to, pieceType);
	prepareMove(move, variant, flag);

	if (count == 0)
	{
		if (flag == move::DontAllowIllegalMove)
			return 0;

		move.setIllegalMove();
	}

	return s;
}


char const*
Board::parseLAN(char const* s, Move& move, move::Constraint flag) const
{
	// IMPORTANT NOTE: should be used only for normal chess.

	M_REQUIRE(s);

	if (*s == '0')
	{
		// "0000" null move used in UCI protocol
		if (s[1] != '0' || s[2] != '0' || s[3] != '0')
			return 0;
		move = makeNullMove();
		return s + 4;
	}

	if (!isFyle(*s))
		return 0;

	int fromFyle = ::toFyle(*s++);

	if (!isRank(*s))
		return 0;

	int fromRank = ::toRank(*s++);

	if (!isFyle(*s))
		return 0;

	int toFyle = ::toFyle(*s++);

	if (!isRank(*s))
		return 0;

	int toRank = ::toRank(*s++);

	if (!(move = prepareMove(	sq::make(fromFyle, fromRank),
										sq::make(toFyle, toRank),
										variant::Normal,
										flag)))
	{
		return 0;
	}

	if (move.isPromotion())
	{
		switch (*s++)
		{
			case 'Q': case 'q':	move.setPromoted(piece::Queen);  break;
			case 'R': case 'r':	move.setPromoted(piece::Rook);   break;
			case 'B': case 'b':	move.setPromoted(piece::Bishop); break;
			case 'N': case 'n':	move.setPromoted(piece::Knight); break;
			default:					return 0;
		}
	}

	return s;
}


void
Board::restoreCastlingRights(uint8_t prevCastlingRights)
{
	uint8_t castling = prevCastlingRights ^ m_castle;

	while (castling)
	{
		Index index = Index(lsbClear(castling));
		m_castleRookCurrent[index] = m_castleRookAtStart[index];
		hashCastling(index);
	}

	m_castle = prevCastlingRights;
}


void
Board::restoreStates(Move const& m)
{
	m_halfMoveClock = m.prevHalfMoves();
	m_capturePromoted = m.prevCapturePromoted();
	m_epSquare = m.prevEpSquare();

	if (m_epSquare != Null)
		hashEnPassant();
}


void
Board::doMove(Move const& m, variant::Type variant)
{
	M_REQUIRE(!m.isEmpty());
	M_REQUIRE(variant != variant::Bughouse || hasPartnerBoard());

	m_capturePromoted = false;

	if (m_epSquare != Null)
	{
		hashEnPassant();
		m_epSquare = Null;
	}

	unsigned from		= m.from();
	unsigned to			= m.to();
	unsigned sntm		= m_stm ^ 1; // side not to move
	uint64_t fromMask	= set1Bit(from);
	uint64_t toMask	= set1Bit(to);
	uint64_t bothMask	= fromMask ^ toMask;

	switch (m.action())
	{
		case Move::Null_Move:
			swapToMove();
			++m_plyNumber;
			return;

		case Move::One_Forward:
			m_halfMoveClock = 0;
			m_pawns ^= bothMask;
			m_piece[to] = piece::Pawn;
			pawnProgressMove(m_stm, from, to);
			hashPawn(from, to, ::toPiece(piece::Pawn, m_stm));
			break;

		case Move::Two_Forward:
			m_halfMoveClock = 0;
			m_pawns ^= bothMask;
			m_piece[to] = piece::Pawn;
			pawnProgressMove(m_stm, from, to);
			hashPawn(from, to, ::toPiece(piece::Pawn, m_stm));
			setEnPassantFyle(color::ID(sntm), sq::fyle(to));
			break;

		case piece::Knight:
			++m_halfMoveClock;
			m_knights ^= bothMask;
			m_piece[to] = piece::Knight;
			hashPiece(from, to, ::toPiece(piece::Knight, m_stm));
			if (m_promoted[m_stm] & fromMask)
				m_promoted[m_stm] ^= bothMask;
			break;

		case piece::Bishop:
			++m_halfMoveClock;
			m_bishops ^= bothMask;
			m_piece[to] = piece::Bishop;
			hashPiece(from, to, ::toPiece(piece::Bishop, m_stm));
			if (m_promoted[m_stm] & fromMask)
				m_promoted[m_stm] ^= bothMask;
			break;

		case piece::Rook:
			++m_halfMoveClock;
			m_rooks ^= bothMask;
			m_piece[to] = piece::Rook;
			hashPiece(from, to, ::toPiece(piece::Rook, m_stm));
			{
				Byte castling = m_destroyCastle[from];
				if (m_castle & ~castling)
				{
					Index index = Index(lsb(uint8_t(~castling)));
					hashCastling(index);
					m_castle &= castling;
					m_castleRookCurrent[index] = Null;
				}
			}
			if (m_promoted[m_stm] & fromMask)
				m_promoted[m_stm] ^= bothMask;
			break;

		case piece::Queen:
			++m_halfMoveClock;
			m_queens ^= bothMask;
			m_piece[to] = piece::Queen;
			hashPiece(from, to, ::toPiece(piece::Queen, m_stm));
			if (m_promoted[m_stm] & fromMask)
				m_promoted[m_stm] ^= bothMask;
			break;

		case piece::King:
			M_ASSERT(m_kings & m_occupiedBy[m_stm]);
			++m_halfMoveClock;
			m_kings ^= bothMask;
			m_ksq[m_stm] = to;
			m_piece[to] = piece::King;
			hashPiece(from, to, ::toPiece(piece::King, m_stm));
			++m_kingHasMoved[m_stm];
			if (canCastle(color::ID(m_stm)))
			{
				hashCastling(color::ID(m_stm));
				destroyCastle(color::ID(m_stm));
				m_castleRookCurrent[::kingSideIndex(m_stm)] = Null;
				m_castleRookCurrent[::queenSideIndex(m_stm)] = Null;
			}
			break;

		case Move::Castle:
		{
			M_ASSERT(kingOnBoard());
			M_ASSERT(from == m_ksq[m_stm]);
			M_ASSERT(!variant::isAntichessExceptLosers(variant));

			++m_halfMoveClock;

			unsigned rank		= ::rank(to);
			unsigned rookFrom	= to;
			unsigned rookTo;

			hashCastling(color::ID(m_stm));
			destroyCastle(color::ID(m_stm));
			m_castleRookCurrent[::kingSideIndex(m_stm)] = Null;
			m_castleRookCurrent[::queenSideIndex(m_stm)] = Null;

			if (from < to)
			{
				addCastling(kingSide(color::ID(m_stm)));
				rookTo = sq::make(FyleF, rank);
				to = sq::make(FyleG, rank);
			}
			else
			{
				addCastling(queenSide(color::ID(m_stm)));
				rookTo = sq::make(FyleD, rank);
				to = sq::make(FyleC, rank);
			}

			uint64_t rookSrc = m_occupiedBy[m_stm] & set1Bit(rookFrom);

			// in Chess 960 the king may stand still
			if (to != m_ksq[m_stm])
			{
				bothMask = fromMask ^ set1Bit(to);
				m_ksq[m_stm] = to;
				m_kings ^= bothMask;
				m_piece[from] = piece::None;
				hashPiece(from, to, ::toPiece(piece::King, m_stm));

				m_occupiedBy[m_stm] ^= bothMask;
				m_occupiedL90 ^= MaskL90[from] ^ MaskL90[to];
				m_occupiedL45 ^= MaskL45[from] ^ MaskL45[to];
				m_occupiedR45 ^= MaskR45[from] ^ MaskR45[to];
			}

			// in handicap games the rook field is possibly empty
			// (but probably occupied by another piece)
			if (m_piece[rookFrom] == piece::Rook && rookSrc)
			{
				uint64_t rookMask = set1Bit(rookFrom) ^ set1Bit(rookTo);

				m_piece[rookFrom] = piece::None;
				m_piece[rookTo] = piece::Rook;
				m_rooks ^= rookMask;
				m_occupiedBy[m_stm] ^= rookMask;
				m_occupiedL90 ^= MaskL90[rookFrom] ^ MaskL90[rookTo];
				m_occupiedL45 ^= MaskL45[rookFrom] ^ MaskL45[rookTo];
				m_occupiedR45 ^= MaskR45[rookFrom] ^ MaskR45[rookTo];
				hashPiece(rookFrom, rookTo, ::toPiece(piece::Rook, m_stm));
			}

			m_piece[to] = piece::King;
			m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];

			if (variant == variant::ThreeCheck && givesCheck())
			{
				M_ASSERT(m_checksGiven[m_stm] < 3);
				hashChecksGiven(m_stm, m_checksGiven[m_stm]++);
			}

			swapToMove();
			++m_plyNumber;
			return;
		}

		case Move::Promote:
			static_assert(sizeof(m_progress.side[0].rank) < 7, "reimplement pawn progress");
			m_halfMoveClock = 0;
			m_pawns ^= fromMask;
			++m_promotions;
			decrMaterial<piece::Pawn>(m_stm);
			hashPawn(from, ::toPiece(piece::Pawn, m_stm));

			switch (Byte(m.promoted()))
			{
				case piece::Knight:
					m_knights ^= toMask;
					m_piece[to] = piece::Knight;
					++m_underPromotions;
					incrMaterial<piece::Knight>(m_stm);
					hashPromotedPiece(to, ::toPiece(piece::Knight, m_stm), variant);
					m_promoted[m_stm] ^= toMask;
					break;

				case piece::Bishop:
					m_bishops ^= toMask;
					m_piece[to] = piece::Bishop;
					++m_underPromotions;
					incrMaterial<piece::Bishop>(m_stm);
					hashPromotedPiece(to, ::toPiece(piece::Bishop, m_stm), variant);
					m_promoted[m_stm] ^= toMask;
					break;

				case piece::Rook:
					m_rooks ^= toMask;
					m_piece[to] = piece::Rook;
					++m_underPromotions;
					incrMaterial<piece::Rook>(m_stm);
					hashPromotedPiece(to, ::toPiece(piece::Rook, m_stm), variant);
					m_promoted[m_stm] ^= toMask;
					break;

				case piece::Queen:
					m_queens ^= toMask;
					m_piece[to] = piece::Queen;
					incrMaterial<piece::Queen>(m_stm);
					hashPromotedPiece(to, ::toPiece(piece::Queen, m_stm), variant);
					m_promoted[m_stm] ^= toMask;
					break;

				case piece::King:
					M_ASSERT(variant::isAntichessExceptLosers(variant));
					m_kings ^= toMask;
					m_piece[to] = piece::King;
					incrMaterial<piece::King>(m_stm);
					hashPiece(to, ::toPiece(piece::King, m_stm));
					break;
			}
			break;

			case Move::PieceDrop:
				M_ASSERT(variant::isZhouse(variant));
				switch (Byte(m.dropped()))
				{
					case piece::Pawn:
						m_pawns ^= toMask;
						m_piece[to] = piece::Pawn;
						incrMaterial<piece::Pawn>(m_stm);
						hashPawn(to, ::toPiece(piece::Pawn, m_stm));
						removeFromMyHolding<piece::Pawn>(variant, m_stm);
						break;

					case piece::Knight:
						m_knights ^= toMask;
						m_piece[to] = piece::Knight;
						incrMaterial<piece::Knight>(m_stm);
						hashPiece(to, ::toPiece(piece::Knight, m_stm));
						removeFromMyHolding<piece::Knight>(variant, m_stm);
						break;

					case piece::Bishop:
						m_bishops ^= toMask;
						m_piece[to] = piece::Bishop;
						incrMaterial<piece::Bishop>(m_stm);
						hashPiece(to, ::toPiece(piece::Bishop, m_stm));
						removeFromMyHolding<piece::Bishop>(variant, m_stm);
						break;

					case piece::Rook:
						m_rooks ^= toMask;
						m_piece[to] = piece::Rook;
						incrMaterial<piece::Rook>(m_stm);
						hashPiece(to, ::toPiece(piece::Rook, m_stm));
						removeFromMyHolding<piece::Rook>(variant, m_stm);
						if (m_kingHasMoved[m_stm] == 0)
						{
							unsigned index = ::kingSideIndex(m_stm);
							if (to == m_castleRookAtStart[index])
							{
								m_castleRookCurrent[index] = to;
								m_castle |= kingSide(color::ID(m_stm));
								hashCastling(Index(index));
							}
							else
							{
								unsigned index = ::queenSideIndex(m_stm);
								if (to == m_castleRookAtStart[index])
								{
									m_castleRookCurrent[index] = to;
									m_castle |= queenSide(color::ID(m_stm));
									hashCastling(Index(index));
								}
							}
						}
						break;

					case piece::Queen:
						m_queens ^= toMask;
						m_piece[to] = piece::Queen;
						incrMaterial<piece::Queen>(m_stm);
						hashPiece(to, ::toPiece(piece::Queen, m_stm));
						removeFromMyHolding<piece::Queen>(variant, m_stm);
						break;
				}

				m_occupiedL90 ^= MaskL90[to];
				m_occupiedL45 ^= MaskL45[to];
				m_occupiedR45 ^= MaskR45[to];
				m_occupiedBy[m_stm] ^= toMask;
				m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];
				swapToMove();
				++m_plyNumber;
				return;
	}

	switch (m.removal())
	{
		case piece::None:
			// extra cleanup needed for non-captures
			m_occupiedL90 ^= MaskL90[to];
			m_occupiedL45 ^= MaskL45[to];
			m_occupiedR45 ^= MaskR45[to];
			break;

		case piece::Pawn:
			m_halfMoveClock = 0;
			m_pawns ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			pawnProgressRemove(sntm, to);
			decrMaterial<piece::Pawn>(sntm);
			hashPawn(to, ::toPiece(piece::Pawn, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Pawn>(variant, sntm);
			break;

		case piece::Knight:
			m_halfMoveClock = 0;
			m_knights ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			decrMaterial<piece::Knight>(sntm);
			hashPiece(to, ::toPiece(piece::Knight, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Knight>(toMask, variant, sntm);
			break;

		case piece::Bishop:
			m_halfMoveClock = 0;
			m_bishops ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			decrMaterial<piece::Bishop>(sntm);
			hashPiece(to, ::toPiece(piece::Bishop, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Bishop>(toMask, variant, sntm);
			break;

		case piece::Rook:
			m_halfMoveClock = 0;
			m_rooks ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			{
				Byte castling = m_destroyCastle[to];
				if (m_castle & ~castling)
				{
					Index index = Index(lsb(uint8_t(~castling)));
					hashCastling(index);
					m_castle &= castling;
					m_castleRookCurrent[index] = Null;
				}
			}
			decrMaterial<piece::Rook>(sntm);
			hashPiece(to, ::toPiece(piece::Rook, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Rook>(toMask, variant, sntm);
			break;

		case piece::Queen:
			m_halfMoveClock = 0;
			m_queens ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			decrMaterial<piece::Queen>(sntm);
			hashPiece(to, ::toPiece(piece::Queen, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Queen>(toMask, variant, sntm);
			break;

		case piece::King:
			M_ASSERT(variant::isAntichessExceptLosers(variant));
			m_halfMoveClock = 0;
			m_kings ^= toMask;
			m_occupiedBy[sntm] ^= toMask;
			decrMaterial<piece::King>(sntm);
			hashPiece(to, ::toPiece(piece::King, sntm));
			break;

		case Move::En_Passant:
			m_halfMoveClock = 0;
			// annoying move, the capture is not on the 'to' square
			unsigned epsq = PrevRank[m_stm][to];
			m_piece[epsq] = piece::None;
			m_pawns ^= set1Bit(epsq);
			m_occupiedBy[sntm] ^= set1Bit(epsq);
			m_occupiedL90 ^= MaskL90[to] ^ MaskL90[epsq];
			m_occupiedL45 ^= MaskL45[to] ^ MaskL45[epsq];
			m_occupiedR45 ^= MaskR45[to] ^ MaskR45[epsq];
			decrMaterial<piece::Pawn>(sntm);
			pawnProgressRemove(sntm, epsq);
			hashPawn(epsq, ::toPiece(piece::Pawn, sntm));
			if (variant::isZhouse(variant))
				m_partner->addToHolding<piece::Pawn>(variant, sntm);
			break;
	}
	// ...no we did not forget the king!

	m_piece[from] = piece::None;
	m_occupiedBy[m_stm] ^= bothMask;
	m_occupiedL90 ^= MaskL90[from];
	m_occupiedL45 ^= MaskL45[from];
	m_occupiedR45 ^= MaskR45[from];
	m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];

	if (variant == variant::ThreeCheck && givesCheck())
	{
		M_ASSERT(m_checksGiven[m_stm] < 3);
		hashChecksGiven(m_stm, m_checksGiven[m_stm]++);
	}

	swapToMove();
	++m_plyNumber;
}


void
Board::undoMove(Move const& m, variant::Type variant)
{
	M_REQUIRE(!m.isEmpty());
	M_REQUIRE(m.preparedForUndo());
	M_REQUIRE(variant != variant::Bughouse || hasPartnerBoard());

	unsigned from		= m.from();
	unsigned to			= m.to();
	unsigned sntm		= m_stm ^ 1;		// side not to move
	uint64_t fromMask	= set1Bit(from);
	uint64_t toMask	= set1Bit(to);
	uint64_t bothMask	= fromMask ^ toMask;

	if (variant == variant::ThreeCheck && isInCheck())
	{
		M_ASSERT(m_checksGiven[sntm] > 0);
		hashChecksGiven(sntm, --m_checksGiven[sntm]);
	}

	switch (m.action())
	{
		case Move::Null_Move:
			swapToMove();
			--m_plyNumber;
			return;

		case Move::One_Forward:
			m_pawns ^= bothMask;
			m_piece[from] = piece::Pawn;
			pawnProgressMove(sntm, to, from);
			hashPawn(from, to, ::toPiece(piece::Pawn, sntm));
			break;

		case Move::Two_Forward:
			m_pawns ^= bothMask;
			m_piece[from] = piece::Pawn;
			pawnProgressMove(sntm, to, from);
			hashPawn(from, to, ::toPiece(piece::Pawn, sntm));
			if (m_epSquare != Null)
				hashEnPassant();
			break;

		case piece::Knight:
			m_knights ^= bothMask;
			m_piece[from] = piece::Knight;
			hashPiece(from, to, ::toPiece(piece::Knight, sntm));
			if (m_promoted[sntm] & toMask)
				m_promoted[sntm] ^= bothMask;
			break;

		case piece::Bishop:
			m_bishops ^= bothMask;
			m_piece[from] = piece::Bishop;
			hashPiece(from, to, ::toPiece(piece::Bishop, sntm));
			if (m_promoted[sntm] & toMask)
				m_promoted[sntm] ^= bothMask;
			break;

		case piece::Rook:
			m_rooks ^= bothMask;
			m_piece[from] = piece::Rook;
			hashPiece(from, to, ::toPiece(piece::Rook, sntm));
			if (m_promoted[sntm] & toMask)
				m_promoted[sntm] ^= bothMask;
			break;

		case piece::Queen:
			m_queens ^= bothMask;
			m_piece[from] = piece::Queen;
			hashPiece(from, to, ::toPiece(piece::Queen, sntm));
			if (m_promoted[sntm] & toMask)
				m_promoted[sntm] ^= bothMask;
			break;

		case piece::King:
		{
			m_kings ^= bothMask;
			m_piece[from] = piece::King;
			m_ksq[sntm] = from;
			hashPiece(from, to, ::toPiece(piece::King, sntm));
			--m_kingHasMoved[m_stm];
			uint8_t prevCastlingRights = m.prevCastlingRights();
			if (prevCastlingRights & kingSide(color::ID(sntm)))
			{
				unsigned index = ::kingSideIndex(sntm);
				m_castleRookCurrent[index] = m_castleRookAtStart[index];
			}
			if (prevCastlingRights & queenSide(color::ID(sntm)))
			{
				unsigned index = ::queenSideIndex(sntm);
				m_castleRookCurrent[index] = m_castleRookAtStart[index];
			}
			break;
		}

		case Move::Castle:
		{
			unsigned rank		= ::rank(to);
			unsigned rookFrom	= to;
			unsigned rookTo;

			if (from < to)
			{
				removeCastling(kingSide(color::ID(sntm)));
				rookTo = sq::make(FyleF, rank);
				to = sq::make(FyleG, rank);
			}
			else
			{
				removeCastling(queenSide(color::ID(sntm)));
				rookTo = sq::make(FyleD, rank);
				to = sq::make(FyleC, rank);
			}

			// we have to take into account that the castling was potentially illegal
			uint8_t prevCastlingRights = m.prevCastlingRights();

			if (prevCastlingRights & kingSide(color::ID(sntm)))
			{
				unsigned index = ::kingSideIndex(sntm);
				m_castleRookCurrent[index] = m_castleRookAtStart[index];
			}
			if (prevCastlingRights & queenSide(color::ID(sntm)))
			{
				unsigned index = ::queenSideIndex(sntm);
				m_castleRookCurrent[index] = m_castleRookAtStart[index];
			}

			uint64_t rookSrc = m_occupiedBy[sntm] & set1Bit(rookTo);

			// in Chess 960 the king may stand still
			if (from != m_ksq[sntm])
			{
				bothMask = fromMask ^ set1Bit(to);
				m_kings ^= bothMask;
				m_piece[to] = piece::None;
				m_ksq[sntm] = from;
				hashPiece(from, to, ::toPiece(piece::King, sntm));

				m_occupiedBy[sntm] ^= bothMask;
				m_occupiedL90 ^= MaskL90[from] ^ MaskL90[to];
				m_occupiedL45 ^= MaskL45[from] ^ MaskL45[to];
				m_occupiedR45 ^= MaskR45[from] ^ MaskR45[to];
			}

			// in handicap games the rook field is possibly empty
			// (but probably occupied by another piece)
			if (m_piece[rookTo] == piece::Rook && rookSrc)
			{
				uint64_t rookMask = set1Bit(rookFrom) ^ set1Bit(rookTo);

				m_piece[rookTo] = piece::None;
				m_piece[rookFrom] = piece::Rook;
				m_rooks ^= rookMask;
				m_occupiedBy[sntm] ^= rookMask;
				m_occupiedL90 ^= MaskL90[rookFrom] ^ MaskL90[rookTo];
				m_occupiedL45 ^= MaskL45[rookFrom] ^ MaskL45[rookTo];
				m_occupiedR45 ^= MaskR45[rookFrom] ^ MaskR45[rookTo];
				hashPiece(rookFrom, rookTo, ::toPiece(piece::Rook, sntm));
			}

			m_piece[from] = piece::King;
			m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];
			restoreCastlingRights(m.prevCastlingRights());
			restoreStates(m);
			swapToMove();
			--m_plyNumber;
			return;
		}

		case Move::Promote:
			static_assert(sizeof(m_progress.side[0].rank) < 7, "reimplement pawn progress");
			m_pawns ^= fromMask;
			m_piece[from] = piece::Pawn;
			--m_promotions;
			incrMaterial<piece::Pawn>(sntm);
			hashPawn(from, ::toPiece(piece::Pawn, sntm));

			switch (m.promoted())
			{
				case piece::Knight:
					m_knights ^= toMask;
					--m_underPromotions;
					decrMaterial<piece::Knight>(sntm);
					hashPromotedPiece(to, ::toPiece(piece::Knight, sntm), variant);
					m_promoted[sntm] ^= toMask;
					break;

				case piece::Bishop:
					m_bishops ^= toMask;
					--m_underPromotions;
					decrMaterial<piece::Bishop>(sntm);
					hashPromotedPiece(to, ::toPiece(piece::Bishop, sntm), variant);
					m_promoted[sntm] ^= toMask;
					break;

				case piece::Rook:
					m_rooks ^= toMask;
					--m_underPromotions;
					decrMaterial<piece::Rook>(sntm);
					hashPromotedPiece(to, ::toPiece(piece::Rook, sntm), variant);
					m_promoted[sntm] ^= toMask;
					break;

				case piece::Queen:
					m_queens ^= toMask;
					decrMaterial<piece::Queen>(sntm);
					hashPromotedPiece(to, ::toPiece(piece::Queen, sntm), variant);
					m_promoted[sntm] ^= toMask;
					break;

				case piece::King:
					m_kings ^= toMask;
					decrMaterial<piece::King>(sntm);
					hashPiece(to, ::toPiece(piece::King, sntm));
					break;

				default:
					break;
			}
			break;

		case Move::PieceDrop:
			switch (Byte(m.dropped()))
			{
				case piece::Pawn:
					m_pawns ^= toMask;
					decrMaterial<piece::Pawn>(sntm);
					hashPawn(to, ::toPiece(piece::Pawn, sntm));
					addToMyHolding<piece::Pawn>(variant, sntm);
					break;

				case piece::Knight:
					m_knights ^= toMask;
					decrMaterial<piece::Knight>(sntm);
					hashPiece(to, ::toPiece(piece::Knight, sntm));
					addToMyHolding<piece::Knight>(variant, sntm);
					break;

				case piece::Bishop:
					m_bishops ^= toMask;
					decrMaterial<piece::Bishop>(sntm);
					hashPiece(to, ::toPiece(piece::Bishop, sntm));
					addToMyHolding<piece::Bishop>(variant, sntm);
					break;

				case piece::Rook:
					m_rooks ^= toMask;
					decrMaterial<piece::Rook>(sntm);
					hashPiece(to, ::toPiece(piece::Rook, sntm));
					addToMyHolding<piece::Rook>(variant, sntm);
					if (m_kingHasMoved[sntm] == 0)
					{
						unsigned index = ::kingSideIndex(sntm);
						if (to == m_castleRookAtStart[index])
						{
							m_castleRookCurrent[index] = Null;
							m_castle &= ~kingSide(color::ID(sntm));
							hashCastling(Index(index));
						}
						else
						{
							unsigned index = ::queenSideIndex(sntm);
							if (to == m_castleRookAtStart[index])
							{
								m_castleRookCurrent[index] = Null;
								m_castle &= ~queenSide(color::ID(sntm));
								hashCastling(Index(index));
							}
						}
					}
					break;

				case piece::Queen:
					m_queens ^= toMask;
					decrMaterial<piece::Queen>(sntm);
					hashPiece(to, ::toPiece(piece::Queen, sntm));
					addToMyHolding<piece::Queen>(variant, sntm);
					break;
			}

			m_piece[to] = piece::None;
			m_occupiedL90 ^= MaskL90[to];
			m_occupiedL45 ^= MaskL45[to];
			m_occupiedR45 ^= MaskR45[to];
			m_occupiedBy[sntm] ^= toMask;
			m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];
			restoreCastlingRights(m.prevCastlingRights());
			restoreStates(m);
			swapToMove();
			--m_plyNumber;
			return;
	}

	// Reverse captures
	unsigned replace = m.capturedType();

	switch (m.removal())
	{
		case piece::None:
			// extra cleanup needed for non-captures
			m_occupiedL90 ^= MaskL90[to];
			m_occupiedL45 ^= MaskL45[to];
			m_occupiedR45 ^= MaskR45[to];
			break;

		case piece::Pawn:
			m_pawns ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			pawnProgressAdd(m_stm, to);
			incrMaterial<piece::Pawn>(m_stm);
			hashPawn(to, ::toPiece(piece::Pawn, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Pawn>(variant, m_stm);
			break;

		case piece::Knight:
			m_knights ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			incrMaterial<piece::Knight>(m_stm);
			hashPiece(to, ::toPiece(piece::Knight, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Knight>(toMask, variant, m_stm);
			break;

		case piece::Bishop:
			m_bishops ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			incrMaterial<piece::Bishop>(m_stm);
			hashPiece(to, ::toPiece(piece::Bishop, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Bishop>(toMask, variant, m_stm);
			break;

		case piece::Rook:
			m_rooks ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			incrMaterial<piece::Rook>(m_stm);
			hashPiece(to, ::toPiece(piece::Rook, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Rook>(toMask, variant, m_stm);
			break;

		case piece::Queen:
			m_queens ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			incrMaterial<piece::Queen>(m_stm);
			hashPiece(to, ::toPiece(piece::Queen, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Queen>(toMask, variant, m_stm);
			break;

		case piece::King:
			m_kings ^= toMask;
			m_occupiedBy[m_stm] ^= toMask;
			incrMaterial<piece::King>(m_stm);
			hashPiece(to, ::toPiece(piece::King, m_stm));
			break;

		case Move::En_Passant:
			replace = piece::None;
			// annoying move, the capture is not on the 'to' square
			unsigned epsq = PrevRank[sntm][to];
			m_piece[epsq] = piece::Pawn;
			m_pawns ^= set1Bit(epsq);
			m_occupiedBy[m_stm] ^= set1Bit(epsq);
			m_occupiedL90 ^= MaskL90[to] ^ MaskL90[epsq];
			m_occupiedL45 ^= MaskL45[to] ^ MaskL45[epsq];
			m_occupiedR45 ^= MaskR45[to] ^ MaskR45[epsq];
			incrMaterial<piece::Pawn>(m_stm);
			pawnProgressAdd(m_stm, epsq);
			hashPawn(epsq, ::toPiece(piece::Pawn, m_stm));
			if (variant::isZhouse(variant))
				m_partner->removeFromHolding<piece::Pawn>(variant, m_stm);
			break;
	}
	// ...no we did not forget the king!

	m_piece[to] = replace;
	m_occupiedBy[sntm] ^= bothMask;
	m_occupiedL90 ^= MaskL90[from];
	m_occupiedL45 ^= MaskL45[from];
	m_occupiedR45 ^= MaskR45[from];
	m_occupied = m_occupiedBy[White] | m_occupiedBy[Black];
	restoreCastlingRights(m.prevCastlingRights());

	restoreStates(m);
	swapToMove();
	--m_plyNumber;
}


uint64_t
Board::pawnMovesFrom(Square s) const
{
	uint64_t targets = PawnF1[m_stm][s] & ~m_occupied;

	if (targets)
		targets |= PawnF2[m_stm][s] & ~m_occupied;

	uint64_t t = m_occupiedBy[m_stm ^ 1];

	if (m_epSquare != Null)
		t |= set1Bit(m_epSquare);

	return targets | (t & PawnAttacks[m_stm][s]);
}


uint64_t
Board::pawnCapturesTo(Square s) const
{
	uint64_t attackers	= 0;
	uint64_t destination	= set1Bit(s);

	if (m_stm == White)
	{
		// en passant moves
		if (m_epSquare != Null)
			attackers |= PawnAttacks[Black][m_epSquare];

		// captures
		attackers |= ::shiftDownRight(destination);
		attackers |= ::shiftDownLeft(destination);
		attackers &= m_occupiedBy[White];
	}
	else
	{
		// en passant moves
		if (m_epSquare != Null)
			attackers |= PawnAttacks[White][m_epSquare];

		// captures
		attackers |= ::shiftUpLeft(destination);
		attackers |= ::shiftUpRight(destination);
		attackers &= m_occupiedBy[Black];
	}

	return attackers & m_pawns;
}


bool
Board::checkMove(Move const& move, variant::Type variant, move::Constraint flag) const
{
	if (move.isEmpty())
		return false;

// Conflict with generateMoves():
//	if (move.color() != m_stm)
//		return false;

	if (checkState(variant) & (Checkmate | ThreeChecks | Stalemate | Losing))
		return false;

	if (move.isNull())
		return true;

	Square from = move.from();

	if (from == Null)
		return false;
	if (piece(from) != move.pieceMoved())
		return false;

	uint64_t src = set1Bit(from);

	if (!(m_occupiedBy[m_stm] & src) && !move.isPieceDrop())
		return false;

	Square to = move.to();

	if (to == Null)
		return false;

	uint64_t dst = set1Bit(to);

	if (m_occupiedBy[m_stm] & dst)
	{
		if (move.action() != Move::Castle)
			return false;

		if (variant::isAntichessExceptLosers(variant))
			return false;

		if (move.isShortCastling())
		{
			if (m_castleRookCurrent[::kingSideIndex(m_stm)] == Null)
				return flag == move::AllowIllegalMove;

			if (flag == move::AllowIllegalMove)
				return shortCastlingIsPossible();

			return canCastleShort(sideToMove()) && shortCastlingIsLegal();
		}

		if (m_castleRookCurrent[::queenSideIndex(m_stm)] == Null)
			return flag == move::AllowIllegalMove;

		if (flag == move::AllowIllegalMove)
			return longCastlingIsPossible();

		return canCastleLong(sideToMove()) && longCastlingIsLegal();
	}

	if (move.isCapture() == !bool(m_occupiedBy[m_stm ^ 1] & dst))
		return to == m_epSquare && (pawns(color::ID(m_stm)) & src);

	switch (move.action())
	{
		case Move::Promote:
			if (move.promoted() == piece::King && !variant::isAntichessExceptLosers(variant))
				return false;
			// fallthru

		case Move::One_Forward:
		case Move::Two_Forward:
			if (!(pawnMovesFrom(from) & dst))
				return false;
			break;

		case piece::King:
			if (!(kingAttacks(to) & src))
				return false;
			break;

		case piece::Queen:
			if (!(queenAttacks(to) & src))
				return false;
			break;

		case piece::Rook:
			if (!(rookAttacks(to) & src))
				return false;
			break;

		case piece::Bishop:
			if (!(bishopAttacks(to) & src))
				return false;
			break;

		case piece::Knight:
			if (!(knightAttacks(to) & src))
				return false;
			break;

		case Move::Castle:
			if (to == m_castleRookCurrent[::kingSideIndex(m_stm)])
			{
				if (flag == move::AllowIllegalMove)
					return shortCastlingIsPossible();

				return canCastleShort(sideToMove()) && shortCastlingIsLegal();
			}
			if (to == m_castleRookCurrent[::queenSideIndex(m_stm)])
			{
				if (flag == move::AllowIllegalMove)
					return longCastlingIsPossible();

				return canCastleLong(sideToMove()) && longCastlingIsLegal();
			}
			return false;

		case Move::PieceDrop:
			if (!variant::isZhouse(variant))
				return false;

			switch (Byte(move.dropped()))
			{
				case piece::King:
					return false;

				case piece::Queen:
					if (m_holding[m_stm].queen == 0)
						return false;
					break;

				case piece::Rook:
					if (m_holding[m_stm].rook == 0)
						return false;
					break;

				case piece::Bishop:
					if (m_holding[m_stm].bishop == 0)
						return false;
					break;

				case piece::Knight:
					if (m_holding[m_stm].knight == 0)
						return false;
					break;

				case piece::Pawn:
					if (m_holding[m_stm].pawn == 0)
						return false;
					if (dst & (RankMask1 | RankMask8))
						return false;
					break;
			}
			break;
	}

	return	flag == move::AllowIllegalMove
			|| variant::isAntichessExceptLosers(variant)
			|| !isIntoCheck(move, variant);
}


bool
Board::isValidMove(Move const& move, variant::Type variant, move::Constraint flag) const
{
	if (!checkMove(move, variant, flag))
		return false;

	if (move.isNull())
		return (checkState(variant) & (Checkmate | ThreeChecks | Stalemate | Losing)) == 0;

	if (variant::isAntichessExceptLosers(variant) || flag == move::AllowIllegalMove)
		return true;

	return !isIntoCheck(move, variant);
}


Move
Board::prepareMove(Square from, Square to, variant::Type variant, move::Constraint flag) const
{
	M_ASSERT(from != Null);
	M_ASSERT(to != Null);

	uint64_t src = set1Bit(from);

	if (!(m_occupiedBy[m_stm] & src))
		return Move::empty();

	uint64_t dst = set1Bit(to);

	if (m_occupiedBy[m_stm] & dst)
	{
		if (!variant::isAntichessExceptLosers(variant))
		{
			// In Chess 960 a king move could both be the castling king move
			// or just a normal king move. This is why castling moves are
			// generated in the form king "takes" his own rook.
			// Example: e1h1 for the white short castle move in the standard
			// chess start position.
			// We have to catch this special case.

			M_ASSERT(kingOnBoard());

			if (m_ksq[m_stm] == from)
			{
				if (from < to)
				{
					if (m_castleRookCurrent[::kingSideIndex(m_stm)] == to && canCastleShort(color::ID(m_stm)))
					{
						if (shortCastlingIsLegal())
							return setMoveColor(setLegalMove(Move::genCastling(m_ksq[m_stm], to)));

						if (flag == move::AllowIllegalMove && shortCastlingIsPossible())
							return setMoveColor(Move::genCastling(m_ksq[m_stm], to));
					}
				}
				else
				{
					if (m_castleRookCurrent[::queenSideIndex(m_stm)] == to && canCastleLong(color::ID(m_stm)))
					{
						if (longCastlingIsLegal())
							return setMoveColor(setLegalMove(Move::genCastling(m_ksq[m_stm], to)));

						if (flag == move::AllowIllegalMove && longCastlingIsPossible())
							return setMoveColor(Move::genCastling(m_ksq[m_stm], to));
					}
				}

				// Possibly it's something like "g1g1". Some engines - for example Stockfish -
				// are sending such weird notation for castling while analyzing Chess 960 games.
				if (to == (whiteToMove() ? sq::g1 : sq::g8))
				{
					if (canCastleShort(color::ID(m_stm)))
					{
						to = m_castleRookCurrent[::kingSideIndex(m_stm)];

						if (shortCastlingIsLegal())
							return setMoveColor(setLegalMove(Move::genCastling(m_ksq[m_stm], to)));

						if (flag == move::AllowIllegalMove && shortCastlingIsPossible())
							return setMoveColor(Move::genCastling(m_ksq[m_stm], to));
					}
				}
				else if (to == (whiteToMove() ? sq::c1 : sq::c8))
				{
					if (canCastleLong(color::ID(m_stm)))
					{
						to = m_castleRookCurrent[::queenSideIndex(m_stm)];

						if (longCastlingIsLegal())
							return setMoveColor(setLegalMove(Move::genCastling(m_ksq[m_stm], to)));

						if (flag == move::AllowIllegalMove && longCastlingIsPossible())
							return setMoveColor(Move::genCastling(m_ksq[m_stm], to));
					}
				}
			}
		}

		return Move::empty();
	}

	Byte piece		= m_piece[from];
	Byte captured	= m_piece[to];

	if (captured == piece::King && !isAntichessExceptLosers(variant))
		return Move::empty();

	Move move;

	switch (piece)
	{
		case piece::Pawn:
			if (!(pawnMovesFrom(from) & dst))
				return Move::empty();

			if (to == m_epSquare)
			{
				move = Move::genEnPassant(from, to);
			}
			else if (dst & PawnF2[m_stm][from])
			{
				move = Move::genTwoForward(from, to);
			}
			else if (captured == piece::None)
			{
				if (dst & HomeRankMask[m_stm ^ 1])
					move = Move::genPromote(from, to, piece::Queen);
				else
					move = Move::genOneForward(from, to);
			}
			else
			{
				if (dst & HomeRankMask[m_stm ^ 1])
					move = Move::genCapturePromote(from, to, piece::Queen, captured);
				else
					move = Move::genPawnCapture(from, to, captured);
			}
			break;

		case piece::King:
			if (!isAntichessExceptLosers(variant) && !(kingAttacks(to) & src))
			{
				if ((move = prepareCastle(from, to, flag)))
					move.setColor(m_stm);
				return move;
			}
			move = Move::genKingMove(from, to, captured);
			break;

		case piece::Queen:
			if (queenAttacks(to) & src)
				move = Move::genQueenMove(from, to, captured);
			break;

		case piece::Rook:
			if (rookAttacks(to) & src)
				move = Move::genRookMove(from, to, captured);
			break;

		case piece::Bishop:
			if (bishopAttacks(to) & src)
				move = Move::genBishopMove(from, to, captured);
			break;

		case piece::Knight:
			if (knightAttacks(to) & src)
				move = Move::genKnightMove(from, to, captured);
			break;
	}

	return prepareMove(move, variant, flag);
}


Move
Board::preparePieceDrop(Square to, piece::Type piece, move::Constraint flag) const
{
	M_REQUIRE(piece::Queen <= piece && piece <= piece::Pawn);

	if (m_occupied & set1Bit(to) || (piece == piece::Pawn && (set1Bit(to) & (RankMask1 | RankMask8))))
		return Move::empty();

	Move move = Move::genPieceDrop(to, piece);
	move.setColor(m_stm);

	if (!isIntoCheck(move, variant::Crazyhouse))
		move.setLegalMove();
	else if (flag == move::DontAllowIllegalMove)
		move.clear();

	return move;
}


Move
Board::prepareMove(Move& move, variant::Type variant, move::Constraint flag) const
{
	if (move)
	{
		move.setColor(m_stm);

		if (isAntichess(variant))
		{
			if (variant != variant::Losers || !isIntoCheck(move, variant))
			{
				if (!move.isCapture() && (variant != variant::Losers || !isInCheck()))
				{
					MoveList result;
					generateCapturingPawnMoves(variant, result);
					generateCapturingPieceMoves(variant, result);

					if (variant == variant::Losers)
						filterLegalMoves(result, variant);

					if (result.isEmpty())
						move.setLegalMove();
					else if (flag == move::DontAllowIllegalMove)
						move.clear();
				}
				else
				{
					move.setLegalMove();
				}
			}
		}
		else if (m_checksGiven[m_stm ^ 1] == 3)
		{
			move.clear();
		}
		else if (!isIntoCheck(move, variant))
		{
			move.setLegalMove();
		}
		else if (flag == move::DontAllowIllegalMove)
		{
			move.clear();
		}
	}

	return move;
}


Move
Board::prepareCastle(Square from, Square to, move::Constraint flag) const
{
	M_ASSERT(kingOnBoard());

	if (!canCastle(sideToMove()))
		return Move::empty();

	if (whiteToMove())
	{
		if (from == e1)
		{
			switch (to)
			{
				case g1:
					if (m_castleRookCurrent[WhiteKS] == h1 && (m_castle & WhiteKingside))
					{
						if (shortCastlingWhiteIsLegal())
							return setLegalMove(Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteKS]));

						if (flag == move::AllowIllegalMove && shortCastlingWhiteIsPossible())
							return Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteKS]);
					}
					break;

				case c1:
					if (m_castleRookCurrent[WhiteQS] == a1 && (m_castle & WhiteQueenside))
					{
						if (longCastlingWhiteIsLegal())
							return setLegalMove(Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteQS]));

						if (flag == move::AllowIllegalMove && longCastlingWhiteIsPossible())
							return Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteQS]);
					}
					break;
			}
		}

		if (to == m_castleRookCurrent[WhiteKS])
		{
			if (m_castle & WhiteKingside)
			{
				if (shortCastlingWhiteIsLegal())
					return setLegalMove(Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteKS]));

				if (flag == move::AllowIllegalMove && shortCastlingWhiteIsPossible())
					return Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteKS]);
			}
		}
		else if (to == m_castleRookCurrent[WhiteQS])
		{
			if (m_castle & WhiteQueenside)
			{
				if (longCastlingWhiteIsLegal())
					return setLegalMove(Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteQS]));

				if (flag == move::AllowIllegalMove && longCastlingWhiteIsPossible())
					return Move::genCastling(m_ksq[White], m_castleRookCurrent[WhiteQS]);
			}
		}
	}
	else
	{
		if (from == e8)
		{
			switch (to)
			{
				case g8:
					if (m_castleRookCurrent[BlackKS] == h8 && (m_castle & BlackKingside))
					{
						if (shortCastlingBlackIsLegal())
							return setLegalMove(Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackKS]));

						if (flag == move::AllowIllegalMove && shortCastlingBlackIsPossible())
							return Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackKS]);
					}
					break;

				case c8:
					if (m_castleRookCurrent[BlackQS] == a8 && (m_castle & BlackQueenside))
					{
						if (longCastlingBlackIsLegal())
							return setLegalMove(Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackQS]));

						if (flag == move::AllowIllegalMove && longCastlingBlackIsPossible())
							return Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackQS]);
					}
					break;
			}
		}

		if (to == m_castleRookCurrent[BlackKS])
		{
			if (m_castle & BlackKingside)
			{
				if (shortCastlingBlackIsLegal())
					return setLegalMove(Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackKS]));

				if (flag == move::AllowIllegalMove && shortCastlingBlackIsPossible())
					return Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackKS]);
			}
		}
		else if (to == m_castleRookCurrent[BlackQS])
		{
			if (m_castle & BlackQueenside)
			{
				if (longCastlingBlackIsLegal())
					return setLegalMove(Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackQS]));

				if (flag == move::AllowIllegalMove && longCastlingBlackIsPossible())
					return Move::genCastling(m_ksq[Black], m_castleRookCurrent[BlackQS]);
			}
		}
	}

	return Move::empty();
}


Move
Board::makeMove(Square from, Square to, piece::Type promotedOrDrop) const
{
	// NOTE: we assume a valid move (but illegal moves are allowed)

	unsigned piece = m_piece[from];

	if (piece == piece::None)
	{
		M_ASSERT(from == to);
		M_ASSERT(promotedOrDrop != piece::None);

		return setMoveColor(Move::genPieceDrop(to, promotedOrDrop));
	}

	unsigned captured = m_piece[to];

	switch (piece)
	{
		case piece::Pawn:
			if (mstl::abs(to - from) == 16)
				return setMoveColor(Move::genTwoForward(from, to));

			if (to == m_epSquare)
				return setMoveColor(Move::genEnPassant(from, to));

			if (::rank(to) == HomeRank[m_stm ^ 1])
			{
				if (captured == piece::None)
					return setMoveColor(Move::genPromote(from, to, promotedOrDrop));

				return setMoveColor(Move::genCapturePromote(from, to, promotedOrDrop, captured));
			}

			if (captured == piece::None)
				return setMoveColor(Move::genOneForward(from, to));

			return setMoveColor(Move::genPawnCapture(from, to, captured));

		case piece::King:
			// the following takes illegal castlings into account:
			if (m_occupiedBy[m_stm] & set1Bit(to))
				return setMoveColor(Move::genCastling(from, to));

			// the following takes into account that the rook is probably missing
			// (handicap game; only allowed in standard chess)
			switch (int(from) - int(to))
			{
				case -2: // short castling
					return setMoveColor(
						Move::genCastling(from, m_castleRookCurrent[::kingSideIndex(m_stm)]));

				case +2: // long castling
					return setMoveColor(
						Move::genCastling(from, m_castleRookCurrent[::queenSideIndex(m_stm)]));
			}

			return setMoveColor(Move::genKingMove(from, to, captured));

		case piece::Queen:
			return setMoveColor(Move::genQueenMove(from, to, captured));

		case piece::Rook:
			return setMoveColor(Move::genRookMove(from, to, captured));

		case piece::Bishop:
			return setMoveColor(Move::genBishopMove(from, to, captured));

		case piece::Knight:
			return setMoveColor(Move::genKnightMove(from, to, captured));
	}

	return Move::null();
}


bool
Board::needCastlingFyles() const
{
	uint64_t whiteRooks = rooks(White) & RankMask1;
	uint64_t blackRooks = rooks(Black) & RankMask8;

	return	(	whiteRooks
				&& (m_castle & WhiteKingside)
				&& count(whiteRooks & ~(set1Bit(m_ksq[White]) - 1)) > 1)
			|| (	blackRooks
				&& (m_castle & BlackKingside)
				&& count(blackRooks & ~(set1Bit(m_ksq[Black]) - 1)) > 1)
			|| (	whiteRooks
				&& (m_castle & WhiteQueenside)
				&& count(whiteRooks &  (set1Bit(m_ksq[White]) - 1)) > 1)
			|| (	blackRooks
				&& (m_castle & BlackQueenside)
				&& count(blackRooks &  (set1Bit(m_ksq[Black]) - 1)) > 1);
}


mstl::string
Board::asString() const
{
	mstl::string result;

	for (unsigned i = 0; i < 64; ++i)
	{
		piece::ID piece = pieceAt(i);
		result += piece == piece::Empty ? '.' : piece::print(piece);
	}

	result += whiteToMove() ? 'w' : 'b';

	return result;
}


mstl::string&
Board::toFen(mstl::string& result, variant::Type variant, Format format) const
{
	result.reserve(result.size() + 90);

	// piece placement
	for (int row = 7, empty = 0; row >= 0; --row)
	{
		for (unsigned col = 0; col < 8; ++col)
		{
			unsigned 	square	= ::mul8(row) + col;
			piece::ID	piece		= pieceAt(square);

			if (piece == piece::Empty)
			{
				++empty;
			}
			else
			{
				if (empty)
				{
					result += char(empty + '0');
					empty = 0;
				}

				result += piece::print(piece);

				if (variant::isZhouse(variant) && (m_promoted[piece::color(piece)] & set1Bit(square)))
					result += '~';
			}
		}

		if (empty)
		{
			result += char(empty + '0');
			empty = 0;
		}

		if (row > 0)
			result += '/';
	}

	if (variant::isZhouse(variant))
	{
		if (m_holding[White].value | m_holding[Black].value)
		{
			result += '/';

			result.append(m_holding[White].queen,	'Q');
			result.append(m_holding[White].rook,	'R');
			result.append(m_holding[White].bishop,	'B');
			result.append(m_holding[White].knight,	'N');
			result.append(m_holding[White].pawn,	'P');

			result.append(m_holding[Black].queen,	'q');
			result.append(m_holding[Black].rook,	'r');
			result.append(m_holding[Black].bishop,	'b');
			result.append(m_holding[Black].knight,	'n');
			result.append(m_holding[Black].pawn,	'p');
		}
		else if (m_material[White].total() + m_material[Black].total() != 32)
		{
			result += '/'; // empty holding
		}
	}

	// side to move
	result += whiteToMove() ? " w " : " b ";

	// castling rights
	if (castlingRights() == NoRights)
	{
		result += "- ";
	}
	else
	{
		if (castlingRights() & WhiteBothSides)
		{
			M_ASSERT(kingOnBoard());

			uint64_t rooks = this->rooks(White) & RankMask1;

			if (castlingRights() & WhiteKingside)
			{
				int sq = m_castleRookAtStart[WhiteKS];

				M_ASSERT(sq != sq::Null);

				if (format == Shredder)
				{
					result += printFYLE(sq);
				}
				else
				{
					int rt = msb(rooks);

					if (rt > sq || mstl::is_between(lsb(rooks), int(m_ksq[White]), rt - 1))
						result += printFYLE(sq);
					else
						result += 'K';
				}
			}

			if (castlingRights() & WhiteQueenside)
			{
				M_ASSERT(kingOnBoard());

				int sq = m_castleRookAtStart[WhiteQS];

				M_ASSERT(sq != sq::Null);

				if (format == Shredder)
				{
					result += printFYLE(sq);
				}
				else
				{
					int lt = lsb(rooks);

					if (lt < sq || mstl::is_between(msb(rooks), lt + 1, int(m_ksq[White])))
						result += printFYLE(sq);
					else
						result += 'Q';
				}
			}
		}

		if (castlingRights() & BlackBothSides)
		{
			M_ASSERT(kingOnBoard());

			uint64_t rooks = this->rooks(Black) & RankMask8;

			if (castlingRights() & BlackKingside)
			{
				int sq = m_castleRookAtStart[BlackKS];

				M_ASSERT(sq != sq::Null);

				if (format == Shredder)
				{
					result += printFyle(sq);
				}
				else
				{
					int rt = msb(rooks);

					if (rt > sq || mstl::is_between(lsb(rooks), int(m_ksq[Black]), rt - 1))
						result += printFyle(sq);
					else
						result += 'k';
				}
			}

			if (castlingRights() & BlackQueenside)
			{
				M_ASSERT(kingOnBoard());

				int sq = m_castleRookAtStart[BlackQS];

				M_ASSERT(sq != sq::Null);

				if (format == Shredder)
				{
					result += printFyle(sq);
				}
				else
				{
					int lt = lsb(rooks);

					if (lt < sq || mstl::is_between(msb(rooks), lt + 1, int(m_ksq[Black])))
						result += printFyle(sq);
					else
						result += 'q';
				}
		}
		}

		result += ' ';
	}

	// en passant square
	if (m_epSquare == Null)
	{
		result += '-';
	}
	else
	{
		result += printFyle(sq::ID(m_epSquare));
		result += printRank(sq::ID(m_epSquare));
	}
	result += ' ';

	// half move clock
	result.format("%u", unsigned(halfMoveClock()));

	// move number
	result.format(" %u", unsigned(moveNumber()));

	if (variant == variant::ThreeCheck)
	{
		// checks given counter (+<checks given with White>+<checks given with Black>)
		if (m_checksGiven[White] | m_checksGiven[Black])
			result.format(" +%u+%u", m_checksGiven[White], m_checksGiven[Black]);
	}

	return result;
}


mstl::string
Board::toFen(variant::Type variant, Format format) const
{
	mstl::string fen;
	return toFen(fen, variant, format);
}


bool
Board::doMoves(char const* text)
{
	while (::isspace(*text)) ++text;
	while (*text && !::isalpha(*text)) ++text;

	while (*text)
	{
		Move move = parseMove(text, variant::Normal);

		if (!move.isLegal())
			return false;

		doMove(move, variant::Normal);

		while (*text && !::isspace(*text)) ++text;
		while (*text && !::isalpha(*text)) ++text;
	}

	return true;
}


bool
Board::hasBishopOnDark(color::ID side) const
{
	return bishops(side) & ::DarkSquares;
}


bool
Board::hasBishopOnLite(color::ID side) const
{
	return bishops(side) & ::LiteSquares;
}


bool
Board::drawnDueToBishopsOfOppositeColors(variant::Type variant) const
{
	if (variant != variant::Normal)
		return false;

	return	materialCount(White).total() == 2
			&& materialCount(Black).total() == 2
			&& materialCount(White).bishop == 1
			&& materialCount(Black).bishop == 1
			&& hasBishopOnLite(White) == hasBishopOnDark(Black);
}


bool
Board::neitherPlayerHasMatingMaterial(variant::Type variant) const
{
	if (variant::isAntichess(variant) || variant::isZhouse(variant))
		return false;
	
	material::Count wmat = materialCount(White);
	material::Count bmat = materialCount(Black);

	unsigned wtotal = wmat.total();
	unsigned btotal = bmat.total();
	
	if (wtotal == 1 && btotal == 1)
		return true;

	if (variant == variant::ThreeCheck)
		return false;

	if (wtotal == 2 && btotal == 1 && wmat.minor() == 1)
		return true;
	
	if (btotal == 2 && wtotal == 1 && bmat.minor() == 1)
		return true;
	
	return	wtotal == 2
			&& btotal == 2
			&& wmat.bishop == 1
			&& bmat.bishop == 1
			&& hasBishopOnLite(White) == hasBishopOnLite(Black);
}


bool
Board::cannotWin(color::ID color, variant::Type variant) const
{
	if (variant::isAntichess(variant) || variant::isZhouse(variant))
		return false;

	material::Count material = materialCount(color);

	unsigned total = material.total();
	
	if (total == 1)
		return true;
	
	if (variant == variant::ThreeCheck)
		return false;
	
	return total == 2 && material.minor() == 1;
}


castling::Rights
Board::currentCastlingRights() const
{
	unsigned rights = castlingRights();

	if ((rights & castling::WhiteQueenside) && !canCastleLong(White))
		rights &= ~WhiteQueenside;
	if ((rights & castling::WhiteKingside) && !canCastleShort(White))
		rights &= ~WhiteKingside;
	if ((rights & castling::BlackQueenside) && !canCastleLong(Black))
		rights &= ~BlackQueenside;
	if ((rights & castling::BlackKingside) && !canCastleShort(Black))
		rights &= ~BlackKingside;

	return castling::Rights(rights);
}


// ------------------------------------------------------------------------
// adopted from crafty-15.17/swap.c:SwapXray()
// ------------------------------------------------------------------------
// addXrayPiece() is used to determine if a piece is "behind" the piece on
// <from>, and this piece would attack <target> if the piece on <from> were
// moved (as in playing out sequences of swaps). If so, this indirect
// attacker is added to the list of attackers bearing to <target>.
uint64_t
Board::addXrayPiece(unsigned from, unsigned target) const
{
	switch (::Directions[target][from])
	{
		case  1: return rankAttacks(from) & (m_rooks | m_queens) & Plus1Dir[from];
		case  7: return diagA1H8Attacks(from) & (m_bishops | m_queens) & Plus7Dir[from];
		case  8: return fyleAttacks(from) & (m_rooks | m_queens) & Plus8Dir[from];
		case  9: return diagH1A8Attacks(from) & (m_bishops | m_queens) & Plus9Dir[from];
		case -1: return rankAttacks(from) & (m_queens | m_rooks) & Minus1Dir[from];
		case -7: return diagA1H8Attacks(from) & (m_bishops | m_queens) & Minus7Dir[from];
		case -8: return fyleAttacks(from) & (m_rooks | m_queens) & Minus8Dir[from];
		case -9: return diagH1A8Attacks(from) & (m_bishops | m_queens) & Minus9Dir[from];
	}

	return 0;
}


// ------------------------------------------------------------------------
// adopted from crafty-15.17/swap.c:Swap()
// ------------------------------------------------------------------------
// A Static Exchange Evaluator (or SEE for short).
//
// SSE is used to analyze capture moves to see whether or not they appear
// to be profitable. The basic algorithm is extremely fast since it uses the
// bitmaps to determine which squares are attacking the <target> square.
//
// The algorithm is quite simple. Using the attack bitmaps, we enumerate all
// the pieces that are attacking <target> for either side. Then we simply
// use the lowest piece (value) for the correct side to capture on <target>.
// We continually "flip" sides taking the lowest piece each time.
//
// As a piece is used, if it is a sliding piece (pawn, bishop, rook or queen)
// we "peek" behind it to see if it is attacked by a sliding piece in the
// direction away from the piece being captured. If so, and that sliding
// piece moves in this direction, then it is added to the list of attackers
// since its attack has been "uncovered" by moving the capturing piece.
int
Board::staticExchangeEvaluator(Move const& move, int const* pieceValues) const
{
	M_REQUIRE(pieceValues);

	int attackedPiece;
	int swapList[65];

	// Initialize by placing the piece on target first in
	// the list as it is being captured to start things off.
	if (move.isPromotion())
	{
		attackedPiece = pieceValues[move.promoted()];
		swapList[0] = attackedPiece - pieceValues[piece::Pawn];
	}
	else
	{
		attackedPiece = pieceValues[move.pieceMoved()];
		swapList[0] = pieceValues[move.capturedOrDropped()];
	}

	int target	= move.to();
	int n			= 1;

	uint64_t fromMask		= ::set1Bit(move.from());
	uint64_t occupied		= m_occupiedBy[m_stm ^ 1] & ~fromMask;
	uint64_t occupied2	= m_occupiedBy[m_stm] & ~fromMask;
	uint64_t pawns			= PawnAttacks[m_stm][target] & m_pawns;
	uint64_t pawns2		= PawnAttacks[m_stm ^ 1][target] & m_pawns;
	uint64_t knights		= knightAttacks(target) & m_knights;
	uint64_t bishops		= bishopAttacks(target) & m_bishops;
	uint64_t rooks			= rookAttacks(target) & m_rooks;
	uint64_t queens		= queenAttacks(target) & m_queens;
	uint64_t kings			= kingAttacks(target) & m_kings;

	occupied |= addXrayPiece(move.from(), target);

	// Now pick out the least valuable piece for the correct
	// side that is bearing on <target>. As we find one, we
	// call addXrayPiece() to add the piece behind this piece
	// that is indirectly bearing on <target> (if any).
	for ( ; occupied; ++n)
	{
		if (pawns & occupied)
		{
			int square = lsb(pawns & occupied);
			occupied &= ~::set1Bit(square);
			occupied |= addXrayPiece(square, target);
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::Pawn];
		}
		else if (knights & occupied)
		{
			occupied &= ~::set1Bit(lsb(knights & occupied));
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::Knight];
		}
		else if (bishops & occupied)
		{
			int square = lsb(bishops & occupied);
			occupied &= ~::set1Bit(square);
			occupied |= addXrayPiece(square, target);
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::Bishop];
		}
		else if (rooks & occupied)
		{
			int square = lsb(rooks & occupied);
			occupied &= ~::set1Bit(square);
			occupied |= addXrayPiece(square, target);
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::Rook];
		}
		else if (queens & occupied)
		{
			int square = lsb(queens & occupied);
			occupied &= ~::set1Bit(square);
			occupied |= addXrayPiece(square, target);
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::Queen];
		}
		else if (kings & occupied)
		{
			occupied &= ~::set1Bit(lsb(kings & occupied));
			swapList[n] = -swapList[n - 1] + attackedPiece;
			attackedPiece = pieceValues[piece::King];
		}
		else
		{
			break;
		}

		mstl::swap(occupied, occupied2);
		mstl::swap(pawns, pawns2);
	}

	// Starting at the end of the sequence of values, use a
	// "minimax" like procedure to decide where the captures
	// will stop.
	while (--n)
	{
		if (swapList[n] > -swapList[n - 1])
			swapList[n - 1] = -swapList[n];
	}

	return swapList[0];
}


void
Board::dump() const
{
	::printf("\n");

	for (unsigned r = 8; r > 0; --r)
	{
		for (unsigned f = 0; f < 8; ++f)
		{
			piece::ID piece = pieceAt((r - 1)*8 + f);
			::printf("%c", piece == piece::Empty ? '-' : piece::print(piece));
		}

		::printf("\n");
	}
	::printf("\nHolding: ");
	::printf("Q%u R%u B%u N%u P%u  q%u r%u b%u n%u p%u",
				unsigned(m_holding[0].queen),
				unsigned(m_holding[0].rook),
				unsigned(m_holding[0].bishop),
				unsigned(m_holding[0].knight),
				unsigned(m_holding[0].pawn),
				unsigned(m_holding[1].queen),
				unsigned(m_holding[1].rook),
				unsigned(m_holding[1].bishop),
				unsigned(m_holding[1].knight),
				unsigned(m_holding[1].pawn));
	if (m_promoted[White] || m_promoted[Black])
	{
		::printf("\nPromoted:");
		for (unsigned i = 0; i < 2; i++)
		{
			uint64_t promoted = m_promoted[i];
			while (promoted)
			{
				Square sq = lsbClear(promoted);
				piece::ID piece = pieceAt(sq);
				::printf(" %c%s", piece::print(piece), sq::printAlgebraic(sq));
			}
		}
	}
	::printf("\n---------------------------------------\n");
	::fflush(stdout);
}


void
Board::initialize()
{
#ifdef BROKEN_LINKER_HACK
	static bool initialized = false;

	if (initialized)
		return;

	initialized = true;
	base::initialize();
#endif

	m_initialHolding.queen = 1;
	m_initialHolding.rook = 2;
	m_initialHolding.bishop = 2;
	m_initialHolding.knight = 2;
	m_initialHolding.pawn = 8;

	// Empty board
	::memset(&m_emptyBoard, 0, sizeof(m_emptyBoard));
	::memset(m_emptyBoard.m_destroyCastle, 0xff, sizeof(m_emptyBoard.m_destroyCastle));
	::memset(m_emptyBoard.m_castleRookCurrent, Null, 4);
	::memset(m_emptyBoard.m_castleRookAtStart, Null, 4);
	m_emptyBoard.m_epSquare = Null;
	m_emptyBoard.m_ksq[0] = Null;
	m_emptyBoard.m_ksq[1] = Null;

	// Standard board
	m_standardBoard.setup(variant::fen(variant::Standard), variant::Normal);
	assert(m_standardBoard.m_holding[White].value == 0);
	assert(m_standardBoard.m_holding[Black].value == 0);
	::memset(m_standardBoard.m_unambiguous, true, U_NUMBER_OF(m_standardBoard.m_unambiguous));
	m_antichessBoard.setup(variant::fen(variant::NoCastling), variant::Antichess);

	// Shuffle Chess board
	m_shuffleChessBoard.setup("8/pppppppp/8/8/8/8/PPPPPPPP/8 w - - 0 1", variant::Normal);
	assert(m_shuffleChessBoard.m_holding[White].value == 0);
	assert(m_shuffleChessBoard.m_holding[Black].value == 0);
	::memset(m_shuffleChessBoard.m_unambiguous, true, U_NUMBER_OF(m_shuffleChessBoard.m_unambiguous));
	m_shuffleChessBoard.m_material[White] = m_standardBoard.m_material[White];
	m_shuffleChessBoard.m_material[Black] = m_standardBoard.m_material[Black];
	m_shuffleChessBoard.m_matSig = m_standardBoard.m_matSig;

	m_littleGame.setup(variant::fen(variant::LittleGame), variant::Normal);
	m_pawnsOn4thRank.setup(variant::fen(variant::PawnsOn4thRank), variant::Normal);
	m_pyramid.setup(variant::fen(variant::Pyramid), variant::Normal);
	m_KNNvsKP.setup(variant::fen(variant::KNNvsKP), variant::Normal);
	m_pawnsOnly.setup(variant::fen(variant::PawnsOnly), variant::Normal);
	m_knightsOnly.setup(variant::fen(variant::KnightsOnly), variant::Normal);
	m_bishopsOnly.setup(variant::fen(variant::BishopsOnly), variant::Normal);
	m_rooksOnly.setup(variant::fen(variant::RooksOnly), variant::Normal);
	m_queensOnly.setup(variant::fen(variant::QueensOnly), variant::Normal);
	m_noQueens.setup(variant::fen(variant::NoQueens), variant::Normal);
	m_wildFive.setup(variant::fen(variant::WildFive), variant::Normal);
	m_kbnk.setup(variant::fen(variant::KBNK), variant::Normal);
	m_kbbk.setup(variant::fen(variant::KBBK), variant::Normal);
	m_runaway.setup(variant::fen(variant::Runaway), variant::Normal);
	m_queenVsRooks.setup(variant::fen(variant::QueenVsRooks), variant::Normal);
	m_upsideDown.setup(variant::fen(variant::UpsideDown), variant::Normal);

#if 0
	printf("#define LittleGame_Hash     UINT64_C(0x%016llx)\n", m_littleGame.m_hash);
	printf("#define PawnsOn4thRank_Hash UINT64_C(0x%016llx)\n", m_pawnsOn4thRank.m_hash);
	printf("#define Pyramid_Hash        UINT64_C(0x%016llx)\n", m_pyramid.m_hash);
	printf("#define KNNvsKP_Hash        UINT64_C(0x%016llx)\n", m_KNNvsKP.m_hash);
	printf("#define PawnsOnly_Hash      UINT64_C(0x%016llx)\n", m_pawnsOnly.m_hash);
	printf("#define KnightsOnly_Hash    UINT64_C(0x%016llx)\n", m_knightsOnly.m_hash);
	printf("#define BishopsOnly_Hash    UINT64_C(0x%016llx)\n", m_bishopsOnly.m_hash);
	printf("#define RooksOnly_Hash      UINT64_C(0x%016llx)\n", m_rooksOnly.m_hash);
	printf("#define QueensOnly_Hash     UINT64_C(0x%016llx)\n", m_queensOnly.m_hash);
	printf("#define NoQueens_Hash       UINT64_C(0x%016llx)\n", m_noQueens.m_hash);
	printf("#define WildFive_Hash       UINT64_C(0x%016llx)\n", m_wildFive.m_hash);
	printf("#define KBNK_Hash           UINT64_C(0x%016llx)\n", m_kbnk.m_hash);
	printf("#define KBBK_Hash           UINT64_C(0x%016llx)\n", m_kbbk.m_hash);
	printf("#define Runaway_Hash        UINT64_C(0x%016llx)\n", m_runaway.m_hash);
	printf("#define QueenVsRooks_Hash   UINT64_C(0x%016llx)\n", m_queenVsRooks.m_hash);
	printf("#define UpsideDown_Hash     UINT64_C(0x%016llx)\n", m_upsideDown.m_hash);
#else
	assert(m_littleGame.m_hash == LittleGame_Hash);
	assert(m_pawnsOn4thRank.m_hash == PawnsOn4thRank_Hash);
	assert(m_pyramid.m_hash == Pyramid_Hash);
	assert(m_KNNvsKP.m_hash == KNNvsKP_Hash);
	assert(m_pawnsOnly.m_hash == PawnsOnly_Hash);
	assert(m_knightsOnly.m_hash == KnightsOnly_Hash);
	assert(m_bishopsOnly.m_hash == BishopsOnly_Hash);
	assert(m_rooksOnly.m_hash == RooksOnly_Hash);
	assert(m_queensOnly.m_hash == QueensOnly_Hash);
	assert(m_noQueens.m_hash == NoQueens_Hash);
	assert(m_wildFive.m_hash == WildFive_Hash);
	assert(m_kbnk.m_hash = KBNK_Hash);
	assert(m_kbbk.m_hash = KBBK_Hash);
	assert(m_runaway.m_hash == Runaway_Hash);
	assert(m_queenVsRooks.m_hash == QueenVsRooks_Hash);
	assert(m_upsideDown.m_hash == UpsideDown_Hash);
#endif

#ifdef CHECK_HASH_KEYS

	mstl::set<uint64_t> used;

# define HASHKEY(type) rand64::Holding[c ? piece::Black##type : piece::White##type]

	for (unsigned color = 0; color < 2; ++color)
	{
		color::ID c = color::ID(color);

		for (unsigned p = 0; p <= 8; ++p)
		{
			uint64_t pk = p ? mstl::bf::rotate_left(HASHKEY(Pawn), p - 1) : 0;

			for (unsigned n = 0; n <= 4; ++n)
			{
				uint64_t nk = n ? mstl::bf::rotate_left(HASHKEY(Knight), n - 1) : 0;

				for (unsigned b = 0; b <= 4; ++b)
				{
					uint64_t bk = b ? mstl::bf::rotate_left(HASHKEY(Bishop), b - 1) : 0;

					for (unsigned r = 0; r <= 4; ++r)
					{
						uint64_t rk = r ? mstl::bf::rotate_left(HASHKEY(Rook), r - 1) : 0;

						for (unsigned q = 0; q <= 2; ++q)
						{
							if (p > 1 || n > 1 || b > 1 || r > 1 || q > 1)
							{
								uint64_t qk		= q ? mstl::bf::rotate_left(HASHKEY(Queen), q - 1) : 0;
								uint64_t key	= 0;

								if (pk) key ^= pk;
								if (nk) key ^= nk;
								if (bk) key ^= bk;
								if (rk) key ^= rk;
								if (qk) key ^= qk;

								if (!used.insert_unique(key))
								{
									fprintf(	stderr,
												"hash key collision: p=%u, n=%u, b=%u, r=%u, q=%u\n",
												p, n, b, r, q);
								}

								for (unsigned ii = 0; ii < U_NUMBER_OF(rand64::RandomTable); ++ii)
								{
									if (key == rand64::RandomTable[ii])
									{
										fprintf(	stderr,
													"hash key collision: p=%u, n=%u, b=%u, r=%u, q=%u\n",
													p, n, b, r, q);
									}
								}
							}
						}
					}
				}
			}
		}
	}

#endif // CHECK_HASH_KEYS
}

// vi:set ts=3 sw=3:
