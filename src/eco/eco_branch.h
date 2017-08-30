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

#ifndef _eco_branch_included
#define _eco_branch_included

#include "eco_id.h"

#include "db_move.h"

#include "m_bitset.h"

namespace eco {

class Node;

struct Branch
{
	enum LinkType
	{
		NextMove,
		Transposition,
	};

	Branch();
	Branch(db::Move m, Node* n, LinkType linkType);

	auto linkType() const -> LinkType;

	void setId(Id id);
	void setAll();
	void setLinkType(LinkType linkType);

	db::Move			move;
	Node*				node;
	mstl::bitset	codes;
	uint8_t			bits;
	uint8_t			weight;
	uint8_t			pathLength;
	uint8_t			exception:1;
	uint8_t			transposition:1;
	uint8_t			bypass:1;
	uint8_t			backlink:1; // not yet used
	uint8_t			useBits:1;
	uint8_t			recursion:1;

	static unsigned count;
};

} // namespace eco

#include "eco_branch.ipp"

#endif // _eco_branch_included

// vi:set ts=3 sw=3:
