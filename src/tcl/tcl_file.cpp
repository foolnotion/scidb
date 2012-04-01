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

#include "tcl_file.h"

#include "m_assert.h"

using namespace tcl;


struct File::Cookie
{
	static __ssize_t
	read(void* cookie, char* buf, size_t len)
	{
		return Tcl_Read(static_cast<File*>(cookie)->m_chan, buf, len);
	}

	static int
	seek(void* cookie, __off64_t* pos, int whence)
	{
		return Tcl_Seek(static_cast<File*>(cookie)->m_chan, *pos, whence);
	}

	static int
	close(void* cookie)
	{
		static_cast<File*>(cookie)->m_fp = 0;
		return 0;
	}

	static __ssize_t
	write(void* cookie, char const* buf, size_t len)
	{
		return Tcl_Write(static_cast<File*>(cookie)->m_chan, buf, len);
	}
};


File::File(Tcl_Channel chan)
	:m_chan(chan)
	,m_fp(0)
{
	if (chan)
		open(chan);
}


File::~File() throw()
{
	close();
}


bool
File::isOpen() const
{
	return m_fp != 0;
}


FILE*
File::handle() const
{
	return m_fp;
}


void
File::open(Tcl_Channel chan)
{
	static cookie_io_functions_t Cookie =
	{
		Cookie::read,
		Cookie::write,
		Cookie::seek,
		Cookie::close,
	};

	M_REQUIRE(chan);
	M_REQUIRE(!isOpen());

	m_fp = ::fopencookie(this, "r+", Cookie);
	::setvbuf(m_fp, 0, _IONBF, 0);
}


void
File::flush()
{
	M_REQUIRE(isOpen());
	::fflush(m_fp);
}


void
File::close()
{
	if (m_fp)
	{
		::fclose(m_fp);
printf("File:~File()\n");
		m_fp = 0;
	}
}

// vi:set ts=3 sw=3:
