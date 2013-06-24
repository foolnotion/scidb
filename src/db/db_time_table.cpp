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

#include "m_utility.h"
#include "m_bit_functions.h"
#include "m_assert.h"

#include <string.h>

using namespace db;


TimeTable::TimeTable()
	:m_types(0)
{
	::memset(m_size, 0, sizeof(m_size));
}


void
TimeTable::clear()
{
	m_table.clear();
	::memset(m_size, 0, sizeof(m_size));
}


void
TimeTable::cut(unsigned newSize)
{
	M_REQUIRE(newSize <= size());

	m_table.resize(newSize);
	::memset(m_size, 0, sizeof(m_size));

	for (unsigned i = 0; i < m_table.size(); ++i)
	{
		for (unsigned t = 0; t < MoveInfo::LAST; ++t)
		{
			if (!m_table[i][t].isEmpty())
				m_size[t] = i + 1;
		}
	}
}


void
TimeTable::ensure(unsigned size)
{
	m_table.reserve(size);

	while (m_table.size() < size)
	{
		m_table.push_back();
		m_table.back().resize(MoveInfo::LAST);
	}
}


void
TimeTable::set(unsigned index, MoveInfo const& moveInfo)
{
	M_REQUIRE(index < size());
	M_REQUIRE(!moveInfo.isEmpty());

	unsigned col = moveInfo.content() - 1;

	m_table[index][col] = moveInfo;
	m_size[col] = mstl::max(m_size[col], index + 1);
	m_types |= 1 << col;
}


void
TimeTable::set(unsigned index, MoveInfoSet const& moveInfoSet)
{
	unsigned size = index + 1;

	if (m_table.size() < size)
		ensure(size);

	MoveInfoSet& set = m_table[index];

	set.resize(MoveInfo::LAST);

	for (unsigned i = 0; i < moveInfoSet.count(); ++i)
	{
		static_assert(MoveInfo::None == 0, "wrong index access");

		MoveInfo const&	info	= moveInfoSet[i];
		unsigned				col	= info.content() - 1;

		M_ASSERT(!info.isEmpty());

		set[col] = info;
		m_size[col] = mstl::max(m_size[col], size);
		m_types |= 1 << col;
	}
}


unsigned
TimeTable::columns() const
{
	return mstl::bf::count_bits(m_types);
}

// vi:set ts=3 sw=3:
