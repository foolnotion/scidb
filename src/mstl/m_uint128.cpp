// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "m_uint128_t.h"

#if __WORDSIZE == 32 || !__GNUC_PREREQ(4, 4)

#include "m_assert.h"

using namespace mstl;


template <typename T>
static void
divide(const T &numerator, const T &denominator, T &quotient, T &remainder)
{
	static int const Bits = sizeof(T)*8;

	M_ASSERT(denominator != uint64_t(0));

	T n		= numerator;
	T d		= denominator;
	T x		= T(1u);
	T result = T(0u);


	while (n >= d && ((d >> (Bits - 1u)) & uint64_t(1)) == uint64_t(0))
	{
		x <<= 1u;
		d <<= 1u;
	}

	while (x != uint64_t(0))
	{
		if (n >= d)
		{
			n -= d;
			result |= x;
		}

		x >>= 1u;
		d >>= 1u;
	}

	quotient = result;
	remainder = n;
}


uint128&
uint128::operator*=(uint128 const& rhs)
{
	if ((rhs.m_hi | rhs.m_lo) == 0u)
	{
		m_hi = 0u;
		m_lo = 0u;
	}
	else if (rhs.m_hi || rhs.m_lo != 1u)
	{
		uint128 a(*this);
		uint128 t = rhs;

		m_lo = 0u;
		m_hi = 0u;

		for (unsigned i = 0u; i < 64u; ++i)
		{
			if (t.m_lo & 1u)
				*this += (a << i);

			t >>= 1;
		}
	}

	return *this;
}


uint128&
uint128::operator/=(uint128 const& rhs)
{
	M_REQUIRE(rhs != uint64_t(0));

	uint128 remainder;
	divide(*this, rhs, *this, remainder);
	return *this;
}


uint128&
uint128::operator%=(uint128 const& rhs)
{
	M_REQUIRE(rhs != uint64_t(0));

	uint128 quotient;
	divide(*this, rhs, quotient, *this);
	return *this;
}


uint128&
uint128::operator<<=(unsigned n)
{
	if (n >= 128u)
	{
		m_hi = 0u;
		m_lo = 0;
	}
	else
	{
		if (n >= 64u)
		{
			n -= 64u;
			m_hi = m_lo;
			m_lo = 0u;
		}

		if (n != 0u)
		{
			m_hi <<= n;

			uint64_t const mask(~(uint64_t(-1) >> n));

			m_hi |= (m_lo & mask) >> (64u - n);
			m_lo <<= n;
		}
	}

	return *this;
}


uint128&
uint128::operator>>=(unsigned n)
{
	if (n >= 128u)
	{
		m_hi = 0u;
		m_lo = 0u;
	}
	else
	{
		if (n >= 64u)
		{
			n -= 64u;
			m_lo = m_hi;
			m_hi = 0u;
		}

		if (n != 0u)
		{
			m_lo >>= n;

			const uint64_t mask(~(uint64_t(-1) << n));

			m_lo |= (m_hi & mask) << (64u - n);
			m_hi >>= n;
		}
	}

	return *this;
}

#endif // _WORDSIZE == 32

// vi:set ts=3 sw=3:
