// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2013 Gregor Cramer
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
#include "m_types.h"
#include "m_assert.h"

#include <tcl.h>
#include <tk.h>

#include <string.h>


static Tcl_Command tk_cmd = 0;


//#define GET_EXTENTS_IMMEDIATELY


#if !defined(__WIN32__) && !defined(__MacOSX__)

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

struct MWM_Hints
{
	unsigned long flags;
	unsigned long functions;
	unsigned long decorations;
	long input_mode;
	unsigned long status;
};

struct Rect
{
	Rect() :left(0), right(0), width(0), height(0) {}

	bool isEmpty() const { return height == 0 || width == 0 || left == 0 || right == 0; }
	bool hasSize() const { return height > 0 && width > 0; }

	void set(unsigned long const* data)
	{
		left		= data[0];
		right		= data[1];
		width		= data[2];
		height	= data[3];
	}

	int left;
	int right;
	int width;
	int height;
};

struct MyAtom
{
	MyAtom(char const* name) :m_name(name), m_atom(None), m_allocate(true) {}

	Atom get(Display* display, bool onlyIfExists)
	{
		if (m_allocate)
		{
			m_atom = XInternAtom(display, m_name, onlyIfExists ? True : False);
			m_allocate = false;
		}

		return m_atom;
	}

	char const*	m_name;
	Atom			m_atom;
	bool			m_allocate;
};


static char const* XA_KDE_NET_WM_FRAME_STRUT				= "_KDE_NET_WM_FRAME_STRUT";
static char const* XA_KDE_NET_WM_WINDOW_TYPE_OVERRIDE	= "_KDE_NET_WM_WINDOW_TYPE_OVERRIDE";
static char const* XA_KWM_WIN_DECORATION					= "KWM_WIN_DECORATION";
static char const* XA_MOTIF_WM_HINTS						= "_MOTIF_WM_HINTS";
static char const* XA_NET_ACTIVE_WINDOW					= "_NET_ACTIVE_WINDOW";
static char const* XA_NET_CURRENT_DESKTOP					= "_NET_CURRENT_DESKTOP";
static char const* XA_NET_FRAME_EXTENTS					= "_NET_FRAME_EXTENTS";
static char const* XA_NET_NUMBER_OF_DESKTOPS				= "_NET_NUMBER_OF_DESKTOPS";
static char const* XA_NET_REQUEST_FRAME_EXTENTS			= "_NET_REQUEST_FRAME_EXTENTS";
static char const* XA_NET_SUPPORTED							= "_NET_SUPPORTED";
static char const* XA_NET_WM_ACTION_CLOSE					= "_NET_WM_ACTION_CLOSE";
static char const* XA_NET_WM_ACTION_MAXIMIZE_HORZ		= "_NET_WM_ACTION_MAXIMIZE_HORZ";
static char const* XA_NET_WM_ACTION_MAXIMIZE_VERT		= "_NET_WM_ACTION_MAXIMIZE_VERT";
static char const* XA_NET_WM_ACTION_MOVE					= "_NET_WM_ACTION_MOVE";
static char const* XA_NET_WM_ACTION_RESIZE				= "_NET_WM_ACTION_RESIZE";
static char const* XA_NET_WM_ALLOWED_ACTIONS				= "_NET_WM_ALLOWED_ACTIONS";
static char const* XA_NET_WM_DESKTOP						= "_NET_WM_DESKTOP";
static char const* XA_NET_WM_WINDOW_TYPE					= "_NET_WM_WINDOW_TYPE";
static char const* XA_NET_WM_WINDOW_TYPE_DIALOG			= "_NET_WM_WINDOW_TYPE_DIALOG";
static char const* XA_NET_WM_WINDOW_TYPE_MENU			= "_NET_WM_WINDOW_TYPE_MENU";
static char const* XA_NET_WM_WINDOW_TYPE_NORMAL			= "_NET_WM_WINDOW_TYPE_NORMAL";
static char const* XA_NET_WM_WINDOW_TYPE_SPLASH			= "_NET_WM_WINDOW_TYPE_SPLASH";
static char const* XA_NET_WM_WINDOW_TYPE_TOOLBAR		= "_NET_WM_WINDOW_TYPE_TOOLBAR";
static char const* XA_NET_WORKAREA							= "_NET_WORKAREA";
static char const* XA_WIN_HINTS								= "_WIN_HINTS";
static char const* XA_WM_CLIENT_LEADER						= "WM_CLIENT_LEADER";

static MyAtom AtomList[] =
{
	XA_KDE_NET_WM_FRAME_STRUT,
	XA_KDE_NET_WM_WINDOW_TYPE_OVERRIDE,
	XA_KWM_WIN_DECORATION,
	XA_MOTIF_WM_HINTS,
	XA_NET_ACTIVE_WINDOW,
	XA_NET_CURRENT_DESKTOP,
	XA_NET_FRAME_EXTENTS,
	XA_NET_NUMBER_OF_DESKTOPS,
	XA_NET_REQUEST_FRAME_EXTENTS,
	XA_NET_SUPPORTED,
	XA_NET_WM_ACTION_CLOSE,
	XA_NET_WM_ACTION_MAXIMIZE_HORZ,
	XA_NET_WM_ACTION_MAXIMIZE_VERT,
	XA_NET_WM_ACTION_MOVE,
	XA_NET_WM_ACTION_RESIZE,
	XA_NET_WM_ALLOWED_ACTIONS,
	XA_NET_WM_DESKTOP,
	XA_NET_WM_WINDOW_TYPE,
	XA_NET_WM_WINDOW_TYPE_DIALOG,
	XA_NET_WM_WINDOW_TYPE_MENU,
	XA_NET_WM_WINDOW_TYPE_NORMAL,
	XA_NET_WM_WINDOW_TYPE_SPLASH,
	XA_NET_WM_WINDOW_TYPE_TOOLBAR,
	XA_NET_WORKAREA,
	XA_WIN_HINTS,
	XA_WM_CLIENT_LEADER,
};

static Rect m_extents;
#ifdef GET_EXTENTS_IMMEDIATELY
static bool m_timeout = false;
#endif


static unsigned char*
getProperty(Display* display, Window window, Atom atom, unsigned length, unsigned offset = 0)
{
	Atom				actualType;
	unsigned long	nitems;
	unsigned long	bytesAfter;
	int				actualFormat;
	unsigned char*	prop;

	int status = XGetWindowProperty(	display,
												window,
												atom,
												offset,
												length,
												False,
												XA_CARDINAL,
												&actualType,
												&actualFormat,
												&nitems,
												&bytesAfter,
												&prop);

	return status == Success && nitems >= length && actualFormat == 32 ? prop : 0;
}


static void
changeProperty1(Display* display, Window window, Atom which, void* data, int nelements)
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


static void
changeProperty2(Display* display, Window window, Atom prop, void* data, int nelements)
{
	XChangeProperty(	display,
							window,
							prop,
							XA_ATOM,
							32,
							PropModeReplace,
							static_cast<unsigned char*>(data),
							nelements);
}


static int
checkAtom(Atom& request, Display* display, char const* name)
{
	for (unsigned i = 0; i < U_NUMBER_OF(AtomList); ++i)
	{
		if (AtomList[i].m_name == name)
		{
			request = AtomList[i].get(display, true);
			return request != None;
		}
	}

	return 0;
}


static Atom
getAtom(Display* display, char const* name)
{
	for (unsigned i = 0; i < U_NUMBER_OF(AtomList); ++i)
	{
		if (AtomList[i].m_name == name)
			return AtomList[i].get(display, false);
	}

	return None;
}


static int
changeDecoration(Tk_Window tkwin, Window window, char const* property)
{
	M_ASSERT(property);

	Atom	request;
	int	rc = 0;

	Display* display = Tk_Display(tkwin);

	XLockDisplay(display);

	// First try to set MWM hints (works!)
	if ((rc = checkAtom(request, display, XA_MOTIF_WM_HINTS)))
	{
		MWM_Hints hints = { MWM_HINTS_DECORATIONS, 0, MWM_DECOR_NONE, 0, 0 };
		changeProperty1(display, window, request, &hints, sizeof(hints)/4);
	}

	// Now try to set KWM hints (doesn't work for any reason)
	if ((rc = checkAtom(request, display, XA_KWM_WIN_DECORATION)))
	{
		unsigned KWMHints = KDE_tinyDecoration;
		changeProperty1(display, window, request, &KWMHints, 1);
	}

	// Now try to set GNOME hints (working?)
	if ((rc = checkAtom(request, display, XA_WIN_HINTS)))
	{
		unsigned GNOMEHints = 0;
		changeProperty1(display, window, request, &GNOMEHints, 1);
	}

	// Now try to set KDE NET_WM hints
	if ((rc = checkAtom(request, display, XA_KDE_NET_WM_WINDOW_TYPE_OVERRIDE)))
	{
		Atom netWmHints[2] =
		{
			request,
			Tk_InternAtom(tkwin, property),
		};
		changeProperty2(display, window, request, &netWmHints, U_NUMBER_OF(netWmHints));
	}

	XUnlockDisplay(display);
	return rc;
}


static Window
getParent(Display* display, Window window)
{
	Window	root;
	Window	parent;
	Window*	childs;
	unsigned	nchilds;

	if (XQueryTree(display, window, &root, &parent, &childs, &nchilds) == 0)
		return window;

	if (childs)
		XFree(childs);

	if (parent == XDefaultRootWindow(display))
		return window;
	
	return parent;
}


void
setClientLeader(Tk_Window tkwin, Window window)
{
	static Window leader = 0;

	Atom		clientLeader	= Tk_InternAtom(tkwin, XA_WM_CLIENT_LEADER);
	Display*	display			= Tk_Display(tkwin);

	if (leader == 0)
	{
		Window rootWindow = XRootWindow(display, Tk_ScreenNumber(tkwin));
		leader = XCreateSimpleWindow(display, rootWindow, 0, 0, 1, 1, 0, 0, 0);
	}

	changeProperty1(display, getParent(display, window), clientLeader, &leader, 1);
}


void
raiseWindow(Tk_Window tkwin)
{
	Atom		atom				= Tk_InternAtom(tkwin, XA_NET_ACTIVE_WINDOW);
	Display*	display			= Tk_Display(tkwin);
	Window	rootWindow		= XRootWindow(display, Tk_ScreenNumber(tkwin));
	Window	activeWindow	= rootWindow;
	Window	window			= Tk_WindowId(tkwin);
	XEvent	xev;

	// NOTE: this function is not working although it should (seems to be a KDE problem)

	if (1)
	{
		Atom retAtom;
		int actualFormatReturn;
		unsigned long nitemsReturn;
		unsigned long bytesAfterReturn;
		unsigned char *data;

		XGetWindowProperty(
			display,
			rootWindow,
			atom,
			0, 1024,
			False,
			XA_WINDOW,
			&retAtom,
			&actualFormatReturn,
			&nitemsReturn,
			&bytesAfterReturn,
			&data);

		activeWindow = *((Window *)data);
		XFree(data);
	}

	::memset(&xev, 0, sizeof(xev));
	xev.xclient.type = ClientMessage;
//	xev.xclient.send_event = True;
	xev.xclient.display = display;
	xev.xclient.window = window;
	xev.xclient.message_type = atom;
	xev.xclient.format = 32;
	xev.xclient.data.l[0] = 1;
	xev.xclient.data.l[1] = CurrentTime;
	xev.xclient.data.l[2] = activeWindow;

	XSendEvent(	display,
					rootWindow,
					False,
					SubstructureRedirectMask|SubstructureNotifyMask,
					&xev);
	XSync(display, False);

	Window w = Tk_IsTopLevel(tkwin) ? getParent(display, window) : window;
	XRaiseWindow(display, w);

	XSetInputFocus(display, window, RevertToParent, CurrentTime);
	XFlush(display);
}


#if 0
static void
setDesktop(Tk_Window tkwin, int desktop)
{
	if (desktop < 0)
		return;

	Display*	display	= Tk_Display(tkwin);
	Window	window	= Tk_WindowId(tkwin);
	Atom		request;

	if (!checkAtom(request, display, XA_NET_WM_DESKTOP))
		return;

	XWindowAttributes attr;
	XGetWindowAttributes(display, window, &attr);

	XEvent xev;
	memset(&xev, 0, sizeof(xev));

	xev.type = ClientMessage;
	xev.xclient.display = display;
	xev.xclient.window = window;
	xev.xclient.message_type = request;
	xev.xclient.format = 32;
	xev.xclient.data.l[0] = desktop;
	xev.xclient.data.l[1] = 1;

	XSendEvent(	display,
					attr.screen->root,
					False,
					SubstructureNotifyMask | SubstructureRedirectMask,
					&xev);
}
#endif


static int
getDesktop(Tk_Window tkwin)
{
	Display*	display	= Tk_Display(tkwin);
	Window	window	= getParent(display, Tk_WindowId(tkwin));
	Atom		request;

	if (!checkAtom(request, display, XA_NET_WM_DESKTOP))
		return -1;

	while (!Tk_IsTopLevel(tkwin))
	{
		if ((tkwin = Tk_Parent(tkwin)) == 0)
			return -1;
	}

	unsigned long* data = reinterpret_cast<unsigned long*>(getProperty(display, window, request, 1));

	if (data == 0)
		return -1;

	int desktop = *data;
	XFree(data);
	return desktop;
}


static void
setCurrentDesktop(Tk_Window tkwin, int desktop)
{
	if (desktop < 0)
		return;

	Display*	display	= Tk_Display(tkwin);
	Window	root		= XDefaultRootWindow(display);
	Atom		request;

	if (!checkAtom(request, display, XA_NET_CURRENT_DESKTOP))
		return;

	XEvent xev;
	memset(&xev, 0, sizeof(xev));

	xev.type = ClientMessage;
	xev.xclient.display = display;
	xev.xclient.window = root;
	xev.xclient.message_type = request;
	xev.xclient.format = 32;
	xev.xclient.data.l[0] = desktop;
	xev.xclient.data.l[1] = CurrentTime;

	XSendEvent(display, root, False, SubstructureNotifyMask | SubstructureRedirectMask, &xev);
}


static bool
getWorkArea(Display* display, int desktop, Rect& result)
{
	if (desktop < 0)
		return false;

	Window	root = XDefaultRootWindow(display);
	Atom		prop;

	if (!checkAtom(prop, display, XA_NET_WORKAREA))
		return false;

	unsigned long* data =
		reinterpret_cast<unsigned long*>(getProperty(display, root, prop, 4, 4*desktop));

	if (data == 0)
		return false;

	result.set(data);
	XFree(data);

	return true;
}


static int
getCurrentDesktop(Display* display)
{
	Window	root = XDefaultRootWindow(display);
	Atom		prop;

	if (!checkAtom(prop, display, XA_NET_CURRENT_DESKTOP))
		return -1;

	unsigned long* data = reinterpret_cast<unsigned long*>(getProperty(display, root, prop, 1));

	if (data == 0)
		return -1;

	int desktop = *data;
	XFree(data);

	return desktop;
}


static bool
getDefaultExtents(Rect& result)
{
	result.left = 3;
	result.right = 3;
	result.width = 30;
	result.height = 3;

	return false;
}


#ifdef GET_EXTENTS_IMMEDIATELY
static void
timeoutProc(ClientData clientData)
{
	m_timeout = true;
}
#endif


static int
handleDesktopProperties(ClientData clientData, XEvent* xev)
{
	if (	xev->type == PropertyNotify
		&& xev->xproperty.atom == Atom(clientData)
		&& xev->xproperty.state == PropertyNewValue)
	{
		Atom extents;

		if (checkAtom(extents, xev->xany.display, XA_NET_FRAME_EXTENTS))
		{
			unsigned long* data = reinterpret_cast<unsigned long*>
											(getProperty(xev->xany.display, xev->xany.window, extents, 4));

			if (data)
			{
				m_extents.set(data);
				XFree(data);
			}
		}

#ifdef GET_EXTENTS_IMMEDIATELY
		m_timeout = true;
#endif
	}

	return 0;
}


static void
requestDesktopProperties(Tcl_Interp* ti, Tk_Window tkwin)
{
	Display*	display	= Tk_Display(tkwin);
	Window	window	= Tk_WindowId(tkwin);
	Atom		extents;

	if (checkAtom(extents, display, XA_NET_FRAME_EXTENTS))
	{
		Atom xaAtom = getAtom(display, XA_NET_REQUEST_FRAME_EXTENTS);

		XEvent xev;
		memset(&xev, 0, sizeof(xev));
		xev.xclient.message_type = xaAtom;
		xev.xclient.type = ClientMessage;
		xev.xclient.display = display;
		xev.xclient.window = window; // XXX is this the correct window?
		xev.xclient.format = 32;

		Window root = XDefaultRootWindow(display);
		XSendEvent(display, root, False, SubstructureRedirectMask | SubstructureNotifyMask, &xev);

		// XXX clientdata is correct?
		Tk_CreateGenericHandler(handleDesktopProperties, ClientData(xaAtom));

#ifdef GET_EXTENTS_IMMEDIATELY
		Tcl_TimerToken timer = Tcl_CreateTimerHandler(250, timeoutProc, ti);

		m_timeout = false;

		while (!m_timeout)
			Tcl_DoOneEvent(TCL_ALL_EVENTS);

		Tcl_DeleteTimerHandler(timer);
		Tk_DeleteGenericHandler(handleDesktopProperties, ClientData(xaAtom));
#endif
	}
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


static void
setResult(Tcl_Interp* ti, Rect& rect)
{
	Tcl_Obj* objs[4] =
	{
		Tcl_NewIntObj(rect.left),
		Tcl_NewIntObj(rect.right),
		Tcl_NewIntObj(rect.width),
		Tcl_NewIntObj(rect.height)
	};
	Tcl_SetObjResult(ti, Tcl_NewListObj(4, objs));
}


static int
cmdWM(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	char const* Usage =	"Usage: ::scidb::tk::wm (frameless | splash | toolbar | menu | grid "
								"| setLeader | map | raise | sync | desktop | ondesktop) <window> ...";

	if (objc < 2)
		return tcl_error(ti, Usage);

	char const*	subcmd	= Tcl_GetString(objv[1]);
	char const*	path		= objc <= 2 ? 0 : Tcl_GetString(objv[2]);
	Tk_Window	tkmain	= Tk_MainWindow(ti);
	Tk_Window	tkwin		= path ? Tk_NameToWindow(ti, path, tkmain) : tkmain;

	if (!tkwin)
		return TCL_ERROR;
	
	if (path == 0)
		path = Tk_PathName(tkwin);

	int rc = 1;

	if (strcasecmp(subcmd, "grid") == 0)
	{
		char const* Usage =	"Usage: ::scidb::tk::wm grid <window> <baseWidth> "
									"<baseHeight> <widthInc> <heightInc>";

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
	else if (strcasecmp(subcmd, "startup") == 0)
	{
#if !defined(__WIN32__) && !defined(__MacOSX__)
		getDefaultExtents(m_extents);
		requestDesktopProperties(ti, tkwin);
#endif
	}
	else if (strcasecmp(subcmd, "desktop") == 0)
	{
#if !defined(__WIN32__) && !defined(__MacOSX__)
		setCurrentDesktop(tkmain, getDesktop(tkwin));
#endif
	}
	else if (strcasecmp(subcmd, "ondesktop") == 0)
	{
		bool result = true;

#if !defined(__WIN32__) && !defined(__MacOSX__)
		int desktop1 = getCurrentDesktop(Tk_Display(tkwin));
		int desktop2 = getDesktop(tkwin);

		result = desktop1 >= 0 && desktop2 >= 0 && desktop1 == desktop2;
#endif

		Tcl_SetObjResult(ti, Tcl_NewBooleanObj(result));
		return TCL_OK;
	}
	else if (strcasecmp(subcmd, "workarea") == 0)
	{
		Rect result;

#if defined(__WIN32__)
# error "not yet implemented"
#elif defined(__MacOSX__)
# error "not yet implemented"
#else
		Display* display = Tk_Display(tkwin);

		if (!getWorkArea(display, getDesktop(tkwin), result))
			getWorkArea(display, getCurrentDesktop(display), result);
#endif

		if (result.hasSize())
			setResult(ti, result);

		return TCL_OK;
	}
	else if (strcasecmp(subcmd, "extents") == 0)
	{
		Rect result;

#if defined(__WIN32__)
# error "not yet implemented"
#elif defined(__MacOSX__)
# error "not yet implemented"
#endif

		if (!m_extents.isEmpty())
			setResult(ti, m_extents);

		return TCL_OK;
	}
#if !defined(__WIN32__) && !defined(__MacOSX__)
	else if (	strcasecmp(subcmd, "frameless") == 0
				|| strcasecmp(subcmd, "dialog") == 0
				|| strcasecmp(subcmd, "normal") == 0
				|| strcasecmp(subcmd, "toolbar") == 0
				|| strcasecmp(subcmd, "splash") == 0
				|| strcasecmp(subcmd, "notification") == 0
				|| strcasecmp(subcmd, "menu") == 0)
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

		Window parent = getParent(Tk_Display(tkmain), window);

		char const* prop = 0;

		switch (*subcmd)
		{
			case 'd': prop = XA_NET_WM_WINDOW_TYPE_DIALOG; break;
			case 'f': prop = XA_NET_WM_WINDOW_TYPE_DIALOG; break;
			case 'm': prop = XA_NET_WM_WINDOW_TYPE_MENU; break;
			case 'n': prop = XA_NET_WM_WINDOW_TYPE_NORMAL; break;
			case 't': prop = XA_NET_WM_WINDOW_TYPE_TOOLBAR; break;
			case 's': prop = XA_NET_WM_WINDOW_TYPE_SPLASH; break;
		}

		rc = changeDecoration(tkmain, parent, prop);
	}
	else if (strcasecmp(subcmd, "setLeader") == 0)
	{
		if (!Tk_IsTopLevel(tkwin))
			return tcl_error(ti, "'%s' isn't a top level window", path);

		setClientLeader(tkwin, Tk_WindowId(tkwin));
	}
	else if (strcasecmp(subcmd, "raise") == 0)
	{
		raiseWindow(tkwin);
	}
	else if (strcasecmp(subcmd, "map") == 0)
	{
		Tk_MapWindow(tkwin);
	}
	else if (strcasecmp(subcmd, "sync") == 0)
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
