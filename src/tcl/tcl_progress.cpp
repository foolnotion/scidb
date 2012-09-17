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

#include "tcl_progress.h"
#include "tcl_exception.h"
#include "tcl_base.h"

#include "m_string.h"

#include <tcl.h>

using namespace tcl;


Tcl_Obj* Progress::m_open			= 0;
Tcl_Obj* Progress::m_close			= 0;
Tcl_Obj* Progress::m_start			= 0;
Tcl_Obj* Progress::m_update		= 0;
Tcl_Obj* Progress::m_tick			= 0;
Tcl_Obj* Progress::m_finish		= 0;
Tcl_Obj* Progress::m_interrupted	= 0;
Tcl_Obj* Progress::m_ticks			= 0;
Tcl_Obj* Progress::m_message		= 0;


static void __attribute__((constructor)) initialize() { Progress::initialize(); }


inline
void
checkResult(int rc, Tcl_Obj* cmd, Tcl_Obj* subcmd, Tcl_Obj* arg)
{
//	if (rc != TCL_OK)
//	{
//		TCL_RAISE(	"'%s %s %s' failed",
//						Tcl_GetString(cmd),
//						Tcl_GetString(subcmd),
//						Tcl_GetString(arg));
//	}
}


void
Progress::initialize()
{
	if (m_open == 0)
	{
		Tcl_IncrRefCount(m_open				= Tcl_NewStringObj("open",				-1));
		Tcl_IncrRefCount(m_close			= Tcl_NewStringObj("close",			-1));
		Tcl_IncrRefCount(m_start			= Tcl_NewStringObj("start",			-1));
		Tcl_IncrRefCount(m_update			= Tcl_NewStringObj("update",			-1));
		Tcl_IncrRefCount(m_tick				= Tcl_NewStringObj("tick",				-1));
		Tcl_IncrRefCount(m_finish			= Tcl_NewStringObj("finish",			-1));
		Tcl_IncrRefCount(m_interrupted	= Tcl_NewStringObj("interrupted?",	-1));
		Tcl_IncrRefCount(m_ticks			= Tcl_NewStringObj("ticks",			-1));
		Tcl_IncrRefCount(m_message			= Tcl_NewStringObj("message",			-1));
	}
}


Progress::Progress(Tcl_Obj* cmd, Tcl_Obj* arg)
	:m_cmd(cmd)
	,m_arg(arg)
	,m_maximum(0)
	,m_numTicks(-1)
	,m_sendFinish(false)
	,m_sendMessage(false)
	,m_checkInterruption(false)
{
	invoke(__func__, m_cmd, m_open, m_arg, nullptr);
}


Progress::~Progress() throw()
{
	if (m_sendFinish)
		sendFinish();

	invoke(__func__, m_cmd, m_close, m_arg, nullptr);
}


void
Progress::checkInterruption()
{
	m_checkInterruption = true;
}


unsigned
Progress::ticks() const
{
	if (m_numTicks == -1)
	{
		m_numTicks = 0;

		Tcl_Obj* result = call(__func__, m_cmd, m_ticks, m_arg, 0);

		if (result)
		{
			Tcl_GetIntFromObj(interp(), result, &m_numTicks);
			Tcl_DecrRefCount(result);

			if (m_numTicks < 0)
				m_numTicks = 0;
		}
	}

	return m_numTicks;
}


bool
Progress::interrupted()
{
	Tcl_Obj* result = call(__func__, m_cmd, m_interrupted, m_arg, 0);

	if (!result)
		return false;

	int rc;

	if (Tcl_GetIntFromObj(interp(), result, &rc) != TCL_OK)
		rc = 0;

	Tcl_DecrRefCount(result);
	return rc != 0;
}


void
Progress::start(unsigned total)
{
	Tcl_Obj* maximum = Tcl_NewLongObj(m_maximum = total);
	Tcl_IncrRefCount(maximum);
	int rc = invoke(__func__, m_cmd, m_start, m_arg, maximum, nullptr);
	Tcl_DecrRefCount(maximum);
	m_sendFinish = rc == TCL_OK;
	m_sendMessage = true;
	checkResult(rc, m_cmd, m_start, m_arg);

	if (!m_msg.empty())
	{
		message(m_msg);
		m_msg.clear();
	}

	if (m_checkInterruption && interrupted())
		throw InterruptException();
}


void
Progress::message(mstl::string const& msg)
{
	if (m_sendMessage)
	{
		Tcl_Obj* message = Tcl_NewStringObj(msg, msg.size());
		Tcl_IncrRefCount(message);
		int rc = invoke(__func__, m_cmd, m_message, m_arg, message, nullptr);
		Tcl_DecrRefCount(message);
		checkResult(rc, m_cmd, m_update, m_arg);

		if (m_checkInterruption && interrupted())
			throw InterruptException();
	}
	else
	{
		m_msg.assign(msg);
	}
}


void
Progress::tick(unsigned count)
{
	Tcl_Obj* value = Tcl_NewLongObj(count);
	Tcl_IncrRefCount(value);
	int rc = invoke(__func__, m_cmd, m_tick, m_arg, value, nullptr);
	Tcl_DecrRefCount(value);
	checkResult(rc, m_cmd, m_update, m_arg);

	if (m_checkInterruption && interrupted())
		throw InterruptException();
}


void
Progress::update(unsigned progress)
{
	Tcl_Obj* value = Tcl_NewLongObj(progress);
	Tcl_IncrRefCount(value);
	int rc = invoke(__func__, m_cmd, m_update, m_arg, value, nullptr);
	Tcl_DecrRefCount(value);
	checkResult(rc, m_cmd, m_update, m_arg);

	if (m_checkInterruption && interrupted())
		throw InterruptException();
}


int
Progress::sendFinish() throw()
{
	Tcl_Obj* maximum = Tcl_NewLongObj(m_maximum);
	Tcl_IncrRefCount(maximum);
	int rc = invoke(__func__, m_cmd, m_finish, m_arg, maximum, nullptr);
	Tcl_DecrRefCount(maximum);
	return rc;
}


void
Progress::finish() throw()
{
	int rc = sendFinish();
	m_sendFinish = rc != TCL_OK;
	m_sendMessage = false;
	checkResult(rc, m_cmd, m_finish, m_arg);
}

// vi:set ts=3 sw=3:
