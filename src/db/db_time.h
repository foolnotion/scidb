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
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
// ======================================================================

#ifndef _db_time_included
#define _db_time_included

#include "u_base.h"

#include "m_string.h"

namespace sys { namespace file { struct Time; } }

namespace db {

class Time
{
public:

	Time();
	Time(::sys::file::Time& time);

	operator bool() const;

	bool isEmpty() const;

	unsigned year() const;
	unsigned month() const;
	unsigned day() const;
	unsigned hour() const;
	unsigned minute() const;
	unsigned second() const;

	mstl::string asString() const;

	void clear();

	friend bool operator==(const Time& d1, const Time& d2);
	friend bool operator!=(const Time& d1, const Time& d2);

private:

	uint16_t	m_year;
	uint8_t	m_month;
	uint8_t	m_day;
	uint8_t	m_hour;
	uint8_t	m_minute;
	uint8_t	m_second;
};

bool operator==(const Time& d1, const Time& d2);
bool operator!=(const Time& d1, const Time& d2);

} // namespace db

namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod<db::Time> { enum { value = 1 }; };

} // namespace mstl

#include "db_time.ipp"

#endif // _db_time_included

// vi:set ts=3 sw=3:
