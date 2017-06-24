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

#include "m_algorithm.h"
#include "m_utility.h"
#include "m_assert.h"

#include <alloca.h>
#include <string.h>


/// Exchanges ranges [first, first+1) and [first+1, last)
bool
mstl::bits::rotate_fast(void* first, void* last, size_t size)
{
	M_ASSERT(first <= last);

	typedef char* T;

	if (first != last)
	{
		void* buf = alloca(size);

		if (buf == 0)
			return false;

		memcpy(buf, first, size);
		memmove(first, T(first) + size, T(last) - T(first) - size);
		memcpy(T(last) - size, buf, size);
	}

	return true;
}


/// Exchanges ranges [first, middle) and [middle, last)
bool
mstl::bits::rotate_fast(void* first, void* middle, void* last, size_t size)
{
	M_ASSERT(first <= middle);
	M_ASSERT(middle <= last);

	typedef char* T;

	size_t half1	= T(middle) - T(first);
	size_t half2	= T(last) - T(middle);
	size_t hmin		= min(half1, half2)*size;

	if (hmin == 0)
		return true;

	if (hmin > 1024*1024)
		return false;

	void* buf = alloca(hmin);

	if (buf == 0)
		return false;

	if (half2 < half1)
	{
		memcpy(buf, middle, half2);
		memmove(T(last) - half1, first, half1);
		memcpy(first, buf, half2);
	}
	else
	{
		memcpy(buf, first, half1);
		memmove(first, middle, half2);
		memcpy(T(first) + half2, buf, half1);
	}

	return true;
}

// vi:set ts=3 sw=3:
