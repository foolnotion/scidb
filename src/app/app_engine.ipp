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

namespace app {

inline bool Engine::Concrete::isActive() const					{ return m_engine->isActive(); }
inline bool Engine::Concrete::isAnalyzing() const				{ return m_engine->isAnalyzing(); }
inline bool Engine::Concrete::isProbing() const					{ return m_engine->isProbing(); }

inline bool Engine::startAnalysis(db::Board const& board)	{ return m_engine->startAnalysis(board); }
inline bool Engine::stopAnalysis()									{ return m_engine->stopAnalysis(); }

inline unsigned Engine::Concrete::maxMultiPV() const			{ return m_engine->maxMultiPV(); }
inline unsigned Engine::Concrete::numVariations() const		{ return m_engine->numVariations(); }
inline unsigned Engine::Concrete::searchMate() const			{ return m_engine->searchMate(); }
inline unsigned Engine::Concrete::limitedStrength() const	{ return m_engine->limitedStrength(); }
inline long Engine::Concrete::pid() const							{ return m_engine->pid(); }

inline void Engine::Concrete::send(mstl::string const& message)	{ m_engine->send(message); }
inline void Engine::Concrete::deactivate()								{ m_engine->deactivate(); }
inline void Engine::Concrete::addFeature(unsigned feature)			{ m_engine->addFeature(feature); }

inline void Engine::Concrete::setBestMove(db::Move const& move)	{ m_engine->setBestMove(move); }
inline void Engine::Concrete::setPonder(db::Move const& move)		{ m_engine->setPonder(move); }
inline void Engine::Concrete::setScore(int score)						{ m_engine->setScore(score); }
inline void Engine::Concrete::setMate(int numHalfMoves)				{ m_engine->setMate(numHalfMoves); }
inline void Engine::Concrete::setDepth(unsigned depth)				{ m_engine->setDepth(depth); }
inline void Engine::Concrete::setTime(double time)						{ m_engine->setTime(time); }
inline void Engine::Concrete::setNodes(unsigned nodes)				{ m_engine->setNodes(nodes); }

inline void Engine::Concrete::updateInfo()								{ m_engine->updateInfo(); }
inline void Engine::Concrete::resetInfo()									{ m_engine->resetInfo(); }

inline void Engine::Concrete::log(mstl::string const& msg)			{ m_engine->log(msg); }
inline void Engine::Concrete::error(mstl::string const& msg)		{ m_engine->error(msg); }


inline
void
Engine::doMove(db::Game const& game, db::Move const& lastMove)
{
	m_engine->doMove(game, lastMove);
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
void Engine::Concrete::setIdentifier(mstl::string const& name)
{
	m_engine->setIdentifier(name);
}


inline
void Engine::Concrete::setAuthor(mstl::string const& name)
{
	m_engine->setAuthor(name);
}


inline
void Engine::Concrete::setMaxMultiPV(unsigned n)
{
	m_engine->setMaxMultiPV(n);
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


inline bool Engine::hasFeature(unsigned feature) const 		{ return m_features & feature; }

inline mstl::string const& Engine::identifier() const			{ return m_identifier; }
inline mstl::string const& Engine::author() const				{ return m_author; }
inline unsigned Engine::limitedStrength() const					{ return m_limitedStrength; }
inline unsigned Engine::maxMultiPV() const						{ return m_maxMultiPV; }
inline unsigned Engine::numVariations() const					{ return m_numVariations; }
inline unsigned Engine::searchMate() const						{ return m_searchMate; }
inline Engine::Concrete* Engine::concrete()						{ return m_engine; }

inline void Engine::setScore(int score)							{ m_score = score; }
inline void Engine::setDepth(unsigned depth)						{ m_depth = depth; }
inline void Engine::setTime(double time)							{ m_time = time; }
inline void Engine::setNodes(unsigned nodes)						{ m_nodes = nodes; }
inline void Engine::setIdentifier(mstl::string const& name)	{ m_identifier = name; }
inline void Engine::setAuthor(mstl::string const& name)		{ m_author = name; }
inline void Engine::setMaxMultiPV(unsigned n)					{ m_maxMultiPV = n; }
inline void Engine::setBestMove(db::Move const& move)			{ m_bestMove = move; }
inline void Engine::setPonder(db::Move const& move)			{ m_ponder = move; }
inline void Engine::setLimitedStrength(unsigned elo)			{ m_limitedStrength = elo; }
inline void Engine::addFeature(unsigned feature)				{ m_features |= feature; }


inline
void
Engine::setMate(int numHalfMoves)
{
	if ((m_mate = numHalfMoves))
		m_score = mstl::signum(numHalfMoves)*32000;
}

} // namespace app

// vi:set ts=3 sw=3:
