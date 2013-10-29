// ======================================================================
// Author : $Author$
// Version: $Revision: 957 $
// Date   : $Date: 2013-09-30 17:11:24 +0200 (Mon, 30 Sep 2013) $
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

#include "app_chessbase_book.h"

using namespace db;
using namespace app::chessbase;


Book::Book(mstl::string const& filename)
{
}


bool Book::isReadonly() const			{ return true; }
Book::Format Book::format() const	{ return ChessBase; }


Move
Book::probeNextMove(::db::Board const& position, variant::Type variant)
{
	return Move();
}


bool
Book::probePosition(::db::Board const& position, variant::Type variant, Entry& result)
{
	return false;
}


bool
Book::remove(::db::Board const& position, variant::Type variant)
{
	return false;
}


bool
Book::modify(::db::Board const& position, variant::Type variant, Entry const& entry)
{
	return false;
}


bool
Book::add(::db::Board const& position, variant::Type variant, Entry const& entry)
{
	return false;
}

// vi:set ts=3 sw=3:
