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

#include "cbf_decoder_position.h"

#include "db_board_base.h"
#include "db_exception.h"

#include "u_byte_stream.h"

#include "m_utility.h"

using namespace util;
using namespace db;
using namespace db::cbf::decoder;


namespace {

struct MoveGenEntry
{
	piece::Type	type;

	int df;
	int dr;

	bool epIndex;
};

static const MoveGenEntry MoveGenTable[] =
{
	{ piece::King,		-1, -1, false },
	{ piece::King,		-1,  0, false },
	{ piece::King,		-1, +1, false },
	{ piece::King,		 0, -1, false },
	{ piece::King,		 0, +1, false },
	{ piece::King,		+1, -1, false },
	{ piece::King,		+1,  0, false },
	{ piece::King,		+1, +1, false },
	{ piece::King,		+2,  0, false },
	{ piece::King,		-2,  0, false },
	{ piece::Queen,	-1, -1, false },
	{ piece::Queen,	+1, -1, false },
	{ piece::Queen,	+1, +1, false },
	{ piece::Queen,	-1, +1, false },
	{ piece::Queen,	-1,  0, false },
	{ piece::Queen,	 0, -1, false },
	{ piece::Queen,	+1,  0, false },
	{ piece::Queen,	 0, +1, false },
	{ piece::Rook,		-1,  0, false },
	{ piece::Rook,		 0, -1, false },
	{ piece::Rook,		+1,  0, false },
	{ piece::Rook,		 0, +1, false },
	{ piece::Bishop,	-1, -1, false },
	{ piece::Bishop,	+1, -1, false },
	{ piece::Bishop,	+1, +1, false },
	{ piece::Bishop,	-1, +1, false },
	{ piece::Knight,	-2, -1, false },
	{ piece::Knight,	-2, +1, false },
	{ piece::Knight,	+2, -1, false },
	{ piece::Knight,	+2, +1, false },
	{ piece::Knight,	-1, -2, false },
	{ piece::Knight,	-1, +2, false },
	{ piece::Knight,	+1, -2, false },
	{ piece::Knight,	+1, +2, false },
	{ piece::Pawn,		 0, +2, false },
	{ piece::Pawn,		 0, +1, false },
	{ piece::Pawn,		-1, +1, false },
	{ piece::Pawn,		+1, +1, false },
	{ piece::Pawn,		-1, +1, true  },
	{ piece::Pawn,		+1, +1, true  },
	{ piece::None,		 0,  0, false },
};

static const unsigned TableOffset[] =
{
	 0, // piece::None
	 0, // piece::King
	10, // piece::Queen
	18, // piece::Rook
	22, // piece::Bishop
	26, // piece::Knight
	34, // piece::Pawn
};

static const piece::Type PromotionTbl[] =
{
	piece::Queen, piece::Rook, piece::Bishop, piece::Knight
};

} // namespace


Position::Entry::Entry() :epFake(false) {}


Position::Position()
{
	static_assert(		piece::None   == 0
						&& piece::King   == 1
						&& piece::Queen  == 2
						&& piece::Rook   == 3
						&& piece::Bishop == 4
						&& piece::Knight == 5
						&& piece::Pawn   == 6,
						"table not working");

	m_stack.reserve(10);
	m_stack.push();
}


Move
Position::doMove(unsigned moveNumber)
{
	Entry&		top			= m_stack.top();
	Board&		board			= top.board;
	color::ID	sideToMove	= board.sideToMove();
	unsigned		count			= 0;
	Move			move;

	for (Byte fyle = sq::FyleA; fyle <= sq::FyleH; ++fyle)
	{
		for (Byte rank = sq::Rank1; rank <= sq::Rank8; ++rank)
		{
			sq::ID		sq		= sq::make(fyle, rank);
			piece::ID	piece	= board.pieceAt(sq);

			if (piece != piece::Empty && piece::color(piece) == sideToMove)
			{
				piece::Type				type			= piece::type(piece);
				MoveGenEntry const*	moveGen		= MoveGenTable + TableOffset[type];
				unsigned					iteration	= piece::longStepPiece(piece) ? 7 : 1;

				for ( ; moveGen->type == type; ++moveGen)
				{
					// Imitating the strange behaviour of ChessBase:
					// -----------------------------------------------------------
					// Count a5xh6ep as a legal move if the opponent has not moved
					// any pawn from the 7th to the 5th rank during the last move
					// (a4xh3ep similar).
					if (	moveGen->epIndex
						&& moveGen->df == 1
						&& fyle == sq::FyleA
						&& rank == (sideToMove == color::White ? sq::Rank5 : sq::Rank4)
						&& board.enPassantSquareFen() == sq::Null)
					{
						++count;
					}

					Byte f = fyle;
					Byte r = rank;

					for (unsigned j = 0; j < iteration; ++j)
					{
						if (type == piece::King && mstl::abs(moveGen->df) == 2 && f == sq::FyleE)
						{
							if (sideToMove == color::White)
							{
								if (r != sq::Rank1)
									break;

								if (moveGen->df == 2)
								{
									if (	board.pieceAt(sq::h1) != piece::WhiteRook
										|| board.anyOccupied(board::F1 | board::G1))
									{
										break;
									}
								}
								else
								{
									if (	board.pieceAt(sq::a1) != piece::WhiteRook
										|| board.anyOccupied(board::B1 | board::C1 | board::D1))
									{
										break;
									}
								}
							}
							else
							{
								if (r != sq::Rank8)
									break;

								if (moveGen->df == 2)
								{
									if (	board.pieceAt(sq::h8) != piece::BlackRook
										|| board.anyOccupied(board::F8 | board::G8))
									{
										break;
									}
								}
								else
								{
									if (	board.pieceAt(sq::a8) != piece::BlackRook
										|| board.anyOccupied(board::B8 | board::C8 | board::D8))
									{
										break;
									}
								}
							}

							move = board.makeMove(sq, sq::make(f + moveGen->df, r), piece::None);
							M_ASSERT(move);
						}
						else
						{
							if (!sq::isValidFyle(f += moveGen->df))
								break;

							if (piece == piece::BlackPawn)
								r -= moveGen->dr;
							else
								r += moveGen->dr;

							if (!sq::isValidRank(r))
								break;

							sq::ID to = sq::make(f, r);

							move = board.prepareMove(sq, to, variant::Normal, move::AllowIllegalMove);

							if (!move)
							{
								if (moveGen->epIndex && to == board.enPassantSquare() && top.epFake)
								{
									// Imitating the strange behaviour of ChessBase:
									// ---------------------------------------------------
									// Unbelievable! In case of an restored e.p. right (see below)
									// en passant moves will be counted even if the target is occupied
									// by an own piece. Try game #6813 from
									// <ftp://ftp.pitt.edu/group/student-activities/chess/CB/Openings/sisch-cb.zip>.
									++count;
								}

								break;
							}

							bool isEnPassant = move.isEnPassant();

							if (isEnPassant && !moveGen->epIndex)
							{
								// Probably it's not an en passant move due to wrong e.p. rights.
								// See hack below.
								if (board.piece(move.to()) != piece::None)
									move.unsetEnPassant();
							}

							if (move.isEnPassant() != moveGen->epIndex)
								break;

							if (isEnPassant && top.epFake && board.piece(move.to()) == piece::None)
							{
								// Wow! We can decode games which even ChessBase cannot decode
								// correctly! It's a severe encoding/decoding bug in ChessBase.
								// Try game #288 from
								// <ftp://ftp.pitt.edu/group/student-activities/chess/PGN/Players/kburg-pg.zip>.
								++count;
								break;
							}
						}

						count += move.isPromotion() ? 4 : 1;

						if (count >= moveNumber)
						{
							if (move.isPromotion())
							{
								M_ASSERT(3 - (count - moveNumber) < U_NUMBER_OF(PromotionTbl));
								move.setPromotionPiece(PromotionTbl[3 - (count - moveNumber)]);
							}

							if (!board.isValidMove(move, variant::Normal, move::AllowIllegalMove))
								IO_RAISE(Game, Corrupted, "corrupted game data");

							Square epSq = board.enPassantSquareFen();

							board.prepareUndo(move);
							board.doMove(move, variant::Normal);

							// Imitating the strange behaviour of ChessBase:
							// ------------------------------------------------
							// We restore the en passant square of previous ply
							// if the last ply is a castling.
							if ((top.epFake = (move.isCastling() && epSq != sq::Null)))
								board.setEnPassantFyle(board.sideToMove(), sq::fyle(epSq));

							return move;
						}
					}
				}
			}
		}
	}

	return move;
}


inline
void
Position::reset()
{
	while (m_stack.size() > 1)
		m_stack.pop();
}


void
Position::setup()
{
	reset();
	board().setStandardPosition();
}


void
Position::setup(ByteStream& strm, Byte h10, Byte h11)
{
	reset();

	if (h10 & 1)
	{
		M_ASSERT(strm.size() >= 33);
		static_assert(sq::a1 == 0 && sq::b1 == 1 && sq::h8 == 63, "iteration loop not working");

		Board& board = this->board();
		board.clear();

		for (Byte sq = sq::a1; sq <= sq::h8; ++sq)
		{
			Byte byte = strm.peek();

			if (mstl::is_odd(sq))
			{
				byte &= 0x0f;
				strm.skip(1);
			}
			else
			{
				byte >>= 4;
			}

			if (byte)
			{
				static piece::Type PieceMap[] =
				{
					piece::King,	piece::Queen,	piece::Knight,
					piece::Bishop,	piece::Rook,	piece::Pawn,
					piece::None,	piece::None,	piece::None,
				};

				piece::Type	piece = PieceMap[(byte < 0x09 ? byte : byte - 0x08) - 1];
				color::ID	color = byte < 0x09 ? color::White : color::Black;

				board.setAt(sq, piece::piece(piece, color), variant::Normal);
			}
		}

		if (h10 & 0x02)
			board.swapToMove();

		board.setMoveNumber(strm.get() + 1);

		if (h10 & 0x04)
			board.setCastleLong(color::White);
		if (h10 & 0x08)
			board.setCastleShort(color::White);
		if (h10 & 0x10)
			board.setCastleLong(color::Black);
		if (h10 & 0x20)
			board.setCastleShort(color::Black);
		if (h10 & (0x04 | 0x08 | 0x10 | 0x20))
			board.fixBadCastlingRights();

		if (h11 & 0x0f)
		{
			static_assert(sq::Rank1 == 0, "not working");
			static_assert(sq::Rank8 == 7, "not working");

			board.setEnPassantFyle(sq::Fyle(((h11 & 0x0f) - 1)));
		}

		Board::SetupStatus status = board.validate(variant::Normal);

		if (status == Board::InvalidEnPassant)
		{
			// ChessBase may allow invalid e.p. squares: we will fix this silently.
			board.setEnPassantSquare(sq::Null);
			status = board.validate(variant::Normal);
		}

		if (status != Board::Valid)
			IO_RAISE(Game, Corrupted, "illegal start position");
	}
	else
	{
		board().setStandardPosition();
	}
}

// vi:set ts=3 sw=3:
