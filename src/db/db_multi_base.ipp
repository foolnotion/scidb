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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline bool MultiBase::isSingleBase() const	{ return m_singleBase; }
inline Database* MultiBase::database()			{ return m_leader; }


inline
bool
MultiBase::isEmpty(variant::Type variant) const
{
	M_REQUIRE(variant::isMainVariant(variant));
	return isEmpty(variant::toIndex(variant));
}


inline
bool
MultiBase::exists(unsigned variantIndex) const
{
	return m_bases[variantIndex];
}


inline
bool
MultiBase::exists(variant::Type variant) const
{
	M_REQUIRE(variant::isMainVariant(variant));
	return exists(variant::toIndex(variant));
}


inline
Database*
MultiBase::database(variant::Type variant)
{
	M_REQUIRE(variant::isMainVariant(variant));
	M_REQUIRE(exists(variant));

	return m_bases[variant::toIndex(variant)];
}


inline
Database*
MultiBase::database(unsigned variantIndex)
{
	M_REQUIRE(exists(variantIndex));
	return m_bases[variantIndex];
}

} // namespace db

// vi:set ts=3 sw=3:
