// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
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

#include "db_eco.h"

#include <stdio.h>

using namespace db;

int
main(int argc, char const* argv[])
{
	if (argc < 2)
	{
		fprintf(stderr, "Usage: eco2code A00.001\n");
		return -1;
	}

	printf("%s -> %u\n", argv[1], unsigned(Eco(argv[1])));

	return 0;
}

// vi:set ts=3 sw=3:
