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
#include "m_assert.h"

#include <ctype.h>

using namespace db::si3;


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


//static void
//appendSpace(mstl::string& str)
//{
//	if (!str.empty())
//		str += ' ';
//}


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

	if (usedIdSet.size() < base.nextId())
		usedIdSet.resize(base.nextId());

	switch (base.type())
	{
		case Namebase::Player:	insertPlayers(base, codec); break;
		case Namebase::Site:		insertSites(base, codec); break;
		case Namebase::Event:	insertEvents(base, codec); break;
		case Namebase::Round:	insertRounds(base, codec);

		default: M_ASSERT(!"unexpected base type");
	}

	M_ASSERT(m_size <= m_list.size());

	m_first = m_list.begin();
	m_last = m_first + m_size;

	// TODO: handle entries in (m_newIdSet - m_usedIdSet)
	// TODO: handle entries in (m_usedIdSet - m_newIdSet)
	// TODO: handle entries with id >= m_newIdSet.count()
}


NameList::Node*
NameList::makeNode(NamebaseEntry* entry, mstl::string const* str)
{
	Node* node = m_nodeAlloc.alloc();

	node->entry = entry;
	node->frequency = entry->frequency();

//	if (!m_usedIdSet.test(entry->id()))
//	{
//		unsigned id = m_usedIdSet.find_first_not();
//
//		if (id != mstl::bitset::npos)
//		{
//			m_base.replaceId(entry, id);
//			m_usedIdSet.reset(entry->id());
//			m_usedIdSet.set(id);
//		}
//	}

	m_newIdSet.set(entry->id());
	node->id = entry->id() + 1;
	m_lookup[entry->id()] = node->id;

	if (node->id > m_size)
		m_size = node->id;

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
	unsigned oldId = node->id - 1;

	if (!m_usedIdSet.test(oldId) && entry->id() < oldId)
	{
		m_newIdSet.reset(oldId);
		m_newIdSet.set(entry->id());
		node->id = entry->id() + 1;

		if (node->id > m_size)
			m_size = node->id;
	}

	m_lookup[entry->id()] = node->id;

	if ((node->frequency += entry->frequency()) > m_maxFrequency)
		m_maxFrequency = node->frequency;
}


void
NameList::insertRounds(Namebase& base, Codec& codec)
{
	M_ASSERT(base.type() == Namebase::Round);

	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebaseEntry* entry = base.entryAt(i);

		if (entry->id() < base.nextId())
		{
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


void
NameList::insertEvents(Namebase& base, Codec& codec)
{
	M_ASSERT(base.type() == Namebase::Event);

	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebaseEvent* entry = base.eventAt(i);

		if (entry->id() < base.nextId())
		{
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


void
NameList::insertSites(Namebase& base, Codec& codec)
{
	M_ASSERT(base.type() == Namebase::Site);

	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebaseSite* entry = base.siteAt(i);

		if (entry->id() < base.nextId())
		{
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

#if 0
			if (entry->country() != country::Unknown && str->size() < 256 - 4)
			{
				char const* country = country::toString(entry->country());

				unsigned n = str->find(country);

				if (	n == mstl::string::npos
					|| (n == 0
							? str->size() > 3 && ::isalnum(str->at(3))
							: ::isalnum(str->at(n - 1)) || (n + 3 < str->size() && ::isalnum(str->at(n + 3)))))
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
#endif

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


void
NameList::insertPlayers(Namebase& base, Codec& codec)
{
	M_ASSERT(base.type() == Namebase::Player);

	for (unsigned i = 0, n = base.size(); i < n; ++i)
	{
		NamebasePlayer* entry = base.playerAt(i);

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

#if 0
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

// vi:set ts=3 sw=3:
