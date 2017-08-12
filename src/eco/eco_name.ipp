// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_algorithm.h"
#include "m_assert.h"

#include <string.h>

namespace eco {

inline Name::Name() :m_size(0), m_mark(false) { init(); }
inline Name::Name(char const* s) :m_size(0), m_mark(false) { init(); set(0, s); }

inline auto Name::size() const -> unsigned	{ return m_size; }
inline auto Name::countChars() -> unsigned	{ return m_numChars; }
inline auto Name::countNames() -> unsigned	{ return m_lookup.size(); }
inline auto Name::countStrings() -> unsigned	{ return m_strings.size(); }
inline auto Name::empty() -> Name const&		{ return m_empty; }
inline auto Name::isEmpty() const -> bool		{ return m_size == 0; }
inline auto Name::hasMark() const -> bool		{ return m_mark; }
inline void Name::setMark()						{ m_mark = true; }

inline auto Name::str(unsigned level) const -> mstl::string const& { return m_strings[ref(level)]; }


inline
auto Name::operator==(Name const& name) const -> bool
{
	return mstl::equal(m_ref, m_ref + NumEntries, name.m_ref);
}


inline
auto Name::operator!=(Name const& name) const -> bool
{
	return !mstl::equal(m_ref, m_ref + NumEntries, name.m_ref);
}


inline
auto Name::number(unsigned level) const -> unsigned
{
	M_REQUIRE(level < NumEntries);
	return m_ref[level];
}


inline
auto Name::isEmpty(unsigned level) const -> bool
{
	M_REQUIRE(level < NumEntries);
	return number(level) == 0;
}


inline
auto Name::lookup(unsigned ref) -> Name*
{
	M_REQUIRE(ref < countNames());
	return m_lookup[ref];
}


inline
auto Name::ref(unsigned level) const -> unsigned
{
	M_REQUIRE(level < NumEntries);
	M_REQUIRE(number(level) != 0);

	return m_ref[level] - 1;
}


inline
auto Name::lastRef() const -> unsigned
{
	M_REQUIRE(!isEmpty());
	return m_ref[m_size - 1] - 1;
}


inline
void Name::clear()
{
	m_size = 0;
	init();
}

} // namespace eco

// vi:set ts=3 sw=3:
