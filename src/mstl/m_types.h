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

#ifndef _mstl_types_included
#define _mstl_types_included

#include <stdint.h>
#include <stddef.h>

#ifndef __WIN32__
# if defined(_WIN32) || defined(WIN32) || defined(__MINGW32__) || defined(__WINDOWS_386__)
#  define __WIN32__
#  ifndef WIN32
#   define WIN32
#  endif
# endif
#endif

// STRICT: See MSDN Article Q83456
#ifdef __WIN32__
# ifndef STRICT
#  define STRICT
# endif
#endif

#ifndef __GNUC_PREREQ
# ifdef __GNUC__
#  define __GNUC_PREREQ(maj, min) ((__GNUC__ << 16) + __GNUC_MINOR__ >= ((maj) << 16) + (min))
# else
#  define __GNUC_PREREQ(maj, min) 0
# endif
#endif

#ifndef INT64_C
# if __WORDSIZE == 64
#  define INT64_C(c)		c ## L
#  define UINT64_C(c)	c ## UL
# else
#  define INT64_C(c)		c ## LL
#  define UINT64_C(c)	c ## ULL
# endif
#endif

#endif // _mstl_types_included

// vi:set ts=3 sw=3:
