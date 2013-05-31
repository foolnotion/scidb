// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

// Session management, which is missing in the Tk library.
// ----------------------------------------------------------------------
//
// sm connect
// 	?-command <string>?
// 	?-restart <bool>
// 	?-saveYourself <proc>?
// 	?-saveComplete <proc>?
// 	?-shutdownCancelled <proc>?
// 	?-interactRequest <proc>?
// 	?-die <proc>?
//
// Normally "-command" is not required. The default for "command" is the
// result of [tk appname].
//
// If "-restart" is set to "true", then the client should be restarted in
// the next session if it was running at the end of the current session.
//
// The "-saveYourself" proc is called as soon as the application receives
// a "save yourself" message from the session manager, for example if
// the system is going shutdown, or if the user is logging out. It gets
// a boolean argument, whether the system is going shutdown.
//
// The "-saveComplete" proc is called as soon as the application receives
// a "save complete" message from the session manager. This happens only
// if the system is not going shutdown, and after "save yourself".
//
// The "-shutdownCancelled" proc will be called if the user is cancelling
// the shutdown.
//
// The "-interactRequest" proc will be called with a boolean argument
// whether the system is going shutdown. If the user wants to cancel
// the shutdown he has to return "true".
//
// The "-die" proc will be called before the system is going shutdown,
// after the "save yourself" message from the session manager.
//
// "sm connect" returns the client id. If no session management is
// available, for example the environment variable SESSION_MANAGEMENT"
// is not exisiting, the result of this call is an empty string.
//
// ----------------------------------------------------------------------
//
// sm disconnect
//
// Close the connection.
//
// ----------------------------------------------------------------------
//
// sm configure
// 	?-command <string>?
// 	?-saveYourself <proc>?
// 	?-saveComplete <proc>?
// 	?-shutdownCancelled <proc>?
// 	?-interactRequest <proc>?
// 	?-die <proc>?
//
// The user may modify the values. This can be done before "sm connect"
// is called, or later.
// ----------------------------------------------------------------------
//
// sm get <arg>
//
// where <arg> is one of:
// 	-restart
// 	-command
//		-argv
// 	-saveYourself?
// 	-saveComplete
// 	-shutdownCancelled
// 	-interactRequest
// 	-die <proc>
//
// Returns the value of the argument. "-argv" gives the argument list
// which will be used by the session managaer to restart the application,
// "-command" gives the name of the executable.
//
// ----------------------------------------------------------------------
//
// sm saveyourself ?-shutdown <boolean>?
//
// Send a save yourself message.
//
// ----------------------------------------------------------------------

#include <tcl.h>

struct Tcl_Interp;

namespace tk
{
	Tcl_Command session_manager_init(Tcl_Interp* ti, char const* cmdName);
}

// vi:set ts=3 sw=3:
