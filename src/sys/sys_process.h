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
	virtual ~Process() throw();

	bool isAlive() const;

	Priority priority() const;
	long pid() const;

	int gets(mstl::string& result);
	int puts(mstl::string const& msg);

	void kill() throw();
	void setPriority(Priority priority);

	virtual void readyRead() = 0;
	virtual void exited() = 0;

private:

	typedef struct Tcl_Channel_* Channel;

	int write(char const* msg, int size);

	Channel	m_chan;
	long		m_pid;
};

} // namespace sys

#include "sys_process.ipp"

#endif // _sys_process_included

// vi:set ts=3 sw=3:
