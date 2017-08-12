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

#include "eco_path_node.h"

#include "m_bit_functions.h"
#include "m_utility.h"
#include "m_assert.h"

using namespace eco;


PathNode::Set PathNode::m_set;
unsigned PathNode::m_count(0);


static inline
auto log2(uint8_t n) -> PathNode::BitLengths::value_type
{
	return n ? mstl::bf::msb_index(n) + 1 : 0;
}


PathNode::PathNode(uint8_t bits)
	:m_bits(bits)
	,m_used(true)
	,m_ref(1)
{
	++m_count;
}


PathNode::~PathNode()
{
	for (PathNode* node : m_nodes)
	{
		M_ASSERT(node->m_ref > 0);

		if (--node->m_ref == 0)
			delete node;
	}

	--m_count;
}


void PathNode::add(uint8_t bits, PathNode* node)
{
	M_REQUIRE(node == 0 || !used());

	if (node == 0)
	{
		node = new PathNode(bits);
	}
	else
	{
		node->m_bits = bits;
		node->m_used = true;
		++node->m_ref;
	}

	m_nodes.push_back(node);
}


void PathNode::add(PathNode* node)
{
	if (node == 0)
		return;

	for (PathNode* n : m_nodes)
	{
		if (!n->m_used && n == node)
			return;
	}

	m_nodes.push_back(node);
	++node->m_ref;
}

// XXX
static unsigned N = 0;
static unsigned K = 0;
#include <stdio.h>

void PathNode::computeBitlengths(BitLengths& bitLengths, unsigned level) const
{
	if (level == 1)
		fprintf(stderr, "computeBitlengths: %u\n", ++N);

	for (PathNode* node : m_nodes)
	{
		M_ASSERT(node);

		if (node->m_used)
		{
			if (level == bitLengths.size())
			{
				bitLengths.push_back(::log2(node->m_bits));
			}
			else
			{
				BitLengths::value_type& length = bitLengths[level];
				length = mstl::max(length, ::log2(node->m_bits));
			}

			node->computeBitlengths(bitLengths, level + 1);
		}
		else
		{
			node->computeBitlengths(bitLengths, level);
		}
	}
}


void PathNode::makePathMap(Path const& path)
{
	if (m_nodes.empty())
	{
if (++K % 100000 == 0)
fprintf(stderr, "makePathMap: %u (%u - %u)\n", K, m_set.size() + 1, m_set.container().capacity());
		m_set.push_back(path);
	}
	else
	{
		for (PathNode* node : m_nodes)
		{
			M_ASSERT(node);

			if (node->m_used)
			{
				Path myPath(path);
				myPath.append(node->m_bits);
				node->makePathMap(myPath);
			}
			else
			{
				node->makePathMap(path);
			}
		}
	}
}


auto PathNode::checkPathMap() -> bool
{
	Set::container_type const& c = m_set.container();

	for (unsigned i = 1; i < c.size(); ++i)
	{
		M_ASSERT(	M_UINT128_HI(c[i-1].bits()) < M_UINT128_HI(c[i].bits())
					|| (	M_UINT128_HI(c[i-1].bits()) == M_UINT128_HI(c[i].bits())
						&& M_UINT128_LO(c[i-1].bits()) <  M_UINT128_LO(c[i].bits())));

		if (!(c[i - 1] < c[i]))
			return false;
	}

	return true;
}

// vi:set ts=3 sw=3:
