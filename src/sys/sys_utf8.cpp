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

#include "sys_utf8.h"

#include "m_string.h"
#include "m_utility.h"
#include "m_assert.h"

#include <tcl.h>
#include <ctype.h>


inline
static char const*
mapToGerman(int c)
{
	static char const GermanMap[128][2] =
#define ___ 0
#define _e_ 0
		{
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 80 81 82 83
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 84 85 86 87
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 88 89 8a 8b
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 8c 8d 8e 8f
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 90 91 92 93
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 94 95 96 97
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 98 99 9a 9b
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// 9c 9d 9e 9f
			{ '?', ___ }, { '?', ___ }, { 'c', ___ }, { '#', ___ },	// a0 a1 a2 a3
			{ '?', ___ }, { 'Y', ___ }, { '?', ___ }, { '?', ___ },	// a4 a5 a6 a7
			{ '?', ___ }, { 'C', ___ }, { '?', ___ }, { '?', ___ },	// a8 a9 aa ab
			{ '?', ___ }, { '?', ___ }, { 'R', ___ }, { '-', ___ },	// ac ad ae af
			{ '-', ___ }, { '-', ___ }, { '-', ___ }, { '?', ___ },	// b0 b1 b2 b3
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// b4 b5 b6 b7
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// b8 b9 ba bb
			{ '?', ___ }, { '?', ___ }, { '?', ___ }, { '?', ___ },	// bc bd be bf
			{ 'A', ___ }, { 'A', ___ }, { 'A', ___ }, { 'A', ___ },	// c0 c1 c2 c3
			{ 'A', 'e' }, { 'A', ___ }, { 'A', _e_ }, { 'C', ___ },	// c4 c5 c6 c7
			{ 'E', ___ }, { 'E', ___ }, { 'E', ___ }, { 'E', ___ },	// c8 c9 ca cb
			{ 'I', ___ }, { 'I', ___ }, { 'I', ___ }, { 'I', ___ },	// cc cd ce cf
			{ 'D', ___ }, { 'N', ___ }, { 'O', ___ }, { 'O', ___ },	// d0 d1 d2 d3
			{ 'O', ___ }, { 'O', ___ }, { 'O', 'e' }, { 'x', ___ },	// d4 d5 d6 d7
			{ 'O', 'e' }, { 'U', ___ }, { 'U', ___ }, { 'U', ___ },	// d8 d9 da db
			{ 'U', 'e' }, { 'Y', ___ }, { '?', ___ }, { 's', 's' },	// dc dd de df
			{ 'a', ___ }, { 'a', ___ }, { 'a', ___ }, { 'a', ___ },	// e0 e1 e2 e3
			{ 'a', 'e' }, { 'a', ___ }, { 'a', _e_ }, { 'c', ___ },	// e4 e5 e6 e7
			{ 'e', ___ }, { 'e', ___ }, { 'e', ___ }, { 'e', ___ },	// e8 e9 ea ab
			{ 'i', ___ }, { 'i', ___ }, { 'i', ___ }, { 'i', ___ },	// ec ed ee ef
			{ 'd', ___ }, { 'n', ___ }, { 'o', ___ }, { 'o', ___ },	// f0 f1 f2 f3
			{ 'o', ___ }, { 'o', ___ }, { 'o', 'e' }, { '/', ___ },	// f4 f5 f6 f7
			{ 'o', _e_ }, { 'u', ___ }, { 'u', ___ }, { 'u', ___ },	// f8 f9 fa fb
			{ 'u', 'e' }, { 'y', ___ }, { '?', ___ }, { 'y', ___ },	// fc fd fe ff
		};
#undef _e_
#undef ___

	return (c & 0xffffff80) == 0x80 ? GermanMap[c & 0x7f] : 0;
};


inline
static int
mapToLatin1(int c)
{
	static int const Latin1Map[128] =
	{
		'?', '?', '?', '?',	// 80 81 82 83
		'?', '?', '?', '?',	// 84 85 86 87
		'?', '?', '?', '?',	// 88 89 8a 8b
		'?', '?', '?', '?',	// 8c 8d 8e 8f
		'?', '?', '?', '?',	// 90 91 92 93
		'?', '?', '?', '?',	// 94 95 96 97
		'?', '?', '?', '?',	// 98 99 9a 9b
		'?', '?', '?', '?',	// 9c 9d 9e 9f
		'?', '?', 'c', '#',	// a0 a1 a2 a3
		'?', 'Y', '?', '?',	// a4 a5 a6 a7
		'?', 'C', '?', '?',	// a8 a9 aa ab
		'?', '?', 'R', '-',	// ac ad ae af
		'-', '-', '-', '?',	// b0 b1 b2 b3
		'?', '?', '?', '?',	// b4 b5 b6 b7
		'?', '?', '?', '?',	// b8 b9 ba bb
		'?', '?', '?', '?',	// bc bd be bf
		'A', 'A', 'A', 'A',	// c0 c1 c2 c3
		'A', 'A', 'A', 'C',	// c4 c5 c6 c7
		'E', 'E', 'E', 'E',	// c8 c9 ca cb
		'I', 'I', 'I', 'I',	// cc cd ce cf
		'D', 'N', 'O', 'O',	// d0 d1 d2 d3
		'O', 'O', 'O', 'x',	// d4 d5 d6 d7
		'O', 'U', 'U', 'U',	// d8 d9 da db
		'U', 'Y', '?', 's',	// dc dd de df
		'a', 'a', 'a', 'a',	// e0 e1 e2 e3
		'a', 'a', 'a', 'c',	// e4 e5 e6 e7
		'e', 'e', 'e', 'e',	// e8 e9 ea ab
		'i', 'i', 'i', 'i',	// ec ed ee ef
		'd', 'n', 'o', 'o',	// f0 f1 f2 f3
		'o', 'o', 'o', '/',	// f4 f5 f6 f7
		'o', 'u', 'u', 'u',	// f8 f9 fa fb
		'u', 'y', '?', 'y',	// fc fd fe ff
	};

	return (c & 0xffffff80) == 0x80 ? Latin1Map[c & 0x7f] : c;
}


inline
static int
latin1Diff(int lhs, int rhs)
{
	return mapToLatin1(lhs) - mapToLatin1(rhs);
}


namespace {

// adopted from Frank Yung-Fong Tang <http://people.netscape.com/ftang/utf8/isutf8.c>
//
// Valid octet sequences:
// 00-7f
//	c2-df	80-bf
//	e0		a0-bf 80-bf
//	e1-ec	80-bf 80-bf
//	ed		80-9f 80-bf
//	ee-ef	80-bf 80-bf
//	f0		90-bf 80-bf 80-bf
//	f1-f3	80-bf 80-bf 80-bf
//	f4		80-8f 80-bf 80-bf

enum State { Start, A, B, C, D, E, F, G, Error };

static int const Byte_Class_Lookup_Tbl[256] =
{
//	00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 00
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 10
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 20
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 30
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 40
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 50
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 60
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 70
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, // 80
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, // 90
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, // A0
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, // B0
	4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, // C0
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, // D0
	6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, // E0
	9,10,10,10,11, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, // F0
};

#define _ Error
static enum State const State_Transition_Tbl[12][8] =
{
//	  Start  A      B      C      D      E      F      G
	{ Start, _    , _    , _    , _    , _    , _    , _    }, //  0: 00-7f
	{ _    , Start, A    , _    , A    , B    , _    , B    }, //  1: 80-8f
	{ _    , Start, A    , _    , A    , B    , B    , _    }, //  2: 90-9f
	{ _    , Start, A    , A    , _    , B    , B    , _    }, //  3: a0-bf
	{ _    , _    , _    , _    , _    , _    , _    , _    }, //  4: c0-c1, f5-ff
	{ A    , _    , _    , _    , _    , _    , _    , _    }, //  5: c2-df
	{ C    , _    , _    , _    , _    , _    , _    , _    }, //  6: e0
	{ B    , _    , _    , _    , _    , _    , _    , _    }, //  7: e1-ec, ee-ef
	{ D    , _    , _    , _    , _    , _    , _    , _    }, //  8: ed
	{ F    , _    , _    , _    , _    , _    , _    , _    }, //  9: f0
	{ E    , _    , _    , _    , _    , _    , _    , _    }, // 10: f1-f3
	{ G    , _    , _    , _    , _    , _    , _    , _    }, // 11: f4
};
#undef _


inline
static State
nextState(State current, unsigned char c)
{
	return State_Transition_Tbl[Byte_Class_Lookup_Tbl[c]][current];
}

} // namespace


bool
sys::utf8::validate(char const* str, unsigned nbytes)
{
	M_REQUIRE(str);

	::State state = ::Start;

	for (char const* e = str + nbytes; str < e; ++str)
	{
		state = ::nextState(state, *str);

		if (state == ::Error)
			return false;
	}

	return state == ::Start;
}


sys::utf8::uchar
sys::utf8::bits::toUniChar__(char const* s, unsigned charLen)
{
	M_ASSERT(s);
	M_ASSERT(charLen > 1);

	sys::utf8::uchar value =
		(static_cast<unsigned char>(*s) & (0xff >> (charLen + 1))) << ((charLen - 1)*6);

	for (charLen -= 1, s += 1; charLen > 0; --charLen, ++s)
		value |= (static_cast<unsigned char>(*s) - 0x80) << ((charLen - 1)*6);

	return value;
}


static
bool
matchString(char const* s, char const* t, unsigned len)
{
	char const* e = s + len;

	while (s < e)
	{
		sys::utf8::uchar u, v;

		s += sys::utf8::bits::toUniChar(s, u);
		t += sys::utf8::bits::toUniChar(t, v);

		if (u != v)
			return false;
	}

	return true;
}


struct IsAlpha 	{ inline bool operator()(sys::utf8::uchar uc) { return  Tcl_UniCharIsAlpha(uc); } };
struct IsSpace		{ inline bool operator()(sys::utf8::uchar uc) { return  Tcl_UniCharIsSpace(uc); } };
struct IsNonAlpha	{ inline bool operator()(sys::utf8::uchar uc) { return !Tcl_UniCharIsAlpha(uc); } };
struct IsNonSpace	{ inline bool operator()(sys::utf8::uchar uc) { return !Tcl_UniCharIsSpace(uc); } };


template <typename Func>
static
char const*
skip(char const* str, char const* end, Func func)
{
	if (str == end)
		return str;

	sys::utf8::uchar code;
	unsigned	len = sys::utf8::bits::toUniChar(str, code);

	while (str < end && func(code))
		len = sys::utf8::bits::toUniChar(str += len, code);

	return str;
}


bool
sys::utf8::isAscii(mstl::string const& str)
{
	char const* s = str.begin();
	char const* e = str.end();

	for ( ; s < e; ++s)
	{
		if (!isAscii(*s))
			return false;
	}

	return true;
}


bool
sys::utf8::isAlpha(char const* s)
{
	uchar u;
	bits::toUniChar(s, u);
	return isAlpha(u);
}


bool
sys::utf8::isAlnum(char const* s)
{
	uchar u;
	bits::toUniChar(s, u);
	return isAlnum(u);
}


bool
sys::utf8::isSpace(char const* s)
{
	uchar u;
	bits::toUniChar(s, u);
	return isSpace(u);
}


bool
sys::utf8::isPunct(char const* s)
{
	uchar u;
	bits::toUniChar(s, u);
	return isPunct(u);
}


unsigned
sys::utf8::bits::charLength(char const* str)
{
	M_ASSERT(str);
	M_ASSERT(static_cast<unsigned char>(*str) >= 0x80);

	char c = *str;

	if ((c & 0xe0) == 0xc0) return 2;
	if ((c & 0xf0) == 0xe0) return 3;
	if ((c & 0xf8) == 0xf0) return 4;
							  
	char const* t = str + 5;
	while (isTail(*t))
		++t;
	return t - str;
}


unsigned
sys::utf8::bits::charLength(uchar uc)
{
	M_ASSERT(uc >= 0x80);

	if (uc < 0x0000800) return 2;
	if (uc < 0x0010000) return 3;
	if (uc < 0x0110000) return 4;

	return 3; // length of replacement character
}


unsigned
sys::utf8::byteLength(mstl::string const& str, unsigned numChars)
{
	M_REQUIRE(numChars <= countChars(str));

	char const* s = str;

	for (unsigned i = 0; i < numChars; ++i)
		s = nextChar(s);

	return s - str.c_str();
}


char*
sys::utf8::toLower(char* s)
{
	M_REQUIRE(s);

	uchar lower = getChar(s);

	if (isLower(lower))
	{
		uchar upper = Tcl_UniCharToUpper(lower);

		if (charLength(lower) == charLength(upper))
			copy(s, upper);
	}

	return s;
}


char*
sys::utf8::toUpper(char* s)
{
	M_REQUIRE(s);

	uchar upper = getChar(s);

	if (isUpper(upper))
	{
		uchar lower = Tcl_UniCharToLower(upper);

		if (charLength(lower) == charLength(upper))
			copy(s, lower);
	}

	return s;
}


void
sys::utf8::bits::append(mstl::string& result, uchar uc)
{
	M_ASSERT(uc >= 0x80);

	char buf[TCL_UTF_MAX];
	result.append(buf, Tcl_UniCharToUtf(uc, buf));
}


char const*
sys::utf8::skipAlphas(char const* str, char const* end)
{
	M_REQUIRE(str);
	M_REQUIRE(end);

	return ::skip(str, end, IsAlpha());
}


char const*
sys::utf8::skipNonAlphas(char const* str, char const* end)
{
	M_REQUIRE(str);
	M_REQUIRE(end);

	return ::skip(str, end, IsNonAlpha());
}


char const*
sys::utf8::skipSpaces(char const* str, char const* end)
{
	M_REQUIRE(str);
	M_REQUIRE(end);

	return ::skip(str, end, IsSpace());
}


char const*
sys::utf8::skipNonSpaces(char const* str, char const* end)
{
	M_REQUIRE(str);
	M_REQUIRE(end);

	return ::skip(str, end, IsNonSpace());
}


#ifdef USE_FAST_UTF8_STRING_LENGTH

// source: http://www.daemonology.net/blog/2008-06-05-faster-utf8-strlen.html
unsigned
sys::utf8::countChars(mstl::string const& str)
{
	static size_t const OneMask = size_t(-1)/0xff;

	size_t count = 0;

	// Handle any initial misaligned bytes.
	for (char const* s = str.c_str(); (uintptr_t)(s) & (sizeof(size_t) - 1); ++s)
	{
		unsigned char b = *s;

		// Exit if we hit a zero byte.
		if (b == '\0')
			return ((s - str.c_str()) - count);

		// Is this byte NOT the first byte of a character?
		count += (b >> 7) & ((~b) >> 6);
	}

	// Handle complete blocks.
	for ( ; ; s += sizeof(size_t))
	{
		// Prefetch 256 bytes ahead.
		__builtin_prefetch(&s[256], 0, 0);

		// Grab 4 or 8 bytes of UTF-8 data.
		size_t u = *(size_t const*)(s);

		// Exit the loop if there are any zero bytes.
		if ((u - OneMask) & (~u) & (OneMask*0x80))
			break;

		// Count bytes which are NOT the first byte of a character.
		u = ((u & (OneMask * 0x80)) >> 7) & ((~u) >> 6);
		count += (u*OneMask) >> ((sizeof(size_t) - 1)*8);
	}

	// Take care of any left-over bytes.
	for ( ; ; ++s)
	{
		unsigned char b = *s;

		// Exit if we hit a zero byte.
		if (b == '\0')
			break;

		// Is this byte NOT the first byte of a character?
		count += (b >> 7) & ((~b) >> 6);
	}

	return ((s - str.c_str()) - count);
}

#endif


unsigned
sys::utf8::makeValid(mstl::string& str, mstl::string const& replacement)
{
	mstl::string result;

	char const* s = str.begin();
	char const* e = str.end();
	char const* p = s;

	unsigned removed = 0;

	::State state = ::Start;

	for ( ; s < e; ++s)
	{
		state = ::nextState(state, *s);

		switch (int(state))
		{
			case ::Error:
				result.append(replacement);
				removed += 1;
				state = ::Start;
				while (s < e && ((*s & 0xc0) == 0x80 || ::nextState(state, *s) != ::Start))
					++s;
				p = s;
				if (s < e)
					--s;
				break;

			case ::Start:
				result.append(p, s + 1);
				p = s + 1;
				break;
		}
	}

	if (state != ::Error && state != ::Start)
	{
		result.append(replacement);
		removed += 1;
	}

	str.swap(result);
	return removed;
}


int
sys::utf8::compare(mstl::string const& lhs, mstl::string const& rhs)
{
	M_REQUIRE(validate(lhs));
	M_REQUIRE(validate(rhs));

	char const* p = lhs.c_str();
	char const* q = rhs.c_str();

	while (true)
	{
		uchar c, d;

		if (*p == 0) return *q == 0 ? 0 : -1;
		if (*q == 0) return *p == 0 ? 0 : +1;

		p = nextChar(p, c);
		q = nextChar(q, d);

		if (c != d) return int(c) - int(d);
	}

	return 0;	// satisfies the compiler
}


int
sys::utf8::casecmp(mstl::string const& lhs, mstl::string const& rhs)
{
	M_REQUIRE(validate(lhs));
	M_REQUIRE(validate(rhs));

	// IMPORTANT NOTE:
	// At this time, the case conversions are only defined for the ISO8859-1 characters.

	char const* p = lhs.c_str();
	char const* q = rhs.c_str();

	while (true)
	{
		uchar c, d;

		if (*p == 0) return *q == 0 ? 0 : -1;
		if (*q == 0) return *p == 0 ? 0 : +1;

		p = nextChar(p, c);
		q = nextChar(q, d);

		if (c != d)
		{
			c = toLower(c);
			d = toLower(d);

			if (c != d) return int(c) - int(d);
		}
	}

	return 0;	// satisfies the compiler
}


bool
sys::utf8::caseMatch(mstl::string const& lhs, mstl::string const& rhs, unsigned size)
{
	M_REQUIRE(validate(lhs));
	M_REQUIRE(validate(rhs));

	// IMPORTANT NOTE:
	// At this time, the case conversions are only defined for the ISO8859-1 characters.

	char const* p = lhs.c_str();
	char const* q = rhs.c_str();
	char const* e = p + size;
	char const* f = q + size;

	uchar c, d;

	while (p < e && q < f)
	{
		if (*p == 0)
			return false;
		if (*q == 0)
			return true;

		p = nextChar(p, c);
		q = nextChar(q, d);

		if (c != d)
		{
			c = toLower(c);
			d = toLower(d);

			if (c != d)
				return false;
		}
	}

	return true;
}


bool
sys::utf8::matchChar(char const* lhs, char const* rhs)
{
	if (isAscii(*lhs))
		return *lhs == *rhs;
	
	if (isAscii(*rhs))
		return false;

	uchar u, v;

	bits::toUniChar(lhs, u);
	bits::toUniChar(rhs, v);

	return u == v;
}


bool
sys::utf8::caseMatchChar(char const* lhs, char const* rhs)
{
	if (isAscii(*lhs))
		return ::toupper(*lhs) == ::toupper(*rhs);

	if (isAscii(*rhs))
		return false;

	uchar u, v;

	bits::toUniChar(lhs, u);
	bits::toUniChar(rhs, v);

	return sys::utf8::toLower(u) == sys::utf8::toLower(v);
}


char const*
sys::utf8::findString(char const* haystack, unsigned haystackLen, char const* needle, unsigned needleLen)
{
	M_REQUIRE(haystack);
	M_REQUIRE(needle);
	M_REQUIRE(validate(needle, needleLen));
	M_REQUIRE(validate(haystack, haystackLen));

	if (needleLen == 0)
		return 0;

	char const* end = haystack + haystackLen - needleLen + 1;

	for (char const* p = haystack; p < end; p = nextChar(p))
	{
		if (matchChar(p, needle) && ::matchString(p, needle, needleLen))
			return p;
	}

	return 0;
}


static
bool
matchStringNoCase(char const* s, char const* t, unsigned len)
{
	M_REQUIRE(s);
	M_REQUIRE(t);

	char const* e = s + len;

	while (s < e)
	{
		sys::utf8::uchar u, v;

		s += sys::utf8::bits::toUniChar(s, u);
		t += sys::utf8::bits::toUniChar(t, v);

		if (sys::utf8::toLower(u) != sys::utf8::toLower(v))
			return false;
	}

	return true;
}


char const*
sys::utf8::findStringNoCase(	char const* haystack,
										unsigned haystackLen,
										char const* needle,
										unsigned needleLen)
{
	M_REQUIRE(haystack);
	M_REQUIRE(needle);
	M_REQUIRE(validate(needle, needleLen));
	M_REQUIRE(validate(haystack, haystackLen));

	if (needleLen == 0)
		return 0;

	char const* end = haystack + haystackLen - needleLen + 1;

	uchar u;
	unsigned bytes = bits::toUniChar(needle, u);

	u = toLower(u);
	needleLen -= bytes;
	needle += bytes;

	for (char const* p = haystack; p < end; )
	{
		char const* s = p;
		uchar v;

		p += bits::toUniChar(p, v);

		if (u == toLower(v) && ::matchStringNoCase(p, needle, needleLen))
			return s;
	}

	return 0;
}


int
sys::utf8::findFirst(char const* haystack, unsigned haystackLen, char const* needle, unsigned needleLen)
{
	char const* p = findString(haystack, haystackLen, needle, needleLen);
	return p ? p - haystack : -1;
}


int
sys::utf8::findFirstNoCase(char const* haystack,
									unsigned haystackLen,
									char const* needle,
									unsigned needleLen)
{
	char const* p = findStringNoCase(haystack, haystackLen, needle, needleLen);
	return p ? p - haystack : -1;
}


char const*
sys::utf8::findChar(char const* s, char const* e, uchar code)
{
	while (s < e)
	{
		uchar u;
		s += bits::toUniChar(s, u);

		if (u == code)
			return s;
	}

	return 0;
}


char const*
sys::utf8::findCharNoCase(char const* s, char const* e, uchar code)
{
	code = toLower(code);

	while (s < e)
	{
		uchar u;
		s += bits::toUniChar(s, u);

		if (toLower(u) == code)
			return s;
	}

	return 0;
}


unsigned
sys::utf8::levenshteinDistance(	mstl::string const& lhs,
											mstl::string const& rhs,
											unsigned ins,
											unsigned del,
											unsigned sub)
{
	if (lhs.c_str() == rhs.c_str())
		return 0;

	unsigned lhsSize = sys::utf8::countChars(lhs);
	unsigned rhsSize = sys::utf8::countChars(rhs);

	if (lhsSize == 0)
		return rhsSize*ins;

	if (rhsSize == 0)
		return lhsSize*ins;

	// algorithm from http://en.wikipedia.org/wiki/Levenshtein_distance

	uchar d[lhsSize + 1][rhsSize + 1];
	uchar c[lhsSize];

	::memset(d, 0, sizeof(uchar)*(lhsSize+ 1)*(rhsSize + 1));

	for (unsigned i = 0; i <= lhsSize; ++i)
		d[i][0] = i;
	for (unsigned j = 0; j <= rhsSize; ++j)
		d[0][j] = j;

	char const* ls = lhs.c_str();
	char const* rs = rhs.c_str();

	for (unsigned i = 0; i < lhsSize; ++i)
		ls = nextChar(ls, c[i]);

	for (unsigned j = 0; j < rhsSize; ++j)
	{
		uchar b;

		rs = nextChar(rs, b);

		for (unsigned i = 0; i < lhsSize; ++i)
		{
			if (c[i] == b)
				d[i + 1][j + 1] = d[i][j];
			else
				d[i + 1][j + 1] = mstl::min(d[i][j + 1] + del, d[i + 1][j] + ins, d[i][j] + sub);
		}
	}

	return d[lhsSize][rhsSize];
}


unsigned
sys::utf8::levenshteinDistanceFast(mstl::string const& lhs, mstl::string const& rhs)
{
	if (lhs.c_str() == rhs.c_str())
		return 0;

	unsigned lhsSize = sys::utf8::countChars(lhs);
	unsigned rhsSize = sys::utf8::countChars(rhs);

	if (lhsSize == 0)
		return rhsSize;

	if (rhsSize == 0)
		return lhsSize;

	// algorithm from http://en.wikipedia.org/wiki/Levenshtein_distance

	unsigned v0[rhs.size() + 1];
	unsigned v1[rhs.size() + 1];

	for (unsigned i = 0; i <= rhs.size(); ++i)
		v0[i] = i;

	uchar d[rhsSize];

	char const* ls = lhs.c_str();
	char const* rs = rhs.c_str();

	for (unsigned i = 0; i < rhsSize; ++i)
		rs = nextChar(rs, d[i]);

	for (unsigned i = 0; i < lhsSize; ++i)
	{
		uchar c;

		ls = nextChar(ls, c);
		v1[0] = i + 1;

		for (unsigned j = 0; j < rhsSize; ++j)
		{
			unsigned cost = (c == d[j]) ? 0 : 1;
			v1[j + 1] = mstl::min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
		}

		for (unsigned j = 0; j <= rhs.size(); ++j)
			v0[j] = v1[j];
	}

	return v1[rhs.size()];
}


void
sys::utf8::latin1::map(mstl::string const& name, mstl::string& result)
{
	char const* s = name.begin();
	char const* e = name.end();

	result.clear();
	result.reserve(name.size());

	while (s < e)
	{
		uchar c;
		s += bits::toUniChar(s, c);
		append(result, ::mapToLatin1(c));
	}
}


int
sys::utf8::latin1::dictionaryCompare(char const* lhs, char const* rhs, bool skipPunct)
{
	M_REQUIRE(lhs);
	M_REQUIRE(rhs);

	typedef unsigned char Byte;

	int diff = 0;
	int secondaryDiff = 0;

	while (true)
	{
		if (isdigit(*rhs) && isdigit(*lhs))
		{
			int zeros = 0;

			while (*rhs == '0' && isdigit(rhs[1]))
			{
				rhs++;
				zeros--;
			}

			while (*lhs == '0' && isdigit(lhs[1]))
			{
				lhs++;
				zeros++;
			}

			if (secondaryDiff == 0)
				secondaryDiff = zeros;

			diff = 0;

			while (1)
			{
				if (diff == 0)
					diff = int(Byte(*lhs)) - int(Byte(*rhs));

				rhs++;
				lhs++;

				if (!isdigit(*rhs))
				{
					if (isdigit(*lhs))
						return -1;

					if (diff)
						return diff;

					break;
				}
				else if (!isdigit(*lhs))
				{
					return +1;
				}
			}
		}
		else if (skipPunct && ispunct(*lhs))
		{
			++lhs;
		}
		else if (skipPunct && ispunct(*rhs))
		{
			++rhs;
		}
		else
		{
			uchar ulhs, urhs;

			if (*lhs && *rhs)
			{
				lhs += bits::toUniChar(lhs, ulhs);
				rhs += bits::toUniChar(rhs, urhs);

				ulhs = toLower(ulhs);
				urhs = toLower(urhs);
			}
			else
			{
				diff = int(Byte(*lhs)) - int(Byte(*rhs));
				break;
			}

			if ((diff = latin1Diff(ulhs, urhs)))
				return diff;

			// special case: German s-zet
			if (ulhs == 0xdf)
			{
				if (*rhs != 's')
				{
					bits::toUniChar(rhs, urhs);
					return int('s') - int(toLower(urhs));
				}
			}
			else if (urhs == 0xdf)
			{
				if (*lhs != 's')
				{
					bits::toUniChar(rhs, ulhs);
					return int(toLower(ulhs)) - int('s');
				}
			}

			if (secondaryDiff == 0)
			{
				if (isUpper(ulhs) && isLower(urhs))
					secondaryDiff = +1;
				else if (isUpper(urhs) && isLower(ulhs))
					secondaryDiff = -1;
			}
		}
	}

	if (diff == 0)
		diff = secondaryDiff;

	return diff;
}


int
sys::utf8::latin1::compare(char const* lhs, char const* rhs, bool noCase, bool skipPunct)
{
	M_REQUIRE(lhs);
	M_REQUIRE(rhs);

	typedef unsigned char Byte;

	while (true)
	{
		if (*lhs == '\0' || *rhs == '\0')
			return int(Byte(*lhs)) - int(Byte(*rhs));

		if (skipPunct)
		{
			if (ispunct(*lhs))
			{
				++lhs;
				continue;
			}

			if (ispunct(*rhs))
			{
				++rhs;
				continue;
			}
		}

		uchar ulhs, urhs;

		lhs += bits::toUniChar(lhs, ulhs);
		rhs += bits::toUniChar(rhs, urhs);

		if (noCase)
		{
			ulhs = toLower(ulhs);
			urhs = toLower(urhs);
		}

		if (int diff = latin1Diff(ulhs, urhs))
			return diff;

		// special case: German s-zet
		if (ulhs == 0xdf)
		{
			if (*rhs != 's')
			{
				bits::toUniChar(rhs, urhs);
				if (noCase)
					urhs = toLower(urhs);
				return int('s') - int(urhs);
			}
		}
		else if (urhs == 0xdf)
		{
			if (*lhs != 's')
			{
				bits::toUniChar(rhs, ulhs);
				if (noCase)
					ulhs = toLower(ulhs);
				return int(ulhs) - int('s');
			}
		}
	}

	return 0; // satisfies the compiler
}


bool
sys::utf8::ascii::match(mstl::string const& utf8, mstl::string const& ascii, bool noCase)
{
	// IMPORTANT NOTE:
	// At this time, the match algorithm is only defined for the ISO8859-1 characters.

	char const* s = ascii.begin();
	char const* e = ascii.end();
	char const* t = utf8.begin();
	char const* f = utf8.end();

	uchar c;

	if (noCase)
	{
		while (t < f)
		{
			if (s == e)
				return false;

			t += bits::toUniChar(t, c);

			uchar d = ::mapToLatin1(toLower(c));

			if (d != ::tolower(*s++))
				return false;

			// special case: German s-zet
			if (c == 0xdf && *s++ != 's')
				return false;
		}
	}
	else
	{
		while (t < f)
		{
			if (s == e)
				return false;

			t += bits::toUniChar(t, c);

			uchar d = ::mapToLatin1(toLower(c));

			if (d != *s++)
				return false;

			// special case: German s-zet
			if (c == 0xdf && *s++ != 's')
				return false;
		}
	}

	return true;
}


void
sys::utf8::german::map(mstl::string const& name, mstl::string& result)
{
	char const* s = name.begin();
	char const* e = name.end();

	result.clear();
	result.reserve(mstl::mul2(name.size()));

	while (s < e)
	{
		uchar c;
		s += bits::toUniChar(s, c);

		char const* ss = mapToGerman(c);

		if (ss)
		{
			result += ss[0];

			if (ss[1])
				result += ss[1];
		}
		else
		{
			result += c;
		}
	}
}


bool
sys::utf8::german::match(mstl::string const& utf8, mstl::string const& ascii, bool noCase)
{
	// IMPORTANT NOTE:
	// At this time, the match algorithm is only defined for the ISO8859-1 characters.

	char const* s = ascii.begin();
	char const* e = ascii.end();
	char const* t = utf8.begin();
	char const* f = utf8.end();

	uchar c;

	if (noCase)
	{
		while (t < f)
		{
			if (s == e)
				return false;

			t += bits::toUniChar(t, c);
			c = toLower(c);

			char const* ss = ::mapToGerman(c);

			if (ss)
			{
				if (ss[0] != ::tolower(*s++))
					return false;

				if (s == e)
					return false;

				if (ss[1] && ss[1] != ::tolower(*s++))
					return false;
			}
			else
			{
				if (c != ::tolower(*s++))
					return false;
			}
		}
	}
	else
	{
		while (t < f)
		{
			if (s == e)
				return false;

			t += bits::toUniChar(t, c);

			char const* ss = ::mapToGerman(c);

			if (ss)
			{
				if (ss[0] != *s++)
					return false;

				if (ss == e)
					return false;

				if (ss[1] && ss[1] != *s++)
					return false;
			}
			else
			{
				if (c != *s++)
					return false;
			}
		}
	}

	return true;
}

// vi:set ts=3 sw=3:
