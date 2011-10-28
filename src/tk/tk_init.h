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

#ifndef _tk_init_defined
#define _tk_init_defined

extern "C" { struct Tcl_Interp; }

namespace tk { void init(Tcl_Interp* ti); }

// internally used
namespace tk {

void image_init(Tcl_Interp*);
void jpeg_init(Tcl_Interp*);
void png_init(Tcl_Interp*);
void gif_init(Tcl_Interp*);
void window_manager_init(Tcl_Interp*);
void twm_init(Tcl_Interp*);
void xcursor_init(Tcl_Interp*);
void busy_init(Tcl_Interp*);
void multiwindow_init(Tcl_Interp*);

}

#endif // _tk_init_defined

// vi:set ts=3 sw=3:
