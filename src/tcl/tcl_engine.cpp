// ======================================================================
// Author : $Author$
// Version: $Revision: 385 $
// Date   : $Date: 2012-07-27 21:44:01 +0200 (Fri, 27 Jul 2012) $
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
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_base.h"

#include "app_engine.h"

#include "db_player.h"

#include "m_ofstream.h"
#include "m_string.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <tcl.h>

using namespace db;
using namespace tcl;


static char const* CmdInfo		= "::scidb::engine::info";
static char const* CmdList		= "::scidb::engine::list";
static char const* CmdLog		= "::scidb::engine::log";
static char const* CmdProbe	= "::scidb::engine::probe";


namespace {

class Log
{
public:

	Log(FILE* fp, Tcl_Obj* cmd, Tcl_Obj* arg)
		:m_stream(fp)
		,m_cmd(cmd)
		,m_arg(arg)
	{
		m_stream.set_unbuffered();
		m_stream.set_text();

		Tcl_IncrRefCount(m_cmd);
		Tcl_IncrRefCount(m_arg);
	}

	~Log()
	{
		Tcl_DecrRefCount(m_cmd);
		Tcl_DecrRefCount(m_arg);
	}

	void write(char const* s, size_t len)
	{
		Tcl_Obj* str = Tcl_NewStringObj(s, len);

		Tcl_IncrRefCount(str);
		invoke(__func__, m_cmd, m_arg, str, nullptr);
		Tcl_DecrRefCount(str);
	}

	mstl::ostream* stream() { return &m_stream; }

private:

	mstl::ofstream	m_stream;
	Tcl_Obj*			m_cmd;
	Tcl_Obj*			m_arg;
};


class Engine : public app::Engine
{
public:

	Engine(Protocol protocol, mstl::string const& command, mstl::string const& directory)
		:app::Engine(protocol, command, directory)
	{
	}

	void updateInfo() override {}
};

}


static Log* m_log = 0;


static __ssize_t
read(void* cookie, char* buf, size_t len)
{
	M_ASSERT(!"unexpected call");
	return -1;
}


static int
seek(void* cookie, __off64_t* pos, int whence)
{
	M_ASSERT(!"unexpected call");
	return -1;
}


static int
close(void* cookie)
{
	return 0;
}


static __ssize_t
write(void* cookie, char const* buf, size_t len)
{
	M_ASSERT(m_log);
	m_log->write(buf, len);
	return len;
}


static int
cmdLog(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static cookie_io_functions_t Cookie = { read, write, seek, close };

	char const* subcmd = stringFromObj(objc, objv, 1);

	if (strcmp(subcmd, "open") == 0)
	{
		if (m_log)
			return error(CmdLog, subcmd, 0, "log is already open");

		m_log = new Log(	fopencookie(0, "wb", Cookie),
								objectFromObj(objc, objv, 2),
								objectFromObj(objc, objv, 3));
	}
	else if (strcmp(subcmd, "close") == 0)
	{
		delete m_log;
		m_log = 0;
	}

	return TCL_OK;
}


static int
cmdProbe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	command		= stringFromObj(objc, objv, 1);
	char const*	directory	= stringFromObj(objc, objv, 2);
	char const*	protocol		= stringFromObj(objc, objv, 3);
	unsigned		timeout		= 5000;

	if (objc >= 5)
		timeout = unsignedFromObj(objc, objv, 4);

	Engine::Protocol prot;

	if (::toupper(*protocol) == 'U')
		prot = Engine::Uci;
	else if (::toupper(*protocol) == 'W')
		prot = Engine::WinBoard;
	else
		return error(CmdProbe, 0, 0, "unknown protocol '%s'", protocol);

	Engine engine(prot, command, directory);

	if (m_log)
		engine.setLog(m_log->stream());

	Engine::Result result = engine.probe(timeout);

	switch (result)
	{
		case app::Engine::Probe_Failed:
			setResult("failed");
			break;

		case app::Engine::Probe_Undecidable:
			setResult("undecidable");
			break;

		case app::Engine::Probe_Successfull:
		{
			Tcl_Obj* objs[8];

			objs[0] = Tcl_NewStringObj("ok", -1);
			objs[1] = Tcl_NewStringObj(engine.identifier(), engine.identifier().size());
			objs[2] = Tcl_NewStringObj(engine.author(), engine.author().size());
			objs[3] = Tcl_NewIntObj(engine.maxMultiPV());
			objs[4] = Tcl_NewBooleanObj(engine.hasFeature(app::Engine::Feature_Chess_960));
			objs[5] = Tcl_NewBooleanObj(engine.hasFeature(app::Engine::Feature_Shuffle_Chess));
			objs[6] = Tcl_NewBooleanObj(engine.hasFeature(app::Engine::Feature_Pause));
			objs[7] = Tcl_NewBooleanObj(engine.hasFeature(app::Engine::Feature_PlayOther));

			setResult(U_NUMBER_OF(objs), objs);
			break;
		}
	}

	return TCL_OK;
}


static int
cmdList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* result = Tcl_NewListObj(0, 0);

	struct Callback : public ::db::Player::PlayerCallback
	{
		Callback(Tcl_Obj* obj) : list(obj) {}
		Tcl_Obj* list;

		void entry(::db::Player const& player) override
		{
			if (player.isEngine() && (player.supportsUciProtocol() || player.supportsWinboardProtocol()))
				Tcl_ListObjAppendElement(0, list, Tcl_NewStringObj(player.name(), player.name().size()));
		}
	};

	Callback cb(result);
	::db::Player::enumerate(cb);
	setResult(result);
	return TCL_OK;
}


static int
cmdInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	::db::Player const* player = ::db::Player::findPlayer(stringFromObj(objc, objv, 1));

	Tcl_Obj* objs[8];
	int n = 0;

	if (player)
	{
		objs[n++] = Tcl_NewStringObj(player->name(), -1);
		objs[n++] = Tcl_NewStringObj(::db::country::toString(player->federation()), -1);
		objs[n++] = Tcl_NewIntObj(player->latestRating(::db::rating::Elo));
		objs[n++] = Tcl_NewIntObj(player->latestRating(::db::rating::Rating));
		objs[n++] = Tcl_NewBooleanObj(player->supportsUciProtocol());
		objs[n++] = Tcl_NewBooleanObj(player->supportsWinboardProtocol());
		objs[n++] = Tcl_NewBooleanObj(player->supportsChess960());
		objs[n++] = Tcl_NewBooleanObj(player->supportsShuffleChess());
	}

	setResult(Tcl_NewListObj(n, objs));
	return TCL_OK;
}


namespace tcl {
namespace engine {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdInfo,		cmdInfo);
	createCommand(ti, CmdList,		cmdList);
	createCommand(ti, CmdLog,		cmdLog);
	createCommand(ti, CmdProbe,	cmdProbe);
}

} // namespace engine
} // namespace tcl

// vi:set ts=3 sw=3:
