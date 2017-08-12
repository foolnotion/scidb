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

#ifndef _eco_visitor_included
#define _eco_visitor_included

#include "db_board.h"

namespace eco {

class Branch;
class Node;

class Visitor
{
public:

	Visitor();
	virtual ~Visitor() = default;

	auto board() const -> db::Board const&;
	auto level() const -> unsigned;

	void reset();
	void doMove(db::Move& move);
	void undoMove(db::Move const& move);

	virtual void visit(Node const& node) = 0;
	virtual auto branch(Branch const& branch) -> bool = 0;
	virtual void finishBranch(Branch const& branch);
	virtual void finish();

private:

	friend class Node;

	db::Board	m_board;
	unsigned		m_level;
};

} // namespace eco

#include "eco_visitor.ipp"

#endif // _eco_visitor_included

// vi:set ts=3 sw=3:
