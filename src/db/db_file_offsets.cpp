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

#include "db_file_offsets.h"

using namespace db;


FileOffsets::FileOffsets(FileOffsets const& fileOffsets)
	:m_countSkipped(fileOffsets.m_countSkipped)
{
	if (!fileOffsets.isEmpty())
		m_offsets.assign(fileOffsets.m_offsets.begin(), fileOffsets.m_offsets.end() - 1);
}

// vi:set ts=3 sw=3:
