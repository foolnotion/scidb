// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
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
// Copyright: (C) 2011-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

#include <string.h>

namespace tcl {

inline Obj::operator Tcl_Obj* () const { return m_obj; }

inline Obj::Obj(Tcl_Obj* obj) :m_obj(obj) {}


inline
void
Obj::ref()
{
	if (m_obj)
		Tcl_IncrRefCount(m_obj);
}


inline
void
Obj::deref()
{
	if (m_obj)
		Tcl_DecrRefCount(m_obj);
}


inline
Tcl_Obj*
Obj::operator()() const
{
	M_ASSERT(m_obj);
	return m_obj;
}


inline
bool
Obj::operator==(Obj const& obj) const
{
	if (m_obj == 0)
		return obj.m_obj == 0;

	if (obj.m_obj == 0)
		return false;

	return ::strcmp(Tcl_GetStringFromObj(m_obj, 0), Tcl_GetStringFromObj(obj.m_obj, 0)) == 0;
}

} // namespace tcl

// vi:set ts=3 sw=3:
