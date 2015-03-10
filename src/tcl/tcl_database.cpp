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

#include "tcl_database.h"
#include "tcl_tree.h"
#include "tcl_application.h"
#include "tcl_pgn_reader.h"
#include "tcl_player.h"
#include "tcl_progress.h"
#include "tcl_exception.h"
#include "tcl_game.h"
#include "tcl_view.h"
#include "tcl_file.h"
#include "tcl_tree.h"
#include "tcl_log.h"
#include "tcl_obj.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_multi_cursor.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_database.h"
#include "db_database_codec.h"
#include "db_multi_base.h"
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

#include "m_utility.h"
#include "m_bitset.h"
#include "m_vector.h"
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
static char const* CmdCopy				= "::scidb::db::copy";
static char const* CmdCount			= "::scidb::db::count";
static char const* CmdFetch			= "::scidb::db::fetch";
static char const* CmdFind				= "::scidb::db::find";
static char const* CmdImport			= "::scidb::db::import";
static char const* CmdLoad				= "::scidb::db::load";
static char const* CmdNew				= "::scidb::db::new";
static char const* CmdSet				= "::scidb::db::set";
static char const* CmdGet				= "::scidb::db::get";
static char const* CmdMatch			= "::scidb::db::match";
static char const* CmdOpen				= "::scidb::db::open";
static char const* CmdPlayerCard		= "::scidb::db::playerCard";
static char const* CmdPlayerInfo		= "::scidb::db::playerInfo";
static char const* CmdRecode			= "::scidb::db::recode";
static char const* CmdReverse			= "::scidb::db::reverse";
static char const* CmdSave				= "::scidb::db::save";
static char const* CmdSavePGN			= "::scidb::db::savePGN";
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


static bool
isOption(char const* s)
{
	return s[0] == '-' && !isdigit(s[1]);
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
			if      (c == User1) flags[i] = '1';
			else if (c == User2) flags[i] = '2';
			else if (c == User3) flags[i] = '3';
			else if (c == User4) flags[i] = '4';
			else if (c == User5) flags[i] = '5';
			else if (c == User6) flags[i] = '6';
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
		GameList				= 1 << table::Games,
		PlayerList			= 1 << table::Players,
		EventList			= 1 << table::Events,
		SiteList				= 1 << table::Sites,
		AnnotatorList		= 1 << table::Annotators,
		DatabaseInfo		= 1 << 5,
		GameInfo				= 1 << 6,
		GameData				= 1 << 7,
		GameHistory			= 1 << 8,
		GameSwitched		= 1 << 9,
		GameClosed			= 1 << 10,
		DatabaseSwitched	= 1 << 11,
		Tree					= 1 << 12,
		None					= 1 << 13,
	};

	typedef mstl::tuple<Obj, Obj, Obj> Tuple;

	struct Args
	{
		Args() :m_type(GameList), m_tuple(0, 0, 0), m_ref(0) {}

		Args(Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
			:m_type(type)
			,m_tuple(updateCmd, closeCmd, arg ? arg : Tcl_NewListObj(0, 0))
			,m_ref(0)
		{
			static_assert(table::Games      < 5, "index failure");
			static_assert(table::Players    < 5, "index failure");
			static_assert(table::Events     < 5, "index failure");
			static_assert(table::Sites      < 5, "index failure");
			static_assert(table::Annotators < 5, "index failure");
		}

		void ref()
		{
			if (m_ref++ == 0)
			{
				m_tuple.get<0>().ref();
				m_tuple.get<1>().ref();
				m_tuple.get<2>().ref();
			}
		}

		void deref()
		{
			M_ASSERT(m_ref > 0);

			if (--m_ref == 0)
			{
				m_tuple.get<0>().deref();
				m_tuple.get<1>().deref();
				m_tuple.get<2>().deref();

				m_type = None;
				m_tuple = Tuple(0, 0, 0);
			}
		}

		Type		m_type;
		Tuple		m_tuple;
		unsigned	m_ref;

		bool operator==(Args const& args) const
		{
			return m_type == args.m_type && m_tuple == args.m_tuple;
		}

		Tcl_Obj* getUpdate() const	{ return m_tuple.get<0>(); }
		Tcl_Obj* getClose() const	{ return m_tuple.get<1>(); }
		Tcl_Obj* getArg() const		{ return m_tuple.get<2>(); }
	};

	typedef mstl::vector<Args> ArgsList;

	ArgsList			m_list;
	mstl::bitset	m_used;
	unsigned			m_last;

	void setCmd(Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		Args args(type, updateCmd, closeCmd, arg);
		ArgsList::iterator i = mstl::find(m_list.begin(), m_list.end(), args);

		if (i == m_list.end())
		{
			unsigned index = m_used.find_first_not();

			if (index == m_used.npos)
			{
				index = m_list.size();
				m_list.push_back();
				m_used.resize(m_list.size());
			}

			m_list[index] = args;
			m_list[index].ref();
			m_used.set(index);
			m_last = m_used.find_last() + 1;
		}
		else
		{
			i->ref();
		}
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
			m_used.reset(i - m_list.begin());
			m_last = m_used.find_last() + 1;
		}
	}

	void setListCmd(table::Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		setCmd(Type(1 << type), updateCmd, closeCmd, arg);
	}

	void setGameSwitchedCmd(Tcl_Obj* updateCmd)
	{
		setCmd(GameSwitched, updateCmd, 0, 0);
	}

	void setGameClosedCmd(Tcl_Obj* updateCmd)
	{
		setCmd(GameClosed, updateCmd, 0, 0);
	}

	void setDatabaseSwitchedCmd(Tcl_Obj* updateCmd)
	{
		setCmd(DatabaseSwitched, updateCmd, 0, 0);
	}

	void unsetListCmd(table::Type type, Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(Type(1 << type), updateCmd, closeCmd, arg);
	}

	void unsetTreeCmd(Tcl_Obj* updateCmd, Tcl_Obj* closeCmd, Tcl_Obj* arg)
	{
		unsetCmd(Tree, updateCmd, closeCmd, arg);
	}

	void closeDatabase(mstl::string const& name, variant::Type variant) override
	{
		Tcl_Obj* file = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);

		Tcl_IncrRefCount(file);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.getClose())
				invoke(__func__, i.getClose(), i.getArg(), file, t, nullptr);
		}

		Tcl_DecrRefCount(file);
	}

	void updateDatabaseInfo(mstl::string const& name, variant::Type variant) override
	{
		Tcl_Obj* f = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);

		Tcl_IncrRefCount(f);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type & DatabaseInfo)
				invoke(__func__, i.getUpdate(), i.getArg(), f, t, nullptr);
		}

		Tcl_DecrRefCount(f);
	}

	void updateList(	unsigned id,
							string const& name,
							variant::Type variant,
							unsigned view,
							unsigned index,
							Type type)
	{
		Tcl_Obj* n = Tcl_NewIntObj(id);
		Tcl_Obj* f = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);
		Tcl_Obj* v = Tcl_NewIntObj(view);
		Tcl_Obj* w = Tcl_NewIntObj(index);

		Tcl_IncrRefCount(n);
		Tcl_IncrRefCount(f);
		Tcl_IncrRefCount(v);
		Tcl_IncrRefCount(w);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type & type)
				invoke(__func__, i.getUpdate(), i.getArg(), n, f, t, v, w, nullptr);
		}

		Tcl_DecrRefCount(n);
		Tcl_DecrRefCount(f);
		Tcl_DecrRefCount(v);
		Tcl_DecrRefCount(w);
	}

	void updateList(table::Type type, unsigned id, string const& name, variant::Type variant) override
	{
		updateList(id, name, variant, unsigned(-1), unsigned(-1), Type(1 << type));
	}

	void updateList(	table::Type type,
							unsigned id,
							string const& name,
							variant::Type variant,
							unsigned view) override
	{
		updateList(id, name, variant, view, unsigned(-1), Type(1 << type));
	}

	void updateList(	table::Type type,
							unsigned id,
							string const& name,
							variant::Type variant,
							unsigned view,
							unsigned index) override
	{
		updateList(id, name, variant, view, index, Type(1 << type));
	}

	void updateGameData(unsigned position, bool evenMainline) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_Obj* mainline = Tcl_NewBooleanObj(evenMainline);

		Tcl_IncrRefCount(pos);
		Tcl_IncrRefCount(mainline);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == GameData)
				invoke(__func__, i.getUpdate(), i.getArg(), pos, mainline, nullptr);
		}

		Tcl_DecrRefCount(pos);
		Tcl_DecrRefCount(mainline);
	}

	void updateGameInfo(unsigned position) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_IncrRefCount(pos);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == GameInfo)
				invoke(__func__, i.getUpdate(), i.getArg(), pos, nullptr);
		}

		Tcl_DecrRefCount(pos);
	}

	void updateGameInfo(mstl::string const& name, variant::Type variant, unsigned index) override
	{
		Tcl_Obj* f = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);
		Tcl_Obj* w = Tcl_NewIntObj(index);

		Tcl_IncrRefCount(f);
		Tcl_IncrRefCount(w);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == GameHistory)
				invoke(__func__, i.getUpdate(), i.getArg(), f, t, w, nullptr);
		}

		Tcl_DecrRefCount(f);
		Tcl_DecrRefCount(w);
	}

	void gameSwitched(unsigned position) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_IncrRefCount(pos);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == GameSwitched)
				invoke(__func__, i.getUpdate(), pos, nullptr);
		}

		Tcl_DecrRefCount(pos);
	}

	void gameClosed(unsigned position) override
	{
		Tcl_Obj* pos = Tcl_NewIntObj(position);
		Tcl_IncrRefCount(pos);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == GameClosed)
				invoke(__func__, i.getUpdate(), pos, nullptr);
		}

		Tcl_DecrRefCount(pos);
	}

	void databaseSwitched(mstl::string const& name, variant::Type variant) override
	{
		Tcl_Obj* f = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);

		Tcl_IncrRefCount(f);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == DatabaseSwitched)
				invoke(__func__, i.getUpdate(), f, t, nullptr);
		}

		Tcl_DecrRefCount(f);
	}

	void updateTree(mstl::string const& name, variant::Type variant) override
	{
		static mstl::string prevFilename;

		if (name != prevFilename)
		{
			prevFilename = name;
			tcl::tree::referenceBaseChanged();
		}

		Tcl_Obj* file = Tcl_NewStringObj(name, name.size());
		Tcl_Obj* t = tcl::tree::variantToString(variant);

		Tcl_IncrRefCount(file);

		for (unsigned k = 0; k < m_last; ++k)
		{
			Args const& i = m_list[k];

			if (i.m_type == Tree)
				invoke(__func__, i.getUpdate(), i.getArg(), file, t, nullptr);
		}

		Tcl_DecrRefCount(file);
	}

	void invalidateTreeCache() override
	{
		tcl::tree::invalidateCache();
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
		case type::ThreeCheck:					return "ThreeCheck";
		case type::Crazyhouse:					return "Crazyhouse";
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


static void
flagsToString(unsigned flags, mstl::string& result)
{
	mstl::string buf;

	GameInfo::flagsToString(flags & ~GameInfo::Flag_Deleted, buf);

	for (unsigned i = 0; i < buf.size(); ++i)
	{
		result += buf[i];
		result += ' ';
	}

	result.trim();
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
		scidb->cursor(database).getDatabase().attach(filename, progress);
	}
	else
	{
		util::Progress progress;
		scidb->cursor(database).getDatabase().attach(filename, progress);
	}

	return TCL_OK;
}


static int
cmdLoad(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 4)
	{
		Tcl_WrongNumArgs(
			ti,
			1, objv,
			"<file> <progress-cmd> <arg> ?-encoding <string>? ?-readonly <flag>?");
		return TCL_ERROR;
	}

	char const* encoding = sys::utf8::Codec::utf8();
	permission::ReadMode permission = permission::ReadWrite;

	for ( ; objc > 4; objc -= 2)
	{
		char const* arg = stringFromObj(objc, objv, objc - 2);

		if (::strcmp(arg, "-encoding") == 0)
			encoding = stringFromObj(objc, objv, objc - 1);
		else if (::strcmp(arg, "-readonly") == 0)
			permission = boolFromObj(objc, objv, objc - 1) ? permission::ReadOnly : permission::ReadWrite;
		else
			error(CmdLoad, nullptr, nullptr, "unexpected option '%s'", arg);
	}

	mstl::string path(Tcl_GetString(objv[1]));

	if (util::misc::file::suffix(path) == "sci")
		encoding = sys::utf8::Codec::utf8();

	Progress	progress(objv[2], objv[3]);
	progress.checkInterruption();

	Cursor* cursor = scidb->open(path, encoding, permission, process::Synchronous, progress);

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
	static char const* Usage =
		"<database> <file> <log> <log-arg> <progress-cmd> <progress-arg> ?-encoding <string>?";

	if (objc < 7)
	{
		Tcl_WrongNumArgs(ti, 1, objv, Usage);
		return TCL_ERROR;
	}

	mstl::string	encoding		= sys::utf8::Codec::utf8();
	char const*		option		= stringFromObj(objc, objv, objc - 2);

	if (*option == '-')
	{
		if (::strcmp(option, "-encoding") == 0)
		{
			encoding = stringFromObj(objc, objv, objc - 1);
		}
		else
		{
			appendResult("unexpected option '%s'", option);
			return TCL_ERROR;
		}

		objc -= 2;
	}

	if (objc < 7)
	{
		Tcl_WrongNumArgs(ti, 1, objv, Usage);
		return TCL_ERROR;
	}

	mstl::string	dst(stringFromObj(objc, objv, 1));
	mstl::string	src(stringFromObj(objc, objv, 2));
	mstl::string	ext(::util::misc::file::suffix(src));
	Progress			progress(objv[5], objv[6]);
	int				count = 0;

	if (ext == "sci" || ext == "si3" || ext == "si4")
	{
		unsigned accepted[variant::NumberOfVariants];
		unsigned rejected[variant::NumberOfVariants];

		::memset(accepted, 0, sizeof(accepted));
		::memset(rejected, 0, sizeof(accepted));

		tcl::Log log(objv[3], objv[4]);
		unsigned illegalRejected = 0;

		if (scidb->contains(src))
		{
			::app::Application::Variants srcVariants = Scidb->getAllVariants(src);
			::app::Application::Variants dstVariants = Scidb->getAllVariants(dst);

			for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
			{
				if (srcVariants.test(v) && dstVariants.test(v))
				{
					variant::Type variant = variant::fromIndex(v);
					Cursor const& source(scidb->cursor(src, variant));
					Cursor& destination(const_cast<Cursor&>(Scidb->cursor(dst, variant)));
					unsigned k = destination.database().countGames();
					unsigned n = destination.importGames(source.database(), illegalRejected, log, progress);

					count += n;
					accepted[v] = n;
					rejected[v] = source.database().countGames() - n - k;
				}
				else if (srcVariants.test(v))
				{
					rejected[v] = scidb->cursor(src, variant::fromIndex(v)).database().countGames();
				}
			}
		}
		else
		{
			mstl::auto_ptr< ::db::Database> db;

			try
			{
				db = new ::db::Database(src, encoding);
			}
			catch (...)
			{
				appendResult("cannot open file '%s'", src.c_str());
				return TCL_ERROR;
			}

			unsigned variantIndex = variant::toIndex(db->variant());

			if (Scidb->contains(dst, db->variant()))
			{
				Cursor& destination(scidb->cursor(dst, db->variant()));
				unsigned k = destination.database().countGames();
				unsigned n = destination.importGames(*db, illegalRejected, log, progress);

				count += n;
				accepted[variantIndex] = n;
				rejected[variantIndex] = destination.database().countGames() - n - k;
			}
			else
			{
				rejected[variantIndex] = db->countGames();
			}
		}

		if (progress.interrupted())
			count = -count - 1;

		tcl::PgnReader::setResult(count, illegalRejected, accepted, rejected);
	}
	else if (ext == "pgn" || ext == "gz" || ext == "zip" || ext == "PGN" || ext == "ZIP")
	{
		util::ZStream stream(sys::file::internalName(src), ios_base::in);

		if (!stream)
		{
			appendResult("cannot open file '%s'", src.c_str());
			return TCL_ERROR;
		}

		::db::MultiBase& destination = scidb->multiBase(dst);

		tcl::PgnReader	reader(	stream,
										variant::Undetermined,
										encoding,
										objv[3],
										objv[4],
										tcl::PgnReader::Normalize,
										tcl::PgnReader::File);

		count = destination.importGames(reader, progress);
		stream.close();

		if (progress.interrupted())
			count = -count - 1;

		reader.setResult(count, 0);
	}
	else
	{
		appendResult("unsupported extension '%s'", ext.c_str());
		return TCL_ERROR;
	}

	return TCL_OK;
}


static int
cmdOpen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* Usage =
		"<file> <log> <log-arg> <progress-cmd> <progress-arg> ?-description <flag>?";

	if (objc < 6)
	{
		Tcl_WrongNumArgs(ti, 1, objv, Usage);
		return TCL_ERROR;
	}

	mstl::string	encoding		= sys::utf8::Codec::automatic();
	char const*		option		= stringFromObj(objc, objv, objc - 2);
	bool				description	= false;

	while (objc >= 6 && *option == '-')
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
		option = stringFromObj(objc, objv, objc - 2);
	}

	mstl::string	dst(stringFromObj(objc, objv, 1));
	mstl::string	ext(::util::misc::file::suffix(dst));
	Progress			progress(objv[4], objv[5]);

	ext.tolower();

	if (ext != "pgn" && ext != "gz" && ext != "zip" && ext != "PGN" && ext != "ZIP")
	{
		appendResult("unsupported extension '%s'", ext.c_str());
		return TCL_ERROR;
	}

	util::ZStream stream(sys::file::internalName(dst), ios_base::in);

	if (!stream)
	{
		appendResult("cannot open file '%s'", dst.c_str());
		return TCL_ERROR;
	}

	mstl::auto_ptr< ::db::FileOffsets> fileOffsets;

	if (ext == "pgn" || ext == "PGN" || ext == "gz")
		fileOffsets.reset(new ::db::FileOffsets);

	tcl::PgnReader	reader(	stream,
									variant::Undetermined,
									encoding,
									objv[2],
									objv[3],
									tcl::PgnReader::Normalize,
									tcl::PgnReader::File,
									fileOffsets.get());

	int n = scidb->create(dst, type::PGNFile, reader, progress);

	if (description)
	{
		for (unsigned v = 0; v < variant::NumberOfVariants; ++v)
		{
			variant::Type variant = variant::fromIndex(v);

			if (Scidb->contains(dst, variant))
				scidb->cursor(dst, variant).setupDescription(reader.description());
		}
	}

	stream.close();

	if (progress.interrupted())
	{
		scidb->multiCursor(dst).multiBase().setup(0);
		n = -n - 1;
	}
	else
	{
		scidb->multiCursor(dst).multiBase().setup(fileOffsets.release());
	}

	reader.setResult(n, 0);
	return TCL_OK;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4 && objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<file> <variant> <type> ?<encoding>?");
		return TCL_ERROR;
	}

	char const* name = stringFromObj(objc, objv, 1);
	variant::Type variant = tcl::game::variantFromObj(objc, objv, 2);
	int type;

	if (convToType(::CmdSet, objv[3], &type) != TCL_OK)
		return TCL_ERROR;

	mstl::string encoding;

	if (objc == 5)
		encoding = stringFromObj(objc, objv, 4);

	mstl::string suffix(util::misc::file::suffix(name));

	if (suffix == "pgn" || suffix == "gz" || suffix == "zip" || suffix == "PGN" || suffix == "ZIP")
	{
		// currently we do not support charset detection for PGN files
		if (encoding.empty() || encoding == sys::utf8::Codec::automatic())
			encoding = sys::utf8::Codec::latin1();
	}
	else if (encoding.empty() || encoding == sys::utf8::Codec::automatic())
	{
		encoding = sys::utf8::Codec::utf8();
	}

	if (scidb->create(name, variant, encoding, type::ID(type)) == 0)
		return error(::CmdNew, nullptr, nullptr, "database '%s' already exists", name);

	return TCL_OK;
}


static int
cmdSet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"type", "description", "readonly", "delete", "flag", "variant", 0,
	};
	static char const* args[] =
	{
		"<database> <number>",
		"<database> <string>",
		"?<database>? <bool>",
		"<index> <view> <database> <variant> <value>",
		"<index> <view> ?<database> <flag> <value>",
		"<database> <variant>",
	};
	enum { Cmd_Type, Cmd_Description, Cmd_Readonly, Cmd_Delete, Cmd_Flag, Cmd_Variant };

	if (objc < 2)
		return usage(::CmdSet, nullptr, nullptr, subcommands, args);

	int cmd = tcl::uniqueMatchObj(objv[1], subcommands);

	switch (cmd)
	{
		case Cmd_Delete:
			scidb->deleteGame(
				scidb->cursor(stringFromObj(objc, objv, 4), tcl::game::variantFromObj(objc, objv, 5)),
				intFromObj(objc, objv, 2),
				intFromObj(objc, objv, 3),
				intFromObj(objc, objv, 6));
			break;

		case Cmd_Flag:
		{
			int index	= intFromObj(objc, objv, 2);
			int view		= intFromObj(objc, objv, 3);

			char const*		base		= stringFromObj(objc, objv, 4);
			variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 5);

			Cursor& cursor = scidb->cursor(base, variant);
			mstl::string flags(stringFromObj(objc, objv, 6));

			if (cursor.database().format() == format::Scid4)
				::remapScid4Flags(flags);

			unsigned oldFlags = cursor.database().gameInfo(cursor.index(table::Games, index, view)).flags();
			unsigned newFlags = GameInfo::stringToFlags(flags);
			bool		value		= boolFromObj(objc, objv, 7);

			if (value)
				oldFlags |= newFlags;
			else
				oldFlags &= ~newFlags;

			scidb->setGameFlags(cursor, index, view, oldFlags);
			break;
		}

		case Cmd_Type:
		{
			int type;
			if (convToType(::CmdSet, objv[3], &type) != TCL_OK)
				return TCL_ERROR;
			scidb->cursor(stringFromObj(objc, objv, 2)).databaseObject().setType(type::ID(type));
			break;
		}

		case Cmd_Description:
		{
			Database& db = scidb->cursor(stringFromObj(objc, objv, 2)).databaseObject();
			char const* descr = stringFromObj(objc, objv, 3);

			if (strlen(descr) <= db.maxDescriptionLength())
			{
				db.updateDescription(descr);
				setResult(unsigned(0));
			}
			else
			{
				setResult(db.maxDescriptionLength());
			}
			break;
		}

		case Cmd_Readonly:
			if (objc == 4)
			{
				setResult(scidb->setReadonly(	scidb->multiCursor(stringFromObj(objc, objv, 2)),
														boolFromObj(objc, objv, 3)));
			}
			else
			{
				setResult(scidb->setReadonly(scidb->multiCursor(), boolFromObj(objc, objv, 2)));
			}
			break;

		case Cmd_Variant:
		{
			char const*		base		= stringFromObj(objc, objv, 2);
			variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 3);

			scidb->changeVariant(base, variant);
			break;
		}

		default:
			return usage(::CmdSet, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
countGames(char const* database)
{
	mstl::string base;
	if (database)
		base.assign(database);
	else
		base.assign(Scidb->cursor().name());
	::tcl::setResult(Scidb->countGames(base));
	return TCL_OK;
}


static int
count(table::Type type, char const* database, variant::Type variant)
{
	M_ASSERT(Scidb->contains(database, variant));
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	::tcl::setResult(cursor.count(type));
	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"games", "players", "annotators", "events", "sites", "total", 0
	};
	static char const* args[] =
	{
		"?\?<database>? <variant>?",
		"?\?<database>? <variant>?",
		"?\?<database>? <variant>?",
		"?\?<database>? <variant>?",
		"?\?<database>? <variant>?",
		"?<database>?",
	};
	enum { Cmd_Games, Cmd_Players, Cmd_Annotators, Cmd_Events, Cmd_Sites, Cmd_Total };

	char const*		base		= 0;
	variant::Type	variant	= variant::Undetermined;

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	if (index == Cmd_Total)
	{
		if (objc > 2)
			base = Tcl_GetString(objv[2]);
	}
	else
	{
		if (objc < 3)
		{
			variant = Scidb->currentVariant();
		}
		else if (objc == 3)
		{
			variant = tcl::game::variantFromObj(objc, objv, 2);
		}
		else
		{
			base = Tcl_GetString(objv[2]);
			variant = tcl::game::variantFromObj(objc, objv, 3);
		}
	}

	switch (index)
	{
		case Cmd_Players:		return count(table::Players, base, variant);
		case Cmd_Annotators:	return count(table::Annotators, base, variant);
		case Cmd_Games:		return count(table::Games, base, variant);
		case Cmd_Events:		return count(table::Events, base, variant);
		case Cmd_Sites:		return count(table::Sites, base, variant);
		case Cmd_Total:		return countGames(base);
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
getCodec()
{
	::tcl::setResult(Scidb->cursor().database().extension());
	return TCL_OK;
}


static int
getCodec(char const* database, variant::Type variant)
{
	M_ASSERT(database);

	if (variant != variant::Undetermined)
		variant = variant::toMainVariant(variant);

	M_ASSERT(Scidb->contains(database, variant));
	::tcl::setResult(Scidb->cursor(database, variant).database().extension());
	return TCL_OK;
}


static int
getEncoding(char const* database, variant::Type variant)
{
	M_ASSERT(database == 0 || Scidb->contains(database, variant));
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	::tcl::setResult(cursor.database().encoding());
	return TCL_OK;
}


static int
getUsedEncoding(char const* database, variant::Type variant)
{
	M_ASSERT(database == 0 || Scidb->contains(database, variant));
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	::tcl::setResult(cursor.database().usedEncoding());
	return TCL_OK;
}


static int
getCreated(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(Scidb->cursor(database).database().created().asString());
	return TCL_OK;
}


static int
getModified(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(Scidb->cursor(database).database().modified().asString());
	return TCL_OK;
}


static int
getReadonly(char const* database, variant::Type variant __attribute__((unused)))
{
	M_ASSERT(database == 0 || Scidb->contains(database, variant));
	MultiCursor const& cursor = database ? Scidb->multiCursor(database) : Scidb->multiCursor();
	::tcl::setResult(cursor.isReadonly());
	return TCL_OK;
}


static int
getWritable(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(Scidb->isWritable(database));
	return TCL_OK;
}


static int
getDescription(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(Scidb->cursor(database).database().description());
	return TCL_OK;
}


static int
getVariant(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(tcl::tree::variantToString(Scidb->cursor(database).database().variant()));
	return TCL_OK;
}


static int
getVariant(char const* database, unsigned number)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(tcl::tree::variantToString(Scidb->cursor(database).database().variant(number)));
	return TCL_OK;
}


static int
getVariants(char const* database)
{
	M_ASSERT(database);

	Application::Variants variants = Scidb->getAllVariants(database);

	Tcl_Obj* objs[::db::variant::NumberOfVariants];
	int objc = 0;

	for (	unsigned i = variants.find_first();
			i != Application::Variants::npos;
			i = variants.find_next(i))
	{
		M_ASSERT(objc < variant::NumberOfVariants);
		objs[objc++] = tcl::tree::variantToString(::db::variant::fromIndex(i));
	}

	setResult(objc, objs);
	return TCL_OK;
}


static int
isUnsaved(char const* database)
{
	M_ASSERT(database);
	setResult(Scidb->multiBase(database).isUnsaved());
	return TCL_OK;
}


static int
getChanges(char const* database)
{
	M_ASSERT(database);

	MultiBase const& base = Scidb->multiBase(database);
	Tcl_Obj* result[4];
	result[0] = Tcl_NewIntObj(base.countGames(MultiBase::Added));
	result[1] = Tcl_NewIntObj(base.countGames(MultiBase::Changed));
	result[2] = Tcl_NewIntObj(base.countGames(MultiBase::Deleted));
	result[3] = Tcl_NewBooleanObj(base.descriptionHasChanged());
	setResult(U_NUMBER_OF(result), result);
	return TCL_OK;
}


static int
getType(char const* database = 0)
{
	M_ASSERT(database == 0 || Scidb->contains(database));
	::tcl::setResult(lookupType(Scidb->cursor(database).type()));
	return TCL_OK;
}


static int
getGameIndex(int number, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database == 0 || Scidb->contains(database, variant));

	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	View const& v = cursor.view(view);

	if (number < int(v.total(table::Games)))
		::tcl::setResult(v.lookupGame(number));
	else
		::tcl::setResult(-1);

	return TCL_OK;
}


static int
getIndex(table::Type type, unsigned index, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database == 0 || Scidb->contains(database, variant));

	if (database)
		::tcl::setResult(Scidb->cursor(database, variant).view(view).index(type, index));
	else
		::tcl::setResult(Scidb->cursor().view(view).index(type, index));

	return TCL_OK;
}


static int
getLookupPlayer(unsigned index, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database);
	M_ASSERT(Scidb->contains(database, variant));
	::tcl::setResult(Scidb->cursor(database, variant).view(view).lookupPlayer(index));
	return TCL_OK;
}


static int
getLookupEvent(unsigned index, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database);
	M_ASSERT(Scidb->contains(database, variant));
	::tcl::setResult(Scidb->cursor(database, variant).view(view).lookupEvent(index));
	return TCL_OK;
}


static int
getLookupSite(unsigned index, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database);
	M_ASSERT(Scidb->contains(database, variant));
	::tcl::setResult(Scidb->cursor(database, variant).view(view).lookupSite(index));
	return TCL_OK;
}


static int
getAnnotatorIndex(char const* name, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database);
	M_ASSERT(Scidb->contains(database, variant));
	::tcl::setResult(Scidb->cursor(database, variant).view(view).lookupAnnotator(name));
	return TCL_OK;
}


static int
getStats(char const* database)
{
	Statistic const& statistic = Scidb->cursor(database).database().statistic();
	Tcl_Obj*	objv[14];

	objv[ 0] = Tcl_NewIntObj(statistic.deleted);
	objv[ 1] = Tcl_NewIntObj(statistic.changed);
	objv[ 2] = Tcl_NewIntObj(statistic.added);
	objv[ 3] = Tcl_NewIntObj(statistic.content.minYear);
	objv[ 4] = Tcl_NewIntObj(statistic.content.maxYear);
	objv[ 5] = Tcl_NewIntObj(statistic.content.avgYear);
	objv[ 6] = Tcl_NewIntObj(statistic.content.minElo);
	objv[ 7] = Tcl_NewIntObj(statistic.content.maxElo);
	objv[ 8] = Tcl_NewIntObj(statistic.content.avgElo);
	objv[ 9] = Tcl_NewIntObj(statistic.content.result[0]);
	objv[10] = Tcl_NewIntObj(statistic.content.result[1]);
	objv[11] = Tcl_NewIntObj(statistic.content.result[2]);
	objv[12] = Tcl_NewIntObj(statistic.content.result[3]);
	objv[13] = Tcl_NewIntObj(statistic.content.result[4]);

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
	objv[EventKey_TimeMode]		= Tcl_NewStringObj(::db::time::toString(event.timeMode()), -1);
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
getGameInfo(int index, int view, char const* database, variant::Type variant, unsigned which)
{
	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Games, index, view);

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

				if (variant::isShuffleChess(info.idn()))
					shuffle::utf8::position(info.idn(), position);
				else if (info.idn())
					position = variant::ficsIdentifier(info.idn());

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
				else if (info.idn() == variant::Standard)
					eco = info.ecoKey();

				if (eco)
				{
					EcoTable const& ecoTable = EcoTable::specimen(variant);
					ecoTable.getOpening(eco, openingLong, openingShort, variation, subvar);

					if (eco.basic() == info.ecoKey().basic())
					{
						mstl::string unused;
						ecoTable.getOpening(info.ecoKey(), unused, unused, variation, subvar);
					}
					else
					{
						variation.clear();
						subvar.clear();
					}
				}

				if (variant::isShuffleChess(info.idn()))
					shuffle::utf8::position(info.idn(), position);
				else if (info.idn())
					position = variant::ficsIdentifier(info.idn());

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

				flagsToString(info.flags(), flags);
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
			obj = Tcl_NewStringObj(::db::time::toString(info.timeMode()), -1);
			break;

		case attribute::game::EventCountry:
			obj = Tcl_NewStringObj(country::toString(info.findEventCountry()), -1);
			break;

		case attribute::game::EventType:
			obj = Tcl_NewStringObj(event::toString(info.eventType()), -1);
			break;

		case attribute::game::Deleted:
			obj = Tcl_NewBooleanObj(info.isDeleted());
			break;

		case attribute::game::Changed:
			obj = Tcl_NewBooleanObj(info.isChanged());
			break;

		case attribute::game::Added:
			obj = Tcl_NewBooleanObj(cursor.database().isAdded(index));
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

	if (variant::isShuffleChess(info.idn()))
		shuffle::utf8::position(info.idn(), startPosition);
	else if (info.idn())
		startPosition = variant::ficsIdentifier(info.idn());

	mstl::string openingLong, openingShort, variation, subvariation, round;

	Eco eco = info.eco();
	Eco eop = info.idn() == variant::Standard ? info.ecoKey() : Eco();

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

	EcoTable const& ecoTable = EcoTable::specimen(db.variant());

	if (info.idn() == variant::Standard && eco)
	{
		ecoTable.getOpening(eco, openingLong, openingShort, variation, subvariation);

		if (info.eco().basic() == info.ecoKey().basic())
		{
			mstl::string unused;
			ecoTable.getOpening(info.ecoKey(), unused, unused, variation, subvariation);
		}
		else
		{
			variation.clear();
			subvariation.clear();
		}
	}

	mstl::string flags;
	mstl::string overview;

	flagsToString(info.flags(), flags);

	if (db.format() == format::Scid4)
		::mapScid4Flags(flags);

	if (info.idn() == variant::Standard)
	{
		if (eop)
			ecoTable.getLine(eop).print(overview, variant::Normal, protocol::Scidb, encoding::Utf8);
	}
	else if (variant::isShuffleChess(info.idn()))
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

	uint16_t idn = variant::isShuffleChess(info.idn()) ? info.idn() : 0;

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
	SET(BlackSex,             Tcl_NewStringObj(sex::toString(info.findSex(color::Black)), -1));
	SET(Event,                Tcl_NewStringObj(info.event(), info.event().size()));
	SET(EventType,            Tcl_NewStringObj(event::toString(info.eventType()), -1));
	SET(EventDate,            Tcl_NewStringObj(info.eventDate().asShortString(), -1));
	SET(Result,               Tcl_NewStringObj(result::toString(info.result()), -1));
	SET(Site,                 Tcl_NewStringObj(info.site(), info.site().size()));
	SET(EventCountry,         Tcl_NewStringObj(country::toString(info.findEventCountry()), -1));
	SET(Date,                 Tcl_NewStringObj(info.date().asShortString(), -1));
	SET(Round,                Tcl_NewStringObj(round, round.size()));
	SET(Annotator,            Tcl_NewStringObj(info.annotator(), info.annotator().size()));
	SET(Idn,                  Tcl_NewIntObj(idn));
	SET(Position,             Tcl_NewStringObj(startPosition, -1));
	SET(Length,               Tcl_NewIntObj(mstl::div2(info.plyCount() + 1)));
	SET(Eco,                  Tcl_NewStringObj(eco.asShortString(), -1));
	SET(Flags,                Tcl_NewStringObj(flags, flags.size()));
	SET(Material,             Tcl_NewStringObj(material, material.size()));
	SET(Deleted,              Tcl_NewBooleanObj(info.isDeleted()));
	SET(Changed,              Tcl_NewIntObj(info.isChanged()));
	SET(Added,                Tcl_NewIntObj(db.isAdded(index)));
	SET(Acv,                  Tcl_NewStringObj(acv, acvSize));
	SET(CommentEngFlag,       Tcl_NewBooleanObj(info.containsEnglishLanguage()));
	SET(CommentOthFlag,       Tcl_NewBooleanObj(info.containsOtherLanguage()));
	SET(Promotion,            Tcl_NewBooleanObj(info.hasPromotion()));
	SET(UnderPromotion,       Tcl_NewBooleanObj(info.hasUnderPromotion()));
	SET(StandardPosition,     Tcl_NewBooleanObj(variant::isStandardChess(info.idn(), db.variant())));
	SET(Chess960Position,     Tcl_NewBooleanObj(variant::isChess960(info.idn())));
	SET(Termination,          Tcl_NewStringObj(termination::toString(info.terminationReason()), -1));
	SET(Mode,                 Tcl_NewStringObj(event::toString(info.eventMode()), -1));
	SET(TimeMode,             Tcl_NewStringObj(::db::time::toString(info.timeMode()), -1));
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
getGameInfo(int index, int view, char const* database, variant::Type variant)
{
	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Games, index, view);

	return getGameInfo(cursor.database(), index, Ratings(rating::Elo, rating::DWZ));
}


static int
getGameInfo(int index, int view, char const* database, variant::Type variant, Ratings const& ratings)
{
	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Games, index, view);

	return getGameInfo(cursor.database(), index, ratings);
}


static int
getPlayerInfo(int index, int view, char const* database, variant::Type variant, unsigned which)
{
	M_ASSERT(database);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Players, index, view);

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
getPlayerInfo(	int index,
					int view,
					char const* database,
					variant::Type variant,
					Ratings& ratings,
					federation::ID federation,
					bool info,
					bool idCard,
					bool usePlayerBase)
{
	M_ASSERT(database);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Players, index, view);

	NamebasePlayer const& player = cursor.database().player(index);
	return tcl::player::getInfo(player, ratings, federation, info, idCard, usePlayerBase);
}


static int
getEventInfo(int index, int view, char const* database, variant::Type variant, unsigned which)
{
	M_ASSERT(database);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Events, index, view);

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
			obj = Tcl_NewStringObj(::db::time::toString(event.timeMode()), -1);
			break;

		default:
			return error(::CmdGet, "eventInfo", nullptr, "cannot access number %u", which);
	}

	setResult(obj);
	return TCL_OK;
}


static int
getSiteInfo(int index, int view, char const* database, variant::Type variant, unsigned which)
{
	M_ASSERT(database);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Sites, index, view);

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
	objv[attribute::event::TimeMode ] = Tcl_NewStringObj(::db::time::toString(event.timeMode()), -1);
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
getEventInfo(int index, int view, char const* database, variant::Type variant, bool idCard)
{
	M_ASSERT(variant);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Events, index, view);

	return getEventInfo(cursor.database().event(index), idCard ? &cursor.database() : nullptr);
}


static int
getSiteInfo(int index, int view, char const* database, variant::Type variant)
{
	M_ASSERT(database);

	Cursor const& cursor = Scidb->cursor(database, variant);

	if (view >= 0)
		index = cursor.index(table::Sites, index, view);

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
		index = cursor.index(table::Annotators, index, view);

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
getDeleted(int index, int view, char const* database, variant::Type variant)
{
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();

	if (view >= 0)
		index = cursor.index(table::Games, index, view);

	setResult(cursor.database().gameInfo(index).isDeleted());
	return TCL_OK;
}


static int
getChanged(int index, int view, char const* database, variant::Type variant)
{
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();

	if (view >= 0)
		index = cursor.index(table::Games, index, view);

	setResult(cursor.database().gameInfo(index).isChanged());
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
getTags(int index, char const* database, variant::Type variant)
{
	TagSet tags;
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	cursor.database().getInfoTags(index, tags);
	return getTags(tags, false);
}


static int
getChecksum(int index, char const* database, variant::Type variant)
{
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	setResult(cursor.database().computeChecksum(index));
	return TCL_OK;
}


static int
getIdn(int index, char const* database, variant::Type variant)
{
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	setResult(cursor.database().gameInfo(index).idn());
	return TCL_OK;
}


static int
getEco(int index, char const* database)
{
	setResult(Scidb->cursor(database, variant::Normal).database().gameInfo(index).eco().asShortString());
	return TCL_OK;
}


static int
getRatingTypes(int index, char const* database, variant::Type variant)
{
	Cursor const& cursor = database ? Scidb->cursor(database, variant) : Scidb->cursor();
	GameInfo const& info = cursor.database().gameInfo(index);

	mstl::string const& wr = rating::toString(info.ratingType(color::White));
	mstl::string const& br = rating::toString(info.ratingType(color::Black));

	Tcl_Obj* objs[2] = { Tcl_NewStringObj(wr, wr.size()), Tcl_NewStringObj(br, br.size())};
	setResult(2, objs);

	return TCL_OK;
}


static int
cmdPlayerInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4 && objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <variant> (<player-index> | <game-index> <side>)");
		return TCL_ERROR;
	}

	char const*					database(stringFromObj(objc, objv, 1));
	variant::Type				variant(tcl::game::variantFromObj(objc, objv, 2));
	unsigned                index(unsignedFromObj(objc, objv, 3));
	Database const&         base(Scidb->cursor(database, variant).database());
	NamebasePlayer const*   player;

	if (objc == 4)
		player = &base.player(index);
	else
		player = &base.player(index, color::fromSide(stringFromObj(objc, objv, 4)));

	Ratings ratings(rating::Any, rating::Any);
	return tcl::player::getInfo(*player, ratings, federation::Fide, true, true, true);
}


static int
cmdPlayerCard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	struct Log : public TeXt::Controller::Log
	{
		void error(mstl::string const& msg) { str = msg; }
		mstl::string str;
	};

	if (objc != 7 && objc != 8)
	{
		Tcl_WrongNumArgs(
			ti,
			1,
			objv,
			"<search-dir> <script> <preamble> <database> <variant> (<player-index> | <game-index> <side>)");
		return TCL_ERROR;
	}

	mstl::string				searchDir(stringFromObj(objc, objv, 1));
	mstl::string				script(stringFromObj(objc, objv, 2));
	mstl::string				preamble(stringFromObj(objc, objv, 3));
	char const*					database(stringFromObj(objc, objv, 4));
	variant::Type				variant(tcl::game::variantFromObj(objc, objv, 5));
	unsigned						index(unsignedFromObj(objc, objv, 6));
	Database const&			base(Scidb->cursor(database, variant).database());
	TeXt::Controller::LogP	myLog(new Log);
	TeXt::Controller			controller(searchDir, TeXt::Controller::AbortMode, myLog);
	mstl::istringstream		src(preamble);
	mstl::ostringstream		dst;
	mstl::ostringstream		out;
	NamebasePlayer const*	player;

	if (objc == 7)
		player = &base.player(index);
	else
		player = &base.player(index, color::fromSide(stringFromObj(objc, objv, 7)));

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
		"<game-index> <database> ?<variant>?",
		"<game-index> <database> ?<variant>?",
		"<game-index> <database> ?<variant>?",
		"<game-index> <database> ?<variant>?",
		"<game-index> <database> ?<variant>?",
		0,
	};
	enum
	{
		Cmd_EventInfo,
		Cmd_WhitePlayerInfo, Cmd_BlackPlayerInfo,
		Cmd_WhitePlayerStats, Cmd_BlackPlayerStats
	};

	int index = intFromObj(objc, objv, 2);
	char const* database = stringFromObj(objc, objv, 3);
	variant::Type variant = tcl::game::variantFromObj(objc, objv, 4);
	Cursor const& cursor = Scidb->cursor(database, variant);
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
				federation::ID federation = federation::Fide;

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
						else if (::strcmp(lastArg, "-federation") == 0)
						{
							federation = federation::fromString(stringFromObj(objc, objv, objc - 1));
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
				NamebasePlayer const& player = *info.playerEntry(side);

				return tcl::player::getInfo(player, ratings, federation, infoWanted, idCard, true);
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
		"modified?", "gameInfo", "playerInfo", "eventInfo", "siteInfo", "annotator", "gameIndex",
		"playerIndex", "eventIndex", "siteIndex", "annotatorIndex", "description", "variant?",
		"stats", "readonly?", "encodingState", "deleted?", "open?", "lastChange", "customFlags",
		"gameFlags", "gameNumber", "minYear", "maxYear", "maxUsage", "tags", "checksum", "idn",
		"eco", "ratingTypes", "lookupPlayer", "lookupEvent", "lookupSite", "writable?",
		"upgrade?", "memoryOnly?", "compact?", "playerKey", "eventKey", "siteKey", "variants",
		"changed?", "unsaved?", "changes", "usedencoding", 0
	};
	static char const* args[] =
	{
		/* clipbase			*/ "<name>|<type>",
		/* scratchbase		*/ "<name>|<type>",
		/* types				*/ "sci|si3|si4",
		/* type				*/ "?<database>?",
		/* name				*/ "",
		/* codec				*/ "?<database>? ?<variant>?",
		/* encoding			*/ "?<database>?",
		/* created?			*/ "?<database>?",
		/* modified?		*/ "?<database>?",
		/* gameInfo			*/ "<index> <view> <database> ?<variant>?",
		/* playerInfo		*/ "<index> <view> <database> <variant> ?<which>?",
		/* eventInfo		*/ "<index> <view> <database> <variant> ?<which>?",
		/* siteInfo			*/ "<index> <view> <database> <variant> ?<which>?",
		/* annotator		*/ "<index> <view>?",
		/* gameIndex		*/ "<number> <view> ?<database>? ?<variant>?",
		/* playerIndex		*/ "<number> ?<view>? ?<database>? ?<variant>?",
		/* eventIndex		*/ "<number> <view> ?<database>? ?<variant>?",
		/* siteIndex		*/ "<number> ?<view>? ?<database>? ?<variant>?",
		/* annotatorIndex	*/ "<number> ?<view>? ?<database>? ?<variant>?",
		/* description		*/ "?<database>?",
		/* variant?			*/ "?<database> ?<number>??",
		/* stats				*/ "<database>",
		/* readonly?		*/ "?<database>?",
		/* encodingState	*/ "?<database>?",
		/* deleted?			*/ "<index> ?<view>? ?<database>? ?<variant>?",
		/* open?				*/ "<database> ?<variant>?",
		/* lastChange		*/ "?<database>? ?<variant>?",
		/* customFlags		*/ "?<database>? ?<variant>?",
		/* gameFlags		*/ "?<database>? ?<variant>?",
		/* gameNumber		*/ "<database> ?<variant>? <index> <view>",
		/* minYear			*/ "<database> ?<variant>?",
		/* maxYear			*/ "<database> ?<variant>?",
		/* maxUsage			*/ "<database> <variant> <namebase-type>",
		/* tags				*/ "<number> ?<database>? ?<variant>",
		/* checksum			*/ "<number> ?<database>? ?<variant>?",
		/* idn				*/ "<number> ?<database>? ?<variant>?",
		/* eco				*/ "<number> ?<database>?",
		/* ratingTypes		*/ "<number> ?<database>? ?<variant>?",
		/* lookupPlayer	*/ "<index> ?<view>? ?<database>? ?<variant>?",
		/* lookupEvent		*/ "<index> ?<view>? ?<database>? ?<variant>?",
		/* lookupSite		*/ "<index> ?<view>? ?<database>? ?<variant>?",
		/* writable?		*/ "?<database>?",
		/* upgrade?			*/ "<database>",
		/* memoryOnly?		*/ "?<database>?",
		/* compact?			*/ "<database>",
		/* playerKey		*/ "<database> <variant> (<player-index> | <game-index> <side>)",
		/* eventKey			*/ "<database> <variant> game|event <event>",
		/* siteKey			*/ "<database> <variant> game|site <site>",
		/* variants			*/ "<database>",
		/* changed?			*/ "<index> ?<view>? ?<database>? ?<variant>?",
		/* unsaved?			*/ "<database>",
		/* changes			*/ "<database>",
		/* usedencoding	*/ "?<database>?",
		0
	};
	enum
	{
		Cmd_Clipbase, Cmd_Scratchbase, Cmd_Types, Cmd_Type, Cmd_Name, Cmd_Codec, Cmd_Encoding,
		Cmd_Created, Cmd_Modified, Cmd_GameInfo, Cmd_PlayerInfo, Cmd_EventInfo, Cmd_SiteInfo,
		Cmd_Annotator, Cmd_GameIndex, Cmd_PlayerIndex, Cmd_EventIndex, Cmd_SiteIndex,
		Cmd_AnnotatorIndex, Cmd_Description, Cmd_Variant, Cmd_Stats, Cmd_ReadOnly, Cmd_EncodingState,
		Cmd_Deleted, Cmd_Open, Cmd_LastChange, Cmd_CustomFlags, Cmd_GameFlags, Cmd_GameNumber,
		Cmd_MinYear, Cmd_MaxYear, Cmd_MaxUsage, Cmd_Tags, Cmd_Checksum, Cmd_Idn, Cmd_Eco, Cmd_RatingTypes,
		Cmd_LookupPlayer, Cmd_LookupEvent, Cmd_LookupSite, Cmd_Writable, Cmd_Upgrade, Cmd_MemoryOnly,
		Cmd_Compact, Cmd_PlayerKey, Cmd_EventKey, Cmd_SiteKey, Cmd_Variants, Cmd_Changed, Cmd_Unsaved,
		Cmd_Changes, Cmd_UsedEncoding,
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
			return getCodec(Tcl_GetString(objv[2]), tcl::game::variantFromObj(objc, objv, 3));

		case Cmd_Encoding:
			return getEncoding(	objc > 2 ? stringFromObj(objc, objv, 2) : 0,
										tcl::game::variantFromObj(objc, objv, 3));

		case Cmd_UsedEncoding:
			return getUsedEncoding(	objc > 2 ? stringFromObj(objc, objv, 2) : 0,
											tcl::game::variantFromObj(objc, objv, 3));

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

			index = unsignedFromObj(objc, objv, 2);
			view = intFromObj(objc, objv, 3);
			char const* database = stringFromObj(objc, objv, 4);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 5);

			if (parseRatings)
				return getGameInfo(index, view, database, variant, ratings);

			if (objc <= 6)
				return getGameInfo(index, view, database, variant);

			return getGameInfo(index, view, database, variant, unsignedFromObj(objc, objv, 6));
		}

		case Cmd_PlayerInfo:
		{
			Ratings ratings(rating::Any, rating::Any);
			federation::ID federation = federation::Fide;

			bool parseOptions 	= true;
			bool idCard				= false;
			bool info				= false;
			bool usePlayerBase	= true;

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
					else if (::strcmp(lastArg, "-federation") == 0)
					{
						federation = federation::fromString(stringFromObj(objc, objv, objc - 1));
						--objc;
					}
					else if (::strcmp(lastArg, "-usebase") == 0)
					{
						usePlayerBase = boolFromObj(objc, objv, objc - 1);
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

			index = unsignedFromObj(objc, objv, 2);

			if (objc > 3)
				view = intFromObj(objc, objv, 3);

			char const*		database	= stringFromObj(objc, objv, 4);
			variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 5);

			if (objc < 7)
			{
				return getPlayerInfo(index,
											view,
											database,
											variant,
											ratings,
											federation,
											info,
											idCard,
											usePlayerBase);
			}

			unsigned which = unsignedFromObj(objc, objv, 6);

			return getPlayerInfo(index, view, database, variant, which);
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

			index = unsignedFromObj(objc, objv, 2);

			if (objc > 3)
				view = intFromObj(objc, objv, 3);

			char const*		database	= stringFromObj(objc, objv, 4);
			variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 5);

			if (objc < 7)
				return getEventInfo(index, view, database, variant, idCard);

			unsigned which = unsignedFromObj(objc, objv, 6);

			return getEventInfo(index, view, database, variant, which);
		}

		case Cmd_SiteInfo:
		{
			index = unsignedFromObj(objc, objv, 2);

			if (objc > 3)
				view = intFromObj(objc, objv, 3);

			char const*		database	= stringFromObj(objc, objv, 4);
			variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 5);

			if (objc < 7)
				return getSiteInfo(index, view, database, variant);

			unsigned which = unsignedFromObj(objc, objv, 6);

			return getSiteInfo(index, view, database, variant, which);
		}

		case Cmd_Annotator:
			return getAnnotator(unsignedFromObj(objc, objv, 2), objc > 3 ? intFromObj(objc, objv, 3) : -1);

		case Cmd_GameIndex:
			return getGameIndex(	unsignedFromObj(objc, objv, 2),
										objc > 3 ? intFromObj(objc, objv, 3) : -1,
										objc > 4 ? stringFromObj(objc, objv, 4) : 0,
										tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_PlayerIndex:
			return getIndex(	table::Players,
									unsignedFromObj(objc, objv, 2),
									objc > 3 ? intFromObj(objc, objv, 3) : -1,
									objc > 4 ? stringFromObj(objc, objv, 4) : 0,
									tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_LookupPlayer:
			return getLookupPlayer(	unsignedFromObj(objc, objv, 2),
											objc > 3 ? intFromObj(objc, objv, 3) : -1,
											objc > 4 ? stringFromObj(objc, objv, 4) : 0,
											tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_EventIndex:
			return getIndex(	table::Events,
									unsignedFromObj(objc, objv, 2),
									objc > 3 ? intFromObj(objc, objv, 3) : -1,
									objc > 4 ? stringFromObj(objc, objv, 4) : 0,
									tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_SiteIndex:
			return getIndex(	table::Sites,
									unsignedFromObj(objc, objv, 2),
									objc > 3 ? intFromObj(objc, objv, 3) : -1,
									objc > 4 ? stringFromObj(objc, objv, 4) : 0,
									tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_LookupEvent:
			return getLookupEvent(	unsignedFromObj(objc, objv, 2),
											objc > 3 ? intFromObj(objc, objv, 3) : -1,
											objc > 4 ? stringFromObj(objc, objv, 4) : 0,
											tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_LookupSite:
			return getLookupSite(unsignedFromObj(objc, objv, 2),
											objc > 3 ? intFromObj(objc, objv, 3) : -1,
											objc > 4 ? stringFromObj(objc, objv, 4) : 0,
											tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_AnnotatorIndex:
			return getAnnotatorIndex(	stringFromObj(objc, objv, 2),
												objc > 3 ? intFromObj(objc, objv, 3) : -1,
												objc == 5 ? stringFromObj(objc, objv, 4) : 0,
												tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_Description:
			if (objc < 3)
				return getDescription();
			return getDescription(Tcl_GetString(objv[2]));

		case Cmd_Variant:
			if (objc < 3)
				return getVariant();
			if (objc < 4)
				return getVariant(Tcl_GetString(objv[2]));
			return getVariant(Tcl_GetString(objv[2]), unsignedFromObj(objc, objv, 3));

		case Cmd_Stats:
			return getStats(stringFromObj(objc, objv, 2));

		case Cmd_ReadOnly:
			return getReadonly(	objc > 2 ? stringFromObj(objc, objv, 2) : 0,
										tcl::game::variantFromObj(objc, objv, 3));

		case Cmd_Writable:
			if (objc < 3)
				return getWritable();
			return getWritable(stringFromObj(objc, objv, 2));

		case Cmd_Upgrade:
			::tcl::setResult(Scidb->cursor(stringFromObj(objc, objv, 2)).database().shouldUpgrade());
			return TCL_OK;

		case Cmd_Open:
			if (objc > 3)
			{
				setResult(	Scidb->contains(stringFromObj(objc, objv, 2),
								tcl::game::variantFromObj(objc, objv, 3)));
			}
			else
			{
				setResult(Scidb->contains(stringFromObj(objc, objv, 2)));
			}
			return TCL_OK;

		case Cmd_EncodingState:
			if (objc < 3)
				return getEncodingState(0);
			return getEncodingState(Tcl_GetString(objv[2]));

		case Cmd_Deleted:
			return getDeleted(intFromObj(objc, objv, 2),
									objc < 4 ? -1 : intFromObj(objc, objv, 3),
									objc < 5 ? 0 : stringFromObj(objc, objv, 4),
									tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_Changed:
			return getChanged(intFromObj(objc, objv, 2),
									objc < 4 ? -1 : intFromObj(objc, objv, 3),
									objc < 5 ? 0 : stringFromObj(objc, objv, 4),
									tcl::game::variantFromObj(objc, objv, 5));

		case Cmd_LastChange:
		{
			char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			Cursor const& cursor = objc < 3 ? Scidb->cursor() : Scidb->cursor(base, variant);
			setResult(Tcl_NewWideIntObj(cursor.database().lastChange()));
			return TCL_OK;
		}

		case Cmd_CustomFlags:
		{
			char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			Cursor const& cursor = objc < 3 ? Scidb->cursor() : Scidb->cursor(base, variant);
			Database const& database = cursor.database();

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

			return TCL_OK;
		}

		case Cmd_GameFlags:
		{
			char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			Cursor const& cursor = objc < 3 ? Scidb->cursor() : Scidb->cursor(base, variant);
			Database const& database = cursor.database();
			mstl::string flags;

			flagsToString(database.codec().gameFlags(), flags);

			if (database.format() == format::Scid4)
				::mapScid4Flags(flags);

			setResult(flags);
			return TCL_OK;
		}

		case Cmd_GameNumber:
			if ((view = intFromObj(objc, objv, objc > 5 ? 5 : 4)) >= 0)
			{
				char const*		base		= stringFromObj(objc, objv, 2);
				unsigned			idx		= unsignedFromObj(objc, objv, objc > 5 ? 4 : 3);
				variant::Type	variant	= variant::Undetermined;

				if (objc > 5)
					variant = tcl::game::variantFromObj(objv[3]);

				index = Scidb->cursor(base, variant).index(table::Games, idx, view);
			}
			else
			{
				index = unsignedFromObj(objc, objv, objc > 5 ? 4 : 3);
			}
			setResult(index);
			return TCL_OK;

		case Cmd_MinYear:
		{
			char const* base = stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			setResult(Scidb->cursor(base, variant).database().codec().minYear());
			return TCL_OK;
		}

		case Cmd_MaxYear:
		{
			char const* base = stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			setResult(Scidb->cursor(base, variant).database().codec().maxYear());
			return TCL_OK;
		}

		case Cmd_MaxUsage:
		{
			char const* base = stringFromObj(objc, objv, 2);
			variant::Type variant = tcl::game::variantFromObj(objc, objv, 3);
			Tcl_Obj* namebase = objectFromObj(objc, objv, 4);

			Namebase::Type	type = getNamebaseType(namebase, ::CmdGet);
			setResult(Scidb->cursor(base, variant).database().namebase(type).maxUsage());
			return TCL_OK;
		}

		case Cmd_Tags:
			return getTags(unsignedFromObj(objc, objv, 2),
								objc > 3 ? stringFromObj(objc, objv, 3) : 0,
								tcl::game::variantFromObj(objc, objv, 4));

		case Cmd_Checksum:
			return getChecksum(unsignedFromObj(objc, objv, 2),
									objc > 3 ? stringFromObj(objc, objv, 3) : 0,
									tcl::game::variantFromObj(objc, objv, 4));

		case Cmd_Idn:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getIdn(	unsignedFromObj(objc, objv, 2),
								objc > 3 ? stringFromObj(objc, objv, 3) : 0,
								tcl::game::variantFromObj(objc, objv, 4));

		case Cmd_Eco:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getEco(index, objc == 4 ? stringFromObj(objc, objv, 3) : 0);

		case Cmd_RatingTypes:
			if (objc < 3 || Tcl_GetIntFromObj(ti, objv[2], &index) != TCL_OK)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);
			return getRatingTypes(	unsignedFromObj(objc, objv, 2),
											objc > 3 ? stringFromObj(objc, objv, 3) : 0,
											tcl::game::variantFromObj(objc, objv, 4));

		case Cmd_MemoryOnly:
		{
			char const* base = objc < 3 ? "" : stringFromObj(objc, objv, 2);
			setResult(Scidb->cursor(base).database().isMemoryOnly());
			return TCL_OK;
		}

		case Cmd_Compact:
		{
			char const*		database(stringFromObj(objc, objv, 2));
			variant::Type	variant(tcl::game::variantFromObj(objc, objv, 3));

			setResult(Scidb->cursor(database, variant).database().shouldCompact());
			return TCL_OK;
		}

		case Cmd_PlayerKey:
		{
			if (objc != 5 && objc != 6)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);

			char const*			database(stringFromObj(objc, objv, 2));
			variant::Type		variant(tcl::game::variantFromObj(objc, objv, 3));
			unsigned				index(unsignedFromObj(objc, objv, 4));
			Database const&	base(Scidb->cursor(database, variant).database());

			if (objc == 5)
				getPlayerKey(base.player(index));
			else
				getPlayerKey(base.player(index, color::fromSide(stringFromObj(objc, objv, 5))));

			return TCL_OK;
		}

		case Cmd_EventKey:
		{
			if (objc != 6)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);

			char const*			database(stringFromObj(objc, objv, 2));
			variant::Type		variant(tcl::game::variantFromObj(objc, objv, 3));
			char const*			what(stringFromObj(objc, objv, 4));
			unsigned				index(unsignedFromObj(objc, objv, 5));
			Database const&	base(Scidb->cursor(database, variant).database());

			getEventKey(base.event(index, *what == 'e' ? Database::MyIndex : Database::GameIndex));
			return TCL_OK;
		}

		case Cmd_SiteKey:
		{
			if (objc != 6)
				return usage(::CmdGet, nullptr, nullptr, subcommands, args);

			char const*			database(stringFromObj(objc, objv, 2));
			variant::Type		variant(tcl::game::variantFromObj(objc, objv, 3));
			char const*			what(stringFromObj(objc, objv, 4));
			unsigned				index(unsignedFromObj(objc, objv, 5));
			Database const&	base(Scidb->cursor(database, variant).database());

			getSiteKey(base.site(index, *what == 'e' ? Database::MyIndex : Database::GameIndex));
			return TCL_OK;
		}

		case Cmd_Variants:
			return getVariants(stringFromObj(objc, objv, 2));

		case Cmd_Unsaved:
			return isUnsaved(stringFromObj(objc, objv, 2));

		case Cmd_Changes:
			return getChanges(stringFromObj(objc, objv, 2));
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
			"gameData|gameHistory|gameSwitch|gameClose|databaseSwitch|tree <update-cmd> ??"
			"<close-cmd> ?<arg>?");
		return TCL_ERROR;
	}

	static char const* subcommands[] =
	{
		"dbInfo", "gameList", "playerList", "annotatorList", "eventList", "siteList",
		"gameInfo", "gameData", "gameHistory", "gameSwitch", "gameClose", "databaseSwitch",
		"tree", 0
	};
	enum
	{
		Cmd_DbInfo, Cmd_GameList, Cmd_PlayerList, Cmd_AnnotatorList, Cmd_EventList,
		Cmd_SiteList, Cmd_GameInfo, Cmd_GameData, Cmd_GameHistory, Cmd_GameSwitch,
		Cmd_GameClose, Cmd_DatabaseSwitched, Cmd_Tree,
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
			subscriber->setCmd(Subscriber::DatabaseInfo, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameList:
			subscriber->setListCmd(table::Games, updateCmd, closeCmd, arg);
			break;

		case Cmd_PlayerList:
			subscriber->setListCmd(table::Players, updateCmd, closeCmd, arg);
			break;

		case Cmd_AnnotatorList:
			subscriber->setListCmd(table::Annotators, updateCmd, closeCmd, arg);
			break;

		case Cmd_EventList:
			subscriber->setListCmd(table::Events, updateCmd, closeCmd, arg);
			break;

		case Cmd_SiteList:
			subscriber->setListCmd(table::Sites, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameInfo:
			subscriber->setCmd(Subscriber::GameInfo, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameData:
			subscriber->setCmd(Subscriber::GameData, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameHistory:
			subscriber->setCmd(Subscriber::GameHistory, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameSwitch:
			subscriber->setGameSwitchedCmd(updateCmd);
			break;

		case Cmd_GameClose:
			subscriber->setGameClosedCmd(updateCmd);
			break;

		case Cmd_DatabaseSwitched:
			subscriber->setDatabaseSwitchedCmd(updateCmd);
			break;

		case Cmd_Tree:
			subscriber->setCmd(Subscriber::Tree, updateCmd, closeCmd, arg);
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
			"dbInfo|gameList|playerList|annotatorList|eventList|"
			"siteList|gameInfo|gameData|gameHistory|tree "
			"<update-cmd> ??" "<close-cmd>? <arg>?");
		return TCL_ERROR;
	}

	static char const* subcommands[] =
	{
		"dbInfo", "gameList", "playerList", "eventList", "siteList",
		"annotatorList", "gameInfo", "gameData", "gameHistory", "tree", 0
	};
	enum
	{
		Cmd_DbInfo, Cmd_GameList, Cmd_PlayerList, Cmd_EventList, Cmd_SiteList,
		Cmd_AnnotatorList, Cmd_GameInfo, Cmd_GameData, Cmd_GameHistory, Cmd_Tree
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
			subscriber->unsetCmd(Subscriber::DatabaseInfo, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameList:
			subscriber->unsetListCmd(table::Games, updateCmd, closeCmd, arg);
			break;

		case Cmd_PlayerList:
			subscriber->unsetListCmd(table::Players, updateCmd, closeCmd, arg);
			break;

		case Cmd_EventList:
			subscriber->unsetListCmd(table::Events, updateCmd, closeCmd, arg);
			break;

		case Cmd_SiteList:
			subscriber->unsetListCmd(table::Sites, updateCmd, closeCmd, arg);
			break;

		case Cmd_AnnotatorList:
			subscriber->unsetListCmd(table::Annotators, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameInfo:
			subscriber->unsetCmd(Subscriber::GameInfo, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameData:
			subscriber->unsetCmd(Subscriber::GameData, updateCmd, closeCmd, arg);
			break;

		case Cmd_GameHistory:
			subscriber->unsetCmd(Subscriber::GameHistory, updateCmd, closeCmd, arg);
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
	if (objc != 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <variant>");
		return TCL_ERROR;
	}

	char const*		database	= Tcl_GetString(objv[1]);
	variant::Type	variant	= tcl::game::variantFromObj(objv[2]);

	scidb->switchBase(scidb->cursor(database, variant));

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
	char const*		database	= stringFromObj(objc, objv, 1);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 2);

	if (variant == variant::Undetermined)
		scidb->clearBase(scidb->multiCursor(database));
	else
		scidb->clearBase(scidb->cursor(database, variant));

	return TCL_OK;
}


static int
cmdSort(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "gameInfo", "player", "event", "site", "annotator", 0 };
	static char const* args[] =
	{
		"<database> <variant> <column> ?<view>? ?-reset? ?-descending? ?-ascending? ?-average?"
			" -ratings {<rating type> <rating type>}",
		"<database> <variant> <column> ?<view>? ?-reset? ?-descending? ?-ascending? ?-latest?",
		"<database> <variant> <column> ?<view>? ?-reset? ?-descending? ?-ascending?",
		"<database> <variant> <column> ?<view>? ?-reset? ?-descending? ?-ascending?",
		"<database> <variant> <column> ?<view>? ?-reset? ?-descending? ?-ascending?",
	};
	enum { Cmd_GameInfo, Cmd_Player, Cmd_Event, Cmd_Site, Cmd_Annotator };

	if (objc < 5)
		return usage(::CmdSort, nullptr, nullptr, subcommands, args);

	int				view		= View::DefaultView;
	int				index		= tcl::uniqueMatchObj(objv[1], subcommands);
	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= tcl::game::variantFromObj(objv[3]);
	bool				average	= false;
	bool				latest	= false;
	bool				reset		= false;
	order::ID		order		= order::Ascending;
	int				optCount	= 0;

	Ratings ratings(rating::Elo, rating::Elo);

	while (	objc > 5
			&& (	::isOption(stringFromObj(objc, objv, objc - 1))
				|| ::isOption(stringFromObj(objc, objv, objc - 2))))
	{
		++optCount;
		--objc;
	}

	if (objc < 4 || 6 < objc)
		return usage(::CmdSort, nullptr, nullptr, subcommands, args);

	if (objc == 6)
		view = intFromObj(objc, objv, 5);

	for (int i = 0; i < optCount; ++i)
	{
		char const* opt = stringFromObj(optCount, objv + objc, i);

		if (*opt == '-')
		{
			if (::strcmp(opt, "-average") == 0)
				average = true;
			else if (::strcmp(opt, "-latest") == 0)
				latest = true;
			else if (::strcmp(opt, "-ascending") == 0)
				order = order::Ascending;
			else if (::strcmp(opt, "-descending") == 0)
				order = order::Descending;
			else if (::strcmp(opt, "-reset") == 0)
				reset = true;
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
				attribute::game::ID column = lookupGameInfo(objv[4], ratings, average);
				if (column < 0)
					return TCL_ERROR;
				if (reset)
					scidb->resetOrder(scidb->cursor(database, variant), view, table::Games);
				scidb->sort(scidb->cursor(database, variant), view, column, order, ratings.first);
			}
			break;

		case Cmd_Player:
			{
				attribute::player::ID column = lookupPlayerBase(objv[4], ratings, latest);
				if (column < 0)
					return TCL_ERROR;
				if (reset)
					scidb->resetOrder(scidb->cursor(database, variant), view, table::Players);
				scidb->sort(scidb->cursor(database, variant), view, column, order, ratings.first);
			}
			break;

		case Cmd_Event:
			{
				attribute::event::ID column = lookupEventBase(objv[4]);
				if (column < 0)
					return TCL_ERROR;
				if (reset)
					scidb->resetOrder(scidb->cursor(database, variant), view, table::Events);
				scidb->sort(scidb->cursor(database, variant), view, column, order);
			}
			break;

		case Cmd_Site:
			{
				attribute::site::ID column = lookupSiteBase(objv[4]);
				if (column < 0)
					return TCL_ERROR;
				if (reset)
					scidb->resetOrder(scidb->cursor(database, variant), view, table::Sites);
				scidb->sort(scidb->cursor(database, variant), view, column, order);
			}
			break;

		case Cmd_Annotator:
			{
				attribute::annotator::ID column = lookupAnnotatorBase(objv[4]);
				if (column < 0)
					return TCL_ERROR;
				if (reset)
					scidb->resetOrder(scidb->cursor(database, variant), view, table::Annotators);
				scidb->sort(scidb->cursor(database, variant), view, column, order);
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
		"<database> <variant> ?<view>?",
		"<database> <variant> ?<view>?",
		"<database> <variant> ?<view>?",
		"<database> <variant> ?<view>?",
		"<database> <variant> ?<view>?",
	};
	enum { Cmd_GameInfo, Cmd_Player, Cmd_Event, Cmd_Site, Cmd_Annotator };

	if (objc < 4 || 5 < objc)
		return usage(::CmdReverse, nullptr, nullptr, subcommands, args);

	int				view		= View::DefaultView;
	int				index		= tcl::uniqueMatchObj(objv[1], subcommands);
	char const*		database	= Tcl_GetString(objv[2]);
	variant::Type	variant	= tcl::game::variantFromObj(objv[3]);

	if (objc >= 5 && Tcl_GetIntFromObj(ti, objv[4], &view) != TCL_OK)
		return error(CmdReverse, nullptr, nullptr, "integer expected for view argument");

	table::Type type;

	switch (index)
	{
		case Cmd_GameInfo:	type = table::Games; break;
		case Cmd_Player:		type = table::Players; break;
		case Cmd_Event:		type = table::Events; break;
		case Cmd_Site:			type = table::Sites; break;
		case Cmd_Annotator:	type = table::Annotators; break;
		default:					return usage(::CmdReverse, nullptr, nullptr, subcommands, args);
	}

	scidb->reverseOrder(scidb->cursor(database, variant), view, type);
	return TCL_OK;
}


static int
cmdMatch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 6 && objc != 8)
	{
		Tcl_WrongNumArgs(
			ti,
			1,
			objv,
			"player|event|site|annotator <database> <variant> <maximal> <string> "
			"?<rating-type> <two-ratings-flag>?");
		return TCL_ERROR;
	}

	Namebase::Type		type			= getNamebaseType(objv[1], ::CmdMatch);
	char const*			database		= stringFromObj(objc, objv, 2);
	variant::Type		variant		= tcl::game::variantFromObj(objc, objv, 4);
	unsigned				maximal		= unsignedFromObj(objc, objv, 4);
	mstl::string		suffix		= stringFromObj(objc, objv, 5);
	rating::Type		ratingType	= rating::Any;
	bool					twoRatings	= true;
	Player::Matches	playerMatches;
	Site::Matches		siteMatches;

	if (objc > 6)
		ratingType = rating::fromString(stringFromObj(objc, objv, 6));
	if (objc > 7)
		twoRatings	= boolFromObj(objc, objv, 7);

	if (twoRatings && ratingType == rating::Elo)
		ratingType = rating::Any;

	Namebase::Matches matches;
	Scidb->cursor(database, variant).database().namebase(type).findMatches(suffix, matches, maximal);
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
					objs[n++] = Tcl_NewStringObj(::db::time::toString(event->timeMode()), -1);
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
	if (objc != 4 && objc != 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "player|event|site|annotator <database> ?<variant>? <key>");
		return TCL_ERROR;
	}

	char const*		what		= stringFromObj(objc, objv, 1);
	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= objc == 4 ? variant::Undetermined : tcl::game::variantFromObj(objv[3]);
	Tcl_Obj*			keyObj	= objv[objc == 4 ? 3 : 4];
	unsigned			numObjs	= 0;

	if (strcmp(what, "player") == 0)
	{
		numObjs = PlayerKey_LAST;
	}
	else if (strcmp(what, "event") == 0)
	{
		numObjs = EventKey_LAST;
	}
	else if (strcmp(what, "site") == 0)
	{
		numObjs = SiteKey_LAST;
	}
	else if (strcmp(what, "annotator") == 0)
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

	Database const& db = Scidb->cursor(database, variant).database();
	int index = -1;

	if (strcmp(what, "player") == 0)
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
	else if (strcmp(what, "event") == 0)
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
				::db::time::fromString(Tcl_GetString(objs[EventKey_TimeMode])),
				event::modeFromString(Tcl_GetString(objs[EventKey_EventMode])),
				site
			);
		}
	}
	else if (strcmp(what, "site") == 0)
	{
		index = db.namebase(Namebase::Site).findSiteIndex(
			Tcl_GetString(objs[SiteKey_Site]),
			country::fromString(Tcl_GetString(objs[SiteKey_Country]))
		);
	}
	else if (strcmp(what, "annotator") == 0)
	{
		index = db.namebase(Namebase::Annotator).findAnnotatorIndex(Tcl_GetString(objs[0]));
	}

	setResult(index);
	return TCL_OK;
}


static int
cmdSave(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 4)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	char const*	db(stringFromObj(objc, objv, 1));
	Progress		progress(objv[2], objv[3]);

	scidb->save(db, progress);
	return TCL_OK;
}


static int
cmdSavePGN(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 6)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<database> <encoding> <flags> <progress-cmd> <progress-arg>");
		return TCL_ERROR;
	}

	char const*	db(stringFromObj(objc, objv, 1));
	char const*	encoding(stringFromObj(objc, objv, 2));
	unsigned		flags(unsignedFromObj(objc, objv, 3));
	Progress		progress(objv[4], objv[5]);

	switch (scidb->save(db, encoding, flags, progress))
	{
		case file::IsUpTodate:	setResult("IsUpTodate"); break;
		case file::Updated:		setResult("Updated"); break;
		case file::IsRemoved:	setResult("IsRemoved"); break;
		case file::IsReadonly:	setResult("IsReadonly"); break;
		case file::HasChanged:	setResult("HasChanged"); break;
	}

	return TCL_OK;
}


static int
cmdUpdate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*		database	= stringFromObj(objc, objv, 1);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 2);
	unsigned			index		= unsignedFromObj(objc, objv, 3);

	int rc = TCL_OK;
	TagSet tags;

	if ((rc = game::convertTags(tags, objectFromObj(objc, objv, 4))) == TCL_OK)
		scidb->cursor(database, variant).updateCharacteristics(index, tags);

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

	Progress				progress(objv[2], objv[3]);
	Cursor&				cursor(scidb->cursor(database));
	Database const&	db(cursor.database());
	View&					v(cursor.view());
	Log					log;
	type::ID				type(db.type());
	View::FileMode		fmode(DatabaseCodec::upgradeIndexOnly() ? View::Create : View::Upgrade);

	try
	{
		::db::sci::Codec::remove(filename); // to be sure
		unsigned illegalRejected = 0;

		setResult(v.exportGames(filename,
										sys::utf8::Codec::utf8(),
										db.description(),
										db.creationTime(),
										type,
										0,
										::db::copy::AllGames,
										View::TagBits(true),
										true,
										illegalRejected,
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
cmdCopy(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 8)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<source> <destination> <tag-set> "
			"<progress-cmd> <progress-arg> <log-cmd> <log-arg>");
		return TCL_ERROR;
	}

	::db::tag::TagSet	tagBits;
	mstl::string		source(stringFromObj(objc, objv, 1));
	mstl::string		destination(stringFromObj(objc, objv, 2));
	bool					extraTags(tcl::view::buildTagSet(ti, CmdCopy, objv[3], tagBits));
	Tcl_Obj*				progressCmd(objectFromObj(objc, objv, 4));
	Tcl_Obj*				progressArg(objectFromObj(objc, objv, 5));
	Tcl_Obj*				logCmd(objectFromObj(objc, objv, 6));
	Tcl_Obj*				logArg(objectFromObj(objc, objv, 7));
	Progress				progress(progressCmd, progressArg);
	tcl::Log				log(logCmd, logArg);
	unsigned				accepted[variant::NumberOfVariants];
	unsigned				rejected[variant::NumberOfVariants];
	unsigned				illegalRejected(0);
	int					n;

	::memset(accepted, 0, sizeof(accepted));
	::memset(rejected, 0, sizeof(rejected));

	n = scidb->multiCursor(source).copyGames(
			scidb->multiCursor(destination),
			accepted,
			rejected,
			tagBits,
			extraTags,
			illegalRejected,
			log,
			progress);

	if (progress.interrupted())
		n = -n - 1;

	tcl::PgnReader::setResult(n, illegalRejected, accepted, rejected);
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
		scidb->cursor(baseName).databaseObject().writeIndex(os, progress);
	else if (strcmp(extension, "scn") == 0)
		scidb->cursor(baseName).databaseObject().writeNamebases(os, progress);
	else if (strcmp(extension, "scg") == 0)
		scidb->cursor(baseName).databaseObject().writeGames(os, progress);
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

	EcoTable const& ecoTable = EcoTable::specimen(database.variant());

	objs[0] = Tcl_NewListObj(0, 0);
	for (unsigned i = 0, n = mstl::min(5u, stats.countEcoLines(color::White)); i < n; ++i)
	{
		Tcl_Obj* argv[2];
		mstl::string line;

		ecoTable.getLine(stats.ecoLine(color::White, i)).
			print(line, variant::Normal, protocol::Scidb, encoding::Utf8);
		argv[0] = Tcl_NewIntObj(stats.ecoCount(color::White, i));
		argv[1] = Tcl_NewStringObj(line, line.size());
		Tcl_ListObjAppendElement(0, objs[0], Tcl_NewListObj(2, argv));
	}
	objs[1] = Tcl_NewListObj(0, 0);
	for (unsigned i = 0, n = mstl::min(5u, stats.countEcoLines(color::Black)); i < n; ++i)
	{
		Tcl_Obj* argv[2];
		mstl::string line;

		ecoTable.getLine(stats.ecoLine(color::Black, i)).
			print(line, variant::Normal, protocol::Scidb, encoding::Utf8);
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
	createCommand(ti, CmdCopy,			cmdCopy);
	createCommand(ti, CmdCount,			cmdCount);
	createCommand(ti, CmdFetch,			cmdFetch);
	createCommand(ti, CmdFind,				cmdFind);
	createCommand(ti, CmdImport,			cmdImport);
	createCommand(ti, CmdLoad,				cmdLoad);
	createCommand(ti, CmdNew,				cmdNew);
	createCommand(ti, CmdSet,				cmdSet);
	createCommand(ti, CmdGet,				cmdGet);
	createCommand(ti, CmdMatch,			cmdMatch);
	createCommand(ti, CmdOpen,			cmdOpen);
	createCommand(ti, CmdPlayerCard,		cmdPlayerCard);
	createCommand(ti, CmdPlayerInfo,		cmdPlayerInfo);
	createCommand(ti, CmdRecode,			cmdRecode);
	createCommand(ti, CmdReverse,			cmdReverse);
	createCommand(ti, CmdSave,				cmdSave);
	createCommand(ti, CmdSavePGN,			cmdSavePGN);
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
