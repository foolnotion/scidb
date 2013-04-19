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
namespace relation {

inline MatchMinMax::MatchMinMax(unsigned min, unsigned max) :m_min(min), m_max(max) {}
inline OriginalDifferentCount::OriginalDifferentCount() :MatchMinMax(1, 1000) {}
inline OriginalSameCount::OriginalSameCount() :MatchMinMax(1, 1000) {}
inline MissingPieceCount::MissingPieceCount() :MatchMinMax(0, 0) {}
inline NewPieceCount::NewPieceCount() :MatchMinMax(0, 0) {}

inline bool MatchMinMax::result(unsigned count) { return m_min <= count && count <= m_max; }

} // namespace relation
} // namespace cql

// vi:set ts=3 sw=3:
