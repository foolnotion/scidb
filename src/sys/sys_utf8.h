// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _sys_utf8_included
#define _sys_utf8_included

#include "m_types.h"

namespace mstl { class string; }

namespace sys {
namespace utf8 {

typedef uint16_t uchar;

bool isTail(char c);
bool isFirst(char c);

bool validate(mstl::string const& str);
bool validate(char const* str, unsigned nbytes);

bool isAlpha(uchar uc);
bool isSpace(uchar uc);

bool isAscii(char c);

uchar toLower(uchar uc);
uchar toUpper(uchar uc);

unsigned countChars(mstl::string const& str);
unsigned countChars(char const* str, unsigned byteLength);
unsigned charLength(char const* str);

uchar getChar(char const* str);
mstl::string& append(mstl::string& result, uchar uc);

char const* nextChar(char const* str);
char const* nextChar(char const* str, uchar& code);
char const* prevChar(char const* str, char const* start);
char const* atIndex(char const* str, unsigned n);

char const* skipAlphas(char const* str, char const* end);
char const* skipNonAlphas(char const* str, char const* end);
char const* skipSpaces(char const* str, char const* end);
char const* skipNonSpaces(char const* str, char const* end);

void makeValid(mstl::string& str, bool& failed);

int compare(mstl::string const& lhs, mstl::string const& rhs);
int casecmp(mstl::string const& lhs, mstl::string const& rhs);

bool caseMatch(mstl::string const& lhs, mstl::string const& rhs, unsigned size);

int findFirst(char const* haystack, unsigned haystackLen, char const* needle, unsigned needleLen);
int findFirstNoCase(char const* haystack, unsigned haystackLen, char const* needle, unsigned needleLen);

unsigned levenstein(	mstl::string const& lhs,
							mstl::string const& rhs,
							unsigned ins = 2,
							unsigned del = 2,
							unsigned sub = 1);
bool isSimilar(mstl::string const& lhs, mstl::string const& rhs, unsigned threshold = 2);

} // namespace utf8
} // namespace sys

#include "sys_utf8.ipp"

#endif // _sys_utf8_included

// vi:set ts=3 sw=3:
