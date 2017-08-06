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

#ifndef _db_statistic_included
#define _db_statistic_included

#include "db_common.h"

#include "m_bitset.h"

namespace db {

class GameInfo;

class Statistic
{
public:

	enum Mode { Reset, Continue };

	Statistic();

	uint32_t positionCount(uint16_t idn) const;
	uint16_t idnAt(unsigned index) const;

	void reset();
	void add(GameInfo const& info);
	void addPosition(GameInfo const& info);
	void removePosition(GameInfo const& info);
	void addLanguages(GameInfo const& info);
	void removeLanguages(GameInfo const& info);
	template <typename Iterator> void compute(Iterator first, Iterator last);

	struct Counter
	{
		unsigned deleted;
		unsigned changed;
		unsigned added;

		unsigned commented;
		//unsigned allLang;
		unsigned englishLang;
		unsigned otherLang;
	};

	struct Content
	{
		uint16_t minYear;
		uint16_t maxYear;
		uint16_t avgYear;
		uint16_t minElo;
		uint16_t maxElo;
		uint16_t avgElo;
		unsigned result[5];
	};

	Counter			counter;
	Content			content;
	mstl::bitset	positions;

private:

	void count(GameInfo const& info);

	struct MyCounter
	{
		double	sumYear;
		double	sumElo;
		unsigned	dateCount;
		unsigned	eloCount;
		uint32_t	posFreq[variant::MaxCode + 1];
	};

	MyCounter m_counter;
};

} // namespace db

#include "db_statistic.ipp"

#endif // _db_statistic_included

// vi:set ts=3 sw=3:
