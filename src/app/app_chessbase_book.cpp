// ======================================================================
// Author : $Author$
// Version: $Revision: 957 $
// Date   : $Date: 2013-09-30 17:11:24 +0200 (Mon, 30 Sep 2013) $
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

// ======================================================================
// This source is based on daydreamer's implementation:
// <https://raw.github.com/AaronBecker/daydreamer/release/book_ctg.c>
// ======================================================================

#include "app_chessbase_book.h"

#include "db_board.h"
#include "db_move_list.h"
#include "db_exception.h"

#include "u_byte_stream.h"
#include "u_misc.h"

#include "sys_file.h"

#include "m_ifstream.h"
#include "m_utility.h"
#include "m_assert.h"

using namespace db;
using namespace db::sq;
using namespace db::piece;
using namespace db::color;
using namespace db::castling;
using namespace app::chessbase;
using namespace util;


// Description of CTG format:
// <http://rybkaforum.net/cgi-bin/rybkaforum/topic_show.pl?pid=26942>


namespace {

template <bool FlipColor, bool FlipBoard> struct LookupSquare {};

template <> // FlipColor,FlipBoard
struct LookupSquare<false,false>
{
	static bool find(Board const& pos, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (unsigned f = 0; f < 8; ++f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (piece == pos.pieceAt(make(Fyle(f), Rank(r))))
				{
					if (++count == nth)
					{
						fyle = Fyle(f);
						rank = Rank(r);
						return true;
					}
				}
			}
		}

		return false;
	}
};


template <> // FlipColor,FlipBoard
struct LookupSquare<true,false>
{
	static bool find(Board const& pos, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (unsigned f = 0; f < 8; ++f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (piece == piece::swap(pos.pieceAt(make(Fyle(f), Rank(r)))))
				{
					if (++count == nth)
					{
						fyle = Fyle(f);
						rank = Rank(r);
						return true;
					}
				}
			}
		}

		return false;
	}
};


template <> // FlipColor,FlipBoard
struct LookupSquare<false,true>
{
	static bool find(Board const& pos, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (int f = 7; f >= 0; --f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (piece == pos.pieceAt(make(f, r)))
				{
					if (++count == nth)
					{
						fyle = Fyle(f);
						rank = Rank(r);
						return true;
					}
				}
			}
		}

		return false;
	}
};


template <> // FlipColor,FlipBoard
struct LookupSquare<true,true>
{
	static bool find(Board const& pos, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (int f = 7; f >= 0; --f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (piece == piece::swap(pos.pieceAt(make(Fyle(f), Rank(r)))))
				{
					if (++count == nth)
					{
						fyle = Fyle(f);
						rank = Rank(r);
						return true;
					}
				}
			}
		}

		return false;
	}
};

} // namespace


struct CTGSignature
{
	uint8_t	buf[64];
	unsigned	size;
};


// Convert a position's huffman code to a 4 byte hash.
static
uint32_t
signatureToHash(CTGSignature const& sig)
{
	static uint32_t const HashBits[64] =
	{
		0x3100d2bf, 0x3118e3de, 0x34ab1372, 0x2807a847, 0x1633f566, 0x2143b359, 0x26d56488, 0x3b9e6f59,
		0x37755656, 0x3089ca7b, 0x18e92d85, 0x0cd0e9d8, 0x1a9e3b54, 0x3eaa902f, 0x0d9bfaae, 0x2f32b45b,
		0x31ed6102, 0x3d3c8398, 0x146660e3, 0x0f8d4b76, 0x02c77a5f, 0x146c8799, 0x1c47f51f, 0x249f8f36,
		0x24772043, 0x1fbc1e4d, 0x1e86b3fa, 0x37df36a6, 0x16ed30e4, 0x02c3148e, 0x216e5929, 0x0636b34e,
		0x317f9f56, 0x15f09d70, 0x131026fb, 0x38c784b1, 0x29ac3305, 0x2b485dc5, 0x3c049ddc, 0x35a9fbcd,
		0x31d5373b, 0x2b246799, 0x0a2923d3, 0x08a96e9d, 0x30031a9f, 0x08f525b5, 0x33611c06, 0x2409db98,
		0x0ca4feb2, 0x1000b71e, 0x30566e32, 0x39447d31, 0x194e3752, 0x08233a95, 0x0f38fe36, 0x29c7cd57,
		0x0f7b3a39, 0x328e8a16, 0x1e7d1388, 0x0fba78f5, 0x274c7e7c, 0x1e8be65c, 0x2fa0b0bb, 0x1eb6c371,
	};

	uint32_t hash = 0;
	uint16_t temp = 0;

	for (unsigned i = 0; i < sig.size; ++i)
	{
		uint8_t byte = sig.buf[i];

		temp += ((0x0f - (byte & 0x0f)) << 2) + 1;
		hash += HashBits[temp & 0x3f];
		temp += ((0xf0 - (byte & 0xf0)) >> 2) + 1;
		hash += HashBits[temp & 0x3f];
	}

	return hash;
}


// Convert a ctg-format move to native format. The ctg move format seems
// really bizarre; maybe there's some simpler formulation. The ctg move
// indicates the piece type, the index of the piece to be moved (counting
// from A1 to H8 by ranks), and the delta x and delta y of the move.
// We just look these values up in big tables.
static Move
byteToMove(Board& pos, uint8_t byte)
{
	static char const* PieceCode =
		"PNxQPQPxQBKxPBRNxxBKPBxxPxQBxBxxxRBQPxBPQQNxxPBQNQBxNxNQQQBQBxxx"
		"xQQxKQxxxxPQNQxxRxRxBPxxxxxxPxxPxQPQxxBKxRBxxxRQxxBxQxxxxBRRPRQR"
		"QRPxxNRRxxNPKxQQxxQxQxPKRRQPxQxBQxQPxRxxxRxQxRQxQPBxxRxQxBxPQQKx"
		"xBBBRRQPPQBPBRxPxPNNxxxQRQNPxxPKNRxRxQPQRNxPPQQRQQxNRBxNQQQQxQQx";

	static unsigned char const PieceIndex[256] =
	{
		5, 2, 9, 2, 2, 1, 4, 9, 2, 2, 1, 9, 1, 1, 2, 1,
		9, 9, 1, 1, 8, 1, 9, 9, 7, 9, 2, 1, 9, 2, 9, 9,
		9, 2, 2, 2, 8, 9, 1, 3, 1, 1, 2, 9, 9, 6, 1, 1,
		2, 1, 2, 9, 1, 9, 1, 1, 2, 1, 1, 2, 1, 9, 9, 9,
		9, 2, 1, 9, 1, 1, 9, 9, 9, 9, 8, 1, 2, 2, 9, 9,
		1, 9, 1, 9, 2, 3, 9, 9, 9, 9, 9, 9, 7, 9, 9, 5,
		9, 1, 2, 2, 9, 9, 1, 1, 9, 2, 1, 0, 9, 9, 1, 2,
		9, 9, 2, 9, 1, 9, 9, 9, 9, 2, 1, 2, 3, 2, 1, 1,
		1, 1, 6, 9, 9, 1, 1, 1, 9, 9, 1, 1, 1, 9, 2, 1,
		9, 9, 2, 9, 1, 9, 2, 1, 1, 1, 1, 3, 9, 1, 9, 2,
		2, 9, 1, 8, 9, 2, 9, 9, 9, 2, 9, 2, 9, 2, 2, 9,
		2, 6, 1, 9, 9, 2, 9, 1, 9, 2, 9, 5, 2, 2, 1, 9,
		9, 1, 2, 1, 2, 2, 2, 7, 7, 2, 2, 6, 2, 1, 9, 4,
		9, 2, 2, 2, 9, 9, 9, 1, 2, 1, 1, 1, 9, 9, 5, 1,
		2, 1, 9, 2, 9, 1, 4, 1, 1, 1, 9, 4, 1, 1, 2, 1,
		2, 1, 9, 2, 2, 2, 0, 1, 2, 2, 2, 2, 9, 1, 2, 9,
	};

	static char const Forward[256] =
	{
		 1, -1,  9,  0,  1,  1,  1,  9,  0,  6, -1,  9,  1,  3,  0, -1,
		 9,  9,  7,  1,  1,  5,  9,  9,  1,  9,  6,  1,  9,  7,  9,  9,
		 9,  0,  2,  6,  1,  9,  7,  1,  5,  0, -2,  9,  9,  1,  1,  0,
		-2,  0,  5,  9,  2,  9,  1,  4,  4,  0,  6,  5,  5,  9,  9,  9,
		 9,  5,  7,  9, -1,  3,  9,  9,  9,  9,  2,  5,  2,  1,  9,  9,
		 6,  9,  0,  9,  1,  1,  9,  9,  9,  9,  9,  9,  1,  9,  9,  2,
		 9,  6,  2,  7,  9,  9,  3,  1,  9,  7,  4,  0,  9,  9,  0,  7,
		 9,  9,  7,  9,  0,  9,  9,  9,  9,  6,  3,  6,  1,  1,  3,  0,
		 6,  1,  1,  9,  9,  2,  0,  5,  9,  9, -2,  1, -1,  9,  2,  0,
		 9,  9,  1,  9,  3,  9,  1,  0,  0,  4,  6,  2,  9,  2,  9,  4,
		 3,  9,  2,  1,  9,  5,  9,  9,  9,  0,  9,  6,  9,  0,  3,  9,
		 4,  2,  6,  9,  9,  0,  9,  5,  9,  3,  9,  1,  0,  2,  0,  9,
		 9,  2,  2,  2,  0,  4,  5,  1,  2,  7,  3,  1,  5,  0,  9,  1,
		 9,  1,  1,  1,  9,  9,  9,  1,  0,  2, -2,  2,  9,  9,  1,  1,
		-1,  7,  9,  3,  9,  0,  2,  4,  2, -1,  9,  1,  1,  7,  1,  0,
		 0,  1,  9,  2,  2,  1,  0,  1,  0,  6,  0,  2,  9,  7,  3,  9,
	};

	static char const Left[256] =
	{
		-1,  2,  9, -2,  0,  0,  1,  9, -4, -6,  0,  9,  1, -3, -3,  2,
		 9,  9, -7,  0, -1, -5,  9,  9,  0,  9,  0,  1,  9, -7,  9,  9,
		 9, -7,  2, -6,  1,  9,  7,  1, -5, -6, -1,  9,  9, -1, -1, -1,
		 1, -3, -5,  9, -1,  9, -2,  0,  4, -5, -6,  5,  5,  9,  9,  9,
		 9, -5,  7,  9, -1, -3,  9,  9,  9,  9,  0,  5, -1,  0,  9,  9,
		 0,  9, -6,  9,  1,  0,  9,  9,  9,  9,  9,  9, -1,  9,  9,  0,
		 9, -6,  0,  7,  9,  9,  3, -1,  9,  0, -4,  0,  9,  9, -5, -7,
		 9,  9,  7,  9, -2,  9,  9,  9,  9,  6,  0,  0, -1,  0,  3, -1,
		 6,  0,  1,  9,  9,  1, -7,  0,  9,  9, -1, -1,  1,  9,  2, -7,
		 9,  9, -1,  9,  0,  9, -1,  1, -3,  0,  0,  0,  9,  0,  9,  4,
		 0,  9, -2,  0,  9,  0,  9,  9,  9, -2,  9,  6,  9, -4, -3,  9,
		 0,  0,  6,  9,  9, -5,  9,  0,  9, -3,  9,  0, -5,  0, -1,  9,
		 9, -2, -2,  2, -1,  0,  0,  1,  0,  0,  3,  0,  5, -2,  9,  0,
		 9,  1, -2,  2,  9,  9,  9,  1, -6,  2,  1,  0,  9,  9,  1,  1,
		-2,  0,  9,  0,  9, -4,  0, -4,  0, -2,  9, -1,  0, -7,  1, -4,
		-7, -1,  9,  1,  0, -1,  0,  2, -1,  0, -3, -2,  9,  0,  3,  9,
	};

	bool flipColor = pos.blackToMove();

	switch (byte)
	{
		case 107:
		{
			Rank rank = flipColor ? Rank8 : Rank1;
			Move move = pos.makeMove(make(FyleE, rank), make(FyleG, rank));

			return move.isCastling() ? move : Move::null();
		}

		case 246:
		{
			Rank rank = flipColor ? Rank8 : Rank1;
			Move move = pos.makeMove(make(FyleE, rank), make(FyleC, rank));

			return move.isCastling() ? move : Move::null();
		}
	}

	piece::ID piece = piece::Empty;

	switch (PieceCode[byte])
	{
		case 'P':	piece = WP; break;
		case 'N':	piece = WN; break;
		case 'B':	piece = WB; break;
		case 'R':	piece = WR; break;
		case 'Q':	piece = WQ; break;
		case 'K':	piece = WK; break;
		default:		return Move();
	}

	bool flipBoard = fyle(pos.kingSquare(White)) <= FyleD && pos.currentCastlingRights() == NoRights;

	unsigned	nth = PieceIndex[byte];
	Fyle		fyle;
	Rank		rank;

	M_ASSERT(nth > 0);

	switch (unsigned(flipColor) | mstl::mul2(unsigned(flipBoard)))
	{
		case 0: if (!LookupSquare<false,false>::find(pos, piece, nth, fyle, rank)) return Move(); break;
		case 1: if (!LookupSquare<true, false>::find(pos, piece, nth, fyle, rank)) return Move(); break;
		case 2: if (!LookupSquare<false,true >::find(pos, piece, nth, fyle, rank)) return Move(); break;
		case 3: if (!LookupSquare<true, true >::find(pos, piece, nth, fyle, rank)) return Move(); break;
	}

	Fyle toFyle = Fyle(mstl::mod8(unsigned((int(fyle) - Left[byte]) + 16)));
	Rank toRank = Rank(mstl::mod8(unsigned((int(rank) + Forward[byte]) + 16)));

	if (flipColor)
	{
		rank   = flipRank(rank);
		toRank = flipRank(toRank);
	}

	if (flipBoard)
	{
		fyle   = flipFyle(fyle);
		toFyle = flipFyle(toFyle);
	}

	return pos.makeMove(make(fyle, rank), make(toFyle, toRank));
}


// Given source and destination squares for a move, produce the corresponding
// native format move.
static Move
squaresToMove(Board const& pos, sq::ID from, sq::ID to)
{
	MoveList moveList;
	pos.generateMoves(variant::Normal, moveList);
	pos.filterLegalMoves(moveList, variant::Normal);

	for (unsigned i = 0; i < moveList.size(); ++i)
	{
		Move move = moveList[i];

		if (	from == move.from()
			&& to == move.to()
			&& (	move.promoted() == None
				|| move.promoted() == Queen))
		{
			return move;
		}
	}

	return Move();
}


#if 0
// Assign a weight to the given move, which indicates its relative
// probability of being selected.
static int64_t
moveWeight(Board const& pos, Move move, uint8_t annotation, bool& recommended)
{
	undo_info_t undo;
	do_move(pos, move, &undo);
	ctg_entry_t entry;
	bool success = ctg_get_entry(pos, &entry);

	pos.undoMove(move, variant::Normal);

	if (!success) return 0;

	*recommended = false;
	int64_t half_points = 2*entry.wins + entry.draws;
	int64_t games = entry.wins + entry.draws + entry.losses;
	int64_t weight = (games < 1) ? 0 : (half_points * 10000) / games;
	if (entry.recommendation == 64) weight = 0;
	if (entry.recommendation == 128) *recommended = true;

	// Adjust weights based on move annotations. Note that moves can be both
	// marked as recommended and annotated with a '?'. Since moves like this
	// are not marked green in GUI tools, the recommendation is turned off in
	// order to give results consistent with expectations.
	switch (annotation) {
	case 0x01: weight *=  8; break;                         //  !
	case 0x02: weight  =  0; *recommended = false; break;   //  ?
	case 0x03: weight *= 32; break;                         // !!
	case 0x04: weight  =  0; *recommended = false; break;   // ??
	case 0x05: weight /=  2; *recommended = false; break;   // !?
	case 0x06: weight /=  8; *recommended = false; break;   // ?!
	case 0x08: weight = INT32_MAX; break;                   // Only move
	case 0x16: break;                                       // Zugzwang
	default: break;
	}
	printf("info string book move ");
	print_coord_move(move);
	printf("weight %6"PRIu64"\n", weight);
	//printf("weight %6"PRIu64" wins %6d draws %6d losses %6d rec %3d "
	//        "note %2d avg_games %6d avg_score %9d "
	//        "perf_games %6d perf_score %9d\n",
	//        weight, entry.wins, entry.draws, entry.losses, entry.recommendation,
	//        annotation, entry.avg_rating_games, entry.avg_rating_score,
	//        entry.perf_rating_games, entry.perf_rating_score);
	return weight;
}
#endif


Book::Book(mstl::string const& ctgFilename)
	:m_ctgMapping(0)
	,m_ctoMapping(0)
{
	mstl::string ctoFilename(misc::file::rootname(ctgFilename) + ".cto");
	mstl::string ctbFilename(misc::file::rootname(ctgFilename) + ".ctb");

	if (!sys::file::access(ctoFilename, sys::file::Readable))
		IO_RAISE(BookFile, Open_Failed, "cannot open file: %s", ctoFilename.c_str());
	if (!sys::file::access(ctbFilename, sys::file::Readable))
		IO_RAISE(BookFile, Open_Failed, "cannot open file: %s", ctbFilename.c_str());

	mstl::ifstream ctbStrm(ctbFilename, mstl::ios_base::in | mstl::ios_base::binary);

	if (!ctbStrm)
		IO_RAISE(BookFile, Open_Failed, "cannot open file: %s", ctbFilename.c_str());
	
	Byte buf[12];

	if (!ctbStrm.read(buf, sizeof(buf)))
		IO_RAISE(BookFile, Read_Error, "unexpected end of file in '%s'", ctbFilename.c_str());
	
	ctbStrm.close();

	ByteStream bstrm(buf + 4, 8);

	bstrm >> m_pageBounds.lower;
	bstrm >> m_pageBounds.upper;

	m_ctgMapping = new Mapping(ctgFilename, sys::file::Readable);
	m_ctoMapping = new Mapping(ctoFilename, sys::file::Readable);

	m_ctgStrm.setup(m_ctgMapping->address(), m_ctgMapping->size());
	m_ctoStrm.setup(m_ctoMapping->address(), m_ctoMapping->size());
}


Book::~Book()
{
	delete m_ctgMapping;
	delete m_ctoMapping;
}


bool Book::isReadonly() const			{ return true; }
bool Book::isOpen() const				{ return m_ctgMapping; }
bool Book::isEmpty() const				{ return m_pageBounds.lower >= m_pageBounds.upper; }
Book::Format Book::format() const	{ return ChessBase; }


Move
Book::probeNextMove(::db::Board const& position, variant::Type variant)
{
	Move move;

//	ctg_entry_t entry;
//	if (!ctg_get_entry(pos, &entry)) return NO_MOVE;
//	if (!ctg_pick_move(pos, &entry, &move)) return NO_MOVE;

	return move;
}


bool
Book::probePosition(::db::Board const& position, variant::Type variant, Entry& result)
{
	return false;
}


bool
Book::remove(::db::Board const& position, variant::Type variant)
{
	return false;
}


bool
Book::modify(::db::Board const& position, variant::Type variant, Entry const& entry)
{
	return false;
}


bool
Book::add(::db::Board const& position, variant::Type variant, Entry const& entry)
{
	return false;
}


int32_t
Book::getPageIndex(unsigned hash)
{
	uint32_t key = 0;

	for (unsigned mask = 1; key <= m_pageBounds.upper; mask = (mask << 1) + 1)
	{
		key = (hash & mask) + mask;

		if (key >= m_pageBounds.lower)
		{
			int32_t pageIndex;

			m_ctoStrm.seekg(mstl::mul4(key) + 16);
			m_ctoStrm >> pageIndex;

			if (pageIndex >= 0)
				return pageIndex;
		}
	}

	return -1;
}

// vi:set ts=3 sw=3:
