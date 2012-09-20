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

		virtual ~Concrete() throw();

		virtual bool isReady() const = 0;

		virtual bool startAnalysis(bool isNewGame) = 0;
		virtual bool stopAnalysis() = 0;

		virtual void protocolStart(bool isProbing) = 0;
		virtual void protocolEnd() = 0;

		virtual void pause() = 0;
		virtual void resume() = 0;

		virtual void processMessage(mstl::string const& message) = 0;
		virtual void sendNumberOfVariations() = 0;
		virtual void sendHashSize() = 0;
		virtual void sendOptions() = 0;
		virtual void doMove(db::Move const& lastMove) = 0;
		virtual void clearHash() = 0;

		virtual Result probeResult() const = 0;
		virtual unsigned probeTimeout() const = 0;
		virtual unsigned maxVariations() const;
		virtual db::Board const& currentBoard() const = 0;

		friend class Engine;

	protected:

		bool isActive() const;
		bool isAnalyzing() const;
		bool isProbing() const;
		bool hasFeature(unsigned feature) const;

		unsigned maxMultiPV() const;
		unsigned numVariations() const;
		unsigned hashSize() const;
		unsigned numThreads() const;
		unsigned searchMate() const;
		unsigned limitedStrength() const;
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

		void setScore(int score);
		void setMate(int numHalfMoves);
		void setDepth(unsigned depth);
		void setTime(double time);
		void setNodes(unsigned nodes);
		void setVariation(db::MoveList const& moves, unsigned no = 0);
		void setCurrentMove(unsigned number, db::Move const& move);

		void setIdentifier(mstl::string const& name);
		void setShortName(mstl::string const& name);
		void setAuthor(mstl::string const& name);
		void setUrl(mstl::string const& address);
		void setEmail(mstl::string const& address);
		void setElo(unsigned elo);
		void setEloRange(unsigned minElo, unsigned maxElo);
		void setSkillLevel(unsigned level);
		void setMaxSkillLevel(unsigned maxLevel);
		void setMaxMultiPV(unsigned n);
		void setHashSize(unsigned size);
		void setHashRange(unsigned minSize, unsigned maxSize);
		void setThreads(unsigned num);
		void setThreadRange(unsigned minThreads, unsigned maxThreads);
		void setPlayingStyles(mstl::string const& styles);

		void updatePvInfo();
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

	static unsigned const Feature_Hash_Size		= 1 << 0;
	static unsigned const Feature_Clear_Hash		= 1 << 1;
	static unsigned const Feature_Chess_960		= 1 << 2;
	static unsigned const Feature_Shuffle_Chess	= 1 << 3;
	static unsigned const Feature_Pause				= 1 << 4;
	static unsigned const Feature_Play_Other		= 1 << 5;
	static unsigned const Feature_Ponder			= 1 << 6;
	static unsigned const Feature_Limit_Strength	= 1 << 7;
	static unsigned const Feature_Skill_Level		= 1 << 8;
	static unsigned const Feature_Multi_PV			= 1 << 9;
	static unsigned const Feature_Threads			= 1 << 10;
	static unsigned const Feature_Playing_Styles	= 1 << 11;

	Engine(Protocol protocol, mstl::string const& command, mstl::string const& directory);
	virtual ~Engine() throw();

	Concrete* concrete();

	void setLog(mstl::ostream* stream = 0);
	void setLimitedStrength(unsigned elo = 0);

	void activate();
	void deactivate();

	bool isAlive();
	bool isActive() const;
	bool isAnalyzing() const;
	bool isProbing() const;
	bool hasFeature(unsigned feature) const;

	int score() const;
	int mate() const;
	unsigned depth();
	double time() const;
	unsigned nodes() const;
	db::MoveList const& variation(unsigned no);
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

	bool startAnalysis(db::Game const* game);
	bool stopAnalysis();

	void pause();
	void resume();

	unsigned changeNumberOfVariations(unsigned n);
	unsigned changeHashSize(unsigned size);
	void changeOptions(Options const& options);
	void clearHash();

	bool doMove(db::Move const& lastMove);

	friend class uci::Engine;
	friend class winboard::Engine;

protected:

	Engine();

	virtual void updatePvInfo() = 0;
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

	void addFeature(unsigned feature);
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

	void setScore(int score);			// centi-pawns from white's perspective
	void setMate(int numHalfMoves);	// number of half moves from white's prespective
	void setDepth(unsigned depth);	// search depth
	void setTime(double time);			// search time in seconds (.e.g. 10.28 seconds)
	void setNodes(unsigned nodes);	// nodes searched
	void setVariation(db::MoveList const& moves, unsigned no);
	void setCurrentMove(unsigned number, db::Move const& move);

	void setIdentifier(mstl::string const& name);
	void setShortName(mstl::string const& name);
	void setAuthor(mstl::string const& name);
	void setUrl(mstl::string const& address);
	void setEmail(mstl::string const& address);
	void setElo(unsigned elo);
	void setEloRange(unsigned minElo, unsigned maxElo);
	void setSkillLevel(unsigned level);
	void setMaxSkillLevel(unsigned maxLevel);
	void setMaxMultiPV(unsigned n);
	void setHashSize(unsigned size);
	void setHashRange(unsigned minSize, unsigned maxSize);
	void setThreads(unsigned num);
	void setThreadRange(unsigned minThreads, unsigned maxThreads);
	void setPlayingStyles(mstl::string const& styles);
	void resetInfo();

	void log(mstl::string const& msg);
	void error(mstl::string const& msg);

private:

	typedef mstl::pvector<db::MoveList> Variations;

	class Process;
	friend class Process;

	bool detectShortName(mstl::string const& s, bool setId);
	void readyRead();
	void exited();

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
	unsigned				m_elo;
	unsigned				m_minElo;
	unsigned				m_maxElo;
	unsigned				m_skillLevel;
	unsigned				m_maxSkillLevel;
	unsigned				m_maxMultiPV;
	Variations			m_variations;
	unsigned				m_numVariations;
	unsigned				m_hashSize;
	unsigned				m_minHashSize;
	unsigned				m_maxHashSize;
	unsigned				m_numThreads;
	unsigned				m_minThreads;
	unsigned				m_maxThreads;
	unsigned				m_searchMate;
	unsigned				m_limitedStrength;
	unsigned				m_features;
	unsigned				m_currMoveNumber;
	db::Move				m_currMove;
	db::Move				m_bestMove;
	db::Move				m_ponder;
	int					m_score;
	int					m_mate;
	unsigned				m_depth;
	double				m_time;
	unsigned				m_nodes;
	bool					m_active;
	bool					m_analyzing;
	bool					m_probe;
	bool					m_protocol;
	bool					m_identifierSet;
	bool					m_useLimitedStrength;
	Process*				m_process;
	mstl::ostream*		m_logStream;
	Options				m_options;
	mstl::string		m_buffer;
};

} // namespace app

#include "app_engine.ipp"

#endif // _app_engine_included

// vi:set ts=3 sw=3:
