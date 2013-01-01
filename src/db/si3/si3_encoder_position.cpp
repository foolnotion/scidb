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

#include "si3_encoder_position.h"

#include "db_board.h"
#include "db_exception.h"

#include <string.h>

using namespace db;
using namespace db::si3::encoder;


__attribute__((noreturn))
inline static void
throwInvalidBoardPosition()
{
	IO_RAISE(Game, Corrupted, "invalid board position");
}


inline static unsigned
convSquare(unsigned s)
{
	return sq::make(sq::fyle(s), sq::Rank8 - sq::rank(s));
}


Position::Position()
{
	m_stack.reserve(10);
	m_stack.push();
}


void
Position::doMove(Move const& move)
{
 	Lookup&		lookup	= m_stack.top();
	unsigned		pieceNum = lookup.numbers[move.from()];
	color::ID	color		= move.color();

	if (move.isCastling())
	{
		sq::Rank rank = sq::rank(move.to());

		if (move.isShortCastling())
		{
			Byte& rookNum = lookup.rookNumbers[castling::kingSideIndex(color)];

			if (rookNum != 255)	// we allow castlings without rook
			{
				rookNum = lookup.numbers[lookup.squares[color][rookNum]];
				lookup.set(sq::make(sq::FyleF, rank), rookNum, color);
			}

			lookup.set(sq::make(sq::FyleG, rank), pieceNum, color);
		}
		else
		{
			Byte& rookNum = lookup.rookNumbers[castling::queenSideIndex(color)];

			if (rookNum != 255)	// we allow castlings without rook
			{
				rookNum = lookup.numbers[lookup.squares[color][rookNum]];
				lookup.set(sq::make(sq::FyleD, rank), rookNum, color);
			}

			lookup.set(sq::make(sq::FyleC, rank), pieceNum, color);
		}
	}
	else if (__builtin_expect(!move.isNull(), 1))
	{
		M_ASSERT(!move.isPieceDrop());

		if (move.isCapture())
		{
			color::ID	opposite	= color::opposite(color);
			unsigned		count		= --lookup.pieceCount[opposite];

			lookup.capturedNum = lookup.numbers[move.capturedSquare()];
			lookup.set(lookup.squares[opposite][count], lookup.capturedNum, opposite);
		}

		lookup.set(move.to(), pieceNum, color);
	}
}


void
Position::undoMove(Move const& move)
{
 	Lookup&		lookup	= m_stack.top();
	color::ID	color		= move.color();

 	if (move.isCastling())
 	{
 		if (move.isShortCastling())
 		{
 			Byte rookNum = lookup.rookNumbers[castling::kingSideIndex(color)];

			if (rookNum != 255)	// we allow castlings without rook
				lookup.set(sq::make(sq::FyleH, sq::rank(move.to())), rookNum, color);
		}
 		else
 		{
 			Byte rookNum = lookup.rookNumbers[castling::queenSideIndex(move.color())];

			if (rookNum != 255)	// we allow castlings without rook
				lookup.set(sq::make(sq::FyleA, sq::rank(move.to())), rookNum, color);
 		}

		lookup.set(move.from(), 0, color);
 	}
 	else if (__builtin_expect(!move.isNull(), 1))
 	{
		M_ASSERT(!move.isPieceDrop());

 		unsigned	pieceNum	= lookup.numbers[move.to()];

	 	if (move.captured() != piece::None)
 		{
 			M_ASSERT(lookup.capturedNum);

			color::ID	opposite	= color::opposite(move.color());
 			unsigned		count		= lookup.pieceCount[opposite]++;

			lookup.set(lookup.squares[opposite][lookup.capturedNum], count, opposite);
			lookup.set(move.capturedSquare(), lookup.capturedNum, opposite);
 		}

		lookup.set(move.from(), pieceNum, color);
 	}
}


void
Position::setup(Board const& board)
{
	M_ASSERT(!board.isStandardPosition());

	while (m_stack.size() > 1)
		m_stack.pop();

	Square shortCastlingRook[2];
	Square longCastlingRook[2];

	Byte whitePieceNum = 0;
	Byte blackPieceNum = 0;

	Lookup& lookup = m_stack.top();

	Lookup::Numbers&		numbers		= lookup.numbers;
	Lookup::Squares&		squares		= lookup.squares;
	Lookup::RookNumbers&	rookNumbers	= lookup.rookNumbers;
	Lookup::Count&			pieceCount	= lookup.pieceCount;

	::memset(numbers, 0, sizeof(Lookup::Numbers));
	::memset(squares, 0, sizeof(Lookup::Squares));
	::memset(rookNumbers, 255, sizeof(Lookup::RookNumbers));
	pieceCount[0] = pieceCount[1] = 0;

	shortCastlingRook[color::White] = board.shortCastlingRook(color::White);
	shortCastlingRook[color::Black] = board.shortCastlingRook(color::Black);
	longCastlingRook [color::White] = board.longCastlingRook (color::White);
	longCastlingRook [color::Black] = board.longCastlingRook (color::Black);

	for (unsigned i = 0; i < 64; ++i)
	{
		unsigned square = ::convSquare(i);

		switch (board.pieceAt(square))
		{
			case piece::Empty:
				break;

			case piece::WhiteKing:
				if (whitePieceNum)
				{
					if (rookNumbers[castling::WhiteQS] == 0)
						rookNumbers[castling::WhiteQS] = whitePieceNum;
					else if (rookNumbers[castling::WhiteKS] == 0)
						rookNumbers[castling::WhiteKS] = whitePieceNum;
					numbers[squares[color::White][0]] = whitePieceNum;
					mstl::swap(squares[color::White][0], squares[color::White][whitePieceNum]);
				}
				whitePieceNum++;
				lookup.set(square, 0, color::White);
				lookup.pieceCount[color::White]++;
				break;

			case piece::BlackKing:
				if (blackPieceNum)
				{
					if (rookNumbers[castling::BlackQS] == 0)
						rookNumbers[castling::BlackQS] = blackPieceNum;
					else if (rookNumbers[castling::BlackKS] == 0)
						rookNumbers[castling::BlackKS] = blackPieceNum;
					numbers[squares[color::Black][0]] = blackPieceNum;
					mstl::swap(squares[color::Black][0], squares[color::Black][blackPieceNum]);
				}
				blackPieceNum++;
				lookup.set(square, 0, color::Black);
				lookup.pieceCount[color::Black]++;
				break;

			case piece::WhiteRook:
				if (square == shortCastlingRook[color::White])
					rookNumbers[castling::WhiteKS] = whitePieceNum;
				else if (square == longCastlingRook[color::White])
					rookNumbers[castling::WhiteQS] = whitePieceNum;
				// fallthru

			case piece::WhiteQueen:
			case piece::WhiteBishop:
			case piece::WhiteKnight:
			case piece::WhitePawn:
				if (__builtin_expect(whitePieceNum == 16, 0))
					::throwInvalidBoardPosition();
				lookup.set(square, whitePieceNum++, color::White);
				lookup.pieceCount[color::White]++;
				break;

			case piece::BlackRook:
				if (square == shortCastlingRook[color::Black])
					rookNumbers[castling::BlackKS] = blackPieceNum;
				else if (square == longCastlingRook[color::Black])
					rookNumbers[castling::BlackQS] = blackPieceNum;
				// fallthru

			case piece::BlackQueen:
			case piece::BlackBishop:
			case piece::BlackKnight:
			case piece::BlackPawn:
				if (__builtin_expect(blackPieceNum == 16, 0))
					::throwInvalidBoardPosition();
				lookup.set(square, blackPieceNum++, color::Black);
				lookup.pieceCount[color::Black]++;
				break;
		}
	}
}


void
Position::setup()
{
#define __ 255
	static Lookup::Numbers const StandardPieceNumbers =
	{
		 1,  2,  3,  4,  0,  5,  6,  7,
		 8,  9, 10, 11, 12, 13, 14, 15,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		 8,  9, 10, 11, 12, 13, 14, 15,
		 1,  2,  3,  4,  0,  5,  6,  7,
	};
#undef __

	static Lookup::Squares const StandardSquares =
	{
		{
			sq::e1, sq::a1, sq::b1, sq::c1, sq::d1, sq::f1, sq::g1, sq::h1,
			sq::a2, sq::b2, sq::c2, sq::d2, sq::e2, sq::f2, sq::g2, sq::h2,
		},
		{
			sq::e8, sq::a8, sq::b8, sq::c8, sq::d8, sq::f8, sq::g8, sq::h8,
			sq::a7, sq::b7, sq::c7, sq::d7, sq::e7, sq::f7, sq::g7, sq::h7,
		},
	};

	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();

	::memcpy(lookup.numbers, StandardPieceNumbers, sizeof(StandardPieceNumbers));
	::memcpy(lookup.squares, StandardSquares, sizeof(StandardSquares));
	lookup.pieceCount[0] = lookup.pieceCount[1] = 16;
	lookup.rookNumbers[castling::WhiteQS] = lookup.rookNumbers[castling::BlackQS] = 1;
	lookup.rookNumbers[castling::WhiteKS] = lookup.rookNumbers[castling::BlackKS] = 7;
}

// vi:set ts=3 sw=3:
