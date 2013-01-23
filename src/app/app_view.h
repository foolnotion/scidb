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

#ifndef _app_view_included
#define _app_view_included

#include "db_filter.h"
#include "db_selector.h"
#include "db_log.h"
#include "db_common.h"
#include "db_consumer.h"

#include "m_pvector.h"
#include "m_vector.h"
#include "m_pair.h"
#include "m_string.h"

namespace util { class Progress; }
namespace TeXt { class Environment; }

namespace db {

class TournamentTable;
class Database;
class Query;
class Consumer;
class Log;

} // namespace db

namespace app {

class Application;
class Cursor;

class View
{
public:

	enum FileMode		{ Create, Append, Upgrade };
	enum UpdateMode	{ AddNewGames, LeaveEmpty };

	typedef mstl::pvector<mstl::string>	StringList;
	typedef mstl::vector<unsigned> LengthList;
	typedef ::db::tag::TagSet TagBits;
	typedef db::Byte NagMap[db::nag::Scidb_Last];
	typedef mstl::string Languages[4];

	typedef mstl::pair<db::load::State,unsigned> Result;

	static unsigned const DefaultView = 0;

	View(Application& app, db::Database& db);
	View(View& view, db::Database& db);
	View(	Application& app,
			db::Database& db,
			UpdateMode gameUpdateMode,
			UpdateMode playerUpdateMode,
			UpdateMode eventUpdateMode,
			UpdateMode siteUpdateMode,
			UpdateMode annotatorUpdateMode);

	/// Return application.
	Application const& application() const;
	/// Return database.
	db::Database const& database() const;

	/// Return the update mode of the specified table.
	UpdateMode updateMode(db::table::Type type) const;

	/// Return number of items in filter.
	unsigned count(db::table::Type type) const;
	/// Return size of filter.
	unsigned total(db::table::Type type) const;
	/// Return index according to current selector.
	unsigned index(db::table::Type type, unsigned index) const;

	/// Return index in current selector of given game number.
	int lookupGame(unsigned number) const;
	/// Return index in current selector of given player name.
	int lookupPlayer(mstl::string const& name) const;
	/// Return index in current selector of given player number.
	int lookupPlayer(unsigned number) const;
	/// Return index in current selector of given event title.
	int lookupEvent(mstl::string const& name) const;
	/// Return index in current selector of given event number.
	int lookupEvent(unsigned number) const;
	/// Return index in current selector of given site.
	int lookupSite(mstl::string const& name) const;
	/// Return index in current selector of given site number.
	int lookupSite(unsigned number) const;
	/// Return index in current selector of given annotator number.
	int lookupAnnotator(mstl::string const& name) const;
	/// Return index of first matching player.
	int findPlayer(mstl::string const& name) const;
	/// Return index of first matching event.
	int findEvent(mstl::string const& title) const;
	/// Return index of first matching site.
	int findSite(mstl::string const& title) const;
	/// Return index of first matching annotator.
	int findAnnotator(mstl::string const& name) const;

	/// Return current table filter.
	db::Filter const& filter(db::table::Type type) const;
	/// Return current table selector.
	db::Selector const& selector(db::table::Type type) const;

	/// Get PGN (without variations) of given game index.
	Result dumpGame(unsigned index, mstl::string const& fen, mstl::string& result) const;
	Result dumpGame(	unsigned index,
							unsigned split,
							mstl::string const& fen,
							StringList& result,
							StringList& positions) const;

	/// Sort database (using a selector).
	void sort(	db::attribute::game::ID attr,
					db::order::ID order,
					db::rating::Type ratingType = db::rating::Any);
	/// Sort database (using a selector).
	void sort(	db::attribute::player::ID attr,
					db::order::ID order,
					db::rating::Type ratingType = db::rating::Any);
	/// Sort database (using a selector).
	void sort(db::attribute::event::ID attr, db::order::ID order);
	/// Sort database (using a selector).
	void sort(db::attribute::site::ID attr, db::order::ID order);
	/// Sort database (using a selector).
	void sort(db::attribute::annotator::ID attr, db::order::ID order);
	/// Reverse order of table (using a selector).
	void reverseOrder(db::table::Type type);
	/// Reset order of table (using a selector).
	void resetOrder(db::table::Type type);
	/// Update the modified selector. Must be used after any filter or sorting functions.
	void updateSelector(db::table::Type type);
	/// Do a search for games (modifies the filter).
	void searchGames(db::Query const& query);
	/// Set table filter according to game filter.
	void filterOnGames(db::table::Type type);

	/// Reflect database changes (number of games),
	void update();
	/// Set game filter.
	void setGameFilter(db::Filter const& filter);

	/// Build tournament table for all games in current view.
	db::TournamentTable* makeTournamentTable() const;

	/// Copy games from database to database.
	unsigned copyGames(	Cursor& destination,
								TagBits const& allowedTags,
								bool allowExtraTags,
								unsigned& illegalRejected,
								db::Log& log,
								util::Progress& progress);

	/// Export games in view.
	unsigned exportGames(	mstl::string const& filename,
									mstl::string const& encoding,
									mstl::string const& description,
									db::type::ID type,
									unsigned flags,
									db::copy::Mode copyMode,
									TagBits const& allowedTags,
									bool allowExtraTags,
									unsigned& illegalRejected,
									db::Log& log,
									util::Progress& progress,
									FileMode fmode = Create) const;

	/// Print games in view.
	unsigned printGames(	TeXt::Environment& environment,
								db::format::Type format,
								unsigned flags,
								unsigned options,
								NagMap const& nagMap,
								Languages const& languages,
								unsigned significantLanguages,
								db::Log& log,
								util::Progress& progress) const;

private:

	unsigned exportGames(db::Consumer& destination,
								db::copy::Mode copyMode,
								unsigned& illegalRejected,
								db::Log& log,
								util::Progress& progress) const;
	unsigned exportGames(db::Database& destination,
								db::copy::Mode copyMode,
								unsigned& illegalRejected,
								db::Log& log,
								util::Progress& progress) const;

	void initialize();

	Application&	m_app;
	db::Database&	m_db;
	UpdateMode		m_updateMode[db::table::LAST];
	db::Filter		m_filter[db::table::LAST];
	db::Selector	m_selector[db::table::LAST];
};

} // namespace app

#include "app_view.ipp"

#endif // _app_view_included

// vi:set ts=3 sw=3:
