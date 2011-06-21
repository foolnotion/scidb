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

#include "tcl_progress.h"
#include "tcl_application.h"
#include "tcl_log.h"
#include "tcl_obj.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_query.h"
#include "db_search.h"
#include "db_database.h"

#include "sys_utf8_codec.h"

#include "m_vector.h"
#include "m_algorithm.h"
#include "m_tuple.h"
#include "m_map.h"
#include "m_assert.h"

#include <tcl.h>

using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::app;

static char const* CmdClose			= "::scidb::view::close";
static char const* CmdCount			= "::scidb::view::count";
static char const* CmdExport			= "::scidb::view::export";
static char const* CmdFind				= "::scidb::view::find";
static char const* CmdMap				= "::scidb::view::map";
static char const* CmdNew				= "::scidb::view::new";
static char const* CmdSearch			= "::scidb::view::search";
static char const* CmdSubscribe		= "::scidb::view::subscribe";
static char const* CmdUnsubscribe	= "::scidb::view::unsubscribe";


namespace {

struct Subscriber : public Cursor::Subscriber
{
	typedef mstl::tuple<Obj,Obj,Obj> Tuple;

	void addProc(Tcl_Obj* base, Tcl_Obj* proc, Tcl_Obj* arg)
	{
		M_ASSERT(base);
		M_ASSERT(proc);

		m_list.push_back(Tuple(base, proc, arg));
		m_list.back().get<0>().ref();
		m_list.back().get<1>().ref();
		m_list.back().get<2>().ref();
	}

	void removeProc(Tcl_Obj* base, Tcl_Obj* proc, Tcl_Obj* arg)
	{
		List::iterator i = mstl::find(m_list.begin(), m_list.end(), Tuple(base, proc, arg));

		if (i == m_list.end())
		{
			fprintf(stderr, "Warning: view::unsubscribe failed\n");
		}
		else
		{
			i->get<0>().deref();
			i->get<1>().deref();
			i->get<2>().deref();
			m_list.erase(i);
		}
	}

	void close(unsigned view)
	{
		Tcl_Obj* v = Tcl_NewIntObj(view);
		Tcl_IncrRefCount(v);

		for (unsigned i = 0; i < m_list.size(); ++i)
		{
			Tuple const& data = m_list[i];

			if (data.get<2>())
				invoke(__func__, data.get<0>()(), data.get<2>()(), data.get<1>()(), v, NULL);
			else
				invoke(__func__, data.get<0>()(), data.get<1>()(), v, NULL);
		}

		Tcl_DecrRefCount(v);
	}

	typedef mstl::vector<Tuple> List;

	List m_list;
};


typedef mstl::ref_counted_ptr<Subscriber> SubscriberP;
typedef mstl::map<mstl::string, SubscriberP> SubscriberMap;

static SubscriberMap subscriberMap;

} // namespace


static Search*
buildSearch(Database const& db, Tcl_Interp* ti, Tcl_Obj* query)
{
	int objc;
	Tcl_Obj** objv;

	Tcl_ListObjGetElements(ti, query, &objc, &objv);

	if (objc < 2)
	{
		error(CmdSearch, 0, 0, "invalid query");
		return 0;
	}

	static char const* subcommands[] =
	{
		"OR", "AND", "NOT", "player", "event", "gameevent", "annotator", 0
	};
	static char const* args[] =
	{
		"<query>+", "<query>+", "<query>+", "<string>", "<string>", "<string>"
	};
	enum
	{
		OR, AND, NOT, Player, Event, GameEvent, Annotator
	};

	Search* search = 0;

	switch (tcl::uniqueMatchObj(objv[0], subcommands))
	{
		case OR:
		case AND:
			// TODO
			return 0;

		case NOT:
			if (objc != 2)
			{
				error(CmdSearch, "NOT", 0, "invalid query");
				return 0;
			}
			search = new SearchOpNot(buildSearch(db, ti, objv[1]));
			break;

		case Player:
			if (objc != 2)
			{
				error(CmdSearch, "player", 0, "invalid query");
				return 0;
			}
			search = new SearchPlayer(&db.player(unsignedFromObj(2, objv, 1)));
			break;

		case Event:
			if (objc != 2)
			{
				error(CmdSearch, "event", 0, "invalid query");
				return 0;
			}
			search = new SearchEvent(&db.event(unsignedFromObj(2, objv, 1)));
			break;

		case GameEvent:
			if (objc != 2)
			{
				error(CmdSearch, "gameevent", 0, "invalid query");
				return 0;
			}
			search = new SearchEvent(db.gameInfo(unsignedFromObj(2, objv, 1)).eventEntry());
			break;

		case Annotator:
			if (objc != 2)
			{
				error(CmdSearch, "annotator", 0, "invalid query");
				return 0;
			}
			search = new SearchAnnotator(Tcl_GetStringFromObj(objv[1], 0));
			break;

		default:
			usage(CmdSearch, Tcl_GetStringFromObj(objv[0], 0), 0, subcommands, args);
			return 0;
	}

	return search;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*			base		= stringFromObj(objc, objv, 1);
	View::UpdateMode	mode[4];

	for (unsigned i = 0; i < U_NUMBER_OF(mode); ++i)
	{
		char const* arg = stringFromObj(objc, objv, i + 2);

		if (::strcmp(arg, "master") == 0)
			mode[i] = View::AddNewGames;
		else if (::strcmp(arg, "slave") == 0)
			mode[i] = View::LeaveEmpty;
		else
			error(CmdNew, 0, 0, "unknown resize mode '%s'", arg);
	}

	appendResult("%u", scidb.cursor(base).newView(mode[0], mode[1], mode[2], mode[3]));
	return TCL_OK;
}


static int
cmdClose(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <view>");
		return TCL_ERROR;
	}

	int view;

	if (Tcl_GetIntFromObj(ti, objv[2], &view) != TCL_OK)
		return error(CmdClose, 0, 0, "unsigned integer expected for view");

	scidb.cursor(Tcl_GetStringFromObj(objv[1], 0)).closeView(view);
	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "games", "players", "annotators", "events", 0 };
	static char const* args[] = { "<database> <view>" };
	enum { Cmd_Games, Cmd_Players, Cmd_Annotators, Cmd_Events };

	if (objc != 4)
		return usage(CmdCount, 0, 0, subcommands, args);

	char const* database = stringFromObj(objc, objv, 2);

	int index	= tcl::uniqueMatchObj(objv[1], subcommands);
	int view		= intFromObj(objc, objv, 3);

	switch (index)
	{
		case Cmd_Games:
			appendResult("%u", Scidb.cursor(database).view(view).countGames());
			return TCL_OK;

		case Cmd_Players:
			appendResult("%u", Scidb.cursor(database).view(view).countPlayers());
			return TCL_OK;

		case Cmd_Annotators:
			appendResult("%u", Scidb.cursor(database).view(view).countAnnotators());
			return TCL_OK;

		case Cmd_Events:
			appendResult("%u", Scidb.cursor(database).view(view).countEvents());
			return TCL_OK;
	}

	return usage(CmdCount, 0, 0, subcommands, args);
}


static int
cmdFind(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "player", "event", "annotator", 0 };
	static char const* args[] = { "<database> <view>" };
	enum { Cmd_Player, Cmd_Event, Cmd_Annotator };

	if (objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "player|event|annotator <database> <view> <string>");
		return TCL_ERROR;
	}

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	char const*	database	= Tcl_GetStringFromObj(objv[2], 0);
	char const* name		= Tcl_GetStringFromObj(objv[4], 0);

	int view;

	if (Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
		return error(CmdFind, 0, 0, "unsigned integer expected for view");

	View const& v = Scidb.cursor(database).view(view);

	switch (index)
	{
		case Cmd_Player:
			appendResult("%d", v.findPlayer(name));
			break;

		case Cmd_Event:
			appendResult("%d", v.findEvent(name));
			break;

		case Cmd_Annotator:
			appendResult("%d", v.findAnnotator(name));
			break;

		default:
			return usage(CmdCount, 0, 0, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdSearch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 5 || 6 < objc)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <view> <operator> <none|events|players> ?<query>?");
		return TCL_ERROR;
	}

	char const*	database	= Tcl_GetStringFromObj(objv[1], 0);
	char const*	ops		= Tcl_GetStringFromObj(objv[3], 0);

	Query::Operator op;

	if (strcmp(ops, "null") == 0)
		op = Query::Null;
	else if (strcmp(ops, "or") == 0)
		op = Query::Or;
	else if (strcmp(ops, "and") == 0)
		op = Query::And;
	else if (strcmp(ops, "not") == 0)
		op = Query::Not;
	else if (strcmp(ops, "reset") == 0)
		op = Query::Reset;
	else if (strcmp(ops, "remove") == 0)
		op = Query::Remove;
	else
		return error(CmdSearch, 0, 0, "invalid operator %s", ops);

	char const* f = Tcl_GetStringFromObj(objv[4], 0);
	unsigned filter = Application::None;

	switch (f[0])
	{
		case 'n': break;												// none
		case 'e': filter |= Application::Events; break;		// events
		case 'p': filter |= Application::Players; break;	// players

		default:  return error(CmdSearch, 0, 0, "invalid filter argument %s", f);
	}

	int view;

	if (Tcl_GetIntFromObj(ti, objv[2], &view) != TCL_OK)
		return error(CmdSearch, 0, 0, "unsigned integer expected for view");

	// TODO: we don't like to interrupt tree search!
	Cursor& cursor = scidb.cursor(database);

	Search* search = objc < 6 ? 0 : buildSearch(cursor.database(), ti, objv[5]);

	if (search == 0 && objc == 6)
		return TCL_ERROR;

	scidb.searchGames(cursor, Query(search, op), view, filter);

	return TCL_OK;
}


static int
cmdExport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 12)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<database> <view> <file> <flags> <mode> <encoding> <exclude-illegal-games-flag> "
			"<progress-cmd> <progress-arg> <log-cmd> <log-arg>");
		return TCL_ERROR;
	}

	char const*		database			= stringFromObj(objc, objv, 1);
	unsigned			view				= unsignedFromObj(objc, objv, 2);
	char const*		filename			= stringFromObj(objc, objv, 3);
	unsigned			flags				= unsignedFromObj(objc, objv, 4);
	View::FileMode	mode				= boolFromObj(objc, objv, 5) ? View::Append : View::Create;
	char const*		encoding			= stringFromObj(objc, objv, 6);
	bool				excludeIllegal	= boolFromObj(objc, objv, 7);

	Progress		progress(objv[8], objv[9]);
	tcl::Log		log(objv[10], objv[11]);
	Cursor&		cursor(scidb.cursor(database));
	Database&	db(cursor.database());
	View&			v(cursor.view(view));
	type::ID		type(db.type());

	if (type == type::Temporary)
		type = type::Unspecific;

	setResult(v.exportGames(filename,
									encoding,
									db.description(),
									type,
									flags,
									excludeIllegal ? View::ExcludeIllegal : View::AllGames,
									log,
									progress,
									mode));

	return TCL_OK;
}


static int
cmdMap(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* attr = stringFromObj(objc, objv, 1);
	Cursor const& cursor(Scidb.cursor(stringFromObj(objc, objv, 2)));
	View const& view = cursor.view(unsignedFromObj(objc, objv, 3));
	unsigned index = unsignedFromObj(objc, objv, 4);

	if (::strcmp(attr, "player") == 0)
		setResult(view.lookupPlayer(index));
	else if (::strcmp(attr, "event") == 0)
		setResult(view.lookupEvent(index));
	else if (::strcmp(attr, "game") == 0)
		setResult(view.lookupGame(index));
	else
		error(CmdMap, 0, 0, "unexpected attribute '%s'", attr);

	return TCL_OK;
}


static int
cmdSubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* proc	= objectFromObj(objc, objv, 1);
	Tcl_Obj* base	= objectFromObj(objc, objv, 2);
	Tcl_Obj* arg = objc > 3 ? objv[3] : 0;

	// XXX we don't want cancelling tree search
	mstl::string basename(Tcl_GetStringFromObj(base, 0));
	Cursor& cursor = scidb.cursor(basename);

	SubscriberP& subscriber = ::subscriberMap[basename];

	if (!subscriber)
	{
		subscriber = new Subscriber;
		cursor.setSubscriber(subscriber);
	}

	subscriber->addProc(proc, base, arg);

	return TCL_OK;
}


static int
cmdUnsubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* proc	= objectFromObj(objc, objv, 1);
	Tcl_Obj* base	= objectFromObj(objc, objv, 2);
	Tcl_Obj* arg = objc > 3 ? objv[3] : 0;

	mstl::string basename(Tcl_GetStringFromObj(base, 0));
	SubscriberMap::iterator i = ::subscriberMap.find(basename);

	if (i != subscriberMap.end())
	{
		i->second->removeProc(proc, base, arg);

		if (i->second->m_list.empty())
			::subscriberMap.erase(i);
	}

	return TCL_OK;
}


namespace tcl {
namespace view {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdClose,			cmdClose);
	createCommand(ti, CmdCount,			cmdCount);
	createCommand(ti, CmdExport,		cmdExport);
	createCommand(ti, CmdFind,			cmdFind);
	createCommand(ti, CmdMap,			cmdMap);
	createCommand(ti, CmdNew,			cmdNew);
	createCommand(ti, CmdSearch,		cmdSearch);
	createCommand(ti, CmdSubscribe,	cmdSubscribe);
	createCommand(ti, CmdUnsubscribe,	cmdUnsubscribe);
}

} // namespace view
} // namespace tcl

// vi:set ts=3 sw=3:
