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

#ifndef _jpeg_exception_defined
#define _jpeg_exception_defined

namespace JPEG {

class Exception
{
public:

	Exception(char const* fmt, ...) __attribute__((__format__(__printf__, 2, 3)));
	Exception(Exception const& exc);
	~Exception() throw();

	char const* what (void) const throw();

private:

	char* m_msg;
};

} // namespace JPEG

#endif // _jpeg_exception_defined

// vi:set ts=3 sw=3:
