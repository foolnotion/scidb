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

inline View::UpdateMode View::updateMode(db::table::Type type) const		{ return m_updateMode[type]; }
inline db::Filter const& View::filter(db::table::Type type) const			{ return m_filter[type]; }
inline db::Selector const& View::selector(db::table::Type type) const	{ return m_selector[type]; }
inline Application const& View::application() const							{ return m_app; }
inline db::Database const& View::database() const								{ return m_db; }

} // namespace db

// vi:set ts=3 sw=3:
