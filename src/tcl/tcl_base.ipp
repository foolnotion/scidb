// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include <string.h>

namespace tcl { namespace bits { extern Tcl_Interp* interp; } }

inline Tcl_Interp* tcl::interp() { return bits::interp; }

inline
bool
tcl::equal(char const* lhs, char const* rhs)
{
	return ::strcmp(lhs, rhs) == 0;
}

// vi:set ts=3 sw=3:
