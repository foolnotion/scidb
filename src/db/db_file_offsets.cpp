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

#include "db_file_offsets.h"

#include "m_assert.h"

using namespace db;


void
FileOffsets::resize(unsigned n)
{
	for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
		m_indexMap[i].resize(n);

	m_offsets.reserve(n);
}


void
FileOffsets::setIndex(unsigned variant, unsigned gameIndex)
{
	M_REQUIRE(variant < variant::NumberOfVariants);

	IndexMap& map = m_indexMap[variant];

	if (map.size() <= gameIndex)
		map.resize(map.size() + 32768);

	map.set(gameIndex);
}

// vi:set ts=3 sw=3:
