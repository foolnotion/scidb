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

#ifndef _cql_match_relation_included
#define _cql_match_relation_included

#include "cql_designator.h"

namespace db { class Board; }

namespace cql {

class Designator;

namespace relation {

struct Match
{
	typedef db::Board Board;

	virtual ~Match() = 0;
	virtual bool match(Board const& p1, Board const& p2, Designator const& allowable) = 0;
};


struct MatchMinMax : public Match
{
	MatchMinMax(unsigned min, unsigned max);

	bool result(unsigned count);

	unsigned m_min;
	unsigned m_max;
};


struct OriginalDifferentCount : public MatchMinMax
{
	OriginalDifferentCount();

	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;
};


struct OriginalSameCount : public MatchMinMax
{
	OriginalSameCount();

	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;
};


#if 0
struct Shift : public Match
{
	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;
};


struct Flip : public Match
{
	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;
};
#endif


class MissingPieceCount : public MatchMinMax
{
public:

	MissingPieceCount();

	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;

private:

	Designator m_designator;
};


struct NewPieceCount : public MatchMinMax
{
public:

	NewPieceCount();

	bool match(Board const& p1, Board const& p2, Designator const& allowable) override;

private:

	Designator m_designator;
};

} // namespace relation
} // namespace cql

#include "cql_match_relation.ipp"

#endif // _cql_match_relation_included

// vi:set ts=3 sw=3:
