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

#include "si3_name_list.h"

#include "db_namebase.h"

#include "sys_utf8_codec.h"

#include "m_algorithm.h"
#include "m_string.h"
#include "m_utility.h"
#include "m_pair.h"
#include "m_map.h"
#include "m_assert.h"

#include <ctype.h>

using namespace db::si3;


static unsigned const InvalidId = unsigned(-1);


namespace db {
namespace si3 {

// This is the implementation of Scid's
// asymmetric (and weird) comparison behaviour.
static int
compare(char const* lhs, char const* rhs)
{
	if (*rhs == 0)
		return -int(Byte(*lhs));

	if (*rhs != *lhs)
		return int(Byte(*lhs)) - int(Byte(*rhs));

	for (++rhs, ++lhs; *rhs; ++lhs, ++rhs)
	{
		if (*rhs != *lhs)
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


NameList::NameList(Namebase& base, sys::utf8::Codec& codec, mstl::bitset& usedIdSet)
	:m_usedIdSet(usedIdSet)
	,m_newIdSet(base.nextId())
	,m_maxFrequency(0)
	,m_size(0)
	,m_first(0)
	,m_last(0)
	,m_nodeAlloc(32768)
	,m_stringAlloc(32768)
{
	M_REQUIRE(codec.hasEncoding());

	m_nodeAlloc.set_zero();
	m_lookup.resize(base.nextId());
	m_list.reserve(base.nextId());

	if (m_usedIdSet.size() < base.nextId())
		m_usedIdSet.resize(base.nextId());

	buildList(base, codec);
	renumber(base);
	m_usedIdSet.swap(m_newIdSet);

	M_ASSERT(m_size <= m_list.size());

	m_first = m_list.begin();
	m_last = m_first + m_size;
}


void
NameList::renumber(Namebase& base)
{
	typedef mstl::map<unsigned,unsigned> ChangedMap;

	unsigned count = m_newIdSet.count();

	if (count == 0)
		return;

	unsigned expectedMaxId	= count - 1;
	unsigned maxUsedId		= (m_usedIdSet & m_newIdSet).find_last();

	if (maxUsedId != mstl::bitset::npos && maxUsedId > expectedMaxId)
		expectedMaxId = maxUsedId;

	Namebase::EntryMap map;
	mstl::bitset exchangeSet(m_newIdSet.size());
	mstl::bitset changedSet(m_newIdSet.size());
	ChangedMap changedMap;
	List* entryList = 0;

	for (	unsigned id = m_newIdSet.find_next(expectedMaxId);
			id != mstl::bitset::npos;
			id = m_newIdSet.find_next(id))
	{
		unsigned wantedId = m_newIdSet.find_first_not();

		M_ASSERT(wantedId < id);

		if (entryList == 0)
		{
			entryList = new List(m_newIdSet.size());

			for (unsigned i = 0; i < m_list.size(); ++i)
			{
				unsigned id = m_list[i]->id;

				M_ASSERT(m_lookup[m_list[i]->entry->id()]);
				M_ASSERT((*entryList)[id] == 0);

				(*entryList)[id] = m_list[i];
			}
		}

		M_ASSERT((*entryList)[id]);

		Node*		node		= (*entryList)[id];
		unsigned	mappedId	= m_lookup[wantedId]->id;

		changedMap[id] = mappedId;
		changedMap[wantedId] = wantedId;
		changedSet.set(id);
		changedSet.set(wantedId);

		exchangeSet.set(wantedId);
		map[wantedId] = node->entry;

		node->id = wantedId;
		m_newIdSet.reset(id);
		m_newIdSet.set(wantedId);
	}

	if (entryList)
	{
		delete entryList;
		base.exchangeId(exchangeSet, map);
		m_size = m_newIdSet.find_last();

		if (m_size == mstl::bitset::npos)
			m_size = 0;
		else
			++m_size;
	}
	else
	{
		m_size = expectedMaxId + 1;
	}
}


NameList::Node*
NameList::makeNode(NamebaseEntry* entry, mstl::string const* str)
{
	Node* node = m_nodeAlloc.alloc();

	node->entry = entry;
	node->frequency = entry->frequency();

	m_newIdSet.set(node->id = entry->id());
	m_lookup[node->id] = node;

	if (node->id >= m_size)
		m_size = node->id + 1;

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


void
NameList::copyNode(Node* node, NamebaseEntry* entry)
{
	unsigned oldId = node->id;

	if (!m_usedIdSet.test(oldId) && entry->id() < oldId)
	{
		m_newIdSet.reset(oldId);
		m_newIdSet.set(node->id = entry->id());
		node->entry = entry;

		if (node->id >= m_size)
			m_size = node->id + 1;
	}

	m_lookup[entry->id()] = node;

	if ((node->frequency += entry->frequency()) > m_maxFrequency)
		m_maxFrequency = node->frequency;
}


void
NameList::buildList(Namebase& base, Codec& codec)
{
	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebaseEntry* entry = base.entryAt(i);

		if (entry->id() < base.nextId())
		{
			mstl::string const* str;

			if (entry->frequency() > m_maxFrequency)
				m_maxFrequency = entry->frequency();

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

#ifdef SI3_NORMALIZE_ENTRIES
			switch (int(base.type()))
			{
				case Namebase::Site:
					prepareSite(static_cast<NamebaseSite const*>(entry), str);
					break;

				case Namebase::Player:
					preparePlayer(static_cast<NamebasePlayer const*>(entry), str);
					break;
			}
#endif

			M_ASSERT(str->size() < 256);

			if (m_list.empty())
			{
				m_list.push_back(makeNode(entry, str));
			}
			else
			{
				int cmp = ::compare(m_list.back()->encoded.c_str(), str->c_str());

				if (cmp < 0)
				{
					m_list.push_back(makeNode(entry, str));
				}
				else if (cmp > 0)
				{
					List::iterator i = mstl::lower_bound(m_list.begin(), m_list.end(), *str);

					if (i == m_list.end())
						m_list.push_back(makeNode(entry, str));
					else if (::compare((*i)->encoded.c_str(), str->c_str()) != 0)
						m_list.insert(m_list.begin() + (i - m_list.begin()), makeNode(entry, str));
					else
						copyNode(*i, entry);
				}
				else // cmp == 0
				{
					copyNode(m_list.back(), entry);
				}
			}
		}
	}
}


#ifdef SI3_NORMALIZE_ENTRIES

void
NameList::preparePlayer(NamebasePlayer const* entry, mstl::string const*& str)
{
	M_ASSERT(entry);
	M_ASSERT(str);

	if (entry->haveSex())
	{
		M_ASSERT(entry->sex() != sex::Unspecified);

		if (str->size() < (256 - 4))
		{
			if (str != &m_buf)
			{
				m_buf = *str;
				str = &m_buf;
			}

			::appendSpace(m_buf);
			m_buf += '(';
			m_buf += sex::toChar(entry->sex());
			m_buf += ')';
		}
	}

	if (entry->haveType() && entry->type() == species::Program)
	{
		if (str->size() < (256 - 11))
		{
			if (str != &m_buf)
			{
				m_buf = *str;
				str = &m_buf;
			}

			::appendSpace(m_buf);
			m_buf += "(computer)";
		}
	}

	if (entry->haveTitle())
	{
		M_ASSERT(entry->title() != title::None);

		mstl::string const& title = title::toString(entry->title());

		if (str->size() < 255 - title.size())
		{
			if (str != &m_buf)
			{
				m_buf = *str;
				str = &m_buf;
			}

			::appendSpace(m_buf);
			m_buf += title;
		}
	}

	if (entry->haveFederation())
	{
		M_ASSERT(entry->federation() != country::Unknown);

		if (str->size() < (256 - 6))
		{
			if (str != &m_buf)
			{
				m_buf = *str;
				str = &m_buf;
			}

			::appendSpace(m_buf);
			m_buf += '(';
			m_buf += country::toString(entry->federation());
			m_buf += ')';
		}
	}
}


void
NameList::prepareSite(NamebaseSite const* entry, mstl::string const*& str)
{
	M_ASSERT(entry);
	M_ASSERT(str);

	if (entry->country() != country::Unknown && str->size() < 256 - 4)
	{
		char const* country = country::toString(entry->country());

		unsigned n = str->find(country);

		if (	n == mstl::string::npos
			|| (n == 0
					? str->size() > 3 && ::isalnum(str->at(3))
					: 	::isalnum(str->at(n - 1))
					|| (n + 3 < str->size() && ::isalnum(str->at(n + 3)))))
		{
			if (str != &m_buf)
			{
				m_buf = *str;
				str = &m_buf;
			}

			M_ASSERT(::strlen(country) == 3);

			::appendSpace(m_buf);
			m_buf.append(country, 3);
		}
	}
}

#endif

// vi:set ts=3 sw=3:
