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

#include "si3_name_list.h"

#include "db_namebase.h"

#include "sys_utf8_codec.h"

#include "m_algorithm.h"
#include "m_string.h"
#include "m_assert.h"

#include <ctype.h>

using namespace db::si3;


namespace db {
namespace si3 {

// This is the implementation of Scid's weird comparison behaviour.
// Why does it not use strcmp()?
static int
compare(char const* lhs, char const* rhs)
{
	if (*rhs == 0)
		return int(Byte(*lhs));

	if (*lhs != *rhs)
		return int(Byte(*lhs)) - int(Byte(*rhs));

	for (++rhs, ++lhs; *rhs; ++lhs, ++rhs)
	{
		if (*lhs != *rhs)
			return int(*lhs) - int(*rhs);
	}

	return int(*lhs);
}


__attribute__((unused))
static void
appendSpace(mstl::string& str)
{
	if (!str.empty())
		str += ' ';
}


inline
static bool
operator<(NameList::Node* lhs, mstl::string const& rhs)
{
	return compare(lhs->encoded.c_str(), rhs.c_str()) < 0;
}

} // namespace si3
} // namespace db


NameList::NameList()
	:m_maxFrequency(0)
	,m_maxId(0)
	,m_nextId(0)
	,m_first(0)
	,m_last(0)
	,m_nodeAlloc(32768)
	,m_stringAlloc(32768)
{
}


NameList::Node const*
NameList::first() const
{
	M_ASSERT(m_list.size() == size());
	M_ASSERT(m_usedIdSet.count() == size());

	m_first = m_list.begin();
	m_last = m_list.end();

	return m_first == m_last ? 0 : *m_first;
}


void
NameList::reserve(unsigned size)
{
	m_usedIdSet.resize(size);
	m_lookup.resize(size);
	m_access.resize(size);
}


void
NameList::update(Namebase& base, sys::utf8::Codec& codec)
{
	M_REQUIRE(codec.hasEncoding());

	m_maxFrequency = 0;

	for (unsigned i = 0; i < m_list.size(); ++i)
	{
		m_list[i]->entry = 0;
		m_list[i]->frequency = 0;
	}

	if (base.nextId() > m_lookup.size())
		reserve(base.nextId());

	for (unsigned i = 0; i < base.size(); ++i)
	{
		// XXX but this entry may still remain in namebase!
		if (base.entryAt(i)->frequency() == 0)
			m_usedIdSet.reset(base.entryAt(i)->id());
	}

	m_nextId = m_usedIdSet.find_first_not();

#ifndef NDEBUG
	m_lookup.fill(0);
#endif

	buildList(base, codec);
	renumber();
	adjustListSize();
}


void
NameList::renumber()
{
	unsigned count = m_usedIdSet.count();

	if (count == 0)
	{
		m_maxId = 0;
		m_nextId = 0;
		m_list.clear();
		m_usedIdSet.clear();
		m_stringAlloc.clear();
		m_nodeAlloc.clear();
	}
	else
	{
		unsigned expectedMaxId = m_usedIdSet.find_last();

		m_maxId = expectedMaxId + 1;

		if (expectedMaxId < count)
			return;

		unsigned wantedId = m_usedIdSet.find_first_not();

		for (	unsigned id = m_usedIdSet.find_next(expectedMaxId);
				id != mstl::bitset::npos;
				id = m_usedIdSet.find_next(id))
		{
			Node* node = m_access[id];

			M_ASSERT(node);
			M_ASSERT(node->id == id);
			M_ASSERT(wantedId != mstl::bitset::npos);

			node->id = wantedId;
			m_usedIdSet.reset(id);
			m_usedIdSet.set(wantedId);
			m_access[wantedId] = node;
			wantedId	= m_usedIdSet.find_next_not(wantedId);
		}

		m_maxId = m_usedIdSet.find_last() + 1;
	}
}


void
NameList::adjustListSize()
{
	unsigned count = m_usedIdSet.count();

	M_ASSERT(count <= m_maxId);

	if (m_list.size() == m_maxId && count == m_maxId)
		return;

	List::reverse_iterator e = m_list.rend();

	unsigned id = mstl::bitset::npos;

	for (List::reverse_iterator i = m_list.rbegin(); i != e; ++i)
	{
		if ((*i)->entry == 0)
		{
			if (m_list.size() > m_maxId)
			{
				m_list.erase(i.base());

				if (m_list.size() == m_maxId && count == m_maxId)
					return;
			}
			else if (count < m_maxId)
			{
				if (id == mstl::bitset::npos)
					id = m_usedIdSet.find_first_not();
				else
					id = m_usedIdSet.find_next_not(id);

				M_ASSERT(id != mstl::bitset::npos);

				(*i)->id = id;
				m_usedIdSet.set(id);

				if (++count == m_maxId && m_list.size() == m_maxId)
					return;
			}
		}
	}

	M_ASSERT(m_list.size() == size());
	M_ASSERT(m_usedIdSet.count() == size());
}


NameList::Node*
NameList::newNode(NamebaseEntry* entry, mstl::string const* str, unsigned id)
{
	Node* node = m_nodeAlloc.alloc();

	node->entry = entry;
	node->frequency = entry->frequency();
	node->id = id;

	m_lookup[entry->id()] = m_access[id] = node;

	if (node->frequency > m_maxFrequency)
		m_maxFrequency = node->frequency;

	if (str == &m_buf)
	{
		char* s = m_stringAlloc.alloc(m_buf.size() + 1);
		node->encoded.hook(s, m_buf.size());
		::memcpy(s, m_buf.c_str(), m_buf.size() + 1);
	}
	else
	{
		node->encoded.hook(const_cast<char*>(entry->name().c_str()), entry->name().size());
	}

	return node;
}


NameList::Node*
NameList::makeNode(NamebaseEntry* entry, mstl::string const* str)
{
	unsigned id = m_nextId;

	if (id == mstl::bitset::npos || m_usedIdSet.size() <= id)
	{
		unsigned n = m_usedIdSet.size();

		id = n;
		m_usedIdSet.resize(n + mstl::max(50u, (n*9)/10));
		m_access.resize(m_usedIdSet.size());
	}

	m_usedIdSet.set(id);
	m_nextId = m_usedIdSet.find_next_not(m_nextId);
	return newNode(entry, str, id);
}


void
NameList::reuseNode(Node* node, NamebaseEntry* entry)
{
	node->entry = entry;
	m_lookup[entry->id()] = node;
	m_usedIdSet.set(node->id);

	if ((node->frequency += entry->frequency()) > m_maxFrequency)
		m_maxFrequency = node->frequency;
}


void
NameList::addEntry(unsigned originalId, NamebaseEntry* entry)
{
	M_ASSERT(m_lookup[originalId]);

	unsigned id = entry->id();

	if (id >= m_lookup.size())
		m_lookup.resize(id + mstl::max(50u, (id*9)/10));

	m_lookup[id] = m_lookup[originalId];
}


void
NameList::append(	mstl::string const& originalName,
						unsigned id,
						NamebaseEntry* entry,
						sys::utf8::Codec& codec)
{
	if (m_list.empty() || originalName != m_list.back()->encoded)
	{
		mstl::string const* str;

		if (entry->name() == originalName)
		{
			str = 0;
		}
		else
		{
			m_buf.assign(originalName);
			str = &m_buf;
		}

		m_list.push_back(newNode(entry, str, id));
	}

	m_usedIdSet.set(id);
	m_lookup[id] = m_list.back();
	m_maxId = mstl::max(m_maxId, id + 1);
}


void
NameList::buildList(Namebase& base, Codec& codec)
{
	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebaseEntry* entry = base.entryAt(i);

		if (entry->used())
		{
			M_ASSERT(entry->id() < base.nextId());

			mstl::string const* str;

			if (Codec::is7BitAscii(entry->name()))
			{
				str = &entry->name();
			}
			else
			{
				codec.convertFromUtf8(entry->name(), m_buf);
				if (m_buf.size() >= 256)
					m_buf.set_size(255);
				str = &m_buf;
			}

			M_ASSERT(str->size() < 256);

			if (m_list.empty())
			{
				m_list.push_back(makeNode(entry, str));
			}
			else
			{
				int cmp = ::compare(m_list.back()->encoded.c_str(), *str);

				if (cmp < 0)
				{
					m_list.push_back(makeNode(entry, str));
				}
				else if (cmp > 0)
				{
					List::iterator i = mstl::lower_bound(m_list.begin(), m_list.end(), *str);

					if (i == m_list.end())
						m_list.push_back(makeNode(entry, str));
					else if (::compare((*i)->encoded.c_str(), *str) != 0)
						m_list.insert(m_list.begin() + (i - m_list.begin()), makeNode(entry, str));
					else
						reuseNode(*i, entry);
				}
				else // cmp == 0
				{
					reuseNode(m_list.back(), entry);
				}
			}
		}
	}
}

// vi:set ts=3 sw=3:
