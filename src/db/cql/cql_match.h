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

#ifndef _cql_match_included
#define _cql_match_included

#include "cql_common.h"

#include "m_match.h"
#include "m_list.h"
#include "m_vector.h"
#include "m_pair.h"

namespace db
{
	class GameInfo;
	class Board;
	class Move;
}

namespace cql {

namespace info { class Match; }

class Position;

class Match
{
public:

	enum Section
	{
		Section_None		= 0,
		Section_GameInfo	= 1 << 0,
		Section_Moves		= 1 << 1,
		Section_Positions	= 1 << 2,
		Section_Comments	= 1 << 3,
		Section_Flags		= 1 << 4,
	};

	typedef mstl::pair<char const*, char const*> Range;
	typedef mstl::vector<Range> Ranges;
	typedef error::Type Error;

	Match();
	~Match();

	// Returns the affected sections for this search.
	// May be zero if search is empty.
	unsigned sections() const;

	// Returns whether given expression complies with CQL standard.
	bool isStandard() const;

	// Use this method after match of initial board position. Returns false if never matching.
	bool proceed() const;

	// Returns true if any comment should be matched.
	// Do only use if comment section is involved.
	bool matchComments() const;

	// Use this method only if any comment should be matched.
	// Do only use if comment section is involved.
	bool matchComments(char const* data, unsigned length);

	// Use this method at start of game. Returns false if never matching.
	// Do only use if game information section is involved.
	bool match(db::GameInfo const& info, db::variant::Type variant, unsigned gameNo);

	// Use this method for intial board and each board position after making
	// a move. Set parameter 'isFinal' to true only for final board position.
	// Do only use if board (position) section is involved.
	bool match(db::GameInfo const& info, db::Board const& board, db::variant::Type variant, bool isFinal);

	// Use this method before matching board position after move.
	// Do only use if move section is involved.
	bool match(db::Board const& board, db::Move const& move);

	// Use this method after starting a variation. Returns false if
	// variation cannot match.
	bool beginVariation();

	// Use this method before ending a variation.
	void endVariation();

	// Parse given expression, and either return the string position
	// where first error is detected, or the position after expression.
	char const* parse(char const* s, Error& error);

	// Returns all sub-expressions which do not comply with CQL standard.
	Ranges const& nonStandardRanges() const;

	friend class Position;
	class Logical;

private:

	typedef mstl::list<mstl::pattern> MatchCommentList;
	typedef mstl::vector<info::Match*> MatchGameInfoList;
	typedef mstl::vector<Position*> MatchPositionList;
	typedef mstl::vector<Match::Logical*> MatchLogicalList;

	Match(bool isTopLevel);

	bool doMatchComments(char const* data, unsigned length);
	bool doMatch(db::GameInfo const& info, db::variant::Type variant, unsigned gameNo);

	void reset();
	void setInitial();
	void setFinal();
	void addPosition(Position* position);

	char const* parseAnd(char const* s, Error& error);
	char const* parseAnnotator(char const* s, Error& error);
	char const* parseBirthYear(char const* s, Error& error);
	char const* parseBlackBirthYear(char const* s, Error& error);
	char const* parseBlackCountry(char const* s, Error& error);
	char const* parseBlackDeathYear(char const* s, Error& error);
	char const* parseBlackElo(char const* s, Error& error);
	char const* parseBlackGender(char const* s, Error& error);
	char const* parseBlackIsComputer(char const* s, Error& error);
	char const* parseBlackIsHuman(char const* s, Error& error);
	char const* parseBlackPlayer(char const* s, Error& error);
	char const* parseBlackRating(char const* s, Error& error);
	char const* parseBlackTitle(char const* s, Error& error);
	char const* parseComment(char const* s, Error& error);
	char const* parseCountry(char const* s, Error& error);
	char const* parseDate(char const* s, Error& error);
	char const* parseDeathYear(char const* s, Error& error);
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
	char const* parseIsComputer(char const* s, Error& error);
	char const* parseIsHuman(char const* s, Error& error);
	char const* parseIsShuffleChess(char const* s, Error& error);
	char const* parseIsStandardPosition(char const* s, Error& error);
	char const* parseIsStartPosition(char const* s, Error& error);
	char const* parseLanguage(char const* s, Error& error);
	char const* parseNot(char const* s, Error& error);
	char const* parseOr(char const* s, Error& error);
	char const* parsePlayer(char const* s, Error& error);
	char const* parsePlyCount(char const* s, Error& error);
	char const* parsePosition(char const* s, Error& error);
	char const* parseRating(char const* s, Error& error);
	char const* parseResult(char const* s, Error& error);
	char const* parseRound(char const* s, Error& error);
	char const* parseSite(char const* s, Error& error);
	char const* parseStartPosition(char const* s, Error& error);
	char const* parseTermination(char const* s, Error& error);
	char const* parseTimeMode(char const* s, Error& error);
	char const* parseTitle(char const* s, Error& error);
	char const* parseVariant(char const* s, Error& error);
	char const* parseWhiteBirthYear(char const* s, Error& error);
	char const* parseWhiteCountry(char const* s, Error& error);
	char const* parseWhiteDeathYear(char const* s, Error& error);
	char const* parseWhiteElo(char const* s, Error& error);
	char const* parseWhiteGender(char const* s, Error& error);
	char const* parseWhiteIsComputer(char const* s, Error& error);
	char const* parseWhiteIsHuman(char const* s, Error& error);
	char const* parseWhitePlayer(char const* s, Error& error);
	char const* parseWhiteRating(char const* s, Error& error);
	char const* parseWhiteTitle(char const* s, Error& error);
	char const* parseYear(char const* s, Error& error);

	bool						m_isTopLevel;
	bool						m_not;
	bool						m_initialOnly;
	bool						m_finalOnly;
	bool						m_isStandard;
	unsigned					m_sections;
	unsigned					m_idn;
	MatchLogicalList		m_matchLogicalList;
	MatchGameInfoList		m_matchGameInfoList;
	MatchCommentList		m_matchCommentList;
	MatchPositionList		m_matchPositionList;
	Ranges					m_ranges;
};

} // namespace cql

#include "cql_match.ipp"

#endif // _cql_match_included

// vi:set ts=3 sw=3:
