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

#include "m_assert.h"

namespace db {
namespace si3 {
namespace encoder {

inline void Position::push()	{ m_stack.dup(); }
inline void Position::pop()	{ m_stack.pop(); }

inline Byte Position::operator[](unsigned n) const	{ return m_stack.top().numbers[n]; }
inline Position::Lookup& Position::lookup()			{ return m_stack.top(); }


inline
void
Position::Lookup::set(Square square, unsigned pieceNum, color::ID color)
{
	M_ASSERT(pieceNum < 16);

	squares[color][pieceNum] = square;
	numbers[square] = pieceNum;
}

} // namespace encoder
} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
