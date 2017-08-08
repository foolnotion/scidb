// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _sys_process_included
#define _sys_process_included

#include "m_string.h"
#include "m_vector.h"
#include "m_utility.h"

extern "C" { struct Tcl_Channel_; }
extern "C" { struct Tcl_DString; }

namespace sys {

class Process : private mstl::noncopyable
{
public:

	enum Priority
	{
		Unknown	= -9999,
		Idle		= 18,
		Normal	= 0,
		High		= -15,
	};

	typedef mstl::vector<mstl::string> Command;

	Process(Command const& command, mstl::string const& directory);
	virtual ~Process();

	bool isAlive() const;
	bool isRunning() const;
	bool isStopped() const;

	bool wasCrashed() const;
	bool wasKilled() const;
	bool pipeWasClosed() const;

	Priority priority() const;
	long pid() const;
	int exitStatus() const;
	mstl::string const& program() const;

	int gets(mstl::string& result);
	int puts(mstl::string const& msg);

	void close();
	void setPriority(Priority priority);
	void stop();
	void resume();
	void kill();

	virtual void readyRead() = 0;
	virtual void exited() = 0;
	virtual void stopped() = 0;
	virtual void resumed() = 0;

	void signalExited(int status);
	void signalKilled(char const* signal);
	void signalCrashed();
	void signalStopped();
	void signalResumed();

private:

	typedef struct Tcl_Channel_* Channel;

	int write(char const* msg, int size);

	static void closeHandler(void* clientData);
	static void callStopped(void* clientData);
	static void callResumed(void* clientData);

	mstl::string	m_program;
	Channel			m_chan;
	long				m_pid;
	Tcl_DString*	m_buffer;
	int				m_exitStatus;
	bool				m_signalCrashed;
	bool				m_signalKilled;
	bool				m_pipeClosed;
	bool				m_running;
	bool				m_stopped;
	bool				m_calledExited;
};

} // namespace sys

#include "sys_process.ipp"

#endif // _sys_process_included

// vi:set ts=3 sw=3:
