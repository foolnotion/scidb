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

#include "sys_time.h"

#ifdef WIN32

# include <windows.h>
# include <sys/timeb.h>

uint32_t
sys::time::time()
{
	FILETIME ft;
	GetSystemTimeAsFileTime(&ft);
	uint64_t time = (uint64_t(ft.dwHighDateTime) << 32) | uint64_t(ft.dwLowDateTime);
	return (time - UINT64_C(116444736000000000))/10000000;
}


uint64_t
sys::time::timestamp()
{
	struct ::timeb tb;
	return (uint64_t(tb.time)*1000 + tb.millitm)*1000;
}

#else

# include <time.h>
# include <sys/time.h>

uint32_t sys::time::time() { return ::time(0); }


uint64_t
sys::time::timestamp()
{
	struct ::timeval tv;
	::gettimeofday(&tv, 0);
	return uint64_t(tv.tv_sec)*(1000*1000) + tv.tv_usec;
}

#endif

// vi:set ts=3 sw=3:
