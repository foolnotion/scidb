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

#include "db_move.h"

#include "u_byte_stream.h"
#include "u_rkiss.h"

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

	db::Move probeMove(db::Board const& position, db::variant::Type variant, Choice choice) override;
	bool probePosition(db::Board const& position, db::variant::Type variant, Entry& result) override;

	class CTGEntry;
	class CTGSignature;

private:

	typedef ::sys::file::Mapping Mapping;
	typedef ::util::ByteStream ByteStream;

	struct PageBounds
	{
		unsigned lower;
		unsigned upper;
	};

	bool getEntry(db::Board const& pos, CTGEntry& entry);
	bool lookupEntry(unsigned pageIndex, CTGSignature const& sig, CTGEntry& entry);
	bool fillEntry(uint8_t const* data, CTGEntry& entry);

	int32_t getPageIndex(unsigned hash);

	db::Move pickMove(db::Board const& pos, CTGEntry& entry, Choice choice);
	uint64_t moveWeight(db::Board const& pos, db::Move move, uint8_t annotation, bool& recommended);

	Mapping*		m_ctgMapping;
	Mapping*		m_ctoMapping;
	ByteStream	m_ctgStrm;
	ByteStream	m_ctoStrm;
	PageBounds	m_pageBounds;
	util::RKiss	m_rkiss;
};

} // namespace chessbase
} // namespace app

#endif // _app_chessbase_book_included

// vi:set ts=3 sw=3:
