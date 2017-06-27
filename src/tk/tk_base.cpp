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
// Copyright: (C) 2010-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_base.h"

#include "tcl_exception.h"

#include <tkInt.h>


extern "C" { void TkpWmSetState(TkWindow* winPtr, int state); }


static void
reparent(TkWindow* childPtr, TkWindow* newParentPtr = nullptr)
{
	M_ASSERT(childPtr);
	M_ASSERT(childPtr->window);
	M_ASSERT(!newParentPtr || newParentPtr->window);

#if defined(__WIN32__) || defined(__WIN64__)

	// Reparent to nullptr so UpdateWrapper won't delete our original parent window
	HWND handle = newParentPtr ? TkWinGetHWND(newParentPtr->window) : None;
	SetParent(TkWinGetHWND(winPtr->window), hwnd);

#elif defined(__MacOSX__)

# error "not yet implemented"

#else // if defined(__unix__)

	Window parent = newParentPtr ?
		newParentPtr->window : XRootWindow(childPtr->display, childPtr->screenNum);
	XReparentWindow(childPtr->display, childPtr->window, parent, 0, 0);

#endif
}


static void
unlinkWindow(TkWindow* winPtr)
{
	M_ASSERT(winPtr);

	if (!winPtr->parentPtr)
		return;

	TkWindow* prevPtr = winPtr->parentPtr->childList;

	if (prevPtr == winPtr)
	{
		if (!(winPtr->parentPtr->childList = winPtr->nextPtr))
			winPtr->parentPtr->lastChildPtr = nullptr;
	}
	else
	{
		for ( ; prevPtr->nextPtr != winPtr; prevPtr = prevPtr->nextPtr)
			M_ASSERT(prevPtr);

		if (!(prevPtr->nextPtr = prevPtr->nextPtr->nextPtr))
			winPtr->parentPtr->lastChildPtr = prevPtr;
	}

	winPtr->nextPtr = nullptr;
}


static void
linkWindow(TkWindow* winPtr)
{
	M_ASSERT(winPtr);

	if (!winPtr->parentPtr)
		return;

	TkWindow* parent = winPtr->parentPtr;

	if (TkWindow* prevPtr = parent->childList)
	{
		while (prevPtr->nextPtr)
			prevPtr = prevPtr->nextPtr;

		prevPtr->nextPtr = winPtr;
	}
	else
	{
		parent->childList = winPtr;
	}

	winPtr->nextPtr = nullptr;
	parent->lastChildPtr = winPtr;
}


static void
relink(TkWindow* childPtr, TkWindow* newParentPtr)
{
	M_ASSERT(childPtr);
	M_ASSERT(newParentPtr);
	M_ASSERT(childPtr->parentPtr != newParentPtr);

	unlinkWindow(childPtr);
	childPtr->parentPtr = newParentPtr;
	linkWindow(childPtr);
}


Tk_Window
tk::mainWindow()
{
	Tk_Window w = Tk_MainWindow(::tcl::interp());

	if (!w)
		M_THROW(tcl::Exception("no main window exists"));
	
	return w;
}


Tk_Window
tk::window(char const* path)
{
	M_REQUIRE(path);

	Tk_Window w = Tk_NameToWindow(::tcl::interp(), path, mainWindow());

	if (!w)
		M_THROW(tcl::Exception("invalid window '%s'", path));
	
	return w;
}


void
tk::raise(Tk_Window window, Tk_Window aboveThis)
{
	M_REQUIRE(window);
	M_REQUIRE(aboveThis);

	if (Tk_RestackWindow(window, Above, aboveThis) != TCL_OK)
	{
		M_THROW(tcl::Exception(
			"can't raise \"%s\" above \"%s\"",
			Tk_PathName(window),
			Tk_PathName(aboveThis)));
	}
}


void
tk::reparent(Tk_Window child, Tk_Window newParent)
{
	M_REQUIRE(child);
	M_REQUIRE(newParent);
	M_ASSERT(parent(child) != newParent);

	TkWindow* childPtr	= reinterpret_cast<TkWindow*>(child);
	TkWindow* parentPtr	= reinterpret_cast<TkWindow*>(newParent);

	if (parentPtr->window == None)
		unmap(child);
	
	::relink(childPtr, parentPtr);

	if (childPtr->window != None && parentPtr->window != None)
		::reparent(childPtr, parentPtr);
}


bool
tk::release(Tk_Window window)
{
	M_REQUIRE(window);

	if (isTopLevel(window))
		return false;

	// detach the window from its gemoetry manager, if any
	unmanage(window);

	TkWindow* winPtr = reinterpret_cast<TkWindow*>(window);

	// TkFocusSplit(winPtr); // has hidden scope
	// We hope that this toplevel don't has a focus record.

	if (winPtr->window == None)
	{
		// The window is not created yet, we still have time
		// to make it an legitimate toplevel window.
		winPtr->dirtyAtts |= CWBorderPixel;
	}
	else
	{
		if (winPtr->flags & TK_MAPPED)
			unmap(window);

		::reparent(winPtr);
	}

	winPtr->flags |= TK_TOP_HIERARCHY | TK_TOP_LEVEL | TK_HAS_WRAPPER | TK_WIN_MANAGED;

	TkWmNewWindow(winPtr);
	TkpWmSetState(winPtr, WithdrawnState);

	// Size was set - force a call to Geometry Manager
	winPtr->reqWidth++;
	winPtr->reqHeight++;
	Tk_GeometryRequest(window, winPtr->reqWidth - 1, winPtr->reqHeight - 1);
	//Tk_GeometryRequest(mainWindow(), winPtr->reqWidth - 1, winPtr->reqHeight - 1);

	TkWmMapWindow(winPtr);

	return true;
}


bool
tk::capture(Tk_Window tkwin, Tk_Window tkparent)
{
	TkWindow* winPtr = reinterpret_cast<TkWindow*>(tkwin);

	if (!winPtr->parentPtr)
		return false;

	if (!(winPtr->flags & TK_TOP_LEVEL))
		return true; // window is already captured

	// withdraw the window
	TkpWmSetState(winPtr, WithdrawnState);

	if (tkparent && tkparent != reinterpret_cast<Tk_Window>(winPtr->parentPtr))
		::relink(winPtr, reinterpret_cast<TkWindow*>(tkparent));

	if (winPtr->window == None)
	{
		// cause this and parent window to exist
		winPtr->atts.event_mask &= ~StructureNotifyMask;
		winPtr->flags &= ~TK_TOP_LEVEL;
	}
	else
	{
		XSetWindowAttributes atts;

#ifdef __WIN32__

		// SetParent must be done before TkWmDeadWindow or it's DestroyWindow on the
		// parent Hwnd will also destroy the child
		makeExists(reinterpret_cast<Tk_Window>(winPtr->parentPtr));
		::reparent(winPtr, winPtr->parentPtr);
		// Dis-associate from wm
		TkWmDeadWindow(winPtr);

#elif defined(__MacOSX__)

# error "not yet implemented"

#else // if defined(__unix__)

		TkWmDeadWindow(winPtr);
		XUnmapWindow(winPtr->display, winPtr->window);
		makeExists(reinterpret_cast<Tk_Window>(winPtr->parentPtr));
		::reparent(winPtr, winPtr->parentPtr);

#endif

		// clear those attributes that non-toplevel windows don't possess
		winPtr->flags &= ~(TK_TOP_HIERARCHY | TK_TOP_LEVEL | TK_HAS_WRAPPER | TK_WIN_MANAGED);
		atts.event_mask = winPtr->atts.event_mask;
		atts.event_mask &= ~StructureNotifyMask;
		Tk_ChangeWindowAttributes(tkwin, CWEventMask, &atts);
	}

	unmanage(tkwin);

	// Can't delete the TopLevelEventProc, because this definition only exists
	// in tkWinWm.c or tkUnixWm.c. Is having this event handler around really cause
	// a problem?
//	Tk_DeleteEventHandler(tkwin, StructureNotifyMask, TopLevelEventProc, winPtr);

	return true;
}

// vi:set ts=3 sw=3:
