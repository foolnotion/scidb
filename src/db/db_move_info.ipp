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
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline bool MoveInfo::isEmpty() const				{ return m_content == None; }
inline MoveInfo::Type MoveInfo::content() const	{ return m_content; }


inline
bool
MoveInfo::hasTimeInfo() const
{
	return m_content != AnalysisInformation && m_content != None;
}


inline
bool
MoveInfo::hasAnalysisInfo() const
{
	return m_content == AnalysisInformation;
}


inline
Clock const&
MoveInfo::clock() const
{
	M_REQUIRE(hasTimeInfo());
	return m_time.m_clock;
}


inline
Date const&
MoveInfo::date() const
{
	M_REQUIRE(hasTimeInfo());
	return m_time.m_date;
}


inline
unsigned
MoveInfo::engine() const
{
	M_REQUIRE(hasAnalysisInfo());
	return m_analysis.m_engine;
}


inline
unsigned
MoveInfo::depth() const
{
	M_REQUIRE(hasAnalysisInfo());
	return m_analysis.m_depth;
}


inline
unsigned
MoveInfo::pawns() const
{
	M_REQUIRE(hasAnalysisInfo());
	return m_analysis.m_pawns;
}


inline
unsigned
MoveInfo::centipawns() const
{
	M_REQUIRE(hasAnalysisInfo());
	return m_analysis.m_centipawns;
}


inline
float
MoveInfo::value() const
{
	M_REQUIRE(hasAnalysisInfo());
	return float(m_analysis.m_pawns) + float(m_analysis.m_centipawns)/100.0f;
}

} // namespace db

// vi:set ts=3 sw=3:
