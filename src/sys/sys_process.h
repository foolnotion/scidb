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

#ifndef _sys_process_included
#define _sys_process_included

extern "C" { struct Tcl_Channel_; }

namespace mstl { class string; }

namespace sys {

class Process
{
public:

	enum Priority
	{
		Unknown	= -1,
		Idle		= 20,	// XXX OK?
		Normal	= 0,
		High		= 15,
	};

	Process(mstl::string const& command, mstl::string const& directory);
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

	int gets(mstl::string& result);
	int puts(mstl::string const& msg);

	void close();
	void setPriority(Priority priority);

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

	Channel	m_chan;
	long		m_pid;
	int		m_exitStatus;
	bool		m_signalCrashed;
	bool		m_signalKilled;
	bool		m_pipeClosed;
	bool		m_running;
	bool		m_stopped;
	bool		m_calledExited;
};

} // namespace sys

#include "sys_process.ipp"

#endif // _sys_process_included

// vi:set ts=3 sw=3:
