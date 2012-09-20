// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

// ======================================================================
// This file is adopted from tcl3d/tcl3dOgl/Ogl/ogl.c
// Copyright (C) 1996-2002 Brian Paul and Ben Bederson
// Copyright (C) 2005-2009 Greg Couch
// Copyright (C) 2005-2010 Paul Obermeier
// ======================================================================

#include "tk_ogl.h"

#define namespace namespace_	// bug in tcl8.6/tkInt.h
#include <tkInt.h>
#undef namespace

#if defined(__WIN32__)

//# define WIN32_LEAN_AND_MEAN
# include <windows.h>
//# undef WIN32_LEAN_AND_MEAN
# include <winnt.h>
# include <Strsafe.h>

# undef near
# undef far

#elif defined(__unix__)

# include <X11/Xlib.h>
# include <X11/Xutil.h>
# include <X11/Xatom.h>

# ifndef SOLARIS_BUG
#  include "X11/XmuColormap.h"
# endif

//// Mac headers ////
#elif defined(__MacOSX__)

# define Cursor QDCursor
# include <AGL/agl.h>
# undef Cursor
# include <tkInt.h>
# include <tkMacOSX.h>
# include <tkMacOSXInt.h>      // usa MacDrawable
# include <ApplicationServices/ApplicationServices.h>

# define MacOSXGetDrawablePort(ogl) \
	TkMacOSXGetDrawablePort((Drawable)((TkWindow *)ogl->tkWin)->privatePtr)

#else

# error Unsupported platform, or confused platform defines...

#endif

# include <GL/glx.h>

#include "m_assert.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#ifdef __WIN32__
# include <tkPlatDecls.h>
# include <tkWinInt.h>
#endif


#ifndef GLX_CONTEXT_MAJOR_VERSION_ARB
# define GLX_CONTEXT_MAJOR_VERSION_ARB		0x2091
#endif
#ifndef GLX_CONTEXT_MINOR_VERSION_ARB
# define GLX_CONTEXT_MINOR_VERSION_ARB		0x2092
#endif
#ifndef GLX_CONTEXT_FLAGS_ARB
# define GLX_CONTEXT_FLAGS_ARB				0x2094
#endif
#ifndef GLX_CONTEXT_PROFILE_MASK_ARB
# define GLX_CONTEXT_PROFILE_MASK_ARB		0x9126
#endif
#ifndef GLX_CONTEXT_CORE_PROFILE_BIT_ARB
# define GLX_CONTEXT_CORE_PROFILE_BIT_ARB	0x0001
#endif
#ifndef GLX_CONTEXT_DEBUG_BIT_ARB
# define GLX_CONTEXT_DEBUG_BIT_ARB			0x0001
#endif


#define DEFAULT_WIDTH		"400"
#define DEFAULT_HEIGHT		"400"
#define DEFAULT_IDENT		""
#define DEFAULT_FONTNAME	"fixed"
#define DEFAULT_FONTSIZE	"12"
#define DEFAULT_TIME			"1"


#ifdef __WIN32__

// Maximum size of a logical palette corresponding to a colormap in color index mode.
# define MAX_CI_COLORMAP_SIZE 4096
# define MAX_CI_COLORMAP_BITS 12

#endif


// The constant DUMMY_WINDOW is used to signal window creation failure from ogl_makeWindow()
#define DUMMY_WINDOW ((Window) -1)

#define ALL_EVENTS_MASK   \
	( KeyPressMask         \
	| KeyReleaseMask       \
	| ButtonPressMask      \
	| ButtonReleaseMask    \
	| EnterWindowMask      \
	| LeaveWindowMask      \
	| PointerMotionMask    \
	| ExposureMask         \
	| VisibilityChangeMask \
	| FocusChangeMask      \
	| PropertyChangeMask   \
	| ColormapChangeMask)


typedef tk::ogl::Context Ogl;

// Stuff we initialize on a per package (ogl_init) basis.
// Since Tcl uses one interpreter per thread, any per-thread
// data goes here.
struct ogl_packageGlobals
{
	Tk_OptionTable optionTable;		// Used to parse options
	Ogl*				oglHead;				// Head of linked list of all Ogl widgets
	int				nextContextTag;	// Used to assign similar context tags
};

typedef struct ogl_packageGlobals ogl_packageGlobals;


namespace tk {
namespace ogl {

struct Context
{
    Context*					next;					// next in linked list

#if defined(__WIN32__)

    HGLRC						ctx;					// OpenGL rendering context to be made current
    HDC							tglGLHdc;			// Device context of device that OpenGL calls will be drawn on
    int							ciColormapSize;	// (Maximum) size of colormap in color index mode

#elif defined(__unix__)

    GLXContext					ctx;					// Normal planes GLX context

#elif defined(__MacOSX__)

    AGLContext					ctx;

#endif

    int						contextTag;			// all contexts with same tag share display lists
    XVisualInfo*			visInfo;				// Visual info of the current
    Display*				display;				// X's token for the window's display.
    Tk_Window				tkWin;				// Tk window structure
    Tcl_Interp*			interp;				// Tcl interpreter
    Tcl_Command			widgetCmd;			// Token for ogl's widget command
    ogl_packageGlobals*	tpg;					// Used to access globals
    Tk_Cursor				cursor;				// The widget's cursor
    int						width;     	 		// Dimensions of window
	 int						height;				// Dimensions of window
    int						setGrid;				// positive is grid size for window manager
    int						timerInterval;		// Time interval for timer in milliseconds
    Tcl_TimerToken		timerHandler;		// Token for Ogl's timer handler
    int						rgbaRed;
    int						rgbaGreen;
    int						rgbaBlue;
    Bool						doubleFlag;
    Bool						depthFlag;
    int						depthSize;
    Bool						accumFlag;
    int						accumRed;
    int						accumGreen;
    int						accumBlue;
    int						accumAlpha;
    Bool						alphaFlag;
    int						alphaSize;
    Bool						stencilFlag;
    int						stencilSize;
    Bool						privateCmapFlag;
    int						auxNumber;
    Bool						indirect;
    int						pixelFormat;
    int						majorVersion;
    int						minorVersion;
    Bool						debugContext;
    int						swapInterval;
    int						multisampleBuffers;
    int						multisampleSamples;
    Bool						fullscreenFlag;
    char const*			shareList;			// name (ident) of Ogl to share dlists with
    char const*			shareContext;		// name (ident) to share OpenGL context with
    char const*			ident;				// User's identification string
    ClientData				clientData;			// Pointer to user data
    Bool						updatePending;		// Should normal planes be redrawn?
    Tcl_Obj*				createProc;			// Callback when widget is realized
    Tcl_Obj*				displayProc;		// Callback when widget is redrawn
    Tcl_Obj*				reshapeProc;		// Callback when window size changes
    Tcl_Obj*				destroyProc;		// Callback when widget is destroyed
    Tcl_Obj*				timerProc;			// Callback when widget is idle
    GLfloat*				redMap;				// Index2RGB Maps for Color index modes
    GLfloat*				greenMap;
    GLfloat*				blueMap;
    GLint					mapSize;				// = Number of indices in our Ogl
    int						badWindow;			// true when ogl_makeWindow fails or should create a dummy
};

} // namespace tk
} // namespace ogl


static int ogl_objCmd(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj *const* objv);
static void ogl_objCmdDelete(ClientData clientData);
static void ogl_eventProc(ClientData clientData, XEvent *eventPtr);
static Window ogl_makeWindow(Tk_Window, Window, ClientData);
static void ogl_worldChanged(ClientData);
static void ogl_oglCmdDeletedProc(ClientData);

#if defined(__MacOSX__)
static void setMacBufRect(Ogl* ogl);
#endif

static void ogl_postRedisplay(Ogl* ogl);
static GLuint ogl_loadBitmapFont(Ogl const* ogl,
											char const* fontname,
											char const* fontsize,
											char const* weight,
											char const* slant);
static void ogl_unloadBitmapFont(Ogl const* ogl, GLuint fontbase);
static int ogl_contextTag(Ogl const* ogl);
static int ogl_width(Ogl const* ogl);
static int ogl_height(Ogl const* ogl);


#define GEOMETRY_MASK		0x1
#define FORMAT_MASK			0x2
#define CURSOR_MASK			0x4
#define TIMER_MASK			0x8
#define SWAP_MASK				0x20
#define MULTISAMPLE_MASK	0x40
#define PROFILE_MASK			0x80

static Tk_OptionSpec optionSpecs[] = {
	{TK_OPTION_PIXELS, "-height", "height", "Height",
		DEFAULT_HEIGHT, -1, Tk_Offset(Ogl, height), 0, 0, GEOMETRY_MASK},
	{TK_OPTION_PIXELS, "-width", "width", "Width",
		DEFAULT_WIDTH, -1, Tk_Offset(Ogl, width), 0, 0, GEOMETRY_MASK},
	{TK_OPTION_INT, "-redsize", "redsize", "RedSize",
		"1", -1, Tk_Offset(Ogl, rgbaRed), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-greensize", "greensize", "GreenSize",
		"1", -1, Tk_Offset(Ogl, rgbaGreen), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-bluesize", "bluesize", "BlueSize",
		"1", -1, Tk_Offset(Ogl, rgbaBlue), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-double", "double", "Double",
		"false", -1, Tk_Offset(Ogl, doubleFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-depth", "depth", "Depth",
		"false", -1, Tk_Offset(Ogl, depthFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-depthsize", "depthsize", "DepthSize",
		"1", -1, Tk_Offset(Ogl, depthSize), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-accum", "accum", "Accum",
		"false", -1, Tk_Offset(Ogl, accumFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-accumredsize", "accumredsize", "AccumRedSize",
		"1", -1, Tk_Offset(Ogl, accumRed), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-accumgreensize", "accumgreensize",
		"AccumGreenSize", "1", -1, Tk_Offset(Ogl, accumGreen), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-accumbluesize", "accumbluesize",
		"AccumBlueSize", "1", -1, Tk_Offset(Ogl, accumBlue), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-accumalphasize", "accumalphasize",
		"AccumAlphaSize", "1", -1, Tk_Offset(Ogl, accumAlpha), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-alpha", "alpha", "Alpha",
		"false", -1, Tk_Offset(Ogl, alphaFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-alphasize", "alphasize", "AlphaSize",
		"1", -1, Tk_Offset(Ogl, alphaSize), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-stencil", "stencil", "Stencil",
		"false", -1, Tk_Offset(Ogl, stencilFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-stencilsize", "stencilsize", "StencilSize",
		"1", -1, Tk_Offset(Ogl, stencilSize), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-auxbuffers", "auxbuffers", "AuxBuffers",
		"0", -1, Tk_Offset(Ogl, auxNumber), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-privatecmap", "privateCmap", "PrivateCmap",
		"false", -1, Tk_Offset(Ogl, privateCmapFlag), 0, 0, FORMAT_MASK},
	{TK_OPTION_CURSOR, "-cursor", "cursor", "Cursor",
		"", -1, Tk_Offset(Ogl, cursor), TK_OPTION_NULL_OK, 0, CURSOR_MASK},
	{TK_OPTION_INT, "-setgrid", "setGrid", "SetGrid",
		"0", -1, Tk_Offset(Ogl, setGrid), 0, 0, GEOMETRY_MASK},
	{TK_OPTION_INT, "-time", "time", "Time",
		DEFAULT_TIME, -1, Tk_Offset(Ogl, timerInterval), 0, 0, TIMER_MASK},
	{TK_OPTION_STRING, "-sharelist", "sharelist", "ShareList",
		0, -1, Tk_Offset(Ogl, shareList), 0, 0, FORMAT_MASK},
	{TK_OPTION_STRING, "-sharecontext", "sharecontext",
		"ShareContext", 0, -1, Tk_Offset(Ogl, shareContext), 0, 0, FORMAT_MASK},
	{TK_OPTION_STRING, "-ident", "ident", "Ident",
		DEFAULT_IDENT, -1, Tk_Offset(Ogl, ident), 0, 0, 0},
	{TK_OPTION_BOOLEAN, "-indirect", "indirect", "Indirect",
		"false", -1, Tk_Offset(Ogl, indirect), 0, 0, FORMAT_MASK},
	{TK_OPTION_INT, "-pixelformat", "pixelFormat", "PixelFormat",
		"0", -1, Tk_Offset(Ogl, pixelFormat), 0, 0, FORMAT_MASK},
	{TK_OPTION_BOOLEAN, "-debug", "debug", "Debug",
		"false", -1, Tk_Offset(Ogl, debugContext), 0, 0, PROFILE_MASK},
	{TK_OPTION_INT, "-major", "major", "Major",
		"1", -1, Tk_Offset(Ogl, majorVersion), 0, 0, PROFILE_MASK},
	{TK_OPTION_INT, "-minor", "minor", "Minor",
		"0", -1, Tk_Offset(Ogl, minorVersion), 0, 0, PROFILE_MASK},
	{TK_OPTION_INT, "-swapinterval", "swapInterval", "SwapInterval",
		"0", -1, Tk_Offset(Ogl, swapInterval), 0, 0, SWAP_MASK},
	{TK_OPTION_INT, "-multisamplebuffers", "multisampleBuffers",
		"MultisampleBuffers", "0", -1, Tk_Offset(Ogl, multisampleBuffers),
		0, 0, MULTISAMPLE_MASK},
	{TK_OPTION_INT, "-multisamplesamples", "multisampleSamples",
		"MultisampleSamples", "2", -1, Tk_Offset(Ogl, multisampleSamples),
		0, 0, MULTISAMPLE_MASK},
	{TK_OPTION_BOOLEAN, "-fullscreen", "fullscreen", "Fullscreen",
		"false", -1, Tk_Offset(Ogl, fullscreenFlag), 0, 0, GEOMETRY_MASK|FORMAT_MASK},
	{TK_OPTION_STRING, "-createcommand", "createCommand",
		"CallbackCommand", 0, Tk_Offset(Ogl, createProc), -1, TK_OPTION_NULL_OK, 0, 0},
	{TK_OPTION_SYNONYM, "-create", 0, 0,
		0, -1, -1, 0, (ClientData) "-createcommand", 0},
	{TK_OPTION_STRING, "-displaycommand", "displayCommand",
		"CallbackCommand", 0, Tk_Offset(Ogl, displayProc), -1, TK_OPTION_NULL_OK, 0, 0},
	{TK_OPTION_SYNONYM, "-display", 0, 0,
		0, -1, -1, 0, (ClientData) "-displaycommand", 0},
	{TK_OPTION_STRING, "-reshapecommand", "reshapeCommand",
		"CallbackCommand", 0, Tk_Offset(Ogl, reshapeProc), -1, TK_OPTION_NULL_OK, 0, 0},
	{TK_OPTION_SYNONYM, "-reshape", 0, 0,
		0, -1, -1, 0, (ClientData) "-reshapecommand", 0},
	{TK_OPTION_STRING, "-destroycommand", "destroyCommand",
		"CallbackCommand", 0, Tk_Offset(Ogl, destroyProc), -1, TK_OPTION_NULL_OK, 0, 0},
	{TK_OPTION_SYNONYM, "-destroy", 0, 0,
		0, -1, -1, 0, (ClientData) "-destroycommand", 0},
	{TK_OPTION_STRING, "-timercommand", "timerCommand",
		"CallbackCommand", 0, Tk_Offset(Ogl, timerProc), -1, TK_OPTION_NULL_OK, 0, 0},
	{TK_OPTION_SYNONYM, "-timer", 0, 0,
		0, -1, -1, 0, (ClientData) "-timercommand", 0},
	{TK_OPTION_SYNONYM, "-createproc", 0, 0,
		0, -1, -1, 0, (ClientData) "-createcommand", 0},
	{TK_OPTION_SYNONYM, "-displayproc", 0, 0,
		0, -1, -1, 0, (ClientData) "-displaycommand", 0},
	{TK_OPTION_SYNONYM, "-reshapeproc", 0, 0,
		0, -1, -1, 0, (ClientData) "-reshapecommand", 0},
	{TK_OPTION_END, 0, 0, 0, 0, -1, -1, 0, 0, 0}
};


#ifdef __unix__
#endif


// Add given ogl widget to linked list.
static void
addToList(Ogl* t)
{
	t->next = t->tpg->oglHead;
	t->tpg->oglHead = t;
}


// Remove given ogl widget from linked list.
static void
removeFromList(Ogl* t)
{
	Ogl* prev	= 0;
	Ogl* cur	= t->tpg->oglHead;

	while (t != cur)
	{
		prev = cur;
		cur = cur->next;

		if (cur == 0)
			return;
	}

	if (prev)
		prev->next = cur->next;
	else
		t->tpg->oglHead = cur->next;

	cur->next = 0;
}


// Return pointer to ogl widget given a user identifier string.
static Ogl*
findOgl(Ogl* ogl, char const* ident)
{
	Ogl* t;

	if (ident[0] != '.')
	{
		for (t = ogl->tpg->oglHead; t; t = t->next)
		{
			if (strcmp(t->ident, ident) == 0)
				return t;
		}
	}
	else
	{
		for (t = ogl->tpg->oglHead; t; t = t->next)
		{
			char const* pathname = Tk_PathName(t->tkWin);

			if (strcmp(pathname, ident) == 0)
				return t;
		}
	}

	return 0;
}


// Return pointer to another ogl widget with same OpenGL context.
static Ogl*
findOglWithSameContext(Ogl const* ogl)
{
	Ogl* t = ogl->tpg->oglHead;

	for (t = ogl->tpg->oglHead; t; t = t->next)
	{
		if (t != ogl && t->ctx == ogl->ctx)
			return t;
	}

	return 0;
}


#if defined(__unix__)

// Return an X colormap to use for OpenGL RGB-mode rendering.
// Input:  dpy - the X display
//         scrnum - the X screen number
//         visinfo - the XVisualInfo as returned by glXChooseVisual()
// Return:  an X Colormap or 0 if there's a _serious_ error.
static Colormap
get_rgb_colormap(Display* dpy, int scrnum, XVisualInfo const* visinfo, Tk_Window tkwin)
{
	Window	root			= XRootWindow(dpy, scrnum);
	Bool		usingMesa;

	// First check if visinfo's visual matches the default/root visual.
	if (visinfo->visual == Tk_Visual(tkwin)) {
		// use the default/root colormap
		return Tk_Colormap(tkwin);
	}

	// Check if we're using Mesa.
	usingMesa = strstr(glXQueryServerString(dpy, scrnum, GLX_VERSION), "Mesa") != 0;

	// Next, if we're using Mesa and displaying on an HP with the "Color
	// Recovery" feature and the visual is 8-bit TrueColor, search for a
	// special colormap initialized for dithering.  Mesa will know how to
	// dither using this colormap.
	if (usingMesa)
	{
		Atom hpCrMaps = XInternAtom(dpy, "_HP_RGB_SMOOTH_MAP_LIST", True);

		if (	hpCrMaps
# ifdef __cplusplus
			&& visinfo->visual->c_class == TrueColor
# else
			&& visinfo->visual->class == TrueColor
# endif
			&& visinfo->depth == 8)
		{
			XStandardColormap* standardCmaps;
			int numCmaps;

			if (XGetRGBColormaps(dpy, root, &standardCmaps, &numCmaps, hpCrMaps))
			{
				int i;

				for (i = 0; i < numCmaps; i++) {
					if (standardCmaps[i].visualid == visinfo->visual->visualid)
					{
						Colormap cmap = standardCmaps[i].colormap;
						XFree(standardCmaps);
						return cmap;
					}
				}

				XFree(standardCmaps);
			}
		}
	}

	// Next, try to find a standard X colormap.
# ifndef SOLARIS_BUG
	if (XmuLookupStandardColormap(
			dpy,
			visinfo->screen,
			visinfo->visualid,
			visinfo->depth,
			XA_RGB_DEFAULT_MAP,
			False,
			True)  == 1)
	{
		XStandardColormap* standardCmaps;
		int numCmaps;

		if (XGetRGBColormaps(dpy, root, &standardCmaps, &numCmaps, XA_RGB_DEFAULT_MAP) == 1)
		{
			int i;

			for (i = 0; i < numCmaps; i++)
			{
				if (standardCmaps[i].visualid == visinfo->visualid)
				{
					Colormap cmap = standardCmaps[i].colormap;
					XFree(standardCmaps);
					return cmap;
				}
			}

			XFree(standardCmaps);
		}
	}
# endif

	// If we get here, give up and just allocate a new colormap.
	return XCreateColormap(dpy, root, visinfo->visual, AllocNone);
}

#elif defined(__WIN32__)

// Code to create RGB palette is taken from the GENGL sample program of Win32 SDK

static const unsigned char threeto8[8] =
{
	0, 0111 >> 1, 0222 >> 1, 0333 >> 1, 0444 >> 1, 0555 >> 1, 0666 >> 1, 0377
};

static const unsigned char twoto8[4] = { 0, 0x55, 0xaa, 0xff };
static const unsigned char oneto8[2] = { 0, 255 };

static int const defaultOverride[13] =
{
	0, 3, 24, 27, 64, 67, 88, 173, 181, 236, 247, 164, 91
};

static const PALETTEENTRY defaultPalEntry[20] =
{
	{ 0x00, 0x00, 0x00, 0x00 },
	{ 0x80, 0x00, 0x00, 0x00 },
	{ 0x00, 0x80, 0x00, 0x00 },
	{ 0x80, 0x80, 0x00, 0x00 },
	{ 0x00, 0x00, 0x80, 0x00 },
	{ 0x80, 0x00, 0x80, 0x00 },
	{ 0x00, 0x80, 0x80, 0x00 },
	{ 0xC0, 0xC0, 0xC0, 0x00 },

	{ 0xC0, 0xDC, 0xC0, 0x00 },
	{ 0xA6, 0xCA, 0xF0, 0x00 },
	{ 0xFF, 0xFB, 0xF0, 0x00 },
	{ 0xA0, 0xA0, 0xA4, 0x00 },

	{ 0x80, 0x80, 0x80, 0x00 },
	{ 0xFF, 0x00, 0x00, 0x00 },
	{ 0x00, 0xFF, 0x00, 0x00 },
	{ 0xFF, 0xFF, 0x00, 0x00 },
	{ 0x00, 0x00, 0xFF, 0x00 },
	{ 0xFF, 0x00, 0xFF, 0x00 },
	{ 0x00, 0xFF, 0xFF, 0x00 },
	{ 0xFF, 0xFF, 0xFF, 0x00 }
};


static unsigned char
componentFromIndex(int i, UINT nbits, UINT shift)
{
	unsigned char val = (unsigned char)(i >> shift);

	switch (nbits)
	{
		case 1: return oneto8[val & 0x1];
		case 2: return twoto8[val & 0x3];
		case 3: return threeto8[val & 0x7];
	}

	return 0;
}


static Colormap
win32CreateRgbColormap(PIXELFORMATDESCRIPTOR pfd)
{
	TkWinColormap*	cmap	= ckalloc(sizeof(TkWinColormap));
	int				n		= 1 << pfd.cColorBits;
	LOGPALETTE*		pPal	= LocalAlloc(LMEM_FIXED, sizeof(LOGPALETTE) + n*sizeof(PALETTEENTRY));
	int				i;

	pPal->palVersion = 0x300;
	pPal->palNumEntries = n;

	for (i = 0; i < n; i++)
	{
		pPal->palPalEntry[i].peRed = componentFromIndex(i, pfd.cRedBits, pfd.cRedShift);
		pPal->palPalEntry[i].peGreen = componentFromIndex(i, pfd.cGreenBits, pfd.cGreenShift);
		pPal->palPalEntry[i].peBlue = componentFromIndex(i, pfd.cBlueBits, pfd.cBlueShift);
		pPal->palPalEntry[i].peFlags = 0;
	}

	// fix up the palette to include the default GDI palette
	if (	pfd.cColorBits == 8
		&& pfd.cRedBits == 3
		&& pfd.cRedShift == 0
		&& pfd.cGreenBits == 3
		&& pfd.cGreenShift == 3
		&& pfd.cBlueBits == 2
		&& pfd.cBlueShift == 6)
	{
		for (i = 1; i <= 12; i++)
			pPal->palPalEntry[defaultOverride[i]] = defaultPalEntry[i];
	}

	cmap->palette = CreatePalette(pPal);
	LocalFree(pPal);
	cmap->size = n;
	cmap->stale = 0;

	// Since this is a private colormap of a fix size, we do not need a valid
	// hash table, but a dummy one.
	Tcl_InitHashTable(&cmap->refCounts, TCL_ONE_WORD_KEYS);
	return (Colormap)cmap;
}


static Colormap
win32CreateCiColormap(Ogl* ogl)
{
	// Create a colormap with size of ogl->ciColormapSize and set all entries to black
	LOGPALETTE		logPalette;
	TkWinColormap*	cmap = (TkWinColormap*)ckalloc(sizeof(TkWinColormap));

	logPalette.palVersion = 0x300;
	logPalette.palNumEntries = 1;
	logPalette.palPalEntry[0].peRed = 0;
	logPalette.palPalEntry[0].peGreen = 0;
	logPalette.palPalEntry[0].peBlue = 0;
	logPalette.palPalEntry[0].peFlags = 0;

	cmap->palette = CreatePalette(&logPalette);
	cmap->size = ogl->ciColormapSize;
	ResizePalette(cmap->palette, cmap->size);	// sets new entries to black
	cmap->stale = 0;

	// Since this is a private colormap of a fix size, we do not need a valid
	// hash table, but a dummy one.
	Tcl_InitHashTable(&cmap->refCounts, TCL_ONE_WORD_KEYS);
	return (Colormap)cmap;
}


// errorExit is from <http://msdn2.microsoft.com/en-us/library/ms680582.aspx>
static void
errorExit(LPTSTR lpszFunction)
{
	// Retrieve the system error message for the last-error code
	LPTSTR	lpMsgBuf;
	LPTSTR	lpDisplayBuf;
	DWORD		err = GetLastError();

	if (err == 0)
	{
		// The function said it failed, but GetLastError says it didn't, so pretend it didn't.
		return;
	}

	FormatMessage(	FORMAT_MESSAGE_ALLOCATE_BUFFER
							| FORMAT_MESSAGE_FROM_SYSTEM
							| FORMAT_MESSAGE_IGNORE_INSERTS,
						0,
						err,
						MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
						(LPTSTR)&lpMsgBuf,
						0,
						0);

	// Display the error message and exit the process
	lpDisplayBuf = LocalAlloc(
							LMEM_ZEROINIT,
							(lstrlen(lpMsgBuf) + lstrlen(lpszFunction) + 40)*sizeof(TCHAR));
	StringCchPrintf(	lpDisplayBuf,
							LocalSize(lpDisplayBuf),
							TEXT("%s failed with error %ld: %s"),
							lpszFunction,
							err,
							lpMsgBuf);
	MessageBox(0, lpDisplayBuf, TEXT("Error"), MB_OK);

	LocalFree(lpMsgBuf);
	LocalFree(lpDisplayBuf);
	ExitProcess(err);
}

#endif

// Called upon system startup to create Ogl command.
int
tk::ogl::init(Tcl_Interp* ti)
{
	M_REQUIRE(ti);

	int major, minor, patchLevel, releaseType;
	Tcl_GetVersion(&major, &minor, &patchLevel, &releaseType);

	if (Tcl_CreateObjCommand(ti, "ogl::create", ogl_objCmd, 0, ogl_objCmdDelete) == 0)
		return TCL_ERROR;

	if (Tcl_PkgProvide(ti, "tkogl", OGL_VERSION) != TCL_OK)
		return TCL_ERROR;

	return TCL_OK;
}


// Call command with ogl widget as only argument
int
ogl_callCallback(Ogl* ogl, Tcl_Obj *cmd)
{
	int		result;
	Tcl_Obj*	objv[3];

	if (cmd == 0 || ogl->widgetCmd == 0)
		return TCL_OK;

	objv[0] = cmd;
	Tcl_IncrRefCount(objv[0]);
	objv[1] = Tcl_NewStringObj(Tcl_GetCommandName(ogl->interp, ogl->widgetCmd), -1);
	Tcl_IncrRefCount(objv[1]);
	objv[2] = 0;
	result = Tcl_EvalObjv(ogl->interp, 2, objv, TCL_EVAL_GLOBAL);
	Tcl_DecrRefCount(objv[1]);
	Tcl_DecrRefCount(objv[0]);

	if (result != TCL_OK)
		Tcl_BackgroundError(ogl->interp);

	return result;
}


// Gets called from Tk_CreateTimerHandler.
static void
ogl_timer(ClientData clientData)
{
	Ogl* ogl = (Ogl*)clientData;

	if (ogl->timerProc)
	{
		if (ogl_callCallback(ogl, ogl->timerProc) != TCL_OK)
		{
			ogl->timerHandler = 0;
			Tcl_BackgroundError(ogl->interp);
		}
		else
		{
			// Re-register this callback since Tcl/Tk timers are "one-shot".
			// That is, after the timer callback is called it not normally
			// called again.  That's not the behavior we want for Ogl.
			ogl->timerHandler = Tcl_CreateTimerHandler(ogl->timerInterval, ogl_timer, (ClientData)ogl);
		}
	}
}


// Bind the OpenGL rendering context to the specified
// Ogl widget.  If given a 0gl argument, then the
// OpenGL context is released without assigning a new one.
static void
ogl_makeCurrent(Ogl const* ogl)
{
#if defined(__WIN32__)

	int res = TRUE;

	if (ogl == 0)
	{
		HDC hdc = wglGetCurrentDC();

		if (hdc != 0)
			res = wglMakeCurrent(hdc, 0);
	}
	else
	{
		res = wglMakeCurrent(ogl->tglGLHdc, ogl->ctx);
	}

	if (!res)
		errorExit(TEXT("wglMakeCurrent"));

#elif defined(__unix__)

	Display* display = ogl ? ogl->display : glXGetCurrentDisplay();

	if (display)
	{
		GLXDrawable drawable = ogl && ogl->tkWin ? Tk_WindowId(ogl->tkWin) : None;
		glXMakeCurrent(display, drawable, drawable ? ogl->ctx : 0);
	}

#elif defined(__MacOSX__)

	if (ogl == 0 || ogl->ctx == 0)
		aglSetCurrentContext(0);
	else
		aglSetCurrentContext(ogl->ctx);

#endif
}


static Bool
ogl_swapInterval(Ogl const* ogl, int interval)
{
#if defined(__MacOSX__)

	GLint swapInterval = interval;
	return aglSetInteger(ogl->ctx, AGL_SWAP_INTERVAL, &swapInterval);

#elif defined(__WIN32__)

	typedef BOOL (WINAPI* BOOLFuncInt)(int);
	typedef char const* (WINAPI* StrFuncHDC)(HDC);

	static BOOLFuncInt swapInterval = 0;
	static BOOL initialized = False;

	if (!initialized) {
		StrFuncHDC getExtensionsString = (StrFuncHDC)wglGetProcAddress("wglGetExtensionsStringARB");

		if (getExtensionsString == 0)
			getExtensionsString = (StrFuncHDC)wglGetProcAddress("wglGetExtensionsStringEXT");

		if (getExtensionsString)
		{
			char const* extensions = getExtensionsString(ogl->tglGLHdc);

			if (strstr(extensions, "WGL_EXT_swap_control") != 0)
				swapInterval = (BOOLFuncInt)wglGetProcAddress("wglSwapIntervalEXT");
		}

		initialized = True;
	}

	return swapInterval ? swapInterval(interval) : False;

#elif defined(__unix__)

	typedef int (*IntFuncInt)(int);

	static IntFuncInt swapInterval = 0;
	static int initialized = False;

	if (!initialized)
	{
		char const* extensions = glXQueryExtensionsString(ogl->display, Tk_ScreenNumber(ogl->tkWin));

		if (strstr(extensions, "GLX_SGI_swap_control") != 0)
			swapInterval = (IntFuncInt)glXGetProcAddressARB((const GLubyte*)"glXSwapIntervalSGI");
		else if (strstr(extensions, "GLX_MESA_swap_control") != 0)
			swapInterval = (IntFuncInt)glXGetProcAddressARB((const GLubyte *)"glXSwapIntervalMESA");

		initialized = True;
	}

	return swapInterval ? swapInterval(interval) == 0 : False;

#endif
}


#if defined(__MacOSX__)

// tell OpenGL which part of the Mac window to render to
static void
setMacBufRect(Ogl* ogl)
{
	GLint				wrect[4];
	Rect				r;
	MacDrawable*	d = ((TkWindow *)ogl->tkWin)->privatePtr;

	// set wrect[0,1] to lower left corner of widget
	wrect[2] = Tk_Width(ogl->tkWin);
	wrect[3] = Tk_Height(ogl->tkWin);
	wrect[0] = d->xOff;

	GetPortBounds(MacOSXGetDrawablePort(ogl), &r);
	wrect[1] = r.bottom - wrect[3] - d->yOff;

	if (ogl->fullscreenFlag)
	{
		aglEnable(ogl->ctx, AGL_FS_CAPTURE_SINGLE);
		aglSetFullScreen(ogl->ctx, 0, 0, 0, 0);
	}
	else
	{
		aglUpdateContext(ogl->ctx);
	}

	aglSetInteger(ogl->ctx, AGL_BUFFER_RECT, wrect);
	aglEnable(ogl->ctx, AGL_BUFFER_RECT);
}

#endif


// Called when the widget's contents must be redrawn.  Basically, we
// just call the user's render callback function.
//
// Note that the parameter type is ClientData so this function can be
// passed to Tk_DoWhenIdle().
static void
ogl_render(ClientData clientData)
{
	Ogl* ogl = (Ogl*)clientData;

	if (ogl->displayProc)
	{
		ogl_makeCurrent(ogl);

		if (ogl_callCallback(ogl, ogl->displayProc) != TCL_OK)
			return Tcl_BackgroundError(ogl->interp);
	}

	ogl->updatePending = False;
}


// See domentation about what can't be changed
static int
ogl_objConfigure(Tcl_Interp* ti, Ogl* ogl, int objc, Tcl_Obj* const* objv)
{
	Tk_SavedOptions savedOptions;

	int		error;
	int		mask;
	int		undoMask		= 0;
	Tcl_Obj*	errorResult	= 0;

	for (error = 0; error <= 1; ++error, mask = undoMask)
	{
		if (error == 0)
		{
			 // Tk_SetOptions parses the command arguments and looks for defaults in the resource database.
			if (Tk_SetOptions(
					ti,
					reinterpret_cast<char*>(ogl),
					ogl->tpg->optionTable,
					objc,
					objv,
					ogl->tkWin,
					&savedOptions,
					&mask) != TCL_OK)
			{
				// previous values are restored, so nothing to do
				return TCL_ERROR;
			}
		}
		else
		{
			// Restore options from saved values
			errorResult = Tcl_GetObjResult(ti);
			Tcl_IncrRefCount(errorResult);
			Tk_RestoreSavedOptions(&savedOptions);
		}

		if (ogl->ident && ogl->ident[0] == '.')
		{
			Tcl_AppendResult(ti, "Can not set ident to a window path name", 0);
			continue;
		}

		if (ogl->fullscreenFlag)
		{
			// override width and height
			ogl->width = WidthOfScreen(Tk_Screen(ogl->tkWin));
			ogl->height = HeightOfScreen(Tk_Screen(ogl->tkWin));
			undoMask |= GEOMETRY_MASK;
		}

		if (mask & GEOMETRY_MASK)
		{
			ogl_worldChanged((ClientData) ogl);
#if OPA
			// Reset width and height so ConfigureNotify event will call reshape callback
			ogl->width = oldWidth;
			ogl->height = oldHeight;
#endif
			undoMask |= GEOMETRY_MASK;
		}

		if (mask & SWAP_MASK)
		{
			if (ogl->ctx)
			{
				// Change existing swap interval
				ogl_makeCurrent(ogl); // TODO: needed?
				ogl_swapInterval(ogl, ogl->swapInterval);
				undoMask |= SWAP_MASK;
			}
		}

		if (mask & FORMAT_MASK)
		{
			if (ogl->ctx)
			{
				// Trying to change existing pixel format/graphics context
				// TODO: (re)create graphics context
				//
				// save old graphics context
				// try to create new one and share display lists
				// if failure, then restore old one
				Tcl_AppendResult(ti, "Unable to change pixel format", 0);
				continue;
			}

			if (ogl->shareContext && ogl->shareList)
			{
				Tcl_AppendResult(ti, "only one of -sharelist and -sharecontext allowed", 0);
				continue;
			}

			// Whether or not the format is okay is figured out when ogl tries to create the window.
			undoMask |= FORMAT_MASK;
		}

		if (mask & TIMER_MASK)
		{
			if (ogl->timerHandler != 0)
				Tcl_DeleteTimerHandler(ogl->timerHandler);

			if (ogl->timerProc)
			{
				ogl->timerHandler = Tcl_CreateTimerHandler(	ogl->timerInterval,
																			ogl_timer,
																			(ClientData)ogl);
			}

			undoMask |= TIMER_MASK;
		}

		break;
	}

	if (error == 0)
	{
		Tk_FreeSavedOptions(&savedOptions);
	}
	else
	{
		Tcl_SetObjResult(ti, errorResult);
		Tcl_DecrRefCount(errorResult);
	}

	return error ? TCL_ERROR : TCL_OK;
}


static int
ogl_objWidget(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj *const* objv)
{
	char const* commands[] =
	{
		"cget", "configure", "extensions",
		"postredisplay", "render",
		"swapbuffers", "makecurrent", "takephoto",
		"loadbitmapfont", "unloadbitmapfont",
		"contexttag", "width", "height",
		0
	};
	enum command
	{
		OGL_CGET, OGL_CONFIGURE, OGL_EXTENSIONS,
		OGL_POSTREDISPLAY, OGL_RENDER,
		OGL_SWAPBUFFERS, OGL_MAKECURRENT, OGL_TAKEPHOTO,
		OGL_LOADBITMAPFONT, OGL_UNLOADBITMAPFONT,
		OGL_USELAYER, OGL_CONTEXTTAG, OGL_WIDTH, OGL_HEIGHT
	};

	Ogl*		ogl		= (Ogl*)clientData;
	int		result	= TCL_OK;
	Tcl_Obj*	objPtr;
	int		index;

	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "command ?arg arg ...?");
		return TCL_ERROR;
	}

	Tk_Preserve((ClientData) ogl);
	result = Tcl_GetIndexFromObj(ti, objv[1], commands, "option", 0, &index);

	switch (index)
	{
		case OGL_CGET:
			if (objc != 3)
			{
				Tcl_WrongNumArgs(ti, 2, objv, "option");
				result = TCL_ERROR;
			}
			else
			{
				objPtr = Tk_GetOptionValue(ti,
													reinterpret_cast<char*>(ogl),
													ogl->tpg->optionTable,
													(objc == 3) ? objv[2] : 0,
													ogl->tkWin);

				if (objPtr == 0)
					result = TCL_ERROR;
				else
					Tcl_SetObjResult(ti, objPtr);
			}
			break;

		case OGL_CONFIGURE:
			if (objc <= 3)
			{
				// Return one item if the option is given,
				// or return all configuration information
				objPtr = Tk_GetOptionInfo(	ti,
													reinterpret_cast<char*>(ogl),
												 	ogl->tpg->optionTable,
													(objc == 3) ? objv[2] : 0,
						 							ogl->tkWin);

				if (objPtr == 0)
					result = TCL_ERROR;
				else
					Tcl_SetObjResult(ti, objPtr);
			}
			else
			{
				// Execute a configuration change
				result = ogl_objConfigure(ti, ogl, objc - 2, objv + 2);
			}
			break;

		case OGL_EXTENSIONS:
			// Return a list of OpenGL extensions available
			if (objc == 2)
			{
				char const*	extensions	= (char const*)glGetString(GL_EXTENSIONS);
				Tcl_Obj*		objPtr		= Tcl_NewStringObj(extensions, -1);
				int			length		= -1;

				// convert to list by asking for its length
				Tcl_ListObjLength(ti, objPtr, &length);
				Tcl_SetObjResult(ti, objPtr);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_POSTREDISPLAY:
			// schedule the widget to be redrawn
			if (objc == 2)
			{
				ogl_postRedisplay(ogl);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_RENDER:
			// force the widget to be redrawn
			if (objc == 2)
			{
				ogl_render((ClientData)ogl);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_SWAPBUFFERS:
			// force the widget to be redrawn
			if (objc == 2)
			{
				tk::ogl::swapBuffers(ogl);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_MAKECURRENT:
			// force the widget to be redrawn
			if (objc == 2)
			{
				ogl_makeCurrent(ogl);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_LOADBITMAPFONT:
		{
			GLuint		fontbase;
			Tcl_Obj*		fontbaseAsTclObject;
			char const*	name						= DEFAULT_FONTNAME;
			char const*	size						= DEFAULT_FONTSIZE;
			char const*	weight					= "*";
			char const*	slant						= "r";
			int			i							= 2;

			for ( ; i < objc ; i++)
			{
				char const* optName = Tcl_GetString(objv[i]);

				if (strncmp (optName, "-family", 7) == 0)
				{
					if (i < objc-1)
						name = Tcl_GetString(objv[++i]);
				}
				else if (strncmp (optName, "-slant", 6) == 0)
				{
					if (i < objc-1)
						slant = Tcl_GetString(objv[++i]);
				}
				else if (strncmp (optName, "-weight", 7) == 0)
				{
					if (i < objc-1)
						weight = Tcl_GetString(objv[++i]);
				}
				else if (strncmp (optName, "-size", 5) == 0)
				{
					if (i < objc-1)
						size = Tcl_GetString(objv[++i]);
				}
				else
				{
					// No option given. The supplied parameter should be a XLFD
					// specification. We pass it over to ogl_loadBitmapFont, where
					// it will be checked for correctness.
					name = Tcl_GetString(objv[i]);
					break;
				}
			}

			fontbase = ogl_loadBitmapFont(ogl, name, size, weight, slant);

			if (fontbase)
			{
				fontbaseAsTclObject = Tcl_NewIntObj(fontbase);
				Tcl_SetObjResult(ti, fontbaseAsTclObject);
				result = TCL_OK;
			} else
			{
				Tcl_AppendResult(ti, "Could not allocate font \"", name, "\"", 0);
				result = TCL_ERROR;
			}
			break;
		}

		case OGL_UNLOADBITMAPFONT:
			if (objc == 3)
			{
				int fontbase;
				result = Tcl_GetIntFromObj(ti, objv[2], &fontbase);
				if (result == TCL_ERROR)
					break;
				ogl_unloadBitmapFont(ogl, fontbase);
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, "fontbase");
				result = TCL_ERROR;
			}
			break;

		case OGL_CONTEXTTAG:
			if (objc == 2)
			{
				Tcl_SetObjResult(ti, Tcl_NewIntObj(ogl_contextTag(ogl)));
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_WIDTH:
			if (objc == 2)
			{
				Tcl_SetObjResult(ti, Tcl_NewIntObj(ogl_width(ogl)));
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;

		case OGL_HEIGHT:
			if (objc == 2)
			{
				Tcl_SetObjResult(ti, Tcl_NewIntObj(ogl_height(ogl)));
			}
			else
			{
				Tcl_WrongNumArgs(ti, 2, objv, 0);
				result = TCL_ERROR;
			}
			break;
	}

	Tk_Release((ClientData)ogl);
	return result;
}


// Called when ogl command is removed from interpreter.
static void
ogl_objCmdDelete(ClientData clientData)
{
	if (clientData != 0)
	{
		ogl_packageGlobals* tpg = (ogl_packageGlobals*)clientData;
		Tk_DeleteOptionTable(tpg->optionTable);
		ckfree((char*)clientData);
	}
}


static int
objCmdError(Tcl_Interp* ti, Ogl* ogl)
{
	Tcl_SavedResult saveError;

	Tcl_SaveResult(ti, &saveError);
	ogl->badWindow = True;
	Tcl_DeleteCommandFromToken(ti, ogl->widgetCmd);
	Tcl_RestoreResult(ti, &saveError);
	Tcl_AppendResult(ti, "\nCouldn't configure ogl widget", 0);

	return TCL_ERROR;
}


// Called when Ogl is executed - creation of a Ogl widget.
// * Creates a new window
// * Creates an 'Ogl' data structure
// * Creates an event handler for this window
// * Creates a command that handles this object
// * Configures this Ogl for the given arguments
static int
ogl_objCmd(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const* objv)
{
	ogl_packageGlobals*	tpg;
	Ogl*						ogl;
	Tk_Window				tkwin;
	Tk_ClassProcs*			procsPtr;

	if (objc <= 1)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "pathName ?options?");
		return TCL_ERROR;
	}

	tpg = (ogl_packageGlobals*)clientData;

	if (tpg == 0)
	{
		Tcl_CmdInfo info;
		char const* name;

		// Initialize the ogl_packageGlobals for this widget the
		// first time a Ogl widget is created.  The globals are
		// saved as our client data.

		tpg = (ogl_packageGlobals*)ckalloc(sizeof(ogl_packageGlobals));
		if (tpg == 0)
			return TCL_ERROR;
		tpg->nextContextTag = 0;
		tpg->optionTable = Tk_CreateOptionTable(ti, optionSpecs);
		tpg->oglHead = 0;
		name = Tcl_GetString(objv[0]);
		Tcl_GetCommandInfo(ti, name, &info);
		info.objClientData = (ClientData) tpg;
		Tcl_SetCommandInfo(ti, name, &info);
	}

	// Create the window.
	tkwin = Tk_CreateWindowFromPath(ti, Tk_MainWindow(ti), Tcl_GetString(objv[1]), 0);
	if (tkwin == 0)
		return TCL_ERROR;

	Tk_SetClass(tkwin, "Ogl");

	// Create Ogl data structure
	ogl = (Ogl*)ckalloc(sizeof(Ogl));
	if (ogl == 0)
		return TCL_ERROR;

	// initialize Ogl data structures values
	ogl->next = 0;
	ogl->ctx = 0;
#if defined(__WIN32__)
	ogl->tglGLHdc = 0;
#endif
	ogl->contextTag = 0;
	ogl->display = Tk_Display(tkwin);
	ogl->tkWin = tkwin;
	ogl->interp = ti;
	ogl->visInfo = 0;
	ogl->updatePending = False;
	ogl->tpg = tpg;
	ogl->clientData = 0;
	// for color index mode photos
	ogl->redMap = ogl->greenMap = ogl->blueMap = 0;
	ogl->mapSize = 0;
	ogl->cursor = None;
	ogl->width = 0;
	ogl->height = 0;
	ogl->setGrid = 0;
	ogl->timerInterval = 0;
	ogl->rgbaRed = 1;
	ogl->rgbaGreen = 1;
	ogl->rgbaBlue = 1;
	ogl->doubleFlag = False;
	ogl->depthFlag = False;
	ogl->depthSize = 1;
	ogl->accumFlag = False;
	ogl->accumRed = 1;
	ogl->accumGreen = 1;
	ogl->accumBlue = 1;
	ogl->accumAlpha = 1;
	ogl->alphaFlag = False;
	ogl->alphaSize = 1;
	ogl->stencilFlag = False;
	ogl->stencilSize = 1;
	ogl->auxNumber = 0;
	ogl->indirect = False;
	ogl->pixelFormat = 0;
	ogl->majorVersion = 1;
	ogl->minorVersion = 0;
	ogl->debugContext = False;
	ogl->swapInterval = 1;
	ogl->multisampleBuffers = 0;
	ogl->multisampleSamples = 2;
	ogl->fullscreenFlag = False;
	ogl->createProc = 0;
	ogl->displayProc = 0;
	ogl->reshapeProc = 0;
	ogl->destroyProc = 0;
	ogl->timerProc = 0;
	ogl->timerHandler = 0;
	ogl->shareList = 0;
	ogl->shareContext = 0;
	ogl->ident = 0;
	ogl->privateCmapFlag = False;
	ogl->badWindow = False;

	// Create command event handler
	ogl->widgetCmd = Tcl_CreateObjCommand(	ti,
														Tk_PathName(tkwin),
														ogl_objWidget,
														(ClientData)ogl,
														ogl_oglCmdDeletedProc);

	// Setup the Tk_ClassProcs callbacks to point at our own window creation
	// function

	procsPtr = (Tk_ClassProcs*)ckalloc(sizeof(Tk_ClassProcs));
	procsPtr->size = sizeof(Tk_ClassProcs);
	procsPtr->createProc = ogl_makeWindow;
	procsPtr->worldChangedProc = ogl_worldChanged;
	procsPtr->modalProc = 0;
	Tk_SetClassProcs(ogl->tkWin, procsPtr, (ClientData) ogl);

	Tk_CreateEventHandler(tkwin, ExposureMask | StructureNotifyMask, ogl_eventProc, (ClientData)ogl);

	// Configure Ogl widget
	if (	Tk_InitOptions(ti, reinterpret_cast<char*>(ogl), tpg->optionTable, tkwin) != TCL_OK
		|| ogl_objConfigure(ti, ogl, objc - 2, objv + 2) != TCL_OK)
	{
		return objCmdError(ti, ogl);
	}

	// If OpenGL window wasn't already created by ogl_objConfigure() we
	// create it now.  We can tell by checking if the OpenGL context has
	// been initialized.
	if (!ogl->ctx)
	{
		Tk_MakeWindowExist(ogl->tkWin);
		if (ogl->badWindow)
			return objCmdError(ti, ogl);
	}

	ogl_makeCurrent(ogl);
	if (ogl->contextTag == 0)
		ogl->contextTag = ++tpg->nextContextTag;

	ogl_swapInterval(ogl, ogl->swapInterval);

	// If defined, call create callback
	if (ogl->createProc)
	{
		if (ogl_callCallback(ogl, ogl->createProc) != TCL_OK)
			return objCmdError(ti, ogl);
	}

#ifdef __MacOSX__
	setMacBufRect(ogl);
#endif

	// If defined, call reshape proc
	if (ogl->reshapeProc)
	{
		if (ogl_callCallback(ogl, ogl->reshapeProc) != TCL_OK)
			return objCmdError(ti, ogl);
	}
	else
	{
		glViewport(0, 0, ogl->width, ogl->height);
	}

	Tcl_AppendResult(ti, Tk_PathName(tkwin), 0);

	// Add to linked list
	addToList(ogl);

	return TCL_OK;
}


#ifdef __WIN32__

# define OGL_CLASS_NAME "Ogl Class"

static Bool oglClassInitialized = False;


static LRESULT CALLBACK
win32WinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	LONG		result;
	Ogl*		ogl			= (Ogl*)GetWindowLongPtr(hwnd, 0);
	WNDCLASS	childClass;

	switch (message) {
		case WM_WINDOWPOSCHANGED:
			// Should be processed by DefWindowProc, otherwise a double buffered
			// context is not properly resized when the corresponding window is
			// resized.
			break;

		case WM_DESTROY:
			if (ogl && ogl->tkWin != 0)
			{
				if (ogl->setGrid > 0)
					Tk_UnsetGrid(ogl->tkWin);
				Tcl_DeleteCommandFromToken(ogl->interp, ogl->widgetCmd);
			}
			break;

		case WM_ERASEBKGND:
			// We clear our own window.
			return 1;

		default:
# if USE_STATIC_LIB
			return TkWinChildProc(hwnd, message, wParam, lParam);
# else
			// OK, since TkWinChildProc is not explicitly exported in the
			// dynamic libraries, we have to retrieve it from the class info
			// registered with windows.
			if (tkWinChildProc == 0)
			{
				GetClassInfo(Tk_GetHINSTANCE(), TK_WIN_CHILD_CLASS_NAME, &childClass);
				tkWinChildProc = childClass.lpfnWndProc;
			}
			return tkWinChildProc(hwnd, message, wParam, lParam);
# endif
	}

	result = DefWindowProc(hwnd, message, wParam, lParam);
	Tcl_ServiceAll();

	return result;
}

#endif


// Window creation function, invoked as a callback from Tk_MakeWindowExist.
// This is called instead of TkpMakeWindow and must always succeed.
static Window
ogl_makeWindow(Tk_Window tkwin, Window parent, ClientData instanceData)
{
	Ogl*				ogl = (Ogl*)instanceData;
	XVisualInfo*	visinfo = 0;
	Display*			dpy;
	Colormap			cmap;
	int				scrnum;
	Window			window = None;
	Bool				contextAttribSuccess = False;

#if defined(__unix__)

	Bool	directCtx = True;
	int	attrib_list[1000];
	int	attrib_count;
	int	dummy;
	XSetWindowAttributes swa;

# define MAX_ATTEMPTS 12
	typedef GLXContext (*CREATECONTEXTATTRIBSARB)(	Display* dpy,
																	GLXFBConfig config,
																	GLXContext share_context,
																	BOOL direct,
																	int const* attrib_list);

	static int dbl_flags[MAX_ATTEMPTS] = { 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1 };

	static CREATECONTEXTATTRIBSARB createContextAttribs;
	GLXFBConfig* fbc = None;
	int fbcCount = 0;

#elif defined(__WIN32__)

	typedef BOOL (WINAPI* ChooseFunc)(HDC, int const*, const FLOAT*, UINT, int*, UINT*);
	typedef char const* (WINAPI* StrFuncHDC)(HDC);
	typedef HGLRC (WINAPI* CREATECONTEXTATTRIBSARB) (HDC, HGLRC, int const*);

	static ChooseFunc choosePixelFormat = 0;
	static CREATECONTEXTATTRIBSARB createContextAttribs;
	static BOOL initialized = False;

	HWND			hwnd;
	HWND			parentWin;
	int			pixelformat;
	HINSTANCE	hInstance;
	WNDCLASS		OglClass;
	UINT			matching;
	float			fAttribs[1] = { 0 };
	int			iAttribs[100];
	int			attrib_count;
	HGLRC			hglrcAttrib = 0;

	PIXELFORMATDESCRIPTOR pfd;

#elif defined(__MacOSX__)

	GLint				attribs[20];
	int				na;
	AGLPixelFormat	fmt;

#endif

	if (ogl->badWindow)
		return TkpMakeWindow((TkWindow*)tkwin, parent);

	dpy = Tk_Display(tkwin);

#if defined(__unix__)

	// Make sure OpenGL's GLX extension supported.
	if (!glXQueryExtension(dpy, &dummy, &dummy))
	{
		Tcl_SetResult(	ogl->interp,
							const_cast<char*>("X server has no OpenGL GLX extension"),
							TCL_STATIC);
		return DUMMY_WINDOW;
	}

	if (ogl->shareContext && findOgl(ogl, ogl->shareContext))
	{
		// share OpenGL context with existing Ogl widget.
		Ogl* shareWith = findOgl(ogl, ogl->shareContext);

		assert(shareWith != 0);
		assert(shareWith->ctx != 0);

		ogl->ctx = shareWith->ctx;
		ogl->contextTag = shareWith->contextTag;
		ogl->visInfo = shareWith->visInfo;
		visinfo = ogl->visInfo;
	}
	else
	{
		if (ogl->pixelFormat)
		{
			XVisualInfo tmplate;
			int count = 1;
			Bool rgbaFlag = True;

			tmplate.visualid = ogl->pixelFormat;
			visinfo = XGetVisualInfo(dpy, VisualIDMask, &tmplate, &count);
			if (visinfo == 0)
			{
				Tcl_SetResult(	ogl->interp,
									const_cast<char*>("couldn't choose pixel format"),
									TCL_STATIC);
				return DUMMY_WINDOW;
			}
			// fill in flags normally passed in that affect behavior.
			glXGetConfig(dpy, visinfo, GLX_RGBA, &rgbaFlag);
			glXGetConfig(dpy, visinfo, GLX_DOUBLEBUFFER, &ogl->doubleFlag);

			M_REQUIRE(rgbaFlag);
		}
		else
		{
			int attempt;

			// It may take a few tries to get a visual.
			for (attempt = 0; attempt < MAX_ATTEMPTS; attempt++)
			{
				attrib_count = 0;

				attrib_list[attrib_count++] = GLX_RED_SIZE;
				attrib_list[attrib_count++] = ogl->rgbaRed;
				attrib_list[attrib_count++] = GLX_GREEN_SIZE;
				attrib_list[attrib_count++] = ogl->rgbaGreen;
				attrib_list[attrib_count++] = GLX_BLUE_SIZE;
				attrib_list[attrib_count++] = ogl->rgbaBlue;

				if (ogl->alphaFlag)
				{
					attrib_list[attrib_count++] = GLX_ALPHA_SIZE;
					attrib_list[attrib_count++] = ogl->alphaSize;
				}

				free(ogl->redMap);
				free(ogl->greenMap);
				free(ogl->blueMap);
				ogl->redMap = ogl->greenMap = ogl->blueMap = 0;
				ogl->mapSize = 0;

				if (ogl->depthFlag)
				{
					attrib_list[attrib_count++] = GLX_DEPTH_SIZE;
					attrib_list[attrib_count++] = ogl->depthSize;
				}

				if (ogl->doubleFlag || dbl_flags[attempt])
				{
					attrib_list[attrib_count++] = GLX_DOUBLEBUFFER;
					attrib_list[attrib_count++] = ogl->doubleFlag;
				}

				if (ogl->stencilFlag)
				{
					attrib_list[attrib_count++] = GLX_STENCIL_SIZE;
					attrib_list[attrib_count++] = ogl->stencilSize;
				}

				if (ogl->accumFlag)
				{
					attrib_list[attrib_count++] = GLX_ACCUM_RED_SIZE;
					attrib_list[attrib_count++] = ogl->accumRed;
					attrib_list[attrib_count++] = GLX_ACCUM_GREEN_SIZE;
					attrib_list[attrib_count++] = ogl->accumGreen;
					attrib_list[attrib_count++] = GLX_ACCUM_BLUE_SIZE;
					attrib_list[attrib_count++] = ogl->accumBlue;

					if (ogl->alphaFlag)
					{
						attrib_list[attrib_count++] = GLX_ACCUM_ALPHA_SIZE;
						attrib_list[attrib_count++] = ogl->accumAlpha;
					}
				}

				if (ogl->multisampleBuffers)
				{
					attrib_list[attrib_count++] = GLX_SAMPLE_BUFFERS_ARB;
					attrib_list[attrib_count++] = ogl->multisampleBuffers;
					attrib_list[attrib_count++] = GLX_SAMPLES_ARB;
					attrib_list[attrib_count++] = ogl->multisampleSamples;
				}

				if (ogl->auxNumber != 0)
				{
					attrib_list[attrib_count++] = GLX_AUX_BUFFERS;
					attrib_list[attrib_count++] = ogl->auxNumber;
				}

				if (ogl->indirect)
					directCtx = False;

				attrib_list[attrib_count++] = None;

				if (!(fbc = glXChooseFBConfig(dpy, Tk_ScreenNumber(tkwin), attrib_list, &fbcCount)))
				{
					fprintf(stderr, "glXChooseFBConfig failed\n");
					break;
				}

				visinfo = glXGetVisualFromFBConfig(dpy, fbc[0]);
				if (visinfo)
					break;	// found a GLX visual!
			}

			ogl->visInfo = visinfo;

			if (visinfo == 0)
			{
				Tcl_SetResult(	ogl->interp,
									const_cast<char*>("couldn't choose pixel format"),
									TCL_STATIC);
				return DUMMY_WINDOW;
			}

			createContextAttribs = (CREATECONTEXTATTRIBSARB)
												glXGetProcAddressARB((const GLubyte*)"glXCreateContextAttribsARB");
			contextAttribSuccess = createContextAttribs ? True : False;
			if (createContextAttribs)
			{
				int attribList[] =
				{
					GLX_CONTEXT_MAJOR_VERSION_ARB, 1,
					GLX_CONTEXT_MINOR_VERSION_ARB, 0,
					GLX_CONTEXT_FLAGS_ARB, 0,
					GLX_CONTEXT_PROFILE_MASK_ARB, 0,
					0
				};
				int contextFlags = 0;

				if (ogl->debugContext)
					contextFlags |= GLX_CONTEXT_DEBUG_BIT_ARB;

				attribList[1] = ogl->majorVersion;
				attribList[3] = ogl->minorVersion;
				attribList[5] = contextFlags;
				attribList[7] = GLX_CONTEXT_CORE_PROFILE_BIT_ARB;

				if (!(ogl->ctx = createContextAttribs(dpy, fbc[0], None, directCtx, attribList)))
					contextAttribSuccess = False;
			}
		}

		if (!contextAttribSuccess)
			ogl->ctx = glXCreateContext(dpy, visinfo, None, directCtx);

		// Create a new OpenGL rendering context.
		if (ogl->shareList)
		{
			// share display lists with existing ogl widget.
			Ogl* shareWith = findOgl(ogl, ogl->shareList);
			GLXContext shareCtx;

			if (shareWith)
			{
				shareCtx = shareWith->ctx;
				ogl->contextTag = shareWith->contextTag;
			}
			else
			{
				shareCtx = None;
			}

			ogl->ctx = glXCreateContext(dpy, visinfo, shareCtx, directCtx);
		}

		if (ogl->ctx == 0)
		{
			Tcl_SetResult(	ogl->interp,
								const_cast<char*>("could not create rendering context"),
								TCL_STATIC);
			return DUMMY_WINDOW;
		}
	}
#endif

#ifdef __WIN32__

	parentWin = Tk_GetHWND(parent);
	hInstance = Tk_GetHINSTANCE();

	if (!oglClassInitialized)
	{
		oglClassInitialized = True;
		oglClass.style = CS_HREDRAW | CS_VREDRAW;
		oglClass.cbClsExtra = 0;
		oglClass.cbWndExtra = sizeof(LONG_PTR);	// to save ogl*
		oglClass.hInstance = hInstance;
		oglClass.hbrBackground = 0;
		oglClass.lpszMenuName = 0;
		oglClass.lpszClassName = OGL_CLASS_NAME;
		oglClass.lpfnWndProc = win32WinProc;
		oglClass.hIcon = 0;
		oglClass.hCursor = 0;

		if (!RegisterClass(&oglClass))
		{
			Tcl_SetResult(ogl->interp, "unable register Ogl window class", TCL_STATIC);
			return DUMMY_WINDOW;
		}
	}

	hwnd = CreateWindow(	OGL_CLASS_NAME,
								0,
								WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
								0,
								0,
								ogl->width,
								ogl->height,
								parentWin,
								0,
								hInstance,
								0);
	SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE);

	ogl->tglGLHdc = GetDC(hwnd);

	pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_SUPPORT_COMPOSITION;
	if (ogl->doubleFlag)
		pfd.dwFlags |= PFD_DOUBLEBUFFER;

	if (ogl->pixelFormat)
	{
		pixelformat = ogl->pixelFormat;
	}
	else
	{
		pfd.cColorBits = ogl->rgbaRed + ogl->rgbaGreen + ogl->rgbaBlue;
		pfd.iPixelType = PFD_TYPE_RGBA;
		// Alpha bitplanes are not supported in the current generic OpenGL
		// implementation, but may be supported by specific hardware devices.
		pfd.cAlphaBits = ogl->alphaFlag ? ogl->alphaSize : 0;
		pfd.cAccumBits = ogl->accumFlag
									? (ogl->accumRed + ogl->accumGreen + ogl->accumBlue + ogl->accumAlpha)
									: 0;
		pfd.cDepthBits = ogl->depthFlag ? ogl->depthSize : 0;
		pfd.cStencilBits = ogl->stencilFlag ? ogl->stencilSize : 0;
		// Auxiliary buffers are not supported in the current generic OpenGL
		// implementation, but may be supported by specific hardware devices.
		pfd.cAuxBuffers = ogl->auxNumber;
		pfd.iLayerType = PFD_MAIN_PLANE;

		attrib_count = 0;
		iAttribs[attrib_count++] = WGL_DRAW_TO_WINDOW_ARB;
		iAttribs[attrib_count++] = GL_TRUE;
		iAttribs[attrib_count++] = WGL_ACCELERATION_ARB;
		iAttribs[attrib_count++] = WGL_FULL_ACCELERATION_ARB;
		iAttribs[attrib_count++] = WGL_RED_BITS_ARB;
		iAttribs[attrib_count++] = ogl->rgbaRed;
		iAttribs[attrib_count++] = WGL_GREEN_BITS_ARB;
		iAttribs[attrib_count++] = ogl->rgbaGreen;
		iAttribs[attrib_count++] = WGL_BLUE_BITS_ARB;
		iAttribs[attrib_count++] = ogl->rgbaBlue;

		if (ogl->alphaFlag)
		{
			iAttribs[attrib_count++] = WGL_ALPHA_BITS_ARB;
			iAttribs[attrib_count++] = ogl->alphaSize;
		}

		if (ogl->depthFlag)
		{
			iAttribs[attrib_count++] = WGL_DEPTH_BITS_ARB;
			iAttribs[attrib_count++] = ogl->depthSize;
		}

		if (ogl->doubleFlag)
		{
			iAttribs[attrib_count++] = WGL_DOUBLE_BUFFER_ARB;
			iAttribs[attrib_count++] = GL_TRUE;
		}

		if (ogl->stencilFlag)
		{
			iAttribs[attrib_count++] = WGL_STENCIL_BITS_ARB;
			iAttribs[attrib_count++] = ogl->stencilSize;
		}

		if (ogl->accumFlag)
		{
			iAttribs[attrib_count++] = WGL_ACCUM_RED_BITS_ARB;
			iAttribs[attrib_count++] = ogl->accumRed;
			iAttribs[attrib_count++] = WGL_ACCUM_GREEN_BITS_ARB;
			iAttribs[attrib_count++] = ogl->accumGreen;
			iAttribs[attrib_count++] = WGL_ACCUM_BLUE_BITS_ARB;
			iAttribs[attrib_count++] = ogl->accumBlue;

			if (ogl->alphaFlag)
			{
				iAttribs[attrib_count++] = WGL_ACCUM_ALPHA_BITS_ARB;
				iAttribs[attrib_count++] = ogl->accumAlpha;
			}
		}

		if (ogl->multisampleBuffers)
		{
			iAttribs[attrib_count++] = WGL_SAMPLE_BUFFERS_ARB;
			iAttribs[attrib_count++] = ogl->multisampleBuffers;
			iAttribs[attrib_count++] = WGL_SAMPLES_ARB;
			iAttribs[attrib_count++] = ogl->multisampleSamples;
		}

		if (ogl->auxNumber != 0)
		{
			iAttribs[attrib_count++] = WGL_AUX_BUFFERS_ARB;
			iAttribs[attrib_count++] = ogl->auxNumber;
		}

		iAttribs[attrib_count] = 0;

		if (!initialized)
		{
			char const*	extensions;
			StrFuncHDC	getExtensionsString;
			HWND			hwnd1;
			HDC			hdc;
			HGLRC			hglrc;
			int			pformat;

			hwnd1 = CreateWindow(OGL_CLASS_NAME,
										"",
										WS_POPUP | WS_DISABLED,
										0,
										0,
										10,
										10,
										0,
										0,
										hInstance,
										0);
			hdc = GetDC(hwnd1);
			pformat = ChoosePixelFormat(hdc, &pfd);
			SetPixelFormat(hdc, pformat, &pfd);

			hglrc = wglCreateContext(hdc);
			if (hglrc)
				wglMakeCurrent(hdc, hglrc);

			getExtensionsString = (StrFuncHDC)wglGetProcAddress("wglGetExtensionsStringARB");
			if (getExtensionsString == 0)
				getExtensionsString = (StrFuncHDC)wglGetProcAddress("wglGetExtensionsStringEXT");

			if (getExtensionsString)
			{
				extensions = getExtensionsString(ogl->tglGLHdc);
				if (strstr(extensions, "WGL_ARB_pixel_format") != 0)
					choosePixelFormat = (ChooseFunc)wglGetProcAddress("wglChoosePixelFormatARB");
			}

			createContextAttribs = (CREATECONTEXTATTRIBSARB)wglGetProcAddress("wglCreateContextAttribsARB");

			initialized = True;
			if (hglrc)
			{
				wglMakeCurrent(0, 0);
				wglDeleteContext(hglrc);
			}
			ReleaseDC(hwnd1, hdc);

			// OPA TODO
			// DestroyWindow(hwnd1);
		}

		// Choose and set the closest available pixel format.
		if (	!choosePixelFormat
			|| !choosePixelFormat(ogl->tglGLHdc, iAttribs, fAttribs, 1, &pixelformat, &matching)
			|| !matching)
		{
			pixelformat = ChoosePixelFormat(ogl->tglGLHdc, &pfd);
		}
		if (!pixelformat)
		{
			Tcl_SetResult(ogl->interp, "Ogl: couldn't choose pixel format", TCL_STATIC);
			return DUMMY_WINDOW;
		}
	}

	if (SetPixelFormat(ogl->tglGLHdc, pixelformat, &pfd) == FALSE)
	{
		Tcl_SetResult(ogl->interp, "couldn't choose pixel format", TCL_STATIC);
		ReleaseDC(hwnd, ogl->tglGLHdc);
		ogl->tglGLHdc = 0;
		DestroyWindow(hwnd);
		return DUMMY_WINDOW;
	}

	// Get the actual pixel format.
	DescribePixelFormat(ogl->tglGLHdc, pixelformat, sizeof(pfd), &pfd);
	if (ogl->pixelFormat)
	{
		// fill in flags normally passed in that affect behavior
		ogl->doubleFlag = pfd.cDepthBits > 0;
		// TODO: set depth flag, and more
	}

	if (ogl->shareContext && findOgl(ogl, ogl->shareContext))
	{
		// share OpenGL context with existing Ogl widget
		Ogl* shareWith = findOgl(ogl, ogl->shareContext);

		assert(shareWith);
		assert(shareWith->ctx);

		ogl->ctx = shareWith->ctx;
		ogl->contextTag = shareWith->contextTag;
		ogl->visInfo = shareWith->visInfo;
		visinfo = ogl->visInfo;
	}
	else
	{
		// Create a new OpenGL rendering context. And check to share lists.

		contextAttribSuccess = createContextAttribs ? True : False;

		if (createContextAttribs)
		{
			int attribList[] =
			{
				WGL_CONTEXT_MAJOR_VERSION_ARB, 1,
				WGL_CONTEXT_MINOR_VERSION_ARB, 0,
				WGL_CONTEXT_FLAGS_ARB, 0,
				WGL_CONTEXT_PROFILE_MASK_ARB, 0,
				0
			};
			int contextFlags = 0;

			if (ogl->debugContext)
				contextFlags |= WGL_CONTEXT_DEBUG_BIT_ARB;

			attribList[1] = ogl->majorVersion;
			attribList[3] = ogl->minorVersion;
			attribList[5] = contextFlags;
			attribList[7] = WGL_CONTEXT_CORE_PROFILE_BIT_ARB;

			if (!(hglrcAttrib = createContextAttribs(ogl->tglGLHdc, 0, attribList)))
				contextAttribSuccess = False;

			wglMakeCurrent(ogl->tglGLHdc, hglrcAttrib);
			ogl->ctx = hglrcAttrib;
		}

		if (!contextAttribSuccess)
			ogl->ctx = wglCreateContext(ogl->tglGLHdc);

		if (ogl->shareList)
		{
			// share display lists with existing ogl widget
			Ogl* shareWith = findOgl(ogl, ogl->shareList);

			if (shareWith)
			{
				if (!wglShareLists(shareWith->ctx, ogl->ctx))
				{
					Tcl_SetResult(ogl->interp, "unable to share display lists", TCL_STATIC);
					ReleaseDC(hwnd, ogl->tglGLHdc);
					ogl->tglGLHdc = 0;
					DestroyWindow(hwnd);
					return DUMMY_WINDOW;
				}

				ogl->contextTag = shareWith->contextTag;
			}
		}

		if (!ogl->ctx)
		{
			Tcl_SetResult(ogl->interp, "could not create rendering context", TCL_STATIC);
			ReleaseDC(hwnd, ogl->tglGLHdc);
			ogl->tglGLHdc = 0;
			DestroyWindow(hwnd);
			return DUMMY_WINDOW;
		}

		// Just for portability, define the simplest visinfo.
		visinfo = (XVisualInfo*)malloc(sizeof(XVisualInfo));
		visinfo->visual = DefaultVisual(dpy, DefaultScreen(dpy));
		visinfo->depth = visinfo->visual->bits_per_rgb;
		ogl->visInfo = visinfo;
	}

	SetWindowLongPtr(hwnd, 0, (LONG_PTR) ogl);

#endif

	// for __MacOSX__, we create the window first, then choose the pixel format

	// find a colormap
	scrnum = Tk_ScreenNumber(tkwin);

#if defined(__unix__)

	cmap = get_rgb_colormap(dpy, scrnum, visinfo, tkwin);

#elif defined(__WIN32__)

	if (pfd.dwFlags & PFD_NEED_PALETTE)
		cmap = win32CreateRgbColormap(pfd);
	else
		cmap = DefaultColormap(dpy, scrnum);

	free(ogl->redMap);
	free(ogl->greenMap);
	free(ogl->blueMap);
	ogl->redMap = ogl->greenMap = ogl->blueMap = 0;
	ogl->mapSize = 0;

#elif defined(__MacOSX__)

	cmap = DefaultColormap(dpy, scrnum);

	free(ogl->redMap);
	free(ogl->greenMap);
	free(ogl->blueMap);
	ogl->redMap = ogl->greenMap = ogl->blueMap = 0;
	ogl->mapSize = 0;

#endif

#if !defined(__MacOSX__)

	// Make sure Tk knows to switch to the new colormap when the cursor is over
	// this window when running in color index mode.
	Tk_SetWindowVisual(tkwin, visinfo->visual, visinfo->depth, cmap);

#endif

#ifdef __WIN32__

	// Install the colormap.
	SelectPalette(ogl->tglGLHdc, ((TkWinColormap*)cmap)->palette, TRUE);
	RealizePalette(ogl->tglGLHdc);

#endif

#if defined(__unix__)

	swa.background_pixmap = None;
	swa.border_pixel = 0;
	swa.colormap = cmap;
	swa.event_mask = ALL_EVENTS_MASK;
	window = XCreateWindow(	dpy,
									parent,
									0,
									0,
									ogl->width,
									ogl->height,
									0,
									visinfo->depth,
									InputOutput,
									visinfo->visual,
									CWBackPixmap | CWBorderPixel | CWColormap | CWEventMask,
									&swa);
	// Make sure window manager installs our colormap.
	XSetWMColormapWindows(dpy, window, &window, 1);

   if (!ogl->doubleFlag)
	{
		int dblFlag;

		// See if we requested single buffering but had to accept a double
		// buffered visual.  If so, set the GL draw buffer to be the front
		// buffer to simulate single buffering.
		if (glXGetConfig(dpy, ogl->visInfo, GLX_DOUBLEBUFFER, &dblFlag))
		{
			if (dblFlag)
			{
				glXMakeCurrent(dpy, window, ogl->ctx);
				glDrawBuffer(GL_FRONT);
				glReadBuffer(GL_FRONT);
			}
		}
	}
#elif defined(__WIN32__)

	window = Tk_AttachHWND(tkwin, hwnd);

#elif defined(__MacOSX__)

		window = TkpMakeWindow((TkWindow*)tkwin, parent);

#endif

	// Request the X window to be displayed.
	XMapWindow(dpy, window);

#if defined(__MacOSX__)

	if (ogl->shareContext && findOgl(ogl, ogl->shareContext))
	{
		// share OpenGL context with existing Ogl widget.
		Ogl* shareWith = findOgl(ogl, ogl->shareContext);

		assert(shareWith);
		assert(shareWith->ctx);

		ogl->ctx = shareWith->ctx;
		ogl->contextTag = shareWith->contextTag;
		ogl->visInfo = shareWith->visInfo;
		visinfo = ogl->visInfo;
	}
	else
	{
		AGLContext shareCtx = 0;

		if (ogl->pixelFormat)
		{
			// fill in RgbaFlag, DoubleFlag
			GLint has_rgba, has_doublebuf;

			fmt = (AGLPixelFormat)ogl->pixelFormat;

			if (	aglDescribePixelFormat(fmt, AGL_RGBA, &has_rgba)
				&& aglDescribePixelFormat(fmt, AGL_DOUBLEBUFFER, &has_doublebuf))
			{
				M_ASSERT(has_rgba);
				ogl->doubleFlag = has_doublebuf ? True : False;
			}
			else
			{
				Tcl_SetResult(ogl->interp, "failed querying pixel format attributes", TCL_STATIC);
				return DUMMY_WINDOW;
			}
		}
		else
		{
			// Need to do this after mapping window, so MacDrawable structure
			// is more completely filled in.
			na = 0;
			attribs[na++] = AGL_MINIMUM_POLICY;
			// ask for hardware-accelerated onscreen
			attribs[na++] = AGL_ACCELERATED;
			attribs[na++] = AGL_NO_RECOVERY;
			attribs[na++] = AGL_RGBA;
			attribs[na++] = AGL_RED_SIZE;
			attribs[na++] = ogl->rgbaRed;
			attribs[na++] = AGL_GREEN_SIZE;
			attribs[na++] = ogl->rgbaGreen;
			attribs[na++] = AGL_BLUE_SIZE;
			attribs[na++] = ogl->rgbaBlue;

			if (ogl->alphaFlag)
			{
				attribs[na++] = AGL_ALPHA_SIZE;
				attribs[na++] = ogl->alphaSize;
			}

			if (ogl->depthFlag)
			{
				attribs[na++] = AGL_DEPTH_SIZE;
				attribs[na++] = ogl->depthSize;
			}

			if (ogl->doubleFlag)
				attribs[na++] = AGL_DOUBLEBUFFER;

			if (ogl->stencilFlag)
			{
				attribs[na++] = AGL_STENCIL_SIZE;
				attribs[na++] = ogl->stencilSize;
			}

			if (ogl->accumFlag)
			{
				attribs[na++] = AGL_ACCUM_RED_SIZE;
				attribs[na++] = ogl->accumRed;
				attribs[na++] = AGL_ACCUM_GREEN_SIZE;
				attribs[na++] = ogl->accumGreen;
				attribs[na++] = AGL_ACCUM_BLUE_SIZE;
				attribs[na++] = ogl->accumBlue;

				if (ogl->alphaFlag)
				{
					attribs[na++] = AGL_ACCUM_ALPHA_SIZE;
					attribs[na++] = ogl->accumAlpha;
				}
			}

			if (ogl->auxNumber != 0)
			{
				attribs[na++] = AGL_AUX_BUFFERS;
				attribs[na++] = ogl->auxNumber;
			}

			attribs[na++] = AGL_NONE;

			if ((fmt = aglChoosePixelFormat(0, 0, attribs)) == 0)
			{
				Tcl_SetResult(ogl->interp, "couldn't choose pixel format", TCL_STATIC);
				return DUMMY_WINDOW;
			}
		}

		// Check whether to share lists.
		if (ogl->shareList)
		{
			// share display lists with existing ogl widget
			Ogl* shareWith = findOgl(ogl, ogl->shareList);

			if (shareWith)
			{
				shareCtx = shareWith->ctx;
				ogl->contextTag = shareWith->contextTag;
			}
		}

		if ((ogl->ctx = aglCreateContext(fmt, shareCtx)) == 0)
		{
			GLenum err = aglGetError();
			char const* msg;

			aglDestroyPixelFormat(fmt);

			switch (err)
			{
				case AGL_BAD_MATCH:
					msg = "unable to share display lists: shared context doesn't match";
					break;

				case AGL_BAD_CONTEXT:
					msg = "unable to share display lists: bad shared context";
					break;

				case AGL_BAD_PIXELFMT:
					msg = "could not create rendering context: bad pixel format";
					break;

				default:
					msg = "could not create rendering context: unknown reason";
					break;
			}

			Tcl_SetResult(ogl->interp, msg, TCL_STATIC);
			return DUMMY_WINDOW;
		}

		aglDestroyPixelFormat(fmt);

		if (!aglSetDrawable(ogl->ctx, ((MacDrawable *) (window))->toplevel->grafPtr))
		{
			aglDestroyContext(ogl->ctx);
			Tcl_SetResult(ogl->interp, "couldn't set drawable", TCL_STATIC);
			return DUMMY_WINDOW;
		}

		// Just for portability, define the simplest visinfo.
		visinfo = (XVisualInfo*)malloc(sizeof(XVisualInfo));
		visinfo->visual = DefaultVisual(dpy, DefaultScreen(dpy));
		visinfo->depth = visinfo->visual->bits_per_rgb;

		Tk_SetWindowVisual(tkwin, visinfo->visual, visinfo->depth, cmap);
	}
#endif

#if defined(__unix__)
	// Check for a single/double buffering snafu.
	{
		int dblFlag;

		if (glXGetConfig(dpy, visinfo, GLX_DOUBLEBUFFER, &dblFlag))
		{
			if (!ogl->doubleFlag && dblFlag)
			{
				// We requested single buffering but had to accept a
				// double buffered visual. Set the GL draw buffer to
				// be the front buffer to simulate single buffering.
				glDrawBuffer(GL_FRONT);
			}
		}
	}
#endif

	return window;
}


//	Add support for setgrid option.
static void
ogl_worldChanged(ClientData instanceData)
{
	Ogl* ogl = (Ogl*)instanceData;

	Tk_GeometryRequest(ogl->tkWin, ogl->width, ogl->height);
	Tk_SetInternalBorder(ogl->tkWin, 0);

	if (ogl->setGrid > 0)
	{
		Tk_SetGrid(	ogl->tkWin,
						ogl->width/ogl->setGrid,
						ogl->height/ogl->setGrid,
						ogl->setGrid,
						ogl->setGrid);
	}
	else
	{
		Tk_UnsetGrid(ogl->tkWin);
	}
}


// Wrap the ckfree macro.
static void
ogl_free(char* clientData)
{
	ckfree(clientData);
}


//	This procedure is invoked when a widget command is deleted.  If
//	the widget isn't already in the process of being destroyed,
//	this command destroys it.
//
// Results:
//	  None.
//
// Side effects:
//	  The widget is destroyed.
static void
ogl_oglCmdDeletedProc(ClientData clientData)
{
	Ogl*			ogl	= (Ogl*)clientData;
	Tk_Window	tkwin	= ogl->tkWin;

	// This procedure could be invoked either because the window was
	// destroyed and the command was then deleted (in which case tkwin
	// is 0) or because the command was deleted, and then this procedure
	// destroys the widget.

	if (tkwin)
		Tk_DeleteEventHandler(tkwin, ExposureMask | StructureNotifyMask, ogl_eventProc, (ClientData)ogl);

	Tk_Preserve((ClientData)ogl);
	Tcl_EventuallyFree((ClientData)ogl, ogl_free);

	if (ogl->destroyProc)
	{
		// call user's cleanup code
		if (ogl_callCallback(ogl, ogl->destroyProc) != TCL_OK)
			return Tcl_BackgroundError(ogl->interp);
	}

	if (ogl->timerProc != 0)
	{
		Tcl_DeleteTimerHandler(ogl->timerHandler);
		ogl->timerHandler = 0;
	}
	if (ogl->updatePending)
	{
		Tcl_CancelIdleCall(ogl_render, (ClientData)ogl);
		ogl->updatePending = False;
	}
	if (ogl->cursor != None)
	{
		Tk_FreeCursor(ogl->display, ogl->cursor);
		ogl->cursor = None;
	}

	// remove from linked list
	removeFromList(ogl);

	ogl->tkWin = 0;

	if (tkwin != 0 && Tk_WindowId(tkwin) != DUMMY_WINDOW)
	{
#if defined(__MacOSX__)

		if (ogl->ctx)
		{
			aglDestroyContext(ogl->ctx);
			ogl->ctx = 0;
		}

#elif defined(__unix__)

		if (ogl->ctx)
		{
			if (findOglWithSameContext(ogl) == 0)
				glXDestroyContext(ogl->display, ogl->ctx);
			ogl->ctx = 0;
		}

#elif defined(__WIN32__)

		if (ogl->ctx)
		{
			if (findOglWithSameContext(ogl) == 0)
				wglDeleteContext(ogl->ctx);
			ogl->ctx = 0;
		}

		if (tkwin && ogl->tglGLHdc)
		{
			HWND hwnd = Tk_GetHWND(Tk_WindowId(tkwin));

			ReleaseDC(hwnd, ogl->tglGLHdc);
			ogl->tglGLHdc = 0;
		}

#endif

		if (ogl->setGrid > 0)
			Tk_UnsetGrid(tkwin);
		Tk_DestroyWindow(tkwin);
	}

	Tk_Release((ClientData)ogl);
}


// This gets called to handle Ogl window configuration events
static void
ogl_eventProc(ClientData clientData, XEvent *eventPtr)
{
	Ogl* ogl = (Ogl*)clientData;

	switch (eventPtr->type)
	{
	  case Expose:
		  if (eventPtr->xexpose.count == 0)
		  {
			  if (!ogl->updatePending && eventPtr->xexpose.window == Tk_WindowId(ogl->tkWin))
				  ogl_postRedisplay(ogl);
		  }
		  break;

	  case ConfigureNotify:
		 if (ogl->width == Tk_Width(ogl->tkWin) && ogl->height == Tk_Height(ogl->tkWin)) {
#ifdef __MacOSX__
			  // Even though the size hasn't changed,
			  // it's position on the screen may have.
			  setMacBufRect(ogl);
#endif
			  break;
		  }

		  ogl->width = Tk_Width(ogl->tkWin);
		  ogl->height = Tk_Height(ogl->tkWin);
		  XResizeWindow(Tk_Display(ogl->tkWin), Tk_WindowId(ogl->tkWin), ogl->width, ogl->height);
#ifdef __MacOSX__
		  setMacBufRect(ogl);
#endif
		  ogl_makeCurrent(ogl);

		  if (ogl->reshapeProc)
		  {
			  if (ogl_callCallback(ogl, ogl->reshapeProc) != TCL_OK)
				  return Tcl_BackgroundError(ogl->interp);
		  }
		  else
		  {
			  glViewport(0, 0, ogl->width, ogl->height);
		  }
		  break;

	  case MapNotify:
#if defined(__MacOSX__)
		  {
			  // See comment for the UnmapNotify case below.
			  AGLDrawable d = MacOSXGetDrawablePort(ogl);

			  // aglSetDrawable is deprecated in OS X 10.5
			  aglSetDrawable(ogl->ctx, d);
			  setMacBufRect(ogl);
		  }
#endif
		  break;

	  case UnmapNotify:
#if defined(__MacOSX__)
		  {
				// For Mac OS X Aqua, Tk subwindows are not implemented as
				// separate Aqua windows.  They are just different regions of
				// a single Aqua window.  To unmap them they are just not drawn.
				// Have to disconnect the AGL context otherwise they will continue
				// to be displayed directly by Aqua.
				aglSetDrawable(ogl->ctx, 0);
		  }
#endif
		  break;

	  case DestroyNotify:
		  if (ogl->tkWin != 0)
		  {
#ifdef __WIN32__
			  HWND hwnd = Tk_GetHWND(Tk_WindowId(ogl->tkWin));

			  // Prevent win32WinProc from calling Tcl_DeleteCommandFromToken a second time.
			  SetWindowLongPtr(hwnd, 0, (LONG_PTR) 0);
#endif
			  if (ogl->setGrid > 0)
				  Tk_UnsetGrid(ogl->tkWin);
			  Tcl_DeleteCommandFromToken(ogl->interp, ogl->widgetCmd);
		  }
		  break;
	}
}


static void
ogl_postRedisplay(Ogl* ogl)
{
	if (!ogl->updatePending)
	{
		ogl->updatePending = True;
		Tk_DoWhenIdle(ogl_render, (ClientData)ogl);
	}
}


Bool
ogl_updatePending(Ogl const* ogl)
{
	return ogl->updatePending;
}


void
tk::ogl::swapBuffers(Context const* ctx)
{
	M_REQUIRE(ctx);

	if (ctx->doubleFlag)
	{
#if defined(__WIN32__)

		int res = SwapBuffers(ctx->tglGLHdc);

		if (!res)
			errorExit(TEXT("SwapBuffers"));

#elif defined(__unix__)

		glXSwapBuffers(Tk_Display(ctx->tkWin), Tk_WindowId(ctx->tkWin));

#elif defined(__MacOSX__)

		aglSwapBuffers(ctx->ctx);

#endif
	}
	else
	{
		glFlush();
	}
}


static int
ogl_width(Ogl const* ogl)
{
	return ogl->width;
}


static int
ogl_height(Ogl const* ogl)
{
	return ogl->height;
}


static int
ogl_contextTag(Ogl const* ogl)
{
	return ogl->contextTag;
}


#define MAX_FONTS 1000
static GLuint listBase[MAX_FONTS];
static GLuint listCount[MAX_FONTS];


// Load the named bitmap font as a sequence of bitmaps in a display list.
// fontname may be one of the predefined fonts like OGL_FONT_MONOSPACE
// or an X font name.
static GLuint
ogl_loadBitmapFont(	Ogl const* ogl,
							char const* fontname,
							char const* fontsize,
							char const* weight,
							char const* slant)
{
	static Bool firstTime = True;

#if defined(__unix__)

	XFontStruct* fontinfo;

#elif defined(__WIN32__)

	FontAttributes	fa;
	XLFDAttributes	xa;
	HFONT				font;
	HFONT				oldFont;
	TEXTMETRIC		tm;

#endif

	int			first;
	int			last;
	int			count;
	GLuint		fontbase;
	char const*	name;
	char			simpleFont[100];
	char			msgStr[512];

	// Initialize the listBase and listCount arrays.
	if (firstTime)
	{
		memset(listBase, 0, sizeof(listBase));
		memset(listCount, 0, sizeof(listCount));
		firstTime = False;
	}

	if (!strchr (fontname, '-'))
	{
		// Font specification does not seem to be in XLFD notation.
		sprintf(simpleFont, "-*-%s-%s-%c-*-*-%s-*-*-*-*-*-*-*", fontname, weight, slant[0], fontsize);
		name = simpleFont;
	}
	else
	{
		name = (char const*)fontname;
	}

	sprintf(msgStr, "FontName: %s\n", name);
	assert(name);

#if defined(__unix__)

	fontinfo = (XFontStruct*)XLoadQueryFont(Tk_Display(ogl->tkWin), name);
	if (!fontinfo)
		return 0;
	first = fontinfo->min_char_or_byte2;
	last = fontinfo->max_char_or_byte2;

	sprintf(msgStr, "Font: (%d, %d)\n", first, last);

#elif defined(__WIN32__)

	if (TCL_OK != FontParseXLFD(name, &fa, &xa))
		return 0;

	font = CreateFont(fa.size,
							0,
							0,
							0,
							fa.weight,
							fa.slant,
							fa.underline,
							fa.overstrike,
							DEFAULT_CHARSET,
							OUT_TT_PRECIS,
							CLIP_DEFAULT_PRECIS,
							ANTIALIASED_QUALITY,
							FF_DONTCARE|DEFAULT_PITCH,
							fa.family);
	if (!font)
		return 0;

	oldFont = SelectObject(ogl->tglGLHdc, font);
	GetTextMetrics(ogl->tglGLHdc, &tm);
	first = tm.tmFirstChar;
	last = tm.tmLastChar;

	sprintf(msgStr, "Font: %s Size: %d (%d, %d)\n", fa.family, fa.size, first, last);

#elif defined(__MacOSX__)

	first = 10;	// don't know how to determine font range on Mac...
	last = 255;

#endif

	count = last - first + 1;
	fontbase = glGenLists((GLuint) (last + 1));

	if (fontbase == 0)
	{
#ifdef __WIN32__
		SelectObject(ogl->tglGLHdc, oldFont);
		DeleteObject(font);
#endif
		return 0;
	}

#if defined(__WIN32__)

	wglUseFontBitmaps(ogl->tglGLHdc, first, count, (int)fontbase + first);
	SelectObject(ogl->tglGLHdc, oldFont);
	DeleteObject(font);

#elif defined(__unix__)

	glXUseXFont(fontinfo->fid, first, count, (int) fontbase + first);

#elif defined(__MacOSX__)

	aglUseFont(ogl->ctx, 1, 0, atoi(fontsize), first, count, fontbase + first);

#endif

	// Record the list base and number of display lists for ogl_unloadBitmapFont().
	{
		int i;

		for (i = 0; i < MAX_FONTS; i++)
		{
			if (listBase[i] == 0)
			{
				listBase[i] = fontbase;
				listCount[i] = last + 1;
				break;
			}
		}
	}

	return fontbase;
}


// Release the display lists which were generated by ogl_loadBitmapFont().
static void
ogl_unloadBitmapFont(Ogl const* ogl, GLuint fontbase)
{
	int i;

	for (i = 0; i < MAX_FONTS; i++)
	{
		if (listBase[i] == fontbase)
		{
			glDeleteLists(listBase[i], listCount[i]);
			listBase[i] = listCount[i] = 0;
			return;
		}
	}
}

#if 0 // unused functions

int
ogl_getOglFromObj(Tcl_Interp* ti, Tcl_Obj* obj, Ogl** oglPtr)
{
	Tcl_Command	oglCmd;
	Tcl_CmdInfo	info;

	oglCmd = Tcl_GetCommandFromObj(ti, obj);

	if (Tcl_GetCommandInfoFromToken(oglCmd, &info) == 0 || info.objProc != ogl_objWidget)
	{
		Tcl_AppendResult(ti, "expected ogl command argument", 0);
		return TCL_ERROR;
	}

	*oglPtr = (Ogl*)info.objClientData;
	return TCL_OK;
}

int
ogl_getOglFromName(Tcl_Interp* ti, char const* cmdName, Ogl* *oglPtr)
{
	Tcl_CmdInfo info;

	if (Tcl_GetCommandInfo(ti, cmdName, &info) == 0 || info.objProc != ogl_objWidget)
	{
		Tcl_AppendResult(ti, "expected ogl command argument", 0);
		return TCL_ERROR;
	}

	*oglPtr = (Ogl*)info.objClientData;
	return TCL_OK;
}

#endif

// vi:set ts=3 sw=3:
