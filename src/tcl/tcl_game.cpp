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

#include "tcl_game.h"
#include "tcl_board.h"
#include "tcl_database.h"
#include "tcl_application.h"
#include "tcl_position.h"
#include "tcl_pgn_reader.h"
#include "tcl_log.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_database.h"
#include "db_game.h"
#include "db_edit_node.h"
#include "db_move.h"
#include "db_move_node.h"
#include "db_eco_table.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_tag_set.h"
#include "db_var_consumer.h"

#include "u_progress.h"

#include "sys_utf8_codec.h"

#include "m_sstream.h"

#include <tcl.h>

#include <string.h>
#include <ctype.h>

#ifdef DEBUG
# undef DEBUG
# define DEBUG(x) x
#else
# define DEBUG(x)
#endif

using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::app;

static char const* CmdBoard		= "::scidb::game::board";
static char const* CmdCleanUp		= "::scidb::game::cleanup";
static char const* CmdClear		= "::scidb::game::clear";
static char const* CmdCount		= "::scidb::game::count";
static char const* CmdCurrent		= "::scidb::game::current";
static char const* CmdDump			= "::scidb::game::dump";
static char const* CmdExchange	= "::scidb::game::exchange";
static char const* CmdExecute		= "::scidb::game::execute";
static char const* CmdGo			= "::scidb::game::go";
static char const* CmdImport		= "::scidb::game::import";
static char const* CmdInfo			= "::scidb::game::info";
static char const* CmdLevel		= "::scidb::game::level";
static char const* CmdLoad			= "::scidb::game::load";
static char const* CmdMaterial	= "::scidb::game::material";
static char const* CmdMove			= "::scidb::game::move";
static char const* CmdMoveto		= "::scidb::game::moveto";
static char const* CmdNew			= "::scidb::game::new";
static char const* CmdNext			= "::scidb::game::next";
static char const* CmdNumber		= "::scidb::game::number";
static char const* CmdPly			= "::scidb::game::ply";
static char const* CmdPop			= "::scidb::game::pop";
static char const* CmdPosition	= "::scidb::game::position";
static char const* CmdPush			= "::scidb::game::push";
static char const* CmdQuery		= "::scidb::game::query";
static char const* CmdRefresh		= "::scidb::game::refresh";
static char const* CmdRelease		= "::scidb::game::release";
static char const* CmdReplace		= "::scidb::game::replace";
static char const* CmdSave			= "::scidb::game::save";
static char const* CmdSetup		= "::scidb::game::setup";
static char const* CmdSink			= "::scidb::game::sink?";
static char const* CmdStrip		= "::scidb::game::strip";
static char const* CmdSubscribe	= "::scidb::game::subscribe";
static char const* CmdTags			= "::scidb::game::tags";
static char const* CmdTranspose	= "::scidb::game::transpose";
static char const* CmdUpdate		= "::scidb::game::update";
static char const* CmdVariation	= "::scidb::game::variation";
static char const* CmdSwitch		= "::scidb::game::switch";


static char const*
skipSpaces(char const* s)
{
	while (::isspace(*s))
		++s;

	return s;
}


static char const*
toString(Game::Command command)
{
	switch (command)
	{
		case Game::None:					return "";
		case Game::SetAnnotation:		return "move:annotation";
		case Game::AddMove:				return "move:append";
		case Game::ExchangeMove:		return "move:exchange";
		case Game::AddVariation:		return "variation:new";
		case Game::ReplaceVariation:	return "variation:replace";
		case Game::TruncateVariation:	return "variation:truncate";
		case Game::FirstVariation:		return "variation:first";
		case Game::PromoteVariation:	return "variation:promote";
		case Game::RemoveVariation:	return "variation:remove";
		case Game::NewMainline:			return "variation:mainline";
		case Game::InsertMoves:			return "variation:insert";
		case Game::ExchangeMoves:		return "variation:exchange";
		case Game::StripMoves:			return "strip:moves";
		case Game::StripAnnotations:	return "strip:annotations";
		case Game::StripMarks:			return "strip:marks";
		case Game::StripComments:		return "strip:comments";
		case Game::StripVariations:	return "strip:variations";
		case Game::Clear:					return "game:clear";
		case Game::Transpose:			return "game:transpose";
	}

	return 0;	// never reached
}


namespace {

struct SingleProgress : public util::Progress
{
	SingleProgress() { setFrequency(1); }
	bool interrupted() { return true; }
};


class Visitor : public edit::Visitor
{
public:

	Visitor()
		:m_objc(0)
	{
		if (m_action == 0)
		{
			Tcl_IncrRefCount(m_action		= Tcl_NewStringObj("action",		-1));
			Tcl_IncrRefCount(m_clear		= Tcl_NewStringObj("clear",		-1));
			Tcl_IncrRefCount(m_insert		= Tcl_NewStringObj("insert",		-1));
			Tcl_IncrRefCount(m_replace		= Tcl_NewStringObj("replace",		-1));
			Tcl_IncrRefCount(m_remove		= Tcl_NewStringObj("remove",		-1));
			Tcl_IncrRefCount(m_finish		= Tcl_NewStringObj("finish",		-1));
			Tcl_IncrRefCount(m_header		= Tcl_NewStringObj("header",		-1));
			Tcl_IncrRefCount(m_idn			= Tcl_NewStringObj("idn",			-1));
			Tcl_IncrRefCount(m_eco			= Tcl_NewStringObj("eco",			-1));
			Tcl_IncrRefCount(m_position	= Tcl_NewStringObj("position",	-1));
			Tcl_IncrRefCount(m_opening		= Tcl_NewStringObj("opening",		-1));
			Tcl_IncrRefCount(m_languages	= Tcl_NewStringObj("languages",	-1));
			Tcl_IncrRefCount(m_ply			= Tcl_NewStringObj("ply",			-1));
			Tcl_IncrRefCount(m_white		= Tcl_NewStringObj("white",		-1));
			Tcl_IncrRefCount(m_black		= Tcl_NewStringObj("black",		-1));
			Tcl_IncrRefCount(m_legal		= Tcl_NewStringObj("legal",		-1));
			Tcl_IncrRefCount(m_diagram		= Tcl_NewStringObj("diagram",		-1));
			Tcl_IncrRefCount(m_color		= Tcl_NewStringObj("color",		-1));
			Tcl_IncrRefCount(m_board		= Tcl_NewStringObj("board",		-1));
			Tcl_IncrRefCount(m_comment		= Tcl_NewStringObj("comment",		-1));
			Tcl_IncrRefCount(m_annotation	= Tcl_NewStringObj("annotation",	-1));
			Tcl_IncrRefCount(m_marks		= Tcl_NewStringObj("marks",		-1));
			Tcl_IncrRefCount(m_space		= Tcl_NewStringObj("space",		-1));
			Tcl_IncrRefCount(m_break		= Tcl_NewStringObj("break",		-1));
			Tcl_IncrRefCount(m_begin		= Tcl_NewStringObj("begin",		-1));
			Tcl_IncrRefCount(m_end			= Tcl_NewStringObj("end",			-1));
			Tcl_IncrRefCount(m_move			= Tcl_NewStringObj("move",			-1));
			Tcl_IncrRefCount(m_start		= Tcl_NewStringObj("start",		-1));
			Tcl_IncrRefCount(m_result		= Tcl_NewStringObj("result",		-1));
			Tcl_IncrRefCount(m_open			= Tcl_NewStringObj("(",				-1));
			Tcl_IncrRefCount(m_close		= Tcl_NewStringObj(")",				-1));
			Tcl_IncrRefCount(m_none			= Tcl_NewStringObj("",				-1));
			Tcl_IncrRefCount(m_zero			= Tcl_NewIntObj(0));
		}

		Tcl_IncrRefCount(m_list = Tcl_NewListObj(0, 0));
	}

	~Visitor() throw()
	{
		Tcl_DecrRefCount(m_list);
	}

	void start(result::ID)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "start {}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_ListObjAppendElement(0, m_list, m_start);
	}

	void finish(result::ID result)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "result { ";
		s += result::toString(result);
		s += " }\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[2];

		objv[0] = m_result;
		objv[1] = Tcl_NewStringObj(result::toString(result), -1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv), objv));
	}

	void clear()
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "action { clear }\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[2];

		objv_1[0] = m_action;
		objv_1[1] = Tcl_NewListObj(1, &m_clear);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1));
	}

	void insert(unsigned level, edit::Key const& beforeKey)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "action { insert ";
		s.format("%u ", level);
		s += beforeKey.id();
		s += " }\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[3];

		objv_1[0] = m_insert;
		objv_1[1] = Tcl_NewIntObj(level);
		objv_1[2] = Tcl_NewStringObj(beforeKey.id(), beforeKey.id().size());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2));
	}

	void replace(unsigned level, edit::Key const& startKey, edit::Key const& endKey)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "action { replace ";
		s.format("%u ", level);
		s += startKey.id();
		s += " ";
		s += endKey.id();
		s += " }\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[4];

		objv_1[0] = m_replace;
		objv_1[1] = Tcl_NewIntObj(level);
		objv_1[2] = Tcl_NewStringObj(startKey.id(), startKey.id().size());
		objv_1[3] = Tcl_NewStringObj(endKey.id(), endKey.id().size());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2));
	}

	void remove(unsigned level, edit::Key const& startKey, edit::Key const& endKey)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "action { remove ";
		s.format(" %u ", level);
		s += startKey.id();
		s += " ";
		s += endKey.id();
		s += " }\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[4];

		objv_1[0] = m_remove;
		objv_1[1] = Tcl_NewIntObj(level);
		objv_1[2] = Tcl_NewStringObj(startKey.id(), startKey.id().size());
		objv_1[3] = Tcl_NewStringObj(endKey.id(), endKey.id().size());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2));
	}

	void finish(unsigned level)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s.format("action { finish %u }\n", level);
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[2];

		objv_1[0] = m_finish;
		objv_1[1] = Tcl_NewIntObj(level);

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2));
	}

	void opening(Board const& startBoard, uint16_t idn, Eco const& eco)
	{
		mstl::string openingLong, openingShort, variation, subvariation, position;
		EcoTable::specimen().getOpening(eco, openingLong, openingShort, variation, subvariation);

////////////////////////////////////////////////////////////////////////
		mstl::string pos;

		if (idn)
		{
//			shuffle::utf8::position(idn, pos);
			pos = shuffle::position(idn);
			// TODO add castling rights
		}
		else
		{
			startBoard.toFen(pos);
		}

		s.format("header {\n");
		s.format("  idn %u\n", unsigned(idn));
		s.format("  position %s\n", pos.c_str());
		s.format("  eco %s\n", eco.asShortString().c_str());
		s.format("  opening {{%s} {%s}} {%s} {%s}}\n",
					openingLong.c_str(),
					openingShort.c_str(),
					variation.c_str(),
					subvariation.c_str());
		s.format("}\n");
////////////////////////////////////////////////////////////////////////

		if (idn)
			shuffle::utf8::position(idn, position);
		else
			startBoard.toFen(position);

		Tcl_Obj* objv_1[2];

		objv_1[0] = Tcl_NewStringObj(openingLong, openingLong.size());
		objv_1[1] = Tcl_NewStringObj(openingShort, openingShort.size());

		Tcl_Obj* objv_2[3];

		objv_2[0] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);
		objv_2[1] = Tcl_NewStringObj(variation, variation.size());
		objv_2[2] = Tcl_NewStringObj(subvariation, subvariation.size());

		Tcl_Obj* objv_3[2];

		objv_3[0] = m_idn;
		objv_3[1] = Tcl_NewIntObj(idn);

		Tcl_Obj* objv_4[2];

		objv_4[0] = m_eco;
		objv_4[1] = Tcl_NewStringObj(eco.asShortString(), -1);

		Tcl_Obj* objv_5[2];

		objv_5[0] = m_position;
		objv_5[1] = Tcl_NewStringObj(position, position.size());

		Tcl_Obj* objv_6[2];

		objv_6[0] = m_opening;
		objv_6[1] = Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2);

		Tcl_Obj* objv_7[4];

		objv_7[0] = Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_3);
		objv_7[1] = Tcl_NewListObj(U_NUMBER_OF(objv_3), objv_4);
		objv_7[2] = Tcl_NewListObj(U_NUMBER_OF(objv_4), objv_5);
		objv_7[3] = Tcl_NewListObj(U_NUMBER_OF(objv_5), objv_6);

		Tcl_Obj* objv_8[2];

		objv_8[0] = m_header;
		objv_8[1] = Tcl_NewListObj(U_NUMBER_OF(objv_7), objv_7);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_8), objv_8));
	}

	void languages(LanguageSet const& languages)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "languages {";

		for (LanguageSet::const_iterator i = languages.begin(), e = languages.end(); i != e; ++i)
		{
			if (!i->first.empty())
			{
				if (i != languages.begin())
					s += " ";
				s += i->first;
			}
		}

		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj*  objv_1[languages.size()];
		Tcl_Obj** p(&objv_1[0]);

		for (LanguageSet::const_iterator i = languages.begin(), e = languages.end(); i != e; ++i)
		{
			if (!i->first.empty())
				*p++ = Tcl_NewStringObj(i->first, i->first.size());
		}

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_languages;
		objv_2[1] = Tcl_NewListObj(p - objv_1, objv_1);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2));
	}

	void move(unsigned moveNo, Move const& move)
	{
		mstl::string san;

////////////////////////////////////////////////////////////////////////
		move.printSan(san);
		s += l;
		s += "ply ";
		if (moveNo)
			s.format("%u ", moveNo);
		s += "{ ";
		s += color::printColor(move.color());
		s += " ";
		s += san;
		if (!move.isLegal())
			s += " illegal";
		s += " }\n";
		san.clear();
////////////////////////////////////////////////////////////////////////

		move.printSan(san, Move::Unicode);

		Tcl_Obj* objv_1[4];

		objv_1[0] = Tcl_NewIntObj(moveNo);
		objv_1[1] = color::isWhite(move.color()) ? m_white : m_black;
		objv_1[2] = Tcl_NewStringObj(san, san.size());
		objv_1[3] = Tcl_NewBooleanObj(move.isLegal());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_ply;
		objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2);
	}

	void position(::db::Board const& board, color::ID fromColor)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "color ";
		s += color::printColor(fromColor);
		s += "\n";
		s += l;
		s += "board ";
		board.toFen(s);
		s += "\n";
////////////////////////////////////////////////////////////////////////

		mstl::string position = tcl::board::toBoard(board);

		Tcl_Obj* objv_1[2];

		objv_1[0] = m_color;
		objv_1[1] = color::isWhite(fromColor) ? m_white : m_black;

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_board;
		objv_2[1] = Tcl_NewStringObj(position, position.size());

		M_ASSERT(m_objc + 1 < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2);
	}

	void comment(edit::Key const& key, Comment const& comment)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "comment ";
		s += key.id();
		s += " {";
		s += comment.content();
		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv_1[4];

		objv_1[0] = m_comment;
		objv_1[1] = Tcl_NewStringObj(key.id(), key.id().size());
		objv_1[2] = m_objc == 1 ? m_objv[0] : Tcl_NewListObj(0, 0);
		objv_1[3] = Tcl_NewStringObj(comment.content(), comment.content().size());

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1));
		m_objc = 0;
	}

	void comment(Comment const& comment)
	{
////////////////////////////////////////////////////////////////////////
		mstl::string buf;
		if (::sys::utf8::Codec::fitsRegion(comment.content(), 1))
			::sys::utf8::Codec::convertToNonDiacritics(1, comment.content(), buf);
		else
			buf = "<comment not LATIN-1>";
		s += l;
		s += "comment {";
		s += buf;
		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[2];

		objv[0] = m_comment;
		objv[1] = Tcl_NewStringObj(comment.content(), comment.content().size());

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
	}

	void annotation(Annotation const& annotation)
	{
		mstl::string prefix, infix, suffix;

		annotation.prefix(prefix);
		annotation.infix(infix);
		annotation.suffix(suffix);

////////////////////////////////////////////////////////////////////////
		s += l;
		s += "annotation {";
		s += prefix;
		s += "} {";
		s += infix;
		s += "} {";
		s += suffix;
		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[4];

		objv[0] = m_annotation;
		objv[1] = Tcl_NewStringObj(prefix, prefix.size());
		objv[2] = Tcl_NewStringObj(infix, infix.size());
		objv[3] = Tcl_NewStringObj(suffix, suffix.size());

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
	}

	void marks(MarkSet const& marks)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s.format("marks %u\n", unsigned(marks.count()));
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[2];

		objv[0] = m_marks;
		objv[1] = Tcl_NewIntObj(marks.count());

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
	}

	void space(char bracket)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s += "space";
		if (bracket == '(')
			s += " { open } ";
		else if (bracket == ')')
			s += " { close } ";
		s += '\n';
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[2];

		objv[0] = m_space;

		switch (bracket)
		{
			case edit::Node::Open:	objv[1] = m_open; break;
			case edit::Node::Close:	objv[1] = m_close; break;
			default:						objv[1] = m_none; break;
		}

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
	}

	void linebreak(unsigned level, char bracket)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s.format("break %u", level);
		if (bracket == '(')
			s += " { open } ";
		else if (bracket == ')')
			s += " { close } ";
		s += '\n';
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[3];

		objv[0] = m_break;
		objv[1] = Tcl_NewIntObj(level);

		switch (bracket)
		{
			case edit::Node::Open:	objv[2] = m_open; break;
			case edit::Node::Close:	objv[2] = m_close; break;
			default:						objv[2] = m_none; break;
		}

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = Tcl_NewListObj(U_NUMBER_OF(objv), objv);
	}

	void startVariation(edit::Key const& startKey, edit::Key const& endKey)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		s.format("begin %s { %u }\n", startKey.id().c_str(), startKey.level());
		l.assign(2*(l.size()/2 + 1), ' ');
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[3];

		objv[0] = m_begin;
		objv[1] = Tcl_NewStringObj(startKey.id(), startKey.id().size());
		objv[2] = Tcl_NewIntObj(startKey.level());

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv), objv));
	}

	void endVariation(edit::Key const& startKey, edit::Key const& endKey)
	{
////////////////////////////////////////////////////////////////////////
		l.assign(2*(l.size()/2 - 1), ' ');
		s += l;
		s.format("end %s { %u }\n", endKey.id().c_str(), endKey.level());
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[3];

		objv[0] = m_end;
		objv[1] = Tcl_NewStringObj(endKey.id(), endKey.id().size());
		objv[2] = Tcl_NewIntObj(endKey.level());

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv), objv));
	}

	void startMove(edit::Key const& key)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		l.assign(2*(l.size()/2 + 1), ' ');
		s.format("move %s {\n", key.id().c_str());
////////////////////////////////////////////////////////////////////////
	}

	void endMove(edit::Key const& key)
	{
////////////////////////////////////////////////////////////////////////
		l.assign(2*(l.size()/2 - 1), ' ');
		s += l;
		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[3];

		objv[0] = m_move;
		objv[1] = Tcl_NewStringObj(key.id(), key.id().size());
		objv[2] = Tcl_NewListObj(m_objc, m_objv);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv), objv));
		m_objc = 0;
	}

	void startDiagram(edit::Key const& key)
	{
////////////////////////////////////////////////////////////////////////
		s += l;
		l.assign(2*(l.size()/2 + 1), ' ');
		s.format("diagram %s {\n", key.id().c_str());
////////////////////////////////////////////////////////////////////////
	}

	void endDiagram(edit::Key const& key)
	{
////////////////////////////////////////////////////////////////////////
		l.assign(2*(l.size()/2 - 1), ' ');
		s += l;
		s += "}\n";
////////////////////////////////////////////////////////////////////////

		Tcl_Obj* objv[3];

		objv[0] = m_diagram;
		objv[1] = Tcl_NewStringObj(key.id(), key.id().size());
		objv[2] = Tcl_NewListObj(m_objc, m_objv);

		Tcl_ListObjAppendElement(0, m_list, Tcl_NewListObj(U_NUMBER_OF(objv), objv));
		m_objc = 0;
	}

////////////////////////////////////////////////////////////////////////
	mstl::string l;
	mstl::string s;
////////////////////////////////////////////////////////////////////////

	Tcl_Obj* m_list;

	Tcl_Obj* m_objv[10];
	unsigned m_objc;

	static Tcl_Obj* m_action;
	static Tcl_Obj* m_clear;
	static Tcl_Obj* m_insert;
	static Tcl_Obj* m_replace;
	static Tcl_Obj* m_remove;
	static Tcl_Obj* m_finish;
	static Tcl_Obj* m_header;
	static Tcl_Obj* m_idn;
	static Tcl_Obj* m_eco;
	static Tcl_Obj* m_position;
	static Tcl_Obj* m_opening;
	static Tcl_Obj* m_languages;
	static Tcl_Obj* m_ply;
	static Tcl_Obj* m_white;
	static Tcl_Obj* m_black;
	static Tcl_Obj* m_legal;
	static Tcl_Obj* m_diagram;
	static Tcl_Obj* m_color;
	static Tcl_Obj* m_board;
	static Tcl_Obj* m_comment;
	static Tcl_Obj* m_annotation;
	static Tcl_Obj* m_marks;
	static Tcl_Obj* m_space;
	static Tcl_Obj* m_break;
	static Tcl_Obj* m_begin;
	static Tcl_Obj* m_end;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_start;
	static Tcl_Obj* m_result;
	static Tcl_Obj* m_open;
	static Tcl_Obj* m_close;
	static Tcl_Obj* m_none;
	static Tcl_Obj* m_zero;
};


Tcl_Obj* Visitor::m_action			= 0;
Tcl_Obj* Visitor::m_clear			= 0;
Tcl_Obj* Visitor::m_insert			= 0;
Tcl_Obj* Visitor::m_replace		= 0;
Tcl_Obj* Visitor::m_remove			= 0;
Tcl_Obj* Visitor::m_finish			= 0;
Tcl_Obj* Visitor::m_header			= 0;
Tcl_Obj* Visitor::m_idn				= 0;
Tcl_Obj* Visitor::m_eco				= 0;
Tcl_Obj* Visitor::m_position		= 0;
Tcl_Obj* Visitor::m_opening		= 0;
Tcl_Obj* Visitor::m_languages		= 0;
Tcl_Obj* Visitor::m_ply				= 0;
Tcl_Obj* Visitor::m_white			= 0;
Tcl_Obj* Visitor::m_black			= 0;
Tcl_Obj* Visitor::m_legal			= 0;
Tcl_Obj* Visitor::m_diagram		= 0;
Tcl_Obj* Visitor::m_color			= 0;
Tcl_Obj* Visitor::m_board			= 0;
Tcl_Obj* Visitor::m_comment			= 0;
Tcl_Obj* Visitor::m_annotation	= 0;
Tcl_Obj* Visitor::m_marks			= 0;
Tcl_Obj* Visitor::m_space			= 0;
Tcl_Obj* Visitor::m_break			= 0;
Tcl_Obj* Visitor::m_begin			= 0;
Tcl_Obj* Visitor::m_end				= 0;
Tcl_Obj* Visitor::m_move			= 0;
Tcl_Obj* Visitor::m_start			= 0;
Tcl_Obj* Visitor::m_result			= 0;
Tcl_Obj* Visitor::m_open			= 0;
Tcl_Obj* Visitor::m_close			= 0;
Tcl_Obj* Visitor::m_none			= 0;
Tcl_Obj* Visitor::m_zero			= 0;


struct Subscriber : public Game::Subscriber
{
	Tcl_Obj*	m_board;
	Tcl_Obj*	m_tree;
	Tcl_Obj*	m_pgn;
	Tcl_Obj*	m_position;
	bool		m_mainlineOnly;

	static bool m_addSpace;

	static Tcl_Obj* m_action;
	static Tcl_Obj* m_set;
	static Tcl_Obj* m_goto;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_marks;

	Subscriber(Tcl_Obj* position)
		:m_board(0)
		,m_tree(0)
		,m_pgn(0)
		,m_position(position)
		,m_mainlineOnly(false)
	{
		if (m_action == 0)
		{
			Tcl_IncrRefCount(m_action	= Tcl_NewStringObj("action", -1));
			Tcl_IncrRefCount(m_set		= Tcl_NewStringObj("set", -1));
			Tcl_IncrRefCount(m_goto		= Tcl_NewStringObj("goto", -1));
			Tcl_IncrRefCount(m_move		= Tcl_NewStringObj("move", -1));
			Tcl_IncrRefCount(m_marks	= Tcl_NewStringObj("marks", -1));

			pos::resetMoveCache();
		}

		Tcl_IncrRefCount(m_position);
	}

	void setBoardCmd(Tcl_Obj* obj)
	{
		if (!m_board)
			Tcl_IncrRefCount(m_board = obj);
	}

	void setTreeCmd(Tcl_Obj* obj)
	{
		if (!m_tree)
			Tcl_IncrRefCount(m_tree = obj);
	}

	void setPgnCmd(Tcl_Obj* obj, bool mainlineOnly = false)
	{
		if (!m_pgn)
		{
			Tcl_IncrRefCount(m_pgn = obj);
			m_mainlineOnly = mainlineOnly;
		}
	}

	bool mainlineOnly() { return m_mainlineOnly; }
	bool addSpaceAfterMoveNumber() { return m_addSpace; }

	void updateEditor(edit::Root const* node)
	{
		M_ASSERT(node);

		if (m_pgn)
		{
			Visitor visitor;
			node->visit(visitor);
			DEBUG(::fprintf(stderr, visitor.s.c_str()));
			DEBUG(::fprintf(stderr, "================================\n"));
			invoke(__func__, m_pgn, m_position, visitor.m_list, 0);
		}
	}

	void updateEditor(Game::DiffList const& nodes, TagSet const& tags)
	{
		if (m_pgn)
		{
			Visitor visitor;
			edit::Node::visit(visitor, nodes, tags);
			::fprintf(stderr, visitor.s.c_str());
			::fprintf(stderr, "================================\n");
			invoke(__func__, m_pgn, m_position, visitor.m_list, 0);
		}
	}

	void boardSetup(Board const& board)
	{
		if (m_board)
		{
			mstl::string pos;
			pos::dumpBoard(board, pos);

			Tcl_Obj* b = Tcl_NewStringObj(pos, pos.size());
			invoke(__func__, m_board, m_position, m_set, b, 0);
		}

		if (m_tree)
			invoke(__func__, m_tree, m_position, 0);
	}

	void boardMove(Board const& board, Move const& move, bool forward)
	{
		if (m_board)
		{
			char pieceFrom	= piece::print(move.piece());
			char pieceTo	= piece::print(move.isPromotion() ? move.promotedPiece() : move.piece());
			char pieceCap	= piece::print(move.capturedPiece());

			if (pieceCap == ' ')	pieceCap = '.';

			if (forward && move.isEnPassant())
				pieceCap = '.';

			int squareCap = move.capturedSquare();

			if (move.capturedPiece() == piece::Empty)
				squareCap = -1;

			Tcl_Obj* objv[9];

			objv[0] = Tcl_NewStringObj(color::isWhite(move.color()) ? "w" : "b", 1);
			objv[3] = Tcl_NewIntObj(squareCap);
			objv[4] = Tcl_NewStringObj(&pieceFrom, 1);
			objv[5] = Tcl_NewStringObj(&pieceTo, 1);
			objv[6] = Tcl_NewStringObj(&pieceCap, 1);

			if (move.isCastling())
			{
				int	rookFrom	= -1;
				int	rookTo	= -1;
				Byte	rook		= piece::piece(piece::Rook, move.color());

				// we allow castling w/o rook
				if (forward)
				{
					if (board.pieceAt(move.castlingRookTo()) == rook)
					{
						rookFrom = move.castlingRookFrom();
						rookTo = move.castlingRookTo();
					}
				}
				else
				{
					if (board.pieceAt(move.castlingRookFrom()) == rook)
					{
						rookFrom = move.castlingRookFrom();
						rookTo = move.castlingRookTo();
					}
				}

				objv[1] = Tcl_NewIntObj(move.castlingKingFrom());
				objv[2] = Tcl_NewIntObj(move.castlingKingTo());
				objv[7] = Tcl_NewIntObj(rookFrom);
				objv[8] = Tcl_NewIntObj(rookTo);
			}
			else
			{
				objv[1] = Tcl_NewIntObj(move.from());
				objv[2] = Tcl_NewIntObj(move.to());
				objv[7] = Tcl_NewIntObj(-1);
				objv[8] = Tcl_NewIntObj(-1);
			}

			if (!forward)
			{
				mstl::swap(objv[1], objv[2]);
				mstl::swap(objv[4], objv[5]);
				mstl::swap(objv[7], objv[8]);
			}

			invoke(__func__, m_board, m_position, m_move, U_NUMBER_OF(objv), objv);
		}

		pos::resetMoveCache();

		if (m_tree)
			invoke(__func__, m_tree, m_position, 0);
	}

	void updateMarks(mstl::string const& marks)
	{
		if (m_pgn)
		{
			Tcl_Obj* objv_1[2];

			objv_1[0] = m_marks;
			objv_1[1] = Tcl_NewStringObj(marks, marks.size());

			Tcl_Obj* objv_2[2];

			objv_2[0] = m_action;
			objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

			Tcl_Obj* objv_3[1] = { Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2) };

			invoke(__func__, m_pgn, m_position, Tcl_NewListObj(1, objv_3), 0);
		}
	}

	void gotoMove(mstl::string const& key, mstl::string const& succKey)
	{
		if (m_pgn)
		{
			Tcl_Obj* objv_1[3];

			objv_1[0] = m_goto;
			objv_1[1] = Tcl_NewStringObj(key, key.size());
			objv_1[2] = Tcl_NewStringObj(succKey, succKey.size());

			Tcl_Obj* objv_2[2];

			objv_2[0] = m_action;
			objv_2[1] = Tcl_NewListObj(U_NUMBER_OF(objv_1), objv_1);

			Tcl_Obj* objv_3[1] = { Tcl_NewListObj(U_NUMBER_OF(objv_2), objv_2) };

			invoke(__func__, m_pgn, m_position, Tcl_NewListObj(1, objv_3), 0);
		}

		pos::resetMoveCache();
	}
};

Tcl_Obj* Subscriber::m_action	= 0;
Tcl_Obj* Subscriber::m_set		= 0;
Tcl_Obj* Subscriber::m_goto	= 0;
Tcl_Obj* Subscriber::m_move	= 0;
Tcl_Obj* Subscriber::m_marks	= 0;

bool Subscriber::m_addSpace = false;

} // namespace


int
::tcl::game::convertTags(	::db::TagSet& tags,
									Tcl_Obj* taglist,
									::db::tag::ID wrt,
									::db::tag::ID brt,
									Ratings const* ratings)
{
	Ratings		rt = { tag::ExtraTag, tag::ExtraTag };
	Tcl_Obj**	objv;

	if (ratings)
		::memcpy(rt, *ratings, sizeof(rt));

	int maxSignificance[2] = { 1, 1 };
	int objc;

	if (Tcl_ListObjGetElements(interp(), taglist, &objc, &objv) != TCL_OK)
	{
		return error(	"save/update",
							0, 0,
							"cannot convert to list object: %s",
							Tcl_GetStringFromObj(taglist, 0));
	}
	if (objc % 2)
		return error("save/update", 0, 0, "odd number of elements in tag list");

	for (int i = 0; i < objc; i += 2)
	{
		tag::ID tid = tag::fromName(stringFromObj(objc, objv, i));

		if (tid == tag::ExtraTag)
		{
			tags.setExtra(stringFromObj(objc, objv, i), stringFromObj(objc, objv, i + 1));
		}
		else
		{
			tags.set(tid, stringFromObj(objc, objv, i + 1));

			if (tid == wrt)
			{
				tags.setSignificance(
					tid,
					rt[color::White] == tag::WhiteElo ? maxSignificance[color::White] = 2 : 1);
				rt[color::White] = tid;
			}
			else if (tid == brt)
			{
				tags.setSignificance(
					tid,
					rt[color::Black] == tag::BlackElo ? maxSignificance[color::Black] = 2 : 1);
				rt[color::Black] = tid;
			}
			else if (tid == tag::WhiteElo)
			{
				tags.setSignificance(tid, 1);

				if (rt[color::White] != tag::ExtraTag)
					tags.setSignificance(rt[color::White], maxSignificance[color::White] = 2);

				rt[color::White] = tid;
			}
			else if (tid == tag::BlackElo)
			{
				tags.setSignificance(tid, 1);

				if (rt[color::Black] != tag::ExtraTag)
					tags.setSignificance(rt[color::Black], maxSignificance[color::Black] = 2);

				rt[color::Black] = tid;
			}
		}
	}

	for (int i = 0; i < objc; i += 2)
	{
		tag::ID tid = tag::fromName(stringFromObj(objc, objv, i));

		if (tag::isWhiteRatingTag(tid))
		{
			if (tags.significance(tid) == 0 && maxSignificance[color::White] == 1)
				tags.setSignificance(tid, maxSignificance[color::White] = 2);
		}
		else if (tag::isBlackRatingTag(tid))
		{
			if (tags.significance(tid) == 0 && maxSignificance[color::Black] == 1)
				tags.setSignificance(tid, maxSignificance[color::Black] = 2);
		}
	}

	return TCL_OK;
}


static Square
squareFromObj(int objc, Tcl_Obj* const objv[], unsigned index)
{
	unsigned val = unsignedFromObj(objc, objv, index);

	if (val < sq::a1 || sq::h8 < val)
		return sq::Null;

	return val;
}


static int
cmdDump(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*		database	= stringFromObj(objc, objv, 1);
	unsigned			view		= unsignedFromObj(objc, objv, 2);
	unsigned			number	= unsignedFromObj(objc, objv, 3);
	mstl::string	fen;

	if (objc >= 5)
		fen = stringFromObj(objc, objv, 4);

	if (objc >= 6)
	{
		typedef View::StringList StringList;
		typedef View::LengthList LengthList;

		StringList result, positions;

		unsigned split = unsignedFromObj(objc, objv, 5);
		bool ok = Scidb.cursor(database).view(view).dumpGame(number, split, fen, result, positions).first;

		for (unsigned i = 0; i < positions.size(); ++i)
			pos::dumpFen(positions[i], positions[i]);

		Tcl_Obj* objv[mstl::mul2(result.size()) + 1];

		objv[0] = Tcl_NewBooleanObj(ok);

		for (unsigned i = 0; i < result.size(); ++i)
		{
			objv[mstl::mul2(i) + 1] = Tcl_NewStringObj(result[i], result[i].size());
			objv[mstl::mul2(i) + 2] = Tcl_NewStringObj(positions[i], positions[i].size());
		}

		setResult(mstl::mul2(result.size()) + 1, objv);
	}
	else
	{
		mstl::string result;

		bool ok = Scidb.cursor(database).view(view).dumpGame(number, fen, result).first;

		Tcl_Obj* objv[2] = { Tcl_NewBooleanObj(ok), Tcl_NewStringObj(result, result.size()) };
		setResult(2, objv);
	}

	return TCL_OK;
}


static int
cmdLoad(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned		position	= unsignedFromObj(objc, objv, 1);
	char const*	database	= stringFromObj(objc, objv, 2);
	unsigned		number	= unsignedFromObj(objc, objv, 3);

	setResult(scidb.loadGame(position, scidb.cursor(database), number));

	return TCL_OK;
}


static int
cmdMove(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.game().addMove(stringFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.newGame(unsignedFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdSwitch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = intFromObj(objc, objv, 1);
	scidb.switchGame(position);
	return TCL_OK;
}


static int
cmdRelease(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position	= unsignedFromObj(objc, objv, 1);
	scidb.releaseGame(position);
	return TCL_OK;
}


static int
cmdInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = intFromObj(objc, objv, 1);

	return tcl::db::getGameInfo(	Scidb.gameInfoAt(position),
											Scidb.gameIndex(position),
											tcl::db::Ratings(rating::Elo, rating::Elo),
											Scidb.cursor().database().format());
}


static int
cmdSubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* what				= stringFromObj(objc, objv, 1);
	unsigned		position			= unsignedFromObj(objc, objv, 2);
	bool			mainlineOnly	= false;

	if (strcmp(what, "pgn") != 0 && strcmp(what, "board") != 0 && strcmp(what, "tree") != 0)
		return error(::CmdSubscribe, 0, 0, "unexpected argument %s", what);

	Game&			game			= scidb.game(position);
	Subscriber*	subscriber	= static_cast<Subscriber*>(game.subscriber());
	unsigned		flags;

	if (subscriber == 0)
	{
		subscriber = new Subscriber(objv[2]);
		game.setSubscriber(Game::SubscriberP(subscriber));
	}

	if (strcmp(what, "board") == 0)
	{
		subscriber->setBoardCmd(objv[3]);
		flags = Game::UpdateBoard;
	}
	else if (strcmp(what, "tree") == 0)
	{
		subscriber->setTreeCmd(objv[3]);
		flags = Game::UpdateBoard;
	}
	else
	{
		if (objc >= 5)
			mainlineOnly = boolFromObj(objc, objv, 4);

		subscriber->setPgnCmd(objv[3], mainlineOnly);
		flags = Game::UpdatePgn | Game::UpdateOpening | Game::UpdateLanguageSet | Game::UpdateIllegalMoves;
	}

	game.updateSubscriber(flags);

	return TCL_OK;
}


static int
cmdRefresh(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.refreshGame();
	return TCL_OK;
}


static int
cmdTranspose(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool force = boolFromObj(objc, objv, 1);
	setResult(scidb.game().transpose(force ? Game::TruncateIfNeccessary : Game::OnlyIfRemainsConsistent));
	return TCL_OK;
}


static int
cmdCleanUp(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(scidb.game().cleanupVariations());
	return TCL_OK;
}


static int
cmdGo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned		index		= 1;
	char const*	firstArg	= stringFromObj(objc, objv, index);
	unsigned		position	= Application::InvalidPosition;

	if (objc >= 3 && (equal(firstArg, "-1") || isdigit(firstArg[0])))
		position = intFromObj(objc, objv, index++);

	Game& game = scidb.game(position);

	char const*	cmd = stringFromObj(objc, objv, index);

	switch (cmd[0])
	{
		case 'd': // down
			game.goIntoNextVariation();
			break;

		case 'u': // up
			game.goIntoPrevVariation();
			break;

		case 's': // start (of mainline)
			game.goToMainlineStart();
			break;

		case 'e': // end (of mainline)
			game.goToMainlineEnd();
			break;

		case 'f': // first (start of variation)
			game.goToStart();
			break;

		case 'l': // last (end of variation)
			game.goToEnd();
			break;

		case 'v': // variation
			{
				int i = intFromObj(objc, objv, index + 1);

				if (i >= 0)
					game.goIntoVariation(i);
			}
			break;

		case 'p': // position
			{
				char const* fen = stringFromObj(objc, objv, index + 1);

				if (*fen)
					game.goToPosition(stringFromObj(objc, objv, index + 1));
				else
					game.goToStart();
			}
			break;

		case 'c': // current
			game.goToCurrentMove();
			break;

		case 'k': // key
			game.goTo(stringFromObj(objc, objv, index + 1));
			break;

		default:
		{
			int count = intFromObj(objc, objv, index);

			if (count >= 0)
				game.goForward(count);
			else
				game.goBackward(-count);
		}
		break;
	}

	return TCL_OK;
}


static int
cmdMoveto(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned		position	= objc <= 2 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	char const*	key		= stringFromObj(objc, objv, objc <= 2 ? 1 : 2);

	scidb.game(position).goTo(key);
	return TCL_OK;
}


static int
cmdPosition(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"atStart?", "atEnd?", "isMainline?", "key", "forward", "backward", 0
	};
	static char const* args[] =
	{
		"?<position>?", "?<position>?", "?<position>?", "?<position>?", "?<position>?", "?<position>?", 0
	};
	enum { Cmd_AtStart, Cmd_AtEnd, Cmd_IsMainline, Cmd_Key, Cmd_Forward, Cmd_Backward };

	if (objc < 2)
		return usage(::CmdPosition, 0, 0, subcommands, args);

	int position	= objc < 3 ? -1 : intFromObj(objc, objv, 1);
	int index		= tcl::uniqueMatchObj(objv[objc < 3 ? 1 : 2], subcommands);

	switch (index)
	{
		case Cmd_AtStart:
			appendResult("%d", Scidb.game(position).atLineStart());
			break;

		case Cmd_AtEnd:
			appendResult("%d", Scidb.game(position).atLineEnd());
			break;

		case Cmd_IsMainline:
			appendResult("%d", Scidb.game(position).isMainline());
			break;

		case Cmd_Key:
			setResult(Scidb.game(position).currentKey().id());
			break;

		case Cmd_Forward:
			scidb.game(position).forward();
			break;

		case Cmd_Backward:
			scidb.game(position).backward();
			break;

		default:
			return usage(::CmdPosition, 0, 0, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdNext(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "keys", "moves", "move", 0 };
	static char const* args[] = { "<position>", "<position>", "",  };
	enum { Cmd_Keys, Cmd_Moves, Cmd_Move };

	if (objc < 2)
		return usage(::CmdNext, 0, 0, subcommands, args);

	unsigned		flags			= 0;	// satisifies the compiler
	char const*	lastOption	= stringFromObj(objc, objv, objc - 1);
	int			index			= tcl::uniqueMatchObj(objv[1], subcommands);

	if (equal(lastOption, "-ascii"))
		flags = Game::ExportFormat;
	else if (equal(lastOption, "-unicode"))
		flags = Game::MoveOnly;
	else if (lastOption[0] == '-')
		return error(CmdNext, 0, 0, "unknown option %s", lastOption);

	if (lastOption[0] == '-' && --objc < 2)
		return usage(::CmdNext, 0, 0, subcommands, args);

	if (index == Cmd_Move)
	{
		Game& game = scidb.game();
		setResult(game.atLineEnd() ? mstl::string::empty_string : game.getNextMove(flags));
	}
	else
	{
		if (index != Cmd_Keys && index != Cmd_Moves)
			return usage(::CmdNext, 0, 0, subcommands, args);

		int position = objc < 3 ? -1 : intFromObj(objc, objv, 2);

		Game::StringList result;

		switch (index)
		{
			case Cmd_Keys:		Scidb.game(position).getNextKeys(result); break;
			case Cmd_Moves:	Scidb.game(position).getNextMoves(result, flags); break;
		}

		Tcl_Obj* objs[result.size()];

		for (unsigned i = 0; i < result.size(); ++i)
			objs[i] = Tcl_NewStringObj(result[i], -1);

		setResult(result.size(), objs);
	}

	return TCL_OK;
}


static int
cmdLevel(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb.game().variationLevel());
	return TCL_OK;
}


static int
cmdVariation(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"count", "current", "new", "remove", "insert", "exchange",
		"promote", "mainline", "first", "leave", "length", 0
	};
	static char const* args[] =
	{
		"", "", "<san>", "<varno>", "<varno> ?-force?", "<varno> ?-force?",
		"<varno>", "<san>", "<varno>", "", "?<varno>?", 0
	};
	enum
	{
		Cmd_Count, Cmd_Current, Cmd_New, Cmd_Remove, Cmd_Insert, Cmd_Exchange,
		Cmd_Promote, Cmd_Mainline, Cmd_First, Cmd_Leave, Cmd_Length,
	};

	if (objc < 2)
		return usage(::CmdVariation, 0, 0, subcommands, args);

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Game& game = scidb.game();

	switch (index)
	{
		case Cmd_Count:
			setResult(game.subVariationCount());
			break;

		case Cmd_Current:
			setResult(game.variationNumber() + 1);
			break;

		case Cmd_New:
			setResult(game.addVariation(stringFromObj(objc, objv, 2)));
			break;

		case Cmd_Remove:
			game.removeVariation(unsignedFromObj(objc, objv, 2) - 1);
			break;

		case Cmd_Insert:
			{
				Game::Force flag = Game::OnlyIfRemainsConsistent;

				if (::strcmp(stringFromObj(objc, objv, objc - 1), "-force") == 0)
					flag = Game::TruncateIfNeccessary;

				setResult(game.insertMoves(unsignedFromObj(objc, objv, 2) - 1, flag));
			}
			break;

		case Cmd_Exchange:
			{
				Game::Force flag = Game::OnlyIfRemainsConsistent;

				if (::strcmp(stringFromObj(objc, objv, objc - 1), "-force") == 0)
					flag = Game::TruncateIfNeccessary;

				setResult(game.exchangeMoves(
					unsignedFromObj(objc, objv, 2) - 1, unsignedFromObj(objc, objv, 3), flag));
			}
			break;

		case Cmd_Promote:
			game.promoteVariation(unsignedFromObj(objc, objv, 2) - 1);
			break;

		case Cmd_Mainline:
			game.newMainline(stringFromObj(objc, objv, 2));
			break;

		case Cmd_First:
			game.firstVariation(unsignedFromObj(objc, objv, 2) - 1);
			break;

		case Cmd_Leave:
			setResult(game.variationNumber() + 1);
			game.exitVariation();
			break;

		case Cmd_Length:
			if (objc <= 2)
				setResult(game.lengthOfCurrentLine());
			else
				setResult(game.countHalfMoves(unsignedFromObj(objc, objv, 2) - 1));
			break;

		default:
			return error(CmdVariation, 0, 0, "unexpected command %s", stringFromObj(objc, objv, 1));
	}

	return TCL_OK;
}


static int
cmdCurrent(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb.currentPosition());
	return TCL_OK;
}


static int
cmdPly(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// NOTE: this call may come too early (before scratch game is created)
	if (scidb.haveCurrentGame())
		setResult(scidb.game().board().plyNumber());
	else
		setResult(0);

	return TCL_OK;
}


static int
cmdSave(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 7 && objc != 9)
	{
		Tcl_WrongNumArgs(
			ti,
			1, objv,
			"<database> <tag-list> <white-ratingtype> <black-ratingtype> "
			"<log-cmd> <log-arg> ?-replace <bool>?"
		);
		return TCL_ERROR;
	}

	bool				replace		= false;
	char const*		db				= stringFromObj(objc, objv, 1);
	tag::ID			wrt			= tag::fromName(stringFromObj(objc, objv, 3));
	tag::ID			brt			= tag::fromName(stringFromObj(objc, objv, 4));
	Tcl_Obj*			taglist		= objectFromObj(objc, objv, 2);
	tag::ID			ratings[2]	= { tag::ExtraTag, tag::ExtraTag };
	tcl::Log			log(objv[3], objv[4]);

	if (objc == 9)
	{
		if (::strcmp(stringFromObj(objc, objv, 7), "-replace") != 0)
			return error(CmdSave, 0, 0, "unexpected argument %s", stringFromObj(objc, objv, 7));

		replace = boolFromObj(objc, objv, 8);
	}

	TagSet tags;

	int rc = game::convertTags(tags, taglist, wrt, brt, &ratings);

	if (rc == TCL_OK)
	{
		// TODO: check tags

		scidb.game().setTags(tags);

		save::State state = scidb.saveGame(scidb.cursor(db), replace);

		setResult(state == save::Ok);
		log.error(state, Scidb.gameIndex());
	}

	return rc;
}


static int
cmdStrip(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"moves", "truncate", "annotations", "marks", "comments", "variations", 0
	};
	enum { Cmd_Moves, Cmd_Truncate, Cmd_Annotations, Cmd_Marks, Cmd_Comments, Cmd_Variations };

	if (objc < 2)
		return usage(CmdStrip, 0, 0, subcommands);

	switch (tcl::uniqueMatchObj(objv[1], subcommands))
	{
		case Cmd_Moves:
			scidb.game().stripMoves();
			break;

		case Cmd_Truncate:
			scidb.game().truncateVariation();
			break;

		case Cmd_Annotations:
			scidb.game().stripAnnotations();
			break;

		case Cmd_Marks:
			scidb.game().stripMarks();
			break;

		case Cmd_Comments:
			if (objc < 3)
				scidb.game().stripComments();
			else
				scidb.game().stripComments(stringFromObj(objc, objv, 2));
			break;

		case Cmd_Variations:
			{
				Game& game = scidb.game();

				game.exitToMainline();
				game.stripVariations();
				game.goToCurrentMove();
			}
			break;

		default:
			return error(CmdStrip, 0, 0, "unexpected command %s", stringFromObj(objc, objv, 1));
	}

	return TCL_OK;
}


static int
cmdReplace(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.game().replaceVariation(stringFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdExchange(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	san	= stringFromObj(objc, objv, 1);
	bool			force	= false;

	if (objc >= 3)
	{
		if (!equal(stringFromObj(objc, objv, 2), "-force"))
			return error(CmdExchange, 0, 0, "unexpected argument %s", stringFromObj(objc, objv, 2));

		force = true;
	}

	setResult(scidb.game().exchangeMove(
		san,
		force ? Game::TruncateIfNeccessary : Game::OnlyIfRemainsConsistent));

	return TCL_OK;
}


static int
cmdSink(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = intFromObj(objc, objv, 1);
	Tcl_Obj* objs[2];

	objs[0] = Tcl_NewStringObj(Scidb.databaseName(position), -1);
	objs[1] = Tcl_NewIntObj(Scidb.gameIndex(position));

	setResult(Tcl_NewListObj(2, objs));
	return TCL_OK;
}


static int
cmdQuery(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int			pos = objc == 2 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	char const*	cmd = stringFromObj(objc, objv, objc == 2 ? 1 : 2);

	if (::strlen(cmd) <= 1)
		return error(CmdQuery, 0, 0, "unexpected argument %s", cmd);

	switch (cmd[0])
	{
		case 'u': setResult(toString(Scidb.game(pos).undoCommand())); break;	// undo
		case 't': setResult(Scidb.hasTrialMode(pos)); break;						// trial
		case 'i': setResult(Scidb.game().idn()); break;								// idn
		case 'f': setResult(Scidb.game().startBoard().toFen()); break;			// fen
		case 'c': setResult(Scidb.game().comment()); break;							// comment

		case 'm':
			switch (cmd[1])
			{
				case 'o':	// modified?
					setResult(Scidb.game(pos).isModified());
					break;

				case 'a':	// marks
					{
						mstl::string marks;
						setResult(Scidb.game(pos).marks().print(marks));
					}
					break;

				default: return error(CmdQuery, 0, 0, "invalid command %s", cmd);
			}
			break;

		case 's':
			if (cmd[1] == 't')
			{
				switch (cmd[2])
				{
					case 'a': setResult(Scidb.game(pos).startKey()); break;		// start
					case 'm': setResult(color::printColor(Scidb.game(pos).sideToMove())); break; // stm

					default: return error(CmdQuery, 0, 0, "invalid command %s", cmd);
				}
			}
			else
			{
				return error(CmdQuery, 0, 0, "invalid command %s", cmd);
			}
			break;

		case 'a':	// annotation
			{
				mstl::string s;

				Game const&	game = Scidb.game(pos);
				Tcl_Obj*		objs[3];

				objs[0] = Tcl_NewStringObj(game.prefix(s), -1);
				objs[1] = Tcl_NewStringObj(game.infix(s),  -1);
				objs[2] = Tcl_NewStringObj(game.suffix(s), -1);

				setResult(3, objs);
			}
			break;

		case 'l':	// langSet
			{
				Game::LanguageSet const& langSet = Scidb.game().languageSet();
				mstl::string languages;

				for (Game::LanguageSet::const_iterator i = langSet.begin(); i != langSet.end(); ++i)
				{
					if (!languages.empty())
						languages += ' ';
					languages += i->first;
				}

				setResult(languages);
			}
			break;

		case 'r':
			switch (cmd[1])
			{
				case 'e':	// redo
					setResult(toString(Scidb.game(pos).redoCommand()));
					break;

				case 'a':	// ratingTypes
					{
						GameInfo const& info = Scidb.gameInfoAt(pos);

						mstl::string const& wr = rating::toString(info.ratingType(color::White));
						mstl::string const& br = rating::toString(info.ratingType(color::Black));

						Tcl_Obj* objs[2] = { Tcl_NewStringObj(wr, wr.size()), Tcl_NewStringObj(br, br.size())};
						setResult(2, objs);
					}
					break;

				default: return error(CmdQuery, 0, 0, "invalid command %s", cmd);
			}
			break;

		case 'e':
			switch (cmd[1])
			{
				case 'm': setResult(Scidb.game(pos).isEmpty()); break;									// empty?
				case 'c': setResult(Scidb.game(pos).computeEcoCode().asShortString()); break;	// eco

				default: return error(CmdQuery, 0, 0, "invalid command %s", cmd);
			}
			break;

		case 'd':	// database
			setResult(Scidb.databaseName(pos));
			break;

		default: return error(CmdQuery, 0, 0, "invalid command %s", cmd);
	}

	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int pos = objc == 3 ? intFromObj(objc, objv, 1) : Application::InvalidPosition;

	char const*	cmd = stringFromObj(objc, objv, objc == 3 ? 2 : 1);

	if (::strlen(cmd) <= 1)
		return error(CmdQuery, 0, 0, "unexpected argument %s", cmd);

	switch (cmd[0])
	{
		case 'a': setResult(scidb.game(pos).countAnnotations()); break;	// annotations
		case 'm': setResult(scidb.game(pos).countMarks()); break;			// marks
		case 'c': setResult(scidb.game(pos).countComments()); break;			// comments
		case 'v': setResult(scidb.game(pos).countVariations()); break;		// variations
		case 'h': setResult(scidb.game(pos).countHalfMoves()); break;		// halfmoves
		case 'l': setResult(scidb.game(pos).countLength()); break;			// length
		default:  return error(CmdQuery, 0, 0, "invalid command %s", cmd);
	}

	return TCL_OK;
}


static int
cmdClear(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	fen = stringFromObj(objc, objv, 1);
	int			idn = 0;

	Board board;

	if (Tcl_GetIntFromObj(interp(), objv[1], &idn) == TCL_OK)
	{
		if (idn < 1 || 4*960 < idn)
			error(CmdClear, 0, 0, "invalid IDN %d", idn);

		board.setup(unsigned(idn));
	}
	else
	{
		if (!board.setup(fen))
			error(CmdClear, 0, 0, "invalid FEN '%s'", fen);
	}

	scidb.clearGame(&board);

	return TCL_OK;
}


static int
cmdExecute(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	cmd = stringFromObj(objc, objv, 1);

	if (equal(cmd, "undo"))
		scidb.game().undo();
	else if (equal(cmd, "redo"))
		scidb.game().redo();
	else
		return error(CmdQuery, 0, 0, "invalid command %s", stringFromObj(objc, objv, 1));

	return TCL_OK;
}


static int
cmdBoard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;

	if (objc == 1)
		board = Scidb.game().board();
	else
		board = Scidb.game(intFromObj(objc, objv, 1)).board(stringFromObj(objc, objv, 2));

	mstl::string str;
	pos::dumpBoard(board, str);
	setResult(str);

	return TCL_OK;
}


static int
cmdMaterial(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board const& board = Scidb.game().board();

	int p = 0;
	int n = 0;
	int b = 0;
	int r = 0;
	int q = 0;

	for (unsigned i = 0; i < 64; ++i)
	{
		switch (int(board.pieceAt(i)))
		{
			case piece::WhiteBishop: ++b; break;
			case piece::WhiteKnight: ++n; break;
			case piece::WhitePawn:   ++p; break;
			case piece::WhiteRook:   ++r; break;
			case piece::WhiteQueen:  ++q; break;

			case piece::BlackBishop: --b; break;
			case piece::BlackKnight: --n; break;
			case piece::BlackPawn:   --p; break;
			case piece::BlackRook:   --r; break;
			case piece::BlackQueen:  --q; break;
		}
	}

	Tcl_Obj*	objs[5] =
	{
		Tcl_NewIntObj(p), Tcl_NewIntObj(n), Tcl_NewIntObj(b), Tcl_NewIntObj(r), Tcl_NewIntObj(q),
	};

	setResult(5, objs);
	return TCL_OK;
}


static int
cmdSetup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	edit::Node::linebreakThreshold			= unsignedFromObj(objc, objv, 1);
	edit::Node::linebreakMaxLineLengthMain	= unsignedFromObj(objc, objv, 2);
	edit::Node::linebreakMaxLineLengthVar	= unsignedFromObj(objc, objv, 3);
	edit::Node::linebreakMinCommentLength	= unsignedFromObj(objc, objv, 4);

	return TCL_OK;
}


static int
cmdTags(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int	position				= -1;
	bool	userSuppliedOnly	= false;

	if (objc > 1)
	{
		char const* opt = stringFromObj(objc, objv, 1);

		if (::isdigit(opt[0]) || ((opt[0] == '-' || opt[0] == '+') && ::isdigit(opt[1])))
		{
			position = intFromObj(objc, objv, 1);
			--objc;
			++objv;
		}
	}

	if (objc > 2)
	{
		char const* opt = stringFromObj(objc, objv, 1);

		if (::strcmp(opt, "-userSuppliedOnly") != 0)
		{
			return error(	::CmdTags, 0, 0,
								"unexpected option '%s'",
								stringFromObj(objc, objv, 1));
		}

		userSuppliedOnly = boolFromObj(objc, objv, 2);
	}

	TagSet const& tags = Scidb.game(position).tags();

	Tcl_Obj* result = Tcl_NewListObj(0, 0);

	for (unsigned tag = 0; tag < tag::ExtraTag; ++tag)
	{
		if (tags.contains(tag::ID(tag)) && (!userSuppliedOnly || tags.isUserSupplied(tag::ID(tag))))
		{
			Tcl_Obj* objs[2];

			mstl::string const name		= tag::toName(tag::ID(tag));
			mstl::string const value	= tags.value(tag::ID(tag));

			objs[0] = Tcl_NewStringObj(name, name.size());
			objs[1] = Tcl_NewStringObj(value, value.size());

			Tcl_ListObjAppendElement(ti, result, Tcl_NewListObj(2, objs));
		}
	}

	for (unsigned i = 0; i < tags.countExtra(); ++i)
	{
		Tcl_Obj* objs[2];

		TagSet::Tag const& pair = tags.extra(i);
		objs[0] = Tcl_NewStringObj(pair.name, pair.name.size());
		objs[1] = Tcl_NewStringObj(pair.value, pair.value.size());

		Tcl_ListObjAppendElement(ti, result, Tcl_NewListObj(2, objs));
	}

	setResult(result);
	return TCL_OK;
}


static int
cmdNumber(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb.gameIndex(objc > 1 ? intFromObj(objc, objv, 1) : -1) + 1);
	return TCL_OK;
}


static int
cmdPush(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.startTrialMode();
	return TCL_OK;
}


static int
cmdPop(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb.endTrialMode();
	scidb.refreshGame();
	return TCL_OK;
}


static int
cmdUpdate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"annotation", "infix", "prefix", "suffix", "comment", "marks", 0
	};
	static char const* args[] =
	{
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <string>",
		"<key> <type> <color> <from> <to>",
		0
	};
	enum { Cmd_Annotation, Cmd_Infix, Cmd_Pefix, Cmd_Suffix, Cmd_Comment, Cmd_Marks };

	if (objc < 2)
		return usage(::CmdUpdate, 0, 0, subcommands, args);

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Game& game = scidb.game();

	if (game.currentKey() != stringFromObj(objc, objv, 2))
	{
		return error(	::CmdUpdate, 0, 0,
							"key should be current position ('%s'), not '%s'",
							game.currentKey().id().c_str(),
							stringFromObj(objc, objv, 2));
	}

	switch (index)
	{
		case Cmd_Annotation:
			game.setAnnotation(Annotation(stringFromObj(objc, objv, 3)));
			break;

		case Cmd_Infix:
			{
				mstl::string s(stringFromObj(objc, objv, 3));
				game.prefix(s);
				game.suffix(s);
				game.setAnnotation(Annotation(s));
			}
			break;

		case Cmd_Pefix:
			{
				mstl::string s(stringFromObj(objc, objv, 3));
				game.infix(s);
				game.suffix(s);
				game.setAnnotation(Annotation(s));
			}
			break;

		case Cmd_Suffix:
			{
				mstl::string s(stringFromObj(objc, objv, 3));
				game.infix(s);
				game.prefix(s);
				game.setAnnotation(Annotation(s));
			}
			break;

		case Cmd_Comment:
			game.setComment(stringFromObj(objc, objv, 3));
			break;

		case Cmd_Marks:
			{
				char const*	text	= stringFromObj(objc, objv, 3);
				mark::Type	type	= mark::typeFromString(text);
				mark::Color	color	= mark::colorFromString(stringFromObj(objc, objv, 4));
				Square		from	= squareFromObj(objc, objv, 5);
				Square		to		= squareFromObj(objc, objv, 6);

				if (from == sq::Null || (type == mark::Arrow && (to == sq::Null || from == to)))
				{
					return error(	::CmdUpdate, "marks", 0,
										"invalid square(s) (%s, %s)",
										stringFromObj(objc, objv, 5),
										stringFromObj(objc, objv, 6));
				}

				if (from == to)
					to = sq::Null;

				Mark		mark(type, color, from, to, type == mark::Text ? *text : '\0');
				MarkSet	marks	= scidb.game().marks();
				int		index	= marks.match(mark);

				if (index == -1)
				{
					marks.add(mark);
				}
				else if (type == mark::Arrow || marks[index] == mark)
				{
					marks.remove(index);
				}
				else
				{
					marks.remove(index);
					marks.add(mark);
				}

				scidb.game().setMarks(marks);
			}
			break;

		default:
			return usage(::CmdUpdate, 0, 0, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdImport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	typedef tcl::PgnReader::Encoder Encoder;

	char const* figurine = 0;
	char const* encoding = sys::utf8::Codec::utf8();
	char const* option;

	bool	asVariation	= false;
	int	varno			= -1;

	while (objc > 2 && *(option = stringFromObj(objc, objv, objc - 2)) == '-')
	{
		if (::strcmp(option, "-encoding") == 0)
		{
			encoding = stringFromObj(objc, objv, objc - 1);
		}
		else if (::strcmp(option, "-figurine") == 0)
		{
			figurine = stringFromObj(objc, objv, objc - 1);

			for (unsigned i = 0; i < 6; ++i)
			{
				if (!::isupper(figurine[i]))
					return error(CmdImport, 0, 0, "invalid figurines '%s'", figurine);
			}
		}
		else if (::strcmp(option, "-variation") == 0)
		{
			asVariation = boolFromObj(objc, objv, objc - 1);
		}
		else if (::strcmp(option, "-varno") == 0)
		{
			varno = intFromObj(objc, objv, objc - 1);
		}
		else
		{
			return error (CmdImport, 0, 0, "unexpected option '%s'", option);
		}

		objc -= 2;
	}

	if (objc != 5)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<position> <text> <log> <log-arg> ?-encoding <string>?");
		return TCL_ERROR;
	}

	if (asVariation)
	{
		Encoder					encoder(encoding);
		mstl::istringstream	stream(stringFromObj(objc, objv, 2));
		tcl::PgnReader			reader(stream, encoder, objv[3], objv[4], -1);
		VarConsumer				consumer(Scidb.game().board());
		SingleProgress			progress;

		if (figurine)
			reader.setFigurine(figurine);
		reader.setConsumer(&consumer);

		reader.process(progress);

		if (reader.countErrors() > 0)
		{
			setResult(-int(reader.countErrors()));
		}
		else if (varno < 0)
		{
			setResult(scidb.game().addVariation(Game::MoveNodeP(consumer.release())));
		}
		else
		{
			scidb.game().changeVariation(Game::MoveNodeP(consumer.release()), varno);
			setResult(varno);
		}
	}
	else
	{
		mstl::string text(stringFromObj(objc, objv, 2));

		unsigned lineOffset = 0;

		if (*::skipSpaces(text) != '[')
		{
			text.insert(text.begin(),	"[Event  \"?\"]\n"
												"[Site   \"?\"]\n"
												"[Date   \"????.??.??\"]\n"
												"[Round  \"?\"]\n"
												"[White  \"?\"]\n"
												"[Black  \"?\"]\n"
												"[Result \"*\"]\n");

			lineOffset = 7;
		}

		int						position(intFromObj(objc, objv, 1));
		Encoder					encoder(encoding);
		mstl::istringstream	stream(text);
		tcl::PgnReader			reader(stream, encoder, objv[3], objv[4], 0, lineOffset);
		unsigned					count;

		if (figurine)
			reader.setFigurine(figurine);

		count = scidb.scratchBase().importGame(reader, scidb.indexAt(position));

		if (count >= 1)
			scidb.loadGame(position);

		setResult(count);
	}

	return TCL_OK;
}


namespace tcl {
namespace game {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdBoard,		cmdBoard);
	createCommand(ti, CmdCleanUp,	cmdCleanUp);
	createCommand(ti, CmdClear,		cmdClear);
	createCommand(ti, CmdCount,		cmdCount);
	createCommand(ti, CmdCurrent,		cmdCurrent);
	createCommand(ti, CmdDump,			cmdDump);
	createCommand(ti, CmdExchange,		cmdExchange);
	createCommand(ti, CmdExecute,		cmdExecute);
	createCommand(ti, CmdGo,			cmdGo);
	createCommand(ti, CmdImport,		cmdImport);
	createCommand(ti, CmdInfo,			cmdInfo);
	createCommand(ti, CmdLevel,		cmdLevel);
	createCommand(ti, CmdLoad,			cmdLoad);
	createCommand(ti, CmdMaterial,		cmdMaterial);
	createCommand(ti, CmdMove,			cmdMove);
	createCommand(ti, CmdMoveto,		cmdMoveto);
	createCommand(ti, CmdNew,			cmdNew);
	createCommand(ti, CmdNext,			cmdNext);
	createCommand(ti, CmdNumber,		cmdNumber);
	createCommand(ti, CmdPly,			cmdPly);
	createCommand(ti, CmdPop,			cmdPop);
	createCommand(ti, CmdPosition,	cmdPosition);
	createCommand(ti, CmdPush,			cmdPush);
	createCommand(ti, CmdQuery,		cmdQuery);
	createCommand(ti, CmdRefresh,		cmdRefresh);
	createCommand(ti, CmdRelease,		cmdRelease);
	createCommand(ti, CmdReplace,		cmdReplace);
	createCommand(ti, CmdSave,			cmdSave);
	createCommand(ti, CmdSetup,			cmdSetup);
	createCommand(ti, CmdSink,		cmdSink);
	createCommand(ti, CmdStrip,			cmdStrip);
	createCommand(ti, CmdSubscribe,	cmdSubscribe);
	createCommand(ti, CmdTags,			cmdTags);
	createCommand(ti, CmdTranspose,	cmdTranspose);
	createCommand(ti, CmdUpdate,		cmdUpdate);
	createCommand(ti, CmdVariation,	cmdVariation);
	createCommand(ti, CmdSwitch,		cmdSwitch);
}

} // namespace game
} // namespace tcl

// vi:set ts=3 sw=3:
