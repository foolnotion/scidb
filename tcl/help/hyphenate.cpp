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
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "Hyphenator.h"

#include "m_exception.h"
#include "m_ofstream.h"
#include "m_ifstream.h"
#include "m_string.h"
#include "m_utility.h"

#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

using namespace hyphenate;


inline static bool isdelim(char c) { return c == ' ' || c == '>'; }


static void
__attribute__((__format__(__printf__, 1, 2)))
error(char const* format, ...)
{
	va_list args;
	va_start(args, format);
	vfprintf(stderr, format, args);
	fprintf(stderr, "\n");
	va_end(args);
	exit(1);
}


static Hyphenator*
buildHyphenator(mstl::string const& line)
{
	mstl::string::size_type n = line.find(" lang='");

	if (n == mstl::string::npos)
		error("Missing language tag in '%s'", line.c_str());

	mstl::string lang(line.begin() + n + 7, line.begin() + n + 9);
	mstl::string patternFilename("../../../src/util/libhyphenate/pattern/");
	mstl::string dictFilenames("../../../src/util/libhyphenate/dict/");
	mstl::string personalFilename("../../../src/util/libhyphenate/dict/xx.dat");

	(patternFilename += lang) += ".dat";
	(dictFilenames += lang) += ".dat";

	struct ::stat st;

	if (stat(patternFilename, &st) == -1)
		error("file '%s' does not exist", patternFilename.c_str());

	if (stat(dictFilenames, &st) == -1)
		dictFilenames.clear();
	if (stat(personalFilename, &st) == -1)
		personalFilename.clear();
	
	if (dictFilenames.empty())
		dictFilenames = personalFilename;
	else if (!personalFilename.empty())
		(dictFilenames += ';') += personalFilename;
	
	return new Hyphenator(patternFilename, dictFilenames);
}


static bool
isExcludingTag(char const* s)
{
	return	(strncasecmp(s, "a", 1) == 0 && isdelim(s[1]))
			|| (strncasecmp(s, "tt", 2) == 0 && isdelim(s[2]))
			|| (strncasecmp(s, "title", 5) == 0 && isdelim(s[5]))
			|| (tolower(s[0]) == 'h' && isdigit(s[1]) && isdelim(s[2]));
}


int
main(int argc, char const* argv[])
{
	mstl::string	hyphen("&shy;");
	Hyphenator*		hypenator = nullptr;
	unsigned			skipCounter = 0;
	unsigned			lessCounter = 0;
	mstl::string	result;
	mstl::string	buf;

	try
	{
		while (mstl::cin.getline(buf))
		{
			result.clear();

			char const* s = buf.begin();
			char const* e = buf.end();

			while (s < e)
			{
				if (mstl::is_odd(lessCounter))
				{
					char const* p = strchr(s, '>');

					if (p)
						--lessCounter, ++p;
					else
						p = e;

					result.append(s, p);
					s = p;
				}
				else
				{
					char const* p = strchr(s, '<');

					if (p)
						++lessCounter;
					else
						p = e;

					if (s < p)
					{
						if (skipCounter > 0 || !hypenator)
							result.append(s, p);
						else
							result.append(hypenator->hyphenate(mstl::string(s, p), hyphen));

						s = p;
					}

					if (s[0] == '<')
					{
						if (s[1] == '/')
						{
							if (isExcludingTag(s + 2))
								--skipCounter;
						}
						else
						{
							char const* q = s + 1;

							while (s < e && *s != '<')
								++q;

							if (q < e && q[-1] == '/')
							{
								result.append(s, ++q);
								s = q;
								--lessCounter;
							}
							else if (isExcludingTag(s + 1))
							{
								++skipCounter;
							}
							else if (strncasecmp(s + 1, "html", 4) == 0 && isdelim(s[5]))
							{
								hypenator = buildHyphenator(buf);
							}
						}
					}
				}
			}

			result.append('\n');
			mstl::cout.write(result);
		}

		if (!hypenator)
			error("Couldn't detect language tag");
	}
	catch (mstl::exception const& exc)
	{
		error("Exception catched: %s", exc.what());
	}

	return 0;
}

// vi:set ts=3 sw=3:
