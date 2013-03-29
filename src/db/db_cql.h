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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _db_cql_included
#define _db_cql_included

#include "db_common.h"
#include "db_date.h"
#include "db_eco.h"

#include "m_list.h"
#include "m_vector.h"
#include "m_string.h"

namespace db {

class GameInfo;
class Board;
class Move;

namespace cql {

enum Error
{
	No_Error,
	Position_Expected,
	Invalid_Keyword,
	Range_Expected,
	Pattern_Expected,
	Positive_Integer_Expected,
	Double_Quote_Expected,
	Unterminated_String,
	Empty_String_Not_Allowed,
	Invalid_Date,
	Illegal_Date,
	Illegal_Date_Offset,
	Invalid_Eco_Code,
	Invalid_Rating_Type,
	Invalid_Country_Code,
	Illegal_Country_Code,
	Invalid_Event_Mode,
	Invalid_Event_Type,
	Invalid_Game_Flag,
	Invalid_Tag_Name,
	Invalid_Gender,
	Invalid_Result,
	Invalid_Termination,
	Invalid_Time_Mode,
	Invalid_Title,
	Invalid_Variant,
	Invalid_Fen,
	Invalid_Promotion_Ranks,
	Integer_Out_Of_Range,
	Unexpected_Token,
	Left_Parenthesis_Expected,
	Right_Parenthesis_Expected,
	Trailing_Characters,
	Keyword_Match_Expected,
	Unmatched_Bracket,
	Empty_Piece_Designator,
	Any_Fyle_Not_Allowed_In_Range,
	Any_Rank_Not_Allowed_In_Range,
	Invalid_Fyle_In_Square_Designator,
	Invalid_Rank_In_Square_Designator,
};


namespace gameinfo { class Match; }


class Match
{
public:

	Match(variant::Type variant);
	~Match();

	bool match(GameInfo const& info, unsigned gameNo);
	bool match(GameInfo const& info, Board const& board, bool isInitial, bool isFinal);
	bool match(Board const& board, Move const& move);

	bool beginVariation();
	void endVariation();

	char const* parse(char const* s, Error& error);

	void setInitial();
	void setFinal();

	class Position;

private:

	typedef mstl::vector<gameinfo::Match*> MatchGameInfoList;
	typedef mstl::list<mstl::string> MatchCommentList;
	typedef mstl::vector<Position*> MatchPositionList;

	char const* parseAnnotator(char const* s, Error& error);
	char const* parseBlackCountry(char const* s, Error& error);
	char const* parseBlackElo(char const* s, Error& error);
	char const* parseBlackGender(char const* s, Error& error);
	char const* parseBlackIsComputer(char const* s, Error& error);
	char const* parseBlackIsHuman(char const* s, Error& error);
	char const* parseBlackPlayer(char const* s, Error& error);
	char const* parseBlackRating(char const* s, Error& error);
	char const* parseBlackTitle(char const* s, Error& error);
	char const* parseComment(char const* s, Error& error);
	char const* parseDate(char const* s, Error& error);
	char const* parseEco(char const* s, Error& error);
	char const* parseElo(char const* s, Error& error);
	char const* parseEvent(char const* s, Error& error);
	char const* parseEventCountry(char const* s, Error& error);
	char const* parseEventDate(char const* s, Error& error);
	char const* parseEventMode(char const* s, Error& error);
	char const* parseEventType(char const* s, Error& error);
	char const* parseForAny(char const* s, Error& error);
	char const* parseGameNumber(char const* s, Error& error);
	char const* parseHasAnnotation(char const* s, Error& error);
	char const* parseHasComments(char const* s, Error& error);
	char const* parseHasFlags(char const* s, Error& error);     
	char const* parseHasVariations(char const* s, Error& error);
	char const* parseIsChess960(char const* s, Error& error);
	char const* parseIsShuffleChess(char const* s, Error& error);
	char const* parseLanguage(char const* s, Error& error);
	char const* parsePlayer(char const* s, Error& error);
	char const* parsePlyCount(char const* s, Error& error);
	char const* parsePosition(char const* s, Error& error);
	char const* parseRating(char const* s, Error& error);
	char const* parseResult(char const* s, Error& error);
	char const* parseRound(char const* s, Error& error);
	char const* parseSite(char const* s, Error& error);
	char const* parseTermination(char const* s, Error& error);
	char const* parseTimeMode(char const* s, Error& error);
	char const* parseTitle(char const* s, Error& error);
	char const* parseVariant(char const* s, Error& error);
	char const* parseWhiteCountry(char const* s, Error& error);
	char const* parseWhiteElo(char const* s, Error& error);
	char const* parseWhiteGender(char const* s, Error& error);
	char const* parseWhiteIsComputer(char const* s, Error& error);
	char const* parseWhiteIsHuman(char const* s, Error& error);
	char const* parseWhitePlayer(char const* s, Error& error);
	char const* parseWhiteRating(char const* s, Error& error);
	char const* parseWhiteTitle(char const* s, Error& error);
	char const* parseYear(char const* s, Error& error);

	variant::Type		m_variant;
	bool					m_initial;
	bool					m_final;
	MatchGameInfoList	m_matchGameInfoList;
	MatchCommentList	m_matchCommentList;
	MatchPositionList	m_matchPositionList;
};

} // namespace cql
} // namespace db

#endif // _db_cql_included

// vi:set ts=3 sw=3:
