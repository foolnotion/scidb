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

#include "db_common.h"

#include "m_utility.h"
#include "m_stdio.h"

#include <stdarg.h>

enum { Piece_Shift = 2 };

extern "C"
{
	static void (*egtb_error)(int) = 0;
	static void egtb_exit(int n) { (*egtb_error)(n); }

	static char egtb_message[512]	= { '\0' };
	static int  egtb_msgLength		= 0;

	static int
	egtb_printf(char const* fmt, ...)
	{
		va_list 	ap;
		int		length;

		va_start(ap, fmt);
		length = vsnprintf(egtb_message + egtb_msgLength,
								sizeof(egtb_message) - egtb_msgLength,
								fmt, ap);
		va_end(ap);

		egtb_msgLength += length < 0 ? 0 : length;

		return length;
	}
}

// #############################################################################
// Including tbindex.cpp (see egtb/probe.txt)
// #############################################################################

#define NEW							// if you want to use my new, more compact tablebase format
#define XX	::db::sq::Null		// 'invalid' square - used to specify impossibilty of
										// en-passant capture. Must be any 'square' value except
										// 0..63.

#ifdef PROBE_USE_41
# define T41_INCLUDE				// if you want to probe any 5-man 4+1 table (e.g. KPPPK)
#endif
#if defined(PROBE_USE_42) && !defined(PROBE_USE_SCID)
# define T42_INCLUDE				// if you want to probe any 6-man 4+2 table (e.g. KNNNKN)
#endif
#if defined(PROBE_USE_33) && !defined(PROBE_USE_SCID)
# define T33_INCLUDE				// if you want to probe any 6-man 3+3 table (e.g. KNNKNN)
#endif

#if defined(PROBE_USE_42) || defined(PROBE_USE_33)
# define T_INDEX64				// if we have to use 64 bit indices
#endif

#ifdef T_INDEX64
typedef uint64_t INDEX;			// have to be wide enough to fit all enumerated positions
#else
typedef uint32_t INDEX;			// have to be wide enough to fit all enumerated positions
#endif
typedef unsigned square;		// any integer type, preferable the fastest on the given machine

#define LockInit(p)
#define LockFree(p)
#define Lock(p)
#define Unlock(p)
#define lock_t __attribute__((unused)) volatile int

// Enumeration types 'color' and 'piece' are declared in tbindex.cpp. For your
// purposes you must know that white is 0, black is 1; pawn is 1, ..., king is 6;
// A1 is 0, B1 is 1, ..., H8 is 63.

namespace egtb
{
	typedef square	Square;

	enum Piece
	{
		Pawn		= 1,
		Knight	= 2,
		Bishop	= 3,
		Rook		= 4,
		Queen		= 5,
		King		= 6,
		Last		= 7,
	};

	enum Color
	{
		White		= 0,
		Black		= 1,
	};

	inline unsigned mapSquare(Square sq)				{ return sq; }
	inline Piece mapPiece(::db::piece::Type piece)	{ return Piece(7 - piece); }
	inline Color opposite(Color color)					{ return Color(color ^ 1); }
}

inline static square SqFindKing(square const* squares)
{
	return squares[egtb::King >> Piece_Shift];
}
inline static square SqFindOne(square const* squares, int piece)
{
	return squares[piece >> Piece_Shift];
}
inline static square SqFindFirst(square const* squares, int piece)
{
	return squares[piece >> Piece_Shift];
}
inline static square SqFindSecond(square const* squares, int piece)
{
	return squares[(piece >> Piece_Shift) + 1];
}

#include <stdlib.h>				// must be included before we include egtb/tbindex.cpp
#define exit(n) egtb_exit(n)	// because of this macro definition
#define printf(fmt,args...) egtb_printf(fmt,##args)
#ifdef __WIN32__
# include <ctype.h>
#endif
#ifdef PROBE_USE_SCID
# include "egtb/scid/tbindex.cpp"
#else
# include "egtb/tbindex.cpp"
#endif
#undef exit
#undef printf

#undef XX
#undef NEW

#include "m_assert.h"

namespace egtb
{
	// Maximum number of pieces per side, including Kings.
	// It will be 3, unless T41_INCLUDE or T42_INCLUDE is
	// defined.
	enum
	{
#if defined(T41_INCLUDE) || defined(T42_INCLUDE)
		Max_Per_Side = 4
#else
		Max_Per_Side = 3
#endif
	};

	static int
	findTableIndex(::db::material::Count white, ::db::material::Count black)
	{
		int pieceCounts[10] =
		{
			int(white.pawn), int(white.knight), int(white.bishop), int(white.rook), int(white.queen),
			int(black.pawn), int(black.knight), int(black.bishop), int(black.rook), int(black.queen),
		};

		int index = IDescFindFromCounters(pieceCounts);

		M_ASSERT(unsigned(mstl::abs(index)) < U_NUMBER_OF(rgtbdDesc));

		return index;
	}

	inline static int
	initialize(char const* path)
	{
		M_ASSERT(path);
		return IInitializeTb(const_cast<char*>(path));
	}

	inline static void
	setCache(unsigned char* buffer, unsigned size)
	{
		M_ASSERT(buffer);
		M_ASSERT(size >= 8*1024);	// 8 kb

		FTbSetCacheSize(buffer, size);
	}

	inline static bool
	isRegistered(int tableIndex, Color color)
	{
		M_ASSERT(tableIndex > 0);
		M_ASSERT(unsigned(tableIndex) < U_NUMBER_OF(rgtbdDesc));

		return FRegistered(tableIndex, color);
	}

	static bool
	isRegistered(int tableIndex)
	{
		if (tableIndex == 0)
			return false;

		if (tableIndex < 0)
			tableIndex = -tableIndex;

		return isRegistered(tableIndex, White) || isRegistered(tableIndex, Black);
	}

	static int
	probe(int tableIndex, Color color,
			Square const* whiteSquares, Square const* blackSquares,
			Square epSquare, bool flip)
	{
		M_ASSERT(tableIndex);
		M_ASSERT(isRegistered(tableIndex, color));
		M_ASSERT(whiteSquares);
		M_ASSERT(blackSquares);

		INDEX	index		= PfnIndCalc(tableIndex, color)(	const_cast<Square*>(whiteSquares),
																		const_cast<Square*>(blackSquares),
																		epSquare,
																		flip);
		int	tbScore	= L_TbtProbeTable(tableIndex, color, index);

		if (tbScore == L_bev_broken)
			return ::db::tb::Broken;

		if (tbScore > 0)
			return 32767 - tbScore;

		if (tbScore < 0)
			return -32767 - tbScore;

		return 0;
	}

	inline static int worstScore() { return -32767; }
}

#ifdef debug
# undef debug
#endif

// #############################################################################
// End of including tbindex.cpp
// #############################################################################

#include "db_probe.h"
#include "db_board.h"
#include "db_move_list.h"
#include "db_move.h"
#include "db_exception.h"

#include "m_string.h"

#include <string.h>

using namespace db;


enum { Squares_Size = (1 << Piece_Shift)*egtb::Last };


static void
errorInEGTB(int n)
{
	if (egtb_msgLength == 0)
		DB_RAISE("error in EGTB code (exit code %d)", n);

	egtb_msgLength = 0;
	DB_RAISE("error in EGTB code (exit code %d): %s", n, egtb_message);
}


static void __attribute__((constructor)) initialize() { Probe::initialize(); }


static void
setupSquares(Board const& board, egtb::Square* whiteSquares, egtb::Square* blackSquares, bool flip)
{
	egtb::Square* firstSq[::db::piece::Last + 1];

	if (flip)
		mstl::swap(whiteSquares, blackSquares);

	firstSq[::db::piece::WhiteKing  ] = &(whiteSquares[(egtb::King  ) << Piece_Shift]);
	firstSq[::db::piece::BlackKing  ] = &(blackSquares[(egtb::King  ) << Piece_Shift]);
	firstSq[::db::piece::WhiteQueen ] = &(whiteSquares[(egtb::Queen ) << Piece_Shift]);
	firstSq[::db::piece::BlackQueen ] = &(blackSquares[(egtb::Queen ) << Piece_Shift]);
	firstSq[::db::piece::WhiteRook  ] = &(whiteSquares[(egtb::Rook  ) << Piece_Shift]);
	firstSq[::db::piece::BlackRook  ] = &(blackSquares[(egtb::Rook  ) << Piece_Shift]);
	firstSq[::db::piece::WhiteBishop] = &(whiteSquares[(egtb::Bishop) << Piece_Shift]);
	firstSq[::db::piece::BlackBishop] = &(blackSquares[(egtb::Bishop) << Piece_Shift]);
	firstSq[::db::piece::WhiteKnight] = &(whiteSquares[(egtb::Knight) << Piece_Shift]);
	firstSq[::db::piece::BlackKnight] = &(blackSquares[(egtb::Knight) << Piece_Shift]);
	firstSq[::db::piece::WhitePawn  ] = &(whiteSquares[(egtb::Pawn  ) << Piece_Shift]);
	firstSq[::db::piece::BlackPawn  ] = &(blackSquares[(egtb::Pawn  ) << Piece_Shift]);

	for (Square sq = sq::a1; sq <= sq::h8; ++sq)
	{
		::db::piece::ID piece = board.pieceAt(sq);

		if (piece != ::db::piece::Empty)
		{
			M_ASSERT(unsigned(piece) < U_NUMBER_OF(firstSq));
			*firstSq[piece]++ = egtb::mapSquare(sq);
		}
	}
}


static void
movePiece(Move const& move, egtb::Square* whiteSquares, egtb::Square* blackSquares, bool flip)
{
	egtb::Square*	squares	= ::db::color::isWhite(move.color()) == flip ? blackSquares : whiteSquares;
	egtb::Square	from		= egtb::mapSquare(move.from());

	squares += egtb::mapPiece(move.moved()) << Piece_Shift;

	for (unsigned i = 0; i < 1 << Piece_Shift; ++i)
	{
		if (from == squares[i])
		{
			squares[i] = egtb::mapSquare(move.to());
			return;
		}
	}

	M_RAISE("internal error in %s", __func__);
}


Probe::Probe(unsigned cacheSize)
	:m_cache(0)
	,m_cacheSize(mstl::min(unsigned(Cache_Max_Size), mstl::max(unsigned(Cache_Min_Size), cacheSize)))
	,m_maxPieceNumber(0)
{
}


Probe::~Probe() throw()
{
	delete m_cache;
}


//! Initialises the tablebases given a directory string. All the tables
//! to be used must be in the directory; subdirectories are not
//! scanned. However, the directory string may have more than one
//! dircetory in it, separated by commas (,) or semicolons (;).
//! Returns the same value as maxPieceNumber().
unsigned
Probe::setup(mstl::string const& egtbPath)
{
    m_maxPieceNumber = egtb::initialize(egtbPath);

	 delete [] m_cache;
    m_cache = new Byte[m_cacheSize];

    egtb::setCache(m_cache, m_cacheSize);

    return m_maxPieceNumber;
}


int
Probe::quiesce(material::Count white, material::Count black) const
{
	unsigned numWhitePieces = white.total();
	unsigned numBlackPieces = black.total();

	// Quickly check that there is not too much material.
	if (	numWhitePieces + numBlackPieces > m_maxPieceNumber
		|| mstl::max(numWhitePieces, numBlackPieces) > egtb::Max_Per_Side)
	{
		return -1;
	}

	// If two lone Kings, just return 0.
	if (numWhitePieces + numBlackPieces <= 2)
		return 0;

	// If KB-K or KN-K, return 0 because they are all-drawn tablebases.
	return	numWhitePieces + numBlackPieces == 3
			&& (white.minor() == 1 || black.minor() == 1) ? 0 : 1;
}


/// Given a material configuration, returns a boolean indicating
/// if the tablebase for that material is registered for use.
///
/// Note: there are actually TWO tablebases for any material
/// combination, one for each side to move (file suffixes .nbw.emd
/// and .nbb.emd); this function returns true if EITHER one is
/// registered (since having only one of the two is usually good
/// enough to solve the endgame).
bool
Probe::isAvailable(Board const& board) const
{
	if (m_maxPieceNumber == 0)
		return false;

	material::Count white = board.materialCount(color::White);
	material::Count black = board.materialCount(color::Black);

	switch (quiesce(white, black))
	{
		case -1:	return false;
		case  0: return true;
	}

	return egtb::isRegistered(egtb::findTableIndex(white, black));
}


/// Given a board, probes the appropriate tablebase and returns the
/// score.
///
/// The score returned is as follows, where STM is the side to move:
///
///	Not_Found	position not found
///	  3			STM mates in 3, etc.
///	  2			STM mates in 2.
///	  1			STM mates in 1.
///	  0			Draw.
///	 -1			STM is checkmated.
///	 -1			STM mated in 1.
///	 -2			STM mated in 2, etc.
int
Probe::findScore(Board const& board) const
{
	M_REQUIRE(board.validate(variant::Undetermined));

	if (m_maxPieceNumber == 0)
		return tb::Not_Found;

	material::Count white = board.materialCount(color::White);
	material::Count black = board.materialCount(color::Black);

	switch (quiesce(white, black))
	{
		case -1: return tb::Not_Found;
		case  0: return 0;
	}

	int tblIndex = egtb::findTableIndex(white, black);

	M_ASSERT(tblIndex);

	bool			flip	= tblIndex < 0;
	egtb::Color	color	= board.whiteToMove() == flip ? egtb::Black : egtb::White;

	if (flip)
		tblIndex = -tblIndex;

	if (!egtb::isRegistered(tblIndex, color))
		return tb::Not_Found;

	egtb::Square whiteSquares[::Squares_Size];
	egtb::Square blackSquares[::Squares_Size];
	::setupSquares(board, whiteSquares, blackSquares, flip);

	egtb::Square epSquare = egtb::mapSquare(board.enPassantSquare());
	return egtb::probe(tblIndex, color, whiteSquares, blackSquares, epSquare, flip);
}


int
Probe::findBest(Board const& board, Move& result) const
{
	if (m_maxPieceNumber == 0)
		return tb::Not_Found;

	material::Count white = board.materialCount(color::White);
	material::Count black = board.materialCount(color::Black);

	switch (quiesce(white, black))
	{
		case -1:	return tb::Not_Found;
		case  0:	return tb::Any_Move;
	}

	int tblIndex = egtb::findTableIndex(white, black);

	M_ASSERT(tblIndex);

	bool			flip	= tblIndex < 0;
	egtb::Color	color	= board.whiteToMove() == flip ? egtb::Black : egtb::White;

	if (flip)
		tblIndex = -tblIndex;

	if (!egtb::isRegistered(tblIndex, color))
		return tb::Not_Found;

	egtb::Square whiteSquares[::Squares_Size];
	egtb::Square blackSquares[::Squares_Size];

	::memset(whiteSquares, 0, sizeof(whiteSquares));
	::memset(blackSquares, 0, sizeof(blackSquares));

	::setupSquares(board, whiteSquares, blackSquares, flip);

	MoveList	moves;
	Board		peek(board);

	int bestScore	= egtb::worstScore() - 1;
	int bestIndex	= -1;

	color = egtb::opposite(color);
	peek.generateMoves(variant::Normal, moves);

	for (unsigned i = 0; i < moves.size(); ++i)
	{
		Move move = moves[i];

		peek.prepareUndo(move);
		peek.doMove(move, variant::Normal);

		if (peek.isLegal())
		{
			egtb::Square wSquares[::Squares_Size];
			egtb::Square bSquares[::Squares_Size];

			int index	= 0; // shut up the compiler
			int swap		= 0; // shut up the compiler

			if (move.isCaptureOrPromotion())
			{
				white = peek.materialCount(color::White);
				black = peek.materialCount(color::Black);

				switch (quiesce(white, black))
				{
					case -1:	// should not happen
						return tb::Broken;

					case 0:
						if (bestScore < 0)
						{
							bestIndex = i;
							bestScore = 0;
						}
						index = 0;
						break;

					case 1:
						index = egtb::findTableIndex(white, black);

						M_ASSERT(index);

						if ((swap = index < 0))
							index = -index;

						if (!egtb::isRegistered(index, color))
							return tb::Incomplete_Data;

						::setupSquares(peek, wSquares, bSquares, swap);
						break;
				}
			}
			else
			{
				index = tblIndex;
				swap = flip;
				::memcpy(wSquares, whiteSquares, sizeof(wSquares));
				::memcpy(bSquares, blackSquares, sizeof(bSquares));
				movePiece(move, wSquares, bSquares, swap);
			}

			if (index)
			{
				M_ASSERT(index > 0);
				M_ASSERT(egtb::isRegistered(index, color));

				egtb::Square epSquare = egtb::mapSquare(peek.enPassantSquare());
				int score = egtb::probe(index, color, wSquares, bSquares, epSquare, swap);

				if (score == tb::Broken)	// should never happen
					return score;

				if (score > bestScore)
				{
					bestIndex = i;
					bestScore = score;
				}
			}
		}

		peek.undoMove(move, variant::Normal);
	}

	if (bestIndex == -1)
	{
		unsigned state = board.checkState(variant::Normal);

		if (state & Board::Checkmate)
			return tb::Is_Check_Mate;
		if (state & Board::Stalemate)
			return tb::Is_Stale_Mate;

		return tb::Illegal_Position;
	}

	result = moves[bestIndex];
	return bestScore;
}


void Probe::initialize() { egtb_error = &errorInEGTB; }

// vi:set ts=3 sw=3:
