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

#include "m_utility.h"
#include "m_assert.h"

#include <string.h>

namespace db {

inline Line::Line() : moves(0), length(0) {}


inline Line::Line(uint16_t const* moves, unsigned length)
	:moves(moves)
	,length(length)
{
	M_REQUIRE(moves);
}


inline
void
Line::copy(Line const& line)
{
	M_REQUIRE(moves);

	length = line.length;
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	::memcpy(const_cast<uint16_t*>(moves), line.moves, mstl::mul2(length));
}


inline
void
Line::copy(Line const& line, unsigned maxLength)
{
	M_REQUIRE(moves);

	length = mstl::min(line.length, maxLength);
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	::memcpy(const_cast<uint16_t*>(moves), line.moves, mstl::mul2(length));
}


inline
void
Line::copy(uint16_t const* line, unsigned maxLength)
{
	M_REQUIRE(moves);
	M_REQUIRE(line);

	length = mstl::min(length, maxLength);
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	::memcpy(const_cast<uint16_t*>(moves), line, mstl::mul2(length));
}


inline
Line&
Line::transpose()
{
	return transpose(*this);
}


inline
bool
Line::operator==(Line const& line) const
{
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	return length == line.length && ::memcmp(moves, line.moves, mstl::mul2(length)) == 0;
}


inline
bool
Line::operator!=(Line const& line) const
{
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	return length != line.length || ::memcmp(moves, line.moves, mstl::mul2(length)) != 0;
}


inline
bool
Line::operator<=(Line const& line) const
{
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	return length <= line.length && ::memcmp(moves, line.moves, mstl::mul2(length)) <= 0;
}


inline
bool
Line::partialMatch(Line const& line) const
{
	M_REQUIRE(length <= line.length);
	static_assert(sizeof(moves[0]) == 2, "memcmp() cannot work");
	return ::memcmp(moves, line.moves, mstl::mul2(length)) == 0;
}


inline
uint16_t
Line::operator[](unsigned n) const
{
	M_REQUIRE(n < length);
	return moves[n];
}


inline
mstl::string&
Line::print(mstl::string& result,
				Board const& startBoard,
				variant::Type variant,
				move::Notation style,
				protocol::ID protocol,
				encoding::CharSet charSet) const
{
	return print(result, startBoard, variant, 0, length, length, style, protocol, charSet);
}


#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

inline
Line::Line(Line&& line)
	:moves(line.moves)
	,length(line.length)
{
	line.moves = 0;
}


inline
Line&
Line::operator=(Line&& line)
{
	mstl::swap(moves, line.moves);
	length = line.length;
	return *this;
}

#endif

} // namespace db

// vi:set ts=3 sw=3:
