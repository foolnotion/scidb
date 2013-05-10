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

#include "cql_match_board.h"
#include "cql_position.h"
#include "cql_piece_type_designator.h"

#include "db_game_info.h"
#include "db_board_base.h"

#include "m_utility.h"

using namespace cql;
using namespace cql::board;
using namespace db;
using namespace db::board;
using namespace db::color;


static bool isAlwaysTrue(db::piece::Type) { return true; }


namespace bits {

typedef bool (*RayCondition)(db::piece::Type);


struct RayHorizontal
{
	typedef mstl::vector<Designator> List;
	typedef db::Board Board;

	RayHorizontal(Board const& board, List const& designators)
		:m_board(board)
		,m_designators(designators)
	{
	}

	unsigned matchLeft(Square s, uint64_t ray, uint64_t empty)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = msb(pieces);
			uint64_t	e = mstl::bitfield<uint64_t>::mask(t, s); // empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	unsigned matchRight(Square s, uint64_t ray, uint64_t empty)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = lsb(pieces);
			uint64_t	e = mstl::bitfield<uint64_t>::mask(s, t); // empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	bool match(RayCondition cond = &isAlwaysTrue)
	{
		M_ASSERT(m_designators.size() >= 2);

		uint64_t pieces = m_designators[0].find(m_board);

		if (pieces == 0)
			return 0;

		unsigned count = 0;

		uint64_t empty = m_board.empty();

		for (unsigned i = 0; i < 8; ++i)
		{
			uint64_t ray = db::board::RankMask[i];
			uint64_t r = pieces & ray;

			while (r)
			{
				Square s = lsbClear(r);

				if (r && cond(m_board.piece(s)))
				{
					uint64_t bit	= setBit(s);
					uint64_t rl		= ray & (bit - 1);	// left from square s
					uint64_t rr		= ray & ~(rl | bit);	// right from square s

					if (rl)
						count += matchLeft(s, rl, empty);
					if (rr)
						count += matchRight(s, rr, empty);
				}
			}
		}

		return count;
	}

	Board const&	m_board;
	List const&			m_designators;
};


struct RayVertical
{
	typedef mstl::vector<Designator> List;
	typedef db::Board Board;

	RayVertical(Board const& board, List const& designators)
		:m_board(board)
		,m_designators(designators)
	{
	}

	unsigned matchBelow(Square s, uint64_t ray, uint64_t empty)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = msb(pieces);
			uint64_t	e = db::board::MaskVertical[s][t]; // empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	unsigned matchAbove(Square s, uint64_t ray, uint64_t empty)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = lsb(pieces);
			uint64_t	e = db::board::MaskVertical[s][t]; // empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	bool match(RayCondition cond = &isAlwaysTrue)
	{
		M_ASSERT(m_designators.size() >= 2);

		uint64_t pieces = m_designators[0].find(m_board);

		if (pieces == 0)
			return 0;

		unsigned count = 0;

		uint64_t empty = m_board.empty();

		for (unsigned i = 0; i < 8; ++i)
		{
			uint64_t ray	= db::board::FyleMask[i];
			uint64_t r		= pieces & ray;

			while (r)
			{
				Square s = lsbClear(r);

				if (r && cond(m_board.piece(s)))
				{
					uint64_t bit	= setBit(s);
					uint64_t rb		= ray & (bit - 1);	// below square s
					uint64_t ra		= ray & ~(rb | bit);	// above square s

					if (rb)
						count += matchBelow(s, rb, empty);
					if (ra)
						count += matchAbove(s, ra, empty);
				}
			}
		}

		return count;
	}

	Board const&	m_board;
	List const&			m_designators;
};


struct RayDiagonal
{
	typedef mstl::vector<Designator> List;
	typedef db::Board Board;

	RayDiagonal(Board const& board, List const& designators)
		:m_board(board)
		,m_designators(designators)
	{
	}

	unsigned matchBelow(Square s, uint64_t ray, uint64_t empty, uint64_t diagonal)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = msb(pieces);
			uint64_t	e = mstl::bitfield<uint64_t>::mask(t, s) & diagonal;	// empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	unsigned matchAbove(Square s, uint64_t ray, uint64_t empty, uint64_t diagonal)
	{
		for (unsigned index = 2; index < m_designators.size(); ++index)
		{
			uint64_t pieces = m_designators[index].find(m_board) & ray;

			if (pieces == 0)
				return 0;

			Square	t = lsb(pieces);
			uint64_t	e = mstl::bitfield<uint64_t>::mask(s, t) & diagonal;	// empty squares

			ray &= ~e;
			e &= ~(setBit(s) | setBit(t));

			if ((empty & e) != e)
				return 0;

			s = t;
		}

		return 1;
	}

	bool match(uint64_t const* maskDiagonal, RayCondition cond = &isAlwaysTrue)
	{
		M_ASSERT(m_designators.size() >= 2);
		M_ASSERT(maskDiagonal);

		uint64_t pieces = m_designators[0].find(m_board);

		if (pieces == 0)
			return 0;

		unsigned count = 0;

		uint64_t empty	= m_board.empty();

		while (pieces)
		{
			Square s = lsbClear(pieces);

			if (pieces && cond(m_board.piece(s)))
			{
				uint64_t	diagonal = maskDiagonal[s];
				uint64_t	ray		= pieces & diagonal;
				uint64_t bit		= setBit(s);
				uint64_t rb			= ray & (bit - 1);	// below square s
				uint64_t ra			= ray & ~(rb | bit);	// above square s

				if (rb)
					count += matchBelow(s, rb, empty, diagonal);
				if (ra)
					count += matchAbove(s, ra, empty, diagonal);
			}
		}

		return count;
	}

	Board const&	m_board;
	List const&			m_designators;
};

} // namespace bits


template <class Iterator>
inline
static void
deleteAll(Iterator first, Iterator last)
{
	for ( ; first != last; ++first)
		delete *first;
}


static bool
isEndGame(db::Board const& board, variant::Type variant)
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
				&& Designator::power(b, variant) <= 16)
			|| (	b.queen == 1
				&& w.queen == 0
				&& b.rook == 0
				&& b.bishop + b.knight <= 1
				&& Designator::power(w, variant) <= 16);
}


cql::board::Match::~Match() {}

bool MatchMinMax::result(unsigned count) { return mstl::is_between(count, m_min, m_max); }
void MatchRay::add(Designator const& designator) { m_designators.push_back(designator); }



bool
Designators::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	for (List::iterator i = m_list.begin(); i != m_list.end(); ++i)
	{
		if (!i->match(board))
			return false;
	}

	return true;
}


AttackCount::AttackCount(Designator const& fst, Designator const& snd, unsigned min, unsigned max)
	:MatchMinMax(min, max)
	,m_fst(fst)
	,m_snd(snd)
{
	m_color[White] = bool(m_fst.pieces(White)) && bool(m_snd.pieces(Black));
	m_color[Black] = bool(m_fst.pieces(Black)) && bool(m_snd.pieces(White));
}


bool
AttackCount::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	color::ID sideToMove = board.sideToMove();

	unsigned n = 0;

	if (m_color[sideToMove])
	{
		uint64_t attackers	= m_fst.pieces(board, sideToMove);
		uint64_t affected		= m_snd.pieces(board, board.notToMove());

		while (attackers)
			n += count(board.attacks(sideToMove, lsbClear(attackers)) & affected);
	}

	return result(n);
}


bool
CannotWin::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.cannotWin(m_color, variant);
}


bool
Check::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.isInCheck();
}


bool
DoubleCheck::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.isInCheck() && (board.checkState(variant) & Board::DoubleCheck);
}


bool
NoCheck::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return !board.isInCheck();
}


bool
NoDoubleCheck::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return !board.isInCheck() && (board.checkState(variant) & Board::DoubleCheck) == 0;
}


Castling::Castling(PieceTypeDesignator const& designator)
	:m_castling(0)
{
	if (designator.test(cql::piece::WK))
		m_castling |= castling::WhiteKingside;
	if (designator.test(cql::piece::BK))
		m_castling |= castling::BlackKingside;
	if (designator.test(cql::piece::WQ))
		m_castling |= castling::WhiteQueenside;
	if (designator.test(cql::piece::BQ))
		m_castling |= castling::BlackQueenside;
}


bool
Castling::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return bool(board.signature().castling() & m_castling);
}


bool
ContactCheck::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.isContactCheck();
}


bool
NoContactCheck::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return !board.isContactCheck();
}


bool
State::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	unsigned states = board.checkState(variant);
	return (states & m_and) == m_and && (states & m_not) == 0;
}


bool
ToMove::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.sideToMove() == m_color;
}


Fen::Fen(Board const& board)
	:m_board(board)
{
	m_includeHolding	=  board.checksGiven(White) > 0
							|| board.checksGiven(Black) > 0
							|| board.holding(White).total() > 0
							|| board.holding(Black).total() > 0;
}


bool
Fen::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (m_includeHolding && (variant::isZhouse(variant) || variant == variant::ThreeCheck))
		return board.isEqualZHPosition(m_board);

	return board.isEqualPosition(m_board);
}


bool
FiftyMoveRule::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.halfMoveClock() >= 100;
}


bool
HalfmoveClockLimit::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.halfMoveClock() <= m_limit;
}


bool
CheckCount::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (variant != variant::ThreeCheck)
		return false;

	if (m_bcount < 4)
		return board.checksGiven(White) == m_wcount || board.checksGiven(Black) == m_wcount;

	return board.checksGiven(White) == m_wcount && board.checksGiven(Black) == m_bcount;
}


bool
EndGame::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return ::isEndGame(board, variant);
}


bool
NoEndGame::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return !isEndGame(board, variant);
}


cql::Position&
Sequence::pushBack()
{
	m_stack.reserve(m_list.size() + 1);
	return GappedSequence::pushBack();
}


bool
Sequence::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (m_info != &info)
	{
		m_info = &info;
		m_index = 0;
		m_stack.clear();
	}

	if (m_list[m_index]->match(info, board, variant, flags))
	{
		if (++m_index == m_list.size())
		{
			m_index = 0;
			m_stack.clear();
			return true;
		}

		m_stack.push_back(board);
	}
	else
	{
		Stack::const_iterator i = m_stack.begin();
		Stack::const_iterator e = m_stack.end();

		m_index = 0;

		while (i != e && m_list[m_index]->match(info, *i, variant, flags))
		{
			++m_index;
			++i;
		}

		m_stack.resize(i);
	}

	return false;
}


GappedSequence::~GappedSequence() { ::deleteAll(m_list.begin(), m_list.end()); }


cql::Position&
GappedSequence::pushBack()
{
	m_list.push_back();
	return *m_list.back();
}


bool
GappedSequence::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (m_info != &info)
	{
		m_info = &info;
		m_index = 0;
	}

	if (m_list[m_index]->match(info, board, variant, flags))
	{
		if (++m_index == m_list.size())
		{
			m_index = 0;
			return true;
		}
	}

	// XXX not working if combined with not.
	// XXX in this case we have to return 'probably'; that means: don't stop matching
	return false;
}


bool
MatingMaterial::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return board.neitherPlayerHasMatingMaterial(variant) == !m_negate;
}


bool
Evaluation::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	// TODO
	return false;
}


bool
MaxSwapEvaluation::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	MoveList moves;
	int maxScore = INT_MIN;

	board.generateMoves(variant, moves);
	board.filterLegalMoves(moves, variant);

	for (MoveList::const_iterator i = moves.begin(); i != moves.end(); ++i)
	{
		if ((m_from.pieces(White) & setBit(i->from())) && (m_to.pieces(White) & setBit(i->to())))
		{
			int score = board.staticExchangeEvaluator(*i, Designator::pieceValues(variant));
			if (score > maxScore)
				maxScore = score;
		}
	}

	return mstl::is_between(maxScore, m_minScore, m_maxScore);
}


bool
PieceCount::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	return result(m_designator.count(board));
}


bool
Power::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	unsigned power = m_designator.powerWhite(board, variant) + m_designator.powerBlack(board, variant);
	return result(power);
}


bool
PowerDifference::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	int diff = int(m_designator.powerWhite(board, variant))
				- int(m_designator.powerBlack(board, variant));

	return m_min <= diff && diff <= m_max;
}


bool
Repetition::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	if (flags & flags::IsInsideVariation)
		return false; // skip variations

	if (m_info != &info)
	{
		m_map.clear();
		m_info = &info;
	}

	PositionBucket& bucket = m_map[board.hash()];

	PositionBucket::iterator i = bucket.begin();
	PositionBucket::iterator e = bucket.end();

	while (i != e && i->m_board != board.exactZHPosition())
		++i;

	if (i == e)
		bucket.push_back(board.exactZHPosition());
	else if (++i->m_count == 3)
		return true;

	return false;
}


bool
RayHorizontal::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayHorizontal match(board, m_designators);
	return result(match.match());
}


bool
RayVertical::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayVertical match(board, m_designators);
	return result(match.match());
}


bool
RayOrthogonal::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayHorizontal horz(board, m_designators);
	::bits::RayVertical   vert(board, m_designators);

	return result(horz.match() + vert.match());
}


bool
RayDiagonal::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayDiagonal match(board, m_designators);
	return result(match.match(db::board::MaskDiagonal) + match.match(db::board::MaskOffDiagonal));
}


bool
Ray::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayHorizontal	horz(board, m_designators);
	::bits::RayVertical		vert(board, m_designators);
	::bits::RayDiagonal		diag(board, m_designators);

	return result(	horz.match()
					 + vert.match()
					 + diag.match(db::board::MaskDiagonal)
					 + diag.match(db::board::MaskOffDiagonal));
}


bool
RayAttack::match(GameInfo const& info, Board const& board, Variant variant, unsigned flags)
{
	::bits::RayHorizontal	horz(board, m_designators);
	::bits::RayVertical		vert(board, m_designators);
	::bits::RayDiagonal		diag(board, m_designators);

	return result(	horz.match(&db::piece::isOrthogonalLongStepPiece)
					 + vert.match(&db::piece::isOrthogonalLongStepPiece)
					 + diag.match(db::board::MaskDiagonal, db::piece::isDiagonalLongStepPiece)
					 + diag.match(db::board::MaskOffDiagonal, db::piece::isDiagonalLongStepPiece));
}

// vi:set ts=3 sw=3:
