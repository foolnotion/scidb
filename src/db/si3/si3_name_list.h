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

	NameList();

	bool isEmpty() const;

	unsigned size() const;
	unsigned maxFrequency() const;
	Node const* lookup(unsigned id) const;

	Node const* first() const;
	Node const* next() const;

#ifdef DEBUG_SI4
	Node* back();
#endif

	void append(mstl::string const& originalName, NamebaseEntry* entry, sys::utf8::Codec& codec);
	void add(unsigned originalId, NamebaseEntry* entry);
	void update(Namebase& base, sys::utf8::Codec& codec);
	void reserve(unsigned size);

private:

	typedef mstl::vector<Node*> List;
	typedef List::const_iterator Iterator;

	typedef mstl::chunk_allocator<Node> NodeAlloc;
	typedef mstl::chunk_allocator<char> StringAlloc;
	typedef sys::utf8::Codec Codec;

	void buildList(Namebase& base, Codec& codec);
	void renumber();
	void adjustListSize();

	void reuseNode(Node* node, NamebaseEntry* entry);
	Node* newNode(NamebaseEntry* entry, mstl::string const* str, unsigned id);
	Node* makeNode(NamebaseEntry* entry, mstl::string const* str);

	mstl::bitset		m_usedIdSet;
	mstl::bitset		m_newIdSet;
	List					m_list;
	List					m_lookup;
	List					m_access;
	unsigned				m_maxFrequency;
	unsigned				m_size;
	unsigned				m_nextId;
	mutable Iterator	m_first;
	mutable Iterator	m_last;
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
