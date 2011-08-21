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

#ifndef _db_clock_included
#define _db_clock_included

#include "m_types.h"

namespace db {

class Clock
{
public:

	Clock();
	Clock(uint8_t hour, uint8_t minute, uint8_t second);

	uint8_t hour() const;
	uint8_t minute() const;
	uint8_t second() const;

	void set(uint8_t hour, uint8_t minute, uint8_t second);

private:

	uint8_t m_hour;
	uint8_t m_minute;
	uint8_t m_second;
};

} // namespace db

#include "db_clock.ipp"

#endif // _db_clock_included

// vi:set ts=3 sw=3:
