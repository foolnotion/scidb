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
#include "tcl_application.h"

#include "app_engine.h"
#include "app_application.h"

#include "db_player.h"

#include "m_ofstream.h"
#include "m_string.h"
#include "m_assert.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <tcl.h>

using namespace db;
using namespace tcl;


static char const* CmdAnalyize	= "::scidb::engine::analyze";
static char const* CmdClearHash	= "::scidb::engine::clearHash";
static char const* CmdGet			= "::scidb::engine::get";
static char const* CmdInfo			= "::scidb::engine::info";
static char const* CmdList			= "::scidb::engine::list";
static char const* CmdLog			= "::scidb::engine::log";
static char const* CmdProbe		= "::scidb::engine::probe";
static char const* CmdSet			= "::scidb::engine::set";
static char const* CmdStart		= "::scidb::engine::start";
static char const* CmdStop			= "::scidb::engine::stop";


namespace {

class EngineLog
{
public:

	EngineLog(FILE* fp, Tcl_Obj* cmd, Tcl_Obj* arg)
		:m_stream(fp)
		,m_cmd(cmd)
		,m_arg(arg)
	{
		m_stream.set_unbuffered();
		m_stream.set_text();

		Tcl_IncrRefCount(m_cmd);
		Tcl_IncrRefCount(m_arg);
	}

	~EngineLog()
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


class ProbeEngine : public ::app::Engine
{
public:

	ProbeEngine(Protocol protocol, mstl::string const& command, mstl::string const& directory)
		: ::app::Engine(protocol, command, directory)
	{
	}

	void updateInfo() override {}
	void updateBestMove() override {}
	void engineIsReady() override {}
};


class Engine : public ::app::Engine
{
public:

	Engine(	Protocol protocol,
				mstl::string const& command,
				mstl::string const& directory,
				Tcl_Obj* isReadyCmd,
				Tcl_Obj* updateInfoCmd,
				Tcl_Obj* updateBestMoveCmd)
		: ::app::Engine(protocol, command, directory)
		,m_isReadyCmd(isReadyCmd)
		,m_updateInfoCmd(updateInfoCmd)
		,m_updateBestMoveCmd(updateBestMoveCmd)
		,m_id(0)
	{
		M_ASSERT(isReadyCmd);
		M_ASSERT(updateInfoCmd);
		M_ASSERT(updateBestMoveCmd);

		Tcl_IncrRefCount(m_isReadyCmd);
		Tcl_IncrRefCount(m_updateInfoCmd);
		Tcl_IncrRefCount(m_updateBestMoveCmd);
	}

	~Engine() throw()
	{
		Tcl_DecrRefCount(m_isReadyCmd);
		Tcl_DecrRefCount(m_updateInfoCmd);
		Tcl_DecrRefCount(m_updateBestMoveCmd);

		if (m_id)
			Tcl_DecrRefCount(m_id);
	}

	void updateInfo() override
	{
		Tcl_Obj* vars[numVariations()];
		unsigned halfMoveNo = currentBoard().plyNumber();

		for (unsigned i = 0; i < numVariations(); ++i)
		{
			mstl::string s;
			variation(i).print(s, halfMoveNo);
			vars[i] = Tcl_NewStringObj(s, s.size());
		}

		Tcl_Obj* objScore	= Tcl_NewIntObj(score());
		Tcl_Obj* objMate	= Tcl_NewIntObj(mate());
		Tcl_Obj* objDepth	= Tcl_NewIntObj(depth());
		Tcl_Obj* objTime	= Tcl_NewDoubleObj(time());
		Tcl_Obj* objNodes	= Tcl_NewIntObj(nodes());
		Tcl_Obj* objVars	= Tcl_NewListObj(numVariations(), vars);

		Tcl_IncrRefCount(objScore);
		Tcl_IncrRefCount(objMate);
		Tcl_IncrRefCount(objDepth);
		Tcl_IncrRefCount(objTime);
		Tcl_IncrRefCount(objNodes);
		Tcl_IncrRefCount(objVars);

		tcl::invoke(__func__,
						m_updateInfoCmd,
						m_id,
						objScore,
						objMate,
						objDepth,
						objTime,
						objNodes,
						objVars,
						nullptr);

		Tcl_DecrRefCount(objScore);
		Tcl_DecrRefCount(objMate);
		Tcl_DecrRefCount(objDepth);
		Tcl_DecrRefCount(objTime);
		Tcl_DecrRefCount(objNodes);
		Tcl_DecrRefCount(objVars);
	}

	void updateBestMove() override
	{
		mstl::string s;
		bestMove().printSan(s);

		Tcl_Obj* move = Tcl_NewStringObj(s, s.size());
		Tcl_IncrRefCount(move);
		tcl::invoke(__func__, m_updateBestMoveCmd, m_id, move, nullptr);
		Tcl_DecrRefCount(move);
	}

	void engineIsReady() override
	{
		tcl::invoke(__func__, m_isReadyCmd, m_id, nullptr);
	}

	void setId(unsigned id)
	{
		Tcl_IncrRefCount(m_id = Tcl_NewIntObj(id));
	}

private:

	Tcl_Obj* m_isReadyCmd;
	Tcl_Obj* m_updateInfoCmd;
	Tcl_Obj* m_updateBestMoveCmd;
	Tcl_Obj* m_id;
};

}


static EngineLog* m_log = 0;


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
	if (m_log)
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

		m_log = new EngineLog(	fopencookie(0, "wb", Cookie),
										objectFromObj(objc, objv, 2),
										objectFromObj(objc, objv, 3));

		tcl::app::scidb->setEngineLog(m_log->stream());
	}
	else if (strcmp(subcmd, "close") == 0)
	{
		tcl::app::scidb->setEngineLog(0);
		delete m_log;
		m_log = 0;
	}
	else if (strcmp(subcmd, "send") == 0)
	{
		if (m_log)
		{
			mstl::string msg(stringFromObj(objc, objv, 2));

			if (!msg.empty())
			{
				if (msg.back() != '\n')
					msg.append('\n');
				m_log->write(msg, msg.size());
			}
		}
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

	ProbeEngine::Protocol prot;

	if (::toupper(*protocol) == 'U')
		prot = Engine::Uci;
	else if (::toupper(*protocol) == 'W')
		prot = Engine::WinBoard;
	else
		return error(CmdProbe, 0, 0, "unknown protocol '%s'", protocol);

	ProbeEngine engine(prot, command, directory);

	if (m_log)
		engine.setLog(m_log->stream());

	ProbeEngine::Result result = engine.probe(timeout);

	switch (result)
	{
		case ::app::Engine::Probe_Failed:
			setResult("failed");
			break;

		case ::app::Engine::Probe_Undecidable:
			setResult("undecidable");
			break;

		case ::app::Engine::Probe_Successfull:
		{
			Tcl_Obj* objs[11];
			ProbeEngine::Options const& options = engine.options();

			objs[ 0] = Tcl_NewStringObj("ok", -1);
			objs[ 1] = Tcl_NewStringObj(engine.identifier(), engine.identifier().size());
			objs[ 2] = Tcl_NewStringObj(engine.author(), engine.author().size());
			objs[ 3] = Tcl_NewIntObj(engine.maxMultiPV());
			objs[ 4] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Chess_960));
			objs[ 5] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Shuffle_Chess));
			objs[ 6] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Pause));
			objs[ 7] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Play_Other));
			objs[ 8] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Hash_Size));
			objs[ 9] = Tcl_NewBooleanObj(engine.hasFeature(::app::Engine::Feature_Clear_Hash));
			objs[10] = Tcl_NewListObj(0, 0);

			for (ProbeEngine::Options::const_iterator i = options.begin(); i != options.end(); ++i)
			{
				Tcl_Obj* v[6];

				v[0] = Tcl_NewStringObj(i->name, i->name.size());
				v[1] = Tcl_NewStringObj(i->type, i->type.size());
				v[2] = Tcl_NewStringObj(i->val,  i->val.size());
				v[3] = Tcl_NewStringObj(i->dflt, i->dflt.size());
				v[4] = Tcl_NewStringObj(i->var,  i->var.size());
				v[5] = Tcl_NewStringObj(i->max,  i->max.size());

				Tcl_ListObjAppendElement(ti, objs[10], Tcl_NewListObj(U_NUMBER_OF(v), v));
			}

			setResult(U_NUMBER_OF(objs), objs);
			break;
		}
	}

	return TCL_OK;
}


static int
cmdStart(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	command		= stringFromObj(objc, objv, 1);
	char const*	directory	= stringFromObj(objc, objv, 2);
	char const*	protocol		= stringFromObj(objc, objv, 3);
	Tcl_Obj*		isReadyCmd	= objectFromObj(objc, objv, 4);
	Tcl_Obj*		updateCmd	= objectFromObj(objc, objv, 5);
	Tcl_Obj*		bestMoveCmd	= objectFromObj(objc, objv, 6);

	Engine::Protocol prot;

	if (::toupper(*protocol) == 'U')
		prot = Engine::Uci;
	else if (::toupper(*protocol) == 'W')
		prot = Engine::WinBoard;
	else
		return error(CmdProbe, 0, 0, "unknown protocol '%s'", protocol);

	Engine* engine = new Engine(prot, command, directory, isReadyCmd, updateCmd, bestMoveCmd);
	engine->activate();

	unsigned id = tcl::app::scidb->addEngine(engine);

	engine->setId(id);
	setResult(id);

	return TCL_OK;
}


static int
cmdStop(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);
	tcl::app::scidb->removeEngine(id);
	return TCL_OK;
}


static int
cmdAnalyze(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	cmd	= stringFromObj(objc, objv, 1);
	unsigned		id		= unsignedFromObj(objc, objv, 2);

	if (strcmp(cmd, "start") == 0)
		setResult(tcl::app::scidb->startAnalysis(id));
	else if (strcmp(cmd, "stop") == 0)
		setResult(tcl::app::scidb->stopAnalysis(id));
	else
		return error(CmdAnalyize, 0, 0, "unknown command '%s'", cmd);

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

	if (player)
	{
		::db::Player::StringList const& aliases = player->aliases();
		Tcl_Obj* objs[10];
		Tcl_Obj* v[aliases.size() + 1];

		v[0] = Tcl_NewStringObj(player->name(), player->name().size());

		for (unsigned i = 0; i < aliases.size(); ++i)
			v[i + 1] = Tcl_NewStringObj(aliases[i], aliases[i].size());

		objs[0] = Tcl_NewStringObj(player->name(), -1);
		objs[1] = Tcl_NewStringObj(::db::country::toString(player->federation()), -1);
		objs[2] = Tcl_NewIntObj(player->latestRating(::db::rating::Elo));
		objs[3] = Tcl_NewIntObj(player->latestRating(::db::rating::Rating));
		objs[4] = Tcl_NewBooleanObj(player->supportsUciProtocol());
		objs[5] = Tcl_NewBooleanObj(player->supportsWinboardProtocol());
		objs[6] = Tcl_NewBooleanObj(player->supportsChess960());
		objs[7] = Tcl_NewBooleanObj(player->supportsShuffleChess());
		objs[8] = Tcl_NewStringObj(player->url(), -1);
		objs[9] = Tcl_NewListObj(aliases.size() + 1, v);

		setResult(Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}
	else
	{
		setResult("");
	}

	return TCL_OK;
}


static int
cmdGet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned 	id		= unsignedFromObj(objc, objv, 1);
	char const*	attr	= stringFromObj(objc, objv, 2);

	if (strcmp(attr, "maxMultiPV") == 0)
		setResult(tcl::app::Scidb->engine(id)->maxMultiPV());
	else if (strcmp(attr, "numVariations") == 0)
		setResult(tcl::app::Scidb->engine(id)->numVariations());
	else if (strcmp(attr, "chess960") == 0)
		setResult(tcl::app::Scidb->engine(id)->hasFeature(::app::Engine::Feature_Chess_960));
	else if (strcmp(attr, "shuffleChess") == 0)
		setResult(tcl::app::Scidb->engine(id)->hasFeature(::app::Engine::Feature_Shuffle_Chess));
	else if (strcmp(attr, "hashSize") == 0)
		setResult(tcl::app::Scidb->engine(id)->hashSize());
	else if (strcmp(attr, "clearHash") == 0)
		setResult(tcl::app::Scidb->engine(id)->hasFeature(::app::Engine::Feature_Clear_Hash));
	else
		return error(CmdGet, 0, 0, "unknown attribute '%s'", attr);

	return TCL_OK;
}


static int
cmdSet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned 	id		= unsignedFromObj(objc, objv, 1);
	char const*	attr	= stringFromObj(objc, objv, 2);

	if (strcmp(attr, "multiPV") == 0)
	{
		tcl::app::scidb->engine(id)->changeNumberOfVariations(unsignedFromObj(objc, objv, 3));
	}
	else if (strcmp(attr, "hashSize") == 0)
	{
		tcl::app::scidb->engine(id)->changeHashSize(unsignedFromObj(objc, objv, 3));
	}
	else if (strcmp(attr, "options") == 0)
	{
		::app::Engine::Options options;

		Tcl_Obj** objs;
		int numObjs;

		if (Tcl_ListObjGetElements(ti, objectFromObj(objc, objv, 3), &numObjs, &objs) != TCL_OK)
			return error(CmdSet, 0, 0, "invalid option list");

		int n;
		Tcl_Obj** v;

		for (int i = 0; i < numObjs; ++i)
		{
			if (Tcl_ListObjGetElements(ti, objs[i], &n, &v) != TCL_OK || n != 6)
				return error(CmdSet, 0, 0, "invalid option list");

			::app::Engine::Option opt;

			opt.name = Tcl_GetString(v[0]);
			opt.type = Tcl_GetString(v[1]);
			opt.val  = Tcl_GetString(v[2]);
			opt.dflt = Tcl_GetString(v[3]);
			opt.var  = Tcl_GetString(v[4]);
			opt.max  = Tcl_GetString(v[5]);

			options.push_back(opt);
		}

		tcl::app::scidb->engine(id)->changeOptions(options);
	}
	else
	{
		return error(CmdSet, 0, 0, "unknown attribute '%s'", attr);
	}

	return TCL_OK;
}


static int
cmdClearHash(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	tcl::app::scidb->engine(unsignedFromObj(objc, objv, 1))->clearHash();
	return TCL_OK;
}


namespace tcl {
namespace engine {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAnalyize,	cmdAnalyze);
	createCommand(ti, CmdClearHash,	cmdClearHash);
	createCommand(ti, CmdGet,			cmdGet);
	createCommand(ti, CmdInfo,			cmdInfo);
	createCommand(ti, CmdList,			cmdList);
	createCommand(ti, CmdLog,			cmdLog);
	createCommand(ti, CmdProbe,		cmdProbe);
	createCommand(ti, CmdSet,			cmdSet);
	createCommand(ti, CmdStart,		cmdStart);
	createCommand(ti, CmdStop,			cmdStop);
}

} // namespace engine
} // namespace tcl

// vi:set ts=3 sw=3:
