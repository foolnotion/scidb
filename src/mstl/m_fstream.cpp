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

#include "m_fstream.h"
#include "m_assert.h"

#include <string.h>

using namespace mstl;


static void
makeModeString(char modestr[4], ios_base::openmode mode)
{
	::memcpy(modestr, "w\0\0\0", 4);

	switch (mode & ~ios_base::binary)
	{
		case ios_base::out | ios_base::app:							::strcpy(modestr, "a"); break;
		case ios_base::in:												::strcpy(modestr, "r"); break;
		case ios_base::in | ios_base::out:							::strcpy(modestr, "r+"); break;
		case ios_base::in | ios_base::out | ios_base::app:		::strcpy(modestr, "a+"); break;
		case ios_base::in | ios_base::out | ios_base::trunc:	::strcpy(modestr, "w+"); break;
	}

	if (mode & ios_base::binary)
	{
		modestr[2] = modestr[1];
		modestr[1] = 'b';
	}
}


fstream::fstream() {}
fstream::fstream(char const* filename, openmode mode) { open(filename, mode); }


void
fstream::open(char const* filename, openmode mode)
{
	M_REQUIRE(filename);
	M_REQUIRE(!is_open());
	M_REQUIRE(	(mode & ~binary) == (mode & out)
				|| (mode & ~binary) == (mode & (out | app))
				|| (mode & ~binary) == (mode & (out | trunc))
				|| (mode & ~binary) == (mode & in)
				|| (mode & ~binary) == (mode & (in | out))
				|| (mode & ~binary) == (mode & (in | out | app))
				|| (mode & ~binary) == (mode & (in | out | trunc)));

	char modestr[4];
	::makeModeString(modestr, mode);
	setmode(mode);
	bits::file::open(filename, modestr);
}


void
fstream::open(char const* filename)
{
	open(filename, in | out);
}


void
fstream::reopen(openmode mode)
{
	M_REQUIRE(is_open());
	M_REQUIRE(	(mode & ~binary) == (mode & out)
				|| (mode & ~binary) == (mode & (out | app))
				|| (mode & ~binary) == (mode & (out | trunc))
				|| (mode & ~binary) == (mode & in)
				|| (mode & ~binary) == (mode & (in | out))
				|| (mode & ~binary) == (mode & (in | out | app))
				|| (mode & ~binary) == (mode & (in | out | trunc)));

	char modestr[4];
	::makeModeString(modestr, mode);
	setmode(mode);
	bits::file::reopen(modestr);
}

// vi:set ts=3 sw=3:
