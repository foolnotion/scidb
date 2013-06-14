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

namespace db {

class FileOffsets
{
public:

	struct Offset
	{
	public:

		Offset(unsigned offset);
		Offset(unsigned offset, unsigned variant, unsigned gameIndex);

		bool isGameIndex() const;

		unsigned offset() const;
		unsigned variant() const;
		unsigned gameIndex() const;

	private:

		uint32_t m_offset;
		uint32_t m_index:24;
		uint32_t m_variant:8;
	};

	typedef mstl::vector<Offset> Offsets;

	unsigned size() const;
	Offset const& get(unsigned index) const;

	void append(unsigned offset);
	void append(unsigned offset, unsigned variant, unsigned gameIndex);

	void reserve(unsigned n);

private:

	Offsets m_offsets;
};

} // namespace db

#include "db_file_offsets.ipp"

#endif // _db_file_offsets_included

// vi:set ts=3 sw=3:
