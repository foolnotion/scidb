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

inline bool Cursor::isOpen() const					{ return m_db; }
inline bool Cursor::isClosed() const				{ return m_db == 0; }
inline bool Cursor::isActive() const				{ return m_isActive; }
inline bool Cursor::isReferenceBase() const		{ return m_isRefBase; }
inline bool Cursor::hasTreeView() const			{ return m_treeView != -1; }

inline int Cursor::treeViewIdentifier() const			{ return m_treeView; }
inline unsigned Cursor::maxViewNumber() const			{ return m_viewList.size() - 1; }
inline Cursor::SubscriberP Cursor::subscriber() const	{ return m_subscriber; }
inline MultiCursor const& Cursor::multiCursor() const	{ return m_cursor; }
inline MultiCursor& Cursor::multiCursor()					{ return m_cursor; }

inline void Cursor::setReferenceBase(bool flag)	{ m_isRefBase = flag; }
inline void Cursor::setActive(bool flag)			{ m_isActive = flag; }


inline
db::Database const&
Cursor::database() const
{
	M_REQUIRE(isOpen());
	return *m_db;
}


inline
db::Database&
Cursor::databaseObject()
{
	M_REQUIRE(isOpen());
	return *m_db;
}


inline
db::Database&
Cursor::base()
{
	M_REQUIRE(isOpen());
	return *m_db;
}


inline
bool
Cursor::isValidView(unsigned view) const
{
	return view == BaseView || view <= maxViewNumber();
}


inline View const&
Cursor::view() const
{
	M_REQUIRE(isViewOpen(0));
	return *m_viewList[1];
}


inline View&
Cursor::view()
{
	M_REQUIRE(isViewOpen(0));
	return *m_viewList[1];
}


inline
View const&
Cursor::view(unsigned id) const
{
	M_REQUIRE(isViewOpen(id));
	return *m_viewList[id + 1];
}


inline
View&
Cursor::view(unsigned id)
{
	M_REQUIRE(isViewOpen(id));
	return *m_viewList[id + 1];
}


inline
View const&
Cursor::treeView() const
{
	M_REQUIRE(hasTreeView());
	M_REQUIRE(isViewOpen(treeViewIdentifier()));

	return *m_viewList[m_treeView + 1];
}


inline
View&
Cursor::treeView()
{
	M_REQUIRE(hasTreeView());
	M_REQUIRE(isViewOpen(treeViewIdentifier()));

	return *m_viewList[m_treeView + 1];
}


inline
void
Cursor::setSubscriber(SubscriberP subscriber)
{
	m_subscriber = subscriber;
}

} // namespace app

// vi:set ts=3 sw=3:
