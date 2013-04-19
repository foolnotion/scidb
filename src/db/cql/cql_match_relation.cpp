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

#include "cql_match_relation.h"

#include "db_board.h"
#include "db_board_base.h"

using namespace cql;
using namespace cql::relation;
using namespace db;
using namespace db::board;
using namespace db::color;


Match::~Match() {}


bool
OriginalDifferentCount::match(Board const& p1, Board const& p2, Designator const& allowable)
{
	return allowable.different(p1, p2);
}


bool
OriginalSameCount::match(Board const& p1, Board const& p2, Designator const& allowable)
{
	return allowable.same(p1, p2);
}


bool
MissingPieceCount::match(Board const& p1, Board const& p2, Designator const& allowable)
{
	return result(count(m_designator.find(p1) & allowable.find(p1) & p2.empty()));
}


bool
NewPieceCount::match(Board const& p1, Board const& p2, Designator const& allowable)
{
	return result(count(m_designator.find(p2) & allowable.find(p2) & p1.empty()));
}

// vi:set ts=3 sw=3:
