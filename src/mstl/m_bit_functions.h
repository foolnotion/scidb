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

#ifndef _mstl_bit_functions_included
#define _mstl_bit_functions_included

namespace mstl {
namespace bf {

template <typename T> unsigned count_bits(T x);
template <typename T> unsigned msb_index(T x);
template <typename T> unsigned lsb_index(T x);

template <typename T> constexpr bool more_than_one(T x);
template <typename T> constexpr bool at_most_one(T x);
template <typename T> constexpr bool exactly_one(T x);

template <typename T> T reverse(T x);
template <typename T> T rotate_left(T x, unsigned shift);
template <typename T> T rotate_right(T x, unsigned shift);

} // namespace bf
} // namespace mstl

#include "m_bit_functions.ipp"

#endif // _mstl_bit_functions_included

// vi:set ts=3 sw=3:
