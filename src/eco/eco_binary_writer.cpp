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

#include "eco_binary_writer.h"
#include "eco_node.h"
#include "eco_name.h"

#include "db_eco_table.h"

#include "u_byte_stream.h"

#include "m_ostream.h"

#ifdef NREQ
# define DEBUG(expr)
#else
# define DEBUG(expr) expr
#endif

using namespace eco;
using namespace db;
using namespace util;


BinaryWriter::BinaryWriter(mstl::ostream& strm)
	:Writer(strm)
{
}


auto BinaryWriter::branch(Branch const& branch) -> bool
{
	return !branch.transposition;
}


void BinaryWriter::visit(Node const& node)
{
	M_ASSERT(node.key());
	M_ASSERT(node.id());
	M_ASSERT(!m_info.test(node.key()));
	M_ASSERT((uint32_t(node.key()) & 0xffffff00) == 0);
	M_ASSERT((uint32_t(node.backlinks().size()) & 0xffffff80) == 0);
	M_ASSERT((uint32_t(node.ref()) & 0xfffff000) == 0);
	M_ASSERT((uint32_t(node.numBranches()) & 0xffffffe0) == 0);
	M_ASSERT((uint32_t(node.numBypasses()) & 0xfffffff8) == 0);
	M_ASSERT(node.successors().size() <= 20);

	DEBUG(m_info.set(node.key()));

	unsigned char buf[3];
	ByteStream bstrm(buf, sizeof(buf));

	bstrm << uint16_t(node.key());
	m_strm.write(buf, 2);

	bool isMainKey = node.key() <= Node::countMainCodes();

	m_strm.put(node.backlinks().size() | (isMainKey << 7));

	if (isMainKey)
	{
		uint16_t ecoCode = node.id().asShort();

		if (node.id().isBasicCode() && !m_ecoCodes.test_and_set(ecoCode))
			ecoCode |= 0x8000;

		bstrm.resetp();
		bstrm << ecoCode;
		m_strm.write(buf, 2);

		bstrm.resetp();
		bstrm << uint16_t(node.ref());
		m_strm.write(buf, 2);
	}

	for (unsigned i = 0; i < node.backlinks().size(); ++i)
	{
		bstrm.resetp();
		bstrm << uint16_t(node.backlink(i).key());
		m_strm.write(buf, 2);
	}

	m_strm.put(node.numBranches() | (node.numBypasses() << 5));

	for (auto const& branch : node.successors())
	{
		M_ASSERT((branch.move.index() & 0xf000) == 0);

		uint16_t move	= uint16_t(branch.move.index())
							| (uint16_t(branch.useBits) << 14)
							| (uint16_t(branch.transposition) << 15);

		if (branch.bypass)
			move |= uint16_t(1) << 13;

		bstrm.resetp();
		bstrm << move << uint8_t(branch.weight);
		m_strm.write(buf, 3);

		if (branch.useBits)
		{
			M_ASSERT((branch.bits & 0x80) == 0);
			m_strm.put(branch.bits);
		}
	}
}


void BinaryWriter::print(Node const* root)
{
	unsigned numCodes = root->countCodes();

	DEBUG(m_info.resize(numCodes));
	DEBUG(m_info.set(0));

	m_ecoCodes.resize(Id::Num_Basic_Codes + 1);
	m_ecoCodes.set(0);

	m_strm.write("eco.bin", 8);

	unsigned char buf[28];
	ByteStream bstrm(buf, sizeof(buf));

	bstrm << uint16_t(EcoTable::FileVersion);
	bstrm << uint16_t(numCodes);
	bstrm << uint32_t(root->countMoves());
	bstrm << uint32_t(root->countBranches());
	bstrm << uint16_t(root->countBacklinks());
	bstrm << uint32_t(root->countLines());
	bstrm << uint16_t(Name::countStrings());
	bstrm << uint16_t(Name::countNames());
	bstrm << uint16_t(Name::countChars());
	bstrm << uint16_t(root->countMainCodes());
	bstrm << uint16_t(root->countMaxPathNodes());

	m_strm.write(buf, sizeof(buf));
	Name::dump(m_strm);
	Writer::print(root);
}

// vi:set ts=3 sw=3:
