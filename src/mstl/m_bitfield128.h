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

#ifndef _mstl_bitfield128_included
#define _mstl_bitfield128_included

#ifndef _mstl_bitfield_included
# error "m_bitfield128.h should not be used, use m_bitfield.h instead"
#endif

#include "m_types.h"

# if __WORDSIZE == 32 || !__GNUC_PREREQ(4,4)

#include "m_uint128_t.h"

namespace mstl {

template <typename T> class bitfield;

template <>
class bitfield<uint128_t>
{
public:

	// types
	typedef uint128_t value_type;

	// nested classes
	class reference
	{
	public:

		// structors
		reference(value_type& bits, value_type mask);

		// assignment
		reference& operator=(reference const& ref);

		// comparators
		bool operator==(reference const& ref) const;
		bool operator< (reference const& ref) const;

		// casters
		operator bool() const;

		// tester
		bool operator!() const;
		bool operator~() const;

		// assignment
		reference& operator=(bool x);

		// operations
		reference& operator&=(bool x);
		reference& operator|=(bool x);
		reference& operator^=(bool x);

	private:

		// attributes
		value_type&	m_bits;
		value_type	m_mask;
	};

	// constants
	static unsigned const nbytes	= sizeof(value_type);
	static unsigned const nbits	= nbytes*8;
	static unsigned const npos		= unsigned(-1);

	// structors
	bitfield();
	explicit bitfield(bool flag);
	explicit bitfield(value_type n);
	bitfield(unsigned from, unsigned to);

	// assignment
	bitfield& operator=(value_type const& value);

	// operators
	bitfield operator&(bitfield const& bf) const;
	bitfield operator|(bitfield const& bf) const;
	bitfield operator^(bitfield const& bf) const;
	bitfield operator-(bitfield const& bf) const;
	bitfield operator<<(unsigned n) const;
	bitfield operator>>(unsigned n) const;
	bitfield operator~() const;

	bitfield& operator&=(bitfield const& bf);
	bitfield& operator|=(bitfield const& bf);
	bitfield& operator^=(bitfield const& bf);
	bitfield& operator-=(bitfield const& bf);
	bitfield& operator<<=(unsigned n);
	bitfield& operator>>=(unsigned n);

	// queries
	bool test(unsigned n) const;

	bool none() const;
	bool any() const;
	bool complete() const;
	bool contains(bitfield const& bf) const;
	bool disjunctive(bitfield const& bf) const;

	// accessors
	unsigned count() const;
	unsigned count(unsigned start, unsigned end) const;
	unsigned index(unsigned nth) const;
	unsigned rindex(unsigned nth) const;

	unsigned find_last() const;
	unsigned find_prev(unsigned next) const;
	unsigned find_first() const;
	unsigned find_next(unsigned prev) const;
	unsigned find_last_not() const;
	unsigned find_prev_not(unsigned next) const;
	unsigned find_first_not() const;
	unsigned find_next_not(unsigned prev) const;

	// accessors
	reference operator[](unsigned n);
	bool operator[](unsigned n) const;

	// serialization
	value_type const& value() const;
	value_type& value();

	// modifiers
	bool test_and_set(unsigned n);

	void set();
	void set(unsigned n);
	void set(unsigned from, unsigned to);

	void reset();
	void reset(unsigned n);
	void reset(unsigned from, unsigned to);

	void put(bool value);
	void put(unsigned n, bool value);
	void put(unsigned from, unsigned to, bool value);

	void flip();
	void flip(unsigned n);
	void flip(unsigned from, unsigned to);

	void increase(unsigned from, unsigned to);

	// helpers
	static unsigned word_index(unsigned n);

	static value_type mask(unsigned n);
	static value_type mask(unsigned from, unsigned to);
	static value_type byte_mask(unsigned n);
	static value_type byte_mask(unsigned from, unsigned to);

private:

	// attributes
	value_type m_bits;

	static const value_type m_zero;
	static const value_type m_one;
	static const value_type m_inverse;
};

// comparators
template <class uint128_t>
bool operator==(bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs);
template <class uint128_t>
bool operator!=(bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs);
template <class uint128_t>
bool operator< (bitfield<uint128_t> const& lhs, bitfield<uint128_t> const& rhs);

template <class uint128_t> bool operator==(uint128_t lhs, bitfield<uint128_t> const& rhs);
template <class uint128_t> bool operator!=(uint128_t lhs, bitfield<uint128_t> const& rhs);
template <class uint128_t> bool operator< (uint128_t lhs, bitfield<uint128_t> const& rhs);
template <class uint128_t> bool operator==(bitfield<uint128_t> const& lhs, uint128_t rhs);
template <class uint128_t> bool operator!=(bitfield<uint128_t> const& lhs, uint128_t rhs);
template <class uint128_t> bool operator< (bitfield<uint128_t> const& lhs, uint128_t rhs);

// performance tuning
template <typename T> struct is_scalar;
template <typename T> struct is_pod;

template <> struct is_scalar< ::mstl::bitfield<uint128_t> >	{ enum { value = 1 }; };
template <> struct is_pod< ::mstl::bitfield<uint128_t> >		{ enum { value = 1 }; };

} // namespace mstl

#include "m_bitfield128.ipp"

#endif // __WORDSIZE == 32
#endif // _mstl_bitfield128_included

// vi:set ts=3 sw=3:
