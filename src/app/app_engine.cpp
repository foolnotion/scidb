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

#include "app_engine.h"
#include "app_uci_engine.h"
#include "app_winboard_engine.h"

#include "sys_process.h"
#include "sys_timer.h"

#include "u_misc.h"

#include "m_ostream.h"

using namespace app;
using namespace db;
using namespace util::misc::file;


struct Engine::Process : public sys::Process
{
	Process(Engine* engine, mstl::string const& command, mstl::string const& directory);

	void readyRead();
	void exited();

	Engine*	m_engine;
	bool		m_connected;
};


Engine::Process::Process(Engine* engine, mstl::string const& command, mstl::string const& directory)
	:sys::Process(command, directory)
	,m_engine(engine)
	,m_connected(false)
{
}


void
Engine::Process::readyRead()
{
	if (m_connected)
	{
		m_engine->readyRead();
	}
	else
	{
		mstl::string buf;

		while (gets(buf))
			;

		m_engine->concrete()->protocolStart(m_engine->isProbing());
	}
}


void
Engine::Process::exited()
{
	m_engine->exited();
}


Engine::Concrete::~Concrete() throw() {}


Engine::Engine(Protocol protocol,
					mstl::string const& name,
					mstl::string const& command,
					mstl::string const& directory)
	:m_engine(0)
	,m_name(name)
	,m_command(command)
	,m_directory(directory)
	,m_identifier(rootname(basename(command)))
	,m_variations(1, MoveList())
	,m_numVariations(1)
	,m_searchMate(0)
	,m_limitedStrength(0)
	,m_features(0)
	,m_score(0)
	,m_mate(0)
	,m_depth(0)
	,m_time(0.0)
	,m_nodes(0)
	,m_active(false)
	,m_analyzing(false)
	,m_probe(false)
	,m_process(0)
	,m_logStream(0)
{
	switch (protocol)
	{
		case Uci:		m_engine = new uci::Engine; break;
		case WinBoard:	m_engine = new winboard::Engine; break;
	}

	m_engine->m_engine = this;
}


Engine::~Engine() throw()
{
	if (m_process)
	{
		deactivate();
		delete m_process;
	}

	delete m_engine;
}


bool Engine::startAnalysis(db::Board const& board)	{ return m_engine->startAnalysis(board); }
bool Engine::stopAnalysis()								{ return m_engine->stopAnalysis(); }


long
Engine::pid() const
{
	return m_process->pid();
}


void
Engine::kill()
{
	m_active = m_analyzing = false;
	m_process->kill();
}


void
Engine::setLog(mstl::ostream* stream)
{
	m_logStream = stream;
}


bool
Engine::isAlive()
{
	return m_active && m_process->isAlive();
}


bool
Engine::isActive() const
{
	return m_active;
}


bool
Engine::isAnalyzing() const
{
	return m_analyzing;
}


bool
Engine::isProbing() const
{
	return m_probe;
}


void
Engine::activate()
{
	if (!m_active)
		m_process = new Process(this, m_command, m_directory);

}


void
Engine::deactivate()
{
	if (m_active)
		m_engine->protocolEnd();
}


void
Engine::log(mstl::string const& msg)
{
	if (m_logStream && !msg.empty())
	{
		m_logStream->write(" >", 2);
		m_logStream->write(msg, msg.size());
		m_logStream->put('\n');
	}
}


void
Engine::error(mstl::string const& msg)
{
	if (m_logStream)
		log("<ERROR> " + msg);
}


void
Engine::readyRead()
{
	mstl::string line;

	while (m_process->gets(line) > 0)
	{
		line.trim();
		log(line);
		m_engine->processMessage(line);
	}
}


void
Engine::exited()
{
	if (m_active)
	{
		if (m_analyzing)
		{
			m_analyzing = false;
			analysisStopped();
		}

		m_active = false;
	}

	delete m_process;
	m_process = 0;
}


void
Engine::send(mstl::string const& message)
{
	log(message);
	m_process->puts(message);
}


Engine::Result
Engine::probe(unsigned timeout)
{
	Result result = Probe_Failed;

	if (timeout < 2000)
		timeout = 2000;

	m_probe = true;

	sys::Timer timer(timeout);

	try
	{
		activate();

		while (result != Probe_Successfull && !timer.expired())
		{
			timer.doNextEvent();
			result = m_engine->probeResult();
		}
	}
	catch (mstl::exception const& exc)
	{
		deactivate();
		m_active = false;
		m_probe = false;
		throw exc;
	}

	deactivate();
	m_active = false;
	m_probe = false;

	return result;
}


void
Engine::setVariation(db::MoveList const& moves, unsigned no)
{
	M_REQUIRE(no >= 1);
	M_REQUIRE(no <= numVariations());

	m_variations[no] = moves;
}


void
Engine::resetInfo()
{
	m_score = 0;
	m_mate = 0;
	m_depth = 0;
	m_time = 0.0;
	m_nodes = 0;

	for (unsigned i = 0; i < m_variations.size(); ++i)
		m_variations[i].clear();
}


void
Engine::addOption(mstl::string const& name,
						mstl::string const& type,
						mstl::string const& dflt,
						mstl::string const& var,
						mstl::string const& max)
{
	m_options.push_back();

	Option& opt = m_options.back();

	opt.s[0] = name;
	opt.s[1] = type;
	opt.s[2] = dflt;
	opt.s[3] = var;
	opt.s[4] = max;
}

// vi:set ts=3 sw=3:
