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

#include "tcl_view.h"

#include "tcl_progress.h"
#include "tcl_application.h"
#include "tcl_pgn_reader.h"
#include "tcl_game.h"
#include "tcl_exception.h"
#include "tcl_log.h"
#include "tcl_obj.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_query.h"
#include "db_search.h"
#include "db_database.h"

#include "T_Controller.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"

#include "m_ofstream.h"
#include "m_sstream.h"
#include "m_vector.h"
#include "m_algorithm.h"
#include "m_tuple.h"
#include "m_map.h"
#include "m_ref_counted_ptr.h"
#include "m_assert.h"

#include <tcl.h>
#include <ctype.h>

using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::app;

static char const* CmdClose			= "::scidb::view::close";
static char const* CmdCopy				= "::scidb::view::copy";
static char const* CmdCount			= "::scidb::view::count";
static char const* CmdEnumTags		= "::scidb::view::enumTags";
static char const* CmdExport			= "::scidb::view::export";
static char const* CmdFind				= "::scidb::view::find";
static char const* CmdMap				= "::scidb::view::map";
static char const* CmdNew				= "::scidb::view::new";
static char const* CmdOpen				= "::scidb::view::open?";
static char const* CmdPrint			= "::scidb::view::print";
static char const* CmdSearch			= "::scidb::view::search";
static char const* CmdStrip			= "::scidb::view::strip";
static char const* CmdSubscribe		= "::scidb::view::subscribe";
static char const* CmdUnsubscribe	= "::scidb::view::unsubscribe";


namespace {

struct Subscriber : public Cursor::Subscriber
{
	typedef mstl::tuple<Obj,Obj,Obj,variant::Type> Tuple;

	void addProc(Tcl_Obj* base, variant::Type variant, Tcl_Obj* proc, Tcl_Obj* arg)
	{
		M_ASSERT(base);
		M_ASSERT(proc);

		m_list.push_back(Tuple(proc, arg, base, variant));
		m_list.back().get<0>().ref();
		m_list.back().get<1>().ref();
		m_list.back().get<2>().ref();
	}

	void removeProc(Tcl_Obj* base, variant::Type variant, Tcl_Obj* proc, Tcl_Obj* arg)
	{
		List::iterator i = mstl::find(m_list.begin(), m_list.end(), Tuple(proc, arg, base, variant));

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

	void close(mstl::string const& name, variant::Type variant, unsigned view) override
	{
		Tcl_Obj* u = tcl::game::objFromVariant(variant);
		Tcl_Obj* v = Tcl_NewIntObj(view);

		Tcl_IncrRefCount(v);

		for (unsigned i = 0; i < m_list.size(); ++i)
		{
			Tuple const& data = m_list[i];

			if (name == Tcl_GetString(data.get<2>()) && variant == data.get<3>())
			{
				if (data.get<1>())
					invoke(__func__, data.get<0>()(), data.get<1>()(), data.get<2>()(), u, v, nullptr);
				else
					invoke(__func__, data.get<0>()(), data.get<2>()(), u, v, nullptr);
			}
		}

		Tcl_DecrRefCount(v);
	}

	typedef mstl::vector<Tuple> List;

	List m_list;
};


typedef mstl::ref_counted_ptr<Subscriber> SubscriberP;
typedef mstl::map<mstl::string, SubscriberP> SubscriberMap;
typedef mstl::ref_counted_ptr<Search> SearchP;

static SubscriberMap subscriberMap;

} // namespace


static SearchP
buildSearch(Database const& db, Tcl_Interp* ti, Tcl_Obj* query)
{
	int objc;
	Tcl_Obj** objv;

	Tcl_ListObjGetElements(ti, query, &objc, &objv);

	if (objc < 2)
	{
		error(CmdSearch, 0, 0, "invalid query");
		return SearchP();
	}

	static char const* subcommands[] =
	{
		"OR", "AND", "NOT", "REMOVE", "RESET", "NULL",
		"player", "event", "site", "gameevent", "annotator",
		0
	};
	static char const* args[] =
	{
		"<query>+", "<query>+", "<query>+", "<string>", "<string>", "<string>", "<string>", "<string>", 0
	};
	enum
	{
		Or, And, Not, Remove, Reset, Null, Player, Event, Site, GameEvent, Annotator
	};

	SearchP search;

	switch (tcl::uniqueMatchObj(objv[0], subcommands))
	{
		case Or:
		case And:
		case Remove:
		case Reset:
		case Null:
			// TODO
			return search;

		case Not:
			if (objc != 2)
			{
				error(CmdSearch, "NOT", 0, "invalid query");
				return search;
			}
			search = new SearchOpNot(buildSearch(db, ti, objv[1]));
			break;

		case Player:
			if (objc != 2)
			{
				error(CmdSearch, "player", 0, "invalid query");
				return search;
			}
			search = new SearchPlayer(&db.player(unsignedFromObj(2, objv, 1)));
			break;

		case Event:
			if (objc != 2)
			{
				error(CmdSearch, "event", 0, "invalid query");
				return search;
			}
			search = new SearchEvent(&db.event(unsignedFromObj(2, objv, 1)));
			break;

		case GameEvent:
		{
			if (objc != 2)
			{
				error(CmdSearch, "gameevent", 0, "invalid query");
				return search;
			}
			GameInfo const& info = db.gameInfo(unsignedFromObj(2, objv, 1));
			search = new SearchGameEvent(info.eventEntry(), info.date());
			break;
		}

		case Site:
			if (objc != 2)
			{
				error(CmdSearch, "event", 0, "invalid query");
				return search;
			}
			search = new SearchSite(&db.site(unsignedFromObj(2, objv, 1)));
			break;

		case Annotator:
			if (objc != 2)
			{
				error(CmdSearch, "annotator", 0, "invalid query");
				return search;
			}
			search = new SearchAnnotator(Tcl_GetString(objv[1]));
			break;

		default:
			usage(CmdSearch, Tcl_GetString(objv[0]), nullptr, subcommands, args);
			return search;
	}

	return search;
}


bool
tcl::view::buildTagSet(Tcl_Interp* ti, char const* cmd, Tcl_Obj* allowedTags, ::db::tag::TagSet& tagBits)
{
	Tcl_Obj**	tags;
	int			tagCount;
	bool			extraTags	= false;

	if (Tcl_ListObjGetElements(ti, allowedTags, &tagCount, &tags) != TCL_OK)
		error(cmd, 0, 0, "invalid tag list");

	if (tagCount == 0)
	{
		tagBits.set();
		extraTags = true;
	}
	else
	{
		for (int i = 0; i < tagCount; ++i)
		{
			if (*Tcl_GetString(tags[i]))
			{
				tag::ID tag = tag::fromName(Tcl_GetString(tags[i]));

				if (tag == tag::ExtraTag)
					extraTags = true;
				else
					tagBits.set(tag);
			}
		}
	}

	return extraTags;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*			base		= stringFromObj(objc, objv, 1);
	variant::Type		variant	= variant::Undetermined;
	unsigned				n			= 2;
	View::UpdateMode	mode[5];

	if (objc > 7)
		variant = tcl::game::variantFromObj(objv[n++]);

	for (unsigned i = 0; i < U_NUMBER_OF(mode); ++i)
	{
		char const* arg = stringFromObj(objc, objv, i + n);

		if (::strcmp(arg, "master") == 0)
			mode[i] = View::AddNewGames;
		else if (::strcmp(arg, "slave") == 0)
			mode[i] = View::LeaveEmpty;
		else
			error(CmdNew, 0, 0, "unknown resize mode '%s'", arg);
	}

	setResult(scidb->cursor(base, variant).newView(mode[0], mode[1], mode[2], mode[3], mode[4]));
	return TCL_OK;
}


static int
cmdClose(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> ?<variant>? <view>");
		return TCL_ERROR;
	}

	int view;

	if (Tcl_GetIntFromObj(ti, objv[objc > 3 ? 3 : 2], &view) != TCL_OK)
		return error(CmdClose, 0, 0, "unsigned integer expected for view");

	variant::Type variant = objc > 3 ? tcl::game::variantFromObj(objv[2]) : variant::Undetermined;

	scidb->cursor(Tcl_GetString(objv[1]), variant).closeView(view);
	return TCL_OK;
}


static int
cmdOpen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "games", "players", "annotators", "events", "sites", 0 };
	static char const* args[] = { "<database> <variant> <view>" };
	enum { Cmd_Games, Cmd_Players, Cmd_Annotators, Cmd_Events, Cmd_Sites };

	if (objc != 5)
		return usage(CmdCount, nullptr, nullptr, subcommands, args);

	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 3);

	int index	= tcl::uniqueMatchObj(objv[1], subcommands);
	int view		= intFromObj(objc, objv, 4);

	switch (index)
	{
		case Cmd_Games:
			setResult(Scidb->cursor(database, variant).isViewOpen(view));
			return TCL_OK;

		case Cmd_Players:
			setResult(Scidb->cursor(database, variant).isViewOpen(view));
			return TCL_OK;

		case Cmd_Annotators:
			setResult(Scidb->cursor(database, variant).isViewOpen(view));
			return TCL_OK;

		case Cmd_Events:
			setResult(Scidb->cursor(database, variant).isViewOpen(view));
			return TCL_OK;

		case Cmd_Sites:
			setResult(Scidb->cursor(database, variant).isViewOpen(view));
			return TCL_OK;
	}

	return usage(CmdCount, nullptr, nullptr, subcommands, args);
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "games", "players", "annotators", "events", "sites", 0 };
	static char const* args[] = { "<database> <variant> <view>" };
	enum { Cmd_Games, Cmd_Players, Cmd_Annotators, Cmd_Events, Cmd_Sites };

	if (objc < 5)
		return usage(CmdCount, nullptr, nullptr, subcommands, args);

	char const* database = stringFromObj(objc, objv, 2);
	variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);

	int index	= tcl::uniqueMatchObj(objv[1], subcommands);
	int view		= intFromObj(objc, objv, 4);

	table::Type type;

	switch (index)
	{
		case Cmd_Games:		type = table::Games; break;
		case Cmd_Players:		type = table::Players; break;
		case Cmd_Annotators:	type = table::Annotators; break;
		case Cmd_Events:		type = table::Events; break;
		case Cmd_Sites:		type = table::Sites; break;
		default:					return usage(CmdCount, nullptr, nullptr, subcommands, args);
	}

	setResult(Scidb->cursor(database, variant).view(view).count(type));
	return TCL_OK;
}


static int
cmdFind(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "player", "event", "site", "annotator", 0 };
	static char const* args[] = { "<database> <variant> <view>" };
	enum { Cmd_Player, Cmd_Event, Cmd_Site, Cmd_Annotator };

	if (objc != 6)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "player|event|site|annotator <database> <variant> <view> <string>");
		return TCL_ERROR;
	}

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	char const*		database	= Tcl_GetString(objv[2]);
	char const* 	name		= Tcl_GetString(objv[5]);
	variant::Type	variant	= tcl::game::variantFromObj(objv[3]);

	int view;

	if (Tcl_GetIntFromObj(ti, objv[4], &view) != TCL_OK)
		return error(CmdFind, 0, 0, "unsigned integer expected for view");

	View const& v = Scidb->cursor(database, variant).view(view);

	switch (index)
	{
		case Cmd_Player:
			setResult(v.findPlayer(name));
			break;

		case Cmd_Event:
			setResult(v.findEvent(name));
			break;

		case Cmd_Site:
			setResult(v.findSite(name));
			break;

		case Cmd_Annotator:
			setResult(v.findAnnotator(name));
			break;

		default:
			return usage(CmdCount, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdSearch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 5 || 7 < objc)
	{
		Tcl_WrongNumArgs(
			ti,
			1,
			objv,
			"<database> ?<variant>? <view> <operator> <none|events|sites|players> ?<query>?");
		return TCL_ERROR;
	}

	unsigned n = *Tcl_GetString(objv[2]) == '-' || isdigit(*Tcl_GetString(objv[2])) ? 0 : 1;

	char const*		database	= Tcl_GetString(objv[1]);
	char const*		ops		= Tcl_GetString(objv[3 + n]);
	variant::Type	variant	= n ? tcl::game::variantFromObj(objv[2]) : variant::Undetermined;

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

	char const* f = Tcl_GetString(objv[4 + n]);
	unsigned filter = Application::None;

	switch (f[0])
	{
		case 'n': break;												// none
		case 'e': filter |= Application::Events; break;		// events
		case 'p': filter |= Application::Players; break;	// players
		case 's': filter |= Application::Sites; break;		// sites

		default:  return error(CmdSearch, 0, 0, "invalid filter argument %s", f);
	}

	int view;

	if (Tcl_GetIntFromObj(ti, objv[2 + n], &view) != TCL_OK)
		return error(CmdSearch, 0, 0, "unsigned integer expected for view");

	// NOTE: we don't like to interrupt tree search!
	Cursor const& cursor = Scidb->cursor(database, variant);

	SearchP search;

	if (objc + n >= 6)
		search = buildSearch(cursor.database(), ti, objv[5 + n]);

	if (!search && objc == int(6 + n))
		return TCL_ERROR;

	scidb->searchGames(	const_cast<Cursor&>(cursor),
								Query(mstl::ref_counted_ptr<Search>(search), op),
								view,
								filter);

	return TCL_OK;
}


static int
cmdCopy(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 10)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<source> <view> <destination> <variant> <tag-set> "
			"<progress-cmd> <progress-arg> <log-cmd> <log-arg>");
		return TCL_ERROR;
	}


	View::TagBits	tagBits;
	mstl::string	source(stringFromObj(objc, objv, 1));
	unsigned			viewNo(unsignedFromObj(objc, objv, 2));
	mstl::string	destination(stringFromObj(objc, objv, 3));
	variant::Type	variant(tcl::game::variantFromObj(objc, objv, 4));
	bool				extraTags(tcl::view::buildTagSet(ti, CmdCopy, objv[5], tagBits));
	Tcl_Obj*			progressCmd(objectFromObj(objc, objv, 6));
	Tcl_Obj*			progressArg(objectFromObj(objc, objv, 7));
	Tcl_Obj*			logCmd(objectFromObj(objc, objv, 8));
	Tcl_Obj*			logArg(objectFromObj(objc, objv, 9));
	Progress			progress(progressCmd, progressArg);
	tcl::Log			log(logCmd, logArg);
	View&				view(scidb->cursor(source, variant).view(viewNo));
	unsigned			n;
	unsigned			accepted[variant::NumberOfVariants];
	unsigned			rejected[variant::NumberOfVariants];

	::memset(accepted, 0, sizeof(accepted));
	::memset(rejected, 0, sizeof(rejected));

	Cursor& dst = scidb->cursor(destination, variant);
	unsigned variantIndex = variant::toIndex(variant);
	unsigned illegalRejected = 0;

	n = view.copyGames(dst, tagBits, extraTags, illegalRejected, log, progress);
	accepted[variantIndex] = n;
	rejected[variantIndex] = dst.count(table::Games) - n;

	if (progress.interrupted())
		n = -n - 1;

	tcl::PgnReader::setResult(n, illegalRejected, accepted, rejected);
	return TCL_OK;
}


static int
cmdExport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 14)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<database> <variant> <view> <file> <flags> <mode> <encoding> <exclude-illegal-games-flag> "
			"<exported-tags> <progress-cmd> <progress-arg> <log-cmd> <log-arg>");
		return TCL_ERROR;
	}

	View::TagBits	tagBits;
	char const*		database			= stringFromObj(objc, objv, 1);
	variant::Type	variant			= tcl::game::variantFromObj(objc, objv, 2);
	unsigned			view				= unsignedFromObj(objc, objv, 3);
	char const*		filename			= stringFromObj(objc, objv, 4);
	unsigned			flags				= unsignedFromObj(objc, objv, 5);
	View::FileMode	mode				= boolFromObj(objc, objv, 6) ? View::Append : View::Create;
	mstl::string	encoding			= stringFromObj(objc, objv, 7);
	bool				excludeIllegal	= boolFromObj(objc, objv, 8);
	bool				extraTags		= tcl::view::buildTagSet(ti, CmdExport, objv[9], tagBits);

	Progress			progress(objv[10], objv[11]);
	tcl::Log			log(objv[12], objv[13]);
	Cursor&			cursor(scidb->cursor(database, variant));
	Database&		db(cursor.database());
	View&				v(cursor.view(view));
	type::ID			type(db.type());
	unsigned			illegalRejected(0);

	if (type == type::PGNFile)
		type = type::Unspecific;

	int n = v.exportGames(	sys::file::internalName(filename),
									encoding,
									db.description(),
									type,
									flags,
									excludeIllegal ? ::db::copy::ExcludeIllegal : ::db::copy::AllGames,
									tagBits,
									extraTags,
									illegalRejected,
									log,
									progress,
									mode);

	if (progress.interrupted())
		n = -n - 1;

	Tcl_Obj* objs[2];
	objs[0] = Tcl_NewIntObj(n);
	objs[1] = Tcl_NewIntObj(illegalRejected);
	setResult(2, objs);

	return TCL_OK;
}


static int
cmdPrint(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	struct Log : public TeXt::Controller::Log
	{
		void error(mstl::string const& msg) { str = msg; }
		mstl::string str;
	};

	if (objc != 18)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<database> <variant> <view> <file> <search-path> <script-path> <preamble> <flags> "
			" <options> <nag-map> <languages> <significant> <trace> <progress-cmd> <progress-arg> "
			"<log-cmd> <log-arg>");
		return TCL_ERROR;
	}

	char const*		database			= stringFromObj(objc, objv, 1);
	variant::Type	variant			= tcl::game::variantFromObj(objc, objv, 2);
	unsigned			view				= unsignedFromObj(objc, objv, 3);
	char const*		filename			= stringFromObj(objc, objv, 4);
	char const* 	searchPath		= stringFromObj(objc, objv, 5);
	mstl::string 	scriptPath		= stringFromObj(objc, objv, 6);
	mstl::string 	preamble			= stringFromObj(objc, objv, 7);
	unsigned			flags				= unsignedFromObj(objc, objv, 8);
	unsigned			options			= unsignedFromObj(objc, objv, 9);
	Tcl_Obj*			mapObj			= objectFromObj(objc, objv, 10);
	Tcl_Obj*			languageList	= objectFromObj(objc, objv, 11);
	unsigned			significant		= unsignedFromObj(objc, objv, 12);
	char const*		trace				= stringFromObj(objc, objv, 13);

	Progress				progress(objv[14], objv[15]);
	tcl::Log				log(objv[16], objv[17]);
	Cursor&				cursor(scidb->cursor(database, variant));
	View&					v(cursor.view(view));
	Tcl_Obj**			objs;
	View::NagMap		nagMap;
	View::Languages	languages;

	::memset(nagMap, 0, sizeof(nagMap));

	if (Tcl_ListObjGetElements(ti, mapObj, &objc, &objs) != TCL_OK)
		error(CmdExport, 0, 0, "invalid nag map");

	for (int i = 0; i < objc; ++i)
	{
		Tcl_Obj** pair;
		int nelems;

		if (Tcl_ListObjGetElements(ti, objs[i], &nelems, &pair) != TCL_OK || nelems != 2)
			error(CmdExport, 0, 0, "invalid nag map");

		int lhs = intFromObj(2, pair, 0);
		int rhs = intFromObj(2, pair, 1);

		if (lhs >= nag::Scidb_Last || rhs >= nag::Scidb_Last)
			error(CmdExport, 0, 0, "invalid nag map values");

		nagMap[lhs] = rhs;
	}

	if (	Tcl_ListObjGetElements(ti, languageList, &objc, &objs) != TCL_OK
		|| objc >= int(U_NUMBER_OF(languages)))
	{
		error(CmdExport, 0, 0, "invalid language list");
	}

	for (int i = 0; i < objc; ++i)
		languages[i] = stringFromObj(objc, objs, i);

	TeXt::Controller::LogP myLog(new Log);
	TeXt::Controller controller(searchPath, TeXt::Controller::AbortMode, myLog);
	mstl::istringstream src(preamble);
	mstl::ofstream dst(sys::file::internalName(filename));
	mstl::ostringstream out;

	if (controller.processInput(src, dst, &out, &out) >= 0)
	{
		int rc = controller.processInput(scriptPath, dst, &out, &out);

		if (rc == TeXt::Controller::OpenInputFileFailed)
			out.write(static_cast<Log*>(myLog.get())->str);
	}

	setResult(v.printGames(	controller.environment(),
									format::LaTeX,
									flags,
									options,
									nagMap,
									languages,
									significant,
									log,
									progress));

	{
		mstl::string log(out.str());

		if (!log.empty() && log.back() == '\n')
			log.set_size(log.size() - 1);

		Tcl_SetVar2Ex(ti, trace, 0, Tcl_NewStringObj(log, log.size()), TCL_GLOBAL_ONLY);
	}

	return TCL_OK;
}


static int
cmdMap(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*		attr		= stringFromObj(objc, objv, 1);
	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= objc > 5 ? tcl::game::variantFromObj(objv[3]) : variant::Undetermined;
	Cursor const&	cursor	= Scidb->cursor(database, variant);
	View const&		view		= cursor.view(unsignedFromObj(objc, objv, objc > 5 ? 4 : 3));
	unsigned			index		= unsignedFromObj(objc, objv, objc > 5 ? 5 : 4);

	if (::strcmp(attr, "player") == 0)
		setResult(view.lookupPlayer(index));
	else if (::strcmp(attr, "event") == 0)
		setResult(view.lookupEvent(index));
	else if (::strcmp(attr, "site") == 0)
		setResult(view.lookupSite(index));
	else if (::strcmp(attr, "game") == 0)
		setResult(view.lookupGame(index));
	else
		error(CmdMap, 0, 0, "unexpected attribute '%s'", attr);

	return TCL_OK;
}


static int
cmdSubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj*			proc		= objectFromObj(objc, objv, 1);
	Tcl_Obj*			base		= objectFromObj(objc, objv, 2);
	variant::Type	variant	= game::variantFromObj(objc, objv, 3);
	Tcl_Obj*			arg		= objc > 4 ? objv[4] : 0;

	mstl::string basename(Tcl_GetString(base));
	Cursor const& cursor = Scidb->cursor(basename); // don't cancel tree search

	SubscriberP& subscriber = ::subscriberMap[basename];

	if (!subscriber)
	{
		subscriber = new Subscriber;
		const_cast<Cursor&>(cursor).setSubscriber(subscriber);
	}

	subscriber->addProc(base, variant, proc, arg);

	return TCL_OK;
}


static int
cmdUnsubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj*			proc		= objectFromObj(objc, objv, 1);
	Tcl_Obj*			base		= objectFromObj(objc, objv, 2);
	variant::Type	variant	= game::variantFromObj(objc, objv, 3);
	Tcl_Obj*			arg		= objc > 4 ? objv[4] : 0;

	mstl::string basename(Tcl_GetString(base));
	SubscriberMap::iterator i = ::subscriberMap.find(basename);

	if (i != subscriberMap.end())
	{
		i->second->removeProc(base, variant, proc, arg);

		if (i->second->m_list.empty())
			::subscriberMap.erase(i);
	}

	return TCL_OK;
}


static int
cmdStrip(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 8)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<what> <database> <variant> <view> <attributes> <progress-cmd> <progress-arg> ");
		return TCL_ERROR;
	}

	char const*		what		= stringFromObj(objc, objv, 1);
	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 3);
	Cursor&			cursor	= scidb->cursor(database, variant);
	View&				view		= cursor.view(unsignedFromObj(objc, objv, 4));
	Tcl_Obj*			attrs		= objectFromObj(objc, objv, 5);
	Progress			progress(objv[6], objv[7]);

	if (::strcmp(what, "moveInfo") == 0)
	{
		Tcl_Obj** objs;

		if (Tcl_ListObjGetElements(ti, attrs, &objc, &objs) != TCL_OK)
			return error(CmdStrip, 0, 0, "list of attributes expected");

		unsigned types = 0;

		for (int i = 0; i < objc; ++i)
		{
			char const* attr = Tcl_GetString(objs[i]);

			if (::strcasecmp(attr, "evaluation") == 0)
				types |= 1 << MoveInfo::Evaluation;
			else if (::strcasecmp(attr, "playersClock") == 0)
				types |= 1 << MoveInfo::PlayersClock;
			else if (::strcasecmp(attr, "elapsedGameTime") == 0)
				types |= 1 << MoveInfo::ElapsedGameTime;
			else if (::strcasecmp(attr, "elapsedMoveTime") == 0)
				types |= 1 << MoveInfo::ElapsedMoveTime;
			else if (::strcasecmp(attr, "elapsedMilliSecs") == 0)
				types |= 1 << MoveInfo::ElapsedMilliSeconds;
			else if (::strcasecmp(attr, "clockTime") == 0)
				types |= 1 << MoveInfo::ClockTime;
			else if (::strcasecmp(attr, "corrChessSent") == 0)
				types |= 1 << MoveInfo::CorrespondenceChessSent;
			else if (::strcasecmp(attr, "videoTime") == 0)
				types |= 1 << MoveInfo::VideoTime;
			else
				return error(CmdStrip, 0, 0, "unknown attribute '%s'", attr);
		}

		setResult(scidb->stripMoveInformation(view, types, progress, Application::DontUpdateGameInfo));
	}
	else if (::strcmp(what, "tags") == 0)
	{
		typedef Application::TagMap TagMap;

		Tcl_Obj**	objs;
		TagMap		tags;

		if (Tcl_ListObjGetElements(ti, attrs, &objc, &objs) != TCL_OK)
			return error(CmdStrip, 0, 0, "list of attributes expected");

		for (int i = 0; i < objc; ++i)
			tags[Tcl_GetString(objs[i])] = 1;

		setResult(scidb->stripTags(view, tags, progress, Application::UpdateGameInfo));
	}
	else
	{
		return error(CmdStrip, 0, 0, "unexpected attribute '%s'", what);
	}

	return TCL_OK;
}


static int
cmdEnumTags(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	typedef View::TagMap TagMap;

	if (objc != 6)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<database> <variant> <view> <progress-cmd> <progress-arg> ");
		return TCL_ERROR;
	}

	char const*		database	= stringFromObj(objc, objv, 1);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 2);
	Cursor&			cursor	= scidb->cursor(database, variant);
	View&				view		= cursor.view(unsignedFromObj(objc, objv, 3));
	Progress			progress(objv[4], objv[5]);

	TagMap tags;
	Scidb->findTags(view, tags, progress);

	if (progress.interrupted())
	{
		setResult("interrupted");
	}
	else
	{
		Tcl_Obj* objs[tags.size()];
		unsigned n = 0;

		for (TagMap::const_iterator i = tags.begin(); i != tags.end(); ++i)
		{
			Tcl_Obj* v[2];

			v[0] = Tcl_NewStringObj(i->first, i->first.size());
			v[1] = Tcl_NewIntObj(i->second);

			M_ASSERT(n < tags.size());
			objs[n++] = Tcl_NewListObj(2, v);
		}

		M_ASSERT(n == tags.size());
		setResult(tags.size(), objs);
	}

	return TCL_OK;
}


namespace tcl {
namespace view {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdClose,			cmdClose);
	createCommand(ti, CmdCopy,				cmdCopy);
	createCommand(ti, CmdCount,			cmdCount);
	createCommand(ti, CmdEnumTags,		cmdEnumTags);
	createCommand(ti, CmdExport,			cmdExport);
	createCommand(ti, CmdFind,				cmdFind);
	createCommand(ti, CmdMap,				cmdMap);
	createCommand(ti, CmdNew,				cmdNew);
	createCommand(ti, CmdOpen,				cmdOpen);
	createCommand(ti, CmdPrint,			cmdPrint);
	createCommand(ti, CmdSearch,			cmdSearch);
	createCommand(ti, CmdStrip,				cmdStrip);
	createCommand(ti, CmdSubscribe,		cmdSubscribe);
	createCommand(ti, CmdUnsubscribe,	cmdUnsubscribe);
}

} // namespace view
} // namespace tcl

// vi:set ts=3 sw=3:
