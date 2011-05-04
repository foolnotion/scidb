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

#ifndef _tcl_exception_included
#define _tcl_exception_included

#include "u_exception.h"

#define TCL_RAISE(fmt,args...) M_THROW(::tcl::Exception(fmt,##args))

namespace tcl {

class Exception : public util::Exception
{
public:

	// structors
	Exception();
	explicit Exception(char const* fmt, ...) __attribute__((__format__(__printf__, 2, 3)));
	Exception(util::Exception& exc);
	~Exception() throw();
};

} // namespace tcl

#endif // _tcl_exception_included

// vi:set ts=3 sw=3:
