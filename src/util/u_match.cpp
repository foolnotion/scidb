// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "u_match.h"

#include "sys_utf8.h"

#include "m_assert.h"

#include <ctype.h>
#include <string.h>

using namespace util;
using namespace sys;


static char const VirtualSpace = '\001';
static char const Space = '\002';


typedef bool (*MatchChar)(char const* lhs, char const* rhs);
typedef bool (*MatchUC)(utf8::uchar lhs, utf8::uchar rhs);
typedef int (*MapCase)(int ch);


static bool
isDelim(utf8::uchar uc)
{
	return !utf8::isAlnum(uc) && (utf8::isPunct(uc) || utf8::isSpace(uc));
}


static bool
isDelim(char const* s)
{
	return isDelim(utf8::getChar(s));
}


static bool matchUC(utf8::uchar lhs, utf8::uchar rhs) { return lhs == rhs; }


static bool
caseMatchUC(utf8::uchar lhs, utf8::uchar rhs)
{
	return utf8::toLower(lhs) != utf8::toLower(rhs);
}


static bool
closingCurlyBraceAhead(char const* s, char const* e)
{
	while (s < e)
	{
		switch (*s)
		{
			case '\\':
				++s;
				break;

			case '{':
				return false;

			case '}':
				return true;

			default:
				s = utf8::nextChar(s);
				break;
		}
	}

	return false;
}


static bool
intersects(char const* pattern, char const* s, char const* e, MatchUC matchChar)
{
	while (s < e)
	{
		if (*s == '*')
			return true;

		switch (*pattern)
		{
			case '*':
				return true;

			case '?':
				++pattern;
				s = utf8::nextChar(s);
				break;

			case '(':
			case ')':
				if (*s == *pattern)
					++s;
				++pattern;
				break;

			default:
			{
				utf8::uchar lhs, rhs;

				pattern = utf8::nextChar(pattern, lhs);
				s = utf8::nextChar(s, rhs);

				if (*s != '?' && matchChar(lhs, rhs))
					return false;
				break;
			}
		}
	}

	if (*pattern == '*')
		return true;

	return *pattern == '\0';
}


static bool
intersect(mstl::string& result, char const* lhs, char const* rhs, MatchChar matchChar)
{
	while (*rhs)
	{
		switch (*lhs)
		{
			case '\0':
				if (*rhs == '*')
					++rhs;
				return *rhs == '\0';

			case '?':
				result.append('?');
				if (*rhs != '*')
					rhs = utf8::nextChar(rhs);
				++lhs;
				break;

			case '*':
				while (*rhs == '?')
					result.append(*rhs++);

				switch (*rhs)
				{
					case '\0':
						return lhs[1] == '\0';

					case '*':
						result.append(*rhs++);
						break;

					case '(':
						if (result.empty() || result.back() != '(')
							result.append(*lhs);
						break;

					case ')':
						if (result.empty() || (result.back() != '(' && result.back() != ')'))
							result.append(*lhs);
						break;

					default:
					{
						unsigned lenSoFar = result.size();

						++lhs;

						while (*rhs)
						{
							if (intersect(result, lhs, rhs, matchChar))
								return true;

							unsigned len = utf8::charLength(rhs);

							result.set_size(lenSoFar);
							result.append(rhs, len);
							rhs += len;
						}

						return false;
					}
					break;
				}
				++lhs;
				break;

			case '(':
				if (result.empty() || result.back() != '(')
					result.append(*lhs);
				++lhs;
				break;

			case ')':
				if (result.empty() || (result.back() != '(' && result.back() != ')'))
					result.append(*lhs);
				++lhs;
				break;

			case '\\':
				++lhs;
				// fallthru

			default:
				switch (*rhs)
				{
					case '?':
						result.append('?');
						++rhs;
						lhs = utf8::nextChar(lhs);
						break;

					case '*':
					{
						unsigned lenSoFar = result.size();

						++rhs;

						while (*lhs)
						{
							if (intersect(result, lhs, rhs, matchChar))
								return true;

							unsigned len = utf8::charLength(lhs);

							result.set_size(lenSoFar);
							result.append(lhs, len);
							lhs += len;
						}

						return false;
					}

					case '(':
					{
						if (result.empty() || result.back() != '(')
							result.append('(');
						++rhs;
						break;
					}

					case ')':
					{
						if (result.empty() || (result.back() != '(' && result.back() != ')'))
							result.append(')');
						++rhs;
						break;
					}

					case '\\':
						++rhs;
						// fallthru

					default:
					{
						if (!matchChar(lhs, rhs))
							return false;

						unsigned len = utf8::charLength(rhs);
						result.append(rhs, len);
						rhs += len;
						break;
					}
				}
				break;
		}
	}

	if (*lhs == '*')
		++lhs;

	return *lhs == '\0';
}


static bool
match(char const* pattern, char const* s, char const* e, MatchChar matchChar)
{
	M_ASSERT(pattern);
	M_ASSERT(s);
	M_ASSERT(s <= e);

	char const*	start = s;
	unsigned		countDelims = 0;

	while (s < e)
	{
		switch (*pattern)
		{
			case '\0':
				return false;

			case '?':
				++pattern;
				s = utf8::nextChar(s);
				break;

			case '*':
				if (*++pattern == '\0')
					return true;

				for ( ; s < e; s = utf8::nextChar(s))
				{
					if (match(pattern, s, e, matchChar))
						return true;
				}
				return false;

			case ' ':
				if (*s != ' ')
					return false;
				while (s < e && *s == ' ')
					++s;
				++pattern;
				++countDelims;
				break;

			case Space:
				if (*s != ' ')
					return false;
				++pattern;
				++countDelims;
				break;

			case VirtualSpace:
				while (*s == ' ')
					++s;
				++pattern;
				++countDelims;
				break;

			case '(':
				if (!utf8::isAlnum(s))
					return false;
				++pattern;
				countDelims = 0;
				break;

			case ')':
				if (countDelims > 0)
					return false;
				if (s == start || utf8::isAlnum(s) || !utf8::isAlnum(utf8::prevChar(s - 1, start)))
					return false;
				++pattern;
				break;

			case '\\':
				++pattern;
				// fallthru

			default:
				if (!matchChar(pattern, s))
					return false;
				s = utf8::nextChar(s);
				pattern = utf8::nextChar(pattern);
				break;
		}
	}

	if (*pattern == '*')
		++pattern;

	return *pattern == '\0';
}


static bool
matchPattern(char const* pattern, char const* s, char const* e, MatchChar matchChar)
{
	M_ASSERT(pattern);
	M_ASSERT(s);
	M_ASSERT(s <= e);

	while (s < e)
	{
		switch (*pattern)
		{
			case '\0':
				return false;

			case '?':
				if (*s == '*')
					return false;

				s = utf8::nextChar(s);
				++pattern;
				break;

			case '*':
				if (*++pattern == '\0')
					return true;

				if (*s == '*')
					++s;

				for ( ; s < e; ++s)
				{
					if (matchPattern(pattern, s, e, matchChar))
						return true;
				}

				return false;

			case '(':
			case ')':
				if (*s != *pattern)
					return false;

				++s;
				++pattern;
				break;

			default:
				if (*s == '*' || *s == '?')
					return false;

				if ((*s == '(' || *s == ')') && !matchChar(s, pattern))
					return false;

				s = utf8::nextChar(s);
				pattern = utf8::nextChar(pattern);
				break;
		}
	}

	if (*pattern == '*')
		++pattern;

	return *pattern == '\0';
}


static bool
checkWord(char const* s, char const* e)
{
	while (s < e)
	{
		utf8::uchar uc;

		s = utf8::nextChar(s, uc);

		if (::isDelim(s))
			return false;
	}

	return true;
}


static char const*
find(char const*& pattern, char const* s, char const* start, bool ignoreCase)
{
	int ch = *pattern;

	switch (ch)
	{
		case '*':
		case '?':
			return s;

		case Space:
			return ::strchr(s, ' ');

		case VirtualSpace:
		{
			++pattern;
			char const* p = find(pattern, s, start, ignoreCase);
			--pattern;
			return p ? p : ::strchr(s, ' ');
		}

		case '(':
			if (!isalnum(*s))
				return 0;
			++pattern;
			return find(pattern, s, start, ignoreCase);

		case ')':
			if (s == start || !isalnum(s[-1]))
				return 0;
			++pattern;
			return find(pattern, s, start, ignoreCase);

		case '\\':
			++pattern;
	}

	if (!ignoreCase)
		return ::strchr(s, ch);
	
	ch = toupper(ch);

	for (char const* p = s; *p; ++p)
	{
		if (toupper(*p) == ch)
			return p;
	}

	return 0;
}


static char const*
search(char const* pattern, char const* s, char const* e, bool ignoreCase)
{
	M_REQUIRE(pattern);
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	char const* start = s;

	char const* p = pattern;
	char const* r = s;

	if ((s = find(p, s, start, ignoreCase)) == 0)
		return 0;

	unsigned		checkWord	= 0;
	bool			advance		= true;
	char const*	w				= 0;
	MatchChar	matchChar	= ignoreCase ? utf8::caseMatchChar : utf8::matchChar;

	while (r < e)
	{
		switch (*p)
		{
			case '\0':
				if (*s == '\0')
					return r;
				advance = true;
				break;

			case '?':
				if (*s == '\0')
					advance = true;
				else
					++p;
				break;

			case '*':
				while (p[1] == '*')
					++p;

				if (p[1] == '\0')
					return r;

				for ( ; *s; ++s)
				{
					if (match(p + 1, s, e, matchChar))
						return r;
				}

				advance = true;
				break;

			case '(':
				if (	s == e
					|| !utf8::isAlnum(s)
					|| (start < s && utf8::isAlnum(utf8::prevChar(s - 1, start))))
				{
					advance = true;
				}
				else
				{
					w = s;
					++p;
					checkWord = 1;
				}
				break;

			case ')':
				if (	checkWord == 2
					|| s == start
					|| !utf8::isAlnum(utf8::prevChar(s - 1, start))
					|| (s < e && utf8::isAlnum(s)))
				{
					advance = true;
				}
				else
				{
					++p;
				}
				break;

			case ' ':
				if (*s == ' ')
				{
					do ++s; while (s < e && *s == ' ');
					++p;
				}
				else
				{
					advance = true;
				}
				break;

			case VirtualSpace:
				while (s < e && *s == ' ')
					++s;
				++p;
				break;

			case Space:
				if (*s == ' ')
				{
					++s;
					++p;
				}
				else
				{
					advance = true;
				}
				break;

			case '\\':
				++p;
				// fallthru

			default:
				if (utf8::isAscii(*p))
				{
					if (*p == *s)
					{
						++p;
						++s;
					}
					else
					{
						advance = true;
					}
				}
				else if (utf8::isAscii(*s))
				{
					advance = true;
				}
				else
				{
					utf8::uchar uc1, uc2;

					p = utf8::nextChar(p, uc1);
					s = utf8::nextChar(s, uc2);

					if (ignoreCase)
					{
						uc1 = utf8::toLower(uc1);
						uc2 = utf8::toLower(uc2);
					}

					advance = uc1 != uc2;
				}

				if (!advance && w && !::checkWord(w, s))
					advance = true;
				break;
		}

		if (advance)
		{
			p = pattern;

			if ((s = find(p, ++r, start, ignoreCase)) == 0)
				return 0;

			advance = false;
			w = 0;
		}
	}

	return 0;
}


unsigned
Pattern::normalize(char const* s, char const* e)
{
	m_isPlain = true;
	m_isPartial = false;

	if (s == 0)
		return 0;

	if (s[0] == '!')
	{
		if (s[1] == '\0')
			return 0;

		m_ignoreCase = false;
		++s;
	}

	m_pattern.reserve(e - s);

	unsigned countMarks	= 0;
	unsigned countStars	= 0;
	unsigned countSpaces	= 0;
	unsigned n				= 0;

	bool noSpacingRules = false;

	for ( ; s < e; )
	{
		switch (*s)
		{
			case '*':
				++s;
				++countStars;
				if (countSpaces)
				{
					m_pattern.append(' ');
					countSpaces = 0;
				}
				break;

			case '?':
				++s;
				++countMarks;
				if (countSpaces)
				{
					m_pattern.append(' ');
					countSpaces = 0;
				}
				break;

			case ' ':
				++s;
				++n;
				if (noSpacingRules)
				{
					m_pattern.append(::Space);
				}
				else
				{
					m_isPlain = false;
					++countSpaces;
				}
				break;

			default:
				if (utf8::isControl(s))
				{
					s = utf8::nextChar(s);
					continue; // ignore control characters
				}
				if (countMarks)
				{
					M_ASSERT(countSpaces == 0);
					m_pattern.append(countMarks, '?');
					countMarks = 0;
					m_isPlain = false;
				}
				if (countStars)
				{
					M_ASSERT(countSpaces == 0);
					m_pattern.append('*');
					countStars = 0;
					m_isPlain = false;
				}
				switch (*s)
				{
					case '(':
						if (countSpaces)
						{
							m_pattern.append(' ');
							countSpaces = 0;
						}
						++s;
						if (m_pattern.empty() || m_pattern.back() != '(')
						{
							if (s + 1 < e && s[1] == ')')
							{
								++s;
							}
							else
							{
								m_pattern.append('(');
								m_isPlain = false;
							}
							continue;
						}
						break;

					case ')':
						if (countSpaces)
						{
							m_pattern.append(' ');
							countSpaces = 0;
						}
						if (m_pattern.empty() || m_pattern.back() == '(')
							continue;
						break;

					case '{':
						if (countSpaces)
						{
							m_pattern.append(' ');
							countSpaces = 0;
						}
						if (!noSpacingRules && (noSpacingRules = ::closingCurlyBraceAhead(s + 1, e)))
						{
							m_isPlain = false;
							continue;
						}
						break;

					case '}':
						if (noSpacingRules)
						{
							noSpacingRules = false;
							continue;
						}
						break;

					case '\\':
						if (::strchr("*?!(){}\\", *s++))
							m_pattern.append('\\');
						if (*s != '?' && *s != '!')
							break;
						// fallthru

					case '!':
					case '?':
					case ',':
					case '.':
					case ':':
					case ';':
						if (!noSpacingRules)
						{
							countSpaces = 0;
							m_pattern.append(::VirtualSpace);
							m_pattern.append(*s++);
							m_pattern.append(::VirtualSpace);
							while (*s == ' ')
								++s;
							m_isPlain = false;
							++n;
							continue;
						}
						break;
				}
				if (utf8::isAscii(*s))
				{
					m_pattern.append(*s++);
					++n;
				}
				else
				{
					unsigned len = utf8::charLength(s);

					m_pattern.append(s, len);
					s += len;
					n += len;
				}
				break;
		}
	}

	if (countStars)
	{
		M_ASSERT(countSpaces == 0);

		if (m_isPlain)
			m_isPartial = true;
		else
			m_pattern.append('*');
	}
	else if (countMarks)
	{
		M_ASSERT(countSpaces == 0);

		m_pattern.append('?');
		m_isPlain = false;
	}
	else if (countSpaces)
	{
		m_pattern.append(' ');
	}

	if (m_isPlain)
	{
		mstl::string str;
		str.swap(m_pattern);
		char const* s = str.c_str();

		for ( ; *s; ++s)
		{
			if (s[0] != '\\')
				m_pattern.append(*s);
			else if (s[1] == '\\')
				m_pattern.append(*s++);
		}
	}

	return n;
}


void
Pattern::assign(mstl::string const& pattern)
{
	m_pattern.clear();
	m_minSize = normalize(pattern.begin(), pattern.end());
}


void
Pattern::assign(char const* s, char const* e)
{
	m_pattern.clear();
	m_minSize = normalize(s, e);
}


void
Pattern::clear()
{
	m_pattern.clear();
	m_minSize = 0;
	m_isPlain = true;
	m_isPartial = false;
	m_ignoreCase = true;
}


bool
Pattern::includes(Pattern const& pattern) const
{
	if (m_pattern.empty())
		return pattern.m_pattern.empty();

	MatchChar matchChar = m_ignoreCase && pattern.m_ignoreCase ? utf8::caseMatchChar : utf8::matchChar;
	return ::matchPattern(m_pattern, pattern.m_pattern.begin(), pattern.m_pattern.end(), matchChar);
}


bool
Pattern::intersects(Pattern const& pattern) const
{
	if (m_isPlain)
		return !pattern.m_isPlain;

	if (pattern.m_isPlain)
		return !m_isPlain;

	return ::intersects(	m_pattern,
								pattern.m_pattern.begin(),
								pattern.m_pattern.end(),
								m_ignoreCase || pattern.m_ignoreCase ? ::caseMatchUC : ::matchUC);
}


bool
Pattern::match(char const* s, char const* e) const
{
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	if (m_pattern.empty())
		return m_isPartial || s == e;

	unsigned size = e - s;

	if (m_isPlain)
	{
		if (m_isPartial)
		{
			if (size < m_pattern.size())
				return false;
		}
		else if (size != m_pattern.size())
		{
			return false;
		}

		if (!m_isPartial && size != m_pattern.size())
			return false;

		if (m_ignoreCase)
			return ::strncasecmp(s, m_pattern, m_pattern.size()) == 0;

		return ::strncmp(s, m_pattern, m_pattern.size()) == 0;
	}

	if (size < m_minSize)
		return false;

	return ::match(m_pattern, s, e, m_ignoreCase ? utf8::caseMatchChar : utf8::matchChar);
}


bool
Pattern::match(mstl::string const& s) const
{
	if (m_pattern.empty())
		return m_isPartial || s.empty();

	if (m_isPlain)
	{
		if (m_isPartial)
		{
			if (s.size() < m_pattern.size())
				return false;
		}
		else if (s.size() != m_pattern.size())
		{
			return false;
		}

		if (m_ignoreCase)
			return s.case_equal(m_pattern, m_pattern.size());

		return s.equal(m_pattern, m_pattern.size());
	}

	if (s.size() < m_minSize)
		return false;

	return ::match(m_pattern, s.begin(), s.end(), m_ignoreCase ? utf8::caseMatchChar : utf8::matchChar);
}


char const*
Pattern::search(char const* s, char const* e) const
{
	M_REQUIRE(s);
	M_REQUIRE(s <= e);

	if (m_pattern.empty())
		return m_isPartial ? s : 0;

	unsigned size = e - s;

	if (size < m_minSize)
		return 0;

	if (!m_isPlain)
		return ::search(m_pattern, s, e - m_minSize, m_ignoreCase);

	if (m_ignoreCase)
		return utf8::findStringNoCase(s, e - s, m_pattern.begin(), m_pattern.size());

	return utf8::findString(s, e - s, m_pattern, m_pattern.size());
}


char const*
Pattern::search(mstl::string const& s) const
{
	if (m_pattern.empty())
		return m_isPartial ? s.c_str() : 0;

	if (s.size() < m_minSize)
		return 0;

	if (!m_isPlain)
		return ::search(m_pattern, s.begin(), s.end() - m_minSize, m_ignoreCase);

	if (m_ignoreCase)
		return utf8::findStringNoCase(s, s.size(), m_pattern, m_pattern.size());

	return utf8::findString(s, s.size(), m_pattern, m_pattern.size());
}


bool
Pattern::join(Pattern const& pattern)
{
	if (includes(pattern))
		return true;

	if (!pattern.includes(*this))
		return false;

	*this = pattern;
	return true;
}


bool
Pattern::intersect(Pattern const& pattern)
{
	// true:  result is non-empty
	// false: result is empty

	if (*this == pattern)
		return matchAny();

	if (matchNone())
		return false;

	if (pattern.matchNone())
	{
		*this = pattern;
		return false;
	}

	if (isPlain() && pattern.isPlain())
	{
		if (m_pattern == pattern.m_pattern)
			return true;

		clear();
		return false;
	}

	mstl::string s;
	bool ignoreCase = m_ignoreCase && pattern.m_ignoreCase;

	if (!::intersect(s, m_pattern, pattern.m_pattern, ignoreCase ? utf8::caseMatchChar : utf8::matchChar))
	{
		clear();
		return false;
	}

	m_pattern.clear();
	m_minSize = normalize(s.begin(), s.end());
	m_ignoreCase = ignoreCase;

	return true;
}


mstl::string
Pattern::prefix() const
{
	mstl::string prefix;
	prefix.reserve(m_pattern.size());

	char const* s = m_pattern.begin();
	char const* e = m_pattern.end();

	if (*s == '!')
		++s;

	while (s < e)
	{
		switch (*s)
		{
			case '*':
			case '?':
			case ::VirtualSpace:
				return prefix;

			case '{':
				break;

			case ::Space:
				prefix.append(' ');
				++s;
				break;

			case '\\':
				++s;
				break;

			default:
			{
				unsigned len = utf8::charLength(s);
				prefix.append(s, len);
				s += len;
				break;
			}
		}
	}

	return prefix;
}

// vi:set ts=3 sw=3:
