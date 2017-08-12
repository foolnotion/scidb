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

#ifndef _eco_path_included
#define _eco_path_included

#include "db_transposition_path.h"

#include "m_vector.h"

namespace eco {

struct Path
{
public:

	enum { Max_Bits = db::TranspositionPath::Max_Bits };

	using BitLenghtList = db::TranspositionPath::BitLengths;

	Path();

	auto operator<(Path const& path) const -> bool;

	auto data() const -> db::TranspositionPath::Bits;
	auto bits() const -> db::TranspositionPath::Bits const&;

	auto length() const -> unsigned;

	void append(uint64_t bits);

	static auto bitLengthList() -> BitLenghtList const&;
	static void setBitLengthList(BitLenghtList const& bitLengthList);
	static void dumpBitLengths();

private:

	db::TranspositionPath m_path;

	static BitLenghtList m_bitLengthList;
};

} // namespace eco

#include "eco_path.ipp"

#endif // _eco_path_included

// vi:set ts=3 sw=3:
