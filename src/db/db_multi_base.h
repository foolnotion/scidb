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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_multi_base_included
#define _db_multi_base_included

#include "db_common.h"

#include "m_string.h"

namespace util { class Progress; }

namespace db {

class Producer;
class Database;

class MultiBase
{
public:

	typedef type::ID Type;
	typedef format::Type Format;
	typedef unsigned GameCount[variant::NumberOfVariants];

	MultiBase(	mstl::string const& name,
					mstl::string const& encoding,
					Producer& producer,
					util::Progress& progress);
	MultiBase(	mstl::string const& name,
					mstl::string const& encoding,
					permission::Mode mode,
					util::Progress& progress);
	MultiBase(	mstl::string const& name,
					mstl::string const& encoding,
					variant::Type variant,
					storage::Type storage = storage::MemoryOnly,
					Type type = type::Unspecific);
	~MultiBase();

	bool isEmpty() const;
	bool isEmpty(variant::Type variant) const;
	bool isEmpty(unsigned variantIndex) const;
	bool exists(variant::Type variant) const;
	bool exists(unsigned variantIndex) const;
	bool isSingleBase() const;

	/// Returns the (decoding) format of database
	Format format() const;
	/// Returns the variant of the leading database.
	variant::Type variant() const;
	/// Returns the leading database
	Database* database();
	/// Returns the specified database
	Database* database(variant::Type variant);
	/// Returns the specified database
	Database* database(unsigned variantIndex);
	/// Count total number of games.
	unsigned countGames() const;
	/// Count games of each variant, and return total number of games.
	unsigned countGames(GameCount& result) const;

	/// Close all underlying databases.
	void close();
	/// Close database of given variant.
	void close(variant::Type variant);
	/// Change the variant.
	void changeVariant(variant::Type variant);
	/// Import games from given producer.
	unsigned importGames(Producer& producer, util::Progress& progress, GameCount* count = 0);

private:

	typedef Database* Bases[variant::NumberOfVariants];

	Bases			m_bases;
	Database*	m_leader;
	bool			m_singleBase;
};

} // namespace db

#include "db_multi_base.ipp"

#endif // _db_multi_base_included

// vi:set ts=3 sw=3:
