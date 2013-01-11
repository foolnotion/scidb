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

#ifndef _db_time_table_included
#define _db_time_table_included

#include "db_move_info.h"

#include "m_vector.h"

namespace db {

class TimeTable
{
public:

	MoveInfo const& operator[](unsigned index) const;

	bool isEmpty() const;

	unsigned size() const;

	void clear();
	void cut(unsigned newSize);
	void reserve(unsigned capacity);
	void add(MoveInfo const& moveInfo);
	void set(unsigned index, MoveInfo const& moveInfo);

private:

	typedef mstl::vector<MoveInfo> Table;

	Table m_table;
};

} // namespace db

#include "db_time_table.ipp"

#endif // _db_time_table_included

// vi:set ts=3 sw=3:
