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
#include "tcl_application.h"
#include "tcl_base.h"

#include "app_application.h"

#include "db_board.h"
#include "db_board_base.h"
#include "db_game.h"

#include "m_string.h"
#include "m_bit_functions.h"

#include <tcl.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace tcl;
using namespace tcl::app;
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


Board::Format
getFormat(int objc, Tcl_Obj* const* objv, int index)
{
	if (index >= objc)
		return Board::XFen;

	char const* format = stringFromObj(objc, objv, index);
	return ::toupper(*format) == 'S' ? Board::Shredder : Board::XFen;
}


static char const*
validate(Board const& board, variant::Type variant)
{
	char const* error = 0;

	switch (board.validate(variant, castling::DontAllowHandicap))
	{
		case Board::Valid: break;

		case Board::EmptyBoard:					error = "EmptyBoard"; break;
		case Board::NoWhiteKing:				error = "NoWhiteKing"; break;
		case Board::NoBlackKing:				error = "NoBlackKing"; break;
		case Board::BothInCheck:				error = "BothInCheck"; break;
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
		case Board::TooManyPiecesInHolding:	error = "TooManyPiecesInHolding"; break;
		case Board::TooFewPiecesInHolding:	error = "TooFewPiecesInHolding"; break;
		case Board::TooManyPromotedPieces:	error = "TooManyPromotedPieces"; break;
		case Board::TooFewPromotedPieces:	error = "TooFewPromotedPieces"; break;

		case Board::BadCastlingRights:
			if (board.validate(variant, castling::AllowHandicap) == Board::Valid)
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
	char const* fen = stringFromObj(objc, objv, 1);
	variant::Type variant = Scidb->game().variant();

	// TODO: strip zeroes from first part

	if (!board.setup(fen, variant))
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

			error = ::validate(board, variant);

			if (error == 0 && board.castlingRights() != castling::Rights(rights))
				error = "BadCastlingRights";

			board.setCastlingRights(castling::Rights(rights));
		}

		if (error == 0)
			error = ::validate(board, variant);
	}

	Tcl_Obj* objs[10];

	if (error == 0 && board.isStartPosition() && !board.isShuffleChessPosition())
		error = "UnsupportedVariant";

	Tcl_Obj* checksGiven[2] =
	{
		Tcl_NewIntObj(board.checksGiven(color::White)),
		Tcl_NewIntObj(board.checksGiven(color::Black)),
	};

	Tcl_Obj* promoted[64];
	unsigned n = 0;

	for (unsigned i = 0; i < 64; ++i)
	{
		if (board.hasPromoted(sq::ID(i)))
			promoted[n++] = Tcl_NewIntObj(i);
	}

	objs[0] = Tcl_NewStringObj(error ? error : "", -1);
	objs[1] = Tcl_NewIntObj(error ? 0 : board.computeIdn());
	objs[2] = Tcl_NewBooleanObj(board.notDerivableFromStandardChess());
	objs[3] = Tcl_NewBooleanObj(board.notDerivableFromChess960());
	objs[4] = Tcl_NewStringObj(toCastling(board), -1);
	objs[5] = Tcl_NewStringObj(sq::printAlgebraic(board.enPassantSquare()), -1);
	objs[6] = Tcl_NewStringObj(color::isWhite(board.sideToMove()) ? "w" : "b", -1);
	objs[7] = Tcl_NewIntObj(board.moveNumber());
	objs[8] = Tcl_NewListObj(2, checksGiven);
	objs[9] = Tcl_NewListObj(n, promoted);

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
	unsigned		checksW	= unsignedFromObj(objc, objv, 5);
	unsigned		checksB	= unsignedFromObj(objc, objv, 6);
	char const*	holding	= stringFromObj(objc, objv, 7);
	Tcl_Obj*		promoted	= objectFromObj(objc, objv, 8);

	color::ID		toMove	= ::tolower(*stm) == 'w' ? color::White : color::Black;
	variant::Type	variant	= Scidb->game().variant();

	Board pos;
	pos.clear();

	if (::strlen(board) != 64)
		return error(CmdMakeFen, nullptr, nullptr, "invalid board: %s", board);

	for (unsigned i = 0; i < 64; ++i)
		pos.setAt(i, piece::pieceFromLetter(board[i]), variant);

	pos.setHolding(holding);

	Tcl_Obj** squares;
	int nsquares;

	if (Tcl_ListObjGetElements(ti, promoted, &nsquares, &squares) != TCL_OK)
		return error(CmdMakeFen, nullptr, nullptr, "list of squares expected");

	for (unsigned i = 0; i < unsigned(nsquares); ++i)
	{
		sq::ID sq = sq::ID(unsignedFromObj(nsquares, squares, i));

		switch (int(pos.piece(sq)))
		{
			case piece::Queen: case piece::Rook: case piece::Bishop: case piece::Knight:
				pos.setPromoted(sq, variant);
				break;
		}
	}

	pos.setToMove(toMove);
	pos.setMoveNumber(::strtoul(moveNo, nullptr, 10));
	pos.setChecksGiven(checksW, checksB);

	char epFyle = ::tolower(*ep);

	if (epFyle >= 'a' && epFyle <= 'h')
		pos.setEnPassantFyle(sq::Fyle(sq::FyleA + epFyle - 'a'));

	setResult(pos.toFen(variant, getFormat(objc, objv, 8)));
	return TCL_OK;
}


static int
cmdIsValidFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	// TODO: we need some flags: allowHandicap, allowIllegalPosition (king in check)
	setResult(Board::isValidFen(stringFromObj(objc, objv, 1), Scidb->game().variant()));
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
	board.setup(stringFromObj(objc, objv, 1), Scidb->game().variant());
	setResult(tcl::board::toBoard(board));
	return TCL_OK;
}


static int
cmdIdnToFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	unsigned idn = unsignedFromObj(objc, objv, 1);

	Board board;
	board.setup(idn);
	mstl::string result;

	Tcl_Obj* objs[2];

	objs[0] = Tcl_NewStringObj(board.toFen(Scidb->game().variant(), getFormat(objc, objv, 2)), -1);
	objs[1] = Tcl_NewStringObj(toCastling(board), -1);

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdTransposeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;
	variant::Type variant = Scidb->game().variant();

	board.setup(stringFromObj(objc, objv, 1), variant);
	board.transpose(variant);
	setResult(board.toFen(variant, getFormat(objc, objv, 2)));
	return TCL_OK;
}


static int
cmdNormalizeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Board board;
	variant::Type variant = Scidb->game().variant();
	char const* fen = stringFromObj(objc, objv, 1);

	board.setup(fen, variant);
	setResult(board.toFen(variant, getFormat(objc, objv, 2)));

	return TCL_OK;
}


namespace tcl {
namespace board {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdAnalyseFen,			cmdAnalyseFen);
	createCommand(ti, CmdFenToBoard,			cmdFenToBoard);
	createCommand(ti, CmdIdnToFen,			cmdIdnToFen);
	createCommand(ti, CmdIsValidFen,			cmdIsValidFen);
	createCommand(ti, CmdMakeFen,				cmdMakeFen);
	createCommand(ti, CmdNormalizeFen,		cmdNormalizeFen);
	createCommand(ti, CmdPositionNumber,	cmdPositionNumber);
	createCommand(ti, CmdTransposeFen,		cmdTransposeFen);
}

} // namespace board
} // namespace tcl

// vi:set ts=3 sw=3:
