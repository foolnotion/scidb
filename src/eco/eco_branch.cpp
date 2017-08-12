// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
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

#include "eco_branch.h"

using namespace eco;
using namespace db;

unsigned Branch::count = 0;


Branch::Branch()
	:move(0)
	,node(nullptr)
	,bits(0)
	,weight(0)
	,pathLength(0)
	,transposition(false)
	,bypass(false)
	,backlink(false)
	,useBits(false)
	,recursion(false)
{
	++count;
}


Branch::Branch(Move m, Node* n, LinkType linkType)
	:move(m)
	,node(n)
	,bits(0)
	,weight(0)
	,pathLength(0)
	,transposition(linkType == Transposition)
	,bypass(false)
	,backlink(false)
	,useBits(false)
	,recursion(false)
{
	++count;
}

// vi:set ts=3 sw=3:
