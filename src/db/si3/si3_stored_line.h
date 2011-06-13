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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _si3_stored_line_included
#define _si3_stored_line_included

#include "db_eco.h"
#include "db_line.h"

namespace db {
namespace si3 {

class StoredLine
{
public:

	enum { Max_Length = 21 };

	static bool isInitialized();

	bool isSuccessor(uint8_t index) const;

	uint8_t index() const;
	Eco ecoKey() const;
	Eco opening() const;
	Line const& line() const;

	static StoredLine const& lookup(Eco const& key);
	static StoredLine const& getLine(uint8_t index);
	static StoredLine const& findLine(Line const& line);
	static char const* getText(uint8_t index);
	static unsigned count();

	static void initialize();

private:

	StoredLine();

	uint16_t	m_buf[Max_Length + 1];
	Line		m_line;
	Eco		m_opening;
	Eco		m_ecoKey;

	static StoredLine	m_lines[255];
};

} // namespace si3
} // namespace db

namespace mstl {

template <> struct is_pod<db::si3::StoredLine>
{
	enum { value = is_pod<db::Line>::value & is_pod<db::Eco>::value };
};

} // namespace mstl

#include "si3_stored_line.ipp"

#endif // _si3_stored_line_included

// vi:set ts=3 sw=3:
