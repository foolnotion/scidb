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

#include "cql_relation.h"
#include "cql_match_relation.h"

#include "db_board.h"

#include "u_base.h"

#include "m_string.h"
#include "m_algorithm.h"

#include <ctype.h>

using namespace cql;
using namespace cql::error;


namespace {

typedef char const* (Relation::*RelMeth)(char const* s, error::Type& error);

struct RelPair
{
	RelPair(char const* s, RelMeth f) :keyword(s), func(f) {}

	bool operator<(mstl::string const& s) const { return keyword < s; }

	mstl::string	keyword;
	RelMeth			func;
};

} // namespace


namespace mstl {

static inline
bool
operator<(mstl::string const& lhs, RelPair const& rhs)
{
	return lhs < rhs.keyword;
}

} // namespace mstl


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;

	if (*s == ';')
	{
		// skip comment
		while (*s != '\n' && *s != '\0')
			++s;

		while (isspace(*s))
			++s;
	}

	return s;
}


static unsigned
lengthOfKeyword(char const* s)
{
	char const* t = s;

	while (::isalpha(*t))
		++t;

	return t - s;
}


Relation::Relation()
	:m_sideToMove(Same)
	,m_variationsOnly(false)
	,m_mainlineOnly(true)
	,m_usePattern(false)
	,m_matched(false)
{
}


char const*
Relation::parseChangeSideToMove(char const* s, Error& error)
{
	m_sideToMove = Change;
	return s;
}


char const*
Relation::parseFlip(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseIgnoreSideToMove(char const* s, Error& error)
{
	m_sideToMove = Ignore;
	return s;
}


char const*
Relation::parseMissingPieceCount(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseNewPieceCount(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseOriginalDifferentCount(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseOriginalSameCount(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parsePattern(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseSameSideToMove(char const* s, Error& error)
{
	m_sideToMove = Same;
	return s;
}


char const*
Relation::parseShift(char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Relation::parseVariations(char const* s, Error& error)
{
	m_mainlineOnly = false;
	m_variationsOnly = false;
	return s;
}


char const*
Relation::parseVariationsOnly(char const* s, Error& error)
{
	m_mainlineOnly = false;
	m_variationsOnly = true;
	return s;
}


char const*
Relation::parse(char const* s, Error& error)
{
	typedef RelPair Pair;

	static Pair const Trampolin[] =
	{
		Pair("changesidetomove",			&Relation::parseChangeSideToMove),
		Pair("flip",							&Relation::parseFlip),
		Pair("ignoresidetomove",			&Relation::parseIgnoreSideToMove),
		Pair("missingpiececount",			&Relation::parseMissingPieceCount),
		Pair("newpiececount",				&Relation::parseNewPieceCount),
		Pair("originaldifferentcount",	&Relation::parseOriginalDifferentCount),
		Pair("originalsamecount",			&Relation::parseOriginalSameCount),
		Pair("pattern",						&Relation::parsePattern),
		Pair("samesidetomove",				&Relation::parseSameSideToMove),
		Pair("shift",							&Relation::parseShift),
		Pair("variations",					&Relation::parseVariations),
		Pair("variationsonly",				&Relation::parseVariationsOnly),
	};

	mstl::string key;

	error = No_Error;
	s = ::skipSpaces(s);

	if (*s == '(')
	{
		do
		{
			mstl::string key(s + 1, ::lengthOfKeyword(s + 1));
			Pair const* p = mstl::binary_search(Trampolin, Trampolin + U_NUMBER_OF(Trampolin), key);

			if (p == Trampolin + U_NUMBER_OF(Trampolin))
			{
				error = Invalid_Relation_Keyword;
				return s;
			}

			char const* t = (this->*p->func)(::skipSpaces(s + key.size() + 1), error);

			if (error != No_Error)
				return t;

			s = ::skipSpaces(t);
		}
		while (*s && error == No_Error);
	}
	else
	{
		error = Relation_List_Expected;
	}

	return s;
}


void
Relation::finish(Position const& pos)
{
	if (m_usePattern)
	{
		// TODO:
		// The :pattern keyword signifies that all piece designators that occur
		// at the top level of the position list that encloses the current relation
		// list define the allowable squares.
	}
}


bool
Relation::match(Board const& board)
{
	MatchList::iterator i = m_matchList.begin();
	MatchList::iterator e = m_matchList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(m_pos, board, m_pattern))
			return false;
	}

	return true;
}


bool
Relation::match(Board const& board, bool insideVariation)
{
	if (m_matched)
	{
		if (insideVariation ? m_mainlineOnly : m_variationsOnly)
			return false;

		switch (m_sideToMove)
		{
			case Ignore:	return match(board);
			case Same:		if (m_pos.sideToMove() != board.sideToMove()) return false; break;
			case Change:	if (m_pos.sideToMove() == board.sideToMove()) return false; break;
		}

		return match(board);
	}

	m_matched = true;
	m_pos = board;

	return false;
}

// vi:set ts=3 sw=3:
