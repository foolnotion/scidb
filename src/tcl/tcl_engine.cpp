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
// Copyright: (C) 2012-2013 Gregor Cramer
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
#include "db_game.h"

#include "sys_process.h"

#include "m_ofstream.h"
#include "m_string.h"
#include "m_vector.h"
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
static char const* CmdBind				= "::scidb::engine::bind";
static char const* CmdClearHash		= "::scidb::engine::clearHash";
static char const* CmdCountLines		= "::scidb::engine::countLines";
static char const* CmdEmpty			= "::scidb::engine::empty?";
static char const* CmdInfo				= "::scidb::engine::info";
static char const* CmdInvoke			= "::scidb::engine::invoke";
static char const* CmdActive			= "::scidb::engine::active?";
static char const* CmdKill				= "::scidb::engine::kill";
static char const* CmdList				= "::scidb::engine::list";
static char const* CmdLog				= "::scidb::engine::log";
static char const* CmdMultiPV			= "::scidb::engine::multiPV";
static char const* CmdOrdering		= "::scidb::engine::ordering";
static char const* CmdPause			= "::scidb::engine::pause";
static char const* CmdPriority		= "::scidb::engine::priority";
static char const* CmdProbe			= "::scidb::engine::probe";
static char const* CmdResume			= "::scidb::engine::resume";
static char const* CmdSetFeatures	= "::scidb::engine::setFeatures";
static char const* CmdSetOptions		= "::scidb::engine::setOptions";
static char const* CmdSnapshot		= "::scidb::engine::snapshot";
static char const* CmdStart			= "::scidb::engine::start";
static char const* CmdStop				= "::scidb::engine::stop";
static char const* CmdVariant			= "::scidb::engine::variant";


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

	mstl::string const& error() const { return m_error; }

	void updateError(Error code) override
	{
		switch (int(code))
		{
			case Engine_Requires_Registration:	m_error = "registration"; break;
			case Engine_Has_Copy_Protection:		m_error = "copyprotection"; break;
		}
	}

	void clearInfo() override {}
	void updatePvInfo(unsigned) override {}
	void updateInfo(db::color::ID, board::Status) override {}
	void updateState(State) override {}
	void engineIsReady() override {}
	void engineSignal(Signal) override {}


private:

	mstl::string m_error;
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
			Tcl_IncrRefCount(m_error = Tcl_NewStringObj("error", -1));
			Tcl_IncrRefCount(m_clear = Tcl_NewStringObj("clear", -1));
			Tcl_IncrRefCount(m_pv = Tcl_NewStringObj("pv", -1));
			Tcl_IncrRefCount(m_checkmate = Tcl_NewStringObj("checkmate", -1));
			Tcl_IncrRefCount(m_stalemate = Tcl_NewStringObj("stalemate", -1));
			Tcl_IncrRefCount(m_threechecks = Tcl_NewStringObj("threechecks", -1));
			Tcl_IncrRefCount(m_losing = Tcl_NewStringObj("losing", -1));
			Tcl_IncrRefCount(m_over = Tcl_NewStringObj("over", -1));
			Tcl_IncrRefCount(m_move = Tcl_NewStringObj("move", -1));
			Tcl_IncrRefCount(m_line = Tcl_NewStringObj("line", -1));
			Tcl_IncrRefCount(m_bestmove = Tcl_NewStringObj("bestmove", -1));
			Tcl_IncrRefCount(m_bestscore = Tcl_NewStringObj("bestscore", -1));
			Tcl_IncrRefCount(m_depth = Tcl_NewStringObj("depth", -1));
			Tcl_IncrRefCount(m_seldepth = Tcl_NewStringObj("seldepth", -1));
			Tcl_IncrRefCount(m_time = Tcl_NewStringObj("time", -1));
			Tcl_IncrRefCount(m_hash = Tcl_NewStringObj("hash", -1));
			Tcl_IncrRefCount(m_state = Tcl_NewStringObj("state", -1));
			Tcl_IncrRefCount(m_start = Tcl_NewStringObj("start", -1));
			Tcl_IncrRefCount(m_stop = Tcl_NewStringObj("stop", -1));
			Tcl_IncrRefCount(m_pause = Tcl_NewStringObj("pause", -1));
			Tcl_IncrRefCount(m_resume = Tcl_NewStringObj("resume", -1));
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

	void clearInfo() override
	{
		sendInfo(m_clear, Tcl_NewListObj(0, 0));
	}

	void updateError(Error code) override
	{
		char const* msg = 0; // satisfies the compiler

		switch (code)
		{
			case Engine_Requires_Registration:	msg = "registration"; break;
			case Engine_Has_Copy_Protection:		msg = "copyprotection"; break;
			case Standard_Chess_Not_Supported:	msg = "standard"; break;
			case Chess_960_Not_Supported:			msg = "chess960"; break;
			case Losers_Not_Supported:				// fallthru
			case Suicide_Not_Supported:			// fallthru
			case Giveaway_Not_Supported:			// fallthru
			case Bughouse_Not_Supported:			// fallthru
			case Crazyhouse_Not_Supported:		// fallthru
			case Three_Check_Not_Supported:		msg = "variant"; break;
			case No_Analyze_Mode:					msg = "analyze"; break;
			case Illegal_Position:					msg = "position"; break;
			case Illegal_Moves:						msg = "moves"; break;
			case Did_Not_Receive_Pong:				msg = "pong"; break;
		}

		sendInfo(m_error, Tcl_NewStringObj(msg, -1));
	}

	void updateState(State state) override
	{
		Tcl_Obj* obj = 0; // satisfies the compiler

		switch (state)
		{
			case ::app::Engine::Start:		obj = m_start; break;
			case ::app::Engine::Stop:		obj = m_stop; break;
			case ::app::Engine::Pause:		obj = m_pause; break;
			case ::app::Engine::Resume:	obj = m_resume; break;
		}

		sendInfo(m_state, obj);
	}

	void updatePvInfo(unsigned line) override
	{
		unsigned halfMoveNo = currentBoard().plyNumber();

		mstl::string s;
		variation(line).print(s, halfMoveNo);

		int score = mstl::max(-9900, mstl::min(9900, this->score(line)));

		Tcl_Obj* objs[8];

		objs[0] = Tcl_NewIntObj(score);
		objs[1] = Tcl_NewIntObj(mate(line));
		objs[2] = Tcl_NewIntObj(depth());
		objs[3] = Tcl_NewIntObj(selectiveDepth());
		objs[4] = Tcl_NewDoubleObj(time());
		objs[5] = Tcl_NewIntObj(nodes());
		objs[6] = Tcl_NewIntObj(ordering(line));
		objs[7] = Tcl_NewStringObj(s, s.size());

		if (bestInfoHasChanged())
		{
			Tcl_Obj* objs2[3];
			Tcl_Obj* v[::app::Engine::MaxNumVariations];
			unsigned n = countLines();

			M_TEST(mstl::bitfield<unsigned> _complete)

			for (unsigned i = 0; i < n; ++i)
			{
				v[ordering(i)] = Tcl_NewBooleanObj(isBestLine(i));
				M_TEST(_complete.set(ordering(i)))
			}

			M_ASSERT(_complete.count() == n);

			int score = mstl::max(-9900, mstl::min(9900, bestScore()));

			objs2[0] = Tcl_NewIntObj(score);
			objs2[1] = Tcl_NewIntObj(shortestMate());
			objs2[2] = Tcl_NewListObj(n, v);

			sendInfo(m_bestscore, Tcl_NewListObj(3, objs2));
			resetBestInfoHasChanged();
		}

		sendInfo(m_pv, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateInfo(db::color::ID sideToMove, board::Status state) override
	{
		Tcl_Obj* objs[2];

		switch (state)
		{
			case board::Checkmate:		objs[0] = m_checkmate; break;
			case board::Stalemate:		objs[0] = m_stalemate; break;
			case board::ThreeChecks:	objs[0] = m_threechecks; break;
			case board::Losing:			objs[0] = m_losing; break;
			case board::None:				M_ASSERT(!"should not happen"); return;
		}

		objs[1] = Tcl_NewStringObj(color::printColor(sideToMove), -1);
		sendInfo(m_over, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateCurrMove() override
	{
		Tcl_Obj* objs[3];
		mstl::string move;

		currentMove().printSan(move, protocol::Scidb, encoding::Utf8);
		objs[0] = Tcl_NewIntObj(currentMoveNumber());
		objs[1] = Tcl_NewIntObj(currentMoveCount());
		objs[2] = Tcl_NewStringObj(move, move.size());
		sendInfo(m_move, Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}

	void updateCurrLine() override
	{
	}

	void updateBestMove() override
	{
		mstl::string move;
		bestMove().printSan(move, protocol::Scidb, encoding::Utf8);
		sendInfo(m_bestmove, Tcl_NewStringObj(move, move.size()));
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
		sendInfo(m_hash, Tcl_NewIntObj(hashFullness()));
	}

	void engineIsReady() override
	{
		tcl::invoke(__func__, m_isReadyCmd, m_id, nullptr);
	}

	void engineSignal(Signal signal) override
	{
		char const* msg = 0; // satisfies the compiler
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

	static Tcl_Obj* m_error;
	static Tcl_Obj* m_clear;
	static Tcl_Obj* m_pv;
	static Tcl_Obj* m_checkmate;
	static Tcl_Obj* m_stalemate;
	static Tcl_Obj* m_threechecks;
	static Tcl_Obj* m_losing;
	static Tcl_Obj* m_over;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_line;
	static Tcl_Obj* m_bestmove;
	static Tcl_Obj* m_bestscore;
	static Tcl_Obj* m_depth;
	static Tcl_Obj* m_seldepth;
	static Tcl_Obj* m_time;
	static Tcl_Obj* m_hash;
	static Tcl_Obj* m_state;
	static Tcl_Obj* m_start;
	static Tcl_Obj* m_stop;
	static Tcl_Obj* m_pause;
	static Tcl_Obj* m_resume;
};

Tcl_Obj* Engine::m_error			= 0;
Tcl_Obj* Engine::m_clear			= 0;
Tcl_Obj* Engine::m_pv				= 0;
Tcl_Obj* Engine::m_checkmate		= 0;
Tcl_Obj* Engine::m_stalemate		= 0;
Tcl_Obj* Engine::m_threechecks	= 0;
Tcl_Obj* Engine::m_losing			= 0;
Tcl_Obj* Engine::m_over				= 0;
Tcl_Obj* Engine::m_move				= 0;
Tcl_Obj* Engine::m_line				= 0;
Tcl_Obj* Engine::m_bestmove		= 0;
Tcl_Obj* Engine::m_bestscore		= 0;
Tcl_Obj* Engine::m_depth			= 0;
Tcl_Obj* Engine::m_seldepth		= 0;
Tcl_Obj* Engine::m_time				= 0;
Tcl_Obj* Engine::m_hash				= 0;
Tcl_Obj* Engine::m_state			= 0;
Tcl_Obj* Engine::m_start			= 0;
Tcl_Obj* Engine::m_stop				= 0;
Tcl_Obj* Engine::m_pause			= 0;
Tcl_Obj* Engine::m_resume			= 0;

}


namespace {

	struct Callback : public ::db::Player::PlayerCallback
	{
		Callback(Tcl_Obj* obj) : m_list(obj) {}
		Tcl_Obj* m_list;

		void entry(unsigned index, ::db::Player const& player) override
		{
			if (player.isEngine() && (player.supportsUciProtocol() || player.supportsWinboardProtocol()))
				Tcl_ListObjAppendElement(0, m_list, Tcl_NewStringObj(player.name(), player.name().size()));
		}
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

	if (!engine.error().empty())
	{
		setResult(engine.error());
	}
	else
	{
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

				Tcl_Obj* objs[5];
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

				mstl::bitfield<unsigned> variants(engine.supportedVariants());

				for (	unsigned i = variants.find_first();
						i != mstl::bitfield<unsigned>::npos;
						i = variants.find_next(i))
				{
					char const* s = 0;

					switch (1u << i)
					{
						case ::app::Engine::Variant_Standard:		s = "standard"; break;
						case ::app::Engine::Variant_Chess_960:		s = "chess960"; break;
						case ::app::Engine::Variant_Losers:			s = "losers"; break;
						case ::app::Engine::Variant_Suicide:		s = "suicide"; break;
						case ::app::Engine::Variant_Crazyhouse:	s = "crazyhouse"; break;
						case ::app::Engine::Variant_Bughouse:		s = "bughouse"; break;
						case ::app::Engine::Variant_Giveaway:		s = "giveaway"; break;
						case ::app::Engine::Variant_Three_Check:	s = "3check"; break;
					}

					if (s == 0)
						fprintf(stderr, "Do not know variant %u\n", 1u << i);
					else
						v[n++] = Tcl_NewStringObj(s, -1);
				}

				objs[2] = Tcl_NewListObj(n, v);
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
				if (engine.hasFeature(::app::Engine::Feature_SMP))
				{
					v[n++] = Tcl_NewStringObj("smp", -1);
					v[n++] = Tcl_NewStringObj("true", 4);
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
					v[n++] = Tcl_NewStringObj("limitStrength", -1);
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

				objs[3] = Tcl_NewListObj(n, v);
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

				objs[4] = Tcl_NewListObj(n, v);

				setResult(U_NUMBER_OF(objs), objs);
				break;
			}
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
			"analyze", "multiPV", "ponder", "hashSize", "threads", "smp",
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
			Feature_SMP,
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

		if ((size % 2) == 1)
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

				case Feature_SMP:
					engine->changeCores(atoi(value));
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
		char const* type = stringFromObj(objc, objv, 2);
		::app::Engine* engine = tcl::app::scidb->engine(id);

		switch (*type)
		{
			case 's': // script
				engine->updateConfiguration(stringFromObj(objc, objv, 3));
				break;

			case 'o': // options
			{
				::app::Engine::Options opts;

				int size;
				Tcl_Obj** objs;

				if (Tcl_ListObjGetElements(ti, objectFromObj(objc, objv, 3), &size, &objs) != TCL_OK)
					return error(CmdActivate, 0, 0, "list obj expected");

				if ((size % 2) == 1)
					return error(CmdActivate, 0, 0, "options list must have even size");

				for (int i = 0; i < size; i += 2)
					engine->setOption(Tcl_GetString(objs[i]), Tcl_GetString(objs[i + 1]));

				break;
			}
		}

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
		Tcl_Obj* objs[9];
		Tcl_Obj* v[aliases.size() + 1];
		Tcl_Obj* f[8];

		v[0] = Tcl_NewStringObj(player->name(), player->name().size());

		for (unsigned i = 0; i < aliases.size(); ++i)
			v[i + 1] = Tcl_NewStringObj(aliases[i], aliases[i].size());

		f[0] = Tcl_NewBooleanObj(player->supportsChess960());
		f[1] = Tcl_NewBooleanObj(player->supportsShuffleChess());
		f[2] = Tcl_NewBooleanObj(player->supportsThreeCheckChess());
		f[3] = Tcl_NewBooleanObj(player->supportsCrazyhouseChess());
		f[4] = Tcl_NewBooleanObj(player->supportsBughouseChess());
		f[5] = Tcl_NewBooleanObj(player->supportsSuicideChess());
		f[6] = Tcl_NewBooleanObj(player->supportsGiveawayChess());
		f[7] = Tcl_NewBooleanObj(player->supportsLosersChess());

		objs[0] = Tcl_NewStringObj(player->name(), -1);
		objs[1] = Tcl_NewStringObj(::db::country::toString(player->federation()), -1);
		objs[2] = Tcl_NewIntObj(player->latestRating(::db::rating::Elo));
		objs[3] = Tcl_NewIntObj(player->latestRating(::db::rating::Rating));
		objs[4] = Tcl_NewBooleanObj(player->supportsUciProtocol());
		objs[5] = Tcl_NewBooleanObj(player->supportsWinboardProtocol());
		objs[6] = Tcl_NewListObj(8, f);
		objs[7] = Tcl_NewStringObj(player->url(), -1);
		objs[8] = Tcl_NewListObj(aliases.size() + 1, v);

		setResult(Tcl_NewListObj(U_NUMBER_OF(objs), objs));
	}
	else
	{
		setResult("");
	}

	return TCL_OK;
}


static int
cmdInvoke(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->engine(id)->invokeOption(stringFromObj(objc, objv, 2));

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
cmdCountLines(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		setResult(tcl::app::scidb->engine(id)->countLines());
	else
		setResult(0);

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


static int
cmdOrdering(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);
	char const* ordering = stringFromObj(objc, objv, 2);

	if (tcl::app::scidb->engineExists(id))
	{
		::app::Engine::Ordering method = ::app::Engine::Unordered;

		switch (::tolower(*ordering))
		{
			case 'k': method = ::app::Engine::KeepStable; break;
			case 'b': method = ::app::Engine::BestFirst; break;
			case 'u': method = ::app::Engine::Unordered; break;
		}

		tcl::app::scidb->engine(id)->setOrdering(method);
	}

	return TCL_OK;
}


static int
cmdMultiPV(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);
	unsigned value = unsignedFromObj(objc, objv, 2);

	if (tcl::app::scidb->engineExists(id))
		tcl::app::scidb->engine(id)->changeNumberOfVariations(value);

	return TCL_OK;
}


static int
cmdPriority(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);
	char const* priority = stringFromObj(objc, objv, 2);

	if (tcl::app::scidb->engineExists(id))
	{
		sys::Process::Priority value = sys::Process::Unknown;

		switch (tolower(priority[0]))
		{
			case 'n': value = sys::Process::Normal; break;
			case 'l': value = sys::Process::Idle; break;
			case 'h': value = sys::Process::High; break;
		}

		if (value != sys::Process::Unknown)
			tcl::app::scidb->engine(id)->process().setPriority(value);
	}

	return TCL_OK;
}


static int
cmdActive(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
		setResult(tcl::app::scidb->engine(id)->isActive());
	else
		setResult(false);

	return TCL_OK;
}


static int
cmdVariant(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
	{
		mstl::string variant(variant::identifier(tcl::app::scidb->engine(id)->variant()));
		mstl::string::size_type n = variant.find('-');
		if (n != mstl::string::npos)
			variant.erase(variant.begin() + n);
		setResult(variant);
	}

	return TCL_OK;
}


static int
cmdEmpty(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned	id		= unsignedFromObj(objc, objv, 1);
	unsigned line	= unsignedFromObj(objc, objv, 2);

	if (tcl::app::scidb->engineExists(id))
		setResult(tcl::app::Scidb->engine(id)->lineIsEmpty(line));
	else
		setResult(true);

	return TCL_OK;
}


static int
cmdSnapshot(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned	id = unsignedFromObj(objc, objv, 1);
	bool		rc = false;

	if (tcl::app::scidb->engineExists(id))
	{
		::app::Engine* engine = tcl::app::Scidb->engine(id);
		Game* game = engine->currentGame();

		if (objc == 2)
		{
			engine->snapshot();
			rc = !game->atLineEnd();
		}
		else
		{
			char const* cmd = Tcl_GetString(objv[2]);

			if (game)
			{
				if (::strcmp(cmd, "add") == 0 || ::strcmp(cmd, "move") == 0)
				{
					unsigned line = unsignedFromObj(objc, objv, 3);

					if (engine->snapshotExists(line) && !engine->snapshotLine(line).isEmpty())
					{
						if (game->atLineEnd())
						{
							game->addMove(engine->snapshotLine(line)[0]);
							game->goForward();
						}
						else if (::strcmp(cmd, "move") == 0)
						{
							game->addVariation(engine->snapshotLine(line)[0]);
						}
						else
						{
							game->addVariation(engine->snapshotLine(line));
						}

						rc = true;
					}
				}
				else if (!game->isEmpty())
				{
					if (::strcmp(cmd, "line") == 0)
					{
						unsigned line = unsignedFromObj(objc, objv, 3);

						if (engine->snapshotExists(line) && !engine->snapshotLine(line).isEmpty())
						{
							game->mergeVariation(engine->snapshotLine(line));
							rc = true;
						}
					}
					else if (::strcmp(cmd, "all") == 0)
					{
						for (unsigned line = 0; engine->snapshotExists(line); ++line)
						{
							if (!engine->snapshotLine(line).isEmpty())
								rc = true;
						}

						if (rc)
						{
							game->startUndoPoint(Game::RemoveVariations);

							for (unsigned line = 0; engine->snapshotExists(line); ++line)
							{
								if (!engine->snapshotLine(line).isEmpty())
									game->mergeVariation(engine->snapshotLine(line));
							}

							game->endUndoPoint(Game::UpdatePgn);
						}
					}
					else
					{
						return error(CmdSnapshot, 0, 0, "unknown command '%s'", cmd);
					}
				}
			}
		}
	}

	setResult(rc);
	return TCL_OK;
}


static int
cmdBind(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned id = unsignedFromObj(objc, objv, 1);

	if (tcl::app::scidb->engineExists(id))
	{
		::app::Engine* engine = tcl::app::Scidb->engine(id);
		engine->bind(&tcl::app::scidb->game());
	}

	return TCL_OK;
}


namespace tcl {
namespace engine {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdActivate,		cmdActivate);
	createCommand(ti, CmdActive,			cmdActive);
	createCommand(ti, CmdAnalyize,		cmdAnalyze);
	createCommand(ti, CmdBind,				cmdBind);
	createCommand(ti, CmdClearHash,		cmdClearHash);
	createCommand(ti, CmdCountLines,		cmdCountLines);
	createCommand(ti, CmdEmpty,				cmdEmpty);
	createCommand(ti, CmdInfo,				cmdInfo);
	createCommand(ti, CmdInvoke,			cmdInvoke);
	createCommand(ti, CmdKill,				cmdKill);
	createCommand(ti, CmdList,				cmdList);
	createCommand(ti, CmdLog,				cmdLog);
	createCommand(ti, CmdMultiPV,			cmdMultiPV);
	createCommand(ti, CmdOrdering,		cmdOrdering);
	createCommand(ti, CmdPause,			cmdPause);
	createCommand(ti, CmdPriority,		cmdPriority);
	createCommand(ti, CmdProbe,			cmdProbe);
	createCommand(ti, CmdResume,			cmdResume);
	createCommand(ti, CmdStart,			cmdStart);
	createCommand(ti, CmdSetFeatures,	cmdSetFeatures);
	createCommand(ti, CmdSetOptions,		cmdSetOptions);
	createCommand(ti, CmdSnapshot,			cmdSnapshot);
	createCommand(ti, CmdStop,				cmdStop);
	createCommand(ti, CmdVariant,			cmdVariant);
}

} // namespace engine
} // namespace tcl

// vi:set ts=3 sw=3:
