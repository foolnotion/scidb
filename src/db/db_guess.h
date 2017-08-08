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

#ifndef _db_guess_included
#define _db_guess_included

#include "db_board.h"
#include "db_move_list.h"

// null move search is probably not recommendable
//#define USE_NULL_MOVE_SEARCH

namespace db {

class Board;

class Guess : public Board
{
public:

	enum { MaxDepth = 7, DefaultDepth = 3 };
	enum { IdnStandard = variant::Standard };

	Guess(Board const& board, variant::Type variant, uint16_t idn);
	~Guess() throw();

	Move search(Square square, unsigned maxDepth = DefaultDepth);
	Move bestMove(Square square, unsigned maxDepth = DefaultDepth);
	Move bestMove(	Square square,
						MoveList const& exclude,
						unsigned maxDepth = DefaultDepth);
	Square bestSquare(Square square, unsigned maxDepth = DefaultDepth);

	struct Score
	{
		Score();
		Score(int score);
		Score(int middleGameScore, int endGameScore);

		Score operator/(int n) const;
		Score operator*(int n) const;
		Score operator+(int n) const;
		Score operator-(int n) const;
		Score operator-() const;

		Score& operator+=(int score);
		Score& operator-=(int score);
		Score& operator+=(Score const& score);
		Score& operator-=(Score const& score);

		int weightedScore(int totalPiecesWhite, int totalPiecesBlack) const;

		int middleGame;
		int endGame;
	};

	class Transposition;

private:

	enum { PawnTableSize = 512 };

	enum WinningChances
	{
		NeitherSideCanWin,	// neither side can win, this is a dead drawn position
		OnlyWhiteCanWin,		// white can win, black can not win
		OnlyBlackCanWin,		// white can not win, black can win
		BothSidesCanWin,		// both white and black can win
	};

#if 0
	enum Recognized
	{
		RecogDraw,
		RecogWin,
		RecogUnknown,
	};
#endif

	typedef sq::ID (*Flip)(sq::ID);
	typedef int const PieceValues[8];

	static int constexpr Infinity					= 32000;

	static int constexpr KingValue				= 32767;
	static int constexpr QueenValue				=   970;
	static int constexpr RookValue				=   500;
	static int constexpr BishopValue				=   325;
	static int constexpr KnightValue				=   300;
	static int constexpr PawnValue				=   100;

	static int constexpr KingValueZH				= 32767;
	static int constexpr QueenValueZH			=   480; // Sjeng gives 450
	static int constexpr RookValueZH				=   300; // Sjeng gives 250
	static int constexpr BishopValueZH			=   300; // Sjeng gives 230
	static int constexpr KnightValueZH			=   250; // sjeng gives 210
	static int constexpr PawnValueZH				=   130; // Sjeng gives 100

	static int constexpr QueenValueInHand		=   450; // Sjeng gives 450
	static int constexpr RookValueInHand		=   300; // Sjeng gives 250
	static int constexpr BishopValueInHand		=   240; // Sjeng gives 230
	static int constexpr KnightValueInHand		=   250; // sjeng gives 210
	static int constexpr PawnValueInHand		=   100; // Sjeng gives 100

	// Piece values from Sjeng
	static int constexpr KingValueSuicide		=  500; //                    -- 280
	static int constexpr QueenValueSuicide		=   50; // Nilatac gives  100 -- 390
	static int constexpr RookValueSuicide		=  150; // Nilatac gives  500 -- 500
	static int constexpr BishopValueSuicide	=    0; // Nilatac gives -200 -- 370
	static int constexpr KnightValueSuicide	=  150; // Nilatac gives   50 -- 340
	static int constexpr PawnValueSuicide		=   15; // Nilatac gives -100 -- 290

	// Piece values from Sjeng
	static int constexpr KingValueLosers		= 5000;
	static int constexpr QueenValueLosers		=  400;
	static int constexpr RookValueLosers		=  350;
	static int constexpr BishopValueLosers		=  270;
	static int constexpr KnightValueLosers		=  320;
	static int constexpr PawnValueLosers		=   80;

	void generateMoves(Square square, MoveList& result) const;

	Move search(MoveList& moves, unsigned maxDepth);
	int quiesce(int alpha, int beta, bool isPromotion);
	int quiesce(int alpha, int beta);

#ifdef USE_NULL_MOVE_SEARCH
	int search(MoveList& moves, unsigned depth, int alpha, int beta, bool allowNull);
	int iterate(MoveList& moves, unsigned depth, int alpha, int beta, bool allowNull);
#else
	int search(MoveList& moves, unsigned depth, int alpha, int beta);
	int iterate(MoveList& moves, unsigned depth, int alpha, int beta);
#endif
	int search1(MoveList& moves, int alpha, int beta);
	int iterate(MoveList& moves, int alpha, int beta);

	void addKillerMove(Move const& move, int score);
	bool isKillerMove(uint32_t move, unsigned index);

	bool kingIsInCheck(color::ID color) const;
	bool kingMovesIntoCheck(Move const& move) const;
	bool boardIsLegal() const;
	int evaluateNoMoves() const;
	int countAllPieces(color::ID side) const;
	int staticExchangeEvaluator(Move const& move) const;
	uint64_t addXrayPiece(unsigned from, unsigned target) const;
	int pieceValue(piece::Type piece, Square from) const;

	// normal chess evaluation
	void preEvaluate();
	void preEvaluateNormal();
	void preEvaluate3check();
	void preEvaluateZH();
	int evaluate(int alpha, int beta);
	int evaluate3check(int alpha, int beta);
	int evaluateZH(int alpha, int beta);
	Score evaluateMaterial();
	Score evaluateMaterialZH();
	int evaluateMaterialDynamic(color::ID side);
	WinningChances evaluateWinningChances();
	bool evaluateWinningChances(color::ID side);
	int evaluateDraws(WinningChances canWin, int score);
	int evaluateMate(color::ID side);
	int evaluateDevelopment(color::ID side);
	Score evaluateKings(color::ID side, Flip flip);
	Score evaluateKnights(color::ID side, Flip flip);
	Score evaluateBishops(color::ID side, Flip flip);
	Score evaluateRooks(color::ID side, Flip flip);
	Score evaluateQueens(color::ID side, Flip flip);
	Score evaluatePawns(color::ID side);
	int evaluateKingsFyle(color::ID side, int whichFyle);
	Score evaluateWeakPawns(color::ID side, int square, uint64_t pawnMoves);
	Score evaluatePassedPawns(color::ID side, Flip flip);
	Score evaluatePassedPawnRaces();
	bool doScorePieces(Score score, int alpha, int beta) const;
	bool doScorePiecesZH(Score score, int alpha, int beta) const;

	// Suicide evaluation
	void preEvaluateSuicide();
	int evaluateSuicide(int alpha, int beta);
	int evaluateMaterialSuicide();
	int evaluateKnightsSuicide(color::ID side, Flip flip);
	int evaluateBishopsSuicide(color::ID side, Flip flip);
	int evaluateQueensSuicide(color::ID side, Flip flip);
	int evaluateRooksSuicide(color::ID side);
	int evaluatePawnsSuicide(color::ID side);
	int evaluateKingsSuicide(color::ID side);

	// Losers evaluation
	void preEvaluateLosers();
	int evaluateLosers(int alpha, int beta);
	int evaluateMaterialLosers();
	int evaluateKnightsLosers(color::ID side, Flip flip);
	int evaluateBishopsLosers(color::ID side, Flip flip);
	int evaluateQueensLosers(color::ID side, Flip flip);
	int evaluateRooksLosers(color::ID side);
	int evaluatePawnsLosers(color::ID side);
	int evaluateKingsLosers(color::ID side);

#if 0
	Recognized recognize();
	Recognized recogMateInCorner();
	Recognized recogKPK(color::ID side);
	Recognized recogKBPK(color::ID side);
	Recognized recogKQKP(color::ID side);
#endif

	Move setColor(Move move);

	static unsigned minor(Material mat);
	static unsigned major(Material mat);
	static unsigned total(Material mat);

	struct PawnEval
	{
		int8_t	defects[8];
		int8_t	longVsShortScore;
		int8_t	shortVsLongScore;
		uint8_t	openFyle;
		uint8_t	passedPawn;
		uint8_t	candidates;
		uint8_t	all;
	};

	typedef PawnEval Eval[2];

	struct PawnHashEntry
	{
		uint64_t	key;
		Score		score;
		Eval		eval;
	};

	struct Root
	{
		Byte m_castle;
		Byte m_stm;

		castling::Rights castlingRights(color::ID side) const;
		bool canCastle(color::ID side) const;
		color::ID sideToMove() const;
	};

	typedef int (Guess::*EvalMeth)(int, int);
	typedef void (Guess::*PreEvalMeth)();

	static PieceValues PieceStandard;
	static PieceValues PieceSuicide;
	static PieceValues PieceLosers;
	static PieceValues PieceZH;
	static PieceValues PieceInHand;

	variant::Type	m_variant;
	int				m_idn;
	int				m_totalPieces[2];
	int				m_tropism[2];
	int				m_majors;
	int				m_minors;
	PawnHashEntry*	m_pawnData;
	PawnHashEntry	m_pawnTable[PawnTableSize];
	bool				m_dangerous[2];
	Root				m_root;
	Transposition*	m_trans;
	uint32_t			m_killer[(2*MaxDepth + 2)*2];
	unsigned			m_ply;
	PreEvalMeth		m_preEvalMeth;
	EvalMeth			m_evalMeth;
	int const*		m_pieceValues;
	int				m_dangerFactor;
	int				m_kingSafetyFactor;
#ifdef USE_NULL_MOVE_SEARCH
	int				m_pvCounter;
#endif
};

Guess::Score operator*(int n, Guess::Score const& score);
Guess::Score operator+(int n, Guess::Score const& score);
Guess::Score operator-(int n, Guess::Score const& score);

} // namespace db

#include "db_guess.ipp"

#endif // _db_guess_included

// vi:set ts=3 sw=3:
