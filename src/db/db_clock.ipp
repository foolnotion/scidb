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
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace db {

inline Clock::Clock() :m_hour(0), m_minute(0), m_second(0) {}

inline uint8_t Clock::hour() const		{ return m_hour; }
inline uint8_t Clock::minute() const	{ return m_minute; }
inline uint8_t Clock::second() const	{ return m_second; }


inline
Clock::Clock(uint8_t hour, uint8_t minute, uint8_t second)
	:m_hour(hour)
	,m_minute(minute)
	,m_second(second)
{
}


inline
void
Clock::set(uint8_t hour, uint8_t minute, uint8_t second)
{
	m_hour = hour;
	m_minute = minute;
	m_second = second;
}

} // namespace db

// vi:set ts=3 sw=3:
