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

#ifndef _mstl_uint128_included
#define _mstl_uint128_included

#include "m_types.h"

#if __WORDSIZE == 32

namespace mstl {

class uint128
{
public:

	uint128();
	uint128(uint64_t hi, uint64_t lo);
	uint128(uint64_t value);
	uint128(uint32_t value);

	bool operator!() const;

	uint64_t lo() const;
	uint64_t hi() const;

	uint128 operator-() const;
	uint128 operator~() const;

	uint128& operator++();
	uint128  operator++(int);
	uint128& operator--();
	uint128  operator--(int);

	uint128 operator|(uint128 const& i) const;
	uint128 operator&(uint128 const& i) const;
	uint128 operator^(uint128 const& i) const;

	uint128& operator|=(uint128 const& i);
	uint128& operator&=(uint128 const& i);
	uint128& operator^=(uint128 const& i);

	uint128 operator+(uint128 const& i) const;
	uint128 operator-(uint128 const& i) const;
	uint128 operator*(uint128 const& i) const;
	uint128 operator/(uint128 const& i) const;
	uint128 operator%(uint128 const& i) const;

	uint128& operator+=(uint128 const& i);
	uint128& operator-=(uint128 const& i);
	uint128& operator*=(uint128 const& i);
	uint128& operator/=(uint128 const& i);
	uint128& operator%=(uint128 const& i);

	uint128 operator>>(unsigned n) const;
	uint128 operator<<(unsigned n) const;

	uint128& operator>>=(unsigned n);
	uint128& operator<<=(unsigned n);

private:

	uint64_t m_hi;
	uint64_t m_lo;
};

bool operator==(uint128 const& lhs, uint128 const& rhs);
bool operator!=(uint128 const& lhs, uint128 const& rhs);
bool operator<=(uint128 const& lhs, uint128 const& rhs);
bool operator>=(uint128 const& lhs, uint128 const& rhs);
bool operator< (uint128 const& lhs, uint128 const& rhs);
bool operator> (uint128 const& lhs, uint128 const& rhs);

bool operator==(uint128 const& lhs, unsigned rhs);
bool operator!=(uint128 const& lhs, unsigned rhs);

bool operator==(unsigned lhs, uint128 const& rhs);
bool operator!=(unsigned lhs, uint128 const& rhs);

typedef uint128 uint128_t;

template <typename T> struct numeric_limits;

template <>
struct numeric_limits<uint128_t>
{
	inline static uint128_t min() { return 0u; }
	inline static uint128_t max() { return uint128_t(uint64_t(~0u), uint64_t(~0u)); }

	static bool const is_signed	= false;
	static bool const is_unsigned	= false;
	static bool const is_integer	= true;
	static bool const is_integral	= true;
};

} // namespace mstl

#include "m_uint128.ipp"

#endif // _WORDSIZE == 32
#endif // _mstl_uint128_included

// vi:set ts=3 sw=3:
