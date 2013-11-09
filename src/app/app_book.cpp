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

#include "app_book.h"
#include "app_polyglot_book.h"
#include "app_chessbase_book.h"

#include "u_misc.h"

#include "m_string.h"
#include "m_assert.h"

using namespace db;
using namespace app;
using namespace util;


Book::Entry::Entry() :totalWeight(0) {}


Book::Entry::Item::Item()
	:weight(0)
	,avgRatingGames(0)
	,avgRatingScore(0)
	,perfRatingGames(0)
	,perfRatingScore(0)
	,total(0)
	,wins(0)
	,losses(0)
	,draws(0)
{
	info.__value__ = 0;
}


Book::~Book() {}


Book*
Book::open(mstl::string const& filename)
{
	Book* book;

	if (misc::file::suffix(filename) == "ctg")
		book = new chessbase::Book(filename);
	else
		book = new polyglot::Book(filename);

	book->m_filename = filename;

	return book;
}


bool Book::isModified() const		{ return false; }
bool Book::isPersistent() const	{ return true; }


bool
Book::remove(Board const& position, variant::Type variant)
{
	M_ASSERT(!"should not be used");
	return false;
}


bool
Book::modify(Board const& position, variant::Type variant, Entry const& entry)
{
	M_ASSERT(!"should not be used");
	return false;
}


bool
Book::add(Board const& position, variant::Type variant, Entry const& entry)
{
	M_ASSERT(!"should not be used");
	return false;
}

// vi:set ts=3 sw=3:
