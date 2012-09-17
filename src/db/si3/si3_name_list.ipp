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

inline bool NameList::isEmpty() const				{ return m_maxId == 0; }
inline bool NameList::hasId(unsigned id) const	{ return m_lookup[id] != 0; }

inline unsigned NameList::size() const				{ return m_maxId; }
inline unsigned NameList::maxFrequency() const	{ return m_maxFrequency; }

#ifdef DEBUG_SI4
inline NameList::Node* NameList::back()			{ return m_list.back(); }
#endif

inline void NameList::resetMaxFrequency()			{ m_maxFrequency = 0; }


inline
void
NameList::updateMaxFrequency(unsigned freq)
{
	if (freq > m_maxFrequency)
		m_maxFrequency = freq;
}


inline
NameList::Node const*
NameList::next() const
{
	return (++m_first == m_last) ? 0 : *m_first;
}


inline
NameList::Node*
NameList::operator[](unsigned i) const
{
	M_ASSERT(i < size());
	return m_list[i];
}


inline
NameList::Node*
NameList::lookup(unsigned id)
{
	M_ASSERT(id < m_lookup.size());
	M_ASSERT(m_lookup[id]);

	return m_lookup[id];
}


inline
NameList::Node const*
NameList::lookup(unsigned id) const
{
	M_ASSERT(id < m_lookup.size());
	M_ASSERT(m_lookup[id]);

	return m_lookup[id];
}

} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
