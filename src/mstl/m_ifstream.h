// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _mstl_ifstream_included
#define _mstl_ifstream_included

#include "m_istream.h"
#include "m_file.h"

namespace mstl {

class ifstream : public istream, virtual protected bits::file
{
public:

	ifstream();
	explicit ifstream(char const* filename, openmode mode = in);
	explicit ifstream(int fd, openmode mode = in);
	explicit ifstream(struct _IO_FILE* fp, openmode mode = in);
	~ifstream() throw();

	using file::is_open;
	using file::is_buffered;
	using file::is_unbuffered;

	using file::size;
	using file::bufsize;
	using file::buffer;
	using file::mtime;
	using file::filename;

	virtual void open(char const* filename);
	virtual void open(char const* filename, openmode mode);
	void open(int fd, openmode mode = in);
	void open(struct _IO_FILE* fp, openmode mode = in);
	using file::close;

	using file::set_unbuffered;
	using file::set_line_buffered;
	using file::set_binary;
	using file::set_text;
	using file::set_bufsize;
};

extern ifstream cin;

} // namespace mstl

#endif // _mstl_ifstream_included

// vi:set ts=3 sw=3:
