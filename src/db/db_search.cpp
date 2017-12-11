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
// Copyright: (C) 2009-2013 Gregor Cramer
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

#include "m_utility.h"
#include "m_assert.h"

using namespace db;


Search::~Search() throw() {}
SearchOpNot::~SearchOpNot() throw() {}

SearchPlayer::SearchPlayer(NamebasePlayer const* entry) :m_entry(entry) {}
SearchEvent::SearchEvent(NamebaseEvent const* entry) :m_entry(entry) {}
SearchSite::SearchSite(NamebaseSite const* entry) :m_entry(entry) {}
SearchOpNot::SearchOpNot(SearchP const& search) :m_search(search) { M_REQUIRE(search); }
SearchAnnotator::SearchAnnotator(mstl::string const& name) :m_name(name) {}
SearchPosition::SearchPosition(uint16_t idn) :m_idn(idn) {}


#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

# include "m_utility.h"

SearchOpNot::SearchOpNot(SearchOpNot&& search)
	:m_search(mstl::move(search.m_search))
{
}


SearchOpNot&
SearchOpNot::operator=(SearchOpNot&& search)
{
	m_search = mstl::move(search.m_search);
	return *this;
}

#endif


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


SearchGameEvent::SearchGameEvent(NamebaseEvent const* entry, Date const& date)
	:m_entry(entry)
	,m_firstDate(date)
	,m_lastDate(date)
{
	if (date.month())
	{
		int y1 = date.year();
		int y2 = y1;
		int m1 = int(date.month()) - 3;
		int m2 = int(date.month()) + 3;

		if (m1 <= 0)
		{
			m1 += 12;
			--y1;
		}

		if (m2 > 12)
		{
			m2 -= 12;
			++y2;
		}

		int d1 = mstl::min(date.day(), Date::lastDayInMonth(y1, m1));
		int d2 = mstl::min(date.day(), Date::lastDayInMonth(y2, m2));

		m_firstDate.setYMD(mstl::max(y1, int(Date::MinYear)), m1, d1);
		m_lastDate .setYMD(mstl::min(y2, int(Date::MaxYear)), m2, d2);
	}
}


bool
SearchGameEvent::match(GameInfo const& info) const
{
	if (info.eventEntry() != m_entry)
		return false;

	if (m_entry->date())
		return true;

	if (!info.date())
		return !m_firstDate;

	return m_firstDate <= info.date() && info.date() <= m_lastDate;
}


bool
SearchSite::match(GameInfo const& info) const
{
	return info.eventEntry()->site() == m_entry;
}


bool
SearchAnnotator::match(GameInfo const& info) const
{
	return info.annotator() == m_name;
}


bool
SearchPosition::match(GameInfo const& info) const
{
	return info.idn() == m_idn;
}

// vi:set ts=3 sw=3:
