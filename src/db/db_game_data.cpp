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

#include "db_game_data.h"
#include "db_move_node.h"

using namespace db;


GameData::GameData()
	:m_startNode(new MoveNode)
	,m_startBoard(Board::standardBoard())
	,m_crc(0)
{
	m_tags.set(tag::Event,	"?", 1);
	m_tags.set(tag::Site,	"?", 1);
	m_tags.set(tag::Date,	"????.??.??", 10);
	m_tags.set(tag::Round,	"?", 1);
	m_tags.set(tag::White,	"?", 1);
	m_tags.set(tag::Black,	"?", 1);
	m_tags.set(tag::Result,	"*", 1);
}

GameData::~GameData() throw() { delete m_startNode; }

// vi:set ts=3 sw=3:
