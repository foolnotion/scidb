// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_uint128.h"
#include "m_assert.h"

using namespace mstl;


template <typename T>
static void
divide(const T &numerator, const T &denominator, T &quotient, T &remainder)
{
	static int const Bits = sizeof(T)*8;

	M_ASSERT(denominator != 0);

	T n		= numerator;
	T d		= denominator;
	T x		= 1u;
	T result = 0u;


	while (n >= d && ((d >> (Bits - 1)) & 1u) == 0)
	{
		x <<= 1u;
		d <<= 1u;
	}

	while (x != 0)
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
	if ((rhs.m_hi | rhs.m_lo) == 0)
	{
		m_hi = 0;
		m_lo = 0;
	}
	else if (rhs.m_hi || rhs.m_lo != 1)
	{
		uint128 a(*this);
		uint128 t = rhs;

		m_lo = 0;
		m_hi = 0;

		for (unsigned i = 0; i < 64u; ++i)
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
	M_REQUIRE(rhs != 0);

	uint128 remainder;
	divide(*this, rhs, *this, remainder);
	return *this;
}


uint128&
uint128::operator%=(uint128 const& rhs)
{
	M_REQUIRE(rhs != 0);

	uint128 quotient;
	divide(*this, rhs, quotient, *this);
	return *this;
}


uint128&
uint128::operator<<=(unsigned n)
{
	if (n >= 64)
	{
		m_hi = 0;
		m_lo = 0;
	}
	else
	{
		if (n >= 32)
		{
			n -= 32;
			m_hi = m_lo;
			m_lo = 0;
		}

		if (n != 0)
		{
			m_hi <<= n;

			uint64_t const mask(~(uint64_t(-1) >> n));

			m_hi |= (m_lo & mask) >> (32 - n);
			m_lo <<= n;
		}
	}

	return *this;
}


uint128&
uint128::operator>>=(unsigned n)
{
	if (n >= 64)
	{
		m_hi = 0;
		m_lo = 0;
	}
	else
	{
		if (n >= 32)
		{
			n -= 32;
			m_lo = m_hi;
			m_hi = 0;
		}

		if (n != 0)
		{
			m_lo >>= n;

			const uint64_t mask(~(uint64_t(-1) << n));

			m_lo |= (m_hi & mask) << (32 - n);
			m_hi >>= n;
		}
	}

	return *this;
}

// vi:set ts=3 sw=3:
