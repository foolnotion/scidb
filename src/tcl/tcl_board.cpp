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
// Copyright: (C) 2010-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_board.h"
#include "tcl_base.h"

#include "db_board.h"
#include "db_board_base.h"

#include "m_string.h"
#include "m_bit_functions.h"

#include <tcl.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace tcl;
using namespace db;

static char const* CmdAnalyseFen			= "::scidb::board::analyseFen";
static char const* CmdFenToBoard			= "::scidb::board::fenToBoard";
static char const* CmdIdnToFen			= "::scidb::board::idnToFen";
static char const* CmdIsValidFen			= "::scidb::board::isValidFen";
static char const* CmdMakeFen				= "::scidb::board::makeFen";
static char const* CmdTransposeFen		= "::scidb::board::transposeFen";
static char const* CmdPositionNumber	= "::scidb::board::positionNumber";
static char const* CmdNormalizeFen		= "::scidb::board::normalizeFen";


mstl::string
tcl::board::toBoard(Board const& board)
{
	mstl::string result(64, '.');

	for (unsigned i = 0; i < 64; ++i)
	{
		char c = piece::print(board.pieceAt(i));

		if (::isalpha(c))
			result[i] = c;
	}

	return result;
}


static mstl::string
toCastling(Board const& board)
{
	mstl::string result;

	result += sq::printAlgebraic(board.castlingRookSquare(castling::WhiteKS));
	result += ' ';
	result += sq::printAlgebraic(board.castlingRookSquare(castling::WhiteQS));
	result += ' ';
	result += sq::printAlgebraic(board.castlingRookSquare(castling::BlackKS));
	result += ' ';
	result += sq::printAlgebraic(board.castlingRookSquare(castling::BlackQS));

	return result;
}


static char const*
validate(Board const& board)
{
	char const* error = 0;

	switch (board.validate(variant::Unknown, castling::DontAllowHandicap))
	{
		case Board::Valid: break;

		case Board::NoWhiteKing:				error = "NoWhiteKing"; break;
		case Board::NoBlackKing:				error = "NoBlackKing"; break;
		case Board::DoubleCheck:				error = "DoubleCheck"; break;
		case Board::OppositeCheck:				error = "OppositeCheck"; break;
		case Board::TooManyWhitePawns:		error = "TooManyWhitePawns"; break;
		case Board::TooManyBlackPawns:		error = "TooManyBlackPawns"; break;
		case Board::TooManyWhitePieces:		error = "TooManyWhitePieces"; break;
		case Board::TooManyBlackPieces:		error = "TooManyBlackPieces"; break;
		case Board::PawnsOn18:					error = "PawnsOn18"; break;
		case Board::TooManyKings:				error = "TooManyKings"; break;
		case Board::TooManyWhite:				error = "TooManyWhite"; break;
		case Board::TooManyBlack:				error = "TooManyBlack"; break;
		case Board::InvalidEnPassant:			error = "InvalidEnPassant"; break;
		case Board::MultiPawnCheck:			error = "MultiPawnCheck"; break;
		case Board::TripleCheck:				error = "TripleCheck"; break;
		case Board::InvalidCastlingRights:	error = "InvalidCastlingRights"; break;
		case Board::AmbiguousCastlingFyles:	error = "AmbiguousCastlingFyles"; break;

		case Board::BadCastlingRights:
			if (board.validate(variant::Unknown, castling::AllowHandicap) == Board::Valid)
				error = "CastlingWithoutRook";
			else
				error = "BadCastlingRights";
			break;
	}

	return error;
}


static int
cmdAnalyseFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* error = 0;

	Board board;

	// TODO: strip zeroes from first part

	if (!board.setup(stringFromObj(objc, objv, 1)))
	{
		error = "InvalidFen";
	}
	else
	{
		if (objc > 2)
		{
			unsigned			rights	= castling::NoRights;
			char const*		castling	= stringFromObj(objc, objv, 2);
			char const*		fyles		= stringFromObj(objc, objv, 3);

			board.removeCastlingRights();

			for ( ; *castling; ++castling)
			{
				switch (*castling)
				{
					case 'K':
						rights |= castling::WhiteKingside;
						board.setCastleShort(color::White);
						break;

					case 'k':
						rights |= castling::BlackKingside;
						board.setCastleShort(color::Black);
						break;

					case 'Q':
						rights |= castling::WhiteQueenside;
						board.setCastleLong(color::White);
						break;

					case 'q':
						rights |= castling::BlackQueenside;
						board.setCastleLong(color::Black);
						break;
				}
			}

			for ( ; *fyles; ++fyles)
			{
				if ('A' <= *fyles && *fyles <= 'H')
					board.setCastlingFyle(color::White, sq::Fyle(sq::FyleA + *fyles - 'A'));
				else if ('a' <= *fyles && *fyles <= 'h')
					board.setCastlingFyle(color::Black, sq::Fyle(sq::FyleA + *fyles - 'a'));
			}

			error = ::validate(board);

			if (error == 0 && board.castlingRights() != castling::Rights(rights))
				error = "BadCastlingRights";

			board.setCastlingRights(castling::Rights(rights));
		}

		if (error == 0)
			error = ::validate(board);
	}

	Tcl_Obj* objs[8];

	if (error == 0 && board.isStartPosition() && !board.isShuffleChessPosition())
		error = "UnsupportedVariant";

	objs[0] = Tcl_NewStringObj(error ? error : "", -1);
	objs[1] = Tcl_NewIntObj(error ? 0 : board.computeIdn());
	objs[2] = Tcl_NewBooleanObj(board.notDerivableFromStandardChess());
	objs[3] = Tcl_NewBooleanObj(board.notDerivableFromChess960());
	objs[4] = Tcl_NewStringObj(toCastling(board), -1);
	objs[5] = Tcl_NewStringObj(sq::printAlgebraic(board.enPassantSquare()), -1);
	objs[6] = Tcl_NewStringObj(color::isWhite(board.sideToMove()) ? "w" : "b", -1);
	objs[7] = Tcl_NewIntObj(board.moveNumber());

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdMakeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* board		= stringFromObj(objc, objv, 1);
	char const* stm		= stringFromObj(objc, objv, 2);
	char const* ep			= stringFromObj(objc, objv, 3);
	char const* moveNo	= stringFromObj(objc, objv, 4);

	color::ID toMove = ::tolower(*stm) == 'w' ? color::White : color::Black;

	Board pos;
	pos.clear();

	if (::strlen(board) != 64)
		return error(CmdMakeFen, nullptr, nullptr, "invalid board: %s", board);

	for (unsigned i = 0; i < 64; ++i)
		pos.setAt(i, piece::pieceFromLetter(board[i]));

	pos.setToMove(toMove);
	pos.setMoveNumber(::strtoul(moveNo, nullptr, 10));

	char epFyle = ::tolower(*ep);

	if (epFyle >= 'a' && epFyle <= 'h')
		pos.setEnPassantFyle(sq::Fyle(sq::FyleA + epFyle - 'a'));

	setResult(pos.toFen());
	return TCL_OK;
}


static int
cmdIsValidFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// TODO: we need some flags: allowHandicap, allowIllegalPosition (king in check)
	setResult(Board::isValidFen(stringFromObj(objc, objv, 1), variant::Unknown));
	return TCL_OK;
}


static int
cmdPositionNumber(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(shuffle::lookup(stringFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdFenToBoard(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;
	board.setup(stringFromObj(objc, objv, 1));
	setResult(tcl::board::toBoard(board));
	return TCL_OK;
}


static int
cmdIdnToFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned idn = unsignedFromObj(objc, objv, 1);

	if (idn < 1 || 4*960 < idn)
		return error(CmdIdnToFen, nullptr, nullptr, "invalid IDN: %u", idn);

	Board board;
	board.setup(idn);
	mstl::string result;

	Tcl_Obj* objs[2];

	objs[0] = Tcl_NewStringObj(board.toFen(), -1);
	objs[1] = Tcl_NewStringObj(toCastling(board), -1);

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdTransposeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;
	board.setup(stringFromObj(objc, objv, 1));
	board.transpose();
	setResult(board.toFen());
	return TCL_OK;
}


static int
cmdNormalizeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;
	board.setup(stringFromObj(objc, objv, 1));
	setResult(board.toFen());
	return TCL_OK;
}


namespace tcl {
namespace board {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAnalyseFen,		cmdAnalyseFen);
	createCommand(ti, CmdFenToBoard,		cmdFenToBoard);
	createCommand(ti, CmdIdnToFen,			cmdIdnToFen);
	createCommand(ti, CmdIsValidFen,		cmdIsValidFen);
	createCommand(ti, CmdMakeFen,			cmdMakeFen);
	createCommand(ti, CmdNormalizeFen,	cmdNormalizeFen);
	createCommand(ti, CmdPositionNumber,	cmdPositionNumber);
	createCommand(ti, CmdTransposeFen,	cmdTransposeFen);
}

} // namespace board
} // namespace tcl

// vi:set ts=3 sw=3:
