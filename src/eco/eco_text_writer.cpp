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

#include "eco_text_writer.h"
#include "eco_name.h"
#include "eco_branch.h"
#include "eco_node.h"

#include "m_ostream.h"
#include "m_assert.h"

#include <time.h>
#include <stdio.h>

using namespace eco;
using namespace db;


TextWriter::TextWriter(mstl::ostream& strm)
	:Writer(strm)
	,m_eco("A00")
	,m_recursion(false)
	,m_linesWritten(false)
{
}


auto TextWriter::branch(Branch const& branch) -> bool
{
	if (branch.transposition)
		return false;
	
	M_ASSERT(!branch.node->alreadyDone());

	return branch.codes.test(m_eco.basic());
}


void TextWriter::visit(Node const& node)
{
	if (node.id().basic() == m_eco.basic() && node.shouldBeFinal())
	{
#if 1
		m_used.set(node.id());
#else
		if (m_used.test_and_set(node.id()))
			M_RAISE("duplicate id %s (%u)", node.id().asString().c_str(), node.lineNo());
#endif

		if (node.isExtension())
			m_strm << "# Line automatically inserted for move transposition\n";
		else if (!node.isFinal())
			m_strm << "# Line automatically inserted for move transition\n";

		for (auto const& branch : node.successors())
		{
			if (branch.recursion)
				m_strm << "# Transposition to parent " << branch.node->id().asString() << "\n";
		}

		m_strm << node.id().asString();

		Name const& name = node.name();

		for (unsigned k = 0; k < name.size(); ++k)
		{
			unsigned j = (k == 1 && name.str(k).empty()) ? 0 : k;
			m_strm << ' ' << '"' << name.str(j) << '"';
		}

		mstl::string s;

		node.line().dump(s);
		if (!s.empty())
			m_strm << ' ' << s;

		for (auto const& branch : node.successors())
		{
			Id nextId = branch.node->finalNode()->id();
			char open, close;

			switch (branch.linkType())
			{
				case Branch::NextMove:			open = '('; close = ')'; break;
				case Branch::Transposition:	open = '['; close = ']'; break;
			}

			s.clear();
			branch.move.printSAN(s, protocol::Scidb, encoding::Latin1);
			m_strm << ' ' << open << nextId.asString() << close << ' ' << s;
			m_referenced.set(nextId);
		}

		m_strm << '\n';
		m_linesWritten = true;
	}
}


void TextWriter::print(Node const* root)
{
	M_REQUIRE(root);

	char buf[200];
	time_t t = ::time(0);
	struct tm tm;
	::localtime_r(&t, &tm);
	::strftime(buf, sizeof(buf), "%F", &tm);

	m_strm << "# Extended ECO table: generated " << buf << '\n';
	m_linesWritten = true;
	m_used.resize(Id::Max_Code + 1);
	m_referenced.resize(Id::Max_Code + 1);

	for (unsigned code = 0; code < 500; ++code)
	{
		if (m_linesWritten)
		{
			m_strm << '\n';
			m_linesWritten = false;
		}

		m_eco = Id(code, 0);
		Writer::print(root);
	}

	if (m_linesWritten)
		m_strm << '\n';

	m_strm << "# eof\n";

	m_used -= m_referenced;
	m_used.reset(Id::root());

	for (mstl::bitset::enumerator i = m_used.begin_index(); i != m_used.end_index(); ++i)
		fprintf(stderr, "line %s is unreferenced\n", Id(*i).asString().c_str());

	if (m_used.any())
		M_RAISE("aborted due to errors");
}

// vi:set ts=3 sw=3:
