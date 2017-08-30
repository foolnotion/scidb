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
#include <string.h>

using namespace eco;


static mstl::string
strip(mstl::string const& str)
{
	if (char const* s = strchr(str.begin(), '('))
	{
		while (s > str.begin() && s[-1] == ' ')
			--s;
		return mstl::string(str, s - str.begin());
	}

	return str;
}


LineWriter::LineWriter(mstl::ostream& strm) :Writer(strm), m_eco("A00"), m_needHeader(true) {}


auto LineWriter::branch(Branch const& branch) -> bool
{
	return	!branch.transposition
			&& !branch.node->alreadyDone()
			&& !branch.codes.empty()
			&& branch.codes.test(m_eco.basic());
}


void LineWriter::printTransposition(Node const& node, Branch const& branch)
{
	Node const* succ = branch.node;

	db::MoveLine line(node.line());
	line.append(branch.move);
	mstl::string s;
	line.dump(s);

	m_strm << m_eco.asShortString() << ' ' << s;
	m_strm << (branch.exception ? " ---> " : " -> ");
	m_strm << succ->id().asShortString();

	if (succ->comment().empty())
	{
		Name const& name = succ->name();

		m_strm << " #";
		if (name.size() > 2)
			m_strm << " \"" << ::strip(name.str(name.size() - 1)) << '\"';
		m_strm << " \"" << ::strip(name.str(name.str(1).empty() ? 0 : 1)) << '\"';
	}
	else
	{
		m_strm << " # " << succ->comment();
	}

	m_strm << '\n';
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

		for (auto const& branch : node.successors())
		{
			if (branch.transposition && branch.node->id().basic() == m_eco.basic())
			{
				m_strm << " ++";
				break;
			}
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
		{
			if (node.sign() != '-' || node.successors().empty())
				m_strm << " #" << node.sign();
		}

		m_strm << '\n';

		for (auto const& branch : node.successors())
		{
			if (	branch.transposition
				&& !branch.node->isExtension()
				&& branch.node->id().basic() != m_eco.basic())
			{
				printTransposition(node, branch);
			}
		}
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
