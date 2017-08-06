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

#ifndef _db_database_content_included
#define _db_database_content_included

#include "db_namebases.h"
#include "db_game_info.h"
#include "db_statistic.h"
#include "db_time.h"
#include "db_common.h"

#include "m_chunk_vector.h"
#include "m_vector.h"
#include "m_string.h"
#include "m_utility.h"

namespace db {

class DatabaseContent : public mstl::noncopyable
{
public:

	typedef type::ID Type;
	typedef mstl::chunk_vector<GameInfo> GameInfoList;

	DatabaseContent(	mstl::string const& filename,
							mstl::string const& encoding,
							Type type = type::Unspecific);
	DatabaseContent(mstl::string const& filename, DatabaseContent const& content);
	virtual ~DatabaseContent() throw();

	unsigned size() const;

	Namebase& namebase(Namebase::Type type);
	Namebase const& namebase(Namebase::Type type) const;

	mstl::string	m_rootname;
	mstl::string	m_suffix;
	GameInfoList	m_gameInfoList;
	Namebases		m_namebases;
	Type				m_type;
	variant::Type	m_variant;
	uint32_t			m_created;
	bool				m_readOnly;
	bool				m_writable;
	bool				m_memoryOnly;
	bool				m_temporary;
	bool				m_shouldCompact;
	mstl::string	m_description;
	mstl::string	m_encoding;
	Statistic*		m_statistic;
};

} // namespace db

#include "db_database_content.ipp"

#endif // _db_database_content_includedy

// vi:set ts=3 sw=3:
