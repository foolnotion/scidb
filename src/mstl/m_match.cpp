// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "m_match.h"
#include "m_assert.h"

#include <ctype.h>
#include <string.h>

using namespace mstl;


static unsigned
min_length(mstl::string& dst, char const* s, char const* e)
{
	if (s == 0)
		return 0;

	unsigned n = 0;

	dst.reserve(e - s);

	for ( ; s < e; ++s)
	{
		switch (*s)
		{
			case '*':
				if (dst.empty() || dst.back() != '*')
					dst.append(*s);
				break;

			case '\\':
				dst.append('\\');
				++s;
				// fallthru

			default:
				dst.append(*s);
				++n;
				break;
		}
	}

	return n;
}


static bool
is_plain(char const* s, char const* e)
{
	if (s == 0)
		return true;

	for ( ; s < e; ++s)
	{
		switch (*s)
		{
			case '*':
			case '?':
				return false;

			case '\\':
				++s;
				break;
		}
	}

	return true;
}


static bool
match(char const* pattern, char const* s, char const* e)
{
	M_ASSERT(pattern);
	M_ASSERT(s);
	M_ASSERT(s <= e);

	for ( ; s < e; ++s, ++pattern)
	{
		switch (*pattern)
		{
			case '\0':
				return false;

			case '?':
				break;

			case '*':
				if (pattern[1] == '\0')
					return true;

				for ( ; s < e; ++s)
				{
					if (match(pattern + 1, s, e))
						return true;
				}
				return false;

			case '\\':
				++pattern;
				// fallthru

			default:
				if (*pattern != *s)
					return false;
				break;
		}
	}

	if (*pattern == '*')
		++pattern;

	return *pattern == '\0';
}


static bool
match_ignore_case(char const* pattern, char const* s, char const* e)
{
	M_ASSERT(pattern);
	M_ASSERT(s);
	M_ASSERT(s <= e);

	for ( ; s < e; ++s, ++pattern)
	{
		switch (*pattern)
		{
			case '\0':
				return false;

			case '?':
				break;

			case '*':
				if (pattern[1] == '\0')
					return true;

				for ( ; s < e; ++s)
				{
					if (match(pattern + 1, s, e))
						return true;
				}
				return false;

			case '\\':
				++pattern;
				// fallthru

			default:
				if (::toupper(*pattern) != ::toupper(*s))
					return false;
				break;
		}
	}

	if (*pattern == '*')
		++pattern;

	return *pattern == '\0';
}


static char const*
find(char const*& pattern, char const* s)
{
	if (*pattern == '*' || *pattern == '?')
		return s;

	if (*pattern == '\\')
		++pattern;

	return ::strchr(s, *pattern);
}


static char const*
search(char const* pattern, char const* s, char const* e)
{
	M_REQUIRE(pattern);
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	char const* p = pattern;
	char const* r = s;

	if ((s = find(p, s)) == 0)
		return 0;

	while (r < e)
	{
		switch (*p)
		{
			case '\0':
				if (*s == '\0')
					return r;
				p = pattern;
				if ((s = find(p, ++r)) == 0)
					return 0;
				break;

			case '?':
				if (*s == '\0')
				{
					p = pattern;
					if ((s = find(p, ++r)) == 0)
						return 0;
				}
				break;

			case '*':
				while (p[1] == '*')
					++p;

				if (p[1] == '\0')
					return r;

				for ( ; *s; ++s)
				{
					if (match(p + 1, s, e))
						return r;
				}
				p = pattern;
				if ((s = find(p, ++r)) == 0)
					return 0;
				break;

			case '\\':
				++p;
				// fallthru

			default:
				if (*p != *s)
				{
					p = pattern;
					if ((s = find(p, ++r)) == 0)
						return 0;
				}
				break;
		}
	}

	return 0;
}


pattern::pattern() {}


pattern::pattern(string const& pattern)
	:m_min_length(::min_length(m_pattern, pattern.begin(), pattern.end()))
	,m_is_plain(::is_plain(pattern.begin(), pattern.end()))
	,m_is_ascii(true) // TODO
{
}


pattern::pattern(char const* s, char const* e)
	:m_min_length(::min_length(m_pattern, s, e))
	,m_is_plain(::is_plain(s, e))
	,m_is_ascii(true) // TODO
{
}


bool
pattern::match(char const* s, char const* e) const
{
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	if (m_pattern.empty())
		return s == e;

	unsigned size = e - s;

	if (m_is_plain)
		return size == m_pattern.size() && ::strncmp(s, m_pattern, m_pattern.size()) == 0;

	if (size < m_min_length)
		return false;
	
	return ::match(m_pattern, s, e);
}


bool
pattern::match(string const& s) const
{
	if (m_pattern.empty())
		return s.size() == 0;

	if (m_is_plain)
		return s.size() == m_pattern.size() && ::strncmp(s, m_pattern, m_pattern.size()) == 0;

	if (s.size() < m_min_length)
		return false;
	
	return ::match(m_pattern, s.begin(), s.end());
}


bool
pattern::match_ignore_case(char const* s, char const* e) const
{
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	if (m_pattern.empty())
		return s == e;

	unsigned size = e - s;

	if (m_is_plain)
		return size == m_pattern.size() && ::strncasecmp(s, m_pattern, m_pattern.size()) == 0;

	if (size < m_min_length)
		return false;
	
	return ::match_ignore_case(m_pattern, s, e);
}


bool
pattern::match_ignore_case(string const& s) const
{
	if (m_pattern.empty())
		return s.size() == 0;

	if (m_is_plain)
		return s.size() == m_pattern.size() && ::strncasecmp(s, m_pattern, m_pattern.size()) == 0;

	if (s.size() < m_min_length)
		return false;
	
	return ::match_ignore_case(m_pattern, s.begin(), s.end());
}


char const*
pattern::search(char const* s, char const* e) const
{
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	if (m_pattern.empty())
		return 0;

	unsigned size = e - s;

	if (size < m_min_length)
		return false;
	
	if (!m_is_plain)
		return ::search(m_pattern, s, e - m_min_length);

	s = ::strchr(s, *m_pattern);

	while (s + m_min_length < e)
	{
		if (::strncmp(s, m_pattern, m_pattern.size()) == 0)
			return s;

		s = ::strchr(s + 1, *m_pattern);
	}

	return 0;
}


char const*
pattern::search(string const& s) const
{
	if (m_pattern.empty())
		return 0;

	if (s.size() < m_min_length)
		return false;
	
	if (!m_is_plain)
		return ::search(m_pattern, s.begin(), s.end() - m_min_length);

	return ::strstr(m_pattern, s);
}

// vi:set ts=3 sw=3:
