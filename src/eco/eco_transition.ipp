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

namespace eco {

inline Transition::Transition() :transposition(false) {}

inline auto Transition::operator==(Id i) const -> bool { return id == i; }
inline auto Transition::operator!=(Id i) const -> bool { return id != i; }


inline
Transition::Transition(Id i, db::Move m, Type type)
	:id(i)
	,move(m)
	,transposition(type == Transposition)
{
}

} // namespace eco

// vi:set ts=3 sw=3:
