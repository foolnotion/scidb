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

#include "m_bit_functions.h"

#ifdef BF_USE_FLIP_ARR
uint8_t mstl::bf::bits::Flip[256];
#endif

namespace mstl {
namespace bf {
namespace bits {

#if defined(BF_USE_FLIP_ARR)

namespace {

struct initializer { initializer(); };
static initializer initializer;

initializer::initializer()
{
	for (unsigned i = 0; i < 256; ++i)
	{
		uint8_t x = i;

		x =			((x >> 1) & 0x55) | ((x << 1) & 0xAA);
		x =			((x >> 2) & 0x33) | ((x << 2) & 0xCC);
		Flip[i] =	((x >> 4) & 0x0F) | ((x << 4) & 0xF0);
	}
}

} // namespace
} // namespace bits
} // namespace bf
} // namespace mstl

#endif // defined(BF_USE_FLIP_ARR)


uint32_t
mstl::bf::bits::reverse(uint32_t a)
{
	a =		((a >>  1) & 0x55555555) | ((a <<  1) & 0xAAAAAAAA);
	a =		((a >>  2) & 0x33333333) | ((a <<  2) & 0xCCCCCCCC);
	a =		((a >>  4) & 0x0F0F0F0F) | ((a <<  4) & 0xF0F0F0F0);
	a =		((a >>  8) & 0x00FF00FF) | ((a <<  8) & 0xFF00FF00);
	return	((a >> 16) & 0x0000FFFF) | ((a << 16) & 0xFFFF0000);
}


uint64_t
mstl::bf::bits::reverse(uint64_t a)
{
   a =		((a >>  1) & 0x5555555555555555LL) | ((a <<  1) & 0xAAAAAAAAAAAAAAAALL);
   a =		((a >>  2) & 0x3333333333333333LL) | ((a <<  2) & 0xCCCCCCCCCCCCCCCCLL);
   a =		((a >>  4) & 0x0F0F0F0F0F0F0F0FLL) | ((a <<  4) & 0xF0F0F0F0F0F0F0F0LL);
   a =		((a >>  8) & 0x00FF00FF00FF00FFLL) | ((a <<  8) & 0xFF00FF00FF00FF00LL);
   a =		((a >> 16) & 0x0000FFFF0000FFFFLL) | ((a << 16) & 0xFFFF0000FFFF0000LL);
   return	((a >> 32) & 0x00000000FFFFFFFFLL) | ((a << 32) & 0xFFFFFFFF00000000LL);
}


#if defined(VALGRIND) && __WORDSIZE == 32

// Workaround for the __ctzdi2 problem with valgrind.
unsigned
mstl::bf::bits::ctz(unsigned long long x)
{
	unsigned r(x); return r ? ctz(r) : 32 + ctz(unsigned(x >> 32));
}

#endif

// vi:set ts=3 sw=3:
