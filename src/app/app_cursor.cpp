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

#include "app_cursor.h"
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


Cursor::Subscriber::~Subscriber() throw() {}


Cursor::Cursor(Application& app, Database* database)
	:m_app(app)
	,m_db(database)
	,m_treeView(-1)
	,m_isRefBase(false)
	,m_isScratchBase(false)
	,m_isActive(false)
{
	M_REQUIRE(database);

	m_viewList.push_back(new View(app, *database));	// base view
	m_viewList.push_back(new View(app, *database));	// view 0
}


Cursor::~Cursor()
{
	clear();
	delete *m_viewList.begin();
}


void
Cursor::clear() throw()
{
	for (ViewList::iterator i = m_viewList.begin() + 1; i < m_viewList.end(); ++i)
		delete *i;

	m_viewList.resize(1);
	m_treeView = -1;
}


bool
Cursor::isReadOnly() const
{
	M_REQUIRE(isOpen());
	return m_db->isReadOnly();
}


bool
Cursor::isWriteable() const
{
	M_REQUIRE(isOpen());
	return m_db->isWriteable();
}



void
Cursor::setDescription(mstl::string const& description)
{
	M_REQUIRE(isOpen());
	m_db->setDescription(description);
}


bool
Cursor::isViewOpen(unsigned view) const
{
	M_REQUIRE(isValidView(view));
	return view == BaseView ? true : m_viewList[view + 1] != 0;
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
	View*		view = new View(	m_app,
										*m_db,
										gameUpdateMode,
										playerUpdateMode,
										eventUpdateMode,
										siteUpdateMode,
										annotatorUpdateMode);

	if (m_freeSet.empty())
	{
		viewId = m_viewList.size() - 1;
		m_viewList.push_back(view);
	}
	else
	{
		viewId = *m_freeSet.begin();
		m_freeSet.erase(m_freeSet.begin());
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
Cursor::closeView(unsigned view)
{
	M_REQUIRE(view != BaseView);
	M_REQUIRE(isValidView(view));

	if (view != 0 && m_viewList[view + 1])
	{
		m_freeSet.push_back(view);
		delete m_viewList[view + 1];
		m_viewList[view + 1] = 0;

		if (m_treeView == int(view))
			m_treeView = -1;

		if (m_subscriber)
			m_subscriber->close(view);
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
Cursor::countGames() const
{
	M_REQUIRE(isOpen());
	return m_db->countGames();
}


unsigned
Cursor::countPlayers() const
{
	M_REQUIRE(isOpen());
	return m_db->countPlayers();
}


unsigned
Cursor::countEvents() const
{
	M_REQUIRE(isOpen());
	return m_db->countEvents();
}


unsigned
Cursor::countSites() const
{
	M_REQUIRE(isOpen());
	return m_db->countSites();
}


unsigned
Cursor::countAnnotators() const
{
	M_REQUIRE(isOpen());
	return m_db->countAnnotators();
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
Cursor::gameIndex(unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->gameIndex(index);
}


unsigned
Cursor::playerIndex(unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->playerIndex(index);
}


unsigned
Cursor::eventIndex(unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->eventIndex(index);
}


unsigned
Cursor::siteIndex(unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->siteIndex(index);
}


unsigned
Cursor::annotatorIndex(unsigned index, unsigned view) const
{
	M_REQUIRE(isOpen());
	M_REQUIRE(isViewOpen(view));

	return view == BaseView ? index : m_viewList[view + 1]->annotatorIndex(index);
}


Database&
Cursor::database()
{
	if (m_isRefBase)
		Application::stopUpdateTree();

	return *m_db;
}


void
Cursor::close()
{
	if (m_db)
	{
		for (unsigned i = 1; i < m_viewList.size(); ++i)
			closeView(i - 1);

		m_db->close();
		delete m_db;
		m_db = 0;
		clear();
		m_freeSet.clear();
	}
}


void
Cursor::updateCharacteristics(unsigned index, TagSet const& tags)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(index < countGames());

	// TODO: handle return code!
	m_app.updateCharacteristics(*this, index, tags);
}


void
Cursor::updateViews()
{
	if (!m_isScratchBase)
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
	M_REQUIRE(!isReadOnly());

	if (m_isRefBase)
		Application::stopUpdateTree();

	unsigned res = m_db->importGames(producer, progress);

	if (res > 0)
		updateViews();

	if (m_isRefBase)
		m_app.startUpdateTree(*this);	

	return res;
}


unsigned
Cursor::importGames(db::Database& src, Log& log, util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());

	if (m_isRefBase)
		Application::stopUpdateTree();

	unsigned res = m_db->importGames(src, log, progress);

	if (res > 0)
		updateViews();

	if (m_isRefBase)
		m_app.startUpdateTree(*this);	

	return res;
}


void
Cursor::clearBase()
{
	M_REQUIRE(!isReadOnly());

	database().clear();
	updateViews();
}


bool
Cursor::compact(::util::Progress& progress)
{
	M_REQUIRE(isOpen());
	M_REQUIRE(!isReadOnly());
	M_REQUIRE(isWriteable());

	m_db->sync(progress);

	unsigned numGames	= m_db->countGames();
	unsigned deleted	= 0;

	for (unsigned i = 0; i < numGames; ++i)
	{
		if (m_db->gameInfo(i).isDeleted())
			++deleted;
	}

	if (deleted == 0)
		return false;

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
		unsigned frequency	= progress.frequency(numGames, 20000);
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
	}
	catch (...)
	{
		compacted->remove();
		throw;
	}

	m_db->close();
	delete m_db;

	m_db = compacted.release();
	m_db->rename(orig);

	ViewList viewList;

	for (unsigned i = 0; i < m_viewList.size(); ++i)
	{
		if (m_viewList[i])
		{
			viewList.push_back(new View(*m_viewList[i], *m_db));
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
