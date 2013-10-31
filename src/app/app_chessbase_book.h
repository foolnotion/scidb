// ======================================================================
// Author : $Author$
// Version: $Revision: 957 $
// Date   : $Date: 2013-09-30 17:11:24 +0200 (Mon, 30 Sep 2013) $
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

#ifndef _app_chessbase_book_included
#define _app_chessbase_book_included

#include "app_book.h"

#include "u_byte_stream.h"

namespace sys { namespace file { class Mapping; } }

namespace app {
namespace chessbase {

class Book : public app::Book
{
public:

	Book(mstl::string const& ctgFilename);
	~Book();

	bool isReadonly() const override;
	bool isOpen() const override;
	bool isEmpty() const override;

	Format format() const override;

	db::Move probeNextMove(db::Board const& position, db::variant::Type variant) override;
	bool probePosition(db::Board const& position, db::variant::Type variant, Entry& result) override;

	bool remove(db::Board const& position, db::variant::Type variant) override;
	bool modify(db::Board const& position, db::variant::Type variant, Entry const& entry) override;
	bool add(db::Board const& position, db::variant::Type variant, Entry const& entry) override;

private:

	class CTGEntry;

	typedef ::sys::file::Mapping Mapping;
	typedef ::util::ByteStream ByteStream;

	struct PageBounds
	{
		unsigned lower;
		unsigned upper;
	};

	int32_t getPageIndex(unsigned hash);

	Mapping*		m_ctgMapping;
	Mapping*		m_ctoMapping;
	ByteStream	m_ctgStrm;
	ByteStream	m_ctoStrm;
	PageBounds	m_pageBounds;
};

} // namespace chessbase
} // namespace app

#endif // _app_chessbase_book_included

// vi:set ts=3 sw=3:
