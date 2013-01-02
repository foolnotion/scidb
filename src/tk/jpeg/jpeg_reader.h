// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _jpeg_reader_included
#define _jpeg_reader_included

#include <stddef.h>

namespace JPEG {

struct Reader
{
	virtual ~Reader();

	virtual void attach();
	virtual void detach();

	virtual size_t read(unsigned char* buf, size_t len) = 0;
	virtual bool skip(size_t nbytes) = 0;
};

} // namespace JPEG

#endif // _jpeg_reader_included

// vi:set ts=3 sw=3:
