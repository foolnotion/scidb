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

#include "eco_pgn_writer.h"
#include "eco_node.h"

#include "m_ostream.h"

using namespace eco;


PGNWriter::PGNWriter(mstl::ostream& strm) :Writer(strm), m_eco("A00") {}


auto PGNWriter::branch(Branch const& branch) -> bool
{
	return !branch.node->alreadyDone() && !branch.codes.empty() && branch.codes.test(m_eco.basic());
}


void PGNWriter::visit(Node const& node)
{
	if (node.id().basic() == m_eco.basic() && node.shouldBeFinal())
	{
		mstl::string eco(m_eco.asShortString());
		mstl::string var;
		mstl::string line;

		node.line().dump(line);
		node.line().print(var);

		m_strm << "[Event \"" << eco << "\"]\n";
		m_strm << "[Site \"?\"]\n";
		m_strm << "[Date \"????.??.??\"]\n";
		m_strm << "[Round \"?\"]\n";
		m_strm << "[White \"" << node.name().opening() << "\"]\n";
		m_strm << "[Black \"" << var << "\"]\n";
		m_strm << "[Result \"*\"]\n";
		m_strm << "[ECO \"" << eco << "\"]\n\n";
		m_strm << line << " *\n\n";
	}
}


void PGNWriter::print(Node const* root)
{
	M_REQUIRE(root);

	m_strm << "\0xef\0xbb\0xbf";

	for (unsigned code = 0; code < 500; ++code)
	{
		m_eco = Id(code, 0);
		Writer::print(root);
	}
}

// vi:set ts=3 sw=3:
