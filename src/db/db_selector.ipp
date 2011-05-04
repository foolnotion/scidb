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

namespace db {

inline unsigned Selector::size() const { return m_map.size(); }


inline
unsigned
Selector::map(unsigned index) const
{
	return index < m_map.size() ? m_map[index] : index;
}


inline
unsigned
Selector::lookup(unsigned index) const
{
	return index < m_list.size() ? m_list[index] : index;
}

} // namespace db

// vi:set ts=3 sw=3:
