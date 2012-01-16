// ======================================================================
// $RCSfile: tk_image.cpp,v $
// $Revision$
// $Date$
// $Author: gregor $
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_bitfield.h"
#include "m_vector.h"
#include "m_set.h"

#include <stdio.h>
#include <string.h>
#include <assert.h>

//#define INCLUDE_ZERO_PAWNS


enum { Size = 5 };


typedef mstl::bitfield<uint8_t> Board[3];
typedef mstl::set<uint32_t> Set;
typedef mstl::vector<uint16_t> List;


Set map;
uint32_t leftPawnKey;


void permute(Board& brd, List& list);


uint16_t
hash(Board const& brd)
{
	return brd[0].value() << Size | brd[1].value();
}


void
insert(uint32_t src, uint32_t dst)
{
	uint32_t key = (src << 2*Size) | dst;

#ifndef INCLUDE_ZERO_PAWNS
	if ((key & leftPawnKey) == 0)
		map.insert(key | leftPawnKey);

	if (dst == 0)
		return;
#endif

	map.insert(key);

#ifdef INCLUDE_ZERO_PAWNS
	map.insert(src << 2*Size);
#endif
}


void
permute(Board& brd, List& list, int row, int col, int dir)
{
	int r = row + 1;
	int c = col + dir;

	if (c == -1 || c == Size || !brd[r].test(c))
	{
		brd[row].reset(col);

		if (r == 1 && c >= 0 && c < Size)
			brd[1].set(c);

		uint16_t key = hash(brd);

		list.push_back(key);

		for (unsigned i = 0; i < list.size(); ++i)
			insert(list[i], key);

		permute(brd, list);
		list.pop_back();

		if (r == 1 && c >= 0 && c < Size)
			brd[1].reset(c);

		brd[row].set(col);
	}
}


void
permute(Board& brd, List& list)
{
	for (int row = 0; row < 2; ++row)
	{
		for (int col = 0; col < Size; ++col)
		{
			if (brd[row].test(col))
			{
				permute(brd, list, row, col,   0);
				permute(brd, list, row, col,  -1);
				permute(brd, list, row, col,  +1);
			}
		}
	}
}


int
main()
{
	Board brd;
	List  list;

	brd[1].set(Size - 1);
	leftPawnKey = hash(brd);

	brd[0].set(0, Size - 1);
	brd[1].reset();

	uint16_t key = hash(brd);

	insert(0, 0);
	insert(key, key);

	list.push_back(key);
	permute(brd, list);

	unsigned col = 7;

	printf("// %u entries\n", map.size());

	for (Set::const_iterator i = map.begin(); i != map.end(); ++i)
	{
		if (++col == 8)
		{
			printf("\n");
			col = 0;
		}
		else
		{
			printf(" ");
		}

		printf("0x%05x,", *i);
	}

	printf("\n");

	return 0;
}

// vi:set ts=3 sw=3:
