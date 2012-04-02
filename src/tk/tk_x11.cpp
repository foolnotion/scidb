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

#include "m_utility.h"
#include "m_backtrace.h"
#include "m_sstream.h"

#include <tcl.h>
#include <tk.h>
#include <string.h>
#include <stdio.h>

#if defined(__unix__) && !defined(__MacOSX__)

#ifdef override
# undef override
#endif

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xproto.h>
#include <X11/Xlibint.h>

using namespace tcl;

static char const* Command = "::scidb::tk::x11";
static XErrorHandler xErrorHandler = 0;


static int
getRegion(char const* subcmd, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	int x = intFromObj(objc, objv, 0);
	int y = intFromObj(objc, objv, 1);

	Tk_PhotoHandle handle = Tk_FindPhoto(ti, Tcl_GetString(objv[2]));

	if (!handle)
	{
		return error(	::Command, subcmd, 0,
							"invalid argument: '%s' is not a photo image",
							Tcl_GetString(objv[2]));
	}

	int width, height;
	Tk_PhotoGetSize(handle, &width, &height);

	if (x < 0) { width  += x; x = 0; }
	if (y < 0) { height += y; y = 0; }

	Tk_Window	tkmain		= Tk_MainWindow(ti);
	Display*		display		= Tk_Display(tkmain);
	Window		rootWindow	= XRootWindow(display, Tk_ScreenNumber(tkmain));
	XImage*		ximage		= 0;

	XWindowAttributes attribs;

	if (	XGetWindowAttributes(display, rootWindow, &attribs)
		&& attribs.visual->bits_per_rgb == 8
		&& attribs.visual->c_class == TrueColor)
	{
		if (attribs.width - x < width)
			width = attribs.width - x;
		if (attribs.height - y < height)
			height = attribs.height - y;

		if (width > 0 && height > 0)
		{
#if 0
			while (true)
			{
				while (Tcl_DoOneEvent(TCL_IDLE_EVENTS))
					continue;

				XSync(display, False);

				if (!Tcl_DoOneEvent(TCL_IDLE_EVENTS))
					break;
			}
#endif

			ximage = XGetImage(display, rootWindow, x, y, width, height, AllPlanes, ZPixmap);

			Tk_PhotoImageBlock block;

			block.pixelSize = ximage->bits_per_pixel/8;
			block.pitch = ximage->bytes_per_line;
			block.pixelPtr = reinterpret_cast<unsigned char*>(ximage->data);
			block.width = width;
			block.height = height;
			block.offset[0] = 0;
			block.offset[1] = 1;
			block.offset[2] = 2;
			block.offset[3] = 3;

			if (ximage->blue_mask == 0xff)
				mstl::swap(block.offset[0], block.offset[2]);

			if (block.pixelSize == 4)
			{
				unsigned size = ximage->bytes_per_line*height;
				block.pixelPtr = new unsigned char[size];
				::memcpy(block.pixelPtr, ximage->data, size);

				for (int r = 0; r < height; ++r)
				{
					unsigned char* p = block.pixelPtr + r*ximage->bytes_per_line;
					unsigned char* e = p + ximage->bytes_per_line;

					for (; p < e; p += 4)
						p[3] = 255;
				}
			}

			Tk_PhotoPutBlock(ti, handle, &block, 0, 0, width, height, TK_PHOTO_COMPOSITE_SET);
			if (static_cast<void*>(ximage->data) != static_cast<void*>(block.pixelPtr))
				delete [] block.pixelPtr;
			XDestroyImage(ximage);
		}
	}

	Tcl_SetObjResult(ti, Tcl_NewBooleanObj(ximage != 0));
	return TCL_OK;
}


static int
cmdX11(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "region", 0 };
	struct { char const* usage; int min_args; } const definitions[] = { { "region <x> <y> <photo>", 4 } };
	enum { Cmd_Region };

	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "subcommand ?options?");
		return TCL_ERROR;
	}

	int index;
	int result = Tcl_GetIndexFromObj(ti, objv[1], subcommands, "subcommand", TCL_EXACT, &index);

	if (result != TCL_OK)
		return TCL_ERROR;

	if (objc < definitions[index].min_args)
	{
		Tcl_WrongNumArgs(ti, 1, objv, definitions[index].usage);
		return TCL_ERROR;
	}

	objv += 2;
	objc -= 2;

	switch (index)
	{
		case Cmd_Region:
			return getRegion(subcommands[index], ti, objc, objv);
	}

	return TCL_OK;
}


static int
handleXErrorMessage(Display* dpy, XErrorEvent* event)
{
	// A BadWindow due to X_SendEvent is likely due to XDND, for example if
	// the source application is crashing.
	if (	event->error_code == BadWindow
		&& (event->request_code == X_SendEvent || event->request_code == X_GetProperty))
	{
		return 0;
	}

	mstl::backtrace bt;
	mstl::ostringstream strm;

	strm.write("\n", 1);
	strm.format("=== Backtrace ============================================\n");
	bt.text_write(strm, 3);
	strm.format("==========================================================\n");
	fprintf(stderr, "%s", strm.str().c_str());

	xErrorHandler(dpy, event);

	return event->error_code != BadImplementation;
}


void
tk::x11_init(Tcl_Interp* ti)
{
	::xErrorHandler = XSetErrorHandler(handleXErrorMessage);
	Tcl_CreateObjCommand(ti, ::Command, cmdX11, 0, 0);
}

#else

void tk::x11_init(Tcl_Interp* ti) {}

#endif

// vi:set ts=3 sw=3:
