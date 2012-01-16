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
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {
namespace si3 {

inline bool StoredLine::isInitialized()		{ return m_lines[1].m_line.length > 0; }
inline uint8_t StoredLine::index() const		{ return this - m_lines; }
inline Eco StoredLine::ecoKey() const			{ return m_ecoKey; }
inline Eco StoredLine::opening() const			{ return m_opening; }
inline unsigned StoredLine::count()				{ return U_NUMBER_OF(m_lines); }
inline Line const& StoredLine::line() const	{ return m_line; }


inline
StoredLine const&
StoredLine::getLine(uint8_t index)
{
	M_ASSERT(index < count());
	return m_lines[index];
}

} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
