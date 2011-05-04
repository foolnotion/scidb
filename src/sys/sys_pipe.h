// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _sys_pipe_included
#define _sys_pipe_included

extern "C" { struct Tcl_Channel_; };

namespace sys {
namespace pipe {

class Pipe
{
public:

	Pipe();
	virtual ~Pipe() throw();

	bool isClosed() const;

	virtual void available(unsigned char c) = 0;
	void send(unsigned char c);

	struct Tcl_Channel_* channel();

	void close();

private:

	struct Tcl_Channel_* makeChannel(int fd);
	int createPipe();
	void closeHandles();

	int m_fd[2];
	struct Tcl_Channel_* m_chan;
};

} // namespace pipe
} // namespace sys

#endif // _sys_pipe_included

// vi:set ts=3 sw=3:
