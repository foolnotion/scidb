// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "m_assert.h"

namespace mstl {

inline unsigned equiv_classes::size() const { return m_list.size(); }


inline
unsigned
equiv_classes::ngroups() const
{
	if (m_ngroups > size())
		prepare_groups();

	return m_ngroups;
}


inline
unsigned
equiv_classes::count(unsigned group) const
{
	M_REQUIRE(group < ngroups());

	if (m_ngroups > size())
		prepare_groups();

	return m_dimension[group];
}


inline
unsigned
equiv_classes::get_group(unsigned a) const
{
	M_REQUIRE(a < size());

	if (m_ngroups > size())
		prepare_groups();

	return m_lookup[a];
}

} // namespace mstl

// vi:set ts=3 sw=3:
