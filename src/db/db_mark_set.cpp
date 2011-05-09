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

#include "db_mark_set.h"

#include "m_algorithm.h"
#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;


static mstl::string&
trim(mstl::string& s)
{
	while (::isspace(s.front()))
		s.erase(s.begin());

	int n = s.size() - 1;

	while (n >= 0 && ::isspace(s[n]))
		s.resize(n--);

	return s;
}


bool
MarkSet::operator==(MarkSet const& marks) const
{
	if (count() != marks.count())
		return false;

	for (unsigned i = 0; i < count(); ++i)
	{
		if (!marks.contains(m_marks[i]))
			return false;
	}

	return true;
}


int
MarkSet::find(Mark const& mark) const
{
	Marks::const_iterator i = mstl::find(m_marks.begin(), m_marks.end(), mark);
	return i == m_marks.end() ? -1 : i - m_marks.begin();
}


int
MarkSet::match(Mark const& mark) const
{
	for (Marks::const_iterator i = m_marks.begin(); i != m_marks.end(); ++i)
	{
		if (mark.match(*i))
			return i - m_marks.begin();
	}

	return -1;
}


void
MarkSet::add(MarkSet const& set)
{
	m_marks.insert(m_marks.end(), set.m_marks.begin(), set.m_marks.end());
}


void
MarkSet::extractFromComment(mstl::string& comment)
{
	mstl::string result;

	Mark mark;
	char const* p = mark.parseDiagramMarker(comment);

	if (!mark.isEmpty())
		add(mark);

	char const* q = ::strchr(p, '[');

	while (q)
	{
		if (q[1] == '%')
		{
			if (q[2] == 'c' && q[3] == 'a' && q[4] == 'l' && q[5] == ' ')
			{
				char const* e = 0;

				switch (q[3])
				{
					case 'a': e = parseChessBaseMark(q + 5, mark::Arrow); break;
					case 's': e = parseChessBaseMark(q + 5, mark::Full); break;
				}

				if (e)
				{
					result.append(p, q - p);
					p = e;
					q = ::strchr(e, '[');
				}
				else
				{
					q = ::strchr(q + 1, '[');
				}
			}
			else
			{
				Mark mark;

				char const* e = mark.parseScidbMark(q);

				if (e == q)
					break;

				if (mark.isEmpty())
				{
					q = ::strchr(e == q ? e + 1: e, '[');
				}
				else
				{
					result.append(p, q - p);
					add(mark);
					p = e;
					q = ::strchr(e, '[');
				}
			}
		}
		else
		{
			q = ::strchr(q + 1, '[');
		}
	}

	if (!isEmpty())
	{
		result.append(p, comment.end());
		comment = result;
	}

	M_ASSERT(!isEmpty() || result.empty());

	::trim(comment);
}


char const*
MarkSet::parseChessBaseMark(char const* s, mark::Type type)
{
	while (1)
	{
		Mark mark;

		s = mark.parseChessBaseMark(s + 1, type);

		if (mark.isEmpty())
			return s;

		add(mark);
	}
	while (*s == ',');

	if (*++s == ']')
		++s;

	return s;
}


mstl::string&
MarkSet::toString(mstl::string& result) const
{
	for (unsigned i = 0; i < m_marks.size(); ++i)
	{
		if (i > 0)
			result += ' ';

		m_marks[i].toString(result);
	}

	return result;
}


mstl::string&
MarkSet::print(mstl::string& result) const
{
	for (unsigned i = 0; i < m_marks.size(); ++i)
	{
		if (i > 0)
			result += ' ';

		m_marks[i].print(result);
	}

	return result;
}

// vi:set ts=3 sw=3:
