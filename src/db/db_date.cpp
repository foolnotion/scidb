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

#include "db_date.h"

#include "m_utility.h"
#include "m_stdio.h"

#include <string.h>
#include <ctype.h>

using namespace db;


// taken from "Communications of the ACM", Vol 6, No 8, p 444 (Aug 1963)
// this function is not valid before 14 Sep 1752
static unsigned
computeJulian(unsigned y, unsigned m, unsigned d)
{
	if (m > 2)
	{
		m -= 3;
	}
	else
	{
		m += 9;
		++y;
	}

	unsigned c = y/100;

	return 1721119 + d + ((146097*c)>>2) + ((1461*(y - 100*c))>>2) + (153*m + 2)/5;
}


// taken from "Communications of the ACM", Vol 6, No 8, p 444 (Aug 1963)
// this function is not valid before 14 Sep 1752
static bool
computeDate(Date& date, unsigned julian)
{
	int j = julian - 1721119;
	int y, m, d, t;

	y = ((j<<2) - 1)/146097;
	j = (j<<2) - 146097*y - 1;
	t = j>>2;
	j = ((t<<2) + 3)/1461;
	y = 100*y + j;
	t = 5*(((t<<2) - 1461*j + 7)>>2);
	m = (t - 3)/153;
	d = (t - 153*m + 2)/5;

	if (m < 10)
	{
		m += 3;
	}
	else
	{
		m -= 9;
		++y;
	}

	return date.setYMD(y, m, d);
}


inline
bool
isLeapYear(unsigned y)
{
	return !mstl::mod4(y) && (y % 100 || !(y % 400));
}


unsigned
Date::lastDayInMonth(unsigned y, unsigned m)
{
	static unsigned const MonthDays[13] = { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

	M_REQUIRE(m <= 12);
	M_REQUIRE(m > 0);

	return m == 2 && isLeapYear(y) ? 29 : MonthDays[m];
}


bool
Date::checkDay(unsigned y, unsigned m, unsigned d)
{
	M_ASSERT(m <= 12);
	M_ASSERT(m > 0);

	return d <= lastDayInMonth(y, m);
}


Date::Date() : m_value(0) {}


Date::Date(mstl::string const& s)
	:m_value(0)
{
	if (!s.empty())
		fromString(s);
}


Date::Date(unsigned y)
	:m_day(0)
	,m_month(0)
	,m_year(y)
{
	M_REQUIRE(y == 0 || mstl::is_between(uint16_t(y), MinYear, MaxYear));
}


Date::Date(unsigned y, unsigned m)
	:m_day(0)
	,m_month(m)
	,m_year(y)
{
	M_REQUIRE(y == 0 || mstl::is_between(uint16_t(y), MinYear, MaxYear));
	M_REQUIRE(y ? m <= 12 : m == 0);
}


Date::Date(unsigned y, unsigned m, unsigned d)
	:m_day(d)
	,m_month(m)
	,m_year(y)
{
	M_REQUIRE(y == 0 || mstl::is_between(uint16_t(y), MinYear, MaxYear));
	M_REQUIRE(y ? m <= 12 : m == 0);
	M_REQUIRE(m ? checkDay(y, m, d) : d == 0);
}


bool
Date::setYMD(unsigned y, unsigned m, unsigned d)
{
	if (!mstl::is_between(uint16_t(y), MinYear, MaxYear))
	{
		m_value = 0;
		return false;
	}

	m_year = y;

	if (0 < m && m <= 12)
	{
		m_month = m;

		if (d != 0 && !checkDay(y, m, d))
		{
			m_day = 0;
			return false;
		}

		m_day = d;
	}
	else
	{
		m_minor = 0;
		return false;
	}

	return true;
}


::util::crc::checksum_t
Date::computeChecksum(util::crc::checksum_t crc) const
{
	crc = ::util::crc::compute(crc, m_year);
	crc = ::util::crc::compute(crc, m_month);
	crc = ::util::crc::compute(crc, m_day);

	return crc;
}


bool
Date::parseYear(char const* s)
{
	m_year = (s[0] - '0')*1000 + (s[1] - '0')*100 + (s[2] - '0')*10 + (s[3] - '0');

	if (mstl::is_between(m_year, MinYear, MaxYear))
		return true;

	m_value = 0;
	return false;
}


bool
Date::parseMonth(char const* s)
{
	M_ASSERT(m_year);

	m_month = (s[0] - '0')*10 + (s[1] - '0');

	if (0 < m_month && m_month <= 12)
		return true;

	m_minor = 0;
	return false;
}


bool
Date::parseDay(char const* s)
{
	M_ASSERT(m_year && m_month);

	m_day = (s[0] - '0')*10 + (s[1] - '0');

	if (m_day == 0)
		return false;

	if (checkDay(m_year, m_month, m_day))
		return true;

	m_day = 0;
	return false;
}


bool
Date::parseFromString(char const* s, unsigned size)
{
	switch (size)
	{
		case 4:
			m_minor = 0;

			if (s[0] == '?')
				m_year = 0;
			else if (!parseYear(s))
				return false;
			break;

		case 7:
			m_day = 0;

			if (s[4] == '.' || s[4] == '/')
			{
				if (s[0] == '?')
					m_year = m_month = 0;
				else if (!parseYear(s))
					return false;
				else if (s[5] == '?')
					m_month = 0;
				else if (!parseMonth(s + 5))
					return false;
			}
			else if (s[2] == '.' || s[2] == '/')
			{
				if (s[3] == '?')
					m_year = m_month = 0;
				else if (!parseYear(s + 3))
					return false;
				else if (*s == '?')
					m_month = 0;
				else if (!parseMonth(s))
					return false;
			}
			else
			{
				m_year = m_month = 0;
				return false;
			}
			break;

		case 8:
			m_value = 0;
			if ((s[4] != '.' && s[4] != '/') || (s[6] != '.' && s[6] != '/'))
				return false;
			if (!parseYear(s))
				return false;
			if (s[5] != '?')
			{
				if (!::isdigit(s[5]))
					return false;
				m_month = s[5] - '0';
				if (s[7] != '?')
				{
					if (!::isdigit(s[7]))
						return false;
					m_day = s[7] - '0';
				}
			}
			break;

		case 9:
			m_value = 0;
			if (s[4] != '.' && s[4] != '/')
				return false;
			if (!parseYear(s))
				return false;
			if (s[6] == '.' || s[6] == '/')
			{
				if (s[5] != '?')
				{
					if (!::isdigit(s[5]))
						return false;
					m_month = s[5] - '0';
					if (!parseDay(s + 7))
						return false;
				}
			}
			else if (s[7] == '.' || s[7] == '/')
			{
				if (s[8] != '?')
				{
					if (!parseMonth(s + 5))
						return false;
					if (!::isdigit(s[8]))
						return false;
					m_day = s[8] - '0';
				}
			}
			else
			{
				return false;
			}
			break;

		case 10:
			if (s[4] == '.' || s[4] == '/')
			{
				if (s[0] == '?')
					m_year = m_month = m_day = 0;
				else if (!parseYear(s))
					return false;
				else if (s[5] == '?')
					m_minor = 0;
				else if (!parseMonth(s + 5))
					return false;
				else if (s[8] == '?')
					m_day = 0;
				else if (!parseDay(s + 8))
					return false;
			}
			else if (s[2] == '.' || s[2] == '/')
			{
				if (s[6] == '?')
					m_value = 0;
				else if (!parseYear(s + 6))
					return false;
				else if (s[3] == '?')
					m_minor = 0;
				else if (!parseMonth(s + 3))
					return false;
				else if (*s == '?')
					m_day = 0;
				else if (!parseDay(s))
					return false;
			}
			else
			{
				m_value = 0;
				return false;
			}
			break;

		default:
			m_value = 0;
			return false;
	}

	return true;
}


bool
Date::isValid(mstl::string const& s)
{
	return Date().parseFromString(s);
}


bool
Date::isValid(char const* s, unsigned len)
{
	return Date().parseFromString(s, len ? len : ::strlen(s));
}


bool
Date::isValid(unsigned y, unsigned m, unsigned d)
{
	if (y == 0)
		return m == 0 && d == 0;

	if (y < MinYear || MaxYear < y)
		return false;

	if (m == 0)
		return d == 0;

	if (m > 12)
		return false;

	if (d == 0)
		return true;

	return checkDay(y, m, d);
}


void
Date::fromString(mstl::string const& s)
{
	M_REQUIRE(isValid(s));

	if (s[0] == '?')
	{
		m_value = 0;
	}
	else
	{
		m_year = (s[0] - '0')*1000 + (s[1] - '0')*100 + (s[2] - '0')*10 + (s[3] - '0');

		if (s[5] == '?')
		{
			m_minor = 0;
		}
		else
		{
			m_month = (s[5] - '0')*10 + (s[6] - '0');
			m_day = s[8] == '?' ? 0 : (s[8] - '0')*10 + (s[9] - '0');
		}
	}
}


bool
Date::parseFromString(mstl::string const& s)
{
	return parseFromString(s, s.size());
}


mstl::string
Date::asString() const
{
	if (!m_year)
		return "????.??.??";

	char buf[16];

	if (m_minor == 0)
		::snprintf(buf, sizeof(buf), "%04u.??.??", m_year);
	else if (m_day == 0)
		::snprintf(buf, sizeof(buf), "%04u.%02u.??", m_year, m_month);
	else
		::snprintf(buf, sizeof(buf), "%04u.%02u.%02u", m_year, m_month, m_day);

	return buf;
}


mstl::string
Date::asShortString() const
{
	if (!m_year)
		return "";

	char buf[16];

	if (m_minor == 0)
		::snprintf(buf, sizeof(buf), "%04u", m_year);
	else if (m_day == 0)
		::snprintf(buf, sizeof(buf), "%04u.%02u", m_year, m_month);
	else
		::snprintf(buf, sizeof(buf), "%04u.%02u.%02u", m_year, m_month, m_day);

	return buf;
}


int
Date::compare(Date const& lhs, Date const& rhs)
{
	int res;

	if ((res = int(lhs.year()) - int(rhs.year())))
		return res;

	if ((res = int(lhs.month()) - int(rhs.month())))
		return res;

	return int(lhs.day()) - int(rhs.day());
}


bool
Date::addYears(int n)
{
	M_REQUIRE(year() > 0);

	if (n)
	{
		int y = int(m_year) + n;

		if (y < int(MinYear) || int(MaxYear) < y)
			return false;
		
		m_year = y;

		if (m_day)
		{
			if (!checkDay(m_year, m_month, m_day))
				--m_day;

			M_ASSERT(checkDay(m_year, m_month, m_day));
		}
	}

	return true;
}


bool
Date::addMonths(int n)
{
	M_REQUIRE(month() > 0);

	if (n)
	{
		int sign;

		if (n > 0)
		{
			sign = 1;
		}
		else
		{
			sign = -1;
			n = -n;
		}

		int years = n/12;

		if (n %= 12)
		{
			if (sign == -1 ? m_month > n : m_month + n > 12)
			{
				++years;
				n = 12 - n;
			}
		}

		if (years)
		{
			int y = int(m_year) + sign*years;

			if (y < int(MinYear) || int(MaxYear) < y)
				return false;

			m_year = y;
		}

		m_month += sign*n;
		M_ASSERT(0 < m_month && m_month <= 12);

		if (!checkDay(m_year, m_month, m_day))
			--m_day;

		M_ASSERT(checkDay(m_year, m_month, m_day));
	}

	return true;
}


bool
Date::addDays(int n)
{
	M_REQUIRE(day() > 0);

	unsigned julian = ::computeJulian(m_year, m_month, m_day);

	if (n > int(julian))
		return false;

	return ::computeDate(*this, julian + n);
}

// vi:set ts=3 sw=3:
