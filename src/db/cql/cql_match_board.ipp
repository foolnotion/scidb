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

inline MatchMinMax::MatchMinMax() :m_min(1), m_max(1000) {}
inline MatchMinMax::MatchMinMax(unsigned min, unsigned max) :m_min(min), m_max(max) {}
inline State::State() :m_and(0), m_not(0) {}
inline ToMove::ToMove(db::color::ID color) :m_color(color) {}
inline GappedSequence::GappedSequence() :m_info(0), m_index(0) {}
inline Repetition::Repetition() :m_info(0) {}

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
