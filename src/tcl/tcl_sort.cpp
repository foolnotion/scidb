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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_sort.h"
#include "tcl_base.h"
#include "tcl_compare.h"

#include "sys_utf8.h"

#include "m_utility.h"
#include "m_types.h" // for nullptr

#include <tcl.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>


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
		static int mapCompIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);
		static int mapCompDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);
		static int dictCompIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);
		static int dictCompDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);
		static int compDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);
		static int compIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);

		union
		{
			Tcl_Obj*		m_obj;
			int			m_index;
		};
		union
		{
			char const*	m_value;
			Tcl_Obj*		m_mapped;
		};
		Element*			m_next;
	};

	typedef int (*Compare)(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation);

	Tcl_Obj* selectObjFromSublist(Tcl_Obj* objPtr, Tcl_Obj** currentObj);
	Element* mergeLists(Element* lhs, Element* rhs);

	Tcl_Interp*	m_interp;
	int*			m_indexVec;
	int			m_indexCount;
	int			m_numElements;
	bool			m_noCase;
	bool			m_unique;
	bool			m_skipPunctuation;
	int			m_resultCode;
	Element*		m_subList[NumLists];
	Element*		m_elements;
	Compare		m_compare;
};


int
Sort::Element::mapCompIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return tcl::compare::compare(lhs->m_mapped, rhs->m_mapped);
}


int
Sort::Element::mapCompDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return -tcl::compare::compare(lhs->m_mapped, rhs->m_mapped);
}


int
Sort::Element::dictCompIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return ::sys::utf8::latin1::dictionaryCompare(lhs->m_value, rhs->m_value, skipPunctuation);
}


int
Sort::Element::dictCompDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return -::sys::utf8::latin1::dictionaryCompare(lhs->m_value, rhs->m_value, skipPunctuation);
}


int
Sort::Element::compDecr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return ::sys::utf8::latin1::compare(lhs->m_value, rhs->m_value, noCase, skipPunctuation);
}


int
Sort::Element::compIncr(Element* lhs, Element* rhs, bool noCase, bool skipPunctuation)
{
	return -::sys::utf8::latin1::compare(lhs->m_value, rhs->m_value, noCase, skipPunctuation);
}


Sort::Sort(Tcl_Interp* interp)
	:m_interp(interp)
	,m_indexVec(0)
	,m_indexCount(0)
	,m_numElements(0)
	,m_noCase(false)
	,m_unique(false)
	,m_skipPunctuation(false)
	,m_resultCode(TCL_OK)
	,m_elements(0)
	,m_compare(0)
{
}


Sort::~Sort()
{
	delete [] m_indexVec;
	delete [] m_elements;
}


int
Sort::process(int objc, Tcl_Obj* const objv[])
{
	static char const* Switches[] =
	{
		"-decreasing", "-dictionary", "-increasing", "-index",
		"-indices", "-mapping", "-nocase", "-nopunct", "-order",
		"-unique", nullptr
	};

	enum
	{
		Opt_Decreasing, Opt_Dictionary, Opt_Increasing, Opt_Index,
		Opt_Indices, Opt_Mapping, Opt_NoCase, Opt_NoPunct, Opt_Order,
		Opt_Unique
	};

	bool dictionary	= false;
	bool isIncreasing	= true;
	bool useMapping	= false;
	bool indices		= false;

	for (int i = 1; i < objc - 1; i++)
	{
		int index;

		if (Tcl_GetIndexFromObj(m_interp, objv[i], Switches, "option", 0, &index) != TCL_OK)
			return TCL_ERROR;

		switch (index)
		{
			case Opt_Decreasing:
				isIncreasing = false;
				break;

			case Opt_Dictionary:
				dictionary = true;
				break;

			case Opt_Increasing:
				isIncreasing = true;
				break;

			case Opt_Index:
			{
				if (i == objc - 2)
				{
					Tcl_AppendResult(
						m_interp,
						"\"-index\" option must be followed by list index",
						nullptr);
					return TCL_ERROR;
				}

				Tcl_Obj **indices;

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

			case Opt_Mapping:
			{
				if (i == objc - 2)
				{
					Tcl_AppendResult(
						m_interp,
						"\"-mapping\" option must be followed by mapping table",
						nullptr);
					return TCL_ERROR;
				}
				if (tcl::compare::setMappingTable(objv[i + 1]) != TCL_OK)
					return TCL_ERROR;
				useMapping = true;
				i++;
				break;
			}

			case Opt_NoCase:
				m_noCase = true;
				break;

			case Opt_NoPunct:
				m_skipPunctuation = true;
				break;

			case Opt_Order:
				if (i == objc - 2)
				{
					Tcl_AppendResult(
						m_interp,
						"\"-order\" option must be followed by alphabetic list",
						nullptr);
					return TCL_ERROR;
				}
				if (tcl::compare::setAlphabeticList(objv[i + 1]) != TCL_OK)
					return TCL_ERROR;
				useMapping = true;
				i++;
				break;

			case Opt_Unique:
				m_unique = true;
				break;

			case Opt_Indices:
				indices = true;
				break;
		}
	}

	if (useMapping)
		m_compare = isIncreasing ? Element::mapCompIncr : Element::mapCompDecr;
	else if (dictionary)
		m_compare = isIncreasing ? Element::dictCompIncr : Element::dictCompDecr;
	else
		m_compare = isIncreasing ? Element::compIncr : Element::compDecr;

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
		Tcl_Obj* currentObj;

		if (m_indexCount)
		{
			indexPtr = selectObjFromSublist(listObjPtrs[i], &currentObj);
			if (m_resultCode != TCL_OK)
				return m_resultCode;
		}
		else
		{
			currentObj = indexPtr = listObjPtrs[i];
		}

		if (useMapping)
		{
			char const* value = Tcl_GetString(currentObj);
			Tcl_Obj* mapped = tcl::compare::makeComparableObj(value, m_skipPunctuation);
			Tcl_IncrRefCount(m_elements[i].m_mapped = mapped);
		}
		else
		{
			m_elements[i].m_value = Tcl_GetString(currentObj);
		}

		if (indices)
			m_elements[i].m_index = i;
		else
			m_elements[i].m_obj = indexPtr;

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

	if (useMapping)
	{
		for (int i = 0; i < m_numElements; i++)
			Tcl_IncrRefCount(m_elements[i].m_mapped);
	}

	if (m_resultCode == TCL_OK)
	{
		Tcl_Obj* objv[m_numElements];
		int objc = 0;

		for ( ; element; element = element->m_next, ++objc)
			objv[objc] = indices ? Tcl_NewIntObj(element->m_index) : element->m_obj;

		tcl::setResult(objc, objv);
	}

	return m_resultCode;
}


Tcl_Obj*
Sort::selectObjFromSublist(Tcl_Obj *objPtr, Tcl_Obj** currentObj)
{
	*currentObj = objPtr;

	if (m_indexCount == 0)
		return objPtr;

	for (int i = 0; i < m_indexCount; i++)
	{
		int listLen;

		if (Tcl_ListObjLength(m_interp, objPtr, &listLen) != TCL_OK)
		{
			m_resultCode = TCL_ERROR;
			return nullptr;
		}

		int index = m_indexVec[i];

		if (index < -1)
			index += listLen + 1;

		if (Tcl_ListObjIndex(m_interp, objPtr, index, currentObj) != TCL_OK)
		{
			m_resultCode = TCL_ERROR;
			return nullptr;
		}

		if (*currentObj == nullptr)
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


Sort::Element*
Sort::mergeLists(Element* lhs, Element* rhs)
{
	Element* tail;

	if (!lhs)
		return rhs;
	if (!rhs)
		return lhs;

	int cmp = m_compare(lhs, rhs, m_noCase, m_skipPunctuation);

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
			cmp = m_compare(lhs, rhs, m_noCase, m_skipPunctuation);

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
			cmp = m_compare(lhs, rhs, m_noCase, m_skipPunctuation);

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
