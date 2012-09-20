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

#ifndef _sys_base_included
#define _sys_base_included

#define TCL_PREREQ(maj, min) ((TCL_MAJOR_VERSION << 16) + TCL_MINOR_VERSION >= ((maj) << 16) + (min))

extern "C" { struct Tcl_Interp; }

namespace sys {
namespace tcl {

Tcl_Interp* interp();

} // namespace tcl
} // namespace sys

#include "sys_base.ipp"

#endif // _sys_base_included

// vi:set ts=3 sw=3:
