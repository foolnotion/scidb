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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_database_content.h"
#include "db_game_info.h"

#include "u_misc.h"

using namespace db;
using namespace util;


DatabaseContent::~DatabaseContent() throw() {}


DatabaseContent::DatabaseContent(mstl::string const& filename, mstl::string const& encoding, Type type)
	:m_rootname(misc::file::rootname(filename))
	,m_suffix(misc::file::suffix(filename))
	,m_type(type)
	,m_variant(variant::Undetermined)
	,m_created(0)
	,m_readOnly(false)
	,m_writable(true)
	,m_memoryOnly(false)
	,m_temporary(false)
	,m_shouldCompress(false)
	,m_encoding(encoding)
	,m_allocator(32768)
{
}


DatabaseContent::DatabaseContent(mstl::string const& filename, DatabaseContent const& content)
	:m_rootname(misc::file::rootname(filename))
	,m_suffix(misc::file::suffix(filename))
	,m_type(content.m_type)
	,m_variant(content.m_variant)
	,m_created(content.m_created)
	,m_readOnly(content.m_readOnly)
	,m_writable(content.m_writable)
	,m_memoryOnly(content.m_memoryOnly)
	,m_temporary(content.m_temporary)
	,m_shouldCompress(false)
	,m_description(content.m_description)
	,m_encoding(content.m_encoding)
	,m_allocator(32768)
{
}

// vi:set ts=3 sw=3:
