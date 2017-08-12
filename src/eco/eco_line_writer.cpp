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

#include "eco_line_writer.h"
#include "eco_name.h"
#include "eco_branch.h"
#include "eco_node.h"

#include "db_move_buffer.h"

#include "m_ostream.h"
#include "m_assert.h"

#include <time.h>

using namespace eco;


LineWriter::LineWriter(mstl::ostream& strm) :Writer(strm), m_eco("A00"), m_needHeader(true) {}


auto LineWriter::branch(Branch const& branch) -> bool
{
	return !branch.node->alreadyDone() && !branch.codes.empty() && branch.codes.test(m_eco.basic());
}


void LineWriter::visit(Node const& node)
{
	if (node.id().basic() == m_eco.basic() && (node.isFinal() || node.isEqual()))
	{
		mstl::string s;
		node.line().dump(s);

		if (!node.prologue().empty())
		{
			m_strm << node.prologue();
			m_needHeader = false;
		}
		else if (m_needHeader && node.id().basic() == 0)
		{
			char buf[200];
			time_t t = ::time(0);
			struct tm tm;
			::localtime_r(&t, &tm);
			::strftime(buf, sizeof(buf), "%F", &tm);

			m_strm << "# generated " << buf << '\n';
			m_needHeader = false;
		}

		m_strm << m_eco.asShortString();

		if (!s.empty())
		{
			m_strm << ' ' << s;

			if (node.isEqual())
				m_strm << " **";
		}

		Name const& name = node.name();
		Name const& parentName = node.parentName();

		if (name != parentName)
		{
			unsigned i = 0;

			while (i < name.size() && i < parentName.size() && name.str(i) == parentName.str(i))
				++i;

			if (i == 1)
				i = 0;

			for ( ; i < name.size(); ++i)
			{
				if (!name.str(i).empty() && (i != 0 || name.str(1) != name.str(0)))
					m_strm << " \"" << name.str(i) << '\"';
			}

			m_strm << " {" << char((name.size() <= 2 ? 0 : name.size() - 2) + '0') << "}";
		}

		if (!node.comment().empty())
			m_strm << " # " << node.comment();
		if (node.sign())
			m_strm << " #" << node.sign();
		else if (node.isExtension())
			m_strm << " #X";

		m_strm << '\n';
	}
}


void LineWriter::print(Node const* root)
{
	M_REQUIRE(root);

	for (unsigned code = 0; code < 500; ++code)
	{
		m_eco = Id(code, 0);
		Writer::print(root);
	}

	m_strm << root->epilogue();
}

// vi:set ts=3 sw=3:
