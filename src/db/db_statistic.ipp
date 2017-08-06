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
// Copyright: (C) 2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline
uint32_t
Statistic::positionCount(uint16_t idn) const
{
	M_ASSERT(idn <= variant::MaxCode);
	return m_counter.posFreq[idn];
}


inline
uint16_t
Statistic::idnAt(unsigned index) const
{
	M_REQUIRE(index < positions.count());
	return positions.index(index);
}


template <typename Iterator>
inline
void
Statistic::compute(Iterator first, Iterator last)
{
	if (content.minYear == 0)
		content.minYear = 9999;
	if (content.minElo == 0)
		content.minElo = 9999;

	for ( ; first != last; ++first)
		count(*first);

	if (content.minYear == 9999)
		content.minYear = 0;
	if (content.minElo == 9999)
		content.minElo = 0;

	content.avgYear = uint16_t(m_counter.sumYear/m_counter.dateCount + 0.5);
	content.avgElo = uint16_t(m_counter.sumElo/m_counter.eloCount + 0.5);
}

} // namespace db

// vi:set ts=3 sw=3:
