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

#include "db_time_table.h"

#include "m_assert.h"

using namespace db;


void
TimeTable::cut(unsigned newSize)
{
	M_REQUIRE(newSize <= size());
	m_table.resize(newSize);
}


void
TimeTable::add(MoveInfo const& moveInfo)
{
	M_REQUIRE(moveInfo.content() == MoveInfo::ElapsedMilliSeconds);
	m_table.push_back(moveInfo);
}


void
TimeTable::set(unsigned index, MoveInfo const& moveInfo)
{
	M_REQUIRE(moveInfo.content() == MoveInfo::ElapsedMilliSeconds);

	if (index <= m_table.size())
		m_table.resize(index + 1);

	m_table[index] = moveInfo;
}

// vi:set ts=3 sw=3:
