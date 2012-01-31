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

#include "sys_utf8.h"

#include "m_string.h"
#include "m_assert.h"

#include <tcl.h>


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


template <typename Func>
static
char const*
skip(char const* str, char const* end, Func func)
{
	if (str == end)
		return str;

	sys::utf8::uchar code;
	unsigned	len = Tcl_UtfToUniChar(str, &code);

	while (str < end && func(code))
		len = Tcl_UtfToUniChar(str += len, &code);
	
	return str;
}


unsigned
sys::utf8::countChars(mstl::string const& str)
{
	return Tcl_NumUtfChars(str, str.size());
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
	Tcl_UtfToUniChar(str, &code);
	return code;
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

	if (static_cast<unsigned char>(*str) >= 0xc0)
		return str + Tcl_UtfToUniChar(str, &code);

	code = *str;
	return ++str;
}


char const*
sys::utf8::prevChar(char const* str, char const* start)
{
	M_REQUIRE(str);
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
	return ::skip(str, end, IsAlpha());
}


char const*
sys::utf8::skipNonAlphas(char const* str, char const* end)
{
	return ::skip(str, end, IsNonAlpha());
}


char const*
sys::utf8::skipSpaces(char const* str, char const* end)
{
	return ::skip(str, end, IsSpace());
}


char const*
sys::utf8::skipNonSpaces(char const* str, char const* end)
{
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

// vi:set ts=3 sw=3:
