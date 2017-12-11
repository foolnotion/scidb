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

namespace db {

inline bool Selector::isUnsorted() const		{ return m_map.empty(); }
inline bool Selector::isUnfiltered() const	{ return m_lookup.empty(); }

inline unsigned Selector::size() const			{ return m_map.size(); }

inline void Selector::reset(Database const&)	{ reset(); }


inline
unsigned
Selector::map(unsigned index) const
{
	return index < m_sizeOfMap ? m_map[index] : index;
}


inline
unsigned
Selector::lookup(unsigned index) const
{
	return index < m_sizeOfList ? m_lookup[index] : index;
}


inline
unsigned
Selector::find(unsigned number) const
{
	return number < m_find.size() ? m_find[number] : number;
}


inline
void
Selector::update(unsigned newSize)
{
	if (newSize < m_sizeOfMap)
		reset();
}


#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

inline
Selector::Selector(Selector&& sel)
	:m_map(mstl::move(sel.m_map))
	,m_lookup(mstl::move(sel.m_lookup))
{
}


inline
Selector&
Selector::operator=(Selector&& sel)
{
	m_map = mstl::move(sel.m_map);
	m_lookup = mstl::move(sel.m_lookup);

	return *this;
}

#endif

} // namespace db

// vi:set ts=3 sw=3:
