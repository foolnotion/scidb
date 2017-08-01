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
// Copyright: (C) 2009-2017 Gregor Cramer
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
#include "m_vector.h"
#include "m_utility.h"
#include "m_stdio.h"

#include <tcl.h>

#include <stdarg.h>
#include <stdlib.h>
#include <setjmp.h>
#include <ctype.h>
#include <assert.h>

extern "C" { int Treectrl_Init(Tcl_Interp*); }
extern "C" { int Inotify_Init(Tcl_Interp *interp); }
extern "C" { static Tcl_FreeProc* __tcl_static = TCL_STATIC; }

using namespace ::tcl;
using namespace ::db;

Tcl_Interp* tcl::bits::interp = nullptr;

static char m_buf[4096];

static Tcl_Obj* m_value[10];
static Tcl_Obj* m_blocked		= nullptr;
static Tcl_Obj* m_postponed	= nullptr;
static Tcl_Obj* m_loopLevel	= nullptr;
static Tcl_Obj* m_errMessage	= nullptr;
static Tcl_Obj* m_errResult	= nullptr;

static unsigned m_level = 0;


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


namespace tcl {

DString&
DString::append(int value)
{
	char buf[100];
	::snprintf(buf, sizeof(buf), "%d", value);
	return append(buf);
}


DString&
DString::append(unsigned value)
{
	char buf[100];
	::snprintf(buf, sizeof(buf), "%u", value);
	return append(buf);
}

} // namespace tcl


Tcl_Obj*
tcl::newObj(Tcl_Obj* obj1, Tcl_Obj* obj2)
{
	Tcl_Obj* objv[2] = { obj1 ? obj1 : tcl::newObj(), obj2 ? obj2 : tcl::newObj() };
	return tcl::newObj(2, objv);
}


Tcl_Obj*
tcl::newObj(mstl::vector<Tcl_Obj*> const& list)
{
	return newObj(list.size(), list.data());
}


Tcl_Obj*
tcl::newListObj(char const* s, unsigned len)
{
	M_REQUIRE(s || len == 0);

	if (len == 0)
		return newObj();
	
	Tcl_Obj* obj = newObj(s, len);
	int unused;

	Tcl_ListObjLength(NULL, obj, &unused); // converting to a list
	return obj;
}


Tcl_Obj*
tcl::newListObj(char const* s)
{
	return s ? newListObj(s, ::strlen(s)) : newObj();
}


bool
tcl::isInt(Tcl_Obj* obj)
{
	M_REQUIRE(obj);
	int value;
	return Tcl_GetIntFromObj(nullptr, obj, &value) == TCL_OK;
}


bool
tcl::isUnsigned(Tcl_Obj* obj)
{
	M_REQUIRE(obj);
	int value;
	return Tcl_GetIntFromObj(nullptr, obj, &value) == TCL_OK && value >= 0;
}


bool
tcl::isBoolean(Tcl_Obj* obj)
{
	M_REQUIRE(obj);
	int value;
	return Tcl_GetBooleanFromObj(nullptr, obj, &value) == TCL_OK;
}


int
tcl::asInt(Tcl_Obj* obj)
{
	M_REQUIRE(obj);

	int value;

	if (Tcl_GetIntFromObj(interp(), obj, &value) != TCL_OK)
		M_THROW(tcl::Error());
	
	return value;
}


unsigned
tcl::asUnsigned(Tcl_Obj* obj)
{
	M_REQUIRE(obj);

	int value;

	if (Tcl_GetIntFromObj(interp(), obj, &value) != TCL_OK)
		M_THROW(tcl::Error());
#if 0
	if (value < 0)
		M_THROW(tcl::Exception("positive integer expected"));
#endif
	
	return mstl::max(value, 0);
}


bool
tcl::asBoolean(Tcl_Obj* obj)
{
	M_REQUIRE(obj);

	int rc;

	if (Tcl_GetBooleanFromObj(interp(), obj, &rc) != TCL_OK)
		M_THROW(tcl::Error());

	return rc;
}


unsigned
tcl::getElements(Tcl_Obj* obj, Tcl_Obj**& objv)
{
	M_ASSERT(obj);

	int num;

	if (Tcl_ListObjGetElements(interp(), obj, &num, &objv) != TCL_OK)
		M_THROW(tcl::Error());
	
	return num;
}


Tcl_Obj*
tcl::addElement(Tcl_Obj*& list, Tcl_Obj* elem)
{
	M_REQUIRE(elem);

	if (!list)
		list = newObj();
	
	if (Tcl_ListObjAppendElement(interp(), list, elem) != TCL_OK)
		M_THROW(tcl::Error());
	
	return list;
}


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
	M_REQUIRE(result);
	Tcl_SetObjResult(interp(), tcl::newObj(result));
}


void
tcl::setResultV(char const* format, ...)
{
	M_REQUIRE(format);

	va_list args;
	va_start(args, format);
	char const* arg = va_arg(args, char*);
	mstl::vector<Tcl_Obj*> objv;

	for ( ; arg; arg = va_arg(args, char*))
		objv.push_back(newObj(arg, -1));

	va_end(args);
	Tcl_SetObjResult(interp(), newObj(objv));
}


int
tcl::usage(	char const* cmd, char const* subcmd, char const* subsubcmd,
				char const** options, char const** args)
{
	if (*options == nullptr)
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
			if (*args)
			{
				str += " ";
				str += *args;
			}
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

	Tcl_AppendResult(interp(), buf, nullptr);
}


void
tcl::setResult(Tcl_Obj* obj)
{
	M_REQUIRE(obj);
	Tcl_SetObjResult(interp(), obj);
}


void
tcl::setResult(int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(objc == 0 || objv);
	Tcl_SetObjResult(interp(), Tcl_NewListObj(objc, objv));

}


void
tcl::setResult(int result)
{
	Tcl_SetObjResult(interp(), tcl::newObj(result));
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
	Tcl_SetObjResult(interp(), tcl::newObj(s));
}


void
tcl::setResult(mstl::vector<Tcl_Obj*> const& list)
{
	Tcl_SetObjResult(interp(), Tcl_NewListObj(list.size(), list.data()));
}


static void
decrRefCount(unsigned objc, Tcl_Obj** objv)
{
	for (unsigned i = 0; i < objc; ++i)
		tcl::decrRef(objv[i]);
}


void
tcl::setGlobalVar(Tcl_Obj* var, Tcl_Obj* value)
{
	M_REQUIRE(var);
	M_REQUIRE(value);

	if (!Tcl_ObjSetVar2(interp(), var, nullptr, value, TCL_GLOBAL_ONLY))
		M_THROW(tcl::Error());
}


Tcl_Obj*
tcl::getGlobalVar(Tcl_Obj* var)
{
	M_REQUIRE(var);

	Tcl_Obj* value = Tcl_ObjGetVar2(interp(), var, nullptr, TCL_GLOBAL_ONLY);

	if (!value)
		M_THROW(tcl::Error());
	
	return value;
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
	fprintf(stderr, "%s\n", msg.c_str());

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

		tcl::incrRef(objv[0] = tcl::newObj(cmd));
		char const* arg = va_arg(args, char*);

		for ( ; arg; ++objc, arg = va_arg(args, char*))
		{
			M_ASSERT(objc < MaxArgs);
			tcl::incrRef(objv[objc] = tcl::newObj(arg));
		}

		objv[objc] = nullptr;
		result = info.objProc(info.objClientData, interp(), objc, objv);
		decrRefCount(objc, objv);
	}
	else
	{
		char const*	argv[MaxArgs + 1];
		unsigned		argc = 1;

		char const* arg = va_arg(args, char*);

		for ( ; arg; ++argc, arg = va_arg(args, char*))
		{
			M_ASSERT(argc < MaxArgs);
			argv[argc] = arg;
		}

		argv[argc] = nullptr;
		result = info.proc(info.clientData, interp(), argc, argv);
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

		tcl::incrRef(objv[0] = cmd);
		Tcl_Obj* arg = va_arg(args, Tcl_Obj*);

		for ( ; arg; ++objc, arg = va_arg(args, Tcl_Obj*))
		{
			// simple check whether this is a Tcl object.
			M_ASSERT(0 <= arg->refCount && arg->refCount <= 10000);
			M_ASSERT(objc < MaxArgs);
			objv[objc] = tcl::incrRef(arg);
		}

		objv[objc] = nullptr;
		result = info.objProc(info.objClientData, interp(), objc, objv);
		Tcl_GetStringResult(interp());
		decrRefCount(objc, objv);
	}
	else
	{
		Tcl_Obj*		objv[MaxArgs + 1];
		char const*	argv[MaxArgs + 1];
		unsigned		argc = 1;

		Tcl_Obj* arg = va_arg(args, Tcl_Obj*);

		tcl::incrRef(cmd);

		for ( ; arg; ++argc, arg = va_arg(args, Tcl_Obj*))
		{
			// simple check whether this is a Tcl object.
			M_ASSERT(0 <= arg->refCount && arg->refCount <= 10000);
			M_ASSERT(argc < MaxArgs);

			objv[argc] = tcl::incrRef(arg);
			argv[argc] = Tcl_GetString(arg);
		}

		argv[argc] = nullptr;
		result = info.proc(info.clientData, interp(), argc, argv);
		decrRefCount(argc, objv);
		tcl::decrRef(cmd);
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

	if (rc == TCL_OK)
		Tcl_RestoreResult(interp(), &state);
	else
		M_THROW(tcl::Error());

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

	if (rc == TCL_OK)
		Tcl_RestoreResult(interp(), &state);
	else
		M_THROW(tcl::Error());

	return rc;
}


int
tcl::invoke(char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_SavedResult state;
	Tcl_SaveResult(interp(), &state);

	int rc;

	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	if (arg1 && arg2)
		rc = invoke(callee, cmd, arg1, arg2, list, nullptr);
	else if (arg1)
		rc = invoke(callee, cmd, arg1, list, nullptr);
	else
		rc = invoke(callee, cmd, list, nullptr);

	if (rc == TCL_OK)
		Tcl_RestoreResult(interp(), &state);

	return rc;
}


Tcl_Obj*
tcl::call(char const* callee, char const* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	return rc == TCL_OK ? tcl::incrRef(tcl::result()) : nullptr;
}


Tcl_Obj*
tcl::call(char const* callee, Tcl_Obj* cmd, ...)
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	va_list args;
	va_start(args, cmd);
	int rc = ::vinvoke(callee, cmd, args);
	va_end(args);

	return rc == TCL_OK ? tcl::incrRef(tcl::result()) : nullptr;
}


Tcl_Obj*
tcl::call(	char const* callee,
				Tcl_Obj* cmd,
				int objc, Tcl_Obj* const objv[])
{
	M_REQUIRE(callee);
	M_REQUIRE(cmd);

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, list, nullptr);

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

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, list, nullptr);

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

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, list, nullptr);

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

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, arg3, list, nullptr);

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

	Tcl_Obj* result;
	Tcl_Obj*	list = Tcl_NewListObj(objc, objv);

	result = call(callee, cmd, arg1, arg2, arg3, arg4, list, nullptr);

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

	objs[0] = tcl::newObj("%IO-Error%");
	objs[1] = tcl::newObj(file);
	objs[2] = tcl::newObj(error);
	objs[3] = tcl::newObj(message);

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

	objs[0] = tcl::newObj("%Interrupted%");
	objs[1] = tcl::newObj(count);

	setResult(Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	return TCL_ERROR;
}


static int
GetErrorCode(::db::IOException const& exc)
{
	char const* file	= nullptr;	// avoids gcc warning
	char const* error	= nullptr;	// avoids gcc warning

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

	return tcl::ioError(file, error, exc.what());
}


static Tcl_Obj*
GetErrorInfo(Tcl_Interp* ti)
{
	Tcl_Obj* key;
	Tcl_Obj* errCode;
	Tcl_Obj* errOpts = tcl::incrRef(Tcl_GetReturnOptions(ti, TCL_ERROR));

	key = tcl::incrRef(tcl::newObj("-errorcode"));
	Tcl_DictObjGet(nullptr, errOpts, key, &errCode);
	tcl::decrRef(key);

	Tcl_Obj* stackTrace;

	key = tcl::incrRef(tcl::newObj("-errorstack"));
	Tcl_DictObjGet(nullptr, errOpts, key, &stackTrace);
	tcl::decrRef(key);

#if 0
	if (stack)
	{
		Tcl_Obj **elems;
		unsigned n = tcl::getElements(stackTrace, elems);

		for (unsigned j = 0; j < n; j += 2)
		{
			if (	::strcmp(Tcl_GetString(elems[j]), "INNER") == 0
				|| ::strcmp(Tcl_GetString(elems[j]), "CALL") == 0)
			{
				char const* s = Tcl_GetString(elems[j + 1]);

				if (::strncmp(s, "invoksStk", 9) != 0)
				{
					if (!stack->empty())
						*stack += '\n';
					*stack += s;
				}
			}
		}
	}
#endif

	tcl::decrRef(errOpts);
	return tcl::incrRef(errCode);
}


static Tcl_Obj*
valueObj(unsigned value)
{
	return value < U_NUMBER_OF(m_value) ? m_value[value] : tcl::newObj(value);
}


static int
safeCall(void* clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static Tcl_Obj* savedCode = nullptr;
	static int savedRC = TCL_OK;

	Tcl_Obj* blocked = tcl::incrRef(Tcl_ObjGetVar2(ti, m_blocked, nullptr, TCL_GLOBAL_ONLY));
	int rc;

	if (m_level++ == 0)
	{
		savedCode = nullptr;
		savedRC = TCL_OK;
	}

	tcl::setGlobalVar(m_loopLevel, valueObj(m_level));
	tcl::setGlobalVar(m_blocked, m_value[1]);
	
	try
	{
		rc = Cast(clientData).proc_(nullptr, ti, objc, objv);
	}
	catch (tcl::Error const& exc)
	{
		if (mstl::exception::isEnabled())
		{
			savedCode = GetErrorInfo(ti);
			mstl::exception::setDisabled();
			tcl::setGlobalVar(m_errMessage, tcl::newObj(exc.report()));
			tcl::setGlobalVar(m_errResult, tcl::result());
		}
		rc = TCL_ERROR;
	}
	catch (tcl::InterruptException const& exc)
	{
		mstl::exception::setDisabled();
		rc = tcl::interrupt(exc.count());
	}
	catch (::db::IOException const& exc)
	{
		mstl::exception::setDisabled();
		rc = GetErrorCode(exc);
	}
	catch (mstl::exception const& exc)
	{
		if (mstl::exception::isEnabled())
		{
			tcl::setGlobalVar(m_errMessage, tcl::newObj(exc.report()));
			tcl::setGlobalVar(m_errResult, tcl::newObj(exc.what()));
			savedCode = GetErrorInfo(ti);
			mstl::exception::setDisabled();
		}
		rc = TCL_ERROR;
	}

	tcl::setGlobalVar(m_blocked, blocked);
	tcl::decrRef(blocked);

	m_level -= 1;

	if (rc != TCL_OK)
		savedRC = rc;
	else if (savedRC != TCL_OK)
		rc = savedRC;
	
	if (m_level == 0)
	{
		if (tcl::asBoolean(tcl::getGlobalVar(m_postponed)))
			Tcl_DoWhenIdle(callRemoteUpdate, nullptr);

		if (savedCode)
		{
			Tcl_SetObjErrorCode(ti, savedCode);
			tcl::decrRef(savedCode);
		}

		mstl::exception::setDisabled(false);
	}
	else if (rc != TCL_OK)
	{
		tcl::setError("INTERMEDIATE");
	}

	tcl::setGlobalVar(m_loopLevel, valueObj(m_level));
	return rc;
}


Tcl_Command
tcl::createCommand(Tcl_Interp* ti, char const* cmdName, Tcl_ObjCmdProc* proc)
{
	M_ASSERT(sizeof(Tcl_ObjCmdProc*) == sizeof(void*));	// cannot fail on modern platforms!?
	return Tcl_CreateObjCommand(ti, cmdName, safeCall, Cast(proc).p_, nullptr);
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
	Tcl_Eval(ti, "namespace eval ::scidb::intern {}");

	for (unsigned i = 0; i < U_NUMBER_OF(m_value); ++i)
		tcl::incrRef(::m_value[i] = tcl::newObj(i));
	tcl::incrRef(::m_blocked = tcl::newObj("scidb::intern::blocked"));
	tcl::incrRef(::m_postponed = tcl::newObj("scidb::intern::postponed"));
	tcl::incrRef(::m_loopLevel = tcl::newObj("scidb::intern::looplevel"));
	tcl::incrRef(::m_errMessage = tcl::newObj("scidb::intern::errmsg"));
	tcl::incrRef(::m_errResult = tcl::newObj("scidb::intern::errresult"));

	Tcl_ObjSetVar2(ti, m_blocked, nullptr, m_value[0], TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(ti, m_postponed, nullptr, m_value[0], TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(ti, m_loopLevel, nullptr, m_value[0], TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(ti, m_errMessage, nullptr, tcl::newObj(), TCL_GLOBAL_ONLY);
	Tcl_ObjSetVar2(ti, m_errResult, nullptr, tcl::newObj(), TCL_GLOBAL_ONLY);

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
