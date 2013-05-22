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

#include "cql_position.h"
#include "cql_relation.h"
#include "cql_designator.h"
#include "cql_piece_type_designator.h"
#include "cql_match.h"
#include "cql_match_board.h"
#include "cql_match_move.h"
#include "cql_match_info.h"

#include "db_board.h"
#include "db_board_base.h"

#include "m_auto_ptr.h"
#include "m_string.h"
#include "m_algorithm.h"
#include "m_type_traits.h"

#include <ctype.h>
#include <stdlib.h>

using namespace cql;
using namespace cql::error;
using namespace cql::transformation;
using namespace db;
using namespace db::color;


template <class Iterator>
inline
static void
deleteAll(Iterator first, Iterator last)
{
	for ( ; first != last; ++first)
		delete *first;
}


namespace {

typedef char const* (Position::*PosMeth)(Match& match, char const* s, error::Type& error);

struct PosPair
{
	PosPair(char const* s, PosMeth f) :keyword(s), func(f) {}

	bool operator<(mstl::string const& s) const { return keyword < s; }

	mstl::string	keyword;
	PosMeth			func;
};


struct Adaptor : public cql::board::Match
{
	Adaptor(cql::info::Match* match) :m_match(match) {}
	~Adaptor() { delete m_match; }

	bool match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
	{
		return m_match->match(info, variant, 0); // game number not required
	}

	cql::info::Match* m_match;
};

} // namespace


namespace mstl {

static inline
bool
operator<(mstl::string const& lhs, PosPair const& rhs)
{
	return lhs < rhs.keyword;
}

} // namespace mstl


namespace logical {

struct Match : virtual public cql::move::Match, virtual public cql::board::Match
{
	typedef mstl::vector<Position*> PositionList;
	typedef db::Board Board;
	typedef variant::Type Variant;

	~Match() { ::deleteAll(m_list.begin(), m_list.end()); }

	Position& pushBack()
	{
		m_list.push_back();
		return *m_list.back();
	}

	PositionList m_list;
};


struct And : public Match
{
	bool match(	GameInfo const& info,
					Board const& board,
					Variant variant,
					unsigned flags) override
	{
		PositionList::iterator i = m_list.begin();
		PositionList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, board, variant, flags))
				return false;
		}

		return true;
	}

	bool match(Board const& board, Move const& move, Variant variant) override
	{
		PositionList::iterator i = m_list.begin();
		PositionList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(board, move, variant))
				return false;
		}

		return true;
	}
};


struct Or : public Match
{
	bool match(	GameInfo const& info,
					Board const& board,
					Variant variant,
					unsigned flags) override
	{
		PositionList::iterator i = m_list.begin();
		PositionList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if ((*i)->match(info, board, variant, flags))
				return true;
		}

		return false;
	}

	bool match(Board const& board, Move const& move, Variant variant) override
	{
		PositionList::iterator i = m_list.begin();
		PositionList::iterator e = m_list.end();

		for ( ; i != e; ++i)
		{
			if ((*i)->match(board, move, variant))
				return true;
		}

		return false;
	}
};

} // namespace logical


static bool
isDelim(char c)
{
	return isspace(c) || c == '\0' || c == '(' || c == ')' || c == ';';
}


static char const*
skipToDelim(char const* s)
{
	while (!isDelim(*s))
		++s;

	return s;
}


static char const*
skipSpaces(char const* s)
{
	while (isspace(*s))
		++s;

	if (*s == ';')
	{
		// skip comment
		while (*s != '\n' && *s != '\0')
			++s;

		while (isspace(*s))
			++s;
	}

	return s;
}


static unsigned
lengthOfKeyword(char const* s)
{
	char const* t = s;

	while (isalpha(*t))
		++t;

	return t - s;
}


static char const*
parseSequence(cql::board::GappedSequence& seq, Match& match, char const* s, error::Type& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Keyword_Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));

	if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
	{
		error = Keyword_Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	do
	{
		s = seq.pushBack().parse(match, s, error);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);

		if (*s != '(' && *s != ')')
		{
			error = Keyword_Position_Expected;
			return s;
		}
	}
	while (*s != ')');

	return s;
}


static char const*
parseRange(char const* s, error::Type& error, float& lower, float& upper)
{
	char *e;

	lower = strtof(s, &e);

	if (s == e || !isDelim(*s))
	{
		error = Invalid_Range_Argument;
	}
	else
	{
		upper = strtof(s = skipSpaces(e), &e);

		if (s == e || !isDelim(*s))
			error = Invalid_Range_Argument;
	}

	return s;
}


Position::Position()
	:m_relation(0)
	,m_cutExpression(0)
	,m_designators(new cql::board::Designators)
	,m_state(0)
	,m_finalState(0)
	,m_includeMainline(true)
	,m_includeVariations(false)
	,m_not(false)
	,m_preceding(false)
	,m_matchCount(0)
	,m_minMatchCount(1)
	,m_maxMatchCount(1)
	,m_minMoveNumber(0)
	,m_maxMoveNumber(unsigned(-1))
	,m_transformations(0)
{
}


Position::~Position()
{
	delete m_designators;
	delete m_relation;
	::deleteAll(m_boardMatchList.begin(), m_boardMatchList.end());
	::deleteAll(m_moveMatchList.begin(), m_moveMatchList.end());
}


bool
Position::doMatch(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (m_cutExpression && m_cutExpression->match(info, board, variant, flags))
	{
		m_cutFunc();

		if (m_cutExpression->m_preceding)
			return false;
	}

	if (m_finalState)
	{
		if (!m_finalState->match(info, board, variant, flags))
			return m_not;
	}

	if (!m_designators->match(info, board, variant, flags))
		return m_not;

	{
		BoardMatchList::iterator i = m_boardMatchList.begin();
		BoardMatchList::iterator e = m_boardMatchList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, board, variant, flags))
			{
				static_assert(
					(mstl::is_convertible<cql::board::GappedSequence, cql::board::Sequence>::value),
					"we have to check both, Sequence and GappedSequence");

				if (m_not && dynamic_cast<cql::board::GappedSequence const*>(*i))
					return false;

				return m_not;
			}
		}
	}

	{
		PositionList::iterator i = m_positionList.begin();
		PositionList::iterator e = m_positionList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, board, variant, flags))
				return m_not;
		}
	}

	return !m_not;
}


bool
Position::doMatch(Board const& board, Move const& move, Variant variant)
{
	MoveMatchList::iterator i = m_moveMatchList.begin();
	MoveMatchList::iterator e = m_moveMatchList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(board, move, variant))
			return m_not;
	}

	{
		PositionList::iterator i = m_positionList.begin();
		PositionList::iterator e = m_positionList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(board, move, variant))
				return m_not;
		}
	}

	return !m_not;
}


bool
Position::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	bool match = doMatch(info, board, variant, flags);

	if (match)
		++m_matchCount;

	if (m_relation && !m_relation->match(board, false)) // XXX set parameter insideVariation
		return m_not;

	if (flags & flags::IsFinalPosition)
		return m_minMatchCount <= m_matchCount && m_matchCount <= m_maxMatchCount;

	return m_matchCount >= m_maxMatchCount;
}


bool
Position::match(Board const& board, Move const& move, Variant variant)
{
	unsigned moveNumber = board.moveNumber();

	if (m_minMoveNumber > moveNumber || moveNumber > m_maxMoveNumber)
		return m_not;

	return doMatch(board, move, variant);
}


char const*
Position::adopt(Match& match, char const* s, Error& error)
{
	if (error == No_Error)
	{
		M_ASSERT(!match.m_matchGameInfoList.empty());
		m_boardMatchList.push_back(new Adaptor(match.m_matchGameInfoList.back()));
		match.m_matchGameInfoList.erase(match.m_matchGameInfoList.end() - 1);
	}

	return s;
}


void
Position::toggleNot()
{
	m_not = !m_not;
}


char const*
Position::parseAccumulate(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parseAnd(Match& match, char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Keyword_Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));

	if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
	{
		error = Keyword_Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	mstl::auto_ptr<logical::And> list(new logical::And);

	do
	{
		s = list->pushBack().parse(match, s, error);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);

		if (*s != '(' && *s != ')')
		{
			error = Keyword_Position_Expected;
			return s;
		}
	}
	while (*s != ')');

	m_boardMatchList.push_back(list.release());
	return s + 1;
}


char const*
Position::parseAttackCount(Match& match, char const* s, Error& error)
{
	Designator fst;
	Designator snd;

	s = fst.parse(s, error);

	if (error != No_Error)
		return s;

	s = snd.parse(s, error);

	if (error != No_Error)
		return s;

	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
		return s;
	}

	char* e;
	unsigned min = ::strtoul(s, &e, 10);
	s = ::skipSpaces(e);

	unsigned max = min;

	if (::isdigit(*s))
	{
		max = ::strtoul(s, &e, 10);
		s = e;
	}

	m_boardMatchList.push_back(new cql::board::AttackCount(fst, snd, min, max));
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseBlackCannotWin(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::CannotWin(color::Black));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseBlackElo(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseBlackElo(s, error), error);
}


char const*
Position::parseBlackRating(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseBlackRating(s, error), error);
}


char const*
Position::parseBlackToMove(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::ToMove(Black));
	return s;
}


char const*
Position::parseCastling(Match& match, char const* s, Error& error)
{
	PieceTypeDesignator designator;
	char const* t = designator.parse(s, error);

	if (error == No_Error)
	{
		PieceTypeDesignator::Pieces pieces = designator.pieces();

		pieces.reset(cql::piece::WK);
		pieces.reset(cql::piece::BK);
		pieces.reset(cql::piece::WQ);
		pieces.reset(cql::piece::BQ);

		if (pieces.count() > 0)
		{
			error = Invalid_Designator;
		}
		else
		{
			m_boardMatchList.push_back(new cql::board::Castling(designator));
			s = t;
		}
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseCut(Match& match, char const* s, Error& error)
{
	char const* t = ::skipSpaces(s);

	if (*t == '(')
	{
		mstl::auto_ptr<Position> pos(new Position);

		s = pos->parse(match, t, error);
		pos->m_cutFunc = CutFunc(&Match::cut, &match);

		if (error == No_Error)
			m_positionList.push_back(pos.release());

	}
	else
	{
		m_cutFunc = CutFunc(&Match::cut, &match);
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseIsCastling(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new cql::move::IsCastling);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::Check);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseCheckCount(Match& match, char const* s, Error& error)
{
	s = ::skipSpaces(s);

	if (isdigit(*s))
	{
		char* e;
		unsigned count = ::strtoul(s, &e, 10);

		if (count > 3)
			error = Integer_Out_Of_Range;
		else
			m_boardMatchList.push_back(new cql::board::CheckCount(count));
	}
	else if (*s == '+')
	{
		char* e;
		unsigned wcount = ::strtoul(s, &e, 10);

		if (wcount > 3)
		{
			error = Integer_Out_Of_Range;
		}
		else
		{
			s = e;

			if (*s == '+')
			{
				unsigned bcount = ::strtoul(s, &e, 10);

				if (bcount > 3)
				{
					error = Integer_Out_Of_Range;
				}
				else
				{
					s = e;
					m_boardMatchList.push_back(new cql::board::CheckCount(wcount, bcount));
				}
			}
			else
			{
				error = Positive_Integer_Expected;
			}
		}
	}
	else
	{
		error = Positive_Integer_Expected;
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseContactCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::ContactCheck);
	match.m_isStandard = false;
	return s;
}


char const*
Position::parseDoubleCheck(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new cql::board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::DoubleCheck);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseElo(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseElo(s, error), error);
}


char const*
Position::parseEndGame(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::EndGame);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseEndmost(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parseEnPassant(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new cql::move::EnPassant);
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseEvaluation(Match& match, char const* s, Error& error)
{
	char const *t = ::skipToDelim(s);
	mstl::string mode(s, t);

	if (mode != "depth" && mode != "movetime")
	{
		error = Invalid_Evaluation_Mode;
		return s;
	}

	s = ::skipSpaces(t);

	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
		return s;
	}

	char* e;
	unsigned n = ::strtoul(s, &e, 10);

	if (n == 0)
	{
		error = Integer_Out_Of_Range;
		return s;
	}

	cql::board::Evaluation::Mode emode = mode == "depth" ? cql::Engine::Depth : cql::Engine::MoveTime;

	s = ::skipSpaces(s);

	if (::isdigit(*s) || *s == '.')
	{
		float lower, upper;
		s = ::parseRange(s, error, lower, upper);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);
		t = ::skipToDelim(s);
		mstl::string stm(s, t);

		if (stm != "sidetomove" && stm != "absolute")
		{
			error = Invalid_Evaluation_View;
			return s;
		}

		s = t;

		cql::board::Evaluation::View view;

		if (stm == "sidetomove")
			view = cql::board::Evaluation::SideToMove;
		else
			view = cql::board::Evaluation::Absolute;

		m_boardMatchList.push_back(
			new cql::board::Evaluation(Engine::Score, emode, n, lower, upper, view));
	}
	else if (::strncmp(s, "mate", 4) == 0 && ::isDelim(s[4]))
	{
		m_boardMatchList.push_back(new cql::board::Evaluation(Engine::Mate, emode, n));
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseExclude(Match& match, char const* s, Error& error)
{
	// TODO
	match.m_isStandard = false;
	return s;
}


char const*
Position::parseExchangeEvaluation(Match& match, char const* s, Error& error)
{
	int min, max;
	s = parseSignedRange(s, error, min, max);
	if (error == No_Error)
		m_moveMatchList.push_back(new cql::move::ExchangeEvaluation(min, max));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseFen(Match& match, char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);
	Variant variant = variant::Normal;

	mstl::string fen(s, t);
	Board board;

	if (	board.setup(s, variant::ThreeCheck)
		&& (board.checksGiven(White) > 0 || board.checksGiven(Black) > 0))
	{
		variant = variant::ThreeCheck;
	}
	else if (	board.setup(s, variant::Crazyhouse)
				&& (board.holding(White).total() + board.holding(Black).total() > 0))
	{
		variant = variant::Crazyhouse;
	}
	else if (!Board::isValidFen(s, variant::Normal) && Board::isValidFen(s, variant::Suicide))
	{
		variant = variant::Suicide;
	}

	if (Board::isValidFen(s, variant))
	{
		char const* p = board.setup(fen, variant);

		if (p == fen.end())
		{
			m_boardMatchList.push_back(new cql::board::Fen(board));
			s = t;
		}
		else
		{
			error = Invalid_Fen;
		}
	}
	else
	{
		error = Invalid_Fen;
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseFiftyMoveRule(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::FiftyMoveRule);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseFlipColor(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip_Color;
	return s;
}


char const*
Position::parseFlipDiagonal(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip_Diagonal;
	return s;
}


char const*
Position::parseFlipDihedral(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip;
	return s;
}


char const*
Position::parseFlipHorizontal(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip_Horizontal;
	return s;
}


char const*
Position::parseFlipOffDiagonal(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip_Off_Diagonal;
	return s;
}


char const*
Position::parseFlipVertical(Match& match, char const* s, Error& error)
{
	m_transformations |= Flip_Vertical;
	return s;
}


char const*
Position::parseFollowing(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parseGameIsOver(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new cql::board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::Checkmate | Board::ThreeChecks | Board::Stalemate | Board::Losing);
	m_boardMatchList.push_back(new cql::board::MatingMaterial(true));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseGappedSequence(Match& match, char const* s, Error& error)
{
	mstl::auto_ptr<cql::board::GappedSequence> seq(new cql::board::GappedSequence);
	::parseSequence(*seq, match, s, error);
	if (error == No_Error)
		m_boardMatchList.push_back(seq.release());
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseHalfmoveClockLimit(Match& match, char const* s, Error& error)
{
	s = ::skipSpaces(s);

	if (::isdigit(*s))
	{
		char* e;
		unsigned limit = ::strtoul(s, &e, 10);

		if (limit == 0)
		{
			error = Integer_Out_Of_Range;
		}
		else
		{
			s = e;
			m_boardMatchList.push_back(new cql::board::HalfmoveClockLimit(limit));
		}
	}
	else
	{
		error = Positive_Integer_Expected;
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseInitial(Match& match, char const* s, Error& error)
{
	match.setInitial();
	return s;
}


char const*
Position::parseInside(Match& match, char const* s, Error& error)
{
	// TODO
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseLosing(Match& match, char const* s, Error& error)
{
	if (m_finalState == 0)
		m_finalState = new cql::board::State;

	m_finalState->add(Board::Losing);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseMarkAll(Match& match, char const* s, Error& error)
{
	return s; // ignore
}


char const*
Position::parseMatchCount(Match& match, char const* s, Error& error)
{
	return parseUnsignedRange(s, error, m_minMatchCount, m_maxMatchCount);
}


char const*
Position::parseMate(Match& match, char const* s, Error& error)
{
	if (m_finalState == 0)
		m_finalState = new cql::board::State;

	m_finalState->add(Board::Checkmate);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseMatingMaterial(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::MatingMaterial(false));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseMaxSwapEvaluation(Match& match, char const* s, Error& error)
{
	Designator from;
	s = from.parse(s, error);

	if (error == No_Error)
	{
		Designator to;
		s = to.parse(s, error);

		if (error == No_Error)
		{
			int min, max;
			s = parseSignedRange(s, error, min, max);

			if (error == No_Error)
				m_boardMatchList.push_back(new cql::board::MaxSwapEvaluation(from, to, min, max));
		}
	}

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseMoveEvaluation(Match& match, char const* s, Error& error)
{
	Designator from, to;

	s = from.parse(s, error);

	if (error != No_Error)
		return s;

	s = to.parse(::skipSpaces(s), error);

	if (error != No_Error)
		return s;

	char const *t = ::skipToDelim(::skipSpaces(s));
	mstl::string mode(s, t);

	if (mode != "depth" && mode != "movetime")
	{
		error = Invalid_Evaluation_Mode;
		return s;
	}

	s = ::skipSpaces(t);

	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
		return s;
	}

	char* e;
	unsigned n = ::strtoul(s, &e, 10);

	if (n == 0)
	{
		error = Integer_Out_Of_Range;
		return s;
	}

	float lower, upper;
	s = ::parseRange(s, error, lower, upper);

	if (error != No_Error)
		return s;

	s = ::skipSpaces(s);
	t = ::skipToDelim(s);
	mstl::string stm(s, t);

	if (stm != "sidetomove" && stm != "absolute")
	{
		error = Invalid_Evaluation_View;
		return s;
	}

	s = t;

	cql::move::MoveEvaluation::Mode emode;
	cql::move::MoveEvaluation::View view;

	if (mode == "depth")
		emode = cql::Engine::Depth;
	else
		emode = cql::Engine::MoveTime;

	if (stm == "sidetomove")
		view = cql::move::MoveEvaluation::SideToMove;
	else
		view = cql::move::MoveEvaluation::Absolute;

	m_moveMatchList.push_back(new cql::move::MoveEvaluation(emode, n, from, to, lower, upper, view));

	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseMoveFrom(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new cql::move::MoveFrom(designator));
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseMoveNumber(Match& match, char const* s, Error& error)
{
	return parseUnsignedRange(s, error, m_minMoveNumber, m_maxMoveNumber);
}


char const*
Position::parseMoveTo(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new cql::move::MoveTo(designator));
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseNoAnnotate(Match& match, char const* s, Error& error)
{
	return s; // nothing to do
}


char const*
Position::parseNoCastling(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new cql::move::NoCastling);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseNoCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::NoCheck);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoContactCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::NoContactCheck);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoDoubleCheck(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new cql::board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->sub(Board::DoubleCheck);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoEndGame(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::NoEndGame);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoEnpassant(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new cql::move::NoEnPassant);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseNoMate(Match& match, char const* s, Error& error)
{
	if (m_finalState == 0)
		m_finalState = new cql::board::State;

	m_finalState->sub(Board::Checkmate);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoMatingMaterial(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::MatingMaterial(true));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNoStalemate(Match& match, char const* s, Error& error)
{
	if (m_finalState == 0)
		m_finalState = new cql::board::State;

	m_finalState->sub(Board::Stalemate);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseNot(Match& match, char const* s, Error& error)
{
	char const* t = ::skipSpaces(s);

	if (*t == '(')
	{
		mstl::auto_ptr<Position> pos(new Position);

		s = pos->parse(match, t, error);
		pos->toggleNot();

		if (error == No_Error)
			m_positionList.push_back(pos.release());

		match.m_isStandard = false;
	}
	else
	{
		m_not = !m_not;
	}

	return s;
}


char const*
Position::parseOr(Match& match, char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Keyword_Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));

	if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
	{
		error = Keyword_Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	mstl::auto_ptr<logical::Or> list(new logical::Or);

	do
	{
		s = list->pushBack().parse(match, s, error);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);

		if (*s != '(' && *s != ')')
		{
			error = Keyword_Position_Expected;
			return s;
		}
	}
	while (*s != ')');

	m_boardMatchList.push_back(list.release());
	return s + 1;
}


char const*
Position::parsePieceCount(Match& match, char const* s, Error& error)
{
	Designator designator;

	s = designator.parse(s, error);

	if (error == No_Error)
	{
		unsigned min, max;
		s = parseUnsignedRange(s, error, min, max);
		m_boardMatchList.push_back(new cql::board::PieceCount(designator, min, max));
	}

	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parsePieceDrop(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new cql::move::PieceDrop(designator));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parsePower(Match& match, char const* s, Error& error)
{
	Designator designator;

	s = designator.parse(s, error);

	if (error == No_Error)
	{
		unsigned min, max;
		s = parseUnsignedRange(s, error, min, max);
		m_boardMatchList.push_back(new cql::board::Power(designator, min, max));
	}

	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parsePowerDifference(Match& match, char const* s, Error& error)
{
	Designator designator;

	s = designator.parse(s, error);

	if (error == No_Error)
	{
		int min, max;
		s = parseSignedRange(s, error, min, max);
		m_boardMatchList.push_back(new cql::board::PowerDifference(designator, min, max));
	}

	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parsePreceding(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parsePreTransformMatchCount(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parsePromote(Match& match, char const* s, Error& error)
{
	Designator designator;
	char const* t = designator.parse(s, error);

	if (error == No_Error)
	{
		uint64_t pieces = (designator.pieces(White) | designator.pieces(Black))
							 & ~(db::board::RankMask1 | db::board::RankMask8);

		if (pieces)
		{
			error = Invalid_Promotion_Ranks;
		}
		else
		{
			m_moveMatchList.push_back(new cql::move::Promote(designator));
			s = t;
		}
	}

	match.m_sections |= Match::Section_Moves;
	return s;
}


char const*
Position::parseRay(Match& match, char const* s, Error& error, cql::board::MatchRay* ray)
{
	mstl::auto_ptr<cql::board::MatchRay> rayp(ray);

	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s);

	while (*s != ')')
	{
		Designator designator;
		s = designator.parse(s, error);

		if (error == No_Error)
			return s;

		rayp->add(designator);
		s = ::skipSpaces(s);
	}

	s = ::skipSpaces(s + 1);

	if (::isdigit(*s))
	{
		char* e;
		rayp->m_min = ::strtoul(s, &e, 10);
		s = ::skipSpaces(e);

		if (::isdigit(*s))
		{
			rayp->m_max = ::strtoul(s, &e, 10);

			if (rayp->m_min > rayp->m_max)
				mstl::swap(rayp->m_min, rayp->m_max);

			s = e;
		}
	}

	m_boardMatchList.push_back(rayp.release());
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseRay(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::Ray);
}


char const*
Position::parseRayAttack(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::RayAttack);
}


char const*
Position::parseRayDiagonal(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::RayDiagonal);
}


char const*
Position::parseRayHorizontal(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::RayHorizontal);
}


char const*
Position::parseRayOrthogonal(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::RayOrthogonal);
}


char const*
Position::parseRayVertical(Match& match, char const* s, Error& error)
{
	return parseRay(match, s, error, new cql::board::RayVertical);
}


char const*
Position::parseRelation(Match& match, char const* s, Error& error)
{
	if (m_relation == 0)
		m_relation = new Relation;

	return m_relation->parse(s, error);
}


char const*
Position::parseRepetition(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::Repetition);
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseReset(Match& match, char const* s, Error& error)
{
	// TODO
	match.m_isStandard = false;
	return s;
}


char const*
Position::parseResult(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseResult(s, error), error);
}


char const*
Position::parseSequence(Match& match, char const* s, Error& error)
{
	mstl::auto_ptr<cql::board::Sequence> seq(new cql::board::Sequence);
	::parseSequence(*seq, match, s, error);
	if (error == No_Error)
		m_boardMatchList.push_back(seq.release());
	return s + 1;
}


char const*
Position::parseShift(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift;
	return s;
}


char const*
Position::parseShiftDiagonal(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift_Diagonal;
	return s;
}


char const*
Position::parseShiftHorizontal(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift_Horizontal;
	return s;
}


char const*
Position::parseShiftMainDiagonal(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift_Main_Diagonal;
	return s;
}


char const*
Position::parseShiftOffDiagonal(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift_Off_Diagonal;
	return s;
}


char const*
Position::parseShiftVertical(Match& match, char const* s, Error& error)
{
	m_transformations |= Shift_Vertical;
	return s;
}


char const*
Position::parseStalemate(Match& match, char const* s, Error& error)
{
	if (m_finalState == 0)
		m_finalState = new cql::board::State;

	m_finalState->add(Board::Stalemate);
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseSumRange(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Position::parseTagMatch(Match& match, char const* s, Error& error)
{
	// TODO
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseTerminal(Match& match, char const* s, Error& error)
{
	match.setFinal();
	match.m_isStandard = false;
	return s;
}


char const*
Position::parseVariant(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseVariant(s, error), error);
}


char const*
Position::parseVariations(Match& match, char const* s, Error& error)
{
	m_includeVariations = true;
	return s;
}


char const*
Position::parseVariationsOnly(Match& match, char const* s, Error& error)
{
	m_includeMainline = false;
	return s;
}


char const*
Position::parseWhiteCannotWin(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::CannotWin(color::White));
	match.m_isStandard = false;
	match.m_sections |= Match::Section_Positions;
	return s;
}


char const*
Position::parseWhiteElo(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseWhiteElo(s, error), error);
}


char const*
Position::parseWhiteRating(Match& match, char const* s, Error& error)
{
	return adopt(match, match.parseWhiteRating(s, error), error);
}


char const*
Position::parseWhiteToMove(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new cql::board::ToMove(White));
	return s;
}


Position*
Position::makeLogicalAnd(Match& match, char const*& s, Error& error)
{
	mstl::auto_ptr<Position> pos(new Position);
	s = pos->parseAnd(match, s, error);
	return pos.release();
}


Position*
Position::makeLogicalOr(Match& match, char const*& s, Error& error)
{
	mstl::auto_ptr<Position> pos(new Position);
	s = pos->parseOr(match, s, error);
	return pos.release();
}


char const*
Position::parse(Match& match, char const* s, Error& error)
{
	typedef PosPair Pair;

	static Pair const Trampolin[] =
	{
		Pair("accumulate",					&Position::parseAccumulate),
		Pair("and",								&Position::parseAnd),
		Pair("attackcount",					&Position::parseAttackCount),
		Pair("blackcannotwin",				&Position::parseBlackCannotWin),
 		Pair("blackelo",						&Position::parseBlackElo),
 		Pair("blackrating",					&Position::parseBlackRating),
		Pair("btm",								&Position::parseBlackToMove),
		Pair("castling",						&Position::parseCastling),
		Pair("cut",								&Position::parseCut),
		Pair("check",							&Position::parseCheck),
		Pair("checkcount",					&Position::parseCheckCount),
		Pair("contactcheck",					&Position::parseContactCheck),
		Pair("doublecheck",					&Position::parseDoubleCheck),
	 	Pair("elo",								&Position::parseElo),
		Pair("endgame",						&Position::parseEndGame),
		Pair("endmost",						&Position::parseEndmost),
		Pair("enpassant",						&Position::parseEnPassant),
		Pair("evaluation",					&Position::parseEvaluation),
		Pair("exchangeevaluation",			&Position::parseExchangeEvaluation),
		Pair("exclude",						&Position::parseExclude),
		Pair("fen",								&Position::parseFen),
		Pair("fiftymoverule",				&Position::parseFiftyMoveRule),
		Pair("flip",							&Position::parseFlipDihedral),
		Pair("flipcolor",						&Position::parseFlipColor),
		Pair("flipdiagonal",					&Position::parseFlipDiagonal),
		Pair("flipdihedral",					&Position::parseFlipDihedral),
		Pair("fliphorizontal",				&Position::parseFlipHorizontal),
		Pair("flipoffdiagonal",				&Position::parseFlipOffDiagonal),
		Pair("flipvertical",					&Position::parseFlipVertical),
		Pair("following",						&Position::parseFollowing),
		Pair("gameisover",					&Position::parseGameIsOver),
		Pair("gappedsequence",				&Position::parseGappedSequence),
		Pair("halfmoveclocklimit",			&Position::parseHalfmoveClockLimit),
		Pair("initial",						&Position::parseInitial),
		Pair("inside",							&Position::parseInside),
		Pair("iscastling",					&Position::parseIsCastling),
		Pair("losing",							&Position::parseLosing),
		Pair("markall",						&Position::parseMarkAll),
		Pair("matchcount",					&Position::parseMatchCount),
		Pair("mate",							&Position::parseMate),
		Pair("matingmaterial",				&Position::parseMatingMaterial),
		Pair("maxswapevaluation",			&Position::parseMaxSwapEvaluation),
		Pair("movefrom",						&Position::parseMoveFrom),
		Pair("movenumber",					&Position::parseMoveNumber),
		Pair("moveto",							&Position::parseMoveTo),
		Pair("noannotate",					&Position::parseNoAnnotate),
		Pair("nocastling",					&Position::parseNoCastling),
		Pair("nocheck",						&Position::parseNoCheck),
		Pair("nocontactcheck",				&Position::parseNoContactCheck),
		Pair("nodoublecheck",				&Position::parseNoDoubleCheck),
		Pair("noendgame",						&Position::parseNoEndGame),
		Pair("noenpassant",					&Position::parseNoEnpassant),
		Pair("nomate",							&Position::parseNoMate),
		Pair("nomatingmaterial",			&Position::parseNoMatingMaterial),
		Pair("nostalemate",					&Position::parseNoStalemate),
		Pair("not",								&Position::parseNot),
		Pair("or",								&Position::parseOr),
		Pair("piececount",					&Position::parsePieceCount),
		Pair("piecedrop",						&Position::parsePieceDrop),
		Pair("power",							&Position::parsePower),
		Pair("powerdifference",				&Position::parsePowerDifference),
		Pair("preceding",						&Position::parsePreceding),
		Pair("pretransformmatchcount",	&Position::parsePreTransformMatchCount),
		Pair("promote",						&Position::parsePromote),
		Pair("ray",								&Position::parseRay),
		Pair("rayattack",						&Position::parseRayAttack),
		Pair("raydiagonal",					&Position::parseRayDiagonal),
		Pair("rayhorizontal",				&Position::parseRayHorizontal),
		Pair("rayorthogonal",				&Position::parseRayOrthogonal),
		Pair("rayvertical",					&Position::parseRayVertical),
		Pair("relation",						&Position::parseRelation),
		Pair("repetition",					&Position::parseRepetition),
		Pair("reset",							&Position::parseReset),
 		Pair("result",							&Position::parseResult),
		Pair("sequence",						&Position::parseSequence),
		Pair("shift",							&Position::parseShift),
		Pair("shiftdiagonal",				&Position::parseShiftDiagonal),
		Pair("shifthorizontal",				&Position::parseShiftHorizontal),
		Pair("shiftmaindiagonal",			&Position::parseShiftMainDiagonal),
		Pair("shiftoffdiagonal",			&Position::parseShiftOffDiagonal),
		Pair("shiftvertical",				&Position::parseShiftVertical),
		Pair("stalemate",						&Position::parseStalemate),
		Pair("sumrange",						&Position::parseSumRange),
		Pair("tagmatch",						&Position::parseTagMatch),
		Pair("terminal",						&Position::parseTerminal),
		Pair("variant",						&Position::parseVariant),
		Pair("variations",					&Position::parseVariations),
		Pair("variationsonly",				&Position::parseVariationsOnly),
		Pair("whitecannotwin",				&Position::parseWhiteCannotWin),
 		Pair("whiteelo",						&Position::parseWhiteElo),
 		Pair("whiterating",					&Position::parseWhiteRating),
		Pair("wtm",								&Position::parseWhiteToMove),
	};

	mstl::string key;

	error = No_Error;

	do
	{
		match.m_isStandard = true;
		s = ::skipSpaces(s);

		if (*s == ')')
		{
			// empty position: match all
			s = ::skipSpaces(s + 1);
		}
		else if (*s == ':')
		{
			mstl::string key(s + 1, ::lengthOfKeyword(s + 1));
			Pair const* p = mstl::binary_search(Trampolin, Trampolin + U_NUMBER_OF(Trampolin), key);

			if (p == Trampolin + U_NUMBER_OF(Trampolin))
			{
				error = Invalid_Keyword;
				return s;
			}

			char const* t = (this->*p->func)(match, ::skipSpaces(s + key.size() + 1), error);

			if (error != No_Error)
				return t;

			if (!match.m_isStandard)
				match.m_ranges.push_back(mstl::make_pair(s, t));

			s = ::skipSpaces(t);
		}
		else if (*s)
		{
			Designator designator;
			s = designator.parse(s, error);
			if (error == No_Error)
				m_designators->add(designator);
		}
	}
	while (*s && error == No_Error);

	if (!match.m_ranges.empty())
		match.m_isStandard = false;

	return s;
}


void
Position::reset()
{
	if (m_relation)
		m_relation->reset();

	m_matchCount = 0;

	PositionList::iterator i = m_positionList.begin();
	PositionList::iterator e = m_positionList.end();

	for ( ; i != e; ++i)
		(*i)->reset();
}


void
Position::finish(Match& match)
{
	// m_boardMatchList;
	// m_moveMatchList;
	// m_positionList;
	// m_designators;

	if (m_transformations == 0)
		return;

	mstl::auto_ptr<Position> flipped;

	if ((m_transformations & (Flip | Shift | Flip_Color)) == (Flip | Shift | Flip_Color))
	{
	}

	if (m_transformations & Flip_Color)
	{
		flipped.reset(new Position(*this));

//		BoardMatchList::iterator i = flipped->m_boardMatchList.begin();
//		BoardMatchList::iterator e = flipped->m_boardMatchList.end();

//		for ( ; i != e; ++i)
//			(*i)->flipcolor();
	}

	if (m_transformations & Flip_Vertical)
	{
	}

	if (m_transformations & Flip_Horizontal)
	{
	}
}


char const*
Position::parseUnsignedRange(char const* s, Error& error, unsigned& min, unsigned& max)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;

		min = ::strtoul(s, &e, 10);

		s = ::skipSpaces(e);

		if (!::isdigit(*s))
		{
			error = Positive_Integer_Expected;
		}
		else
		{
			max = ::strtoul(s, &e, 10);

			if (min > max)
				mstl::swap(min, max);

			s = e;
		}
	}

	return s;
}


char const*
Position::parseSignedRange(char const* s, Error& error, int& min, int& max)
{
	if (!::isdigit(s[0]) && ((s[0] != '-' && s[1] != '+') || !::isdigit(s[1])))
	{
		error = Integer_Expected;
	}
	else
	{
		char* e;
		int sign;

		if (*s == '-')
		{
			sign = -1;
			++s;
		}
		else if (*s == '+')
		{
			sign = 1;
			++s;
		}
		else
		{
			sign = 1;
		}

		min = sign*::strtoul(s, &e, 10);
		s = ::skipSpaces(e);

		if (!::isdigit(s[0]) && ((s[0] != '-' && s[1] != '+') || !::isdigit(s[1])))
		{
			error = Integer_Expected;
		}
		else
		{
			if (*s == '-')
			{
				sign = -1;
				++s;
			}
			else if (*s == '+')
			{
				sign = 1;
				++s;
			}
			else
			{
				sign = 1;
			}

			max = sign*::strtoul(s, &e, 10);

			if (min > max)
				mstl::swap(min, max);

			s = e;
		}
	}

	return s;
}

// vi:set ts=3 sw=3:
