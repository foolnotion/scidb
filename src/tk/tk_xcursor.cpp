// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

// =====================================================================================
// This source is adopted from http://wiki.tcl.tk/27678.
// =====================================================================================

// =====================================================================================
// How to create xcursors:
// -------------------------------------------------------------------------------------
// 1.	Open the image you want to use for your cursor in the image editing program of
//		your choice. Resize your image to 32 by 32 pixels so that it is the proper cursor
//		size for X11. Save the image as a PNG file if it isn't one already.
//
// 2. Open a text editor and create a new blank file. Type the configuration settings
//		"32 0 0 click.png" where "32" is the size of the image, "0" and "0" represent the
//		X and Y coordinates of the cursor's point, and "click.png" is the name of your
//		image file. Save this text file in the same directory and with the same name as
//		your cursor, but with a ".cursor" file extension instead of a ".png" extension.
//
// 3.	Type "xcursorgen click.cursor click.xcur" where "click.cursor" is the name of the
//		configuration file you created. Xcursorgen will automatically create an X11 cursor
//		file.
// =====================================================================================

#include <tk.h>

#if !defined(__WIN32__) && !defined(__MacOSX__)

#include <X11/Xcursor/Xcursor.h>


static int
cmdSetCursor(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "window cursor");
		return TCL_ERROR;
	}

	long xid;

	if (Tcl_GetLongFromObj(ti, objv[2], &xid) != TCL_OK)
		return TCL_ERROR;

	Tk_Window tkmain = Tk_MainWindow(ti);

	if (!tkmain)
		return TCL_ERROR;

	Tk_Window tkwin = Tk_NameToWindow(ti, Tcl_GetString(objv[1]), tkmain);

	if (!tkwin)
		return TCL_ERROR;

	if (Tk_WindowId(tkwin) == None)
		Tk_MakeWindowExist(tkwin);

	XDefineCursor(Tk_Display(tkwin), Tk_WindowId(tkwin), static_cast<Cursor>(xid));
	return TCL_OK;
}


static int
cmdGetTheme(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 1)
	{
		Tcl_WrongNumArgs(ti, 1, objv, 0);
		return TCL_ERROR;
	}

	Tcl_SetObjResult(ti, Tcl_NewStringObj(XcursorGetTheme(Tk_Display(Tk_MainWindow(ti))), -1));
	return TCL_OK;
}


static int
cmdLoadCursorFromFile(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "filename");
		return TCL_ERROR;
	}

	Cursor cursor = XcursorFilenameLoadCursor(Tk_Display(Tk_MainWindow(ti)), Tcl_GetString(objv[1]));

	if (cursor == None)
	{
		Tcl_AppendResult(ti, "Can't load cursor from file \"", Tcl_GetString(objv[1]), "\"", 0);
		return TCL_ERROR;
	}

	Tcl_SetObjResult(ti, Tcl_NewLongObj(static_cast<long>(cursor)));
	return TCL_OK;
}


static int
cmdFreeCursor(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "cursorid");
		return TCL_ERROR;
	}

	long xid;

	if (Tcl_GetLongFromObj(ti, objv[1], &xid) != TCL_OK)
		return TCL_ERROR;

	XFreeCursor(Tk_Display(Tk_MainWindow(ti)), static_cast<Cursor>(xid));
	return TCL_OK;
}

#endif // !defined(__WIN32__) && !defined(__MacOSX__)


static int
cmdIsARGBSupported(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int value = 0;

#if !defined(__WIN32__) && !defined(__MacOSX__)
	value = XcursorSupportsARGB(Tk_Display(Tk_MainWindow(ti)));
#endif

	Tcl_SetObjResult(ti, Tcl_NewBooleanObj(value));
	return TCL_OK;
}


namespace tk {

int
xcursor_init(Tcl_Interp* ti)
{
	if (	!Tcl_InitStubs(ti, "8.5", 0)
		|| !Tcl_PkgRequire(ti, "Tcl", "8.5", 0)
		|| !Tk_InitStubs(ti, "8.5", 0)
		|| !Tcl_PkgRequire(ti, "Tk", "8.5", 0))
	{
		return TCL_ERROR;
	}

	if (Tcl_PkgProvide(ti, "xcursor", "1.0") == TCL_ERROR)
		return TCL_ERROR;

	if (Tcl_Eval(ti, "namespace eval ::xcursor {}") == TCL_ERROR)
		return TCL_ERROR;

#if !defined(__WIN32__) && !defined(__MacOSX__)

	// private functions
	Tcl_CreateObjCommand(ti, "::xcursor::DefineCursor", cmdSetCursor, 0, 0);
	Tcl_CreateObjCommand(ti, "::xcursor::LoadFromFile", cmdLoadCursorFromFile, 0, 0);
	Tcl_CreateObjCommand(ti, "::xcursor::FreeCursor", cmdFreeCursor, 0, 0);

	// public functions
	Tcl_CreateObjCommand(ti, "::xcursor::getTheme", cmdGetTheme, 0, 0);

#endif

	// public functions
	Tcl_CreateObjCommand(ti, "::xcursor::supported?", cmdIsARGBSupported, 0, 0);

	return TCL_OK;
}

} // namespace tk

// vi:set ts=3 sw=3:
