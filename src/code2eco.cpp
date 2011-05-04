// eco2code.cpp

#include "db_eco.h"

#include <stdio.h>
#include <stdlib.h>

using namespace db;

int
main(int argc, char const* argv[])
{
	if (argc < 2)
	{
		fprintf(stderr, "Usage: eco2code <eco-value>\n");
		return -1;
	}

	unsigned value = strtoul(argv[1], 0, 10);

	printf("%u -> %s\n", value, Eco(value).asString().c_str());

	return 0;
}

// vi:set ts=3 sw=3:
