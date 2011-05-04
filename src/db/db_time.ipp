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
// Copyright: (C) 2010-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace db {

inline Time::operator bool() const		{ return m_year > 0; }
inline bool Time::isEmpty() const		{ return m_year == 0; }
inline unsigned Time::year() const		{ return m_year; }
inline unsigned Time::month() const		{ return m_month; }
inline unsigned Time::day() const		{ return m_day; }
inline unsigned Time::hour() const		{ return m_hour; }
inline unsigned Time::minute() const	{ return m_minute; }
inline unsigned Time::second() const	{ return m_second; }
inline void Time::clear()					{ m_year = m_month = m_day = m_hour = m_minute = m_second = 0; }


inline
bool
operator==(const Time& lhs, const Time& rhs)
{
	return	lhs.m_year		== rhs.m_year
			&& lhs.m_month		== rhs.m_month
			&& lhs.m_day		== rhs.m_day
			&& lhs.m_hour		== rhs.m_hour
			&& lhs.m_minute	== rhs.m_minute
			&& lhs.m_second	== rhs.m_second;
}


inline
bool
operator!=(const Time& lhs, const Time& rhs)
{
	return	lhs.m_year		!= rhs.m_year
			|| lhs.m_month		!= rhs.m_month
			|| lhs.m_day		!= rhs.m_day
			|| lhs.m_hour		!= rhs.m_hour
			|| lhs.m_minute	!= rhs.m_minute
			|| lhs.m_second	!= rhs.m_second;
}

} // namespace db

// vi:set ts=3 sw=3:
