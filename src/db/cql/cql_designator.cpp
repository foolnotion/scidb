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

#include "cql_designator.h"

#include "db_board.h"
#include "db_board_base.h"

#include <ctype.h>

using namespace cql;
using namespace cql::error;
using namespace db;
using namespace db::board;
using namespace db::color;
using namespace db::sq;


namespace {

enum
{
	WK = 1 << 0,	// white king
	WQ = 1 << 1,	// white queen
	WR = 1 << 2,	// white rook
	WB = 1 << 3,	// white bishop
	WN = 1 << 4,	// white knight
	WP = 1 << 5,	// white pawn
	WM = WQ | WR,	// white major piece
	WI = WB | WN,	// white minor piece

	WA = WK | WM | WI | WP,	// any white piece

	BK = 1 << 10,	// black king
	BQ = 1 << 11,	// black queen
	BR = 1 << 12,	// black rook
	BB = 1 << 13,	// black bishop
	BN = 1 << 14,	// black knight
	BP = 1 << 15,	// black pawn
	BM = BQ | BR,	// black major piece
	BI = BB | BN,	// black minor piece

	BA = BK | BM | BI | BP,	// any black piece

	U  = WA | BA,
	E  = 1 << 20,	// empty
};


inline static bool matchAny(uint64_t lhs, uint64_t rhs) { return bool(lhs & rhs); }


static bool
match(cql::Board const& pos, db::Board const& board)
{
	return	(	matchAny(pos.pieces[White].any, board.pieces(White))
				|| matchAny(pos.pieces[Black].any, board.pieces(Black)))
			&& (	matchAny(pos.pieces[White].pawns, board.pawns(White))
				|| matchAny(pos.pieces[White].knights, board.knights(White))
				|| matchAny(pos.pieces[White].bishops, board.bishops(White))
				|| matchAny(pos.pieces[White].rooks, board.rooks(White))
				|| matchAny(pos.pieces[White].queens, board.queens(White))
				|| matchAny(pos.pieces[White].kings, board.kings(White)))
				|| matchAny(pos.pieces[Black].pawns, board.pawns(Black))
				|| matchAny(pos.pieces[Black].knights, board.knights(Black))
				|| matchAny(pos.pieces[Black].bishops, board.bishops(Black))
				|| matchAny(pos.pieces[Black].rooks, board.rooks(Black))
				|| matchAny(pos.pieces[Black].queens, board.queens(Black))
				|| matchAny(pos.pieces[Black].kings, board.kings(Black));
}


template <unsigned> bool match(cql::Board const&, db::Board const&);


template <>
inline bool
match<WK>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].kings, board.kings(White));
}

template <>
inline bool
match<BK>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].kings, board.kings(White));
}

template <>
inline bool
match<WQ>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].queens, board.queens(White));
}

template <>
inline bool
match<BQ>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[Black].queens, board.queens(Black));
}

template <>
inline bool
match<WR>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].rooks, board.rooks(White));
}

template <>
inline bool
match<BR>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[Black].rooks, board.rooks(Black));
}

template <>
inline bool
match<WB>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].bishops, board.bishops(White));
}

template <>
inline bool
match<BB>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[Black].bishops, board.bishops(Black));
}

template <>
inline bool
match<WN>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].knights, board.knights(White));
}

template <>
inline bool
match<BN>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[Black].knights, board.knights(Black));
}

template <>
inline bool
match<WP>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[White].pawns, board.pawns(White));
}

template <>
inline bool
match<BP>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.pieces[Black].pawns, board.pawns(Black));
}

template <>
inline bool
match<WI>(cql::Board const& pos, db::Board const& board)
{
	return match<WB>(pos, board) || match<WN>(pos, board);
}

template <>
inline bool
match<BI>(cql::Board const& pos, db::Board const& board)
{
	return match<BB>(pos, board) || match<BN>(pos, board);
}

template <>
inline bool
match<WM>(cql::Board const& pos, db::Board const& board)
{
	return match<WQ>(pos, board) || match<WR>(pos, board);
}

template <>
inline bool
match<BM>(cql::Board const& pos, db::Board const& board)
{
	return match<BQ>(pos, board) || match<BR>(pos, board);
}

template <>
inline bool
match<WA>(cql::Board const& pos, db::Board const& board)
{
	return match<WM>(pos, board) || match<WI>(pos, board) || match<WP>(pos, board);
}

template <>
inline bool
match<BA>(cql::Board const& pos, db::Board const& board)
{
	return match<BM>(pos, board) || match<BI>(pos, board) || match<BP>(pos, board);
}

template <>
inline bool
match<U>(cql::Board const& pos, db::Board const& board)
{
	return bool(pos.any & board.pieces());
}

template <>
inline bool
match<E>(cql::Board const& pos, db::Board const& board)
{
	return matchAny(pos.empty, board.empty());
}


inline static unsigned countAny(uint64_t lhs, uint64_t rhs) { return db::board::count(lhs & rhs); }


static unsigned
count(cql::Board const& pos, db::Board const& board)
{
	return	countAny(pos.pieces[White].pawns, board.pawns(White))
			 + countAny(pos.pieces[White].knights, board.knights(White))
			 + countAny(pos.pieces[White].bishops, board.bishops(White))
			 + countAny(pos.pieces[White].rooks, board.rooks(White))
			 + countAny(pos.pieces[White].queens, board.queens(White))
			 + countAny(pos.pieces[White].kings, board.kings(White))
			 + countAny(pos.pieces[Black].pawns, board.pawns(Black))
			 + countAny(pos.pieces[Black].knights, board.knights(Black))
			 + countAny(pos.pieces[Black].bishops, board.bishops(Black))
			 + countAny(pos.pieces[Black].rooks, board.rooks(Black))
			 + countAny(pos.pieces[Black].queens, board.queens(Black))
			 + countAny(pos.pieces[Black].kings, board.kings(Black));
}


template <unsigned> unsigned count(cql::Board const&, db::Board const&);


template <>
inline unsigned
count<WK>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].kings, board.kings(White));
}

template <>
inline unsigned
count<BK>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].kings, board.kings(White));
}

template <>
inline unsigned
count<WQ>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].queens, board.queens(White));
}

template <>
inline unsigned
count<BQ>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[Black].queens, board.queens(Black));
}

template <>
inline unsigned
count<WR>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].rooks, board.rooks(White));
}

template <>
inline unsigned
count<BR>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[Black].rooks, board.rooks(Black));
}

template <>
inline unsigned
count<WB>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].bishops, board.bishops(White));
}

template <>
inline unsigned
count<BB>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[Black].bishops, board.bishops(Black));
}

template <>
inline unsigned
count<WN>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].knights, board.knights(White));
}

template <>
inline unsigned
count<BN>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[Black].knights, board.knights(Black));
}

template <>
inline unsigned
count<WP>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[White].pawns, board.pawns(White));
}

template <>
inline unsigned
count<BP>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.pieces[Black].pawns, board.pawns(Black));
}

template <>
inline unsigned
count<WI>(cql::Board const& pos, db::Board const& board)
{
	return count<WB>(pos, board) + count<WN>(pos, board);
}

template <>
inline unsigned
count<BI>(cql::Board const& pos, db::Board const& board)
{
	return count<BB>(pos, board) + count<BN>(pos, board);
}

template <>
inline unsigned
count<WM>(cql::Board const& pos, db::Board const& board)
{
	return count<WQ>(pos, board) + count<WR>(pos, board);
}

template <>
inline unsigned
count<BM>(cql::Board const& pos, db::Board const& board)
{
	return count<BQ>(pos, board) + count<BR>(pos, board);
}

template <>
inline unsigned
count<WA>(cql::Board const& pos, db::Board const& board)
{
	return count<WM>(pos, board) + count<WI>(pos, board) + count<WP>(pos, board);
}

template <>
inline unsigned
count<BA>(cql::Board const& pos, db::Board const& board)
{
	return count<BM>(pos, board) + count<BI>(pos, board) + count<BP>(pos, board);
}

template <>
inline unsigned
count<U>(cql::Board const& pos, db::Board const& board)
{
	return db::board::count(pos.any & board.pieces());
}

template <>
inline unsigned
count<E>(cql::Board const& pos, db::Board const& board)
{
	return countAny(pos.empty, board.empty());
}


static uint64_t
find(cql::Board const& pos, db::Board const& board)
{
	return	(pos.pieces[White].pawns	& board.pawns(White))
			 | (pos.pieces[Black].pawns	& board.pawns(Black))
			 | (pos.pieces[White].knights	& board.knights(White))
			 | (pos.pieces[Black].knights	& board.knights(Black))
			 | (pos.pieces[White].bishops	& board.bishops(White))
			 | (pos.pieces[Black].bishops	& board.bishops(Black))
			 | (pos.pieces[White].rooks	& board.rooks(White))
			 | (pos.pieces[Black].rooks	& board.rooks(Black))
			 | (pos.pieces[White].queens	& board.queens(White))
			 | (pos.pieces[Black].queens	& board.queens(Black))
			 | (pos.pieces[White].kings	& board.kings(White))
			 | (pos.pieces[Black].kings	& board.kings(Black));
}


template <unsigned> uint64_t find(cql::Board const&, db::Board const&);


template <>
inline uint64_t
find<WK>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].kings & board.kings(White);
}

template <>
inline uint64_t
find<BK>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].kings & board.kings(White);
}

template <>
inline uint64_t
find<WQ>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].queens & board.queens(White);
}

template <>
inline uint64_t
find<BQ>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[Black].queens & board.queens(Black);
}

template <>
inline uint64_t
find<WR>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].rooks & board.rooks(White);
}

template <>
inline uint64_t
find<BR>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[Black].rooks & board.rooks(Black);
}

template <>
inline uint64_t
find<WB>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].bishops & board.bishops(White);
}

template <>
inline uint64_t
find<BB>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[Black].bishops & board.bishops(Black);
}

template <>
inline uint64_t
find<WN>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].knights & board.knights(White);
}

template <>
inline uint64_t
find<BN>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[Black].knights & board.knights(Black);
}

template <>
inline uint64_t
find<WP>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[White].pawns & board.pawns(White);
}

template <>
inline uint64_t
find<BP>(cql::Board const& pos, db::Board const& board)
{
	return pos.pieces[Black].pawns & board.pawns(Black);
}

template <>
inline uint64_t
find<WI>(cql::Board const& pos, db::Board const& board)
{
	return find<WB>(pos, board) | find<WN>(pos, board);
}

template <>
inline uint64_t
find<BI>(cql::Board const& pos, db::Board const& board)
{
	return find<BB>(pos, board) | find<BN>(pos, board);
}

template <>
inline uint64_t
find<WM>(cql::Board const& pos, db::Board const& board)
{
	return find<WQ>(pos, board) | find<WR>(pos, board);
}

template <>
inline uint64_t
find<BM>(cql::Board const& pos, db::Board const& board)
{
	return find<BQ>(pos, board) | find<BR>(pos, board);
}

template <>
inline uint64_t
find<WA>(cql::Board const& pos, db::Board const& board)
{
	return find<WM>(pos, board) | find<WI>(pos, board) | find<WP>(pos, board);
}

template <>
inline uint64_t
find<BA>(cql::Board const& pos, db::Board const& board)
{
	return find<BM>(pos, board) | find<BI>(pos, board) | find<BP>(pos, board);
}

template <>
inline uint64_t
find<U>(cql::Board const& pos, db::Board const& board)
{
	return pos.any & board.pieces();
}

template <>
inline uint64_t
find<E>(cql::Board const& pos, db::Board const& board)
{
	return pos.empty & board.empty();
}


static unsigned
different(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return	db::board::count(pos.pieces[White].pawns		& (p1.pawns(White)	^ p2.pawns(White)))
			 + db::board::count(pos.pieces[Black].pawns		& (p1.pawns(Black)	^ p2.pawns(Black)))
			 + db::board::count(pos.pieces[White].knights	& (p1.knights(White)	^ p2.knights(White)))
			 + db::board::count(pos.pieces[Black].knights	& (p1.knights(Black)	^ p2.knights(Black)))
			 + db::board::count(pos.pieces[White].bishops	& (p1.bishops(White)	^ p2.bishops(White)))
			 + db::board::count(pos.pieces[Black].bishops	& (p1.bishops(Black)	^ p2.bishops(Black)))
			 + db::board::count(pos.pieces[White].rooks		& (p1.rooks(White)	^ p2.rooks(White)))
			 + db::board::count(pos.pieces[Black].rooks		& (p1.rooks(Black)	^ p2.rooks(Black)))
			 + db::board::count(pos.pieces[White].queens		& (p1.queens(White)	^ p2.queens(White)))
			 + db::board::count(pos.pieces[Black].queens		& (p1.queens(Black)	^ p2.queens(Black)))
			 + db::board::count(pos.pieces[White].kings		& (p1.kings(White)	^ p2.kings(White)))
			 + db::board::count(pos.pieces[Black].kings		& (p1.kings(Black)	^ p2.kings(Black)));
}


template <unsigned> unsigned different(cql::Board const&, db::Board const&, db::Board const&);


template <>
inline unsigned
different<WK>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].kings & (p1.kings(White) ^ p2.kings(White)));
}

template <>
inline unsigned
different<BK>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].kings & (p1.kings(White) ^ p2.kings(White)));
}

template <>
inline unsigned
different<WQ>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].queens & (p1.queens(White) ^ p2.queens(White)));
}

template <>
inline unsigned
different<BQ>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].queens & (p1.queens(Black) ^ p2.queens(Black)));
}

template <>
inline unsigned
different<WR>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].rooks & (p1.rooks(White) ^ p2.rooks(White)));
}

template <>
inline unsigned
different<BR>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].rooks & (p1.rooks(Black) ^ p2.rooks(Black)));
}

template <>
inline unsigned
different<WB>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].bishops & (p1.bishops(White) ^ p2.bishops(White)));
}

template <>
inline unsigned
different<BB>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].bishops & (p1.bishops(Black) ^ p2.bishops(Black)));
}

template <>
inline unsigned
different<WN>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].knights & (p1.knights(White) ^ p2.knights(White)));
}

template <>
inline unsigned
different<BN>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].knights & (p1.knights(Black) ^ p2.knights(Black)));
}

template <>
inline unsigned
different<WP>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].pawns & (p1.pawns(White) ^ p2.pawns(White)));
}

template <>
inline unsigned
different<BP>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].pawns & (p1.pawns(Black) ^ p2.pawns(Black)));
}

template <>
inline unsigned
different<WI>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<WB>(pos, p1, p2) + different<WN>(pos, p1, p2);
}

template <>
inline unsigned
different<BI>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<BB>(pos, p1, p2) + different<BN>(pos, p1, p2);
}

template <>
inline unsigned
different<WM>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<WQ>(pos, p1, p2) + different<WR>(pos, p1, p2);
}

template <>
inline unsigned
different<BM>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<BQ>(pos, p1, p2) + different<BR>(pos, p1, p2);
}

template <>
inline unsigned
different<WA>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<WM>(pos, p1, p2) + different<WI>(pos, p1, p2) + different<WP>(pos, p1, p2);
}

template <>
inline unsigned
different<BA>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return different<BM>(pos, p1, p2) + different<BI>(pos, p1, p2) + different<BP>(pos, p1, p2);
}

template <>
inline unsigned
different<U>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.any & (p1.pieces() ^ p2.pieces()));
}

template <>
inline unsigned
different<E>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.empty & (p1.empty() ^ p2.empty()));
}


static unsigned
same(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return	db::board::count(pos.pieces[White].pawns		& p1.pawns(White)		& p2.pawns(White))
			 + db::board::count(pos.pieces[Black].pawns		& p1.pawns(Black)		& p2.pawns(Black))
			 + db::board::count(pos.pieces[White].knights	& p1.knights(White)	& p2.knights(White))
			 + db::board::count(pos.pieces[Black].knights	& p1.knights(Black)	& p2.knights(Black))
			 + db::board::count(pos.pieces[White].bishops	& p1.bishops(White)	& p2.bishops(White))
			 + db::board::count(pos.pieces[Black].bishops	& p1.bishops(Black)	& p2.bishops(Black))
			 + db::board::count(pos.pieces[White].rooks		& p1.rooks(White)		& p2.rooks(White))
			 + db::board::count(pos.pieces[Black].rooks		& p1.rooks(Black)		& p2.rooks(Black))
			 + db::board::count(pos.pieces[White].queens		& p1.queens(White)	& p2.queens(White))
			 + db::board::count(pos.pieces[Black].queens		& p1.queens(Black)	& p2.queens(Black))
			 + db::board::count(pos.pieces[White].kings		& p1.kings(White)		& p2.kings(White))
			 + db::board::count(pos.pieces[Black].kings		& p1.kings(Black)		& p2.kings(Black));
}


template <unsigned> unsigned same(cql::Board const&, db::Board const&, db::Board const&);


template <>
inline unsigned
same<WK>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].kings & p1.kings(White) & p2.kings(White));
}

template <>
inline unsigned
same<BK>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].kings & p1.kings(White) & p2.kings(White));
}

template <>
inline unsigned
same<WQ>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].queens & p1.queens(White) & p2.queens(White));
}

template <>
inline unsigned
same<BQ>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].queens & p1.queens(Black) & p2.queens(Black));
}

template <>
inline unsigned
same<WR>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].rooks & p1.rooks(White) & p2.rooks(White));
}

template <>
inline unsigned
same<BR>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].rooks & p1.rooks(Black) & p2.rooks(Black));
}

template <>
inline unsigned
same<WB>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].bishops & p1.bishops(White) & p2.bishops(White));
}

template <>
inline unsigned
same<BB>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].bishops & p1.bishops(Black) & p2.bishops(Black));
}

template <>
inline unsigned
same<WN>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].knights & p1.knights(White) & p2.knights(White));
}

template <>
inline unsigned
same<BN>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].knights & p1.knights(Black) & p2.knights(Black));
}

template <>
inline unsigned
same<WP>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[White].pawns & p1.pawns(White) & p2.pawns(White));
}

template <>
inline unsigned
same<BP>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.pieces[Black].pawns & p1.pawns(Black) & p2.pawns(Black));
}

template <>
inline unsigned
same<WI>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<WB>(pos, p1, p2) + same<WN>(pos, p1, p2);
}

template <>
inline unsigned
same<BI>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<BB>(pos, p1, p2) + same<BN>(pos, p1, p2);
}

template <>
inline unsigned
same<WM>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<WQ>(pos, p1, p2) + same<WR>(pos, p1, p2);
}

template <>
inline unsigned
same<BM>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<BQ>(pos, p1, p2) + same<BR>(pos, p1, p2);
}

template <>
inline unsigned
same<WA>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<WM>(pos, p1, p2) + same<WI>(pos, p1, p2) + same<WP>(pos, p1, p2);
}

template <>
inline unsigned
same<BA>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return same<BM>(pos, p1, p2) + same<BI>(pos, p1, p2) + same<BP>(pos, p1, p2);
}

template <>
inline unsigned
same<U>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.any & p1.pieces() & p2.pieces());
}

template <>
inline unsigned
same<E>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)
{
	return db::board::count(pos.empty & p1.empty() & p2.empty());
}


#define DEFUN(P1,P2)                                                                 \
	template <>                                                                       \
	inline bool                                                                       \
	match<P1|P2>(cql::Board const& pos, db::Board const& board)                       \
	{                                                                                 \
		return match<P1>(pos, board) && match<P2>(pos, board);                         \
	}                                                                                 \
	template <>                                                                       \
	inline unsigned                                                                   \
	count<P1|P2>(cql::Board const& pos, db::Board const& board)                       \
	{                                                                                 \
		return count<P1>(pos, board) + count<P2>(pos, board);                          \
	}                                                                                 \
	template <>                                                                       \
	inline uint64_t                                                                   \
	find<P1|P2>(cql::Board const& pos, db::Board const& board)                        \
	{                                                                                 \
		return find<P1>(pos, board) | find<P2>(pos, board);                            \
	}                                                                                 \
	template <>                                                                       \
	inline unsigned                                                                   \
	different<P1|P2>(cql::Board const& pos, db::Board const& p1, db::Board const& p2) \
	{                                                                                 \
		return different<P1>(pos, p1, p2) + different<P2>(pos, p1, p2);                \
	}                                                                                 \
	template <>                                                                       \
	inline unsigned                                                                   \
	same<P1|P2>(cql::Board const& pos, db::Board const& p1, db::Board const& p2)      \
	{                                                                                 \
		return same<P1>(pos, p1, p2) + same<P2>(pos, p1, p2);                          \
	}

DEFUN(WK,WQ)
DEFUN(WK,WR)
DEFUN(WK,WB)
DEFUN(WK,WN)
DEFUN(WK,WP)
DEFUN(WK,WI)
DEFUN(WK,WM)
DEFUN(WQ,WB)
DEFUN(WQ,WN)
DEFUN(WQ,WP)
DEFUN(WQ,WI)
DEFUN(WR,WB)
DEFUN(WR,WN)
DEFUN(WR,WP)
DEFUN(WR,WI)
DEFUN(WB,WP)
DEFUN(WB,WM)
DEFUN(WN,WP)
DEFUN(WN,WM)
DEFUN(WP,WI)
DEFUN(WP,WM)

DEFUN(BK,BQ)
DEFUN(BK,BR)
DEFUN(BK,BB)
DEFUN(BK,BN)
DEFUN(BK,BP)
DEFUN(BK,BI)
DEFUN(BK,BM)
DEFUN(BQ,BB)
DEFUN(BQ,BN)
DEFUN(BQ,BP)
DEFUN(BQ,BI)
DEFUN(BR,BB)
DEFUN(BR,BN)
DEFUN(BR,BP)
DEFUN(BR,BI)
DEFUN(BB,BP)
DEFUN(BB,BM)
DEFUN(BN,BP)
DEFUN(BN,BM)
DEFUN(BP,BI)
DEFUN(BP,BM)

DEFUN(WK,BK)
DEFUN(WQ,BQ)
DEFUN(WR,BR)
DEFUN(WB,BB)
DEFUN(WN,BN)
DEFUN(WP,BP)
DEFUN(WI,BI)
DEFUN(WM,BM)

DEFUN(WK,WQ|WB)
DEFUN(WK,WQ|WN)
DEFUN(WK,WQ|WP)
DEFUN(WK,WQ|WI)
DEFUN(WK,WR|WB)
DEFUN(WK,WR|WN)
DEFUN(WK,WR|WP)
DEFUN(WK,WR|WI)
DEFUN(WK,WB|WP)
DEFUN(WK,WB|WM)
DEFUN(WK,WN|WP)
DEFUN(WK,WN|WM)
DEFUN(WK,WP|WI)
DEFUN(WK,WP|WM)
DEFUN(WQ,WB|WP)
DEFUN(WQ,WN|WP)
DEFUN(WR,WB|WP)
DEFUN(WR,WN|WP)
DEFUN(WR,WI|WP)
DEFUN(WB,WP|WM)
DEFUN(WN,WP|WM)

DEFUN(BK,BQ|BB)
DEFUN(BK,BQ|BN)
DEFUN(BK,BQ|BP)
DEFUN(BK,BQ|BI)
DEFUN(BK,BR|BB)
DEFUN(BK,BR|BN)
DEFUN(BK,BR|BP)
DEFUN(BK,BR|BI)
DEFUN(BK,BB|BP)
DEFUN(BK,BB|BM)
DEFUN(BK,BN|BP)
DEFUN(BK,BN|BM)
DEFUN(BK,BP|BI)
DEFUN(BK,BP|BM)
DEFUN(BQ,BB|BP)
DEFUN(BQ,BN|BP)
DEFUN(BR,BB|BP)
DEFUN(BR,BN|BP)
DEFUN(BR,BI|BP)
DEFUN(BB,BP|BM)
DEFUN(BN,BP|BM)

DEFUN(WK,WQ|WB|WP)
DEFUN(BK,BQ|BB|BP)


static void
getFuncs(cql::Board const& pos,
			Designator::MatchFunc& matchFunc,
			Designator::CountFunc& countFunc,
			Designator::FindFunc& findFunc,
			Designator::DiffFunc& diffFunc,
			Designator::DiffFunc& sameFunc)
{
#define RETURN(args) {          \
	matchFunc = &match<args>;    \
	countFunc = &count<args>;    \
	findFunc = &find<args>;      \
	diffFunc = &different<args>; \
	sameFunc = &same<args>;      \
	return; }

	unsigned wk = unsigned(bool(pos.pieces[White].kings));
	unsigned wq = unsigned(bool(pos.pieces[White].queens));
	unsigned wr = unsigned(bool(pos.pieces[White].rooks));
	unsigned wb = unsigned(bool(pos.pieces[White].bishops));
	unsigned wn = unsigned(bool(pos.pieces[White].knights));
	unsigned wp = unsigned(bool(pos.pieces[White].pawns));

	unsigned bk = unsigned(bool(pos.pieces[Black].kings));
	unsigned bq = unsigned(bool(pos.pieces[Black].queens));
	unsigned br = unsigned(bool(pos.pieces[Black].rooks));
	unsigned bb = unsigned(bool(pos.pieces[Black].bishops));
	unsigned bn = unsigned(bool(pos.pieces[Black].knights));
	unsigned bp = unsigned(bool(pos.pieces[Black].pawns));

	if (pos.empty && (wk|wq|wr|wb|wn|wp|bk|bq|br|bb|bn|bp) == 0)
		RETURN(E);

	bool wi = wb && wn;
	bool bi = bb && bn;

	bool wm = wq && wr;
	bool bm = bq && br;

	bool wa = wk && wm && wi && wp;
	bool ba = bk && bm && bi && bp;

	if ((wa+ba) == 2) RETURN(U);

	if ((wk+bk) == 2 && (wq|wr|wb|wn|wp|bq|br|bb|bn|bp) == 0) RETURN(WK|BK);
	if ((wq+bq) == 2 && (wk|wr|wb|wn|wp|bk|br|bb|bn|bp) == 0) RETURN(WQ|BQ);
	if ((wr+br) == 2 && (wk|wq|wb|wn|wp|bk|bq|bb|bn|bp) == 0) RETURN(WR|BR);
	if ((wb+bb) == 2 && (wk|wq|wr|wn|wp|bk|bq|br|bn|bp) == 0) RETURN(WB|BB);
	if ((wn+bn) == 2 && (wk|wq|wr|wb|wp|bk|bq|br|bb|bp) == 0) RETURN(WN|BN);
	if ((wp+bp) == 2 && (wk|wq|wr|wb|wn|bk|bq|br|bb|bn) == 0) RETURN(WP|BP);
	if ((wi+bi) == 2 && (wk|wq|wr|wp   |bk|wq|wr|bp   ) == 0) RETURN(WI|BI);
	if ((wm+bm) == 2 && (wk|wb|wn|wp   |bk|bb|bn|bp   ) == 0) RETURN(WM|BM);

	if (wa & !ba)
	{
		if (wa) RETURN(WA);

		if (wk && (wq|wr|wb|wn|wp) == 0) RETURN(WK);
		if (wq && (wk|wr|wb|wn|wp) == 0) RETURN(WQ);
		if (wr && (wk|wq|wb|wn|wp) == 0) RETURN(WR);
		if (wb && (wk|wq|wr|wn|wp) == 0) RETURN(WB);
		if (wn && (wk|wq|wr|wb|wp) == 0) RETURN(WN);
		if (wp && (wk|wq|wr|wb|wn) == 0) RETURN(WP);
		if (wi && (wk|wq|wr|wp   ) == 0) RETURN(WI);
		if (wm && (wk|wb|wn|wp   ) == 0) RETURN(WM);

		if ((wk+wq) == 2 && (wr|wb|wn|wp) == 0) RETURN(WK|WQ);
		if ((wk+wr) == 2 && (wq|wb|wn|wp) == 0) RETURN(WK|WR);
		if ((wk+wb) == 2 && (wq|wr|wn|wp) == 0) RETURN(WK|WB);
		if ((wk+wn) == 2 && (wq|wr|wb|wp) == 0) RETURN(WK|WN);
		if ((wk+wp) == 2 && (wq|wr|wb|wn) == 0) RETURN(WK|WP);
		if ((wk+wi) == 2 && (wq|wr|wp   ) == 0) RETURN(WK|WI);
		if ((wk+wm) == 2 && (wb|wn|wp   ) == 0) RETURN(WK|WM);
		if ((wq+wb) == 2 && (wk|wr|wn|wp) == 0) RETURN(WQ|WB);
		if ((wq+wn) == 2 && (wk|wr|wb|wp) == 0) RETURN(WQ|WN);
		if ((wq+wp) == 2 && (wk|wr|wb|wn) == 0) RETURN(WQ|WP);
		if ((wq+wi) == 2 && (wk|wr|wp   ) == 0) RETURN(WQ|WI);
		if ((wr+wb) == 2 && (wk|wq|wn|wp) == 0) RETURN(WR|WB);
		if ((wr+wn) == 2 && (wk|wq|wb|wp) == 0) RETURN(WR|WN);
		if ((wr+wp) == 2 && (wk|wq|wb|wn) == 0) RETURN(WR|WP);
		if ((wr+wi) == 2 && (wk|wq|wp   ) == 0) RETURN(WR|WI);
		if ((wb+wp) == 2 && (wk|wq|wr|wn) == 0) RETURN(WB|WP);
		if ((wb+wm) == 2 && (wk|wb|wn|wp) == 0) RETURN(WB|WM);
		if ((wn+wp) == 2 && (wk|wq|wr|wb) == 0) RETURN(WN|WP);
		if ((wn+wm) == 2 && (wk|wb|wp   ) == 0) RETURN(WN|WM);
		if ((wp+wi) == 2 && (wk|wq|wr   ) == 0) RETURN(WP|WI);
		if ((wp+wm) == 2 && (wk|wb|wn   ) == 0) RETURN(WP|WM);

		if ((wk+wq+wb) == 3 && (wr|wn|wp) == 0) RETURN(WK|WQ|WB);
		if ((wk+wq+wn) == 3 && (wr|wb|wp) == 0) RETURN(WK|WQ|WN);
		if ((wk+wq+wp) == 3 && (wr|wb|wn) == 0) RETURN(WK|WQ|WP);
		if ((wk+wq+wi) == 3 && (wr|wp   ) == 0) RETURN(WK|WQ|WI);
		if ((wk+wr+wb) == 3 && (wq|wn|wp) == 0) RETURN(WK|WR|WB);
		if ((wk+wr+wn) == 3 && (wq|wb|wp) == 0) RETURN(WK|WR|WN);
		if ((wk+wr+wp) == 3 && (wq|wb|wn) == 0) RETURN(WK|WR|WP);
		if ((wk+wr+wi) == 3 && (wq|wp   ) == 0) RETURN(WK|WR|WI);
		if ((wk+wb+wp) == 3 && (wq|wr|wn) == 0) RETURN(WK|WB|WP);
		if ((wk+wb+wm) == 3 && (wn|wp   ) == 0) RETURN(WK|WB|WM);
		if ((wk+wn+wp) == 3 && (wq|wr|wb) == 0) RETURN(WK|WN|WP);
		if ((wk+wn+wm) == 3 && (wb|wp   ) == 0) RETURN(WK|WN|WM);
		if ((wk+wp+wi) == 3 && (wq|wr|wn) == 0) RETURN(WK|WP|WI);
		if ((wk+wp+wm) == 3 && (wq|wr|wb) == 0) RETURN(WK|WP|WM);
		if ((wq+wb+wp) == 3 && (wk|wr|wn) == 0) RETURN(WQ|WB|WP);
		if ((wq+wn+wp) == 3 && (wk|wr|wb) == 0) RETURN(WQ|WN|WP);
		if ((wr+wb+wp) == 3 && (wk|wq|wn) == 0) RETURN(WR|WB|WP);
		if ((wr+wn+wp) == 3 && (wk|wq|wb) == 0) RETURN(WR|WN|WP);
		if ((wr+wi+wp) == 3 && (wk|wq   ) == 0) RETURN(WR|WI|WP);
		if ((wb+wp+wm) == 3 && (wk|wn   ) == 0) RETURN(WB|WP|WM);
		if ((wn+wp+wm) == 3 && (wk|wb   ) == 0) RETURN(WN|WP|WM);

		if ((wk+wq+wb+wp) == 4 && (wr == 0)) RETURN(WK|WQ|WB|WP);
	}

	if (ba && !wa)
	{
		if (ba) RETURN(BA);

		if (bk && (bq|br|bb|bn|bp) == 0) RETURN(BK);
		if (bq && (bk|br|bb|bn|bp) == 0) RETURN(BQ);
		if (br && (bk|bq|bb|bn|bp) == 0) RETURN(BR);
		if (bb && (bk|bq|br|bn|bp) == 0) RETURN(BB);
		if (bn && (bk|bq|br|bb|bp) == 0) RETURN(BN);
		if (bp && (bk|bq|br|bb|bn) == 0) RETURN(BP);
		if (bi && (bk|bq|br|bp   ) == 0) RETURN(BI);
		if (bm && (bk|bb|bn|bp   ) == 0) RETURN(BM);

		if ((bk+bq) == 2 && (br|bb|bn|bp) == 0) RETURN(BK|BQ);
		if ((bk+br) == 2 && (bq|bb|bn|bp) == 0) RETURN(BK|BR);
		if ((bk+bb) == 2 && (bq|br|bn|bp) == 0) RETURN(BK|BB);
		if ((bk+bn) == 2 && (bq|br|bb|bp) == 0) RETURN(BK|BN);
		if ((bk+bp) == 2 && (bq|br|bb|bn) == 0) RETURN(BK|BP);
		if ((bk+bi) == 2 && (bq|br|bp   ) == 0) RETURN(BK|BI);
		if ((bk+bm) == 2 && (bb|bn|bp   ) == 0) RETURN(BK|BM);
		if ((bq+bb) == 2 && (bk|br|bn|bp) == 0) RETURN(BQ|BB);
		if ((bq+bn) == 2 && (bk|br|bb|bp) == 0) RETURN(BQ|BN);
		if ((bq+bp) == 2 && (bk|br|bb|bn) == 0) RETURN(BQ|BP);
		if ((bq+bi) == 2 && (bk|br|bp   ) == 0) RETURN(BQ|BI);
		if ((br+bb) == 2 && (bk|bq|bn|bp) == 0) RETURN(BR|BB);
		if ((br+bn) == 2 && (bk|bq|bb|bp) == 0) RETURN(BR|BN);
		if ((br+bp) == 2 && (bk|bq|bb|bn) == 0) RETURN(BR|BP);
		if ((br+bi) == 2 && (bk|bq|bp   ) == 0) RETURN(BR|BI);
		if ((bb+bp) == 2 && (bk|bq|br|bn) == 0) RETURN(BB|BP);
		if ((bb+bm) == 2 && (bk|bb|bn|bp) == 0) RETURN(BB|BM);
		if ((bn+bp) == 2 && (bk|bq|br|bb) == 0) RETURN(BN|BP);
		if ((bn+bm) == 2 && (bk|bb|bp   ) == 0) RETURN(BN|BM);
		if ((bp+bi) == 2 && (bk|bq|br   ) == 0) RETURN(BP|BI);
		if ((bp+bm) == 2 && (bk|bb|bn   ) == 0) RETURN(BP|BM);

		if ((bk+bq+bb) == 3 && (br|bn|bp) == 0) RETURN(BK|BQ|BB);
		if ((bk+bq+bn) == 3 && (br|bb|bp) == 0) RETURN(BK|BQ|BN);
		if ((bk+bq+bp) == 3 && (br|bb|bn) == 0) RETURN(BK|BQ|BP);
		if ((bk+bq+bi) == 3 && (br|bp   ) == 0) RETURN(BK|BQ|BI);
		if ((bk+br+bb) == 3 && (bq|bn|bp) == 0) RETURN(BK|BR|BB);
		if ((bk+br+bn) == 3 && (bq|bb|bp) == 0) RETURN(BK|BR|BN);
		if ((bk+br+bp) == 3 && (bq|bb|bn) == 0) RETURN(BK|BR|BP);
		if ((bk+br+bi) == 3 && (bq|bp   ) == 0) RETURN(BK|BR|BI);
		if ((bk+bb+bp) == 3 && (bq|br|bn) == 0) RETURN(BK|BB|BP);
		if ((bk+bb+bm) == 3 && (bn|bp   ) == 0) RETURN(BK|BB|BM);
		if ((bk+bn+bp) == 3 && (bq|br|bb) == 0) RETURN(BK|BN|BP);
		if ((bk+bn+bm) == 3 && (bb|bp   ) == 0) RETURN(BK|BN|BM);
		if ((bk+bp+bi) == 3 && (bq|br|bn) == 0) RETURN(BK|BP|BI);
		if ((bk+bp+bm) == 3 && (bq|br|bb) == 0) RETURN(BK|BP|BM);
		if ((bq+bb+bp) == 3 && (bk|br|bn) == 0) RETURN(BQ|BB|BP);
		if ((bq+bn+bp) == 3 && (bk|br|bb) == 0) RETURN(BQ|BN|BP);
		if ((br+bb+bp) == 3 && (bk|bq|bn) == 0) RETURN(BR|BB|BP);
		if ((br+bn+bp) == 3 && (bk|bq|bb) == 0) RETURN(BR|BN|BP);
		if ((br+bi+bp) == 3 && (bk|bq   ) == 0) RETURN(BR|BI|BP);
		if ((bb+bp+bm) == 3 && (bk|bn   ) == 0) RETURN(BB|BP|BM);
		if ((bn+bp+bm) == 3 && (bk|bb   ) == 0) RETURN(BN|BP|BM);

		if ((bk+bq+bb+bp) == 4 && (br == 0)) RETURN(BK|BQ|BB|BP);
	}

	matchFunc = &match;
	countFunc = &count;
	findFunc  = &find;
	diffFunc  = &different;
	sameFunc  = &same;

#undef RETURN
}

} // namespace


static bool
isDelim(char c)
{
	return isspace(c) || c == '\0' || c == '(' || c == ')' || c == ';';
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


Designator::Designator() :m_match(::match), m_count(::count), m_find(::find) {}


uint64_t
Designator::pieces(db::Board const& board, color::ID color) const
{
	cql::Board::Pieces const& pieces = m_board.pieces[color];

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
		designator.m_board.pieces[i].knights	= func(m_board.pieces[i].knights);
		designator.m_board.pieces[i].bishops	= func(m_board.pieces[i].bishops);
		designator.m_board.pieces[i].rooks		= func(m_board.pieces[i].rooks);
		designator.m_board.pieces[i].queens		= func(m_board.pieces[i].queens);
		designator.m_board.pieces[i].kings		= func(m_board.pieces[i].kings);
		designator.m_board.pieces[i].pawns		= func(m_board.pieces[i].pawns);
	}

	designator.m_board.empty = func(m_board.empty);
//	position.add(designator);
}


unsigned
Designator::powerWhite(db::Board const& board, variant::Type variant)
{
	material::Count count;

	count.pawn		= ::countAny(m_board.pieces[White].pawns,		board.pawns(White));
	count.knight	= ::countAny(m_board.pieces[White].knights,	board.knights(White));
	count.bishop	= ::countAny(m_board.pieces[White].bishops,	board.bishops(White));
	count.rook		= ::countAny(m_board.pieces[White].rooks,		board.rooks(White));
	count.queen		= ::countAny(m_board.pieces[White].queens,	board.queens(White));
	count.king		= ::countAny(m_board.pieces[White].kings,		board.kings(White));

	return power(count, variant);
}


unsigned
Designator::powerBlack(db::Board const& board, variant::Type variant)
{
	material::Count count;

	count.pawn		= ::countAny(m_board.pieces[Black].pawns,		board.pawns(Black));
	count.knight	= ::countAny(m_board.pieces[Black].knights,	board.knights(Black));
	count.bishop	= ::countAny(m_board.pieces[Black].bishops,	board.bishops(Black));
	count.rook		= ::countAny(m_board.pieces[Black].rooks,		board.rooks(Black));
	count.queen		= ::countAny(m_board.pieces[Black].queens,	board.queens(Black));
	count.king		= ::countAny(m_board.pieces[Black].kings,		board.kings(Black));

	return power(count, variant);
}


void
Designator::shift(Position& position, Shift func) const
{
	for (int step = -7; step <= 7; ++step)
	{
		if (step)
		{
			Designator designator(*this);

			if (func(designator.m_board.empty, step))
			{
				for (unsigned i = 0; i < 2; ++i)
				{
					if (	func(designator.m_board.pieces[i].knights, step)
						&& func(designator.m_board.pieces[i].bishops, step)
						&& func(designator.m_board.pieces[i].rooks, step)
						&& func(designator.m_board.pieces[i].queens, step)
						&& func(designator.m_board.pieces[i].kings, step)
						&& func(designator.m_board.pieces[i].pawns, step))
					{
//						position.add(designator);
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
//	flipdiagonal(position);
//	position.last().fliphorizontal(position);
//	position.last().flipoffdiagonal(position);
//	position.last().flipvertical(position);
//	position.last().flipdiagonal(position);
//	position.last().fliphorizontal(position);
//	position.last().flipoffdiagonal(position);
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

					cql::Board::Pieces& white = d.m_board.pieces[White];
					cql::Board::Pieces& black = d.m_board.pieces[Black];

					if (	::shift(white.pawns,			stepFyle, stepRank)
						&& ::shift(black.pawns,			stepFyle, stepRank)
						&& ::shift(white.knights,		stepFyle, stepRank)
						&& ::shift(black.knights,		stepFyle, stepRank)
						&& ::shift(white.bishops,		stepFyle, stepRank)
						&& ::shift(black.bishops,		stepFyle, stepRank)
						&& ::shift(white.rooks,			stepFyle, stepRank)
						&& ::shift(black.rooks,			stepFyle, stepRank)
						&& ::shift(white.queens,		stepFyle, stepRank)
						&& ::shift(black.queens,		stepFyle, stepRank)
						&& ::shift(white.kings,			stepFyle, stepRank)
						&& ::shift(black.kings,			stepFyle, stepRank)
						&& ::shift(d.m_board.empty,	stepFyle, stepRank))
					{
//						position.add(d);
					}
				}
			}
		}
	}
}


void
Designator::flipcolor(Designator& dest) const
{
	dest = *this;

	mstl::swap(dest.m_board.pieces[White].kings,		dest.m_board.pieces[Black].kings);
	mstl::swap(dest.m_board.pieces[White].queens,	dest.m_board.pieces[Black].queens);
	mstl::swap(dest.m_board.pieces[White].rooks,		dest.m_board.pieces[Black].rooks);
	mstl::swap(dest.m_board.pieces[White].bishops,	dest.m_board.pieces[Black].bishops);
	mstl::swap(dest.m_board.pieces[White].knights,	dest.m_board.pieces[Black].knights);
	mstl::swap(dest.m_board.pieces[White].pawns,		dest.m_board.pieces[Black].pawns);

//	dest.fliphorizontal(position); XXX
}


void
Designator::flipcolor()
{
	m_board.pieces[White].kings	|= m_board.pieces[Black].kings;
	m_board.pieces[Black].kings	|= m_board.pieces[White].kings;

	m_board.pieces[White].queens	|= m_board.pieces[Black].queens;
	m_board.pieces[Black].queens	|= m_board.pieces[White].queens;

	m_board.pieces[White].bishops	|= m_board.pieces[Black].bishops;
	m_board.pieces[Black].bishops	|= m_board.pieces[White].bishops;

	m_board.pieces[White].knights	|= m_board.pieces[Black].knights;
	m_board.pieces[Black].knights	|= m_board.pieces[White].knights;

	m_board.pieces[White].pawns	|= m_board.pieces[Black].pawns;
	m_board.pieces[Black].pawns	|= m_board.pieces[White].pawns;
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
				squares = 0;
		}

		s = t + 1;
	}
	else if (*t == '?' || 'a' <= *t && *t <= 'h')
	{
		s = parseRange(t, error, squares);

		if (error != No_Error)
			return s;
	}
	else if (::isDelim(*t))
	{
		squares = ~uint64_t(0);
	}
	else
	{
		error = Invalid_Square_Designator;
		return t;
	}

	material::Count count[2];
	count[White].value = count[Black].value = 0;

	for ( ; p < q; ++p)
	{
		switch (*p)
		{
			case 'K': m_board.pieces[White].kings		|= squares; break;
			case 'Q': m_board.pieces[White].queens		|= squares; break;
			case 'R': m_board.pieces[White].rooks		|= squares; break;
			case 'B': m_board.pieces[White].bishops	|= squares; break;
			case 'N': m_board.pieces[White].knights	|= squares; break;
			case 'P': m_board.pieces[White].pawns		|= squares; break;
			case 'k': m_board.pieces[Black].kings		|= squares; break;
			case 'q': m_board.pieces[Black].queens		|= squares; break;
			case 'r': m_board.pieces[Black].rooks		|= squares; break;
			case 'b': m_board.pieces[Black].bishops	|= squares; break;
			case 'n': m_board.pieces[Black].knights	|= squares; break;
			case 'p': m_board.pieces[Black].pawns		|= squares; break;
			case '.': m_board.empty							|= squares; break;

			case 'A':
				m_board.pieces[White].kings	|= squares;
				m_board.pieces[White].queens	|= squares;
				m_board.pieces[White].rooks	|= squares;
				m_board.pieces[White].bishops	|= squares;
				m_board.pieces[White].knights	|= squares;
				m_board.pieces[White].pawns	|= squares;
				break;

			case 'a':
				m_board.pieces[Black].kings	|= squares;
				m_board.pieces[Black].queens	|= squares;
				m_board.pieces[Black].rooks	|= squares;
				m_board.pieces[Black].bishops |= squares;
				m_board.pieces[Black].knights	|= squares;
				m_board.pieces[Black].pawns	|= squares;
				break;

			case 'M':
				m_board.pieces[White].queens	|= squares;
				m_board.pieces[White].rooks	|= squares;
				break;

			case 'm':
				m_board.pieces[Black].queens	|= squares;
				m_board.pieces[Black].rooks	|= squares;
				break;

			case 'I':
				m_board.pieces[White].bishops |= squares;
				m_board.pieces[White].knights |= squares;
				break;

			case 'i':
				m_board.pieces[Black].bishops |= squares;
				m_board.pieces[Black].knights |= squares;
				break;

			case 'U':
			case '?':
				for (unsigned i = 0; i < 2; ++i)
				{
					m_board.pieces[i].kings		|= squares;
					m_board.pieces[i].queens	|= squares;
					m_board.pieces[i].rooks		|= squares;
					m_board.pieces[i].bishops	|= squares;
					m_board.pieces[i].knights	|= squares;
					m_board.pieces[i].pawns		|= squares;
				}
				break;
		}
	}

	return s;
}


void
Designator::finish()
{
	::getFuncs(m_board, m_match, m_count, m_find, m_diff, m_same);
	m_board.complete();
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
	Byte fyle1 = FyleA;
	Byte fyle2 = FyleH;

	if (s[0] != '?' && (s[0] < 'a' || 'h' < s[0]))
	{
		error = Invalid_Fyle_In_Square_Designator;
		return s;
	}

	if (s[0] != '?')
		fyle1 = fyle2 = FyleA + s[0] - 'a';

	s += 1;

	if (s[0] == '-')
	{
		if (s[-1] == '?')
		{
			error = Any_Fyle_Not_Allowed_In_Range;
			return s - 1;
		}

		if (s[1] == '?')
		{
			error = Any_Fyle_Not_Allowed_In_Range;
			return s + 1;
		}

		if (s[1] < 'a' || 'h' < s[1])
		{
			error = Invalid_Fyle_In_Square_Designator;
			return s + 1;
		}

		fyle2 = FyleA + s[1] - 'a';

		if (fyle1 > fyle2)
			mstl::swap(fyle1, fyle2);

		s += 2;
	}

	if (s[0] != '?' && (s[0] < '1' || '8' < s[0]))
	{
		error = Missing_Rank_In_Square_Designator;
		return s;
	}

	Byte rank1 = Rank1;
	Byte rank2 = Rank8;

	if (s[0] != '?')
		rank1 = rank2 = Rank1 + s[0] - '1';

	s += 1;

	if (s[0] == '-')
	{
		if (s[-1] == '?')
		{
			error = Any_Rank_Not_Allowed_In_Range;
			return s - 1;
		}

		if (s[1] == '?')
		{
			error = Any_Rank_Not_Allowed_In_Range;
			return s + 1;
		}

		if (s[1] < '1' || '8' < s[1])
		{
			error = Invalid_Rank_In_Square_Designator;
			return s + 1;
		}

		rank2 = Rank1 + s[1] - '1';

		if (rank1 > rank2)
			mstl::swap(rank1, rank2);

		s += 2;
	}

	for (Byte f = fyle1; f <= fyle2; ++f)
	{
		for (Byte r = rank1; r <= rank2; ++r)
			squares |= setBit(make(Fyle(f), Rank(r)));
	}

	return s;
}


unsigned
Designator::power(material::Count m, variant::Type variant)
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

// vi:set ts=3 sw=3:
