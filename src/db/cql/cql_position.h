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

#include "cql_designator.h"

#include "m_list.h"
#include "m_vector.h"
#include "m_function.h"

namespace db
{
	class GameInfo;
	class Board;
	class Move;
}

namespace cql {

namespace board { class Designators; }
namespace board { class State; }
namespace board { class Match; }
namespace board { class MatchRay; }
namespace move  { class Match; }

class Match;
class Relation;

class Position
{
public:

	typedef error::Type Error;
	typedef db::variant::Type Variant;
	typedef db::GameInfo GameInfo;
	typedef db::Board Board;
	typedef db::Move Move;

	Position();
	~Position();

	void reset();

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal);
	bool match(Board const& board, Move const& move, Variant variant);

	char const* parse(Match& match, char const* s, Error& error);
	void finish(Match& match);
	void toggleNot();

	static Position* makeLogicalAnd(Match& match, char const*& s, Error& error);
	static Position* makeLogicalOr(Match& match, char const*& s, Error& error);

	static char const* parseUnsignedRange(char const* s, Error& error, unsigned& min, unsigned& max);
	static char const* parseSignedRange(char const* s, Error& error, int& min, int& max);

private:

	typedef mstl::list<Designator> Designators;
	typedef mstl::vector<board::Match*> BoardMatchList;
	typedef mstl::vector<move::Match*> MoveMatchList;
	typedef mstl::vector<Position*> PositionList;
	typedef mstl::function<void ()> CutFunc;

	bool doMatch(GameInfo const& info, Board const& board, Variant variant, bool isFinal);
	bool doMatch(Board const& board, Move const& move, Variant variant);

	char const* adopt(Match& match, char const* s, Error& error);

	char const* parseAccumulate(Match& match, char const* s, Error& error);
	char const* parseAnd(Match& match, char const* s, Error& error);
	char const* parseAttackCount(Match& match, char const* s, Error& error);
	char const* parseBlackElo(Match& match, char const* s, Error& error);
	char const* parseBlackRating(Match& match, char const* s, Error& error);
	char const* parseBlackToMove(Match& match, char const* s, Error& error);
	char const* parseCastling(Match& match, char const* s, Error& error);
	char const* parseCut(Match& match, char const* s, Error& error);
	char const* parseIsCastling(Match& match, char const* s, Error& error);
	char const* parseCheck(Match& match, char const* s, Error& error);
	char const* parseCheckCount(Match& match, char const* s, Error& error);
	char const* parseContactCheck(Match& match, char const* s, Error& error);
	char const* parseDoubleCheck(Match& match, char const* s, Error& error);
	char const* parseElo(Match& match, char const* s, Error& error);
	char const* parseEndGame(Match& match, char const* s, Error& error);
	char const* parseEnPassant(Match& match, char const* s, Error& error);
	char const* parseExchangeEvaluation(Match& match, char const* s, Error& error);
	char const* parseExclude(Match& match, char const* s, Error& error);
	char const* parseFen(Match& match, char const* s, Error& error);
	char const* parseFiftyMoveRule(Match& match, char const* s, Error& error);
	char const* parseFlip(Match& match, char const* s, Error& error);
	char const* parseFlipColor(Match& match, char const* s, Error& error);
	char const* parseFlipDiagonal(Match& match, char const* s, Error& error);
	char const* parseFlipDihedral(Match& match, char const* s, Error& error);
	char const* parseFlipHorizontal(Match& match, char const* s, Error& error);
	char const* parseFlipOffDiagonal(Match& match, char const* s, Error& error);
	char const* parseFlipVertical(Match& match, char const* s, Error& error);
	char const* parseGameIsOver(Match& match, char const* s, Error& error);
	char const* parseGappedSequence(Match& match, char const* s, Error& error);
	char const* parseHalfmoveClockLimit(Match& match, char const* s, Error& error);
	char const* parseInitial(Match& match, char const* s, Error& error);
	char const* parseInside(Match& match, char const* s, Error& error);
	char const* parseLosing(Match& match, char const* s, Error& error);
	char const* parseMarkAll(Match& match, char const* s, Error& error);
	char const* parseMatchCount(Match& match, char const* s, Error& error);
	char const* parseMate(Match& match, char const* s, Error& error);
	char const* parseMatingMaterial(Match& match, char const* s, Error& error);
	char const* parseMaxSwapEvaluation(Match& match, char const* s, Error& error);
	char const* parseMoveFrom(Match& match, char const* s, Error& error);
	char const* parseMoveNumber(Match& match, char const* s, Error& error);
	char const* parseMoveTo(Match& match, char const* s, Error& error);
	char const* parseNoAnnotate(Match& match, char const* s, Error& error);
	char const* parseNoCastling(Match& match, char const* s, Error& error);
	char const* parseNoCheck(Match& match, char const* s, Error& error);
	char const* parseNoContactCheck(Match& match, char const* s, Error& error);
	char const* parseNoDoubleCheck(Match& match, char const* s, Error& error);
	char const* parseNoEndGame(Match& match, char const* s, Error& error);
	char const* parseNoEnpassant(Match& match, char const* s, Error& error);
	char const* parseNoMate(Match& match, char const* s, Error& error);
	char const* parseNoMatingMaterial(Match& match, char const* s, Error& error);
	char const* parseNoStalemate(Match& match, char const* s, Error& error);
	char const* parseNot(Match& match, char const* s, Error& error);
	char const* parseOr(Match& match, char const* s, Error& error);
	char const* parsePattern(Match& match, char const* s, Error& error);
	char const* parsePieceCount(Match& match, char const* s, Error& error);
	char const* parsePieceDrop(Match& match, char const* s, Error& error);
	char const* parsePower(Match& match, char const* s, Error& error);
	char const* parsePowerDifference(Match& match, char const* s, Error& error);
	char const* parsePreTransformMatchCount(Match& match, char const* s, Error& error);
	char const* parsePromote(Match& match, char const* s, Error& error);
	char const* parseRating(Match& match, char const* s, Error& error);
	char const* parseRay(Match& match, char const* s, Error& error);
	char const* parseRayAttack(Match& match, char const* s, Error& error);
	char const* parseRayDiagonal(Match& match, char const* s, Error& error);
	char const* parseRayHorizontal(Match& match, char const* s, Error& error);
	char const* parseRayOrthogonal(Match& match, char const* s, Error& error);
	char const* parseRayVertical(Match& match, char const* s, Error& error);
	char const* parseRelation(Match& match, char const* s, Error& error);
	char const* parseRepetition(Match& match, char const* s, Error& error);
	char const* parseReset(Match& match, char const* s, Error& error);
	char const* parseResult(Match& match, char const* s, Error& error);
	char const* parseSequence(Match& match, char const* s, Error& error);
	char const* parseShift(Match& match, char const* s, Error& error);
	char const* parseShiftDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftHorizontal(Match& match, char const* s, Error& error);
	char const* parseShiftMainDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftOffDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftVertical(Match& match, char const* s, Error& error);
	char const* parseStalemate(Match& match, char const* s, Error& error);
	char const* parseSumRange(Match& match, char const* s, Error& error);
	char const* parseTagMatch(Match& match, char const* s, Error& error);
	char const* parseTerminal(Match& match, char const* s, Error& error);
	char const* parseVariations(Match& match, char const* s, Error& error);
	char const* parseVariationsOnly(Match& match, char const* s, Error& error);
	char const* parseWhiteElo(Match& match, char const* s, Error& error);
	char const* parseWhiteRating(Match& match, char const* s, Error& error);
	char const* parseWhiteToMove(Match& match, char const* s, Error& error);

	char const* parseRay(Match& match, char const* s, Error& error, cql::board::MatchRay* ray);

	BoardMatchList			m_boardMatchList;
	MoveMatchList			m_moveMatchList;
	PositionList			m_positionList;
	Relation*				m_relation;
	Position*				m_cutExpression;
	board::Designators*	m_designators;
	board::State*			m_state;
	board::State*			m_finalState;
	bool						m_includeMainline;
	bool						m_includeVariations;
	bool						m_not;
	bool						m_preceding;
	CutFunc					m_cutFunc;
	unsigned					m_matchCount;
	unsigned					m_minMatchCount;
	unsigned					m_maxMatchCount;
	unsigned					m_minMoveNumber;
	unsigned					m_maxMoveNumber;
	unsigned					m_transformations;
};

} // namespace cql

// vi:set ts=3 sw=3:
