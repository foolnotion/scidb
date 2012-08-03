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
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include <tcl.h>
#include <zlib.h>
#include <string.h>


static int
cmdZlibCrc(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "data ?crc?");
		return TCL_ERROR;
	}

	int len;
	char const* data = Tcl_GetStringFromObj(objv[1], &len);
	unsigned crc = 0;

	if (objc > 2)
	{
		Tcl_WideInt icrc;

		if (Tcl_GetWideIntFromObj(ti, objv[2], &icrc) != TCL_OK)
		{
			Tcl_SetResult(ti, const_cast<char*>("Invalid checksum argument"), TCL_STATIC);
			return TCL_ERROR;
		}
	}

	Tcl_SetObjResult(ti, Tcl_NewWideIntObj(crc32(crc, reinterpret_cast<Bytef const*>(data), len)));
	return TCL_OK;
}


void
zlib_init(Tcl_Interp* ti)
{
	Tcl_CreateObjCommand(ti, "::zlib::crc", cmdZlibCrc, 0, 0);
}


static int
init(Tcl_Interp* ti)
{
	if (Tcl_Init(ti) == TCL_ERROR)
		return TCL_ERROR;

	zlib_init(ti);
	return Tcl_PkgProvide(ti, "tclscidb", "1.0");
}


int
main(int argc, char* argv[])
{
	Tcl_Main(argc, argv, init);
	return 0;
}

// vi:set ts=3 sw=3:
