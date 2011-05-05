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

#include "m_assert.h"

namespace db {
namespace si3 {

inline bool NameList::isEmpty() const				{ return m_first == m_last; }

inline unsigned NameList::size() const				{ return m_size; }
inline unsigned NameList::maxId() const			{ return m_lookup.size() - 1; }
inline unsigned NameList::maxFrequency() const	{ return m_maxFrequency; }

inline NameList::Node const* NameList::first() const	{ return m_first == m_last ? 0 : *m_first; }
inline NameList::Node const* NameList::next() const	{ return ++m_first == m_last ? 0 : *m_first; }


inline
unsigned
NameList::lookup(unsigned id) const
{
	M_REQUIRE(id <= maxId());

	M_ASSERT(m_lookup[id]);
	M_ASSERT(m_lookup[id]->id < m_size);

	return m_lookup[id]->id;
}

} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
