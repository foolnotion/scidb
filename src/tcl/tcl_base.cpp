// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
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

#include "tcl_base.h"
#include "tcl_exception.h"
#include "tcl_database.h"
#include "tcl_application.h"
#include "tcl_position.h"

#include "db_exception.h"

#include "m_string.h"
#include "m_stdio.h"

#include <tcl.h>
#include <stdarg.h>
#include <stdlib.h>
#include <setjmp.h>
#include <assert.h>

extern "C" { int Treectrl_Init(Tcl_Interp*); }
extern "C" { int Inotify_Init(Tcl_Interp *interp); }
extern "C" { static Tcl_FreeProc* __tcl_static = TCL_STATIC; }

using namespace ::tcl;
using namespace ::db;

Tcl_Interp* tcl::bits::interp = 0;

static char m_buf[4096];

static Tcl_Obj* m_value_1		= 0;
static Tcl_Obj* m_blocked		= 0;
static Tcl_Obj* m_postponed	= 0;

static unsigned m_level = 0;

static char const* TooManyArguments = "Too many arguments (> 10) to tcl::invoke()";


namespace {

union Cast
{
	Cast(void* p) :p_(p) {}
	Cast(Tcl_ObjCmdProc* proc) :proc_(proc) {}

	void*					p_;
	Tcl_ObjCmdProc*	proc_;
};

} // namespace


bool tcl::updateTreeIsBlocked() { return m_level > 1; }


int
tcl::uniqueMatch(char const* option, char const** options)
{
	assert(option);
	assert(options);

	// Check each entry in turn:
	for (int i = 0; *options; ++options, ++i)
	{
		if (::strcmp(option, *options) == 0)
			return i;
	}

	return -1;
}


int
tcl::uniqueMatchObj(Tcl_Obj* obj, char const** options)
{
	return uniqueMatch(Tcl_GetString(obj), options);
}


int
tcl::error(	char const* cmd, char const* subcmd, char const* subsubcmd,
				char const* format,
				va_list& ap)
{
	char fmt[1024];

	if (cmd)
	{
		if (!subcmd)
			::snprintf(fmt, sizeof(fmt), "%s: %s", cmd, format);
		else if (!subsubcmd)
			::snprintf(fmt, sizeof(fmt), "%s %s: %s", cmd, subcmd, format);
		else
			::snprintf(fmt, sizeof(fmt), "%s %s %s: %s", cmd, subcmd, subsubcmd, format);

		format = fmt;
	}

	::vsnprintf(::m_buf, sizeof(::m_buf), format, ap);
	Tcl_SetResult(interp(), ::m_buf, __tcl_static);

	return TCL_ERROR;
}


int
tcl::error( char const* cmd, char const* subcmd, char const* subsubcmd,
				char const* format, ...)
{
	va_list args;
	va_start(args, format);
	int rc = error(cmd, subcmd, subsubcmd, format, args);
	va_end(args);
	return rc;
}


void
tcl::setResult(char const* result)
{
	Tcl_SetObjResult(interp(), Tcl_NewStringObj(result,  -1));
}


int
tcl::usage(	char const* cmd, char const* subcmd, char const* subsubcmd,
				char const** options, char const** args)
{
	if (*options == 0)
		return tcl::error(cmd, subcmd, subsubcmd, "no options required");

	mstl::string str;
	mstl::string command;

	if (cmd)
		command += cmd;

	if (subcmd)
	{
		command += ' ';
		command += subcmd;
	}

	if (subsubcmd)
	{
		command += ' ';
		command += subsubcmd;
	}

	command += ": ";

	if (args)
	{
		for ( ; *options; ++options, ++args)
		{
			str += command;
			str += *options;
			str += " ";
			str += *args;
			str += '\n';
		}
	}
	else
	{
		for ( ; *options; ++options)
		{
			str += command;
			str += *options;
			str += '\n';
		}
	}

	if (!str.empty() && str.back() == '\n')
		str.set_size(str.size() - 1);

	setResult(str.c_str());

	return TCL_ERROR;
}


void
tcl::appendResult(char const* format, ...)
{
	char buf[4096];
	va_list args;

	va_start(args, format);
	vsnprintf(buf, sizeof(buf), format, args);
	va_end(args);

	Tcl_AppendResult(interp(), buf, 0);
}


void
tcl::setResult(Tcl_Obj* obj)
{
	Tcl_IncrRefCount(obj);
	Tcl_SetObjResult(interp(), obj);
	Tcl_DecrRefCount(obj);
}


void
tcl::setResult(int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);
	Tcl_IncrRefCount(list);
	Tcl_SetObjResult(interp(), list);
	Tcl_DecrRefCount(list);

}


void
tcl::setResult(int result)
{
	Tcl_SetObjResult(interp(), Tcl_NewIntObj(result));
}


void
tcl::setResult(unsigned result)
{
	Tcl_SetObjResult(interp(), Tcl_NewWideIntObj(result));
}


void
tcl::setResult(long result)
{
	Tcl_SetObjResult(interp(), Tcl_NewLongObj(result));
}


void
tcl::setResult(unsigned long result)
{
	Tcl_SetObjResult(interp(), Tcl_NewWideIntObj(result));
}


void
tcl::setResult(bool result)
{
	Tcl_SetObjResult(interp(), Tcl_NewBooleanObj(result));
}


void
tcl::setResult(mstl::string const& s)
{
	Tcl_SetObjResult(interp(), Tcl_NewStringObj(s, s.size()));
}


static void
decrRefCount(unsigned objc, Tcl_Obj** objv)
{
	for (unsigned i = 0; i < objc; ++i)
		Tcl_DecrRefCount(objv[i]);
}


static void
invocationError(char const* callee, int argc, char const* argv[])
{
	if (callee == 0)
		return;

	mstl::string msg;
	msg += " [";
	msg += callee;
	msg += "] invocation failed:\n";

	for (int i = 0; i < argc; ++i)
	{
		msg += argv[i];
		if (i < argc - 1)
			msg += ' ';
	}

	Tcl_AddErrorInfo(interp(), msg.c_str());
	Tcl_BackgroundError(interp());
}


static void
invocationError(char const* callee, int objc, Tcl_Obj* const objv[])
{
	if (callee == 0)
		return;

	mstl::string msg;
	msg += " [";
	msg += callee;
	msg += "] invocation failed:\n";

	for (int i = 0; i < objc; ++i)
	{
		msg += Tcl_GetString(objv[i]);
		if (i < objc - 1)
			msg += ' ';
	}

	Tcl_AddErrorInfo(interp(), msg.c_str());
	Tcl_BackgroundError(interp());
}


static bool
getCommandInfo(char const* cmd, Tcl_CmdInfo& info)
{
	if (Tcl_GetCommandInfo(interp(), cmd, &info))
		return true;

	mstl::string msg;
	msg += "Tcl_GetCommandInfo failed: unknown command '";
	msg += cmd;
	msg += "'";
	Tcl_SetObjResult(interp(), Tcl_NewStringObj(msg.c_str(), msg.size()));

	return false;
}


static int
vinvoke(char const* callee, char const* cmd, va_list args)
{
	static unsigned const MaxArgs = 15;

	Tcl_CmdInfo info;
	if (!getCommandInfo(cmd, info))
		return TCL_ERROR;

	int result;

	if (info.isNativeObjectProc)
	{
		Tcl_Obj*	objv[MaxArgs + 1];
		unsigned	objc = 1;

		Tcl_IncrRefCount(objv[0] = Tcl_NewStringObj(cmd, -1));
		char const* arg = va_arg(args, char*);

		for ( ; arg; ++objc, arg = va_arg(args, char*))
		{
			if (objc == MaxArgs)
			{
				decrRefCount(objc, objv);
				TCL_RAISE(TooManyArguments);
			}

			Tcl_IncrRefCount(objv[objc] = Tcl_NewStringObj(arg, -1));
		}

		objv[objc] = 0;
		result = info.objProc(info.objClientData, interp(), objc, objv);
		if (result != TCL_OK)
			invocationError(callee, objc, objv);
		decrRefCount(objc, objv);
	}
	else
	{
		char const*	argv[MaxArgs + 1];
		unsigned		argc = 1;

		char const* arg = va_arg(args, char*);

		for ( ; arg; ++argc, arg = va_arg(args, char*))
		{
			if (argc == MaxArgs)
				TCL_RAISE(TooManyArguments);

			argv[argc] = arg;
		}

		argv[argc] = 0;
		result = info.proc(info.clientData, interp(), argc, argv);
		if (result != TCL_OK)
			invocationError(callee, argc, argv);
	}

	return result;
}


static int
vinvoke(char const* callee, Tcl_Obj* cmd, va_list args)
{
	static unsigned const MaxArgs = 15;

	Tcl_CmdInfo info;
	if (!getCommandInfo(Tcl_GetString(cmd), info))
		return TCL_ERROR;

	int result;

	if (info.isNativeObjectProc)
	{
		Tcl_Obj*	objv[MaxArgs + 1];
		unsigned	objc = 1;

		Tcl_IncrRefCount(objv[0] = cmd);
		Tcl_Obj* arg = va_arg(args, Tcl_Obj*);

		for ( ; arg; ++objc, arg = va_arg(args, Tcl_Obj*))
		{
			if (objc == MaxArgs)
				TCL_RAISE(TooManyArguments);

			Tcl_IncrRefCount(objv[objc] = arg);
		}

		objv[objc] = 0;
		result = info.objProc(info.objClientData, interp(), objc, objv);
		Tcl_GetStringResult(interp());
		decrRefCount(objc, objv);
		if (result != TCL_OK)
			invocationError(callee, objc, objv);
	}
	else
	{
		Tcl_Obj*		objv[MaxArgs + 1];
		char const*	argv[MaxArgs + 1];
		unsigned		argc = 1;

		Tcl_Obj* arg = va_arg(args, Tcl_Obj*);

		Tcl_IncrRefCount(cmd);

		for ( ; arg; ++argc, arg = va_arg(args, Tcl_Obj*))
		{
			if (argc == MaxArgs)
			{
				decrRefCount(argc, objv);
				Tcl_DecrRefCount(cmd);
				TCL_RAISE(TooManyArguments);
			}

			Tcl_IncrRefCount(objv[argc] = arg);
			argv[argc] = Tcl_GetString(arg);
		}

		argv[argc] = 0;
		result = info.proc(info.clientData, interp(), argc, argv);
		decrRefCount(argc, objv);
		Tcl_DecrRefCount(cmd);
		if (result != TCL_OK)
			invocationError(callee, argc, argv);
	}

	return result;
}


int
tcl::invoke(char const* callee, char const* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	Tcl_RestoreResult(interp(), &state);
	return rc;
}


int
tcl::invoke(char const* callee, Tcl_Obj* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	Tcl_RestoreResult(interp(), &state);
	return rc;
}


int
tcl::invoke(char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	int rc;

	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);
	Tcl_IncrRefCount(list);

	if (arg1 && arg2)
		rc = invoke(callee, cmd, arg1, arg2, list, nullptr);
	else if (arg1)
		rc = invoke(callee, cmd, arg1, list, nullptr);
	else
		rc = invoke(callee, cmd, list, nullptr);

	Tcl_DecrRefCount(list);
	return rc;
}


Tcl_Obj*
tcl::call(char const* callee, char const* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	Tcl_Obj* result = rc == TCL_OK ? Tcl_GetObjResult(interp()) : 0;
	if (result)
		Tcl_IncrRefCount(result);
	Tcl_RestoreResult(interp(), &state);

	if (rc != TCL_OK)
		invocationError(callee, 1, &cmd);

	return result;
}


Tcl_Obj*
tcl::call(char const* callee, Tcl_Obj* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	Tcl_Obj* result = rc == TCL_OK ? Tcl_GetObjResult(interp()) : 0;
	if (result)
		Tcl_IncrRefCount(result);
	Tcl_RestoreResult(interp(), &state);

	if (rc != TCL_OK)
		invocationError(callee, 1, &cmd);

	return result;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, list, nullptr);

	Tcl_RestoreResult(interp(), &state);
	return result;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);
	M_REQUIRE(arg1);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, list, nullptr);

	Tcl_RestoreResult(interp(), &state);
	return result;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);
	M_REQUIRE(arg1);
	M_REQUIRE(arg2);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, list, nullptr);

	Tcl_RestoreResult(interp(), &state);
	return result;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2, Tcl_Obj* arg3,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);
	M_REQUIRE(arg1);
	M_REQUIRE(arg2);
	M_REQUIRE(arg3);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, arg3, list, nullptr);

	Tcl_RestoreResult(interp(), &state);
	return result;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2, Tcl_Obj* arg3, Tcl_Obj* arg4,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);
	M_REQUIRE(arg1);
	M_REQUIRE(arg2);
	M_REQUIRE(arg3);
	M_REQUIRE(arg4);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, arg3, arg4, list, nullptr);

	Tcl_RestoreResult(interp(), &state);
	return result;
}


static void
callRemoteUpdate(ClientData)
{
	invoke(__func__, "::remote::update", nullptr);
}


int
tcl::ioError(mstl::string const& file, mstl::string const& error, mstl::string const& message)
{
	Tcl_Obj* objs[4];

	objs[0] = Tcl_NewStringObj("%IO-Error%", -1);
	objs[1] = Tcl_NewStringObj(file, -1);
	objs[2] = Tcl_NewStringObj(error, -1);
	objs[3] = Tcl_NewStringObj(message, -1);

	setResult(Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	return TCL_ERROR;
}


/*
 * Call this C function in case of failed assertions.
 */

extern "C" void assertionFailed(char const* expr,  char const* file, unsigned line, char const* func);

::jmp_buf assertJumpBuf;


void
assertionFailed(char const* expr, char const* file, unsigned line, char const* func)
{
	fprintf(stderr, "assertion failed: %s (%s:%u) [%s]\n", expr, file, line, func);
	Tcl_SetObjResult(
		tcl::bits::interp,
		Tcl_ObjPrintf("assertion failed: %s (%s:%u) [%s]", expr, file, line, func));
	longjmp(::assertJumpBuf, 1);
}


int
tcl::interrupt(int count)
{
	Tcl_Obj* objs[2];

	objs[0] = Tcl_NewStringObj("%Interrupted%", -1);
	objs[1] = Tcl_NewIntObj(count);

	setResult(Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	return TCL_ERROR;
}


static int
safeCall(void* clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int rc;

	++m_level;

	Tcl_Obj* blocked = Tcl_ObjGetVar2(interp(), m_blocked, 0, TCL_GLOBAL_ONLY);

	if (blocked)
	{
		Tcl_IncrRefCount(blocked);
		Tcl_ObjSetVar2(interp(), m_blocked, 0, m_value_1, TCL_GLOBAL_ONLY);
	}

	try
	{
		rc = Cast(clientData).proc_(0, ti, objc, objv);
	}
	catch (tcl::Error const&)
	{
		rc = TCL_ERROR;
	}
	catch (tcl::InterruptException const& exc)
	{
		rc = tcl::interrupt(exc.count());
	}
	catch (::db::IOException const& exc)
	{
		char const* file	= 0;	// avoids gcc warning
		char const* error	= 0;	// avoids gcc warning

		switch (exc.fileType())
		{
			case IOException::Unspecified:	file = "Unspecified"; break;
			case IOException::Index:			file = "Index"; break;
			case IOException::Game:				file = "Game"; break;
			case IOException::Namebase:		file = "Namebase"; break;
			case IOException::Annotation:		file = "Annotation"; break;
			case IOException::PgnFile:			file = "PGN File"; break;
			case IOException::BookFile:		file = "Book File"; break;
		}

		switch (exc.errorType())
		{
			case IOException::Unknown_Error_Type:		error = "UnknownErrorType"; break;
			case IOException::Create_Failed:				error = "CreateFailed"; break;
			case IOException::Open_Failed:				error = "OpenFailed"; break;
			case IOException::Read_Only:					error = "ReadOnly"; break;
			case IOException::Unknown_Version:			error = "UnknownVersion"; break;
			case IOException::Unexpected_Version:		error = "UnexpectedVersion"; break;
			case IOException::Corrupted:					error = "Corrupted"; break;
			case IOException::Write_Failed:				error = "WriteFailed"; break;
			case IOException::Invalid_Data:				error = "InvalidData"; break;
			case IOException::Read_Error:					error = "ReadError"; break;
			case IOException::Encoding_Failed:			error = "EncodingFailed"; break;
			case IOException::Max_File_Size_Exceeded:	error = "MaxFileSizeExceeded"; break;
			case IOException::Load_Failed:				error = "LoadFailed"; break;
			case IOException::Not_Original_Version:	error = "NotOriginalVersion"; break;
			case IOException::Cannot_Create_Thread:	error = "CannotCreateThread"; break;
		}

		rc = tcl::ioError(file, error, exc.what());
	}
	catch (mstl::exception const& exc)
	{
		setResult(exc.what());
		rc = TCL_ERROR;
	}

	if (blocked)
	{
		Tcl_ObjSetVar2(interp(), m_blocked, 0, blocked, TCL_GLOBAL_ONLY);
		Tcl_DecrRefCount(blocked);

		{
			int rc;
			Tcl_GetBooleanFromObj(interp(), Tcl_ObjGetVar2(interp(), m_postponed, 0, TCL_GLOBAL_ONLY), &rc);
			if (rc)
				Tcl_DoWhenIdle(callRemoteUpdate, 0);
		}
	}

	--m_level;
	return rc;
}


Tcl_Command
tcl::createCommand(Tcl_Interp* ti, char const* cmdName, Tcl_ObjCmdProc* proc)
{
	M_ASSERT(sizeof(Tcl_ObjCmdProc*) == sizeof(void*));	// cannot fail on modern platforms!?
	return Tcl_CreateObjCommand(ti, cmdName, safeCall, Cast(proc).p_, 0);
}


Tcl_Obj*
tcl::objectFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	return objv[index];
}


char const*
tcl::stringFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	return Tcl_GetString(objv[index]);
}


int
tcl::intFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	int value;

	if (Tcl_GetIntFromObj(interp(), objv[index], &value) != TCL_OK)
		TCL_RAISE("integer expected as %u. argument to %s", index, Tcl_GetString(objv[0]));

	return value;
}


int64_t
tcl::wideIntFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	Tcl_WideInt value;

	if (Tcl_GetWideIntFromObj(interp(), objv[index], &value) != TCL_OK)
		TCL_RAISE("integer expected as %u. argument to %s", index, Tcl_GetString(objv[0]));

	return value;
}


unsigned
tcl::unsignedFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	int value;

	if (Tcl_GetIntFromObj(interp(), objv[index], &value) != TCL_OK || value < 0)
		TCL_RAISE("positive integer expected as %u. argument to %s", index, Tcl_GetString(objv[0]));

	return value;
}


long
tcl::longFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	long value;

	if (Tcl_GetLongFromObj(interp(), objv[index], &value) != TCL_OK)
		TCL_RAISE("integer expected as %u. argument to %s", index, Tcl_GetString(objv[0]));

	return value;
}


bool
tcl::boolFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	M_REQUIRE(objc > 0);

	if (index >= objc)
		TCL_RAISE("Wrong number of arguments to %s", Tcl_GetString(objv[0]));

	int value;

	if (Tcl_GetBooleanFromObj(interp(), objv[index], &value) != TCL_OK)
		TCL_RAISE("boolean value expected as %u. argument to %s", index, Tcl_GetString(objv[0]));

	return value;
}


namespace tcl {

namespace app			{ void init(Tcl_Interp* interp); }
namespace progress	{ void init(Tcl_Interp* interp); }
namespace db			{ void init(Tcl_Interp* interp); }
namespace view			{ void init(Tcl_Interp* interp); }
namespace game			{ void init(Tcl_Interp* interp); }
namespace tree			{ void init(Tcl_Interp* interp); }
namespace pos			{ void init(Tcl_Interp* interp); }
namespace board		{ void init(Tcl_Interp* interp); }
namespace misc			{ void init(Tcl_Interp* interp); }
namespace crosstable	{ void init(Tcl_Interp* interp); }
namespace zlib			{ void init(Tcl_Interp* interp); }
namespace fam			{ void init(Tcl_Interp* interp); }
namespace engine		{ void init(Tcl_Interp* interp); }
namespace player		{ void init(Tcl_Interp* interp); }

} // namespace tcl


void
tcl::init(Tcl_Interp* ti)
{
	::tcl::bits::interp = ti;

	Treectrl_Init(ti);

	Tcl_Eval(ti, "namespace eval ::scidb {}");
	Tcl_Eval(ti, "namespace eval ::scidb::dir {}");
	Tcl_Eval(ti, "namespace eval ::scidb::db {}");
	Tcl_Eval(ti, "namespace eval ::scidb::view {}");
	Tcl_Eval(ti, "namespace eval ::scidb::game {}");
	Tcl_Eval(ti, "namespace eval ::scidb::tree {}");
	Tcl_Eval(ti, "namespace eval ::scidb::pos {}");
	Tcl_Eval(ti, "namespace eval ::scidb::app {}");
	Tcl_Eval(ti, "namespace eval ::scidb::board {}");
	Tcl_Eval(ti, "namespace eval ::scidb::misc {}");
	Tcl_Eval(ti, "namespace eval ::scidb::crosstable {}");
	Tcl_Eval(ti, "namespace eval ::scidb::engine {}");

	Tcl_IncrRefCount(::m_value_1 = Tcl_NewIntObj(1));
	Tcl_IncrRefCount(::m_blocked = Tcl_NewStringObj("::remote::blocked", -1));
	Tcl_IncrRefCount(::m_postponed = Tcl_NewStringObj("::remote::postponed", -1));

	app::init(ti);
	progress::init(ti);
	db::init(ti);
	view::init(ti);
	game::init(ti);
	tree::init(ti);
	pos::init(ti);
	board::init(ti);
	misc::init(ti);
	crosstable::init(ti);
	zlib::init(ti);
	fam::init(ti);
	engine::init(ti);
	player::init(ti);
}

// vi:set ts=3 sw=3:
