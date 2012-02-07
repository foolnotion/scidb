// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "u_html.h"

#include "Hyphenator.h"

#include "sys_utf8.h"

#include "m_utility.h"
#include "m_pair.h"
#include "m_map.h"
#include "m_assert.h"

#include <expat.h>
#include <ctype.h>
#include <string.h>

using namespace util;
using namespace util::html;


typedef mstl::pair<unsigned,hyphenate::Hyphenator*> HyphenatorP;
typedef mstl::map<mstl::string,HyphenatorP> HyphenatorMap;
static HyphenatorMap hyphenatorMap;


static char const*
findChar(char const* first, char const* last, char c)
{
	while (first < last)
	{
		if (*first == c)
			return first;

		first = sys::utf8::nextChar(first);
	}

	return 0;
}


Search::Search(bool noCase, bool entireWord, bool titleOnly, unsigned maxMatches)
	:m_parser(XML_ParserCreate("UTF-8"))
	,m_needle(0)
	,m_length(0)
	,m_compare(noCase ? sys::utf8::findFirstNoCase : sys::utf8::findFirst)
	,m_entireWord(entireWord)
	,m_titleOnly(titleOnly)
	,m_isTitle(false)
	,m_tooManyMatches(false)
	,m_skip(m_titleOnly ? 1 : 0)
	,m_maxMatches(maxMatches)
	,m_lastBytePos(0)
	,m_lastCharPos(0)
	,m_partialMatch(0)
	,m_partialMatchPos(0)
{
	if (m_parser == 0)
		M_RAISE("couldn't allocate memory for parser");

	XML_SetUserData(m_parser, this);
	XML_SetCharacterDataHandler(m_parser, htmlContent);
	XML_SetElementHandler(m_parser, htmlStartElement, htmlEndElement);
}


Search::~Search()
{
	XML_ParserFree(m_parser);
}


int
Search::stringFirstCmd(char const* haystack, unsigned haystackLen)
{
	int pos = m_compare(haystack, haystackLen, m_needle, m_length);

	M_ASSERT(pos < 0 || unsigned(pos) <= haystackLen - m_length);

	if (m_entireWord)
	{
		while (pos >= 0)
		{
			unsigned match = 0;

			if (pos == 0)
			{
				++match;
			}
			else
			{
				char const* p = sys::utf8::prevChar(haystack + pos, haystack);

				if (!sys::utf8::isAlpha(sys::utf8::getChar(p)))
					++match;
			}

			if (unsigned(pos) + m_length < haystackLen - 1)
			{
				if (!sys::utf8::isAlpha(sys::utf8::getChar(haystack + pos + m_length)))
					++match;
			}
			else
			{
				++match;
			}

			if (match == 2)
				return pos;

			if (unsigned(pos + 1) > haystackLen)
				return -1;

			haystack += pos + 1;
			haystackLen -= pos + 1;
			pos = m_compare(haystack, haystackLen, m_needle, m_length);
		}
	}

	return pos;
}


void
Search::htmlStartElement(void* cbData, XML_Char const* elem, char const** attr)
{
	switch (toupper(elem[0]))
	{
		case 'A':
			if (elem[1] == '\0')
				++static_cast<Search*>(cbData)->m_skip;
			break;

		case 'H':
		{
			if (::isdigit(elem[1]))
			{
				Search* self = static_cast<Search*>(cbData);

				if (elem[1] == '1')
					self->m_isTitle = true;

				if (self->m_titleOnly)
					--self->m_skip;
			}
			else if (::strcasecmp(elem, "head") == 0)
			{
				++static_cast<Search*>(cbData)->m_skip;
			}
		}
		break;
	}

	static_cast<Search*>(cbData)->m_partialMatch = 0;
}


void
Search::htmlEndElement(void* cbData, XML_Char const* elem)
{
	switch (toupper(elem[0]))
	{
		case 'A':
			if (elem[1] == '\0')
				--static_cast<Search*>(cbData)->m_skip;
			break;

		case 'H':
		{
			if (::isdigit(elem[1]))
			{
				Search* self = static_cast<Search*>(cbData);

				self->m_isTitle = false;

				if (self->m_titleOnly)
					++self->m_skip;
			}
			else if (::strcasecmp(elem, "head") == 0)
			{
				--static_cast<Search*>(cbData)->m_skip;
			}
		}
		break;
	}
}


void
Search::addPosition(unsigned bytePos)
{
	M_ASSERT(bytePos > m_lastBytePos);

	if (mstl::div2(m_posList.size()) == m_maxMatches)
	{
		m_tooManyMatches = true;
		++m_skip;
	}
	else
	{
		unsigned nchars = sys::utf8::countChars(m_haystack + m_lastBytePos, bytePos - m_lastBytePos);

		m_lastCharPos += nchars;
		m_posList.push_back(m_lastCharPos);
		m_lastBytePos = bytePos;
	}
}


void
Search::htmlContent(void* cbData, XML_Char const* s, int len)
{
	if (*s == '\n' && len == 1)
		return;

	Search* self = static_cast<Search*>(cbData);

	if (self->m_isTitle)
		self->m_title.append(s, len);

	if (self->m_skip)
		return;

	int pos	= self->stringFirstCmd(s, len);
	int offs	= 0;

	while (pos >= 0)
	{
		M_ASSERT(pos < len);

		unsigned skip = pos + self->m_length;

		self->addPosition(XML_GetCurrentByteIndex(self->m_parser) + offs + pos);

		offs += skip;
		len -= skip;

		pos = self->stringFirstCmd(s + offs, len);
	}
}


bool
Search::parse(char const* document, unsigned length, char const* search, unsigned searchLen)
{
	char* buf = new char[length + 1];
	::memcpy(buf, document, length + 1);
	char* e = buf + length;
	char* s = const_cast<char*>(::findChar(buf, e, '&'));

	while (s)
	{
		char* p = s + 1;

		while (::isalpha(*p))
			++p;

		if (*p++ == ';')
		{
			// expat has problems with some &xxx; tokens.
			::memset(s, ' ', p - s);
		}

		s = const_cast<char*>(::findChar(p, e, '&'));
	}

	m_needle = search;
	m_length = searchLen;
	m_haystack = document;

	int rc = XML_Parse(m_parser, buf, length, true);
	delete [] buf;
	m_title.trim();

	return rc;
}


inline static bool isdelim(char c) { return c == ' ' || c == '>'; }


static bool
isExcludingTag(char const* s)
{
	switch (tolower(s[0]))
	{
//		case 'a': return isdelim(s[1]); break;												// <a>
		case 'c': return strncasecmp(s + 1, "ode", 3) == 0 && isdelim(s[4]);		// <code>
		case 'p': return strncasecmp(s + 1, "re", 2) == 0 && isdelim(s[3]);		// <pre>
//		case 't': return tolower(s[1]) == 't' && isdelim(s[2]);						// <tt>
		case 'h': return isdigit(s[1]) && isdelim(s[2]);								// <h1>, <h2>, ...

		case 's':
			switch (tolower(s[1]))
			{
				case 'c': return strncasecmp(s + 2, "ript", 4) == 0 && isdelim(s[5]);	// <script>
				case 't': return strncasecmp(s + 2, "yle", 3) == 0 && isdelim(s[4]);		// <style>
			}
			break;
	}

	return false;
}

Hyphenate::Hyphenate(mstl::string const& patternFilename,
							mstl::string const& dictFilenames,
							CacheState keepInCache)
	:m_filename(patternFilename)
	,m_keepInCache(keepInCache)
{
	::HyphenatorMap::iterator i = ::hyphenatorMap.find(patternFilename);

	if (i == ::hyphenatorMap.end())
	{
		i = ::hyphenatorMap.insert(::HyphenatorMap::value_type(
				patternFilename,
				::HyphenatorP(0, new ::hyphenate::Hyphenator(patternFilename, dictFilenames)))).first;
	}

	m_hyphenator = i->second.second;
	++i->second.first;
}


Hyphenate::~Hyphenate()
{
	::HyphenatorMap::iterator i = ::hyphenatorMap.find(m_filename);

	if (i == ::hyphenatorMap.end())
	{
		delete m_hyphenator;
	}
	else if (--i->second.first == 0 && m_keepInCache == DontKeepInCache)
	{
		M_ASSERT(m_hyphenator == i->second.second);
		delete i->second.second;
		::hyphenatorMap.erase(i);
	}
}


void
Hyphenate::clearCache(mstl::string const& patternFilename)
{
	if (patternFilename.empty())
	{
		for (::HyphenatorMap::iterator i = ::hyphenatorMap.begin(); i != ::hyphenatorMap.end(); )
		{
			if (i->second.first == 0)
			{
				delete i->second.second;
				i = ::hyphenatorMap.erase(i);
			}
			else
			{
				++i;
			}
		}
	}
	else
	{
		::HyphenatorMap::iterator i = ::hyphenatorMap.find(patternFilename);

		if (i != ::hyphenatorMap.end() && i->second.first == 0)
		{
			delete i->second.second;
			::hyphenatorMap.erase(i);
		}
	}
}


bool
Hyphenate::parse(char const* document, unsigned length)
{
	mstl::string hyphen("&shy;");
	mstl::string buf;

	unsigned skipCounter = 0;
	unsigned lessCounter = 0;

	char const* first		= document;
	char const* last		= document + length;
	char const* escape	= 0;
	char const* markup	= 0;

	m_result.clear();

	while (first < last)
	{
		if (mstl::is_odd(lessCounter))
		{
			char const* endMark = ::findChar(first, last, '>');

			if (endMark)
				--lessCounter, ++endMark;
			else
				endMark = last;

			m_result.append(first, endMark);
			first = endMark;

			if (escape < first)
				escape = 0;
		}
		else
		{
			if (!markup)
			{
				markup = ::findChar(first, last, '<');

				if (!markup)
					markup = last;
			}

			if (!escape)
			{
				escape = ::findChar(first, last, '&');

				if (!escape)
					escape = last;
			}

			if (escape < markup)
			{
				if (first < escape)
				{
					if (skipCounter > 0)
					{
						m_result.append(first, escape);
					}
					else
					{
						buf.hook(const_cast<char*>(first), escape - first);
						m_result.append(m_hyphenator->hyphenate(buf, hyphen));
					}
				}

				first = ::findChar(escape, last, ';');

				if (first)
					++first;
				else
					first = last;

				m_result.append(escape, first);
				escape = 0;
			}
			else
			{
				if (markup < last)
					++lessCounter;

				if (first < markup)
				{
					if (skipCounter > 0)
					{
						m_result.append(first, markup);
					}
					else
					{
						buf.hook(const_cast<char*>(first), markup - first);
						m_result.append(m_hyphenator->hyphenate(buf, hyphen));
					}

					first = markup;
				}

				if (first[0] == '<')
				{
					if (first[1] == '!' && first[2] == '-' && first[3] == '-')
					{
						char const* q = ::findChar(first + 4, last, '-');

						while (q && (q[1] != '-' || q[2] != '>'))
						q = ::findChar(q + 1, last, '-');

						first = q ? q + 3 : last;
					}
					else if (first[1] == '/')
					{
						if (::isExcludingTag(first + 2))
							--skipCounter;
					}
					else
					{
						char const* q = first + 1;

						while (first < last && *first != '<')
						++q;

						if (q < last && q[-1] == '/')
						{
							m_result.append(first, ++q);
							first = q;
							--lessCounter;
						}
						else if (::isExcludingTag(first + 1))
						{
							++skipCounter;
						}
					}
				}

				markup = 0;
			}
		}
	}

	return true;
}

// vi:set ts=3 sw=3:
