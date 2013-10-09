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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_base.h"

#include "sys_fam.h"

#include "m_hash.h"
#include "m_string.h"
#include "m_exception.h"

#include <tcl.h>

using namespace tcl;
using namespace sys;


namespace {

struct Monitor : public FileAlterationMonitor
{
	Monitor(mstl::string const& proc)
		:m_proc(Tcl_NewStringObj(proc, proc.size()))
		,m_ref(0)
	{
		Tcl_IncrRefCount(m_proc);

		if (m_changed == 0)
		{
			Tcl_IncrRefCount(m_changed = Tcl_NewStringObj("changed", -1));
			Tcl_IncrRefCount(m_deleted = Tcl_NewStringObj("deleted", -1));
			Tcl_IncrRefCount(m_created = Tcl_NewStringObj("created", -1));
			Tcl_IncrRefCount(m_umount  = Tcl_NewStringObj("umount",  -1));
		}
	}

	~Monitor() throw() { Tcl_DecrRefCount(m_proc); }

	void signal(unsigned id, Tcl_Obj* action, mstl::string const& path)
	{
		Tcl_Obj* pathObj	= Tcl_NewStringObj(path, path.size());
		Tcl_Obj* idObj		= Tcl_NewIntObj(id);

		Tcl_IncrRefCount(pathObj);
		Tcl_IncrRefCount(idObj);

		Tcl_Obj* objv[4] = { m_proc, idObj, action, pathObj };
		Tcl_EvalObjv(interp(), 4, objv, TCL_EVAL_GLOBAL);

		Tcl_DecrRefCount(pathObj);
		Tcl_DecrRefCount(idObj);
	}

	void signalId(unsigned id, mstl::string const& path) override			{}
	void signalChanged(unsigned id, mstl::string const& path) override	{ signal(id, m_changed, path); }
	void signalDeleted(unsigned id, mstl::string const& path) override	{ signal(id, m_deleted, path); }
	void signalCreated(unsigned id, mstl::string const& path) override	{ signal(id, m_created, path); }
	void signalUnmounted(unsigned id, mstl::string const& path) override	{ signal(id, m_umount, path); }

	Tcl_Obj* m_proc;
	unsigned m_ref;

	static Tcl_Obj* m_changed;
	static Tcl_Obj* m_deleted;
	static Tcl_Obj* m_created;
	static Tcl_Obj* m_umount;
};

Tcl_Obj* Monitor::m_changed	= 0;
Tcl_Obj* Monitor::m_deleted	= 0;
Tcl_Obj* Monitor::m_created	= 0;
Tcl_Obj* Monitor::m_umount		= 0;

typedef mstl::hash<mstl::string, Monitor*> Map;

} // namespace

static Map procMap;


static int
cmdOpen(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "::fam::open proc");
		return TCL_ERROR;
	}

	if (FileAlterationMonitor::isSupported())
	{
		mstl::string proc(Tcl_GetString(objv[1]));
		Monitor*& fam = procMap.find_or_insert(proc, 0);

		if (fam == 0)
		{
			fam = new Monitor(proc);

			if (!fam->valid())
			{
				mstl::string err(fam->error());
				delete fam;
				procMap.remove(proc);
				Tcl_SetResult(ti, const_cast<char*>(err.c_str()), TCL_VOLATILE);
				return TCL_ERROR;
			}
		}

		++fam->m_ref;
		setResult(objv[1]);
	}
	else
	{
		setResult("");
	}

	return TCL_OK;
}


static int
cmdClose(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "::fam::close proc");
		return TCL_ERROR;
	}

	mstl::string proc(Tcl_GetString(objv[1]));
	Monitor*& fam = procMap.find_or_insert(proc, 0);

	if (fam)
	{
		if (--fam->m_ref == 0)
		{
			delete fam;
			procMap.remove(proc);
		}
	}

	return TCL_OK;
}


static int
cmdAdd(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "::fam::add proc path");
		return TCL_ERROR;
	}

	mstl::string proc(Tcl_GetString(objv[1]));
	mstl::string path(Tcl_GetString(objv[2]));
	Monitor*& fam = procMap.find_or_insert(proc, 0);

	if (fam == 0)
		return error("::fam::add", nullptr, nullptr, "proc '%s' not open", proc.c_str());

	if (fam->add(path))
		return TCL_OK;

	Tcl_SetResult(ti, const_cast<char*>(fam->error().c_str()), TCL_VOLATILE);
	return TCL_ERROR;
}


static int
cmdRemove(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "::fam::remove proc path");
		return TCL_ERROR;
	}

	mstl::string proc(Tcl_GetString(objv[1]));
	mstl::string path(Tcl_GetString(objv[2]));
	Monitor*& fam = procMap.find_or_insert(proc, 0);

	if (fam == 0)
		return error("::fam::remove", nullptr, nullptr, "proc '%s' not open", proc.c_str());

	fam->remove(path);
	return TCL_OK;
}


namespace tcl {
namespace fam {

void
init(Tcl_Interp* ti)
{
	Tcl_Eval(ti, "namespace eval ::fam {}");

	createCommand(ti, "::fam::open",		cmdOpen);
	createCommand(ti, "::fam::close",	cmdClose);
	createCommand(ti, "::fam::add",		cmdAdd);
	createCommand(ti, "::fam::remove",	cmdRemove);
}

} // namespace fam
} // namespace tcl

/* vi:set ts=3 sw=3: */
