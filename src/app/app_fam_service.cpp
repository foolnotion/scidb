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

#include "app_fam_service.h"

#include "sys_fam.h"

#include "m_map.h"
#include "m_string.h"

using namespace app;


FAMService::FileAlterationMonitor* FAMService::m_fam = 0;


struct FAMService::FileAlterationMonitor : public sys::FileAlterationMonitor
{
	void signalId(unsigned id, mstl::string const& path) override;
	void signalChanged(unsigned id, mstl::string const& path) override;
	void signalDeleted(unsigned id, mstl::string const& path) override;
	void signalCreated(unsigned id, mstl::string const& path) override;

	typedef mstl::map<mstl::string, FAMService::Callback*> Map;

	Map m_map;
};


void
FAMService::FileAlterationMonitor::signalId(unsigned id, mstl::string const& path)
{
	Map::iterator i = m_map.find(path);
	if (i != m_map.end())
		(*i).second->signalId(id, path);
}


void
FAMService::FileAlterationMonitor::signalChanged(unsigned id, mstl::string const& path)
{
	Map::iterator i = m_map.find(path);
	if (i != m_map.end())
		(*i).second->signalChanged(id, path);
}


void
FAMService::FileAlterationMonitor::signalDeleted(unsigned id, mstl::string const& path)
{
	Map::iterator i = m_map.find(path);
	if (i != m_map.end())
		(*i).second->signalDeleted(id, path);
}


void
FAMService::FileAlterationMonitor::signalCreated(unsigned id, mstl::string const& path)
{
	Map::iterator i = m_map.find(path);
	if (i != m_map.end())
		(*i).second->signalCreated(id, path);
}


FAMService::Callback::~Callback() {}
void FAMService::Callback::signalId(unsigned, mstl::string const&) {}
void FAMService::Callback::signalChanged(unsigned, mstl::string const&) {}
void FAMService::Callback::signalDeleted(unsigned, mstl::string const&) {}
void FAMService::Callback::signalCreated(unsigned, mstl::string const&) {}


void
FAMService::hook(mstl::string const& path, Callback& callback)
{
	if (m_fam == 0)
	{
		if (FileAlterationMonitor::isSupported())
			m_fam = new FileAlterationMonitor;
	}

	if (m_fam)
	{
		m_fam->add(path);
		m_fam->m_map[path] = &callback;
	}
}


void
FAMService::unhook(mstl::string const& path)
{
	if (m_fam)
	{
		m_fam->remove(path);
		m_fam->m_map.erase(path);

		if (m_fam->m_map.empty())
		{
			delete m_fam;
			m_fam = 0;
		}
	}
}

// vi:set ts=3 sw=3:
