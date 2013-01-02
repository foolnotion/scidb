// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_pipe.h"

#include "m_assert.h"

#include <tcl.h>

using namespace sys::pipe;


static void
action(ClientData data, int mask)
{
	M_ASSERT(mask == TCL_READABLE);

	char c;

	if (Tcl_Read(reinterpret_cast<Pipe*>(data)->channel(), &c, 1) != -1)
		reinterpret_cast<Pipe*>(data)->available(c);
}


Pipe::Pipe() :m_chan(makeChannel(createPipe())) {}

bool Pipe::isClosed() const { return m_chan == 0; }
Tcl_Channel Pipe::channel() { return m_chan; }


Pipe::~Pipe() throw()
{
	Tcl_DeleteChannelHandler(m_chan, action, this);
	close();
}


Tcl_Channel
Pipe::makeChannel(int fd)
{
	Tcl_Channel chan = Tcl_MakeFileChannel(reinterpret_cast<ClientData>(fd), TCL_READABLE);

	Tcl_CreateChannelHandler(chan, TCL_READABLE, action, this);
	Tcl_SetChannelOption(0, chan, "-blocking", "no");
	Tcl_SetChannelOption(0, chan, "-encoding", "binary");
	Tcl_SetChannelOption(0, chan, "-translation", "binary binary");

	return chan;
}


void
Pipe::close()
{
	if (m_chan)
	{
		Tcl_Close(0, m_chan);
		m_chan = 0;
		closeHandles();
		m_fd[0] = m_fd[1] = -1;
	}
}


#ifdef __WIN32__

# include <windows.h>
# include <io.h>

int
Pipe::createPipe()
{
	if (::_pipe(m_fd, 256, _O_BINARY) == -1)
		M_RAISE("pipe() failed");

	return get_osfhandle(m_fd[0]);
}

#elif defined(__unix__) || defined(__MacOSX__)

# include <unistd.h>

int
Pipe::createPipe()
{
	if (::pipe(m_fd) == -1)
		M_RAISE("pipe() failed");

	return m_fd[0];
}

#else

# error "Unsupported platform"

#endif

void
Pipe::send(unsigned char c)
{
	M_REQUIRE(!isClosed());
	::write(m_fd[1], &c, 1);
}


void
Pipe::closeHandles()
{
	::close(m_fd[0]);
	::close(m_fd[1]);
}

// vi:set ts=3 sw=3:
