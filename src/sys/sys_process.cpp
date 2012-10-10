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
#include "m_map.h"

#include <tcl.h>
#include <stdlib.h>

//#define DEBUG

#ifdef DEBUG
# include <stdio.h>
# undef DEBUG
# define DEBUG(x) x
#else
# define DEBUG(x)
#endif

using namespace sys;


typedef mstl::map<int, ::sys::Process*> ProcessMap;
static ProcessMap m_processMap;


#ifndef __WIN32__

# include <signal.h>
# include <sys/types.h>
# include <sys/wait.h>
# include <unistd.h>
# include <errno.h>

static bool m_childHandlerHooked = false;


static void
trapChildEvent(int signum)
{
	int	status;
	pid_t pid		= waitpid(-1, &status, WNOHANG | WUNTRACED | WCONTINUED);

	if (pid >= 0)
	{
		ProcessMap::const_iterator i = m_processMap.find(pid);
		Process* process = i == m_processMap.end() ? 0 : i->second;

		if (process)
		{
			if (WIFEXITED(status))
			{
				process->signalExited(WEXITSTATUS(status));
			}
			else if (WIFSTOPPED(status))
			{
				process->signalStopped();
			}
			else if (WIFCONTINUED(status))
			{
				process->signalResumed();
			}
			else if (WIFSIGNALED(status))
			{
				if (WCOREDUMP(status) || WTERMSIG(status) == SIGABRT)
				{
					process->signalCrashed();
				}
				else
				{
					char const* signal = 0;
					char buf[100];

					switch (WTERMSIG(status))
					{
						case SIGQUIT: signal = "QUIT"; break;
						case SIGKILL: signal = "KILL"; break;
						case SIGTERM: signal = "TERM"; break;

						default:
							sprintf(buf, "%d", int(pid));
							signal = buf;
							break;
					}

					process->signalKilled(signal);
				}
			}
		}
	}
}

#endif


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
readHandler(ClientData clientData, int)
{
	Process* process = reinterpret_cast<Process*>(clientData);

	if (process->isRunning())
		process->readyRead();
	else
		process->close();
}


Process::Process(mstl::string const& command, mstl::string const& directory)
	:m_chan(0)
	,m_pid(-1)
	,m_buffer(new Tcl_DString)
	,m_exitStatus(0)
	,m_signalCrashed(false)
	,m_signalKilled(false)
	,m_pipeClosed(false)
	,m_running(false)
	,m_stopped(false)
	,m_calledExited(false)
{
#ifndef __WIN32__
	// trap child events like crashes
	if (!::m_childHandlerHooked)
	{
		signal(SIGCHLD, ::trapChildEvent);
		m_childHandlerHooked = true;
	}
#endif

	Tcl_DStringInit(m_buffer);

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

	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-buffering", "line");
	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-blocking", "no");
	Tcl_SetChannelOption(::sys::tcl::interp(), m_chan, "-translation", "binary");
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
	Tcl_CreateCloseHandler(m_chan, closeHandler, this);

	m_processMap[m_pid] = this;
	m_running = true;
}


Process::~Process()
{
	Tcl_DStringFree(m_buffer);
	delete m_buffer;
	m_processMap.erase(m_pid);
	m_calledExited = true; // process is destroyed by user
	close();
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
	M_REQUIRE(priority != Unknown);

	if (isAlive())
	{
		if (!::setPriority(m_pid, priority))
			TCL_RAISE("setPriority() failed");
	}
}


int
Process::gets(mstl::string& result)
{
	Tcl_DStringTrunc(m_buffer, 0);

	int bytesRead = Tcl_Gets(m_chan, m_buffer);

	if (bytesRead >= 0)
	{
		result.assign(static_cast<char const*>(Tcl_DStringValue(m_buffer)), Tcl_DStringLength(m_buffer));
	}
	else if (!Tcl_InputBlocked(m_chan) && !Tcl_Eof(m_chan))
	{
		if (!isAlive() || isStopped())
			return -1;

		Tcl_ResetResult(::sys::tcl::interp());
		Tcl_AppendResult(::sys::tcl::interp(), "read error occured: ");
		Tcl_AppendResult(::sys::tcl::interp(), Tcl_PosixError(::sys::tcl::interp()));
		Tcl_BackgroundError(::sys::tcl::interp());

		DEBUG(fprintf(	stderr,
							"%s: read error occurred (%s)",
							__func__,
							Tcl_PosixError(::sys::tcl::interp())));

		close();
	}

	return bytesRead;
}


int
Process::puts(mstl::string const& msg)
{
	if (!isRunning() || !isAlive() || isStopped())
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
Process::close()
{
	if (m_chan)
	{
		Tcl_DeleteChannelHandler(m_chan, ::readHandler, this);
		Tcl_DeleteCloseHandler(m_chan, closeHandler, this);
		Tcl_UnregisterChannel(::sys::tcl::interp(), m_chan);
		m_chan = 0;
	}

	if (!m_calledExited)
	{
		m_calledExited = true;
		exited();
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

			close();
		}

		return -1;
	}

	return bytesWritten;
}


void
Process::closeHandler(void* clientData)
{
	Process* process = reinterpret_cast<Process*>(clientData);

	process->m_calledExited = true;
	process->m_pipeClosed = true;
	process->exited();
}


void
Process::signalExited(int status)
{
	DEBUG(fprintf(stderr, "engine exited with error status %d\n", status));
	m_running = false;
	m_exitStatus = status;
}


void
Process::signalCrashed()
{
	DEBUG(fprintf(stderr, "engine core dumped\n"));
	m_running = false;
	m_signalCrashed = true;
}


void
Process::signalKilled(char const* signal)
{
	DEBUG(fprintf(stderr, "engine is killed by signal %s\n", signal));
	m_running = false;
	m_signalKilled = true;
}


void
Process::signalStopped()
{
	DEBUG(fprintf(stderr, "engine stopped\n"));
	m_stopped = true;
	Tcl_DoWhenIdle(callStopped, this);
}


void
Process::signalResumed()
{
	DEBUG(fprintf(stderr, "engine resumed\n"));
	m_stopped = false;
	Tcl_DoWhenIdle(callResumed, this);
}


void
Process::callStopped(void* clientData)
{
	static_cast<Process*>(clientData)->stopped();
}


void
Process::callResumed(void* clientData)
{
	static_cast<Process*>(clientData)->resumed();
}

// vi:set ts=3 sw=3:
