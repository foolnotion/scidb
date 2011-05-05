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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _si3_name_list_included
#define _si3_name_list_included

#include "m_string.h"
#include "m_vector.h"
#include "m_bitset.h"
#include "m_chunk_allocator.h"

namespace sys { namespace utf8 { class Codec; } }

namespace db {

class Namebase;
class NamebaseEntry;
class NamebasePlayer;
class NamebaseSite;

namespace si3 {

class NameList
{
public:

	struct Node
	{
		typedef NamebaseEntry Entry;

		Entry*			entry;
		mstl::string	encoded;
		unsigned			frequency;
		unsigned			id;
	};

	NameList(Namebase& base, sys::utf8::Codec& codec, mstl::bitset& usedIdSet);

	bool isEmpty() const;

	unsigned size() const;
	unsigned maxId() const;
	unsigned maxFrequency() const;
	unsigned lookup(unsigned id) const;

	Node const* first() const;
	Node const* next() const;

private:

	typedef mstl::vector<Node*> List;
	typedef List::const_iterator Iterator;

	typedef mstl::chunk_allocator<Node> NodeAlloc;
	typedef mstl::chunk_allocator<char> StringAlloc;
	typedef sys::utf8::Codec Codec;

	void buildList(Namebase& base, Codec& codec);
	void renumber(Namebase& base);

#ifdef SI3_NORMALIZE_ENTRIES
	void preparePlayer(NamebasePlayer const* entry, mstl::string const*& str);
	void prepareSite(NamebaseSite const* entry, mstl::string const*& str);
#endif

	void copyNode(Node* node, NamebaseEntry* entry);
	Node* makeNode(NamebaseEntry* entry, mstl::string const* str);

	mstl::bitset&		m_usedIdSet;
	mstl::bitset		m_newIdSet;
	List					m_list;
	unsigned				m_maxFrequency;
	unsigned				m_size;
	mutable Iterator	m_first;
	mutable Iterator	m_last;
	List					m_lookup;
	NodeAlloc			m_nodeAlloc;
	StringAlloc			m_stringAlloc;
	mstl::string		m_buf;
};

} // namespace si3
} // namespace db

namespace mstl
{
	template <typename> struct is_pod;
	template <> struct is_pod<db::si3::NameList::Node> { enum { value = 1 }; };
}

#include "si3_name_list.ipp"

#endif // _si3_name_list_included

// vi:set ts=3 sw=3:
