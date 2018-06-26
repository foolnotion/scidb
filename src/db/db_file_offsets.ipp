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
bool
FileOffsets::Offset::isNumberOfSkippedGames() const
{
	return m_variant == variant::NumberOfVariants;
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
FileOffsets::Offset::skipped() const
{
	M_REQUIRE(isNumberOfSkippedGames());
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
unsigned
FileOffsets::Offset::gameCount() const
{
	return isGameIndex() ? 1u : skipped();
}


inline
FileOffsets::Offset::Offset(unsigned offset, unsigned skipped)
	:m_offset(offset)
	,m_index(skipped)
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
FileOffsets::FileOffsets()
	:m_countSkipped(0)
{
}


inline
bool
FileOffsets::isEmpty() const
{
	return m_offsets.empty();
}


inline
unsigned
FileOffsets::size() const
{
	M_ASSERT(isEmpty() || m_offsets.size() > 0);
	return isEmpty() ? 0 : m_offsets.size() - 1;
}


inline
unsigned
FileOffsets::countGames() const
{
	return size() + m_countSkipped;
}


inline
FileOffsets::Offset const&
FileOffsets::get(unsigned index) const
{
	M_REQUIRE(index < size());
	return m_offsets[index];
}


inline
void
FileOffsets::append(unsigned offset, unsigned skipped)
{
	m_offsets.push_back(Offset(offset, skipped));
}


inline
void
FileOffsets::append(unsigned offset, unsigned variant, unsigned gameIndex)
{
	m_offsets.push_back(Offset(offset, variant, gameIndex));
}


inline
void
FileOffsets::append(unsigned offset, Offset const& src)
{
	if (src.isGameIndex())
		append(offset, src.variant(), src.gameIndex());
	else
		append(offset, src.skipped());
}


inline
void
FileOffsets::setSkipped(unsigned count)
{
	M_REQUIRE(!isEmpty());
	M_REQUIRE(get(size()).isNumberOfSkippedGames());
	M_REQUIRE(count > 0);

	m_offsets.back().m_index = count;
	m_countSkipped += count - 1;
}


inline
void
FileOffsets::reserve(unsigned n)
{
	m_offsets.reserve(n + 1);
}

} // namespace db

// vi:set ts=3 sw=3:
