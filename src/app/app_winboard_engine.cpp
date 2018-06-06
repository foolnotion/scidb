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

#include "app_winboard_engine.h"
#include "app_exception.h"

#include "db_game.h"

#include "sys_signal.h"
#include "sys_timer.h"
#include "sys_time.h"

#include "m_stdio.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace app;
using namespace app::winboard;
using namespace db;


static mstl::string
toStr(unsigned value)
{
	char buf[20];
	snprintf(buf, sizeof(buf), "%u", value);
	return buf;
}


static bool
isNumeric(char const* s)
{
	char const* p = s;

	while (isdigit(*p))
		++p;

	return p > s && *p == '\0';
}


static char const*
endOfWord(char const* s)
{
	while (*s && !isspace(*s))
		++s;

	return s;
}


static char const*
endOfKey(char const* s)
{
	if (*s != '"')
		return endOfWord(s);

	do
	{
		if (!*s)
			return s;

		++s;
	}
	while (*s != '"');

	return s + 1;
}


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;
	return s;
}


static char const*
skipDots(char const* s)
{
	while (*s == '.')
		++s;
	return skipSpaces(s);
}


static char const*
skipWord(char const* s)
{
	return skipSpaces(endOfWord(s));
}


static char const*
skipWords(char const* s, unsigned n)
{
	while (n--)
		s = skipWord(s);

	return s;
}


static char const*
skipMoveNumber(char const* s)
{
	while (isdigit(*s))
	{
		do
			++s;
		while (isdigit(*s));

		if (*s == '.')
			++s;

		s = skipSpaces(s);
	}

	return s;
}


mstl::string&
removeHolding(mstl::string& fen)
{
	unsigned count = 0;

	for (char const* s = fen; *s && !::isspace(*s); ++s)
	{
		if (*s == '/' && ++count == 8)
		{
			char const* t = s + 1;

			while (*t && !::isspace(*t))
				++t;

			fen.erase(s, t);
			break;
		}
	}

	return fen;
}


mstl::string
toHolding(material::Count holding)
{
	mstl::string str;

	str.append(holding.pawn,	'P');
	str.append(holding.knight,	'N');
	str.append(holding.bishop,	'B');
	str.append(holding.rook,	'R');
	str.append(holding.queen,	'Q');

	return str;
}


struct winboard::Engine::Timer : public sys::Timer
{
	Timer(winboard::Engine* engine, unsigned timeout) :sys::Timer(timeout), m_engine(engine) {}

	void timeout() { m_engine->timeout(); }

	winboard::Engine* m_engine;
};


winboard::Engine::Engine()
	:m_state(None)
	,m_startTime(0)
	,m_pingCount(0)
	,m_pongCount(0)
	,m_craftyVersion(0)
	,m_isAnalyzing(false)
	,m_response(false)
	,m_waitForDone(false)
	,m_waitForPong(false)
	,m_analyzeResponse(false)
	,m_identifierDetected(false)
	,m_shortNameDetected(false)
	,m_mustUseChess960(false)
	,m_editSent(false)
	,m_dontInvertScore(false)
	,m_wholeSeconds(false)
	,m_wholeSecondsDetected(false)
	,m_featureUsermove(false)
	,m_featureColors(false)
	,m_featureSetboard(false)
	,m_featureSigint(false)
	,m_featureSAN(false)
	,m_featureVariant(false)
	,m_featurePing(false)
	,m_parsingFeatures(false)
	,m_startAnalyzeIsPending(false)
	,m_stopAnalyzeIsPending(false)
	,m_xboardAlreadySent(false)
{
}


winboard::Engine::~Engine() throw() {}


winboard::Engine::Result
winboard::Engine::probeResult() const
{
	if (m_waitForDone)
		return app::Engine::Probe_Failed;

	return m_response ? app::Engine::Probe_Successfull : app::Engine::Probe_Undecidable;
}


winboard::Engine::Result
winboard::Engine::probeAnalyzeFeature() const
{
	if (m_analyzeResponse || hasFeature(app::Engine::Feature_Analyze))
		return app::Engine::Probe_Successfull;

	return app::Engine::Probe_Failed;
}


unsigned
winboard::Engine::probeTimeout() const
{
	return 2000;
}


void
winboard::Engine::invokeOption(mstl::string const& name)
{
	send(name);
}


void
winboard::Engine::sendOptions()
{
	bool isAnalyzing = this->isAnalyzing();

	if (isAnalyzing)
		sendStopAnalysis();

	app::Engine::Options const& opts = options();
	mstl::string msg;

	for (app::Engine::Options::const_iterator i = opts.begin(); i != opts.end(); ++i)
	{
		app::Engine::Option const& opt = *i;

		if (opt.type == "button")
			continue; // we shouldn't trigger any button

		if (	!hasFeature(app::Engine::Feature_SMP)
			|| (opt.type != "spin" && opt.type != "slider")
			|| (opt.name != "Cores" && opt.name != "Threads"))
		{
			msg.assign("option ", 7);
			msg.append(opt.name);
			msg.append('=');

			if (opt.type == "check")
				msg.append(opt.val == "true" ? "1" : "0"); // according to WB
			else
				msg.append(opt.val);

			send(msg);
		}
	}

	if (hasFeature(app::Engine::Feature_Hash_Size))
		send("memory " + ::toStr(hashSize()));

	if (hasFeature(app::Engine::Feature_SMP))
		send("cores " + toStr(numCores()));

#if 0
	if (hasFeature(app::Engine::Feature_Ponder))
		send("setoption name Ponder value false"); // XXX

	if (hasFeature(app::Engine::Feature_Multi_PV))
		send("setoption name MultiPV value " + toStr(numVariations()));
#endif

	if (isAnalyzing)
		sendStartAnalysis();
}


void
winboard::Engine::sendConfiguration(mstl::string const& script)
{
	bool isAnalyzing = this->isAnalyzing();

	if (isAnalyzing)
		sendStopAnalysis();

	mstl::string::size_type sol = 0;

	while (sol < script.size())
	{
		mstl::string::size_type eol = script.find('\n', sol);
		if (eol == mstl::string::npos)
			eol = script.size();
		send(script.substr(sol, eol - sol));
		sol = eol + 1;
		if (sol < script.size() && ::isspace(script[sol])) // skip LF on windows
			++sol;
	}

	if (isAnalyzing)
		sendStartAnalysis();
}


void
winboard::Engine::sendHashSize()
{
	send("memory " + toStr(hashSize()));
}


void
winboard::Engine::sendCores()
{
	send("cores " + ::toStr(numCores()));
}


void
winboard::Engine::sendPondering()
{
	if (pondering())
	{
		send("hard");
	}
	else
	{
		send("hard");
		send("easy");
	}
}


void
winboard::Engine::doMove(Move const& move)
{
	mstl::string s(m_featureUsermove ? "usermove " : "");

	if (move.isNull())
		s.append("@@@@", 4);	// alternatives: "pass", "null", "--"
	else if (/*m_featureSAN || */move.isPieceDrop() || (move.isCastling() && m_mustUseChess960))
		move.printSAN(s, protocol::Standard, encoding::Latin1);
	else
		move.printCAN(s, protocol::Standard, encoding::Latin1);

	send(s);
}


void
winboard::Engine::setupBoard(Board const& board)
{
	if (m_featureSetboard)
	{	// NOTE:
		// The WinBoard documentation doesn't specify any specific
		// FEN format for Chess 960. Thus we will assume that the
		// engine is understanding X-Fen().
		// IMPORTANT NOTE:
		// The "setboard" command might not be appropriate, because
		// it might clear the hash tables.
		mstl::string fen(board.toValidFen(currentVariant()));

		::removeHolding(fen);
		send("setboard " + fen);

		// NOTE: it's unclear which version has removed "mn", I guess it's version 25
		if (0 < m_craftyVersion && m_craftyVersion < 25)
		{
			mstl::string msg;
			msg.format("mn %u", board.moveNumber());
			send(msg);
		}
	}
	else
	{
		if (m_featureColors)
			send(board.whiteToMove() ? "white" : "black");
		else if (board.blackToMove())
			send("a2a3");

		send("edit");
		send("#");	// clear board
		m_editSent = true;

		for (int i = 0; i < 64; ++i)
		{
			piece::ID piece = board.pieceAt(i);

			if (piece::color(piece) == color::White)
				send(mstl::string(1, piece::print(piece::type(piece))) + sq::printAlgebraic(sq::ID(i)));
		}

		send("c");	// change current piece color (initially white)

		for (int i = 0; i < 64; ++i)
		{
			piece::ID piece = board.pieceAt(i);

			if (piece::color(piece) == color::Black)
				send(mstl::string(1, piece::print(piece::type(piece))) + sq::printAlgebraic(sq::ID(i)));
		}

		send(".");	// leave edit mode
	}

	if (variant::isZhouse(currentGame()->variant()))
	{
		mstl::string str("holding [");
		str.append(::toHolding(board.holding(color::White)));
		str.append("] [");
		str.append(::toHolding(board.holding(color::Black)));
		str.append("]");
		send(str);
	}
}


void
winboard::Engine::reset()
{
	m_editSent = false;
}


bool
winboard::Engine::isAnalyzing() const
{
	return m_isAnalyzing;
}


bool
winboard::Engine::startAnalysis(bool)
{
	M_ASSERT(currentGame());
	M_ASSERT(isActive());
	M_ASSERT(!currentGame()->currentBoard().gameIsOver(currentGame()->variant()));

	m_state = Start;

	if (m_stopAnalyzeIsPending)
	{
		m_startAnalyzeIsPending = true; // wait on "pong"
		return true;
	}

	m_startAnalyzeIsPending = false;

	db::Game const* game = currentGame();

	History moves;
	game->getHistory(moves);

	mstl::string v;

	if (m_featureSigint)
		::sys::signal::sendInterrupt(pid());

	send("new");
	send("force");

	if (m_featureVariant)
	{
		if (isChess960Position())
		{
			if (game->variant() != variant::Normal)
				error(app::Engine::Chess_960_Not_Supported);

			v = m_chess960Variant;
		}
		else
		{
			switch (currentVariant())
			{
				case variant::Losers:		v = "losers"; break;
				case variant::Suicide:		v = "suicide"; break;
				case variant::Giveaway:		v = "giveaway"; break;
				case variant::Bughouse:		v = "bughouse"; break;
				case variant::Crazyhouse:	v = "crazyhouse"; break;
				case variant::ThreeCheck:	v = "3check"; break;

				case variant::Normal:
					// TODO: probably "wildcastle" is required
					v = "normal";
					break;

				default:
					M_RAISE("unexpected variant %s", variant::identifier(game->variant()).c_str());
			}
		}

		send("variant " + v);
	}

	if (moves.empty())
	{
		if (!currentBoard().isStandardPosition(currentVariant()))
			setupBoard(currentBoard());
	}
	else if (	!m_featureSetboard
				||	(	!analysesOpponentsView()
					&& game->historyIsLegal(Game::DontAllowNullMoves)))
	{
		if (!game->startBoard().isStandardPosition(currentVariant()))
			setupBoard(game->startBoard());

		for (int i = moves.size() - 1; i >= 0; --i)
			doMove(moves[i]);

		if (analysesOpponentsView())
			doMove(Move::null());
	}
	else if (m_featureSetboard)
	{
		setupBoard(currentBoard());
	}
	else
	{
		error(app::Engine::Illegal_Moves);
		return false;
	}

	send("post");	// turn on thinking output
	sendStartAnalysis();

	if (!m_wholeSecondsDetected)
		m_startTime = ::sys::time::timestamp();

	m_isAnalyzing = true;
	updateState(app::Engine::Start);

	return true;
}


void
winboard::Engine::sendStartAnalysis()
{
	if (searchMate())
	{
		error(app::Engine::Search_Mate_Not_Supported);
	}
	else if (searchDepth())
	{
		mstl::string depth(::toStr(searchDepth()));
		send("sd " + depth);
		send("depth " + depth);		// some engines are expecting "depth" instead of "sd"
	}
	else if (searchTime())
	{
		send("time " + ::toStr((searchTime() + 9)/10));
	}
	else if (hasFeature(app::Engine::Feature_Analyze))
	{
		send("analyze");
	}
	else
	{
		send("sd 50");
		send("depth 50");				// some engines are expecting "depth" instead of "sd"
		send("st 120000");			// not all engines do understand "level"
		send("level 1 120000 0");	// better than "st 120000"
		send("go");

		// NOTE: GNU Chess 4 might expect "depth\n50" !!
	}
}


bool
winboard::Engine::stopAnalysis(bool restartIsPending)
{
	State oldState = m_state;

	m_startAnalyzeIsPending = false;
	m_state = Stop;

	if (!isAnalyzing())
		return false;

	m_isAnalyzing = false;

	if (!m_stopAnalyzeIsPending)
	{
		if (oldState != Pause)
		{
			sendStopAnalysis();
			m_stopAnalyzeIsPending = true;
		}
		reset();

		if (!restartIsPending)
			updateState(app::Engine::Stop);

		if (m_stopAnalyzeIsPending)
		{
			mstl::string ping;
			ping.format("ping %u", ++m_pingCount);
			send(ping);

			if (m_pingCount == 1)
			{
				// Catch possible problem: the engine may not respond to "ping".
				m_waitForPong = true;
				m_timer = new Timer(this, 2000);
			}

			// the engine should now send "pong"
		}
	}

	return true;
}


bool
winboard::Engine::continueAnalysis()
{
	return false;
}


void
winboard::Engine::pongReceived()
{
	m_stopAnalyzeIsPending = false;
	m_timer.reset();
	m_waitForPong = false;
	m_pongCount = m_pingCount;

	if (m_startAnalyzeIsPending)
	{
		// Catch a possible timing problem.
		if (!currentGame()->currentBoard().gameIsOver(currentGame()->variant()))
			startAnalysis(true);
	}
}


void
winboard::Engine::sendStopAnalysis()
{
	if (hasFeature(app::Engine::Feature_Analyze))
		send("exit");	// leave analyze mode

	send("force");		// stop engine replying to moves
}


bool
winboard::Engine::pause()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("pause");
	else
		sendStopAnalysis();

	m_state = Pause;
	updateState(app::Engine::Pause);
	return true;
}


bool
winboard::Engine::resume()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("resume");
	else
		sendStartAnalysis();

	m_state = Start;
	updateState(app::Engine::Resume);
	return true;
}


bool
winboard::Engine::isReady() const
{
	return m_response;
}


void
winboard::Engine::protocolStart(bool isProbing)
{
	if (supportedVariants() == 0)
		addVariant(variant::Normal);

	if (!m_xboardAlreadySent)
		send("xboard");
	send("protover 2");
//	send("ponder off");
	send("easy");

	if (isProbing)
	{
		send("log off");		// turn off crafty logging, to reduce number of junk files
//		send("ping 0");		// probably the engine will send 'pong 0'
		send("new");
		send("sd 1");
		send("depth 1");		// some engines are expecting "depth" instead of "sd"
		send("st 1");			// "level 1 1 0" does not work with any machine
		send("time 1");		// not any machine is supporting "time"
		send("post");
		send("go");				// NOTE: don't send "go" if the user is to move

		// NOTE: GNU Chess 4 might expect "depth\n1" !!
	}
	else
	{
		send("force");	// prevent some engines from making an immediate "book" reply move

		// By spec we must wait up to 2 seconds to
		// receive all features offers from engine.
		m_timer = new Timer(this, 2000);
	}
}


void
winboard::Engine::protocolEnd()
{
	stopAnalysis(false);

	if (m_featureSigint)
		::sys::signal::sendInterrupt(pid());

	send("quit");
}


void
winboard::Engine::stimulate()
{
	send("xboard");
	m_xboardAlreadySent = true;
}


void
winboard::Engine::featureDone(bool done)
{
	// We've received a "done" feature offer from engine,
	// so it supports version 2 or better of the xboard protocol.

	m_response = true;
	m_parsingFeatures = false;

	if (!done)
	{
		m_waitForDone = true;
	}
	else
	{
		m_waitForDone = false;

		if (!isProbing())
		{
			// No need to wait any longer wondering if we're talking to a version 1 engine
			m_timer.reset();
			sendOptions();
			engineIsReady();
		}
	}
}


void
winboard::Engine::timeout()
{
	if (isProbing())
	{
		if (m_parsingFeatures)
			m_response = true;

		deactivate();
	}
	else if (m_waitForPong)
	{
		error(app::Engine::Did_Not_Receive_Pong);
		deactivate();
	}
	else
	{
		send("hard");
		send("easy");	// turn off pondering
		engineIsReady();
	}

	m_timer.reset();
}


void
winboard::Engine::processMessage(mstl::string const& message)
{
	char const* msg = message;

	// GNU Chess always prompts ...
	if (::strncmp(msg, "White (1) : ", 12) == 0)
		msg += 12;

	if (isAnalyzing())
	{
		parseAnalysis(msg);
		m_editSent = false;
	}
	else
	{
		switch (msg[0])
		{
			case 'f':
				if (::strncmp(msg, "feature ", 8) == 0)
					return parseFeatures(::skipSpaces(msg + 8));
				break;

			case 'p':
				if (::strncmp(msg, "pong ", 5) == 0)
				{
					if (isProbing())
					{
						m_response = true;
						return;
					}

					if (	m_stopAnalyzeIsPending
						&& m_pongCount < m_pingCount
						&& ::atoi(::skipSpaces(msg + 5)) == int(m_pingCount))
					{
						pongReceived();
					}
				}
				break;

			case 't':
				if (!isProbing() && ::strncmp(msg, "tellics", 7) == 0)
					m_response = true;
				break;

			case 'm':
				if (isProbing() && ::strncmp(msg, "move ", 5) == 0)
				{
					m_response = true;
					return;
				}
				// fallthru

			case 'M':
				if (::strncasecmp(msg, "my move is", 10) == 0)
				{
					if (isProbing())
					{
						m_response = true;
						return;
					}

					// TODO: do something with move
					// skip possible colon after " is".
					return;
				}
				break;

			case 'r':
				if (::strncmp(msg, "resign", 6) == 0)
				{
					// TODO: handle resign
					return;
				}
				break;

			case '1':
				if (::strncmp(msg, "1-0", 3) == 0)
				{
					// TODO: handle "White wins"
					return;
				}
				else if (::strncmp(msg, "1/2-1/2", 7) == 0)
				{
					// TODO: handle "Engine declares draw"
					return;
				}
				break;

			case '0':
				if (::strncmp(msg, "resign", 6) == 0)
				{
					// TODO: handle "Black wins"
					return;
				}
				break;

			case 'I':
			case 'i':	// handle older versions of Crafty
			case 'E':
			case 'e':	// to be sure
				if (::strncasecmp(msg, "Error", 5) == 0 || ::strncasecmp(msg, "Illegal move", 12) == 0)
				{
					if (	!m_featurePing
						&& m_stopAnalyzeIsPending
						&& m_pongCount < m_pingCount
						&& ::strstr(msg, "ping"))
					{
						if (++m_pongCount == m_pingCount)
							pongReceived();
					}
					else
					{
						error(msg);
					}
					return;
				}
				break;
		}

		detectFeatures(msg);

		if (isProbing())
		{
			if (!m_identifierDetected)
				m_identifierDetected = m_shortNameDetected = detectIdentifier(message);
			else if (!m_shortNameDetected)
				m_shortNameDetected = detectShortName(message);
		}
	}
}


void
winboard::Engine::parseFeatures(char const* msg)
{
	m_parsingFeatures = true;

	while (true)
	{
		char const* key	= msg;
		char const* sep	= ::strchr(msg, '=');

		if (sep == 0 || sep[0] == '\0' || sep[1] == '\0')
			return;

		char const* val	= sep + 1;
		char const* end	= ::endOfKey(val);

//		bool accept	= false;
//		bool reject	= false;

		switch (msg[0])
		{
			case '\0':
				return;

			case 'a':
				if (::strncmp(key, "analyze=", 8) == 0)
				{
					if (*val == '1')
						addFeature(app::Engine::Feature_Analyze);
//					accept = true;
				}
				break;

			case 'c':
				if (::strncmp(key, "colors=", 7) == 0)
				{
					m_featureColors = *val == '1';
//					accept = true;
				}
				break;

			case 'd':
				if (::strncmp(key, "done=", 5) == 0)
				{
					featureDone(*val == '1');
//					accept = true;
				}
				break;

			case 'm':
				if (::strncmp(key, "myname=", 7) == 0)
				{
					if (val[0] == '"' && end[-1] == '"')
					{
						mstl::string identifier(val + 1, end - 1);
						setIdentifier(identifier);
						m_identifierDetected = true;
						detectFeatures(mstl::string(val + 1, end - val));

						if (isProbing() && detectShortName(identifier))
							m_shortNameDetected = true;
					}
				}
				else if (::strncmp(key, "memory=", 7) == 0)
				{
					if (*val == '1')
						addFeature(app::Engine::Feature_Hash_Size);
				}
				break;

			case 'o':
				if (::strncmp(key, "option=", 7) == 0)
					parseOption(key + 7);
				break;

			case 'p':
				switch (key[1])
				{
					case 'a':
						if (::strncmp(key, "pause=", 6) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_Pause);
//							accept = true;
						}
						break;

					case 'i':
						if (::strncmp(key, "pong=", 5) == 0)
						{
							m_featurePing = *val == '1';
//							accept = true;
						}
						break;

					case 'l':
						if (::strncmp(key, "playother=", 10) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_Play_Other);
//							accept = true;
						}
						break;
				}
				break;

			case 's':
				switch (key[1])
				{
					case 'a':
						if (::strncmp(key, "san=", 4) == 0)
						{
							m_featureSAN = *val == '1';
//							accept = true;
						}
						break;

					case 'e':
						if (::strncmp(key, "setboard=", 9) == 0)
						{
							m_featureSetboard = *val == '1';
//							accept = true;
						}
						break;

					case 'i':
						if (::strncmp(key, "sigint=", 7) == 0)
						{
							 m_featureSigint= *val == '1';
//							accept = true;
						}
						break;

					case 'm':
						if (::strncmp(key, "smp=", 4) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_SMP);
						}
						break;
				}
				break;

			case 'u':
				if (::strncmp(key, "usermove=", 9) == 0)
				{
					m_featureUsermove = *val == '1';
//					accept = true;
				}
				break;

			case 'v':
				if (::strncmp(key, "variants=", 9) == 0)
				{
					unsigned count = 0;

					removeVariant(variant::Normal);
					++val;

					do
					{
						char const* p = ::strchr(val, ',');

						if (p == 0)
							p = val + ::strlen(val) - 1;

						mstl::string variant(val, p);
						variant.trim();

						count += 1;

						switch (variant[0])
						{
							case 'b':
								if (::strcmp(variant, "bughouse") == 0)
									addVariant(variant::Bughouse);
								break;

							case 'c':
								if (::strcmp(variant, "chess960") == 0)
								{
									setSupportsChess960Positions();
									m_chess960Variant = variant;
								}
								else if (::strcmp(variant, "crazyhouse") == 0)
								{
									addVariant(variant::Crazyhouse);
								}
								break;

							case 'f':
								if (::strcmp(variant, "fischerandom") == 0)
								{
									setSupportsChess960Positions();
									m_chess960Variant = variant;
								}
								break;

							case 'g':
								if (::strcmp(variant, "giveaway") == 0)
									addVariant(variant::Giveaway);
								break;

							case 'l':
								if (::strcmp(variant, "losers") == 0)
									addVariant(variant::Losers);
								break;

							case 'n':
								if (::strcmp(variant, "normal") == 0)
									addVariant(variant::Normal);
								break;

							case 's':
								if (::strcmp(variant, "standard") == 0)
									addVariant(variant::Normal);
								else if (::strcmp(variant, "suicide") == 0)
									addVariant(variant::Suicide);
								break;

							case '3':
								if (::strcmp(variant, "3check") == 0)
									addVariant(variant::ThreeCheck);
								break;
						}

						val = ::skipSpaces(p + 1);
					}
					while (*val);

					m_featureVariant = (count > 1);
				}
				break;
		}

#if 0
		if (accept)
			send("accepted " + mstl::string(key, sep));
		else if (reject)
			send("rejected " + mstl::string(key, sep));
#endif

		msg = ::skipSpaces(end);
	}
}


void
winboard::Engine::parseAnalysis(mstl::string const& msg)
{
	switch (msg[0])
	{
		case 'I':
		case 'i':	// handle older versions of Crafty
		case 'E':
		case 'e':	// to be sure
			if (::strncasecmp(msg, "Error", 5) == 0 || ::strncasecmp(msg, "Illegal move", 12) == 0)
			{
				if (msg == "illegal move: sd" || msg == "illegal move: st" || msg == "illegal move: depth")
				{
					// ignore this error message
				}
				else if (isAnalyzing() && m_editSent && ::strstr(msg, "edit"))
				{
					stopAnalysis(false);
					error(app::Engine::No_Analyze_Mode);
				}
				else
				{
					error(msg);
				}
				return;
			}
			break;

		case 'a':
			if (::strncmp(msg, "analyze mode", 12) == 0)
				addFeature(app::Engine::Feature_Analyze);
			break;

		case 'm':
			if (::strncmp(msg, "move ", 5) == 0)
			{
				// some engines - for example TJchess - do exit
				// analyze mode with sending a move
				stopAnalysis(false);
			}
			return;

		case 't':
			if (::strncmp(msg, "telluser", 8) == 0)
			{
				if (::strncmp(msg.c_str() + 8, "error ", 6) != 0)
				{
					log(msg.substr(1));
				}
				else
				{
					stopAnalysis(false);
					error(msg.substr(15));
				}

				return;
			}
			break;
	}

	if (::isdigit(msg[0]))
		parseInfo(msg);

	m_editSent = false;
}


void
winboard::Engine::parseInfo(mstl::string const& msg)
{
	int			score;
	unsigned		depth;
	char const	*s;

	if (::sscanf(msg, "%u", &depth) != 1)
		return;

	resetInfo();
	setDepth(depth);

	unsigned hours(0);
	unsigned minutes(0);
	unsigned seconds;
	unsigned time;
	unsigned nodes;
	unsigned unused;
	float		fscore;

	s = ::skipWord(msg);

	if (::sscanf(s, "%d %u %u ", &score, &time, &nodes) == 3)
	{
		setTime(m_wholeSeconds ? double(time) : time/100.0);
		setNodes(nodes);
		s = ::skipWords(msg, 3);

		if (!m_wholeSecondsDetected)
		{
			uint64_t elapsedTime = ::sys::time::timestamp() - m_startTime;
			if (time*uint64_t(100) > elapsedTime)
				m_wholeSeconds = true;
			m_wholeSecondsDetected = true;
		}
	}
	else if (parseCurrentMove(s))
	{
		return;
	}
	else if (	::sscanf(s, "%u.%u %f", &seconds, &unused, &fscore) == 3
				|| ::sscanf(s, "%u:%u %f", &minutes, &seconds, &fscore) == 3
				|| ::sscanf(s, "%u:%u:%u %f", &hours, &minutes, &seconds, &fscore) == 3)
	{
		setTime((hours*60 + minutes)*60 + seconds);
		score = int(fscore*1000.0 + 0.5);
		s = ::skipWords(msg, 2);
	}

	char const*	illegal(0);
	char const*	e(0);
	char const*	str(s);
	Board 		board(currentBoard());
	MoveList 	moves;

	while (*s)
	{
		s = ::skipMoveNumber(s);

		Move move;
		char const* t = board.parseMove(s, move, currentVariant(), move::MustBeUnambiguous);

		if (t)
		{
			if (move.isLegal())
			{
				board.prepareForPrint(move, currentVariant(), Board::InternalRepresentation);
				board.doMove(move, currentVariant());
				moves.append(move);
				illegal = 0;
				s = ::skipSpaces(t);

				if (moves.isFull())
				{
					log("WARNING: PV is too long (truncated)");
					break;
				}
			}
			else
			{
				illegal = s;
				e = s = ::skipWord(s);
				break;
			}
		}
		else
		{
			s = ::skipWord(s);
		}
	}

	if (illegal)
	{
		mstl::string errMsg("Illegal move in PV: ");
		errMsg.append(illegal, e - illegal);
		errMsg.trim();
		errMsg.append(" (", 2);
		errMsg.append(::skipMoveNumber(str), e);
		errMsg.trim();
		errMsg.append(")", 1);
		error(errMsg);

		if (moves.isEmpty() && isAnalyzing())
		{
			// Some engines (e,g. Gaviota) are playing the bestmove
			// automatically, thus starting from a wrong position in
			// case of restart. Restart analysis again in this case.
			stopAnalysis(true);
			startAnalysis(true);
		}
		return;
	}

	if (moves.size() == 0)
	{
		updateTimeInfo();
	}
	else
	{
		int varno = -1;

		m_analyzeResponse = true;

		if (moves.size() == 1)
		{
			if (msg.back() == '>')
			{
				// any garbage from Sjeng
				updateTimeInfo();
				return;
			}

			varno = findVariation(moves.front());

			setCurrentMove(0, 0, moves[0]);
			updateCurrMove();

			if (msg.back() == '!')
			{
				updateTimeInfo();
				return;
			}
		}

		if (varno == -1)
			varno = setVariation(0, moves);

		if (board.checkState(currentVariant()) & Board::Checkmate)
		{
			int n = mstl::div2(board.plyNumber() - currentBoard().plyNumber() + 1);
			setMate(varno, board.whiteToMove() ? -n : +n);
		}
		else
		{
			setScore(varno, m_dontInvertScore || currentBoard().whiteToMove() ? score : -score);
		}

		updatePvInfo(varno);
	}
}


bool
winboard::Engine::parseCurrentMove(char const* s)
{
	unsigned	hours(0);
	unsigned	minutes(0);
	unsigned	seconds;
	unsigned	moveNo;
	unsigned	moveCount;
	unsigned	unused;

	if (	::sscanf(s, "%u.%u %u/%u?", &seconds, &unused, &moveNo, &moveCount) == 4
		|| ::sscanf(s, "%u:%u %u/%u?", &minutes, &seconds, &moveNo, &moveCount) == 4
		|| ::sscanf(s, "%u:%u:%u %u/%u?", &hours, &minutes, &seconds, &moveNo, &moveCount) == 5)
	{
		s = ::skipMoveNumber(::skipWords(s, 3));

		Move move;
		char const* t = currentBoard().parseMove(::skipDots(s), move, currentVariant(), move::MustBeUnambiguous);

		if (t == 0)
			return true; // skip it anayway

		if (move.isLegal())
		{
			currentBoard().prepareForPrint(move, currentVariant(), Board::InternalRepresentation);
			setCurrentMove(moveNo, moveCount, move);
			updateCurrMove();
			setTime((hours*60 + minutes)*60 + seconds);
			updateTimeInfo();
		}
		else
		{
			mstl::string msg("Illegal current move: ");
			msg.append(s, t - s);
			msg.trim();
			error(msg);
		}

		return true;
	}

	return false;
}


void
winboard::Engine::parseOption(mstl::string const& option)
{
	// SYNTAX: "NAME -TYPE ARGS"

	if (option.size() < 8 || option.front() != '"' || option.back() != '"')
		return;

	mstl::string::size_type i = option.find('-');

	if (i == mstl::string::npos)
		return;

	mstl::string name(option.substr(1, i - 1));
	mstl::string::size_type k = option.find(' ', i);

	if (k == mstl::string::npos)
		return;

	mstl::string type(option.substr(i + 1, k - i - 1));
	mstl::string args(option.substr(k, option.size() - k - 1));

	name.trim(); args.trim();

	if (name.empty() || type.empty())
		return;

	if (type == "button")
	{
		addOption(name, type);
	}
	else if (type == "save")
	{
		// ignore immediate commands
	}
	else if (type == "reset")
	{
		// ignore re-setting of options
	}
	else if (type == "check")
	{
		addOption(name, type, args == "1" ? "true" : "false"); // according to UCI
	}
	else if (type == "string")
	{
		addOption(name, type, args);
	}
	else if (type == "spin" || type == "slider")
	{
		// feature option="NAME -spin VALUE MIN MAX"
		char const* s1 = ::skipSpaces(args.begin());
		char const* s2 = ::skipWord(s1);
		char const* s3 = ::skipSpaces(s2);
		char const* s4 = ::skipWord(s3);
		char const* s5 = ::skipSpaces(s4);
		char const* s6 = ::skipWord(s5);

		if (s6 != args.end())
			return;

		mstl::string val(s1, s2);
		mstl::string min(s3, s4);
		mstl::string max(s5, s6);

		val.trim(); min.trim(); max.trim();

		if (!::isNumeric(val) || !::isNumeric(min) || !::isNumeric(max))
			return;

		if (hasFeature(app::Engine::Feature_SMP) && (name == "Cores" || name == "Threads"))
			setThreadRange(::atoi(min), ::atoi(max));
		else
			addOption(name, type, val, min, max);

//		if (name == "memory")
//			setHashRange(::atoi(min), ::atoi(max));
//		else if (name == "smp")
//			setThreadRange(::atoi(min), ::atoi(max));
	}
	else if (type == "combo")
	{
		mstl::string values;
		mstl::string dflt;

		char const* s = skipSpaces(args);

		while (*s)
		{
			char const* t = strchr(s, '/');

			while (t && *t && ::strncmp(t, "///", 3) != 0)
				t = strchr(t + 1, '/');

			if (t == 0)
				t = args.end();

			mstl::string choice(s, t);
			choice.trim();

			if (!choice.empty())
			{
				if (choice.front() == '*')
				{
					choice.erase(choice.begin());
					dflt = choice;
				}

				if (!choice.empty())
				{
					if (!values.empty())
						values += ';';
					values += choice;
				}
			}

			s = *t ? skipSpaces(t + 3) : t;
		}

		if (!dflt.empty() && !values.empty())
			addOption(name, type, dflt, values);
	}
	else if (type == "file" || type == "path")
	{
		addOption(name, type, args);
	}
}


void
winboard::Engine::detectFeatures(char const* identifier)
{
	if (m_craftyVersion == 0 && ::strncmp(identifier, "Crafty", 5) == 0)
	{
		if (::sscanf(identifier, "Crafty v%u.", &m_craftyVersion) == 0)
			m_craftyVersion = 1;
		else if (m_craftyVersion >= 18)
			m_dontInvertScore = true;

		if (isProbing())
			send("log off");	// turn off crafty logging, to reduce number of junk files

		send("linelength 100000"); // disable line breaks

		addFeature(app::Engine::Feature_Analyze);
		m_featureSetboard = true;
	}
}

// vi:set ts=3 sw=3:
