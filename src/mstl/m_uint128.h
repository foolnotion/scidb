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

#ifndef _mstl_uint128_included
#define _mstl_uint128_included

#ifndef _mstl_uint128_t_included
# error "m_uint128.h should not be used, use m_uint128_t.h instead"
#endif

#include "m_types.h"

#if __WORDSIZE == 32 || !__GNUC_PREREQ(4,4)

namespace mstl {

class uint128
{
public:

	uint128();
	uint128(uint64_t hi, uint64_t lo);
	explicit uint128(uint64_t value);

	uint128& operator=(uint128 const& i);
	uint128& operator=(uint64_t value);

	bool operator!() const;
	operator bool () const;

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

	uint128 operator|(uint64_t i) const;
	uint128 operator&(uint64_t i) const;
	uint128 operator^(uint64_t i) const;

	uint128& operator|=(uint128 const& i);
	uint128& operator&=(uint128 const& i);
	uint128& operator^=(uint128 const& i);

	uint128& operator|=(uint64_t i);
	uint128& operator&=(uint64_t i);
	uint128& operator^=(uint64_t i);

	uint128 operator+(uint128 const& i) const;
	uint128 operator-(uint128 const& i) const;
	uint128 operator*(uint128 const& i) const;
	uint128 operator/(uint128 const& i) const;
	uint128 operator%(uint128 const& i) const;

	uint128 operator+(uint64_t i) const;
	uint128 operator-(uint64_t i) const;

	uint128& operator+=(uint128 const& i);
	uint128& operator-=(uint128 const& i);
	uint128& operator*=(uint128 const& i);
	uint128& operator/=(uint128 const& i);
	uint128& operator%=(uint128 const& i);

	uint128& operator+=(uint64_t i);
	uint128& operator-=(uint64_t i);

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

bool operator==(uint128 const& lhs, uint64_t rhs);
bool operator!=(uint128 const& lhs, uint64_t rhs);

bool operator==(unsigned lhs, uint128 const& rhs);
bool operator!=(unsigned lhs, uint128 const& rhs);

} // namespace mstl

#include "m_uint128.ipp"

#endif // _WORDSIZE
#endif // _mstl_uint128_included

// vi:set ts=3 sw=3:
