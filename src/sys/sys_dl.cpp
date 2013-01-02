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

#include "sys_dl.h"
#include "sys_base.h"

#include "m_string.h"
#include "m_assert.h"

#include <tcl.h>

using namespace sys::dl;

#if !TCL_PREREQ(8,5)
# error  "unsupported TCL version"
#endif

extern "C"
{
	extern int TclLoadFile(	Tcl_Interp* interp,
									Tcl_Obj* pathPtr,
									int symc,
									char const* symbols[],
									Tcl_PackageInitProc** procPtrs[],
									Tcl_LoadHandle* handlePtr,
									ClientData* clientDataPtr,
									Tcl_FSUnloadFileProc** unloadProcPtr);

	extern Tcl_PackageInitProc* TclpFindSymbol(	Tcl_Interp* interp,
																Tcl_LoadHandle loadHandle,
																char const* symbol);
	// XXX these functions are protected! stupid!!!
	int TclLoadFile(	Tcl_Interp*,
							Tcl_Obj*,
							int,
							char const*[],
							Tcl_PackageInitProc**[],
							Tcl_LoadHandle*,
							ClientData*,
							Tcl_FSUnloadFileProc**) { return 0; }
	Tcl_PackageInitProc* TclpFindSymbol(Tcl_Interp*, Tcl_LoadHandle, char const*) { return 0; }
}

struct sys::dl::Handle
{
	Tcl_LoadHandle				loadHandle;
	Tcl_FSUnloadFileProc*	unloadProc;
	mstl::string				error;
};



Handle*
sys::dl::open(char const* path, mstl::string* error)
{
	M_REQUIRE(path);

	Tcl_LoadHandle				loadHandle	= 0;
	Tcl_Obj*						pathObj		= Tcl_NewStringObj(path, -1);
	Tcl_FSUnloadFileProc*	unloadProc	= 0;
	ClientData					clientData;

	Tcl_IncrRefCount(pathObj);

	int rc = TclLoadFile(::sys::tcl::interp(),
								pathObj,
								0, 0, 0,
								&loadHandle,
								&clientData,
								&unloadProc);

	Tcl_DecrRefCount(pathObj);

	if (rc != TCL_OK)
	{
		if (error)
			error->assign(Tcl_GetStringResult(::sys::tcl::interp()));

		Tcl_ResetResult(::sys::tcl::interp());
		return 0;
	}

	Handle* handle = new Handle;
	handle->loadHandle = loadHandle;
	handle->unloadProc = unloadProc;

	return handle;
}


void
sys::dl::close(Handle*& handle)
{
	if (handle)
	{
		if (handle->unloadProc)
			handle->unloadProc(handle->loadHandle);

		delete handle;
		handle = 0;
	}
}


void*
sys::dl::lookup(Handle* handle, char const* symbol)
{
	M_REQUIRE(handle);
	M_REQUIRE(symbol);

	typedef void* VoidPtr;
	return VoidPtr(TclpFindSymbol(::sys::tcl::interp(), handle->loadHandle, symbol));
}

// vi:set ts=3 sw=3:
