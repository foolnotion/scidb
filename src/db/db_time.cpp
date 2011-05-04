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

#include "db_time.h"

#include "sys_file.h"

using namespace db;


Time::Time(::sys::file::Time& time)
	:m_year(time.year)
	,m_month(time.month)
	,m_day(time.day)
	,m_hour(time.hour)
	,m_minute(time.minute)
	,m_second(time.second)
{
}


mstl::string
Time::asString() const
{
	mstl::string str;

	if (!isEmpty())
		str.format("%04u.%02u.%02u %02u:%02u:%02u", m_year, m_month, m_day, m_hour, m_minute, m_second);

	return str;
}

// vi:set ts=3 sw=3:
