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

namespace app {

inline View::UpdateMode View::gameUpdateMode() const			{ return m_gameUpdateMode; }
inline View::UpdateMode View::playerUpdateMode() const		{ return m_playerUpdateMode; }
inline View::UpdateMode View::eventUpdateMode() const			{ return m_eventUpdateMode; }
inline View::UpdateMode View::siteUpdateMode() const			{ return m_siteUpdateMode; }
inline View::UpdateMode View::annotatorUpdateMode() const	{ return m_annotatorUpdateMode; }

inline unsigned View::countGames() const		{ return m_gameFilter.count(); }
inline unsigned View::totalGames() const		{ return m_gameFilter.size(); }
inline unsigned View::countPlayers() const	{ return m_playerFilter.count(); }
inline unsigned View::countEvents() const		{ return m_eventFilter.count(); }
inline unsigned View::countSites() const		{ return m_siteFilter.count(); }
inline unsigned View::totalPlayers() const	{ return m_playerFilter.size(); }
inline unsigned View::totalEvents() const		{ return m_eventFilter.size(); }

inline db::Filter const& View::gameFilter() const		{ return m_gameFilter; }
inline db::Selector const& View::gameSelector() const	{ return m_gameSelector; }
inline Application const& View::application() const	{ return m_app; }
inline db::Database const& View::database() const		{ return m_db; }

} // namespace db

// vi:set ts=3 sw=3:
