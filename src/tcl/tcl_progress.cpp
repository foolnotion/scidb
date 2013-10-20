// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2013 Gregor Cramer
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

static char const* CmdInterrupt		= "::scidb::progress::interrupt";
static char const* CmdInterruptable	= "::scidb::progress::interruptable?";

static Progress* m_currentProgress = 0;

static Tcl_Obj* m_open				= 0;
static Tcl_Obj* m_close				= 0;
static Tcl_Obj* m_start				= 0;
static Tcl_Obj* m_update			= 0;
static Tcl_Obj* m_tick				= 0;
static Tcl_Obj* m_finish			= 0;
static Tcl_Obj* m_interrupted		= 0;
static Tcl_Obj* m_interruptable	= 0;
static Tcl_Obj* m_ticks				= 0;
static Tcl_Obj* m_message			= 0;


static void
informTermination(ClientData clientData)
{
	Tcl_Obj* cmd = static_cast<Tcl_Obj*>(clientData);
	Tcl_EvalObjEx(interp(), cmd, TCL_EVAL_GLOBAL);
	Tcl_DecrRefCount(cmd);
}


void
Progress::initialize()
{
	if (::m_open == 0)
	{
		Tcl_IncrRefCount(::m_open				= Tcl_NewStringObj("open",					-1));
		Tcl_IncrRefCount(::m_close				= Tcl_NewStringObj("close",				-1));
		Tcl_IncrRefCount(::m_start				= Tcl_NewStringObj("start",				-1));
		Tcl_IncrRefCount(::m_update			= Tcl_NewStringObj("update",				-1));
		Tcl_IncrRefCount(::m_tick				= Tcl_NewStringObj("tick",					-1));
		Tcl_IncrRefCount(::m_finish			= Tcl_NewStringObj("finish",				-1));
		Tcl_IncrRefCount(::m_interrupted		= Tcl_NewStringObj("interrupted?",		-1));
		Tcl_IncrRefCount(::m_interruptable	= Tcl_NewStringObj("interruptable?",	-1));
		Tcl_IncrRefCount(::m_ticks				= Tcl_NewStringObj("ticks",				-1));
		Tcl_IncrRefCount(::m_message			= Tcl_NewStringObj("message",				-1));
	}
}


Progress::Progress(Tcl_Obj* cmd, Tcl_Obj* arg)
	:m_cmd(cmd)
	,m_arg(arg)
	,m_inform(0)
	,m_maximum(0)
	,m_numTicks(-1)
	,m_sendFinish(false)
	,m_sendMessage(false)
	,m_interrupted(false)
	,m_checkInterruption(false)
{
	m_currentProgress = this;
	invoke(__func__, m_cmd, ::m_open, m_arg, nullptr);
}


Progress::~Progress() throw()
{
	if (m_sendFinish)
		sendFinish();

	invoke(__func__, m_cmd, ::m_close, m_arg, nullptr);
	m_currentProgress = 0;

	if (m_inform)
		Tcl_DoWhenIdle(informTermination, m_inform);
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

		Tcl_Obj* result = call(__func__, m_cmd, ::m_ticks, m_arg, 0);

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
Progress::interruptable() const
{
	Tcl_Obj* result = call(__func__, m_cmd, ::m_interruptable, m_arg, 0);

	if (!result)
		return false;

	int rc;

	if (Tcl_GetBooleanFromObj(interp(), result, &rc) != TCL_OK)
		rc = 0;

	Tcl_DecrRefCount(result);
	return rc != 0;
}


bool
Progress::interrupted()
{
	if (m_interrupted)
		return true;

	Tcl_Obj* result = call(__func__, m_cmd, ::m_interrupted, m_arg, 0);

	if (!result)
		return false;

	int rc;

	if (Tcl_GetBooleanFromObj(interp(), result, &rc) != TCL_OK)
		rc = 0;

	Tcl_DecrRefCount(result);
	return m_interrupted = (rc != 0);
}


void
Progress::interrupt(Tcl_Obj* inform)
{
	m_interrupted = true;

	if ((m_inform = inform))
		Tcl_IncrRefCount(m_inform);
}


void
Progress::start(unsigned total)
{
	Tcl_Obj* maximum = Tcl_NewWideIntObj(m_maximum = total);
	Tcl_IncrRefCount(maximum);
	int rc = invoke(__func__, m_cmd, ::m_start, m_arg, maximum, nullptr);
	Tcl_DecrRefCount(maximum);
	m_sendFinish = rc == TCL_OK;
	m_sendMessage = true;

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
		invoke(__func__, m_cmd, ::m_message, m_arg, message, nullptr);
		Tcl_DecrRefCount(message);

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
	Tcl_Obj* value = Tcl_NewWideIntObj(count);
	Tcl_IncrRefCount(value);
	invoke(__func__, m_cmd, ::m_tick, m_arg, value, nullptr);
	Tcl_DecrRefCount(value);

	if (m_checkInterruption && interrupted())
		throw InterruptException();
}


void
Progress::update(unsigned progress)
{
	Tcl_Obj* value = Tcl_NewWideIntObj(progress);
	Tcl_IncrRefCount(value);
	invoke(__func__, m_cmd, ::m_update, m_arg, value, nullptr);
	Tcl_DecrRefCount(value);

	if (m_checkInterruption && interrupted())
		throw InterruptException();
}


int
Progress::sendFinish() throw()
{
	Tcl_Obj* maximum = Tcl_NewWideIntObj(m_maximum);
	Tcl_IncrRefCount(maximum);
	int rc = invoke(__func__, m_cmd, ::m_finish, m_arg, maximum, nullptr);
	Tcl_DecrRefCount(maximum);
	return rc;
}


void
Progress::finish() throw()
{
	int rc = sendFinish();
	m_sendFinish = rc != TCL_OK;
	m_sendMessage = false;
}


static int
cmdInterrupt(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool		wait		= false;
	Tcl_Obj*	inform	= 0;

	for (int i = 1; i < objc; i += 2)
	{
		char const* option = stringFromObj(objc, objv, i);

		if (strcmp(option, "-wait") == 0)
			wait = boolFromObj(objc, objv, i + 1);
		else if (strcmp(option, "-inform") == 0)
			inform = objectFromObj(objc, objv, i + 1);
		else
			return error(CmdInterrupt, 0, 0, "unknown option '%s'", option);
	}

	if (m_currentProgress)
	{
		m_currentProgress->interrupt(inform);
	
		if (wait)
		{
			while (m_currentProgress)
				Tcl_DoOneEvent(TCL_ALL_EVENTS);
		}
	}

	setResult(m_currentProgress == 0);
	return TCL_OK;
}


static int
cmdInterruptable(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(m_currentProgress && m_currentProgress->interruptable());
	return TCL_OK;
}


namespace tcl {
namespace progress {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdInterrupt,		cmdInterrupt);
	createCommand(ti, CmdInterruptable,	cmdInterruptable);
}

} // namespace progress
} // namespace tcl

// vi:set ts=3 sw=3:
