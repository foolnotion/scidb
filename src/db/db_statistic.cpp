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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_statistic.h"
#include "db_game_info.h"

#include <string.h>

using namespace db;


Statistic::Statistic() { clear(); }


void
Statistic::clear()
{
	::memset(this, 0, sizeof(*this));
}


void
Statistic::reset()
{
	::memset(&content, 0, sizeof(content));
}


void
Statistic::count(GameInfo const& info)
{
	if (info.isDeleted())
		++deleted;

	// TODO: use SSE

	uint16_t year = info.date().year();

	if (year)
	{
		if (year < content.minYear)
			content.minYear = year;
		else if (year > content.maxYear)
			content.maxYear = year;

		m_sumYear += year;
		++m_dateCount;
	}

	uint16_t elo = info.elo(color::White);

	if (elo)
	{
		if (elo < content.minElo)
			content.minElo = elo;
		else if (elo > content.maxElo)
			content.maxElo = elo;

		m_sumElo += elo;
		++m_eloCount;
	}

	elo = info.elo(color::Black);

	if (elo)
	{
		if (elo < content.minElo)
			content.minElo = elo;
		else if (elo > content.maxElo)
			content.maxElo = elo;

		m_sumElo += elo;
		++m_eloCount;
	}

	M_ASSERT(info.result() < int(U_NUMBER_OF(content.result)));
	++content.result[info.result()];
}


void
Statistic::add(GameInfo const& info)
{
	if (content.minYear == 0)
		content.minYear = 9999;
	if (content.minElo == 0)
		content.minElo = 9999;

	count(info);

	if (content.minYear == 9999)
		content.minYear = 0;
	if (content.minElo == 9999)
		content.minElo = 0;

	content.avgYear = uint16_t(m_sumYear/m_dateCount + 0.5);
	content.avgElo = uint16_t(m_sumElo/m_eloCount + 0.5);
}


void
Statistic::compute(GameInfo* const* first, GameInfo* const* last, Mode mode)
{
	if (mode == Reset)
		reset();

	if (content.minYear == 0)
		content.minYear = 9999;
	if (content.minElo == 0)
		content.minElo = 9999;

	for ( ; first != last; ++first)
		count(**first);

	if (content.minYear == 9999)
		content.minYear = 0;
	if (content.minElo == 9999)
		content.minElo = 0;

	content.avgYear = uint16_t(m_sumYear/m_dateCount + 0.5);
	content.avgElo = uint16_t(m_sumElo/m_eloCount + 0.5);
}

// vi:set ts=3 sw=3:
