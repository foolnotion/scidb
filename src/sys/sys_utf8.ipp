// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include <tcl.h>

#include "m_string.h"
#include "m_assert.h"


namespace sys {
namespace utf8 {
namespace bits {

void append(mstl::string& result, uchar uc);
unsigned charLength(char const* str);
uchar toUniChar__(char const* s, unsigned charLen);


inline
unsigned
charLength(uchar uc)
{
	M_ASSERT(uc >= 0x80);
	M_ASSERT(sizeof(uchar) == 2);

	if (uc < 0x0000800) return 2;

#if 0 // only if sizeof(uchar) > 2
	if (uc < 0x0010000) return 3;
	if (uc < 0x0110000) return 4;
#endif

	return 3; // length of replacement character
}


inline
unsigned
toUniChar(char const* s, uchar& ch)
{
	M_ASSERT(s);

	unsigned charLen;

	if (static_cast<unsigned char>(*s) < 0x80)
	{
		ch = *s;
		charLen = 1;
	}
	else
	{
		ch = toUniChar__(s, charLen = charLength(s));
	}

	return charLen;
}

} // namespace bits
} // namespace utf8
} // namespace sys


inline bool sys::utf8::isFirst(char c)	{ return (c & 0xc0) != 0x80; }
inline bool sys::utf8::isTail(char c)	{ return (c & 0xc0) == 0x80; }
inline bool sys::utf8::isAscii(char c)	{ return (c & 0x80) == 0x00; }

inline bool sys::utf8::validate(mstl::string const& str) { return validate(str, str.size()); }


inline
unsigned
sys::utf8::charLength(char const* str)
{
	M_REQUIRE(str);
	return static_cast<unsigned char>(*str) < 0x80 ? 1 : bits::charLength(str);
}


inline
unsigned
sys::utf8::charLength(uchar uc)
{
	return uc < 0x80 ? 1 : bits::charLength(uc);
}

#ifndef USE_FAST_UTF8_STRING_LENGTH

inline
unsigned
sys::utf8::countChars(mstl::string const& str)
{
	return Tcl_NumUtfChars(str, str.size());
}

#endif

inline
unsigned
sys::utf8::countChars(char const* str, unsigned byteLength)
{
	return Tcl_NumUtfChars(str, byteLength);
}


inline
bool
sys::utf8::isAlpha(uchar uc)
{
	return Tcl_UniCharIsAlpha(uc);
}


inline
bool
sys::utf8::isAlnum(uchar uc)
{
	return Tcl_UniCharIsAlnum(uc);
}


inline
bool
sys::utf8::isSpace(uchar uc)
{
	return Tcl_UniCharIsSpace(uc);
}


inline
bool
sys::utf8::isPunct(uchar uc)
{
	return Tcl_UniCharIsPunct(uc);
}


inline
bool
sys::utf8::isLower(uchar uc)
{
	return Tcl_UniCharIsLower(uc);
}


inline
bool
sys::utf8::isUpper(uchar uc)
{
	return Tcl_UniCharIsUpper(uc);
}


inline
sys::utf8::uchar
sys::utf8::toLower(uchar uc)
{
	return Tcl_UniCharToLower(uc);
}


inline
sys::utf8::uchar
sys::utf8::toUpper(uchar uc)
{
	return Tcl_UniCharToUpper(uc);
}


inline
bool
sys::utf8::isSimilar(mstl::string const& lhs, mstl::string const& rhs, unsigned threshold)
{
	return levenshteinDistance(lhs, rhs) < threshold;
}


inline
char const*
sys::utf8::prevChar(char const* str, char const* start)
{
	M_REQUIRE(str);
	M_REQUIRE(start);

	return Tcl_UtfPrev(str, start);
}


inline
char const*
sys::utf8::atIndex(char const* str, unsigned n)
{
	M_REQUIRE(str);
	return Tcl_UtfAtIndex(str, n);
}


inline
unsigned
sys::utf8::copy(char* dst, uchar uc)
{
	// assert: sizeof(dst) >= charLength(uc)
	return Tcl_UniCharToUtf(uc, dst);
}


inline
sys::utf8::uchar
sys::utf8::getChar(char const* str)
{
	M_REQUIRE(str);

	uchar code;
	bits::toUniChar(str, code);
	return code;
}


inline
sys::utf8::uchar
sys::utf8::getChar(char const* str, unsigned& len)
{
	M_REQUIRE(str);

	uchar code;
	len = bits::toUniChar(str, code);
	return code;
}


inline
char const*
sys::utf8::nextChar(char const* str)
{
	M_REQUIRE(str);
	return str + (static_cast<unsigned char>(*str) < 0x80 ? 1 : charLength(str));
}


inline
char const*
sys::utf8::nextChar(char const* str, uchar& code)
{
	M_REQUIRE(str);

	str += bits::toUniChar(str, code);
	return str;
}


inline
mstl::string&
sys::utf8::append(mstl::string& result, uchar uc)
{
	if (uc < 0x80)
		result.append(char(uc));
	else
		bits::append(result, uc);
	return result;
}

// vi:set ts=3 sw=3:
