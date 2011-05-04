// eco2code.cpp

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
