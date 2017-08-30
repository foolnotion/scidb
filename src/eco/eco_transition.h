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

#ifndef _eco_transition_included
#define _eco_transition_included

#include "eco_id.h"

#include "db_move.h"

#include "m_vector.h"

namespace eco {

struct Transition
{
	enum Type
	{
		NextMove,
		Transposition
	};

	Transition();
	Transition(Id i, db::Move m, Type type);

	auto operator==(Id id) const -> bool;
	auto operator!=(Id id) const -> bool;

	Id			id;
	db::Move	move;
	bool		transposition;
};

using Transitions = mstl::vector<Transition>;

} // namespace eco

#include "eco_transition.ipp"

#endif // _eco_transition_included

// vi:set ts=3 sw=3:
