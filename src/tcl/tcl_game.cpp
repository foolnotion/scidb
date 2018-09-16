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
// Copyright: (C) 2009-2018 Gregor Cramer
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
#include "tcl_view.h"
#include "tcl_tree.h"
#include "tcl_log.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"
#include "app_view.h"

#include "db_database.h"
#include "db_board_base.h"
#include "db_game.h"
#include "db_edit_node.h"
#include "db_move.h"
#include "db_move_node.h"
#include "db_eco_table.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_tag_set.h"
#include "db_var_consumer.h"
#include "db_pgn_writer.h"

#include "T_Controller.h"

#include "u_progress.h"

#include "sys_utf8_codec.h"
#include "sys_file.h"

#include "m_sstream.h"
#include "m_vector.h"
#include "m_bitset.h"
#include "m_ofstream.h"
#include "m_sstream.h"

#include <tcl.h>

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;
using namespace app;
using namespace tcl;
using namespace tcl::app;

static char const* CmdBoard			= "::scidb::game::board";
static char const* CmdClear			= "::scidb::game::clear";
static char const* CmdCodeToFen		= "::scidb::game::codeToFen";
static char const* CmdCopy				= "::scidb::game::copy";
static char const* CmdCount			= "::scidb::game::count";
static char const* CmdCurrent			= "::scidb::game::current";
static char const* CmdDump				= "::scidb::game::dump";
static char const* CmdEcoTable		= "::scidb::game::ecotable";
static char const* CmdExchange		= "::scidb::game::exchange";
static char const* CmdExecute			= "::scidb::game::execute";
static char const* CmdExport			= "::scidb::game::export";
static char const* CmdFen				= "::scidb::game::fen";
static char const* CmdGo				= "::scidb::game::go";
static char const* CmdImport			= "::scidb::game::import";
static char const* CmdIndex			= "::scidb::game::index";
static char const* CmdInfo				= "::scidb::game::info";
static char const* CmdLangSet			= "::scidb::game::langSet";
static char const* CmdLayout			= "::scidb::game::layout";
static char const* CmdLevel			= "::scidb::game::level";
static char const* CmdLines			= "::scidb::game::lines";
static char const* CmdLink				= "::scidb::game::link?";
static char const* CmdLoad				= "::scidb::game::load";
static char const* CmdMaterial		= "::scidb::game::material";
static char const* CmdMerge			= "::scidb::game::merge";
static char const* CmdModified		= "::scidb::game::modified";
static char const* CmdMove				= "::scidb::game::move";
static char const* CmdMoveto			= "::scidb::game::moveto";
static char const* CmdNew				= "::scidb::game::new";
static char const* CmdNext				= "::scidb::game::next";
static char const* CmdNumber			= "::scidb::game::number";
static char const* CmdPaste			= "::scidb::game::paste";
static char const* CmdPly				= "::scidb::game::ply";
static char const* CmdPop				= "::scidb::game::pop";
static char const* CmdPosition		= "::scidb::game::position";
static char const* CmdPrint			= "::scidb::game::print";
static char const* CmdPromoted		= "::scidb::game::promoted";
static char const* CmdPush				= "::scidb::game::push";
static char const* CmdQuery			= "::scidb::game::query";
static char const* CmdRefresh			= "::scidb::game::refresh";
static char const* CmdRelease			= "::scidb::game::release";
static char const* CmdReload			= "::scidb::game::reload";
static char const* CmdReplace			= "::scidb::game::replace";
static char const* CmdSave				= "::scidb::game::save";
static char const* CmdSetupNags		= "::scidb::game::setupNags";
static char const* CmdSetupStyle		= "::scidb::game::setupStyle";
static char const* CmdSink				= "::scidb::game::sink";
static char const* CmdSink_			= "::scidb::game::sink?";
static char const* CmdStrip			= "::scidb::game::strip";
static char const* CmdSubscribe		= "::scidb::game::subscribe";
static char const* CmdSwap				= "::scidb::game::swap";
static char const* CmdSwapPositions	= "::scidb::game::swapPositions";
static char const* CmdSwitch			= "::scidb::game::switch";
static char const* CmdTags				= "::scidb::game::tags";
static char const* CmdToPGN			= "::scidb::game::toPGN";
static char const* CmdTranspose		= "::scidb::game::transpose";
static char const* CmdTrial			= "::scidb::game::trial";
static char const* CmdUndoSetup		= "::scidb::game::undoSetup";
static char const* CmdUnsubscribe	= "::scidb::game::unsubscribe";
static char const* CmdUpdate			= "::scidb::game::update";
static char const* CmdValid			= "::scidb::game::valid?";
static char const* CmdVariant			= "::scidb::game::variant?";
static char const* CmdVariation		= "::scidb::game::variation";
static char const* CmdVerify			= "::scidb::game::verify";
static char const* CmdView				= "::scidb::game::view";


static char const*
searchTag(char const* s)
{
	while (*s == ';')
	{
		do
			++s;
		while (*s && *s != '\n');

		while (isspace(*s))
			++s;
	}

	while (isspace(*s))
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
		case Game::AddMoves:				return "move:nappend";
		case Game::ExchangeMove:		return "move:exchange";
		case Game::AddVariation:		return "variation:new";
		case Game::AddVariations:		return "variation:new:n";
		case Game::ReplaceVariation:	return "variation:replace";
		case Game::TruncateVariation:	return "variation:truncate";
		case Game::FirstVariation:		return "variation:first";
		case Game::PromoteVariation:	return "variation:promote";
		case Game::RemoveVariation:	return "variation:remove";
		case Game::RemoveVariations:	return "variation:remove:n";
		case Game::MergeVariation:		return "variation:merge";
		case Game::NewMainline:			return "variation:mainline";
		case Game::InsertMoves:			return "variation:insert";
		case Game::ExchangeMoves:		return "variation:exchange";
		case Game::StripMoves:			return "strip:moves";
		case Game::StripAnnotations:	return "strip:annotations";
		case Game::StripMoveInfo:		return "strip:info";
		case Game::StripMarks:			return "strip:marks";
		case Game::StripComments:		return "strip:comments";
		case Game::StripVariations:	return "strip:variations";
		case Game::CopyComments:		return "copy:comments";
		case Game::MoveComments:		return "move:comments";
		case Game::Clear:					return "game:clear";
		case Game::MergeGame:			return "game:merge";
		case Game::Transpose:			return "game:transpose";
	}

	return 0;	// never reached
}


static int
stateToInt(load::State state)
{
	switch (state)
	{
		case load::None:			return  0;
		case load::Ok:				return  1;
		case load::Failed:		return -1;
		case load::Corrupted:	return -2;
	}

	return 0; // never reached
}


static unsigned
getMoveInfoTypes(char const* cmd, char const* subcmd, Tcl_Obj* moveInfo, unsigned& moveInfoTypes)
{
	Array elems = getElements(moveInfo);

	moveInfoTypes = 0;

	for (unsigned i = 0; i < elems.size(); ++i)
	{
		char const* type = asString(elems[i]);

		if (equal(type, "eval"))
			moveInfoTypes |= moveinfo::Evaluation;
		else if (equal(type, "clk"))
			moveInfoTypes |= moveinfo::Clock;
		else if (equal(type, "emt"))
			moveInfoTypes |= moveinfo::ElapsedTime;
		else if (equal(type, "ccsnt"))
			moveInfoTypes |= moveinfo::CorrSent;
		else if (equal(type, "video"))
			moveInfoTypes |= moveinfo::Video;
		else
			return error(cmd, subcmd, nullptr, "unknown move info type '%s'", type);
	}

	return TCL_OK;
}


static Tcl_Obj*
makePromotionList(Board const& board)
{
	Tcl_Obj* objs[64];

	unsigned n = 0;
	uint64_t promoted = board.promoted();

	while (promoted)
		objs[n++] = newObj(::db::board::lsbClear(promoted));

	return newObj(n, objs);
}


::db::move::Notation
tcl::game::notationFromObj(Tcl_Obj* obj)
{
	char const* moveStyle = asString(obj);

	if (equal(moveStyle, "can"))
		return move::CAN;
	else if (equal(moveStyle, "san"))
		return move::SAN;
	else if (equal(moveStyle, "lan"))
		return move::LAN;
	else if (equal(moveStyle, "gan"))
		return move::GAN;
	else if (equal(moveStyle, "man"))
		return move::MAN;
	else if (equal(moveStyle, "ran"))
		return move::RAN;
	else if (equal(moveStyle, "smi"))
		return move::Smith;
	else if (equal(moveStyle, "edn"))
		return move::EDN;
	else if (equal(moveStyle, "sdn"))
		return move::SDN;
	else if (equal(moveStyle, "cor"))
		return move::Numeric;
	else if (equal(moveStyle, "tel"))
		return move::Alphabetic;

	M_RAISE("unexpected move style '%s'", moveStyle);
	return move::SAN;
}


::db::move::Notation
tcl::game::notationFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	return notationFromObj(objectFromObj(objc, objv, index));
}


::db::variant::Type
tcl::game::variantFromObj(Tcl_Obj* obj)
{
	char const* variant = asString(obj);

	switch (::toupper(*variant))
	{
		case 'N': return ::db::variant::Normal;
		case 'B': return ::db::variant::Bughouse;
		case 'C': return ::db::variant::Crazyhouse;
		case 'T': return ::db::variant::ThreeCheck;
		case 'S': return ::db::variant::Suicide;
		case 'G': return ::db::variant::Giveaway;
		case 'L': return ::db::variant::Losers;
		case 'A': return ::db::variant::Antichess;
	}

	return ::db::variant::Undetermined;
}


::db::variant::Type
tcl::game::variantFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index)
{
	if (index < objc)
		return variantFromObj(objv[index]);

	return variant::Undetermined;
}


Tcl_Obj*
tcl::game::objFromVariant(::db::variant::Type variant)
{
	static mstl::vector<Tcl_Obj*> m_variants;

	if (size_t(variant) >= m_variants.size() || m_variants[variant] == 0)
	{
		char const* s = nullptr;

		switch (variant)
		{
			case ::db::variant::Normal:			s = "Normal"; break;
			case ::db::variant::Bughouse:			s = "Bughouse"; break;
			case ::db::variant::Crazyhouse:		s = "Crazyhouse"; break;
			case ::db::variant::ThreeCheck:		s = "ThreeCheck"; break;
			case ::db::variant::Suicide:			s = "Suicide"; break;
			case ::db::variant::Giveaway:			s = "Giveaway"; break;
			case ::db::variant::Losers:			s = "Losers"; break;
			case ::db::variant::Antichess:		s = "Antichess"; break;
			case ::db::variant::Undetermined:	s = "Undetermined"; break;
		}

		m_variants.resize(variant + 1, 0);
		m_variants[variant] = newObj(s);
		incrRef(m_variants[variant]);
	}

	return m_variants[variant];
}


namespace {

struct SingleProgress : public util::Progress
{
	SingleProgress() { setFrequency(1); }
	bool interrupted() override { return true; }
};


class Visitor : public edit::Visitor
{
public:

	typedef edit::Comment::VarPos VarPos;

	Visitor(move::Notation moveStyle)
		:m_objc(0)
		,m_moveStyle(moveStyle)
	{
		if (!m_action)
		{
			incrRef(m_action			= newObj("action"));
			incrRef(m_clear			= newObj("clear"));
			incrRef(m_insert			= newObj("insert"));
			incrRef(m_replace			= newObj("replace"));
			incrRef(m_remove			= newObj("remove"));
			incrRef(m_finish			= newObj("finish"));
			incrRef(m_header			= newObj("header"));
			incrRef(m_idn				= newObj("idn"));
			incrRef(m_eco				= newObj("eco"));
			incrRef(m_position		= newObj("position"));
			incrRef(m_opening			= newObj("opening"));
			incrRef(m_languages		= newObj("languages"));
			incrRef(m_ply				= newObj("ply"));
			incrRef(m_white			= newObj("white"));
			incrRef(m_black			= newObj("black"));
			incrRef(m_legal			= newObj("legal"));
			incrRef(m_diagram			= newObj("diagram"));
			incrRef(m_color			= newObj("color"));
			incrRef(m_board			= newObj("board"));
			incrRef(m_comment			= newObj("comment"));
			incrRef(m_annotation		= newObj("annotation"));
			incrRef(m_states			= newObj("states"));
			incrRef(m_marks			= newObj("marks"));
			incrRef(m_space			= newObj("space"));
			incrRef(m_break			= newObj("break"));
			incrRef(m_begin			= newObj("begin"));
			incrRef(m_end				= newObj("end"));
			incrRef(m_move				= newObj("move"));
			incrRef(m_start			= newObj("start"));
			incrRef(m_result			= newObj("result"));
			incrRef(m_checkmate		= newObj("checkmate"));
			incrRef(m_stalemate		= newObj("stalemate"));
			incrRef(m_threeChecks	= newObj("three-checks"));
			incrRef(m_material		= newObj("material"));
			incrRef(m_lessMaterial	= newObj("less-material"));
			incrRef(m_equalMaterial	= newObj("equal-material"));
			incrRef(m_bishops			= newObj("bishops"));
			incrRef(m_threefold		= newObj("threefold"));
			incrRef(m_fivefold		= newObj("fivefold"));
			incrRef(m_fifty			= newObj("fifty"));
			incrRef(m_mating			= newObj("nomating"));
			incrRef(m_empty			= newObj(""));
			incrRef(m_number			= newObj("["));
			incrRef(m_leave			= newObj("]"));
			incrRef(m_open				= newObj("("));
			incrRef(m_close			= newObj(")"));
			incrRef(m_close_fold		= newObj("*"));
			incrRef(m_fold				= newObj("+"));
			incrRef(m_preceding		= newObj("preceding"));
			incrRef(m_trailing		= newObj("trailing"));
			incrRef(m_before			= newObj("before"));
			incrRef(m_after			= newObj("after"));
			incrRef(m_finally			= newObj("finally"));
			incrRef(m_e					= newObj("e"));
			incrRef(m_s					= newObj("s"));
			incrRef(m_blank			= newObj(" "));
			incrRef(m_delim			= newObj("|"));
			incrRef(m_zero				= newObj(0));
		}

		incrRef(m_list = newObj());
	}

	~Visitor() throw()
	{
		decrRef(m_list);
	}

	void start(result::ID) override
	{
		addElement(m_list, m_start);
	}

	void finish(result::ID result, termination::State termination, color::ID toMove) override
	{
		Tcl_Obj* objv[4];
		Tcl_Obj* term = nullptr;

		switch (termination)
		{
			case termination::None:										term = m_empty; break;
			case termination::Checkmate:								term = m_checkmate; break;
			case termination::Stalemate:								term = m_stalemate; break;
			case termination::GotThreeChecks:						term = m_threeChecks; break;
			case termination::LostAllMaterial:						term = m_material; break;
			case termination::HavingLessMaterial:					term = m_lessMaterial; break;
			case termination::DrawnByStalemate:						term = m_equalMaterial; break;
			case termination::BishopsOfOppositeColor:				term = m_bishops; break;
			case termination::ThreefoldRepetition:					term = m_threefold; break;
			case termination::FivefoldRepetition:					term = m_fivefold; break;
			case termination::FiftyMoveRuleExceeded:				term = m_fifty; break;
			case termination::NeitherPlayerHasMatingMaterial:	term = m_mating; break;
			case termination::WhiteCannotWin:						term = m_white; break;
			case termination::BlackCannotWin:						term = m_black; break;
		}

		objv[0] = m_result;
		objv[1] = newObj(result::toString(result));
		objv[2] = newObj(color::printColor(toMove));
		objv[3] = term;

		addElement(m_list, objv);
	}

	void clear() override
	{
		Tcl_Obj* objv_1[2];

		objv_1[0] = m_action;
		objv_1[1] = newObj(1, &m_clear);

		addElement(m_list, objv_1);
	}

	void insert(unsigned level, edit::Key const& beforeKey) override
	{
		Tcl_Obj* objv_1[3];

		objv_1[0] = m_insert;
		objv_1[1] = newObj(level);
		objv_1[2] = newObj(beforeKey.id());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = newObj(objv_1);

		addElement(m_list, objv_2);
	}

	void replace(unsigned level, edit::Key const& startKey, edit::Key const& endKey) override
	{
		Tcl_Obj* objv_1[4];

		objv_1[0] = m_replace;
		objv_1[1] = newObj(level);
		objv_1[2] = newObj(startKey.id());
		objv_1[3] = newObj(endKey.id());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = newObj(objv_1);

		addElement(m_list, objv_2);
	}

	void remove(unsigned level, edit::Key const& startKey, edit::Key const& endKey) override
	{
		Tcl_Obj* objv_1[4];

		objv_1[0] = m_remove;
		objv_1[1] = newObj(level);
		objv_1[2] = newObj(startKey.id());
		objv_1[3] = newObj(endKey.id());

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = newObj(objv_1);

		addElement(m_list, objv_2);
	}

	void finish(unsigned level) override
	{
		Tcl_Obj* objv_1[2];

		objv_1[0] = m_finish;
		objv_1[1] = newObj(level);

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_action;
		objv_2[1] = newObj(objv_1);

		addElement(m_list, objv_2);
	}

	void opening(Board const& startBoard, variant::Type variant, uint16_t idn, Eco const& eco) override
	{
		EcoTable const& ecoTable = EcoTable::specimen(variant::toMainVariant(variant));
		EcoTable::Opening const& opening = ecoTable.getOpening(eco);
		Square handicap = idn == 0 ? startBoard.handicap() : sq::Null;
		mstl::string position;

		if (handicap != sq::Null)
			idn = variant::Standard;

		if (idn == 0)
			startBoard.toFen(position, variant);
		else if (variant::isShuffleChess(idn))
			shuffle::utf8::position(idn, position);
		else
			position = variant::ficsIdentifier(idn);

		Tcl_Obj* objv_1[2];

		objv_1[0] = m_idn;
		objv_1[1] = newObj(idn);

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_eco;
		objv_2[1] = newObj(eco.asShortString());

		Tcl_Obj* objv_3[4];
		unsigned objc_3 = handicap == sq::Null ? 2 : 4;

		objv_3[0] = m_position;
		objv_3[1] = newObj(position);

		if (objc_3 == 4)
		{
			piece::Type piece = piece::type(Board::standardBoard(variant::Normal).pieceAt(handicap));
			objv_3[2] = newObj(sq::printAlgebraic(handicap));
			objv_3[3] = newObj(piece::utf8::asString(piece));
		}

		Tcl_Obj* objv_4[EcoTable::Num_Name_Parts + 1];
		unsigned objc_4 = 3;

		objv_4[0] = m_opening;
		objv_4[1] = newObj(opening.part[0]);
		objv_4[2] = newObj(opening.part[1]);

		for ( ; objc_4 <= EcoTable::Num_Name_Parts && opening.part[objc_4 - 1].size(); ++objc_4)
			objv_4[objc_4] = newObj(opening.part[objc_4 - 1]);

		Tcl_Obj* objv_5[4];

		objv_5[0] = newObj(objv_1);
		objv_5[1] = newObj(objv_2);
		objv_5[2] = newObj(objc_3, objv_3);
		objv_5[3] = newObj(objc_4, objv_4);

		Tcl_Obj* objv_6[2];

		objv_6[0] = m_header;
		objv_6[1] = newObj(objv_5);

		addElement(m_list, objv_6);
	}

	void languages(LanguageSet const& languages) override
	{
		Tcl_Obj*  objv_1[languages.size()];
		Tcl_Obj** p(&objv_1[0]);

		for (LanguageSet::const_iterator i = languages.begin(), e = languages.end(); i != e; ++i)
			*p++ = newObj(i->first);

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_languages;
		objv_2[1] = newObj(p - objv_1, objv_1);

		addElement(m_list, objv_2);
	}

	void move(unsigned moveNo, Move const& move) override
	{
		mstl::string san;
		move.printForDisplay(san, m_moveStyle);

		Tcl_Obj* objv_1[4];

		objv_1[0] = newObj(moveNo);
		objv_1[1] = color::isWhite(move.color()) ? m_white : m_black;
		objv_1[2] = newObj(san);
		objv_1[3] = newObj(move.isLegal() || move.isEmpty()); // hack

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_ply;
		objv_2[1] = newObj(objv_1);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv_2);
	}

	void position(::db::Board const& board, color::ID fromColor) override
	{
		mstl::string position = tcl::board::toBoard(board);

		Tcl_Obj* objv_1[2];

		objv_1[0] = m_color;
		objv_1[1] = color::isWhite(fromColor) ? m_white : m_black;

		Tcl_Obj* objv_2[2];

		objv_2[0] = m_board;
		objv_2[1] = newObj(position);

		M_ASSERT(m_objc + 1 < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv_1);
		m_objv[m_objc++] = newObj(objv_2);
	}

	void comment(move::Position position, VarPos varPos, Comment const& comment) override
	{
		Tcl_Obj* objv[3];

		objv[0] = m_comment;
		switch (varPos)
		{
			case edit::Comment::AtStart:	objv[1] = m_preceding; break;
			case edit::Comment::AtEnd:		objv[1] = m_trailing; break;
			case edit::Comment::Inside:	objv[1] = (position == move::Ante) ? m_before: m_after; break;
			case edit::Comment::Finally:	objv[1] = m_finally; break;
		}
		objv[2] = newObj(comment.content());

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	}

	void annotation(Annotation const& annotation, edit::Annotation::DisplayType type) override
	{
		if (type == edit::Annotation::Textual)
		{
			M_ASSERT(!annotation.containsUsualNags());
			M_ASSERT(annotation.countPrefixNags() == 0);

			mstl::string textual;

			annotation.infix(textual);
			annotation.suffix(textual);

			Tcl_Obj* objv[2];

			objv[0] = m_annotation;
			objv[1] = newObj(textual);

			M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
			m_objv[m_objc++] = newObj(objv);
		}
		else
		{
			mstl::string	prefix, infix, suffix, textual;
			Annotation		usual, unusual;

			usual.setUsualNags(annotation);
			unusual.setUnusualNags(annotation);

			usual.prefix(prefix);
			usual.infix(infix);
			usual.suffix(suffix);
			unusual.all(textual);

			Tcl_Obj* objv[5];

			objv[0] = m_annotation;
			objv[1] = newObj(prefix);
			objv[2] = newObj(infix);
			objv[3] = newObj(suffix);
			objv[4] = newObj(textual);

			M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
			m_objv[m_objc++] = newObj(objv);
		}
	}

	void states(bool threefoldRepetition, bool fivefoldRepetition, bool fiftyMoveRule) override
	{
		mstl::string states;

		if (fivefoldRepetition)
			states += '5';
		if (threefoldRepetition)
			states += '3';
		if (fiftyMoveRule)
			states += 'f';

		Tcl_Obj* objv[2];

		objv[0] = m_states;
		objv[1] = newObj(states);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	};

	void marks(bool hasMarks) override
	{
		Tcl_Obj* objv[2];

		objv[0] = m_marks;
		objv[1] = newObj(hasMarks);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	}

	void number(mstl::string const& number, bool isFirstVar) override
	{
		Tcl_Obj* objv[4];

		objv[0] = m_space;
		objv[1] = m_number;
		objv[2] = newObj(isFirstVar);
		objv[3] = newObj(number);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	}

	void space(Bracket bracket, unsigned number, unsigned count) override
	{
		Tcl_Obj* objv[4];

		objv[0] = m_space;

		switch (bracket)
		{
			case edit::Node::Open:			objv[1] = m_open; break;
			case edit::Node::Close:			objv[1] = m_close; break;
			case edit::Node::CloseFold:	objv[1] = m_close_fold; break;
			case edit::Node::Fold:			objv[1] = m_fold; break;
			case edit::Node::Empty:			objv[1] = m_e; break;
			case edit::Node::Start:			objv[1] = m_s; break;
			case edit::Node::Blank:			objv[1] = m_blank; break;
			case edit::Node::Delimiter:	objv[1] = m_delim; break;
			case edit::Node::End:			objv[1] = m_leave; break;
		}

		objv[2] = newObj(count);
		objv[3] = newObj(number);
		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	}

	void linebreak(unsigned level) override
	{
		Tcl_Obj* objv[2];

		objv[0] = m_break;
		objv[1] = newObj(level);

		M_ASSERT(m_objc < U_NUMBER_OF(m_objv));
		m_objv[m_objc++] = newObj(objv);
	}

	void startVariation(edit::Key const& key, edit::Key const& startKey, edit::Key const& endKey) override
	{
		Tcl_Obj* objv[4];

		objv[0] = m_begin;
		objv[1] = newObj(key.id());
		objv[2] = newObj(startKey.id());
		objv[3] = newObj(startKey.level());

		addElement(m_list, objv);
	}

	void endVariation(edit::Key const& key, edit::Key const& startKey, edit::Key const& endKey) override
	{
		Tcl_Obj* objv[4];

		objv[0] = m_end;
		objv[1] = newObj(key.id());
		objv[2] = newObj(endKey.id());
		objv[3] = newObj(startKey.level());

		addElement(m_list, objv);
	}

	void startMove(edit::Key const& key) override
	{
	}

	void endMove(edit::Key const& key) override
	{
		Tcl_Obj* objv[3];

		objv[0] = m_move;
		objv[1] = newObj(key.id());
		objv[2] = newObj(m_objc, m_objv);

		addElement(m_list, objv);
		m_objc = 0;
	}

	void startDiagram(edit::Key const& key) override
	{
	}

	void endDiagram(edit::Key const& key) override
	{
		Tcl_Obj* objv[3];

		objv[0] = m_diagram;
		objv[1] = newObj(key.id());
		objv[2] = newObj(m_objc, m_objv);

		addElement(m_list, objv);
		m_objc = 0;
	}

	Tcl_Obj*			m_list;
	Tcl_Obj*			m_objv[10];
	unsigned			m_objc;
	move::Notation	m_moveStyle;

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
	static Tcl_Obj* m_states;
	static Tcl_Obj* m_marks;
	static Tcl_Obj* m_space;
	static Tcl_Obj* m_break;
	static Tcl_Obj* m_begin;
	static Tcl_Obj* m_end;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_start;
	static Tcl_Obj* m_result;
	static Tcl_Obj* m_checkmate;
	static Tcl_Obj* m_stalemate;
	static Tcl_Obj* m_threeChecks;
	static Tcl_Obj* m_material;
	static Tcl_Obj* m_lessMaterial;
	static Tcl_Obj* m_equalMaterial;
	static Tcl_Obj* m_bishops;
	static Tcl_Obj* m_threefold;
	static Tcl_Obj* m_fivefold;
	static Tcl_Obj* m_fifty;
	static Tcl_Obj* m_mating;
	static Tcl_Obj* m_empty;
	static Tcl_Obj* m_number;
	static Tcl_Obj* m_leave;
	static Tcl_Obj* m_open;
	static Tcl_Obj* m_close;
	static Tcl_Obj* m_close_fold;
	static Tcl_Obj* m_fold;
	static Tcl_Obj* m_blank;
	static Tcl_Obj* m_delim;
	static Tcl_Obj* m_zero;
	static Tcl_Obj* m_preceding;
	static Tcl_Obj* m_trailing;
	static Tcl_Obj* m_before;
	static Tcl_Obj* m_after;
	static Tcl_Obj* m_finally;
	static Tcl_Obj* m_e;
	static Tcl_Obj* m_s;
};


Tcl_Obj* Visitor::m_action				= nullptr;
Tcl_Obj* Visitor::m_clear				= nullptr;
Tcl_Obj* Visitor::m_insert				= nullptr;
Tcl_Obj* Visitor::m_replace			= nullptr;
Tcl_Obj* Visitor::m_remove				= nullptr;
Tcl_Obj* Visitor::m_finish				= nullptr;
Tcl_Obj* Visitor::m_header				= nullptr;
Tcl_Obj* Visitor::m_idn					= nullptr;
Tcl_Obj* Visitor::m_eco					= nullptr;
Tcl_Obj* Visitor::m_position			= nullptr;
Tcl_Obj* Visitor::m_opening			= nullptr;
Tcl_Obj* Visitor::m_languages			= nullptr;
Tcl_Obj* Visitor::m_ply					= nullptr;
Tcl_Obj* Visitor::m_white				= nullptr;
Tcl_Obj* Visitor::m_black				= nullptr;
Tcl_Obj* Visitor::m_legal				= nullptr;
Tcl_Obj* Visitor::m_diagram			= nullptr;
Tcl_Obj* Visitor::m_color				= nullptr;
Tcl_Obj* Visitor::m_board				= nullptr;
Tcl_Obj* Visitor::m_comment			= nullptr;
Tcl_Obj* Visitor::m_annotation		= nullptr;
Tcl_Obj* Visitor::m_states				= nullptr;
Tcl_Obj* Visitor::m_marks				= nullptr;
Tcl_Obj* Visitor::m_space				= nullptr;
Tcl_Obj* Visitor::m_break				= nullptr;
Tcl_Obj* Visitor::m_begin				= nullptr;
Tcl_Obj* Visitor::m_end					= nullptr;
Tcl_Obj* Visitor::m_move				= nullptr;
Tcl_Obj* Visitor::m_start				= nullptr;
Tcl_Obj* Visitor::m_result				= nullptr;
Tcl_Obj* Visitor::m_checkmate			= nullptr;
Tcl_Obj* Visitor::m_stalemate			= nullptr;
Tcl_Obj* Visitor::m_threeChecks		= nullptr;
Tcl_Obj* Visitor::m_material			= nullptr;
Tcl_Obj* Visitor::m_lessMaterial		= nullptr;
Tcl_Obj* Visitor::m_equalMaterial	= nullptr;
Tcl_Obj* Visitor::m_bishops			= nullptr;
Tcl_Obj* Visitor::m_threefold			= nullptr;
Tcl_Obj* Visitor::m_fivefold			= nullptr;
Tcl_Obj* Visitor::m_fifty				= nullptr;
Tcl_Obj* Visitor::m_mating				= nullptr;
Tcl_Obj* Visitor::m_empty				= nullptr;
Tcl_Obj* Visitor::m_number				= nullptr;
Tcl_Obj* Visitor::m_leave				= nullptr;
Tcl_Obj* Visitor::m_open				= nullptr;
Tcl_Obj* Visitor::m_close				= nullptr;
Tcl_Obj* Visitor::m_close_fold		= nullptr;
Tcl_Obj* Visitor::m_fold				= nullptr;
Tcl_Obj* Visitor::m_blank				= nullptr;
Tcl_Obj* Visitor::m_delim				= nullptr;
Tcl_Obj* Visitor::m_zero				= nullptr;
Tcl_Obj* Visitor::m_preceding			= nullptr;
Tcl_Obj* Visitor::m_trailing			= nullptr;
Tcl_Obj* Visitor::m_before				= nullptr;
Tcl_Obj* Visitor::m_after				= nullptr;
Tcl_Obj* Visitor::m_finally			= nullptr;
Tcl_Obj* Visitor::m_e					= nullptr;
Tcl_Obj* Visitor::m_s					= nullptr;


class MySubscriber : public Game::Subscriber
{
public:

	typedef mstl::vector<Tcl_Obj*> CmdList;

	CmdList	m_board;
	CmdList	m_tree;
	CmdList	m_opening;
	Tcl_Obj*	m_pgn;
	Tcl_Obj*	m_state;
	Tcl_Obj*	m_position;
	Tcl_Obj*	m_onlyThis;
	bool		m_mainlineOnly;
	unsigned	m_count;

	static Tcl_Obj* m_action;
	static Tcl_Obj* m_set;
	static Tcl_Obj* m_goto;
	static Tcl_Obj* m_move;
	static Tcl_Obj* m_marks;
	static Tcl_Obj* m_merge;
	static Tcl_Obj* m_true;
	static Tcl_Obj* m_false;

	MySubscriber(Tcl_Obj* position)
		:m_pgn(nullptr)
		,m_state(nullptr)
		,m_position(position)
		,m_mainlineOnly(false)
		,m_count(0)
	{
		if (!m_action)
		{
			incrRef(m_action	= newObj("action"));
			incrRef(m_set		= newObj("set"));
			incrRef(m_goto		= newObj("goto"));
			incrRef(m_move		= newObj("move"));
			incrRef(m_marks	= newObj("marks"));
			incrRef(m_merge	= newObj("merge"));

			incrRef(m_true		= newObj(true));
			incrRef(m_false	= newObj(false));

			pos::resetMoveCache();
		}

		incrRef(m_position);
	}

	~MySubscriber() throw()
	{
		for (unsigned i = 0; i < m_board.size(); ++i)
			decrRef(m_board[i]);
		for (unsigned i = 0; i < m_tree.size(); ++i)
			decrRef(m_tree[i]);
		for (unsigned i = 0; i < m_opening.size(); ++i)
			decrRef(m_opening[i]);
		decrRef(m_pgn);
		decrRef(m_state);
	}

	void setBoardCmd(Tcl_Obj* obj)	{ m_board.push_back(incrRef(obj)); m_count += 1; }
	void setTreeCmd(Tcl_Obj* obj)		{ m_tree.push_back(incrRef(obj)); m_count += 1; }
	void setOpeningCmd(Tcl_Obj* obj)	{ m_opening.push_back(incrRef(obj)); m_count += 1; }

	void setPgnCmd(Tcl_Obj* obj, bool mainlineOnly = false)
	{
		if (!m_pgn)
		{
			incrRef(m_pgn = obj);
			m_mainlineOnly = mainlineOnly;
			m_count += 1;
		}
	}

	void setStateCmd(Tcl_Obj* obj)
	{
		if (!m_state)
		{
			incrRef(m_state = obj);
			m_count += 1;
		}
	}

	unsigned unsetBoardCmd(Tcl_Obj* obj)	{ return unsetCmd(m_board, obj); }
	unsigned unsetTreeCmd(Tcl_Obj* obj)		{ return unsetCmd(m_tree, obj); }
	unsigned unsetOpeningCmd(Tcl_Obj* obj)	{ return unsetCmd(m_opening, obj); }
	unsigned unsetPgnCmd(Tcl_Obj* obj)		{ return unsetCmd(m_pgn, obj); }
	unsigned unsetStateCmd(Tcl_Obj* obj)	{ return unsetCmd(m_state, obj); }

	bool mainlineOnly() override { return m_mainlineOnly; }

	void stateChanged(bool locked) override
	{
		if (m_state)
			invoke(__func__, m_state, m_position, locked ? m_true : m_false, nullptr);
	}

	void updateOpening() override
	{
		for (unsigned i = 0; i < m_opening.size(); ++i)
			invoke(__func__, m_opening[i], m_position, nullptr);
	}

	void updateEditor(edit::Root const* node, move::Notation moveStyle) override
	{
		M_ASSERT(node);

		if (m_pgn)
		{
			Visitor visitor(moveStyle);
			node->visit(visitor);
			invoke(__func__, m_pgn, m_position, visitor.m_list, nullptr);
		}
	}

	void updateEditor(Game::DiffList const& nodes,
							TagSet const& tags,
							move::Notation moveStyle,
							termination::State termination,
							color::ID toMove) override
	{
		if (m_pgn)
		{
			Visitor visitor(moveStyle);
			edit::Node::visit(visitor, nodes, tags, termination, toMove);
			invoke(__func__, m_pgn, m_position, visitor.m_list, nullptr);
		}
	}

	void updateMergeResults(Game::MergeResults const& mergeResults) override
	{
		if (m_pgn)
		{
			int objc = 2*mergeResults.size();
			Tcl_Obj* objv[objc];

			for (unsigned i = 0; i < mergeResults.size(); ++i)
			{
				objv[mstl::mul2(i)] = newObj(mergeResults[i].first.id());
				objv[mstl::mul2(i) + 1] = newObj(mergeResults[i].second.id());
			}

			Tcl_Obj* objv2[2];
			Tcl_Obj* objv3[1];

			objv2[0] = m_merge;
			objv2[1] = newObj(objc, objv);
			objv3[0] = newObj(objv2);

			invoke(__func__, m_pgn, m_position, newObj(objv3), nullptr);
		}
	}

	void boardSetup(Board const& board, variant::Type variant) override
	{
		// TODO: realize that the board contains the variant, then remove the parameter 'variant'
		pos::resetMoveCache();

		if (!m_board.empty())
		{
			mstl::string pos;
			pos::dumpBoard(board, pos);

			Tcl_Obj* promoted;
			Tcl_Obj* b = newObj(pos);

			promoted = (variant == variant::Crazyhouse) ? ::makePromotionList(board) : Tcl_NewObj();

			incrRef(b);
			incrRef(promoted);

			for (unsigned i = 0; i < m_board.size(); ++i)
				invoke(__func__, m_board[i], m_position, m_set, b, promoted, nullptr);

			decrRef(b);
			decrRef(promoted);
		}

		for (unsigned i = 0; i < m_tree.size(); ++i)
			invoke(__func__, m_tree[i], m_position, nullptr);
	}

	void boardMove(Board const& board, Move const& move, bool forward) override
	{
		if (!m_board.empty())
		{
			char pieceFrom		= piece::print(move.piece());
			char pieceHolding	= '.';
			char pieceCap;
			char pieceTo;

			if (move.isCapture())
				pieceCap = piece::print(move.capturedPiece());
			else
				pieceCap = '.';

			if (move.isPromotion() || move.isPieceDrop())
				pieceTo = piece::print(move.promotedPiece());
			else
				pieceTo = piece::print(move.piece());

			if (forward && move.isEnPassant())
				pieceCap = '.';

			//if (board.variant() == variant::Crazyhouse) // not needed
			{
				if (!forward && board.isPromotedPiece(move.to()))
					pieceHolding = piece::print(piece::piece(piece::Pawn, move.color()));
				else if (move.isCapture())
					pieceHolding = piece::print(piece::piece(move.captured(), move.color()));
			}

			int squareCap = move.isCapture() ? move.capturedSquare() : -1;

			Tcl_Obj* objv[11];

			objv[0] = newObj(color::isWhite(move.color()) ? "w" : "b", 1);
			objv[3] = newObj(squareCap);
			objv[4] = newObj(&pieceFrom, 1);
			objv[5] = newObj(&pieceTo, 1);
			objv[6] = newObj(&pieceCap, 1);
			objv[7] = newObj(&pieceHolding, 1);

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

				objv[1] = newObj(move.castlingKingFrom());
				objv[2] = newObj(move.castlingKingTo());
				objv[8] = newObj(rookFrom);
				objv[9] = newObj(rookTo);
			}
			else
			{
				objv[1] = newObj(move.from());
				objv[2] = newObj(move.to());
				objv[8] = newObj(-1);
				objv[9] = newObj(-1);
			}

			if (!forward)
			{
				mstl::swap(objv[1], objv[2]);
				mstl::swap(objv[4], objv[5]);
				mstl::swap(objv[8], objv[9]);
			}

			objv[10] = newObj(forward);

			Tcl_Obj* list = newObj(objv);
			Tcl_Obj* promoted = newObj();

			incrRef(list);
			incrRef(promoted);

			for (unsigned i = 0; i < m_board.size(); ++i)
				invoke(__func__, m_board[i], m_position, m_move, list, promoted, nullptr);

			decrRef(list);
			decrRef(promoted);
		}

		pos::resetMoveCache();

		for (unsigned i = 0; i < m_tree.size(); ++i)
			invoke(__func__, m_tree[i], m_position, nullptr);
	}

	void updateMarks(mstl::string const& marks) override
	{
		if (m_pgn)
		{
			Tcl_Obj* objv_1[2];

			objv_1[0] = m_marks;
			objv_1[1] = newObj(marks);

			Tcl_Obj* objv_2[2];

			objv_2[0] = m_action;
			objv_2[1] = newObj(objv_1);

			Tcl_Obj* objv_3[1] = { newObj(objv_2) };

			invoke(__func__, m_pgn, m_position, newObj(objv_3), nullptr);
		}
	}

	void gotoMove(mstl::string const& key, mstl::string const& succKey) override
	{
		pos::resetMoveCache();

		if (m_pgn)
		{
			Tcl_Obj* objv_1[3];

			objv_1[0] = m_goto;
			objv_1[1] = newObj(key);
			objv_1[2] = newObj(succKey);

			Tcl_Obj* objv_2[2];

			objv_2[0] = m_action;
			objv_2[1] = newObj(objv_1);

			Tcl_Obj* objv_3[1] = { newObj(objv_2) };

			invoke(__func__, m_pgn, m_position, newObj(objv_3), nullptr);
		}
	}

private:

	unsigned unsetCmd(Tcl_Obj*& var, Tcl_Obj* obj)
	{
		if (equal(var, obj))
		{
			M_ASSERT(m_count > 0);
			zero(var);
			m_count -= 1;
		}
		return m_count;
	}

	unsigned unsetCmd(CmdList& list, Tcl_Obj* obj)
	{
		for (CmdList::iterator i = list.begin(); i != list.end(); ++i)
		{
			if (equal(*i, obj))
			{
				M_ASSERT(m_count > 0);
				decrRef(*i);
				list.erase(i);
				return --m_count;
			}
		}
		return m_count;
	}
};

Tcl_Obj* MySubscriber::m_action	= 0;
Tcl_Obj* MySubscriber::m_set		= 0;
Tcl_Obj* MySubscriber::m_goto	= 0;
Tcl_Obj* MySubscriber::m_move	= 0;
Tcl_Obj* MySubscriber::m_marks	= 0;
Tcl_Obj* MySubscriber::m_merge	= 0;
Tcl_Obj* MySubscriber::m_true	= 0;
Tcl_Obj* MySubscriber::m_false	= 0;

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
							nullptr, nullptr,
							"cannot convert to list object: %s",
							asString(taglist));
	}
	if (objc % 2)
		return error("save/update", nullptr, nullptr, "odd number of elements in tag list");

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
cmdEcoTable(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	move::Notation	notation	= move::SAN;
	EcoTable::Mode mode = EcoTable::SinglePly;

	for ( ; objc > 2; objc -= 2)
	{
		char const* option	= asString(objv[objc - 2]);
		Tcl_Obj*		value		= objv[objc - 1];

		if (equal(option, "-notation"))
			notation = game::notationFromObj(value);
		else if (equal(option, "-mode"))
			mode = equal(value, "compact") ? EcoTable::Compact : EcoTable::SinglePly;
		else
			return error(CmdEcoTable, nullptr, nullptr, "unknown option %s", option);
	}

	if (Scidb->haveCurrentGame())
	{
		Game const& game = Scidb->game();
		Line const& line = game.openingLine();

		EcoTable const& ecoTable = EcoTable::specimen(variant::toMainVariant(game.variant()));
		EcoTable::Openings opList;

		ecoTable.getOpenings(game.startBoard(), line, opList, mode);
		M_ASSERT(line.length >= opList.size());

		Tcl_Obj* result = newObj();

		for (EcoTable::Openings::const_iterator i = opList.begin(); i != opList.end(); ++i)
		{
			mstl::string str;

			if (mode == EcoTable::Compact)
			{
				line.print(	str,
								game.startBoard(),
								game.variant(),
								0,
								i->ply + 1,
								i->ply + 1,
								notation,
								::db::protocol::Scidb,
								::db::encoding::Utf8);
			}
			else
			{
				line.printMove(str,
									game.startBoard(),
									game.variant(),
									i->ply,
									notation,
									::db::protocol::Scidb,
									::db::encoding::Utf8);
			}

			Tcl_Obj* parts[EcoTable::Num_Name_Parts];

			for (unsigned k = 0; k < EcoTable::Num_Name_Parts; ++k)
				parts[k] = newObj(i->opening.part[k]);

			Tcl_Obj* objs[4] =
			{
				newObj(str), newObj(i->eco.asShortString()), newObj(i->eco.code()), newObj(parts)
			};
			addElement(result, objs);
		}

		setResult(result);
	}

	return TCL_OK;
}


static int
cmdDump(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*		database	= stringFromObj(objc, objv, 1);
	variant::Type	variant	= ::tcl::game::variantFromObj(objc, objv, 2);
	int				viewNo	= intFromObj(objc, objv, 3);
	unsigned			number	= unsignedFromObj(objc, objv, 4);
	mstl::string	fen;

	if (objc > 5)
		fen = stringFromObj(objc, objv, 5);

	View const& view = Scidb->cursor(database, variant).view(viewNo);

	if (objc > 6)
	{
		typedef View::StringList StringList;

		StringList result, positions;

		unsigned		split = unsignedFromObj(objc, objv, 6);
		load::State	state = view.dumpGame(number, split, fen, result, positions).first;

		for (unsigned i = 0; i < positions.size(); ++i)
			pos::dumpFen(positions[i], variant, positions[i]);

		Tcl_Obj* objv[mstl::mul2(result.size()) + 1];

		objv[0] = newObj(::stateToInt(state));

		for (unsigned i = 0; i < result.size(); ++i)
		{
			objv[mstl::mul2(i) + 1] = newObj(result[i]);
			objv[mstl::mul2(i) + 2] = newObj(positions[i]);
		}

		setResult(mstl::mul2(result.size()) + 1, objv);
	}
	else
	{
		mstl::string result;

		load::State state = view.dumpGame(number, fen, result).first;

		Tcl_Obj* objv[2] = { newObj(::stateToInt(state)), newObj(result) };
		setResult(objv);
	}

	return TCL_OK;
}


static int
cmdLoad(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int view = -1;

	while (objc > 2 && *asString(objv[objc - 2]) == '-')
	{
		char const* option = asString(objv[objc - 2]);

		if (equal(option, "-view"))
		{
			view = intFromObj(objc, objv, objc - 1);
			objc -= 2;
		}
		else
		{
			return error(::CmdSubscribe, nullptr, nullptr, "unexpected option '%s'", option);
		}
	}

	unsigned			position	= unsignedFromObj(objc, objv, 1);
	char const*		database	= stringFromObj(objc, objv, 2);
	variant::Type	variant	= tcl::game::variantFromObj(objc, objv, 3);
	unsigned			number	= unsignedFromObj(objc, objv, 4);
	mstl::string	fen;

	mstl::string const* pfen = nullptr;

	if (objc >= 6)
	{
		fen.assign(stringFromObj(objc, objv, 5));
		if (!fen.empty())
			pfen = &fen;
	}

	setResult(::stateToInt(scidb->loadGame(position, scidb->cursor(database, variant), number, pfen)));

	if (view >= 0)
		scidb->bindGameToView(position, view, Application::DontUpdateGameInfo);

	return TCL_OK;
}


static int
cmdReload(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = objc == 1 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	setResult(::stateToInt(scidb->loadGame(position)));
	return TCL_OK;
}


static int
cmdModified(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool flag = true;
	bool irreversible = false;

	while (objc > 3 && *asString(objv[objc - 2]) == '-')
	{
		char const* option = stringFromObj(objc, objv, objc - 2);

		if (equal(option, "-irreversible"))
			irreversible = boolFromObj(objc, objv, objc - 1);
		else
			return error(::CmdSubscribe, nullptr, nullptr, "unexpected option '%s'", option);

		objc -= 2;
	}

	if (objc > 2)
		flag = boolFromObj(objc, objv, 2);

	Game& game = scidb->game(unsignedFromObj(objc, objv, 1));

	if (irreversible)
		game.setIsIrreversible(flag);
	else
		game.setIsModified(flag);

	return TCL_OK;
}


static int
cmdMove(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->game().addMove(stringFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdValid(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Game const& game = Scidb->game();
	mstl::string san(stringFromObj(objc, objv, 1));
	setResult(bool(game.currentBoard().parseMove(san, game.variant(), move::MustBeUnambiguous)));
	return TCL_OK;
}


static int
cmdVariant(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(::tcl::tree::variantToString(Scidb->game().variant()));
	return TCL_OK;
}


static int
cmdNew(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned view = unsignedFromObj(objc, objv, 1);
	::db::variant::Type type = ::db::variant::Normal;

	if (objc > 2)
		type = tcl::game::variantFromObj(objv[2]);

	if (type == variant::Antichess)
		type = variant::Suicide;

	scidb->newGame(view, type);
	return TCL_OK;
}


static int
cmdSwitch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = intFromObj(objc, objv, 1);

	if (position == Application::InvalidPosition)
		position = Scidb->currentPosition();

	Application::ReferenceGames updateReferenceGames = Application::DontUpdateReferenceGames;

	if (position <= 9)
		updateReferenceGames = Application::UpdateReferenceGames;

	scidb->switchGame(position, updateReferenceGames);
	return TCL_OK;
}


static int
cmdRelease(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position	= unsignedFromObj(objc, objv, 1);
	scidb->releaseGame(position);
	return TCL_OK;
}


static int
cmdSwap(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->swapGames(unsignedFromObj(objc, objv, 1), unsignedFromObj(objc, objv, 2));
	return TCL_OK;
}


static int
cmdSwapPositions(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->swapGamePositions(unsignedFromObj(objc, objv, 1), unsignedFromObj(objc, objv, 2));
	return TCL_OK;
}


static int
cmdInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = intFromObj(objc, objv, 1);

	return tcl::db::getGameInfo(	Scidb->database(position),
											Scidb->gameIndex(position),
											tcl::db::Ratings(rating::Elo, rating::Elo),
											move::SAN);
}


static int
cmdLayout(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned	position	= unsignedFromObj(objc, objv, 1);
	Game&		game		= scidb->game(position);

	game.updateSubscriber(	Game::UpdatePgn
								 | Game::UpdateOpening
								 | Game::UpdateLanguageSet
								 | Game::UpdateIllegalMoves);

	return TCL_OK;
}


static int
cmdSubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*		what				= stringFromObj(objc, objv, 1);
	unsigned			position			= unsignedFromObj(objc, objv, 2);
	bool				mainlineOnly	= false;
	Game&				game				= scidb->game(position);
	MySubscriber*	subscriber		= static_cast<MySubscriber*>(game.subscriber().get());
	Tcl_Obj*			arg				= objectFromObj(objc, objv, 3);

	if (!subscriber)
		game.setSubscriber(Game::SubscriberP(subscriber = new MySubscriber(objv[2])));

	if (equal(what, "pgn") && objc >= 5)
		mainlineOnly = asBoolean(objv[4]);

	if (equal(what, "board"))
		subscriber->setBoardCmd(arg);
	else if (equal(what, "tree"))
		subscriber->setTreeCmd(arg);
	else if (equal(what, "state"))
		subscriber->setStateCmd(arg);
	else if (equal(what, "pgn"))
		subscriber->setPgnCmd(arg, mainlineOnly);
	else if (equal(what, "opening"))
		subscriber->setOpeningCmd(arg);
	else
		return error(::CmdSubscribe, nullptr, nullptr, "unexpected argument %s", what);

	return TCL_OK;
}


static int
cmdUnsubscribe(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned	position = unsignedFromObj(objc, objv, 2);

	if (!Scidb->containsGameAt(position))
		return TCL_OK;
 
	char const*	what	= stringFromObj(objc, objv, 1);
	Game&			game	= scidb->game(position);
	Tcl_Obj*		arg	= objectFromObj(objc, objv, 3);

	MySubscriber* subscriber = static_cast<MySubscriber*>(game.subscriber().get());

	if (!subscriber)
		return error(::CmdUnsubscribe, nullptr, nullptr, "cannot unsubscribe");
	
	bool count;

	if (equal(what, "board"))
		count = subscriber->unsetBoardCmd(arg);
	else if (equal(what, "tree"))
		count = subscriber->unsetTreeCmd(arg);
	else if (equal(what, "state"))
		count = subscriber->unsetStateCmd(arg);
	else if (equal(what, "pgn"))
		count = subscriber->unsetPgnCmd(arg);
	else if (equal(what, "opening"))
		count = subscriber->unsetOpeningCmd(arg);
	else
		return error(::CmdUnsubscribe, nullptr, nullptr, "unexpected argument %s", what);
	
	if (count == 0)
		game.releaseSubscriber();

	return TCL_OK;
}


static int
cmdRefresh(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = objc > 1 ? unsignedFromObj(objc, objv, 1) : Application::InvalidPosition;

	if (Scidb->containsGameAt(position))
	{
		bool immediate = false;

		if (objc >= 2)
		{
			char const* option = stringFromObj(objc, objv, objc - 1);

			if (equal(option, "-immediate"))
			{
				immediate = true;
				--objc;
			}
		}

		scidb->refreshGame(position, immediate);
	}

	return TCL_OK;
}


static int
cmdTranspose(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool	force	= boolFromObj(objc, objv, 1);
	Game&	game	= scidb->game();

	setResult(game.transpose(force ? Game::TruncateIfNeccessary : Game::OnlyIfRemainsConsistent));
	game.clearUndo();

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

	Game& game = scidb->game(position);

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

		case 't': // trykey
		{
			char const* s = stringFromObj(objc, objv, index + 1);
			if (::db::edit::Key::isValid(s))
			{
				::db::edit::Key key(s);
				if (game.isValidKey(key))
					game.goTo(key);
			}
			break;
		}

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

	scidb->game(position).goTo(key);
	return TCL_OK;
}


static int
cmdPosition(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"atStart?", "atEnd?", "isMainline?", "key", "startKey", "forward", "backward", 0
	};
	static char const* args[] =
	{
		"?<position>?", "?<position>?", "?<position>?", "?<position>?",
		"?<position>?", "?<position>?", "?<position>?", 0
	};
	enum { Cmd_AtStart, Cmd_AtEnd, Cmd_IsMainline, Cmd_Key, Cmd_StartKey, Cmd_Forward, Cmd_Backward };

	if (objc < 2)
		return usage(::CmdPosition, nullptr, nullptr, subcommands, args);

	int position	= objc < 3 ? -1 : intFromObj(objc, objv, 1);
	int index		= tcl::uniqueMatchObj(objv[objc < 3 ? 1 : 2], subcommands);

	switch (index)
	{
		case Cmd_AtStart:
			setResult(Scidb->game(position).atLineStart());
			break;

		case Cmd_AtEnd:
			setResult(Scidb->game(position).atLineEnd());
			break;

		case Cmd_IsMainline:
			setResult(Scidb->game(position).isMainline());
			break;

		case Cmd_Key:
			setResult(Scidb->game(position).currentKey().id());
			break;

		case Cmd_StartKey:
			setResult(Scidb->game(position).startKey());
			break;

		case Cmd_Forward:
			scidb->game(position).forward();
			break;

		case Cmd_Backward:
			scidb->game(position).backward();
			break;

		default:
			return usage(::CmdPosition, nullptr, nullptr, subcommands, args);
	}

	return TCL_OK;
}


static int
cmdNext(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "keys", "moves", "move", 0 };
	static char const* args[] = { "?<position>?", "?<position>?", "",  };
	enum { Cmd_Keys, Cmd_Moves, Cmd_Move };

	if (objc < 2)
		return usage(::CmdNext, nullptr, nullptr, subcommands, args);

	unsigned		flags				= 0;	// satisifies the compiler
	char const*	lastOption		= stringFromObj(objc, objv, objc - 1);
	int			index				= tcl::uniqueMatchObj(objv[1], subcommands);
	bool			useGameStyle	= false;

	while (objc >= 2 && lastOption[0] == '-' && !::isdigit(lastOption[1]))
	{
		if (equal(lastOption, "-ascii"))
			flags = Game::ExportFormat;
		else if (equal(lastOption, "-unicode"))
			flags = Game::MoveOnly;
		else if (equal(lastOption, "-usegamestyle"))
			useGameStyle = true;
		else
			return error(CmdNext, nullptr, nullptr, "unknown option %s", lastOption);

		--objc;
		lastOption = stringFromObj(objc, objv, objc - 1);
	}

	if (index == Cmd_Move)
	{
		Game& game = scidb->game();
		setResult(game.atLineEnd() ? mstl::string::empty_string : game.getNextMove(flags));
	}
	else
	{
		if (index != Cmd_Keys && index != Cmd_Moves)
			return usage(::CmdNext, nullptr, nullptr, subcommands, args);

		int position = -1;

		if (objc > 2 && ::isdigit(*asString(objv[2])))
			position = intFromObj(objc, objv, 2);

		Game::StringList result;

		switch (index)
		{
			case Cmd_Keys:
				Scidb->game(position).getNextKeys(result);
				break;

			case Cmd_Moves:
			{
				move::Notation style = move::SAN;
				if (useGameStyle)
					style = Scidb->game(position).moveStyle();
				Scidb->game(position).getNextMoves(result, style, flags);
				break;
			}
		}

		Tcl_Obj* objs[result.size()];
		unsigned k = 0;

		Game::StringList::const_iterator i = result.begin();
		Game::StringList::const_iterator e = result.end();

		for ( ; i != e; ++i)
			objs[k++] = newObj(*i);

		setResult(result.size(), objs);
	}

	return TCL_OK;
}


static int
cmdLevel(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb->game().variationLevel());
	return TCL_OK;
}


static int
cmdLangSet(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int position = objc < 2 ? -1 : intFromObj(objc, objv, 1);
	Tcl_Obj* languages = objectFromObj(objc, objv, objc < 2 ? 1 : 2);

	char const* s = asString(languages);

	if (*s == '*')
	{
		scidb->game(position).setAllLanguages();
	}
	else if (*s)
	{
		Game::LanguageSet set;
		int n = countElements(languages);

		for (int i = 0; i < n; ++i)
		{
			Tcl_Obj* lang;
			Tcl_ListObjIndex(ti, languages, i, &lang);
			set[mstl::string(asString(lang))] = 1;
		}

		scidb->setupLanguageSet(set, position);
	}
	else
	{
		scidb->setupLanguageSet(Game::LanguageSet(), position);
	}

	return TCL_OK;
}


static int
cmdVariation(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"count", "current", "new", "remove", "insert", "exchange",
		"promote", "mainline", "first", "leave", "length", "fold",
		"folded?", "unfold", 0
	};
	static char const* args[] =
	{
		"", "", "<san>", "<varno>", "<varno> ?-force?", "<varno> ?-force?",
		"<varno>", "<san>", "<varno>", "", "?<varno>?", "?<key>? <flag>",
		"<key>", "", 0
	};
	enum
	{
		Cmd_Count, Cmd_Current, Cmd_New, Cmd_Remove, Cmd_Insert, Cmd_Exchange,
		Cmd_Promote, Cmd_Mainline, Cmd_First, Cmd_Leave, Cmd_Length, Cmd_Fold,
		Cmd_Folded, Cmd_Unfold,
	};

	if (objc < 2)
		return usage(::CmdVariation, nullptr, nullptr, subcommands, args);

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Game& game = scidb->game();

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

				if (equal(stringFromObj(objc, objv, objc - 1), "-force"))
					flag = Game::TruncateIfNeccessary;

				setResult(game.insertMoves(unsignedFromObj(objc, objv, 2) - 1, flag));
			}
			break;

		case Cmd_Exchange:
			{
				Game::Force flag = Game::OnlyIfRemainsConsistent;

				if (equal(stringFromObj(objc, objv, objc - 1), "-force"))
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

		case Cmd_Fold:
			if (objc == 3)
				scidb->game().setFolded(boolFromObj(objc, objv, 2));
			else if (equal(stringFromObj(objc, objv, 3), "toggle"))
				scidb->game().toggleFolded(edit::Key(stringFromObj(objc, objv, 2)));
			else
				scidb->game().setFolded(edit::Key(stringFromObj(objc, objv, 2)), boolFromObj(objc, objv, 3));
			break;

		case Cmd_Folded:
			setResult(Scidb->game().isFolded(edit::Key(stringFromObj(objc, objv, 2))));
			break;

		case Cmd_Unfold:
			if (objc > 2)
			{
				if (!equal(stringFromObj(objc, objv, 2), "-force"))
				{
					error(CmdVariation,
							nullptr,
							nullptr,
							"unexpected option %s",
							stringFromObj(objc, objv, 2));
				}

				scidb->game().setFolded(Scidb->game().currentKey(), false);
			}
			else
			{
				scidb->game().unfold();
			}
			break;

		default:
			return error(	CmdVariation,
								nullptr,
								nullptr,
								"unexpected command %s",
								stringFromObj(objc, objv, 1));
	}

	return TCL_OK;
}


static int
cmdCurrent(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(int(Scidb->currentPosition()));
	return TCL_OK;
}


static int
cmdPly(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// NOTE: this call may come too early (before scratch game is created)
	if (scidb->haveCurrentGame())
		setResult(scidb->game().currentBoard().plyNumber());
	else
		setResult(0);

	return TCL_OK;
}


static int
cmdSave(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 8 && objc != 10)
	{
		Tcl_WrongNumArgs(
			ti,
			1, objv,
			"<database> <variant> <tag-list> <white-ratingtype> <black-ratingtype> "
			"<log-cmd> <log-arg> ?-replace <bool>?"
		);
		return TCL_ERROR;
	}

	bool				replace		= false;
	char const*		db				= stringFromObj(objc, objv, 1);
	variant::Type	variant		= tcl::game::variantFromObj(objc, objv, 2);
	tag::ID			wrt			= tag::fromName(stringFromObj(objc, objv, 4));
	tag::ID			brt			= tag::fromName(stringFromObj(objc, objv, 5));
	Tcl_Obj*			taglist		= objectFromObj(objc, objv, 3);
	tag::ID			ratings[2]	= { tag::ExtraTag, tag::ExtraTag };
	tcl::Log			log(objv[4], objv[5]);

	if (objc == 10)
	{
		if (!equal(stringFromObj(objc, objv, 8), "-replace"))
			return error(CmdSave, nullptr, nullptr, "unexpected argument %s", stringFromObj(objc, objv, 8));

		replace = boolFromObj(objc, objv, 9);
	}

	TagSet tags;

	int rc = game::convertTags(tags, taglist, wrt, brt, &ratings);

	if (rc == TCL_OK)
	{
		// TODO: check tags

		scidb->game().setTags(tags);

		save::State state = scidb->saveGame(scidb->cursor(db, variant), replace);

		setResult(save::isOk(state));
		log.error(state, Scidb->gameIndex());
	}

	return rc;
}


static int
cmdStrip(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"moves", "truncate", "annotations", "info", "marks", "comments", "variations", 0
	};
	enum { Cmd_Moves, Cmd_Truncate, Cmd_Annotations, Cmd_Info, Cmd_Marks, Cmd_Comments, Cmd_Variations };

	if (objc < 2)
		return usage(CmdStrip, nullptr, nullptr, subcommands);

	switch (tcl::uniqueMatchObj(objv[1], subcommands))
	{
		case Cmd_Moves:
			scidb->game().stripMoves();
			break;

		case Cmd_Truncate:
			scidb->game().truncateVariation();
			break;

		case Cmd_Annotations:
			scidb->game().stripAnnotations();
			break;

		case Cmd_Info:
			scidb->game().stripMoveInfo();
			break;

		case Cmd_Marks:
			scidb->game().stripMarks();
			break;

		case Cmd_Comments:
			if (objc < 3)
				scidb->game().stripComments();
			else
				scidb->game().stripComments(stringFromObj(objc, objv, 2));
			break;

		case Cmd_Variations:
			{
				Game& game = scidb->game();

				game.exitToMainline();
				game.stripVariations();
				game.goToCurrentMove();
			}
			break;

		default:
			return error(CmdStrip, nullptr, nullptr, "unexpected command %s", stringFromObj(objc, objv, 1));
	}

	return TCL_OK;
}


static int
cmdReplace(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->game().replaceVariation(stringFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdTrial(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Game& game = scidb->game();

	game.replaceVariation(stringFromObj(objc, objv, 1));
	game.clearUndo();

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
		{
			return error(	CmdExchange,
								nullptr,
								nullptr,
								"unexpected argument %s",
								stringFromObj(objc, objv, 2));
		}

		force = true;
	}

	setResult(scidb->game().exchangeMove(
		san,
		force ? Game::TruncateIfNeccessary : Game::OnlyIfRemainsConsistent));

	return TCL_OK;
}


static int
cmdLink(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = objc == 1 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	Tcl_Obj* objs[5];

	objs[0] = newObj(Scidb->sourceName(position));
	objs[1] = ::tcl::tree::variantToString(Scidb->variant(position));
	objs[2] = newObj(Scidb->sourceIndex(position));
	objs[3] = newObj(int64_t(Scidb->sourceCrcIndex(position)));
	objs[4] = newObj(int64_t(Scidb->sourceCrcMoves(position)));

	setResult(objs);
	return TCL_OK;
}


static int
cmdSink(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	typedef ::util::crc::checksum_t checksum_t;

	unsigned		position		= unsignedFromObj(objc, objv, 1);
	char const*	sourceName	= stringFromObj(objc, objv, 2);
	int			sourceIndex	= intFromObj(objc, objv, 3);
	checksum_t	crcIndex		= wideIntFromObj(objc, objv, 4);
	checksum_t	crcMoves		= wideIntFromObj(objc, objv, 5);

	if (sourceIndex == -1)
		sourceIndex = Scidb->database(position).countGames() - 1;

	scidb->setSource(position, sourceName, sourceIndex, crcIndex, crcMoves);
	return TCL_OK;
}


static int
cmdSink_(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = objc == 1 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	Tcl_Obj* objs[3];

	objs[0] = newObj(Scidb->databaseName(position));
	objs[1] = ::tcl::tree::variantToString(Scidb->variant(position));
	objs[2] = newObj(Scidb->gameIndex(position));

	setResult(objs);
	return TCL_OK;
}


static int
cmdQuery(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* fst = stringFromObj(objc, objv, 1);
	char const* cmd;

	int pos;
	int nextArg;

	if (::isdigit(fst[0]) || (fst[0] == '-' && ::isdigit(fst[1])))
	{
		pos = intFromObj(objc, objv, 1);
		cmd = stringFromObj(objc, objv, 2);
		nextArg = 3;
	}
	else
	{
		pos = Application::InvalidPosition;
		cmd = stringFromObj(objc, objv, 1);
		nextArg = 2;
	}

	if (::strlen(cmd) <= 1)
		return error(CmdQuery, nullptr, nullptr, "unexpected argument %s", cmd);

	switch (cmd[0])
	{
		case 'u': setResult(toString(Scidb->game(pos).undoCommand())); break;	// undo
		case 'i': setResult(Scidb->game(pos).idn()); break;							// idn

		case 'f': // fen
			setResult(Scidb->game(pos).startBoard().toFen(Scidb->game().variant()));
			break;

		case 'V': // Variant? (of database)
			setResult(tcl::tree::variantToString(variant::toMainVariant(Scidb->game(pos).variant())));
			break;

		case 'v':
			if (equal(cmd, "varia", 5))
			{
				switch (cmd[5])
				{
					case 't': // variations?
						setResult(Scidb->game(pos).hasVariations());
						break;

					case 'n': // variant?
						setResult(tcl::tree::variantToString(Scidb->game(pos).variant()));
						break;
				}
			}
			break;

		case 't':
			switch (cmd[1])
			{
				case 'r':	// trial
					setResult(Scidb->hasTrialMode(pos));
					break;

				case 'e':	// termination
					setResult(termination::toString(Scidb->gameInfoAt(pos).terminationReason()));
					break;
			}
			break;

		case 'o':
			switch (cmd[1])
			{
				case 'p':	// open?
					setResult(Scidb->containsGameAt(pos));
					break;

				case 'v':	// over?
					setResult(bool(Scidb->game(pos).currentBoard().gameIsOver(Scidb->game().variant())));
					break;
			}
			break;

		case 'p':			// parent
			{
				edit::Key key(stringFromObj(objc, objv, nextArg));
				key.removePly();
				key.removeVariation();
				setResult(key.id());
			}
			break;

		case 'c':
			{
				switch (cmd[1])
				{
					case 'h':	// checksum
						{
							Tcl_Obj* objs[2];
							objs[0] = newObj(int64_t(Scidb->checksumIndex(pos)));
							objs[1] = newObj(int64_t(Scidb->checksumMoves(pos)));
							setResult(objs);
						}
						break;

					case 'o':
						switch (cmd[2])
						{
							case 'm':	// comment
								{
									char const* which = stringFromObj(objc, objv, nextArg);

									Comment comment;
									Game const& game = Scidb->game(pos);

									if (*which == 't')
									{
										comment = game.trailingComment();
									}
									else
									{
										move::Position position = *which == 'b' ? move::Ante : move::Post;
										comment = game.comment(position);
									}

									if (game.displayStyle() & display::ShowEmoticons)
										comment.detectEmoticons();
									setResult(comment);
								}
								break;

							case 'u':	// country
								{
									char const* side = stringFromObj(objc, objv, nextArg);
									color::ID color = *side == 'w' ? color::White : color::Black;
									country::Code country = Scidb->gameInfoAt(pos).findFederation(color);
									setResult(country::toString(country));
									break;
								}
						}
						break;

					case 'u':			// current?
						setResult(Scidb->game(pos).currentKey().id());
						break;
				}
			}
			break;

		case 'm':
			switch (cmd[1])
			{
				case 'o':
					switch (cmd[2])
					{
						case 'd':	// modified?
							setResult(Scidb->game(pos).isModified());
							break;

						case 'v':	// moveInfo?
							if (nextArg < objc)
							{
								Tcl_Obj* moveInfo = objectFromObj(objc, objv, nextArg);
								unsigned moveInfoTypes;

								if (getMoveInfoTypes(::CmdQuery, "moveInfo?", moveInfo, moveInfoTypes) != TCL_OK)
									return TCL_ERROR;

								setResult(Scidb->game(pos).hasMoveInfo(moveInfoTypes));
							}
							else
							{
								setResult(Scidb->game(pos).hasMoveInfo());
							}
							break;
					}
					break;

				case 'a':
					switch (cmd[2])
					{
						case 'r':	// marks
						if (nextArg < objc)
						{
							mstl::string key(stringFromObj(objc, objv, nextArg));
							mstl::string marks;

							setResult(Scidb->game(pos).marks(key).print(marks));
						}
						else
						{
							mstl::string marks;
							setResult(Scidb->game(pos).marks().print(marks));
						}
						break;

						case 'i':	// mainvariant?
							setResult(tcl::tree::variantToString(
								variant::toMainVariant(Scidb->game(pos).variant())));
							break;
					}
					break;

				default: return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
			}
			break;

		case 's':
			switch (cmd[1])
			{
				case 't':
					switch (cmd[2])
					{
						case 'a': setResult(Scidb->game(pos).startKey()); break;		// start
						case 'm': setResult(color::printColor(Scidb->game(pos).sideToMove())); break; // stm

						default: return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
					}
					break;

				default:
					return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
			}
			break;

		case 'a':	// annotation
			{
				mstl::string s, t, u;

				Game const&	game = Scidb->game(pos);
				Tcl_Obj*		objs[3];

				objs[0] = newObj(game.prefix(s));
				objs[1] = newObj(game.infix(t));
				objs[2] = newObj(game.suffix(u));

				setResult(objs);
			}
			break;

		case 'l':
			switch (cmd[1])
			{
				case 'a':	// langSet
					if (objc >= 4)
					{
						char const* position(stringFromObj(objc, objv, nextArg));
						char const* lang(stringFromObj(objc, objv, nextArg + 2));
						edit::Key	key(stringFromObj(objc, objv, nextArg + 1));

						move::Position p = *position == 'a' ? move::Ante : move::Post;
						if (*position == 't')
							key.incrementPly();
						setResult(Scidb->game(pos).containsLanguage(key, p, lang));
					}
					else
					{
						Game::LanguageSet const& langSet = Scidb->game(pos).languageSet();
						Tcl_Obj* objv[langSet.size()];
						unsigned k = 0;

						for (Game::LanguageSet::const_iterator i = langSet.begin(); i != langSet.end(); ++i)
							objv[k++] = newObj(i->first);

						setResult(k, objv);
					}
					break;

				case 'e':	// length
					setResult(Scidb->game(pos).plyCount());
					break;
			}
			break;

		case 'r':
			switch (cmd[1])
			{
				case 'e':	// redo
					setResult(toString(Scidb->game(pos).redoCommand()));
					break;

				case 'a':	// ratingTypes
					{
						GameInfo const& info = Scidb->gameInfoAt(pos);

						mstl::string const& wr = rating::toString(info.ratingType(color::White));
						mstl::string const& br = rating::toString(info.ratingType(color::Black));

						Tcl_Obj* objs[2] = { newObj(wr), newObj(br)};
						setResult(objs);
					}
					break;

				default: return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
			}
			break;

		case 'e':
			switch (cmd[1])
			{
				case 'm': setResult(Scidb->game(pos).isEmpty()); break;									// empty?
				case 'n': setResult(Scidb->encoding(pos)); break;											// encoding?
				case 'c': setResult(Scidb->game(pos).computeEcoCode().asShortString()); break;	// eco
				case 'x': setResult(false); break;																// expansion

				case 'l':	// elo
					{
						char const* side = stringFromObj(objc, objv, nextArg);
						color::ID color = *side == 'w' ? color::White : color::Black;
						setResult(Scidb->gameInfoAt(pos).findElo(color));
					}
					break;

				default: return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
			}
			break;

		case 'd':	// database
			setResult(Scidb->databaseName(pos));
			break;

		case 'n':	// nextKey?
			setResult(Scidb->game(pos).nextKey(stringFromObj(objc, objv, nextArg)));
			break;

		default: return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
	}

	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int pos = objc == 3 ? intFromObj(objc, objv, 1) : Application::InvalidPosition;

	char const*	cmd = stringFromObj(objc, objv, objc == 3 ? 2 : 1);

	if (::strlen(cmd) <= 1)
		return error(CmdQuery, nullptr, nullptr, "unexpected argument %s", cmd);

	switch (cmd[0])
	{
		case 'a': setResult(scidb->game(pos).countAnnotations()); break;	// annotations
		case 'i': setResult(scidb->game(pos).countMoveInfo()); break;		// info
		case 'm': setResult(scidb->game(pos).countMarks()); break;			// marks
		case 'c': setResult(scidb->game(pos).countComments()); break;		// comments
		case 'v': setResult(scidb->game(pos).countVariations()); break;	// variations
		case 'h': setResult(scidb->game(pos).countHalfMoves()); break;		// halfmoves
		case 'l': setResult(scidb->game(pos).countLength()); break;			// length
		default:  return error(CmdQuery, nullptr, nullptr, "invalid command %s", cmd);
	}

	return TCL_OK;
}


static int
cmdClear(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	variant::Type	variant	= Scidb->game().variant();
	int				idn		= 0;

	Board board;

	if (Tcl_GetIntFromObj(interp(), objv[1], &idn) == TCL_OK)
	{
		if (idn < 1 || 4*960 < idn)
			error(CmdClear, nullptr, nullptr, "invalid IDN %d", idn);

		board.setup(unsigned(idn), variant);
	}
	else
	{
		char const* fen = stringFromObj(objc, objv, 1);

		if (!board.setup(fen, variant))
			error(CmdClear, nullptr, nullptr, "invalid FEN '%s'", fen);
	}

	scidb->clearGame(&board);

	return TCL_OK;
}


static int
cmdExecute(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	cmd		= stringFromObj(objc, objv, 1);
	int			position	= objc < 3 ? -1 : intFromObj(objc, objv, 2);

	if (equal(cmd, "undo"))
		scidb->game(position).undo();
	else if (equal(cmd, "redo"))
		scidb->game(position).redo();
	else
		return error(CmdQuery, nullptr, nullptr, "invalid command %s", stringFromObj(objc, objv, 1));

	return TCL_OK;
}


static int
cmdBoard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;

	if (objc == 1)
		board = Scidb->game().currentBoard();
	else
		board = Scidb->game(intFromObj(objc, objv, 1)).board(stringFromObj(objc, objv, 2));

	mstl::string str;
	pos::dumpBoard(board, str);
	setResult(str);

	return TCL_OK;
}


static int
cmdFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	int pos = objc == 1 ? Application::InvalidPosition : intFromObj(objc, objv, 1);
	setResult(Scidb->game(pos).currentBoard().toFen(Scidb->game().variant()));
	return TCL_OK;
}


static int
cmdPromoted(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;

	switch (objc)
	{
		case 1:	board = Scidb->game().currentBoard(); break;
		case 2:	board = Scidb->game(intFromObj(objc, objv, 1)).currentBoard(); break;
		default:	board = Scidb->game(intFromObj(objc, objv, 1)).board(stringFromObj(objc, objv, 2)); break;
	}

	setResult(makePromotionList(board));
	return TCL_OK;
}


static int
cmdMaterial(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Game const& game = Scidb->game();

	material::Count matW = game.currentBoard().materialCount(color::White);
	material::Count matB = game.currentBoard().materialCount(color::Black);

	Tcl_Obj*	objs[6] =
	{
		newObj(matW.pawn   - matB.pawn  ),
		newObj(matW.knight - matB.knight),
		newObj(matW.bishop - matB.bishop),
		newObj(matW.rook   - matB.rook  ),
		newObj(matW.queen  - matB.queen ),
		newObj(matW.king   - matB.king  ),
	};

	setResult(objs);
	return TCL_OK;
}


static int
cmdUndoSetup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned undoLevel = unsignedFromObj(objc, objv, 1);
	unsigned combinePredecessingMoves = unsignedFromObj(objc, objv, 2);

	scidb->setupGameUndo(undoLevel, combinePredecessingMoves);
	return TCL_OK;
}


static int
cmdSetupStyle(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned position = unsignedFromObj(objc, objv, 1);

	if (Scidb->containsGameAt(position))
	{
		unsigned 		linebreakThreshold			= unsignedFromObj(objc, objv, 2);
		unsigned 		linebreakMaxLineLengthMain	= unsignedFromObj(objc, objv, 3);
		unsigned 		linebreakMaxLineLengthVar	= unsignedFromObj(objc, objv, 4);
		unsigned 		linebreakMinCommentLength	= unsignedFromObj(objc, objv, 5);
		bool				columnStyle						= boolFromObj(objc, objv, 6);
		move::Notation	moveForm							= game::notationFromObj(objc, objv, 7);
		bool				paragraphSpacing				= boolFromObj(objc, objv, 8);
		bool				showDiagram						= boolFromObj(objc, objv, 9);
		Tcl_Obj*			showMoveInfo					= objectFromObj(objc, objv, 10);
		bool				showEmoticon					= boolFromObj(objc, objv, 11);
		bool				showVariationNumbers			= boolFromObj(objc, objv, 12);
		bool				discardUnknownResult			= boolFromObj(objc, objv, 13);
		unsigned			displayStyle					= columnStyle ? display::ColumnStyle : display::CompactStyle;
		unsigned			moveInfoTypes;

		if (getMoveInfoTypes(::CmdSetupStyle, 0, showMoveInfo, moveInfoTypes) != TCL_OK)
			return TCL_ERROR;

		if (showDiagram)
			displayStyle |= display::ShowDiagrams;
		if (showEmoticon)
			displayStyle |= display::ShowEmoticons;
		if (paragraphSpacing)
			displayStyle |= display::ParagraphSpacing;
		if (moveInfoTypes)
			displayStyle |= display::ShowMoveInfo;
		if (showVariationNumbers)
			displayStyle |= display::ShowVariationNumbers;
		if (discardUnknownResult)
			displayStyle |= display::DiscardUnknownResult;

		scidb->game(position).setup(	linebreakThreshold,
												linebreakMaxLineLengthMain,
												linebreakMaxLineLengthVar,
												linebreakMinCommentLength,
												displayStyle,
												moveInfoTypes,
												moveForm);
	}

	return TCL_OK;
}


static int
cmdSetupNags(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Array elems = getElements(objectFromObj(objc, objv, 1));

	::db::Annotation::unsetUnusualNags();

	for (unsigned i = 0; i < elems.size(); ++i)
	{
		int nag = asInt(elems[i]);

		if (nag >= ::db::nag::Scidb_Last)
			return error(::CmdSetupNags, nullptr, nullptr, "invalid NAG '%s'", asString(elems[i]));

		::db::Annotation::setUnusualNag(nag::ID(nag));
	}

	if (!elems.empty())
		::db::Annotation::flipUnusualNags();

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

		if (!equal(opt, "-userSuppliedOnly"))
		{
			return error(	::CmdTags, nullptr, nullptr,
								"unexpected option '%s'",
								stringFromObj(objc, objv, 1));
		}

		userSuppliedOnly = boolFromObj(objc, objv, 2);
	}

	TagSet const& tags = Scidb->game(position).tags();
	return tcl::db::getTags(tags, userSuppliedOnly);
}


static int
cmdNumber(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb->gameNumber(objc > 1 ? intFromObj(objc, objv, 1) : -1));
	return TCL_OK;
}


static int
cmdIndex(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb->gameIndex(objc > 1 ? intFromObj(objc, objv, 1) : -1));
	return TCL_OK;
}


static int
cmdPush(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->startTrialMode();
	return TCL_OK;
}


static int
cmdPop(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->endTrialMode();
	scidb->refreshGame(Application::InvalidPosition, true);
	return TCL_OK;
}


static int
cmdUpdate(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] =
	{
		"annotation", "infix", "prefix", "suffix", "comment", "marks", "moves", "addcomment", 0
	};
	static char const* args[] =
	{
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <nag-list>",
		"<key> <position> <string>",
		"<key> <type> <color> <from> <to>",
		"<key>",
		"<key> <position> <string>",
		nullptr
	};
	enum
	{
		Cmd_Annotation, Cmd_Infix, Cmd_Pefix, Cmd_Suffix,
		Cmd_Comment, Cmd_Marks, Cmd_Moves, Cmd_AddComment,
	};

	if (objc < 2)
		return usage(::CmdUpdate, nullptr, nullptr, subcommands, args);

	int index = tcl::uniqueMatchObj(objv[1], subcommands);

	Game& game = scidb->game();

	if (index == Cmd_Moves)
	{
		scidb->updateMoves();
	}
	else
	{
		if (game.currentKey() != stringFromObj(objc, objv, 2))
		{
			return error(	::CmdUpdate, nullptr, nullptr,
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
				{
					char const*		pos = stringFromObj(objc, objv, 3);
					mstl::string	comment(stringFromObj(objc, objv, 4));

					if (*pos == 't')
						game.setTrailingComment(comment);
					else
						game.setComment(comment, *pos == 'b' ? move::Ante : move::Post);
				}
				break;

			case Cmd_AddComment:
			{
				mstl::string comment(stringFromObj(objc, objv, 4));
				game.appendComment(comment, move::Post);
				break;
			}

			case Cmd_Marks:
				{
					char const*	text	= stringFromObj(objc, objv, 3);
					mark::Type	type	= mark::typeFromString(text);
					mark::Color	color	= mark::colorFromString(stringFromObj(objc, objv, 4));
					Square		from	= squareFromObj(objc, objv, 5);
					Square		to		= squareFromObj(objc, objv, 6);

					if (from == sq::Null || (type == mark::Arrow && (to == sq::Null || from == to)))
					{
						return error(	::CmdUpdate, "marks", nullptr,
											"invalid square(s) (%s, %s)",
											stringFromObj(objc, objv, 5),
											stringFromObj(objc, objv, 6));
					}

					if (from == to)
						to = sq::Null;

					Mark		mark(type, color, from, to, type == mark::Text ? *text : '\0');
					MarkSet	marks	= scidb->game().marks();
					int		index	= marks.match(mark);

					if (index == -1)
					{
						marks.add(mark);
					}
					else if (marks[index] == mark)
					{
						marks.remove(index);
					}
					else
					{
						marks.remove(index);
						marks.add(mark);
					}

					scidb->game().setMarks(marks);
				}
				break;

			default:
				return usage(::CmdUpdate, nullptr, nullptr, subcommands, args);
		}
	}

	return TCL_OK;
}


static int
cmdImport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* figurine = nullptr;
	char const* encoding = sys::utf8::Codec::utf8();
	char const* database	= nullptr;
	char const* option;

	int index = -1;

	bool	asVariation	= false;
	bool	trialMode	= false;
	int	varno			= -1;

	::db::variant::Type variant = ::db::variant::Normal;

	tcl::PgnReader::Modification modification = tcl::PgnReader::Normalize;

	while (objc > 2 && *(option = stringFromObj(objc, objv, objc - 2)) == '-')
	{
		if (equal(option, "-encoding"))
		{
			encoding = stringFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-figurine"))
		{
			figurine = stringFromObj(objc, objv, objc - 1);

			for (unsigned i = 0; i < 6; ++i)
			{
				if (!::isupper(figurine[i]))
					return error(CmdImport, nullptr, nullptr, "invalid figurines '%s'", figurine);
			}
		}
		else if (equal(option, "-variation"))
		{
			asVariation = boolFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-trial"))
		{
			trialMode = boolFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-varno"))
		{
			varno = intFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-scidb"))
		{
			if (boolFromObj(objc, objv, objc - 1))
				modification = tcl::PgnReader::Raw;
		}
		else if (equal(option, "-database"))
		{
			database = stringFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-index"))
		{
			index = intFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-variant"))
		{
			char const* v = stringFromObj(objc, objv, objc - 1);
			variant = ::db::variant::fromString(v);
		}
		else
		{
			return error(CmdImport, nullptr, nullptr, "unexpected option '%s'", option);
		}

		objc -= 2;
	}

	if (objc != 3 && objc != 5)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<position> <text> ?<log> <log-arg>? ?-encoding <string>?");
		return TCL_ERROR;
	}

	if (database && index == -1)
		error(CmdImport, nullptr, nullptr, "-database specified, but no -index");
	if (index >= 0 && !database)
		error(CmdImport, nullptr, nullptr, "-index specified, but no -database");

	Tcl_Obj* cmd = objc < 5 ? nullptr : objv[3];
	Tcl_Obj* arg = objc < 5 ? nullptr : objv[4];

	if (asVariation)
	{
		if (variant == variant::Undetermined)
		{
			return error(	CmdImport,
								nullptr,
								nullptr,
								"invalid variant '%s'",
								variant::identifier(variant).c_str());
		}

		mstl::istringstream	stream(stringFromObj(objc, objv, 2));
		tcl::PgnReader			reader(	stream,
												variant,
												encoding,
												cmd,
												arg,
												modification,
												tcl::PgnReader::Variation);
		VarConsumer				consumer(Scidb->game().currentBoard());
		SingleProgress			progress;

		if (figurine)
			reader.setFigurine(figurine);
		reader.setConsumer(&consumer);

		reader.process(progress);

		if (reader.countErrors() > 0)
		{
			setResult(-int(reader.countErrors()));
		}
		else if (trialMode)
		{
			setResult(scidb->game().isValidVariation(consumer.result()));
		}
		else if (consumer.result()->countHalfMoves() > 0)
		{
			if (varno < 0)
			{
				if (scidb->game().isEmpty())
				{
					scidb->game().addMoves(Game::MoveNodeP(consumer.release()));
					setResult(0);
				}
				else
				{
					setResult(scidb->game().addVariation(Game::MoveNodeP(consumer.release())));
				}
			}
			else
			{
				scidb->game().changeVariation(Game::MoveNodeP(consumer.release()), varno);
				setResult(varno);
			}
		}
		else
		{
			setResult(-1);
		}
	}
	else
	{
		mstl::string text(stringFromObj(objc, objv, 2));

		char const* searchTag = ::searchTag(text);
		unsigned lineOffset = 0;

		if (modification == tcl::PgnReader::Normalize && *searchTag != '[')
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

		int position(intFromObj(objc, objv, 1));

		if (variant == variant::Undetermined)
		{
			struct NullConsumer : public ::db::Consumer
			{
				NullConsumer(mstl::string const& encoding)
					: ::db::Consumer(	::db::format::Pgn,
											encoding,
											::db::tag::TagSet(),
											false)									{}
				format::Type format() const override						{ return ::db::format::Scidb; }
				void start() override											{}
				void finish() override											{}
				bool beginGame(TagSet const&) override						{ return true; }
				save::State endGame(TagSet const&) override				{ return save::Ok; }

				void sendPrecedingComment(	Comment const&,
													Annotation const&,
													MarkSet const&) override	{}
				void sendTrailingComment(	Comment const&,
													bool) override	{}
				void sendComment(Comment const&) override					{}
				void sendMoveInfo(MoveInfoSet const&) override			{}
				bool sendMove(Move const&) override							{ return true; }
				bool sendMove(	Move const&,
									Annotation const&,
									MarkSet const&,
									Comment const&,
									Comment const&) override					{ return true; }

				void beginMoveSection() override								{}
				void endMoveSection(result::ID result) override			{}

				void beginVariation() override								{}
				void endVariation(bool) override								{}
			};

			mstl::istringstream	stream(text);

			tcl::PgnReader	reader(	stream,
											variant,
											encoding,
											nullptr,
											nullptr,
											::db::Reader::Raw,
											tcl::PgnReader::Game,
											nullptr,
											lineOffset,
											true);
			util::Progress	progress;
			NullConsumer	consumer(encoding);

			if (figurine)
				reader.setFigurine(figurine);
			reader.setConsumer(&consumer);
			reader.process(progress);

			if ((variant = reader.detectedVariant()) == variant::Undetermined)
				variant = variant::Normal;

			scidb->changeVariant(position, variant);
		}

		mstl::istringstream	stream(text);
		tcl::PgnReader			reader(	stream,
												variant,
												encoding,
												cmd,
												arg,
												modification,
												tcl::PgnReader::Game,
												nullptr,
												lineOffset,
												trialMode);

		if (figurine)
			reader.setFigurine(figurine);

		load::State state = scidb->importGame(reader, position, trialMode);

		if (database && Scidb->scratchBase().name() != database)
			scidb->bindGameToDatabase(position, database, index);

		if (trialMode)
		{
			setResult(reader.countErrors() == 0);
		}
		else
		{
			setResult(::stateToInt(state));

			if (state == load::None)
			{
				for (unsigned i = 0; i < variant::NumberOfVariants; ++i)
				{
					if (reader.rejected(i))
						setResult(variant::identifier(variant::fromIndex(i)));
				}
			}
		}
	}

	return TCL_OK;
}


static int
cmdExport(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*					option;
	char const*					comment("");
	unsigned						flags(Writer::Flag_Use_Scidb_Import_Format);
	Application::FileMode	mode(Application::Create);
	mstl::string				encoding(sys::utf8::Codec::utf8());
	unsigned						position(Application::InvalidPosition);
	View::Languages			languages;
	View::Languages*			languagePtr(&languages);
	int							significant(0);

	while (objc > 2 && *(option = stringFromObj(objc, objv, objc - 2)) == '-')
	{
		if (equal(option, "-comment"))
		{
			comment = stringFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-flags"))
		{
			flags = unsignedFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-encoding"))
		{
			encoding = stringFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-languages"))
		{
			if ((significant = ::tcl::view::makeLangList(ti, CmdExport, objv[objc - 1], languages)) == -1)
				return TCL_ERROR;
		}
		else if (equal(option, "-position"))
		{
			position = unsignedFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-mode"))
		{
			char const* fmode = stringFromObj(objc, objv, objc - 1);

			if (equal(fmode, "append"))
				mode = Application::Append;
			else if (equal(fmode, "create"))
				mode = Application::Create;
			else
				return error (CmdExport, nullptr, nullptr, "unknown mode '%s'", fmode);
		}
		else
		{
			return error (CmdExport, nullptr, nullptr, "unexpected option '%s'", option);
		}

		objc -= 2;
	}

	if (objc != 2)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<filename> ?-comment <string>? ?-flags <flags>? "
			"?-mode append|create? ?-encoding <encoding>? ?-position <index>?");
		return TCL_ERROR;
	}

	if (significant == 0) {
		languagePtr = nullptr;
	}

	char const* filename = stringFromObj(objc, objv, 1);
	setResult(save::isOk(scidb->writeGame(
		position, filename, encoding, comment, languagePtr, significant, flags, mode)));
	return TCL_OK;
}


static int
cmdToPGN(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const*	option;
	unsigned		flags(PgnWriter::Default_Flags);
	unsigned		position(Application::InvalidPosition);

	while (objc > 2 && *(option = stringFromObj(objc, objv, objc - 2)) == '-')
	{
		if (equal(option, "-flags"))
			flags = unsignedFromObj(objc, objv, objc - 1);
		else if (equal(option, "-position"))
			position = unsignedFromObj(objc, objv, objc - 1);
		else
			return error (CmdExport, nullptr, nullptr, "unexpected option '%s'", option);

		objc -= 2;
	}

	char const* arg = stringFromObj(objc, objv, 1);
	copy::Source source;

	if (equal(arg, "original"))
		source = copy::OriginalSource;
	else if (equal(arg, "modified"))
		source = copy::ModifiedVersion;
	else
		return error(CmdCopy, nullptr, nullptr, "unexpected source '%s'", arg);

	mstl::ostringstream strm;

	if (save::isOk(scidb->exportGame(position, strm, flags, source)))
		setResult(strm.str());

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

	if (objc < 5 || ((objc - 5) % 2) == 1)
	{
		Tcl_WrongNumArgs(
			ti, 1, objv,
			"<file> <search-path> <script-path> <preamble> ?-flags <flags> "
			"-options <options> -nags <nag-map> -languages <languages> -trace <trace>?");
		return TCL_ERROR;
	}

	char const*		filename			= stringFromObj(objc, objv, 1);
	char const* 	searchPath		= stringFromObj(objc, objv, 2);
	mstl::string 	scriptPath		= stringFromObj(objc, objv, 3);
	mstl::string 	preamble			= stringFromObj(objc, objv, 4);
	unsigned			flags				= 0;
	unsigned			options			= 0;
	char const*		trace				= "";

	Tcl_Obj**			objs;
	View::NagMap		nagMap;
	View::Languages	languages;
	int					significant(-1);
	char const*			option;

	while (objc > 6 && *(option = stringFromObj(objc, objv, objc - 2)) == '-')
	{
		if (equal(option, "-flags"))
		{
			flags = unsignedFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-options"))
		{
			options = unsignedFromObj(objc, objv, objc - 1);
		}
		else if (equal(option, "-nags"))
		{
			Tcl_Obj* mapObj = objv[objc - 1];

			if (Tcl_ListObjGetElements(ti, mapObj, &objc, &objs) != TCL_OK)
				error(CmdExport, 0, 0, "invalid nag map");

			for (int i = 0; i < objc; ++i)
			{
				Tcl_Obj** pair;
				int nelems;

				if (Tcl_ListObjGetElements(ti, objs[i], &nelems, &pair) != TCL_OK || nelems != 2)
					error(CmdPrint, 0, 0, "invalid nag map");

				int lhs = intFromObj(2, pair, 0);
				int rhs = intFromObj(2, pair, 1);

				if (lhs >= nag::Scidb_Last || rhs >= nag::Scidb_Last)
					error(CmdPrint, 0, 0, "invalid nag map values");

				nagMap[lhs] = rhs;
			}
		}
		else if (equal(option, "-languages"))
		{
			if ((significant = ::tcl::view::makeLangList(ti, CmdPrint, objv[objc - 1], languages)) == -1)
				return TCL_ERROR;
		}
		else if (equal(option, "-trace"))
		{
			trace = stringFromObj(objc, objv, objc - 1);
		}
		else
		{
			return error (CmdPrint, nullptr, nullptr, "unexpected option '%s'", option);
		}

		objc -= 2;
	}
	::memset(nagMap, 0, sizeof(nagMap));

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

	Scidb->printGame(	Application::InvalidPosition,
							controller.environment(),
							format::LaTeX,
							flags,
							options,
							nagMap,
							significant == 0 ? nullptr : &languages,
							significant);

	{
		mstl::string log(out.str());

		if (!log.empty() && log.back() == '\n')
			log.set_size(log.size() - 1);

		Tcl_SetVar2Ex(ti, trace, 0, newObj(log), TCL_GLOBAL_ONLY);
	}

	return TCL_OK;
}


static int
cmdCopy(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* cmd = stringFromObj(objc, objv, 1);

	if (equal(cmd, "comments"))
	{
		char const* src = stringFromObj(objc, objv, 2);
		char const* dst = stringFromObj(objc, objv, 3);

		bool strip = false;

		if (objc == 6)
		{
			char const* option = stringFromObj(objc, objv, 4);

			if (!equal(option, "-strip"))
				return error(CmdCopy, nullptr, nullptr, "unexpected option '%s'", option);

			strip = boolFromObj(objc, objv, 5);
		}

		scidb->game().copyComments(src, dst, strip);
	}
	else if (equal(cmd, "game"))
	{
		char const* database = stringFromObj(objc, objv, 2);
		char const* arg = stringFromObj(objc, objv, 4);
		copy::Source source;

		if (equal(arg, "original"))
			source = copy::OriginalSource;
		else if (equal(arg, "modified"))
			source = copy::ModifiedVersion;
		else
			return error(CmdCopy, nullptr, nullptr, "unexpected source '%s'", arg);

		scidb->copyGame(scidb->multiCursor(database), unsignedFromObj(objc, objv, 3), source);
	}
	else
	{
		return error(CmdView, nullptr, nullptr, "unexpected command '%s'", cmd);
	}

	return TCL_OK;
}


static int
cmdView(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	static char const* subcommands[] = { "id", "next", "prev", "first", "last", "random", 0 };
	enum { Cmd_Id, Cmd_Next, Cmd_Prev, Cmd_First, Cmd_Last, Cmd_Random };

	if (objc != 3)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<position> action>");
		return TCL_ERROR;
	}

	unsigned		position	= unsignedFromObj(objc, objv, 1);
	int			index		= -1;

	switch (tcl::uniqueMatchObj(objv[2], subcommands))
	{
		case Cmd_Id:		index = Scidb->getViewId(position); break;
		case Cmd_Next:		index = Scidb->getNextGameIndex(position); break;
		case Cmd_Prev:		index = Scidb->getPrevGameIndex(position); break;
		case Cmd_First:	index = Scidb->getFirstGameIndex(position); break;
		case Cmd_Last:		index = Scidb->getLastGameIndex(position); break;
		case Cmd_Random:	index = Scidb->getRandomGameIndex(position); break;

		default:
			return error(CmdView, nullptr, nullptr, "unexpected command '%s'", asString(objv[2]));
	}

	setResult(index);
	return TCL_OK;
}


static int
cmdPaste(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* arg = stringFromObj(objc, objv, 1);

	if (equal(arg, "clipbase"))
	{
		scidb->pasteLastClipbaseGame(unsignedFromObj(objc, objv, 2));
	}
	else
	{
		unsigned from	= unsignedFromObj(objc, objv, 1);
		unsigned to		= unsignedFromObj(objc, objv, 2);

		scidb->pasteGame(from, to);
	}

	return TCL_OK;
}


static int
cmdMerge(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj*		args	= objectFromObj(objc, objv, 2);
	char const*	pos	= stringFromObj(objc, objv, 3);
	char const*	trans	= stringFromObj(objc, objv, 4);

	unsigned variationDepth = unsigned(-1);

	if (isdigit(*stringFromObj(objc, objv, 5)))
		variationDepth = unsignedFromObj(objc, objv, 5);

	unsigned maximalVariationLength = unsigned(-1);

	if (isdigit(*stringFromObj(objc, objv, 6)))
		maximalVariationLength = unsignedFromObj(objc, objv, 6);

	position::ID	startPos;
	move::Order		moveOrder;

	if (equal(pos, "initial"))
		startPos = position::Initial;
	else if (equal(pos, "current"))
		startPos = position::Current;
	else
		return error(CmdMerge, nullptr, nullptr, "unexpected position '%s'", pos);

	if (equal(trans, "ignore"))
		moveOrder = move::Strict;
	else if (equal(trans, "consider"))
		moveOrder = move::Transposition;
	else
		return error(CmdMerge, nullptr, nullptr, "unexpected order '%s'", trans);

	unsigned primary = unsignedFromObj(objc, objv, 1);
	int nargs;
	Tcl_Obj** objs;

	if (Tcl_ListObjGetElements(ti, args, &nargs, &objs) != TCL_OK)
		return error(CmdMerge, nullptr, nullptr, "list of position id's expected");

	bool rc = false;

	for (int i = 0; i < nargs; ++i)
	{
		unsigned to = unsignedFromObj(nargs, objs, i);
		unsigned modState = 0;

		if (i == 0)
			modState |= modification::First;
		if (i == nargs - 1)
			modState |= modification::Last;

		if (scidb->mergeGame(primary,
									to,
									startPos,
									moveOrder,
									variationDepth,
									maximalVariationLength,
									modState))
		{
			rc = true;
		}
	}

	setResult(rc);
	return TCL_OK;
}


static int
cmdVerify(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(scidb->verifyGame(unsignedFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdLines(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Game const& game = Scidb->game();

	Line line(game.openingLine().moves, mstl::min(game.plyNumber(), game.openingLine().length));

	EcoTable::Lines lines;
	EcoTable::specimen(game.variant()).getMoveOrders(line, lines);

	Tcl_Obj* objs[lines.size()];
	unsigned index = 0;

	for (EcoTable::Lines::const_iterator i = lines.begin(); i != lines.end(); ++i)
	{
		mstl::string opening;
		i->line().print(opening, game.variant(), move::SAN, protocol::Scidb, encoding::Utf8);
		objs[index++] = newObj(opening);
	}

	setResult(lines.size(), objs);

	return TCL_OK;
}


static int
cmdCodeToFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned code(unsignedFromObj(objc, objv, 1));
	::db::variant::Type variant(Scidb->game().variant());
	::db::Line const& line(::db::EcoTable::specimen(variant).getLine(::db::Eco(code)));
	::db::Board board(Scidb->game().startBoard());
	line.finalBoard(variant, board);
	setResult(board.toFen(variant));
	return TCL_OK;
}


namespace tcl {
namespace game {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdBoard,			cmdBoard);
	createCommand(ti, CmdClear,			cmdClear);
	createCommand(ti, CmdCodeToFen,		cmdCodeToFen);
	createCommand(ti, CmdCopy,				cmdCopy);
	createCommand(ti, CmdCount,			cmdCount);
	createCommand(ti, CmdCurrent,			cmdCurrent);
	createCommand(ti, CmdDump,				cmdDump);
	createCommand(ti, CmdEcoTable,		cmdEcoTable);
	createCommand(ti, CmdExchange,		cmdExchange);
	createCommand(ti, CmdExecute,			cmdExecute);
	createCommand(ti, CmdExport,			cmdExport);
	createCommand(ti, CmdFen,				cmdFen);
	createCommand(ti, CmdGo,				cmdGo);
	createCommand(ti, CmdImport,			cmdImport);
	createCommand(ti, CmdIndex,			cmdIndex);
	createCommand(ti, CmdInfo,				cmdInfo);
	createCommand(ti, CmdLangSet,			cmdLangSet);
	createCommand(ti, CmdLayout,			cmdLayout);
	createCommand(ti, CmdLevel,			cmdLevel);
	createCommand(ti, CmdLines,			cmdLines);
	createCommand(ti, CmdLink,				cmdLink);
	createCommand(ti, CmdLoad,				cmdLoad);
	createCommand(ti, CmdMaterial,		cmdMaterial);
	createCommand(ti, CmdMerge,			cmdMerge);
	createCommand(ti, CmdModified,		cmdModified);
	createCommand(ti, CmdMove,				cmdMove);
	createCommand(ti, CmdMoveto,			cmdMoveto);
	createCommand(ti, CmdNew,				cmdNew);
	createCommand(ti, CmdNext,				cmdNext);
	createCommand(ti, CmdNumber,			cmdNumber);
	createCommand(ti, CmdPaste, 			cmdPaste);
	createCommand(ti, CmdPly,				cmdPly);
	createCommand(ti, CmdPop,				cmdPop);
	createCommand(ti, CmdPosition,		cmdPosition);
	createCommand(ti, CmdPrint,			cmdPrint);
	createCommand(ti, CmdPromoted,		cmdPromoted);
	createCommand(ti, CmdPush,				cmdPush);
	createCommand(ti, CmdQuery,			cmdQuery);
	createCommand(ti, CmdRefresh,			cmdRefresh);
	createCommand(ti, CmdRelease,			cmdRelease);
	createCommand(ti, CmdReload,			cmdReload);
	createCommand(ti, CmdReplace,			cmdReplace);
	createCommand(ti, CmdSave,				cmdSave);
	createCommand(ti, CmdSetupNags,		cmdSetupNags);
	createCommand(ti, CmdSetupStyle,		cmdSetupStyle);
	createCommand(ti, CmdSink,				cmdSink);
	createCommand(ti, CmdSink_,			cmdSink_);
	createCommand(ti, CmdStrip,			cmdStrip);
	createCommand(ti, CmdSubscribe,		cmdSubscribe);
	createCommand(ti, CmdSwap,				cmdSwap);
	createCommand(ti, CmdSwapPositions,	cmdSwapPositions);
	createCommand(ti, CmdSwitch,			cmdSwitch);
	createCommand(ti, CmdTags,				cmdTags);
	createCommand(ti, CmdToPGN,			cmdToPGN);
	createCommand(ti, CmdTranspose,		cmdTranspose);
	createCommand(ti, CmdTrial,			cmdTrial);
	createCommand(ti, CmdUndoSetup,		cmdUndoSetup);
	createCommand(ti, CmdUnsubscribe,	cmdUnsubscribe);
	createCommand(ti, CmdUpdate,			cmdUpdate);
	createCommand(ti, CmdValid,			cmdValid);
	createCommand(ti, CmdVariant,			cmdVariant);
	createCommand(ti, CmdVariation,		cmdVariation);
	createCommand(ti, CmdVerify,			cmdVerify);
	createCommand(ti, CmdView,				cmdView);
}

} // namespace game
} // namespace tcl

// vi:set ts=3 sw=3:
