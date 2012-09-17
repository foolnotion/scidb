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
#include "db_player.h"

#include "sys_signal.h"
#include "sys_timer.h"

#include "m_stdio.h"
#include "m_vector.h"

#include <string.h>
#include <ctype.h>

using namespace app;
using namespace app::winboard;
using namespace db;


struct Range
{
	Range(char const* s, char const* e) :start(s), end(e) {}
	Range() :start(0), end(0) {}

	operator bool() const { return start < end; }

	char const* start;
	char const* end;
};

typedef mstl::vector<Range> Ranges;

static Range findIdentifier(Range const& range);


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
skipWords(char const* s, unsigned n)
{
	while (n--)
	{
		while (*s && !isspace(*s))
			++s;
		s = skipSpaces(s);
	}

	return s;
}


static bool
isAlgebraic(char const* s)
{
	if (s[0] == '0' || s[0] == 'O')
		return s[1] == '-';

	if (::isalpha(s[0]))
	{
		if (*++s == 'x')
			++s;
	}

	return ::isdigit(s[0]) && ::isalpha(s[1]);
}


static char const*
nextAlgebraic(char const* s)
{
	// Note: Yace puts ".", "t", "t-" or "t+" at the start of its moves text; skip it.
	// Note: Gullydeckel puts "T" followed by a number at the start of its moves text; skip it.
	// Note: Some engines (Crafty, Gullydeckel) adds "<HT>" for a hash table comment; skip it.
	// Note: Skip move numbers.
	// Note: Skip '(' at start of line.

	do
	{
		if (*s == '(')
			++s;
		else
			s = skipWords(s, 1);

		s = skipSpaces(s);
	}
	while (*s && !isAlgebraic(s));

	return s;
}


static unsigned
split(Ranges& result, Range range, char delim)
{
	result.clear();

	while (range)
	{
		char const* p = strchr(range.start + 1, delim);

		if (p == 0 || p >= range.end)
		{
			result.push_back(range);
			return result.size();
		}

		result.push_back(Range(range.start, p));
		range.start = p + 1;

		while (range && *range.start == delim)
			++range.start;
	}

	return result.size();
}


static Range
findIdentifier(Ranges::const_iterator s, Ranges::const_iterator e)
{
	for (Ranges::const_iterator i = s; i != e; ++i)
	{
		for (Ranges::const_iterator k = e - 1; k >= i; --k)
		{
			Range r(i->start, k->end);

			if (db::Player::findEngine(mstl::string(r.start, r.end)))
				return r;
		}

		if (Range r = findIdentifier(*i))
			return r;
	}

	return Range();
}


static Range
findIdentifier(Range const& range)
{
	if (!range)
		return range;

	Ranges ranges;

	if (split(ranges, range, ',') == 1)
	{
		if (db::Player::findEngine(mstl::string(range.start, range.end)))
			return range;

		if (split(ranges, range, '.') == 1)
		{
			if (db::Player::findEngine(mstl::string(range.start, range.end)))
				return range;

			if (split(ranges, range, ' ') == 1)
			{
				if (db::Player::findEngine(mstl::string(range.start, range.end)))
					return range;
			}
			else
			{
				if (Range r = findIdentifier(ranges.begin(), ranges.end()))
					return r;
			}
		}
		else
		{
			if (Range r = findIdentifier(ranges.begin(), ranges.end()))
				return r;
		}
	}
	else
	{
		if (Range r = findIdentifier(ranges.begin(), ranges.end()))
			return r;
	}

	if (range.start[0] == '(' && range.end[-1] == ')')
		return findIdentifier(Range(range.start + 1, range.end - 1));

	return Range();
}


static char const*
findVersionNumber(char const* s)
{
	if (*s == 'v' || *s == '.')
		++s;

	if (!isdigit(*s))
		return 0;

	++s;

	while (isdigit(*s) || *s == '.')
		++s;

	while (s[-1] == '.')
		--s;

	return s;
}


static char const*
findRomanNumber(char const* s)
{
	if (*s != 'X' && *s != 'V' && *s != 'I')
		return 0;

	++s;

	while (*s == 'X' || *s == 'V' || *s == 'I')
		++s;

	if (isalnum(*s))
		return 0;

	return s;
}


struct winboard::Engine::Timer : public sys::Timer
{
	Timer(winboard::Engine* engine, unsigned timeout) :sys::Timer(timeout), m_engine(engine) {}

	void timeout() { timeout(); }

	winboard::Engine* m_engine;
};


winboard::Engine::Engine()
	:m_response(false)
	,m_detected(false)
	,m_hasIdentifier(false)
	,m_mustUseChess960(false)
	,m_mustUseNoCastle(false)
	,m_editSent(false)
	,m_dontInvertScore(false)
	,m_wholeSeconds(false)
	,m_featureUsermove(false)
	,m_featureColors(false)
	,m_featureSetboard(false)
	,m_featureSigint(false)
	,m_featureAnalyze(false)
	,m_featurePause(false)
	,m_featurePlayOther(false)
	,m_featureSan(false)
	,m_variantChess960(false)
	,m_variantNoCastle(false)
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

	if (m_featureSan)
		move.printSan(s);
	else if (move.isNull())
		s.append("@@@@", 4);	// alternatives: "pass", "null", "--"
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
	m_timer.reset();
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

	Board const& startBoard = game->startBoard();

	m_mustUseChess960 = startBoard.notDerivableFromStandardChess();
	m_mustUseNoCastle = m_mustUseChess960 && startBoard.castlingRights() == castling::NoRights;

	if (m_mustUseNoCastle)
	{
		if (!m_variantNoCastle || !m_featureSetboard)
		{
			error("Shuffle chess not supported");
			return false;
		}

		send("variant nocastle");
	}
	else if (m_mustUseChess960)
	{
		if (!m_variantChess960 || !m_featureSetboard)
		{
			error("Chess 960 not supported");
			return false;
		}

		send("variant " + m_variant);
	}

	m_board = game->currentBoard();

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

		for (int i = moves.size() - 1; i >= 0; ++i)
			doMove(moves[i]);
	}

	send("post");	// turn on thinking output

	if (m_featureAnalyze)
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

//	setAnalyzing(true);

	return true;
}


bool
winboard::Engine::stopAnalysis()
{
	if (isAnalyzing())
	{
		send("force");		// Stop engine replying to moves.

		if (m_featureAnalyze)
			send("exit");	// leave analyze mode

		reset();
//		setAnalyzing(false);

		// TODO: we should send now the best move so far
		// because the UCI protocol is doing this
	}

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
	send("xboard");
	send("ponder off");

	if (isProbing)
	{
		send("log off");		// turn off crafty logging, to reduce number of junk files
		send("ping");			// probably the engine will send 'pong'
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
			send("protover 2");
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
					return parseFeatures(::skipSpaces(msg + 8));
				break;

			case 'p':
				if (isProbing() && ::strncmp(msg, "pong ", 5) == 0)
				{
					m_response = true;
					return;
				}
				break;

			case 'm':
				if (isProbing() && ::strncmp(msg, "move ", 5) == 0)
				{
					m_response = true;
					return;
				}
				// fallthru

			case 'M':
				if (::strncmp(msg, "my move is", 10) == 0)
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

		if (isProbing() && !m_hasIdentifier)
			detectIdentifier(message);
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
		bool reject	= true;

		switch (msg[0])
		{
			case '\0':
				return;

			case 'a':
				if (::strncmp(key, "analyze=", 8) == 0)
				{
					m_featureAnalyze = *val == '1';
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
				if (::strncmp(key, "myname=", 7) == 0 && val[0] == '"' && end[-1] == '"')
				{
					setIdentifier(mstl::string(val + 1, end - 1));
					detectFeatures(mstl::string(val + 1, end - val));
					m_hasIdentifier = true;
					reject = false;
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
							m_featurePause= *val == '1';
							accept = true;

							if (isProbing())
								addFeature(app::Engine::Feature_Pause);
						}
						break;

					case 'l':
						if (::strncmp(key, "playother=", 10) == 0)
						{
							m_featurePlayOther= *val == '1';
							accept = true;

							if (isProbing())
								addFeature(app::Engine::Feature_Play_Other);
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

					if (p)
					{
						m_variant = "chess960";
						m_variantChess960 = true;
					}
					else
					{
						p = ::strstr(val + 1, "fischerandom");

						if (p)
						{
							m_variantChess960 = true;
							m_variant = "fischerandom";
							accept = true;
						}
					}

					p = ::strstr(val + 1, "nocastle");

					if (p)
					{
						m_variantNoCastle = true;
						accept = true;
					}

					if (isProbing())
					{
						if (m_variantChess960)
						{
							addFeature(app::Engine::Feature_Chess_960);

							if (m_variantNoCastle)
								addFeature(app::Engine::Feature_Shuffle_Chess);
						}
					}
				}
				break;
		}

		if (accept)
			send("accepted " + mstl::string(key, sep));
		else if (reject)
			send("rejected " + mstl::string(key, sep));

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
				}
			}
			break;
	}

	if (::isdigit(msg[0]))
		parseInfo(msg);
	else
		log(msg);

	m_editSent = false;
}


void
winboard::Engine::parseInfo(mstl::string const& msg)
{
	int		score;
	unsigned	depth, nodes, time;
	char		dummy;

	if (::sscanf(msg, "%u%c %d %u %u ", &depth, &dummy, &score, &time, &nodes) != 5)
		return;

	char const* s = ::skipWords(msg, 4);

	if (!isAlgebraic(s) && !*(s = ::nextAlgebraic(s)))
		return;

//	resetInfo();	not neccessary
	setDepth(depth);
	// NOTE: most engines do use >= 32767 as mating score
	setScore(m_dontInvertScore || m_board.whiteToMove() ? score : -score);
	setTime(m_wholeSeconds ? double(time) : time/100.0);
	setNodes(nodes);

	bool		okSoFar(true);
	Board 	board(m_board);
	MoveList moves;

	for ( ; *s && okSoFar && !moves.isFull(); s = ::nextAlgebraic(s))
	{
		Move move = board.parseMove(s);

		if (move.isLegal())
		{
			board.prepareForPrint(move);
			board.doMove(move);
			moves.append(move);
		}
		else
		{
			okSoFar = false;
		}
	}

	setVariation(moves);
	updateInfo();
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
		//	ignore buttons, not usable for configuration
//		addOption(name, type);
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
	}
	else if (type == "string")
	{
		addOption(name, type, args);
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
	struct Attrs
	{
		char const*	identifier;
		bool			hasAnalyze;
		bool			hasSetboard;
		bool			hasWholeSeconds;
	};

#define ____ false
	static Attrs const EngineList[] =
	{
		// from scid-3.6.26/tcl/tools/wbdetect.tcl:
		// Thanks to Allen Lake for testing many WinBoard engines.

		// identifier					analyze	setboard	seconds
		{ "Amy version",				true,		____,		____ },
		{ "Baron",						true,		true,		true },
		{ "Calzerano",					true,		____,		____ },
		{ "D U K E",					true,		____,		____ },
		{ "ESCbook.bin",				true,		____,		____ },
		{ "EXchess",					true,		true,		____ },
		{ "EngineControl-TCB",		true,		____,		____ },
		{ "FORTRESS",					true,		____,		____ },
		{ "GNU Chess v5",				____,		true,		____ },
		{ "Gromit3",					true,		____,		____ },
		{ "Gullydeckel 2",			true,		true,		____ },
		{ "Jester",						true,		____,		____ },
		{ "King of Kings",			true,		true,		____ },
		{ "LordKing",					true,		____,		____ },
		{ "micro-Max 4",				____,		____,		____ },
		{ "NEJMET",						true,		true,		____ },
		{ "Nejmet",						true,		true,		____ },
		{ "Phalanx",					true,		true,		____ },
		{ "Pharaon",					true,		true,		true },
		{ "Scorpio",					true,		____,		____ },
		{ "Skaki",						true,		____,		____ },
		{ "WildCat version 2.61",	true,		____,		____ },
		{ "ZChess",						true,		____,		true },
	};
#undef ____

	if (m_detected)
		return;

	if (::strncmp(identifier, "Crafty", 5) == 0)
	{
		int major;

		if (::sscanf(identifier, "Crafty v%d.", &major) == 1 && major >= 18)
			m_dontInvertScore = true;

		send("log off");		// turn off crafty logging, to reduce number of junk files
		send("noise 1000");	// set a fairly low noise value
//		send("egtb off");		// turn off end game table book
		send("resign 0");		// turn off alarm

		m_featureSetboard = true;
		m_featureAnalyze = true;
		m_detected = true;
	}
	else
	{
		static Attrs const* first	= EngineList;
		static Attrs const* last	= EngineList + U_NUMBER_OF(EngineList);

		for (Attrs const* attrs = first; attrs < last; ++attrs)
		{
			if (::strstr(identifier, attrs->identifier))
			{
				if (attrs->hasAnalyze)			m_featureAnalyze = true;
				if (attrs->hasSetboard)			m_featureSetboard = true;
				if (attrs->hasWholeSeconds)	m_wholeSeconds = true;

				m_detected = true;
				return;
			}
		}
	}
}


void
winboard::Engine::detectIdentifier(mstl::string const& s)
{
	if (Range range = ::findIdentifier(Range(s.begin(), s.end())))
	{
		char const* q = range.end + 1;
		char const* p = ::findVersionNumber(q);

		if (!p)
			p = ::findRomanNumber(q);

		if (!p)
			p = range.end;

		setIdentifier(mstl::string(range.start, p));
		m_hasIdentifier = true;
	}
}

// vi:set ts=3 sw=3:
