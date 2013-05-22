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

#ifndef _cql_engine_included
#define _cql_engine_included

#include "db_common.h"

namespace db { class Board; }
namespace db { class Move; }

namespace cql {

class Engine
{
public:

	struct Creator
	{
		virtual ~Creator() = 0;

		virtual Engine* createEngine() = 0;
		virtual void destroyEngine(Engine* engine) = 0;
	};

	enum Mode	{ MoveTime, Depth };
	enum Method	{ Mate, Score };

	virtual ~Engine() = 0;

	static bool hasCreator();

	virtual void newGame() = 0;
	virtual void setup(::db::Board const& board) = 0;
	virtual void move(::db::Move const& move) = 0;

	virtual float searchMate(Mode mode, unsigned arg) = 0;
	virtual float evaluate(Mode mode, unsigned arg) = 0;
	virtual float evaluate(Mode mode, unsigned arg, ::db::Move const& move) = 0;

	static void hookCreator(Creator* creator);

private:

	static Creator* m_creator;
};

} // namespace cql

#endif // _cql_engine_included

// vi:set ts=3 sw=3:
