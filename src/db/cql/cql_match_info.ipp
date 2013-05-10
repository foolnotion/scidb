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

namespace cql {
namespace info {

inline Annotator::Annotator(char const* s, char const* e) :m_pattern(s, e) {}
inline Event::Event(char const* s, char const* e) :m_pattern(s, e) {}
inline Site::Site(char const* s, char const* e) :m_pattern(s, e) {}
inline Date::Date(db::Date const& min, db::Date const& max) :m_min(min), m_max(max) {}
inline Eco::Eco(db::Eco min, db::Eco max) :m_min(min), m_max(max) {}
inline EventCountry::EventCountry(mstl::bitset const& countries) :m_countries(countries) {}
inline EventMode::EventMode(unsigned modes) :m_modes(modes) {}
inline EventType::EventType(unsigned types) :m_types(types) {}
inline GameNumber::GameNumber(unsigned min, unsigned max) :m_min(min), m_max(max) {}
inline GameMarkers::GameMarkers(unsigned flags) :m_flags(flags) {}
inline Gender::Gender(unsigned colors, db::sex::ID sex) :m_colors(colors), m_sex(sex) {}
inline IsComputer::IsComputer(unsigned colors) :m_colors(colors) {}
inline IsHuman::IsHuman(unsigned colors) :m_colors(colors) {}
inline PlyCount::PlyCount(unsigned min, unsigned max) :m_min(min), m_max(max) {}
inline SpecialGameMarkers::SpecialGameMarkers(unsigned flags) :m_flags(flags) {}
inline Result::Result(unsigned results) :m_results(results) {}
inline Round::Round(unsigned round) :m_round(round), m_subround(0) {}
inline Termination::Termination(unsigned reasons) :m_reasons(reasons) {}
inline Round::Round(unsigned round, unsigned subround) :m_round(round), m_subround(subround) {}
inline TimeMode::TimeMode(unsigned modes) :m_modes(modes) {}
inline Title::Title(unsigned titles, unsigned colors) :m_titles(titles), m_colors(colors) {}
inline Variant::Variant(unsigned variants) :m_variants(variants) {}
inline Year::Year(unsigned min, unsigned max) :m_min(min), m_max(max) {}


inline
BirthYear::BirthYear(unsigned colors, unsigned min, unsigned max)
	:m_colors(colors)
	,m_min(min)
	,m_max(max)
{
}


inline
DeathYear::DeathYear(unsigned colors, unsigned min, unsigned max)
	:m_colors(colors)
	,m_min(min)
	,m_max(max)
{
}


inline
Player::Player(char const* s, char const* e, unsigned colors)
	:m_pattern(s, e)
	,m_colors(colors)
{
}


inline
EventDate::EventDate(db::Date const& min, db::Date const& max)
	:m_min(min)
	,m_max(max)
{
}


inline
Country::Country(unsigned colors, mstl::bitset const& countries)
	:m_colors(colors)
	,m_countries(countries)
{
}


inline
Rating::Rating(db::rating::Type ratingType, uint16_t minScore, uint16_t maxScore, unsigned colors)
	:m_ratingType(ratingType)
	,m_colors(colors)
	,m_minScore(minScore)
	,m_maxScore(maxScore)
{
}


inline
StartPosition::StartPosition(Positions positions)
	:m_positions(positions)
	,m_none(positions.none())
{
}


inline mstl::pattern const& Player::pattern() const { return m_pattern; }

} // namespace info
} // namespace cql

// vi:set ts=3 sw=3:
