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
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "eco.h"

#include "db_eco_table.h"
#include "db_eco.h"
#include "db_board.h"
#include "db_line.h"

#include "u_byte_stream.h"

#include "m_map.h"
#include "m_vector.h"
#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_exception.h"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

enum { OldFileVersion = 91 };


using namespace db;
using namespace util;


struct EcoMap
{
	MyEco			eco;
	uint64_t		hash;
	uint16_t*	lineBuf;
	Line			line;

	EcoMap() :hash(0), lineBuf(new uint16_t[opening::Max_Line_Length]), line(lineBuf) {}
};

struct Path
{
	uint16_t		key;
	uint16_t		path;
	uint16_t		length;
	uint16_t*	lineBuf;
	Line			line;

	Path() :key(0), path(0), length(0), lineBuf(new uint16_t[opening::Max_Line_Length]), line(lineBuf) {}

	void set(uint16_t k, uint16_t p, unsigned n, Line const& l)
	{
		key = k;
		path = p;
		length = n;
		line.copy(l);
	}
};


using EcoList	= mstl::vector<EcoMap>;
using KeyMap	= mstl::map<uint64_t,Path>;


static EcoList	ecoList;
static KeyMap	keyMap;


__attribute__((noreturn))
static
void throwCorrupted(unsigned lineNo)
{
	M_RAISE("ECO file corrupted (line %u)", lineNo);
}


static
endOfWord(char const* s) -> char const*
{
	while (*s && *s != ' ')
		++s;

	return s;
}


static
nextWord(char const* s) -> char const*
{
	s = endOfWord(s);

	while (*s == ' ')
		++s;

	if (!*s)
		return 0;

	while (::isdigit(*s))
		++s;

	if (*s == '.')
		++s;

	while (*s == ' ')
		++s;

	return s;
}


static
void loadEco(mstl::istream& strm)
{
	mstl::string	buf;
	unsigned			lineNo(0);

	while (true)
	{
		do
		{
			if (!strm.getline(buf))
				return;

			++lineNo;
		}
		while (buf.empty() || buf[0] == '#');

		if (buf.size() < 10)
			throwCorrupted(lineNo);

		char const* s = buf.c_str();

		MyEco eco(s);

		if (eco == 0)
			throwCorrupted(lineNo);

		s = ::strchr(s + 8, '"');

		if (!s)
			throwCorrupted(lineNo);

		while (*s == '"')
		{
			char const* e = ::strchr(s + 1, '"');

			if (!e)
				throwCorrupted(lineNo);

			char const* t = ::strchr(e + 1, '"');
			s = t ? t : e - 1;
		}

		Board board(Board::standardBoard(variant::Normal));
		EcoMap& entry = ecoList.push_back();

		while ((s = ::nextWord(s + 1)) && ::isalpha(*s))
		{
			Move move = board.parseMove(s, variant::Normal);

			if (!move.isLegal())
				throwCorrupted(lineNo);

			board.doMove(move, variant::Normal);
			entry.lineBuf[entry.line.length++] = move.index();
		}

		entry.eco = eco;
		entry.hash = board.hash();
	}
}


static
void loadKey(mstl::istream& strm)
{
	mstl::string	buf;
	unsigned			lineNo(0);
	unsigned			key(0);
	unsigned			path(0);
	unsigned			length(0);

	while (true)
	{
		do
		{
			if (!strm.getline(buf))
				return;

			++lineNo;
		}
		while (buf.empty() || buf[0] == '#');

		if (buf.size() < 11)
			throwCorrupted(lineNo);

		char const* s = buf.c_str();
		char* e = 0;

		key = strtoul(s, &e, 10);

		if (e == 0 || e[0] != ':' || !isdigit(e[1]))
			throwCorrupted(lineNo);

		path = strtoul(s = e + 1, &e, 10);

		if (e == 0 || e[0] != ':' || !isdigit(e[1]))
			throwCorrupted(lineNo);

		length = strtoul(s = e + 1, &e, 10);

		if (e == 0 || (*e != '\0' && !isspace(e[0])))
			throwCorrupted(lineNo);

		while (isspace(*s))
			++s;

		Board		board(Board::standardBoard(variant::Normal));
		uint16_t	lineBuf[opening::Max_Line_Length];
		Line		line(lineBuf);

		if (*s)
		{
			while ((s = ::nextWord(s + 1)) && ::isalpha(*s))
			{
				Move move = board.parseMove(s, variant::Normal);

				if (!move.isLegal())
					throwCorrupted(lineNo);

				board.doMove(move, variant::Normal);
				lineBuf[line.length++] = move.index();
			}
		}

		keyMap[board.hash()].set(key, path, length, line);
	}
}


static
void mapping(mstl::ostream& strm)
{
	using uint24_t = ByteStream::uint24_t;

	unsigned char buf[8];
	ByteStream bstrm(buf, 8);

	M_ASSERT(keyMap.find(Board::standardBoard(variant::Normal).hash()) != keyMap.end());
	M_ASSERT(keyMap.find(Board::standardBoard(variant::Normal).hash()) == keyMap.find(ecoList[0].hash));

	for (auto const& entry : ecoList)
	{
		union Data
		{
			struct
			{
				uint64_t key :20;
				uint64_t cls :17; // one bit is reserved
				uint64_t path:16;
				uint64_t length:4;
				uint64_t unpredictable:1;
				uint64_t __unused__:6;
			};

			uint64_t value;
		}
		data;

		KeyMap::const_iterator k = keyMap.find(entry.hash);

		if (k == keyMap.end())
		{
			fprintf(stderr, "Missing eco line %s\n", entry.eco.asString().c_str());
			exit(1);
		}

		data.value = 0;
		data.key = entry.eco;
		data.cls = k->second.key;
		data.path = k->second.path;
		data.length = k->second.length;
		data.unpredictable = (entry.line != k->second.line);

		bstrm.resetp();
		bstrm << data.value;
		mstl::cout.write(buf, 8);
	}
}


auto main(int argc, char const* argv[]) -> int
{
	if (argc < 3)
	{
		printf("Usage: %s <old-eco-file> <eco-map>\n", argv[0]);
		return 1;
	}

	Board::initialize();

	try
	{
		mstl::ifstream strm1(argv[1]);
		mstl::ifstream strm2(argv[2]);

		loadEco(strm1);
		loadKey(strm2);

		mstl::cout.write("eco.map", 8);
		mstl::cout << uint8_t(OldFileVersion);
		mstl::cout << uint8_t(EcoTable::FileVersion);

		mapping(mstl::cout);
	}
	catch (mstl::exception const& exc)
	{
		fflush(stdout);
		fprintf(stderr, "\n%s\n", exc.what());
		exit(1);
	}

	return 0;
}

// vi:set ts=3 sw=3:
