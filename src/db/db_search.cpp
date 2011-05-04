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

#include "db_search.h"
#include "db_game_info.h"
#include "db_namebase_entry.h"

#include "m_assert.h"

using namespace db;


Search::~Search() throw() {}

SearchPlayer::SearchPlayer(NamebasePlayer const* entry) :m_entry(entry) {}
SearchEvent::SearchEvent(NamebaseEvent const* entry) :m_entry(entry) {}
SearchOpNot::SearchOpNot(Search* search) :m_search(search) { M_REQUIRE(search); }
SearchAnnotator::SearchAnnotator(mstl::string const& name) :m_name(name) {}

SearchOpNot::~SearchOpNot() throw() { delete m_search; }


bool
SearchOpNot::match(GameInfo const& info) const
{
	return !m_search->match(info);
}


bool
SearchPlayer::match(GameInfo const& info) const
{
	return info.playerEntry(color::White) == m_entry || info.playerEntry(color::Black) == m_entry;
}


bool
SearchEvent::match(GameInfo const& info) const
{
	return info.eventEntry() == m_entry;
}


bool
SearchAnnotator::match(GameInfo const& info) const
{
	return info.annotator() == m_name;
}

// vi:set ts=3 sw=3:
