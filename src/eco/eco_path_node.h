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

#ifndef _eco_path_node_included
#define _eco_path_node_included

#include "eco_path.h"

#include "m_set.h"
#include "m_vector.h"

namespace eco {

class PathNode
{
public:

	using Set = mstl::set<Path>;
	using BitLengths = Path::BitLenghtList;

	PathNode();
	~PathNode();

	auto empty() const -> bool;
	auto used() const -> bool;
	auto single() const -> bool;

	static auto count() -> unsigned;

	void add(uint8_t bits, PathNode* node);
	void add(PathNode* node);
	void computeBitlengths(BitLengths& bitLengths) const;
	void makePathMap();

	auto front() -> PathNode*;

	static auto set() -> Set const&;
	static auto lookup(Path const& path) -> unsigned;

private:

	using Nodes = mstl::vector<PathNode*>;

	PathNode(uint8_t bits);

	void makePathMap(Path const& path);
	void computeBitlengths(BitLengths& bitLengths, unsigned level) const;

	static auto checkPathMap() -> bool;

	uint8_t	m_bits;
	uint8_t	m_used;
	uint8_t	m_ref;
	Nodes		m_nodes;

	static Set m_set;
	static unsigned m_count;
};

} // namespace eco

#include "eco_path_node.ipp"

#endif // _eco_path_node_included

// vi:set ts=3 sw=3:
