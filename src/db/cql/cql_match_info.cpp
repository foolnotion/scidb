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

#include "cql_match_info.h"

#include "db_game_info.h"

#include "m_utility.h"

using namespace cql;
using namespace cql::info;
using namespace db;
using namespace db::color;


Match::~Match() {}


bool
Annotator::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	if (NamebaseEntry const* annotator = info.annotatorEntry())
		return m_pattern.match(annotator->name());

	return false;
}


bool
info::Player::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_pattern.match(info.playerEntry(m_color)->name());
}


bool
Event::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_pattern.match(info.eventEntry()->name());
}


bool
info::Site::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_pattern.match(info.eventEntry()->site()->name());
}


bool
Rating::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	uint16_t rating = info.findRating(m_color, m_ratingType);
	return m_minScore <= rating && rating <= m_maxScore;
}


bool
info::Date::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	db::Date date(info.date());
	return m_min <= date && date <= m_max;
}


bool
info::Eco::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	db::Eco eco(info.eco());
	return m_min <= eco && eco <= m_max;
}


bool
EventCountry::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_countries.test(info.eventCountry());
}


bool
EventDate::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_min <= info.eventDate() && info.eventDate() <= m_max;
}


bool
EventMode::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return bool(m_modes | (1 << info.eventMode()));
}


bool
EventType::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return bool(m_types | (1 << info.eventType()));
}


bool
Country::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_countries.test(info.eventCountry());
}


bool
GameNumber::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_number == gameNumber;
}


bool
HasAnnotation::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.countAnnotations() > 0;
}


bool
HasComments::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.countComments() > 0;
}


bool
HasVariation::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.countVariations() > 0;
}


bool
GameFlags::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return (info.flags() & m_flags) == m_flags;
}


bool
Gender::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	static_assert((White | Black) == 1, "loop not working");

	for (unsigned i = 0; i < 2; ++i)
	{
		if ((m_colors & (1 << i)) && (info.sex(db::color::ID(i)) & m_sex))
			return true;
	}

	return false;
}


bool
IsComputer::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.playerType(m_color) == species::Program;
}


bool
IsHuman::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.playerType(m_color) == species::Human;
}


bool
IsChess960::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return variant::isChess960(info.idn());
}


bool
IsShuffleChess::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return variant::isShuffleChess(info.idn());
}


bool
IsStandardPosition::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return variant::isStandardChess(info.idn(), variant);
}


bool
IsStartPosition::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return info.idn() > 0;
}


bool
PlyCount::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_min <= info.plyCount() && info.plyCount() <= m_max;
}


bool
StartPosition::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	if (m_idn == 0 || !isAntichessExceptLosers(variant))
		return info.idn() == m_idn;

	return info.idn() == (m_idn <= 960) ? m_idn + 3*960 : m_idn;
}


bool
Result::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return (1u << info.result()) & m_results;
}


bool
Round::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	if (m_subround && m_subround != info.subround())
		return false;

	return m_round == info.round();
}


bool
Termination::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_reasons & (1u << info.terminationReason());
}


bool
TimeMode::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	return m_modes & (1u << info.timeMode());
}


bool
Title::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	static_assert((White | Black) == 1, "loop not working");

	for (unsigned i = 0; i < 2; ++i)
	{
		if ((m_colors & (1 << i)) && (m_titles & title::fromID(info.title(db::color::ID(i)))))
			return true;
	}

	return false;
}


bool
Variant::match(GameInfo const& info, Match::Variant variant, unsigned gameNumber)
{
	switch (int(m_variant))
	{
		case variant::Giveaway:	return info.isGiveaway();
		case variant::Suicide:	return !info.isGiveaway();
	}

	return true;
}


bool
Year::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	unsigned year = info.date().year();
	return m_min <= year && year <= m_max;
}


bool
BirthYear::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	static_assert((White | Black) == 1, "loop not working");

	for (unsigned i = 0; i < 2; ++i)
	{
		if (m_colors & (1 << i))
		{
			db::Date const& date = info.player(db::color::ID(i))->dateOfBirth();

			if (date && mstl::is_between(unsigned(date.year()), m_min, m_max))
				return true;
		}
	}

	return false;
}


bool
DeathYear::match(GameInfo const& info, Variant variant, unsigned gameNumber)
{
	db::Date const& date = info.player(m_color)->dateOfDeath();

	if (!date)
		return false;

	unsigned year = date.year();

	return m_min <= year && year <= m_max;
}

// vi:set ts=3 sw=3:
