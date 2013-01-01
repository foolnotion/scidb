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
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_sort.h"
#include "tcl_base.h"

#include "m_types.h" // for nullptr

#include <tcl.h>
#include <tk.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>


static int
latin1Diff(int lhs, int rhs)
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

	if (lhs > 128 && 256 > lhs)
		lhs = Latin1Map[lhs - 128];
	if (rhs > 128 && 256 > rhs)
		rhs = Latin1Map[rhs - 128];

	return rhs - lhs;
}


static int
dictionaryCompare(char const* lhs, char const* rhs, bool skipPunct)
{
	typedef unsigned char UChar;

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
					diff = int(UChar(*lhs)) - int(UChar(*rhs));

				rhs++;
				lhs++;

				if (!isdigit(*rhs))
				{
					if (isdigit(*lhs))
						return 1;
					else if (diff)
						return diff;

					break;
				}
				else if (!isdigit(*lhs))
				{
					return -1;
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
			Tcl_UniChar uniLhs, uniRhs, uniLhsLower, uniRhsLower;

			if (*lhs && *rhs)
			{
				lhs += Tcl_UtfToUniChar(lhs, &uniLhs);
				rhs += Tcl_UtfToUniChar(rhs, &uniRhs);

				uniLhsLower = Tcl_UniCharToLower(uniLhs);
				uniRhsLower = Tcl_UniCharToLower(uniRhs);
			}
			else
			{
				diff = int(UChar(*rhs)) - int(UChar(*lhs));
				break;
			}

			diff = latin1Diff(uniLhsLower, uniRhsLower);

			if (diff)
				return diff;

			if (secondaryDiff == 0)
			{
				if (Tcl_UniCharIsUpper(uniLhs) && Tcl_UniCharIsLower(uniRhs))
					secondaryDiff = -1;
				else if (Tcl_UniCharIsUpper(uniRhs) && Tcl_UniCharIsLower(uniLhs))
					secondaryDiff = 1;
			}
		}
	}

	if (diff == 0)
		diff = secondaryDiff;

	return diff;
}


static int
latin1Compare(char const* lhs, char const* rhs, bool skipPunct, bool noCase)
{
	typedef unsigned char UChar;

	while (true)
	{
		if (*lhs == '\0' || *rhs == '\0')
			return int(UChar(*rhs)) - int(UChar(*lhs));

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

		Tcl_UniChar uniLhs, uniRhs;

		lhs += Tcl_UtfToUniChar(lhs, &uniLhs);
		rhs += Tcl_UtfToUniChar(rhs, &uniRhs);

		Tcl_UniChar uniLhsLower = Tcl_UniCharToLower(uniLhs);
		Tcl_UniChar uniRhsLower = Tcl_UniCharToLower(uniRhs);

		if (int diff = latin1Diff(uniLhsLower, uniRhsLower))
			return diff;
	}

	return 0; // satisfies the compiler
}


namespace {

class Sort
{
public:

	Sort(Tcl_Interp* interp);
	~Sort();

	int process(int objc, Tcl_Obj* const objv[]);

private:

	enum { NumLists = 30 };

	struct Element
	{
		union
		{
			Tcl_Obj*	obj;
			int		index;
		}
		m_obj;

		char const*	m_value;
		Element*		m_next;
	};

	Tcl_Obj* selectObjFromSublist(Tcl_Obj* objPtr);
	Element* mergeLists(Element* lhs, Element* rhs);
	int compare(Element* lhs, Element* rhs);

	Tcl_Interp*	m_interp;
	int*			m_indexVec;
	int			m_indexCount;
	int			m_numElements;
	bool			m_isIncreasing;
	bool			m_indices;
	bool			m_noCase;
	bool			m_unique;
	bool			m_dictionary;
	bool			m_skipPunctuation;
	int			m_resultCode;
	Element*		m_subList[NumLists];
	Element*		m_elements;
};


Sort::Sort(Tcl_Interp* interp)
	:m_interp(interp)
	,m_indexVec(0)
	,m_indexCount(0)
	,m_numElements(0)
	,m_isIncreasing(true)
	,m_indices(false)
	,m_noCase(false)
	,m_unique(false)
	,m_dictionary(false)
	,m_skipPunctuation(false)
	,m_resultCode(TCL_OK)
	,m_elements(0)
{
}


Sort::~Sort()
{
	delete m_indexVec;
	delete m_elements;
}


int
Sort::process(int objc, Tcl_Obj* const objv[])
{
	static char const* Switches[] =
	{
		"-decreasing", "-dictionary", "-increasing", "-index",
		"-indices", "-nocase", "-nopunct", "-unique", nullptr
	};
	enum
	{
		LSORT_DECREASING, LSORT_DICTIONARY, LSORT_INCREASING, LSORT_INDEX,
		LSORT_INDICES, LSORT_NOCASE, LSORT_NOPUNCT, LSORT_UNIQUE
	};

	for (int i = 1; i < objc - 1; i++)
	{
		int index;

		if (Tcl_GetIndexFromObj(m_interp, objv[i], Switches, "option", 0, &index) != TCL_OK)
			return TCL_ERROR;

		switch (index)
		{
			case LSORT_DECREASING:
				m_isIncreasing = false;
				break;

			case LSORT_DICTIONARY:
				m_dictionary = true;
				break;

			case LSORT_INCREASING:
				m_isIncreasing = true;
				break;

			case LSORT_INDEX:
			{
				Tcl_Obj **indices;

				if (i == objc - 2)
				{
					Tcl_AppendResult(
						m_interp,
						"\"-index\" option must be " "followed by list index",
						nullptr);
					return TCL_ERROR;
				}

				if (Tcl_ListObjGetElements(m_interp, objv[i + 1], &m_indexCount, &indices) != TCL_OK)
					return TCL_ERROR;

				m_indexVec = new int[m_indexCount];

				for (int j = 0; j < m_indexCount; j++)
				{
					if (Tcl_GetIntFromObj(m_interp, indices[j], &m_indexVec[j]) != TCL_OK)
					{
						Tcl_AppendObjToErrorInfo(
							m_interp,
							Tcl_ObjPrintf( "\n    (-index option item number %d)", j));
						return TCL_ERROR;
					}
				}

				i++;
				break;
			}

			case LSORT_NOCASE:
				m_noCase = true;
				break;

			case LSORT_NOPUNCT:
				m_skipPunctuation = true;
				break;

			case LSORT_UNIQUE:
				m_unique = true;
				break;

			case LSORT_INDICES:
				m_indices = true;
				break;
		}
	}

	Tcl_Obj** listObjPtrs;
	m_resultCode = Tcl_ListObjGetElements(m_interp, objv[objc - 1], &m_numElements, &listObjPtrs);
	if (m_resultCode != TCL_OK || m_numElements <= 0)
		return m_resultCode;

	m_elements = new Element[m_numElements];

	::memset(m_subList, 0, sizeof(m_subList));
	::memset(m_elements, 0, m_numElements*sizeof(Element));

	for (int i = 0; i < m_numElements; i++)
	{
		Tcl_Obj* indexPtr;

		if (m_indexCount)
		{
			indexPtr = selectObjFromSublist(listObjPtrs[i]);
			if (m_resultCode != TCL_OK)
				return m_resultCode;
		}
		else
		{
			indexPtr = listObjPtrs[i];
		}

		m_elements[i].m_value = Tcl_GetString(indexPtr);

		if (m_indices)
			m_elements[i].m_obj.index = i;
		else
			m_elements[i].m_obj.obj = indexPtr;

		m_elements[i].m_next = nullptr;

		Element* element = &m_elements[i];

		int j = 0;

		for ( ; m_subList[j]; j++)
		{
			element = mergeLists(m_subList[j], element);
			m_subList[j] = nullptr;
		}

		if (j >= NumLists)
			j = NumLists - 1;

		m_subList[j] = element;
	}

	Element* element = m_subList[0];

	for (int j = 1; j < NumLists; j++)
		element = mergeLists(m_subList[j], element);

	if (m_resultCode == TCL_OK)
	{
		Tcl_Obj* objv[m_numElements];
		int objc = 0;

		for ( ; element; element = element->m_next, ++objc)
			objv[objc] = m_indices ? Tcl_NewIntObj(element->m_obj.index) : element->m_obj.obj;

		tcl::setResult(objc, objv);
	}

	return m_resultCode;
}


Tcl_Obj*
Sort::selectObjFromSublist(Tcl_Obj *objPtr)
{
	if (m_indexCount == 0)
		return objPtr;

	for (int i = 0; i < m_indexCount; i++)
	{
		int listLen;
		Tcl_Obj *currentObj;

		if (Tcl_ListObjLength(m_interp, objPtr, &listLen) != TCL_OK)
		{
			m_resultCode = TCL_ERROR;
			return nullptr;
		}

		int index = m_indexVec[i];

		if (index < -1)
			index += listLen + 1;

		if (Tcl_ListObjIndex(m_interp, objPtr, index, &currentObj) != TCL_OK)
		{
			m_resultCode = TCL_ERROR;
			return nullptr;
		}

		if (currentObj == nullptr)
		{
			char buffer[100];

			::sprintf(buffer, "%d", index);
			Tcl_AppendResult(	m_interp,
									"element ",
									buffer,
									" missing from sublist \"",
									Tcl_GetString(objPtr),
									"\"",
									nullptr);
			m_resultCode = TCL_ERROR;
			return nullptr;
		}
	}

	return objPtr;
}


int
Sort::compare(Element* lhs, Element* rhs)
{
	int order = 0;

	if (m_dictionary)
		order = ::dictionaryCompare(lhs->m_value, rhs->m_value, m_skipPunctuation);
	else
		order = ::latin1Compare(lhs->m_value, rhs->m_value, m_skipPunctuation, m_noCase);

	return m_isIncreasing ? -order : order;
}


Sort::Element*
Sort::mergeLists(Element* lhs, Element* rhs)
{
	Element* tail;

	if (!lhs)
		return rhs;
	if (!rhs)
		return lhs;

	int cmp = compare(lhs, rhs);

	if (cmp > 0 || (cmp == 0 && m_unique))
	{
		if (cmp == 0)
		{
			m_numElements--;
			lhs = lhs->m_next;
		}
		tail = rhs;
		rhs = rhs->m_next;
	}
	else
	{
		tail = lhs;
		lhs = lhs->m_next;
	}

	Element* head = tail;

	if (!m_unique)
	{
		while (lhs && rhs)
		{
			cmp = compare(lhs, rhs);
			if (cmp > 0)
			{
				tail->m_next = rhs;
				tail = rhs;
				rhs = rhs->m_next;
			}
			else
			{
				tail->m_next = lhs;
				tail = lhs;
				lhs = lhs->m_next;
			}
		}
	}
	else
	{
		while (lhs && rhs)
		{
			cmp = compare(lhs, rhs);
			if (cmp >= 0)
			{
				if (cmp == 0)
				{
					m_numElements--;
					lhs = lhs->m_next;
				}
				tail->m_next = rhs;
				tail = rhs;
				rhs = rhs->m_next;
			}
			else
			{
				tail->m_next = lhs;
				tail = lhs;
				lhs = lhs->m_next;
			}
		}
	}

	if (lhs)
		tail->m_next = lhs;
	else
		tail->m_next = rhs;

	return head;
}

} // namespace


int
tcl::misc::sort(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "?options? list");
		return TCL_ERROR;
	}

	Sort sort(ti);
	return sort.process(objc, objv);
}

// vi:set ts=3 sw=3:
