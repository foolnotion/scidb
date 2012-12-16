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

namespace db {
namespace sci {

inline
void
Encoder::changeVariant(db::variant::Type variant)
{
	m_variant = variant;
}


inline
bool
Encoder::doEncoding(Move const& move)
{
	bool rc = encodeMove(move);
	m_position.doMove(move);
	return rc;
}

} // namespace sci
} // namespace db

// vi:set ts=3 sw=3:
