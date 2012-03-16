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

#include "m_string.h"

#include <tcl.h>
#include <tk.h>
#include <string.h>


#if defined(WIN32)

# error "not yet implemented"

#elif defined(__MacOSX__)

# error "not yet implemented"

#elif defined(__unix__)

# include <X11/Xatom.h>

extern "C" { int TclRenameCommand(Tcl_Interp* ti, char const* oldName, char const* newName); }

static bool m_selectionRetrieved = false;
static bool m_timeOut = true;
static Tcl_Obj* m_renamedCmd = 0;


static int
selEventProc(Tk_Window tkwin, XEvent *eventPtr)
{
	char*	propInfo	= 0;
	Atom	type;
	int	format;

	unsigned long numItems;
	unsigned long bytesAfter;

	if (m_timeOut)
		return 0; // we don't expect a selection

	if (eventPtr->xselection.property == None)
		return 0; // this may happen sporadically

	int result = XGetWindowProperty(	eventPtr->xselection.display,
												eventPtr->xselection.requestor,
												eventPtr->xselection.property,
												0,
												100000,
												False,
												AnyPropertyType,
												&type,
												&format,
												&numItems,
												&bytesAfter,
												reinterpret_cast<unsigned char**>(&propInfo));

	int done = 0;

	if (result == Success && propInfo != 0 && type != None && bytesAfter == 0 && format == 8)
	{
		static Atom xaPlainText	= 0;
		static Atom xaUriList	= 0;

		if (xaPlainText == 0)
		{
			xaPlainText = Tk_InternAtom(tkwin, "text/plain");
			xaUriList = Tk_InternAtom(tkwin, "text/uri-list");
		}

		if (type == xaPlainText || type == xaUriList)
		{
			Tcl_DString	ds;

			while (numItems > 0 && propInfo[numItems - 1] == '\0')
				--numItems;

			Tcl_ExternalToUtfDString(0, propInfo, numItems, &ds);
			Tcl_DStringResult(tcl::interp(), &ds);
			Tcl_DStringFree(&ds);
			done = 1;
			m_selectionRetrieved = true;
			m_timeOut = true;
		}
	}

	if (propInfo)
		XFree(propInfo);

	return done;
}


static void
selTimeoutProc(ClientData clientData)
{
	m_timeOut = true;
	Tcl_SetResult(static_cast<Tcl_Interp*>(clientData), "selection owner didn't respond", TCL_STATIC);
}


static int
selGet(Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* const* objs = objv;
	int count = objc;

	char const* path			= 0;
	char const* selName		= 0;
	char const* targetName	= 0;

	for ( ; count > 0; count -= 2, objs += 2)
	{
		static char const* OptionStrings[] = { "-displayof", "-selection", "-type", 0 };
		enum { GET_DISPLAYOF, GET_SELECTION, GET_TYPE };

		char const* string = Tcl_GetString(objs[0]);

		if (string[0] != '-')
			break;

		if (count < 2)
		{
			Tcl_AppendResult(ti, "value for \"", string, "\" missing", NULL);
			return TCL_ERROR;
		}

		int index;

		if (Tcl_GetIndexFromObj(ti, objs[0], OptionStrings, "option", 0, &index) != TCL_OK)
			return TCL_ERROR;

		switch (index)
		{
			case GET_DISPLAYOF:
				path = Tcl_GetString(objs[1]);
				break;

			case GET_SELECTION:
				selName = Tcl_GetString(objs[1]);
				break;

			case GET_TYPE:
				targetName = Tcl_GetString(objs[1]);
				break;
		}
	}

	if (count > 1)
	{
		Tcl_WrongNumArgs(ti, 2, objv, "?options?");
		return TCL_ERROR;
	}

	Tk_Window tkwin = Tk_MainWindow(ti);

	if (path && tkwin)
		tkwin = Tk_NameToWindow(ti, path, tkwin);

	if (!tkwin)
		return TCL_ERROR;

	Atom selection	= selName ? Tk_InternAtom(tkwin, selName) : XA_PRIMARY;
	Atom target		= XA_STRING;

	if (count == 1)
		target = Tk_InternAtom(tkwin, Tcl_GetString(objs[0]));
	else if (targetName)
		target = Tk_InternAtom(tkwin, targetName);

	XConvertSelection(Tk_Display(tkwin), selection, target, selection, Tk_WindowId(tkwin), CurrentTime);

	Tcl_TimerToken timeout = Tcl_CreateTimerHandler(500, selTimeoutProc, ti);
	m_selectionRetrieved = m_timeOut = false;
	while (!m_timeOut)
		Tcl_DoOneEvent(0);
	Tcl_DeleteTimerHandler(timeout);

	return m_selectionRetrieved ? TCL_OK : TCL_ERROR;
}


static int
selCmd(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	int result = TCL_ERROR;

	if (objc >= 2 && strcmp(Tcl_GetString(objv[1]), "get") == 0)
	{
		result = selGet(ti, objc - 2, objv + 2);
	}
	else
	{
		Tcl_Obj* objs[objc];
		memcpy(objs, objv, objc*sizeof(Tcl_Obj*));
		objs[0] = m_renamedCmd;
		result = Tcl_EvalObjv(ti, objc, objs, 0);
	}

	return result;
}


static void
selInit(Tcl_Interp* ti)
{
	Tcl_IncrRefCount(m_renamedCmd = Tcl_NewStringObj("__selection__x11_", -1));
	TclRenameCommand(ti, "selection", Tcl_GetString(m_renamedCmd));
	Tcl_CreateObjCommand(ti, "selection", selCmd, 0, 0);
}

#else

# error "unsupported platform"

#endif


static int
handleSelection(ClientData clientData, XEvent* eventPtr)
{
	if (eventPtr->type == SelectionNotify)
		return selEventProc(Tk_IdToWindow(eventPtr->xany.display, eventPtr->xany.window), eventPtr);

	return 0;
}


void
tk::selection_init(Tcl_Interp* ti)
{
	// Poor Tk library cannot handle the most common types "text/plain", and "text/uri-list".
	// This means we have to do our own selection handling.

	selInit(ti);
	Tk_CreateGenericHandler(handleSelection, 0);
}

// vi:set ts=3 sw=3:
