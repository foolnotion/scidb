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

#include "m_limits.h"
#include "m_bit_functions.h"
#include "m_static_check.h"

namespace mstl {
namespace bits {

template <size_t N> struct signed_arithmetic;

template <>
struct signed_arithmetic<1>
{
	template <typename T> inline static T div2(T x) { return x/2; }
	template <typename T> inline static T div4(T x) { return x/4; }
	template <typename T> inline static T mod2(T x) { return x%2; }
	template <typename T> inline static T mod4(T x) { return x%4; }
	template <typename T> inline static T mul2(T x) { return x*2; }
	template <typename T> inline static T mul4(T x) { return x*4; }

	template <typename T>
	inline
	static T
	abs(T x)
	{
#ifdef WITHOUT_BRANCHING
		return a - ((a + a) & (a >> (sizeof(T)*8 - 1)));
#else
		return x < 0 ? -x : x;
#endif
	}
};

template <>
struct signed_arithmetic<0>
{
	template <typename T> inline static T div2(T x) { return x >> 1; }
	template <typename T> inline static T div4(T x) { return x >> 2; }
	template <typename T> inline static T mod2(T x) { return x & 1; }
	template <typename T> inline static T mod4(T x) { return x & 3; }
	template <typename T> inline static T mul2(T x) { return x << 1; }
	template <typename T> inline static T mul4(T x) { return x << 2; }
	template <typename T> inline static T abs(T x)  { return x; }
};

} // namespace bits


template <typename T>
inline
T
min(T a, T b)
{
#ifdef WITHOUT_BRANCHING
	b -= a;
	return a = b & (b >> (sizeof(T)*8 - 1));
#else
	return a < b ? a : b;
#endif
}


template <typename T>
inline
T
max(T a, T b)
{
#ifdef WITHOUT_BRANCHING
	b = a - b;
	return a - b & (b >> (sizeof(T)*8 - 1));
#else
	return a < b ? b : a;
#endif
}


template <typename T>
inline
T
min(T a, T b, T c)
{
	return min(a, min(b, c));
}


template <typename T>
inline
T
max(T a, T b, T c)
{
	return max(a, max(b, c));
}


template <typename T> inline T sqr(T x) { return x*x; }

template <typename T> inline void swap(T& a, T& b)	{ T x = a; a = b; b = x; }

template <typename T> inline T advance(T i, size_t offset)			{ return i + offset; }
template <typename T> inline ptrdiff_t distance(T first, T last)	{ return last - first; }


inline
void*
advance(void* i, size_t offset)
{
	return static_cast<char*>(i) + offset;
}


template <>
inline
ptrdiff_t
distance(void* first, void* last)
{
	return static_cast<char*>(last) - static_cast<char*>(first);
}


template <typename T>
inline
T
align(T n, size_t grain)
{
    T r = n % grain;
    return r ? n + (grain - r) : n;
}


template <typename T>
inline
bool
is_odd(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mod2(x) != 0;
}


template <typename T>
inline
bool
is_even(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mod2(x) == 0;
}


template <typename T>
inline
bool
is_pow_2(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return x && !(x & (x - 1));
}


template <typename T>
inline
bool
is_not_pow_2(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return x & (x - 1);
}


template <typename T>
inline
T
abs(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::abs(x);
}


template <typename T>
inline
T
signum(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return (0 < x) - (x < 0);
}


template <typename T>
inline
T
div2(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::div2(x);
}


template <typename T>
inline
T
div4(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integer);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::div4(x);
}


template <typename T>
inline
T
mod2(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mod2(x);
}


template <typename T>
inline
T
mod4(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integer);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mod4(x);
}


template <typename T>
inline
T
mul2(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integral);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mul2(x);
}


template <typename T>
inline
T
mul4(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integer);
	return bits::signed_arithmetic<numeric_limits<T>::is_signed>::mul4(x);
}


template <typename T>
inline
unsigned
log2_floor(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integer);
	M_REQUIRE(x > 0);

	return bf::msb_index(x);
}


template <typename T>
inline
unsigned
log2_ceil(T x)
{
	M_STATIC_CHECK(numeric_limits<T>::is_integer, Template_Parameter_Not_Integer);
	M_REQUIRE(x > 0);

	T n = bf::msb_index(x);
	return is_not_pow_2(x) ? n + 1 : n;
}


template <typename T>
inline
bool
is_between(T x, T a, T b)
{
	return a <= x && x <= b;
}

} // namespace mstl

// vi:set ts=3 sw=3:
