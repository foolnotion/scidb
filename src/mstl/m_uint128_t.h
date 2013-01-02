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

#ifndef _mstl_uint128_t_included
#define _mstl_uint128_t_included

#include "m_types.h"

#if __WORDSIZE == 64

# if __GNUC_PREREQ(4,6)

typedef __uint128_t uint128_t;

# elif __GNUC_PREREQ(4,4)

typedef unsigned int uint128_t __attribute__ ((__mode__(TI)));

# else // !__GNUC_PREREQ(4,4)

# include "m_uint128.h"
typedef mstl::uint128 uint128_t;

# endif

#else // __WORDSIZE == 32

# include "m_uint128.h"
typedef mstl::uint128 uint128_t;

#endif

namespace mstl {

template <typename T> struct numeric_limits;

template <>
struct numeric_limits<uint128_t>
{
	inline static uint128_t min() { return uint128_t(0u); }
	inline static uint128_t max() { return uint128_t(~0u); }

	static bool const is_signed	= false;	///< True if the type is signed.
	static bool const is_unsigned	= true;	///< True if the type is unsigned.
	static bool const is_integer	= true;	///< True if stores an exact value.
	static bool const is_integral	= true;	///< True if fixed size and cast-copyable.
};

// performance tuning
template <typename T> struct is_integral;
template <typename T> struct is_scalar;
template <typename T> struct is_pod;

template <> struct is_integral<uint128_t>	{ enum { value = 1 }; };
template <> struct is_scalar<uint128_t>	{ enum { value = 1 }; };
template <> struct is_pod<uint128_t>		{ enum { value = 1 }; };

} // namespace mstl

#endif // _mstl_uint128_t_included

// vi:set ts=3 sw=3:
