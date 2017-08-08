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

#ifndef _app_uci_engine_included
#define _app_uci_engine_included

#include "app_engine.h"

#include "db_board.h"
#include "db_move.h"
#include "db_move_list.h"

#include "m_string.h"

namespace app {
namespace uci {

class Engine : public app::Engine::Concrete
{
public:

	Engine();

	bool startAnalysis(bool isNew) override;
	bool stopAnalysis(bool restartIsPending) override;
	bool continueAnalysis() override;

	bool isAnalyzing() const override;
	bool isReady() const override;

	using Concrete::stopAnalysis;

protected:

	void protocolStart(bool isProbing) override;
	void protocolEnd() override;
	void stimulate() override;
	void sendNumberOfVariations() override;
	void clearHash() override;
	void sendHashSize() override;
	void sendThreads() override;
	void sendSkillLevel() override;
//	void sendPlayingStyle() override;
	void sendPondering() override;
	void sendStrength() override;
	void sendOptions() override;
	void invokeOption(mstl::string const& name) override;
	void processMessage(mstl::string const& message) override;
	void doMove(db::Move const& lastMove) override;

	Result probeResult() const override;
	unsigned probeTimeout() const override;

private:

	enum State { None, Start, Stop, Pause };

	bool whiteToMove() const;

	void parseBestMove(char const* msg);
	void parseInfo(char const* msg);
	void parseOption(char const* msg);
	char const* parseMoveList(char const* s, db::Board& board, db::MoveList& moves);
	void setupPosition(db::Board const& board);
	void sendOption(mstl::string const& name, mstl::string const& value = mstl::string::empty_string);

	db::Move parseCurrentMove(char const* s);

	mstl::string		m_position;
	mstl::string		m_waitingOn;
	mstl::string		m_name;
	mstl::string		m_value;
	mstl::string		m_threads;
//	mstl::string		m_playingStyle;
	mstl::string		m_minThreads;
	mstl::string		m_maxThreads;
	mstl::string		m_clearHash;
	mstl::string		m_skillLevel;
	State					m_state;
	db::variant::Type	m_variant;
	bool					m_uciok;
	bool					m_isReady;
	bool					m_hasMultiPV;
	bool					m_hasAnalyseMode;
	bool					m_hasOwnBook;
	bool					m_hasShowCurrLine;
	bool					m_hasShowRefutations;
	bool					m_isAnalyzing;
	bool					m_isNewGame;
	bool					m_startAnalyzeIsPending;
	bool					m_stopAnalyzeIsPending;
	bool					m_isChess960;
	bool					m_sendAnalyseMode;
	bool					m_usedAnalyseModeBefore;
	bool					m_clearHashOnTheFly;
	bool					m_uciAlreadySent;
};

} // namespace uci
} // namespace app

#endif // _app_uci_engine_included

// vi:set ts=3 sw=3:
