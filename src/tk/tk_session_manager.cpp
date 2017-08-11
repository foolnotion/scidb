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

#include "tk_session_manager.h"

#if !defined(__WIN32__) && !defined(__MacOSX__)

#include <tk.h>

#include <X11/SM/SMlib.h>

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <pwd.h>

extern "C" { static Tcl_FreeProc* __tcl_static = TCL_STATIC; }

static char const* SessionIdOption = "--session-id";

static char*			m_tkCmdName					= 0;
static bool				m_setProps					= false;
static Bool				m_shutdown					= False;
static int				m_restartStyle				= SmRestartNever;
static int				m_restartIndex				= 0;
static SmcConn			m_connection				= 0;
static Tcl_Obj*		m_sessionId					= 0;
static Tcl_Obj*		m_command					= 0;
static Tcl_Obj*		m_argv						= 0;
static Tcl_Obj*		m_saveYourselfProc		= 0;
static Tcl_Obj*		m_dieProc					= 0;
static Tcl_Obj*		m_saveCompleteProc		= 0;
static Tcl_Obj*		m_shutdownCancelledProc	= 0;
static Tcl_Obj*		m_interactRequestProc	= 0;
static Tcl_Channel	m_chan						= 0;


static void iceIoErrorHandler(IceConn);
static void closeConnection();
static void callbackSaveYourself(SmcConn, SmPointer, int, Bool, int, Bool);


static int
setError(Tcl_Interp* ti, char const* format, ...)
{
	va_list args;
	va_start(args, format);

	static char buf[4096];
	int len = snprintf(buf, sizeof(buf), "%s: ", m_tkCmdName);
	vsnprintf(buf + len, sizeof(buf) - len, format, args);
	Tcl_SetResult(ti, buf, __tcl_static);

	va_end(args);
	return TCL_ERROR;
}


static int
setResult(Tcl_Interp *ti, Tcl_Obj* result)
{
	Tcl_SetObjResult(ti, result ? result : Tcl_NewListObj(0, 0));
	return TCL_OK;
}


static Tcl_Obj*
eval(Tcl_Interp* ti, char const* script)
{
	Tcl_Obj* result = 0;

	Tcl_SavedResult state;
	Tcl_SaveResult(ti, &state);

	if (Tcl_Eval(ti, script) == TCL_OK)
	{
		result = Tcl_GetObjResult(ti);

		if (result)
			Tcl_IncrRefCount(result);
	}

	Tcl_RestoreResult(ti, &state);
	return result;
}


static Tcl_Obj*
getVar(Tcl_Interp* ti, char const* varName)
{
	Tcl_SavedResult state;
	Tcl_SaveResult(ti, &state);

	Tcl_Obj* result = Tcl_GetVar2Ex(ti, varName, 0, TCL_GLOBAL_ONLY);

	if (result)
		Tcl_IncrRefCount(result);

	Tcl_RestoreResult(ti, &state);
	return result;
}


static int
determineCommandAndArguments(Tcl_Interp* ti)
{
	static char const* ReconstructOptions[] =	{ "-colormap", "-visual", "-display", "-use"	};
	static int ReconstructSize = sizeof(ReconstructOptions)/sizeof(ReconstructOptions[0]);

	if (m_command)
		return TCL_OK;

	static char const* CommandScript = "file normalize [info nameofexecutable]";

	Tcl_Obj* interactive = getVar(ti, "tcl_interactive");

	m_command = eval(ti, CommandScript);

	if (m_command == 0)
		return setError(ti, "couldn't evaluate [%s]", CommandScript);

	if (m_argv == 0)
	{
		if ((m_argv = getVar(ti, "argv")) == 0)
			return setError(ti, "couldn't get value of variable 'argv'");

		int n;
		if (Tcl_ListObjLength(ti, m_argv, &n) != TCL_OK)
			return setError(ti, "'argv' is not a list object");

		Tcl_Obj* argv0 = 0;
		int interactiveVal = 0;

		if (	interactive
			&& Tcl_GetIntFromObj(ti, interactive, &interactiveVal) == TCL_OK
			&& !interactiveVal)
		{
			if ((argv0 = getVar(ti, "argv0")) == 0)
				return setError(ti, "couldn't get value of variable 'argv0'");
		}

		int objc = 0;
		Tcl_Obj** objv = 0;
		Tcl_ListObjGetElements(ti, m_argv, &objc, &objv);

		Tcl_Obj* objs[objc + 3 + 2*ReconstructSize];
		int objn = m_restartIndex = argv0 ? 1 : 0;

		for (int i = 0; i < ReconstructSize; ++i)
		{
			char script[128];
			sprintf(script, ". cget %s", ReconstructOptions[i]);
			Tcl_Obj* value = eval(ti, script);

			if (value)
			{
				if (strlen(Tcl_GetString(value)) == 0)
				{
					Tcl_DecrRefCount(value);
				}
				else
				{
					objs[objn++] = Tcl_NewStringObj(ReconstructOptions[i], -1);
					objs[objn++] = value;
				}
			}
		}

		Tcl_Obj* geometry = getVar(ti, "geometry");
		if (geometry)
		{
			objs[objn++] = Tcl_NewStringObj("-geometry", 9);
			objs[objn++] = geometry;
		}

		for (int i = 0; i < objc; ++i)
		{
			if (strcmp(Tcl_GetString(objv[i]), SessionIdOption) != 0)
				objs[objn++] = objv[i];
			else if (++i < objc)
				Tcl_IncrRefCount(m_sessionId = objv[i]);
		}

		if (argv0)
			objs[0] = argv0;

		Tcl_DecrRefCount(m_argv);
		Tcl_IncrRefCount(m_argv = Tcl_NewListObj(objn, objs));
	}

	return TCL_OK;
}


static int
invokeProc(Tcl_Interp* ti, char const* which, Tcl_Obj* proc)
{
	int rc = TCL_OK;

	if (proc)
	{
		Tcl_SavedResult state;
		Tcl_SaveResult(ti, &state);

		if ((rc = Tcl_EvalObjEx(ti, proc, TCL_EVAL_GLOBAL)) != TCL_OK)
			fprintf(stderr, "%s: call of '%s' failed\n", m_tkCmdName, which);

		Tcl_RestoreResult(ti, &state);
	}

	return rc;
}


static int
invokeProc(Tcl_Interp* ti, char const* which, Tcl_Obj* proc, bool arg)
{
	int rc = TCL_OK;

	if (proc)
	{
		Tcl_SavedResult state;
		Tcl_SaveResult(ti, &state);

		Tcl_Obj* objv[2] = { proc, Tcl_NewBooleanObj(m_shutdown) };
		Tcl_IncrRefCount(objv[1]);

		if ((rc = Tcl_EvalObjv(ti, 2, objv, TCL_EVAL_GLOBAL)) != TCL_OK)
			fprintf(stderr, "%s: call of '%s' failed\n", m_tkCmdName, which);

		Tcl_DecrRefCount(objv[1]);
		Tcl_RestoreResult(ti, &state);
	}

	return rc;
}


static void
callbackDie(SmcConn smcConn, SmPointer clientData)
{
	invokeProc(static_cast<Tcl_Interp*>(clientData), "dieProc", m_dieProc);
	SmcCloseConnection(smcConn, 0, 0);
   exit(0);
}


static void
saveYourselfInteraction(SmcConn smcConn, SmPointer clientData)
{
	Tcl_Interp* ti = static_cast<Tcl_Interp*>(clientData);

	bool cancelShutdown = false;

	Tcl_SavedResult state;
	Tcl_SaveResult(ti, &state);

	Tcl_Obj* objv[2] = { m_interactRequestProc, Tcl_NewBooleanObj(m_shutdown) };
	Tcl_IncrRefCount(objv[1]);

	if (Tcl_EvalObjv(ti, 2, objv, TCL_EVAL_GLOBAL) != TCL_OK)
	{
		fprintf(stderr, "%s: call of 'interactRequestProc' failed\n", m_tkCmdName);
	}
	else
	{
		Tcl_Obj*	result = Tcl_GetObjResult(ti);
		int		proceed;

		if (result == 0 || Tcl_GetBooleanFromObj(ti, result, &proceed) != TCL_OK)
			fprintf(stderr, "%s: 'interactRequestProc' should return boolean\n", m_tkCmdName);
		else
			cancelShutdown = proceed ? False : True;
	}

	Tcl_DecrRefCount(objv[1]);
	Tcl_RestoreResult(ti, &state);

	SmcInteractDone(smcConn, cancelShutdown);

	if (cancelShutdown)
		SmcSaveYourselfDone(smcConn, True);
	else
		callbackSaveYourself(smcConn, clientData, SmSaveGlobal, m_shutdown, SmInteractStyleNone, False);
}


static void
callbackSaveYourself(SmcConn smcConn,
							SmPointer clientData,
							int saveStyle,
							Bool shutdown,
							int interactStyle,
							Bool fast __attribute((unused))) // ignored, no one is using this flag
{
	if (m_setProps)
	{
		int objc = 0;
		Tcl_Obj** objv = 0;
		Tcl_Interp* ti = static_cast<Tcl_Interp*>(clientData);

		Tcl_ListObjGetElements(ti, m_argv, &objc, &objv);

		struct
		{
			SmPropValue		program[1];
			SmPropValue		user[1];
			SmPropValue		hint[1];
			SmPropValue		pwd[1];
			SmPropValue*	clone;
			SmPropValue*	restart;
		}
		vals;

		vals.clone = new SmPropValue[objc];
		vals.restart = new SmPropValue[objc + 2];

		SmProp prop[] =
		{
#define C(x) const_cast<char*>(x)
			{ C(SmProgram),          C(SmLISTofARRAY8), 1,        vals.program },
			{ C(SmUserID),           C(SmLISTofARRAY8), 1,        vals.user    },
			{ C(SmRestartStyleHint), C(SmCARD8),        1,        vals.hint    },
			{ C(SmCurrentDirectory), C(SmARRAY8),       0,        vals.pwd     },
			{ C(SmCloneCommand),     C(SmLISTofARRAY8), objc,     vals.clone   },
			{ C(SmRestartCommand),   C(SmLISTofARRAY8), objc + 2, vals.restart },
#undef C
		};

		SmProp* props[] = { &prop[0], &prop[1], &prop[2], &prop[3], &prop[4], &prop[5] };

		vals.program->value  = Tcl_GetString(m_command);
		vals.program->length = strlen(Tcl_GetString(m_command));

		struct passwd const* pw = getpwuid(getuid());
		char* name = pw ? pw->pw_name : const_cast<char*>("");
		vals.user->value  = name;
		vals.user->length = strlen(name);

		char restart_style = m_restartStyle;
		vals.hint->value  = &restart_style;
		vals.hint->length = 1;

		char buf[4096];
		if (char* pwd = getcwd(buf, sizeof(buf)))
		{
			vals.pwd->value  = pwd;
			vals.pwd->length = strlen(pwd);
			prop[3].num_vals = 1;
		}

		for (int i = 0; i < objc; ++i)
		{
			vals.clone[i].value = Tcl_GetString(objv[i]);
			vals.clone[i].length = strlen(Tcl_GetString(objv[i]));
		}

		for (int i = 0, n = 0; i < objc; ++i, ++n)
		{
			if (n == m_restartIndex)
				n += 2;
			vals.restart[n].value = Tcl_GetString(objv[i]);
			vals.restart[n].length = strlen(Tcl_GetString(objv[i]));
		}

		vals.restart[m_restartIndex].value = const_cast<void*>(static_cast<void const*>(SessionIdOption));
		vals.restart[m_restartIndex].length = strlen(SessionIdOption);
		vals.restart[m_restartIndex + 1].value = Tcl_GetString(m_sessionId);
		vals.restart[m_restartIndex + 1].length = strlen(Tcl_GetString(m_sessionId));

		SmcSetProperties(smcConn, sizeof(props)/sizeof(props[0]), props);

		delete [] vals.clone;
		delete [] vals.restart;

		m_setProps = false;
	}

	if (saveStyle != SmSaveLocal)
	{
		m_shutdown = shutdown;

		if (	m_interactRequestProc
			&& interactStyle == SmInteractStyleAny
			&& SmcInteractRequest(smcConn, SmDialogNormal, saveYourselfInteraction, clientData) != 0)
		{
			return;
		}

		invokeProc(	static_cast<Tcl_Interp*>(clientData),
						"saveYourselfProc",
						m_saveYourselfProc,
						shutdown);
	}

	SmcSaveYourselfDone(smcConn, True);
}


static void
callbackShutdownCancelled(SmcConn smcConn, SmPointer clientData)
{
	invokeProc(static_cast<Tcl_Interp*>(clientData), "shutdownCancelledProc", m_shutdownCancelledProc);
}


static void
callbackSaveComplete(SmcConn smcConn, SmPointer clientData)
{
	invokeProc(static_cast<Tcl_Interp*>(clientData), "saveCompleteProc", m_saveCompleteProc);
}


static void
processMessages(ClientData data, int mask)
{
	if (IceProcessMessages(IceConn(data), 0, 0) == IceProcessMessagesIOError)
		iceIoErrorHandler(IceConn(data));
}


static void
closeConnection()
{
	if (m_connection)
	{
		int fd = IceConnectionNumber(SmcGetIceConnection(m_connection));

		SmcCloseConnection(m_connection, 0, 0);

		if (m_chan)
		{
			Tcl_DeleteChannelHandler(m_chan, processMessages, reinterpret_cast<ClientData>(fd));
#if TCL_MAJOR_VERSION != 8 || TCL_MINOR_VERSION != 7 || TCL_RELEASE_SERIAL != 0
			// 6.8.0 is crashing with a closes descriptor
			Tcl_Close(0, m_chan);
#endif
		}

		Tcl_DecrRefCount(m_sessionId);
		m_sessionId = 0;
		m_connection = 0;
		m_chan = 0;
		m_setProps = false;
		m_shutdown = False;
	}
}


static void
iceIoErrorHandler(IceConn connection)
{
	closeConnection();
	fprintf(stderr, "%s: ICE IO error - SMC connection closed", m_tkCmdName);
}


static int
setupCallback(Tcl_Interp* ti, SmcCallbacks& callbacks)
{
	static int ProcMask	= SmcSaveYourselfProcMask
								| SmcDieProcMask
								| SmcSaveCompleteProcMask
								| SmcShutdownCancelledProcMask;

	callbacks.save_yourself.callback = callbackSaveYourself;
	callbacks.die.callback = callbackDie;
	callbacks.save_complete.callback = callbackSaveComplete;
	callbacks.shutdown_cancelled.callback = callbackShutdownCancelled;

	callbacks.save_yourself.client_data = ti;
	callbacks.die.client_data = ti;
	callbacks.save_complete.client_data = ti;
	callbacks.shutdown_cancelled.client_data = ti;

	return ProcMask;
}


static int
sessionInit(Tcl_Interp* ti)
{
	IceSetIOErrorHandler(iceIoErrorHandler);

	SmcCallbacks callbacks;

	char	errorBuf[4096] = "";
	char*	previousId = m_sessionId ? Tcl_GetString(m_sessionId) : 0;
	char*	clientId = 0;

	m_connection = SmcOpenConnection(0,
												0,
												SmProtoMajor,
												SmProtoMinor,
												setupCallback(ti, callbacks),
												&callbacks,
												previousId,
												&clientId,
												sizeof(errorBuf),
												errorBuf);

	if (m_connection == 0)
		return setError(ti, errorBuf);

	int fd = IceConnectionNumber(SmcGetIceConnection(m_connection));
	m_chan = Tcl_MakeFileChannel(reinterpret_cast<ClientData>(fd), TCL_READABLE);

	Tcl_CreateChannelHandler(m_chan, TCL_READABLE, processMessages, SmcGetIceConnection(m_connection));
	Tcl_SetChannelOption(0, m_chan, "-blocking", "no");
	Tcl_SetChannelOption(0, m_chan, "-encoding", "binary");
	Tcl_SetChannelOption(0, m_chan, "-translation", "binary binary");

	m_setProps = previousId == 0 || strcmp(previousId, clientId) != 0;

	if (m_sessionId)
		Tcl_DecrRefCount(m_sessionId);
	Tcl_IncrRefCount(m_sessionId = Tcl_NewStringObj(clientId, -1));
	Tcl_SetObjResult(ti, m_sessionId);

	return TCL_OK;
}


static int
cmdConfigure(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[], bool isConnect)
{
	for (int i = 2; i + 1 < objc; i+= 2)
	{
		char const* option = Tcl_GetString(objv[i]);

		if (strcmp(option, "-saveYourself") == 0)
		{
			Tcl_IncrRefCount(m_saveYourselfProc = objv[i + 1]);
		}
		else if (strcmp(option, "-die") == 0)
		{
			Tcl_IncrRefCount(m_dieProc = objv[i + 1]);
		}
		else if (strcmp(option, "-saveComplete") == 0)
		{
			Tcl_IncrRefCount(m_saveCompleteProc = objv[i + 1]);
		}
		else if (strcmp(option, "-shutdownCancelled") == 0)
		{
			Tcl_IncrRefCount(m_shutdownCancelledProc = objv[i + 1]);
		}
		else if (strcmp(option, "-interactRequest") == 0)
		{
			Tcl_IncrRefCount(m_interactRequestProc = objv[i + 1]);
		}
		else if (strcmp(option, "-command") == 0)
		{
			Tcl_IncrRefCount(m_command = objv[i + 1]);
		}
		else if (isConnect && strcmp(option, "-restart") == 0)
		{
			int flag;
			if (Tcl_GetBooleanFromObj(ti, objv[i + 1], &flag) != TCL_OK)
				return setError(ti, "boolean value expected for '-restart'");
			m_restartStyle = flag ? SmRestartIfRunning : SmRestartNever;
		}
		else
		{
			return setError(ti, "unknown option '%s'", option);
		}
	}

	if (objc % 2 == 1)
		return setError(ti, "value for '%s' missing", Tcl_GetString(objv[objc - 1]));
	
	SmcCallbacks callbacks;

	if (m_connection)
		SmcModifyCallbacks(m_connection, setupCallback(ti, callbacks), &callbacks);

	return TCL_OK;
}


static int
cmdGet(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
		return setError(ti, "wrong # args; should be 'get argument'");

	determineCommandAndArguments(ti);

	char const* option = Tcl_GetString(objv[2]);

	if (strcmp(option, "-restart") == 0)
		return setResult(ti, Tcl_NewBooleanObj(m_restartStyle == SmRestartIfRunning));
	if (strcmp(option, "-saveYourself") == 0)
		return setResult(ti, m_saveYourselfProc);
	if (strcmp(option, "-die") == 0)
		return setResult(ti, m_dieProc);
	if (strcmp(option, "-saveComplete") == 0)
		return setResult(ti, m_saveCompleteProc);
	if (strcmp(option, "-shutdownCancelled") == 0)
		return setResult(ti, m_shutdownCancelledProc);
	if (strcmp(option, "-interactRequest") == 0)
		return setResult(ti, m_interactRequestProc);
	if (strcmp(option, "-command") == 0)
		return setResult(ti, m_command);
	if (strcmp(option, "-argv") == 0)
		return setResult(ti, m_argv);

	return setError(ti, "unknown option '%s'", option) != TCL_OK;
}


static int
cmdConnect(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (getenv("SESSION_MANAGER") == 0)
	{
		Tcl_SetResult(ti, const_cast<char*>(""), __tcl_static);
		return TCL_OK;
	}

	if (m_connection)
		return setError(ti, "is already connected");

	if (cmdConfigure(ti, objc, objv, true) != TCL_OK)
		return TCL_ERROR;

	if (determineCommandAndArguments(ti) != TCL_OK)
		return TCL_ERROR;

	return sessionInit(ti);
}


static int
cmdDisconnect(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	closeConnection();
	return TCL_OK;
}


static int
cmdSaveYourself(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (m_connection == 0)
		return setError(ti, "not connected to session manager");

	Bool shutdown = False;

	for (int i = 2; i + 1 < objc; i+= 2)
	{
		char const* option = Tcl_GetString(objv[i]);

		if (strcmp(option, "-shutdown") == 0)
		{
			int flag;
			if (Tcl_GetBooleanFromObj(ti, objv[i + 1], &flag) != TCL_OK)
				return setError(ti, "boolean value expected for '-shutdown'");
			shutdown = flag ? True : False;
		}
		else
		{
			return setError(ti, "unknown option '%s'", option);
		}
	}

	SmcRequestSaveYourself(m_connection, SmSaveGlobal, shutdown, SmInteractStyleAny, False, False);
	return TCL_OK;
}


static int
cmdSessionManager(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
		return setError(ti, "wrong # args; should be 'subcommand ?argument ...?'");

	char const* subcmd = Tcl_GetString(objv[1]);

	int rc = TCL_OK;

	if (strcmp(subcmd, "connect") == 0)
		rc = cmdConnect(ti, objc, objv);
	else if (strcmp(subcmd, "disconnect") == 0)
		rc = cmdDisconnect(ti, objc, objv);
	else if (strcmp(subcmd, "configure") == 0)
		rc = cmdConfigure(ti, objc, objv, false);
	else if (strcmp(subcmd, "get") == 0)
		rc = cmdGet(ti, objc, objv);
	else if (strcmp(subcmd, "saveyourself") == 0)
		rc = cmdSaveYourself(ti, objc, objv);
	else
		rc = setError(ti, "unknown command '%s'; must be 'connect' or 'configure'", subcmd);

	return rc;
}


Tcl_Command
tk::session_manager_init(Tcl_Interp* ti, char const* cmdName)
{
	return Tcl_CreateObjCommand(ti, m_tkCmdName = strdup(cmdName), cmdSessionManager, 0, 0);
}

#else

Tcl_Command
tk::session_manager_init(Tcl_Interp* ti, char const* cmdName)
{
	return 0;
}

#endif

// vi:set ts=3 sw=3:
