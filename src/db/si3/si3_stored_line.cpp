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

#include "si3_stored_line.h"

#include "db_board.h"
#include "db_eco_table.h"
#include "db_line.h"

#include "u_byte_stream.h"

#include "m_utility.h"

#include <string.h>
#include <assert.h>

using namespace db;
using namespace db::si3;

static char const* StoredLines[255] =
{
	"",
	"b3",
	"c4",
	"c4 c5",
	"c4 c5 Nf3",
	"c4 e5",
	"c4 e5 Nc3",
	"c4 e5 Nc3 Nf6",
	"c4 e6",
	"c4 e6 Nf3",
	"c4 g6",
	"c4 Nf6",
	"c4 Nf6 Nc3",
	"c4 Nf6 Nc3 e6",
	"c4 Nf6 Nc3 g6",
	"d4",
	"d4 d5",
	"d4 d5 c4",
	"d4 d5 c4 c6",
	"d4 d5 c4 c6 Nc3",
	"d4 d5 c4 c6 Nc3 Nf6",
	"d4 d5 c4 c6 Nc3 Nf6 Nf3",
	"d4 d5 c4 c6 Nf3",
	"d4 d5 c4 c6 Nf3 Nf6",
	"d4 d5 c4 c6 Nf3 Nf6 Nc3",
	"d4 d5 c4 c6 Nf3 Nf6 Nc3 e6",
	"d4 d5 c4 dxc4",
	"d4 d5 c4 dxc4 Nf3",
	"d4 d5 c4 dxc4 Nf3 Nf6",
	"d4 d5 c4 e6",
	"d4 d5 c4 e6 Nc3",
	"d4 d5 c4 e6 Nc3 c6",
	"d4 d5 c4 e6 Nc3 Nf6",
	"d4 d5 c4 e6 Nf3",
	"d4 d5 Nf3",
	"d4 d5 Nf3 Nf6",
	"d4 d5 Nf3 Nf6 c4",
	"d4 d5 Nf3 Nf6 c4 c6",
	"d4 d5 Nf3 Nf6 c4 e6",
	"d4 d6",
	"d4 d6 Nf3",
	"d4 e6",
	"d4 e6 c4",
	"d4 e6 c4 Nf6",
	"d4 f5",
	"d4 f5 g3 Nf6 Bg2",
	"d4 g6",
	"d4 g6 c4 Bg7",
	"d4 Nf6",
	"d4 Nf6 Bg5",
	"d4 Nf6 Bg5 Ne4",
	"d4 Nf6 c4",
	"d4 Nf6 c4 c5",
	"d4 Nf6 c4 c5 d5",
	"d4 Nf6 c4 c5 d5 b5",
	"d4 Nf6 c4 c5 d5 b5 cxb5 a6",
	"d4 Nf6 c4 e6 g3",
	"d4 Nf6 c4 e6 g3 d5",
	"d4 Nf6 c4 e6 Nc3",
	"d4 Nf6 c4 e6 Nc3 Bb4",
	"d4 Nf6 c4 e6 Nc3 Bb4 e3",
	"d4 Nf6 c4 e6 Nc3 Bb4 e3 O-O",
	"d4 Nf6 c4 e6 Nc3 Bb4 Qc2",
	"d4 Nf6 c4 e6 Nc3 Bb4 Qc2 O-O",
	"d4 Nf6 c4 e6 Nc3 Bb4 Qc2 O-O a3 Bxc3+ Qxc3",
	"d4 Nf6 c4 e6 Nc3 d5",
	"d4 Nf6 c4 e6 Nf3",
	"d4 Nf6 c4 e6 Nf3 b6",
	"d4 Nf6 c4 e6 Nf3 b6 a3",
	"d4 Nf6 c4 e6 Nf3 b6 g3",
	"d4 Nf6 c4 e6 Nf3 b6 g3 Ba6",
	"d4 Nf6 c4 e6 Nf3 Bb4+",
	"d4 Nf6 c4 e6 Nf3 d5",
	"d4 Nf6 c4 e6 Nf3 d5 Nc3",
	"d4 Nf6 c4 g6",
	"d4 Nf6 c4 g6 Nc3 Bg7",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Be2 O-O",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Be2 O-O Nf3",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 f3",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 f3 O-O",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 f3 O-O Be3",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O Be2",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O Be2 e5",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O Be2 e5 O-O",
	"d4 Nf6 c4 g6 Nc3 Bg7 e4 d6 Nf3 O-O Be2 e5 O-O Nc6 d5 Ne7",
	"d4 Nf6 c4 g6 Nc3 d5",
	"d4 Nf6 c4 g6 Nc3 d5 Nf3",
	"d4 Nf6 c4 g6 Nc3 d5 cxd5 Nxd5",
	"d4 Nf6 c4 g6 Nc3 d5 cxd5 Nxd5 e4 Nxc3 bxc3 Bg7",
	"d4 Nf6 Nf3",
	"d4 Nf6 Nf3 c5",
	"d4 Nf6 Nf3 d5",
	"d4 Nf6 Nf3 e6",
	"d4 Nf6 Nf3 e6 Bg5",
	"d4 Nf6 Nf3 e6 c4",
	"d4 Nf6 Nf3 g6",
	"d4 Nf6 Nf3 g6 Bg5",
	"d4 Nf6 Nf3 g6 c4",
	"d4 Nf6 Nf3 g6 c4 Bg7",
	"d4 Nf6 Nf3 g6 c4 Bg7 Nc3",
	"d4 Nf6 Nf3 g6 c4 Bg7 Nc3 O-O",
	"d4 Nf6 Nf3 g6 g3",
	"d4 Nf6 Nf3 g6 g3 Bg7 Bg2",
	"e4",
	"e4 c5",
	"e4 c5 c3",
	"e4 c5 c3 d5 exd5 Qxd5 d4",
	"e4 c5 c3 d5 exd5 Qxd5 d4 Nf6",
	"e4 c5 c3 Nf6 e5 Nd5",
	"e4 c5 c3 Nf6 e5 Nd5 d4 cxd4",
	"e4 c5 d4 cxd4",
	"e4 c5 Nc3",
	"e4 c5 Nc3 Nc6",
	"e4 c5 Nc3 Nc6 g3",
	"e4 c5 Nc3 Nc6 g3 g6",
	"e4 c5 Nc3 Nc6 g3 g6 Bg2 Bg7",
	"e4 c5 Nc3 Nc6 g3 g6 Bg2 Bg7 d3",
	"e4 c5 Nf3",
	"e4 c5 Nf3 d6",
	"e4 c5 Nf3 d6 Bb5+",
	"e4 c5 Nf3 d6 d4",
	"e4 c5 Nf3 d6 d4 cxd4",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6 Bc4",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6 Be2",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6 Be3",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6 Bg5",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 a6 Bg5 e6",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 g6",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 g6 Be3 Bg7 f3",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 g6 Be3 Bg7 f3 O-O",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 Nc6",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 Nc6 Bg5",
	"e4 c5 Nf3 d6 d4 cxd4 Nxd4 Nf6 Nc3 Nc6 Bg5 e6 Qd2",
	"e4 c5 Nf3 e6",
	"e4 c5 Nf3 e6 d3",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 a6",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 a6 Bd3",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nc6",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nc6 Nc3",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nc6 Nc3 Qc7",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nf6",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nf6 Nc3",
	"e4 c5 Nf3 e6 d4 cxd4 Nxd4 Nf6 Nc3 d6",
	"e4 c5 Nf3 Nc6",
	"e4 c5 Nf3 Nc6 Bb5",
	"e4 c5 Nf3 Nc6 Bb5 g6",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 e5",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 g6",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 d6",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 d6 Bg5",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 e5",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 e5 Ndb5 d6",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 e5 Ndb5 d6 Bg5 a6",
	"e4 c5 Nf3 Nc6 d4 cxd4 Nxd4 Nf6 Nc3 e5 Ndb5 d6 Bg5 a6 Na3 b5",
	"e4 c6",
	"e4 c6 d4 d5",
	"e4 c6 d4 d5 e5",
	"e4 c6 d4 d5 e5 Bf5",
	"e4 c6 d4 d5 exd5 cxd5",
	"e4 c6 d4 d5 exd5 cxd5 c4 Nf6 Nc3",
	"e4 c6 d4 d5 Nc3",
	"e4 c6 d4 d5 Nc3 dxe4 Nxe4",
	"e4 c6 d4 d5 Nd2 dxe4 Nxe4",
	"e4 d5 exd5 Nf6",
	"e4 d5 exd5 Qxd5",
	"e4 d5 exd5 Qxd5 Nc3",
	"e4 d5 exd5 Qxd5 Nc3 Qa5",
	"e4 d6",
	"e4 d6 d4",
	"e4 d6 d4 Nf6",
	"e4 d6 d4 Nf6 Nc3",
	"e4 d6 d4 Nf6 Nc3 g6",
	"e4 d6 d4 Nf6 Nc3 g6 f4 Bg7 Nf3",
	"e4 d6 d4 Nf6 Nc3 g6 Nf3 Bg7",
	"e4 e5",
	"e4 e5 f4",
	"e4 e5 Nc3",
	"e4 e5 Nf3",
	"e4 e5 Nf3 Nc6",
	"e4 e5 Nf3 Nc6 Bb5",
	"e4 e5 Nf3 Nc6 Bb5 a6",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O b5 Bb3",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 d6",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 d6 c3 O-O",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 d6 c3 O-O h3",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 d6 c3 O-O h3 Na5 Bc2 c5 d4",
	"e4 e5 Nf3 Nc6 Bb5 a6 Ba4 Nf6 O-O Be7 Re1 b5 Bb3 O-O",
	"e4 e5 Nf3 Nc6 Bb5 Nf6",
	"e4 e5 Nf3 Nc6 Bc4",
	"e4 e5 Nf3 Nc6 Bc4 Nf6",
	"e4 e5 Nf3 Nc6 d4 exd4",
	"e4 e5 Nf3 Nc6 d4 exd4 Nxd4",
	"e4 e5 Nf3 Nc6 Nc3",
	"e4 e5 Nf3 Nc6 Nc3 Nf6",
	"e4 e5 Nf3 Nf6",
	"e4 e5 Nf3 Nf6 Nxe5 d6",
	"e4 e6",
	"e4 e6 d3",
	"e4 e6 d4",
	"e4 e6 d4 d5",
	"e4 e6 d4 d5 e5 c5",
	"e4 e6 d4 d5 e5 c5 c3",
	"e4 e6 d4 d5 Nc3",
	"e4 e6 d4 d5 Nc3 Bb4",
	"e4 e6 d4 d5 Nc3 Bb4 e5",
	"e4 e6 d4 d5 Nc3 Bb4 e5 c5",
	"e4 e6 d4 d5 Nc3 Bb4 e5 c5 a3 Bxc3+ bxc3",
	"e4 e6 d4 d5 Nc3 Nf6",
	"e4 e6 d4 d5 Nc3 Nf6 Bg5",
	"e4 e6 d4 d5 Nd2",
	"e4 e6 d4 d5 Nd2 c5",
	"e4 e6 d4 d5 Nd2 Nf6",
	"e4 e6 d4 d5 Nd2 Nf6 e5 Nfd7",
	"e4 e6 d4 d5 Nd2 Nf6 e5 Nfd7 Bd3 c5 c3 Nc6 Ne2",
	"e4 g6",
	"e4 g6 d4",
	"e4 g6 d4 Bg7",
	"e4 g6 d4 Bg7 Nc3",
	"e4 g6 d4 Bg7 Nc3 d6",
	"e4 Nf6",
	"e4 Nf6 e5 Nd5",
	"e4 Nf6 e5 Nd5 d4 d6",
	"e4 Nf6 e5 Nd5 d4 d6 Nf3",
	"f4",
	"g3",
	"Nf3",
	"Nf3 c5",
	"Nf3 c5 c4",
	"Nf3 d5",
	"Nf3 d5 c4",
	"Nf3 d5 d4",
	"Nf3 d5 g3",
	"Nf3 g6",
	"Nf3 Nf6",
	"Nf3 Nf6 c4",
	"Nf3 Nf6 c4 c5",
	"Nf3 Nf6 c4 e6",
	"Nf3 Nf6 c4 g6",
	"Nf3 Nf6 c4 g6 Nc3",
	"Nf3 Nf6 g3",
	"Nf3 Nf6 g3 g6",
};


StoredLine StoredLine::m_lines[255];


void
StoredLine::initialize()
{
	if (isInitialized())
		return;

	static_assert(U_NUMBER_OF(StoredLines) == U_NUMBER_OF(m_lines), "implementation error");

	for (unsigned i = 0; i < U_NUMBER_OF(StoredLines); ++i)
	{
		Board			board	= Board::standardBoard();
		char const*	text	= StoredLines[i];
		StoredLine&	line	= StoredLine::m_lines[i];

		while (*text)
		{
			assert(line.m_line.length < Max_Length);

			Move move = board.parseMove(text);
			assert(move.isLegal());

			board.doMove(move);
			line.m_buf[line.m_line.length++] = move.index();

			while (*text && *text != ' ') ++text;
			while (*text == ' ') ++text;
		}

		line.m_ecoKey = EcoTable::specimen().lookup(line.m_line);
//		assert(EcoTable::specimen().getLine(line.m_eco).length == line.m_line.length);
	}
}


StoredLine::StoredLine()
	:m_line(m_buf, 0)
{
	::memset(m_buf, 0, sizeof(m_buf));
}


StoredLine const&
StoredLine::findLine(Line const& line)
{
	M_REQUIRE(isInitialized());

	unsigned				length	= mstl::min(line.length, unsigned(Max_Length));
	StoredLine const* current	= &StoredLine::m_lines[0];
	StoredLine const* last		= &StoredLine::m_lines[255];
	StoredLine const* found		= current;
	uint16_t const*	moves		= line.moves;

	for (unsigned ply = 0; ply < length; ++moves)
	{
		if (*moves == 0)
			return *found;

		while (*moves != current->m_line.moves[ply])
		{
			if (++current == last || current->m_line.moves[ply] == 0)
				return *found;
		}

		if (!found->m_line.partialMatch(current->m_line))
			return *found;

		if (++ply == current->m_line.length)
			found = current;
	}

	return *found;
}


StoredLine const&
StoredLine::lookup(Eco const& key)
{
	// TODO: find a faster algorithm
	return findLine(EcoTable::specimen().getLine(key));
}


bool
StoredLine::isSuccessor(uint8_t index) const
{
	M_REQUIRE(index < count());

	StoredLine const& other = StoredLine::m_lines[index];

	if (m_line.length + 1 != other.m_line.length)
		return false;

	return ::memcmp(m_line.moves, other.m_line.moves, m_line.length*sizeof(m_line.moves[0])) == 0;
}


char const*
StoredLine::getText(uint8_t index)
{
	M_REQUIRE(index < count());
	return StoredLines[index];
}

// vi:set ts=3 sw=3:
