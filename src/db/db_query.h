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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_query_included
#define _db_query_included

namespace db {

class Search;
class GameInfo;

class Query
{
public:

	enum Operator { Null, Not, And, Or, Reset, Remove };

	Query(Search* search, Operator op = Null);
	~Query() throw();

	bool empty() const;

	Operator op() const;

	bool match(GameInfo const& info) const;

private:

	Operator	m_op;
	Search*	m_search;
};

} // namespace db

#include "db_query.ipp"

#endif // _db_query_included

// vi:set ts=3 sw=3:
