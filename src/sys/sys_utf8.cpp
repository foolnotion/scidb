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
			{ 'O', ___ }, { 'O', ___ }, { 'O', ___ }, { 'x', ___ },	// d4 d5 d6 d7
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


namespace validate {

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

} // namespace validate


bool
sys::utf8::validate(char const* str, unsigned nbytes)
{
	M_REQUIRE(str);

	validate::State state = validate::Start;

	for (char const* e = str + nbytes; str < e; ++str)
	{
		state = validate::nextState(state, *str);

		if (state == validate::Error)
			return false;
	}

	return state == validate::Start;
}


inline static int
utfToUniChar(char const* s, sys::utf8::uchar& ch)
{
	static_assert(sizeof(Tcl_UniChar) == sizeof(sys::utf8::uchar), "re-implementation required");

	if (static_cast<unsigned char>(*s) >= 0xc0)
		return Tcl_UtfToUniChar(s, &ch);

	ch = *s;
	return 1;
}


static
bool
matchString(char const* s, char const* t, unsigned len)
{
	char const* e = s + len;

	while (s < e)
	{
		sys::utf8::uchar u, v;

		s += ::utfToUniChar(s, u);
		t += ::utfToUniChar(t, v);

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
	unsigned	len = ::utfToUniChar(str, code);

	while (str < end && func(code))
		len = ::utfToUniChar(str += len, code);

	return str;
}


unsigned
sys::utf8::countChars(mstl::string const& str)
{
	return Tcl_NumUtfChars(str, str.size());
}


unsigned
sys::utf8::countChars(char const* str, unsigned byteLength)
{
	return Tcl_NumUtfChars(str, byteLength);
}


bool
sys::utf8::isAlpha(uchar uc)
{
	return Tcl_UniCharIsAlpha(uc);
}


bool
sys::utf8::isSpace(uchar uc)
{
	return Tcl_UniCharIsSpace(uc);
}


bool
sys::utf8::isLower(uchar uc)
{
	return Tcl_UniCharIsLower(uc);
}


bool
sys::utf8::isUpper(uchar uc)
{
	return Tcl_UniCharIsUpper(uc);
}


sys::utf8::uchar
sys::utf8::toLower(uchar uc)
{
	return Tcl_UniCharToLower(uc);
}


sys::utf8::uchar
sys::utf8::toUpper(uchar uc)
{
	return Tcl_UniCharToUpper(uc);
}


unsigned
sys::utf8::charLength(char const* str)
{
	M_REQUIRE(str);
	return Tcl_UtfNext(str) - str;
}


sys::utf8::uchar
sys::utf8::getChar(char const* str)
{
	M_REQUIRE(str);

	uchar code;
	::utfToUniChar(str, code);
	return code;
}


mstl::string&
sys::utf8::append(mstl::string& result, uchar uc)
{
	char buf[TCL_UTF_MAX];
	result.append(buf, Tcl_UniCharToUtf(uc, buf));
	return result;
}


char const*
sys::utf8::nextChar(char const* str)
{
	M_REQUIRE(str);
	return Tcl_UtfNext(str);
}


char const*
sys::utf8::nextChar(char const* str, uchar& code)
{
	M_REQUIRE(str);

	str += ::utfToUniChar(str, code);
	return str;
}


char const*
sys::utf8::prevChar(char const* str, char const* start)
{
	M_REQUIRE(str);
	M_REQUIRE(start);

	return Tcl_UtfPrev(str, start);
}


char const*
sys::utf8::atIndex(char const* str, unsigned n)
{
	M_REQUIRE(str);
	return Tcl_UtfAtIndex(str, n);
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


void
sys::utf8::makeValid(mstl::string& str, bool& failed)
{
	mstl::string result;

	char const* s = str.begin();
	char const* e = str.end();
	char const* p = s;

	validate::State state = validate::Start;

	for ( ; s < e; ++s)
	{
		state = validate::nextState(state, *s);

		switch (int(state))
		{
			case validate::Error:
				result += '?';
				failed = true;
				state = validate::Start;
				while (s < e && ((*s & 0xc0) == 0x80 || validate::nextState(state, *s) == validate::Error))
					++s;
				p = s;
				if (s < e)
					--s;
				break;

			case validate::Start:
				result.append(p, s + 1);
				p = s + 1;
				break;
		}
	}

	if (state != validate::Error && state != validate::Start)
	{
		failed = true;
		result += '?';
	}

	str.swap(result);
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


int
sys::utf8::findFirst(char const* haystack, unsigned haystackLen, char const* needle, unsigned needleLen)
{
	M_REQUIRE(haystack);
	M_REQUIRE(needle);
	M_REQUIRE(validate(needle, needleLen));
	M_REQUIRE(validate(haystack, haystackLen));

	if (needleLen == 0)
		return -1;

	char const* end = haystack + haystackLen - needleLen + 1;

	for (char const* p = haystack; p < end; p = nextChar(p))
	{
		if (*p == *needle && ::matchString(p, needle, needleLen))
			return p - haystack;
	}

	return -1;
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

		s += ::utfToUniChar(s, u);
		t += ::utfToUniChar(t, v);

		if (sys::utf8::toUpper(u) != sys::utf8::toUpper(v))
			return false;
	}

	return true;
}


int
sys::utf8::findFirstNoCase(char const* haystack,
									unsigned haystackLen,
									char const* needle,
									unsigned needleLen)
{
	M_REQUIRE(haystack);
	M_REQUIRE(needle);
	M_REQUIRE(validate(needle, needleLen));
	M_REQUIRE(validate(haystack, haystackLen));

	if (needleLen == 0)
		return -1;

	char const* end = haystack + haystackLen - needleLen + 1;

	uchar u;
	unsigned bytes = ::utfToUniChar(needle, u);
	u = toUpper(u);
	needleLen -= bytes;
	needle += bytes;

	for (char const* p = haystack; p < end; )
	{
		char const* s = p;
		uchar v;

		p += ::utfToUniChar(p, v);

		if (u == toUpper(v) && ::matchStringNoCase(p, needle, needleLen))
			return s - haystack;
	}

	return -1;
}


unsigned
sys::utf8::levenstein(	mstl::string const& lhs,
								mstl::string const& rhs,
								unsigned ins,
								unsigned del,
								unsigned sub)
{
	// we have to restrict array size
	M_REQUIRE(countChars(lhs) < 256);
	M_REQUIRE(countChars(rhs) < 256);

	unsigned lhsSize = sys::utf8::countChars(lhs);
	unsigned rhsSize = sys::utf8::countChars(rhs);

	if (lhsSize == 0)
		return rhsSize*ins;
	if (rhsSize == 0)
		return lhsSize*ins;

	// algorithm from http://en.wikipedia.org/wiki/Levenshtein_distance

	uchar d[256][256];
	uchar c[256];

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
				lhs += ::utfToUniChar(lhs, ulhs);
				rhs += ::utfToUniChar(rhs, urhs);

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
					::utfToUniChar(rhs, urhs);
					return int('s') - int(toLower(urhs));
				}
			}
			else if (urhs == 0xdf)
			{
				if (*lhs != 's')
				{
					::utfToUniChar(rhs, ulhs);
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

		lhs += ::utfToUniChar(lhs, ulhs);
		rhs += ::utfToUniChar(rhs, urhs);

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
				::utfToUniChar(rhs, urhs);
				if (noCase)
					urhs = toLower(urhs);
				return int('s') - int(urhs);
			}
		}
		else if (urhs == 0xdf)
		{
			if (*lhs != 's')
			{
				::utfToUniChar(rhs, ulhs);
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

			t += ::utfToUniChar(t, c);

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

			t += ::utfToUniChar(t, c);

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
		s += ::utfToUniChar(s, c);

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

			t += ::utfToUniChar(t, c);
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

			t += ::utfToUniChar(t, c);

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
