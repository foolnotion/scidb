// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"
#include "m_bit_functions.h"
#include "m_limits.h"

namespace mstl {

inline
bitfield<uint128_t>::reference::reference(value_type& bits, value_type mask)
	:m_bits(bits)
	,m_mask(mask)
{
}


inline
bitfield<uint128_t>::reference&
bitfield<uint128_t>::reference::operator=(reference const& ref)
{
	return *this = bool(*this);
}


inline
bool
bitfield<uint128_t>::reference::operator==(reference const& ref) const
{
	return bool(*this) == bool(ref);
}


inline
bool
bitfield<uint128_t>::reference::operator<(reference const& ref) const
{
	return !bool(*this) && bool(ref);
}


inline
bitfield<uint128_t>::reference::operator bool () const
{
	return !!(m_bits & m_mask);
}


inline
bool
bitfield<uint128_t>::reference::operator!() const
{
	return !(m_bits & m_mask);
}


inline
bool
bitfield<uint128_t>::reference::operator~() const
{
	return !(m_bits & m_mask);
}


inline
bitfield<uint128_t>::reference&
bitfield<uint128_t>::reference::operator=(bool x)
{
	if (x)
		m_bits |= m_mask;
	else
		m_bits &= ~m_mask;

	return *this;
}


inline
bitfield<uint128_t>::reference&
bitfield<uint128_t>::reference::operator&=(bool x)
{
	if (!x)
		m_bits &= ~m_mask;

	return *this;
}


inline
bitfield<uint128_t>::reference&
bitfield<uint128_t>::reference::operator|=(bool x)
{
	if (x)
		m_bits |= m_mask;

	return *this;
}


inline
bitfield<uint128_t>::reference&
bitfield<uint128_t>::reference::operator^=(bool x)
{
	if (x)
		m_bits ^= m_mask;

	return *this;
}


inline
bitfield<uint128_t>::bitfield()
	:m_bits(0u)
{
	static_assert(numeric_limits<uint128_t>::is_integer, "template parameter is not integer");
	static_assert(numeric_limits<uint128_t>::is_unsigned, "template parameter is not unsigned integer");
}


inline
bitfield<uint128_t>::bitfield(bool flag)
	:m_bits(flag ? m_inverse : m_zero)
{
}


inline
bitfield<uint128_t>::bitfield(value_type n)
	:m_bits(n)
{
	static_assert(numeric_limits<uint128_t>::is_integer, "template parameter is not integer");
	static_assert(numeric_limits<uint128_t>::is_unsigned, "template parameter is not unsigned integer");
}


inline
bitfield<uint128_t>::bitfield(unsigned from, unsigned to)
{
	static_assert(numeric_limits<uint128_t>::is_integer, "template parameter is not integer");
	static_assert(numeric_limits<uint128_t>::is_unsigned, "template parameter is not unsigned integer");

	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	set(from, to);
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator=(value_type const& value)
{
	m_bits = value;
	return *this;
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator<<(unsigned n) const
{
	M_REQUIRE(n < nbits);
	return bitfield(m_bits << n);
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator>>(unsigned n) const
{
	M_REQUIRE(n < nbits);
	return bitfield(value_type(m_bits >> n));
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator<<=(unsigned n)
{
	M_REQUIRE(n < nbits);

	m_bits <<= n;
	return *this;
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator>>=(unsigned n)
{
	M_REQUIRE(n < nbits);

	m_bits >>= n;
	return *this;
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator&(bitfield const& bf) const
{
	return bitfield(m_bits & bf.m_bits);
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator|(bitfield const& bf) const
{
	return bitfield(m_bits | bf.m_bits);
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator^(bitfield const& bf) const
{
	return bitfield(m_bits ^ bf.m_bits);
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator-(bitfield const& bf) const
{
	return bitfield(m_bits & ~bf.m_bits);
}


inline
bitfield<uint128_t>
bitfield<uint128_t>::operator~() const
{
	return bitfield(~m_bits);
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator&=(bitfield const& bf)
{
	m_bits &= bf.m_bits;
	return *this;
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator|=(bitfield const& bf)
{
	m_bits |= bf.m_bits;
	return *this;
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator^=(bitfield const& bf)
{
	m_bits ^= bf.m_bits;
	return *this;
}


inline
bitfield<uint128_t>&
bitfield<uint128_t>::operator-=(bitfield const& bf)
{
	m_bits &= ~bf.m_bits;
	return *this;
}


inline
bitfield<uint128_t>::value_type
bitfield<uint128_t>::mask(unsigned n)
{
	M_REQUIRE(n < nbits);
	return m_one << n;
}


inline
bitfield<uint128_t>::value_type
bitfield<uint128_t>::mask(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	return value_type((m_inverse << from) & (m_inverse >> ((nbits - 1u) - to)));
}


inline
bitfield<uint128_t>::value_type
bitfield<uint128_t>::byte_mask(unsigned n)
{
	M_REQUIRE(n < nbits);
	return value_type(0xffu) << (n << 3);
}


inline
bitfield<uint128_t>::value_type
bitfield<uint128_t>::byte_mask(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	return mask(from ? (from << 3) - 1u : from, ((to + 1u) << 3) - 1u);
}


inline
bitfield<uint128_t>::reference
bitfield<uint128_t>::operator[](unsigned n)
{
	M_REQUIRE(n < nbits);
	return reference(m_bits, mask(n));
}


inline
bool
bitfield<uint128_t>::operator[](unsigned n) const
{
	M_REQUIRE(n < nbits);
	return m_bits & mask(n);
}


inline
bitfield<uint128_t>::value_type const&
bitfield<uint128_t>::value() const
{
	return m_bits;
}


inline
bitfield<uint128_t>::value_type&
bitfield<uint128_t>::value()
{
	return m_bits;
}


inline
void
bitfield<uint128_t>::set()
{
	m_bits = m_inverse;
}


inline
void
bitfield<uint128_t>::set(unsigned n)
{
	M_REQUIRE(n < nbits);
	m_bits |= mask(n);
}


inline
void
bitfield<uint128_t>::set(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	m_bits |= mask(from, to);
}


inline
bool
bitfield<uint128_t>::test_and_set(unsigned n)
{
	M_REQUIRE(n < nbits);

	value_type m = mask(n);

	if ((m_bits & m) != m_zero)
		return true;

	m_bits |= m;
	return false;
}


inline
void
bitfield<uint128_t>::reset()
{
	m_bits = 0u;
}


inline
void
bitfield<uint128_t>::reset(unsigned n)
{
	M_REQUIRE(n < nbits);
	m_bits &= ~mask(n);
}


inline
void
bitfield<uint128_t>::reset(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	m_bits &= ~mask(from, to);
}


inline
void
bitfield<uint128_t>::put(bool value)
{
	if (value)
		m_bits = m_inverse;
	else
		m_bits = m_zero;
}


inline
void
bitfield<uint128_t>::put(unsigned n, bool value)
{
	M_REQUIRE(n < nbits);
	value ? set(n) : reset(n);
}


inline
void
bitfield<uint128_t>::put(unsigned from, unsigned to, bool value)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	value ? set(from, to) : reset(from, to);
}


inline
void
bitfield<uint128_t>::flip()
{
	m_bits ^= m_inverse;
}


inline
void
bitfield<uint128_t>::flip(unsigned n)
{
	M_REQUIRE(n < nbits);
	m_bits ^= mask(n);
}


inline
void
bitfield<uint128_t>::flip(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	m_bits ^= mask(from, to);
}


inline
unsigned
bitfield<uint128_t>::word_index(unsigned n)
{
	return n & (nbits - 1u);
}


inline
bool
bitfield<uint128_t>::test(unsigned n) const
{
	M_REQUIRE(n < nbits);
	return operator[](n);
}


inline
bool
bitfield<uint128_t>::none() const
{
	return !m_bits;
}


inline
bool
bitfield<uint128_t>::any() const
{
	return m_bits != uint64_t(0u);
}


inline
bool
bitfield<uint128_t>::complete() const
{
	return m_bits == m_inverse;
}


inline
bool
bitfield<uint128_t>::contains(bitfield const& bf) const
{
	return bf.m_bits == (m_bits & bf.m_bits);
}


inline
bool
bitfield<uint128_t>::disjunctive(bitfield const& bf) const
{
	return !(bf.m_bits & m_bits);
}


inline
unsigned
bitfield<uint128_t>::count() const
{
	return bf::count_bits(m_bits);
}


inline
unsigned
bitfield<uint128_t>::count(unsigned start, unsigned end) const
{
	M_REQUIRE(end < nbits);
	M_REQUIRE(start <= end);

	return bf::count_bits(m_bits & mask(start, end));
}


inline
unsigned
bitfield<uint128_t>::find_last() const
{
	return m_bits == uint64_t(0u) ? npos : bf::msb_index(m_bits);
}


inline
unsigned
bitfield<uint128_t>::find_first() const
{
	return m_bits == uint64_t(0u) ? npos : bf::lsb_index(m_bits);
}


inline
unsigned
bitfield<uint128_t>::find_next(unsigned prev) const
{
	M_REQUIRE(prev < nbits);
	return bitfield(value_type(m_bits & ~mask(0u, prev))).find_first();
}


inline
unsigned
bitfield<uint128_t>::find_prev(unsigned next) const
{
	M_REQUIRE(next < nbits);
	return bitfield(value_type(m_bits & ~mask(next, nbits - 1u))).find_last();
}


inline
unsigned
bitfield<uint128_t>::find_last_not() const
{
	return m_bits == m_inverse ? npos : bf::msb_index(~m_bits);
}


inline
unsigned
bitfield<uint128_t>::find_first_not() const
{
	return m_bits == m_inverse ? npos : bf::lsb_index(~m_bits);
}


inline
unsigned
bitfield<uint128_t>::find_next_not(unsigned prev) const
{
	M_REQUIRE(prev < nbits);
	return bitfield(value_type(m_bits | mask(0u, prev))).find_first_not();
}


inline
unsigned
bitfield<uint128_t>::find_prev_not(unsigned next) const
{
	M_REQUIRE(next < nbits);
	return bitfield(value_type(m_bits | mask(next, nbits - 1u))).find_last_not();
}


inline
unsigned
bitfield<uint128_t>::index(unsigned nth) const
{
	M_REQUIRE(nth <= count());

	unsigned n = find_first();

	while (nth--)
		n = find_next(n);

	return n;
}


inline
unsigned
bitfield<uint128_t>::rindex(unsigned nth) const
{
	M_REQUIRE(nth <= count());

	unsigned n = find_last();

	while (nth--)
		n = find_prev(n);

	return n;
}


inline
void
bitfield<uint128_t>::increase(unsigned from, unsigned to)
{
	M_REQUIRE(to < nbits);
	M_REQUIRE(from <= to);

	value_type m = mask(from, to);
	value_type v = m_bits & m;

	if (v == m_zero)
		m_bits |= value_type(1u) << from;
	else
		m_bits |= (v << 1u) & m;
}


inline
bool
operator==(bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs)
{
	return lhs.value() == rhs.value();
}


inline
bool
operator==(uint128_t lhs, bitfield<uint128_t> const& rhs)
{
	return lhs == rhs.value();
}


inline
bool
operator==(bitfield<uint128_t> const& lhs, uint128_t rhs)
{
	return lhs.value() == rhs;
}


inline
bool
operator!=(bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs)
{
	return lhs.value() != rhs.value();
}


inline
bool
operator!=(uint128_t lhs, bitfield<uint128_t> const& rhs)
{
	return lhs != rhs.value();
}


inline
bool
operator!=(bitfield<uint128_t> const& lhs, uint128_t rhs)
{
	return lhs.value() != rhs;
}


inline
bool
operator<(bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs)
{
	return lhs.value() < rhs.value();
}


inline
bool
operator<(uint128_t lhs, bitfield<uint128_t> const& rhs)
{
	return lhs < rhs.value();
}


inline
bool
operator<(bitfield<uint128_t> const& lhs, uint128_t rhs)
{
	return lhs.value() < rhs;
}

} // namespace mstl

// vi:set ts=3 sw=3:
