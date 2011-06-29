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

#include "sys_timer.h"
#include "sys_base.h"
#include "sys_base.h"

#include <tcl.h>


using namespace sys;


Timer::Timer(unsigned timeout)
	:m_token(Tcl_CreateTimerHandler(timeout, Timer::timerEvent, this))
	,m_expired(false)
{
}


Timer::~Timer() throw()
{
	Tcl_DeleteTimerHandler(m_token);
}


bool
Timer::expired() const
{
	return m_expired || Tcl_LimitExceeded(::sys::tcl::interp());
}


void
Timer::doNextEvent()
{
	Tcl_DoOneEvent(TCL_ALL_EVENTS);
}


void
Timer::timeout()
{
	// no action
}


void
Timer::timerEvent(void* clientData)
{
	Timer* timer = static_cast<Timer*>(clientData);

	timer->m_expired = true;
	timer->timeout();
}

// vi:set ts=3 sw=3:
