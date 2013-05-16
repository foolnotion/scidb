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

#include "m_assert.h"

namespace app {

inline unsigned Application::countBases() const			{ return m_cursorMap.size(); }
inline unsigned Application::countGames() const			{ return m_gameMap.size(); }
inline unsigned Application::countEngines() const		{ return m_numEngines; }
inline unsigned Application::maxEngineId() const		{ return m_engineList.size(); }

inline bool Application::haveCurrentGame() const		{ return m_currentPosition != InvalidPosition; }
inline bool Application::haveCurrentBase() const		{ return m_current; }
inline bool Application::haveReferenceBase() const		{ return m_referenceBase; }
inline bool Application::switchReferenceBase() const	{ return m_switchReference; }
inline bool Application::hasInstance()						{ return m_instance; }
inline bool Application::isClosed() const					{ return m_isClosed; }

inline Cursor const& Application::scratchBase() const	{ return cursor(scratchbaseName()); }
inline Cursor& Application::scratchBase()					{ return cursor(scratchbaseName()); }
inline Cursor const& Application::clipBase() const		{ return cursor(clipbaseName()); }
inline Cursor& Application::clipBase()						{ return cursor(clipbaseName()); }

inline Application::Subscriber* Application::subscriber() const	{ return m_subscriber.get(); }
inline unsigned Application::currentPosition() const					{ return m_currentPosition; }
inline db::Tree const* Application::currentTree() const				{ return m_currentTree.get(); }
inline mstl::ostream* Application::engineLog() const					{ return m_engineLog; }
inline sys::Thread& Application::treeThread()							{ return m_treeThread; }

inline void Application::setSwitchReferenceBase(bool flag)			{ m_switchReference = flag; }
inline void Application::setReferenceBase(Cursor* cursor)			{ setReferenceBase(cursor, true); }
inline void Application::freezeTree(bool flag)							{ m_treeIsFrozen = flag; }

inline uint32_t Application::rand32() const				{ return m_rand.rand32(); }
inline uint32_t Application::rand32(uint32_t n) const	{ return m_rand.rand32(n); }


inline
Cursor&
Application::referenceBase()
{
	M_REQUIRE(haveReferenceBase());
	return *m_referenceBase;
}


inline
Cursor const&
Application::referenceBase() const
{
	M_REQUIRE(haveReferenceBase());
	return *m_referenceBase;
}


inline
Cursor const&
Application::cursor() const
{
	M_REQUIRE(haveCurrentBase());
	return *m_current;
}


inline
Cursor&
Application::cursor()
{
	M_REQUIRE(haveCurrentBase());
	return *m_current;
}


inline
Cursor const&
Application::cursor(mstl::string const& name) const
{
	M_REQUIRE(name ? contains(name) : haveCurrentBase());
	return *(name.empty() ? m_current : findBase(name));
}


inline
Cursor const&
Application::cursor(mstl::string const& name, db::variant::Type variant) const
{
	M_REQUIRE(contains(name, variant));
	return *findBase(name, variant);
}


inline
Cursor&
Application::cursor(mstl::string const& name)
{
	M_REQUIRE(name.empty() ? haveCurrentBase() : contains(name));
	return *(name.empty() ? m_current : findBase(name));
}


inline
Cursor&
Application::cursor(mstl::string const& name, db::variant::Type variant)
{
	M_REQUIRE(contains(name, variant));
	return *findBase(name, variant);
}


inline
Cursor const&
Application::cursor(char const* name) const
{
	M_REQUIRE(name && *name ? contains(name) : haveCurrentBase());
	return *(!name || !*name ? m_current : findBase(name));
}


inline
Cursor&
Application::cursor(char const* name)
{
	M_REQUIRE(name && *name ? contains(name) : haveCurrentBase());
	return *(name == 0 || *name == '\0' ? m_current : findBase(name));
}


inline
Engine*
Application::engine(unsigned id) const
{
	M_REQUIRE(id < maxEngineId());
	M_REQUIRE(engineExists(id));

	return m_engineList[id];
}

} // namespace app

// vi:set ts=3 sw=3:
