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

namespace mstl {

inline uint128::uint128() :m_hi(0), m_lo(0) {}
inline uint128::uint128(uint64_t hi, uint64_t lo) :m_hi(hi), m_lo(lo) {}
inline uint128::uint128(uint64_t value) : m_hi(0), m_lo(value) {}
inline uint128::uint128(uint32_t value) : m_hi(0), m_lo(value) {}

inline bool uint128::operator!() const { return m_hi == 0 && m_lo == 0; }

inline uint64_t uint128::lo() const { return m_lo; }
inline uint64_t uint128::hi() const { return m_hi; }

inline uint128 uint128::operator~() const { return uint128(~m_hi, ~m_lo); }
inline uint128 uint128::operator-() const { return ~uint128(*this) + 1u; }

inline uint128& uint128::operator++() { if (++m_lo == 0) ++m_hi; return *this; }
inline uint128& uint128::operator--() { if (m_lo-- == 0) --m_hi; return *this; }

inline uint128 uint128::operator>>(unsigned n) const { return uint128(*this) >>= n; }
inline uint128 uint128::operator<<(unsigned n) const { return uint128(*this) <<= n; }


inline
uint128&
uint128::operator|=(uint128 const& i)
{
	m_hi |= i.m_hi;
	m_lo |= i.m_lo;
	return *this;
}


inline
uint128&
uint128::operator&=(uint128 const& i)
{
	m_hi &= i.m_hi;
	m_lo &= i.m_lo;
	return *this;
}


inline
uint128&
uint128::operator^=(uint128 const& i)
{
	m_hi ^= i.m_hi;
	m_lo ^= i.m_lo;
	return *this;
}


inline uint128 uint128::operator|(uint128 const& i) const { return uint128(*this) |= i; }
inline uint128 uint128::operator&(uint128 const& i) const { return uint128(*this) &= i; }
inline uint128 uint128::operator^(uint128 const& i) const { return uint128(*this) ^= i; }


inline
uint128
uint128::operator++(int)
{
	uint128 t(*this);
	if (++m_lo == 0) ++m_hi;
	return t;
}


inline
uint128
uint128::operator--(int)
{
	uint128 t(*this);
	if (m_lo-- == 0) --m_hi;
	return t;
}


inline
uint128&
uint128::operator+=(uint128 const& i)
{
	uint64_t lo = m_lo;

	m_hi += i.m_hi;

	if ((m_lo += i.m_lo) < lo)
		++m_hi;

	return *this;
}


inline
uint128&
uint128::operator-=(uint128 const& i)
{
	uint64_t lo = m_lo;

	m_hi -= i.m_hi;

	if ((m_lo -= i.m_lo) > lo)
		--m_hi;

	return *this;
}


inline uint128 uint128::operator+(uint128 const& i) const { return uint128(*this) += i; }
inline uint128 uint128::operator-(uint128 const& i) const { return uint128(*this) -= i; }
inline uint128 uint128::operator*(uint128 const& i) const { return uint128(*this) *= i; }
inline uint128 uint128::operator/(uint128 const& i) const { return uint128(*this) /= i; }
inline uint128 uint128::operator%(uint128 const& i) const { return uint128(*this) &= i; }


inline
bool
operator==(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.lo() == rhs.lo() && lhs.hi() == rhs.hi();
}


inline
bool
operator!=(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.lo() != rhs.lo() || lhs.hi() != rhs.hi();
}


inline
bool
operator<=(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.hi() < rhs.hi() || (lhs.hi() == rhs.hi() && lhs.lo() <= rhs.lo());
}


inline
bool
operator>=(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.hi() > rhs.hi() || (lhs.hi() == rhs.hi() && lhs.lo() >= rhs.lo());
}


inline
bool
operator<(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.hi() == rhs.hi() ? lhs.lo() < rhs.lo() : lhs.hi() < rhs.hi();
}


inline
bool
operator>(uint128 const& lhs, uint128 const& rhs)
{
	return lhs.hi() == rhs.hi() ? lhs.lo() > rhs.lo() : lhs.hi() > rhs.hi();
}


inline bool operator==(uint128 const& lhs, unsigned rhs) { return lhs.hi() == 0 && lhs.lo() == rhs; }
inline bool operator!=(uint128 const& lhs, unsigned rhs) { return lhs.hi() != 0 || lhs.lo() != rhs; }

inline bool operator==(unsigned lhs, uint128 const& rhs) { return rhs.hi() == 0 && rhs.lo() == lhs; }
inline bool operator!=(unsigned lhs, uint128 const& rhs) { return rhs.hi() != 0 || rhs.lo() != lhs; }

} // namespace mstl

// vi:set ts=3 sw=3:
