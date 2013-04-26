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
namespace move {

inline MoveFrom::MoveFrom(Designator const& designator) :m_designator(designator) {}
inline MoveTo::MoveTo(Designator const& designator) :m_designator(designator) {}
inline PieceDrop::PieceDrop(Designator const& designator) :m_designator(designator) {}
inline Promote::Promote(Designator const& designator) :m_designator(designator) {}

inline
ExchangeEvaluation::ExchangeEvaluation(int minScore, int maxScore)
	:m_minScore(minScore)
	,m_maxScore(maxScore)
{
}

} // namespace move
} // namespace cql

// vi:set ts=3 sw=3:
