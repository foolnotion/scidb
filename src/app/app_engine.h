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

#ifndef _app_engine_included
#define _app_engine_included

#include "db_move_list.h"

#include "m_string.h"
#include "m_pvector.h"
#include "m_list.h"
#include "m_bitfield.h"

namespace mstl	{ class ostream; }

namespace db
{
	class Board;
	class Game;
	class Move;
	class MoveList;
}

namespace app {

namespace uci { class Engine; }
namespace winboard { class Engine; }

class Engine
{
public:

	static unsigned const MaxNumVariations = 32;

	enum Ordering
	{
		Unordered,
		BestFirst,
		KeepStable,
	};

	enum Result
	{
		Probe_Failed,
		Probe_Undecidable,
		Probe_Successfull,
	};

	enum Protocol
	{
		Uci,
		WinBoard,
	};

	enum Signal
	{
		Stopped,
		Resumed,
		Terminated,
		Crashed,
		Killed,
		PipeClosed,
	};

	struct Option
	{
		mstl::string name;
		mstl::string type;
		mstl::string val;
		mstl::string dflt;
		mstl::string var;
		mstl::string max;
	};

	typedef mstl::list<Option> Options;

	class Concrete
	{
	public:

		typedef app::Engine::Result Result;

		virtual ~Concrete();

		virtual bool isReady() const = 0;
		virtual bool isAnalyzing() const = 0;

		virtual bool startAnalysis(bool isNewGame) = 0;
		virtual bool stopAnalysis() = 0;

		virtual void protocolStart(bool isProbing) = 0;
		virtual void protocolEnd() = 0;

		virtual void pause() = 0;
		virtual void resume() = 0;

		virtual void processMessage(mstl::string const& message) = 0;
		virtual void doMove(db::Move const& lastMove) = 0;

		virtual void sendNumberOfVariations();
		virtual void sendHashSize();
		virtual void sendThreads();
		virtual void sendStrength();
		virtual void sendSkillLevel();
		virtual void sendPlayOther();
		virtual void sendPondering();
		virtual void sendPlayingStyle();
		virtual void clearHash();
		virtual void sendOptions() = 0;

		virtual Result probeResult() const = 0;
		virtual Result probeAnalyzeFeature() const;
		virtual unsigned probeTimeout() const = 0;
		virtual unsigned maxVariations() const;
		virtual db::Board const& currentBoard() const = 0;

		friend class Engine;

	protected:

		bool isActive() const;
		bool isProbing() const;
		bool isProbingAnalyze() const;
		bool hasFeature(unsigned feature) const;

		unsigned maxMultiPV() const;
		unsigned numVariations() const;
		unsigned hashSize() const;
		unsigned numThreads() const;
		unsigned searchMate() const;
		unsigned limitedStrength() const;
		unsigned skillLevel() const;
		bool playOther() const;
		bool pondering() const;
		db::Game const* currentGame() const;
		Options const& options() const;

		long pid() const;

		void engineIsReady();

		void send(mstl::string const& message);
		void deactivate();

		void addFeature(unsigned feature);
		bool detectShortName(mstl::string const& str);
		bool detectIdentifier(mstl::string const& str);
		bool detectUrl(mstl::string const& str);
		bool detectEmail(mstl::string const& str);

		void addOption(mstl::string const& name,
							mstl::string const& type,
							mstl::string const& dflt = mstl::string::empty_string,
							mstl::string const& var = mstl::string::empty_string,
							mstl::string const& max = mstl::string::empty_string);

		void setBestMove(db::Move const& move);
		void setPonder(db::Move const& move);

		void setScore(unsigned no, int score);
		void setMate(unsigned no, int numMoves);
		void setDepth(unsigned depth);
		void setSelectiveDepth(unsigned depth);
		void setTime(double time);
		void setNodes(unsigned nodes);
		void setVariation(unsigned no, db::MoveList const& moves);
		void setCurrentMove(unsigned number, db::Move const& move);

		void setIdentifier(mstl::string const& name);
		void setShortName(mstl::string const& name);
		void setAuthor(mstl::string const& name);
		void setUrl(mstl::string const& address);
		void setEmail(mstl::string const& address);
		void setElo(unsigned elo);
		void setEloRange(unsigned minElo, unsigned maxElo);
		void setSkillLevelRange(unsigned ninLevel, unsigned maxLevel);
		void setMaxMultiPV(unsigned n);
		void setHashRange(unsigned minSize, unsigned maxSize);
		void setThreadRange(unsigned minThreads, unsigned maxThreads);
		void setPlayingStyles(mstl::string const& styles);

		void updatePvInfo(unsigned line);
		void updateCheckMateInfo();
		void updateStaleMateInfo();
		void updateCurrMove();
		void updateCurrLine();
		void updateBestMove();
		void updateDepthInfo();
		void updateTimeInfo();
		void updateHashFullInfo();
		void resetInfo();

		void log(mstl::string const& msg);
		void error(mstl::string const& msg);

	private:

		Engine* m_engine;
	};

	static unsigned const Feature_Analyze			= 1 << 0;
	static unsigned const Feature_Hash_Size		= 1 << 1;
	static unsigned const Feature_Clear_Hash		= 1 << 2;
	static unsigned const Feature_Chess_960		= 1 << 3;
	static unsigned const Feature_Shuffle_Chess	= 1 << 4;
	static unsigned const Feature_Pause				= 1 << 5;
	static unsigned const Feature_Play_Other		= 1 << 6;
	static unsigned const Feature_Ponder			= 1 << 7;
	static unsigned const Feature_Limit_Strength	= 1 << 8;
	static unsigned const Feature_Skill_Level		= 1 << 8;
	static unsigned const Feature_Multi_PV			= 1 << 10;
	static unsigned const Feature_Threads			= 1 << 11;
	static unsigned const Feature_Playing_Styles	= 1 << 12;

	Engine(Protocol protocol, mstl::string const& command, mstl::string const& directory);
	virtual ~Engine();

	Concrete* concrete();

	void setLog(mstl::ostream* stream = 0);
	void setOrdering(Ordering method);

	void activate();
	void deactivate();

	bool isAlive();
	bool isActive() const;
	bool isAnalyzing() const;
	bool isProbing() const;
	bool isProbingAnalyze() const;
	bool hasFeature(unsigned feature) const;
	bool playOther() const;
	bool pondering() const;
	bool isBestLine(unsigned no) const;
	bool bestInfoHasChanged() const;

	int exitStatus() const;

	int score(unsigned no) const;
	int mate(unsigned no) const;
	int bestScore() const;
	int shortestMate() const;
	unsigned depth() const;
	unsigned selectiveDepth() const;
	double time() const;
	unsigned nodes() const;
	db::MoveList const& variation(unsigned no) const;
	db::Board const& currentBoard() const;
	db::Move const& bestMove() const;
	unsigned currentMoveNumber() const;
	db::Move const& currentMove() const;

	mstl::string const& identifier() const;
	mstl::string const& shortName() const;
	mstl::string const& author() const;
	mstl::string const& email() const;
	mstl::string const& url() const;
	unsigned elo() const;
	unsigned minElo() const;
	unsigned maxElo() const;
	unsigned skillLevel() const;
	unsigned minSkillLevel() const;
	unsigned maxSkillLevel() const;
	unsigned maxMultiPV() const;
	unsigned numVariations() const;
	unsigned hashSize() const;
	unsigned minHashSize() const;
	unsigned maxHashSize() const;
	unsigned numThreads() const;
	unsigned minThreads() const;
	unsigned maxThreads() const;
	unsigned searchMate() const;
	unsigned limitedStrength() const;
	mstl::string const& playingStyles() const;
	db::Game const* currentGame() const;
	Options const& options() const;

	Result probe(unsigned timeout);

	virtual void engineIsReady() = 0;
	virtual void engineSignal(Signal signal) = 0;

	bool startAnalysis(db::Game const* game);
	bool stopAnalysis();

	void pause();
	void resume();

	unsigned changeNumberOfVariations(unsigned n);
	unsigned changeHashSize(unsigned size);
	unsigned changeThreads(unsigned n);
	unsigned changeStrength(unsigned elo);
	unsigned changeSkillLevel(unsigned level);
	mstl::string const& changePlayingStyle(mstl::string const& style);
	void resetBestInfoHasChanged();
	bool playOther(bool flag);
	bool pondering(bool flag);
	void clearHash();
	void setOption(mstl::string const& name, mstl::string const& value);
	void updateOptions();

	void addFeature(unsigned feature);
	void removeFeature(unsigned feature);

	bool doMove(db::Move const& lastMove);

	friend class uci::Engine;
	friend class winboard::Engine;

protected:

	Engine();

	virtual void clearInfo() = 0;
	virtual void updatePvInfo(unsigned line) = 0;
	virtual void updateCheckMateInfo() = 0;
	virtual void updateStaleMateInfo() = 0;
	virtual void updateCurrMove();
	virtual void updateCurrLine();
	virtual void updateBestMove();
	virtual void updateDepthInfo();
	virtual void updateTimeInfo();
	virtual void updateHashFullInfo();

	bool protocolAlreadyStarted() const;

	long pid() const;
	void kill();

	// Sends a message to the chess engine
	void send(char const* message);
	void send(mstl::string const& message);

	bool detectShortName(mstl::string const& str);
	bool detectIdentifier(mstl::string const& str);
	bool detectUrl(mstl::string const& str);
	bool detectEmail(mstl::string const& str);

	void addOption(mstl::string const& name,
						mstl::string const& type,
						mstl::string const& dflt,
						mstl::string const& var,
						mstl::string const& max);

	void setBestMove(db::Move const& move);
	void setPonder(db::Move const& move);

	void setScore(unsigned no, int score);		// centi-pawns from white's perspective
	void setMate(unsigned no, int numMoves);	// number of moves
	void setDepth(unsigned depth);				// search depth
	void setSelectiveDepth(unsigned depth);	// selective search depth
	void setTime(double time);						// search time in seconds (.e.g. 10.28 seconds)
	void setNodes(unsigned nodes);				// nodes searched
	void setVariation(unsigned no, db::MoveList const& moves);
	void setCurrentMove(unsigned number, db::Move const& move);

	void setIdentifier(mstl::string const& name);
	void setShortName(mstl::string const& name);
	void setAuthor(mstl::string const& name);
	void setUrl(mstl::string const& address);
	void setEmail(mstl::string const& address);
	void setElo(unsigned elo);
	void setEloRange(unsigned minElo, unsigned maxElo);
	void setSkillLevelRange(unsigned minLevel, unsigned maxLevel);
	void setMaxMultiPV(unsigned n);
	void setHashRange(unsigned minSize, unsigned maxSize);
	void setThreadRange(unsigned minThreads, unsigned maxThreads);
	void setPlayingStyles(mstl::string const& styles);
	void resetInfo();

	void log(mstl::string const& msg);
	void error(mstl::string const& msg);
	void fatal(mstl::string const& msg);

private:

	typedef mstl::bitfield<unsigned> Selection;
	typedef mstl::pvector<db::MoveList> Variations;
	typedef int Scores[MaxNumVariations];
	typedef unsigned Map[MaxNumVariations];

	class Process;
	friend class Process;

	void reorderBestFirst(unsigned currentNo);
	bool detectShortName(mstl::string const& s, bool setId);
	void readyRead();
	void exited();
	void stopped();
	void resumed();

	Concrete*			m_engine;
	db::Game const*	m_game;
	unsigned				m_gameId;
	mstl::string		m_name;
	mstl::string		m_command;
	mstl::string		m_directory;
	mstl::string		m_identifier;
	mstl::string		m_shortName;
	mstl::string		m_author;
	mstl::string		m_url;
	mstl::string		m_email;
	mstl::string		m_playingStyles;
	mstl::string		m_playingStyle;
	Ordering				m_ordering;
	unsigned				m_elo;
	unsigned				m_minElo;
	unsigned				m_maxElo;
	unsigned				m_skillLevel;
	unsigned				m_minSkillLevel;
	unsigned				m_maxSkillLevel;
	unsigned				m_maxMultiPV;
	Map					m_map;
	Variations			m_variations;
	unsigned				m_numVariations;
	Scores				m_scores;
	Scores				m_mates;
	Scores				m_sortScores;
	unsigned				m_hashSize;
	unsigned				m_minHashSize;
	unsigned				m_maxHashSize;
	unsigned				m_numThreads;
	unsigned				m_minThreads;
	unsigned				m_maxThreads;
	bool					m_playOther;
	bool					m_pondering;
	unsigned				m_searchMate;
	unsigned				m_strength;
	unsigned				m_features;
	unsigned				m_currMoveNumber;
	db::Move				m_currMove;
	db::Move				m_bestMove;
	db::Move				m_ponder;
	Selection			m_selection;
	unsigned				m_bestIndex;
	int					m_bestScore;
	int					m_shortestMate;
	unsigned				m_depth;
	unsigned				m_selDepth;
	double				m_time;
	unsigned				m_nodes;
	bool					m_active;
	bool					m_probe;
	bool					m_probeAnalyze;
	bool					m_protocol;
	bool					m_identifierSet;
	bool					m_useLimitedStrength;
	bool					m_bestInfoHasChanged;
	Process*				m_process;
	int					m_exitStatus;
	mstl::ostream*		m_logStream;
	Options				m_options;
	mstl::string		m_buffer;
};

} // namespace app

#include "app_engine.ipp"

#endif // _app_engine_included

// vi:set ts=3 sw=3:
