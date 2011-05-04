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

#include "m_assert.h"

namespace app {

inline bool Cursor::isOpen() const					{ return m_db; }
inline bool Cursor::isClosed() const				{ return m_db == 0; }
inline bool Cursor::isReferenceBase() const		{ return m_isRefBase; }
inline bool Cursor::hasTreeView() const			{ return m_treeView != -1; }

inline db::Database const& Cursor::database() const	{ return *m_db; }
inline db::Database& Cursor::base()							{ return *m_db; }
inline int Cursor::treeViewIdentifier() const			{ return m_treeView; }
inline unsigned Cursor::maxViewNumber() const			{ return m_viewList.size(); }

inline void Cursor::setReferenceBase(bool flag)	{ m_isRefBase = flag; }


inline View const&
Cursor::view() const
{
	M_REQUIRE(isViewOpen(0));
	return *m_viewList[0];
}


inline View&
Cursor::view()
{
	M_REQUIRE(isViewOpen(0));
	return *m_viewList[0];
}


inline
View const&
Cursor::view(unsigned id) const
{
	M_REQUIRE(isViewOpen(id));
	return *m_viewList[id];
}


inline
View&
Cursor::view(unsigned id)
{
	M_REQUIRE(isViewOpen(id));
	return *m_viewList[id];
}


inline
View const&
Cursor::treeView() const
{
	M_REQUIRE(hasTreeView());
	M_REQUIRE(isViewOpen(treeViewIdentifier()));

	return *m_viewList[m_treeView];
}


inline
View&
Cursor::treeView()
{
	M_REQUIRE(hasTreeView());
	M_REQUIRE(isViewOpen(treeViewIdentifier()));

	return *m_viewList[m_treeView];
}

} // namespace app

// vi:set ts=3 sw=3:
