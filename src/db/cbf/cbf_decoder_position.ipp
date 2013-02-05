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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace db {
namespace cbf {
namespace decoder {

inline unsigned Position::variationLevel() const { return m_stack.size() - 1; }

inline void Position::push()						{ m_stack.dup(); }
inline void Position::pop()						{ m_stack.pop(); }

inline Board const& Position::board() const	{ return m_stack.top(); }
inline Board& Position::board()					{ return m_stack.top(); }

} // namespace decoder
} // namespace cbf
} // namespace db

// vi:set ts=3 sw=3:
