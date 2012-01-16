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

#include "m_assert.h"

namespace app {

inline unsigned Application::countBases() const			{ return m_cursorMap.size(); }
inline unsigned Application::countGames() const			{ return m_gameMap.size(); }

inline bool Application::haveCurrentGame() const		{ return m_position != InvalidPosition; }
inline bool Application::haveCurrentBase() const		{ return m_current; }
inline bool Application::haveClipbase() const			{ return m_clipBase; }
inline bool Application::haveReferenceBase() const		{ return m_referenceBase; }
inline bool Application::switchReferenceBase() const	{ return m_switchReference; }
inline bool Application::hasInstance()						{ return m_instance; }
inline bool Application::isClosed() const					{ return m_isClosed; }

inline Cursor const& Application::scratchBase() const	{ return *m_scratchBase; }
inline Cursor& Application::scratchBase()					{ return *m_scratchBase; }

inline Application::Subscriber* Application::subscriber() const	{ return m_subscriber.get(); }
inline mstl::string const& Application::clipbaseName()				{ return m_clipbaseName; }
inline mstl::string const& Application::scratchbaseName()			{ return m_scratchbaseName; }
inline unsigned Application::currentPosition() const					{ return m_position; }
inline db::Tree const* Application::currentTree() const				{ return m_currentTree.get(); }

inline void Application::setSwitchReferenceBase(bool flag)			{ m_switchReference = flag; }
inline void Application::setReferenceBase(Cursor* cursor)			{ setReferenceBase(cursor, true); }


inline
Cursor const&
Application::clipBase() const
{
	M_REQUIRE(haveClipbase());
	return *m_clipBase;
}


inline
Cursor&
Application::clipBase()
{
	M_REQUIRE(haveClipbase());
	return *m_clipBase;
}


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
Cursor&
Application::cursor(mstl::string const& name)
{
	M_REQUIRE(name.empty() ? haveCurrentBase() : contains(name));
	return *(name.empty() ? m_current : findBase(name));
}


inline
Cursor const&
Application::cursor(char const* name) const
{
	M_REQUIRE(name && *name ? contains(name) : haveCurrentBase());
	return *(name == 0 || *name == '\0' ? m_current : findBase(name));
}


inline
Cursor&
Application::cursor(char const* name)
{
	M_REQUIRE(name && *name ? contains(name) : haveCurrentBase());
	return *(name == 0 || *name == '\0' ? m_current : findBase(name));
}

} // namespace app

// vi:set ts=3 sw=3:
