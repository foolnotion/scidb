// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_process.h"
#include "sys_base.h"

#include "tcl_exception.h"
#include "tcl_base.h"

#include "m_string.h"

#include <tcl.h>
#include <stdlib.h>

#define DEBUG

#ifdef DEBUG
# include <stdio.h>
# undef DEBUG
# define DEBUG(x) x
#else
# define DEBUG(x)
#endif

using namespace sys;


namespace {

#ifdef __WIN32__

# include <windows.h>


static Process::Priority
priority(DWORD pid)
{
	HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, false, pid);

	if (!hProcess)
		return Unknown;

	unsigned priorityClass = GetPriorityClass(hProcess);

	CloseHandle(hProcess);

	switch (priorityClass)
	{
		case NORMAL_PRIORITY_CLASS:	return Normal;
		case IDLE_PRIORITY_CLASS:		return Idle;
		case HIGH_PRIORITY_CLASS:		return High;
	}

	return Unknown;
}


static bool
setPriority(DWORD pid, Priority priority)
{
	HANDLE hProcess = OpenProcess(PROCESS_SET_INFORMATION, false, pid);

	if (!hProcess)
		return false;

	unsigned priorityClass;

	switch (priority)
	{
		case Normal:	priorityClass = NORMAL_PRIORITY_CLASS; break;
		case Idle:		priorityClass = IDLE_PRIORITY_CLASS; break;
		case High:		priorityClass = HIGH_PRIORITY_CLASS; break;
		case Unknown:	return false;
	}

	SetPriorityClass(hProcess, priorityClass);
	CloseHandle(hProcess);

	return true;
}

#else

# include <sys/resource.h>
# include <errno.h>


static Process::Priority
getPriority(int pid)
{
	errno = 0;
	return Process::Priority(getpriority(PRIO_PROCESS, pid));
}


static bool
setPriority(int pid, Process::Priority priority)
{
	return setpriority(PRIO_PROCESS, pid, priority) == 0;
}

#endif


struct DString
{
	Tcl_DString str;

	DString()	{ Tcl_DStringInit(&str); }
	~DString()	{ Tcl_DStringFree(&str); }

	operator Tcl_DString* ()	{ return &str; }
	operator char const* ()		{ return Tcl_DStringValue(&str); }
	operator bool ()				{ return Tcl_DStringLength(&str) > 0; }

	int length()					{ return Tcl_DStringLength(&str); }
};

} // namespace


static void
closeHandler(ClientData clientData)
{
	reinterpret_cast<Process*>(clientData)->exited();
}


static void
readHandler(ClientData clientData, int)
{
	reinterpret_cast<Process*>(clientData)->readyRead();
}


Process::Process(mstl::string const& command, mstl::string const& directory)
	:m_chan(0)
	,m_pid(-1)
{
	DString cmd, dir, cwd;

	Tcl_TranslateFileName(::sys::tcl::interp(), command, cmd);
	Tcl_TranslateFileName(::sys::tcl::interp(), directory, dir);

	if (!directory.empty() && Tcl_GetCwd(::sys::tcl::interp(), cwd) && cwd)
		Tcl_Chdir(dir);

	char const* argv[1] = { command.c_str() };

	m_chan = Tcl_OpenCommandChannel(	::sys::tcl::interp(),
												1, argv,
												TCL_STDIN | TCL_STDOUT | TCL_STDERR | TCL_ENFORCE_MODE);

	if (cwd)
		Tcl_Chdir(cwd);

	if (!m_chan)
		TCL_RAISE("cannot create process: %s", Tcl_PosixError(::sys::tcl::interp()));

	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-buffering", "none"); // XXX instead of "line"
	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-blocking", "no");
	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-encoding", "binary");
	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-translation", "binary binary");
	Tcl_RegisterChannel(::sys::tcl::interp(), m_chan);

#ifdef Tcl_PidObjCmd__is_not_hidden

	extern "C" { int Tcl_PidObjCmd(ClientData, Tcl_Interp*, int, Tcl_Obj* const[]); }

	Tcl_Obj* channelName = Tcl_NewStringObj(Tcl_GetChannelName(m_chan), -1);
	Tcl_IncrRefCount(channelName);
	m_pid = Tcl_PidObjCmd(0, ::sys::tcl::interp(), 1, &channelName);
	Tcl_DecrRefCount(channelName);

#else

	char const*	pidCmd = "::pid";
	Tcl_Obj*		result = 0;

	try
	{
		result = ::tcl::call(__func__, pidCmd, Tcl_GetChannelName(m_chan), 0);
	}
	catch (::tcl::Error const&)
	{
	}

	if (result == 0)
		TCL_RAISE("tcl::invoke(\"%s %s\") failed", pidCmd, Tcl_GetChannelName(m_chan));

	if (Tcl_GetLongFromObj(::sys::tcl::interp(), result, &m_pid) != TCL_OK)
	{
		TCL_RAISE(	"%s should return long (instead of '%s')",
						pidCmd,
						Tcl_GetString(result));
	}

#endif

	Tcl_CreateChannelHandler(m_chan, TCL_READABLE, ::readHandler, this);
	Tcl_CreateCloseHandler(m_chan, ::closeHandler, this);
}


Process::~Process() throw()
{
	kill();
}


bool
Process::isAlive() const
{
	return m_chan && Tcl_Eof(m_chan) == 0;
}


Process::Priority
Process::priority() const
{
	if (!isAlive())
		return Unknown;

	return ::getPriority(m_pid);
}


void
Process::setPriority(Priority priority)
{
	if (isAlive())
	{
		if (!::setPriority(m_pid, priority))
			TCL_RAISE("setPriority() failed");
	}
}


int
Process::gets(mstl::string& result)
{
	if (!isAlive())
		return -1;

	char buf[2048];

	int bytesRead = Tcl_Read(m_chan, buf, sizeof(buf));

	if (bytesRead == -1)
	{
		if (!isAlive())
			return -1;

		Tcl_ResetResult(::sys::tcl::interp());
		Tcl_AppendResult(::sys::tcl::interp(), "read error occured: ");
		Tcl_AppendResult(::sys::tcl::interp(), Tcl_PosixError(::sys::tcl::interp()));
		Tcl_BackgroundError(::sys::tcl::interp());

		DEBUG(fprintf(	stderr,
							"%s: read error occurred (%s)",
							__func__,
							Tcl_PosixError(::sys::tcl::interp())));

		kill();
	}

	result.assign(static_cast<char const*>(buf), bytesRead);

	return bytesRead;
}


int
Process::puts(mstl::string const& msg)
{
	if (!isAlive())
		return -1;

	if (msg.empty())
		return 0;

	int bytesWritten = write(msg.c_str(), msg.size());

	if (msg.back() != '\n')
	{
		int numBytes = write("\n", 1);

		if (numBytes == -1)
			return -1;

		bytesWritten += numBytes;
	}

	return bytesWritten;
}


void
Process::kill() throw()
{
	if (m_chan)
	{
		Tcl_DeleteChannelHandler(m_chan, ::readHandler, this);
		Tcl_DeleteCloseHandler(m_chan, ::closeHandler, this);
		Tcl_UnregisterChannel(::sys::tcl::interp(), m_chan);
		m_chan = 0;
	}
}


int
Process::write(char const* msg, int size)
{
	int bytesWritten = Tcl_WriteChars(m_chan, msg, size);

	if (bytesWritten == -1)
	{
		if (isAlive())
		{
			Tcl_ResetResult(::sys::tcl::interp());
			Tcl_AppendResult(::sys::tcl::interp(), "write error occured: ");
			Tcl_AppendResult(::sys::tcl::interp(), Tcl_PosixError(::sys::tcl::interp()));
			Tcl_BackgroundError(::sys::tcl::interp());

			DEBUG(fprintf(	stderr,
								"%s: write error occurred (%s)",
								__func__,
								Tcl_PosixError(::sys::tcl::interp())));

			kill();
		}

		return -1;
	}

	return bytesWritten;
}

// vi:set ts=3 sw=3:
