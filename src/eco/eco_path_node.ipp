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

#include "m_algorithm.h"
#include "m_assert.h"

namespace eco {

inline PathNode::PathNode() :m_bits(0), m_used(false), m_ref(1) {}

inline auto PathNode::set() -> Set const&	{ return m_set; }
inline auto PathNode::count() -> unsigned	{ return m_count; }

inline auto PathNode::used() const -> bool	{ return m_used; }
inline auto PathNode::empty() const -> bool	{ return m_nodes.empty(); }
inline auto PathNode::single() const -> bool	{ return m_nodes.size() == 1; }


inline
auto PathNode::front() -> PathNode*
{
	M_REQUIRE(!empty());
	return m_nodes.front();
}


inline
auto PathNode::lookup(Path const& path) -> unsigned
{
	Set::const_iterator i = m_set.find(path);
	M_ASSERT(i != m_set.end());
	return i - m_set.begin();
}


inline
void PathNode::makePathMap()
{
	makePathMap(Path());
	M_ASSERT(checkPathMap());
}


inline
void PathNode::computeBitlengths(BitLengths& bitLengths) const
{
	computeBitlengths(bitLengths, 0);
}

} // namespace eco

// vi:set ts=3 sw=3:
