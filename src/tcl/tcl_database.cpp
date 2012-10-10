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

#include "tcl_database.h"
#include "tcl_tree.h"
#include "tcl_application.h"
#include "tcl_pgn_reader.h"
#include "tcl_progress.h"
#include "tcl_exception.h"
#include "tcl_game.h"
#include "tcl_file.h"
#include "tcl_log.h"
#include "tcl_obj.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_database.h"
#include "db_database_codec.h"
#include "db_game_info.h"
#include "db_player.h"
#include "db_player_stats.h"
#include "db_site.h"
#include "db_statistic.h"
#include "db_pgn_reader.h"
#include "db_eco_table.h"
#include "db_exception.h"

#include "si3_decoder.h"
#include "si3_encoder.h"
#include "sci_codec.h"

#include "T_Controller.h"

#include "u_zstream.h"
#include "u_zlib_ostream.h"
#include "u_misc.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"

#include "m_vector.h"
#include "m_utility.h"
#include "m_algorithm.h"
#include "m_limits.h"
#include "m_tuple.h"
#include "m_sstream.h"
#include "m_auto_ptr.h"

#include <tcl.h>
#include <string.h>
#include <ctype.h>


using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::db;
using namespace tcl::app;
using namespace mstl;

static char const* CmdAttach			= "::scidb::db::attach";
static char const* CmdClear			= "::scidb::db::clear";
static char const* CmdClose			= "::scidb::db::close";
static char const* CmdCompact			= "::scidb::db::compact";
static char const* CmdCount			= "::scidb::db::count";
static char const* CmdFetch			= "::scidb::db::fetch";
static char const* CmdFind				= "::scidb::db::find";
static char const* CmdImport			= "::scidb::db::import";
static char const* CmdLoad				= "::scidb::db::load";
static char const* CmdNew				= "::scidb::db::new";
static char const* CmdSet				= "::scidb::db::set";
static char const* CmdGet				= "::scidb::db::get";
static char const* CmdMatch			= "::scidb::db::match";
static char const* CmdPlayerCard		= "::scidb::db::playerCard";
static char const* CmdPlayerInfo		= "::scidb::db::playerInfo";
static char const* CmdRecode			= "::scidb::db::recode";
static char const* CmdReverse			= "::scidb::db::reverse";
static char const* CmdSave				= "::scidb::db::save";
static char const* CmdSort				= "::scidb::db::sort";
static char const* CmdSubscribe		= "::scidb::db::subscribe";
static char const* CmdSwitch			= "::scidb::db::switch";
static char const* CmdUnsubscribe	= "::scidb::db::unsubscribe";
static char const* CmdUpdate			= "::scidb::db::update";
static char const* CmdUpgrade			= "::scidb::db::upgrade";
static char const* CmdWrite			= "::scidb::db::write";


static char const User1 = GameInfo::mapFlag(GameInfo::Flag_User1);
static char const User2 = GameInfo::mapFlag(GameInfo::Flag_User2);
static char const User3 = GameInfo::mapFlag(GameInfo::Flag_User3);
static char const User4 = GameInfo::mapFlag(GameInfo::Flag_User4);
static char const User5 = GameInfo::mapFlag(GameInfo::Flag_User5);
static char const User6 = GameInfo::mapFlag(GameInfo::Flag_User6);


enum
{
	PlayerKey_Name,
	PlayerKey_FideID,
	PlayerKey_Sex,
	PlayerKey_Country,
	PlayerKey_Title,
	PlayerKey_Type,
	PlayerKey_LAST,
};

enum
{
	EventKey_Name,
	EventKey_Type,
	EventKey_Date,
	EventKey_TimeMode,
	EventKey_EventMode,
	EventKey_Site,
	EventKey_SiteCountry,
	EventKey_LAST,
};

enum
{
	SiteKey_Site,
	SiteKey_Country,
	SiteKey_LAST,
};


__attribute__((unused))
static bool
checkNonZero(Tcl_Obj** objv, unsigned size)
{
	for (unsigned i = 0; i < size; ++i)
	{
		if (!objv[i])
			return false;
	}

	return true;
}


static Ratings
convRatings(char const* s)
{
	M_ASSERT(s);

	char const* t = s;

	while (*t && !::isspace(*t))
		++t;

	while (::isspace(*t))
		++t;

	return Ratings(rating::fromString(s), rating::fromString(t));
}


static void
mapScid4Flags(mstl::string& flags)
{
	for (unsigned i = 0; i < flags.size(); ++i)
	{
		char c = flags[i];

		if (!isspace(c))
		{
			if (c == User1)
				flags[i] = '1';
			else if (c == User2)
				flags[i] = '2';
			else if (c == User3)
				flags[i] = '3';
			else if (c == User4)
				flags[i] = '4';
			else if (c == User5)
				flags[i] = '5';
			else if (c == User6)
				flags[i] = '6';
		}
	}
}


static void
remapScid4Flags(mstl::string& flags)
{
	for (unsigned i = 0; i < flags.size(); ++i)
	{
		switch (flags[i])
		{
			case '1': flags[i] = User1; break;
			case '2': flags[i] = User2; break;
			case '3': flags[i] = User3; break;
			case '4': flags[i] = User4; break;
			case '5': flags[i] = User5; break;
			case '6': flags[i] = User6; break;
		}
	}
}


static Namebase::Type
getNamebaseType(Tcl_Obj* obj, char const* cmd)
{
	static char const* Keywords[] = { "player", "event", "site", "annotator", 0 };
	enum { Type_Player, Type_Event, Type_Site, Type_Annotator };

	switch (tcl::uniqueMatchObj(obj, Keywords))
	{
		case Type_Player:		return Namebase::Player;
		case Type_Event:		return Namebase::Event;
		case Type_Site:		return Namebase::Site;
		case Type_Annotator:	return Namebase::Annotator;
	}

	error(cmd, nullptr, nullptr, "unknown namebase type '%s'", Tcl_GetString(obj));
	return Namebase::Player;	// never reached
}


namespace {

struct Subscriber : public Application::Subscriber
{
	enum Type
	{
		DatabaseInfo	= 1 << 0,
		GameList			= 1 << 1,
		PlayerList		= 1 << 2,
		EventList		= 1 << 3,
		SiteList			= 1 << 4,
		AnnotatorList	= 1 << 5,
		GameInfo			= 1 << 6,
		GameHistory		= 1 << 7,
		GameSwitched	= 1 << 8,
		Tree				= 1 << 9,
	};

	typedef mstl::tuple<Obj, Obj, Obj> Tuple;

	struct Args
	{
		Args(Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
			:m_type(type)
			,m_tuple(updateCmd, closeCmd, arg ? arg : Tcl_NewListObj(0, 0))
		{
		}

		void ref()		{ m_tuple.get<0>().ref(); m_tuple.get<1>().ref(); m_tuple.get<2>().ref(); }
		void deref()	{ m_tuple.get<0>().deref(); m_tuple.get<1>().deref(); m_tuple.get<2>().deref(); }

		Type	m_type;
		Tuple	m_tuple;

		bool operator==(Args const& args) const
		{
			return m_type == args.m_type && m_tuple == args.m_tuple;
		}

		Tcl_Obj* getUpdate() const	{ return m_tuple.get<0>(); }
		Tcl_Obj* getClose() const	{ return m_tuple.get<1>(); }
		Tcl_Obj* getArg() const		{ return m_tuple.get<2>(); }
	};

	typedef vector<Args> ArgsList;
	ArgsList m_list;

	void setCmd(Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		m_list.push_back(Args(type, updateCmd, closeCmd, arg));
		m_list.back().ref();
	}

	void unsetCmd(Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		Args args(type, updateCmd, closeCmd, arg);

		ArgsList::iterator i = mstl::find(m_list.begin(), m_list.end(), args);

		if (i == m_list.end())
		{
			fprintf(	stderr,
						"Warning: database::unsubscribe failed (%s, %s, %s)\n",
						Tcl_GetString(updateCmd),
						closeCmd ? Tcl_GetString(closeCmd) : "",
						Tcl_GetString(arg));
		}
		else
		{
			i->deref();
			m_list.erase(i);
		}
	}

	void setDatabaseInfoCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(DatabaseInfo, updateCmd, closeCmd, arg);
	}

	void setGameListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(GameList, updateCmd, closeCmd, arg);
	}

	void setPlayerListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(PlayerList, updateCmd, closeCmd, arg);
	}

	void setEventListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(EventList, updateCmd, closeCmd, arg);
	}

	void setSiteListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(SiteList, updateCmd, closeCmd, arg);
	}

	void setAnnotatorListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(AnnotatorList, updateCmd, closeCmd, arg);
	}

	void setGameInfoCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(GameInfo, updateCmd, closeCmd, arg);
	}

	void setGameHistoryCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(GameHistory, updateCmd, closeCmd, arg);
	}

	void setGameSwitchedCmd(Tcl_Obj* updateCmd)
	{
		setCmd(GameSwitched, updateCmd, 0, 0);
	}

	void setTreeCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(Tree, updateCmd, closeCmd, arg);
	}

	void unsetDatabaseInfoCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(DatabaseInfo, updateCmd, closeCmd, arg);
	}

	void unsetGameListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(GameList, updateCmd, closeCmd, arg);
	}

	void unsetPlayerListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(PlayerList, updateCmd, closeCmd, arg);
	}

	void unsetEventListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(EventList, updateCmd, closeCmd, arg);
	}

	void unsetSiteListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(SiteList, updateCmd, closeCmd, arg);
	}

	void unsetAnnotatorListCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(AnnotatorList, updateCmd, closeCmd, arg);
	}

	void unsetGameInfoCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(GameInfo, updateCmd, closeCmd, arg);
	}

	void unsetGameHistoryCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(GameHistory, updateCmd, closeCmd, arg);
	}

	void unsetTreeCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(Tree, updateCmd, closeCmd, arg);
	}

	void closeDatabase(mstl::string const& filename) override
	{
		Tcl_Obj* file = Tcl_NewStringObj(filename, filename.size());
		Tcl_IncrRefCount(file);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->getClose())
				invoke(__func__, i->getClose(), i->getArg(), file, nullptr);
		}

		Tcl_DecrRefCount(file);
	}

	void updateDatabaseInfo(mstl::string const& filename) override
	{
		Tcl_Obj* f = Tcl_NewStringObj(filename, filename.size());

		Tcl_IncrRefCount(f);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type & DatabaseInfo)
				invoke(__func__, i->getUpdate(), i->getArg(), f, nullptr);
		}

		Tcl_DecrRefCount(f);
	}

	void updateList(unsigned id, string const& filename, unsigned view, unsigned index, Type type)
	{
		Tcl_Obj* n = Tcl_NewIntObj(id);
		Tcl_Obj* f = Tcl_NewStringObj(filename, filename.size());
		Tcl_Obj* v = Tcl_NewIntObj(view);
		Tcl_Obj* w = Tcl_NewIntObj(index);

		Tcl_IncrRefCount(n);
		Tcl_IncrRefCount(f);
		Tcl_IncrRefCount(v);
		Tcl_IncrRefCount(w);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type & type)
				invoke(__func__, i->getUpdate(), i->getArg(), n, f, v, w, nullptr);
		}

		Tcl_DecrRefCount(n);
		Tcl_DecrRefCount(f);
		Tcl_DecrRefCount(v);
		Tcl_DecrRefCount(w);
	}

	void updateGameList(unsigned id, string const& filename) override
	{
		updateList(id, filename, unsigned(-1), unsigned(-1), GameList);
	}

	void updateGameList(unsigned id, string const& filename, unsigned view) override
	{
		updateList(id, filename, view, unsigned(-1), GameList);
	}

	void updateGameList(unsigned id, string const& filename, unsigned view, unsigned index) override
	{
		updateList(id, filename, view, index, GameList);
	}

	void updatePlayerList(unsigned id, mstl::string const& filename) override
	{
		updateList(id, filename, unsigned(-1), unsigned(-1), PlayerList);
	}

	void updatePlayerList(unsigned id, mstl::string const& filename, unsigned view) override
	{
		updateList(id, filename, view, unsigned(-1), PlayerList);
	}

	void updatePlayerList(unsigned id, mstl::string const& filename, unsigned view, unsigned index) override
	{
		updateList(id, filename, view, index, PlayerList);
	}

	void updateEventList(unsigned id, mstl::string const& filename) override
	{
		updateList(id, filename, unsigned(-1), unsigned(-1), EventList);
	}

	void updateEventList(unsigned id, mstl::string const& filename, unsigned view) override
	{
		updateList(id, filename, view, unsigned(-1), EventList);
	}

	void updateEventList(unsigned id, mstl::string const& filename, unsigned view, unsigned index) override
	{
		updateList(id, filename, view, index, EventList);
	}

	void updateSiteList(unsigned id, mstl::string const& filename) override
	{
		updateList(id, filename, unsigned(-1), unsigned(-1), SiteList);
	}

	void updateSiteList(unsigned id, mstl::string const& filename, unsigned view) override
	{
		updateList(id, filename, view, unsigned(-1), SiteList);
	}

	void updateSiteList(unsigned id, mstl::string const& filename, unsigned view, unsigned index) override
	{
		updateList(id, filename, view, index, SiteList);
	}

	void updateAnnotatorList(unsigned id, mstl::string const& filename) override
	{
		updateList(id, filename, unsigned(-1), unsigned(-1), AnnotatorList);
	}

	void updateAnnotatorList(unsigned id, mstl::string const& filename, unsigned view) override
	{
		updateList(id, filename, view, unsigned(-1), AnnotatorList);
	}

	void updateAnnotatorList(unsigned id, mstl::string const& filename, unsigned view, unsigned index) override
	{
		updateList(id, filename, view, index, AnnotatorList);
	}

	void updateGameInfo(unsigned position) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_IncrRefCount(pos);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type == GameInfo)
				invoke(__func__, i->getUpdate(), i->getArg(), pos, nullptr);
		}

		Tcl_DecrRefCount(pos);
	}

	void updateGameInfo(mstl::string const& filename, unsigned index) override
	{
		Tcl_Obj* f = Tcl_NewStringObj(filename, filename.size());
		Tcl_Obj* w = Tcl_NewIntObj(index);

		Tcl_IncrRefCount(f);
		Tcl_IncrRefCount(w);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type == GameHistory)
				invoke(__func__, i->getUpdate(), i->getArg(), f, w, nullptr);
		}

		Tcl_DecrRefCount(f);
		Tcl_DecrRefCount(w);
	}

	void gameSwitched(unsigned position) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_IncrRefCount(pos);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type == GameSwitched)
				invoke(__func__, i->getUpdate(), pos, nullptr);
		}

		Tcl_DecrRefCount(pos);
	}

	void updateTree(mstl::string const& filename) override
	{
		static mstl::string prevFilename;

		if (filename != prevFilename)
		{
			prevFilename = filename;
			tcl::tree::referenceBaseChanged();
		}

		Tcl_Obj* file = Tcl_NewStringObj(filename, filename.size());
		Tcl_IncrRefCount(file);

		for (ArgsList::const_iterator i = m_list.begin(); i != m_list.end(); ++i)
		{
			if (i->m_type == Tree)
				invoke(__func__, i->getUpdate(), i->getArg(), file, nullptr);
		}

		Tcl_DecrRefCount(file);
	}
};

} // namespace



char const*
tcl::db::lookupType(type::ID type)
{
	switch (type)
	{
		case type::Unspecific:					return "Unspecific";
		case type::Temporary:					return "Temporary";
		case type::Work:							return "Work";
		case type::Clipbase:						return "Clipbase";
		case type::My_Games:						return "MyGames";
		case type::Informant:					return "Informant";
		case type::Large_Database:				return "LargeDatabase";
		case type::Correspondence_Chess:		return "CorrespondenceChess";
		case type::Email_Chess:					return "EmailChess";
		case type::Internet_Chess:				return "InternetChess";
		case type::Computer_Chess:				return "ComputerChess";
		case type::Chess_960:					return "Chess960";
		case type::Player_Collection:			return "PlayerCollection";
		case type::Tournament:					return "Tournament";
		case type::Tournament_Swiss:			return "TournamentSwiss";
		case type::GM_Games:						return "GMGames";
		case type::IM_Games:						return "IMGames";
		case type::Blitz_Games:					return "BlitzGames";
		case type::Tactics:						return "Tactics";
		case type::Endgames:						return "Endgames";
		case type::Analysis:						return "Analysis";
		case type::Training:						return "Training";
		case type::Match:							return "Match";
		case type::Studies:						return "Studies";
		case type::Jewels:						return "Jewels";
		case type::Problems:						return "Problems";
		case type::Patzer:						return "Patzer";
		case type::Gambit:						return "Gambit";
		case type::Important:					return "Important";
		case type::Openings_White:				return "OpeningsWhite";
		case type::Openings_Black:				return "OpeningsBlack";
		case type::Openings:						return "Openings";
		case type::Bughouse:						return "Bughouse";
		case type::Antichess:					return "Antichess";
		case type::PlayerCollectionFemale:	return "PlayerCollectionFemale";
		case type::PGNFile:						return "PGNFile";
	}

	return 0;	// not reached
}


static attribute::game::ID
lookupGameInfo(Tcl_Obj* obj, Ratings& ratings, bool averageFlag)
{
	int column;

	if (	Tcl_GetIntFromObj(interp(), obj, &column) != TCL_OK
		|| column < 0
		|| column >= attribute::game::LastColumn)
	{
		appendResult(	"integer in range 0-%d expected", attribute::game::LastColumn - 1);
		return attribute::game::ID(-1);
	}

	switch (column)
	{
		case attribute::game::WhiteRating2:
			ratings.first = ratings.second;
			// fallthru

		case attribute::game::WhiteRating1:
			if (ratings.first == rating::Elo)
				column = averageFlag ? attribute::game::AverageElo : attribute::game::WhiteElo;
			else
				column = averageFlag ? attribute::game::AverageRating : attribute::game::WhiteRating;
			break;

		case attribute::game::BlackRating2:
			ratings.first = ratings.second;
			// fallthru

		case attribute::game::BlackRating1:
			if (ratings.first == rating::Elo)
				column = averageFlag ? attribute::game::AverageElo : attribute::game::BlackElo;
			else
				column = averageFlag ? attribute::game::AverageRating : attribute::game::BlackRating;
			break;

		default:
			if (averageFlag)
			{
				appendResult(	"'average' not allowed for column %d", column);
				return attribute::game::ID(-1);
			}
			break;
	}

	return attribute::game::ID(column);
}


static attribute::player::ID
lookupPlayerBase(Tcl_Obj* obj, Ratings& ratings, bool latest)
{
	int column;

	if (	Tcl_GetIntFromObj(interp(), obj, &column) != TCL_OK
		|| column < 0
		|| column >= attribute::player::LastColumn)
	{
		appendResult(	"integer in range 0-%d expected", attribute::player::LastColumn - 1);
		return attribute::player::ID(-1);
	}

	switch (column)
	{
		case attribute::player::Rating2:
			ratings.first = ratings.second;
			// fallthru

		case attribute::player::Rating1:
			if (latest)
			{
				column = ratings.first == rating::Elo
								? attribute::player::EloLatest
								: attribute::player::RatingLatest;
			}
			else
			{
				column = ratings.first == rating::Elo
								? attribute::player::EloHighest
								: attribute::player::RatingHighest;
			}
			break;
	}

	return attribute::player::ID(column);
}


static attribute::event::ID
lookupEventBase(Tcl_Obj* obj)
{
	int column;

	if (	Tcl_GetIntFromObj(interp(), obj, &column) != TCL_OK
		|| column < 0
		|| column >= attribute::event::LastColumn)
	{
		appendResult(	"integer in range 0-%d expected", attribute::event::LastColumn - 1);
		return attribute::event::ID(-1);
	}

	return attribute::event::ID(column);
}


static attribute::site::ID
lookupSiteBase(Tcl_Obj* obj)
{
	int column;

	if (	Tcl_GetIntFromObj(interp(), obj, &column) != TCL_OK
		|| column < 0
		|| column >= attribute::site::LastColumn)
	{
		appendResult(	"integer in range 0-%d expected", attribute::site::LastColumn - 1);
		return attribute::site::ID(-1);
	}

	return attribute::site::ID(column);
}


static attribute::annotator::ID
lookupAnnotatorBase(Tcl_Obj* obj)
{
	int column;

	if (	Tcl_GetIntFromObj(interp(), obj, &column) != TCL_OK
		|| column < 0
		|| column >= attribute::annotator::LastColumn)
	{
		appendResult(	"integer in range 0-%d expected", attribute::annotator::LastColumn - 1);
		return attribute::annotator::ID(-1);
	}

	return attribute::annotator::ID(column);
}


static int
convToType(char const* cmd, Tcl_Obj* typeObj, int* type)
{
	if (Tcl_GetIntFromObj(interp(), typeObj, type) != TCL_OK)
	{
		return error(	cmd,
							nullptr,
							nullptr,
							"integer expected for type (given: %s)",
							Tcl_GetString(typeObj));
	}

	if (0 > *type || *type > ::db::type::LAST)
		return error(cmd, nullptr, nullptr, "given type exceeds range 0-%d", int(::db::type::LAST));

	return TCL_OK;
}


static int
cmdAttach(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3)
	{
		Tcl_WrongNumArgs(	ti, 1, objv, "<file> <file>");
		return TCL_ERROR;
	}

	char const* database	= stringFromObj(objc, objv, 1);
	char const* filename = stringFromObj(objc, objv, 2);

	if (objc >= 5)
	{
		Progress progress(objv[3], objv[4]);
		scidb->cursor(database).database().attach(filename, progress);
	}
	else
	{
		util::Progress progress;
		scidb->cursor(database).database().attach(filename, progress);
	}

	return TCL_OK;
}


static int
cmdLoad(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4 && objc != 6)
	{
		Tcl_WrongNumArgs(	ti, 1, objv, "<file> <progress-cmd> <arg> ?-encoding <string>?");
		return TCL_ERROR;
	}

	char const* encoding = sys::utf8::Codec::utf8();

	if (objc == 6)
	{
		encoding = stringFromObj(objc, objv, 5);

		if (::strcmp(stringFromObj(objc, objv, 4), "-encoding"))
		{
			appendResult("unexpected option '%s'", stringFromObj(objc, objv, 4));
			return TCL_ERROR;
		}
		encoding = Tcl_GetString(objv[5]);
	}

//	mstl::string path(Tcl_FSGetNativePath(objv[1]));
	mstl::string path(Tcl_GetString(objv[1]));

	if (util::misc::file::suffix(path) == "sci")
		encoding = sys::utf8::Codec::utf8();

	Progress	progress(objv[2], objv[3]);
	progress.checkInterruption();

	Cursor* cursor = scidb->open(path, encoding, false, progress);

	if (cursor == 0)
		return TCL_ERROR;

	if (cursor->database().name() != path)
	{
		mstl::string msg;

		msg += "file ";
		msg += path;
		msg += " conflicts with open file ";
		msg += cursor->database().name();

		return ioError(cursor->database().name(), "HardLinkDetected", msg);
	}

	setResult(lookupType(cursor->type()));
	return TCL_OK;
}


static int
cmdImport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 7 && objc != 9)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<database> <file> <log> <log-arg> <progress-cmd> <progress-arg> "
			"?-encoding <string>? ?-description <flag>");
		return TCL_ERROR;
	}

	mstl::string	encoding		= sys::utf8::Codec::utf8();
	char const*		option		= stringFromObj(objc, objv, objc - 2);
	bool				description	= false;

	if (*option == '-')
	{
		if (::strcmp(option, "-encoding") == 0)
		{
			encoding = stringFromObj(objc, objv, objc - 1);
		}
		else if (::strcmp(option, "-description") == 0)
		{
			description = boolFromObj(objc, objv, objc - 1);
		}
		else
		{
			appendResult("unexpected option '%s'", option);
			return TCL_ERROR;
		}

		objc -= 2;
	}

	mstl::string	dst(stringFromObj(objc, objv, 1));
	mstl::string	src(stringFromObj(objc, objv, 2));
	mstl::string	ext(::util::misc::file::suffix(src));
	Cursor&			cursor(scidb->cursor(dst));
	Progress			progress(objv[5], objv[6]);
	unsigned			n;

	if (ext == "sci" || ext == "si3" || ext == "si4")
	{
		tcl::Log log(objv[3], objv[4]);

		if (scidb->contains(src))
		{
			n = cursor.importGames(
				const_cast< ::db::Database&>(Scidb->cursor(src).database()), log, progress);
		}
		else
		{
			mstl::auto_ptr< ::db::Database> db;

			try
			{
				db = new ::db::Database(src, encoding, ::db::Database::Temporary);
			}
			catch (...)
			{
				appendResult("cannot open file '%s'", src.c_str());
				return TCL_ERROR;
			}

			n = cursor.importGames(*db, log, progress);
		}
	}
	else if (ext == "pgn" || ext == "gz" || ext == "zip")
	{
		util::ZStream stream(sys::file::internalName(src), ios_base::in);

		if (!stream)
		{
			appendResult("cannot open file '%s'", src.c_str());
			return TCL_ERROR;
		}

		tcl::PgnReader	reader(	stream,
										encoding,
										objv[3],
										objv[4],
										tcl::PgnReader::Normalize,
										cursor.countGames());

		n = cursor.importGames(reader, progress);
		if (description)
			cursor.setDescription(reader.description());
		stream.close();
	}
	else
	{
		appendResult("unsupported extension '%s'", ext.c_str());
		return TCL_ERROR;
	}

	if (progress.interrupted())
		throw InterruptException(n);

	setResult(n);
	return TCL_OK;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<file> <type> ?<encoding>?");
		return TCL_ERROR;
	}

	char const* path = stringFromObj(objc, objv, 1);
	int type;

	if (convToType(::CmdSet, objv[2], &type) != TCL_OK)
		return TCL_ERROR;

	mstl::string encoding;

	if (objc == 4)
		encoding = stringFromObj(objc, objv, 3);

	mstl::string suffix(util::misc::file::suffix(path));

	if (suffix == "pgn" || suffix == "gz" || suffix == "zip")
	{
		// currently we do not support charset detection for PGN files
		if (encoding.empty() || encoding == sys::utf8::Codec::automatic())
			encoding = sys::utf8::Codec::latin1();
	}
	else if (encoding.empty() || encoding == sys::utf8::Codec::automatic())
	{
		encoding = sys::utf8::Codec::utf8();
	}

	if (scidb->create(path, encoding, type::ID(type)) == 0)
		return error(::CmdNew, nullptr, nullptr, "database '%s' already exists", path);

	return TCL_OK;
}


static int
cmdSet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"type", "description", "readonly", "delete", "flag", 0
	};
	static char const* args[] =
	{
		"<database> <number>",
		"<database> <string>",
		"?<database>? <bool>",
		"<index> ?<view> ?<database>?? <value>",
		"<index> ?<view> ?<database>?? <flag> <value>",
	};
	enum { Cmd_Type, Cmd_Description, Cmd_Readonly, Cmd_Delete, Cmd_Flag };

	if (objc < 2)
		return usage(::CmdSet, nullptr, nullptr, subcommands, args);

	int cmd = tcl::uniqueMatchObj(objv[1], subcommands);

	switch (cmd)
	{
		case Cmd_Delete:
			scidb->deleteGame(
				scidb->cursor(objc < 5 ? 0 : stringFromObj(objc, objv, 4)),
				intFromObj(objc, objv, 2),
				objc < 5 ? 0 : intFromObj(objc, objv, 3),
				intFromObj(objc, objv, objc < 5 ? 3 : 5));
			break;

		case Cmd_Flag:
			{
				int index	= intFromObj(objc, objv, 2);
				int view		= objc < 6 ? 0 : intFromObj(objc, objv, 3);

				char const* base = objc < 6 ? 0 : stringFromObj(objc, objv, 4);

				Cursor& cursor = scidb->cursor(base);
				mstl::string flags(stringFromObj(objc, objv, objc < 6 ? 3 : 5));

				if (cursor.database().format() == format::Scid4)
					::remapScid4Flags(flags);

				unsigned oldFlags = cursor.database().gameInfo(cursor.gameIndex(index, view)).flags();
				unsigned newFlags = GameInfo::stringToFlags(flags);
				bool		value		= boolFromObj(objc, objv, objc < 6 ? 4 : 6);

				if (value)
					oldFlags |= newFlags;
				else
					oldFlags &= ~newFlags;

				scidb->setGameFlags(cursor, index, view, oldFlags);
			}
			break;

		case Cmd_Type:
			{
				int type;
				if (convToType(::CmdSet, objv[3], &type) != TCL_OK)
					return TCL_ERROR;
				scidb->cursor(stringFromObj(objc, objv, 2)).database().setType(type::ID(type));
			}
			break;

		case Cmd_Description:
			{
				Database& db = scidb->cursor(stringFromObj(objc, objv, 2)).database();
				char const* descr = stringFromObj(objc, objv, 3);

				if (strlen(descr) <= db.maxDescriptionLength())
				{
					db.setDescription(descr);
					setResult(unsigned(0));
				}
				else
				{
					setResult(db.maxDescriptionLength());
				}
			}
			break;

		case Cmd_Readonly:
			if (objc == 4)
			{
				scidb->cursor(
					stringFromObj(objc, objv, 2)).database().setReadOnly(boolFromObj(objc, objv, 3));
			}
			else
			{
				scidb->cursor().database().setReadOnly(boolFromObj(objc, objv, 2));
			}
			break;

		default:
			return usage(::CmdSet, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
countGames(char const* database)
{
	::tcl::setResult(Scidb->cursor(database).countGames());
	return TCL_OK;
}


static int
countPlayers(char const* database)
{
	::tcl::setResult(Scidb->cursor(database).countPlayers());
	return TCL_OK;
}


static int
countEvents(char const* database)
{
	::tcl::setResult(Scidb->cursor(database).countEvents());
	return TCL_OK;
}


static int
countSites(char const* database)
{
	::tcl::setResult(Scidb->cursor(database).countSites());
	return TCL_OK;
}


static int
countAnnotators(char const* database)
{
	::tcl::setResult(Scidb->cursor(database).countAnnotators());
	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "games", "players", "annotators", "events", "sites", 0 };
	static char const* args[] =
	{
		"?<database>?", "?<database>?", "?<database>?", "?<database>?", "?<database>?",
	};
	enum { Cmd_Games, Cmd_Players, Cmd_Annotators, Cmd_Events, Cmd_Sites };

	if (objc < 2)
		return usage(::CmdCount, nullptr, nullptr, subcommands, args);

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	char const* base = objc < 3 ? 0 : Tcl_GetString(objv[2]);

	switch (index)
	{
		case Cmd_Players:		return countPlayers(base);
		case Cmd_Annotators:	return countAnnotators(base);
		case Cmd_Games:		return countGames(base);
		case Cmd_Events:		return countEvents(base);
		case Cmd_Sites:		return countSites(base);
	}

	return usage(::CmdCount, nullptr, nullptr, subcommands, args);
}


static int
getClipbaseAttr(Tcl_Interp*, char const* attr)
{
	if (strcmp(attr, "name") == 0)
		setResult(Scidb->clipbaseName());
	else if (strcmp(attr, "type") == 0)
		setResult(lookupType(type::Clipbase));
	else
		return error(::CmdGet, "clipbase", nullptr, "invalid subcommand '%s'", attr);

	return TCL_OK;
}


static int
getScratchbaseAttr(Tcl_Interp*, char const* attr)
{
	if (strcmp(attr, "name") == 0)
		setResult(Scidb->scratchbaseName());
	else
		return error(::CmdGet, "scratchbase", nullptr, "invalid subcommand '%s'", attr);

	return TCL_OK;
}


static int
getTypes(Tcl_Interp* ti, char const* suffix)
{
	Tcl_Obj* list = Tcl_NewListObj(0, 0);

	if (::strcmp(suffix, "sci") == 0)
	{
		for (int i = 0; i <= type::LAST; ++i)
			Tcl_ListObjAppendElement(ti, list, Tcl_NewStringObj(lookupType(type::ID(i)), -1));
	}
	else	// si3, si4
	{
		for (int i = 0; i <= type::LAST; ++i)
		{
			type::ID type = type::ID(i);

			if (si3::Decoder::decodeType(si3::Encoder::encodeType(type)) == type)
				Tcl_ListObjAppendElement(ti, list, Tcl_NewStringObj(lookupType(type), -1));
		}
	}

	setResult(list);
	return TCL_OK;
}


static int
getName()
{
	::tcl::setResult(Scidb->cursor().name());
	return TCL_OK;
}


static int
getCodec(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().extension());
	return TCL_OK;
}


static int
getEncoding(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().encoding());
	return TCL_OK;
}


static int
getCreated(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().created().asString());
	return TCL_OK;
}


static int
getModified(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().modified().asString());
	return TCL_OK;
}


static int
getReadonly(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().isReadOnly());
	return TCL_OK;
}


static int
getWriteable(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().isWriteable());
	return TCL_OK;
}


static int
getDescription(char const* database = 0)
{
	::tcl::setResult(Scidb->cursor(database).database().description());
	return TCL_OK;
}


static int
getType(char const* database = 0)
{
	::tcl::setResult(lookupType(Scidb->cursor(database).type()));
	return TCL_OK;
}


static int
getGameIndex(int number, int view, char const* database)
{
	Cursor const& cursor = Scidb->cursor(database);
	View const& v = cursor.view(view);

	if (number < int(v.totalGames()))
		::tcl::setResult(v.lookupGame(number));
	else
		::tcl::setResult(-1);

	return TCL_OK;
}


static int
getPlayerIndex(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).playerIndex(index));
	return TCL_OK;
}


static int
getLookupPlayer(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).lookupPlayer(index));
	return TCL_OK;
}


static int
getEventIndex(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).eventIndex(index));
	return TCL_OK;
}


static int
getSiteIndex(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).siteIndex(index));
	return TCL_OK;
}


static int
getLookupEvent(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).lookupEvent(index));
	return TCL_OK;
}


static int
getLookupSite(unsigned index, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).lookupSite(index));
	return TCL_OK;
}


static int
getAnnotatorIndex(char const* name, int view, char const* database)
{
	::tcl::setResult(Scidb->cursor(database).view(view).lookupAnnotator(name));
	return TCL_OK;
}


static int
getStats(char const* database)
{
	Statistic const& statistic = Scidb->cursor(database).database().statistic();
	Tcl_Obj*	objv[12];

	objv[ 0] = Tcl_NewIntObj(statistic.deleted);
	objv[ 1] = Tcl_NewIntObj(statistic.minYear);
	objv[ 2] = Tcl_NewIntObj(statistic.maxYear);
	objv[ 3] = Tcl_NewIntObj(statistic.avgYear);
	objv[ 4] = Tcl_NewIntObj(statistic.minElo);
	objv[ 5] = Tcl_NewIntObj(statistic.maxElo);
	objv[ 6] = Tcl_NewIntObj(statistic.avgElo);
	objv[ 7] = Tcl_NewIntObj(statistic.result[0]);
	objv[ 8] = Tcl_NewIntObj(statistic.result[1]);
	objv[ 9] = Tcl_NewIntObj(statistic.result[2]);
	objv[10] = Tcl_NewIntObj(statistic.result[3]);
	objv[11] = Tcl_NewIntObj(statistic.result[4]);

	setResult(U_NUMBER_OF(objv), objv);

	return TCL_OK;
}


static int
findRating(GameInfo const& info, color::ID color, rating::Type type)
{
	int value = info.findRating(color, type);

	if (!info.isGameRating(color, type))
		value = -value;

	return value;
}


static void
playerRatings(NamebasePlayer const& player, rating::Type type, int16_t* ratings)
{
	ratings[0] = player.playerHighestRating(type);
	ratings[1] = player.playerLatestRating(type);

	if (!player.isPlayerRating(type))
	{
		ratings[0] = -ratings[0];
		ratings[1] = -ratings[1];
	}
}


static int
getPlayerKey(NamebasePlayer const& player)
{
	Tcl_Obj* objv[PlayerKey_LAST];

	objv[PlayerKey_Name]		= Tcl_NewStringObj(player.name(), player.name().size());
	objv[PlayerKey_FideID]	= player.haveFideId() ? Tcl_NewIntObj(player.fideID()) : Tcl_NewListObj(0, 0);
	objv[PlayerKey_Sex]		= Tcl_NewStringObj(sex::toString(player.sex()), -1);
	objv[PlayerKey_Country]	= Tcl_NewStringObj(country::toString(player.federation()), -1);
	objv[PlayerKey_Title]	= Tcl_NewStringObj(title::toString(player.title()), -1);
	objv[PlayerKey_Type]		= Tcl_NewStringObj(species::toString(player.type()), -1);

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getEventKey(NamebaseEvent const& event)
{
	Tcl_Obj* objv[EventKey_LAST];

	objv[EventKey_Name]			= Tcl_NewStringObj(event.name(), event.name().size());
	objv[EventKey_Type]			= Tcl_NewStringObj(event::toString(event.type()), -1);
	objv[EventKey_Date]			= Tcl_NewStringObj(event.date().asString(), -1);
	objv[EventKey_TimeMode]		= Tcl_NewStringObj(time::toString(event.timeMode()), -1);
	objv[EventKey_EventMode]	= Tcl_NewStringObj(event::toString(event.eventMode()), -1);
	objv[EventKey_Site]			= Tcl_NewStringObj(event.site()->name(), event.site()->name().size());
	objv[EventKey_SiteCountry]	= Tcl_NewStringObj(country::toString(event.site()->country()), -1);

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getSiteKey(NamebaseSite const& site)
{
	Tcl_Obj* objv[SiteKey_LAST];

	objv[SiteKey_Site]		= Tcl_NewStringObj(site.name(), site.name().size());
	objv[SiteKey_Country]	= Tcl_NewStringObj(country::toString(site.country()), -1);

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getGameInfo(int index, int view, char const* database, unsigned which)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.gameIndex(index, view);

	GameInfo const& info = cursor.database().gameInfo(index);
	Tcl_Obj* obj;

	switch (which)
	{
		case attribute::game::WhiteCountry:
			obj = Tcl_NewStringObj(country::toString(info.findFederation(color::White)), -1);
			break;

		case attribute::game::WhiteTitle:
			obj = Tcl_NewStringObj(title::toString(info.findTitle(color::White)), -1);
			break;

		case attribute::game::WhiteSex:
			obj = Tcl_NewStringObj(sex::toString(info.findSex(color::White)), 1);
			break;

		case attribute::game::WhiteType:
			obj = Tcl_NewStringObj(species::toString(info.findPlayerType(color::White)), -1);
			break;

		case attribute::game::BlackCountry:
			obj = Tcl_NewStringObj(country::toString(info.findFederation(color::Black)), -1);
			break;

		case attribute::game::BlackTitle:
			obj = Tcl_NewStringObj(title::toString(info.findTitle(color::Black)), -1);
			break;

		case attribute::game::BlackSex:
			obj = Tcl_NewStringObj(sex::toString(info.findSex(color::Black)), 1);
			break;

		case attribute::game::BlackType:
			obj = Tcl_NewStringObj(species::toString(info.findPlayerType(color::Black)), -1);
			break;

		case attribute::game::WhiteRatingType:
			obj = Tcl_NewStringObj(rating::toString(info.findRatingType(color::White)), -1);
			break;

		case attribute::game::BlackRatingType:
			obj = Tcl_NewStringObj(rating::toString(info.findRatingType(color::Black)), -1);
			break;

		case attribute::game::Idn:
			{
				mstl::string position;

				if (info.idn())
					shuffle::utf8::position(info.idn(), position);

				obj = Tcl_NewStringObj(position, position.size());
			}
			break;

		case attribute::game::Eco:
		case attribute::game::Overview:
		case attribute::game::Opening:
		case attribute::game::InternalEco:
			{
				mstl::string openingLong, openingShort, variation, subvar, position;
				Eco eco;

				if (which == attribute::game::Eco || which == attribute::game::Opening)
					eco = info.userEco();
				else
					eco = info.ecoKey();

				if (info.idn() == variant::StandardIdn && eco)
				{
					EcoTable::specimen().getOpening(eco, openingLong, openingShort, variation, subvar);

					if (eco.basic() == info.ecoKey().basic())
					{
						mstl::string unused;
						EcoTable::specimen().getOpening(info.ecoKey(), unused, unused, variation, subvar);
					}
					else
					{
						variation.clear();
						subvar.clear();
					}
				}

				if (info.idn())
					shuffle::utf8::position(info.idn(), position);

				Tcl_Obj* objv[6];

				Tcl_Obj* openingVar[2] =
				{
					Tcl_NewStringObj(openingLong, openingLong.size()),
					Tcl_NewStringObj(openingShort, openingShort.size())
				};

				objv[0] = Tcl_NewIntObj(info.idn());
				objv[1] = Tcl_NewStringObj(position, position.size());
				objv[2] = Tcl_NewStringObj(eco.asShortString(), -1);
				objv[3] = Tcl_NewListObj(2, openingVar);
				objv[4] = Tcl_NewStringObj(variation, variation.size());
				objv[5] = Tcl_NewStringObj(subvar, subvar.size());

				obj = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
			}
			break;

		case attribute::game::Acv:
			{
				char acv[100];

				int acvSize = sprintf(	acv,
												"%u %u %u",
												info.countAnnotations(),
												info.countComments(),
												info.countVariations());
				obj = Tcl_NewStringObj(acv, acvSize);
			}
			break;

		case attribute::game::Flags:
			{
				mstl::string flags;

				GameInfo::flagsToString(info.flags(), flags);
				if (cursor.database().format() == format::Scid4)
					::mapScid4Flags(flags);
				obj = Tcl_NewStringObj(flags, flags.size());
			}
			break;

		case attribute::game::Mode:
			obj = Tcl_NewStringObj(event::toString(info.eventMode()), -1);
			break;

		case attribute::game::Termination:
			obj = Tcl_NewStringObj(termination::toString(info.terminationReason()), -1);
			break;

		case attribute::game::TimeMode:
			obj = Tcl_NewStringObj(time::toString(info.timeMode()), -1);
			break;

		case attribute::game::EventCountry:
			obj = Tcl_NewStringObj(country::toString(info.findEventCountry()), -1);
			break;

		case attribute::game::EventType:
			obj = Tcl_NewStringObj(event::toString(info.eventType()), -1);
			break;

		default:
			return error(::CmdGet, "gameInfo", nullptr, "cannot access number %u", which);
	}

	setResult(obj);
	return TCL_OK;
}


int
tcl::db::getGameInfo(Database const& db, unsigned index, Ratings const& ratings)
{
	GameInfo const& info = db.gameInfo(index);

	char		acv[100];
	Tcl_Obj*	objv[attribute::game::LastColumn];

	M_ASSERT(::memset(objv, 0, sizeof(objv)));

	int acvSize = sprintf(	acv,
									"%u %u %u",
									info.countAnnotations(),
									info.countComments(),
									info.countVariations());

	mstl::string startPosition;
	if (info.idn())
		shuffle::utf8::position(info.idn(), startPosition);

	mstl::string openingLong, openingShort, variation, subvariation, round;

	Eco eco = info.eco();
	Eco eop = info.idn() == variant::StandardIdn ? info.ecoKey() : Eco();

	if (db.format() == format::Scidb)
	{
		if (!eco)
			eco = eop;

		round.assign(info.roundAsString());
	}
	else
	{
		TagSet tags;
		db.getInfoTags(index, tags);
		round.assign(tags.value(tag::Round));
	}

	if (info.idn() == variant::StandardIdn && eco)
	{
		EcoTable::specimen().getOpening(eco, openingLong, openingShort, variation, subvariation);

		if (info.eco().basic() == info.ecoKey().basic())
		{
			mstl::string unused;
			EcoTable::specimen().getOpening(info.ecoKey(), unused, unused, variation, subvariation);
		}
		else
		{
			variation.clear();
			subvariation.clear();
		}
	}

	mstl::string flags;
	mstl::string overview;

	GameInfo::flagsToString(info.flags(), flags);

	if (db.format() == format::Scid4)
		::mapScid4Flags(flags);

	if (info.idn() == variant::StandardIdn)
	{
		if (eop)
			EcoTable::specimen().getLine(eop).print(overview, encoding::Utf8);
	}
	else if (info.idn())
	{
		overview = startPosition;
	}

	Tcl_Obj* openingVar[2] =
	{
		Tcl_NewStringObj(openingLong, openingLong.size()),
		Tcl_NewStringObj(openingShort, openingShort.size())
	};

	mstl::string material;
	material::si3::utf8::print(info.material(), material);

	mstl::string const& whitePlayer = info.playerName(color::White);
	mstl::string const& blackPlayer = info.playerName(color::Black);

	mstl::string const& whiteRatingType = rating::toString(info.findRatingType(color::White));
	mstl::string const& blackRatingType = rating::toString(info.findRatingType(color::Black));

	int32_t whiteFideID = info.findFideID(color::White);
	int32_t blackFideID = info.findFideID(color::Black);

#define SET(attr, value) objv[::attribute::game::attr] = value

	SET(Number,               Tcl_NewIntObj(index + 1));
	SET(WhitePlayer,          Tcl_NewStringObj(whitePlayer, whitePlayer.size()));
	SET(WhiteFideID,          whiteFideID ? Tcl_NewIntObj(whiteFideID) : Tcl_NewListObj(0, 0));
	SET(WhiteRating1,         Tcl_NewIntObj(::findRating(info, color::White, ratings.first)));
	SET(WhiteRating2,         Tcl_NewIntObj(::findRating(info, color::White, ratings.second)));
	SET(WhiteRatingType,      Tcl_NewStringObj(whiteRatingType, whiteRatingType.size()));
	SET(WhiteCountry,         Tcl_NewStringObj(country::toString(info.findFederation(color::White)), -1));
	SET(WhiteTitle,           Tcl_NewStringObj(title::toString(info.findTitle(color::White)), -1));
	SET(WhiteType,            Tcl_NewStringObj(species::toString(info.findPlayerType(color::White)), -1));
	SET(WhiteSex,             Tcl_NewStringObj(sex::toString(info.findSex(color::White)), -1));
	SET(BlackPlayer,          Tcl_NewStringObj(blackPlayer, blackPlayer.size()));
	SET(BlackFideID,          blackFideID ? Tcl_NewIntObj(blackFideID) : Tcl_NewListObj(0, 0));
	SET(BlackRating1,         Tcl_NewIntObj(::findRating(info, color::Black, ratings.first)));
	SET(BlackRating2,         Tcl_NewIntObj(::findRating(info, color::Black, ratings.second)));
	SET(BlackRatingType,      Tcl_NewStringObj(blackRatingType, blackRatingType.size()));
	SET(BlackCountry,         Tcl_NewStringObj(country::toString(info.findFederation(color::Black)), -1));
	SET(BlackTitle,           Tcl_NewStringObj(title::toString(info.findTitle(color::Black)), -1));
	SET(BlackType,            Tcl_NewStringObj(species::toString(info.findPlayerType(color::Black)), -1));
	SET(BlackSex,             Tcl_NewStringObj(sex::toString(info.findSex(color::White)), -1));
	SET(Event,                Tcl_NewStringObj(info.event(), info.event().size()));
	SET(EventType,            Tcl_NewStringObj(event::toString(info.eventType()), -1));
	SET(EventDate,            Tcl_NewStringObj(info.eventDate().asShortString(), -1));
	SET(Result,               Tcl_NewStringObj(result::toString(info.result()), -1));
	SET(Site,                 Tcl_NewStringObj(info.site(), info.site().size()));
	SET(EventCountry,         Tcl_NewStringObj(country::toString(info.findEventCountry()), -1));
	SET(Date,                 Tcl_NewStringObj(info.date().asShortString(), -1));
	SET(Round,                Tcl_NewStringObj(round, round.size()));
	SET(Annotator,            Tcl_NewStringObj(info.annotator(), info.annotator().size()));
	SET(Idn,                  Tcl_NewIntObj(info.idn()));
	SET(Position,             Tcl_NewStringObj(startPosition, -1));
	SET(Length,               Tcl_NewIntObj(mstl::div2(info.plyCount() + 1)));
	SET(Eco,                  Tcl_NewStringObj(eco.asShortString(), -1));
	SET(Flags,                Tcl_NewStringObj(flags, flags.size()));
	SET(Material,             Tcl_NewStringObj(material, material.size()));
	SET(Deleted,              Tcl_NewBooleanObj(info.isDeleted()));
	SET(Acv,                  Tcl_NewStringObj(acv, acvSize));
	SET(CommentEngFlag,       Tcl_NewBooleanObj(info.containsEnglishLanguage()));
	SET(CommentOthFlag,       Tcl_NewBooleanObj(info.containsOtherLanguage()));
	SET(Changed,              Tcl_NewIntObj(info.isDirty() || info.isChanged()));
	SET(Promotion,            Tcl_NewBooleanObj(info.hasPromotion()));
	SET(UnderPromotion,       Tcl_NewBooleanObj(info.hasUnderPromotion()));
	SET(StandardPosition,     Tcl_NewBooleanObj(info.idn() == variant::StandardIdn));
	SET(Chess960Position,     Tcl_NewBooleanObj(info.idn() <= 960));
	SET(Termination,          Tcl_NewStringObj(termination::toString(info.terminationReason()), -1));
	SET(Mode,                 Tcl_NewStringObj(event::toString(info.eventMode()), -1));
	SET(TimeMode,             Tcl_NewStringObj(time::toString(info.timeMode()), -1));
	SET(Overview,             Tcl_NewStringObj(overview, overview.size()));
	SET(Opening,              Tcl_NewListObj(2, openingVar));
	SET(Variation,            Tcl_NewStringObj(variation, variation.size()));
	SET(SubVariation,         Tcl_NewStringObj(subvariation, subvariation.size()));
	SET(InternalEco,          Tcl_NewStringObj(eop.asString(), -1));

#undef SET

	M_ASSERT(::checkNonZero(objv, U_NUMBER_OF(objv)));

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getGameInfo(int index, int view, char const* database)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.gameIndex(index, view);

	return getGameInfo(cursor.database(), index, Ratings(rating::Elo, rating::DWZ));
}


static int
getGameInfo(int index, int view, char const* database, Ratings const& ratings)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.gameIndex(index, view);

	return getGameInfo(cursor.database(), index, ratings);
}


static int
getPlayerInfo(int index, int view, char const* database, unsigned which)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.playerIndex(index, view);

	NamebasePlayer const& player = cursor.database().player(index);
	Tcl_Obj* obj;

	switch (which)
	{
		case attribute::player::Country:
			obj = Tcl_NewStringObj(country::toString(player.findFederation()), -1);
			break;

		case attribute::player::Title:
			obj = Tcl_NewStringObj(title::toString(player.findTitle()), -1);
			break;

		case attribute::player::Type:
			obj = Tcl_NewStringObj(species::toString(player.findType()), -1);
			break;

		case attribute::player::Sex:
			obj = Tcl_NewStringObj(sex::toString(player.findSex()), -1);
			break;

		default:
			return error(::CmdGet, "playerInfo", nullptr, "cannot access number %u", which);
	}

	setResult(obj);
	return TCL_OK;
}


static int
getPlayerInfo(int index, int view, char const* database, Ratings const& ratings, bool info, bool idCard)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.playerIndex(index, view);

	return getPlayerInfo(cursor.database().player(index),
								ratings,
								info,
								idCard);
}


static int
getEventInfo(int index, int view, char const* database, unsigned which)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.eventIndex(index, view);

	NamebaseEvent const& event = cursor.database().event(index);
	Tcl_Obj* obj;

	switch (which)
	{
		case attribute::event::Country:
			obj = Tcl_NewStringObj(country::toString(event.site()->country()), -1);
			break;

		case attribute::event::Type:
			obj = Tcl_NewStringObj(event::toString(event.type()), -1);
			break;

		case attribute::event::Mode:
			obj = Tcl_NewStringObj(event::toString(event.eventMode()), -1);
			break;

		case attribute::event::TimeMode:
			obj = Tcl_NewStringObj(time::toString(event.timeMode()), -1);
			break;

		default:
			return error(::CmdGet, "eventInfo", nullptr, "cannot access number %u", which);
	}

	setResult(obj);
	return TCL_OK;
}


static int
getSiteInfo(int index, int view, char const* database, unsigned which)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.siteIndex(index, view);

	NamebaseSite const& site = cursor.database().site(index);
	Tcl_Obj* obj;

	switch (which)
	{
		case attribute::site::Country:
			obj = Tcl_NewStringObj(country::toString(site.country()), -1);
			break;

		default:
			return error(::CmdGet, "eventInfo", nullptr, "cannot access number %u", which);
	}

	setResult(obj);
	return TCL_OK;
}


static int
getEventInfo(NamebaseEvent const& event, Database const* database = nullptr)
{
	Tcl_Obj* objv[attribute::event::LastColumn + (database ? 3 : 0)];

	mstl::string const& country = country::toString(event.site()->country());
	mstl::string siteName;

#if 0
	if (database)
	{
		if (Site const* site = Site::findSite(event.site()->name()))
			siteName = site->name();
	}

	if (siteName.empty())
#endif
		siteName = event.site()->name();

	objv[attribute::event::Country  ] = Tcl_NewStringObj(country, country.size());
	objv[attribute::event::Site     ] = Tcl_NewStringObj(siteName, siteName.size());
	objv[attribute::event::Title    ] = Tcl_NewStringObj(event.name(), -1);
	objv[attribute::event::Type     ] = Tcl_NewStringObj(event::toString(event.type()), -1);
	objv[attribute::event::Date     ] = Tcl_NewStringObj(event.date().asShortString(), -1);
	objv[attribute::event::Mode     ] = Tcl_NewStringObj(event::toString(event.eventMode()), -1);
	objv[attribute::event::TimeMode ] = Tcl_NewStringObj(time::toString(event.timeMode()), -1);
	objv[attribute::event::Frequency] = Tcl_NewIntObj(event.frequency());

	if (database)
	{
		unsigned averageElo;
		unsigned category;
		unsigned attendants = database->countPlayers(event, averageElo, category);

		objv[attribute::event::Frequency + 1] = Tcl_NewIntObj(attendants);
		objv[attribute::event::Frequency + 2] = Tcl_NewIntObj(averageElo);
		objv[attribute::event::Frequency + 3] = Tcl_NewIntObj(category);
	}

	M_ASSERT(::checkNonZero(objv, attribute::event::LastColumn + (database ? 3 : 0)));

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getEventInfo(int index, int view, bool idCard)
{
	Cursor const& cursor = Scidb->cursor();

	if (view >= 0)
		index = cursor.eventIndex(index, view);

	return getEventInfo(cursor.database().event(index), idCard ? &cursor.database() : nullptr);
}


static int
getSiteInfo(int index, int view)
{
	Cursor const& cursor = Scidb->cursor();

	if (view >= 0)
		index = cursor.siteIndex(index, view);

	NamebaseSite const& site = cursor.database().site(index);

	Tcl_Obj* objv[attribute::site::LastColumn];

	mstl::string const& country	= country::toString(site.country());
	mstl::string const& siteName	= site.name();

	objv[attribute::site::Site     ] = Tcl_NewStringObj(siteName, siteName.size());
	objv[attribute::site::Country  ] = Tcl_NewStringObj(country, country.size());
	objv[attribute::site::Frequency] = Tcl_NewIntObj(site.frequency());

	M_ASSERT(::checkNonZero(objv, attribute::site::LastColumn));

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getAnnotator(int index, int view)
{
	Tcl_Obj* objv[::attribute::annotator::LastColumn];

	M_ASSERT(::memset(objv, 0, sizeof(objv)));

	Cursor const& cursor = Scidb->cursor();

	if (view >= 0)
		index = cursor.annotatorIndex(index, view);

	NamebaseEntry const& annotator = cursor.database().annotator(index);

	objv[::attribute::annotator::Name] = Tcl_NewStringObj(annotator.name(), annotator.name().size());
	objv[::attribute::annotator::Frequency] = Tcl_NewIntObj(annotator.frequency());

	M_ASSERT(::checkNonZero(objv, U_NUMBER_OF(objv)));

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


static int
getEncodingState(char const* database)
{
	Database const& base = Scidb->cursor(database).database();

	if (base.encodingFailed())
		setResult("failed");
	else if (base.encodingIsBroken())
		setResult("broken");
	else
		setResult("ok");

	return TCL_OK;
}


static int
getDeleted(int index, int view, char const* database)
{
	Cursor const& cursor = Scidb->cursor(database);

	if (view >= 0)
		index = cursor.gameIndex(index, view);

	setResult(cursor.database().gameInfo(index).isDeleted());
	return TCL_OK;
}


int
tcl::db::getTags(TagSet const& tags, bool userSuppliedOnly)
{
	Tcl_Obj* result = Tcl_NewListObj(0, 0);

	for (tag::ID tag = tags.findFirst(); tag < tag::ExtraTag; tag = tags.findNext(tag))
	{
		if (tags.isUserSupplied(tag))
		{
			Tcl_Obj* objs[2];

			mstl::string const name		= tag::toName(tag);
			mstl::string const value	= tags.value(tag);

			objs[0] = Tcl_NewStringObj(name, name.size());
			objs[1] = Tcl_NewStringObj(value, value.size());

			Tcl_ListObjAppendElement(0, result, Tcl_NewListObj(2, objs));
		}
	}

	for (unsigned i = 0; i < tags.countExtra(); ++i)
	{
		Tcl_Obj* objs[2];

		TagSet::Tag const& pair = tags.extra(i);
		objs[0] = Tcl_NewStringObj(pair.name, pair.name.size());
		objs[1] = Tcl_NewStringObj(pair.value, pair.value.size());

		Tcl_ListObjAppendElement(0, result, Tcl_NewListObj(2, objs));
	}

	setResult(result);
	return TCL_OK;
}


static int
getTags(int index, char const* database)
{
	TagSet tags;
	Scidb->cursor(database).database().getInfoTags(index, tags);
	return getTags(tags, false);
}


static int
getChecksum(int index, char const* database)
{
	setResult(Scidb->cursor(database).database().computeChecksum(index));
	return TCL_OK;
}


static int
getIdn(int index, char const* database)
{
	setResult(Scidb->cursor(database).database().gameInfo(index).idn());
	return TCL_OK;
}


static int
getEco(int index, char const* database)
{
	setResult(Scidb->cursor(database).database().gameInfo(index).eco().asShortString());
	return TCL_OK;
}


static int
getRatingTypes(int index, char const* database)
{
	GameInfo const& info = Scidb->cursor(database).database().gameInfo(index);

	mstl::string const& wr = rating::toString(info.ratingType(color::White));
	mstl::string const& br = rating::toString(info.ratingType(color::Black));

	Tcl_Obj* objs[2] = { Tcl_NewStringObj(wr, wr.size()), Tcl_NewStringObj(br, br.size())};
	setResult(2, objs);

	return TCL_OK;
}


static int
cmdPlayerInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 3 && objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> (<player-index> | <game-index> <side>)");
		return TCL_ERROR;
	}

	Database const&         base(Scidb->cursor(stringFromObj(objc, objv, 1)).database());
	unsigned                index(unsignedFromObj(objc, objv, 2));
	NamebasePlayer const*   player;

	if (objc == 3)
		player = &base.player(index);
	else
		player = &base.player(index, color::fromSide(stringFromObj(objc, objv, 3)));

	Ratings ratings(rating::Any, rating::Any);
	return getPlayerInfo(*player, ratings, true, true);
}


static int
cmdPlayerCard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	struct Log : public TeXt::Controller::Log
	{
		void error(mstl::string const& msg) { str = msg; }
		mstl::string str;
	};

	if (objc != 6 && objc != 7)
	{
		Tcl_WrongNumArgs(
			ti,
			1,
			objv,
			"<search-dir> <script> <preamble> <database> (<player-index> | <game-index> <side>)");
		return TCL_ERROR;
	}

	unsigned						index(unsignedFromObj(objc, objv, 5));
	Database const&			base(Scidb->cursor(stringFromObj(objc, objv, 4)).database());
	mstl::string				preamble(stringFromObj(objc, objv, 3));
	mstl::string				searchDir(stringFromObj(objc, objv, 1));
	mstl::string				script(stringFromObj(objc, objv, 2));
	TeXt::Controller::LogP	myLog(new Log);
	TeXt::Controller			controller(searchDir, TeXt::Controller::AbortMode, myLog);
	mstl::istringstream		src(preamble);
	mstl::ostringstream		dst;
	mstl::ostringstream		out;
	NamebasePlayer const*	player;

	if (objc == 6)
		player = &base.player(index);
	else
		player = &base.player(index, color::fromSide(stringFromObj(objc, objv, 6)));

	base.emitPlayerCard(controller.receptacle(), *player);

	if (controller.processInput(src, dst, &out, &out) >= 0)
	{
		int rc = controller.processInput(script, dst, &out, &out);

		if (rc == TeXt::Controller::OpenInputFileFailed)
			out.write(static_cast<Log*>(myLog.get())->str);
	}

	mstl::string htm(dst.str());
	mstl::string log(out.str());

	if (!htm.empty() && htm.back() == '\n')
		htm.set_size(htm.size() - 1);
	if (!log.empty() && log.back() == '\n')
		log.set_size(log.size() - 1);

	Tcl_Obj* args[2];
	args[0] = Tcl_NewStringObj(htm, htm.size());
	args[1] = Tcl_NewStringObj(log, log.size());

	setResult(2, args);

	return TCL_OK;
}


static int
cmdFetch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"eventInfo", "whitePlayerInfo", "blackPlayerInfo", "whitePlayerStats", "blackPlayerStats", 0
	};
	static char const* args[] =
	{
		"<game-index> <database>",
		"<game-index> <database>",
		"<game-index> <database>",
		"<game-index> <database>",
		"<game-index> <database>",
		0,
	};
	enum
	{
		Cmd_EventInfo,
		Cmd_WhitePlayerInfo, Cmd_BlackPlayerInfo,
		Cmd_WhitePlayerStats, Cmd_BlackPlayerStats
	};

	int index = intFromObj(objc, objv, 2);

	Cursor const& cursor = Scidb->cursor(stringFromObj(objc, objv, 3));
	GameInfo const& info = cursor.database().gameInfo(index);

	switch (int idx = tcl::uniqueMatchObj(objv[1], subcommands))
	{
		case Cmd_EventInfo:
			{
				bool idCard = false;

				if (objc > 4)
				{
					char const*	lastArg	= Tcl_GetString(objv[objc - 1]);

					if (lastArg[0] == '-' && !::isdigit(lastArg[1]))
					{
						if (::strcmp(lastArg, "-card") != 0)
							return error(::CmdGet, nullptr, nullptr, "invalid argument %s", lastArg);

						idCard = true;
					}
				}

				return getEventInfo(*info.eventEntry(), idCard ? &cursor.database() : nullptr);
			}
			break;

		case Cmd_WhitePlayerInfo:
		case Cmd_BlackPlayerInfo:
			{
				Ratings ratings(rating::Any, rating::Any);

				bool parseOptions = true;
				bool idCard			= false;
				bool infoWanted	= false;

				while (parseOptions && objc > 4)
				{
					char const*	lastArg	= Tcl_GetString(objv[objc - 1]);

					if (*lastArg != '-')
						lastArg = Tcl_GetString(objv[objc - 2]);

					if (lastArg[0] == '-' && !::isdigit(lastArg[1]))
					{
						if (::strcmp(lastArg, "-card") == 0)
						{
							idCard = infoWanted = true;
						}
						else if (::strcmp(lastArg, "-info") == 0)
						{
							infoWanted = true;
						}
						else if (::strcmp(lastArg, "-ratings") == 0)
						{
							ratings = ::convRatings(stringFromObj(objc, objv, objc - 1));
							--objc;
						}
						else
						{
							return error(::CmdFetch, nullptr, nullptr, "invalid argument %s", lastArg);
						}

						--objc;
					}
					else
					{
						parseOptions = false;
					}
				}

				color::ID side = idx == Cmd_WhitePlayerInfo ? color::White : color::Black;
				return getPlayerInfo(*info.playerEntry(side), ratings, infoWanted, idCard);
			}
			break;

		case Cmd_WhitePlayerStats:
		case Cmd_BlackPlayerStats:
			{
				color::ID side = idx == Cmd_WhitePlayerStats ? color::White : color::Black;
				return getPlayerStats(cursor.database(), *info.playerEntry(side));
			}
			break;
	}

	return usage(::CmdFetch, nullptr, nullptr, subcommands, args);
}


static int
cmdGet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"clipbase", "scratchbase", "types", "type", "name", "codec", "encoding", "created?",
		"modified?", "gameInfo", "playerInfo", "playerStats", "eventInfo", "siteInfo",
		"annotator", "gameIndex", "playerIndex", "eventIndex", "siteIndex", "annotatorIndex",
		"description", "stats", "readonly?", "encodingState", "deleted?", "open?", "lastChange",
		"customFlags", "gameFlags", "gameNumber", "minYear", "maxYear", "maxUsage", "tags",
		"checksum", "idn", "eco", "ratingTypes", "lookupPlayer", "lookupEvent", "lookupSite",
		"writeable?", "upgrade?", "memoryOnly?", "compress?", "playerKey", "eventKey", "siteKey",
		0
	};
	static char const* args[] =
	{
		/* clipbase			*/ "<name>|<type>",
		/* scratchbase		*/ "<name>|<type>",
		/* types				*/ "sci|si3|si4",
		/* type				*/ "?<database>?",
		/* name				*/ "",
		/* codec				*/ "?<database>?",
		/* encoding			*/ "?<database>?",
		/* created?			*/ "?<database>?",
		/* modified?		*/ "?<database>?",
		/* gameInfo			*/ "<index> ?<view>? ?<database>?",
		/* playerInfo		*/ "<index> ?<view>? ?<database> <which>?",
		/* playerStats		*/ "<index> ?<view>? ?<database> <which>?",
		/* eventInfo		*/ "<index> ?<view>? ?<database> <which>?",
		/* siteInfo			*/ "<index> ?<view>? ?<database> <which>?",
		/* annotator		*/ "<index> ?<view>?",
		/* gameIndex		*/ "<number> ?<view>? ?<database>?",
		/* playerIndex		*/ "<number> ?<view>? ?<database>?",
		/* eventIndex		*/ "<number> ?<view>? ?<database>?",
		/* siteIndex		*/ "<number> ?<view>? ?<database>?",
		/* annotatorIndex	*/ "<number> ?<view>? ?<database>?",
		/* description		*/ "?<database>?",
		/* stats				*/ "<database>",
		/* readonly?		*/ "?<database>?",
		/* encodingState	*/ "?<database>?",
		/* deleted?			*/ "<index> ?<view>? ?<database>?",
		/* open?				*/ "<database>",
		/* lastChange		*/ "?<database>?",
		/* customFlags		*/ "?<database>?",
		/* gameFlags		*/ "?<database>?",
		/* gameNumber		*/ "?<database>?",
		/* minYear			*/ "?<database>?",
		/* maxYear			*/ "?<database>?",
		/* maxUsage			*/ "?<database>? <namebase-type>",
		/* tags				*/ "<number> ?<database>?",
		/* checksum			*/ "<number> ?<database>?",
		/* idn				*/ "<number> ?<database>?",
		/* eco				*/ "<number> ?<database>?",
		/* ratingTypes		*/ "<number> ?<database>?",
		/* lookupPlayer	*/ "<index> ?<view>? ?<database>?",
		/* lookupEvent		*/ "<index> ?<view>? ?<database>?",
		/* lookupSite		*/ "<index> ?<view>? ?<database>?",
		/* writeable?		*/ "?<database>?",
		/* upgrade?			*/ "<database>",
		/* memoryOnly?		*/ "?<database>?",
		/* compress?		*/ "<database>",
		/* playerKey		*/ "<database> (<player-index> | <game-index> <side>)",
		/* eventKey			*/ "<database> game|event <event>",
		/* siteKey			*/ "<database> game|site <site>",
		0
	};
	enum
	{
		Cmd_Clipbase, Cmd_Scratchbase, Cmd_Types, Cmd_Type, Cmd_Name, Cmd_Codec, Cmd_Encoding,
		Cmd_Created, Cmd_Modified, Cmd_GameInfo, Cmd_PlayerInfo, Cmd_PlayerStats, Cmd_EventInfo,
		Cmd_SiteInfo, Cmd_Annotator, Cmd_GameIndex, Cmd_PlayerIndex, Cmd_EventIndex, Cmd_SiteIndex,
		Cmd_AnnotatorIndex, Cmd_Description, Cmd_Stats, Cmd_ReadOnly, Cmd_EncodingState, Cmd_Deleted,
		Cmd_Open, Cmd_LastChange, Cmd_CustomFlags, Cmd_GameFlags, Cmd_GameNumber, Cmd_MinYear,
		Cmd_MaxYear, Cmd_MaxUsage, Cmd_Tags, Cmd_Checksum, Cmd_Idn, Cmd_Eco, Cmd_RatingTypes,
		Cmd_LookupPlayer, Cmd_LookupEvent, Cmd_LookupSite, Cmd_Writeable, Cmd_Upgrade, Cmd_MemoryOnly,
		Cmd_Compress, Cmd_PlayerKey, Cmd_EventKey, Cmd_SiteKey,
	};

	if (objc < 2)
		return usage(::CmdGet, nullptr, nullptr, subcommands, args);

	int index	= tcl::uniqueMatchObj(objv[1], subcommands);
	int view		= View::DefaultView;

	switch (index)
	{
		case Cmd_Clipbase:
			if (objc != 3)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getClipbaseAttr(ti, Tcl_GetString(objv[2]));

		case Cmd_Scratchbase:
			if (objc != 3)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getScratchbaseAttr(ti, Tcl_GetString(objv[2]));

		case Cmd_Types:
			if (objc != 3)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getTypes(ti, Tcl_GetString(objv[2]));

		case Cmd_Type:
			if (objc < 3)
				return getType();
			return getType(Tcl_GetString(objv[2]));

		case Cmd_Name:
			return getName();

		case Cmd_Codec:
			if (objc < 3)
				return getCodec();
			return getCodec(Tcl_GetString(objv[2]));

		case Cmd_Encoding:
			if (objc < 3)
				return getEncoding();
			return getEncoding(Tcl_GetString(objv[2]));

		case Cmd_Created:
			if (objc < 3)
				return getCreated();
			return getCreated(Tcl_GetString(objv[2]));

		case Cmd_Modified:
			if (objc < 3)
				return getModified();
			return getModified(Tcl_GetString(objv[2]));

		case Cmd_GameInfo:
			{
				Ratings ratings(rating::Any, rating::Any);
				bool parseRatings = ::strcmp(stringFromObj(objc, objv, objc - 2), "-ratings") == 0;

				if (parseRatings)
				{
					ratings = ::convRatings(stringFromObj(objc, objv, objc - 1));
					objc -= 2;
				}

				if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);
				if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				char const* database = objc < 5 ? 0 : stringFromObj(objc, objv, 4);

				if (parseRatings)
					return getGameInfo(index, view, database, ratings);

				if (objc <= 5)
					return getGameInfo(index, view, database);

				return getGameInfo(index, view, database, unsignedFromObj(objc, objv, 5));
			}

        case Cmd_PlayerStats:
            {
                if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
                    return usage(::CmdGet, nullptr, nullptr, subcommands, args);

                if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
                    return usage(::CmdGet, nullptr, nullptr, subcommands, args);

                char const* database = objc < 5 ? 0 : stringFromObj(objc, objv, 4);
                Database const& base = Scidb->cursor(database).database();
                return getPlayerStats(base, base.player(index));
            }
            break;

		case Cmd_PlayerInfo:
			{
				Ratings ratings(rating::Any, rating::Any);

				bool parseOptions = true;
				bool idCard			= false;
				bool info			= false;

				while (parseOptions && objc >= 3)
				{
					char const*	lastArg	= Tcl_GetString(objv[objc - 1]);

					if (*lastArg != '-')
						lastArg = Tcl_GetString(objv[objc - 2]);

					if (lastArg[0] == '-' && !::isdigit(lastArg[1]))
					{
						if (::strcmp(lastArg, "-card") == 0)
						{
							idCard = info = true;
						}
						else if (::strcmp(lastArg, "-info") == 0)
						{
							info = true;
						}
						else if (::strcmp(lastArg, "-ratings") == 0)
						{
							ratings = ::convRatings(stringFromObj(objc, objv, objc - 1));
							--objc;
						}
						else
						{
							return error(::CmdGet, nullptr, nullptr, "invalid argument %s", lastArg);
						}

						--objc;
					}
					else
					{
						parseOptions = false;
					}
				}

				if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc >= 6)
				{
					return getPlayerInfo(index,
												view,
												stringFromObj(objc, objv, 4),
												unsignedFromObj(objc, objv, 5));
				}
				else
				{
					char const* database = objc < 5 ? 0 : stringFromObj(objc, objv, 4);
					return getPlayerInfo(index, view, database, ratings, info, idCard);
				}
			}
			// not reached

		case Cmd_EventInfo:
			{
				bool idCard = false;

				if (objc >= 3)
				{
					char const*	lastArg	= Tcl_GetString(objv[objc - 1]);

					if (lastArg[0] == '-' && !::isdigit(lastArg[1]))
					{
						if (::strcmp(lastArg, "-card") != 0)
							return error(::CmdGet, nullptr, nullptr, "invalid argument %s", lastArg);

						idCard = true;
						--objc;
					}
				}

				if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc < 6)
					return getEventInfo(index, view, idCard);

				char const*	database	= stringFromObj(objc, objv, 4);
				unsigned		which		= unsignedFromObj(objc, objv, 5);

				return getEventInfo(index, view, database, which);
			}

		case Cmd_SiteInfo:
			{
				if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				if (objc < 6)
					return getSiteInfo(index, view);

				char const*	database	= stringFromObj(objc, objv, 4);
				unsigned		which		= unsignedFromObj(objc, objv, 5);

				return getSiteInfo(index, view, database, which);
			}

		case Cmd_Annotator:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			if (objc == 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getAnnotator(index, view);

		case Cmd_GameIndex:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			if (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getGameIndex(index, view, objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_PlayerIndex:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getPlayerIndex(	unsignedFromObj(objc, objv, 2),
											view,
											objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_LookupPlayer:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getLookupPlayer(	unsignedFromObj(objc, objv, 2),
											view,
											objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_EventIndex:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getEventIndex(	unsignedFromObj(objc, objv, 2),
											view,
											objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_SiteIndex:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getSiteIndex(	unsignedFromObj(objc, objv, 2),
										view,
										objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_LookupEvent:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getLookupEvent(	unsignedFromObj(objc, objv, 2),
											view,
											objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_LookupSite:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getLookupSite(unsignedFromObj(objc, objv, 2),
										view,
										objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_AnnotatorIndex:
			if (objc < 3 || (objc >= 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK))
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getAnnotatorIndex(	stringFromObj(objc, objv, 2),
												view,
												objc == 5 ? stringFromObj(objc, objv, 4) : 0);

		case Cmd_Description:
			if (objc < 3)
				return getDescription();
			return getDescription(Tcl_GetString(objv[2]));

		case Cmd_Stats:
			return getStats(stringFromObj(objc, objv, 2));

		case Cmd_ReadOnly:
			if (objc < 3)
				return getReadonly();
			return getReadonly(stringFromObj(objc, objv, 2));

		case Cmd_Writeable:
			if (objc < 3)
				return getWriteable();
			return getWriteable(stringFromObj(objc, objv, 2));

		case Cmd_Upgrade:
			::tcl::setResult(Scidb->cursor(stringFromObj(objc, objv, 2)).database().shouldUpgrade());
			return TCL_OK;

		case Cmd_Open:
			setResult(Scidb->contains(stringFromObj(objc, objv, 2)));
			return TCL_OK;

		case Cmd_EncodingState:
			if (objc < 3)
				return getEncodingState(0);
			return getEncodingState(Tcl_GetString(objv[2]));

		case Cmd_Deleted:
			return getDeleted(intFromObj(objc, objv, 2),
									objc < 4 ? -1 : intFromObj(objc, objv, 3),
									objc < 5 ? 0 : stringFromObj(objc, objv, 4));

		case Cmd_LastChange:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				setResult(Tcl_NewWideIntObj(Scidb->cursor(base).database().lastChange()));
			}
			return TCL_OK;

		case Cmd_CustomFlags:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				Database const& database = Scidb->cursor(base).database();

				if (database.format() == format::Scid4)
				{
					Tcl_Obj* objv[6];

					DatabaseCodec::CustomFlags const& flags = database.codec().customFlags();

					for (unsigned i = 0; i < 6; ++i)
						objv[i] = Tcl_NewStringObj(flags.get(i), -1);

					setResult(6, objv);
				}
				else
				{
					setResult("");
				}
			}
			return TCL_OK;

		case Cmd_GameFlags:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				Database const& database = Scidb->cursor(base).database();
				mstl::string flags;

				GameInfo::flagsToString(database.codec().gameFlags(), flags);

				if (database.format() == format::Scid4)
					::mapScid4Flags(flags);

				setResult(flags);
			}
			return TCL_OK;

		case Cmd_GameNumber:
			{
				char const* base = stringFromObj(objc, objv, 2);
				unsigned index = unsignedFromObj(objc, objv, 3);

				view = intFromObj(objc, objv, 4);

				if (view >= 0)
					index = Scidb->cursor(base).gameIndex(index, view);

				setResult(index);
			}
			return TCL_OK;

		case Cmd_MinYear:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				setResult(Scidb->cursor(base).database().codec().minYear());
			}
			return TCL_OK;

		case Cmd_MaxYear:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				setResult(Scidb->cursor(base).database().codec().maxYear());
			}
			return TCL_OK;

		case Cmd_MaxUsage:
			{
				char const* base = objc < 4 ? "" : stringFromObj(objc, objv, 2);
				Tcl_Obj* namebase = objectFromObj(objc, objv, objc < 4 ? 2 : 3);

				Namebase::Type	type = getNamebaseType(namebase, ::CmdGet);
				setResult(Scidb->cursor(base).database().namebase(type).maxUsage());
			}
			return TCL_OK;

		case Cmd_Tags:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getTags(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_Checksum:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getChecksum(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_Idn:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getIdn(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_Eco:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getEco(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_RatingTypes:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getRatingTypes(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_MemoryOnly:
			{
				char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
				setResult(Scidb->cursor(base).database().isMemoryOnly());
			}
			return TCL_OK;

		case Cmd_Compress:
			setResult(Scidb->cursor(stringFromObj(objc, objv, 2)).database().shouldCompress());
			return TCL_OK;

		case Cmd_PlayerKey:
			{
				if (objc != 4 && objc != 5)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				Database const&	base(Scidb->cursor(stringFromObj(objc, objv, 2)).database());
				unsigned				index(unsignedFromObj(objc, objv, 3));

				if (objc == 4)
					getPlayerKey(base.player(index));
				else
					getPlayerKey(base.player(index, color::fromSide(stringFromObj(objc, objv, 4))));
			}
			return TCL_OK;

		case Cmd_EventKey:
			{
				if (objc != 5)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				Database const&	base(Scidb->cursor(stringFromObj(objc, objv, 2)).database());
				char const*			what(stringFromObj(objc, objv, 3));
				unsigned				index(unsignedFromObj(objc, objv, 4));

				getEventKey(base.event(index, *what == 'e' ? Database::MyIndex : Database::GameIndex));
			}
			return TCL_OK;

		case Cmd_SiteKey:
			{
				if (objc != 5)
					return usage(::CmdGet, nullptr, nullptr, subcommands, args);

				Database const&	base(Scidb->cursor(stringFromObj(objc, objv, 2)).database());
				char const*			what(stringFromObj(objc, objv, 3));
				unsigned				index(unsignedFromObj(objc, objv, 4));

				getSiteKey(base.site(index, *what == 'e' ? Database::MyIndex : Database::GameIndex));
			}
			return TCL_OK;
	}

	return usage(::CmdGet, nullptr, nullptr, subcommands, args);
}


static int
cmdSubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"dbInfo|gameList|playerList|annotatorList|eventList|siteList|gameInfo|"
			"gameHistory|gameSwitch|tree <update-cmd> ??"
			"<close-cmd>? <arg>?");
		return TCL_ERROR;
	}

	static char const* subcommands[] =
	{
		"dbInfo", "gameList", "playerList", "annotatorList", "eventList", "siteList",
		"gameInfo", "gameHistory", "gameSwitch", "tree", 0
	};
	enum
	{
		Cmd_DbInfo, Cmd_GameList, Cmd_PlayerList, Cmd_AnnotatorList, Cmd_EventList,
		Cmd_SiteList, Cmd_GameInfo, Cmd_GameHistory, Cmd_GameSwitch, Cmd_Tree,
	};

	Subscriber* subscriber = static_cast<Subscriber*>(scidb->subscriber());

	if (subscriber == 0)
	{
		subscriber = new Subscriber;
		scidb->setSubscriber(Application::SubscriberP(subscriber));
	}

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Tcl_Obj* updateCmd	= objv[2];
	Tcl_Obj* closeCmd		= objc == 5 ? objv[3] : 0;
	Tcl_Obj* arg			= objc == 5 ? objv[4] : (objc == 4 ? objv[3] : 0);

	switch (index)
	{
		case Cmd_DbInfo:
			subscriber->setDatabaseInfoCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameList:
			subscriber->setGameListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_PlayerList:
			subscriber->setPlayerListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_AnnotatorList:
			subscriber->setAnnotatorListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_EventList:
			subscriber->setEventListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_SiteList:
			subscriber->setSiteListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameInfo:
			subscriber->setGameInfoCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameHistory:
			subscriber->setGameHistoryCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameSwitch:
			subscriber->setGameSwitchedCmd(updateCmd);
			break;

		case Cmd_Tree:
			subscriber->setTreeCmd(updateCmd, closeCmd, arg);
			break;

		default:
			return error(	::CmdSubscribe,
								nullptr, nullptr,
								"invalid argument %s",
								static_cast<char const*>(Tcl_GetString(objv[1])));
	}

	return TCL_OK;
}


static int
cmdUnsubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 3)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"dbInfo|gameList|playerList|annotatorList|eventList|siteList|gameInfo|gameHistory|tree "
			"<update-cmd> ??" "<close-cmd>? <arg>?");
		return TCL_ERROR;
	}

	static char const* subcommands[] =
	{
		"dbInfo", "gameList", "playerList", "eventList", "siteList",
		"annotatorList", "gameInfo", "gameHistory", "tree", 0
	};
	enum
	{
		Cmd_DbInfo, Cmd_GameList, Cmd_PlayerList, Cmd_EventList, Cmd_SiteList,
		Cmd_AnnotatorList, Cmd_GameInfo, Cmd_GameHistory, Cmd_Tree
	};

	Subscriber* subscriber = static_cast<Subscriber*>(scidb->subscriber());

	if (subscriber == 0)
		return TCL_OK;

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Tcl_Obj* updateCmd	= objv[2];
	Tcl_Obj* closeCmd		= objc == 5 ? objv[3] : 0;
	Tcl_Obj* arg			= objc == 5 ? objv[4] : (objc == 4 ? objv[3] : 0);

	switch (index)
	{
		case Cmd_DbInfo:
			subscriber->unsetDatabaseInfoCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameList:
			subscriber->unsetGameListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_PlayerList:
			subscriber->unsetPlayerListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_EventList:
			subscriber->unsetEventListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_SiteList:
			subscriber->unsetSiteListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_AnnotatorList:
			subscriber->unsetAnnotatorListCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameInfo:
			subscriber->unsetGameInfoCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_GameHistory:
			subscriber->unsetGameHistoryCmd(updateCmd, closeCmd, arg);
			break;

		case Cmd_Tree:
			subscriber->unsetTreeCmd(updateCmd, closeCmd, arg);
			break;

		default:
			return error(	::CmdUnsubscribe,
								nullptr,
								nullptr,
								"invalid argument %s",
								Tcl_GetString(objv[1]));
	}

	return TCL_OK;
}


static int
cmdSwitch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database>");
		return TCL_ERROR;
	}

	scidb->switchBase(Tcl_GetString(objv[1]));
	return TCL_OK;
}


static int
cmdClose(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database>");
		return TCL_ERROR;
	}

	scidb->close(Tcl_GetString(objv[1]));
	return TCL_OK;
}


static int
cmdClear(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database>");
		return TCL_ERROR;
	}

	scidb->clearBase(scidb->cursor(Tcl_GetString(objv[1])));
	return TCL_OK;
}


static int
cmdSort(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "gameInfo", "player", "event", "site", "annotator", 0 };
	static char const* args[] =
	{
		"<database> <column> ?<view>? ?-average? ?-descending? -ratings {<rating type> <rating type>}",
		"<database> <column> ?<view>? ?-descending? ?-latest?",
		"<database> <column> ?<view>? ?-descending?",
		"<database> <column> ?<view>? ?-descending?",
		"<database> <column> ?<view>? ?-descending?",
	};
	enum { Cmd_GameInfo, Cmd_Player, Cmd_Event, Cmd_Site, Cmd_Annotator };

	if (objc < 4)
		return usage(::CmdSort, nullptr, nullptr, subcommands, args);

	int			view		= View::DefaultView;
	int			index		= tcl::uniqueMatchObj(objv[1], subcommands);
	char const*	database	= stringFromObj(objc, objv, 2);
	bool			average	= false;
	bool			latest	= false;
	order::ID	order		= order::Ascending;
	int			optCount	= 0;

	Ratings ratings(rating::Elo, rating::Elo);

	while (	objc > 4
			&& (	*stringFromObj(objc, objv, objc - 1) == '-'
				|| *stringFromObj(objc, objv, objc - 2) == '-'))
	{
		++optCount;
		--objc;
	}

	if (objc < 4 || 5 < objc)
		return usage(::CmdSort, nullptr, nullptr, subcommands, args);

	if (objc == 5)
		view = intFromObj(objc, objv, 4);

	for (int i = 0; i < optCount; ++i)
	{
		char const* opt = stringFromObj(optCount, objv + objc, i);

		if (*opt == '-')
		{
			if (::strcmp(opt, "-average") == 0)
				average = true;
			else if (::strcmp(opt, "-latest") == 0)
				latest = true;
			else if (::strcmp(opt, "-descending") == 0)
				order = order::Descending;
			else if (::strcmp(opt, "-ratings") != 0)
				return error(::CmdSort, nullptr, nullptr, "illegal option %s", opt);
			else if (i == optCount - 1)
				return error(::CmdSort, nullptr, nullptr, "missing rating types");
			else
				ratings = convRatings(stringFromObj(optCount, objv + objc, ++i));
		}
		else
		{
			return usage(::CmdSort, nullptr, nullptr, subcommands, args);
		}
	}

	switch (index)
	{
		case Cmd_GameInfo:
			{
				attribute::game::ID column = lookupGameInfo(objv[3], ratings, average);
				if (column < 0)
					return TCL_ERROR;
				scidb->sort(scidb->cursor(database), view, column, order, ratings.first);
			}
			break;

		case Cmd_Player:
			{
				attribute::player::ID column = lookupPlayerBase(objv[3], ratings, latest);
				if (column < 0)
					return TCL_ERROR;
				scidb->sort(scidb->cursor(database), view, column, order, ratings.first);
			}
			break;

		case Cmd_Event:
			{
				attribute::event::ID column = lookupEventBase(objv[3]);
				if (column < 0)
					return TCL_ERROR;
				scidb->sort(scidb->cursor(database), view, column, order);
			}
			break;

		case Cmd_Site:
			{
				attribute::site::ID column = lookupSiteBase(objv[3]);
				if (column < 0)
					return TCL_ERROR;
				scidb->sort(scidb->cursor(database), view, column, order);
			}
			break;

		case Cmd_Annotator:
			{
				attribute::annotator::ID column = lookupAnnotatorBase(objv[3]);
				if (column < 0)
					return TCL_ERROR;
				scidb->sort(scidb->cursor(database), view, column, order);
			}
			break;

		default:
			return usage(::CmdSort, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdRecode(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <encoding> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	char const* database	= stringFromObj(objc, objv, 1);
	char const* encoding	= stringFromObj(objc, objv, 2);

	Progress progress(objv[3], objv[4]);
	scidb->recode(scidb->cursor(database), encoding, progress);

	return TCL_OK;
}


static int
cmdReverse(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "gameInfo", "player", "event", "site", "annotator", 0 };
	static char const* args[] =
	{
		"<database> ?<view>?",
		"<database> ?<view>?",
		"<database> ?<view>?",
		"<database> ?<view>?",
		"<database> ?<view>?",
	};
	enum { Cmd_GameInfo, Cmd_Player, Cmd_Event, Cmd_Site, Cmd_Annotator };

	if (objc < 3 || 4 < objc)
		return usage(::CmdReverse, nullptr, nullptr, subcommands, args);

	int			view		= View::DefaultView;
	int			index		= tcl::uniqueMatchObj(objv[1], subcommands);
	char const*	database	= Tcl_GetString(objv[2]);

	if (objc == 4 && Tcl_GetIntFromObj(ti, objv[3], &view) != TCL_OK)
		return error(CmdReverse, nullptr, nullptr, "integer expected for view argument");

	switch (index)
	{
		case Cmd_GameInfo:
			scidb->reverse(scidb->cursor(database), view, attribute::game::Number);
			break;

		case Cmd_Player:
			scidb->reverse(scidb->cursor(database), view, attribute::player::Name);
			break;

		case Cmd_Event:
			scidb->reverse(scidb->cursor(database), view, attribute::event::Title);
			break;

		case Cmd_Site:
			scidb->reverse(scidb->cursor(database), view, attribute::site::Site);
			break;

		case Cmd_Annotator:
			scidb->reverse(scidb->cursor(database), view, attribute::annotator::Name);
			break;

		default:
			return usage(::CmdReverse, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdMatch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5 && objc != 7)
	{
		Tcl_WrongNumArgs(
			ti,
			1,
			objv,
			"player|event|site|annotator <database> <maximal> <string> "
			"?<rating-type> <two-ratings-flag>?");
		return TCL_ERROR;
	}

	Namebase::Type		type			= getNamebaseType(objv[1], ::CmdMatch);
	char const*			database		= stringFromObj(objc, objv, 2);
	unsigned				maximal		= unsignedFromObj(objc, objv, 3);
	mstl::string		suffix		= stringFromObj(objc, objv, 4);
	rating::Type		ratingType	= rating::Any;
	bool					twoRatings	= true;
	Player::Matches	playerMatches;
	Site::Matches		siteMatches;

	if (objc > 5)
		ratingType = rating::fromString(stringFromObj(objc, objv, 5));
	if (objc > 6)
		twoRatings	= boolFromObj(objc, objv, 6);

	if (twoRatings && ratingType == rating::Elo)
		ratingType = rating::Any;

	Namebase::Matches matches;
	Scidb->cursor(database).database().namebase(type).findMatches(suffix, matches, maximal);
	M_ASSERT(matches.size() <= maximal);

	unsigned resultSize = matches.size();

	switch (unsigned(type))
	{
		case Namebase::Player:
			Player::findMatches(suffix, playerMatches, maximal - matches.size());
			M_ASSERT(playerMatches.size() <= maximal - matches.size());
			resultSize += playerMatches.size();
			break;

		case Namebase::Site:
			Site::findMatches(suffix, siteMatches, maximal - matches.size());
			M_ASSERT(siteMatches.size() <= maximal - matches.size());
			resultSize += siteMatches.size();
			break;
	}

	Tcl_Obj* result[resultSize];

	for (unsigned i = 0; i < matches.size(); ++i)
	{
		NamebaseEntry const* entry = matches[i];

		Tcl_Obj* objs[11];
		unsigned n = 0;

		objs[n++] = Tcl_NewIntObj(entry->frequency());
		objs[n++] = Tcl_NewStringObj(entry->name(), -1);

		switch (unsigned(type))
		{
			case Namebase::Player:
				{
					NamebasePlayer const* player = static_cast<NamebasePlayer const*>(entry);

					uint32_t fideID = player->fideID();

					objs[n++] = Tcl_NewStringObj(player->name(), -1);
					objs[n++] = fideID ? Tcl_NewIntObj(player->fideID()) : Tcl_NewListObj(0, 0);
					objs[n++] = Tcl_NewStringObj(species::toString(player->type()), -1);
					objs[n++] = Tcl_NewStringObj(sex::toString(player->sex()), -1);
					objs[n++] = Tcl_NewStringObj(country::toString(player->federation()), -1);
					objs[n++] = Tcl_NewStringObj(title::toString(player->title()), -1);
					objs[n++] = Tcl_NewIntObj(player->elo());

					if (ratingType != rating::Any && player->rating(ratingType) != 0)
					{
						objs[n++] = Tcl_NewStringObj(rating::toString(ratingType), -1);
						objs[n++] = Tcl_NewIntObj(player->rating(ratingType));
					}
					else if (twoRatings || player->elo() == 0)
					{
						objs[n++] = Tcl_NewStringObj(rating::toString(player->ratingType()), -1);
						objs[n++] = Tcl_NewIntObj(player->rating());
					}
					else
					{
						objs[n++] = Tcl_NewStringObj(rating::toString(rating::Elo), -1);
						objs[n++] = Tcl_NewIntObj(player->elo());
					}
				}
				break;

			case Namebase::Event:
				{
					NamebaseEvent const* event = static_cast<NamebaseEvent const*>(entry);

					objs[n++] = Tcl_NewStringObj(event->site()->name(), -1);
					objs[n++] = Tcl_NewStringObj(country::toString(event->site()->country()), -1);
					objs[n++] = Tcl_NewStringObj(event->date().asShortString(), -1);
					objs[n++] = Tcl_NewStringObj(event::toString(event->eventMode()), -1);
					objs[n++] = Tcl_NewStringObj(event::toString(event->type()), -1);
					objs[n++] = Tcl_NewStringObj(time::toString(event->timeMode()), -1);
				}
				break;

			case Namebase::Site:
				{
					NamebaseSite const* site = static_cast<NamebaseSite const*>(entry);
					objs[n++] = Tcl_NewStringObj(entry->name(), -1);
					objs[n++] = Tcl_NewStringObj(country::toString(site->country()), -1);
				}
				break;
		}

		M_ASSERT(n <= U_NUMBER_OF(objs));
		result[i] = Tcl_NewListObj(n, objs);
	}

	switch (unsigned(type))
	{
		case Namebase::Player:
			for (unsigned i = 0; i < playerMatches.size(); ++i)
			{
				Tcl_Obj* objs[11];
				unsigned n = 0;

				Player const* player = playerMatches[i];
				mstl::string const& ascii = player->asciiName();
				uint32_t fideID = player->fideID();

				objs[n++] = Tcl_NewIntObj(0);
				objs[n++] = Tcl_NewStringObj(player->name(), player->name().size());
				objs[n++] = Tcl_NewStringObj(ascii.empty() ? player->name() : ascii, -1);
				objs[n++] = fideID ? Tcl_NewIntObj(player->fideID()) : Tcl_NewListObj(0, 0);
				objs[n++] = Tcl_NewStringObj(species::toString(player->type()), -1);
				objs[n++] = Tcl_NewStringObj(sex::toString(player->sex()), -1);
				objs[n++] = Tcl_NewStringObj(country::toString(player->federation()), -1);;
				objs[n++] = Tcl_NewStringObj(title::toString(title::best(player->titles())), -1);
				objs[n++] = Tcl_NewIntObj(player->latestElo());

				if (ratingType != rating::Any && player->latestRating(ratingType) != 0)
				{
					objs[n++] = Tcl_NewStringObj(rating::toString(ratingType), -1);
					objs[n++] = Tcl_NewIntObj(player->latestRating(ratingType));
				}
				else if (twoRatings || player->latestElo() == 0)
				{
					rating::Type rt = player->ratingType();

					if (rt == rating::Elo)
						rt = rating::Any;

					unsigned score = rt == rating::Any ? 0 : player->latestRating(rt);

					objs[n++] = Tcl_NewStringObj(rating::toString(rt), -1);
					objs[n++] = Tcl_NewIntObj(score);
				}
				else
				{
					objs[n++] = Tcl_NewStringObj(rating::toString(rating::Elo), -1);
					objs[n++] = Tcl_NewIntObj(player->latestElo());
				}

				result[matches.size() + i] = Tcl_NewListObj(n, objs);
				M_ASSERT(n <= U_NUMBER_OF(objs));
			}

		case Namebase::Site:
			for (unsigned i = 0; i < siteMatches.size(); ++i)
			{
				Tcl_Obj* objs[4];
				unsigned n = 0;

				Site const* site = siteMatches[i].second;
				country::Code country = siteMatches[i].first;
				mstl::string const& ascii = site->nonDiacriticName(country);

				objs[n++] = Tcl_NewIntObj(0);
				objs[n++] = Tcl_NewStringObj(site->name(), site->name().size());
				objs[n++] = Tcl_NewStringObj(ascii, ascii.size());
				objs[n++] = Tcl_NewStringObj(country::toString(country), -1);;

				result[matches.size() + i] = Tcl_NewListObj(n, objs);
			}
			break;
	}

	setResult(resultSize, result);
	return TCL_OK;
}


static int
cmdFind(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "player|event|site|annotator <database> <key>");
		return TCL_ERROR;
	}

	char const*	database	= stringFromObj(objc, objv, 2);
	Tcl_Obj*		keyObj	= objv[3];
	unsigned		numObjs	= 0;

	if (strcmp(stringFromObj(objc, objv, 1), "player") == 0)
	{
		numObjs = PlayerKey_LAST;
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "event") == 0)
	{
		numObjs = EventKey_LAST;
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "site") == 0)
	{
		numObjs = SiteKey_LAST;
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "annotator") == 0)
	{
		numObjs = 1;
	}
	else
	{
		return error(	CmdFind,
							nullptr,
							nullptr,
							"only 'player', 'event', 'site', or 'annotator' is allowed");
	}

	Tcl_Obj* objs[numObjs];
	memset(objs, 0, sizeof(objs));

	for (unsigned i = 0; i < numObjs; ++i)
	{
		Tcl_ListObjIndex(ti, keyObj, i, &objs[i]);

		if (objs[i] == 0)
			return error(CmdFind, nullptr, nullptr, "invalid info list");
	}

	Database const& db = Scidb->cursor(database).database();
	int index = -1;

	if (strcmp(stringFromObj(objc, objv, 1), "player") == 0)
	{
		int fideId = 0;
		Tcl_GetIntFromObj(ti, objs[PlayerKey_FideID], &fideId);

		index = db.namebase(Namebase::Player).findPlayerIndex(
						Tcl_GetString(objs[PlayerKey_Name]),
						fideId,
						country::fromString(Tcl_GetString(objs[PlayerKey_Country])),
						title::fromString(Tcl_GetString(objs[PlayerKey_Title])),
						species::fromString(Tcl_GetString(objs[PlayerKey_Type])),
						sex::fromString(Tcl_GetString(objs[PlayerKey_Sex])));
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "event") == 0)
	{
		NamebaseSite const* site = db.namebase(Namebase::Site).findSite(
												Tcl_GetString(objs[EventKey_Site]),
												country::fromString(Tcl_GetString(objs[EventKey_SiteCountry])));

		if (site)
		{
			index = db.namebase(Namebase::Event).findEventIndex(
				Tcl_GetString(objs[EventKey_Name]),
				Date(Tcl_GetString(objs[EventKey_Date])),
				event::typeFromString(Tcl_GetString(objs[EventKey_Type])),
				time::fromString(Tcl_GetString(objs[EventKey_TimeMode])),
				event::modeFromString(Tcl_GetString(objs[EventKey_EventMode])),
				site
			);
		}
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "site") == 0)
	{
		index = db.namebase(Namebase::Site).findSiteIndex(
			Tcl_GetString(objs[SiteKey_Site]),
			country::fromString(Tcl_GetString(objs[SiteKey_Country]))
		);
	}
	else if (strcmp(stringFromObj(objc, objv, 1), "annotator") == 0)
	{
		index = db.namebase(Namebase::Annotator).findAnnotatorIndex(Tcl_GetString(objs[0]));
	}

	setResult(index);
	return TCL_OK;
}


static int
cmdSave(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <start> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	char const*	db(stringFromObj(objc, objv, 1));
	Cursor&		cursor(scidb->cursor(db));
	Progress		progress(objv[3], objv[4]);
	unsigned		start(unsignedFromObj(objc, objv, 2));

	scidb->save(cursor, progress, start);
	return TCL_OK;
}


static int
cmdUpdate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	database	= stringFromObj(objc, objv, 1);
	unsigned		index		= unsignedFromObj(objc, objv, 2);

	int rc = TCL_OK;
	TagSet tags;

	if ((rc = game::convertTags(tags, objectFromObj(objc, objv, 3))) == TCL_OK)
		scidb->cursor(database).updateCharacteristics(index, tags);

	return rc;
}


static int
cmdUpgrade(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	struct Log : public ::db::Log
	{
		bool error(save::State, unsigned) override	{ return true; }
		void warning(Warning, unsigned) override		{}
	};

	mstl::string database(stringFromObj(objc, objv, 1));
	mstl::string filename(::util::misc::file::rootname(database));

	filename += ".partial-293t83873xx878.sci";

	Progress			progress(objv[2], objv[3]);
	Cursor&			cursor(scidb->cursor(database));
	Database&		db(cursor.database());
	View&				v(cursor.view());
	Log				log;
	type::ID			type(db.type());
	View::FileMode	fmode(DatabaseCodec::upgradeIndexOnly() ? View::Create : View::Upgrade);

	try
	{
		setResult(v.exportGames(sys::file::internalName(filename),
										sys::utf8::Codec::utf8(),
										db.description(),
										type,
										0,
										::db::copy::AllGames,
										View::TagBits(true),
										true,
										log,
										progress,
										fmode));

		::db::sci::Codec::rename(filename, database);
	}
	catch (...)
	{
		::db::sci::Codec::remove(filename);
		throw;
	}

	return TCL_OK;
}


static int
cmdCompact(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	Progress progress(objv[2], objv[3]);
	scidb->compactBase(scidb->cursor(stringFromObj(objc, objv, 1)), progress);

	return TCL_OK;
}


static int
cmdWrite(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 6)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv, "<database> <file-extension> <channel> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	char const*	baseName		= stringFromObj(objc, objv, 1);
	char const* extension	= stringFromObj(objc, objv, 2);
	char const* channelName	= stringFromObj(objc, objv, 3);

	tcl::Progress		progress(objv[4], objv[5]);
	Tcl_Channel			chan(Tcl_GetChannel(ti, channelName, 0));
	tcl::File			file(chan);
	util::ZlibOStream	os(file.handle());

	if (strcmp(extension, "sci") == 0)
		scidb->cursor(baseName).database().writeIndex(os, progress);
	else if (strcmp(extension, "scn") == 0)
		scidb->cursor(baseName).database().writeNamebases(os, progress);
	else if (strcmp(extension, "scg") == 0)
		scidb->cursor(baseName).database().writeGames(os, progress);
	else
		return error(CmdWrite, 0, 0, "unexpected extension '%s'", extension);

	os.flush();
	file.flush();
	os.close();
	file.close();

	Tcl_Obj* objs[3];
	objs[0] = Tcl_NewIntObj(os.size());
	objs[1] = Tcl_NewIntObj(os.compressedSize());
	objs[2] = Tcl_NewIntObj(os.crc());
	setResult(3, objs);

	return TCL_OK;
}


static Tcl_Obj*
wikiLinkList(Player const* player)
{
	typedef Player::AssocList AssocList;

	AssocList wikiLinks;

	if (player->wikipediaLinks(wikiLinks))
	{
		Tcl_Obj* objs[mstl::mul2(wikiLinks.size())];
		unsigned n = 0;

		Player::AssocList::const_iterator i = wikiLinks.begin();
		Player::AssocList::const_iterator e = wikiLinks.end();

		for ( ; i != e; ++i)
		{
			Player::Assoc const& assoc = *i;

			objs[n++] = Tcl_NewStringObj(assoc.first, -1);
			objs[n++] = Tcl_NewStringObj(assoc.second, -1);
		}

		return Tcl_NewListObj(n, objs);
	}

	return Tcl_NewListObj(0, 0);
}


int
tcl::db::getPlayerInfo(NamebasePlayer const& player, Ratings const& ratings, bool info, bool idCard)
{
	M_ASSERT(!idCard || info);

	Tcl_Obj* objv[info ? attribute::player::LastInfo : attribute::player::LastColumn];

	M_ASSERT(::memset(objv, 0, sizeof(objv)));

	mstl::string			title;
	char const*				federation(mstl::string::empty_string.c_str());
	mstl::string const*	name(&player.name());
	mstl::string			sex(sex::toString(player.sex()));
	int32_t					fideID(player.fideID());
	Player const*			p(player.player());

	if (p)
	{
		if (idCard || player.title() == title::None)
		{
			unsigned titles = p->titles();

			while (titles)
			{
				unsigned t = 1u << mstl::bf::lsb_index(titles);

				if (!title.empty())
					title += ' ';

				title += title::toString(title::toID(t));
				titles &= ~t;
			}
		}

		if (idCard || player.federation() == country::Unknown)
			federation = country::toString(p->federation());

		if (idCard || player.sex() == sex::Unspecified)
			sex = sex::toString(p->sex());

		if (idCard)
			name = &p->name();

		if (fideID == 0)
		{
			fideID = p->fideID();

			if (!idCard)
				fideID = -fideID;
		}
	}

	if (title.empty())
		title = title::toString(player.title());

	if (!*federation)
		federation = country::toString(player.federation());

	int16_t rating1[2];
	int16_t rating2[2];

	::playerRatings(player, ratings.first,  rating1);
	::playerRatings(player, ratings.second, rating2);

	Tcl_Obj* ratingObj1[2] = { Tcl_NewIntObj(rating1[0]), Tcl_NewIntObj(rating1[1]) };
	Tcl_Obj* ratingObj2[2] = { Tcl_NewIntObj(rating2[0]), Tcl_NewIntObj(rating2[1]) };

	mstl::string const ratingType = rating::toString(player.playerRatingType());

	objv[attribute::player::Name      ] = Tcl_NewStringObj(*name, name->size());
	objv[attribute::player::FideID    ] = fideID ? Tcl_NewIntObj(fideID) : Tcl_NewListObj(0, 0);
	objv[attribute::player::Sex       ] = Tcl_NewStringObj(sex, -1);
	objv[attribute::player::Rating1   ] = Tcl_NewListObj(2, ratingObj1);
	objv[attribute::player::Rating2   ] = Tcl_NewListObj(2, ratingObj2);
	objv[attribute::player::RatingType] = Tcl_NewStringObj(ratingType, ratingType.size());
	objv[attribute::player::Country   ] = Tcl_NewStringObj(federation, -1);
	objv[attribute::player::Title     ] = Tcl_NewStringObj(title, -1);
	objv[attribute::player::Type      ] = Tcl_NewStringObj(species::toString(player.findType()), -1);
	objv[attribute::player::PlayerInfo] = Tcl_NewBooleanObj(player.havePlayerInfo());
	objv[attribute::player::Frequency ] = Tcl_NewIntObj(player.frequency());

	M_ASSERT(::checkNonZero(objv, attribute::player::LastColumn));

	if (info)
	{
		unsigned			viafID(0);
		unsigned			iccfID(0);
		mstl::string	dsbID;
		mstl::string	ecfID;
		mstl::string	pndID;
		mstl::string	chessgamesID;
		Date				dateOfBirth;
		Date				dateOfDeath;
		Tcl_Obj*			wikiLinkList(0);
		Tcl_Obj*			aliasList(0);

		if (p)
		{
			typedef Player::StringList	StringList;

			dateOfBirth = p->dateOfBirth();
			dateOfDeath = p->dateOfDeath();
			iccfID = p->iccfID();
			dsbID = p->dsbID();
			ecfID = p->ecfID();
			viafID = p->viafID();
			pndID = p->pndID();
			chessgamesID = p->chessgamesID();
			wikiLinkList = ::wikiLinkList(p);

			StringList const& aliases = p->aliases();

			if (!aliases.empty())
			{
				Tcl_Obj* objs[aliases.size()];

				for (unsigned i = 0; i < aliases.size(); ++i)
					objs[i] = Tcl_NewStringObj(aliases[i], aliases[i].size());

				aliasList = Tcl_NewListObj(aliases.size(), objs);
			}
		}

		objv[attribute::player::DateOfBirth  ] = Tcl_NewStringObj(dateOfBirth.asShortString(), -1);
		objv[attribute::player::DateOfDeath  ] = Tcl_NewStringObj(dateOfDeath.asShortString(), -1);
		objv[attribute::player::DsbID        ] = Tcl_NewStringObj(dsbID, dsbID.size());
		objv[attribute::player::EcfID        ] = Tcl_NewStringObj(ecfID, ecfID.size());
		objv[attribute::player::IccfID       ] = iccfID ? Tcl_NewIntObj(iccfID) : Tcl_NewStringObj(0, 0);
		objv[attribute::player::ViafID       ] = viafID ? Tcl_NewIntObj(viafID) : Tcl_NewStringObj(0, 0);
		objv[attribute::player::PndID        ] = Tcl_NewStringObj(pndID, pndID.size());
		objv[attribute::player::ChessgComLink] = Tcl_NewStringObj(chessgamesID, chessgamesID.size());
		objv[attribute::player::WikiLink     ] = wikiLinkList ? wikiLinkList : Tcl_NewListObj(0, 0);
		objv[attribute::player::Aliases      ] = aliasList ? aliasList : Tcl_NewListObj(0, 0);

		M_ASSERT(::checkNonZero(objv, attribute::player::LastInfo));
	}

	setResult(info ? attribute::player::LastInfo : attribute::player::LastColumn, objv);
	return TCL_OK;
}


int
tcl::db::getPlayerStats(Database const& database, NamebasePlayer const& player)
{
	PlayerStats stats;
	database.playerStatistic(player, stats);

	Tcl_Obj* objv[7];
	Tcl_Obj* objs[4];

	objs[0] = Tcl_NewStringObj(stats.firstDate().asString(), -1);
	objs[1] = Tcl_NewStringObj(stats.lastDate().asString(), -1);
	objv[0] = Tcl_NewListObj(2, objs);

	objs[0] = Tcl_NewIntObj(stats.minRating(rating::Elo));
	objs[1] = Tcl_NewIntObj(stats.maxRating(rating::Elo));
	objv[1] = Tcl_NewListObj(2, objs);

	objv[2] = Tcl_NewIntObj(stats.countGames());

	objs[0] = Tcl_NewIntObj(stats.score(color::White, result::White));
	objs[1] = Tcl_NewIntObj(stats.score(color::White, result::Black));
	objs[2] = Tcl_NewIntObj(stats.score(color::White, result::Draw));
	objs[3] = Tcl_NewIntObj(int(stats.percentage(color::White)*100.0));
	objv[3] = Tcl_NewListObj(4, objs);

	objs[0] = Tcl_NewIntObj(stats.score(color::Black, result::Black));
	objs[1] = Tcl_NewIntObj(stats.score(color::Black, result::White));
	objs[2] = Tcl_NewIntObj(stats.score(color::Black, result::Draw));
	objs[3] = Tcl_NewIntObj(int(stats.percentage(color::Black)*100.0));
	objv[4] = Tcl_NewListObj(4, objs);

	objs[0] = Tcl_NewIntObj(stats.score(result::White));
	objs[1] = Tcl_NewIntObj(stats.score(result::Black));
	objs[2] = Tcl_NewIntObj(stats.score(result::Draw));
	objs[3] = Tcl_NewIntObj(int(stats.percentage()*100.0));
	objv[5] = Tcl_NewListObj(4, objs);

	objs[0] = Tcl_NewListObj(0, 0);
	for (unsigned i = 0, n = mstl::min(5u, stats.countEcoLines(color::White)); i < n; ++i)
	{
		Tcl_Obj* argv[2];
		mstl::string line;

		EcoTable::specimen().getLine(stats.ecoLine(color::White, i)).print(line, encoding::Utf8);
		argv[0] = Tcl_NewIntObj(stats.ecoCount(color::White, i));
		argv[1] = Tcl_NewStringObj(line, line.size());
		Tcl_ListObjAppendElement(0, objs[0], Tcl_NewListObj(2, argv));
	}
	objs[1] = Tcl_NewListObj(0, 0);
	for (unsigned i = 0, n = mstl::min(5u, stats.countEcoLines(color::Black)); i < n; ++i)
	{
		Tcl_Obj* argv[2];
		mstl::string line;

		EcoTable::specimen().getLine(stats.ecoLine(color::Black, i)).print(line, encoding::Utf8);
		argv[0] = Tcl_NewIntObj(stats.ecoCount(color::Black, i));
		argv[1] = Tcl_NewStringObj(line, line.size());
		Tcl_ListObjAppendElement(0, objs[1], Tcl_NewListObj(2, argv));
	}
	objv[6] = Tcl_NewListObj(2, objs);

	setResult(U_NUMBER_OF(objv), objv);
	return TCL_OK;
}


namespace tcl {
namespace db {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAttach,			cmdAttach);
	createCommand(ti, CmdClear,			cmdClear);
	createCommand(ti, CmdClose,			cmdClose);
	createCommand(ti, CmdCompact,			cmdCompact);
	createCommand(ti, CmdCount,			cmdCount);
	createCommand(ti, CmdFetch,			cmdFetch);
	createCommand(ti, CmdFind,				cmdFind);
	createCommand(ti, CmdImport,			cmdImport);
	createCommand(ti, CmdLoad,				cmdLoad);
	createCommand(ti, CmdNew,				cmdNew);
	createCommand(ti, CmdSet,				cmdSet);
	createCommand(ti, CmdGet,				cmdGet);
	createCommand(ti, CmdMatch,			cmdMatch);
	createCommand(ti, CmdPlayerCard,		cmdPlayerCard);
	createCommand(ti, CmdPlayerInfo,		cmdPlayerInfo);
	createCommand(ti, CmdRecode,			cmdRecode);
	createCommand(ti, CmdReverse,			cmdReverse);
	createCommand(ti, CmdSave,				cmdSave);
	createCommand(ti, CmdSort,				cmdSort);
	createCommand(ti, CmdSubscribe,		cmdSubscribe);
	createCommand(ti, CmdSwitch,			cmdSwitch);
	createCommand(ti, CmdUnsubscribe,	cmdUnsubscribe);
	createCommand(ti, CmdUpdate,			cmdUpdate);
	createCommand(ti, CmdUpgrade,			cmdUpgrade);
	createCommand(ti, CmdWrite,			cmdWrite);
}

} // namespace db
} // namespace tcl

// vi:set ts=3 sw=3:
