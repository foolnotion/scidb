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
#include "m_utility.h"

namespace db {

class FileOffsets : public mstl::noncopyable
{
public:

	struct Offset
	{
	public:

		Offset(unsigned offset, unsigned skipped);
		Offset(unsigned offset, unsigned variant, unsigned gameIndex);

		bool isGameIndex() const;
		bool isNumberOfSkippedGames() const;

		unsigned offset() const;
		unsigned variant() const;
		unsigned gameIndex() const;
		unsigned skipped() const;

	private:

		friend class FileOffsets;

		uint32_t m_offset;
		uint32_t m_index:24;
		uint32_t m_variant:8;
	};

	typedef mstl::vector<Offset> Offsets;

	FileOffsets();
	FileOffsets(FileOffsets const& fileOffsets);

	bool isEmpty() const;

	unsigned size() const;
	unsigned countGames() const;

	Offset const& get(unsigned index) const;

	void append(unsigned offset, unsigned skipped = 0);
	void append(unsigned offset, unsigned variant, unsigned gameIndex);
	void setSkipped(unsigned count);

	void reserve(unsigned n);

private:

	Offsets	m_offsets;
	unsigned	m_countSkipped;
};

} // namespace db

#include "db_file_offsets.ipp"

#endif // _db_file_offsets_included

// vi:set ts=3 sw=3:
