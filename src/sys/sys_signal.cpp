// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sys_signal.h"

#ifdef WIN32

bool sys::signal::sendInterrupt(long pid) { return false; }

#else

# include <signal.h>

bool
sys::signal::sendInterrupt(long pid)
{
	return ::kill(pid, SIGINT) == 0;
}


bool
sys::signal::sendTerminate(long pid)
{
	return ::kill(pid, SIGTERM) == 0;
}

#endif

// vi:set ts=3 sw=3:
