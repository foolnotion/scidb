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

#ifndef _mstl_static_check_included
#define _mstl_static_check_included

namespace mstl {
namespace bits {

template <bool> struct compile_time_checker;
template <> struct compile_time_checker<true> {};

} // namespace bits
} // namespace mstl

#if (__GNUC__ == 0 || __GNUC__ >= 3)

# define M_STATIC_CHECK(expr, msg) \
	{mstl::bits::compile_time_checker<((expr) != 0)> COMPILE_TIME_ERROR_##msg __attribute__((unused));}

#else

# error "compiler is too old"

#endif

#endif // _mstl_static_check_included

// vi:set ts=3 sw=3:
