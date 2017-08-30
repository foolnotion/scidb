// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "eco_rules.h"

#include "db_board.h"

#include "m_utility.h"
#include "m_assert.h"

#include <stdio.h>

using namespace eco;
using namespace db;


static
void prepareForPrint(db::MoveLine& line)
{
	Board board(Board::standardBoard(variant::Normal));

	for (Move move : line)
	{
		board.prepareForPrint(move, Board::ExternalRepresentation);
		board.doMove(move);
	}
}


Rules::Set::Set() :m_unwanted(500) {}
Rules::Line::Line() :m_used(false), m_lineNo(0) {}


Rules::Line::Line(db::MoveLine const& line, unsigned lineNo)
	:m_line(line)
	,m_used(false)
	,m_lineNo(lineNo)
{
}


auto Rules::testTransposition(Id from, Id to, MoveLine const& line) const -> Permission
{
	Set const& set = m_set[from.basic()];

	for (auto& exc : set.m_exceptions)
	{
		if (exc.first == to.basic())
		{
			unsigned length = mstl::min(exc.second.m_line.size(), line.size());

			if (exc.second.m_line.match(line) == length)
			{
				exc.second.m_used = true;
				return Allowed;
			}
		}
	}

	return set.m_unwanted.test(to.basic()) ? NotAllowed : NotForbidden;
}


void Rules::add(Id id, MoveLine const& line)
{
	M_REQUIRE(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	m_set[id.basic()].m_included.push_back(line);
}


void Rules::addExclusion(Id id, MoveLine const& line)
{
	M_REQUIRE(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	m_set[id.basic()].m_excluded.push_back(line);
}


void Rules::addOmission(Id id, MoveLine const& line, unsigned lineNo)
{
	M_REQUIRE(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	m_set[id.basic()].m_omissions.push_back(Line(line, lineNo));
}


void Rules::setUnwantedTransposition(Id from, Id to)
{
	M_REQUIRE(from.isBasicCode());
	M_REQUIRE(to.isBasicCode());
	M_REQUIRE(from.basic() != to.basic());

	m_set[from.basic()].m_unwanted.set(to.basic());
}


void Rules::addException(Id from, MoveLine const& line, Id to, unsigned lineNo)
{
	m_set[from.basic()].m_exceptions.push_back(mstl::make_pair(to.basic(), Line(line, lineNo)));
}


auto Rules::isIncluded(Id id, MoveLine const& line) const -> int
{
	M_ASSERT(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	Set const& set = m_set[id.basic()];

	for (auto const& included : set.m_included)
	{
		if (line.size() < included.size())
			return -1;

		if (included.match(line, included.size()) == included.size())
			return included.size();
	}

	return -1;
}


auto Rules::isExcluded(Id id, MoveLine const& line, unsigned offset) const -> bool
{
	M_ASSERT(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	Set const& set = m_set[id.basic()];

	unsigned count = 0;

	for (auto const& excluded : set.m_excluded)
	{
		for (unsigned k = offset; k < line.size(); ++k)
		{
			if (excluded.find(line[k].index()) >= 0)
				++count;
		}

		if (count == excluded.size())
			return true;
	}

	return false;
}


auto Rules::isValid(Id id, MoveLine const& line) const -> bool
{
	M_REQUIRE(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	int matchLength = isIncluded(id, line);
	return matchLength >= 0; // && !isExcluded(id, line, matchLength);
}


auto Rules::omit(Id id, db::MoveLine const& line) const -> bool
{
	M_ASSERT(id.isBasicCode());
	M_ASSERT(id.basic() < 500);

	Set const& set = m_set[id.basic()];

	for (auto &omission : set.m_omissions)
	{
		if (omission.m_line == line)
			return omission.m_used = true;
	}

	return false;
}


auto Rules::traceUnusedRules() const -> bool
{
	bool ok = true;

	for (unsigned i = 0; i < 500; ++i)
	{
		Set const& set = m_set[i];

		for (Exceptions::const_iterator k = set.m_exceptions.begin(); k != set.m_exceptions.end(); ++k)
		{
			if (!k->second.m_used)
			{
				mstl::string line;
				::prepareForPrint(const_cast<db::MoveLine&>(k->second.m_line));
				k->second.m_line.dump(line);
				fprintf(stderr, "unused exception (%5u): %s\n", k->second.m_lineNo, line.c_str());
				ok = false;
			}
		}
#if 0
		for (Lines::const_iterator k = set.m_omissions.begin(); k != set.m_omissions.end(); ++k)
		{
			if (!k->m_used)
			{
				mstl::string line;
				::prepareForPrint(const_cast<db::MoveLine&>(k->m_line));
				k->m_line.dump(line);
				fprintf(stderr, "unused omission (%5u): %s\n", k->m_lineNo, line.c_str());
				ok = false;
			}
		}
#endif
	}

	return ok;
}

// vi:set ts=3 sw=3:
