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

namespace cql {
namespace board {

inline Repetition::Position::Position() :m_count(1) {}

inline
Repetition::Position::Position(::db::board::ExactZHPosition const& board)
	:m_board(board)
	,m_count(1)
{
}

inline CannotWin::CannotWin(db::color::ID color) :m_color(color) {}
inline CheckCount::CheckCount(unsigned count) :m_wcount(count), m_bcount(4) {}
inline CheckCount::CheckCount(unsigned wcount, unsigned bcount) :m_wcount(wcount), m_bcount(bcount) {}
inline HalfmoveClockLimit::HalfmoveClockLimit(unsigned limit) :m_limit(limit) {}
inline MatchMinMax::MatchMinMax() :m_min(1), m_max(1000) {}
inline MatchMinMax::MatchMinMax(unsigned min, unsigned max) :m_min(min), m_max(max) {}
inline MatingMaterial::MatingMaterial(bool negate) :m_negate(negate) {}
inline State::State() :m_and(0), m_not(0) {}
inline ToMove::ToMove(db::color::ID color) :m_color(color) {}
inline GappedSequence::GappedSequence() :m_info(0), m_index(0) {}
inline Repetition::Repetition() :m_info(0) {}

inline
Evaluation::Evaluation(Mode mode, unsigned ply)
	:m_mode(mode)
	,m_view(SideToMove)
	,m_arg(ply)
	,m_lower(0.0)
	,m_upper(0.0)
{
}

inline
Evaluation::Evaluation(Mode mode, unsigned n, float lower, float upper, View view)
	:m_mode(mode)
	,m_view(view)
	,m_arg(n)
	,m_lower(lower)
	,m_upper(upper)
{
}

inline
MaxSwapEvaluation::MaxSwapEvaluation(	Designator const& from,
													Designator const& to,
													int minScore,
													int maxScore)
	:m_from(from)
	,m_to(to)
	,m_minScore(minScore)
	,m_maxScore(maxScore)
{
}

inline
Power::Power(Designator const& designator, unsigned min, unsigned max)
	:MatchMinMax(min, max)
	,m_designator(designator)
{
}

inline
PowerDifference::PowerDifference(Designator const& designator, int min, int max)
	:m_designator(designator)
	,m_min(min)
	,m_max(max)
{
}

inline
PieceCount::PieceCount(Designator const& designator, unsigned min, unsigned max)
	:MatchMinMax(min, max)
	,m_designator(designator)
{
}

inline void Designators::add(Designator const& designator) { m_list.push_back(designator); }

inline void State::add(unsigned state) { m_and |= state; }
inline void State::sub(unsigned state) { m_not |= state; }

} // namespace board
} // namespace cql

// vi:set ts=3 sw=3:
