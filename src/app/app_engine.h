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

#ifndef _app_engine_included
#define _app_engine_included

#include "db_move_list.h"

#include "m_string.h"
#include "m_list.h"

namespace mstl	{ class ostream; }

namespace db
{
	class Board;
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

	class Concrete
	{
	public:

		typedef app::Engine::Result Result;

		virtual ~Concrete() throw();

		virtual bool startAnalysis(db::Board const& board) = 0;
		virtual bool stopAnalysis() = 0;

		virtual void protocolStart(bool isProbing) = 0;
		virtual void protocolEnd() = 0;

		virtual void processMessage(mstl::string const& message) = 0;

		virtual Result probeResult() const = 0;

		friend class Engine;

	protected:

		bool isActive() const;
		bool isAnalyzing() const;
		bool isProbing() const;
		bool hasFeature(unsigned feature) const;

		unsigned numVariations() const;
		unsigned searchMate() const;
		unsigned limitedStrength() const;

		long pid() const;

		void send(mstl::string const& message);
		void deactivate();

		void addFeature(unsigned feature);

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
		void setVariation(db::MoveList const& moves, unsigned no = 1);
		void setIdentifier(mstl::string const& name);

		void updateInfo();
		void resetInfo();

		void log(mstl::string const& msg);
		void error(mstl::string const& msg);

	private:

		Engine* m_engine;
	};

	static unsigned const Feature_Chess_960		= 1 << 0;
	static unsigned const Feature_Shuffle_Chess	= 1 << 1;
	static unsigned const Feature_Pause				= 1 << 2;

	Engine(	Protocol protocol,
				mstl::string const& name,
				mstl::string const& command,
				mstl::string const& directory);
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

	mstl::string const& identifier() const;
	unsigned numVariations() const;
	unsigned searchMate() const;
	unsigned limitedStrength() const;

	Result probe(unsigned timeout);

	virtual bool startAnalysis(db::Board const& board);
	virtual bool stopAnalysis();
	virtual void analysisStopped() = 0;

	friend class uci::Engine;
	friend class winboard::Engine;

protected:

	Engine();

	virtual void updateLog() = 0;
	virtual void updateInfo() = 0;

	long pid() const;
	void kill();

	// Sends a message to the chess engine
	void send(char const* message);
	void send(mstl::string const& message);

	void addFeature(unsigned feature);

	void addOption(mstl::string const& name,
						mstl::string const& type,
						mstl::string const& dflt,
						mstl::string const& var,
						mstl::string const& max);

	void setScore(int score);			// centi-pawns from white's perspective
	void setMate(int numHalfMoves);	// number of half moves from white's prespective
	void setDepth(unsigned depth);	// search depth
	void setTime(double time);			// search time in seconds (.e.g. 10.28 seconds)
	void setNodes(unsigned nodes);	// nodes searched

	void setBestMove(db::Move const& move);
	void setPonder(db::Move const& move);
	void setVariation(db::MoveList const& moves, unsigned no);
	void setIdentifier(mstl::string const& name);
	void resetInfo();

	void log(mstl::string const& msg);
	void error(mstl::string const& msg);

private:

	struct Option { mstl::string s[5]; };

	typedef mstl::list<Option> Options;
	typedef mstl::list<db::MoveList> Variations;

	class Process;
	friend class Process;

	void readyRead();
	void exited();

	Concrete*		m_engine;
	mstl::string	m_name;
	mstl::string	m_command;
	mstl::string	m_directory;
	mstl::string	m_identifier;
	Variations		m_variations;
	unsigned			m_numVariations;
	unsigned			m_searchMate;
	unsigned			m_limitedStrength;
	unsigned			m_features;
	db::Move			m_bestMove;
	db::Move			m_ponder;
	int				m_score;
	int				m_mate;
	unsigned			m_depth;
	double			m_time;
	unsigned			m_nodes;
	bool				m_active;
	bool				m_analyzing;
	bool				m_probe;
	Process*			m_process;
	mstl::ostream*	m_logStream;
	Options			m_options;
};

} // namespace app

#include "app_engine.ipp"

#endif // _app_engine_included

// vi:set ts=3 sw=3:
