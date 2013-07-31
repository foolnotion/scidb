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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "app_cql_engine.h"

#include "db_game.h"

#include "sys_thread.h"

#include "m_assert.h"

using namespace ::app::cql;
using namespace ::db;


struct Engine::MyEngine : public app::Engine
{
	MyEngine(app::Engine::Protocol protocol,
				mstl::string const& command,
				mstl::string const& directory)
		:app::Engine(protocol, command, directory)
		,m_isReady(false)
	{
	}

	void engineIsReady() override { m_isReady = true; }
	void engineSignal(Signal signal) override {}

	void clearInfo() override {}
	void updateState(State state) override {}
	void updateError(Error code) override {}
	void updateInfo(db::color::ID sideToMove, db::board::Status state) override {}
	void updatePvInfo(unsigned line) override { m_receiver->setScore(score(line)/100.0, mate(line)); }

	void setReceiver(app::cql::Engine* receiver) { m_receiver = receiver; }

	bool 					m_isReady;
	app::cql::Engine*	m_receiver;
};


Engine::Creator::Creator(	app::Engine::Protocol protocol,
									mstl::string const& command,
									mstl::string const& directory,
									unsigned hashSize,
									unsigned numThreads)
	:m_protocol(protocol)
	,m_command(command)
	,m_directory(directory)
	,m_hashSize(hashSize)
	,m_numThreads(numThreads)
{
}


Engine*
Engine::Creator::createEngine()
{
	M_REQUIRE(sys::Thread::insideMainThread());

	MyEngine* engine = new MyEngine(m_protocol, m_command, m_directory);

	if (m_hashSize)
		engine->changeHashSize(m_hashSize);
	if (m_numThreads)
		engine->changeThreads(m_numThreads);

	engine->activate();

	Engine* e = new Engine(engine);
	engine->setReceiver(e);
	return e;
}


void
Engine::Creator::destroyEngine(Engine* engine) override
{
	delete engine;
}


Engine::Variation::Variation() :length(0) {}
Engine::Variation::Variation(db::Move const& m) :move(m), length(0) {}


Engine::Engine(::app::Engine* impl)
	:m_impl(impl)
	,m_currentThread(0)
	,m_game(0)
	,m_score(0.0)
	,m_mate(0)
{
}


Engine::~Engine() { delete m_impl; delete m_game; }

sys::Thread* Engine::thread() const { return m_currentThread; }


void
Engine::setupThread(sys::Thread* currentThread)
{
	M_REQUIRE(currentThread);
	m_currentThread = currentThread;
}


void
Engine::newGame(variant::Type variant)
{
	delete m_game;
	m_game = new Game;
	m_game->finishLoad(variant);
	m_game->setUndoLevel(0, false);
	m_variationStack.clear();
	m_variationStack.push();
}


void
Engine::setup(::db::Board const& board)
{
	M_ASSERT(m_game);
	M_ASSERT(m_game->isEmpty());

	m_game->clear(&board);
}


void
Engine::move(::db::Move const& move)
{
	m_game->addMove(move);
	m_game->forward();
	++m_variationStack.top().length;
}


void
Engine::enterVariation()
{
	m_variationStack.push(Variation(m_game->currentMove()));
	m_game->truncateVariation(move::Ante);
}


void
Engine::leaveVariation()
{
	M_ASSERT(m_variationStack.size() > 1);

	m_game->backward(m_variationStack.top().length);
	m_game->truncateVariation(move::Post);
	m_game->addMove(m_variationStack.top().move);
	m_game->forward();
	m_variationStack.pop();
}


void
Engine::setupMode(Mode mode, unsigned arg)
{
	switch (mode)
	{
		case Depth:		m_impl->setSearchDepth(arg); break;
		case MoveTime:	m_impl->setSearchTime(arg); break;
	}
}


bool
Engine::searchMate(Mode mode, unsigned arg)
{
	M_REQUIRE(thread());

	setupMode(mode, arg);
	m_impl->startAnalysis(m_game);
	m_currentThread->sleep();

	return m_mate != 0;
}


float
Engine::evaluate(Mode mode, unsigned arg)
{
	M_REQUIRE(thread());

	setupMode(mode, arg);
	m_impl->startAnalysis(m_game);
	m_currentThread->sleep();

	return m_score;
}


float
Engine::evaluate(Mode mode, unsigned arg, ::db::Move const& move)
{
	M_REQUIRE(thread());

	setupMode(mode, arg);
	m_game->addMove(move);
	m_game->forward();
	m_impl->startAnalysis(m_game);
	m_currentThread->sleep();
	m_game->truncateVariation(move::Ante);

	return m_score;
}


void
Engine::setScore(float score, int mate)
{
	m_score = score;
	m_mate = mate;
	m_currentThread->awake();
}

// vi:set ts=3 sw=3:
