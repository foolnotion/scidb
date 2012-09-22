// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "m_utility.h"
#include "m_assert.h"

namespace app {

inline bool Engine::Concrete::isActive() const					{ return m_engine->isActive(); }
inline bool Engine::Concrete::isAnalyzing() const				{ return m_engine->isAnalyzing(); }
inline bool Engine::Concrete::isProbing() const					{ return m_engine->isProbing(); }

inline unsigned Engine::Concrete::maxMultiPV() const			{ return m_engine->maxMultiPV(); }
inline unsigned Engine::Concrete::numVariations() const		{ return m_engine->numVariations(); }
inline unsigned Engine::Concrete::hashSize() const				{ return m_engine->hashSize(); }
inline unsigned Engine::Concrete::searchMate() const			{ return m_engine->searchMate(); }
inline unsigned Engine::Concrete::limitedStrength() const	{ return m_engine->limitedStrength(); }
inline long Engine::Concrete::pid() const							{ return m_engine->pid(); }

inline void Engine::Concrete::send(mstl::string const& message)	{ m_engine->send(message); }
inline void Engine::Concrete::deactivate()								{ m_engine->deactivate(); }
inline void Engine::Concrete::addFeature(unsigned feature)			{ m_engine->addFeature(feature); }
inline void Engine::Concrete::engineIsReady()							{ m_engine->engineIsReady(); }

inline void Engine::Concrete::setBestMove(db::Move const& move)	{ m_engine->setBestMove(move); }
inline void Engine::Concrete::setPonder(db::Move const& move)		{ m_engine->setPonder(move); }
inline void Engine::Concrete::setScore(int score)						{ m_engine->setScore(score); }
inline void Engine::Concrete::setMate(int numHalfMoves)				{ m_engine->setMate(numHalfMoves); }
inline void Engine::Concrete::setDepth(unsigned depth)				{ m_engine->setDepth(depth); }
inline void Engine::Concrete::setSelectiveDepth(unsigned depth)	{ m_engine->setSelectiveDepth(depth); }
inline void Engine::Concrete::setTime(double time)						{ m_engine->setTime(time); }
inline void Engine::Concrete::setNodes(unsigned nodes)				{ m_engine->setNodes(nodes); }

inline void Engine::Concrete::updatePvInfo()								{ m_engine->updatePvInfo(); }
inline void Engine::Concrete::updateCheckMateInfo()					{ m_engine->updateCheckMateInfo(); }
inline void Engine::Concrete::updateStaleMateInfo()					{ m_engine->updateStaleMateInfo(); }
inline void Engine::Concrete::updateCurrMove()							{ m_engine->updateCurrMove(); }
inline void Engine::Concrete::updateCurrLine()							{ m_engine->updateCurrLine(); }
inline void Engine::Concrete::updateBestMove()							{ m_engine->updateBestMove(); }
inline void Engine::Concrete::updateDepthInfo()							{ m_engine->updateDepthInfo(); }
inline void Engine::Concrete::updateTimeInfo()							{ m_engine->updateTimeInfo(); }
inline void Engine::Concrete::updateHashFullInfo()						{ m_engine->updateHashFullInfo(); }
inline void Engine::Concrete::resetInfo()									{ m_engine->resetInfo(); }

inline void Engine::Concrete::log(mstl::string const& msg)			{ m_engine->log(msg); }
inline void Engine::Concrete::error(mstl::string const& msg)		{ m_engine->error(msg); }


inline void Engine::pause()	{ m_engine->pause(); }
inline void Engine::resume()	{ m_engine->resume(); }

inline bool Engine::protocolAlreadyStarted() const		{ return m_protocol; }
inline Engine::Options const& Engine::options() const	{ return m_options; }


inline
bool
Engine::Concrete::detectShortName(mstl::string const& str)
{
	return m_engine->detectShortName(str);
}


inline
bool
Engine::Concrete::detectIdentifier(mstl::string const& str)
{
	return m_engine->detectIdentifier(str);
}


inline
bool
Engine::Concrete::detectUrl(mstl::string const& str)
{
	return m_engine->detectUrl(str);
}


inline
bool
Engine::Concrete::detectEmail(mstl::string const& str)
{
	return m_engine->detectEmail(str);
}


inline
Engine::Options const&
Engine::Concrete::options() const
{
	return m_engine->options();
}


inline
db::Game const*
Engine::Concrete::currentGame() const
{
	return m_engine->currentGame();
}


inline
db::Game const*
Engine::currentGame() const
{
	return m_game;
}


inline
bool
Engine::Concrete::hasFeature(unsigned feature) const
{
	return m_engine->hasFeature(feature);
}


inline
void
Engine::Concrete::setVariation(db::MoveList const& moves, unsigned no)
{
	m_engine->setVariation(moves, no);
}


inline
void
Engine::Concrete::setCurrentMove(unsigned number, db::Move const& move)
{
	m_engine->setCurrentMove(number, move);
}


inline
void
Engine::Concrete::setShortName(mstl::string const& name)
{
	m_engine->setShortName(name);
}



inline
void
Engine::Concrete::setIdentifier(mstl::string const& name)
{
	m_engine->setIdentifier(name);
}


inline
void
Engine::Concrete::setAuthor(mstl::string const& name)
{
	m_engine->setAuthor(name);
}


inline
void
Engine::Concrete::setUrl(mstl::string const& address)
{
	m_engine->setUrl(address);
}


inline
void
Engine::Concrete::setEmail(mstl::string const& address)
{
	m_engine->setEmail(address);
}


inline
void
Engine::Concrete::setElo(unsigned n)
{
	m_engine->setElo(n);
}


inline
void
Engine::Concrete::setEloRange(unsigned minElo, unsigned maxElo)
{
	m_engine->setEloRange(minElo, maxElo);
}


inline
void
Engine::Concrete::setSkillLevel(unsigned level)
{
	m_engine->setSkillLevel(level);
}


inline
void
Engine::Concrete::setSkillLevelRange(unsigned minLevel, unsigned maxLevel)
{
	m_engine->setSkillLevelRange(minLevel, maxLevel);
}


inline
void
Engine::Concrete::setMaxMultiPV(unsigned size)
{
	m_engine->setMaxMultiPV(size);
}


inline
void
Engine::Concrete::setHashSize(unsigned size)
{
	m_engine->setHashSize(size);
}


inline
void
Engine::Concrete::setHashRange(unsigned minSize, unsigned maxSize)
{
	m_engine->setHashRange(minSize, maxSize);
}


inline
void
Engine::Concrete::setThreads(unsigned num)
{
	m_engine->setThreads(num);
}


inline
void
Engine::Concrete::setThreadRange(unsigned minThreads, unsigned maxThreads)
{
	m_engine->setThreadRange(minThreads, maxThreads);
}


inline
void
Engine::Concrete::setPlayingStyles(mstl::string const& styles)
{
	m_engine->setPlayingStyles(styles);
}


inline
void
Engine::Concrete::addOption(	mstl::string const& name,
										mstl::string const& type,
										mstl::string const& dflt,
										mstl::string const& var,
										mstl::string const& max)
{
	m_engine->addOption(name, type, dflt, var, max);
}


inline bool Engine::isAnalyzing() const							{ return m_engine->isAnalyzing(); }
inline bool Engine::hasFeature(unsigned feature) const 		{ return m_features & feature; }
inline bool Engine::isProbing() const								{ return m_probe; }
inline bool Engine::isProbingAnalyze() const						{ return m_probe; }

inline int Engine::score() const										{ return m_score; }
inline int Engine::mate() const										{ return m_mate; }
inline unsigned Engine::depth() const								{ return m_depth; }
inline unsigned Engine::selectiveDepth() const					{ return m_selDepth; }
inline double Engine::time() const									{ return m_time; }
inline unsigned Engine::nodes() const								{ return m_nodes; }
inline db::Board const& Engine::currentBoard() const			{ return m_engine->currentBoard(); }
inline db::Move const& Engine::bestMove() const					{ return m_bestMove; }
inline unsigned Engine::currentMoveNumber() const				{ return m_currMoveNumber; }
inline db::Move const& Engine::currentMove() const				{ return m_currMove; }
inline int Engine::exitStatus() const								{ return m_exitStatus; }
inline mstl::string const& Engine::identifier() const			{ return m_identifier; }
inline mstl::string const& Engine::shortName() const			{ return m_shortName; }
inline mstl::string const& Engine::author() const				{ return m_author; }
inline mstl::string const& Engine::email() const				{ return m_email; }
inline mstl::string const& Engine::url() const					{ return m_url; }
inline unsigned Engine::elo() const									{ return m_elo; }
inline unsigned Engine::minElo() const								{ return m_minElo; }
inline unsigned Engine::maxElo() const								{ return m_maxElo; }
inline unsigned Engine::skillLevel() const						{ return m_skillLevel; }
inline unsigned Engine::minSkillLevel() const					{ return m_minSkillLevel; }
inline unsigned Engine::maxSkillLevel() const					{ return m_maxSkillLevel; }
inline unsigned Engine::limitedStrength() const					{ return m_limitedStrength; }
inline mstl::string const& Engine::playingStyles() const		{ return m_playingStyles; }
inline unsigned Engine::maxMultiPV() const						{ return m_maxMultiPV; }
inline unsigned Engine::numVariations() const					{ return m_numVariations; }
inline unsigned Engine::hashSize() const							{ return m_hashSize; }
inline unsigned Engine::minHashSize() const						{ return m_minHashSize; }
inline unsigned Engine::maxHashSize() const						{ return m_maxHashSize; }
inline unsigned Engine::numThreads() const						{ return m_numThreads; }
inline unsigned Engine::minThreads() const						{ return m_minThreads; }
inline unsigned Engine::maxThreads() const						{ return m_maxThreads; }
inline unsigned Engine::searchMate() const						{ return m_searchMate; }
inline Engine::Concrete* Engine::concrete()						{ return m_engine; }

inline void Engine::setScore(int score)							{ m_score = score; }
inline void Engine::setDepth(unsigned depth)						{ m_depth = depth; }
inline void Engine::setSelectiveDepth(unsigned depth)			{ m_selDepth = depth; }
inline void Engine::setTime(double time)							{ m_time = time; }
inline void Engine::setNodes(unsigned nodes)						{ m_nodes = nodes; }
inline void Engine::setAuthor(mstl::string const& name)		{ m_author = name; }
inline void Engine::setElo(unsigned elo)							{ m_elo = elo; }
inline void Engine::setPonder(db::Move const& move)			{ m_ponder = move; }
inline void Engine::setLog(mstl::ostream* stream)				{ m_logStream = stream; }
inline void Engine::setHashSize(unsigned size)					{ m_hashSize = size; }
inline void Engine::setThreads(unsigned num)						{ m_numThreads = num; }


inline
void
Engine::setCurrentMove(unsigned number, db::Move const& move)
{
	m_currMoveNumber = number;
	m_currMove = move;
}


inline
db::MoveList const&
Engine::variation(unsigned no) const
{
	M_REQUIRE(no < numVariations());
	return m_variations[no];
}


inline
void
Engine::setMate(int numHalfMoves)
{
	if ((m_mate = numHalfMoves))
		m_score = mstl::signum(numHalfMoves)*32000;
}


inline
bool
Engine::detectShortName(mstl::string const& str)
{
	return detectShortName(str, false);
}


inline
bool
Engine::detectIdentifier(mstl::string const& str)
{
	return detectShortName(str, true);
}

} // namespace app

// vi:set ts=3 sw=3:
