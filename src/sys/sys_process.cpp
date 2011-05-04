// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_process.h"

#include "tcl_exception.h"
#include "tcl_base.h"

#include "m_string.h"

#include <tcl.h>
#include <stdlib.h>

using namespace sys;


namespace {

#ifdef WIN32

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
	operator bool ()				{ return Tcl_DStringValue(&str); }

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

	Tcl_TranslateFileName(tcl::interp(), command, cmd);
	Tcl_TranslateFileName(tcl::interp(), directory, dir);

	if (!directory.empty())
	{
		Tcl_GetCwd(tcl::interp(), cwd);
		Tcl_Chdir(dir);
	}

	char const* argv[1] = { command.c_str() };

	m_chan = Tcl_OpenCommandChannel(	tcl::interp(),
												1, argv,
												TCL_STDIN | TCL_STDOUT | TCL_STDERR | TCL_ENFORCE_MODE);

	if (!directory.empty() && cwd)
		Tcl_Chdir(cwd);

	if (!m_chan)
		TCL_RAISE("cannot create process: %s", Tcl_PosixError(tcl::interp()));

#ifdef Tcl_PidObjCmd__is_not_hidden

	extern "C" { int Tcl_PidObjCmd(ClientData, Tcl_Interp*, int, Tcl_Obj* const[]); }

	Tcl_Obj* channelName = Tcl_NewStringObj(Tcl_GetChannelName(m_chan), -1);
	Tcl_IncrRefCount(channelName);
	m_pid = Tcl_PidObjCmd(0, tcl::interp(), 1, &channelName);
	Tcl_DecrRefCount(channelName);

#else

	char const* pidCmd = "::pid";

	Tcl_Obj* result = ::tcl::call(__func__, pidCmd, Tcl_GetChannelName(m_chan), 0);

	if (result == 0)
		TCL_RAISE("tcl::invoke(\"%s\") failed", pidCmd);
	if (Tcl_GetLongFromObj(tcl::interp(), result, &m_pid) != TCL_OK)
		TCL_RAISE("%s should return long (instead of '%s')", pidCmd, Tcl_GetStringFromObj(result, 0));

#endif

	// XXX should be "-buffering", "none" ?
	Tcl_SetChannelOption(tcl::interp(), m_chan, "-buffering", "line");
	Tcl_SetChannelOption(tcl::interp(), m_chan, "-blocking", "0");
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

	DString buf;

	int bytesRead = Tcl_Gets(m_chan, buf);

	if (bytesRead == -1)
	{
		if (!isAlive())
			return -1;

		TCL_RAISE("read error occured: %s", Tcl_PosixError(tcl::interp()));
	}

	result.assign(static_cast<char const*>(buf), buf.length());

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
		Tcl_Close(tcl::interp(), m_chan);
		m_chan = 0;
	}
}


int
Process::write(char const* msg, int size)
{
	int bytesWritten = Tcl_WriteChars(m_chan, msg, size);

	if (bytesWritten == -1)
	{
		if (!isAlive())
			return -1;

		TCL_RAISE("write error occured: %s", Tcl_PosixError(tcl::interp()));
	}

	return bytesWritten;
}

// vi:set ts=3 sw=3:
