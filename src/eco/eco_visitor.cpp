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

#include "eco_visitor.h"

#include "db_move.h"

using namespace eco;
using namespace db;

Visitor::Visitor() { reset(); }

void Visitor::finish() {}
void Visitor::finishBranch(Branch const&) {}


void Visitor::doMove(Move& move)
{
	m_board.prepareUndo(move);
	m_board.doMove(move);
	++m_level;
}


void Visitor::undoMove(Move const& move)
{
	--m_level;
	m_board.undoMove(move);
}


void Visitor::reset()
{
	m_board = Board::standardBoard(variant::Normal);
	m_level = 0;
}

// vi:set ts=3 sw=3:
