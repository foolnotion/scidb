// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_file_offsets_included
#define _db_file_offsets_included

#include "db_common.h"

#include "m_vector.h"
#include "m_bitset.h"

namespace db {

class FileOffsets
{
public:

	typedef mstl::vector<unsigned> Offsets;
	typedef mstl::bitset IndexMap;

	void resize(unsigned n);
	void append(unsigned offset);
	void setIndex(unsigned variant, unsigned gameIndex);

private:

	typedef IndexMap Maps[variant::NumberOfVariants];

	Offsets	m_offsets;
	Maps		m_indexMap;
};

} // namespace db

#include "db_file_offsets.ipp"

#endif // _db_file_offsets_included

// vi:set ts=3 sw=3:
