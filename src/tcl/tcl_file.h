// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_file_included
#define _tcl_file_included

#include "m_stdio.h"

#include <tcl.h>

namespace tcl {

class File
{
public:

	File(Tcl_Channel chan = 0);
	~File() throw();

	bool isOpen() const;

	FILE* handle() const;

	void open(Tcl_Channel chan);
	void flush();
	void close();

private:

	class Cookie;
	friend class Cookie;

	Tcl_Channel	m_chan;
	FILE*			m_fp;
};

} // namespace tcl

#endif // _tcl_file_included

// vi:set ts=3 sw=3:
