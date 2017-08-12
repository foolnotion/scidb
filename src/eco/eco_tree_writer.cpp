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

#include "eco_tree_writer.h"
#include "eco_node.h"
#include "eco_branch.h"

#include "m_ostream.h"
#include "m_utility.h"
#include "m_assert.h"

using namespace eco;
using namespace db;


TreeWriter::TreeWriter(mstl::ostream& strm)
	:Writer(strm)
	,m_transpositionLevel(0)
	,m_break(false)
{
}


auto TreeWriter::branch(Branch const& branch) -> bool
{
	if (m_break)
		return false;

	if (!m_transpositionLevel && branch.transposition)
		m_transpositionLevel = level();

	m_branchStack.push(&branch);
	m_levelStack.dup();
	m_depthStack.dup();
	m_nameStack.dup();
	m_parentStack.dup();

	return true;
}


void TreeWriter::finishBranch(Branch const& branch)
{
	if (m_transpositionLevel == level())
		m_transpositionLevel = 0;

	m_break = false;
	m_branchStack.pop();
	m_levelStack.pop();
	m_depthStack.pop();
	m_nameStack.pop();
	m_parentStack.pop();
}


void TreeWriter::dumpLine(Node const& node)
{
	M_ASSERT(level() > 0);

	bool isTrans = m_transpositionLevel > 0;

	m_strm << (isTrans ? '[' : ' ') << node.id().asString() << (isTrans ? ']' : ' ');

	if (level() > 1)
	{
		m_strm << ' ';

		for (unsigned k = 1; k < m_levelStack.top(); ++k)
			m_strm << (m_lineBits.test(k) ? '|' : ' ') << ' ';
		
		bool hasAncestor(!m_parentStack.top()->isLastBranch());
		bool hasChildren(node.numBranches() > 0);

		m_strm << (hasAncestor ? (!m_transpositionLevel && hasChildren ? '+' : '|') : ' ');
	}
	
	unsigned lastBranchIndex = m_depthStack.top();

	mstl::string s;
	bool paren = false;

	for (unsigned i = lastBranchIndex; i < level(); ++i)
	{
		s.clear();
		s.append(' ');
		if (!isTrans && i == lastBranchIndex + 1 && node.numBranches() > 0)
		{
			s.append('(');
			paren = true;
		}
		if (mstl::is_even(i))
			s.format("%u.", mstl::div2(i) + 1);
		else if (i == lastBranchIndex)
			s.format("%u...", mstl::div2(i) + 1);
		m_branchStack[i]->move.printSAN(s, protocol::Scidb, encoding::Latin1);
		m_strm << s;
	}

	if (paren)
		m_strm << ')';

	Name const& lastName = *m_nameStack.top();
	Name const& currName = node.name();

	char const* comma = isTrans ? " -> " : " ";
	unsigned j = 1;

	while (j < lastName.size() && j < currName.size() && lastName.str(j) == currName.str(j))
		++j;

	for ( ; j < currName.size() && !currName.str(j).empty(); ++j)
	{
		m_strm << comma << currName.str(j);
		comma = ", ";
	}

	m_strm << '\n';
}


void TreeWriter::visit(Node const& node)
{
	if (m_branchStack.empty() || !node.shouldBeFinal())
		return;
	
	dumpLine(node);

	if (m_transpositionLevel)
	{
		m_break = true;
	}
	else
	{
		m_depthStack.top() = level();
		m_nameStack.top() = &node.name();
		m_parentStack.top() = node.startOfSequence();
		m_lineBits.put(++m_levelStack.top(), !m_parentStack.top()->isLastBranch());
	}
}


void TreeWriter::print(Node const* root)
{
	M_ASSERT(root);

	m_levelStack.push(0);
	m_depthStack.push(0);
	m_parentStack.push(root);
	m_nameStack.push(&root->name());
	m_lineBits.set(0);

	Writer::print(root);
}

// vi:set ts=3 sw=3:
