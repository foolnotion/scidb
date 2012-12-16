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
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_guess.h"
#include "db_board_base.h"

using namespace db;
using namespace db::sq;
using namespace db::color;
using namespace db::castling;
using namespace db::board;

//#define TRACE(fmt,args...) 	printf(fmt,##args)
//#define TRACE_2(fmt,args...)	printf(fmt,##args)

#ifndef TRACE
# define TRACE(fmt, args...)
#endif
#ifndef TRACE_2
# define TRACE_2(fmt, args...)
#endif
#define TRACE_1(fmt,args...)	TRACE(fmt,##args)

inline static int mul2(int x)		{ return x << 1; }
inline static int mul3(int x)		{ return x*3; }
inline static int mul4(int x)		{ return x << 2; }

static sq::ID identicalSquare(sq::ID s) { return s; }

static sq::ID (*wflip)(sq::ID) = identicalSquare;
static sq::ID (*bflip)(sq::ID) = sq::flipRank;


namespace bonus
{
	static int const BishopPair				= 13;
	static int const RookHalfOpenFyle		= 10;
	static int const WhiteToMove				= 5;
	static int const RookOpenFyle				= 40;
	static int const RookBehindPassedPawn	= 10;

	static int const BishopKingTropism[8]	= { 0, 2, 2, 1, 0, 0, 0, 0 };
	static int const KnightKingTropism[8]	= { 0, 3, 3, 2, 1, 0, 0, 0 };
	static int const RookKingTropism[8]		= { 0, 4, 3, 2, 1, 1, 1, 1 };
	static int const QueenKingTropism[8]	= { 0, 6, 5, 4, 3, 2, 2, 2 };

	static int8_t const KnightSquare[64] =
	{
		-20, -20, -20, -20, -20, -20, -20, -20,
		  0,   0,   0,   0,   0,   0,   0,   0,
		  0,   0,  16,  14,  14,  16,   0,   0,
		  0,  10,  18,  20,  20,  18,  10,   0,
		  0,  12,  20,  24,  24,  20,  12,   0,
		  0,  12,  20,  24,  24,  20,  12,   0,
		  0,  10,  16,  20,  20,  16,  10,   0,
		-30, -20, -20, -10, -10, -20, -20, -30,
	};

	static int8_t const BishopSquare[64] =
	{
		-10, -10,  -8,  -6,  -6,  -8, -10, -10,
		  0,   8,   6,   8,   8,   6,   8,   0,
		  2,   6,  12,  10,  10,  12,   6,   2,
		  4,   8,  10,  16,  16,  10,   8,   4,
		  4,   8,  10,  16,  16,  10,   8,   4,
		  2,   6,  12,  10,  10,  12,   6,   2,
		  0,   8,   6,   8,   8,   6,   8,   0,
		  0,   0,   2,   4,   4,   2,   0,   0,
	};

	static int8_t const RookSquare[64] =
	{
		 0,  2,  3,  4,  4,  3,  2,  0,
		-4,  2,  3,  4,  4,  3,  2, -4,
		-4,  2,  3,  4,  4,  3,  2, -4,
		-4,  2,  3,  4,  4,  3,  2, -4,
		 0,  2,  3,  4,  4,  3,  2,  0,
		 0,  2,  3,  4,  4,  3,  2,  0,
		 0,  2,  3,  4,  4,  3,  2,  0,
		 0,  2,  3,  4,  4,  3,  2,  0,
	};

	static int8_t const QueenSquare[64] =
	{
		0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  4,  4,  4,  4,  0,  0,
		0,  4,  4,  6,  6,  4,  4,  0,
		0,  4,  6,  8,  8,  6,  4,  0,
		0,  4,  6,  8,  8,  6,  4,  0,
		0,  4,  4,  6,  6,  4,  4,  0,
		0,  0,  4,  4,  4,  4,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,
	};

	static int8_t const PawnSquare[64] =
	{
		 0,   0,   0,   0,   0,   0,   0,   0,
		 0,   0,   0, -12, -12,   0,   0,   0,
		 1,   1,   1,  10,  10,   1,   1,   1,
		 3,   3,   3,  13,  13,   3,   3,   3,
		 6,   6,   6,  16,  16,   6,   6,   6,
		10,  10,  10,  30,  30,  10,  10,  10,
		70,  70,  70,  70,  70,  70,  70,  70,
		 0,   0,   0,   0,   0,   0,   0,   0,
	};
}

namespace penalty
{
	static int const LowerBishop	=  10;
	static int const LowerKnight	=  16;
	static int const LowerRook		=  16;

	static int const FriendlyQueen[8] = { 2, 2, 2, 1, 0, 0, -1, -1 };
}

namespace pawn
{
	static int const Duo			= 4;
	static int const Isolated	= 12;
	static int const Doubled	= 5;
}

namespace safety
{
	static int const Safety[16] =
	{
		0, 7, 14, 21, 28, 35, 42, 49, 56, 63, 70, 77, 84, 91, 98, 105,
	};

	static int const Tropism[16] =
	{
		0, 1, 2, 3, 4, 5, 11, 20, 32, 47, 65, 86, 110, 137, 167, 200,
	};

	static int const KingSafety[16] =
	{
		0,   1,   3,   5,   7,   9,  19,  36,  57,  84, 117, 154, 198, 246, 300, 360,
	};

} // namespace safety

void
db::Guess::preEvaluateSuicide()
{
}


int
db::Guess::evaluateSuicide(int alpha, int beta)
{
	int score = evaluateMaterialSuicide();

	if (m_pawnData->key != m_pawnHash)
	{
		PawnHashEntry* entry = m_pawnTable + (m_pawnHash & (PawnTableSize - 1));

		if (entry->key != m_pawnHash)
		{
			// initialize pawn score structure
			::memset(entry->eval, 0, sizeof(entry->eval));
			entry->key = m_pawnHash;
			entry->score = 0;

			// evaluatePawns() does all of the analysis for information
			// specifically regarding only pawns. In many cases, it merely
			// records the presence/absence of positional pawn feature
			// because that feature also depends on pieces. Note that
			// anything put into EvaluatePawns() can only consider the
			// placement of pawns.
			entry->score += evaluatePawnsSuicide(White);
			entry->score -= evaluatePawnsSuicide(Black);
		}

		m_pawnData = entry;
	}

	score += m_pawnData->score.middleGame;

	TRACE_2("score[evaluate pawns]                = %d, %d\n", score);

	// Call EvaluateDevelopment() to evaluate development.
	// Now evaluate pieces.
	score += evaluateKnightsSuicide(White, ::wflip);
	score -= evaluateKnightsSuicide(Black, ::bflip);

	score += evaluateBishopsSuicide(White, ::wflip);
	score -= evaluateBishopsSuicide(Black, ::bflip);

	score += evaluateRooksSuicide(White);
	score -= evaluateRooksSuicide(Black);

	score += evaluateQueensSuicide(White, ::wflip);
	score -= evaluateQueensSuicide(Black, ::bflip);

	score += evaluateKingsSuicide(White);
	score -= evaluateKingsSuicide(Black);

	TRACE("score[pieces]                        = %d, %d\n", score);

	return score;
}


int
db::Guess::evaluateMaterialSuicide()
{
	// We start with the raw Material balance for the current position.
	int material
		= (int(m_material[White].king  ) - int(m_material[Black].king  ))*KingValueSuicide
		+ (int(m_material[White].queen ) - int(m_material[Black].queen ))*QueenValueSuicide
		+ (int(m_material[White].rook  ) - int(m_material[Black].rook  ))*RookValueSuicide
		+ (int(m_material[White].bishop) - int(m_material[Black].bishop))*BishopValueSuicide
		+ (int(m_material[White].knight) - int(m_material[Black].knight))*KnightValueSuicide
		+ (int(m_material[White].pawn  ) - int(m_material[Black].pawn  ))*PawnValueSuicide;

	int score = material + (whiteToMove() ? bonus::WhiteToMove : -bonus::WhiteToMove);

	TRACE("score[material]                      = %d, %d\n", score);

	return score;
}


int
db::Guess::evaluateKingsSuicide(color::ID side)
{
	int		score		= 0;
	uint64_t	kings	= this->kings(side);

	while (kings)
	{
		sq::ID square = sq::ID(lsbClear(kings));

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		uint64_t moves = (kingAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

		score -= count(moves & (FyleMaskA | FyleMaskH));
		score += count(moves & (FyleMaskB | FyleMaskG));
		score += ::mul2(count(moves & (FyleMaskC | FyleMaskF)));
		score += ::mul3(count(moves & (FyleMaskD | FyleMaskE)));
	}

	TRACE_2("%s kings[mobility]                = %d, %d\n", printColor(side), score);
	TRACE("%s score[kings]                   = %d, %d\n", printColor(side), score);

	return score;
}


int
db::Guess::evaluateKnightsSuicide(color::ID side, Flip flip)
{
	int		score		= 0;
	uint64_t	knights	= this->knights(side);

	// First, evaluate for "outposts" which is a knight that
	// can't be driven off by an enemy pawn, and which is
	// supported by a friendly pawn.
	while (knights)
	{
		sq::ID square			= sq::ID(lsbClear(knights));
		sq::ID flippedSquare	= flip(square);

		// First fold in centralization score.
		score += bonus::KnightSquare[flippedSquare];

		TRACE_2("%s knights[central]               = %d\n", printColor(side), score);

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		{
			static uint64_t const MobilityMask[4] =
			{
				RankMask1 | RankMask8 | FyleMaskA | FyleMaskH,
				((RankMask2 | RankMask7) & ~(A2 | H2 | A7 | H7)) | B3 | B4 | B5 | B6 | G3 | G4 | G5 | G6,
				C3 | D3 | E3 | F3 | C6 | D6 | E6 | F6 | C4 | C5 | F4 | F5,
				D4 | E4 | D5 | E5,
			};

			uint64_t moves = (knightAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerKnight;
			score += count(moves & MobilityMask[0]);
			score += ::mul2(count(moves & MobilityMask[1]));
			score += ::mul3(count(moves & MobilityMask[2]));
			score += ::mul4(count(moves & MobilityMask[3]));

			TRACE_2("%s knights[mobility]              = %d, %d\n", printColor(side), score);
		}
	}

	TRACE("%s score[knights]                 = %d, %d\n", printColor(side), score);

	return score;
}


int
db::Guess::evaluateBishopsSuicide(color::ID side, Flip flip)
{
	int		score		= 0;
	int		pair		= hasBishopOnLite(side) && hasBishopOnDark(side);
	uint64_t	bishops	= this->bishops(side);

	TRACE_2("%s bishops[pawn on wings]         = %d, %d\n", printColor(side), score);

	// First, locate each bishop and add in its static score
	// from the bishop piece/square table.
	while (bishops)
	{
		sq::ID square			= sq::ID(lsbClear(bishops));
		sq::ID flippedSquare	= flip(square);

		score += bonus::BishopSquare[flippedSquare];

		TRACE_2("%s bishops[central]               = %d, %d\n", printColor(side), score);

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		{
			static uint64_t const MobilityMask[4] =
			{
				RankMask1 | RankMask8 | FyleMaskA | FyleMaskH,
				((RankMask2 | RankMask7) & ~(A2 | H2 | A7 | H7)) | B3 | B4 | B5 | B6 | G3 | G4 | G5 | G6,
				C3 | D3 | E3 | F3 | C6 | D6 | E6 | F6 | C4 | C5 | F4 | F5,
				D4 | E4 | D5 | E5,
			};

			uint64_t moves = (bishopAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerBishop;
			score += count(moves & MobilityMask[0])*(1 + pair);
			score += count(moves & MobilityMask[1])*(2 + pair);
			score += count(moves & MobilityMask[2])*(3 + pair);
			score += count(moves & MobilityMask[3])*(4 + pair);

			TRACE_2("%s bishops[mobility]              = %d, %d\n", printColor(side), score);
		}
	}

	TRACE("%s score[bishops]                 = %d, %d\n", printColor(side), score);

	return score;
}


int
db::Guess::evaluateRooksSuicide(color::ID side)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	uint64_t		rooks		= this->rooks(side);

	while (rooks)
	{
		sq::ID	square	= sq::ID(lsbClear(rooks));
		int		fyle		= ::fyle(square);

		// Determine if the rook is on an open fyle or on a half-
		// open fyle, either of which increases its ability to
		// attack important squares (this is bad!).
		if (!(pawns(side) & FyleMask[fyle]))
		{
			if (!(pawns(opponent) & FyleMask[fyle]))
				score -= bonus::RookOpenFyle;
			else
				score -= bonus::RookHalfOpenFyle;
		}

		TRACE_2("%s rooks[(half) open fyle]        = %d, %d\n", printColor(side), score);

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization (fyle).
		{
			uint64_t moves = (rookAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerRook;
			score += count(moves & (FyleMaskA | FyleMaskH));
			score += ::mul2(count(moves & (FyleMaskB | FyleMaskG)));
			score += ::mul3(count(moves & (FyleMaskC | FyleMaskF)));
			score += ::mul4(count(moves & (FyleMaskD | FyleMaskE)));

			TRACE_2(	"%s rooks[mobility]                = %d, %d\n", printColor(side), score);
		}
	}

	TRACE("%s score[rooks]                   = %d, %d\n", printColor(side), score);

	return score;
}


int
db::Guess::evaluateQueensSuicide(color::ID side, Flip flip)
{
	int		score		= 0;
	uint64_t	queens	= this->queens(side);

	// First locate each queen and obtain it's centralization
	// score from the static piece/square table for queens.
	// Then, if the opposing side's king safety is much worse
	// than the king safety for this side, add in a bonus to
	// keep the queen around.

	while (queens)
	{
		sq::ID square			= sq::ID(lsbClear(queens));
		sq::ID flippedSquare	= flip(square);

		score += bonus::QueenSquare[flippedSquare];

		TRACE_2("%s queens[central]                = %d, %d\n", printColor(side), score);
	}

	TRACE("%s score[queens]                  = %d, %d\n", printColor(side), score);

	return score;
}


int
db::Guess::evaluatePawnsSuicide(color::ID side)
{
	uint64_t		pawnMoves	= 0;
	color::ID	opponent		= opposite(side);
	int			score			= 0;
	int			dir			= isWhite(side) ? 8 : -8;
	uint64_t 	myPawns		= pawns(side);
	uint64_t 	enemyPawns	= pawns(opponent);
	uint64_t 	pawns			= myPawns;
	Eval&			eval			= m_pawnData->eval;

	uint64_t const* pawnAttacks			= PawnAttacks[side];
	uint64_t const* pawnAttacksOpponent	= PawnAttacks[opponent];

	Rank pawnRankOpponent = PawnRank[opponent];

	// First, determine which squares pawns can reach.
	while (pawns)
	{
		int square	= lsbClear(pawns);
		int last		= sq::make(::fyle(square), pawnRankOpponent);
		int next		= square + dir;

		for (int sq = square; sq != last; sq = next, next += dir)
		{
			pawnMoves |= ::setBit(sq);

			if (::setBit(next) & m_pawns)
				break;

			int defenders = count(pawnAttacksOpponent[next] & myPawns);
			int attackers = count(pawnAttacks[next] & enemyPawns);

			if (attackers - defenders > 0)
				break;
		}
	}

	pawns = myPawns;

	PawnEval& pawnEval = eval[side];

	while (pawns)
	{
		int square	= lsbClear(pawns);
		int fyle		= ::fyle(square);
		int rank		= isWhite(side) ? ::rank(square) : Rank8 - ::rank(square);
		int sqIndex	= sq::make(fyle, rank);

		// Evaluate pawn advances. Center pawns are encouraged
		// to advance, while wing pawns are pretty much neutral.
		score += bonus::PawnSquare[sqIndex];

		TRACE_2(	"%s pawn[static]   fyle %c, score   = %d, %d\n",
					printColor(side),
					printFyle(fyle), score);

		// Evaluate isolated pawns, which are penalized based on
		// the fyle, with central isolani being worse than when
		// on the wings.
		if (!(myPawns & MaskIsolatedPawn[square]))
		{
			score -= pawn::Isolated;

			if (!(enemyPawns & FyleMask[fyle]))
				score -= pawn::Isolated/2;

			TRACE_2(	"%s pawn[isolated] fyle %c, score   = %d, %d\n",
						printColor(side), printFyle(fyle),
						score);
		}
		else
		{
			// Evaluate doubled pawns. If there are other pawns on
			// this fyle, penalize this pawn.
			if (count(myPawns & FyleMask[fyle]) > 1)
				score -= pawn::Doubled;

			TRACE_2(	"%s pawn[doubled]  fyle %c, score   = %d, %d\n",
						printColor(side), printFyle(fyle),
						score);

			// Test the pawn to see it if forms a "duo" which is two
			// pawns side-by-side.
			if (MaskDuoPawn[square] & myPawns)
				score += pawn::Duo;

			TRACE_2(	"%s pawn[duo]      fyle %c, score   = %d, %d\n",
						printColor(side), printFyle(fyle),
						score);
		}

		uint64_t const* maskPassedPawn = MaskPassedPawn[side];

		// Discover and flag passed pawns for use later.
		if (!(maskPassedPawn[square] & enemyPawns))
		{
			pawnEval.passedPawn |= 1 << fyle;
			TRACE_2("%s pawn[passed]   fyle %c\n", printColor(side), printFyle(fyle));
		}
	}

	return score;
}


inline int db::Guess::evaluatePawnsLosers(color::ID side) { return evaluatePawnsSuicide(side); }


int
db::Guess::evaluateMaterialLosers()
{
	// We start with the raw Material balance for the current position.
	int material
		= (int(m_material[White].queen ) - int(m_material[Black].queen ))*QueenValueLosers
		+ (int(m_material[White].rook  ) - int(m_material[Black].rook  ))*RookValueLosers
		+ (int(m_material[White].bishop) - int(m_material[Black].bishop))*BishopValueLosers
		+ (int(m_material[White].knight) - int(m_material[Black].knight))*KnightValueLosers
		+ (int(m_material[White].pawn  ) - int(m_material[Black].pawn  ))*PawnValueLosers;

	int score = material + (whiteToMove() ? bonus::WhiteToMove : -bonus::WhiteToMove);

	TRACE("score[material]                      = %d, %d\n", score);

	return score;
}


void
db::Guess::preEvaluateLosers()
{
}


int
db::Guess::evaluateLosers(int alpha, int beta)
{
	// Initialize.
	m_totalPieces[White]	= total(m_material[White]);
	m_totalPieces[Black]	= total(m_material[Black]);
	m_dangerous[White]	= 	(m_material[White].queen && m_totalPieces[White] > 13)
								|| (m_material[White].rook > 1 && m_totalPieces[White] > 15);
	m_dangerous[Black]	= 	(m_material[Black].queen && m_totalPieces[Black] > 13)
								|| (m_material[Black].rook > 1 && m_totalPieces[Black] > 15);
	m_tropism[White]		= 0;
	m_tropism[Black]		= 0;

	int score = evaluateMaterialLosers();

	if (m_pawnData->key != m_pawnHash)
	{
		PawnHashEntry* entry = m_pawnTable + (m_pawnHash & (PawnTableSize - 1));

		if (entry->key != m_pawnHash)
		{
			// initialize pawn score structure
			::memset(entry->eval, 0, sizeof(entry->eval));
			entry->key = m_pawnHash;
			entry->score = 0;

			// evaluatePawns() does all of the analysis for information
			// specifically regarding only pawns. In many cases, it merely
			// records the presence/absence of positional pawn feature
			// because that feature also depends on pieces. Note that
			// anything put into EvaluatePawns() can only consider the
			// placement of pawns.
			entry->score += evaluatePawnsLosers(White);
			entry->score -= evaluatePawnsLosers(Black);
		}

		m_pawnData = entry;
	}

	score += m_pawnData->score.middleGame;

	TRACE_2("score[evaluate pawns]                = %d, %d\n", score);

	// Now evaluate pieces.
	score += evaluateKnightsLosers(White, ::wflip);
	score -= evaluateKnightsLosers(Black, ::bflip);

	score += evaluateBishopsLosers(White, ::wflip);
	score -= evaluateBishopsLosers(Black, ::bflip);

	score += evaluateRooksLosers(White);
	score -= evaluateRooksLosers(Black);

	score += evaluateQueensLosers(White, ::wflip);
	score -= evaluateQueensLosers(Black, ::bflip);

	score += evaluateKingsLosers(White);
	score -= evaluateKingsLosers(Black);

	TRACE("score[pieces]                        = %d, %d\n", score);

	return score;
}


int
db::Guess::evaluateKingsLosers(color::ID side)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	sq::ID		kingSq	= this->kingSq(side);

	if (m_dangerous[opponent])
	{
		// Now fold in the king tropism and king pawn shelter
		// scores together. Also add in an enemy pawn tropism
		// score.
		if (	(king(side) & (HomeRankMask[side] | PawnRankMask[side]))
			&& (kingAttacks(kingSq) | kingAttacks(NextRank[side][kingSq])) & pawns(opponent))
		{
			m_tropism[opponent] += 3;
		}
	}
	else
	{
		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		uint64_t moves = (knightAttacks(kingSq) & ~m_occupiedBy[side]) | ::setBit(kingSq);

		score += count(moves & (FyleMaskA | FyleMaskH));
		score += count(moves & (FyleMaskB | FyleMaskG));
		score += ::mul2(count(moves & (FyleMaskC | FyleMaskF)));
		score += ::mul3(count(moves & (FyleMaskD | FyleMaskE)));

		TRACE_2("%s kings[mobility]                = %d, %d\n", printColor(side), score);
	}

	m_tropism[opponent] = mstl::max(0, mstl::min(15, m_tropism[opponent]));

	score -= safety::KingSafety[m_tropism[opponent]];

	TRACE("%s score[kings]                   = %d, %d\n", printColor(side), score);
	TRACE("%s score[tropism]                 = %d\n", printColor(opponent), m_tropism[opponent]);

	return score;
}


int
db::Guess::evaluateKnightsLosers(color::ID side, Flip flip)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	uint64_t		knights	= this->knights(side);

	// First, evaluate for "outposts" which is a knight that
	// can't be driven off by an enemy pawn, and which is
	// supported by a friendly pawn.
	while (knights)
	{
		sq::ID square			= sq::ID(lsbClear(knights));
		sq::ID flippedSquare	= flip(square);

		// First fold in centralization score.
		score += bonus::KnightSquare[flippedSquare];

		TRACE_2("%s knights[central]               = %d\n", printColor(side), score);

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		{
			static uint64_t const MobilityMask[4] =
			{
				RankMask1 | RankMask8 | FyleMaskA | FyleMaskH,
				((RankMask2 | RankMask7) & ~(A2 | H2 | A7 | H7)) | B3 | B4 | B5 | B6 | G3 | G4 | G5 | G6,
				C3 | D3 | E3 | F3 | C6 | D6 | E6 | F6 | C4 | C5 | F4 | F5,
				D4 | E4 | D5 | E5,
			};

			uint64_t moves = (knightAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerKnight;
			score += count(moves & MobilityMask[0]);
			score += ::mul2(count(moves & MobilityMask[1]));
			score += ::mul3(count(moves & MobilityMask[2]));
			score += ::mul4(count(moves & MobilityMask[3]));

			TRACE_2("%s knights[mobility]              = %d, %d\n", printColor(side), score);
		}

		// Adjust the tropism count for this piece.
		if (m_dangerous[side])
			m_tropism[side] += bonus::KnightKingTropism[sq::distance(square, kingSq(opponent))];
	}

	TRACE("%s score[knights]                 = %d, %d\n", printColor(side), score);
	TRACE("%s tropism[knights]               = %d\n", printColor(side), m_tropism[side]);

	return score;
}


int
db::Guess::evaluateBishopsLosers(color::ID side, Flip flip)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	int			pair		= hasBishopOnLite(side) && hasBishopOnDark(side);
	uint64_t		bishops	= this->bishops(side);

	TRACE_2("%s bishops[pawn on wings]         = %d, %d\n", printColor(side), score);

	// First, locate each bishop and add in its static score
	// from the bishop piece/square table.
	while (bishops)
	{
		sq::ID square			= sq::ID(lsbClear(bishops));
		sq::ID flippedSquare	= flip(square);

		score += bonus::BishopSquare[flippedSquare];

		TRACE_2("%s bishops[central]               = %d, %d\n", printColor(side), score);

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization.
		{
			static uint64_t const MobilityMask[4] =
			{
				RankMask1 | RankMask8 | FyleMaskA | FyleMaskH,
				((RankMask2 | RankMask7) & ~(A2 | H2 | A7 | H7)) | B3 | B4 | B5 | B6 | G3 | G4 | G5 | G6,
				C3 | D3 | E3 | F3 | C6 | D6 | E6 | F6 | C4 | C5 | F4 | F5,
				D4 | E4 | D5 | E5,
			};

			uint64_t moves = (bishopAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerBishop;
			score += count(moves & MobilityMask[0])*(1 + pair);
			score += count(moves & MobilityMask[1])*(2 + pair);
			score += count(moves & MobilityMask[2])*(3 + pair);
			score += count(moves & MobilityMask[3])*(4 + pair);

			TRACE_2("%s bishops[mobility]              = %d, %d\n", printColor(side), score);
		}

		// Adjust the tropism count for this piece.
		if (m_dangerous[side])
			m_tropism[side] += bonus::BishopKingTropism[sq::distance(square, kingSq(opponent))];
	}

	TRACE("%s score[bishops]                 = %d, %d\n", printColor(side), score);
	TRACE("%s tropism[bishops]               = %d\n", printColor(side), m_tropism[side]);

	return score;
}


int
db::Guess::evaluateRooksLosers(color::ID side)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	uint64_t		rooks		= this->rooks(side);
	Eval const&	eval		= m_pawnData->eval;

	while (rooks)
	{
		sq::ID	square	= sq::ID(lsbClear(rooks));
		int		fyle		= ::fyle(square);

		// Determine if the rook is on an open fyle or on a half-
		// open fyle, either of which increases its ability to
		// attack important squares (this is bad!).
		if (!(pawns(side) & FyleMask[fyle]))
		{
			if (!(pawns(opponent) & FyleMask[fyle]))
				score -= bonus::RookOpenFyle;
			else
				score -= bonus::RookHalfOpenFyle;
		}

		TRACE_2("%s rooks[(half) open fyle]        = %d, %d\n", printColor(side), score);
		TRACE_2("%s rooks[on 7th rank]             = %d, %d\n", printColor(side), score);

		// See if the rook is behind a passed pawn. If it is,
		// it is given a bonus.
		if (eval[White].passedPawn & (1 << fyle))
		{
			int pawnSq = msb(pawns(White) & FyleMask[fyle]);

			if (msb(fyleAttacks(square) & ::Plus8Dir[square]) == pawnSq)
				score += bonus::RookBehindPassedPawn;
		}

		if (eval[Black].passedPawn & (1 << fyle))
		{
			int pawnSq = lsb(pawns(Black) & FyleMask[fyle]);

			if (lsb(fyleAttacks(square) & ::Minus8Dir[square]) == pawnSq)
				score += bonus::RookBehindPassedPawn;
		}

		// Mobility counts the number of squares the piece
		// attacks, excluding squares with friendly pieces, and
		// weighs each square according to centralization (fyle).
		{
			uint64_t moves = (rookAttacks(square) & ~m_occupiedBy[side]) | ::setBit(square);

			score	-= penalty::LowerRook;
			score += count(moves & (FyleMaskA | FyleMaskH));
			score += ::mul2(count(moves & (FyleMaskB | FyleMaskG)));
			score += ::mul3(count(moves & (FyleMaskC | FyleMaskF)));
			score += ::mul4(count(moves & (FyleMaskD | FyleMaskE)));

			TRACE_2(	"%s rooks[mobility]                = %d, %d\n", printColor(side), score);
		}

		// Adjust the tropism count for this piece.
		if (m_dangerous[side])
		{
			uint64_t mask			= (m_queens | m_rooks) & m_occupiedBy[side];
			uint64_t rookAttacks	= rankAttacks(square, m_occupied & ~mask);
			uint64_t kingAttacks	= this->kingAttacks(m_ksq[opponent]);

			if (rookAttacks & kingAttacks)
			{
				m_tropism[side] += bonus::RookKingTropism[1];
			}
			else
			{
				uint64_t occupied = m_occupiedL90;

				while (mask)
					occupied &= ~MaskL90[lsbClear(mask)];

				rookAttacks = fyleAttacks(square, occupied);

				if (rookAttacks & kingAttacks)
					m_tropism[side] += bonus::RookKingTropism[1];
				else
					m_tropism[side] += bonus::RookKingTropism[sq::distance(square, kingSq(opponent))];
			}
		}
	}

	TRACE("%s score[rooks]                   = %d, %d\n", printColor(side), score);
	TRACE("%s tropism[rooks]                 = %d\n", printColor(side), m_tropism[side]);

	return score;
}


int
db::Guess::evaluateQueensLosers(color::ID side, Flip flip)
{
	int			score		= 0;
	color::ID	opponent	= opposite(side);
	uint64_t		queens	= this->queens(side);

	// First locate each queen and obtain it's centralization
	// score from the static piece/square table for queens.
	// Then, if the opposing side's king safety is much worse
	// than the king safety for this side, add in a bonus to
	// keep the queen around.

	while (queens)
	{
		sq::ID square			= sq::ID(lsbClear(queens));
		sq::ID flippedSquare	= flip(square);

		score += bonus::QueenSquare[flippedSquare];

		TRACE_2("%s queens[central]                = %d, %d\n", printColor(side), score);

		// Adjust the tropism count for this piece.
		//
		// Now we notice whether the queen is on a file that is
		// bearing on the enemy king and adjust tropism if so.
		if (m_dangerous[side])
			m_tropism[side] += bonus::QueenKingTropism[sq::distance(square, kingSq(opponent))];

		m_tropism[opponent] -= penalty::FriendlyQueen[sq::distance(square, kingSq(side))];
	}

	TRACE("%s score[queens]                  = %d, %d\n", printColor(side), score);
	TRACE("%s tropism[queens]                = %d\n", printColor(side), m_tropism[side]);

	return score;
}

// vi:set ts=3 sw=3:
