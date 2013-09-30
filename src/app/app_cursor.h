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

#ifndef _app_cursor_included
#define _app_cursor_included

#include "app_view.h"

#include "db_common.h"

#include "m_vector.h"
#include "m_ref_counted_ptr.h"
#include "m_ref_counter.h"
#include "m_bitset.h"

namespace mstl { class string; }
namespace util { class Progress; }

namespace db
{
	class Database;
	class Producer;
	class TagSet;
}

namespace app {

class Apllication;
class MultiCursor;
class View;

class Cursor
{
public:

	static unsigned const BaseView = unsigned(-1);

	struct Subscriber : public mstl::ref_counter
	{
		virtual ~Subscriber() throw();
		virtual void close(mstl::string const& name, ::db::variant::Type variant, unsigned view) = 0;
	};

	typedef mstl::ref_counted_ptr<Subscriber> SubscriberP;

	Cursor(MultiCursor& cursor, db::Database* database);
	~Cursor();

	bool isOpen() const;
	bool isClosed() const;
	bool isEmpty() const;
	bool isReadonly() const;
	bool isWritable() const;
	bool isActive() const;
	bool isViewOpen(unsigned view) const;
	bool isValidView(unsigned view) const;
	bool isReferenceBase() const;
	bool isScratchbase() const;
	bool isClipbase() const;
	bool isMemoryOnly() const;
	bool hasTreeView() const;

	db::format::Type format() const;
	db::variant::Type variant() const;

	MultiCursor const& multiCursor() const;
	MultiCursor& multiCursor();

	/// Count number of loaded items.
	unsigned count(db::table::Type type) const;
	/// Return maximal view number
	unsigned maxViewNumber() const;
	/// Return database index of current game.
	unsigned gameIndex() const;
	/// Return database index of specified table in given view.
	unsigned index(db::table::Type type, unsigned index, unsigned view) const;
	/// Return name of database (may be a file name)
	mstl::string const& name() const;
	/// Return type of database
	db::type::ID type() const;
	/// Return view identifier of tree view (-1 if not exists)
	int treeViewIdentifier() const;
	/// Return the application object
	Application& app() const;

	/// Create new view and return the identifier.
	unsigned newView(	View::UpdateMode gameUpdateMode,
							View::UpdateMode playerUpdateMode,
							View::UpdateMode eventUpdateMode,
							View::UpdateMode siteUpdateMode,
							View::UpdateMode annotatorUpdateMode);
	/// Create new view for tree and return the identifier.
	unsigned newTreeView();
	/// Close an existing view.
	void closeView(unsigned view, bool informUser = true);
	/// Close an existing tree view.
	void closeTreeView();
	/// Close all existing views.
	void closeAllViews();
	/// Update all open views.
	void updateViews();

	/// Return database object.
	db::Database const& database() const;
	/// Return database object.
	db::Database& database();
	/// Return default view,
	View const& view() const;
	/// Return default view,
	View& view();
	/// Return specified view.
	View const& view(unsigned id) const;
	/// Return specified view.
	View& view(unsigned id);
	/// Return tree view.
	View const& treeView() const;
	/// Return tree view.
	View& treeView();

	/// Import whole database.
	unsigned importGames(db::Producer& producer, util::Progress& progress);
	/// Import whole database.
	unsigned importGames(db::Database const& src,
								unsigned& illegalRejected,
								db::Log& log,
								util::Progress& progress);
	/// Close underlying database
	void close();
	/// Set whether this database is a reference database
	void setReferenceBase(bool flag);
	/// Removes all games from the underlying database.
	void clearBase();
	/// Update the characteristics of a game.
	void updateCharacteristics(unsigned index, db::TagSet const& tags);
	/// Update the database description.
	void setupDescription(mstl::string const& description);
	/// Set flag whether this cursor is the currently active cursor.
	void setActive(bool flag);

	// Compact the database.
	bool compact(::util::Progress& progress);

	SubscriberP subscriber() const;
	void setSubscriber(SubscriberP subscriber);

private:

	friend class Application;
	friend class MultiCursor;
	friend class View;

	typedef mstl::vector<View*>	ViewList;
	typedef mstl::bitset				IndexSet;

	db::Database& base();

	void clear() throw();

	MultiCursor&	m_cursor;
	db::Database*	m_db;
	ViewList			m_viewList;
	IndexSet			m_freeSet;
	int				m_treeView;
	bool				m_isRefBase;
	bool				m_isActive;
	SubscriberP		m_subscriber;
};

} // namespace app

#include "app_cursor.ipp"

#endif // _app_cursor_included

// vi:set ts=3 sw=3:
