// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

namespace util {

inline
unsigned
BitStream::bitsLeft() const
{
	return (m_size << 3) + m_bitsLeft;
}


inline
void
BitStream::fetchBits(unsigned n)
{
	if (m_bitsLeft < n)
		getBits();
}


inline
BitStream::Byte
BitStream::peek(unsigned n)
{
	M_REQUIRE(n <= U_BITS_OF(Byte));
	M_REQUIRE(n <= bitsLeft());

	fetchBits(n);

	return (m_bits >> (m_bitsLeft - n)) & ((1 << n) - 1);
}


inline
BitStream::Byte
BitStream::next(unsigned n)
{
	M_REQUIRE(n <= U_BITS_OF(Byte));
	M_REQUIRE(n <= bitsLeft());

	fetchBits(n);

	return (m_bits >> (m_bitsLeft -= n)) & ((1 << n) - 1);
}

} // namespace util

// vi:set ts=3 sw=3:
