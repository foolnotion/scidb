// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "u_base.h"

#include "m_stdio.h"
#include "m_assert.h"

#include <tcl.h>
#include <tk.h>

#include <string.h>


static Tcl_Command tk_cmd = 0;


#if !defined(WIN32) && !defined(__MacOSX__)

# include <X11/Xlib.h>
# include <X11/Xutil.h>
# include <X11/Xatom.h>


// MWM decorations values
# define MWM_DECOR_NONE				0
# define MWM_DECOR_ALL				(1L << 0)
# define MWM_DECOR_BORDER			(1L << 1)
# define MWM_DECOR_RESIZEH			(1L << 2)
# define MWM_DECOR_TITLE			(1L << 3)
# define MWM_DECOR_MENU				(1L << 4)
# define MWM_DECOR_MINIMIZE		(1L << 5)
# define MWM_DECOR_MAXIMIZE		(1L << 6)

# define MWM_FUNC_ALL				(1L << 0)
# define MWM_FUNC_RESIZE			(1L << 1)
# define MWM_FUNC_MOVE				(1L << 2)
# define MWM_FUNC_MINIMIZE			(1L << 3)
# define MWM_FUNC_MAXIMIZE			(1L << 4)
# define MWM_FUNC_CLOSE				(1L << 5)

# define MWM_HINTS_FUNCTIONS		(1L << 0)
# define MWM_HINTS_DECORATIONS	(1L << 1)


// KDE decoration values
enum
{
	KDE_noDecoration = 0,
	KDE_normalDecoration = 1,
	KDE_tinyDecoration = 2,
	KDE_noFocus = 256,
	KDE_standaloneMenuBar = 512,
	KDE_desktopIcon = 1024,
	KDE_staysOnTop = 2048
};


typedef struct
{
	unsigned long flags;
	unsigned long functions;
	unsigned long decorations;
	long input_mode;
	unsigned long status;
}
MWM_Hints;


static char const* XA_MOTIF_WM_HINTS						= "_MOTIF_WM_HINTS";
static char const* XA_KWM_WIN_DECORATION					= "KWM_WIN_DECORATION";
static char const* XA_WIN_HINTS								= "_WIN_HINTS";
static char const* XA_NET_WM_WINDOW_TYPE					= "_NET_WM_WINDOW_TYPE";
static char const* XA_KDE_NET_WM_WINDOW_TYPE_OVERRIDE	= "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE";
static char const* XA_NET_WM_WINDOW_TYPE_NORMAL			= "_NET_WM_WINDOW_TYPE_NORMAL";
//static char const* XA_NET_WM_WINDOW_TYPE_TOOLBAR		= "_NET_WM_WINDOW_TYPE_TOOLBAR";
//static char const* XA_NET_WM_WINDOW_TYPE_SPLASH			= "_NET_WM_WINDOW_TYPE_SPLASH";

#if 0
static char const* XA_NET_WM_ALLOWED_ACTIONS				= "_NET_WM_ALLOWED_ACTIONS";
static char const* XA_NET_WM_ACTION_MOVE					= "_NET_WM_ACTION_MOVE";
static char const* XA_NET_WM_ACTION_RESIZE				= "_NET_WM_ACTION_RESIZE";
static char const* XA_NET_WM_ACTION_MAXIMIZE_HORZ		= "_NET_WM_ACTION_MAXIMIZE_HORZ";
static char const* XA_NET_WM_ACTION_MAXIMIZE_VERT		= "_NET_WM_ACTION_MAXIMIZE_VERT";
static char const* XA_NET_WM_ACTION_CLOSE					= "_NET_WM_ACTION_CLOSE";
#endif


static void
changeProperty(Display* display, Window window, Atom which, void* data, int nelements)
{
	XChangeProperty(	display,
							window,
							which,
							which,
							32,
							PropModeReplace,
							static_cast<unsigned char*>(data),
							nelements);
}


inline
static int
checkAtom(Atom& wmHints, Tk_Window tkwin, char const* name)
{
	wmHints = Tk_InternAtom(tkwin, name);
	return wmHints != None;
}


static int
noDecor(Tk_Window tkwin, Window window)
{
	Atom	wmHints;
	int	rc = 0;

	Display* display = Tk_Display(tkwin);

	// First try to set MWM hints (works!)
	if ((rc = checkAtom(wmHints, tkwin, XA_MOTIF_WM_HINTS)))
	{
		MWM_Hints hints = { MWM_HINTS_DECORATIONS, 0, MWM_DECOR_NONE, 0, 0 };
		changeProperty(display, window, wmHints, &hints, sizeof(hints)/4);
	}

	// Now try to set KWM hints (doesn't work for any reason)
	if ((rc = checkAtom(wmHints, tkwin, XA_KWM_WIN_DECORATION)))
	{
		uint32_t KWMHints = KDE_tinyDecoration;
		changeProperty(display, window, wmHints, &KWMHints, 1);
	}

	// Now try to set GNOME hints (working?)
	if ((rc = checkAtom(wmHints, tkwin, XA_WIN_HINTS)))
	{
		uint32_t GNOMEHints = 0;
		changeProperty(display, window, wmHints, &GNOMEHints, 1);
	}

	// Now try to set KDE NET_WM hints (doesn't work for any reason)
	if ((rc = checkAtom(wmHints, tkwin, XA_NET_WM_WINDOW_TYPE)))
	{
		Atom netWmHints[2] =
		{
			Tk_InternAtom(tkwin, XA_KDE_NET_WM_WINDOW_TYPE_OVERRIDE),
			Tk_InternAtom(tkwin, XA_NET_WM_WINDOW_TYPE_NORMAL),
		};
		changeProperty(display, window, wmHints, &netWmHints, U_NUMBER_OF(netWmHints));
	}

	return rc;
}

#endif


static int
tcl_error(Tcl_Interp* ti, char const* fmt, ...)
{
	static char buf[512];
	static char extfmt[256];

	snprintf(extfmt, sizeof(extfmt), "%s: %s", Tcl_GetCommandName(ti, tk_cmd), fmt);

	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), extfmt, args);
	va_end(args);

	Tcl_SetResult(ti, buf, TCL_STATIC);
	return TCL_ERROR;
}


static int
cmdWM(ClientData client_data __attribute__((unused)),
		Tcl_Interp *ti,
		int objc,
		Tcl_Obj* const objv[])
{
	char const* Usage = "Usage: ::scidb::tk::wm (noDecor | grid | sync) <window> ...";

	if (objc < 2)
		return tcl_error(ti, Usage);

	char const*	subcmd	= Tcl_GetStringFromObj(objv[1], 0);
	char const*	path		= objc <= 2 ? 0 : Tcl_GetStringFromObj(objv[2], 0);
	Tk_Window	tkmain	= Tk_MainWindow(ti);
	Tk_Window	tkwin		= path ? Tk_NameToWindow(ti, path, tkmain) : tkmain;

	if (!tkwin)
		return TCL_ERROR;

	int rc = 1;

	if (strcmp(subcmd, "grid") == 0)
	{
		char const* Usage = "Usage: sc_wm grid <window> <baseWidth> <baseHeight> <widthInc> <heightInc>";

		if (objc != 7)
			return tcl_error(ti, Usage);

		int baseWidth, baseHeight, widthIncr, heightIncr;

		if (	Tcl_GetIntFromObj(ti, objv[3], &baseWidth ) != TCL_OK
			|| Tcl_GetIntFromObj(ti, objv[4], &baseHeight) != TCL_OK
			|| Tcl_GetIntFromObj(ti, objv[5], &widthIncr ) != TCL_OK
			|| Tcl_GetIntFromObj(ti, objv[6], &heightIncr) != TCL_OK)
		{
			return tcl_error(ti, Usage);
		}

		Tk_SetGrid(tkwin, baseWidth, baseHeight, widthIncr, heightIncr);
	}
#if !defined(WIN32) && !defined(__MacOSX__)
	else if (strcmp(subcmd, "noDecor") == 0)
	{
		Window window = Tk_WindowId(tkwin);

		if (window == None)
		{
			Tk_MakeWindowExist(tkwin);
			window = Tk_WindowId(tkwin);
		}

//		if (window == None)
//			return tcl_error(ti, "window '%s' not yet realized", path);

		if (!Tk_IsTopLevel(tkwin))
			return tcl_error(ti, "'%s' isn't a top level window", path);

		Window	parent;
		Window	root;
		Window*	children;
		unsigned	nchildren;

		if (XQueryTree(Tk_Display(tkmain), window, &root, &parent, &children, &nchildren) == 0)
			return tcl_error(ti, "XQueryTree() failed");

		if (children)
			XFree(children);

		rc = noDecor(tkmain, parent);
	}
	else if (strcmp(subcmd, "sync") == 0)
	{
		XSynchronize(Tk_Display(tkmain), True);
	}
#endif
	else
	{
		return tcl_error(ti, Usage);
	}

	Tcl_SetResult(ti, (char*)(rc ? "1" : "0"), TCL_STATIC);

	return TCL_OK;
}


void
tk::window_manager_init(Tcl_Interp* ti)
{
	tk_cmd = Tcl_CreateObjCommand(ti, "::scidb::tk::wm", cmdWM, 0, 0);
}

// vi:set ts=3 sw=3:
