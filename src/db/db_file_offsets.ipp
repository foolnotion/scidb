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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline
bool
FileOffsets::Offset::isGameIndex() const
{
	return m_variant != variant::NumberOfVariants;
}


inline
unsigned
FileOffsets::Offset::offset() const
{
	return m_offset;
}


inline
unsigned
FileOffsets::Offset::gameIndex() const
{
	M_REQUIRE(isGameIndex());
	return m_index;
}


inline
unsigned
FileOffsets::Offset::variant() const
{
	M_REQUIRE(isGameIndex());
	return m_variant;
}


inline
FileOffsets::Offset::Offset(unsigned offset)
	:m_offset(offset)
	,m_index(0)
	,m_variant(variant::NumberOfVariants)
{
}


inline
FileOffsets::Offset::Offset(unsigned offset, unsigned variant, unsigned gameIndex)
	:m_offset(offset)
	,m_index(gameIndex)
	,m_variant(variant)
{
	M_REQUIRE(variant < variant::NumberOfVariants);
	M_REQUIRE(gameIndex < (1u << 24));
}


inline
unsigned
FileOffsets::size() const
{
	M_ASSERT(!m_offsets.empty());
	return m_offsets.size() - 1;
}


inline
FileOffsets::Offset const&
FileOffsets::get(unsigned index) const
{
	M_REQUIRE(index <= size());
	return m_offsets[index];
}


inline
void
FileOffsets::append(unsigned offset)
{
	m_offsets.push_back(Offset(offset));
}


inline
void
FileOffsets::append(unsigned offset, unsigned variant, unsigned gameIndex)
{
	m_offsets.push_back(Offset(offset, variant, gameIndex));
}


inline
void
FileOffsets::reserve(unsigned n)
{
	m_offsets.reserve(n);
}

} // namespace db

// vi:set ts=3 sw=3:
