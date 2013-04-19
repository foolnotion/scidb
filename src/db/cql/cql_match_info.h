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

#ifndef _cql_match_info_included
#define _cql_match_info_included

#include "db_date.h"
#include "db_eco.h"
#include "db_common.h"

#include "m_match.h"

namespace db { class GameInfo; }

namespace cql {
namespace info {

struct Match
{
	typedef db::GameInfo GameInfo;
	typedef db::variant::Type Variant;

	virtual ~Match() = 0;
	virtual bool match(GameInfo const& info, Variant variant, unsigned gameNumber) = 0;
};


class Annotator : public Match
{
public:

	Annotator(char const* s, char const* e);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	mstl::pattern m_pattern;
};


class Player : public Match
{
public:

	Player(char const* s, char const* e, db::color::ID c);

	mstl::pattern const& pattern() const;

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	mstl::pattern	m_pattern;
	db::color::ID	m_color;
};


class Event : public Match
{
public:

	Event(char const* s, char const* e);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	mstl::pattern m_pattern;
};


class Site : public Match
{
public:

	Site(char const* s, char const* e);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	mstl::pattern m_pattern;
};


class Rating : public Match
{
public:

	Rating(db::rating::Type ratingType, uint16_t minScore, uint16_t maxScore, db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::rating::Type	m_ratingType;
	db::color::ID		m_color;
	uint16_t				m_minScore;
	uint16_t				m_maxScore;
};


class Date : public Match
{
public:

	Date(db::Date const& min, db::Date const& max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::Date m_min;
	db::Date m_max;
};


class Eco : public Match
{
public:

	Eco(db::Eco min, db::Eco max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::Eco m_min;
	db::Eco m_max;
};


class EventCountry : public Match
{
public:

	EventCountry(db::country::Code country);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::country::Code m_country;
};


class EventDate : public Match
{
public:

	EventDate(db::Date const& min, db::Date const& max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::Date m_min;
	db::Date m_max;
};


class EventMode : public Match
{
public:

	EventMode(db::event::Mode mode);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::event::Mode m_mode;
};


class EventType : public Match
{
public:

	EventType(db::event::Type type);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::event::Type m_type;
};


class Country : public Match
{
public:

	Country(db::country::Code country, db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::country::Code	m_country;
	db::color::ID		m_color;
};


class GameNumber : public Match
{
public:

	GameNumber(unsigned number);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_number;
};


struct HasAnnotation : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


struct HasComments : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


struct HasVariation : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


class GameFlags : public Match
{
public:

	GameFlags(unsigned flags);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_flags;
};


class Gender : public Match
{
public:

	Gender(db::sex::ID sex, db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::sex::ID		m_sex;
	db::color::ID	m_color;
};


class IsComputer : public Match
{
public:

	IsComputer(db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::color::ID m_color;
};


class IsHuman : public Match
{
public:

	IsHuman(db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::color::ID m_color;
};


struct IsChess960 : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


struct IsShuffleChess : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


struct IsStandardPosition : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


struct IsStartPosition : public Match
{
	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;
};


class PlyCount : public Match
{
public:

	PlyCount(unsigned min, unsigned max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_min;
	unsigned m_max;
};


class StartPosition : public Match
{
public:

	StartPosition(unsigned idn);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_idn;
};


class Result : public Match
{
public:

	Result(unsigned results);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_results;
};


class Round : public Match
{
public:

	Round(unsigned round);
	Round(unsigned round, unsigned subround);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_round;
	unsigned m_subround;
};


class Termination : public Match
{
public:

	Termination(unsigned reasons);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_reasons;
};


class TimeMode : public Match
{
public:

	TimeMode(unsigned modes);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_modes;
};


class Title : public Match
{
public:

	Title(unsigned titles, db::color::ID color);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned			m_titles;
	db::color::ID	m_color;
};


class Variant : public Match
{
public:

	Variant(Match::Variant variant);

	bool match(GameInfo const& info, Match::Variant variant, unsigned gameNumber) override;

private:

	Match::Variant m_variant;
};


class Year : public Match
{
public:

	Year(unsigned min, unsigned max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	unsigned m_min;
	unsigned m_max;
};


class BirthYear : public Match
{
public:

	BirthYear(db::color::ID color, unsigned min, unsigned max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::color::ID	m_color;
	unsigned			m_min;
	unsigned			m_max;
};


class DeathYear : public Match
{
public:

	DeathYear(db::color::ID color, unsigned min, unsigned max);

	bool match(GameInfo const& info, Variant variant, unsigned gameNumber) override;

private:

	db::color::ID	m_color;
	unsigned			m_min;
	unsigned			m_max;
};

} // namespace info
} // namespace cql

#include "cql_match_info.ipp"

#endif // _cql_match_info_included

// vi:set ts=3 sw=3:
