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

#ifndef _svg_exception_defined
#define _svg_exception_defined

#include "m_exception.h"

#define SVG_RAISE(fmt,args...) M_THROW(::svg::exception(fmt,##args))

namespace svg {

class exception : public mstl::exception
{
public:

	exception(char const* fmt, ...) __attribute__((__format__(__printf__, 2, 3)));
	exception(exception const& exc);
};

} // namespace svg

#endif // _svg_exception_defined

// vi:set ts=3 sw=3:
