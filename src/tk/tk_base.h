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
// Copyright: (C) 2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include <tcl.h>
#include <tk.h>

#ifndef _tk_base_included
#define _tk_base_included

namespace tk {

Tk_Window mainWindow();
Tk_Window window(char const* path);
Tk_Window window(Tcl_Obj* path);
Tk_Window parent(Tk_Window window);

bool exists(char const* path);
bool exists(Tcl_Obj* obj);
bool isTopLevel(Tk_Window window);

int width(Tk_Window window);
int height(Tk_Window window);

void makeExists(Tk_Window window);
void resize(Tk_Window window, int width, int height);
void raise(Tk_Window window, Tk_Window aboveThis);
void unmanage(Tk_Window window);
void unmap(Tk_Window window);
void reparent(Tk_Window window, Tk_Window newParent);

bool release(Tk_Window window);
bool capture(Tk_Window tkwin, Tk_Window tkparent);

void createEventHandler(Tk_Window window, unsigned long mask, Tk_EventProc* proc, void* clientData);
void deleteEventHandler(Tk_Window window, unsigned long mask, Tk_EventProc* proc, void* clientData);

} // namespace tk

#include "tk_base.ipp"

#endif // _tk_base_included
// vi:set ts=3 sw=3:
