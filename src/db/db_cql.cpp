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

#include "db_cql.h"
#include "db_cql_match.h"
#include "db_board.h"
#include "db_board_base.h"
#include "db_game_info.h"

#include "m_algorithm.h"
#include "m_utility.h"
#include "m_pvector.h"
#include "m_assert.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

using namespace db;
using namespace db::cql;
using namespace db::sq;
using namespace db::color;
using namespace db::board;


template <class Iterator>
inline
static void
deleteAll(Iterator first, Iterator last)
{
	for ( ; first != last; ++first)
		delete *first;
}


static uint64_t
flipdiagonal(uint64_t value)
{
	uint64_t result = 0;

	while (Square sq = lsbClear(value))
	{
		uint64_t bit = setBit(sq);

		int shift = 7*(int(rank(sq)) - int(fyle(sq)));

		if (shift < 0)
			bit <<= -shift;
		else if (shift > 0)
			bit >>= shift;

		result |= setBit(bit);
	}

	return result;
}


static uint64_t
flipoffdiagonal(uint64_t value)
{
	uint64_t result = 0;

	while (Square sq = lsbClear(value))
	{
		uint64_t bit = setBit(sq);

		int shift = 9*(7 - int(rank(sq)) - int(fyle(sq)));

		if (shift < 0)
			bit >>= -shift;
		else if (shift > 0)
			bit <<= shift;

		result |= setBit(bit);
	}

	return result;
}


static uint64_t
flipvertical(uint64_t value)
{
	uint64_t result = 0;

	while (Square sq = lsbClear(value))
		result |= setBit(make(fyle(sq), flipRank(rank(sq))));

	return result;
}


static uint64_t
fliphorizontal(uint64_t value)
{
	uint64_t result = 0;

	while (Square sq = lsbClear(value))
		result |= setBit(make(flipFyle(fyle(sq)), rank(sq)));

	return result;
}


static bool
shift(uint64_t& value, int stepFyle, int stepRank)
{
	uint64_t result= 0;

	while (Square sq = lsbClear(value))
	{
		int f = int(fyle(sq)) + stepFyle;

		if (f < int(FyleA) || int(FyleH) < f)
			return false;

		int r = int(rank(sq)) + stepRank;

		if (r < int(Rank1) || int(Rank8) < r)
			return false;

		result |= setBit(make(Fyle(f), Rank(r)));
	}

	value = result;
	return true;
}


static bool shifthorizontal(uint64_t& value, int step)	{ return shift(value, step, 0); }
static bool shiftvertical(uint64_t& value, int step)		{ return shift(value, 0, step); }
static bool shiftmaindiagonal(uint64_t& value, int step)	{ return shift(value, step, step); }
static bool shiftoffdiagonal(uint64_t& value, int step)	{ return shift(value, -step, step); }


// ------------------------------
// Piece type designators
// ------------------------------
// K white king
// Q white queen
// R white rook
// R white knight
// B white bishop
// P white pawn
// k black king
// q black queen
// r black rook
// r black knight
// b black bishop
// p black pawn
// A any white piece
// a any black piece
// M white major piece
// m black major piece
// I white minor piece
// i black minor piece
// U any piece at all
// . empty square
// ? any piece or an empty square

// Square_Designator		::= ( "[" ( Sequence )? "]" )?
// Sequence					::= ( Range | Extended_Designator ) [ "," Sequence ]
// Range						::= Designator "-" Designator
// Extended_Designator	::= ( Rank | "?" ) ( Fyle | "?" )
// Designator				::= Rank Fyle
// Rank						::= "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h"
// Fyle						::= "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8"

struct Designator
{
	typedef Match::Position Position;

	bool match(Board const& board, variant::Type variant);

	/// Reflect about the main diagonal a1 to h8.
	void flipdiagonal(Position& position) const;
	void flipoffdiagonal(Position& position) const;
	void flipvertical(Position& position) const;
	void fliphorizontal(Position& position) const;
	void flipdihedral(Position& position) const;

	void shifthorizontal(Position& position) const;
	void shiftvertical(Position& position) const;
	void shiftmaindiagonal(Position& position) const;
	void shiftoffdiagonal(Position& position) const;
	void shiftdiagonal(Position& position) const;
	void shift(Position& position) const;

	void flipcolor(Position& position) const;

	char const* parse(char const* s, Error& error);

	typedef uint64_t (*Transform)(uint64_t);
	typedef bool (*Shift)(uint64_t&, int);

	void transform(Position& position, Transform func) const;
	void shift(Position& position, Shift func) const;

	uint64_t pieces(color::ID color) const;
	uint64_t pieces(Board const& board, color::ID color) const;

	char const* parseSequence(char const* s, Error& error, uint64_t& squares);
	char const* parseRange(char const* s, Error& error, uint64_t& squares);

	my::Position m_pos;
};


static bool
match(char const* pattern, char const* s)
{
	while (true)
	{
		switch (*pattern)
		{
			case '\0':
				return *s == '\0';

			case '?':
				if (*s == '\0')
					return false;
				break;

			case '*':
				while (pattern[1] == '*')
					++pattern;
				if (pattern[1] == '\0')
					return true;
				while (*s)
				{
					if (match(pattern + 1, s))
						return true;
					++s;
				}
				return false;

			default:
				if (*pattern != *s)
					return false;
				break;
		}

		++pattern;
		++s;
	}

	return false;
}


inline static unsigned
power(material::Count m, variant::Type variant)
{
	switch (variant)
	{
		case variant::Normal:
		case variant::ThreeCheck:
			return 9*m.queen + 5*m.rook + 3*(m.bishop + m.knight) + m.pawn;

		case variant::Crazyhouse:
		case variant::Bughouse:
			return 5*m.queen + 3*(m.rook + m.bishop + m.knight) + m.pawn;

		case variant::Suicide:
		case variant::Giveaway:
			return 30*m.king + 3*m.queen + 9*(m.rook + m.knight) + m.pawn;

		case variant::Losers:
			return 5*m.queen + 4*(m.rook + m.knight) + 3*m.bishop + m.pawn;

		case variant::Undetermined:
		case variant::Antichess:
			M_ASSERT(!"should not happen");
			return 0;
	}

	return 0; // never reached
}


namespace db {
namespace cql {
namespace gameinfo {

struct Match
{
	virtual ~Match() {}
	virtual bool match(GameInfo const& info, unsigned gameNumber) = 0;
};


struct Annotator : public Match
{
	Annotator(char const* s, char const* e) :m_annotator(s, e) {}

	bool match(GameInfo const& info, unsigned) override
	{
		NamebaseEntry const* annotator = info.annotatorEntry();
		return annotator && ::match(m_annotator, annotator->name());
	}

	mstl::string m_annotator;
};


struct Player : public Match
{
	Player(char const* s, char const* e, color::ID c) :m_player(s, e), m_color(c) {}

	bool match(GameInfo const& info, unsigned) override
	{
		return ::match(m_player, info.playerEntry(m_color)->name());
	}

	mstl::string	m_player;
	color::ID		m_color;
};


struct Event : public Match
{
	Event(char const* s, char const* e) :m_event(s, e) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return ::match(m_event, info.eventEntry()->name());
	}

	mstl::string m_event;
};


struct Site : public Match
{
	Site(char const* s, char const* e) :m_site(s, e) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return ::match(m_site, info.eventEntry()->site()->name());
	}

	mstl::string m_site;
};


struct Rating : public Match
{
	Rating(rating::Type ratingType, uint16_t minScore, uint16_t maxScore, color::ID color)
		:m_ratingType(ratingType)
		,m_color(color)
		,m_minScore(minScore)
		,m_maxScore(maxScore)
	{
	}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		uint16_t rating = info.findRating(m_color, m_ratingType);
		return m_minScore <= rating && rating <= m_maxScore;
	}

	rating::Type	m_ratingType;
	color::ID		m_color;
	uint16_t			m_minScore;
	uint16_t			m_maxScore;
};


struct Date : public Match
{
	Date(::db::Date const& min, ::db::Date const& max) :m_min(min), m_max(max) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		::db::Date date(info.date());
		return m_min <= date && date <= m_max;
	}

	::db::Date m_min;
	::db::Date m_max;
};


struct Eco : public Match
{
	Eco(::db::Eco min, ::db::Eco max) :m_min(min), m_max(max) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		::db::Eco eco(info.eco());
		return m_min <= eco && eco <= m_max;
	}

	::db::Eco m_min;
	::db::Eco m_max;
};


struct EventCountry : public Match
{
	EventCountry(country::Code country) :m_country(country) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_country == info.eventCountry();
	}

	country::Code m_country;
};


struct EventDate : public Match
{
	EventDate(::db::Date const& min, ::db::Date const& max) :m_min(min), m_max(max) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_min <= info.eventDate() && info.eventDate() <= m_max;
	}

	::db::Date m_min;
	::db::Date m_max;
};


struct EventMode : public Match
{
	EventMode(event::Mode mode) :m_mode(mode) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_mode == info.eventMode();
	}

	event::Mode m_mode;
};


struct EventType : public Match
{
	EventType(event::Type type) :m_type(type) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_type == info.eventType();
	}

	event::Type m_type;
};


struct Country : public Match
{
	Country(country::Code country, color::ID color) :m_country(country), m_color(color) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_country == info.federation(m_color);
	}

	country::Code	m_country;
	color::ID		m_color;
};


struct GameNumber : public Match
{
	GameNumber(unsigned number) :m_number(number) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_number == gameNumber;
	}

	unsigned m_number;
};


struct HasAnnotation : public Match
{
	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return info.countAnnotations() > 0;
	}
};


struct HasComments : public Match
{
	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return info.countComments() > 0;
	}
};


struct HasVariation : public Match
{
	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return info.countVariations() > 0;
	}
};


struct GameFlags : public Match
{
	GameFlags(unsigned flags) :m_flags(flags) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return (info.flags() & m_flags) == m_flags;
	}

	unsigned m_flags;
};


struct Gender : public Match
{
	Gender(sex::ID sex, color::ID color) :m_sex(sex), m_color(color) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_sex == info.sex(m_color);
	}

	sex::ID		m_sex;
	color::ID	m_color;
};


struct IsComputer : public Match
{
	IsComputer(color::ID color) :m_color(color) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return info.playerType(m_color) == species::Program;
	}

	color::ID m_color;
};


struct IsHuman : public Match
{
	IsHuman(color::ID color) :m_color(color) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return info.playerType(m_color) == species::Human;
	}

	color::ID m_color;
};


struct IsChess960 : public Match
{
	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return variant::isChess960(info.idn());
	}
};


struct IsShuffleChess : public Match
{
	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return variant::isShuffleChess(info.idn());;
	}
};


struct PlyCount : public Match
{
	PlyCount(unsigned min, unsigned max) :m_min(min), m_max(max) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_min <= info.plyCount() && info.plyCount() <= m_max;
	}

	unsigned m_min;
	unsigned m_max;
};


struct Result : public Match
{
	Result(unsigned results) :m_results(results) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return (1u << info.result()) & m_results;
	}

	unsigned m_results;
};


struct Round : public Match
{
	Round(unsigned round) :m_round(round), m_subround(0) {}
	Round(unsigned round, unsigned subround) :m_round(round), m_subround(subround) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		if (m_subround && m_subround != info.subround())
			return false;

		return m_round == info.round();
	}

	unsigned m_round;
	unsigned m_subround;
};


struct Termination : public Match
{
	Termination(unsigned reasons) :m_reasons(reasons) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_reasons & (1u << info.terminationReason());
	}

	unsigned m_reasons;
};


struct TimeMode : public Match
{
	TimeMode(unsigned modes) :m_modes(modes) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_modes & (1u << info.timeMode());
	}

	unsigned m_modes;
};


struct Title : public Match
{
	Title(unsigned titles, color::ID color) :m_titles(titles), m_color(color) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		return m_titles & title::fromID(info.title(m_color));
	}

	unsigned		m_titles;
	color::ID	m_color;
};


struct Variant : public Match
{
	Variant(variant::Type variant) :m_variant(variant) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		switch (int(m_variant))
		{
			case variant::Giveaway:	return info.isGiveaway();
			case variant::Suicide:	return !info.isGiveaway();
		}

		return true;
	}

	variant::Type m_variant;
};


struct Year : public Match
{
	Year(unsigned min, unsigned max) :m_min(min), m_max(max) {}

	bool match(GameInfo const& info, unsigned gameNumber) override
	{
		unsigned year = info.date().year();
		return m_min <= year && year <= m_max;
	}

	unsigned m_min;
	unsigned m_max;
};

} // namespace gameinfo

namespace board {

struct Match
{
	virtual ~Match() {}
	virtual bool match(GameInfo const& info, Board const& board, variant::Type variant) = 0;
};


struct AttackCount : public Match
{
	AttackCount(Designator const& fst, Designator const& snd, unsigned min, unsigned max)
		:m_fst(fst)
		,m_snd(snd)
		,m_min(min)
		,m_max(max)
	{
		m_color[White] = bool(m_fst.pieces(White)) && bool(m_snd.pieces(Black));
		m_color[Black] = bool(m_fst.pieces(Black)) && bool(m_snd.pieces(White));
	}

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		color::ID sideToMove = board.sideToMove();

		if (m_color[sideToMove])
		{
			uint64_t attackers	= m_fst.pieces(board, sideToMove);
			uint64_t affected		= m_snd.pieces(board, board.notToMove());

			while (attackers)
			{
				unsigned n = count(board.attacks(sideToMove, lsbClear(attackers)) & affected);

				if (m_min <= n && n <= m_max)
					return true;
			}
		}

		return false;
	}

	Designator	m_fst;
	Designator	m_snd;
	unsigned		m_min;
	unsigned		m_max;
	bool			m_color[2];
};


struct Check : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return board.isInCheck();
	}
};


struct NoCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return !board.isInCheck();
	}
};


struct ContactCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return board.isContactCheck();
	}
};


struct NoContactCheck : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return !board.isContactCheck();
	}
};


struct State : public Match
{
	State() :m_states(0) {}

	void add(unsigned state) { m_states |= state; }

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return (board.checkState(variant) & m_states) == m_states;
	}

	unsigned m_states;
};


struct ToMove : public Match
{
	ToMove(color::ID color) :m_color(color) {}

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return board.sideToMove() == m_color;
	}

	color::ID m_color;
};


struct Fen : public Match
{
	Fen(Board const& board, bool includeZhouse) :m_board(board), m_includeZhouse(includeZhouse) {}

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return m_includeZhouse ? board.isEqualZHPosition(m_board) : board.isEqualPosition(m_board);
	}

	Board	m_board;
	bool	m_includeZhouse;
};


struct FiftyMoveRule : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return board.halfMoveClock() >= 50;
	}
};


struct NotMate : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		return board.isInCheck() && (board.checkState(variant) & Board::Checkmate);
	}
};


struct CheckCount : public Match
{
	CheckCount(unsigned count, char side)
		:m_count(count)
		,m_color(-1)
	{
		static_assert(White != -1 && Black != -1, "invalid initialization value");

		switch (side)
		{
			case 'w': m_color = White; break;
			case 'b': m_color = Black; break;
		}
	}

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		if (m_color != -1)
			return board.checksGiven(color::ID(m_color)) == m_count;

		return board.checksGiven(White) == m_count || board.checksGiven(Black) == m_count;
	}

	unsigned	m_count;
	int		m_color;
};


struct Rating : public Match
{
	Rating(rating::Type ratingType, uint16_t minScore, uint16_t maxScore, color::ID color)
		:m_ratingType(ratingType)
		,m_color(color)
		,m_minScore(minScore)
		,m_maxScore(maxScore)
	{
	}

	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		uint16_t rating = info.findRating(m_color, m_ratingType);
		return m_minScore <= rating && rating <= m_maxScore;
	}

	rating::Type	m_ratingType;
	color::ID		m_color;
	uint16_t			m_minScore;
	uint16_t			m_maxScore;
};


struct EndGame : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override
	{
		material::Count w = board.materialCount(White);
		material::Count b = board.materialCount(Black);

		return	(	(w.queen | b.queen) == 0
					&& w.rook + w.bishop + w.knight <= 3
					&& b.rook + b.bishop + b.knight <= 3)
				|| (	w.queen == 1
					&& b.queen == 1
					&& w.rook + b.rook == 0
					&& w.bishop + w.knight <= 1)
				|| (	w.queen == 1
					&& b.queen == 0
					&& w.rook == 0
					&& w.bishop + w.knight <= 1
					&& ::power(b, variant) <= 16)
				|| (	b.queen == 1
					&& w.queen == 0
					&& b.rook == 0
					&& b.bishop + b.knight <= 1
					&& ::power(w, variant) <= 16);
	}
};

} // namespace board

namespace move {

struct Match
{
	virtual ~Match() {}
	virtual bool match(Board const& board, Move const& move) = 0;
};


struct EnPassant : public Match
{
	bool match(Board const& board, Move const& move) override
	{
		return move.isEnPassant();
	}
};


struct NoEnPassant : public Match
{
	bool match(Board const& board, Move const& move) override
	{
		return !move.isEnPassant();
	}
};


struct IsCastling : public Match
{
	bool match(Board const& board, Move const& move) override
	{
		return move.isCastling();
	}
};


struct MoveFrom : public Match
{
	MoveFrom(Designator const& designator) :m_designator(designator) {}

	bool match(Board const& board, Move const& move) override
	{
		if (!move.isPieceDrop())
		{
			color::ID	color		= board.sideToMove();
			uint64_t		position	= setBit(move.from());

			switch (move.pieceMoved())
			{
				case piece::King:		return bool(position & m_designator.m_pos.pieces[color].kings);
				case piece::Queen:	return bool(position & m_designator.m_pos.pieces[color].queens);
				case piece::Rook:		return bool(position & m_designator.m_pos.pieces[color].rooks);
				case piece::Bishop:	return bool(position & m_designator.m_pos.pieces[color].bishops);
				case piece::Knight:	return bool(position & m_designator.m_pos.pieces[color].knights);
				case piece::Pawn:		return bool(position & m_designator.m_pos.pieces[color].pawns);
				case piece::None:		M_ASSERT(!"unexpected");
			}
		}

		return false;
	}

	Designator m_designator;
};


struct MoveTo : public Match
{
	MoveTo(Designator const& designator) :m_designator(designator) {}

	bool match(Board const& board, Move const& move) override
	{
		if (!move.isPieceDrop())
		{
			uint64_t pos = setBit(move.to());

			switch (move.captured())
			{
				case piece::King:		return bool(pos & m_designator.m_pos.pieces[board.notToMove()].kings);
				case piece::Queen:	return bool(pos & m_designator.m_pos.pieces[board.notToMove()].queens);
				case piece::Rook:		return bool(pos & m_designator.m_pos.pieces[board.notToMove()].rooks);
				case piece::Bishop:	return bool(pos & m_designator.m_pos.pieces[board.notToMove()].bishops);
				case piece::Knight:	return bool(pos & m_designator.m_pos.pieces[board.notToMove()].knights);
				case piece::Pawn:		return bool(pos & m_designator.m_pos.pieces[board.notToMove()].pawns);
				case piece::None:		return bool(pos & m_designator.m_pos.empty);
			}
		}

		return false;
	}

	Designator m_designator;
};


struct PieceDrop : public Match
{
	PieceDrop(Designator const& designator) :m_designator(designator) {}

	bool match(Board const& board, Move const& move) override
	{
		M_ASSERT(board.sideToMove() == move.color());

		if (move.isPieceDrop())
		{
			uint64_t		position	= setBit(move.to());
			color::ID	color		= board.sideToMove();

			switch (move.capturedOrDropped())
			{
				case piece::King:		return bool(position & m_designator.m_pos.pieces[color].kings);
				case piece::Queen:	return bool(position & m_designator.m_pos.pieces[color].queens);
				case piece::Rook:		return bool(position & m_designator.m_pos.pieces[color].rooks);
				case piece::Bishop:	return bool(position & m_designator.m_pos.pieces[color].bishops);
				case piece::Knight:	return bool(position & m_designator.m_pos.pieces[color].knights);
				case piece::Pawn:		return bool(position & m_designator.m_pos.pieces[color].pawns);
				case piece::None:		M_ASSERT(!"unexpected");
			}
		}

		return false;
	}

	Designator m_designator;
};


struct Promote : public Match
{
	Promote(Designator const& designator) :m_designator(designator) {}

	bool match(Board const& board, Move const& move) override
	{
		if (move.isPromotion())
		{
			uint64_t		position	= setBit(move.to());
			color::ID	color		= board.sideToMove();

			switch (move.promoted())
			{
				case piece::King:		return bool(position & m_designator.m_pos.pieces[color].kings);
				case piece::Queen:	return bool(position & m_designator.m_pos.pieces[color].queens);
				case piece::Rook:		return bool(position & m_designator.m_pos.pieces[color].rooks);
				case piece::Bishop:	return bool(position & m_designator.m_pos.pieces[color].bishops);
				case piece::Knight:	return bool(position & m_designator.m_pos.pieces[color].knights);
				case piece::Pawn:		return bool(position & m_designator.m_pos.pieces[color].pawns);
				case piece::None:		M_ASSERT(!"unexpected");
			}
		}

		return false;
	}

	Designator m_designator;
};

} // namespace move

namespace logical {

struct Match : virtual public move::Match, virtual public board::Match
{
	typedef mstl::vector<cql::Match::Position*> PositionList;

	~Match() { ::deleteAll(m_list.begin(), m_list.end()); }

	cql::Match::Position& back() { return *m_list.back(); }
	void pushBack(variant::Type variant);

	PositionList m_list;
};


struct And : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override;
	bool match(Board const& board, Move const& move) override;
};


struct Or : public Match
{
	bool match(GameInfo const& info, Board const& board, variant::Type variant) override;
	bool match(Board const& board, Move const& move) override;
};

} // namespacelogical
} // namespace cql
} // namespace db


namespace {

typedef char const* (Match::*MatchMeth)(char const* s, Error& error);

struct MatchPair
{
	MatchPair(char const* s, MatchMeth f) :keyword(s), func(f) {}

	bool operator<(mstl::string const& s) const { return keyword < s; }

	mstl::string	keyword;
	MatchMeth		func;
};

typedef char const* (Match::Position::*PosMeth)(Match& match, char const* s, Error& error);

struct PosPair
{
	PosPair(char const* s, PosMeth f) :keyword(s), func(f) {}

	bool operator<(mstl::string const& s) const { return keyword < s; }

	mstl::string	keyword;
	PosMeth			func;
};

} // namespace


namespace mstl {

static inline
bool
operator<(mstl::string const& lhs, MatchPair const& rhs)
{
	return lhs < rhs.keyword;
}

static inline
bool
operator<(mstl::string const& lhs, PosPair const& rhs)
{
	return lhs < rhs.keyword;
}

}


static bool
isDelim(char c)
{
	return isspace(c) || c == '\0' || c == '(' || c == ')' || c == ';';
}


static bool
matchKeyword(char const* s, char const* word, unsigned len)
{
	return *s == ':' && ::strncmp(s + 1, word, len) == 0 && !::isalnum(s[len]);
}


static unsigned
lengthOfKeyword(char const* s)
{
	char const* t = s;

	while (::isalpha(*t))
		++t;

	return t - s;
}


static char const*
skipSpaces(char const* s)
{
	while (::isspace(*s))
		++s;

	if (*s == ';')
	{
		// skip comment
		while (*s != '\n' && *s != '\0')
			++s;

		while (::isspace(*s))
			++s;
	}

	return s;
}


static char const*
skipToDelim(char const* s)
{
	while (!isDelim(*s))
		++s;

	return s;
}


static char const*
parseDate(char const* s, Error& error, Date& date)
{
	if (!date || (*s != '-' && *s != '+'))
	{
		if (	!::isdigit(s[0])
			|| !::isdigit(s[1])
			|| !::isdigit(s[2])
			|| !::isdigit(s[3])
			|| s[4] != '-'
			|| !::isdigit(s[5])
			|| !::isdigit(s[6])
			|| s[7] != '-'
			|| !::isdigit(s[8])
			|| !::isdigit(s[9]))
		{
			error = Invalid_Date;
			return s;
		}

		unsigned y = ::strtoul(s, 0, 10);
		unsigned m = ::strtoul(s + 5, 0, 10);
		unsigned d = ::strtoul(s + 8, 0, 10);

		if (!date.setYMD(y, m, d))
		{
			error = Illegal_Date;
			return s;
		}

		s += 10;
	}

	char const *t = s;

	while (*t == '+' || *t == '-')
	{
		if (!::isdigit(t[1]))
		{
			error = Illegal_Date_Offset;
			return s;
		}

		char* e;
		int offs = ::strtoul(t, &e, 10);
		t = e;

		switch (*t)
		{
			case 'y':
				if (!date.addYears(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			case 'm':
				if (!date.addMonths(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			case 'd':
				if (!date.addDays(offs))
				{
					error = Illegal_Date;
					return s;
				}
				break;

			default:
				error = Invalid_Date;
				return s;
		}
	}

	return t;
}


static char const*
parseEco(char const* s, Error& error, Eco& eco)
{
	if (s[0] > 'A' || 'E' > s[0] || !isdigit(s[1]) || isdigit(s[2]) || !isDelim(s[3]))
	{
		error = Invalid_Eco_Code;
		return s;
	}

	eco.setup(s);
	return s + 3;
}


char const*
parseRatingType(char const* s, Error& error, rating::Type& ratingType)
{
	ratingType = rating::fromString(s);

	if (ratingType == rating::Any)
	{
		error = Invalid_Rating_Type;
	}
	else
	{
		mstl::string const& str = rating::toString(ratingType);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
			error = Invalid_Rating_Type;
		else
			s += str.size();
	}

	return s;
}


char const*
parseScores(char const* s, Error& error, unsigned& min, unsigned& max)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;

		unsigned min = ::strtoul(s, &e, 10);

		s = ::skipSpaces(e);

		if (!::isdigit(*s))
		{
			error = Positive_Integer_Expected;
		}
		else
		{
			s = skipSpaces(s + 2);
			unsigned max = mstl::min(4000u, unsigned(::strtoul(s, &e, 10)));

			if (min > max)
				mstl::swap(min, max);

			s = e;
		}
	}

	return s;
}


char const*
parseCountryCode(char const* s, Error& error, country::Code& code)
{
	if (	!::isalpha(s[0]) || !::isupper(s[0])
		|| !::isalpha(s[1]) || !::isupper(s[1])
		|| !::isalpha(s[2]) || !::isupper(s[2])
		|| !::isDelim(s[3]))
	{
		error = Invalid_Country_Code;
	}
	else if ((code = country::fromString(s)) == country::Unknown)
	{
		error = Illegal_Country_Code;
	}
	else
	{
		s += 3;
	}

	return s;
}


char const*
parseGender(char const* s, Error& error, sex::ID sex)
{
	sex = sex::fromChar(*s);

	if (sex == sex::Unspecified || !::isDelim(s[1]))
		error = Invalid_Gender;
	else
		++s;

	return s;
}


char const*
parseTitle(char const* s, Error& error, unsigned& titles)
{
	if (*s == ',')
	{
		error = Invalid_Result;
		return s;
	}

	titles = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		result.toupper();

		title::ID title = title::fromString(s);

		if (title == title::None || result != title::toString(title))
		{
			error = Invalid_Title;
			return s;
		}

		titles |= title::fromID(title);
		s = t;
	}
	while (*s == ',');

	return s;
}


// Relation ---------------------------------------------------------------------------
//		Pair("changesidetomove",			&Relation::parseChangeSideToMove),
//		Pair("flip",							&Relation::parseFlip),
//		Pair("ignoresidetomove",			&Relation::parseIgnoreSideToMove),
//		Pair("missingpiececount",			&Relation::parseMissingPiececount),
//		Pair("newpiececount",				&Relation::parseNewPieceCount),
//		Pair("originaldifferentcount",	&Relation::parseOriginalDifferentCount),
//		Pair("originalsamecount",			&Relation::parseOriginalSameCount),
//		Pair("pattern",						&Relation::parsePattern),
//		Pair("samesidetomove",				&Relation::parseSameSideToMove),
//		Pair("shift",							&Relation::parseShift),
//		Pair("variations",					&Relation::parseVariations),
//		Pair("variationsonly",				&Relation::parseVariationsOnly),


class Match::Position
{
public:

	Position(variant::Type variant);
	~Position();

	Designator const& last() const;

	bool match(GameInfo const& info, Board const& board, variant::Type variant);
	bool match(Board const& board, Move const& move);

	void add(Designator& designator);

	char const* parse(Match& match, char const* s, Error& error);

private:

	typedef mstl::list<Designator> Designators;
	typedef mstl::vector<board::Match*> BoardMatchList;
	typedef mstl::vector<move::Match*> MoveMatchList;
	typedef mstl::pvector<Position> PositionList;

	bool doMatch(GameInfo const& info, Board const& board, variant::Type variant);
	bool doMatch(Board const& board, Move const& move);

	char const* parseAccumulate(Match& match, char const* s, Error& error);
	char const* parseAnd(Match& match, char const* s, Error& error);
	char const* parseAttackCount(Match& match, char const* s, Error& error);
	char const* parseBlackElo(Match& match, char const* s, Error& error);
	char const* parseBlackRating(Match& match, char const* s, Error& error);
	char const* parseBlackToMove(Match& match, char const* s, Error& error);
	char const* parseIsCastling(Match& match, char const* s, Error& error);
	char const* parseCheck(Match& match, char const* s, Error& error);
	char const* parseCheckCount(Match& match, char const* s, Error& error);
	char const* parseContactCheck(Match& match, char const* s, Error& error);
	char const* parseDoubleCheck(Match& match, char const* s, Error& error);
	char const* parseElo(Match& match, char const* s, Error& error);
	char const* parseEndGame(Match& match, char const* s, Error& error);
	char const* parseEnPassant(Match& match, char const* s, Error& error);
	char const* parseFen(Match& match, char const* s, Error& error);
	char const* parseFiftyMoveRule(Match& match, char const* s, Error& error);
	char const* parseFlip(Match& match, char const* s, Error& error);
	char const* parseFlipColor(Match& match, char const* s, Error& error);
	char const* parseFlipDiagonal(Match& match, char const* s, Error& error);
	char const* parseFlipDihedral(Match& match, char const* s, Error& error);
	char const* parseFlipHorizontal(Match& match, char const* s, Error& error);
	char const* parseFlipOffDiagonal(Match& match, char const* s, Error& error);
	char const* parseFlipVertical(Match& match, char const* s, Error& error);
	char const* parseGappedSequence(Match& match, char const* s, Error& error);
	char const* parseInitial(Match& match, char const* s, Error& error);
	char const* parseInside(Match& match, char const* s, Error& error);
	char const* parseLosing(Match& match, char const* s, Error& error);
	char const* parseMatchCount(Match& match, char const* s, Error& error);
	char const* parseMate(Match& match, char const* s, Error& error);
	char const* parseMaxSwapValue(Match& match, char const* s, Error& error);
	char const* parseMoveFrom(Match& match, char const* s, Error& error);
	char const* parseMoveNumber(Match& match, char const* s, Error& error);
	char const* parseMoveTo(Match& match, char const* s, Error& error);
	char const* parseNoAnnotate(Match& match, char const* s, Error& error);
	char const* parseNoCheck(Match& match, char const* s, Error& error);
	char const* parseNoContactCheck(Match& match, char const* s, Error& error);
	char const* parseNoEndGame(Match& match, char const* s, Error& error);
	char const* parseNoEnpassant(Match& match, char const* s, Error& error);
	char const* parseNoMate(Match& match, char const* s, Error& error);
	char const* parseNoStalemate(Match& match, char const* s, Error& error);
	char const* parseNot(Match& match, char const* s, Error& error);
	char const* parseOr(Match& match, char const* s, Error& error);
	char const* parsePattern(Match& match, char const* s, Error& error);
	char const* parsePieceCount(Match& match, char const* s, Error& error);
	char const* parsePieceDrop(Match& match, char const* s, Error& error);
	char const* parsePlyNumber(Match& match, char const* s, Error& error);
	char const* parsePosition(Match& match, char const* s, Error& error);
	char const* parsePower(Match& match, char const* s, Error& error);
	char const* parsePowerDifference(Match& match, char const* s, Error& error);
	char const* parsePreTransformMatchCount(Match& match, char const* s, Error& error);
	char const* parsePromote(Match& match, char const* s, Error& error);
	char const* parseRating(Match& match, char const* s, Error& error);
	char const* parseRay(Match& match, char const* s, Error& error);
	char const* parseRayAttack(Match& match, char const* s, Error& error);
	char const* parseRayDiagonal(Match& match, char const* s, Error& error);
	char const* parseRayHorizontal(Match& match, char const* s, Error& error);
	char const* parseRayOrthogonal(Match& match, char const* s, Error& error);
	char const* parseRayVertical(Match& match, char const* s, Error& error);
	char const* parseRelation(Match& match, char const* s, Error& error);
	char const* parseRepetition(Match& match, char const* s, Error& error);
	char const* parseResult(Match& match, char const* s, Error& error);
	char const* parseSequence(Match& match, char const* s, Error& error);
	char const* parseShift(Match& match, char const* s, Error& error);
	char const* parseShiftDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftHorizontal(Match& match, char const* s, Error& error);
	char const* parseShiftMainDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftOffDiagonal(Match& match, char const* s, Error& error);
	char const* parseShiftVertical(Match& match, char const* s, Error& error);
	char const* parseStalemate(Match& match, char const* s, Error& error);
	char const* parseSumrange(Match& match, char const* s, Error& error);
	char const* parseTagMatch(Match& match, char const* s, Error& error);
	char const* parseTerminal(Match& match, char const* s, Error& error);
	char const* parseThreeChecks(Match& match, char const* s, Error& error);
	char const* parseVariations(Match& match, char const* s, Error& error);
	char const* parseVariationsOnly(Match& match, char const* s, Error& error);
	char const* parseWhiteElo(Match& match, char const* s, Error& error);
	char const* parseWhiteRating(Match& match, char const* s, Error& error);
	char const* parseWhiteToMove(Match& match, char const* s, Error& error);

	Designators		m_designators;
	BoardMatchList	m_boardMatchList;
	MoveMatchList	m_moveMatchList;
	PositionList	m_positionList;
	board::State*	m_state;
	bool				m_includeMainline;
	bool				m_includeVariations;
	bool				m_not;
	variant::Type	m_variant;
};


Match::Position::Position(variant::Type variant)
	:m_state(0)
	,m_includeMainline(true)
	,m_includeVariations(false)
	,m_not(false)
	,m_variant(variant)
{
}


Match::Position::~Position()
{
	::deleteAll(m_boardMatchList.begin(), m_boardMatchList.end());
	::deleteAll(m_moveMatchList.begin(), m_moveMatchList.end());
}


Designator const&
Match::Position::last() const
{
	M_ASSERT(!m_designators.empty());
	return m_designators.back();
}


void
Match::Position::add(Designator& designator)
{
	designator.m_pos.complete();
	m_designators.push_back(designator);
}


bool
Match::Position::doMatch(GameInfo const& info, Board const& board, variant::Type variant)
{
	{
		Designators::iterator i = m_designators.begin();
		Designators::iterator e = m_designators.end();

		for ( ; i != e; ++i)
		{
			if (!i->match(board, variant))
				return false;
		}
	}

	{
		BoardMatchList::iterator i = m_boardMatchList.begin();
		BoardMatchList::iterator e = m_boardMatchList.end();

		for ( ; i != e; ++i)
		{
			if (!(*i)->match(info, board, variant))
				return false;
		}
	}

	{
		PositionList::iterator i = m_positionList.begin();
		PositionList::iterator e = m_positionList.end();

		for ( ; i != e; ++i)
		{
			if (!i->match(info, board, variant))
				return false;
		}
	}

	return true;
}


bool
Match::Position::doMatch(Board const& board, Move const& move)
{
	MoveMatchList::iterator i = m_moveMatchList.begin();
	MoveMatchList::iterator e = m_moveMatchList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(board, move))
			return false;
	}

	{
		PositionList::iterator i = m_positionList.begin();
		PositionList::iterator e = m_positionList.end();

		for ( ; i != e; ++i)
		{
			if (!i->match(board, move))
				return false;
		}
	}

	return true;
}


bool
Match::Position::match(GameInfo const& info, Board const& board, variant::Type variant)
{
	bool match = doMatch(info, board, variant);
	return m_not ? !match : match;
}


bool
Match::Position::match(Board const& board, Move const& move)
{
	bool match = doMatch(board, move);
	return m_not ? !match : match;
}


char const*
Match::Position::parseAccumulate(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseAnd(Match& match, char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));

	if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
	{
		error = Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	logical::And list;

	do
	{
		list.pushBack(m_variant);
		s = list.back().parse(match, s, error);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);

		if (*s != '(' && *s != ')')
		{
			error = Position_Expected;
			return s;
		}
	}
	while (*s != ')');

	return s;
}


char const*
Match::Position::parseAttackCount(Match& match, char const* s, Error& error)
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

	m_boardMatchList.push_back(new board::AttackCount(fst, snd, min, max));
	return s;
}


char const*
Match::Position::parseBlackElo(Match& match, char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
		m_boardMatchList.push_back(new board::Rating(rating::Elo, min, max, color::Black));

	return s;
}


char const*
Match::Position::parseBlackRating(Match& match, char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
			m_boardMatchList.push_back(new board::Rating(ratingType, min, max, color::Black));
	}

	return s;
}


char const*
Match::Position::parseBlackToMove(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::ToMove(color::Black));
	return s;
}


char const*
Match::Position::parseIsCastling(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new move::IsCastling);
	return s;
}


char const*
Match::Position::parseCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::Check);
	return s;
}


char const*
Match::Position::parseCheckCount(Match& match, char const* s, Error& error)
{
	char side = ' ';

	switch (char c = tolower(*s))
	{
		case 'b': case 'w': side = c; ++s; break;
	}

	if (!isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;
		unsigned count = strtoul(s, &e, 10);

		if (count == 0 || count > 3)
			error = Integer_Out_Of_Range;
		else
			m_boardMatchList.push_back(new board::CheckCount(count, side));
	}

	return s;
}


char const*
Match::Position::parseContactCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::ContactCheck);
	return s;
}


char const*
Match::Position::parseDoubleCheck(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::DoubleCheck);
	return s;
}


char const*
Match::Position::parseElo(Match& match, char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
	{
		m_boardMatchList.push_back(new board::Rating(rating::Elo, min, max, color::White));
		m_boardMatchList.push_back(new board::Rating(rating::Elo, min, max, color::Black));
	}

	return s;
}


char const*
Match::Position::parseEndGame(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::EndGame);
	return s;
}


char const*
Match::Position::parseEnPassant(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new move::EnPassant);
	return s;
}


char const*
Match::Position::parseFen(Match& match, char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);
	mstl::string fen(s, t);

	if (Board::isValidFen(s, m_variant))
	{
		Board board;

		char const* p = board.setup(fen, m_variant);

		if (p == fen.end())
		{
			bool includeZhouse = false;

			if (variant::isZhouse(m_variant))
			{
				unsigned countSlashes = 0;

				for (t = s ; *t && !::isspace(*t); ++t)
				{
					if (*t == '\\')
						++countSlashes;
				}

				if (countSlashes >= 8)
					includeZhouse = true;
			}
			else if (m_variant == variant::ThreeCheck)
			{
				char const* p = t;

				while (p > s && !::isspace(p[-1]))
					--p;

				if (p[0] == '+' && ::isdigit(p[1]))
					includeZhouse = true;
			}

			m_boardMatchList.push_back(new board::Fen(board, includeZhouse));
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

	return s;
}


char const*
Match::Position::parseFiftyMoveRule(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::FiftyMoveRule);
	return s;
}


char const*
Match::Position::parseFlipColor(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->flipcolor(*this);

	return s;
}


char const*
Match::Position::parseFlipDiagonal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->flipdiagonal(*this);

	return s;
}


char const*
Match::Position::parseFlipDihedral(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->flipdihedral(*this);

	return s;
}


char const*
Match::Position::parseFlipHorizontal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->fliphorizontal(*this);

	return s;
}


char const*
Match::Position::parseFlipOffDiagonal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->flipoffdiagonal(*this);

	return s;
}


char const*
Match::Position::parseFlipVertical(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->flipvertical(*this);

	return s;
}


char const*
Match::Position::parseGappedSequence(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseInitial(Match& match, char const* s, Error& error)
{
	match.setInitial();
	return s;
}


char const*
Match::Position::parseInside(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseLosing(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::Losing);
	return s;
}


char const*
Match::Position::parseMatchCount(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseMate(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::Checkmate);
	return s;
}


char const*
Match::Position::parseMaxSwapValue(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseMoveFrom(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new move::MoveFrom(designator));
	return s;
}


char const*
Match::Position::parseMoveNumber(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseMoveTo(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new move::MoveTo(designator));
	return s;
}


char const*
Match::Position::parseNoAnnotate(Match& match, char const* s, Error& error)
{
	return s; // nothing to do
}


char const*
Match::Position::parseNoCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::NoCheck);
	return s;
}


char const*
Match::Position::parseNoContactCheck(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::NoContactCheck);
	return s;
}


char const*
Match::Position::parseNoEndGame(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseNoEnpassant(Match& match, char const* s, Error& error)
{
	m_moveMatchList.push_back(new move::NoEnPassant);
	return s;
}


char const*
Match::Position::parseNoMate(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::NotMate);
	return s;
}


char const*
Match::Position::parseNoStalemate(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseNot(Match& match, char const* s, Error& error)
{
	m_not = !m_not;
	return s;
}


char const*
Match::Position::parseOr(Match& match, char const* s, Error& error)
{
	if (*s != '(')
	{
		error = Left_Parenthesis_Expected;
		return s;
	}

	s = ::skipSpaces(s + 1);

	if (*s != '(')
	{
		error = Position_Expected;
		return s;
	}

	char const* t = ::skipToDelim(::skipSpaces(s + 1));

	if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
	{
		error = Position_Expected;
		return s;
	}

	s = ::skipSpaces(t);

	logical::Or list;

	do
	{
		list.pushBack(m_variant);
		s = list.back().parse(match, s, error);

		if (error != No_Error)
			return s;

		s = ::skipSpaces(s);

		if (*s != '(' && *s != ')')
		{
			error = Position_Expected;
			return s;
		}
	}
	while (*s != ')');

	return s;
}


char const*
Match::Position::parsePieceCount(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePieceDrop(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
		m_moveMatchList.push_back(new move::PieceDrop(designator));
	return s;
}


char const*
Match::Position::parsePlyNumber(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePosition(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePower(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePowerDifference(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePreTransformMatchCount(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parsePromote(Match& match, char const* s, Error& error)
{
	Designator designator;
	s = designator.parse(s, error);
	if (error == No_Error)
	{
		if ((designator.pieces(White) | designator.pieces(Black)) & ~(RankMask1 | RankMask8))
			error = Invalid_Promotion_Ranks;
		else
			m_moveMatchList.push_back(new move::Promote(designator));
	}
	return s;
}


char const*
Match::Position::parseRating(Match& match, char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
		{
			m_boardMatchList.push_back(new board::Rating(ratingType, min, max, color::White));
			m_boardMatchList.push_back(new board::Rating(ratingType, min, max, color::Black));
		}
	}

	return s;
}


char const*
Match::Position::parseRay(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRayAttack(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRayDiagonal(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRayHorizontal(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRayOrthogonal(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRayVertical(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRelation(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseRepetition(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseResult(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseSequence(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseShift(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shift(*this);

	return s;
}


char const*
Match::Position::parseShiftDiagonal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shiftdiagonal(*this);

	return s;
}


char const*
Match::Position::parseShiftHorizontal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shifthorizontal(*this);

	return s;
}


char const*
Match::Position::parseShiftMainDiagonal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shiftmaindiagonal(*this);

	return s;
}


char const*
Match::Position::parseShiftOffDiagonal(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shiftoffdiagonal(*this);

	return s;
}


char const*
Match::Position::parseShiftVertical(Match& match, char const* s, Error& error)
{
	Designators::iterator i = m_designators.begin();
	Designators::iterator e = m_designators.end();

	for ( ; i != e; ++i)
		i->shiftvertical(*this);

	return s;
}


char const*
Match::Position::parseStalemate(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::Stalemate);
	return s;
}


char const*
Match::Position::parseSumrange(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseTagMatch(Match& match, char const* s, Error& error)
{
	// TODO
	return s;
}


char const*
Match::Position::parseTerminal(Match& match, char const* s, Error& error)
{
	match.setFinal();
	return s;
}


char const*
Match::Position::parseThreeChecks(Match& match, char const* s, Error& error)
{
	if (m_state == 0)
	{
		m_state = new board::State;
		m_boardMatchList.push_back(m_state);
	}

	m_state->add(Board::ThreeChecks);
	return s;
}


char const*
Match::Position::parseVariations(Match& match, char const* s, Error& error)
{
	m_includeVariations = true;
	return s;
}


char const*
Match::Position::parseVariationsOnly(Match& match, char const* s, Error& error)
{
	m_includeMainline = false;
	return s;
}


char const*
Match::Position::parseWhiteElo(Match& match, char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
		m_boardMatchList.push_back(new board::Rating(rating::Elo, min, max, color::White));

	return s;
}


char const*
Match::Position::parseWhiteRating(Match& match, char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
			m_boardMatchList.push_back(new board::Rating(ratingType, min, max, color::White));
	}

	return s;
}


char const*
Match::Position::parseWhiteToMove(Match& match, char const* s, Error& error)
{
	m_boardMatchList.push_back(new board::ToMove(color::White));
	return s;
}


char const*
Match::Position::parse(Match& match, char const* s, Error& error)
{
	typedef PosPair Pair;

	static Pair const Trampolin[] =
	{
		Pair("accumulate",					&Position::parseAccumulate),
		Pair("and",								&Position::parseAnd),
		Pair("attackcount",					&Position::parseAttackCount),
		Pair("btm",								&Position::parseBlackToMove),
		Pair("check",							&Position::parseCheck),
		Pair("checkcount",					&Position::parseCheckCount),						// extension
		Pair("contactcheck",					&Position::parseContactCheck),
		Pair("doublecheck",					&Position::parseDoubleCheck),
		Pair("endgame",						&Position::parseEndGame),							// extension
		Pair("enpassant",						&Position::parseEnPassant),
		Pair("fen",								&Position::parseFen),								// extension
		Pair("fiftymoverule",				&Position::parseFiftyMoveRule),
		Pair("flip",							&Position::parseFlipDihedral),
		Pair("flipcolor",						&Position::parseFlipColor),
		Pair("flipdiagonal",					&Position::parseFlipDiagonal),
		Pair("flipdihedral",					&Position::parseFlipDihedral),
		Pair("fliphorizontal",				&Position::parseFlipHorizontal),
		Pair("flipoffdiagonal",				&Position::parseFlipOffDiagonal),
		Pair("flipvertical",					&Position::parseFlipVertical),
		Pair("gappedsequence",				&Position::parseGappedSequence),
		Pair("initial",						&Position::parseInitial),
		Pair("inside",							&Position::parseInside),							// extension
		Pair("iscastling",					&Position::parseIsCastling),						// extension
		Pair("losing",							&Position::parseLosing),							// extension
		Pair("matchcount",					&Position::parseMatchCount),
		Pair("mate",							&Position::parseMate),
		Pair("maxswapvalue",					&Position::parseMaxSwapValue),					// extension
		Pair("movefrom",						&Position::parseMoveFrom),
		Pair("movenumber",					&Position::parseMoveNumber),
		Pair("moveto",							&Position::parseMoveTo),
		Pair("noannotate",					&Position::parseNoAnnotate),
		Pair("nocheck",						&Position::parseNoCheck),
		Pair("nocontactcheck",				&Position::parseNoContactCheck),
		Pair("noendgame",						&Position::parseNoEndGame),						// extension
		Pair("noenpassant",					&Position::parseNoEnpassant),
		Pair("nomate",							&Position::parseNoMate),
		Pair("nostalemate",					&Position::parseNoStalemate),
		Pair("not",								&Position::parseNot),
		Pair("or",								&Position::parseOr),
		Pair("piececount",					&Position::parsePieceCount),
		Pair("piecedrop",						&Position::parsePieceDrop),						// extension
		Pair("plynumber",						&Position::parsePlyNumber),						// extension
		Pair("position",						&Position::parsePosition),
		Pair("power",							&Position::parsePower),
		Pair("powerdifference",				&Position::parsePowerDifference),
		Pair("pretransformmatchcount",	&Position::parsePreTransformMatchCount),
		Pair("promote",						&Position::parsePromote),
		Pair("ray",								&Position::parseRay),
		Pair("rayattack",						&Position::parseRayAttack),
		Pair("raydiagonal",					&Position::parseRayDiagonal),
		Pair("rayhorizontal",				&Position::parseRayHorizontal),
		Pair("rayorthogonal",				&Position::parseRayOrthogonal),
		Pair("rayvertical",					&Position::parseRayVertical),
		Pair("relation",						&Position::parseRelation),
		Pair("repetition",					&Position::parseRepetition),						// extension
		Pair("sequence",						&Position::parseSequence),
		Pair("shift",							&Position::parseShift),
		Pair("shiftdiagonal",				&Position::parseShiftDiagonal),
		Pair("shifthorizontal",				&Position::parseShiftHorizontal),
		Pair("shiftmaindiagonal",			&Position::parseShiftMainDiagonal),
		Pair("shiftoffdiagonal",			&Position::parseShiftOffDiagonal),
		Pair("shiftvertical",				&Position::parseShiftVertical),
		Pair("stalemate",						&Position::parseStalemate),
		Pair("sumrange",						&Position::parseSumrange),
		Pair("tagmatch",						&Position::parseTagMatch),
		Pair("terminal",						&Position::parseTerminal),
		Pair("threechecks",					&Position::parseThreeChecks),						// extension
		Pair("variations",					&Position::parseVariations),
		Pair("variationsonly",				&Position::parseVariationsOnly),
		Pair("wtm",								&Position::parseWhiteToMove),
	 	Pair("elo",								&Position::parseElo),
 		Pair("blackelo",						&Position::parseBlackElo),
 		Pair("blackrating",					&Position::parseBlackRating),						// extension
 		Pair("rating",							&Position::parseRating),							// extension
 		Pair("result",							&Position::parseResult),
 		Pair("whiteelo",						&Position::parseWhiteElo),
 		Pair("whiterating",					&Position::parseWhiteRating),						// extension
	};

	mstl::string key;

	error = No_Error;

	do
	{
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

			s = (this->*p->func)(match, ::skipSpaces(s + key.size() + 1), error);

			if (error != No_Error)
				return s;

			s = ::skipSpaces(s);
		}
		else if (*s)
		{
			Designator designator;
			s = designator.parse(s, error);
			if (error == No_Error)
				m_designators.push_back(designator);
		}
	}
	while (*s && error == No_Error);

	return s;
}



void
logical::Match::pushBack(variant::Type variant)
{
	m_list.push_back(new cql::Match::Position(variant));
}


bool
logical::And::match(GameInfo const& info, Board const& board, variant::Type variant)
{
	PositionList::iterator i = m_list.begin();
	PositionList::iterator e = m_list.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(info, board, variant))
			return false;
	}

	return true;
}


bool
logical::And::match(Board const& board, Move const& move)
{
	PositionList::iterator i = m_list.begin();
	PositionList::iterator e = m_list.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(board, move))
			return false;
	}

	return true;
}


bool
logical::Or::match(GameInfo const& info, Board const& board, variant::Type variant)
{
	PositionList::iterator i = m_list.begin();
	PositionList::iterator e = m_list.end();

	for ( ; i != e; ++i)
	{
		if ((*i)->match(info, board, variant))
			return true;
	}

	return false;
}


bool
logical::Or::match(Board const& board, Move const& move)
{
	PositionList::iterator i = m_list.begin();
	PositionList::iterator e = m_list.end();

	for ( ; i != e; ++i)
	{
		if ((*i)->match(board, move))
			return true;
	}

	return false;
}


uint64_t
Designator::pieces(color::ID color) const
{
	return m_pos.pieces[color].any;
}


uint64_t
Designator::pieces(Board const& board, color::ID color) const
{
	my::Pieces const& pieces = m_pos.pieces[color];

	return	(board.kings(color)		& pieces.kings)
			 | (board.queens(color)		& pieces.queens)
			 | (board.rooks(color)		& pieces.rooks)
			 | (board.bishops(color)	& pieces.bishops)
			 | (board.knights(color)	& pieces.knights)
			 | (board.pawns(color)		& pieces.pawns);
}


void
Designator::transform(Position& position, Transform func) const
{
	Designator designator;

	for (unsigned i = 0; i < 2; ++i)
	{
		designator.m_pos.pieces[i].knights	= func(m_pos.pieces[i].knights);
		designator.m_pos.pieces[i].bishops	= func(m_pos.pieces[i].bishops);
		designator.m_pos.pieces[i].rooks		= func(m_pos.pieces[i].rooks);
		designator.m_pos.pieces[i].queens	= func(m_pos.pieces[i].queens);
		designator.m_pos.pieces[i].kings		= func(m_pos.pieces[i].kings);
		designator.m_pos.pieces[i].pawns		= func(m_pos.pieces[i].pawns);
	}

	designator.m_pos.empty = func(m_pos.empty);
	position.add(designator);
}


bool
Designator::match(Board const& board, variant::Type variant)
{
	return ::match(m_pos, board);
}


void
Designator::shift(Position& position, Shift func) const
{
	for (int step = -7; step <= 7; ++step)
	{
		if (step)
		{
			Designator designator(*this);

			if (func(designator.m_pos.empty, step))
			{
				for (unsigned i = 0; i < 2; ++i)
				{
					if (	func(designator.m_pos.pieces[i].knights, step)
						&& func(designator.m_pos.pieces[i].bishops, step)
						&& func(designator.m_pos.pieces[i].rooks, step)
						&& func(designator.m_pos.pieces[i].queens, step)
						&& func(designator.m_pos.pieces[i].kings, step)
						&& func(designator.m_pos.pieces[i].pawns, step))
					{
						position.add(designator);
					}
				}
			}
		}
	}
}


void Designator::flipdiagonal(Position& position) const			{ transform(position, ::flipdiagonal); }
void Designator::flipoffdiagonal(Position& position) const		{ transform(position, ::flipoffdiagonal);}
void Designator::flipvertical(Position& position) const			{ transform(position, ::flipvertical); }
void Designator::fliphorizontal(Position& position) const		{ transform(position, ::fliphorizontal); }
void Designator::shifthorizontal(Position& position) const		{ shift(position, ::shifthorizontal); }
void Designator::shiftvertical(Position& position) const			{ shift(position, ::shiftvertical); }
void Designator::shiftmaindiagonal(Position& position) const	{ shift(position, ::shiftmaindiagonal); }
void Designator::shiftoffdiagonal(Position& position) const		{ shift(position, ::shiftoffdiagonal); }


void
Designator::flipdihedral(Position& position) const
{
	flipdiagonal(position);
	position.last().fliphorizontal(position);
	position.last().flipoffdiagonal(position);
	position.last().flipvertical(position);
	position.last().flipdiagonal(position);
	position.last().fliphorizontal(position);
	position.last().flipoffdiagonal(position);
}


void
Designator::shiftdiagonal(Position& position) const
{
	shiftmaindiagonal(position);
	shiftoffdiagonal(position);
}


void
Designator::shift(Position& position) const
{
	for (int stepFyle = -7; stepFyle <= 7; ++stepFyle)
	{
		if (stepFyle)
		{
			for (int stepRank = -7; stepRank <= 7; ++stepRank)
			{
				if (stepRank)
				{
					Designator d(*this);

					my::Pieces& white = d.m_pos.pieces[White];
					my::Pieces& black = d.m_pos.pieces[Black];

					if (	::shift(white.pawns,		stepFyle, stepRank)
						&& ::shift(black.pawns,		stepFyle, stepRank)
						&& ::shift(white.knights,	stepFyle, stepRank)
						&& ::shift(black.knights,	stepFyle, stepRank)
						&& ::shift(white.bishops,	stepFyle, stepRank)
						&& ::shift(black.bishops,	stepFyle, stepRank)
						&& ::shift(white.rooks,		stepFyle, stepRank)
						&& ::shift(black.rooks,		stepFyle, stepRank)
						&& ::shift(white.queens,	stepFyle, stepRank)
						&& ::shift(black.queens,	stepFyle, stepRank)
						&& ::shift(white.kings,		stepFyle, stepRank)
						&& ::shift(black.kings,		stepFyle, stepRank)
						&& ::shift(d.m_pos.empty,	stepFyle, stepRank))
					{
						position.add(d);
					}
				}
			}
		}
	}
}


void
Designator::flipcolor(Position& position) const
{
	Designator designator(*this);

	mstl::swap(designator.m_pos.pieces[White].kings,	designator.m_pos.pieces[Black].kings);
	mstl::swap(designator.m_pos.pieces[White].queens,	designator.m_pos.pieces[Black].queens);
	mstl::swap(designator.m_pos.pieces[White].rooks,	designator.m_pos.pieces[Black].rooks);
	mstl::swap(designator.m_pos.pieces[White].bishops,	designator.m_pos.pieces[Black].bishops);
	mstl::swap(designator.m_pos.pieces[White].knights,	designator.m_pos.pieces[Black].knights);
	mstl::swap(designator.m_pos.pieces[White].pawns,	designator.m_pos.pieces[Black].pawns);

	designator.fliphorizontal(position);
}


char const*
Designator::parse(char const* s, Error& error)
{
	char const* p = s;
	char const* q = s;

	if (*q == '[')
	{
		for ( ; *q != ']'; ++q)
		{
			if (*q == '\0')
			{
				error = Unmatched_Bracket;
				return s;
			}
		}

		++p;
		--q;

		if (p == q)
		{
			error = Empty_Piece_Designator;
			return s;
		}
	}
	else
	{
		++q;
	}

	uint64_t squares = 0;

	char const* t = s;

	if (*t == '[')
	{
		t = parseSequence(t + 1, error, squares);

		if (*t != ']')
		{
			for ( ; *t != ']'; ++t)
			{
				if (*t == '\0')
				{
					error = Unmatched_Bracket;
					return s;
				}
			}

			if (t[-1] == '[')
				squares = ~uint64_t(0);
		}

		s = t + 1;
	}

	material::Count count[2];
	count[White].value = count[Black].value = 0;

	for ( ; p < q; ++p)
	{
		switch (*p)
		{
			case 'K': m_pos.pieces[White].kings		|= squares; break;
			case 'Q': m_pos.pieces[White].queens	|= squares; break;
			case 'R': m_pos.pieces[White].rooks		|= squares; break;
			case 'B': m_pos.pieces[White].bishops	|= squares; break;
			case 'N': m_pos.pieces[White].knights	|= squares; break;
			case 'P': m_pos.pieces[White].pawns		|= squares; break;
			case 'k': m_pos.pieces[Black].kings		|= squares; break;
			case 'q': m_pos.pieces[Black].queens	|= squares; break;
			case 'r': m_pos.pieces[Black].rooks		|= squares; break;
			case 'b': m_pos.pieces[Black].bishops	|= squares; break;
			case 'n': m_pos.pieces[Black].knights	|= squares; break;
			case 'p': m_pos.pieces[Black].pawns		|= squares; break;
			case '.': m_pos.empty						|= squares; break;

			case 'A':
				m_pos.pieces[White].kings		|= squares;
				m_pos.pieces[White].queens		|= squares;
				m_pos.pieces[White].rooks		|= squares;
				m_pos.pieces[White].bishops 	|= squares;
				m_pos.pieces[White].knights	|= squares;
				m_pos.pieces[White].pawns		|= squares;
				break;

			case 'a':
				m_pos.pieces[Black].kings		|= squares;
				m_pos.pieces[Black].queens		|= squares;
				m_pos.pieces[Black].rooks		|= squares;
				m_pos.pieces[Black].bishops 	|= squares;
				m_pos.pieces[Black].knights	|= squares;
				m_pos.pieces[Black].pawns		|= squares;
				break;

			case 'M':
				m_pos.pieces[White].queens	|= squares;
				m_pos.pieces[White].rooks	|= squares;
				break;

			case 'm':
				m_pos.pieces[Black].queens	|= squares;
				m_pos.pieces[Black].rooks	|= squares;
				break;

			case 'I':
				m_pos.pieces[White].bishops |= squares;
				m_pos.pieces[White].knights |= squares;
				break;

			case 'i':
				m_pos.pieces[Black].bishops |= squares;
				m_pos.pieces[Black].knights |= squares;
				break;

			case 'U':
			case '?':
				for (unsigned i = 0; i < 2; ++i)
				{
					m_pos.pieces[i].kings	|= squares;
					m_pos.pieces[i].queens	|= squares;
					m_pos.pieces[i].rooks	|= squares;
					m_pos.pieces[i].bishops |= squares;
					m_pos.pieces[i].knights	|= squares;
					m_pos.pieces[i].pawns	|= squares;
				}
				break;
		}
	}

	return s;
}


char const*
Designator::parseSequence(char const* s, Error& error, uint64_t& squares)
{
	M_ASSERT(*s != ']');

	s = parseRange(s, error, squares);

	while (error == No_Error && *s == ',')
		s = parseRange(s + 1, error, squares);

	return s;
}


char const*
Designator::parseRange(char const* s, Error& error, uint64_t& squares)
{
	int fyle1 = -1;
	int fyle2 = -1;

	if (s[0] != '?' && (s[0] < 'a' || 'h' < s[0]))
	{
		error = Invalid_Fyle_In_Square_Designator;
		return s;
	}

	if (s[1] == '-')
	{
		if (s[0] == '?')
		{
			error = Any_Fyle_Not_Allowed_In_Range;
			return s;
		}

		if (s[2] == '?')
		{
			error = Any_Fyle_Not_Allowed_In_Range;
			return s + 2;
		}

		if (s[2] < 'a' || 'h' < s[2])
		{
			error = Invalid_Fyle_In_Square_Designator;
			return s + 2;
		}

		fyle1 = s[0] - 'a';
		fyle2 = s[2] - 'a';

		if (fyle1 > fyle2)
			mstl::swap(fyle1, fyle2);

		s += 3;
	}
	else
	{
		fyle1 = fyle2 = s[0] - 'a';
		s += 1;
	}

	if (s[0] != '?' && (s[0] < '1' || '8' < s[0]))
	{
		error = Invalid_Rank_In_Square_Designator;
		return s;
	}

	if (s[1] == '-')
	{
		if (s[0] == '?')
		{
			error = Any_Rank_Not_Allowed_In_Range;
			return s;
		}

		if (s[2] == '?')
		{
			error = Any_Rank_Not_Allowed_In_Range;
			return s + 2;
		}

		if (s[2] < '1' || '8' < s[2])
		{
			error = Invalid_Rank_In_Square_Designator;
			return s + 2;
		}

		int rank1 = s[0] - '1';
		int rank2 = s[2] - '2';

		if (rank1 > rank2)
			mstl::swap(rank1, rank2);

		for (int f = fyle1; f <= fyle2; ++f)
		{
			for (int r = rank1; r <= rank2; ++r)
				squares |= setBit(make(Fyle(f), Rank(r)));
		}

		return s + 3;
	}

	switch (s[0])
	{
		case 'a' ... 'h':
			switch (s[1])
			{
				case '1' ... '8':
					squares |= setBit(make(s));
					break;

				case '?':
					squares |= FyleMask[s[0] - 'a'];
					break;
			}
			break;

		case '?':
			switch (s[1])
			{
				case '1' ... '8':
					squares |= RankMask[s[1] - '1'];
					break;

				case '?':
					squares |= ~uint64_t(0);
					break;
			}
			break;
	}

	return s + 2;
}


Match::Match(variant::Type variant)
	:m_variant(variant)
	,m_initial(false)
	,m_final(false)
{
}


Match::~Match()
{
	::deleteAll(m_matchGameInfoList.begin(), m_matchGameInfoList.end());
	::deleteAll(m_matchPositionList.begin(), m_matchPositionList.end());
}


void Match::setInitial()	{ m_initial = true; }
void Match::setFinal()		{ m_final = true; }


char const*
Match::parseAnnotator(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Annotator(s, t));
	return t;
}


char const*
Match::parseBlackCountry(char const* s, Error& error)
{
	country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Country(country, color::Black));

	return s;
}


char const*
Match::parseBlackElo(char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Rating(rating::Elo, min, max, color::Black));

	return s;
}


char const*
Match::parseBlackGender(char const* s, Error& error)
{
	sex::ID sex = sex::Unspecified;

	s = ::parseGender(s, error, sex);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Gender(sex, color::Black));

	return s;
}


char const*
Match::parseBlackIsComputer(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsComputer(color::Black));
	return s;
}


char const*
Match::parseBlackIsHuman(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsHuman(color::Black));
	return s;
}

char const*
Match::parseBlackPlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Player(s, t, color::Black));
	return t;
}


char const*
Match::parseBlackRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
			m_matchGameInfoList.push_back(new gameinfo::Rating(ratingType, min, max, color::Black));
	}

	return s;
}


char const*
Match::parseBlackTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Title(titles, color::Black));

	return s;
}


char const*
Match::parseComment(char const* s, Error& error)
{
	if (*s != '"')
	{
		error = Double_Quote_Expected;
	}
	else
	{
		mstl::string comment;
		char const* t = s + 1;

		while (*t != '"')
		{
			switch (*t)
			{
				case '\0':
					error = Unterminated_String;
					return s;

				case '\\':
					switch (*(++t))
					{
						case 'n':	comment.append('\n'); break;
						case 't':	comment.append('\t'); break;
						default:		comment.append(*t); break;
					}
					++t;
					break;
			}
		}

		if (comment.empty())
		{
			error = Empty_String_Not_Allowed;
			return s;
		}

		m_matchCommentList.push_back(comment);
		s = t + 1;
	}

	return s;
}


char const*
Match::parseDate(char const* s, Error& error)
{
	Date min;

	s = ::parseDate(s, error, min);

	if (error != No_Error)
		return s;

	s = ::skipSpaces(s);

	Date max(min);

	if (s[0] == '.' && s[1] == '.')
	{
		s = ::parseDate(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Date(min, max));
	return s;
}


char const*
Match::parseEco(char const* s, Error& error)
{
	Eco min;

	s = ::parseEco(s, error, min);

	if (error != No_Error)
		return s;

	s = ::skipSpaces(s);

	Eco max(min);

	if (s[0] == '.' && s[1] == '.')
	{
		s = ::parseEco(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Eco(min, max));
	return s;
}


char const*
Match::parseElo(char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new gameinfo::Rating(rating::Elo, min, max, color::White));
		m_matchGameInfoList.push_back(new gameinfo::Rating(rating::Elo, min, max, color::Black));
	}

	return s;
}


char const*
Match::parseEvent(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Event(s, t));
	return t;
}


char const*
Match::parseEventCountry(char const* s, Error& error)
{
	country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::EventCountry(country));

	return s;
}


char const*
Match::parseEventDate(char const* s, Error& error)
{
	Date min;

	s = ::parseDate(s, error, min);

	if (error != No_Error)
		return s;

	Date max(min);

	if (s[0] == '.' && s[1] == '.')
	{
		s = ::parseDate(s, error, max);

		if (error != No_Error)
			return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::EventDate(min, max));
	return s;
}


char const*
Match::parseEventMode(char const* s, Error& error)
{
	event::Mode mode = event::modeFromString(s);

	if (mode == event::Undetermined)
	{
		error = Invalid_Event_Mode;
	}
	else
	{
		mstl::string const& str = event::toString(mode);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Event_Mode;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new gameinfo::EventMode(mode));
		}
	}

	return s;
}


char const*
Match::parseEventType(char const* s, Error& error)
{
	event::Type type = event::typeFromString(s);

	if (type == event::Unknown)
	{
		error = Invalid_Event_Type;
	}
	else
	{
		mstl::string const& str = event::toString(type);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Event_Type;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new gameinfo::EventType(type));
		}
	}

	return s;
}


char const*
Match::parseForAny(char const* s, Error& error)
{
	M_ASSERT(!"not yet implemented");
	return s;
}


char const*
Match::parseGameNumber(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;
		unsigned number = ::strtoul(s, &e, 10);
		s = e;
		m_matchGameInfoList.push_back(new gameinfo::GameNumber(number));
	}

	return s;
}


char const*
Match::parseHasAnnotation(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::HasAnnotation);
	return s;
}


char const*
Match::parseHasComments(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::HasComments);
	return s;
}


char const*
Match::parseHasFlags(char const* s, Error& error)
{
	unsigned flags = 0;

	while (!::isDelim(*s))
	{
		unsigned flag = GameInfo::charToFlag(*(s++));

		if (flag == 0)
		{
			error = Invalid_Game_Flag;
			return s;
		}

		flags |= flag;
	}

	m_matchGameInfoList.push_back(new gameinfo::GameFlags(flags));
	return s;
}


char const*
Match::parseHasVariations(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::HasVariation);
	return s;
}


char const*
Match::parseIsChess960(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsChess960);
	return s;
}


char const*
Match::parseIsShuffleChess(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsShuffleChess);
	return s;
}


char const*
Match::parseLanguage(char const* s, Error& error)
{
	M_ASSERT(!"not yet implemented");
	return s;
}


char const*
Match::parsePlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Player(s, t, color::White));
	m_matchGameInfoList.push_back(new gameinfo::Player(s, t, color::Black));
	return t;
}


char const*
Match::parsePlyCount(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char* e;
		unsigned min = ::strtoul(s, &e, 10);
		s = ::skipSpaces(e);

		unsigned max = min;

		if (s[0] == '.' && s[1] == '.')
		{
			s = ::skipSpaces(s);

			if (!::isdigit(*(++s)))
			{
				error = Positive_Integer_Expected;
			}
			else
			{
				max = ::strtoul(s, &e, 10);
				s = e;
			}
		}

		m_matchGameInfoList.push_back(new gameinfo::PlyCount(min, max));
	}

	return s;
}


char const*
Match::parsePosition(char const* s, Error& error)
{
	Position position(m_variant);
	s = position.parse(*this, s, error);
	if (error != No_Error)
		m_matchPositionList.push_back(new Position(position));
	return s;
}


char const*
Match::parseRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
		{
			m_matchGameInfoList.push_back(new gameinfo::Rating(ratingType, min, max, color::White));
			m_matchGameInfoList.push_back(new gameinfo::Rating(ratingType, min, max, color::Black));
		}
	}

	return s;
}


char const*
Match::parseResult(char const* s, Error& error)
{
	unsigned results = 0;

	if (*s == ',')
	{
		error = Invalid_Result;
		return s;
	}

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		if (	result == "*"
			|| result == "1-0"
			|| result == "0-1"
			|| result == "1/2"
			|| result == "1/2-1/2"
			|| result == "0-0")
		{
			result::ID r = result::fromString(result);
			M_ASSERT(r != result::Unknown);
			results |= (1u << r);
		}
		else
		{
			error = Invalid_Result;
			return s;
		}

		s = t;
	}
	while (*s == ',');

	m_matchGameInfoList.push_back(new gameinfo::Result(results));
	return s;
}


char const*
Match::parseRound(char const* s, Error& error)
{
	if (!::isdigit(*s))
	{
		error = Positive_Integer_Expected;
	}
	else
	{
		char const* t = s;
		char* e;
		unsigned round = ::strtoul(s, &e, 10);
		s = e;

		if (*s == '.')
		{
			if (!::isdigit(*(++s)))
			{
				error = Positive_Integer_Expected;
				s = t;
			}
			else
			{
				unsigned subround = ::strtoul(s, &e, 10);
				m_matchGameInfoList.push_back(new gameinfo::Round(round, subround));
				s = e;
			}
		}
		else
		{
			m_matchGameInfoList.push_back(new gameinfo::Round(round));
		}
	}

	return s;
}


char const*
Match::parseSite(char const* s, Error& error)
{
	char const* t = s;

	while (*t && *t != '(' && *t != ')' && !::isspace(*t))
		++t;

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Site(s, t));
	return t;
}


char const*
Match::parseTermination(char const* s, Error& error)
{
	unsigned reasons = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string result(s, t);

		result.toupper();

		termination::Reason reason = termination::fromString(s);

		if (reason == termination::Unknown || result != termination::toString(reason))
		{
			error = Invalid_Termination;
			return s;
		}

		reasons |= 1u << reason;
		s = t;
	}
	while (*s == ',');

	m_matchGameInfoList.push_back(new gameinfo::Termination(reasons));
	return s;
}


char const*
Match::parseTimeMode(char const* s, Error& error)
{
	unsigned modes = 0;

	do
	{
		if (*s == ',')
			++s;

		char const* t = ::skipToDelim(s);
		mstl::string mode(s, t);

		mode.tolower();

		time::Mode m = time::fromString(s);

		if (m == time::Unknown || mode != time::toString(m))
		{
			error = Invalid_Time_Mode;
			return s;
		}

		modes |= 1u << m;
		s = t;
	}
	while (*s == ',');

	m_matchGameInfoList.push_back(new gameinfo::TimeMode(modes));
	return s;
}


char const*
Match::parseTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
	{
		m_matchGameInfoList.push_back(new gameinfo::Title(titles, color::White));
		m_matchGameInfoList.push_back(new gameinfo::Title(titles, color::Black));
	}

	return s;
}


char const*
Match::parseVariant(char const* s, Error& error)
{
	variant::Type variant = variant::fromString(s);

	if (variant == variant::Undetermined)
	{
		error = Invalid_Variant;
	}
	else
	{
		mstl::string const& str = variant::identifier(variant);
		char const* t = ::skipToDelim(s);

		if (unsigned(t - s) != str.size() || ::strncasecmp(s, str, str.size()) != 0)
		{
			error = Invalid_Variant;
		}
		else
		{
			s += str.size();
			m_matchGameInfoList.push_back(new gameinfo::Variant(variant));
		}
	}

	return s;
}


char const*
Match::parseWhiteCountry(char const* s, Error& error)
{
	country::Code country;

	s = parseCountryCode(s, error, country);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Country(country, color::White));

	return s;
}


char const*
Match::parseWhiteElo(char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Rating(rating::Elo, min, max, color::White));

	return s;
}


char const*
Match::parseWhiteGender(char const* s, Error& error)
{
	sex::ID sex = sex::Unspecified;

	s = ::parseGender(s, error, sex);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Gender(sex, color::White));

	return s;
}


char const*
Match::parseWhiteIsComputer(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsComputer(color::White));
	return s;
}


char const*
Match::parseWhiteIsHuman(char const* s, Error& error)
{
	m_matchGameInfoList.push_back(new gameinfo::IsHuman(color::White));
	return s;
}


char const*
Match::parseWhitePlayer(char const* s, Error& error)
{
	char const* t = ::skipToDelim(s);

	if (s == t)
	{
		error = Pattern_Expected;
		return s;
	}

	m_matchGameInfoList.push_back(new gameinfo::Player(s, t, color::White));
	return t;
}


char const*
Match::parseWhiteRating(char const* s, Error& error)
{
	rating::Type ratingType;
	unsigned min, max;

	s = ::parseRatingType(s, error, ratingType);

	if (error == No_Error)
	{
		s = ::parseScores(s, error, min, max);

		if (error == No_Error)
			m_matchGameInfoList.push_back(new gameinfo::Rating(ratingType, min, max, color::White));
	}

	return s;
}


char const*
Match::parseWhiteTitle(char const* s, Error& error)
{
	unsigned titles = 0;

	s = ::parseTitle(s, error, titles);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Title(titles, color::White));

	return s;
}


char const*
Match::parseYear(char const* s, Error& error)
{
	unsigned min, max;

	s = ::parseScores(s, error, min, max);

	if (error == No_Error)
		m_matchGameInfoList.push_back(new gameinfo::Year(min, max));

	return s;
}


char const*
Match::parse(char const* s, Error& error)
{
	typedef MatchPair Pair;

	static Pair const Trampolin[] =
	{
		Pair("annotator",				&Match::parseAnnotator),			// extension
		Pair("blackcountry",			&Match::parseBlackCountry),		// extension
		Pair("blackelo",				&Match::parseBlackElo),
		Pair("blackgender",			&Match::parseBlackGender),			// extension
		Pair("blackiscomputer",		&Match::parseBlackIsComputer),	// extension
		Pair("blackishuman",			&Match::parseBlackIsHuman),		// extension
		Pair("blackplayer",			&Match::parseBlackPlayer),			// extension
		Pair("blackrating",			&Match::parseBlackRating),			// extension
		Pair("blacktitle",			&Match::parseBlackTitle),			// extension
		Pair("comment",				&Match::parseComment),				// extension
		Pair("date",					&Match::parseDate),					// extension
		Pair("eco",						&Match::parseEco),					// extension
		Pair("elo",						&Match::parseElo),
		Pair("event",					&Match::parseEvent),					// extension
		Pair("eventcountry",			&Match::parseEventCountry),		// extension
		Pair("eventdate",				&Match::parseEventDate),			// extension
		Pair("eventmode",				&Match::parseEventMode),			// extension
		Pair("eventtype",				&Match::parseEventType),			// extension
		Pair("forany",					&Match::parseForAny),
		Pair("gamenumber",			&Match::parseGameNumber),
		Pair("hasannotation",		&Match::parseHasAnnotation),		// extension
		Pair("hascomments",			&Match::parseHasComments),			// extension
		Pair("hasflags",				&Match::parseHasFlags),				// extension
		Pair("hasvariations",		&Match::parseHasVariations),		// extension
		Pair("ischess960",			&Match::parseIsChess960),			// extension
		Pair("isshufflechess",		&Match::parseIsShuffleChess),		// extension
		Pair("language",				&Match::parseLanguage),				// extension
		Pair("player",					&Match::parsePlayer),
		Pair("plycount",				&Match::parsePlyCount),				// extension
		Pair("position",				&Match::parsePosition),				// extension
		Pair("rating",					&Match::parseRating),				// extension
		Pair("result",					&Match::parseResult),
		Pair("round",					&Match::parseRound),
		Pair("site",					&Match::parseSite),					// extension
		Pair("termination",			&Match::parseTermination),			// extension
		Pair("timemode",				&Match::parseTimeMode),				// extension
		Pair("title",					&Match::parseTitle),					// extension
		Pair("variant",				&Match::parseVariant),				// extension
		Pair("whitecountry",			&Match::parseWhiteCountry),		// extension
		Pair("whiteelo",				&Match::parseWhiteElo),
		Pair("whitegender",			&Match::parseWhiteGender),			// extension
		Pair("whiteiscomputer",		&Match::parseWhiteIsComputer),	// extension
		Pair("whiteishuman",			&Match::parseWhiteIsHuman),		// extension
		Pair("whiteplayer",			&Match::parseWhitePlayer),			// extension
		Pair("whiterating",			&Match::parseWhiteRating),			// extension
		Pair("whitetitle",			&Match::parseWhiteTitle),			// extension
		Pair("year",					&Match::parseYear),
	};

	mstl::string key;

	error = No_Error;

	if (*s == '(')
	{
		s = ::skipSpaces(s);

		if (::matchKeyword(s, "match", 5))
		{
			s = ::skipSpaces(s + 6);

			while (*s == ':' || *s == '(')
			{
				if (*s == '(')
				{
					char const* t = ::skipSpaces(s + 1);

					if (t - s != 8 || ::strncmp(s, "position", 8) != 0)
					{
						error = Position_Expected;
						return s;
					}

					m_matchPositionList.push_back();
					s = m_matchPositionList.back()->parse(*this, t, error);

					if (error != No_Error)
					{
						m_matchPositionList.pop_back();
						return s;
					}
				}
				else
				{
					mstl::string key(s + 1, ::lengthOfKeyword(s + 1));
					Pair const* p = mstl::binary_search(Trampolin, Trampolin + U_NUMBER_OF(Trampolin), key);

					if (p == Trampolin + U_NUMBER_OF(Trampolin))
					{
						error = Invalid_Keyword;
						return s;
					}

					s = (this->*p->func)(::skipSpaces(s + key.size() + 1), error);

					if (error != No_Error)
						return s;

					s = ::skipSpaces(s);
				}
			}

			if (*s != ')')
			{
				error = Right_Parenthesis_Expected;
			}
			else
			{
				s = ::skipSpaces(s + 1);

				if (*s != '\0')
					error = Trailing_Characters;
			}
		}
		else
		{
			error = Keyword_Match_Expected;
		}
	}
	else
	{
		error = Left_Parenthesis_Expected;
	}

	return s;
}


bool
Match::match(GameInfo const& info, unsigned gameNo)
{
	MatchGameInfoList::iterator i = m_matchGameInfoList.begin();
	MatchGameInfoList::iterator e = m_matchGameInfoList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(info, gameNo))
			return false;
	}

	return true;
}


bool
Match::match(GameInfo const& info, Board const& board, bool isInitial, bool isFinal)
{
	if (m_initial && !isInitial)
		return false;

	if (m_final && !isFinal)
		return false;

	MatchPositionList::iterator i = m_matchPositionList.begin();
	MatchPositionList::iterator e = m_matchPositionList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(info, board, m_variant))
			return false;
	}

	return true;
}


bool
Match::match(Board const& board, Move const& move)
{
	M_ASSERT(board.sideToMove() == move.color());

	MatchPositionList::iterator i = m_matchPositionList.begin();
	MatchPositionList::iterator e = m_matchPositionList.end();

	for ( ; i != e; ++i)
	{
		if (!(*i)->match(board, move))
			return false;
	}

	return true;
}

// vi:set ts=3 sw=3:
