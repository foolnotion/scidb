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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "si3_decoder_position.h"

#include "db_exception.h"

#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;
using namespace db::si3::decoder;


__attribute__((noreturn))
inline static void
throwInvalidFen()
{
	IO_RAISE(Game, Corrupted, "invalid FEN");
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
Position::doMove(Move& move, unsigned pieceNum)
{
	Lookup&		lookup	= m_stack.top();
	color::ID	color		= lookup.board.sideToMove();

	move.setColor(color);

	if (lookup.board.isValidMove(move, move::DontAllowIllegalMove))
		move.setLegalMove();
	else if (!lookup.board.checkMove(move, move::AllowIllegalMove))
		IO_RAISE(Game, Corrupted, "invalid move");

	lookup.board.prepareUndo(move);

	if (move.isCastling())
	{
		sq::Rank rank = sq::rank(move.to());

		if (move.isShortCastling())
		{
			Byte& rookNum = lookup.rookNumbers[castling::kingSideIndex(color)];

			if (__builtin_expect(rookNum != 255, 1))	// we allow castlings without rook
			{
				rookNum = lookup.numbers[lookup.squares[rookNum]];
				lookup.set(rookNum, sq::make(sq::FyleF, rank));
			}

			lookup.set(pieceNum, sq::make(sq::FyleG, rank));
		}
		else
		{
			Byte& rookNum = lookup.rookNumbers[castling::queenSideIndex(color)];

			if (__builtin_expect(rookNum != 255, 1))	// we allow castlings without rook
			{
				rookNum = lookup.numbers[lookup.squares[rookNum]];
				lookup.set(rookNum, sq::make(sq::FyleD, rank));
			}

			lookup.set(pieceNum, sq::make(sq::FyleC, rank));
		}
	}
	else if (__builtin_expect(!move.isNull(), 1))
	{
		if (move.captured() != piece::None)
		{
			unsigned	count = --lookup.pieceCount[color::opposite(color)];
			lookup.capturedNum = lookup.numbers[move.capturedSquare()];
			lookup.set(lookup.capturedNum, lookup.squares[count]);
		}

		lookup.set(pieceNum, move.to());
	}

	lookup.board.doMove(move);
}


void
Position::undoMove(Move const& move)
{
 	Lookup& lookup = m_stack.top();

 	if (move.isCastling())
 	{
		color::ID color = move.color();

		if (move.isShortCastling())
		{
			Byte rookNum = lookup.rookNumbers[castling::kingSideIndex(color)];

			if (__builtin_expect(rookNum != 255, 1))	// we allow castlings without rook
				lookup.set(rookNum, move.to());
		}
		else
		{
			Byte rookNum = lookup.rookNumbers[castling::queenSideIndex(color)];

			if (__builtin_expect(rookNum != 255, 1))	// we allow castlings without rook
				lookup.set(rookNum, move.to());
		}

		lookup.set(color::isWhite(color) ? 0 : 0x10, move.from());

 	}
 	else if (__builtin_expect(!move.isNull(), 1))
 	{
 		unsigned	pieceNum	= lookup.numbers[move.to()];

	 	if (move.captured() != piece::None)
 		{
 			M_ASSERT(lookup.capturedNum);

 			unsigned	count = lookup.pieceCount[color::opposite(move.color())]++;
			lookup.set(count, lookup.squares[lookup.capturedNum]);
			lookup.set(lookup.capturedNum, move.capturedSquare());
 		}

		lookup.set(pieceNum, move.from());
 	}

 	lookup.board.undoMove(move);
}


void
Position::setup(char const* fen)
{
	while (m_stack.size() > 1)
		m_stack.pop();

	typedef unsigned Pieces[2];

	if (__builtin_expect(!board().setup(fen), 0))	// should never fail
		::throwInvalidFen();

	// Scid allows invalid FEN's, we'll try to fix it.
	board().fixBadCastlingRights();

	if (board().validate(variant::Standard) != Board::Valid)
		IO_RAISE(Game, Invalid_Data, "invalid FEN (%s)", fen);

// WARNING: flags::Non_Standard_Start is possibly set wrong (Scid bug)
//	M_ASSERT(!board().isStandardPosition());

	unsigned whitePieceNum = 0;
	unsigned blackPieceNum = 0x10;

	Lookup& lookup = m_stack.top();

	Squares&			squares		= lookup.squares;
	Numbers&			numbers		= lookup.numbers;
	Pieces&			pieceCount	= lookup.pieceCount;
	RookNumbers&	rookNumbers	= lookup.rookNumbers;

	::memset(squares, 0, sizeof(squares));
	::memset(numbers, 0, sizeof(numbers));
	::memset(rookNumbers, 255, sizeof(rookNumbers));

	pieceCount[color::White] = 0;
	pieceCount[color::Black] = 0x10;

	Square shortCastlingRook[2];
	Square longCastlingRook[2];

	bool haveKing[2] = { false, false };

	shortCastlingRook[color::White] = ::convSquare(board().castlingRookSquare(castling::WhiteKS));
	shortCastlingRook[color::Black] = ::convSquare(board().castlingRookSquare(castling::BlackKS));
	longCastlingRook [color::White] = ::convSquare(board().castlingRookSquare(castling::WhiteQS));
	longCastlingRook [color::Black] = ::convSquare(board().castlingRookSquare(castling::BlackQS));

	for (unsigned i = 0; i < 64; ++fen)
	{
		if (::isdigit(*fen))
		{
			if (*fen == '9')
				::throwInvalidFen();

			i += *fen - '0';
		}
		else switch (*fen)
		{
			case 'R':
				if (i == shortCastlingRook[color::White])
					rookNumbers[castling::WhiteKS] = whitePieceNum;
				else if (i == longCastlingRook[color::White])
					rookNumbers[castling::WhiteQS] = whitePieceNum;
				 // fallthru

			case 'Q': case 'B': case 'N':
				if (__builtin_expect(whitePieceNum == 0x10, 0))	// should never happen
					 ::throwInvalidFen();
				lookup.set(whitePieceNum++, ::convSquare(i++));
				++pieceCount[color::White];
				break;

			case 'P':
				if (__builtin_expect(whitePieceNum == 0x10, 0))	// should never happen
					 ::throwInvalidFen();
				{
					Square sq = ::convSquare(i++);
					if ((1 << sq::rank(sq)) & (1 << sq::Rank1 | (1 << sq::Rank8)))
						::throwInvalidFen();
					lookup.set(whitePieceNum++, sq);
					++pieceCount[color::White];
				}
				break;

			case 'r':
				if (i == shortCastlingRook[color::Black])
					rookNumbers[castling::BlackKS] = blackPieceNum;
				else if (i == longCastlingRook[color::Black])
					rookNumbers[castling::BlackQS] = blackPieceNum;
				 // fallthru

			case 'q': case 'b': case 'n':
				if (__builtin_expect(blackPieceNum == 0x20, 0))	// should never happen
					::throwInvalidFen();
				lookup.set(blackPieceNum++, ::convSquare(i++));
				++pieceCount[color::Black];
				break;

			case 'p':
				if (__builtin_expect(blackPieceNum == 0x20, 0))	// should never happen
					::throwInvalidFen();
				{
					Square sq = ::convSquare(i++);
					if ((1 << sq::rank(sq)) & (1 << sq::Rank1 | (1 << sq::Rank8)))
						::throwInvalidFen();
					lookup.set(blackPieceNum++, sq);
					++pieceCount[color::Black];
				}
				break;

			case 'K':
				if (haveKing[color::White])
					::throwInvalidFen();
				if (whitePieceNum)
				{
					if (rookNumbers[castling::WhiteQS] == 0)
						rookNumbers[castling::WhiteQS] = whitePieceNum;
					else if (rookNumbers[castling::WhiteKS] == 0)
						rookNumbers[castling::WhiteKS] = whitePieceNum;
					mstl::swap(squares[0], squares[whitePieceNum]);
					numbers[squares[whitePieceNum]] = whitePieceNum;
				}
				whitePieceNum++;
				lookup.set(0, ::convSquare(i++));
				++pieceCount[color::White];
				haveKing[color::White] = true;
				break;

			case 'k':
				if (haveKing[color::Black])
					::throwInvalidFen();
				if (blackPieceNum != 0x10)
				{
					if (rookNumbers[castling::BlackQS] == 0x10)
						rookNumbers[castling::BlackQS] = blackPieceNum;
					else if (rookNumbers[castling::BlackKS] == 0x10)
						rookNumbers[castling::BlackKS] = blackPieceNum;
					mstl::swap(squares[0x10], squares[blackPieceNum]);
					numbers[squares[blackPieceNum]] = blackPieceNum;
				}
				blackPieceNum++;
				lookup.set(0x10, ::convSquare(i++));
				++pieceCount[color::Black];
				haveKing[color::Black] = true;
			break;

			case '/':
				if (__builtin_expect(i & 7, 0))	// should never happen
					::throwInvalidFen();
				break;
		}
	}
}


void
Position::setup()
{
	static Squares const StandardSquares =
	{
		sq::e1, sq::a1, sq::b1, sq::c1, sq::d1, sq::f1, sq::g1, sq::h1,
		sq::a2, sq::b2, sq::c2, sq::d2, sq::e2, sq::f2, sq::g2, sq::h2,
		sq::e8, sq::a8, sq::b8, sq::c8, sq::d8, sq::f8, sq::g8, sq::h8,
		sq::a7, sq::b7, sq::c7, sq::d7, sq::e7, sq::f7, sq::g7, sq::h7,
	};
#define __ 0
	static Numbers const StandardPieceNumbers =
	{
		 1,  2,  3,  4,  0,  5,  6,  7,
		 8,  9, 10, 11, 12, 13, 14, 15,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		24, 25, 26, 27, 28, 29, 30, 31,
		17, 18, 19, 20, 16, 21, 22, 23,
	};
#undef __

	while (m_stack.size() > 1)
		m_stack.pop();

	Lookup& lookup = m_stack.top();

	::memcpy(lookup.numbers, StandardPieceNumbers, sizeof(StandardPieceNumbers));
	::memcpy(lookup.squares, StandardSquares, sizeof(StandardSquares));
	lookup.pieceCount[color::White] = 16;
	lookup.pieceCount[color::Black] = 32;

	lookup.rookNumbers[castling::WhiteQS] = 1;
	lookup.rookNumbers[castling::WhiteKS] = 7;
	lookup.rookNumbers[castling::BlackQS] = 17;
	lookup.rookNumbers[castling::BlackKS] = 23;

	board().setStandardPosition();
}

// vi:set ts=3 sw=3:
