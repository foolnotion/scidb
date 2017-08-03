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
// Copyright: (C) 2011-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"

namespace db {

inline Clock::Clock() :m_value(0) {}

inline bool Clock::isEmpty() const		{ return m_value == 0; }

inline uint8_t Clock::hour() const		{ return m_hour; }
inline uint8_t Clock::minute() const	{ return m_minute; }
inline uint8_t Clock::second() const	{ return m_second; }


inline
int
Clock::compare(Clock const& lhs, Clock const& rhs)
{
	return mstl::compare(lhs.m_value, rhs.m_value);
}


inline
Clock::Clock(uint8_t hour, uint8_t minute, uint8_t second)
	:m_second(second)
	,m_minute(minute)
	,m_hour(hour)
{
}


inline
void
Clock::setHMS(uint8_t hour, uint8_t minute, uint8_t second)
{
	m_second = second;
	m_minute = minute;
	m_hour = hour;
}

} // namespace db

namespace mstl {

inline
int
compare(::db::Clock const& lhs, ::db::Clock const& rhs)
{
	return ::db::Clock::compare(lhs, rhs);
}

} // namespace mstl

// vi:set ts=3 sw=3:
