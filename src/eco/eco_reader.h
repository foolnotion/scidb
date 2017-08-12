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

#ifndef _eco_reader_included
#define _eco_reader_included

#include "eco_id.h"
#include "eco_transition.h"

#include "db_move_buffer.h"

#include "m_string.h"

namespace mstl { class istream; }

namespace eco {

class Name;
class Node;

class Reader
{
public:

	enum Type { Line, Extended };

	static constexpr char PreParsed	= 1;
	static constexpr char Equal		= 2;

	Reader(Type type);
	virtual ~Reader() = default;

	auto isLineReader() const -> bool;

	auto lineNo() const -> unsigned;
	auto countConflicts() const -> unsigned;
	auto epilogue() const -> mstl::string const&;

	void countConflict();

	virtual auto readLine(
		db::MoveLine& line,
		Transitions& transitions,
		Name& name,
		mstl::string& prologue,
		mstl::string& epilogue,
		char& sign,
		Node* root) -> Id = 0;

protected:

	__m_no_return void throwCorrupted() const;

	Type				m_type;
	unsigned			m_lineNo;
	unsigned			m_conflicts;
	mstl::string	m_epilogue;
};

} // namespace eco

#include "eco_reader.ipp"

#endif // _eco_reader_included

// vi:set ts=3 sw=3:
