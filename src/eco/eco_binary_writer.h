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

#ifndef _eco_binary_writer_included
#define _eco_binary_writer_included

#include "eco_writer.h"

#include "m_bitset.h"

namespace eco {

class BinaryWriter : public Writer
{
public:

	BinaryWriter(mstl::ostream& strm);

	void visit(Node const& node) override;
	auto branch(Branch const& branch) -> bool override;
	void print(Node const* root) override;

private:

	mstl::bitset m_ecoCodes;
#ifndef NREQ
	mstl::bitset m_info;
#endif
};

} // namespace eco

#endif // _eco_binary_writer_included

// vi:set ts=3 sw=3:
