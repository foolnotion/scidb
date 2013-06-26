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

#include "app_cursor.h"
#include "app_multi_cursor.h"
#include "app_application.h"
#include "app_view.h"

#include "db_database.h"
#include "db_exception.h"

#include "u_misc.h"
#include "u_progress.h"

#include "m_auto_ptr.h"
#include "m_assert.h"

using namespace db;
using namespace app;


namespace {

struct WriteGuard
{
	void release() { m_app.setIsWriting(); }

	WriteGuard(Cursor const* cursor)
		:m_app(cursor->app())
	{
		M_ASSERT(cursor);

		if (!cursor->isMemoryOnly())
			m_app.setIsWriting(cursor->database().name());
	}

	~WriteGuard() { release(); }

	Application& m_app;
};

} // namespace


Cursor::Subscriber::~Subscriber() throw() {}


Cursor::Cursor(MultiCursor& cursor, Database* database)
	:m_cursor(cursor)
	,m_db(database)
	,m_treeView(-1)
	,m_isRefBase(false)
	,m_isActive(false)
{
	M_REQUIRE(database);

	m_viewList.push_back(new View(m_cursor.app(), *this));	// base view
	m_viewList.push_back(new View(m_cursor.app(), *this));	// view 0
	m_freeSet.resize(1);
}


Cursor::~Cursor()
{
	clear();
	delete *m_viewList.begin();
}


Application& Cursor::app() const { return m_cursor.app(); }


db::format::Type Cursor::format() const	{ return m_db->format(); }
db::variant::Type Cursor::variant() const	{ return m_db->variant(); }


void
Cursor::clear() throw()
{
	for (ViewList::iterator i = m_viewList.begin() + 1; i < m_viewList.end(); ++i)
		delete *i;

	m_viewList.resize(1);
	m_treeView = -1;
}


bool Cursor::isScratchbase() const	{ return m_cursor.isScratchbase(); }
bool Cursor::isClipbase() const		{ return m_cursor.isClipbase(); }


bool
Cursor::isMemoryOnly() const
{
	return database().isMemoryOnly();
}


bool
Cursor::isReadonly() const
{
	M_REQUIRE(isOpen());
	return m_db->isReadonly();
}


bool
Cursor::isWritable() const
{
	M_REQUIRE(isOpen());
	return m_db->isWritable();
}


bool
Cursor::Cursor::isEmpty() const
{
	M_REQUIRE(isOpen());
	return m_db->isEmpty();
}


void
Cursor::setupDescription(mstl::string const& description)
{
	M_REQUIRE(isOpen());
	m_db->setupDescription(description);
}


bool
Cursor::isViewOpen(unsigned view) const
{
	M_REQUIRE(isValidView(view));
	return view == BaseView || (view + 1 < m_viewList.size() && m_viewList[view + 1] != 0);
}


unsigned
Cursor::newView(	View::UpdateMode gameUpdateMode,
						View::UpdateMode playerUpdateMode,
						View::UpdateMode eventUpdateMode,
						View::UpdateMode siteUpdateMode,
						View::UpdateMode annotatorUpdateMode)
{
	M_REQUIRE(isOpen());

	unsigned	viewId;
	View*		view = new View(	m_cursor.app(),
										*this,
										gameUpdateMode,
										playerUpdateMode,
										eventUpdateMode,
										siteUpdateMode,
										annotatorUpdateMode);

	if (m_freeSet.none())
	{
		viewId = m_viewList.size() - 1;
		m_viewList.push_back(view);
		m_freeSet.resize(m_viewList.size());
	}
	else
	{
		viewId = m_freeSet.find_first();
		m_freeSet.reset(viewId);
		m_viewList[viewId + 1] = view;
	}

	return viewId;
}


unsigned
Cursor::newTreeView()
{
	M_REQUIRE(isReferenceBase());

	return m_treeView =
		newView(View::LeaveEmpty, View::LeaveEmpty, View::LeaveEmpty, View::LeaveEmpty, View::LeaveEmpty);
}


void
Cursor::closeView(unsigned view, bool informUser)
{
	M_REQUIRE(view != BaseView);
	M_REQUIRE(isValidView(view));

	if (view != 0 && m_viewList[view + 1])
	{
		m_cursor.app().viewClosed(*this, view);

		m_freeSet.set(view);
		delete m_viewList[view + 1];
		m_viewList[view + 1] = 0;

		if (m_treeView == int(view))
			m_treeView = -1;

		if (informUser && m_subscriber)
			m_subscriber->close(m_db->name(), m_db->variant(), view);
	}
}


void
Cursor::closeTreeView()
{
	if (hasTreeView())
		closeView(m_treeView);
}


mstl::string const&
Cursor::name() const
{
	M_REQUIRE(isOpen());
	return m_db->name();
}


type::ID
Cursor::type() const
{
	M_REQUIRE(isOpen());
	return m_db->type();
}


unsigned
Cursor::count(db::table::Type type) const
{
	M_REQUIRE(isOpen());
	return m_db->count(type);
}


unsigned
Cursor::gameIndex() const
{
	M_REQUIRE(isOpen());
	M_RAISE("not yet implemented");
	// TODO
	return 0;
}


unsigned
Cursor::index(db::table::Type type, unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->index(type, index);
}


Database&
Cursor::database()
{
	if (m_isRefBase)
		m_cursor.app().stopUpdateTree();

	return *m_db;
}


void
Cursor::closeAllViews()
{
	if (m_db == 0)
		return;

	for (unsigned i = 1; i < m_viewList.size(); ++i)
	{
		unsigned view = i - 1;

		if (m_viewList[view + 1])
		{
			m_cursor.app().viewClosed(*this, view);

			m_freeSet.set(view);
			delete m_viewList[view + 1];
			m_viewList[view + 1] = 0;

			if (m_treeView == int(view))
				m_treeView = -1;

			if (m_subscriber)
				m_subscriber->close(m_db->name(), m_db->variant(), view);
		}
	}
}


void
Cursor::close()
{
	if (m_db)
	{
		closeAllViews();
		m_db->close();
		m_db = 0;
		clear();
		m_freeSet.clear();
	}
}


void
Cursor::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(index < count(table::Games));

	// TODO: handle return code!
	m_cursor.app().updateCharacteristics(*this, index, tags);
}


void
Cursor::updateViews()
{
	if (!isScratchbase())
	{
		for (unsigned i = 0; i < m_viewList.size(); ++i)
		{
			View* view = m_viewList[i];

			if (view)
				view->update();
		}
	}
}


unsigned
Cursor::importGames(Producer& producer, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());

	if (m_isRefBase)
		m_cursor.app().stopUpdateTree();

	WriteGuard guard(this);
	unsigned res = m_db->importGames(producer, progress);
	if (res)
		m_db->save(progress);
	guard.release();

	if (res > 0)
		updateViews();

	if (m_isRefBase)
		m_cursor.app().startUpdateTree(*this);

	return res;
}


unsigned
Cursor::importGames(	db::Database const& src,
							unsigned& illegalRejected,
							Log& log,
							util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());

	if (m_isRefBase)
		m_cursor.app().stopUpdateTree();

	WriteGuard guard(this);
	unsigned res = m_db->importGames(src, illegalRejected, log, progress);
	if (res > 0)
		m_db->save(progress);
	guard.release();

	if (res > 0)
		updateViews();

	if (m_isRefBase)
		m_cursor.app().startUpdateTree(*this);

	return res;
}


void
Cursor::clearBase()
{
	M_REQUIRE(!isReadonly());

	database().clear();
	updateViews();
}


bool
Cursor::compact(::util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadonly());
	M_REQUIRE(isWritable());

	WriteGuard guard(this);
	m_db->sync(progress);

	if (!m_db->shouldCompress())
		return false;

	unsigned numGames		= m_db->countGames();
	unsigned initialSize	= m_db->countInitialGames();

	for (unsigned i = 0, n = initialSize; i < n; ++i)
	{
		if (m_db->gameInfo(i).isDeleted())
			--initialSize;
	}

	mstl::string orig(m_db->name());
	mstl::string name;

	name.append(::util::misc::file::dirname(m_db->name()));
	name.append('.');
	name.append(::util::misc::file::basename(::util::misc::file::rootname(m_db->name())));
	name.append(".compact.293528376.");
	name.append(::util::misc::file::suffix(m_db->name()));

	mstl::auto_ptr<Database> compacted(new Database(*m_db, name));

	try
	{
		unsigned frequency	= progress.frequency(numGames, 5000);
		unsigned reportAfter	= frequency;

		util::ProgressWatcher watcher(progress, numGames);

		for (unsigned i = 0; i < numGames; ++i)
		{
			if (reportAfter == i)
			{
				progress.update(i);
				reportAfter += frequency;
			}

			if (!m_db->gameInfo(i).isDeleted())
			{
				save::State state = m_db->exportGame(i, *compacted);

				if (!save::isOk(state))
				{
					// The following errors cannot happen, but we want to be sure:
					switch (state)
					{
						case save::Ok:
							break;

						case save::UnsupportedVariant:
						case save::DecodingFailed:
						case save::GameTooLong:
						case save::TooManyAnnotatorNames:
							// skip non-fatal errors
							break;

						case save::FileSizeExeeded:
						case save::TooManyGames:
						case save::TooManyPlayerNames:
						case save::TooManyEventNames:
						case save::TooManySiteNames:
						case save::TooManyRoundNames:
							M_THROW(Exception("Compression failed: save state %d", int(state)));
							break;
					}
				}
			}
		}

		compacted->save(progress);
		compacted->resetInitialSize(initialSize);
	}
	catch (...)
	{
		compacted->remove();
		throw;
	}

	m_db = compacted.release();
	m_db->rename(orig);
	m_cursor.replace(m_db);

	guard.release();

	ViewList viewList;

	for (unsigned i = 0; i < m_viewList.size(); ++i)
	{
		if (m_viewList[i])
		{
			viewList.push_back(new View(*m_viewList[i]));
			delete m_viewList[i];
		}
		else
		{
			viewList.push_back(0);
		}
	}

	m_viewList.clear();
	m_viewList.swap(viewList);
	updateViews();

	return true;
}

// vi:set ts=3 sw=3:
