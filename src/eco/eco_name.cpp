// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "eco_name.h"

#include "u_byte_stream.h"

#include "m_set.h"
#include "m_ostream.h"
#include "m_assert.h"

#include <string.h>

using namespace eco;


class NameRef
{
public:

	NameRef(Name const* name, unsigned ref) :m_name(name), m_ref(ref) {}
	auto operator<(NameRef const& ref) const -> bool { return *m_name < *ref.m_name; }

	auto ref() const -> unsigned { return m_ref; }
	auto name() const -> Name const& { return *m_name; }

private:

	Name const*	m_name;
	unsigned		m_ref;
};


using NameSet = mstl::set<NameRef>;

Name::Lookup Name::m_lookup;
mstl::hash<mstl::string,unsigned> Name::m_hash(4000);
Name::StringList Name::m_strings;
unsigned Name::m_numChars = 0;
Name const Name::m_empty;
static NameSet m_nameSet;


auto Name::operator<(Name const& name) const -> bool
{
	for (unsigned i = 0; i < NumEntries; ++i)
	{
		if (m_ref[i] < name.m_ref[i])
			return true;

		if (m_ref[i] > name.m_ref[i])
			return false;
	}

	return false;
}


auto Name::insert(Name const& name) -> unsigned
{
	if (name.size() <= 1)
		return Invalid;

	Name* nameRef = new Name(name);
	NameSet::result_t r = m_nameSet.insert_unique(NameRef(nameRef, m_nameSet.size()));

	if (r.second)
		m_lookup.push_back(nameRef);

	return r.first->ref();
}


void Name::set(unsigned level, mstl::string const& s)
{
	M_REQUIRE(level < NumEntries);
	M_REQUIRE(s.size() < 256);
	M_REQUIRE(level == 0 || number(level - 1) != 0);

	unsigned n = m_hash.find_or_insert(s, m_strings.size());

	if (n == m_strings.size())
	{
		m_strings.push_back(s);
		m_numChars += s.size();
	}

	m_ref[level] = n + 1;
	m_size = level + 1;
	::memset(&m_ref[m_size], 0, sizeof(m_ref[0])*(NumEntries - m_size));
}


void Name::setOpening(Name const& name)
{
	M_REQUIRE(size() >= 2);
	M_REQUIRE(name.size() >= 2);

	m_ref[0] = name.m_ref[0];
	m_ref[1] = name.m_ref[1];
}


void Name::init()
{
	::memset(m_ref, 0, sizeof(m_ref));
}


auto Name::variation() const -> mstl::string
{
	mstl::string s;

	char const* comma = "";

	for (unsigned i = 2; i < size(); ++i)
	{
		if (!str(i).empty())
		{
			s.append(comma);
			s.append(str(i));
			comma = ", ";
		}
	}

	return s;
}


auto Name::opening() const -> mstl::string
{
	mstl::string s;

	if (!isEmpty(0))
	{
		s.append(str(0));

		char const* comma = ": ";

		for (unsigned i = 2; i < size(); ++i)
		{
			if (!isEmpty(i))
			{
				s.append(comma);
				s.append(str(i));
				comma = ", ";
			}
		}
	}

	return s;
}


void Name::dump(mstl::ostream& strm)
{
	unsigned char buf[2];
	util::ByteStream bstrm(buf, sizeof(buf));

	for (unsigned i = 0; i < m_strings.size(); ++i)
	{
		strm.put(m_strings[i].size());
		strm.write(m_strings[i], m_strings[i].size());
	}

	for (unsigned i = 0; i < m_lookup.size(); ++i)
	{
		for (unsigned k = 0; k < Name::NumEntries; ++k)
		{
			bstrm.resetp();
			bstrm << uint16_t(m_lookup[i]->number(k));
			strm.write(buf, 2);
		}
	}
}

// vi:set ts=3 sw=3:
