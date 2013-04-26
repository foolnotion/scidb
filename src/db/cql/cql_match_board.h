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

#ifndef _cql_match_board_included
#define _cql_match_board_included

#include "cql_designator.h"

#include "db_board.h"

#include "m_list.h"
#include "m_ring.h"
#include "m_vector.h"
#include "m_hash.h"

namespace db { class GameInfo; }

namespace cql {

class Position;

namespace board {

struct Match
{
	typedef db::GameInfo GameInfo;
	typedef db::Board Board;
	typedef db::variant::Type Variant;

	virtual ~Match() = 0;
	virtual bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) = 0;
};


struct MatchMinMax : public Match
{
	MatchMinMax();
	MatchMinMax(unsigned min, unsigned max);

	bool result(unsigned count);

	unsigned m_min;
	unsigned m_max;
};


class Designators : public Match
{
public:

	typedef mstl::list<Designator> List;

	void add(Designator const& designator);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	List m_list;
};


class AttackCount : public MatchMinMax
{
public:

	AttackCount(Designator const& fst, Designator const& snd, unsigned min, unsigned max);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Designator	m_fst;
	Designator	m_snd;
	bool			m_color[2];
};


class Castling : public Match
{
public:

	Castling(Designator const& designator);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	unsigned m_castling;
};


struct Check : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


class CheckCount : public Match
{
public:

	CheckCount(unsigned count);
	CheckCount(unsigned wcount, unsigned bcount);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	unsigned m_wcount;
	unsigned m_bcount;
};


struct DoubleCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct NoCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct NoDoubleCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct ContactCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct NoContactCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


class State : public Match
{
public:

	State();

	void add(unsigned state);
	void sub(unsigned state);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	unsigned m_and;
	unsigned m_not;
};


class ToMove : public Match
{
public:

	ToMove(db::color::ID color);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	db::color::ID m_color;
};


class Fen : public Match
{
public:

	Fen(Board const& board);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Board	m_board;
	bool	m_includeHolding;
};


struct FiftyMoveRule : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


class HalfmoveClockLimit : public Match
{
public:

	HalfmoveClockLimit(unsigned limit);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	unsigned m_limit;
};


class EndGame : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct NoEndGame : public Match
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct GappedSequence : public Match
{
	GappedSequence();
	~GappedSequence();

	virtual cql::Position& pushBack();

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

protected:

	typedef mstl::vector<cql::Position*> PositionList;

	GameInfo const*	m_info;
	PositionList		m_list;
	unsigned				m_index;
};


class Sequence : public GappedSequence
{
public:

	virtual cql::Position& pushBack() override;

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	typedef mstl::ring<Board> Stack;

	Stack m_stack;
};


class MatingMaterial : public Match
{
public:

	MatingMaterial(bool negate);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	bool m_negate;
};



class MaxSwapEvaluation : public MatchMinMax
{
public:

	MaxSwapEvaluation(Designator const& from, Designator const& to, int minScore, int maxScore);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Designator	m_from;
	Designator	m_to;
	int			m_minScore;
	int			m_maxScore;
};

class PieceCount : public MatchMinMax
{
public:

	PieceCount(Designator const& designator, unsigned min, unsigned max);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Designator m_designator;
};


class Power : public MatchMinMax
{
public:

	Power(Designator const& designator, unsigned min, unsigned max);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Designator m_designator;
};


class PowerDifference : public Match
{
public:

	PowerDifference(Designator const& designator, int min, int max);

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	Designator	m_designator;
	int			m_min;
	int			m_max;
};


class Repetition : public Match
{
public:

	Repetition();

	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;

private:

	struct Position
	{
		Position();
		Position(db::board::ExactZHPosition const& board);

		db::board::ExactZHPosition m_board;
		unsigned m_count;
	};

	typedef mstl::list<Position> PositionBucket;
	typedef mstl::hash<uint64_t,PositionBucket> RepetitionMap;

	GameInfo const*	m_info;
	RepetitionMap		m_map;
};


struct MatchRay : public MatchMinMax
{
	typedef mstl::vector<Designator> Designators;

	void add(Designator const& designator);

	Designators m_designators;
};


struct RayHorizontal : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct RayVertical : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct RayOrthogonal : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct RayDiagonal : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct Ray : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};


struct RayAttack : public MatchRay
{
	bool match(GameInfo const& info, Board const& board, Variant variant, bool isFinal) override;
};

} // namespace board
} // namespace cql

#include "cql_match_board.ipp"

#endif // _cql_match_board_included

// vi:set ts=3 sw=3:
