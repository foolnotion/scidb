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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _app_multi_cursor_included
#define _app_multi_cursor_included

#include "db_common.h"

#include "m_string.h"
#include "m_ref_counter.h"

namespace db	{ class MultiBase; }
namespace db	{ class Producer; }
namespace db	{ class Database; }
namespace db	{ class Log; }
namespace util	{ class Progress; }

namespace app {

class Application;
class Cursor;

class MultiCursor : public mstl::ref_counter
{
public:

	enum Type { Clipbase, Scratchbase };

	typedef ::db::tag::TagSet TagBits;
	typedef unsigned GameCount[::db::variant::NumberOfVariants];

	MultiCursor(Application& app, Type type);
	MultiCursor(Application& app, db::MultiBase* base);
	MultiCursor(	Application& app,
						mstl::string const& name,
						db::type::ID type,
						db::Producer& producer,
						util::Progress& progress);
	~MultiCursor();

	bool isOpen() const;
	bool isClosed() const;
	bool isReadonly() const;
	bool isWritable() const;
	bool isMemoryOnly() const;
	bool isClipbase() const;
	bool isScratchbase() const;
	bool isSingleBase() const;
	bool exists(unsigned variantIndex) const;
	bool isEmpty(unsigned variantIndex) const;
	bool isEmpty() const;
	bool isUnsaved() const;

	unsigned countGames() const;

	Cursor* operator[](unsigned variantIndex) const;
	Cursor* operator[](db::variant::Type variant) const;

	Cursor& cursor() const;
	Cursor& cursor(unsigned variantIndex) const;
	Cursor& cursor(db::variant::Type variant) const;

	db::MultiBase& multiBase();
	db::MultiBase const& multiBase() const;

	mstl::string const& name() const;
	Application& app() const;

	unsigned copyGames(	MultiCursor& destination,
								GameCount& accepted,
								GameCount& rejected,
								TagBits const& allowedTags,
								bool allowExtraTags,
								unsigned* illegalRejected,
								db::Log& log,
								util::Progress& progress) const;

	/// Mark this database as a clipbase.
	void setClipbase();
	/// Mark this database as a scratchbase.
	void setScratchbase();
	/// Change readonly flag.
	bool setReadonly(bool flag);
	/// Close all databases.
	void close();
	/// Change the variant; requires an empty database.
	void changeVariant(::db::variant::Type variant);
	/// Replace database object.
	void replace(db::Database* database);

	// FAM service
	void famChanged();
	void famDeleted();

	static mstl::string const& clipbaseName();
	static mstl::string const& scratchbaseName();

private:

	Application&	m_app;
	db::MultiBase*	m_base;
	Cursor*			m_leader;
	Cursor*			m_cursor[db::variant::NumberOfVariants];
	bool				m_isScratchbase;
	bool				m_isClipbase;

	static mstl::string m_clipbaseName;
	static mstl::string m_scratchbaseName;
};

} // namespace app

#include "app_multi_cursor.ipp"

#endif // _app_multi_cursor_included

// vi:set ts=3 sw=3:
