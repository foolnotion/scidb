// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "tk_init.h"

#include "tcl_base.h"

#include <tcl.h>
#include <tk.h>

using namespace tcl;


static int
tkMisc(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* Subcommands[] = { "setClass", "shiftMask?" };
	enum { Cmd_SetClass, Cmd_ShiftMask };

	int index;
	int result = Tcl_GetIndexFromObj(ti, objv[1], Subcommands, "subcommand", TCL_EXACT, &index);

	if (result != TCL_OK)
		return TCL_ERROR;

	switch (index)
	{
		case Cmd_SetClass:
		{
			char const*	path	= stringFromObj(objc, objv, 2);
			char const*	cls	= stringFromObj(objc, objv, 3);
			Tk_Window	tkwin	= Tk_NameToWindow(ti, path, Tk_MainWindow(ti));

			if (!tkwin)
				return TCL_ERROR;

			Tk_SetClass(tkwin, cls);
			break;
		}

		case Cmd_ShiftMask:
			Tcl_SetObjResult(ti, Tcl_NewIntObj(ShiftMask));
			break;
	}

	return TCL_OK;
}


void
tk::miscInit(Tcl_Interp* ti)
{
	tcl::createCommand(ti, "::scidb::tk::misc", tkMisc);
}

// vi:set ts=3 sw=3:
