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
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <tcl.h>

using namespace db;
using namespace tcl;


static char const* CmdActivate		= "::scidb::engine::activate";
static char const* CmdAnalyize		= "::scidb::engine::analyze";
static char const* CmdClearHash		= "::scidb::engine::clearHash";
static char const* CmdGet				= "::scidb::engine::get";
static char const* CmdInfo				= "::scidb::engine::info";
static char const* CmdKill				= "::scidb::engine::kill";
static char const* CmdList				= "::scidb::engine::list";
static char const* CmdLog				= "::scidb::engine::log";
static char const* CmdPause			= "::scidb::engine::pause";
static char const* CmdProbe			= "::scidb::engine::probe";
static char const* CmdResume			= "::scidb::engine::resume";
static char const* CmdSetFeatures	= "::scidb::engine::setFeatures";
static char const* CmdSetOptions		= "::scidb::engine::setOptions";
static char const* CmdStart			= "::scidb::engine::start";
static char const* CmdStop				= "::scidb::engine::stop";


namespace {

class EngineLog
{
public:

	EngineLog(FILE* fp, Tcl_Obj* cmd, Tcl_Obj* arg)
		:m_stream(fp)
		,m_cmd(cmd)
		,m_arg(arg)
	{
		m_stream.set_line_buffered();
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

	void updatePvInfo(unsigned) override {}
	void updateCheckMateInfo() override {}
	void updateStaleMateInfo() override {}
	void engineIsReady() override {}
	void engineSignal(Signal) override {}
};


class Engine : public ::app::Engine
{
public:

	Engine(	Protocol protocol,
				mstl::string const& command,
				mstl::string const& directory,
				Tcl_Obj* isReadyCmd,
				Tcl_Obj* signalCmd,
				Tcl_Obj* updateInfoCmd)
		: ::app::Engine(protocol, command, directory)
		,m_isReadyCmd(isReadyCmd)
		,m_signalCmd(signalCmd)
		,m_updateInfoCmd(updateInfoCmd)
		,m_id(0)
	{
		M_ASSERT(isReadyCmd);
		M_ASSERT(signalCmd);
		M_ASSERT(updateInfoCmd);

		Tcl_IncrRefCount(m_isReadyCmd);
		Tcl_IncrRefCount(m_signalCmd);
		Tcl_IncrRefCount(m_updateInfoCmd);

		if (m_pv == 0)
		{
			Tcl_IncrRefCount(m_pv = Tcl_NewStringObj("pv", -1));
			Tcl_IncrRefCount(m_checkmate = Tcl_NewStringObj("checkmate", -1));
			Tcl_IncrRefCount(m_stalemate = Tcl_NewStringObj("stalemate", -1));
			Tcl_IncrRefCount(m_move = Tcl_NewStringObj("move", -1));
			Tcl_IncrRefCount(m_line = Tcl_NewStringObj("line", -1));
			Tcl_IncrRefCount(m_best = Tcl_NewStringObj("best", -1));
			Tcl_IncrRefCount(m_depth = Tcl_NewStringObj("depth", -1));
			Tcl_IncrRefCount(m_seldepth = Tcl_NewStringObj("seldepth", -1));
			Tcl_IncrRefCount(m_time = Tcl_NewStringObj("time", -1));
			Tcl_IncrRefCount(m_hash = Tcl_NewStringObj("hash", -1));
		}
	}

	~Engine() throw()
	{
		Tcl_DecrRefCount(m_isReadyCmd);
		Tcl_DecrRefCount(m_signalCmd);
		Tcl_DecrRefCount(m_updateInfoCmd);

		if (m_id)
			Tcl_DecrRefCount(m_id);
	}

	void sendInfo(Tcl_Obj* cmd, Tcl_Obj* args)
	{
		Tcl_IncrRefCount(args);
		tcl::invoke(__func__, m_updateInfoCmd, m_id, cmd, args, nullptr);
		Tcl_DecrRefCount(args);
	}

	void updatePvInfo(unsigned line) override
	{
		unsigned halfMoveNo = currentBoard().plyNumber();

		mstl::string s;
		variation(line).print(s, halfMoveNo);

		Tcl_Obj* objs[8];

		objs[0] = Tcl_NewIntObj(score());
		objs[1] = Tcl_NewIntObj(mate());
		objs[2] = Tcl_NewIntObj(depth());
		objs[3] = Tcl_NewIntObj(selectiveDepth());
		objs[4] = Tcl_NewDoubleObj(time());
		objs[5] = Tcl_NewIntObj(nodes());
		objs[6] = Tcl_NewIntObj(line);
		objs[7] = Tcl_NewStringObj(s, s.size());

		sendInfo(m_pv, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateCheckMateInfo() override
	{
		sendInfo(m_checkmate, Tcl_NewStringObj(color::printColor(currentBoard().sideToMove()), -1));
	}

	void updateStaleMateInfo() override
	{
		sendInfo(m_stalemate, Tcl_NewStringObj(color::printColor(currentBoard().sideToMove()), -1));
	}

	void updateCurrMove() override
	{
		Tcl_Obj* objs[2];
		mstl::string move;

		currentMove().printSan(move, encoding::Utf8);
		objs[0] = Tcl_NewIntObj(currentMoveNumber());
		objs[1] = Tcl_NewStringObj(move, move.size());
		sendInfo(m_move, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateCurrLine() override
	{
	}

	void updateBestMove() override
	{
		mstl::string move;
		bestMove().printSan(move, encoding::Utf8);
		sendInfo(m_best, Tcl_NewStringObj(move, move.size()));
	}

	void updateDepthInfo() override
	{
		Tcl_Obj* objs[3];

		objs[0] = Tcl_NewIntObj(depth());
		objs[1] = Tcl_NewIntObj(selectiveDepth());
		objs[2] = Tcl_NewIntObj(nodes());
		sendInfo(m_depth, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateTimeInfo() override
	{
		Tcl_Obj* objs[4];

		objs[0] = Tcl_NewDoubleObj(time());
		objs[1] = Tcl_NewIntObj(depth());
		objs[2] = Tcl_NewIntObj(selectiveDepth());
		objs[3] = Tcl_NewIntObj(nodes());

		sendInfo(m_time, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateHashFullInfo() override
	{
//		sendInfo(m_hash, Tcl_NewIntObj(hashFullness()));
	}

	void engineIsReady() override
	{
		tcl::invoke(__func__, m_isReadyCmd, m_id, nullptr);
	}

	void engineSignal(Signal signal) override
	{
		char const* msg;
		char buf[100];

		switch (signal)
		{
			case Stopped:		msg = "stopped"; break;
			case Resumed:		msg = "resumed"; break;
			case Crashed:		msg = "crashed"; break;
			case Killed:		msg = "killed"; break;
			case PipeClosed:	msg = "closed"; break;

			case Terminated:
				sprintf(buf, "%d", exitStatus());
				msg = buf;
				break;
		}

		tcl::invoke(__func__, m_signalCmd, m_id, Tcl_NewStringObj(msg, -1), nullptr);
	}

	void setId(unsigned id)
	{
		Tcl_IncrRefCount(m_id = Tcl_NewIntObj(id));
	}

private:

	Tcl_Obj* m_isReadyCmd;
	Tcl_Obj* m_signalCmd;
	Tcl_Obj* m_updateInfoCmd;
	Tcl_Obj* m_id;

	static Tcl_Obj* m_pv;
	static Tcl_Obj* m_checkmate;
	static Tcl_Obj* m_stalemate;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_line;
	static Tcl_Obj* m_best;
	static Tcl_Obj* m_depth;
	static Tcl_Obj* m_seldepth;
	static Tcl_Obj* m_time;
	static Tcl_Obj* m_hash;
};

Tcl_Obj* Engine::m_pv			= 0;
Tcl_Obj* Engine::m_checkmate	= 0;
Tcl_Obj* Engine::m_stalemate	= 0;
Tcl_Obj* Engine::m_move			= 0;
Tcl_Obj* Engine::m_line			= 0;
Tcl_Obj* Engine::m_best			= 0;
Tcl_Obj* Engine::m_depth		= 0;
Tcl_Obj* Engine::m_seldepth	= 0;
Tcl_Obj* Engine::m_time			= 0;
Tcl_Obj* Engine::m_hash			= 0;

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

		m_log = new EngineLog(	fopencookie(0, "w", Cookie),
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
			ProbeEngine::Options const& options = engine.options();

			Tcl_Obj* objs[4];
			Tcl_Obj* v[mstl::max(unsigned(options.size()), 100u)];
			unsigned n = 0;

			objs[0] = Tcl_NewStringObj("ok", -1);

			if (!engine.identifier().empty())
			{
				v[n++] = Tcl_NewStringObj("Identifier", -1);
				v[n++] = Tcl_NewStringObj(engine.identifier(), engine.identifier().size());
			}
			if (!engine.author().empty())
			{
				v[n++] = Tcl_NewStringObj("Author", -1);
				v[n++] = Tcl_NewStringObj(engine.author(), engine.author().size());
			}
			if (!engine.email().empty())
			{
				v[n++] = Tcl_NewStringObj("Email", -1);
				v[n++] = Tcl_NewStringObj(engine.email(), engine.email().size());
			}
			if (!engine.url().empty())
			{
				v[n++] = Tcl_NewStringObj("Url", -1);
				v[n++] = Tcl_NewStringObj(engine.url(), engine.url().size());
			}
			if (!engine.shortName().empty())
			{
				v[n++] = Tcl_NewStringObj("Name", -1);
				v[n++] = Tcl_NewStringObj(engine.shortName(), engine.shortName().size());
			}
			if (engine.elo())
			{
				v[n++] = Tcl_NewStringObj("Elo", -1);
				v[n++] = Tcl_NewIntObj(engine.elo());
			}

			objs[1] = Tcl_NewListObj(n, v);
			n = 0;

			if (engine.hasFeature(::app::Engine::Feature_Analyze))
			{
				v[n++] = Tcl_NewStringObj("analyze", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Multi_PV))
			{
				v[n++] = Tcl_NewStringObj("multiPV", -1);
				v[n++] = Tcl_NewIntObj(engine.maxMultiPV());
			}
			if (engine.hasFeature(::app::Engine::Feature_Chess_960))
			{
				v[n++] = Tcl_NewStringObj("chess960", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Shuffle_Chess))
			{
				v[n++] = Tcl_NewStringObj("shuffle", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Pause))
			{
				v[n++] = Tcl_NewStringObj("pause", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Ponder))
			{
				v[n++] = Tcl_NewStringObj("ponder", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Play_Other))
			{
				v[n++] = Tcl_NewStringObj("playOther", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Hash_Size))
			{
				Tcl_Obj* range[2] =
					{ Tcl_NewIntObj(engine.minHashSize()), Tcl_NewIntObj(engine.maxHashSize()) };
				v[n++] = Tcl_NewStringObj("hashSize", -1);
				v[n++] = Tcl_NewListObj(2, range);
			}
			if (engine.hasFeature(::app::Engine::Feature_Threads))
			{
				Tcl_Obj* range[2] =
					{ Tcl_NewIntObj(engine.minThreads()), Tcl_NewIntObj(engine.maxThreads()) };
				v[n++] = Tcl_NewStringObj("threads", -1);
				v[n++] = Tcl_NewListObj(2, range);
			}
			if (engine.hasFeature(::app::Engine::Feature_Clear_Hash))
			{
				v[n++] = Tcl_NewStringObj("clearHash", -1);
				v[n++] = Tcl_NewStringObj("true", 4);
			}
			if (engine.hasFeature(::app::Engine::Feature_Limit_Strength))
			{
				Tcl_Obj* range[2] = { Tcl_NewIntObj(engine.minElo()), Tcl_NewIntObj(engine.maxElo()) };
				v[n++] = Tcl_NewStringObj("eloRange", -1);
				v[n++] = Tcl_NewListObj(2, range);
			}
			if (engine.hasFeature(::app::Engine::Feature_Skill_Level))
			{
				Tcl_Obj* range[2] =
					{ Tcl_NewIntObj(engine.minSkillLevel()), Tcl_NewIntObj(engine.maxSkillLevel()) };
				v[n++] = Tcl_NewStringObj("skillLevel", -1);
				v[n++] = Tcl_NewListObj(2, range);
			}
			if (engine.hasFeature(::app::Engine::Feature_Playing_Styles))
			{
				mstl::string const& playingStyles = engine.playingStyles();
				char const* s = playingStyles.begin();
				char const* e = playingStyles.end();
				char const* p = ::strchr(s, ',');

				Tcl_Obj* styles[100];
				int k = 0;

				for (	; p && s < e && k < 100; p = ::strchr(s = p + 1, ','))
					styles[k++] = Tcl_NewStringObj(mstl::string(s, p), p - s);
				styles[k++] = Tcl_NewStringObj(mstl::string(s, e), e - s);

				v[n++] = Tcl_NewStringObj("styles", -1);
				v[n++] = Tcl_NewListObj(k, styles);
			}

			objs[2] = Tcl_NewListObj(n, v);
			n = 0;

			for (ProbeEngine::Options::const_iterator i = options.begin(); i != options.end(); ++i)
			{
				Tcl_Obj* u[6];

				u[0] = Tcl_NewStringObj(i->name, i->name.size());
				u[1] = Tcl_NewStringObj(i->type, i->type.size());
				u[2] = Tcl_NewStringObj(i->val,  i->val.size());
				u[3] = Tcl_NewStringObj(i->dflt, i->dflt.size());
				u[4] = Tcl_NewStringObj(i->var,  i->var.size());
				u[5] = Tcl_NewStringObj(i->max,  i->max.size());

				v[n++] = Tcl_NewListObj(U_NUMBER_OF(u), u);
			}

			objs[3] = Tcl_NewListObj(n, v);

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
	Tcl_Obj*		signalCmd	= objectFromObj(objc, objv, 5);
	Tcl_Obj*		updateCmd	= objectFromObj(objc, objv, 6);

	Engine::Protocol prot;

	if (::toupper(*protocol) == 'U')
		prot = Engine::Uci;
	else if (::toupper(*protocol) == 'W')
		prot = Engine::WinBoard;
	else
		return error(CmdProbe, 0, 0, "unknown protocol '%s'", protocol);

	Engine* engine = new Engine(prot, command, directory, isReadyCmd, signalCmd, updateCmd);
	unsigned id = tcl::app::scidb->addEngine(engine);

	engine->setId(id);
	setResult(id);

	return TCL_OK;
}


static int
cmdActivate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		::tcl::app::scidb->engine(id)->activate();

	return TCL_OK;
}


static int
cmdSetFeatures(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
	{
		static char const* Features[] =
		{
			"analyze", "multipv", "ponder", "hashSize", "threads",
			"skillLevel", "playOther", "limitStrength", "playingStyle",
			nullptr,
		};
		enum
		{
			Feature_Analyze,
			Feature_Multi_PV,
			Feature_Ponder,
			Feature_Hash_Size,
			Feature_Threads,
			Feature_Skill_Level,
			Feature_Play_Other,
			Feature_Limit_Strength,
			Feature_Playing_Styles,
		};

		::app::Engine* engine = tcl::app::scidb->engine(id);

		int size;
		Tcl_Obj** objs;

		if (Tcl_ListObjGetElements(ti, objectFromObj(objc, objv, 2), &size, &objs) != TCL_OK)
			return error(CmdActivate, 0, 0, "list obj expected");

		if (size & 2 == 1)
			return error(CmdActivate, 0, 0, "feature list must have even size");

		for (int i = 0; i < size; i += 2)
		{
			int index;

			if (Tcl_GetIndexFromObj(ti, objs[i], Features, "feature", TCL_EXACT, &index) != TCL_OK)
				return error(CmdActivate, 0, 0, "unknown feature: %s", Tcl_GetString(objs[i]));

			char const* value = Tcl_GetString(objs[i + 1]);

			switch (index)
			{
				case Feature_Analyze:
					if (*value == 't')
						engine->addFeature(Engine::Feature_Analyze);
					break;

				case Feature_Multi_PV:
					engine->changeNumberOfVariations(atoi(value));
					break;

				case Feature_Ponder:
					engine->pondering(*value == 't');
					break;

				case Feature_Hash_Size:
					engine->changeHashSize(atoi(value));
					break;

				case Feature_Threads:
					engine->changeThreads(atoi(value));
					break;

				case Feature_Skill_Level:
					engine->changeSkillLevel(atoi(value));
					break;

				case Feature_Play_Other:
					engine->playOther(*value == 't');
					break;

				case Feature_Limit_Strength:
					engine->changeStrength(atoi(value));
					break;

				case Feature_Playing_Styles:
					engine->changePlayingStyle(value);
					break;
			}
		}
	}

	return TCL_OK;
}


static int
cmdSetOptions(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
	{
		::app::Engine* engine = tcl::app::scidb->engine(id);
		::app::Engine::Options opts;

		int size;
		Tcl_Obj** objs;

		if (Tcl_ListObjGetElements(ti, objectFromObj(objc, objv, 2), &size, &objs) != TCL_OK)
			return error(CmdActivate, 0, 0, "list obj expected");

		if (size & 2 == 1)
			return error(CmdActivate, 0, 0, "options list must have even size");

		for (int i = 0; i < size; i += 2)
			engine->setOption(Tcl_GetString(objs[i]), Tcl_GetString(objs[i + 1]));

		engine->updateOptions();
	}

	return TCL_OK;
}


static int
cmdStop(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->removeEngine(id);

	return TCL_OK;
}


static int
cmdAnalyze(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	cmd	= stringFromObj(objc, objv, 1);
	unsigned		id		= unsignedFromObj(objc, objv, 2);

	if (tcl::app::scidb->engineExists(id))
	{
		if (!tcl::app::scidb->engine(id)->isActive())
			setResult(false);
		else if (strcmp(cmd, "start") == 0)
			setResult(tcl::app::scidb->startAnalysis(id));
		else if (strcmp(cmd, "stop") == 0)
			setResult(tcl::app::scidb->stopAnalysis(id));
		else
			return error(CmdAnalyize, 0, 0, "unknown command '%s'", cmd);
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
cmdClearHash(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->engine(id)->clearHash();

	return TCL_OK;
}


static int
cmdKill(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->removeEngine(id);

	return TCL_OK;
}


static int
cmdPause(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->engine(id)->pause();

	return TCL_OK;
}


static int
cmdResume(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->engine(id)->resume();

	return TCL_OK;
}


namespace tcl {
namespace engine {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdActivate,		cmdActivate);
	createCommand(ti, CmdAnalyize,		cmdAnalyze);
	createCommand(ti, CmdClearHash,		cmdClearHash);
	createCommand(ti, CmdGet,				cmdGet);
	createCommand(ti, CmdInfo,				cmdInfo);
	createCommand(ti, CmdKill,				cmdKill);
	createCommand(ti, CmdList,				cmdList);
	createCommand(ti, CmdLog,				cmdLog);
	createCommand(ti, CmdPause,			cmdPause);
	createCommand(ti, CmdProbe,			cmdProbe);
	createCommand(ti, CmdResume,			cmdResume);
	createCommand(ti, CmdStart,			cmdStart);
	createCommand(ti, CmdSetFeatures,	cmdSetFeatures);
	createCommand(ti, CmdSetOptions,		cmdSetOptions);
	createCommand(ti, CmdStop,				cmdStop);
}

} // namespace engine
} // namespace tcl

// vi:set ts=3 sw=3:
