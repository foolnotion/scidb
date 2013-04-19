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

#ifndef _cql_relation_included
#define _cql_relation_included

#include "cql_designator.h"
#include "cql_common.h"

#include "db_board.h"

#include "m_vector.h"

namespace cql {

namespace relation { class Match; }

class Position;

class Relation
{
public:

	typedef error::Type Error;
	typedef db::Board Board;

	Relation();

	bool match(Board const& board, bool insideVariation);

	char const* parse(char const* s, Error& error);

	// call at end of parsing the position; required for :pattern
	void finish(Position const& pos);

	// call before starting new game
	void reset();

private:

	typedef mstl::vector<relation::Match*> MatchList;

	enum SideToMove { Ignore, Same, Change };

	bool match(Board const& board);

	char const* parseChangeSideToMove(char const* s, Error& error);
	char const* parseFlip(char const* s, Error& error);
	char const* parseIgnoreSideToMove(char const* s, Error& error);
	char const* parseMissingPieceCount(char const* s, Error& error);
	char const* parseNewPieceCount(char const* s, Error& error);
	char const* parseOriginalDifferentCount(char const* s, Error& error);
	char const* parseOriginalSameCount(char const* s, Error& error);
	char const* parsePattern(char const* s, Error& error);
	char const* parseSameSideToMove(char const* s, Error& error);
	char const* parseShift(char const* s, Error& error);
	char const* parseVariations(char const* s, Error& error);
	char const* parseVariationsOnly(char const* s, Error& error);

	Board			m_pos;
	SideToMove	m_sideToMove;
	bool			m_variationsOnly;
	bool			m_mainlineOnly;
	bool			m_usePattern;
	bool			m_matched;
	Designator	m_pattern;
	MatchList	m_matchList;
};

} // namespace cql

#include "cql_relation.ipp"

#endif // _cql_relation_included

// vi:set ts=3 sw=3:
