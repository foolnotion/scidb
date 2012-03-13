// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2012 Gregor Cramer
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

#if !defined(WIN32) && !defined(__MacOSX__)

#ifdef override
# undef override
#endif

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xproto.h>
#include <X11/Xlibint.h>

using namespace tcl;

static Tcl_Command tk_cmd = 0;
static char const* Command = "::scidb::tk::x11";
static XErrorHandler xErrorHandler = 0;


static int
cmdX11(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	char const* Usage =	"Usage: ::scidb::tk::x11 region <x> <y> <photo>";

	if (objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<x> <y> <photo>");
		return TCL_ERROR;
	}

	char const* subcmd = Tcl_GetString(objv[1]);

	if (strcasecmp(subcmd, "region") == 0)
	{
		int x = intFromObj(objc, objv, 2);
		int y = intFromObj(objc, objv, 3);

		Tk_PhotoHandle handle = Tk_FindPhoto(ti, Tcl_GetString(objv[4]));

		if (!handle)
		{
			return error(	::Command, subcmd, 0,
								"invalid argument: '%s' is not a photo image",
								Tcl_GetString(objv[4]));
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
	}
	else
	{
		return error(::Command, subcmd, 0, Usage);
	}

	return TCL_OK;
}


static int
handleXErrorMessage(Display *dpy, XErrorEvent *event)
{
	// a BadWindow due to X_SendEvent is likely due to XDND
	if (event->error_code == BadWindow && event->request_code == X_SendEvent)
		return 0;

	mstl::backtrace bt;
	mstl::ostringstream strm;

	strm.write("\n", 1);
	strm.format("=== Backtrace ============================================\n");
	bt.text_write(strm, 3);
	strm.format("==========================================================\n");
	fprintf(stderr, "%s", strm.str().c_str());

	::xErrorHandler(dpy, event);

	return event->error_code != BadImplementation;
}


void
tk::x11_init(Tcl_Interp* ti)
{
	::xErrorHandler = XSetErrorHandler(handleXErrorMessage);
	tk_cmd = Tcl_CreateObjCommand(ti, ::Command, cmdX11, 0, 0);
}

#else

void tk::x11_init(Tcl_Interp* ti) {}

#endif

// vi:set ts=3 sw=3:
