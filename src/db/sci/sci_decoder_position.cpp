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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "sci_decoder_position.h"

#include "db_exception.h"

#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace db;
using namespace db::sq;
using namespace db::sci::decoder;


static Byte const Invalid = 0xff;
#define __ ::Invalid


__attribute__((noreturn))
inline static void
throwInvalidFen()
{
	IO_RAISE(Game, Corrupted, "error while decoding game data (invalid FEN)");
}


inline static unsigned
convSquare(unsigned s)
{
	return make(fyle(s), Rank8 - rank(s));
}


Position::Position()
{
	m_stack.reserve(10);
	m_stack.push();
}


void
Position::doMove(Move& move, unsigned pieceNum)
{
	M_ASSERT(pieceNum < 64);

	Squares& squares = m_stack.top().squares;

	switch (move.action())
	{
		case Move::Null_Move:
			// nothing to do
			break;

		case Move::Castle:
		{
			Byte rank = sq::rank(move.to());

			if (move.isShortCastling())
			{
				squares[pieceNum] = make(FyleG, rank);

				unsigned rookNum = m_rookNumbers[castling::kingSideIndex(move.color())];

				if (rookNum != ::Invalid)	// we allow castlings w/o rook
					squares[rookNum] = make(FyleF, rank);
			}
			else
			{
				squares[pieceNum] = make(FyleC, rank);

				unsigned rookNum = m_rookNumbers[castling::queenSideIndex(move.color())];

				if (rookNum != ::Invalid)	// we allow castlings w/o rook
					squares[rookNum] = make(FyleD, rank);
			}
			break;
		}

		default:
			squares[pieceNum] = move.to();
			break;
	}
}


inline
void
Position::reset()
{
	while (m_stack.size() > 1)
		m_stack.pop();
}


void
Position::setup(char const* fen, variant::Type variant)
{
	if (__builtin_expect(!board().setup(fen, variant), 0))	// should never fail
		::throwInvalidFen();

	M_ASSERT(board().validate(variant) == Board::Valid);

	reset();

	Squares& squares = m_stack.top().squares;

	::memset(squares, Null, sizeof(squares));
	::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));

	Square shortCastlingRook[2];
	Square longCastlingRook[2];

	shortCastlingRook[color::White] = ::convSquare(board().castlingRookSquare(castling::WhiteKS));
	shortCastlingRook[color::Black] = ::convSquare(board().castlingRookSquare(castling::BlackKS));
	longCastlingRook [color::White] = ::convSquare(board().castlingRookSquare(castling::WhiteQS));
	longCastlingRook [color::Black] = ::convSquare(board().castlingRookSquare(castling::BlackQS));

	unsigned whitePieceNum = 1;
	unsigned blackPieceNum = 17;

	Square whiteKingSq = Null;
	Square blackKingSq = Null;

	for (unsigned i = 0; i < 64; ++fen)
	{
		if (::isdigit(*fen))
		{
			if (__builtin_expect(*fen == '9', 0))
				::throwInvalidFen();

			i += *fen - '0';
		}
		else switch (*fen)
		{
			case 'R':
				if (i == shortCastlingRook[color::White])
					m_rookNumbers[castling::WhiteKS] = whitePieceNum;
				else if (i == longCastlingRook[color::White])
					m_rookNumbers[castling::WhiteQS] = whitePieceNum;
				 // fallthru

			case 'Q': case 'B': case 'N':
				if (__builtin_expect(whitePieceNum == 16, 0))	// should never happen
					 ::throwInvalidFen();
				squares[whitePieceNum++] = ::convSquare(i++);
				break;

			case 'P':
			{
					if (__builtin_expect(whitePieceNum == 16, 0))	// should never happen
					::throwInvalidFen();
				Square sq = ::convSquare(i++);
				if (__builtin_expect((1 << rank(sq)) & (1 << Rank1 | 1 << Rank8), 0))
					::throwInvalidFen();
				squares[whitePieceNum++] = sq;
				break;
			}

			case 'r':
				if (i == shortCastlingRook[color::Black])
					m_rookNumbers[castling::BlackKS] = blackPieceNum;
				else if (i == longCastlingRook[color::Black])
					m_rookNumbers[castling::BlackQS] = blackPieceNum;
				 // fallthru

			case 'q': case 'b': case 'n':
				if (__builtin_expect(blackPieceNum == 0x20, 0))	// should never happen
					::throwInvalidFen();
				squares[blackPieceNum++] = ::convSquare(i++);
				break;

			case 'p':
			{
				if (__builtin_expect(blackPieceNum == 0x20, 0))	// should never happen
					::throwInvalidFen();
				Square sq = ::convSquare(i++);
				if (__builtin_expect((1 << rank(sq)) & (1 << Rank1 | 1 << Rank8), 0))
					::throwInvalidFen();
				squares[blackPieceNum++] = sq;
				break;
			}

			case 'K':
				if (whiteKingSq == Null)
					squares[0] = whiteKingSq = ::convSquare(i++);
				else if (__builtin_expect(!variant::isAntichessExceptLosers(variant), 0))
					::throwInvalidFen();
				else
					squares[whitePieceNum++] = ::convSquare(i++);
				break;

			case 'k':
				if (blackKingSq == Null)
					squares[16] = blackKingSq = ::convSquare(i++);
				else if (__builtin_expect(!variant::isAntichessExceptLosers(variant), 0))
					::throwInvalidFen();
				else
					squares[blackPieceNum++] = ::convSquare(i++);
				break;

			case '/':
				if (__builtin_expect(i & 7, 0))
					::throwInvalidFen();
				break;

			case '~':
				break;

			default:
				::throwInvalidFen();
		}
	}
}


void
Position::setupBoard(Board const& board, variant::Type variant)
{
	M_ASSERT(board.isShuffleChessPosition(variant));

	static Squares const StandardSquares =
	{
		__, a2, b2, c2, d2, e2, f2, g2,
		h2, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		a7, b7, c7, d7, e7, f7, g7, h7,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
		__, __, __, __, __, __, __, __,
	};

	reset();

	Squares& squares = m_stack.top().squares;

	::memcpy(squares, StandardSquares, sizeof(StandardSquares));
	::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));

	squares[ 0] = board.kingSquare(color::White);
	squares[16] = board.kingSquare(color::Black);

	Byte whitePieceNum = 9;
	Byte blackPieceNum = 17;

	for (unsigned square = a1; square <= h1; ++square)
	{
		switch (unsigned(board.piece(ID(square))))
		{
			case piece::Rook:
				if (m_rookNumbers[castling::WhiteQS] == ::Invalid)
				{
					m_rookNumbers[castling::WhiteQS] = whitePieceNum;
					m_rookNumbers[castling::BlackQS] = blackPieceNum;
				}
				else
				{
					m_rookNumbers[castling::WhiteKS] = whitePieceNum;
					m_rookNumbers[castling::BlackKS] = blackPieceNum;
				}
				// fallthru

			case piece::Queen:
			case piece::Bishop:
			case piece::Knight:
				squares[whitePieceNum++] = square;
				squares[blackPieceNum++] = square + 7*8;
				break;
		}
	}
}


void
Position::setupBoard(uint16_t idn, variant::Type variant)
{
	reset();

	Squares&	squares = m_stack.top().squares;

	switch (idn)
	{
		case variant::PawnsOn4thRank:
		{
			static Squares const Squares =
			{
				e1, a4, b4, c4, d4, e4, f4, g4,
				h4, a1, b1, c1, d1, f1, g1, h1,
				e8, a8, b8, c8, d8, f8, g8, h8,
				a5, b5, c5, d5, e5, f5, g5, h5,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 23;
			break;
		}

		case variant::LittleGame:
		{
			static Squares const Squares =
			{
				d1, a2, b2, c2, __, __, __, __,
				__, __, __, __, __, __, __, __,
				e8, f7, g7, h7, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::KNNvsKP:
		{
			static Squares const Squares =
			{
				g3, h2, e5, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				g7, e6, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::Pyramid:
		{
			static Squares const Squares =
			{
				e1, d5, e5, c4, f4, b3, g3, a2,
				h2, a1, b1, c1, d1, f1, g1, h1,
				e8, a8, b8, c8, d8, f8, g8, h8,
				a7, h7, b6, g6, c5, f5, d4, e4,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 23;
			break;
		}

		case variant::PawnsOnly:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, __, __, __, __, __, __, __,
				e8, a7, b7, c7, d7, e7, f7, g7,
				h7, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::KnightsOnly:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, b1, g1, __, __, __, __, __,
				e8, b8, g8, a7, b7, c7, d7, e7,
				f7, g7, h7, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::BishopsOnly:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, c1, f1, __, __, __, __, __,
				e8, c8, f8, a7, b7, c7, d7, e7,
				f7, g7, h7, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::RooksOnly:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, a1, h1, __, __, __, __, __,
				e8, a8, h8, a7, b7, c7, d7, e7,
				f7, g7, h7, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 10;
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 18;
			break;
		}

		case variant::QueensOnly:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, d1, __, __, __, __, __, __,
				e8, d8, a7, b7, c7, d7, e7, f7,
				g7, h7, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::NoQueens:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, a1, b1, c1, f1, g1, h1, __,
				e8, a8, b8, c8, f8, g8, h8, a7,
				b7, c7, d7, e7, f7, g7, h7, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 14;
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 22;
			break;
		}

		case variant::WildFive:
		{
			static Squares const Squares =
			{
				d8, a7, b7, c7, d7, e7, f7, g7,
				h7, __, __, __, __, __, __, __,
				d1, a2, b2, c2, d2, e2, f2, g2,
				h2, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::KBNK:
		case variant::KBBK:
		{
			static Squares const Squares =
			{
				e1, a1, h1, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				e8, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		case variant::Runaway:
		{
			static Squares const Squares =
			{
				e3, a2, b2, c2, d2, e2, f2, g2,
				h2, a1, b1, c1, d1, f1, g1, h1,
				e6, a8, b8, c8, d8, f8, g8, h8,
				a7, b7, c7, d7, e7, f7, g7, h7,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			m_rookNumbers[castling::WhiteQS] =  9;
			m_rookNumbers[castling::WhiteKS] = 15;
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 23;
			break;
		}

		case variant::QueenVsRooks:
		{
			static Squares const Squares =
			{
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, d1, __, __, __, __, __, __,
				e3, a2, b2, c2, d2, e2, f2, g2,
				h2, a1, b1, c1, d1, f1, g1, h1,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			m_rookNumbers[castling::BlackQS] = 17;
			m_rookNumbers[castling::BlackKS] = 18;
			break;
		}

		case variant::UpsideDown:
		{
			static Squares const Squares =
			{
				e8, a8, b8, c8, d8, f8, g8, h8,
				a7, b7, c7, d7, e7, f7, g7, h7,
				e1, a2, b2, c2, d2, e2, f2, g2,
				h2, a1, b1, c1, d1, f1, g1, h1,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
				__, __, __, __, __, __, __, __,
			};
			::memcpy(squares, Squares, sizeof(Squares));
			::memset(m_rookNumbers, ::Invalid, sizeof(m_rookNumbers));
			break;
		}

		default: IO_RAISE(Game, Corrupted, "error while decoding game data (invalid position number)");
	}

	board().setup(idn, variant);
}


void
Position::setup(uint16_t idn, variant::Type variant)
{
	M_ASSERT(idn);

	if (idn == variant::Standard || idn == variant::NoCastling)
	{
		static Squares const StandardSquares =
		{
			e1, a2, b2, c2, d2, e2, f2, g2,
			h2, a1, b1, c1, d1, f1, g1, h1,
			e8, a8, b8, c8, d8, f8, g8, h8,
			a7, b7, c7, d7, e7, f7, g7, h7,
			__, __, __, __, __, __, __, __,
			__, __, __, __, __, __, __, __,
			__, __, __, __, __, __, __, __,
			__, __, __, __, __, __, __, __,
		};

		reset();

		Squares&	squares = m_stack.top().squares;
		::memcpy(squares, StandardSquares, sizeof(StandardSquares));

		m_rookNumbers[castling::WhiteQS] =  9;
		m_rookNumbers[castling::WhiteKS] = 15;
		m_rookNumbers[castling::BlackQS] = 17;
		m_rookNumbers[castling::BlackKS] = 23;

		board().setStandardPosition(idn == variant::Standard ? variant::Normal : variant::Antichess);
	}
	else if (variant::isShuffleChess(idn))
	{
		board().setup(idn, variant);
		setupBoard(board(), variant);
	}
	else
	{
		setupBoard(idn, variant);
	}
}

// vi:set ts=3 sw=3:
