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
// Copyright: (C) 2009-2013 Gregor Cramer
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
		return *e == '\0' || *e == '_' || strncmp(s, "name", 4) == 0;
	}

	i = s.find(lower);

	if (i == mstl::string::npos)
		return false;

	char const* p = s.begin() + i;
	char const* e = p + 4;

	return (i == 0 || p[-1] == '_') && ((*e == '\0' || *e == '_' || strncmp(s, "name", 4) == 0));
}


static bool
isPath(mstl::string const& s)
{
	if (isPathOrFile(s, "Path", "path"))
		return true;
	
	mstl::string::size_type i = s.find("irectory");

	if (i == 0 || i == mstl::string::npos)
		return false;

	char const* p = s.begin() + (--i);

	if (toupper(*p) != 'D')
		return false;

	char const* e = p + 9;
	return (i == 0 || p[-1] == '_') && (*e == '\0' || *e == '_');
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


static mstl::string
toId(mstl::string const& name)
{
	mstl::string id;
	id.reserve(name.size());

	for (mstl::string::const_iterator i = name.begin(); i != name.end(); ++i)
	{
		if (*i != ' ' && *i != '_')
			id += *i;
	}

	id.tolower();
	return id;
}


uci::Engine::Engine()
	:m_state(None)
	,m_variant(variant::Normal)
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
	,m_stopAnalyzeIsPending(false)
	,m_isChess960(false)
	,m_sendAnalyseMode(false)
	,m_usedAnalyseModeBefore(false)
	,m_clearHashOnTheFly(false)
{
}


void
uci::Engine::doMove(db::Move const& lastMove)
{
	if (isAnalyzing())
	{
		stopAnalysis(true);
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
	return currentBoard().whiteToMove();
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


void
uci::Engine::setupPosition(Board const& board)
{
	m_position.assign("position ", 9);

	if (board.isStandardPosition(currentGame()->variant()))
	{
		m_position.append("startpos", 8);
	}
	else
	{
		db::Board::Format	fmt(isChess960Position() ? Board::Shredder : Board::XFen);
		mstl::string		fen(board.toFen(currentVariant(), fmt));

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
	M_ASSERT(!currentGame()->currentBoard().gameIsOver(currentGame()->variant()));

	m_state = Start;
	m_isNewGame = isNewGame;

	if (m_stopAnalyzeIsPending)
		return m_startAnalyzeIsPending = true; // wait on "bestmove"

	m_startAnalyzeIsPending = false;

	db::Game const* game = currentGame();

	if (m_hasAnalyseMode && !m_usedAnalyseModeBefore)
	{
		m_sendAnalyseMode = true;
		m_usedAnalyseModeBefore = true;
	}

	setBoard(game->currentBoard());

	if (game->historyIsLegal(Game::DontAllowNullMoves))
	{
		// We prefer to use the "position moves" setup because (due to Steve):
		// The problem is that lots engines will reset their analysis with "position fen".
		// Only a few will check to see if the new position is in their search tree.
		setupPosition(game->startBoard());

		if (game->startBoard().plyNumber() != currentBoard().plyNumber())
		{
			m_position.append(" moves", 6);
			game->dumpHistory(m_position, isChess960Position() ? protocol::Scidb : protocol::UCI);
		}
	}
	else
	{
		// "position moves" cannot be used because the move history contains illegal moves.
		setupPosition(currentBoard());
	}

	if (isNewGame)
		send("ucinewgame"); // clear all states

	m_waitingOn = "position";
	send("isready");

	updateState(app::Engine::Start);

	return true;
}


bool
uci::Engine::stopAnalysis(bool restartIsPending)
{
	State oldState = m_state;

	m_startAnalyzeIsPending = false;
	m_state = Stop;

	if (!m_isAnalyzing)
		return false;

	if (!m_stopAnalyzeIsPending)
	{
		send("stop");
		if (oldState != Pause)
			m_stopAnalyzeIsPending = true;
		if (!restartIsPending)
			updateState(app::Engine::Stop);
		// the engine should now send final info and bestmove
	}

	return true;
}


bool
uci::Engine::continueAnalysis()
{
	if (m_state == Start)
		return false;

	if (currentGame())
	{
		if (m_waitingOn == "setoption")
			return true;

		send("go infinite");
		m_isAnalyzing = true;
		updateState(app::Engine::Resume);
	}

	m_state = Start;
	return true;
}


void
uci::Engine::pause()
{
	// XXX only working for analyzing mode
	if (m_state != Stop)
		send("stop");
	m_state = Pause;
	m_stopAnalyzeIsPending = true;
	updateState(app::Engine::Pause);
}


void
uci::Engine::resume()
{
	send("go infinite");
	m_isAnalyzing = true;
	m_state = Start;
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
	stopAnalysis(false);
	m_stopAnalyzeIsPending = false;
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

					if (isChess960Position() != m_isChess960)
					{
						send("setoption name UCI_Chess960 value " + ::toBool(isChess960Position()));
						m_isChess960 = isChess960Position();
					}

					if (m_variant != currentVariant())
					{
						// Currently only variant Three-check Chess is supported in UCI mode.
						send("setoption name UCI_VariantThreeCheck value " +
								::toBool(currentVariant() == variant::ThreeCheck));
						m_variant = currentVariant();
					}

					send(m_position);
					m_isAnalyzing = true;

					if (searchMate() > 0)
						send("go mate " + ::toStr(searchMate()));
					else if (searchDepth() > 0)
						send("go depth " + ::toStr(searchDepth()));
					else if (searchTime() > 0)
						send("go time " + ::toStr(searchTime()));
					else
						send("go infinite");

					// NOTE: probably we like to use something like
					// "go wtime 55857 btime 58611 winc 1000 binc 1000"
				}
				else if (m_waitingOn == "setoption")
				{
					mstl::string str("setoption name ");
					str += m_name;
					if (!m_value.empty())
						(str += " value ") += m_value;
					send(str);
					m_waitingOn.clear();
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

						// Only a few engines are able to clear hash tables on the fly,
						// currently this is known only for Stockfish.
						m_clearHashOnTheFly = ::strncmp(identifier, "Stockfish", 9) == 0;
					}
					else if (::strncmp(message, "id author ", 10) == 0)
					{
						setAuthor(message.c_str() + 10);
					}
					break;

				case 'n':
					if ((isAnalyzing() || m_stopAnalyzeIsPending) && ::strncmp(message, "info ", 5) == 0)
						parseInfo(::skipSpaces(message.c_str() + 5));
					break;
			}
			break;

		case 'o':
			if (::strncmp(message, "option name ", 12) == 0)
				parseOption(::skipSpaces(message.c_str() + 7));
			break;

		case 'b':
			if (m_stopAnalyzeIsPending && ::strncmp(message, "bestmove ", 9) == 0)
				parseBestMove(message.c_str() + 9);
			break;

		case 'c':
			if (::strcmp(message, "copyprotection checking") == 0)
			{
				error(app::Engine::Engine_Has_Copy_Protection);
				deactivate();
			}
			break;
	}
}


void
uci::Engine::parseBestMove(char const* msg)
{
	m_stopAnalyzeIsPending = false;

	if (m_state != Start)
		m_isAnalyzing = false;

	char const* s = ::skipSpaces(msg);
	Move move(currentBoard().parseLAN(s));

	if (move.isLegal())
	{
		currentBoard().prepareForPrint(move, m_variant, Board::InternalRepresentation);
		setBestMove(move);
	}
	else if (::strncmp(s, "(none)", 6) != 0)
	{
		mstl::string msg("Illegal best move: ");
		msg.append(s, ::skipNonSpaces(s));
		error(msg);
	}

	s = ::skipNonSpaces(s);

	if (::strncmp(s, "ponder ", 6) == 0)
	{
		s = ::skipSpaces(s + 6);

		currentBoard().doMove(move, m_variant);
		Move ponder(currentBoard().parseLAN(s));
		currentBoard().undoMove(move, m_variant);

		if (move.isLegal())
		{
			setPonder(ponder);
			updateBestMove();
		}
		else if (::strncmp(s, "(none)", 6) != 0)
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
	unsigned varno				= 0;
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
/*						if (::strncmp(s, "currline ", 9) == 0)
						{
							MoveList moves;

							if (!(s = parseMoveList(::skipWords(s, 1), moves)))
								return;

							setCurrLine(moves);
							updateCurrLine();
							continue;
						}
						else*/ if (::strncmp(s, "currmove ", 9) == 0)
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
							setCurrentMove(currMoveNumber, 0, currMove);
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
					Board board(currentBoard());
					MoveList moves;

					if (!(s = parseMoveList(skipWords(s, 1), board, moves)))
						return;

					varno = setVariation(varno, moves);
					havePv = true;

					if (!haveMate && (board.checkState(m_variant) & Board::Checkmate))
					{
						int n = board.moveNumber() - currentBoard().moveNumber();
						mate = board.whiteToMove() ? -n : +n;
						haveMate = true;
					}
					continue;
				}
				break;

			case 'm':
				if (::sscanf(s, "multipv %u", &value) == 1)
				{
					if (value == 0 || value > numVariations())
						return;
					varno = value - 1;
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
			setMate(varno, mate);
		else
			setScore(varno, score);

		updatePvInfo(varno);
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
	Move move = currentBoard().parseLAN(s);

	if (!move.isLegal())
	{
		// Some engines (e.g. Gaviota) are sending SAN (not UCI conform)
		if (!currentBoard().parseMove(s, move, m_variant))
		{
			mstl::string msg("Illegal current move: ");
			msg.append(s, ::skipNonSpaces(s));
			error(msg);
			return Move();
		}

		if (!move)
		{
			// May happen if restart of analysis fails (e.g. Gaviota).
			return move;
		}
	}

	currentBoard().prepareForPrint(move, m_variant, Board::InternalRepresentation);
	return move;
}


char const*
uci::Engine::parseMoveList(char const* s, db::Board& board, db::MoveList& moves)
{
	while (::isLan(s))
	{
		Move move;

		char const *next = board.parseLAN(s, move);

		if (next == 0)
		{
			mstl::string msg("Illegal move in PV: ");
			msg.append(s, ::skipNonSpaces(s));
			error(msg);

			if (moves.isEmpty())
			{
				if (isAnalyzing())
				{
					// Some engines (e,g. Gaviota) are playing the bestmove
					// automatically, thus starting from a wrong position in
					// case of restart. Restart analysis again in this case.
					stopAnalysis(true);
					startAnalysis(true);
				}
			}

			return 0;
		}

		board.prepareForPrint(move, m_variant, Board::InternalRepresentation);
		board.doMove(move, m_variant);
		moves.append(move);

		s = ::skipSpaces(next);

		if (moves.isFull())
		{
			while (::isLan(s))
				s = ::skipWords(s, 1);
			log("WARNING: PV is too long (truncated)");
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
	
	mstl::string id(::toId(name));

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

			case 'V':
				if (name == "UCI_VariantThreeCheck")
					addVariant(app::Engine::Variant_Three_Check);
				break;
		}
	}
	else if (type == "check")
	{
		if (dflt != "true" && dflt != "false")
			return;

		if (id == "ponder")
		{
			// this means that the engine is able to ponder
			// should be enabled by default?
			addFeature(app::Engine::Feature_Ponder);
			return;
		}
		if (id == "ownbook")
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

		if (id == "multipv")
		{
			m_hasMultiPV = true;
			setMaxMultiPV(mstl::max(1ul, ::strtoul(max, nullptr, 10)));
			return;
		}
		else if (id == "hash")
		{
			setHashRange(::atoi(min), ::atoi(max));
		}
		else if (id == "threads")
		{
			setThreadRange(::atoi(min), ::atoi(max));
			m_threads.assign(name);
		}
		else if (id == "minthreads" || id == "minimalthreads")
		{
			// Firenzina is using this instead of "Threads".
			if (m_threads.empty())
			{
				unsigned minThreads = ::atoi(min);
				setThreadRange(minThreads, mstl::max(maxThreads(), minThreads));
				m_minThreads.assign(name);
			}
		}
		else if (id == "maxthreads" || id == "maximalthreads")
		{
			// Firenzina is using this instead of "Threads".
			if (m_threads.empty())
			{
				unsigned maxThreads = ::atoi(max);
				setThreadRange(mstl::min(minThreads(), maxThreads), maxThreads);
				m_maxThreads.assign(name);
			}
		}
		else if (id == "cores")
		{
			// Some engines are using "Cores" instead of "Threads", for example Gaviota.
			if (m_threads.empty())
			{
				setThreadRange(::atoi(min), ::atoi(max));
				m_threads.assign(name);
			}
		}
		else if (id == "skilllevel")
		{
			setSkillLevelRange(::atoi(min), ::atoi(max));
			m_skillLevel = name;
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

			if (id == "playingstyle")
				setPlayingStyles(var);
		}
	}
	else if (type == "button")
	{
		if (id == "clearhash")
		{
			addFeature(app::Engine::Feature_Clear_Hash);
			m_clearHash = name;
		}

		addOption(name, type);
	}
	else if (type == "string")
	{
		if (::isPath(id))
			addOption(name, "path", dflt);
		else if (::isFile(id))
			addOption(name, "file", dflt);
		else
			addOption(name, type, dflt);
	}
}


void
uci::Engine::sendOptions()
{
	bool isAnalyzing = this->isAnalyzing();

	if (m_threads.empty() && (m_minThreads.empty() || m_maxThreads.empty()))
		m_threads.assign("Threads");

	app::Engine::Options const& opts = options();
	mstl::string msg;

	if (isAnalyzing)
		stopAnalysis(true);

	for (app::Engine::Options::const_iterator i = opts.begin(); i != opts.end(); ++i)
	{
		app::Engine::Option const& opt = *i;
		mstl::string id(::toId(opt.name));

		if (opt.name == m_threads || opt.name == m_minThreads || opt.name == m_maxThreads)
			continue; // should not be sent here

		mstl::string val = opt.val;

		switch (id[0])
		{
			case 'b':
				if (id == "bookfile")
				{
//					if (m_hasOwnBook)
					val = "";
				}
				break;

			case 'c':
				if (id == "clearhash")
					continue; // should not be sent here
				if (id == "currentmoveinfo" && opt.type == "check")
					val = "true";
				if (id == "cpuloadinfo" && opt.type == "check")
					val = "false";
				break;

			case 'd':
				if (id == "depthinfo" && opt.type == "check")
					val = "true";
				break;

			case 'h':
				if (id == "hash")
					continue; // should not be sent here
				if ((id == "hashinfo" || id == "hashfullinfo") && opt.type == "check")
					val = "true";
				break;

			case 'e':
				if (id == "elo")
				{
					if (hasFeature(app::Engine::Feature_Limit_Strength))
						::setNonZeroValue(val, limitedStrength());
				}
				break;

			case 'm':
				if (id == "multipv")
					continue; // // should not be sent here
				break;

			case 'n':
				if (id == "npsinfo" && opt.type == "check")
					val = "false";
				break;

			case 'o':
				if (id == "ownbook")
				{
//					if (m_hasOwnBook)
					val = "false";
				}
				break;

			case 'p':
				if (id == "ponder")
					continue; // should not be sent here
				break;

			case 't':
				if (id == "tbhitinfo" && opt.type == "check")
					val = "false";
				break;

			case 'u':
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
	{
		if (!m_threads.empty())
		{
			send("setoption name " + m_threads + " value " + ::toStr(numThreads()));
		}
		else if (!m_minThreads.empty() && !m_maxThreads.empty())
		{
			send("setoption name " + m_minThreads + " value " + ::toStr(numThreads()));
			send("setoption name " + m_maxThreads + " value " + ::toStr(numThreads()));
		}
	}

	if (isAnalyzing)
	{
		m_waitingOn = "readyok";
		send("isready");
	}
}


void
uci::Engine::sendOption(mstl::string const& name, mstl::string const& value)
{
	if (isAnalyzing())
	{
		if (m_state != Stop)
			send("stop");
		// XXX probably "ucinewgame" is required
		m_waitingOn = "setoption";
		m_state = Pause;
		send("isready");
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
	sendOption(name);
}


void
uci::Engine::sendHashSize()
{
	sendOption("Hash", ::toStr(hashSize()));
}


void
uci::Engine::sendNumberOfVariations()
{
#if 0
	sendOption("MultiPV", ::toStr(numVariations()));
#else
	send("setoption name MultiPV value " + ::toStr(numVariations()));
#endif
}


void
uci::Engine::sendThreads()
{
	if (m_threads.empty() && (m_minThreads.empty() || m_maxThreads.empty()))
		m_threads.assign("Threads");

	mstl::string num = ::toStr(numThreads());

	if (!m_threads.empty())
	{
		sendOption(m_threads, num);
	}
	else if (!m_minThreads.empty() && !m_maxThreads.empty())
	{
		sendOption(m_minThreads, num);
		sendOption(m_maxThreads, num);
	}
}


void
uci::Engine::sendSkillLevel()
{
	if (m_skillLevel.empty())
		m_skillLevel.assign("Skill Level");

	sendOption(m_skillLevel, ::toStr(skillLevel()));
}


void
uci::Engine::sendPondering()
{
#if 0
	sendOption("Ponder", ::toBool(pondering()));
#else
	send("setoption name Ponder value " + ::toBool(pondering()));
#endif
}


void
uci::Engine::sendStrength()
{
	sendOption("UCI_Elo", ::toStr(limitedStrength()));
}


void
uci::Engine::clearHash()
{
	if (m_clearHash.empty())
		m_clearHash.assign("Clear Hash");

	if (m_clearHashOnTheFly)
		send("setoption name " + m_clearHash);
	else
		sendOption(m_clearHash);
}

// vi:set ts=3 sw=3:
