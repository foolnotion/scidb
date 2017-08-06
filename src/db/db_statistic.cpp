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
// Copyright: (C) 2009-2017 Gregor Cramer
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


Statistic::Statistic()
	:positions(variant::MaxCode + 1)
{
	reset();
}


void
Statistic::reset()
{
	::memset(&content, 0, sizeof(content));
	::memset(&counter, 0, sizeof(counter));
	::memset(&m_counter, 0, sizeof(m_counter));

	positions.reset();
}


void
Statistic::addLanguages(GameInfo const& info)
{
	/*if (info.containsAllLanguage())
	{
		++counter.allLang;
		++counter.commented;

		if (info.containsEnglishLanguage())
			++counter.englishLang;
		if (info.containsOtherLanguage())
			++counter.otherLang;
	}
	else */if (info.containsEnglishLanguage())
	{
		++counter.englishLang;
		++counter.commented;

		if (info.containsOtherLanguage())
			++counter.otherLang;
	}
	else if (info.containsOtherLanguage())
	{
		++counter.otherLang;
		++counter.commented;
	}
}


void
Statistic::addPosition(GameInfo const& info)
{
	uint16_t idn = info.idn();

	M_ASSERT(idn <= variant::MaxCode);
	positions.set(idn);
	++m_counter.posFreq[idn];
}


void
Statistic::removeLanguages(GameInfo const& info)
{
	/*if (info.containsAllLanguage())
	{
		--counter.allLang;
		--counter.commented;

		if (info.containsEnglishLanguage())
			--counter.englishLang;

		if (info.containsOtherLanguage())
			--counter.otherLang;
	}
	else */if (info.containsEnglishLanguage())
	{
		--counter.englishLang;
		--counter.commented;

		if (info.containsOtherLanguage())
			--counter.otherLang;
	}
	else if (info.containsOtherLanguage())
	{
		--counter.otherLang;
		--counter.commented;
	}
}


void
Statistic::removePosition(GameInfo const& info)
{
	uint16_t idn = info.idn();

	M_ASSERT(idn <= variant::MaxCode);

	if (--m_counter.posFreq[idn] == 0)
		positions.reset(idn);
}


void
Statistic::count(GameInfo const& info)
{
	if (info.isDeleted())
		++counter.deleted;

	// TODO: use SSE

	uint16_t year = info.dateYear();

	if (year)
	{
		if (year < content.minYear)
			content.minYear = year;
		else if (year > content.maxYear)
			content.maxYear = year;

		m_counter.sumYear += year;
		++m_counter.dateCount;
	}

	uint16_t elo = info.elo(color::White);

	if (elo)
	{
		if (elo < content.minElo)
			content.minElo = elo;
		else if (elo > content.maxElo)
			content.maxElo = elo;

		m_counter.sumElo += elo;
		++m_counter.eloCount;
	}

	elo = info.elo(color::Black);

	if (elo)
	{
		if (elo < content.minElo)
			content.minElo = elo;
		else if (elo > content.maxElo)
			content.maxElo = elo;

		m_counter.sumElo += elo;
		++m_counter.eloCount;
	}

	M_ASSERT(info.result() < int(U_NUMBER_OF(content.result)));
	++content.result[info.result()];

	addLanguages(info);
	addPosition(info);
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

	content.avgYear = uint16_t(m_counter.sumYear/m_counter.dateCount + 0.5);
	content.avgElo = uint16_t(m_counter.sumElo/m_counter.eloCount + 0.5);
}

// vi:set ts=3 sw=3:
