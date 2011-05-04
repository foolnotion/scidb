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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "app_uci_engine.h"
#include "app_exception.h"

#include "m_list.h"
#include "m_stdio.h"

#include <string.h>
#include <ctype.h>

using namespace app;
using namespace app::uci;
using namespace db;


inline bool isLan(char const* s)					{ return ::isalpha(s[0]) && ::isdigit(s[1]); }
inline static mstl::string toStr(bool value)	{ return value ? "true" : "false"; }


static mstl::string
toStr(unsigned value)
{
	char buf[20];
	snprintf(buf, sizeof(buf), "%u", value);
	return buf;
}


static char const*
skipSpaces(char const*s)
{
	while (::isspace(*s))
		++s;

	return s;
}


static char const*
skipNonSpaces(char const*s)
{
	while (*s && !::isspace(*s))
		++s;

	return s;
}


static char const*
skipWords(char const* s, unsigned n)
{
	while (n--)
	{
		while (*s && !::isspace(*s))
			++s;

		s = skipSpaces(s);
	}

	return skipSpaces(s);
}


static bool
nextWord(mstl::string& result, char const*& p)
{
	if (!isalpha(*p))
		return false;

	result.clear();

	while (*p && !isspace(*p))
		result += *++p;

	while (isspace(*p))
		++p;

	return true;
}


static void
append(mstl::string& str, mstl::string const& val)
{
	if (!str.empty())
		str += " ";

	str += val;
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


static bool
isNumeric(char const* s)
{
	char const* p = s;

	while (isdigit(*p))
		++p;

	return p > s && *p == '\0';
}


static bool
endsWithPath(mstl::string const& s)
{
	if (s.size() < 4)
		return false;

	return strncmp(s.c_str() + s.size() - 4, "Path", 4) == 0;
}


uci::Engine::Engine()
	:m_needChess960(false)
	,m_uciok(false)
{
}


bool
uci::Engine::whiteToMove() const
{
	return m_board.whiteToMove();
}


uci::Engine::Result
uci::Engine::probeResult() const
{
	return m_uciok ? app::Engine::Probe_Successfull : app::Engine::Probe_Failed;
}


bool
uci::Engine::startAnalysis(Board const& board)
{
	if (!isActive())
		return false;

	if (board.notDerivableFromChess960())
	{
		// what should we do?
	}

	if ((m_needChess960 = board.notDerivableFromStandardChess()))
	{
		if (!hasFeature(app::Engine::Feature_Chess_960))
			APP_RAISE("Chess 960 not supported");
	}

	m_board = board;
	m_fen = board.toFen(
		hasFeature(app::Engine::Feature_Chess_960) ? Board::Shredder : Board::XFen);
	m_waitingOn = "ucinewgame";

	send("stop");
	send("ucinewgame");
	send("isready");

	return true;
}


bool
uci::Engine::stopAnalysis()
{
	if (isAnalyzing())
		send("stop");

	return true;
}


void
uci::Engine::protocolStart(bool isProbing)
{
	// tell the engine we are using the UCI protocol
	send("uci");
	// after that we wait for "uciok"
}


void
uci::Engine::protocolEnd()
{
	// Some engines in analyze mode may not react as expected
	// to "quit" so ensure the engine exits analyze mode first:
	stopAnalysis();
	send("quit");
}


void
uci::Engine::processMessage(mstl::string const& message)
{
	switch (message[0])
	{
		case 'u':
			// we expect "uciok" as a response to "uci"
			if (message == "uciok")
			{
				m_uciok = true;

				if (!isProbing())
				{
					m_waitingOn = "uciok";
					send("isready");	// is required once to finish initialising
					// now we wait for "readyok"
				}
			}
			break;

		case 'r':
			if (message == "readyok")
			{
				if (m_waitingOn == "uciok")
				{
					// engine is now initialised and ready to go
					m_waitingOn = "";
//					setReady(true);
					// now we can send our options
					send("setoption name MultiPv value " + ::toStr(numVariations()));
					//send("setoption name OwnBook value false");
					//send("setoption name BookFile value false");
					send("setoption name UCI_AnalyseMode value true");
					send("setoption name UCI_Chess960 value " + ::toStr(m_needChess960));

					if (limitedStrength())
					{
						send("setoption name UCI_LimitStrength value true");
						send("setoption name UCI_Elo value " + ::toStr(limitedStrength()));
					}
					else
					{
						send("setoption name UCI_LimitStrength value false");
					}
				}
				else if (m_waitingOn == "ucinewgame")
				{
					// engine is now ready to analyse a new position
					m_waitingOn = "";
					send("position fen " + m_fen);

					if (searchMate() > 0)
						send("go mate=" + ::toStr(searchMate()));
					else
						send("go infinite");
				}
			}
			break;

		case 'i':
			if (isAnalyzing())
			{
				if (::strncmp(message, "info ", 5) == 0)
					parseInfo(::skipSpaces(message.c_str() + 5));
			}
			else if (::strncmp(message, "id name ", 8) == 0)
			{
				setIdentifier(message.c_str() + 8);
			}
			break;

		case 'o':
			if (isProbing() && ::strncmp(message, "option name ", 12) == 0)
				parseOption(::skipSpaces(message.c_str() + 12));
			break;

		case 'b':
			if (isAnalyzing() && ::strncmp(message, "bestmove ", 9) == 0)
				parseBestMove(message.c_str() + 9);
			break;
	}
}


void
uci::Engine::parseBestMove(char const* msg)
{
	char const* s = ::skipSpaces(msg);

	if (Move move = m_board.parseMove(s))
	{
		s = ::skipNonSpaces(s);

		if (move.isLegal())
			setBestMove(move);

		if (::strncmp(s, "ponder ", 6) == 0)
		{
			s = ::skipSpaces(s + 6);

			m_board.doMove(move);
			Move ponder = m_board.parseMove(s);
			m_board.undoMove(move);

			if (ponder.isLegal())
				setPonder(ponder);
		}
	}
}


void
uci::Engine::parseInfo(char const* msg)
{
	int	multiPv		= 1;
	bool	havePv		= false;
	bool	haveScore	= false;

	resetInfo();

	while (true)
	{
		unsigned numWords = 2;
		unsigned value;

		switch (msg[0])
		{
			case 'd':
				if (::sscanf(msg, "depth %u ", &value) == 1)
					setDepth(value);
				break;

			case 's':
				if (::strncmp(msg, "score ", 6) == 0)
				{
					int value;

					msg = skipSpaces(msg);

					switch (msg[0])
					{
						case 'c':
							if (::sscanf(msg, "cp %d ", &value) == 1)
							{
								setScore(whiteToMove() ? value : -value);
								haveScore = true;
							}
							break;

						case 'm':
							if (::sscanf(msg, "mate %d ", &value) == 1)
							{
								setMate(whiteToMove() ? value : -value);
								haveScore = true;
							}
							break;
					}
				}
				break;

			case 't':
				if (::sscanf(msg, "time %u ", &value) == 1)
					setTime(value/1000.0);
				break;

			case 'n':
				if (::sscanf(msg, "nodes %u ", &value) == 1)
					setNodes(value);
				break;

			case 'p':
				if (::strncmp(msg, "pv ", 3) == 0)
				{
					bool		okSoFar(true);
					Board		board(m_board);
					MoveList	moves;

					for ( ; ::isLan(msg); msg = ::skipWords(msg, 1))
					{
						if (okSoFar)
						{
							Move move = board.parseMove(msg);

							if (move.isLegal() && moves.notFull())
							{
								board.doMove(move);
								moves.append(move);
							}
							else
							{
								okSoFar = false;
							}
						}
					}

					setVariation(moves, multiPv);
					havePv = true;
					numWords = 0;
				}
				break;

			case 'm':
				if (	::sscanf(msg, "multipv %u ", &value) == 1
					&& 1 <= value
					&& value <= numVariations())
				{
					multiPv = value;
				}
				break;
		}

		msg = ::skipWords(msg, numWords);
	}

	if (haveScore && havePv)
		updateInfo();
}


void
uci::Engine::parseOption(char const* msg)
{
	mstl::string	name;
	mstl::string	type;
	mstl::string	dflt;
	mstl::string	min;
	mstl::string	max;
	mstl::string	key;
	mstl::string*	value = 0;

	mstl::list<mstl::string> vars;

	while (::nextWord(key, msg))
	{
		if (key == "name")			value = &name;
		else if (key == "type")		value = &type;
		else if (key == "default")	value = &dflt;
		else if (key == "min")		value = &min;
		else if (key == "max")		value = &max;
		else if (key == "var")		value = vars.insert(vars.end(), mstl::string());
		else								::append(*value,  key);
	}

	if (name.empty() || name == "Ponder")
		return;

	if (name == "UCI_Chess960")
	{
		addFeature(app::Engine::Feature_Chess_960);
		return;
	}

	if (	::strncmp(name, "UCI_", 4) == 0
		&& (name != "UCI_LimitStrength" && name != "UCI_Elo" && name != "UCI_ShredderbasesPath"))
	{
		return;
	}

	if (type == "check")
	{
		if (dflt != "true" && dflt != "false")
			return;

		addOption(name, type, dflt);
	}
	else if (type == "spin")
	{
		if (!::isNumeric(dflt) || !::isNumeric(min) || !::isNumeric(max))
			return;

		addOption(name, type, dflt, min, max);
	}
	else if (type == "combo")
	{
		mstl::string var;
		bool found = false;

		for (unsigned i = 0; i < vars.size(); ++i)
		{
			if (!vars[i].empty())
			{
				if (dflt == vars[i])
					found = true;

				if (!var.empty())
					var += ";";
				::subst(vars[i], ';');
				var += vars[i];
			}
		}

		if (found)
			addOption(name, type, dflt, var);
	}
//	ignore buttons, not usable for configuration
//	else if (type == "button")
//	{
//		addOption(name, type);
//	}
	else if (type == "string")
	{
		if (::endsWithPath(name))
			addOption(name, "path");
		else
			addOption(name, type, dflt);
	}
}

// vi:set ts=3 sw=3:
