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
// Copyright: (C) 2008-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sci_encoder_position.h"

#include "db_board.h"
#include "db_exception.h"

#include <string.h>

using namespace db;
using namespace db::sci::encoder;

enum { Invalid = 255 };
#define __ ::Invalid


__attribute__((noreturn))
inline static void
throwInvalidBoardPosition()
{
	IO_RAISE(Game, Corrupted, "invalid board position");
}


inline static unsigned
flipSquare(unsigned s)
{
	return sq::make(sq::fyle(s), sq::Rank8 - sq::rank(s));
}


Position::Position()
{
	m_stack.reserve(10);
	m_stack.push();
}


Byte
Position::dropPiece(Move const& move)
{
	Lookup&			lookup	= m_stack.top();
	Lookup::Used&	used		= lookup.used[move.color()];

	M_ASSERT(!used.complete());

	Byte pieceNum = used.find_first_not();

	M_ASSERT(pieceNum > 0);
	used.set(pieceNum);
	lookup[move.to()] = pieceNum;

	return pieceNum;
}


void
Position::doMove(Lookup& lookup, Move const& move)
{
	Square to = move.to();

	switch (move.action())
	{
		case Move::Castle:
		{
			sq::Rank	rank		= sq::rank(to);
			Byte		pieceNum	= lookup[move.from()];

			if (move.isShortCastling())
			{
				lookup[sq::make(sq::FyleF, rank)] = m_rookNumbers[castling::kingSideIndex(move.color())];
				lookup[sq::make(sq::FyleG, rank)] = pieceNum;
			}
			else
			{
				lookup[sq::make(sq::FyleD, rank)] = m_rookNumbers[castling::queenSideIndex(move.color())];
				lookup[sq::make(sq::FyleC, rank)] = pieceNum;
			}
			break;
		}

		case Move::PieceDrop:
		case Move::Null_Move:
			// nothing to do
			break;

		default:
			if (move.capturedType())
			{
				Byte pieceNum = lookup[move.isEnPassant() ? move.enPassantSquare() : to];
				M_ASSERT(pieceNum < 32);
				lookup.used[color::opposite(move.color())].reset(pieceNum);
			}
			lookup[to] = lookup[move.from()];
			break;
	}
}


void
Position::setupZero(Board const& board)
{
	M_ASSERT(!board.isShuffleChessPosition());

	Square shortCastlingRook[2];
	Square longCastlingRook[2];

	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();

	::memset(lookup.numbers, ::Invalid, sizeof(Lookup::Numbers));
	::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));

	shortCastlingRook[color::White] = board.shortCastlingRook(color::White);
	shortCastlingRook[color::Black] = board.shortCastlingRook(color::Black);
	longCastlingRook [color::White] = board.longCastlingRook (color::White);
	longCastlingRook [color::Black] = board.longCastlingRook (color::Black);

	Lookup::Used& wUsed = lookup.used[color::White];
	Lookup::Used& bUsed = lookup.used[color::Black];

	wUsed.reset(); wUsed.set(0); wUsed.set(16);
	bUsed.reset(); bUsed.set(0); bUsed.set(16);

	Byte whitePieceNum = 1;
	Byte blackPieceNum = 1;

	Square whiteKingSq = sq::Null;
	Square blackKingSq = sq::Null;

	for (unsigned i = 0; i < 64; ++i)
	{
		Square square = ::flipSquare(i);

		switch (unsigned(board.pieceAt(square)))
		{
			case piece::WhiteKing:
				if (whiteKingSq == sq::Null)
				{
					lookup[whiteKingSq = square] = 0;
				}
				else
				{
					wUsed.set(whitePieceNum);
					lookup[square] = whitePieceNum++;
				}
				break;

			case piece::BlackKing:
				if (blackKingSq == sq::Null)
				{
					lookup[blackKingSq = square] = 0;
				}
				else
				{
					wUsed.set(blackPieceNum);
					lookup[square] = blackPieceNum++;
				}
				break;

			case piece::WhiteRook:
				if (square == shortCastlingRook[color::White])
					m_rookNumbers[castling::WhiteKS] = whitePieceNum;
				else if (square == longCastlingRook[color::White])
					m_rookNumbers[castling::WhiteQS] = whitePieceNum;
				// fallthru

			case piece::WhiteQueen:
			case piece::WhiteBishop:
			case piece::WhiteKnight:
			case piece::WhitePawn:
				if (__builtin_expect(whitePieceNum == 16, 0))
					::throwInvalidBoardPosition();
				wUsed.set(whitePieceNum);
				lookup[square] = whitePieceNum++;
				break;

			case piece::BlackRook:
				if (square == shortCastlingRook[color::Black])
					m_rookNumbers[castling::BlackKS] = blackPieceNum;
				else if (square == longCastlingRook[color::Black])
					m_rookNumbers[castling::BlackQS] = blackPieceNum;
				// fallthru

			case piece::BlackQueen:
			case piece::BlackBishop:
			case piece::BlackKnight:
			case piece::BlackPawn:
				if (__builtin_expect(blackPieceNum == 16, 0))
					::throwInvalidBoardPosition();
				bUsed.set(blackPieceNum);
				lookup[square] = blackPieceNum++;
				break;
		}
	}
}


void
Position::setupShuffle(Board const& board)
{
	static Lookup::Numbers const PawnPieceNumbers =
	{
		__, __, __, __, __, __, __, __, // a1,..,h1
		 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
		__, __, __, __, __, __, __, __, // a3,..,h3
		__, __, __, __, __, __, __, __, // a4,..,h4
		__, __, __, __, __, __, __, __, // a5,..,h5
		__, __, __, __, __, __, __, __, // a6,..,h6
		 8,  9, 10, 11, 12, 13, 14, 15, // a7,..,h7
		__, __, __, __, __, __, __, __, // a8,..,h8
	};

	M_REQUIRE(board.isShuffleChessPosition());

	Square shortCastlingRook[2];
	Square longCastlingRook[2];

	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();

	::memcpy(lookup.numbers, PawnPieceNumbers, sizeof(PawnPieceNumbers));
	::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));

	shortCastlingRook[color::White] = board.shortCastlingRook(color::White);
	shortCastlingRook[color::Black] = board.shortCastlingRook(color::Black);
	longCastlingRook [color::White] = board.longCastlingRook (color::White);
	longCastlingRook [color::Black] = board.longCastlingRook (color::Black);

	Lookup::Used& wUsed = lookup.used[color::White];
	Lookup::Used& bUsed = lookup.used[color::Black];

	wUsed.reset(); wUsed.set(0, 16);
	bUsed.reset(); bUsed.set(0, 16);

	Square wk = board.kingSquare(color::White);
	lookup[wk] = 0;

	Square bk = board.kingSquare(color::Black);
	lookup[bk] = 0;

	Byte whitePieceNum = 9;
	Byte blackPieceNum = 1;

	for (unsigned square = sq::a1; square <= sq::h1; ++square)
	{
		switch (unsigned(board.piece(sq::ID(square))))
		{
			case piece::Rook:
				if (square == shortCastlingRook[color::White])
				{
					m_rookNumbers[castling::WhiteKS] = whitePieceNum;
					m_rookNumbers[castling::BlackKS] = blackPieceNum;
				}
				else if (square == longCastlingRook[color::White])
				{
					m_rookNumbers[castling::WhiteQS] = whitePieceNum;
					m_rookNumbers[castling::BlackQS] = blackPieceNum;
				}
				// fallthru

			case piece::Queen:
			case piece::Bishop:
			case piece::Knight:
				lookup[square] = whitePieceNum++;
				lookup[square + 7*8] = blackPieceNum++;
				break;
		}
	}
}


void
Position::setup(uint16_t idn)
{
	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();

	Lookup::Used& wUsed = lookup.used[color::White];
	Lookup::Used& bUsed = lookup.used[color::Black];

	wUsed.reset(); wUsed.set(16);
	bUsed.reset(); bUsed.set(16);

	switch (idn)
	{
		case variant::PawnsOn4thRank:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 9, 10, 11, 12,  0, 13, 14, 15, // a1,..,h1
				__, __, __, __, __, __, __, __, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				 1,  2,  3,  4,  5,  6,  7,  8, // a4,..,h4
				 8,  9, 10, 11, 12, 13, 14, 15, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				__, __, __, __, __, __, __, __, // a7,..,h7
				 1,  2,  3,  4,  0,  5,  6,  7, // a8,..,h8
			};
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 15);
			bUsed.set(0, 15);
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  7;
			break;
		}

		case variant::LittleGame:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __,  0, __, __, __, __, // a1,..,h1
				 1,  2,  3, __, __, __, __, __, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				__, __, __, __, __,  1,  2,  3, // a7,..,h7
				__, __, __, __,  0, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 3);
			bUsed.set(0, 3);
			break;
		}

		case variant::KNNvsKP:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __, __, __, __, __, __, // a1,..,h1
				__, __, __, __, __, __, __,  2, // a2,..,h2
				__, __, __, __, __, __,  0, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __,  1, __, __, __, // a5,..,h5
				__, __, __, __, __,  1, __, __, // a6,..,h6
				__, __, __, __, __, __,  0, __, // a7,..,h7
				__, __, __, __, __, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 2);
			bUsed.set(0, 1);
			break;
		}

		case variant::Pyramid:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 9, 10, 11, 12,  0, 13, 14, 15, // a1,..,h1
				 7, __, __, __, __, __, __,  8, // a2,..,h2
				__,  5, __, __, __, __,  6, __, // a3,..,h3
				__, __,  3, 14, 15,  4, __, __, // a4,..,h4
				__, __, 12,  1,  2, 13, __, __, // a5,..,h5
				__, 10, __, __, __, __, 11, __, // a6,..,h6
				 8, __, __, __, __,__, __,   9, // a7,..,h7
				 1,  2,  3,  4,  0,  5,  6,  7, // a8,..,h8
			};
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 15);
			bUsed.set(0, 15);
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  7;
			break;
		}

		case variant::PawnsOnly:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __, __,  0, __, __, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 1,  2,  3,  4,  5,  6,  7,  8, // a7,..,h7
				__, __, __, __,  0, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 8);
			bUsed.set(0, 8);
			break;
		}

		case variant::KnightsOnly:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__,  9, __, __,  0, __, 10, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 3,  4,  5,  6,  7,  8,  9, 10, // a7,..,h7
				__,  1, __, __,  0, __,  2, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 10);
			bUsed.set(0, 10);
			break;
		}

		case variant::BishopsOnly:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __,  9, __,  0, 10, __, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 3,  4,  5,  6,  7,  8,  9, 10, // a7,..,h7
				__, __,  1, __,  0,  2, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 10);
			bUsed.set(0, 10);
			break;
		}

		case variant::RooksOnly:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 9, __, __, __,  0, __, __, 10, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 3,  4,  5,  6,  7,  8,  9, 10, // a7,..,h7
				 1, __, __, __,  0, __, __,  2, // a8,..,h8
			};
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 10;
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  2;
			wUsed.set(0, 10);
			bUsed.set(0, 10);
			break;
		}

		case variant::QueensOnly:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __,  9,  0, __, __, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 2,  3,  4,  5,  6,  7,  8,  9, // a7,..,h7
				__, __, __,  1,  0, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 9);
			bUsed.set(0, 9);
			break;
		}

		case variant::NoQueens:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 9, 10, 11, __,  0, 12, 13, 14, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 7,  8,  9, 10, 11, 12, 13, 14, // a7,..,h7
				 1,  2,  3, __,  0,  4,  5,  6, // a8,..,h8
			};
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 14;
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  6;
			wUsed.set(0, 14);
			bUsed.set(0, 14);
			break;
		}

		case variant::WildFive:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __,  0, __, __, __, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 1,  2,  3,  4,  5,  6,  7,  8, // a7,..,h7
				__, __, __,  0, __, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 8);
			bUsed.set(0, 8);
			break;
		}

		case variant::KBNK:
		case variant::KBBK:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 1, __, __, __,  0, __, __,  2, // a1,..,h1
				__, __, __, __, __, __, __, __, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				__, __, __, __, __, __, __, __, // a7,..,h7
				__, __, __, __,  0, __, __, __, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 2);
			bUsed.set(0);
			break;
		}

		case variant::Runaway:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				 9, 10, 11, 12, __, 13, 14, 15, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __,  0, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __,  0, __, __, __, // a6,..,h6
				 8,  9, 10, 11, 12, 13, 14, 15, // a7,..,h7
				 1,  2,  3,  4, __,  5,  6,  7, // a8,..,h8
			};
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			wUsed.set(0, 15);
			bUsed.set(0, 15);
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  7;
			break;
		}

		case variant::QueenVsRooks:
		{
			static Lookup::Numbers const PieceNumbers =
			{
				__, __, __,  9,  0, __, __, __, // a1,..,h1
				 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
				__, __, __, __, __, __, __, __, // a3,..,h3
				__, __, __, __, __, __, __, __, // a4,..,h4
				__, __, __, __, __, __, __, __, // a5,..,h5
				__, __, __, __, __, __, __, __, // a6,..,h6
				 3,  4,  5,  6,  7,  8,  9, 10, // a7,..,h7
				 1, __, __, __,  0, __, __,  2, // a8,..,h8
			};
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			::memcpy(lookup.numbers, PieceNumbers, sizeof(PieceNumbers));
			m_rookNumbers[castling::BlackQS] =  1;
			m_rookNumbers[castling::BlackKS] =  2;
			wUsed.set(0, 9);
			bUsed.set(0, 10);
			break;
		}

		default:
			M_ASSERT(!"unexpected position number");
			break;
	}
}


void
Position::setupStandard()
{
	static Lookup::Numbers const StandardPieceNumbers =
	{
		 9, 10, 11, 12,  0, 13, 14, 15, // a1,..,h1
		 1,  2,  3,  4,  5,  6,  7,  8, // a2,..,h2
		__, __, __, __, __, __, __, __, // a3,..,h3
		__, __, __, __, __, __, __, __, // a4,..,h4
		__, __, __, __, __, __, __, __, // a5,..,h5
		__, __, __, __, __, __, __, __, // a6,..,h6
		 8,  9, 10, 11, 12, 13, 14, 15, // a7,..,h7
		 1,  2,  3,  4,  0,  5,  6,  7, // a8,..,h8
	};

	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();
	::memcpy(lookup.numbers, StandardPieceNumbers, sizeof(StandardPieceNumbers));

	Lookup::Used& wUsed = lookup.used[color::White];
	Lookup::Used& bUsed = lookup.used[color::Black];
	wUsed.reset(); wUsed.set(0, 16);
	bUsed.reset(); bUsed.set(0, 16);

	m_rookNumbers[castling::WhiteQS] =  9;
	m_rookNumbers[castling::WhiteKS] = 15;
	m_rookNumbers[castling::BlackQS] =  1;
	m_rookNumbers[castling::BlackKS] =  7;
}

// vi:set ts=3 sw=3:
