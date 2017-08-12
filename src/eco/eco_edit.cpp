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

#include "eco_line_reader.h"
#include "eco_text_reader.h"
#include "eco_line_writer.h"
#include "eco_text_writer.h"
#include "eco_tree_writer.h"
#include "eco_pgn_writer.h"
#include "eco_binary_writer.h"
#include "eco_node.h"

#include "db_board.h"

#include "si3/si3_stored_line.h"

#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_exception.h"
#include "m_string.h"

#include <stdio.h>
#include <stdlib.h>

using namespace eco;


auto main(int argc, char const* const argv[]) -> int
{
	mstl::string cmd(argc < 2 ? "" : argv[1]);

	if (	(	argc != 3
			|| (	cmd != "--copy"
				&& cmd != "--recover"
				&& cmd != "--complete"
				&& cmd != "--extend"
				&& cmd != "--test"
				&& cmd != "--binary"
				&& cmd != "--tree"
				&& cmd != "--pgn"))
		&& (argc != 4 || (cmd != "--merge" && cmd != "--build")))
	{
		fprintf(	stderr,
					"Usage: %s --{binary|complete|copy|extend|pgn|recover|test|tree} <eco-file>\n",
					argv[0]);
		fprintf(stderr, "Usage: %s --{build|merge} <eco-file> <more-eco-lines-file>\n", argv[0]);
		return 1;
	}

	cmd.erase(0u, 2u);

	db::Board::initialize();
	db::si3::StoredLine::initialize();

	mstl::ifstream strm(argv[2]);

	if (!strm)
	{
		fprintf(stderr, "Cannot read file '%s'\n", argv[2]);
		return 1;
	}

	if (argc == 4 && !mstl::ifstream(argv[3]))
	{
		fprintf(stderr, "Cannot read file '%s'\n", argv[3]);
		return 1;
	}

	Reader* reader = 0;
	Writer* writer = 0;

	unsigned flags = 0;

	if (cmd == "copy" || cmd == "extend" || cmd == "test")
	{
		reader = new LineReader(strm);
		flags = Node::Check_Ambiguity;
	}

	if (cmd == "merge")
	{
		reader = new LineReader(strm);
		flags = Node::Inherit_Name;
	}

	if (cmd == "pgn" || cmd == "build")
		reader = new LineReader(strm);

	if (cmd == "recover")
		reader = new TextReader(strm, TextReader::SkipInsertedLines);

	if (cmd == "binary" || cmd == "tree" || cmd == "complete")
		reader = new TextReader(strm);

	if (cmd == "copy" || cmd == "recover" || cmd == "merge" || cmd == "build" || cmd == "complete")
		writer = new LineWriter(mstl::cout);
	
	if (cmd == "extend")
		writer = new TextWriter(mstl::cout);
	
	if (cmd == "binary")
		writer = new BinaryWriter(mstl::cout);
	
	if (cmd == "tree")
		writer = new TreeWriter(mstl::cout);

	if (cmd == "pgn")
		writer = new PGNWriter(mstl::cout);

	M_ASSERT(reader);
	M_ASSERT(writer || cmd == "test");

	try
	{
		Node* root = Node::parse(*reader, flags);

		if (cmd == "copy" || cmd == "extend" || cmd == "test")
		{
			bool rc = root->checkLines();

			if (rc)
				root->checkTranspositions();

			if (!rc || reader->countConflicts() || root->hasClash())
				M_RAISE("aborted due to conflicts");
		}

		if (cmd == "extend")
		{
			root->extend();
			root->checkLines();
			root->checkUnusedRules();
			//root->checkTranspositions();
			root->sortBranches();
			root->renumber();
		}

		if (cmd == "merge")
		{
			mstl::ifstream strm2(argv[3]);
			LineReader reader2(strm2, LineReader::Ignore_ECO);
			root->buildBypasses();
			Node::parse(reader2, root, Node::Merge_Line | Node::Inherit_Name);
		}

		if (cmd == "build")
		{
			mstl::ifstream strm2(argv[3]);
			LineReader reader2(strm2, LineReader::Ignore_ECO);
			Node::parse(reader2, root, Node::Merge_Line);
		}

		if (cmd == "complete")
		{
			root->buildBypasses();
			root->refineClassification();
		}

		if (cmd == "binary")
		{
			root->findUnresolvedNodes();
//			root->buildBypasses();
			root->sortBranches();
			root->refineClassification();
			root->enumerateTranspositionPaths();
		}

		if (cmd == "tree")
		{
			root->findUnresolvedNodes();
			root->sortBranches();
			root->refineClassification();
		}

		if (writer)
			writer->print(root);
	}
	catch (mstl::exception const& exc)
	{
		fflush(stdout);
		fprintf(stderr, "\n%s\n", exc.what());
		exit(1);
	}

	return 0;
}

// vi:set ts=3 sw=3:
