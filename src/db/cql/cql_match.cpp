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

#include "cql_match.h"
#include "cql_match_info.h"
#include "cql_position.h"

#include "db_game_info.h"
#include "db_board.h"

#include "m_utility.h"
#include "m_algorithm.h"
#include "m_auto_ptr.h"
#include "m_bit_functions.h"
#include "m_string.h"
#include "m_vector.h"

#include <ctype.h>
#include <string.h>
#include <stdlib.h>

using namespace cql;
using namespace cql::error;
using namespace db;
using namespace db::color;


template <class Iterator>
inline
static void
deleteAll(Iterator first, Iterator last)
{
	for ( ; first != last; ++first)
		delete *first;
}


namespace {

typedef char const* (Match::*MatchMeth)(char const* s, error::Type& error);

struct MatchPair
{
	MatchPair(char const* s, MatchMeth f) :keyword(s), func(f) {}

	bool operator<(mstl::string const& s) const { return keyword < s; }

	mstl::string	keyword;
	MatchMeth		func;
};

} // namespace


struct Match::Logical
{
	typedef mstl::vector<Match*> MatchList;

	virtual ~Logical() { ::deleteAll(m_list.begin(), m_list.end()); }

	Match& pushBack()
	{
		m_list.push_back(new Match(false));
		return *m_list.back();
	}

	virtual bool matchComments(char const* data, unsigned length) = 0;
	virtual bool match(GameInfo const& info, variant::Type variant, unsigned gameNo) = 0;

	MatchList m_list;
};


namespace logical {

struct And : public Match::Logical
{
	bool matchComments(char const* data, unsigned length)
	{
		MatchList::iterator i = m_list.begin();
		MatchList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->matchComments(data, length))
				return false;
		}

		return true;
	}

	bool match(GameInfo const& info, variant::Type variant, unsigned gameNo)
	{
		MatchList::iterator i = m_list.begin();
		MatchList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, variant, gameNo))
				return false;
		}

		return true;
	}
};


struct Or : public Match::Logical
{
	bool matchComments(char const* data, unsigned length)
	{
		MatchList::iterator i = m_list.begin();
		MatchList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if ((*i)->matchComments(data, length))
				return true;
		}

		return false;
	}

	bool match(GameInfo const& info, variant::Type variant, unsigned gameNo)
	{
		MatchList::iterator i = m_list.begin();
		MatchList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, variant, gameNo))
				return true;
		}

		return false;
	}
};

} // namespace logical


namespace mstl {

inline
static bool
operator<(mstl::string const& lhs, MatchPair const& rhs)
{
	return lhs < rhs.keyword;
}

} // namespace mstl


inline static bool
isEqual(char const* s, char const* e, char const* str, unsigned len)
{
	return len == unsigned(e - s) && strncmp(s, str, len) == 0;
}


inline static bool
isDelim(char c)
{
	return isspace(c) || c == '\0' || c == '(' || c == ')' || c == ';';
}


static char const*
skipToDelim(char const* s)
{
	while (!isDelim(*s))
		++s;

	return s;
}


static char const*
skipSpaces(char const* s)
{
	while (::isspace(*s))
		++s;

	if (*s == ';')
	{
		// skip comment
		while (*s != '\n' && *s != '\0')
			++s;

		while (::isspace(*s))
			++s;
	}

	return s;
}


static unsigned
lengthOfKeyword(char const* s)
{
	char const* t = s;

	while (::isalpha(*t))
		++t;

	return t - s;
}


inline static bool
matchKeyword(char const* s, char const* word, unsigned len)
{
	return *s == ':' && ::strncmp(s + 1, word, len) == 0 && !::isalnum(s[len]);
}


static char const*
parseDate(char const* s, error::Type& error, Date& date)
{
	if (!date || (*s != '-' && *s != '+'))
	{
		if (	!::isdigit(s[0])
			|| !::isdigit(s[1])
			|| !::isdigit(s[2])
			|| !::isdigit(s[3])
			|| s[4] != '-'
			|| !::isdigit(s[5])
			|| !::isdigit(s[6])
			|| s[7] != '-'
			|| !::isdigit(s[8])
			|| !::isdigit(s[9]))
		{
			error = Invalid_Date;
			return s;
		}

		unsigned y = ::strtoul(s, 0, 10);
		unsigned m = ::strtoul(s + 5, 0, 10);
		unsigned d = ::strtoul(s + 8, 0, 10);

		if (!date.setYMD(y, m, d))
		{
			error = Illegal_Date;
			return s;
		}

		s += 10;
	}

	char const *t = s;

	while (*t == '+' || *t == '-')
	{
		if (!::isdigit(t[1]))
		{
			error = Illegal_Date_Offset;
			return s;
		}

		char* e;
		int offs = ::strtoul(t, &e, 10);
		t = e;

		switch (*t)
		{
			case 'y':
				if (!date.addYears(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			case 'm':
				if (!date.addMonths(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			case 'd':
				if (!date.addDays(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			default:
				error = Invalid_Date;
				return s;
		}
	}

	return t;
}


static char const*
parseEco(char const* s, error::Type& error, Eco& eco)
{
	if (s[0] > 'A' || 'E' > s[0] || !isdigit(s[1]) || isdigit(s[2]) || !isDelim(s[3]))
	{
		error = Invalid_Eco_Code;
		return s;
	}

	eco.setup(s);
	return s + 3;
}


static char const*
parseCountryCode(char const* s, error::Type& error, db::country::Code& code)
{
	mstl::string str;

	char const* t = s;

	while (::isalpha(*t))
		str += *t++;
	
	if (!::isDelim(*t))
	{
		error = Invalid_Country_Code;
	}
	else
	{
		code = db::country::Unknown;

		switch (str.size())
		{
			case 2:
				str.tolower();
				code = cql::country::lookupIso3166_2(str);
				break;

			case 3:
				str.toupper();
				code = db::country::fromString(str);
				break;
		}

		if (code == db::country::Unknown)
			error = Illegal_Country_Code;
		else
			s = t;
	}

	return s;
}


static char const*
parseGender(char const* s, error::Type& error, sex::ID sex)
{
	sex = sex::fromChar(*s);

	if (sex == sex::Unspecified || !::isDelim(s[1]))
		error = Invalid_Gender;
	else
		++s;

	return s;
}


static char const*
parseTitle(char const* s, error::Type& error, unsigned& titles)
{
	if (*s == ',')
	{
		error = Invalid_Result;
		return s;
	}

	titles = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		result.toupper();

		title::ID title = title::fromString(s);

		if (title == title::None || result != title::toString(title))
		{
			error = Invalid_Title;
			return s;
		}

		titles |= title::fromID(title);
		s = t;
	}
	while (*s == ',');

	return s;
}


static char const*
parseRatingType(char const* s, error::Type& error, rating::Type& ratingType)
{
	ratingType = rating::fromString(s);

	if (ratingType == rating::Any)
	{
		error = Invalid_Rating_Type;
	}
	else
	{
		mstl::string const& str = rating::toString(ratingType);
		char const* t = skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
			error = Invalid_Rating_Type;
		else
			s += str.size();
	}

	return s;
}


Match::Match()
	:m_isTopLevel(true)
	,m_not(false)
	,m_initialOnly(false)
	,m_finalOnly(false)
	,m_isStandard(true)
	,m_sections(0)
	,m_idn(0)
{
}


Match::Match(bool isTopLevel)
	:m_isTopLevel(isTopLevel)
	,m_not(false)
	,m_initialOnly(false)
	,m_finalOnly(false)
	,m_isStandard(true)
	,m_sections(0)
	,m_idn(0)
{
}


Match::~Match()
{
	::deleteAll(m_matchGameInfoList.begin(), m_matchGameInfoList.end());
	::deleteAll(m_matchPositionList.begin(), m_matchPositionList.end());
}


void
Match::addPosition(Position* position)
{
	m_matchPositionList.push_back(position);
}


char const*
Match::parseAnd(char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Keyword_Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));
	char c = *s;

	if (!::isEqual(s, t, "position", 8) && !::isEqual(s, t, "match", 5))
	{
		error = (m_isTopLevel && *s != 'm') ? Keyword_Match_Expected : Keyword_Match_Or_Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	if (c == 'p')
	{
		m_matchPositionList.push_back(Position::makeLogicalAnd(*this, s, error));
	}
	else
	{
		mstl::auto_ptr<logical::And> list;

		if (!m_isTopLevel)
			list.reset(new logical::And);

		do
		{
			if (list)
				s = list->pushBack().parse(s, error);
			else
				s = parse(s, error);

			if (error != No_Error)
				return s;

			s = ::skipSpaces(s);

			if (*s != '(' && *s != ')')
			{
				error = Keyword_Match_Expected;
				return s;
			}
		}
		while (*s != ')');

		if (list)
			m_matchLogicalList.push_back(list.release());
	}

	m_isStandard = false;
	return s + 1;
}


char const*
Match::parseAnnotator(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new info::Annotator(s, t));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parseBirthYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new info::BirthYear(White, min, max));
		m_matchGameInfoList.push_back(new info::BirthYear(Black, min, max));
	}

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseBlackBirthYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::BirthYear(Black, min, max));

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseBlackCountry(char const* s, Error& error)
{
	db::country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Country(country, Black));

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseBlackDeathYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::DeathYear(Black, min, max));

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseBlackElo(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Rating(rating::Elo, min, max, Black));

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseBlackGender(char const* s, Error& error)
{
	sex::ID sex = sex::Unspecified;

	s = ::parseGender(s, error, sex);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Gender(sex, Black));

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseBlackIsComputer(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsComputer(Black));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseBlackIsHuman(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsHuman(Black));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}

char const*
Match::parseBlackPlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new info::Player(s, t, Black));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parseBlackRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = Position::parseUnsignedRange(s, error, min, max);

		if (error == No_Error)
			m_matchGameInfoList.push_back(new info::Rating(ratingType, min, max, Black));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseBlackTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Title(titles, Black));

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseComment(char const* s, Error& error)
{
	if (*s != '"')
	{
		error = Double_Quote_Expected;
	}
	else
	{
		mstl::string comment;
		char const* t = s + 1;

		while (*t != '"')
		{
			switch (*t)
			{
				case '\0':
					error = Unterminated_String;
					return s;

				case '\\':
					switch (*(++t))
					{
						case 'n':	comment.append('\n'); break;
						case 't':	comment.append('\t'); break;
						default:		comment.append(*t); break;
					}
					++t;
					break;
			}
		}

		if (comment.empty())
		{
			error = Empty_String_Not_Allowed;
			return s;
		}

		m_matchCommentList.push_back(comment);
		s = t + 1;
	}

	m_isStandard = false;
	m_sections |= Section_Comments;
	return s;
}


char const*
Match::parseCountry(char const* s, Error& error)
{
	db::country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new info::Country(country, White));
		m_matchGameInfoList.push_back(new info::Country(country, Black));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseDate(char const* s, Error& error)
{
	Date min;

	s = ::parseDate(s, error, min);

	if (error != No_Error)
		return s;

	s = ::skipSpaces(s);

	Date max(min);

	if (::isdigit(*s))
	{
		s = ::parseDate(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new info::Date(min, max));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseDeathYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new info::DeathYear(White, min, max));
		m_matchGameInfoList.push_back(new info::DeathYear(Black, min, max));
	}

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseEco(char const* s, Error& error)
{
	Eco min;

	s = ::parseEco(s, error, min);

	if (error != No_Error)
		return s;

	s = ::skipSpaces(s);

	Eco max(min);

	if ('A' <= *s && *s <= 'E')
	{
		s = ::parseEco(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new info::Eco(min, max));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseElo(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new info::Rating(rating::Elo, min, max, White));
		m_matchGameInfoList.push_back(new info::Rating(rating::Elo, min, max, Black));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseEvent(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new info::Event(s, t));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parseEventCountry(char const* s, Error& error)
{
	db::country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::EventCountry(country));

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseEventDate(char const* s, Error& error)
{
	Date min;

	s = ::parseDate(s, error, min);

	if (error != No_Error)
		return s;

	Date max(min);

	if (s[0] == '.' && s[1] == '.')
	{
		s = ::parseDate(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new info::EventDate(min, max));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseEventMode(char const* s, Error& error)
{
	event::Mode mode = event::modeFromString(s);

	if (mode == event::Undetermined)
	{
		error = Invalid_Event_Mode;
	}
	else
	{
		mstl::string const& str = event::toString(mode);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Event_Mode;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new info::EventMode(mode));
		}
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseEventType(char const* s, Error& error)
{
	event::Type type = event::typeFromString(s);

	if (type == event::Unknown)
	{
		error = Invalid_Event_Type;
	}
	else
	{
		mstl::string const& str = event::toString(type);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Event_Type;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new info::EventType(type));
		}
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseForAny(char const* s, Error& error)
{
	M_ASSERT(!"not yet implemented");
	return s;
}


char const*
Match::parseGameNumber(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;
		unsigned number = ::strtoul(s, &e, 10);
		s = e;
		m_matchGameInfoList.push_back(new info::GameNumber(number));
	}

	m_sections |= Section_GameInfo;
	return s;
}



char const*
Match::parseHasAnnotation(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::HasAnnotation);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseHasComments(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::HasComments);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseHasFlags(char const* s, Error& error)
{
	unsigned flags = 0;

	while (!::isDelim(*s))
	{
		unsigned flag = GameInfo::charToFlag(*(s++));

		if (flag == 0)
		{
			error = Invalid_Game_Flag;
			return s;
		}

		flags |= flag;
	}

	m_matchGameInfoList.push_back(new info::GameFlags(flags));
	m_isStandard = false;
	m_sections |= Section_GameInfo | Section_Flags;
	return s;
}


char const*
Match::parseHasVariations(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::HasVariation);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsChess960(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsChess960);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsComputer(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsComputer(White));
	m_matchGameInfoList.push_back(new info::IsComputer(Black));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsHuman(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsHuman(White));
	m_matchGameInfoList.push_back(new info::IsHuman(Black));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsShuffleChess(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsShuffleChess);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsStandardPosition(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsStandardPosition);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseIsStartPosition(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsStartPosition);
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseLanguage(char const* s, Error& error)
{
	M_ASSERT(!"not yet implemented");
	m_isStandard = false;
	return s;
}


char const*
Match::parseNot(char const* s, Error& error)
{
	char const* t = ::skipSpaces(s);

	if (*t == '(')
	{
		mstl::auto_ptr<Position> pos(new Position);

		s = pos->parse(*this, t, error);
		pos->toggleNot();

		if (error == No_Error)
			m_matchPositionList.push_back(pos.release());
	}
	else
	{
		m_not = true;
	}

	m_isStandard = false;
	return s;
}


char const*
Match::parseOr(char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Keyword_Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));
	char c = *s;

	if (!::isEqual(s, t, "position", 8) && !::isEqual(s, t, "match", 5))
	{
		error = (m_isTopLevel && *s != 'm') ? Keyword_Match_Expected : Keyword_Match_Or_Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	if (c == 'p')
	{
		m_matchPositionList.push_back(Position::makeLogicalOr(*this, s, error));
	}
	else
	{
		mstl::auto_ptr<logical::Or> list;

		if (!m_isTopLevel)
			list.reset(new logical::Or);

		do
		{
			if (list)
				s = list->pushBack().parse(s, error);
			else
				s = parse(s, error);

			if (error != No_Error)
				return s;

			s = ::skipSpaces(s);

			if (*s != '(' && *s != ')')
			{
				error = Keyword_Match_Expected;
				return s;
			}
		}
		while (*s != ')');

		if (list)
			m_matchLogicalList.push_back(list.release());
	}

	m_isStandard = false;
	return s + 1;
}


char const*
Match::parsePlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	info::Player* match[2] = { new info::Player(s, t, White), new info::Player(s, t, Black) };

	m_matchGameInfoList.push_back(match[0]);
	m_matchGameInfoList.push_back(match[1]);

	if (match[0]->pattern().is_utf8())
		m_isStandard = false;

	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parsePlyCount(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;
		unsigned min = ::strtoul(s, &e, 10);
		s = ::skipSpaces(e);

		unsigned max = min;

		if (s[0] == '.' && s[1] == '.')
		{
			s = ::skipSpaces(s);

			if (!::isdigit(*(++s)))
			{
				error = Positive_Integer_Expected;
			}
			else
			{
				max = ::strtoul(s, &e, 10);
				s = e;
			}
		}

		m_matchGameInfoList.push_back(new info::PlyCount(min, max));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parsePosition(char const* s, Error& error)
{
	mstl::auto_ptr<Position> position(new Position);
	s = position->parse(*this, s, error);
	if (error != No_Error)
	{
		position->finish(*this);
		addPosition(position.release());
	}
	return s;
}


char const*
Match::parseRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = Position::parseUnsignedRange(s, error, min, max);

		if (error == No_Error)
		{
			m_matchGameInfoList.push_back(new info::Rating(ratingType, min, max, White));
			m_matchGameInfoList.push_back(new info::Rating(ratingType, min, max, Black));
		}
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseResult(char const* s, Error& error)
{
	unsigned results = 0;

	if (*s == ',')
	{
		error = Invalid_Result;
		return s;
	}

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		if (	result == "*"
			|| result == "1-0"
			|| result == "0-1"
			|| result == "1/2"
			|| result == "1/2-1/2"
			|| result == "0-0")
		{
			result::ID r = result::fromString(result);
			M_ASSERT(r != result::Unknown);
			results |= (1u << r);
		}
		else
		{
			error = Invalid_Result;
			return s;
		}

		s = t;
	}
	while (*s == ',');

	if (mstl::bf::count_bits(results) > 1 || (results & (1 << result::Lost)))
		m_isStandard = false;

	m_matchGameInfoList.push_back(new info::Result(results));
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseRound(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char const* t = s;
		char* e;
		unsigned round = ::strtoul(s, &e, 10);
		s = e;

		if (*s == '.')
		{
			if (!::isdigit(*(++s)))
			{
				error = Positive_Integer_Expected;
				s = t;
			}
			else
			{
				unsigned subround = ::strtoul(s, &e, 10);
				m_matchGameInfoList.push_back(new info::Round(round, subround));
				s = e;
			}
		}
		else
		{
			m_matchGameInfoList.push_back(new info::Round(round));
		}
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseSite(char const* s, Error& error)
{
	char const* t = s;

	while (*t && *t != '(' && *t != ')' && !::isspace(*t))
		++t;

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new info::Site(s, t));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parseStartPosition(char const* s, Error& error)
{
	char const*	t;
	unsigned		idn = 0;

	if (::isdigit(*s))
	{
		idn = ::strtoul(s, const_cast<char**>(&t), 10);

		if (idn == 0)
		{
			idn = 960;
		}
		else if (idn > 4*960)
		{
			error = Invalid_IDN;
		}
	}
	else if (::isalpha(*s))
	{
		mstl::string pos(s, t = ::skipToDelim(s));

		idn = pos == "standard" ? variant::Standard : variant::idnFromString(pos);

		if (idn == variant::None)
			error = Invalid_FICS_Position;
	}
	else
	{
		error = Position_Number_Expected;
	}

	if (error == No_Error)
	{
		s = t;
		m_matchGameInfoList.push_back(new info::StartPosition(idn));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseTermination(char const* s, Error& error)
{
	unsigned reasons = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		result.toupper();

		termination::Reason reason = termination::fromString(s);

		if (reason == termination::Unknown || result != termination::toString(reason))
		{
			error = Invalid_Termination;
			return s;
		}

		reasons |= 1u << reason;
		s = t;
	}
	while (*s == ',');

	m_matchGameInfoList.push_back(new info::Termination(reasons));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseTimeMode(char const* s, Error& error)
{
	unsigned modes = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string mode(s, t);

		mode.tolower();

		time::Mode m = time::fromString(s);

		if (m == time::Unknown || mode != time::toString(m))
		{
			error = Invalid_Time_Mode;
			return s;
		}

		modes |= 1u << m;
		s = t;
	}
	while (*s == ',');

	m_matchGameInfoList.push_back(new info::TimeMode(modes));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new info::Title(titles, White));
		m_matchGameInfoList.push_back(new info::Title(titles, Black));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo; // XXX depends on database format
	return s;
}


char const*
Match::parseVariant(char const* s, Error& error)
{
	variant::Type variant = variant::fromString(s);

	if (variant == variant::Undetermined)
	{
		error = Invalid_Variant;
	}
	else
	{
		mstl::string const& str = variant::identifier(variant);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Variant;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new info::Variant(variant));
		}
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteBirthYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::BirthYear(White, min, max));

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteCountry(char const* s, Error& error)
{
	db::country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Country(country, White));

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteDeathYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::DeathYear(White, min, max));

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteElo(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Rating(rating::Elo, min, max, White));

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteGender(char const* s, Error& error)
{
	sex::ID sex = sex::Unspecified;

	s = ::parseGender(s, error, sex);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Gender(sex, White));

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteIsComputer(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsComputer(White));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteIsHuman(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new info::IsHuman(White));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhitePlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new info::Player(s, t, White));
	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return t;
}


char const*
Match::parseWhiteRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = Position::parseUnsignedRange(s, error, min, max);

		if (error == No_Error)
			m_matchGameInfoList.push_back(new info::Rating(ratingType, min, max, White));
	}

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseWhiteTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Title(titles, White));

	m_isStandard = false;
	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parseYear(char const* s, Error& error)
{
	unsigned min, max;

	s = Position::parseUnsignedRange(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new info::Year(min, max));

	m_sections |= Section_GameInfo;
	return s;
}


char const*
Match::parse(char const* s, Error& error)
{
	typedef MatchPair Pair;

	static Pair const Trampolin[] =
	{
		Pair("and",						&Match::parseAnd),
		Pair("annotator",				&Match::parseAnnotator),
		Pair("birthyear",				&Match::parseBirthYear),
		Pair("blackbirthyear",		&Match::parseBlackBirthYear),
		Pair("blackcountry",			&Match::parseBlackCountry),
		Pair("blackdeathyear",		&Match::parseBlackDeathYear),
		Pair("blackelo",				&Match::parseBlackElo),
		Pair("blackgender",			&Match::parseBlackGender),
		Pair("blackiscomputer",		&Match::parseBlackIsComputer),
		Pair("blackishuman",			&Match::parseBlackIsHuman),
		Pair("blackplayer",			&Match::parseBlackPlayer),
		Pair("blackrating",			&Match::parseBlackRating),
		Pair("blacktitle",			&Match::parseBlackTitle),
		Pair("comment",				&Match::parseComment),
		Pair("country",				&Match::parseCountry),
		Pair("date",					&Match::parseDate),
		Pair("deathyear",				&Match::parseDeathYear),
		Pair("eco",						&Match::parseEco),
		Pair("elo",						&Match::parseElo),
		Pair("event",					&Match::parseEvent),
		Pair("eventcountry",			&Match::parseEventCountry),
		Pair("eventdate",				&Match::parseEventDate),
		Pair("eventmode",				&Match::parseEventMode),
		Pair("eventtype",				&Match::parseEventType),
		Pair("forany",					&Match::parseForAny),
		Pair("gamenumber",			&Match::parseGameNumber),
		Pair("hasannotation",		&Match::parseHasAnnotation),
		Pair("hascomments",			&Match::parseHasComments),
		Pair("hasflags",				&Match::parseHasFlags),
		Pair("hasvariations",		&Match::parseHasVariations),
		Pair("ischess960",			&Match::parseIsChess960),
		Pair("iscomputer",			&Match::parseIsComputer),
		Pair("ishuman",				&Match::parseIsHuman),
		Pair("isshufflechess",		&Match::parseIsShuffleChess),
		Pair("isstandardposition",	&Match::parseIsStandardPosition),
		Pair("isstartposition",		&Match::parseIsStartPosition),
		Pair("language",				&Match::parseLanguage),
		Pair("not",						&Match::parseNot),
		Pair("or",						&Match::parseOr),
		Pair("player",					&Match::parsePlayer),
		Pair("plycount",				&Match::parsePlyCount),
		Pair("position",				&Match::parsePosition),
		Pair("rating",					&Match::parseRating),
		Pair("result",					&Match::parseResult),
		Pair("round",					&Match::parseRound),
		Pair("site",					&Match::parseSite),
		Pair("positionnumber",		&Match::parseStartPosition),
		Pair("termination",			&Match::parseTermination),
		Pair("timemode",				&Match::parseTimeMode),
		Pair("title",					&Match::parseTitle),
		Pair("variant",				&Match::parseVariant),
		Pair("whitebirthyear",		&Match::parseWhiteBirthYear),
		Pair("whitecountry",			&Match::parseWhiteCountry),
		Pair("whitedeatchyear",		&Match::parseWhiteDeathYear),
		Pair("whiteelo",				&Match::parseWhiteElo),
		Pair("whitegender",			&Match::parseWhiteGender),
		Pair("whiteiscomputer",		&Match::parseWhiteIsComputer),
		Pair("whiteishuman",			&Match::parseWhiteIsHuman),
		Pair("whiteplayer",			&Match::parseWhitePlayer),
		Pair("whiterating",			&Match::parseWhiteRating),
		Pair("whitetitle",			&Match::parseWhiteTitle),
		Pair("year",					&Match::parseYear),
	};

	mstl::string key;

	error = No_Error;

	if (*s == '(')
	{
		s = ::skipSpaces(s);

		if (::matchKeyword(s, "match", 5))
		{
			s = ::skipSpaces(s + 6);

			while (*s == ':' || *s == '(')
			{
				if (*s == '(')
				{
					char const* t = ::skipSpaces(s + 1);

					if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
					{
						error = Keyword_Position_Expected;
						return s;
					}

					mstl::auto_ptr<Position> position(new Position);
					position->parse(*this, t, error);

					if (error != No_Error)
						return s;

					addPosition(position.release());
				}
				else
				{
					mstl::string key(s + 1, ::lengthOfKeyword(s + 1));
					Pair const* p = mstl::binary_search(Trampolin, Trampolin + U_NUMBER_OF(Trampolin), key);

					if (p == Trampolin + U_NUMBER_OF(Trampolin))
					{
						error = Invalid_Keyword;
						return s;
					}

					s = (this->*p->func)(::skipSpaces(s + key.size() + 1), error);

					if (error != No_Error)
						return s;

					s = ::skipSpaces(s);
				}
			}

			if (*s != ')')
			{
				error = Right_Parenthesis_Expected;
			}
			else
			{
				s = ::skipSpaces(s + 1);

				if (*s != '\0')
					error = Trailing_Characters;
			}
		}
		else
		{
			error = Keyword_Match_Expected;
		}
	}
	else
	{
		error = Left_Parenthesis_Expected;
	}

	return s;
}


void
Match::reset()
{
	MatchPositionList::iterator i = m_matchPositionList.begin();
	MatchPositionList::iterator e = m_matchPositionList.end();

	for ( ; i != e; ++i)
		(*i)->reset();
}


bool
Match::doMatch(GameInfo const& info, variant::Type variant, unsigned gameNo)
{
	{
		MatchGameInfoList::iterator i = m_matchGameInfoList.begin();
		MatchGameInfoList::iterator e = m_matchGameInfoList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, variant, gameNo))
				return false;
		}
	}
	{
		MatchLogicalList::const_iterator i = m_matchLogicalList.begin();
		MatchLogicalList::const_iterator e = m_matchLogicalList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, variant, gameNo))
				return false;
		}
	}

	reset();

	return true;
}


bool
Match::match(GameInfo const& info, variant::Type variant, unsigned gameNo)
{
	bool match = doMatch(info, variant, gameNo);

	if (m_not)
		match = !match;

	return match;
}



bool
Match::match(GameInfo const& info, db::Board const& board, variant::Type variant, bool isFinal)
{
	if (m_finalOnly && !isFinal)
		return false;
	
	MatchPositionList::iterator i = m_matchPositionList.begin();
	MatchPositionList::iterator e = m_matchPositionList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(info, board, variant, isFinal))
			return false;
	}

	return true;
}


bool
Match::match(db::Board const& board, Move const& move)
{
	M_ASSERT(board.sideToMove() == move.color());

	MatchPositionList::iterator i = m_matchPositionList.begin();
	MatchPositionList::iterator e = m_matchPositionList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(board, move))
			return false;
	}

	return true;
}


bool
Match::matchComments(char const* data, unsigned length)
{
	M_REQUIRE(matchComments());

	bool match = doMatchComments(data, length);

	if (m_not)
		match = !match;
	
	return match;
}


bool
Match::doMatchComments(char const* data, unsigned length)
{
	{
		MatchCommentList::const_iterator i = m_matchCommentList.begin();
		MatchCommentList::const_iterator e = m_matchCommentList.end();

		for ( ; i != e; ++i)
		{
			if (!i->search(data, data + length))
				return false;
		}
	}
	{
		MatchLogicalList::const_iterator i = m_matchLogicalList.begin();
		MatchLogicalList::const_iterator e = m_matchLogicalList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->matchComments(data, length))
				return false;
		}
	}

	return true;
}

// vi:set ts=3 sw=3:
