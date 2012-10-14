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
// Copyright: (C) 2009-2012 Gregor Cramer
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
	while (!isspace(*s))
	{
		if (!*s)
			return s;

		++s;
	}

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
skipWord(char const* s)
{
	while (*s && !isspace(*s))
		++s;

	return skipSpaces(s);
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
	if (isdigit(*s))
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


struct winboard::Engine::Timer : public sys::Timer
{
	Timer(winboard::Engine* engine, unsigned timeout) :sys::Timer(timeout), m_engine(engine) {}

	void timeout() { m_engine->timeout(); }

	winboard::Engine* m_engine;
};


winboard::Engine::Engine()
	:m_currentVariant("standard")
	,m_startTime(0)
	,m_isAnalyzing(false)
	,m_response(false)
	,m_waitForDone(false)
	,m_analyzeResponse(false)
	,m_identifierDetected(false)
	,m_shortNameDetected(false)
	,m_mustUseChess960(false)
	,m_mustUseNoCastle(false)
	,m_editSent(false)
	,m_dontInvertScore(false)
	,m_wholeSeconds(false)
	,m_wholeSecondsDetected(false)
	,m_featureUsermove(false)
	,m_featureColors(false)
	,m_featureSetboard(false)
	,m_featureSigint(false)
	,m_featureSan(false)
	,m_isCrafty(false)
{
}


winboard::Engine::~Engine() throw() {}


db::Board const&
winboard::Engine::currentBoard() const
{
	return m_board;
}


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

		msg.assign("option ", 7);
		msg.append(opt.name);
		msg.append('=');

		if (opt.type == "check")
			msg.append(opt.val == "true" ? "1" : "0"); // according to WB
		else
			msg.append(opt.val);

		send(msg);
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
	else if (m_featureSan)
		move.printSan(s);
	else if (!move.isCastling())
		move.printAlgebraic(s);
	else if (m_mustUseChess960)
		move.printSan(s);
	else if (move.isShortCastling())
		s.append(color::isWhite(move.color()) ? "e1g1" : "e8g8", 4);
	else
		s.append(color::isWhite(move.color()) ? "e1c1" : "e8c8", 4);

	send(s);
}


void
winboard::Engine::setupBoard(Board const& board)
{
	if (m_featureSetboard)
	{	// NOTE:
		// The WinBoard documentation doesn't specify
		// any specific FEN format for Chess 960.
		// Thus we will assume that the engine is
		// understanding X-Fen().
		// IMPORTANT NOTE:
		// The "setboard" command might not be appropriate,
		// because it will clear the hash tables.
		send("setboard " + board.toFen());

		if (m_isCrafty)
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
winboard::Engine::startAnalysis(bool isNewGame)
{
	M_ASSERT(currentGame());
	M_ASSERT(isActive());

	db::Game const* game = currentGame();

	History moves;
	game->getHistory(moves);

	stopAnalysis();

	m_board = game->currentBoard();

	unsigned state = m_board.checkState();

	if (state & Board::CheckMate)
	{
		updateCheckMateInfo();
	}
	else if (state & Board::StaleMate)
	{
		updateStaleMateInfo();
	}
	else
	{
		Board const& startBoard = game->startBoard();
		mstl::string v;

		switch (currentVariant())
		{
			case app::Engine::Variant_Standard:		v = "standard"; break;
			case app::Engine::Variant_Chess_960:	v = m_chess960Variant; break;
			case app::Engine::Variant_Losers:		v = "losers"; break;
			case app::Engine::Variant_Bughouse:		v = "bughouse"; break;
			case app::Engine::Variant_Crazyhouse:	v = "crazyhouse"; break;
		}

		if (m_currentVariant != v)
		{
			send("variant " + v);
			m_currentVariant.swap(v);
		}

		if (m_featureSigint)
			::sys::signal::sendInterrupt(pid());

		send("new");
		send("force");

		if (moves.empty())
		{
			if (!m_board.isStandardPosition())
				setupBoard(m_board);
		}
		else
		{
			if (!startBoard.isStandardPosition())
				setupBoard(startBoard);

			for (int i = moves.size() - 1; i >= 0; --i)
				doMove(moves[i]);
		}

		send("post");	// turn on thinking output
		sendStartAnalysis();

		if (!m_wholeSecondsDetected)
			m_startTime = ::sys::time::timestamp();

		m_isAnalyzing = true;
		updateState(app::Engine::Start);
	}

	return true;
}


void
winboard::Engine::sendStartAnalysis()
{
	if (hasFeature(app::Engine::Feature_Analyze))
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
winboard::Engine::stopAnalysis()
{
	if (isAnalyzing())
	{
		sendStopAnalysis();
		reset();
		m_isAnalyzing = false;
		updateState(app::Engine::Stop);

		// TODO: we should send now the best move so far
		// because the UCI protocol is doing this
	}

	return true;
}


void
winboard::Engine::sendStopAnalysis()
{
	if (hasFeature(app::Engine::Feature_Analyze))
		send("exit");	// leave analyze mode

	send("force");		// Stop engine replying to moves.
}


void
winboard::Engine::pause()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("pause");
	else
		sendStopAnalysis();

	updateState(app::Engine::Pause);
}


void
winboard::Engine::resume()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("resume");
	else
		sendStartAnalysis();

	updateState(app::Engine::Resume);
}


bool
winboard::Engine::isReady() const
{
	return m_response;
}


void
winboard::Engine::protocolStart(bool isProbing)
{
	addVariant(app::Engine::Variant_Standard);

	send("xboard");
	send("protover 2");
//	send("ponder off");
	send("easy");

	if (isProbing)
	{
		send("log off");		// turn off crafty logging, to reduce number of junk files
//		send("ping");			// probably the engine will send 'pong'
		send("new");
		send("sd 1");
		send("depth 1");		// some engines are expecting "depth" instead of "sd"
		send("st 1");			// "level 1 1 0" does not work with any machine
		send("st 0");
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
	stopAnalysis();

	if (m_featureSigint)
		::sys::signal::sendInterrupt(pid());

	send("quit");
}


void
winboard::Engine::featureDone(bool done)
{
	// We've received a "done" feature offer from engine,
	// so it supports version 2 or better of the xboard protocol.

	m_response = true;

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
				{
					m_response = true;
					return parseFeatures(::skipSpaces(msg + 8));
				}
				break;

			case 'p':
				if (isProbing() && ::strncmp(msg, "pong ", 5) == 0)
				{
					m_response = true;
					return;
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
					case 'u':
						if (::strncmp(key, "pause=", 6) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_Pause);
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
							m_featureSan = *val == '1';
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
					removeVariant(app::Engine::Variant_Standard);
					++val;

					do
					{
						char const* p = ::strchr(val, ',');

						if (p == 0)
							p = val + ::strlen(val) - 1;

						mstl::string variant(val, p);
						variant.trim();

						switch (variant[0])
						{
							case 'b':
								if (::strcmp(variant, "bughouse") == 0)
									addVariant(app::Engine::Variant_Bughouse);
								break;

							case 'c':
								if (::strcmp(variant, "chess960") == 0)
								{
									addVariant(app::Engine::Variant_Chess_960);
									m_chess960Variant = variant;
								}
								else if (::strcmp(variant, "crazyhouse") == 0)
								{
									addVariant(app::Engine::Variant_Crazyhouse);
								}
								break;

							case 'f':
								if (::strcmp(variant, "fischerandom") == 0)
								{
									addVariant(app::Engine::Variant_Chess_960);
									m_chess960Variant = variant;
								}
								break;

							case 'g':
								if (::strcmp(variant, "giveaway") == 0)
									addVariant(app::Engine::Variant_Give_Away);
								break;

							case 'l':
								if (::strcmp(variant, "losers") == 0)
									addVariant(app::Engine::Variant_Losers);
								break;

							case 'n':
								if (::strcmp(variant, "normal") == 0)
									addVariant(app::Engine::Variant_Standard);
								break;

							case 's':
								if (::strcmp(variant, "standard") == 0)
									addVariant(app::Engine::Variant_Standard);
								else if (::strcmp(variant, "suicide") == 0)
									addVariant(app::Engine::Variant_Suicide);
								break;

							case '3':
								if (::strcmp(variant, "3check") == 0)
									addVariant(app::Engine::Variant_Three_Check);
								break;
						}

						val = ::skipSpaces(p + 1);
					}
					while (*val);
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
			if (	::strncmp(msg.c_str() + 1, "rror", 4) == 0
				|| ::strncmp(msg.c_str() + 1, "llegal move", 11) == 0)
			{
				if (msg == "illegal move: sd" || msg == "illegal move: st" || msg == "illegal move: depth")
				{
					// ignore this error message
				}
				else if (isAnalyzing() && m_editSent && ::strstr(msg, "edit"))
				{
					stopAnalysis();
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

		case 't':
			if (::strncmp(msg, "telluser", 8) == 0)
			{
				if (::strncmp(msg.c_str() + 8, "error ", 6) == 0)
				{
					stopAnalysis();
					error(msg.substr(15));
					return;
				}
				else
				{
					log(msg.substr(1));
					return;
				}
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
	unsigned		nodes;
	unsigned		time;
	char const	*s;

	if (::sscanf(msg, "%u", &depth) != 1 || ::sscanf(s = ::skipWord(msg), "%d %u %u ", &score, &time, &nodes) != 3)
		return parseCurrentMove(s);

	s = ::skipWords(msg, 3);

	if (!m_wholeSecondsDetected)
	{
		uint64_t elapsedTime = ::sys::time::timestamp() - m_startTime;
		if (time*uint64_t(100) > elapsedTime)
			m_wholeSeconds = true;
		m_wholeSecondsDetected = true;
	}

	resetInfo();
	setDepth(depth);
	setScore(0, m_dontInvertScore || m_board.whiteToMove() ? score : -score);
	setTime(m_wholeSeconds ? double(time) : time/100.0);
	setNodes(nodes);

	char const*	illegal(0);
	char const*	e(0);
	Board 		board(m_board);
	MoveList 	moves;

	while (*s)
	{
		Move move;
		char const* t = board.parseMove(::skipMoveNumber(s), move);

		if (t)
		{
			if (move.isLegal())
			{
				board.prepareForPrint(move);
				board.doMove(move);
				moves.append(move);
				illegal = 0;
				s = ::skipSpaces(t);

				if (moves.isFull())
				{
					log("WARNING: Pv is too long (truncated)");
					break;
				}
			}
			else
			{
				illegal = s;
				e = s = ::skipWord(s);
			}
		}
		else
		{
			s = ::skipWord(s);
		}
	}

	if (illegal)
	{
		mstl::string msg("Illegal move in pv: ");
		msg.append(illegal, e - illegal);
		msg.trim();
		error(msg);
		return;
	}

	if (moves.size() == 0)
	{
		updateTimeInfo();
	}
	else
	{
		if (moves.size() == 1 && s[-1] == '!')
		{
			setCurrentMove(0, 0, moves[0]);
			updateCurrMove();
		}
		else
		{
			m_analyzeResponse = true;
			setVariation(0, moves);

			if (board.checkState() & Board::CheckMate)
			{
				int n = board.moveNumber() - m_board.moveNumber();
				setMate(0, board.whiteToMove() ? -n : +n);

#if 0 // we cannot terminate, the engine might find a "better" pv
				if (isAnalyzing())
					stopAnalysis(); // we don't need further computation if mate
#endif
			}

			updatePvInfo(0);
		}

		m_analyzeResponse = true;
	}
}


void
winboard::Engine::parseCurrentMove(char const* s)
{
	float		time;
	unsigned	depth;
	unsigned	moveNo;
	unsigned	moveCount;

	if (::sscanf(s, "%u %f %u/%u?", &depth, &time, &moveNo, &moveCount) != 4)
		return;

	s = ::skipMoveNumber(::skipWords(s, 3));

	Move move;
	char const* t = m_board.parseMove(s, move);

	if (t == 0)
		return;

	if (move.isLegal())
	{
		m_board.prepareForPrint(move);
		setCurrentMove(moveNo, moveCount, move);
		updateCurrMove();
	}
	else
	{
		mstl::string msg("Illegal current move: ");
		msg.append(s, t - s);
		msg.trim();
		error(msg);
	}
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
	if (!m_isCrafty && ::strncmp(identifier, "Crafty", 5) == 0)
	{
		int major;

		if (::sscanf(identifier, "Crafty v%d.", &major) == 1 && major >= 18)
			m_dontInvertScore = true;

		if (isProbing())
		{
			send("log off");		// turn off crafty logging, to reduce number of junk files
			send("noise 1000");	// set a fairly low noise value
		}

		addFeature(app::Engine::Feature_Analyze);
		m_featureSetboard = true;
		m_isCrafty = true;
	}
}

// vi:set ts=3 sw=3:
