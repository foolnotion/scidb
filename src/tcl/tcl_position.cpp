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
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_position.h"
#include "tcl_application.h"
#include "tcl_base.h"

#include "app_application.h"
#include "app_cursor.h"

#include "db_game.h"
#include "db_game_info.h"
#include "db_guess.h"
#include "db_board.h"
#include "db_move.h"
#include "db_move_list.h"

#include <tcl.h>
#include <ctype.h>
#include <string.h>

using namespace app;
using namespace db;
using namespace tcl;

using namespace tcl::pos;
using namespace tcl::app;

static char const* CmdBoard			= "::scidb::pos::board";
static char const* CmdFen				= "::scidb::pos::fen";
static char const* CmdGuess			= "::scidb::pos::guess";
static char const* CmdGuessNext		= "::scidb::pos::guessNext";
static char const* CmdIdn				= "::scidb::pos::idn";
static char const* CmdInHand			= "::scidb::pos::inHand?";
static char const* CmdLegal			= "::scidb::pos::legal?";
static char const* CmdPromotion		= "::scidb::pos::promotion?";
static char const* CmdSan				= "::scidb::pos::san";
static char const* CmdSearchDepth	= "::scidb::pos::searchDepth";
static char const* CmdSetup			= "::scidb::pos::setup";
static char const* CmdStm				= "::scidb::pos::stm";
static char const* CmdValid			= "::scidb::pos::valid?";
static char const* CmdVariations		= "::scidb::pos::variations";

static Square		m_bestSquareCache[64];
static Move			m_bestMoveCache[64];
static unsigned	m_searchDepth	= 3;
static MoveList	m_bestMoveList;
static unsigned	m_bestMoveIndex = 0;


static Square
squareFromObj(int objc, Tcl_Obj* const objv[], unsigned index)
{
	char const* arg = stringFromObj(objc, objv, index);

	if (sq::isValid(arg))
		return sq::make(arg);

	if (::strcmp(arg, "null") == 0)
		return sq::Null;

	unsigned val = intFromObj(objc, objv, index);

	if (val < sq::a1 || sq::h8 < val)
		return sq::Null;

	return val;
}


static piece::Type
findPiece(material::Count mat)
{
	if (mat.queen ) return piece::Queen;
	if (mat.rook  ) return piece::Rook;
	if (mat.bishop) return piece::Bishop;
	if (mat.knight) return piece::Knight;

	return piece::Pawn;
}


void
pos::resetMoveCache()
{
	memset(m_bestSquareCache, sq::Null, sizeof(m_bestSquareCache));
	m_bestMoveList.clear();
}


void
pos::dumpBoard(Board const& board, mstl::string& result)
{
	result.resize(64);

	for (unsigned i = 0; i < 64; ++i)
	{
		char c = piece::print(board.pieceAt(i));
		result[i] = isalpha(c) ? c : '.';
	}
}


void
pos::dumpFen(mstl::string const& position, variant::Type variant, mstl::string& result)
{
	Board board;
	board.setup(position, variant);
	dumpBoard(board, result);
}


/// Takes a square and returns the best square that makes a move
/// with the given square. The square can be the from or to part of
/// a move. Used for smart move completion.
/// Returns -1 if no legal moves go to or from the square.
static int
cmdGuess(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square square = squareFromObj(objc, objv, 1);

	if (square == sq::Null)
		return error(::CmdGuess, nullptr, nullptr, "invalid square %s", Tcl_GetString(objv[1]));

	Game const& game = Scidb->game();
	Board const& currentBoard = game.currentBoard();
	variant::Type variant = game.variant();

	m_bestMoveList.clear();

	if (m_bestSquareCache[square] == sq::Invalid)
	{
		setResult(-1);
	}
	else if (m_bestSquareCache[square] != sq::Null)
	{
		m_bestMoveList.append(m_bestMoveCache[square]);
		setResult(m_bestSquareCache[square]);
	}
	else
	{
		Guess board(currentBoard, variant, game.idn());
		Move bestMove(board.bestMove(square, m_searchDepth));
		int bestSquare = -1;

		if (bestMove)
		{
			m_bestMoveList.clear();
			m_bestMoveList.append(bestMove);
			m_bestMoveIndex = 0;
			bestSquare = bestMove.from() == square ? bestMove.to() : bestMove.from();
			m_bestSquareCache[square] = sq::ID(bestSquare);
			m_bestMoveCache[square] = bestMove;
		}
		else
		{
			m_bestSquareCache[square] = sq::Invalid;
		}

		setResult(bestSquare);
	}

	return TCL_OK;
}


static int
cmdGuessNext(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square square = squareFromObj(objc, objv, 1);

	if (square == sq::Null)
		return error(::CmdGuess, nullptr, nullptr, "invalid square %s", Tcl_GetString(objv[1]));

	if (	m_bestSquareCache[square] == sq::Null
		|| m_bestSquareCache[square] == sq::Invalid
		|| m_bestMoveList.isEmpty())
	{
		setResult(-1);
	}
	else
	{
		Game const& game = Scidb->game();
		Board const& currentBoard = game.currentBoard();

		// TODO: We have to distinguish between chess960 and standard chess.
		// Currently class Guess is designed for standard chess.
		Guess board(currentBoard, game.variant(), game.idn());
		Move bestMove(board.bestMove(square, m_bestMoveList, m_searchDepth));
		int bestSquare = -1;

		if (bestMove)
		{
			m_bestMoveList.append(bestMove);
			bestSquare = bestMove.from() == square ? bestMove.to() : bestMove.from();
			m_bestMoveIndex = 0;
		}
		else if (m_bestMoveList.size() > 1)
		{
			bestMove = m_bestMoveList[m_bestMoveIndex];
			bestSquare = bestMove.from() == square ? bestMove.to() : bestMove.from();

			if (++m_bestMoveIndex == m_bestMoveList.size())
				m_bestMoveIndex = 0;
		}

		setResult(bestSquare);
	}

	return TCL_OK;
}


static int
cmdSearchDepth(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	m_searchDepth = unsignedFromObj(objc, objv, 1);
	resetMoveCache();
	return TCL_OK;
}


static int
cmdStm(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(color::isWhite(Scidb->game().currentBoard().sideToMove()) ? "w" : "b");
	return TCL_OK;
}


static int
cmdVariations(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* result = Tcl_NewListObj(0, 0);

	Game const& game = Scidb->game();

	if (game.subVariationCount() > 0)
	{
		for (int i = -1; i < int(game.subVariationCount()); ++i)
		{
			mstl::string	san;
			Move				move(i == -1 ? game.nextMove() : game.nextMove(i));

			move.printSan(san, protocol::Scidb, encoding::Utf8);

			Tcl_Obj* objs[3];
			objs[0] = Tcl_NewStringObj(san, san.size());
			objs[1] = Tcl_NewIntObj(move.from());
			objs[2] = Tcl_NewIntObj(move.to());

			Tcl_ListObjAppendElement(ti, result, Tcl_NewListObj(3, objs));
		}
	}

	setResult(result);
	return TCL_OK;
}


static int
cmdBoard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	mstl::string result;
	dumpBoard(Scidb->game().currentBoard(), result);
	setResult(result);
	return TCL_OK;
}


static int
cmdFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb->game().currentBoard().toFen(Scidb->game().variant()));
	return TCL_OK;
}


static int
cmdSetup(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	scidb->game().setStartPosition(stringFromObj(objc, objv, 1));
	return TCL_OK;
}


static int
cmdIdn(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Scidb->game().currentBoard().computeIdn(Scidb->game().variant()));
	return TCL_OK;
}


static int
cmdValid(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square sq1 = squareFromObj(objc, objv, 1);
	Square sq2 = squareFromObj(objc, objv, 2);

	piece::Type piece = piece::None;

	if (objc > 3)
		piece::fromLetter(*stringFromObj(objc, objv, 3));

	Game const& game = Scidb->game();
	Board	board	= game.currentBoard();
	variant::Type variant = game.variant();

	if (board.gameIsOver(variant))
	{
		setResult(false);
	}
	else if (sq1 == sq::Null || sq2 == sq::Null)
	{
		setResult(true);
	}
	else
	{
		Move move;

		if (!variant::isAntichessExceptLosers(variant))
		{
			board.tryCastleShort(board.sideToMove());
			board.tryCastleLong(board.sideToMove());
		}

		if (sq1 == sq2 && variant::isZhouse(variant))
		{
			if (piece == piece::None)
				piece = ::findPiece(board.holding());
			move = board.preparePieceDrop(sq1, piece, move::AllowIllegalMove);
		}
		else
		{
			move = board.prepareMove(sq1, sq2, variant, move::AllowIllegalMove);
		}

#ifdef ALLOW_INVALID_MOVES
		setResult(bool(move));
#else
		setResult(bool(move) && board.checkMove(move, game.variant()));
#endif
	}

	return TCL_OK;
}


static int
cmdLegal(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square sq1 = squareFromObj(objc, objv, 1);
	Square sq2 = squareFromObj(objc, objv, 2);

	Game const& game = Scidb->game();
	Board	board	= game.currentBoard();
	bool allowIllegalMove = boolFromObj(objc, objv, 3);
	variant::Type variant = game.variant();
	piece::Type piece = piece::None;
	move::Constraint flag = allowIllegalMove ? move::AllowIllegalMove : move::DontAllowIllegalMove;

	if (objc > 4)
		piece = piece::fromLetter(*stringFromObj(objc, objv, 4));

	if (board.gameIsOver(variant))
	{
		setResult(false);
	}
	else if (sq1 == sq::Null || sq2 == sq::Null)
	{
		setResult(true);
	}
	else
	{
		Move move;

		if (sq1 == sq2 && variant::isZhouse(variant))
		{
			if (piece == piece::None)
				piece = ::findPiece(board.holding());
			move = board.preparePieceDrop(sq1, piece, flag);
		}
		else
		{
			move = board.prepareMove(sq1, sq2, game.variant(), flag);

			if (!variant::isAntichessExceptLosers(variant) && !move.isLegal() && allowIllegalMove)
			{
				color::ID side = board.sideToMove();

				board.tryCastleShort(side);
				board.tryCastleLong(side);

				move = board.prepareMove(sq1, sq2, variant, move::AllowIllegalMove);
			}
		}

#ifdef ALLOW_INVALID_MOVES
		setResult(bool(move));
#else
		setResult(bool(move) && board.checkMove(move, game.variant(), flag));
#endif
	}

	return TCL_OK;
}


static int
cmdPromotion(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square sq1 = squareFromObj(objc, objv, 1);
	Square sq2 = squareFromObj(objc, objv, 2);

	bool allowIllegalMove = boolFromObj(objc, objv, 3);

	if (sq1 == sq::Null || sq2 == sq::Null)
	{
		setResult(false);
	}
	else
	{
		Game const& game = Scidb->game();

		Board	board	= game.currentBoard();
		Move	move	= board.prepareMove(sq1, sq2, game.variant());

		if (!move.isLegal() && allowIllegalMove)
		{
			Board			board	= Scidb->game().currentBoard();
			color::ID	side	= board.sideToMove();

			board.tryCastleShort(side);
			board.tryCastleLong(side);

			move = board.prepareMove(sq1, sq2, game.variant(), move::AllowIllegalMove);
		}

#ifdef ALLOW_INVALID_MOVES
		setResult(move.isPromotion());
#else
		setResult(move.isPromotion() && board.checkMove(move, game.variant()));
#endif
	}

	return TCL_OK;
}


static int
cmdInHand(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	bool sideToMoveOnly = false;
	Square destination = sq::Null;
	int position = -1;
	int firstArg = 1;

	if (objc > 1)
	{
		char const* arg = Tcl_GetString(objv[1]);

		if (isdigit(arg[0]) || (arg[0] == '-' && isdigit(arg[1])))
		{
			position = intFromObj(objc, objv, 1);
			++firstArg;
		}
	}

	for (int i = firstArg; i < objc; ++i)
	{
		if (strcmp(Tcl_GetString(objv[i]), "-stm") == 0)
		{
			sideToMoveOnly = true;
		}
		else if (strcmp(Tcl_GetString(objv[i]), "-destination") == 0)
		{
			if (++i == objc)
				return error(CmdInHand, nullptr, nullptr, "argument missing to '-destination'");

			destination = squareFromObj(objc, objv, i);
		}
		else
		{
			return error(CmdInHand, nullptr, nullptr, "invalid option '%s'", Tcl_GetString(objv[i]));
		}
	}

	bool includePawns = false;

	if (	destination == sq::Null
		|| (sq::rank(destination) != sq::Rank1 && sq::rank(destination) != sq::Rank8))
	{
		includePawns = true;
	}

	if (sideToMoveOnly)
	{
		Board::Material inHand = Scidb->game(position).currentBoard().holding();

		Tcl_Obj* objs[5];

		objs[0] = Tcl_NewIntObj(inHand.queen);
		objs[1] = Tcl_NewIntObj(inHand.rook);
		objs[2] = Tcl_NewIntObj(inHand.bishop);
		objs[3] = Tcl_NewIntObj(inHand.knight);
		objs[4] = Tcl_NewIntObj(includePawns ? inHand.pawn : 0);

		setResult(5, objs);
	}
	else
	{
		Tcl_Obj* result[2];

		for (unsigned i = 0; i < 2; ++i)
		{
			color::ID color = i ? color::Black : color::White;
			Board::Material inHand = Scidb->game(position).currentBoard().holding(color);

			Tcl_Obj* objs[5];

			objs[0] = Tcl_NewIntObj(inHand.queen);
			objs[1] = Tcl_NewIntObj(inHand.rook);
			objs[2] = Tcl_NewIntObj(inHand.bishop);
			objs[3] = Tcl_NewIntObj(inHand.knight);
			objs[4] = Tcl_NewIntObj(includePawns ? inHand.pawn : 0);

			result[i] = Tcl_NewListObj(5, objs);
		}

		setResult(2, result);
	}

	return TCL_OK;
}


static int
cmdSan(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Square	sq1	= squareFromObj(objc, objv, 1);
	Square	sq2	= squareFromObj(objc, objv, 2);
	Byte		promo	= 'q';

	if (objc >= 4)
		promo = *stringFromObj(objc, objv, 3);

	Game const& game = Scidb->game();
	Move move;

	if (sq1 == sq::Null && sq2 == sq::Null)
		move = game.currentBoard().makeNullMove();
	else if (sq1 == sq::Null)
		return error(::CmdSan, nullptr, nullptr, "invalid square %s", Tcl_GetString(objv[1]));
	else if (sq2 == sq::Null)
		return error(::CmdSan, nullptr, nullptr, "invalid square %s", Tcl_GetString(objv[2]));
	else if (sq1 == sq2)
		move = game.currentBoard().preparePieceDrop(sq2, piece::fromLetter(promo), move::AllowIllegalMove);
	else
		move = game.currentBoard().prepareMove(sq1, sq2, game.variant());

	if (!move.isLegal() && !move.isPieceDrop())
	{
		Board			board	= Scidb->game().currentBoard();
		color::ID	side	= board.sideToMove();

		board.tryCastleShort(side);
		board.tryCastleLong(side);

		move = board.prepareMove(sq1, sq2, game.variant(), move::AllowIllegalMove);
	}

	if (!move)
	{
		setResult(mstl::string::empty_string);
	}
	else
	{
		if (move.isPromotion())
		{
			piece::Type piece = piece::fromLetter(promo);

			if (objc >= 4 && !piece::canPromoteTo(piece, game.variant()))
			{
				return error(	::CmdSan,
									nullptr, nullptr,
									"invalid promotion piece %s",
									Tcl_GetString(objv[3]));
			}

			move.setPromotionPiece(piece);
		}

		mstl::string san;
		Scidb->game().currentBoard().prepareForPrint(
			move, Scidb->game().variant(), Board::InternalRepresentation);
		move.printSan(san, protocol::Standard, encoding::Latin1);
		setResult(san);
	}

	return TCL_OK;
}


namespace tcl {
namespace pos {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdBoard,			cmdBoard);
	createCommand(ti, CmdFen,				cmdFen);
	createCommand(ti, CmdGuess,			cmdGuess);
	createCommand(ti, CmdGuessNext,		cmdGuessNext);
	createCommand(ti, CmdIdn,				cmdIdn);
	createCommand(ti, CmdInHand,			cmdInHand);
	createCommand(ti, CmdLegal,			cmdLegal);
	createCommand(ti, CmdPromotion,		cmdPromotion);
	createCommand(ti, CmdSan,				cmdSan);
	createCommand(ti, CmdSearchDepth,	cmdSearchDepth);
	createCommand(ti, CmdSetup,			cmdSetup);
	createCommand(ti, CmdStm,				cmdStm);
	createCommand(ti, CmdValid,			cmdValid);
	createCommand(ti, CmdVariations,		cmdVariations);
}

} // namespace game
} // namespace tcl

// vi:set ts=3 sw=3:
