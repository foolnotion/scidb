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
// Description of CTG format:
// <http://rybkaforum.net/cgi-bin/rybkaforum/topic_show.pl?pid=26942>
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
#include "m_bit_functions.h"
#include "m_limits.h"
#include "m_assert.h"

#include <string.h>

using namespace db;
using namespace db::sq;
using namespace db::piece;
using namespace db::color;
using namespace db::castling;
using namespace app::chessbase;
using namespace util;


struct Book::CTGEntry
{
	typedef ByteStream::uint24_t uint24_t;

	unsigned	numMoves;
	uint8_t	moves[128];
	uint8_t	annotation[128];
	uint24_t	total;
	uint24_t	wins;
	uint24_t	losses;
	uint24_t	draws;
	uint24_t	avgRatingGames;
	uint32_t	avgRatingScore;
	uint24_t	perfRatingGames;
	uint32_t	perfRatingScore;
	uint8_t	recommendation;
	uint8_t	commentary;
};


struct Book::CTGSignature
{
	uint8_t	buf[512]; // be sure that no overflow occurs
	unsigned	appended;
	unsigned	size;

	CTGSignature() :appended(8) { ::memset(buf, 0, sizeof(buf)); }

	bool equal(uint8_t const* data, unsigned dataSize) const
	{
		return size == dataSize && ::memcmp(data, buf, size) == 0;
	}

	void append(uint8_t bits, unsigned numBits)
	{
		M_ASSERT(appended + numBits <= 64);

		int lshift = 8 - mstl::mod8(appended);
		int rshift = numBits - lshift;

		bits = mstl::bf::reverse(bits) >> (8 - numBits);

		unsigned bytePos = mstl::div8(appended);

		if (rshift > 0)
		{
			buf[bytePos] |= bits >> rshift;
			buf[bytePos + 1] |= bits << (8 - rshift);
		}
		else
		{
			buf[bytePos] |= bits << (lshift - numBits);
		}

		appended += numBits;
	}

	void appendFinally(uint8_t bits, unsigned numBits)
	{
		unsigned freeBits = 8 - mstl::mod8(appended);

		if (freeBits < numBits)
			appended += freeBits;

		int padBits = 8 - mstl::mod8(appended) - numBits;
		appended += padBits < 0 ? padBits + 8 : padBits;
		append(bits, numBits);

		size = mstl::div8(appended + 7);
	}
};


typedef Book::CTGEntry		CTGEntry;
typedef Book::CTGSignature	CTGSignature;


template <typename T> inline static T mul4096(T x)	{ return x << 12; }
template <typename T> inline static T mod32(T x)	{ return x & 0x1f; }
template <typename T> inline static T mul32(T x)	{ return x << 6; }


static bool
computeSignature(piece::ID piece, CTGSignature& sig)
{
	uint8_t	bits;
	unsigned	numBits;

	switch (piece)
	{
		case Empty:	bits = 0x00; numBits = 1; break;
		case WP:		bits = 0x03; numBits = 3; break;
		case BP:		bits = 0x07; numBits = 3; break;
		case WN:		bits = 0x09; numBits = 5; break;
		case BN:		bits = 0x19; numBits = 5; break;
		case WB:		bits = 0x05; numBits = 5; break;
		case BB:		bits = 0x15; numBits = 5; break;
		case WR:		bits = 0x0d; numBits = 5; break;
		case BR:		bits = 0x1d; numBits = 5; break;
		case WQ:		bits = 0x11; numBits = 6; break;
		case BQ:		bits = 0x31; numBits = 6; break;
		case WK:		bits = 0x01; numBits = 6; break;
		case BK:		bits = 0x21; numBits = 6; break;
		default:		return false;
	}

	sig.append(bits, numBits);
	return true;
}


namespace {

template <bool FlipColor, bool FlipBoard> struct ProcessSquares {};

template <> // FlipColor,FlipBoard
struct ProcessSquares<false,false>
{
	static bool find(Board const& position, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (unsigned f = 0; f < 8; ++f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (piece == position.pieceAt(make(Fyle(f), Rank(r))))
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

	static bool computeSignature(Board const& position, CTGSignature& sig)
	{
		for (unsigned f = 0; f < 8; ++f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (!::computeSignature(position.pieceAt(make(Fyle(f), Rank(r))), sig))
					return false;
			}
		}
		return true;
	}
};


template <> // FlipColor,FlipBoard
struct ProcessSquares<true,false>
{
	static bool find(Board const& position, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (unsigned f = 0; f < 8; ++f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (piece == piece::swap(position.pieceAt(make(Fyle(f), Rank(r)))))
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

	static bool computeSignature(Board const& position, CTGSignature& sig)
	{
		for (unsigned f = 0; f < 8; ++f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (!::computeSignature(piece::swap(position.pieceAt(make(Fyle(f), Rank(r)))), sig))
					return false;
			}
		}
		return true;
	}
};


template <> // FlipColor,FlipBoard
struct ProcessSquares<false,true>
{
	static bool find(Board const& position, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (int f = 7; f >= 0; --f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (piece == position.pieceAt(make(f, r)))
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

	static bool computeSignature(Board const& position, CTGSignature& sig)
	{
		for (int f = 7; f >= 0; --f)
		{
			for (unsigned r = 0; r < 8; ++r)
			{
				if (!::computeSignature(position.pieceAt(make(Fyle(f), Rank(r))), sig))
					return false;
			}
		}
		return true;
	}
};


template <> // FlipColor,FlipBoard
struct ProcessSquares<true,true>
{
	static bool find(Board const& position, piece::ID piece, unsigned nth, Fyle& fyle, Rank& rank)
	{
		unsigned count = 0;

		for (int f = 7; f >= 0; --f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (piece == piece::swap(position.pieceAt(make(Fyle(f), Rank(r)))))
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

	static bool computeSignature(Board const& position, CTGSignature& sig)
	{
		for (int f = 7; f >= 0; --f)
		{
			for (int r = 7; r >= 0; --r)
			{
				if (!::computeSignature(piece::swap(position.pieceAt(make(Fyle(f), Rank(r)))), sig))
					return false;
			}
		}
		return true;
	}
};

} // namespace


static bool
computeSignature(Board const& position, CTGSignature& sig)
{
	bool flipColor	= position.blackToMove();
	bool flipBoard	= fyle(position.kingSquare()) <= FyleD && position.castlingRights() == NoRights;
	bool rc			= false;

	switch (unsigned(flipColor) | mstl::mul2(unsigned(flipBoard)))
	{
		case 0: rc = ProcessSquares<false,false>::computeSignature(position, sig); break;
		case 1: rc = ProcessSquares<true, false>::computeSignature(position, sig); break;
		case 2: rc = ProcessSquares<false,true >::computeSignature(position, sig); break;
		case 3: rc = ProcessSquares<true, true >::computeSignature(position, sig); break;
	}

	if (!rc)
		return false;

	unsigned	bitLength	= 0;
	uint8_t	bits			= 0;

	color::ID sideToMove = position.sideToMove();

	if (Rights castlingRights = position.castlingRights(sideToMove))
	{
		if (castlingRights & kingSide(sideToMove))
			bits |= 4;
		if (castlingRights & queenSide(sideToMove))
			bits |= 8;

		color::ID notToMove = position.notToMove();
		castlingRights = position.castlingRights(notToMove);

		if (castlingRights & kingSide(notToMove))
			bits |= 1;
		if (castlingRights & queenSide(notToMove))
			bits |= 2;

		bitLength += 4;
	}

	Square epSquare = position.enPassantSquare();

	if (epSquare != Null)
	{
		Fyle epFyle = fyle(epSquare);

		if (flipBoard)
			epFyle = flipFyle(epFyle);

		bits <<= 3;
		bits |= (mstl::bf::reverse(uint8_t(epFyle)) >> 5);
		bitLength += 3;
	}

	sig.appendFinally(bits, bitLength);
	return true;
}


static
uint32_t
computeHash(CTGSignature const& sig)
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
byteToMove(Board const& position, uint8_t byte)
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

	bool flipColor = position.blackToMove();

	switch (byte)
	{
		case 107:
		{
			Rank rank = flipColor ? Rank8 : Rank1;
			Move move = position.makeMove(make(FyleE, rank), make(FyleG, rank));

			return move.isCastling() ? move : Move::null();
		}

		case 246:
		{
			Rank rank = flipColor ? Rank8 : Rank1;
			Move move = position.makeMove(make(FyleE, rank), make(FyleC, rank));

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

	bool flipBoard = fyle(position.kingSquare()) <= FyleD && position.castlingRights() == NoRights;

	unsigned	nth	= PieceIndex[byte];
	bool		rc		= false;
	Fyle		fyle;
	Rank		rank;

	M_ASSERT(nth > 0);

	switch (unsigned(flipColor) | mstl::mul2(unsigned(flipBoard)))
	{
		case 0: rc = ProcessSquares<false,false>::find(position, piece, nth, fyle, rank); break;
		case 1: rc = ProcessSquares<true, false>::find(position, piece, nth, fyle, rank); break;
		case 2: rc = ProcessSquares<false,true >::find(position, piece, nth, fyle, rank); break;
		case 3: rc = ProcessSquares<true, true >::find(position, piece, nth, fyle, rank); break;
	}

	if (!rc)
		return Move();

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

	return position.makeMove(make(fyle, rank), make(toFyle, toRank));
}


static nag::ID
annotationToNag(Board const& position, uint8_t code)
{
	switch (code)
	{
		case 0x01: return nag::GoodMove;
		case 0x02: return nag::PoorMove;
		case 0x03: return nag::VeryGoodMove;
		case 0x04: return nag::VeryPoorMove;
		case 0x05: return nag::SpeculativeMove;
		case 0x06: return nag::QuestionableMove;
		case 0x08: return nag::SingularMove;
		case 0x16: return position.whiteToMove() ? nag::WhiteIsInZugzwang : nag::BlackIsInZugzwang;
	}

	return nag::Null;
}


static nag::ID
commentaryToNag(uint8_t code)
{
	switch (code)
	{
		case 0x0b: return nag::EqualChancesQuietPosition;
		case 0x0d: return nag::UnclearPosition;
		case 0x0e: return nag::WhiteHasASlightAdvantage;
		case 0x0f: return nag::BlackHasASlightAdvantage;
		case 0x10: return nag::WhiteHasAModerateAdvantage;
		case 0x11: return nag::BlackHasAModerateAdvantage;
		case 0x12: return nag::WhiteHasADecisiveAdvantage;
		case 0x13: return nag::BlackHasADecisiveAdvantage;
		case 0x20: return nag::Development;
		case 0x24: return nag::Initiative;
		case 0x28: return nag::Attack;
		case 0x2c: return nag::WithCompensationForMaterial;
		case 0x84: return nag::Counterplay;
		case 0x8a: return nag::Zeitnot;
	};

	return nag::Null;
}


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
Book::probeMove(::db::Board const& position, variant::Type variant, Choice choice)
{
	Move move;

	if (variant == variant::Normal)
	{
		CTGEntry	entry;

		if (getEntry(position, entry))
			move = pickMove(position, entry, choice);
	}

	return move;
}


bool
Book::probePosition(::db::Board const& position, variant::Type variant, Entry& result)
{
	if (variant != variant::Normal)
		return false;

	CTGEntry entry;

	if (!getEntry(position, entry))
		return false;

	uint64_t weights[128];
	uint64_t maxWeight = 0;
	
	for (unsigned i = 0, k = 0; i < entry.numMoves; ++i)
	{
		if (Move move = ::byteToMove(position, entry.moves[i]))
		{
			result.items.push_back();
			Entry::Item& item = result.items.back();

			bool		recommended;
			uint64_t	weight(moveWeight(position, move, entry.annotation[i], recommended));

			weights[k++] = weight;
			maxWeight = mstl::max(maxWeight, weight);

			item.move					= move;
			item.weight					= weight;
			item.info.annotation		= ::annotationToNag(position, entry.annotation[i]);
			item.info.commentary		= ::commentaryToNag(entry.commentary);
			item.info.mainline		= entry.recommendation == 0x80;
			item.info.exclude			= entry.recommendation == 0x40;
			item.avgRatingGames		= entry.avgRatingGames;
			item.avgRatingScore		= entry.avgRatingScore;
			item.perfRatingGames		= entry.perfRatingGames;
			item.perfRatingScore		= entry.perfRatingScore;
			item.total					= entry.total;
			item.wins					= entry.wins;
			item.losses					= entry.losses;
			item.draws					= entry.draws;
		}
	}

	if (maxWeight)
	{
		unsigned msbIndex = mstl::bf::msb_index(maxWeight);

		if (msbIndex > 15)
		{
			unsigned rshift = msbIndex - 15;

			for (unsigned i = 0; i < result.items.size(); ++i)
				result.items[i].weight = weights[i] >> rshift;
		}
	}

	return true;
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

			if (mstl::mul4(key) + 16 + sizeof(pageIndex) >= m_ctoStrm.capacity())
				return -1;

			m_ctoStrm.seekg(mstl::mul4(key) + 16);
			m_ctoStrm >> pageIndex;

			if (pageIndex >= 0)
				return pageIndex;
		}
	}

	return -1;
}


bool
Book::fillEntry(uint8_t const* data, CTGEntry& entry)
{
	unsigned entrySize = *data;

	if (entrySize == 0)
		return false;

	entry.numMoves = mstl::div2(entrySize - 1);

 	for (unsigned i = 0; i < entry.numMoves; ++i)
	{
		entry.moves[i] = data[mstl::mul2(i) + 1];
		entry.annotation[i] = data[mstl::mul2(i) + 2];
	}

	ByteStream strm(const_cast<uint8_t*>(data) + entrySize, 33u);

	uint32_t	unknown32;
	uint8_t	unknown8;

	strm >> entry.total;
	strm >> entry.losses;
	strm >> entry.wins;
	strm >> entry.draws;
	strm >> unknown32;
	strm >> entry.avgRatingGames;
	strm >> entry.avgRatingScore;
	strm >> entry.perfRatingGames;
	strm >> entry.perfRatingScore;
	strm >> entry.recommendation;
	strm >> unknown8;
	strm >> entry.commentary;

	return true;
}


bool
Book::lookupEntry(unsigned pageIndex, CTGSignature const& sig, CTGEntry& entry)
{
	uint16_t numPositions;

	if (::mul4096(pageIndex + 1) + sizeof(numPositions) >= m_ctgStrm.capacity())
		return false;

	m_ctgStrm.seekg(::mul4096(pageIndex + 1));
	m_ctgStrm >> numPositions;

	uint8_t const* data = m_ctgStrm.data();

	for (unsigned i = 0; i < numPositions; ++i)
	{
		unsigned			entrySize = ::mod32(*data);
		uint8_t const*	nextEntry = data + entrySize + data[entrySize] + 33;

		if (nextEntry >= m_ctgStrm.end())
			return false;

		if (sig.equal(data, entrySize))
			return fillEntry(data + entrySize, entry);

		data = nextEntry;
	}

	return false;
}


bool
Book::getEntry(Board const& position, CTGEntry& entry)
{
	CTGSignature sig;
	computeSignature(position, sig);

	int pageIndex = getPageIndex(computeHash(sig));

	if (pageIndex < 0)
		return false;

	return lookupEntry(pageIndex, sig, entry);
}


Move
Book::pickMove(Board const& position, CTGEntry& entry, Choice choice)
{
	if (entry.numMoves == 0)
		return Move();

	uint64_t	sum			= 0;
	uint64_t	bestWeight	= 0;
	Move		bestMove;

	for (unsigned i = 0; i < entry.numMoves; ++i)
	{
		if (Move move = ::byteToMove(position, entry.moves[i]))
		{
			bool		recommended;
			uint64_t	weight(moveWeight(position, move, entry.annotation[i], recommended));

			if (recommended)
			{
				sum += weight;

				switch (choice)
				{
					case BestFirst:
						if (weight > bestWeight)
						{
							bestMove = move;
							bestWeight = weight;
						}
						break;

					case Best:
						if (	weight > bestWeight
							|| (weight == bestWeight && sum && m_rkiss.rand32(sum) < weight))
						{
							bestMove = move;
							bestWeight = weight;
						}
						break;

					case Random:
						if (sum && m_rkiss.rand32(sum) < weight)
						{
							bestMove = move;
							bestWeight = weight;
						}
						break;
				}
			}
		}
	}

	return bestMove;
}


uint64_t
Book::moveWeight(Board const& position, Move move, uint8_t annotation, bool& recommended)
{
	M_ASSERT(move);

	Board		board(position);
	CTGEntry	entry;
	uint64_t	weight(0);

	board.doMove(move, variant::Normal);

	if (!getEntry(position, entry))
	{
		recommended = false;
		return 0;
	}

	recommended = entry.recommendation == 128;

	if (entry.recommendation != 64)
	{
		uint64_t halfPoints	= mstl::mul2(uint32_t(entry.wins)) + entry.draws;
		uint64_t games			= entry.wins + entry.draws + entry.losses;

		weight = (games < 1) ? 0 : (halfPoints*10000)/games;
	}

	switch (annotation)
	{
		case 0x01: mstl::mul8(weight); break;								//  !
		case 0x02: weight = 0; recommended = false; break;				//  ?
		case 0x03: ::mul32(weight); break;									// !!
		case 0x04: weight = 0; recommended = false; break;				// ??
		case 0x05: mstl::div2(weight); break;								// !?
		case 0x06: mstl::div8(weight); recommended = false; break;	// ?!
		case 0x08: weight = mstl::numeric_limits<uint64_t>::max(); break;	// Only move
		case 0x16: break;															// Zugzwang
	}

	return weight;
}

// vi:set ts=3 sw=3:
