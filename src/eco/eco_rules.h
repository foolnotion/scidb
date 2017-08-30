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

#ifndef _eco_rules_included
#define _eco_rules_included

#include "eco_id.h"

#include "db_move_buffer.h"

#include "m_vector.h"
#include "m_pvector.h"
#include "m_bitset.h"
#include "m_pair.h"

namespace eco {

class Rules
{
public:

	enum Permission { NotAllowed, Allowed, NotForbidden };

	auto isValid(Id id, db::MoveLine const& line) const -> bool;
	auto omit(Id id, db::MoveLine const& line) const -> bool;

	auto testTransposition(Id from, Id to, db::MoveLine const& line) const -> Permission;

	void add(Id id, db::MoveLine const& line);
	void addExclusion(Id id, db::MoveLine const& line);
	void addOmission(Id id, db::MoveLine const& line, unsigned lineNo);
	void addException(Id from, db::MoveLine const& line, Id to, unsigned lineNo);
	void setUnwantedTransposition(Id from, Id to);

	auto traceUnusedRules() const -> bool;

private:

	struct Line
	{
		Line();
		Line(db::MoveLine const& line, unsigned lineNo);

		db::MoveLine	m_line;
		mutable bool	m_used;
		unsigned			m_lineNo;
	};

	using Lines			= mstl::pvector<Line>;
	using MoveLines	= mstl::pvector<db::MoveLine>;
	using Exceptions	= mstl::pvector<mstl::pair<unsigned,Line>>;

	struct Set
	{
		Set();

		MoveLines		m_included;
		MoveLines		m_excluded;
		Lines				m_omissions;
		Exceptions		m_exceptions;
		mstl::bitset	m_unwanted;
	};

	auto isIncluded(Id id, db::MoveLine const& line) const -> int;
	auto isExcluded(Id id, db:: MoveLine const& line, unsigned offset) const -> bool;

	Set m_set[Id::Num_Basic_Codes];
};

} // namespace eco

#endif // _eco_rules_included

