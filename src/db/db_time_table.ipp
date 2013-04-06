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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline bool TimeTable::isEmpty() const					{ return m_table.empty(); }

inline unsigned TimeTable::size() const				{ return m_table.size(); }

inline void TimeTable::reserve(unsigned capacity)	{ m_table.reserve(capacity); }
inline void TimeTable::swap(TimeTable& table)		{ m_table.swap(table.m_table); }

inline MoveInfoSet const& TimeTable::operator[](unsigned index) const { return m_table[index]; }


inline
MoveInfo const&
TimeTable::get(unsigned index, MoveInfo::Type type) const
{
	return m_table[index][type - 1];
}


inline
unsigned
TimeTable::size(unsigned col) const
{
	M_REQUIRE(col < MoveInfo::LAST);
	return m_size[col];
}

} // namespace db

// vi:set ts=3 sw=3:
