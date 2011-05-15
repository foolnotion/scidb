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
// Copyright: (C) 2010-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_tree.h"
#include "tcl_base.h"
#include "tcl_application.h"
#include "tcl_database.h"

#include "app_cursor.h"

#include "db_tree.h"
#include "db_game.h"
#include "db_database.h"
#include "db_namebase_entry.h"

#include "u_piped_progress.h"

#include "m_assert.h"

#include <tcl.h>
#include <string.h>

using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::app;

static char const* CmdFetch		= "::scidb::tree::fetch";
static char const* CmdFinish		= "::scidb::tree::finish";
static char const* CmdGet			= "::scidb::tree::get";
static char const* CmdInit			= "::scidb::tree::init";
static char const* CmdIsRefBase	= "::scidb::tree::isRefBase?";
static char const* CmdList			= "::scidb::tree::list";
static char const* CmdMove			= "::scidb::tree::move";
static char const* CmdPlayer		= "::scidb::tree::player";
static char const* CmdPosition	= "::scidb::tree::position";
static char const* CmdSet			= "::scidb::tree::set";
static char const* CmdStop			= "::scidb::tree::stop";
static char const* CmdSwitch		= "::scidb::tree::switch";
static char const* CmdUpdate		= "::scidb::tree::update";
static char const* CmdView			= "::scidb::tree::view";


namespace {

struct MyPipedProgress : public util::PipedProgress
{
	MyPipedProgress(Tcl_Obj* cmd, Tcl_Obj* arg)
		:m_cmd(cmd)
		,m_arg(arg)
	{
		M_ASSERT(cmd);
		M_ASSERT(arg);

		Tcl_IncrRefCount(m_cmd);
		Tcl_IncrRefCount(m_arg);
	}

	void available(unsigned char c)
	{
		Tcl_Obj* n = Tcl_NewIntObj(c);

		Tcl_IncrRefCount(n);
		invoke(__func__, m_cmd, m_arg, n, 0);
		Tcl_DecrRefCount(n);
	}

	Tcl_Obj* m_cmd;
	Tcl_Obj* m_arg;
};

} // namespace

static MyPipedProgress* m_progress = 0;
static Tree::Key m_key;


void
tcl::tree::referenceBaseChanged()
{
	m_key.clear();
}


static int
cmdInit(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (m_progress == 0)
		m_progress = new MyPipedProgress(objectFromObj(objc, objv, 1), objectFromObj(objc, objv, 2));

	return TCL_OK;
}


static int
cmdList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* list = Tcl_NewListObj(0, 0);
	setResult(list);

	Application::CursorList cursors;
	Scidb.enumCursors(cursors);

	for (unsigned i = 0; i < cursors.size(); ++i)
	{
		switch (cursors[i]->database().format())
		{
			case format::Scidb:
			case format::Scid3:
			case format::Scid4:
			case format::Pgn:
				Tcl_ListObjAppendElement(0, list, Tcl_NewStringObj(cursors[i]->database().name(), -1));
				break;

			case format::ChessBase:	break;
		}
	}

	return TCL_OK;
}


static int
cmdGet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (Scidb.haveReferenceBase())
		setResult(Scidb.referenceBase().database().name());
	else
		setResult("");

	return TCL_OK;
}


static int
cmdSet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* base = stringFromObj(objc, objv, 1);

	if (*base)
		scidb.setReferenceBase(&scidb.cursor(base));

	return TCL_OK;
}


static int
cmdSwitch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.setSwitchReferenceBase(boolFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdUpdate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	M_ASSERT(m_progress);

	rating::Type ratingType = rating::fromString(stringFromObj(objc, objv, 1));

	if (ratingType == rating::Last)
		return error(CmdUpdate, 0, 0, "unknown rating type %s", stringFromObj(objc, objv, 1));

	::db::tree::Mode mode;
	char const* which = stringFromObj(objc, objv, 2);

	if (::strcmp(which, "exact") == 0)
		mode = ::db::tree::Exact;
	else if (::strcmp(which, "fast") == 0)
		mode = ::db::tree::Fast;
	else if (::strcmp(which, "quick") == 0)
		mode = ::db::tree::Rapid;
	else
		return error(CmdUpdate, 0, 0, "unknown mode '%s'", which);

	setResult(scidb.updateTree(mode, ratingType, *m_progress));
	return TCL_OK;
}


static int
cmdStop(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.stopUpdateTree();
	return TCL_OK;
}


static int
cmdFinish(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	attribute::tree::ID sortColumn = attribute::tree::LastColumn;

	while (objc > 3)
	{
		char const* option = stringFromObj(objc, objv, objc - 2);

		if (*option != '-')
			option = stringFromObj(objc, objv, objc - 1);

		if (::strcmp(option, "-sort") == 0)
		{
			int column;

			if (	Tcl_GetIntFromObj(interp(), objv[objc - 1], &column) != TCL_OK
				|| column < 0
				|| column >= attribute::tree::LastColumn)
			{
				return error(	CmdFetch, 0, 0,
									"integer in range 0-%d expected",
									attribute::tree::LastColumn - 1);
			}

			sortColumn = attribute::tree::ID(column);
			objc -= 2;
		}
		else
		{
			return error(CmdFetch, 0, 0, "unknown option '%s'", option);
		}
	}

	rating::Type ratingType = rating::fromString(stringFromObj(objc, objv, 1));

	if (ratingType == rating::Last)
		return error(CmdFetch, 0, 0, "unknown rating type %s", stringFromObj(objc, objv, 1));

	::db::tree::Mode mode;
	char const* which = stringFromObj(objc, objv, 2);

	if (::strcmp(which, "exact") == 0)
		mode = ::db::tree::Exact;
	else if (::strcmp(which, "fast") == 0)
		mode = ::db::tree::Fast;
	else if (::strcmp(which, "quick") == 0)
		mode = ::db::tree::Rapid;
	else
		return error(CmdUpdate, 0, 0, "unknown mode '%s'", which);

	if (sortColumn == attribute::tree::LastColumn)
		return error(CmdFetch, 0, 0, "no sort column given");

	Tree const* tree = scidb.finishUpdateTree(mode, ratingType, sortColumn);

	char const* result = "";

	if (tree)
	{
		if (tree->isEmpty())
		{
			result = "empty";
			m_key.clear();
		}
		else if (tree->isTreeFor(Scidb.referenceBase().database(), m_key))
		{
			result = "unchanged";
		}
		else
		{
			result = "changed";
			m_key = tree->key();
		}
	}
	else
	{
		result = "null";
	}

	setResult(result);
	return TCL_OK;
}


static int
cmdFetch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tree const* tree = Scidb.currentTree();

	if (tree && !tree->isEmpty())
	{
		unsigned objc = tree->size();
		Tcl_Obj* objs[objc + 1];

		for (unsigned i = 0; i <= objc; ++i)
		{
			TreeInfo const&	info = i == objc ? tree->total() : tree->info(i);
			Tcl_Obj*				v[attribute::tree::LastColumn];
			mstl::string		move;

			mstl::string const& best = info.bestPlayer().name();
			mstl::string const& most = info.mostFrequentPlayer().name();

			if (info.move())
				info.move().printSan(move, Move::Unicode);
			else if (i < objc)
				move = "end";

			Tcl_Obj* objvBestPlayer[2] =
			{
				Tcl_NewStringObj(best, best.size()),
				Tcl_NewIntObj(info.bestPlayer().playerHighestRating(tree->ratingType())),
			};

			Tcl_Obj* objvMostFrequentPlayer[2] =
			{
				Tcl_NewStringObj(most, most.size()),
				Tcl_NewIntObj(info.mostFrequentPlayer().frequency()),
			};

			v[attribute::tree::Move              ] = Tcl_NewStringObj(move, move.size());
			v[attribute::tree::Eco               ] = Tcl_NewStringObj(info.eco().asString(), -1);
			v[attribute::tree::Frequency         ] = Tcl_NewIntObj(info.frequency());
			v[attribute::tree::Score             ] = Tcl_NewIntObj(info.score());
			v[attribute::tree::Draws             ] = Tcl_NewIntObj(info.draws());
			v[attribute::tree::AverageRating     ] = Tcl_NewIntObj(info.averageRating());
			v[attribute::tree::Performance       ] = Tcl_NewIntObj(info.performance(tree->ratingType()));
			v[attribute::tree::BestRating        ] = Tcl_NewIntObj(info.bestRating());
			v[attribute::tree::AverageYear       ] = Tcl_NewIntObj(info.averageYear());
			v[attribute::tree::LastYear          ] = Tcl_NewIntObj(info.lastYear());
			v[attribute::tree::BestPlayer        ] = Tcl_NewListObj(2, objvBestPlayer);
			v[attribute::tree::MostFrequentPlayer] = Tcl_NewListObj(2, objvMostFrequentPlayer);

			objs[i] = Tcl_NewListObj(U_NUMBER_OF(v), v);
		}

		setResult(objc + 1, objs);
	}
	else
	{
		setResult(0, 0);
	}

	return TCL_OK;
}


static int
cmdMove(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (Tree const* tree = Scidb.currentTree())
	{
		Board const& board = Scidb.game().currentBoard();

		if (tree->isTreeFor(Scidb.cursor().database(), board))
		{
			unsigned row = unsignedFromObj(objc, objv, 1);

			if (row >= tree->size())
				return error(CmdMove, 0, 0, "invalid row %u", row);

			TreeInfo const& info = tree->info(row);

			if (board.isValidMove(info.move(), move::DontAllowIllegalMove))
			{
				mstl::string s;
				info.move().printSan(s);
				setResult(s);
			}
		}
	}

	return TCL_OK;
}


static int
cmdPlayer(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (Tree const* tree = Scidb.currentTree())
	{
		unsigned row = unsignedFromObj(objc, objv, 1);
		NamebasePlayer const* player;

		if (row > tree->size())
			return error(CmdPlayer, 0, 0, "invalid row (%u)", row);

		TreeInfo const& info = row == tree->size() ? tree->total() : tree->info(row);

		char const* which = stringFromObj(objc, objv, 2);

		if (::strcmp(which, "bestPlayer") == 0)
			player = &info.bestPlayer();
		else if (::strcmp(which, "frequentPlayer") == 0)
			player = &info.mostFrequentPlayer();
		else
			return error(CmdFetch, 0, 0, "invalid id %s", stringFromObj(objc, objv, 2));

		rating::Type ratingType = rating::fromString(stringFromObj(objc, objv, 3));

		if (ratingType == rating::Last)
			return error(CmdFetch, 0, 0, "unknown rating type %s", stringFromObj(objc, objv, 3));

		::tcl::db::Ratings ratings(ratingType, rating::Elo);
		::tcl::db::getPlayerInfo(*player, ratings, true, true);
	}
	else
	{
		setResult(0, 0);
	}

	return TCL_OK;
}


static int
cmdView(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (Scidb.haveReferenceBase())
		setResult(Scidb.referenceBase().treeViewIdentifier());
	else
		setResult(-1);

	return TCL_OK;
}


static int
cmdPosition(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (Tree const* tree = Scidb.currentTree())
	{
		Board board;
		board.setup(tree->position());
		setResult(board.toFen());
	}

	return TCL_OK;
}


static int
cmdIsRefBase(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* base = stringFromObj(objc, objv, 1);

	if (!Scidb.haveReferenceBase())
		setResult(false);
	else if (Scidb.referenceBase().database().name() == base)
		setResult(true);
	else
		setResult(false);

	return TCL_OK;
}


namespace tcl {
namespace tree {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdFetch,		cmdFetch);
	createCommand(ti, CmdFinish,		cmdFinish);
	createCommand(ti, CmdGet,			cmdGet);
	createCommand(ti, CmdInit,			cmdInit);
	createCommand(ti, CmdIsRefBase,	cmdIsRefBase);
	createCommand(ti, CmdList,			cmdList);
	createCommand(ti, CmdMove,			cmdMove);
	createCommand(ti, CmdPlayer,		cmdPlayer);
	createCommand(ti, CmdPosition,	cmdPosition);
	createCommand(ti, CmdSet,			cmdSet);
	createCommand(ti, CmdStop,			cmdStop);
	createCommand(ti, CmdSwitch,		cmdSwitch);
	createCommand(ti, CmdUpdate,		cmdUpdate);
	createCommand(ti, CmdView,			cmdView);
}

} // namespace tree
} // namespace tcl

// vi:set ts=3 sw=3:
