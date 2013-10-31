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

#ifndef _app_polyglot_book_included
#define _app_polyglot_book_included

#include "app_book.h"

namespace sys  { namespace file { class Mapping; } }
namespace mstl { template <typename Key, typename Value> class hash; }
namespace mstl { class ifstream; }

namespace app {
namespace polyglot {

class Book : public app::Book
{
public:

	Book(mstl::string const& filename);
	~Book();

	bool isReadonly() const override;
	bool isOpen() const override;
	bool isEmpty() const override;
	bool isModified() const override;
	bool isPersistent() const override;

	Format format() const override;

	db::Move probeNextMove(db::Board const& position, db::variant::Type variant) override;
	bool probePosition(db::Board const& position, db::variant::Type variant, Entry& result) override;

	bool remove(db::Board const& position, db::variant::Type variant) override;
	bool modify(db::Board const& position, db::variant::Type variant, Entry const& entry) override;
	bool add(db::Board const& position, db::variant::Type variant, Entry const& entry) override;

private:

	typedef sys::file::Mapping Mapping;
	typedef mstl::hash<uint64_t, Entry> Map;

	struct MyEntry
	{
		uint64_t key;
		uint16_t move;
		uint16_t weight;
		uint16_t n;
		uint16_t sum;

		void fill(db::Byte const* src);
		void write(db::Byte* dst) const;
	};

	bool readEntry(unsigned offset, MyEntry& entry);
	void writeEntry();
	unsigned findKey(uint64_t key);
	void readScidMaskFile(mstl::ifstream& strm);

	Format	m_format;
	Mapping*	m_mapping;
	Map*		m_entryMap;
	unsigned	m_bookSize;
	unsigned	m_currentOffs;
	MyEntry	m_current;
	bool		m_someRemoved;
	bool		m_someModified;
	unsigned	m_used;
};

} // namespace polyglot
} // namespace app

#endif // _app_polyglot_book_included

// vi:set ts=3 sw=3:
