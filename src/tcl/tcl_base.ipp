// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_carray.h"
#include "m_string.h"
#include "m_assert.h"

#include <string.h>
#include <tcl.h>

namespace tcl { namespace bits { extern Tcl_Interp* interp; } }

inline Tcl_Interp* tcl::interp() { return bits::interp; }


inline
Tcl_Obj*
tcl::incrRef(Tcl_Obj* obj)
{
	if (obj)
		Tcl_IncrRefCount(obj);
	return obj;
}


inline
void
tcl::decrRef(Tcl_Obj* obj)
{
	if (obj)
	{
#ifndef NDEBUG
		// Tcl does not provide any function for querying the reference count.
		// So we need a work-around.
		Tcl_IncrRefCount(obj);
		M_REQUIRE(Tcl_IsShared(obj));
		Tcl_DecrRefCount(obj);
#endif
		Tcl_DecrRefCount(obj);
	}
}


inline Tcl_Obj* tcl::newObj() { return Tcl_NewObj(); }


inline
Tcl_Obj*
tcl::newObj(char const* s)
{
	M_REQUIRE(s);
	return Tcl_NewStringObj(s, -1);
}


inline
Tcl_Obj*
tcl::newObj(char const* s, unsigned len)
{
	M_REQUIRE(s);
	return Tcl_NewStringObj(s, len);
}


inline
Tcl_Obj*
tcl::newObj(mstl::string const& s)
{
	M_REQUIRE(s);
	return Tcl_NewStringObj(s.c_str(), s.size());
}


inline
Tcl_Obj*
tcl::newObj(unsigned objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(objc == 0 || objv);
	return Tcl_NewListObj(objc, objv);
}


inline
Tcl_Obj*
tcl::newObj(int value)
{
	return Tcl_NewIntObj(value);
}


inline
char const*
tcl::asString(Tcl_Obj* obj)
{
	M_REQUIRE(obj);
	return Tcl_GetString(obj);
}


inline
bool
tcl::equal(char const* lhs, char const* rhs)
{
	M_ASSERT(lhs);
	M_ASSERT(rhs);

	return ::strcmp(lhs, rhs) == 0;
}


inline bool tcl::equal(char const* lhs, Tcl_Obj* rhs) { return equal(lhs, tcl::asString(rhs)); }
inline bool tcl::equal(Tcl_Obj* lhs, char const* rhs) { return equal(tcl::asString(lhs), rhs); }

inline bool tcl::equal(Tcl_Obj* lhs, Tcl_Obj* rhs)
{ return equal(tcl::asString(lhs), tcl::asString(rhs)); }


inline
mstl::carray<Tcl_Obj*>
tcl::getElements(Tcl_Obj* obj)
{
	M_ASSERT(obj);
	Tcl_Obj** objv;
	return mstl::carray<Tcl_Obj*>(objv, getElements(obj, objv));
}


inline
void
tcl::set(Tcl_Obj*& obj, Tcl_Obj* value)
{
	tcl::decrRef(obj);
	obj = tcl::incrRef(value);
}


inline
void
tcl::zero(Tcl_Obj*& obj)
{
	tcl::decrRef(obj);
	obj = nullptr;
}


inline
int
tcl::wrongNumArgs(int objc, Tcl_Obj* const objv[], char const* args)
{
	Tcl_WrongNumArgs(interp(), objc, objv, args);
	return TCL_ERROR;
}


inline
int
tcl::setError(char const* type)
{
	Tcl_SetErrorCode(interp(), "SCIDB", type, nullptr);
	return TCL_ERROR;
}


inline
Tcl_Obj*
tcl::result()
{
	return Tcl_GetObjResult(interp());
}

// vi:set ts=3 sw=3:
