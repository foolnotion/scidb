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


static bool
isNumeric(char const* s)
{
	char const* p = s;

	while (isdigit(*p))
		++p;

	return p > s && *p == '\0';
}


static void
subst(mstl::string& str, char c)
{
	mstl::string clone;

	for (unsigned i = 0; i < str.size(); ++i)
	{
		clone += str[i];

		if (str[i] == c)
			clone += c;
	}

	str.swap(clone);
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
	:m_isAnalyzing(false)
	,m_response(false)
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
winboard::Engine::sendNumberOfVariations()
{
	// nothing to do
}


void
winboard::Engine::sendHashSize()
{
	// nothing to do
}


void
winboard::Engine::sendOptions()
{
	// TODO
}


void
winboard::Engine::clearHash()
{
	// TODO
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
//	checkVariant(startBoard);

	if (game->startBoard().notDerivableFromChess960())
	{
		error("Shuffle chess not supported");
		return false;
	}

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

		m_mustUseChess960 = startBoard.notDerivableFromStandardChess();
		m_mustUseNoCastle = m_mustUseChess960 && startBoard.castlingRights() == castling::NoRights;

		if (m_mustUseNoCastle)
		{
			error("Shuffle chess not supported");
			return false;
		}
		else if (m_mustUseChess960)
		{
			if (!hasFeature(app::Engine::Feature_Chess_960) || !m_featureSetboard)
			{
				error("Chess 960 not supported");
				return false;
			}

			send("variant " + m_variant);
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

		if (!m_wholeSecondsDetected)
			m_startTime = ::sys::time::timestamp();

		m_isAnalyzing = true;
		m_firstMove.clear();
	}

	return true;
}


bool
winboard::Engine::stopAnalysis()
{
	if (isAnalyzing())
	{
		if (hasFeature(app::Engine::Feature_Analyze))
			send("exit");	// leave analyze mode

		send("force");		// Stop engine replying to moves.

		reset();
		m_isAnalyzing = false;

		// TODO: we should send now the best move so far
		// because the UCI protocol is doing this
	}

	return true;
}


void
winboard::Engine::pause()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("pause");
	else
		stopAnalysis();
}


void
winboard::Engine::resume()
{
	if (hasFeature(app::Engine::Feature_Pause))
		send("resume");
	else
		startAnalysis(false);
}


bool
winboard::Engine::isReady() const
{
	return m_response;
}


void
winboard::Engine::protocolStart(bool isProbing)
{
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

	if (isProbing())
	{
		if (done)
			m_response = true;
	}
	else
	{
		// No need to wait any longer wondering if we're talking to a version 1 engine
		m_timer.reset();

		// The engine will send done=1, when its ready to go,
		//  and done=0 if it needs more than 2 seconds to start.
		if (done)
		{
			m_response = true;
			engineIsReady();
		}
		else
		{
			timeout();
		}
	}
}


void
winboard::Engine::timeout()
{
	send("hard");
	send("easy");	// turn off pondering

	if (m_response)
		engineIsReady();
	else
		deactivate();

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

		bool accept	= false;
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
					accept = true;
				}
				break;

			case 'c':
				if (::strncmp(key, "colors=", 7) == 0)
				{
					m_featureColors = *val == '1';
					accept = true;
				}
				break;

			case 'd':
				if (::strncmp(key, "done=", 5) == 0)
				{
					featureDone(*val == '1');
					accept = true;
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
				break;

			case 'o':
				if (::strncmp(key, "option=", 7) == 0)
					parseOption(key + 8);
				break;

			case 'p':
				switch (key[1])
				{
					case 'u':
						if (::strncmp(key, "pause=", 6) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_Pause);
							accept = true;
						}
						break;

					case 'l':
						if (::strncmp(key, "playother=", 10) == 0)
						{
							if (*val == '1')
								addFeature(app::Engine::Feature_Play_Other);
							accept = true;
						}
						break;
				}
				break;

			case 'u':
				if (::strncmp(key, "usermove=", 9) == 0)
				{
					m_featureUsermove = *val == '1';
					accept = true;
				}
				break;

			case 's':
				switch (key[1])
				{
					case 'a':
						if (::strncmp(key, "san=", 4) == 0)
						{
							m_featureSan = *val == '1';
							accept = true;
						}
						break;

					case 'e':
						if (::strncmp(key, "setboard=", 9) == 0)
						{
							m_featureSetboard = *val == '1';
							accept = true;
						}
						break;

					case 'i':
						if (::strncmp(key, "sigint=", 7) == 0)
						{
							 m_featureSigint= *val == '1';
							accept = true;
						}
						break;
				}
				break;

			case 'v':
				if (::strncmp(key, "variants=", 9) == 0)
				{
					char const* p = ::strstr(val + 1, "chess960");
					bool chess960 = false;

					if (p)
					{
						m_variant = "chess960";
						chess960 = true;
					}
					else
					{
						p = ::strstr(val + 1, "fischerandom");

						if (p)
						{
							chess960 = true;
							m_variant = "fischerandom";
							accept = true;
						}
					}

					if (chess960)
						addFeature(app::Engine::Feature_Chess_960);
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
					error("analyzing mode not available");
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
	int		score, depth;
	unsigned	nodes, time;
	char		dummy;

	if (::sscanf(msg, "%d%c %d %u %u ", &depth, &dummy, &score, &time, &nodes) != 5)
		return;

	char const* s = ::skipWords(msg, 4);

	if (!m_wholeSecondsDetected)
	{
		uint64_t elapsedTime = ::sys::time::timestamp() - m_startTime;
		if (time*uint64_t(100) > elapsedTime)
			m_wholeSeconds = true;
		m_wholeSecondsDetected = true;
	}

	resetInfo();
	setDepth(depth);
	setScore(m_dontInvertScore || m_board.whiteToMove() ? score : -score);
	setTime(m_wholeSeconds ? double(time) : time/100.0);
	setNodes(nodes);

	int		illegal(-1);
	Board 	board(m_board);
	MoveList moves;

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
				illegal = -1;
				s = ::skipSpaces(t);

				if (moves.isFull())
				{
					log("WARNING: Pv is too long (truncated)");
					break;
				}
			}
			else
			{
				illegal = moves.size();
				s = ::skipWord(s);
			}
		}
		else
		{
			s = ::skipWord(s);
		}
	}

	if (0 <= illegal && illegal < int(moves.size()))
	{
		error("Illegal move in pv");
		return;
	}

	if (moves.size() == 0 || (moves.size() == 1 && moves[0] == m_firstMove))
	{
		updateTimeInfo();
	}
	else if (moves.size() > 0)
	{
		if (board.checkState() & Board::CheckMate)
		{
			int n = board.moveNumber() - m_board.moveNumber();
			setMate(board.whiteToMove() ? -n : +n);

#if 0 // we cannot terminate, the engine might find a "better" pv
			if (isAnalyzing())
				stopAnalysis(); // we don't need further computation if mate
#endif
		}

		m_firstMove = moves[0];
		setVariation(moves);
		updatePvInfo();
		m_analyzeResponse = true;
	}
}


void
winboard::Engine::parseOption(mstl::string const& option)
{
	// SYNTAX: "NAME -TYPE ARGS"

	mstl::string::size_type i = option.find_first_not_of('-');

	if (i == mstl::string::npos)
		return;

	mstl::string::size_type k = option.find(' ', i);

	if (k == mstl::string::npos)
		k = option.size();

	mstl::string name(option.substr(0, i));
	mstl::string type(option.substr(i + 1, option.size() - k));
	mstl::string args(option.substr(k));

	name.trim(); type.trim(); args.trim();

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
		addOption(name, type, args == "0" ? "true" : "false");

		if (name == "pause" && args == "0")
			addFeature(app::Engine::Feature_Pause);
	}
	else if (type == "string")
	{
		addOption(name, type, args);

		if (name == "variants")
		{
			if (option.find("fischerandom") != mstl::string::npos)
				addFeature(app::Engine::Feature_Chess_960);

			// NOTE:
			// WinBoard support variants like "wildcastle" and "nocastle",
			// but this is not Shuffle Chess!
		}
	}
	else if (type == "spin" || type == "slider")
	{
		// feature option="NAME -spin VALUE MIN MAX"
		i = args.find(' ');

		if (i == mstl::string::npos)
			return;

		while (::isspace(args[i]))
			++i;

		k = args.find(' ', i);

		if (k == mstl::string::npos)
			++k;

		mstl::string val(args.substr(0, args.size() - i));
		mstl::string min(args.substr(i, args.size() - k));
		mstl::string max(args.substr(k));

		val.trim(); min.trim(); max.trim();

		if (!::isNumeric(val) || !::isNumeric(min) || !::isNumeric(max))
			return;

		addOption(name, type, val, min, max);

		if (name == "memory")
		{
			setHashRange(::atoi(min), ::atoi(max));
			setHashSize(::atoi(val));
		}
		else if (name == "smp")
		{
			setThreadRange(::atoi(min), ::atoi(max));
			setThreads(::atoi(val));
		}
	}
	else if (type == "combo")
	{
		mstl::string args;
		mstl::string val;

		char const* s = skipSpaces(args);
		char const* t = endOfWord(s);

		while (*s)
		{
			mstl::string choice(s, t);
			choice.trim();
			::subst(choice, ';');

			if (!choice.empty())
			{
				if (choice.front() == '*')
				{
					choice.erase(choice.begin(), choice.begin() + 1);
					val = choice;
				}

				if (!choice.empty())
				{
					if (!args.empty())
						args += ';';
					args += choice;
				}
			}

			s = skipSpaces(t);
			t = endOfWord(s);
		}

		if (!val.empty() && !args.empty())
			addOption(name, type, val, args);
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

		send("log off");		// turn off crafty logging, to reduce number of junk files
		send("noise 1000");	// set a fairly low noise value
//		send("egtb off");		// turn off end game table book
		send("resign 0");		// turn off alarm

		addFeature(app::Engine::Feature_Analyze);
		m_featureSetboard = true;
		m_isCrafty = true;
	}
}

// vi:set ts=3 sw=3:
