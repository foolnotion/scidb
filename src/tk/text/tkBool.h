/*
 * tkBool.h --
 *
 *	This module provides a boolean type, conform to C++.
 *
 * Copyright (c) 2015-2017 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TK_BOOL
#define _TK_BOOL

#ifdef __cplusplus
extern "C" {
# define bool TkBool
#endif

typedef int bool;

#ifndef __cplusplus
enum { true = (int) 1, false = (int) 0 };
#endif

#ifdef __cplusplus
} /* extern "C" */
#endif

/* This is required for the inlined version. */

#include <stdint.h>

#define HAVE_INTTYPES_H 1
#define HAVE_STDINT_H 1

#ifdef _MSC_VER
# if defined(inline)
#  define TK_C99_INLINE_SUPPORT
# elif _MSC_VER >= 1200
#  define inline __inline
#  define TK_C99_INLINE_SUPPORT
#  define TK_C99_INLINE_DEFINED
# else
#  define inline
#  define TK_C99_INLINE_DEFINED
# endif
#elif __STDC_VERSION__ >= 199901L
# define TK_C99_INLINE_SUPPORT
#else
# define inline
# define TK_C99_INLINE_DEFINED
#endif

/*
 * Detection of >=64 bit architectures, which supports the use of
 * the appropriate integer types. It's possible that we are detecting
 * a 32 bit architecture although it's a 64 bit architecture, in this
 * case a 32 bit system is installed on a 64 bit architecture.
 */

#if HAVE_STDINT_H
#   if (UINTPTR_MAX == 0xffffffffu)
    /* This is quite likely a 32 bit architecture. */
#	define TK_IS_32_BIT_ARCH
#   elif (UINTPTR_MAX >= 0xffffffffffffffffu)
    /* This is a real 64 bit architecture. */
#	define TK_IS_64_BIT_ARCH
#   else
#	error "unsupported architecture" /* should never happen */
#   endif
#elif defined(_WIN64) /* ancient compiler support */
    /* This is a real 64 bit architecture. */
#   define TK_IS_64_BIT_ARCH
#elif defined(_WIN32) /* ancient compiler support */
    /* This is quite likely a 32 bit architecture. */
#   define TK_IS_32_BIT_ARCH
#else
#   error "cannot detect architecture"
#endif /* HAVE_STDINT_H */

#if TCL_MAJOR_VERSION < 8 || (TCL_MAJOR_VERSION == 8 && TCL_MINOR_VERSION < 7)
# if defined(__unix__)
#  define DEF_TEXT_INACTIVE_SELECT_BG_COLOR SELECT_BG
#  define DEF_TEXT_INACTIVE_SELECT_FG_COLOR BLACK
# elif defined(_WIN32) || defined(__CYGWIN__)
#  define DEF_TEXT_INACTIVE_SELECT_BG_COLOR NULL
#  define DEF_TEXT_INACTIVE_SELECT_FG_COLOR SELECT_FG
# elif defined(MAC_OSX_TK)
#  define DEF_TEXT_INACTIVE_SELECT_BG_COLOR SELECT_BG INACTIVE_SELECT_BG
#  define DEF_TEXT_INACTIVE_SELECT_FG_COLOR BLACK "systemDialogActiveText"
# else
# error "unsupported platform"
# endif
#endif

#endif /* _TK_BOOL */
/* vi:set ts=8 sw=4: */
