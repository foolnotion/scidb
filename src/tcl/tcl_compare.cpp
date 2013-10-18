// ======================================================================
// Author : $Author$
// Version: $Revision: 569 $
// Date   : $Date: 2012-12-16 22:41:55 +0100 (Sun, 16 Dec 2012) $
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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_compare.h"
#include "tcl_base.h"

#include "T_AhoCorasick.h"

#include "u_base.h"

#include "sys_utf8.h"

#include "m_string.h"
#include "m_auto_ptr.h"
#include "m_assert.h"

#include <tcl.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace TeXt;


static sys::utf8::uchar m_sortOrderTable[256] =
{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

static char* m_sortMappingTable[256] =
{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

static AhoCorasick* m_lookup = 0;


int
tcl::compare::compare(Tcl_Obj* lhs, Tcl_Obj* rhs)
{
	static_assert(sizeof(sys::utf8::uchar) == 2, "algorithm not working");

	typedef sys::utf8::uchar const uchar;

	int lhsLen, rhsLen;

	uchar* lhsArr = reinterpret_cast<uchar*>(Tcl_GetByteArrayFromObj(lhs, &lhsLen));
	uchar* rhsArr = reinterpret_cast<uchar*>(Tcl_GetByteArrayFromObj(rhs, &rhsLen));

	uchar* lhsEnd = lhsArr + mstl::div2(lhsLen) - 1;
	uchar* rhsEnd = rhsArr + mstl::div2(rhsLen) - 1;

	M_ASSERT(lhsArr <= lhsEnd);
	M_ASSERT(rhsArr <= rhsEnd);

	while (true)
	{
		if (lhsArr == lhsEnd)
			return -int(*rhsArr);
		if (rhsArr == rhsEnd)
			return int(*lhsArr);

		if (int diff = int(*lhsArr) - int(*rhsArr))
			return diff;

		++lhsArr;
		++rhsArr;
	}

	return 0; // satisfies the compiler
}


inline
static char const*
sortMapping(sys::utf8::uchar c)
{
	return c < 256 ? m_sortMappingTable[c] : 0;
}


inline
static sys::utf8::uchar
sortOrder(sys::utf8::uchar c)
{
	return c < 256 ? m_sortOrderTable[c] : c;
}


#if 0
static void
append(Tcl_DString* ds, char const* s, unsigned length)
{
	static_assert(sizeof(sys::utf8::uchar) == 2, "buffer too small");

	char buffer[mstl::mul4(length)];
	char* buf = buffer;

	for (char const* e = s + length ; s < e; buf += 2)
	{
		sys::utf8::uchar uc;
		s = sys::utf8::nextChar(s, uc);
		*reinterpret_cast<sys::utf8::uchar*>(buf) = uc;
	}

	Tcl_DStringAppend(ds, buf, buf - buffer);
}
#endif


inline
static void
append(Tcl_DString* ds, sys::utf8::uchar uc)
{
	static_assert(sizeof(sys::utf8::uchar) == 2, "buffer too small");

	union
	{
		char ch[2];
		sys::utf8::uchar uc;
	}
	buf;

	buf.uc = uc;
	Tcl_DStringAppend(ds, buf.ch, 2);
}


Tcl_Obj*
tcl::compare::makeComparableObj(char const* s, bool skipPunct)
{
	mstl::string str;

	while (*s)
	{
		if (skipPunct && ispunct(*s))
		{
			++s;
		}
		else
		{
			sys::utf8::uchar uc;

			char const* t = sys::utf8::nextChar(s, uc);

			uc = sys::utf8::toLower(uc);

			if (char const* m = sortMapping(uc))
				str.append(m);
			else if (sys::utf8::isAscii(uc))
				str += char(uc);
			else
				sys::utf8::append(str, uc);

			s = t;
		}
	}

	Tcl_DString result;
	Tcl_DStringInit(&result);

	s = str.c_str();

	while (*s)
	{
		sys::utf8::uchar uc;

		char const* t = sys::utf8::nextChar(s, uc);

		if (m_lookup)
		{
			unsigned code;
			char const* u = m_lookup->findTag(s, code);

			if (u)
			{
				::append(&result, sys::utf8::uchar(code));
				t = u;
			}
			else
			{
				::append(&result, sortOrder(uc));
			}
		}
		else
		{
			::append(&result, sortOrder(uc));
		}

		s = t;
	}

	::append(&result, 0);
	unsigned char* arr = reinterpret_cast<unsigned char*>(Tcl_DStringValue(&result));
	Tcl_Obj* obj = Tcl_NewByteArrayObj(arr, Tcl_DStringLength(&result));
	Tcl_DStringFree(&result);
	return obj;
}


int
tcl::compare::setMappingTable(Tcl_Obj* table)
{
	static Tcl_Obj* mappingObj = 0;

	if (table == mappingObj)
		return TCL_OK;

	Tcl_Obj **entries;
	int nentries;

	if (Tcl_ListObjGetElements(interp(), table, &nentries, &entries) != TCL_OK)
		return TCL_ERROR;

	if (nentries % 2 == 1)
	{
		Tcl_AppendResult(interp(), "argument of \"-mapping\" must have even number of entries", nullptr);
		return TCL_ERROR;
	}

	for (unsigned i = 0; i < 256; ++i)
	{
		if (m_sortMappingTable[i])
			free(m_sortMappingTable[i]);
	}

	::memset(m_sortMappingTable, 0, sizeof(m_sortMappingTable));

	int n = mstl::div2(nentries);
	
	for (int i = 0; i < n; i += 2)
	{
		sys::utf8::uchar index = sys::utf8::getChar(Tcl_GetString(entries[i]));

		if (index >= 256)
		{
			Tcl_AppendResult(interp(), "Latin-1 character expected", nullptr);
			return TCL_ERROR;
		}

		m_sortMappingTable[index] = ::strdup(Tcl_GetString(entries[i + 1]));
	}

	mappingObj = table;

	return TCL_OK;
}


int
tcl::compare::setAlphabeticList(Tcl_Obj* table)
{
	static Tcl_Obj* alphList = 0;

	if (table == alphList)
		return TCL_OK;

	Tcl_Obj **entries;
	int nentries;

	if (Tcl_ListObjGetElements(interp(), table, &nentries, &entries) != TCL_OK)
		return TCL_ERROR;
	
	if (nentries == 0)
	{
		delete m_lookup;
		m_lookup = 0;

		for (unsigned i = 0; i < 256; ++i)
			m_sortOrderTable[i] = i;
	}
	else
	{
		mstl::auto_ptr<AhoCorasick> lookup(new AhoCorasick);

		Tcl_Obj* used[256];
		::memset(used, 0, sizeof(used));
		::memset(m_sortOrderTable, 0, sizeof(m_sortOrderTable));

		for (int i = 0; i < nentries; ++i)
		{
			Tcl_Obj **subEntries;
			int nsubEntries;

			if (Tcl_ListObjGetElements(interp(), entries[i], &nsubEntries, &subEntries) != TCL_OK)
				return TCL_ERROR;

			if (nsubEntries > 1)
			{
				sys::utf8::uchar uc = sys::utf8::getChar(Tcl_GetString(subEntries[0]));

				if (uc > 256)
				{
					Tcl_AppendResult(interp(), "character out of Latin-1", nullptr);
					return TCL_ERROR;
				}

				used[uc] = entries[i];
			}
		}

		unsigned count = 0;

		for (unsigned i = 0; i < 256; ++i)
		{
			if (m_sortOrderTable[i] == 0)
				m_sortOrderTable[i] = ++count;

			if (Tcl_Obj* list = used[i])
			{
				Tcl_Obj **entries;
				int nentries;

				Tcl_ListObjGetElements(interp(), list, &nentries, &entries);

				for (int k = 1; k < nentries; ++k)
				{
					char const* s = Tcl_GetString(entries[k]);

					if (sys::utf8::countChars(s) == 1)
					{
						sys::utf8::uchar uc = sys::utf8::getChar(s);

						if (uc > 256)
						{
							Tcl_AppendResult(interp(), "character out of Latin-1", nullptr);
							return TCL_ERROR;
						}

						m_sortOrderTable[uc] = ++count;
					}
					else
					{
						sys::utf8::uchar uc = sys::utf8::getChar(s);

						if (uc != i)
						{
							Tcl_AppendResult(interp(), "invalid sequence", nullptr);
							return TCL_ERROR;
						}

						lookup->add(s, ++count);
					}
				}
			}
		}
		
		delete m_lookup;
		m_lookup = lookup.release();
	}

	return TCL_OK;
}

// vi:set ts=3 sw=3:
