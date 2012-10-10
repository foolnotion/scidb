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

#include "app_uci_engine.h"
#include "app_exception.h"

#include "db_game.h"

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
toBool(bool value)
{
	return value ? "true" : "false";
}


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
	if (*p == '\0')
		return false;

	result.clear();

	while (*p && !isspace(*p))
		result += *p++;

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
isPathOrFile(mstl::string const& s, char const* upper, char const* lower)
{
	mstl::string::size_type i = s.find(upper);

	if (i != mstl::string::npos)
	{
		char const* e = s.begin() + i + 4;
		return *e == '\0' || *e == ' ' || strncmp(s, "name", 4) == 0;
	}

	i = s.find(lower);

	if (i == mstl::string::npos)
		return false;

	char const* p = s.begin() + i;
	char const* e = p + 4;

	return (i == 0 || p[-1] == ' ') && ((*e == '\0' || *e == ' ' || strncmp(s, "name", 4) == 0));
}


static bool
isPath(mstl::string const& s)
{
	return isPathOrFile(s, "Path", "path");
}


static bool
isFile(mstl::string const& s)
{
	return isPathOrFile(s, "File", "file");
}


static void
setNonZeroValue(mstl::string& s, unsigned value)
{
	if (value)
	{
		s.clear();
		s.format("%u", value);
	}
}


uci::Engine::Engine()
	:m_maxMultiPV(1)
	,m_needChess960(false)
	,m_uciok(false)
	,m_isReady(false)
	,m_hasMultiPV(false)
	,m_hasAnalyseMode(false)
	,m_hasOwnBook(false)
	,m_hasShowCurrLine(false)
	,m_hasShowRefutations(false)
	,m_isAnalyzing(false)
	,m_isNewGame(false)
	,m_startAnalyzeIsPending(false)
	,m_stopAnalyizeIsPending(false)
	,m_continueAnalysis(false)
	,m_sendChess960(false)
	,m_sendAnalyseMode(false)
	,m_usedAnalyseModeBefore(false)
{
}


void
uci::Engine::doMove(db::Move const& lastMove)
{
	if (isAnalyzing())
	{
		stopAnalysis();
		startAnalysis(false);
	}
	else
	{
		// TODO
	}
}


bool
uci::Engine::whiteToMove() const
{
	return m_board.whiteToMove();
}


db::Board const&
uci::Engine::currentBoard() const
{
	return m_board;
}


uci::Engine::Result
uci::Engine::probeResult() const
{
	return m_uciok ? app::Engine::Probe_Successfull : app::Engine::Probe_Failed;
}


unsigned
uci::Engine::probeTimeout() const
{
	return 1000;
}


unsigned
uci::Engine::maxVariations() const
{
	return m_maxMultiPV;
}


void
uci::Engine::setupPosition(Board const& board)
{
	m_position.assign("position ", 9);

	if (board.isStandardPosition())
	{
		m_position.append("startpos", 8);
	}
	else
	{
		db::Board::Format	fmt(m_needChess960 ? Board::Shredder : Board::XFen);
		mstl::string		fen(board.toFen(fmt));

		m_position.append("fen ", 4);
		m_position.append(fen);
	}
}


bool
uci::Engine::isAnalyzing() const
{
	return m_isAnalyzing;
}


bool
uci::Engine::startAnalysis(bool isNewGame)
{
	M_ASSERT(currentGame());
	M_ASSERT(isActive());

	m_isNewGame = isNewGame;

	if (m_stopAnalyizeIsPending)
	{
		m_startAnalyzeIsPending = true; // wait on "bestmove"
		return true;
	}

	m_startAnalyzeIsPending = false;

	db::Game const* game = currentGame();

	if (isNewGame)
	{
		bool needChess960 = currentVariant() == app::Engine::Variant_Chess_960;

		if (needChess960 != m_needChess960)
		{
			m_needChess960 = needChess960;
			m_sendChess960 = true;
		}
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
		if (m_hasAnalyseMode && !m_usedAnalyseModeBefore)
		{
			m_sendAnalyseMode = true;
			m_usedAnalyseModeBefore = true;
		}

#if 0
		setupPosition(m_board);
#else
		// We prefer to use the "position moves" setup because (due to Steve):
		// The problem is that mots engines will reset their analysis with "position fen".
		// Only a few will check to see if the new position is in their search tree.
		setupPosition(game->startBoard());

		if (game->startBoard().plyNumber() != m_board.plyNumber())
		{
			m_position.append(" moves", 6);
			game->dumpHistory(m_position);
		}
#endif

		if (isNewGame)
			send("ucinewgame"); // clear's all states

		m_waitingOn = "position";
		send("isready");

		m_isAnalyzing = true;
		updateState(app::Engine::Start);
	}

	return true;
}


bool
uci::Engine::stopAnalysis()
{
	m_startAnalyzeIsPending = false;

	if (!m_isAnalyzing)
		return false;

	m_isAnalyzing = false;

	if (!m_stopAnalyizeIsPending)
	{
		send("stop");
		m_stopAnalyizeIsPending = true;
		updateState(app::Engine::Stop);
		// the engine should now send final info and bestmove
	}

	return true;
}


void
uci::Engine::continueAnalysis()
{
	if (m_continueAnalysis)
	{
		if (currentGame())
			send("go infinite");

		m_continueAnalysis = false;
	}
}


void
uci::Engine::pause()
{
	// XXX only working for analyzing mode
	send("stop");
	m_stopAnalyizeIsPending = true;
	updateState(app::Engine::Pause);
}


void
uci::Engine::resume()
{
	send("go infinite");
	updateState(app::Engine::Resume);
}


bool
uci::Engine::isReady() const
{
	return m_isReady;
}


void
uci::Engine::protocolStart(bool isProbing)
{
	addVariant(app::Engine::Variant_Standard);

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
	m_stopAnalyizeIsPending = false;
	send("quit");
	m_isReady = false;
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
				addFeature(app::Engine::Feature_Analyze);

				if (!isProbing())
				{
					// now we can send our options
					sendOptions();
					send("isready");
					m_waitingOn = "uciok";
				}
			}
			break;

		case 'r':
			if (message == "readyok")
			{
				if (m_waitingOn == "uciok")
				{
					// engine is now initialised and ready to go
					m_isReady = true;
					engineIsReady();
				}
				else if (m_waitingOn == "position")
				{
					// engine is now ready to analyse a new position
					if (m_sendAnalyseMode)
					{
						send("setoption name UCI_AnalyseMode value true");
						m_sendAnalyseMode = false;
					}

					if (m_sendChess960)
					{
						send("setoption name UCI_Chess960 value " + ::toBool(m_needChess960));
						m_sendChess960 = false;
					}

					send(m_position);

					if (searchMate() > 0)
						send("go mate=" + ::toStr(searchMate()));
					else
						send("go infinite");

					// NOTE: probably we like to use something like
					// "go wtime 55857 btime 58611 winc 1000 binc 1000"
				}
				else if (m_waitingOn == "setoption")
				{
					send("setoption name " + m_name + " value " + m_value);
					continueAnalysis();
				}

				m_waitingOn.clear();
			}
			else if (::strcmp(message, "registration checking") == 0)
			{
				// TODO:
				// send("register %s", registration());
				// wait for "registration ok" or "registration error"
				error(app::Engine::Engine_Requires_Registration);
				deactivate();
			}
			break;

		case 'i':
			switch (message[1])
			{
				case 'd':
					if (::strncmp(message, "id name ", 8) == 0)
					{
						mstl::string identifier(message.c_str() + 8, message.size() - 8);
						setIdentifier(identifier);
						if (isProbing())
							detectShortName(identifier);
					}
					else if (::strncmp(message, "id author ", 10) == 0)
					{
						setAuthor(message.c_str() + 10);
					}
					break;

				case 'n':
					if ((isAnalyzing() || m_stopAnalyizeIsPending) && ::strncmp(message, "info ", 5) == 0)
						parseInfo(::skipSpaces(message.c_str() + 5));
					break;
			}
			break;

		case 'o':
			if (::strncmp(message, "option name ", 12) == 0)
				parseOption(::skipSpaces(message.c_str() + 7));
			break;

		case 'b':
			if (m_stopAnalyizeIsPending && ::strncmp(message, "bestmove ", 9) == 0)
				parseBestMove(message.c_str() + 9);
			break;

		case 'c':
			if (::strcmp(message, "copyprotection checking") == 0)
			{
				error(app::Engine::Engins_Has_Copy_Protection);
				deactivate();
			}
			break;
	}
}


void
uci::Engine::parseBestMove(char const* msg)
{
	m_stopAnalyizeIsPending = false;

	char const* s = ::skipSpaces(msg);
	Move move(m_board.parseLAN(s));

	if (move.isLegal())
	{
		m_board.prepareForPrint(move);
		setBestMove(move);
	}
	else
	{
		mstl::string msg("Illegal best move: ");
		msg.append(s, ::skipNonSpaces(s));
		error(msg);
	}

	s = ::skipNonSpaces(s);

	if (::strncmp(s, "ponder ", 6) == 0)
	{
		s = ::skipSpaces(s + 6);

		m_board.doMove(move);
		Move ponder(m_board.parseLAN(s));
		m_board.undoMove(move);

		if (move.isLegal())
		{
			setPonder(ponder);
			updateBestMove();
		}
		else
		{
			mstl::string msg("Illegal ponder move: ");
			msg.append(s, ::skipNonSpaces(s));
			error(msg);
		}
	}

	if (m_startAnalyzeIsPending)
		startAnalysis(m_isNewGame);
}


void
uci::Engine::parseInfo(char const* s)
{
	unsigned multiPv			= 0;
	unsigned currMoveNumber	= 0;
	unsigned score				= 0;
	unsigned mate				= 0;

	bool haveScore				= false;
	bool haveMate				= false;
	bool haveDepth				= false;
	bool haveTime				= false;
	bool havePv					= false;
	bool haveCurrMove			= false;
	bool haveCurrMoveNumber	= false;
	bool haveHashFull			= false;

	Move currMove;

	resetInfo();

	while (*s)
	{
		unsigned value;

		switch (s[0])
		{
			case 'c':
				switch (s[1])
				{
					case 'p':
//						if (::sscanf(s, "cpuload %u", &value) == 1)
//						{
//							setCPULoad(value);
//							haveCpuLoad = true;
//						}
						break;

					case 'u':
						if (::strncmp(s, "currline ", 9) == 0)
						{
							MoveList moves;

							if (!(s = parseMoveList(::skipWords(s, 1), moves)))
								return;

//							setVariation(moves);
							updateCurrLine();
							continue;
						}
						else if (::strncmp(s, "currmove ", 9) == 0)
						{
							if ((currMove = parseCurrentMove(::skipWords(s, 1))))
								haveCurrMove = true;
						}
						else if (::sscanf(s, "currmovenumber %u", &currMoveNumber) == 1)
						{
							haveCurrMoveNumber = true;
						}
						if (haveCurrMoveNumber && haveCurrMove)
						{
							setCurrentMove(currMoveNumber, currMove);
							updateCurrMove();
						}
						break;
				}
				break;

			case 'h':
				if (::sscanf(s, "hashfull %u", &value) == 1)
				{
					setHashFullness(value);
					haveHashFull = true;
				}
				break;

			case 'r':
				if (::strncmp(s, "refutation ", 11) == 0)
				{
					// If UCI_ShowRefutations is set:
					// ------------------------------------------------------
					// "info refutation d1h5 g6h5"	Qd1-h5 is refuted
					// "info refutation d1h5"			Qd1-h5 has no refutation
				}
				break;

			case 'd':
				if (::sscanf(s, "depth %u", &value) == 1)
				{
					setDepth(value);
					haveDepth = true;
				}
				break;

			case 's':
				switch (s[1])
				{
					case 'c':
						if (::strncmp(s, "score ", 6) == 0)
						{
							int value;

							s = skipWords(s, 1);

							switch (s[0])
							{
								case 'c':
									if (::sscanf(s, "cp %d", &value) == 1)
									{
										score = whiteToMove() ? value : -value;
										haveScore = true;
									}
									break;

								case 'm':
									if (::sscanf(s, "mate %d", &value) == 1)
									{
										mate = whiteToMove() ? value : -value;
										haveMate = true;

#if 0 // we cannot terminate, the engine might find a "better" pv
										if (isAnalyzing())
											stopAnalysis(); // we don't need further computation if mate
#endif
									}
									break;
							}
						}
						break;

					case 'e':
						if (::sscanf(s, "seldepth %u", &value) == 1)
							setSelectiveDepth(value);
						break;

					case 't':
						if (::strncmp(s, "string ", 7) == 0)
							return; // ignore rest of message
						break;
				}
				// NOTE: we ignore "sbhits"
				break;

			case 't':
				if (::sscanf(s, "time %u", &value) == 1)
					setTime(value/1000.0);
				// NOTE: we ignore "tbhits"
				break;

			case 'n':
				// skip "nps"
				if (::sscanf(s, "nodes %u", &value) == 1)
					setNodes(value);
				break;

			case 'p':
				if (strncmp(s, "pv ", 3) == 0)
				{
					MoveList moves;

					if (!(s = parseMoveList(skipWords(s, 1), moves)))
						return;

					setVariation(multiPv, moves);
					havePv = true;
					continue;
				}
				break;

			case 'm':
				if (::sscanf(s, "multipv %u", &value) == 1)
				{
					if (value == 0 || value > numVariations())
						return;
					multiPv = value - 1;
				}
				else if (::sscanf(s, "mate %u", &value) == 1)
				{
					mate = whiteToMove() ? value : -value;
					havePv = haveMate = true;
				}
				break;

			case 'l':
				if (::strncmp(s, "lowerbound ", 11) == 0)
					return; // we don't use lowerbound
				break;

			case 'u':
				if (::strncmp(s, "upperbound ", 11) == 0)
					return; // we don't use upperbound
				break;
		}

		s = ::skipWords(s, 2);
	}

	if (haveHashFull)
		updateHashFullInfo();	// "info hashfull <promille>"
//	if (haveCpuLoad)
//		updateCPULoadInfo();

	if (havePv && (haveScore || haveMate))
	{
		if (haveMate)
			setMate(multiPv, mate);
		else
			setScore(multiPv, score);

		updatePvInfo(multiPv);
	}
	else if (haveTime)
	{
		updateTimeInfo(); 		// "info time 1008 nodes 1010000 nps 1002409 cpuload 925"
	}
	else if (haveDepth)
	{
		updateDepthInfo();
	}
}


Move
uci::Engine::parseCurrentMove(char const* s)
{
	Move move = m_board.parseLAN(s);

	if (!move.isLegal())
	{
		mstl::string msg("Illegal current move: ");
		msg.append(s, ::skipNonSpaces(s));
		error(msg);
		return Move();
	}

	m_board.prepareForPrint(move);
	return move;
}


char const*
uci::Engine::parseMoveList(char const* s, db::MoveList& moves)
{
	Board board(m_board);

	while (::isLan(s))
	{
		Move move;

		char const *next = board.parseLAN(s, move);

		if (next == 0)
		{
			mstl::string msg("Illegal move in pv: ");
			msg.append(s, ::skipNonSpaces(s));
			error(msg);
			return 0;
		}

		board.prepareForPrint(move);
		board.doMove(move);
		moves.append(move);

		s = ::skipSpaces(next);

		if (moves.isFull())
		{
			while (::isLan(s))
				s = ::skipWords(s, 1);
			log("WARNING: Pv is too long (truncated)");
			return s;
		}
	}

	return moves.isEmpty() ? 0 : s;
}


void
uci::Engine::parseOption(char const* msg)
{
	typedef mstl::list<mstl::string> Vars;

	mstl::string	name;
	mstl::string	type;
	mstl::string	dflt;
	mstl::string	min;
	mstl::string	max;
	mstl::string	key;
	mstl::string*	value = 0;

	Vars vars;

	while (::nextWord(key, msg))
	{
		if      (key == "name")		value = &name;
		else if (key == "type")		value = &type;
		else if (key == "default")	value = &dflt;
		else if (key == "min")		value = &min;
		else if (key == "max")		value = &max;
		else if (key == "var")		value = vars.insert(vars.end(), mstl::string()).operator->();
		else if (value)				::append(*value,  key);
	}

	if (name.empty())
		return;

	if (::strncmp(name, "UCI_", 4) == 0)
	{
		switch (name[4])
		{
			case 'A':
				if (name == "UCI_AnalyseMode")
					m_hasAnalyseMode = true;
				break;

			case 'C':
				if (name == "UCI_Chess960")
					addVariant(app::Engine::Variant_Chess_960);
				break;

			case 'L':
				if (name == "UCI_LimitStrength")
					addFeature(app::Engine::Feature_Limit_Strength);
				break;

			case 'E':
				if (name == "UCI_EngineAbout")
				{
					if (isProbing())
						detectUrl(dflt);
				}
				else if (name == "UCI_Elo")
				{
					if (type == "spin")
					{
						setEloRange(::atoi(min), ::atoi(max));
						setElo(::atoi(max));
					}
				}
				break;

			case 'S':
				if (name == "UCI_ShowCurrLine")
					m_hasShowCurrLine = true;
				else if (name == "UCI_ShowRefutations")
					m_hasShowRefutations = true;
				else if (name == "UCI_ShredderbasesPath")
					; // we do not use
				else if (name == "UCI_SetPositionValue")
					; // we do not use
				break;
		}
	}
	else if (type == "check")
	{
		if (dflt != "true" && dflt != "false")
			return;

		if (name == "Ponder")
		{
			// this means that the engine is able to ponder
			// should be enabled by default?
			addFeature(app::Engine::Feature_Ponder);
			return;
		}
		if (name == "OwnBook")
		{
			// this means that the engine has its own book
			// if this is set, the engine takes care of the opening book and
			// the GUI will never execute a move out of its book for the engine
			m_hasOwnBook = true;
			return;
		}

		addOption(name, type, dflt);
	}
	else if (type == "spin")
	{
		if (!::isNumeric(dflt) || !::isNumeric(min) || !::isNumeric(max))
			return;

		if (name == "MultiPV")
		{
			m_hasMultiPV = true;
			m_maxMultiPV = mstl::max(1ul, ::strtoul(max, nullptr, 10));
			setMaxMultiPV(m_maxMultiPV);
			return;
		}
		else if (name == "Hash")
		{
			setHashRange(::atoi(min), ::atoi(max));
		}
		else if (name == "Threads")
		{
			setThreadRange(::atoi(min), ::atoi(max));
		}
		else if (name == "Skill Level")
		{
			setSkillLevelRange(::atoi(min), ::atoi(max));
		}

		addOption(name, type, dflt, min, max);
	}
	else if (type == "combo")
	{
		mstl::string var;
		bool found = false;

		Vars::iterator i = vars.begin();
		Vars::iterator e = vars.end();

		for ( ; i != e; ++i)
		{
			mstl::string& v = *i;

			if (!v.empty())
			{
				if (dflt == v)
					found = true;

				if (!var.empty())
					var += ";";
				::subst(v, ';');
				var += v;
			}
		}

		if (found)
		{
			addOption(name, type, dflt, var);

			if (name == "Playing Style")
				setPlayingStyles(var);
		}
	}
	else if (type == "button")
	{
		if (name == "Clear Hash")
			addFeature(app::Engine::Feature_Clear_Hash);

		addOption(name, type);
	}
	else if (type == "string")
	{
		if (::isPath(name))
			addOption(name, "path", dflt);
		else if (::isFile(name))
			addOption(name, "file", dflt);
		else
			addOption(name, type, dflt);
	}
}


void
uci::Engine::sendOptions()
{
	bool isAnalyzing = this->isAnalyzing();

	app::Engine::Options const& opts = options();
	mstl::string msg;

	if (isAnalyzing)
		stopAnalysis();

	for (app::Engine::Options::const_iterator i = opts.begin(); i != opts.end(); ++i)
	{
		app::Engine::Option const& opt = *i;

		mstl::string val = opt.val;

		switch (opt.name[0])
		{
			case 'B':
				if (opt.name == "BookFile")
				{
//					if (m_hasOwnBook)
					val = "";
				}
				break;

			case 'C':
				if (opt.name == "Clear Hash")
					continue; // should not be sent here
				break;

			case 'H':
				if (opt.name == "Hash")
					continue; // should not be sent here
				break;

			case 'E':
				if (opt.name == "Elo")
				{
					if (hasFeature(app::Engine::Feature_Limit_Strength))
						::setNonZeroValue(val, limitedStrength());
				}
				break;

			case 'M':
				if (opt.name == "MultiPV")
					continue; // // should not be sent here
				break;

			case 'O':
				if (opt.name == "OwnBook")
				{
//					if (m_hasOwnBook)
					val = "false";
				}
				break;

			case 'P':
				if (opt.name == "Ponder")
					continue; // should not be sent here
				break;

			case 'T':
				if (opt.name == "Threads")
					continue; // should not be sent here
				break;

			case 'U':
				if (opt.name == "UCI_LimitStrength")
					val = limitedStrength() ? "true" : "false";
				else if (opt.name == "UCI_ShowCurrLine")
					val = "false";
				else if (opt.name == "UCI_ShowRefutations")
					val = "false";
				break;
		}

		msg.assign("setoption name ", 15);
		msg.append(opt.name);

		if (!val.empty())
		{
			msg.append(" value ", 7);
			msg.append(val);
		}

		send(msg);
	}

	if (hasFeature(app::Engine::Feature_Ponder))
		send("setoption name Ponder value " + ::toBool(pondering()));

	if (hasFeature(app::Engine::Feature_Multi_PV))
		send("setoption name MultiPV value " + ::toStr(numVariations()));

	if (hasFeature(app::Engine::Feature_Hash_Size))
		send("setoption name Hash value " + ::toStr(hashSize()));

	if (hasFeature(app::Engine::Feature_Threads))
		send("setoption name Threads value " + ::toStr(numThreads()));

	if (isAnalyzing)
	{
		m_waitingOn = "readyok";
		send("isready");
		m_continueAnalysis = true;
	}
}


void
uci::Engine::sendOption(mstl::string const& name, mstl::string const& value)
{
	if (isAnalyzing())
	{
		send("stop");
		// XXX probably "ucinewgame" is required
		m_waitingOn = "setoption";
		send("isready");
		m_continueAnalysis = true;
		m_name = name;
		m_value = value;
	}
	else
	{
		mstl::string msg("setoption name ");
		msg.append(name);
		if (!value.empty())
		{
			msg.append(" value ");
			msg.append(value);
		}
		send(msg);
	}
}


void
uci::Engine::invokeOption(mstl::string const& name)
{
	sendOption(name, "");
}


void
uci::Engine::sendHashSize()
{
	sendOption("Hash", ::toStr(hashSize()));
}


void
uci::Engine::sendNumberOfVariations()
{
	sendOption("MultiPV", ::toStr(numVariations()));
}


void
uci::Engine::sendThreads()
{
	sendOption("Threads", ::toStr(numThreads()));
}


void
uci::Engine::sendSkillLevel()
{
	sendOption("Skill Level", ::toStr(skillLevel()));
}


void
uci::Engine::sendPondering()
{
	sendOption("Ponder", ::toBool(pondering()));
}


void
uci::Engine::sendStrength()
{
	sendOption("UCI_Elo", ::toStr(limitedStrength()));
}


void
uci::Engine::clearHash()
{
	// XXX should we stop analysis?
	send("setoption name Clear Hash");
}

// vi:set ts=3 sw=3:
