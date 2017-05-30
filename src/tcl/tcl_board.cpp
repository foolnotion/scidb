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
// Copyright: (C) 2010-2013 Gregor Cramer
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
#include "m_vector.h"
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
static char const* CmdNearest				= "::scidb::board::nearest";
static char const* CmdNormalizeFen		= "::scidb::board::normalizeFen";
static char const* CmdPositionNumber	= "::scidb::board::positionNumber";
static char const* CmdTransposeFen		= "::scidb::board::transposeFen";


namespace
{
	typedef mstl::vector<char const*> Warnings;
}


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
toError(db::Board::SetupStatus status)
{
	switch (status)
	{
		case Board::Valid:						return 0;
		case Board::EmptyBoard:					return "EmptyBoard";
		case Board::NoWhiteKing:				return "NoWhiteKing";
		case Board::NoBlackKing:				return "NoBlackKing";
		case Board::BothInCheck:				return "BothInCheck";
		case Board::OppositeCheck:				return "OppositeCheck";
		case Board::OppositeLosing:			return "OppositeLosing";
		case Board::TooManyWhitePawns:		return "TooManyWhitePawns";
		case Board::TooManyBlackPawns:		return "TooManyBlackPawns";
		case Board::TooManyWhitePieces:		return "TooManyWhitePieces";
		case Board::TooManyBlackPieces:		return "TooManyBlackPieces";
		case Board::PawnsOn18:					return "PawnsOn18";
		case Board::TooManyKings:				return "TooManyKings";
		case Board::TooManyWhite:				return "TooManyWhite";
		case Board::TooManyBlack:				return "TooManyBlack";
		case Board::BadCastlingRights:		return "BadCastlingRights";
		case Board::InvalidEnPassant:			return "InvalidEnPassant";
		case Board::MultiPawnCheck:			return "MultiPawnCheck";
		case Board::TripleCheck:				return "TripleCheck";
		case Board::InvalidCastlingRights:	return "InvalidCastlingRights";
		case Board::AmbiguousCastlingFyles:	return "AmbiguousCastlingFyles";
		case Board::TooManyPiecesInHolding:	return "TooManyPiecesInHolding";
		case Board::TooManyPromotedPieces:	return "TooManyPromotedPieces";
		case Board::TooFewPromotedPieces:	return "TooFewPromotedPieces";
		case Board::TooFewPiecesInHolding:	return "TooFewPiecesInHolding";
		case Board::IllegalCheckCount:		return "IllegalCheckCount";
	}

	return 0; // satisfies the compiler
}


static char const*
validate(Board const& board, variant::Type variant, Warnings& warnings)
{
	char const*					error	= 0;
	db::Board::SetupStatus status	= board.validate(variant, castling::DontAllowHandicap);

	if (status == Board::BadCastlingRights)
	{
		status = board.validate(variant, castling::AllowHandicap);

		if (status != Board::BadCastlingRights)
			warnings.push_back("CastlingWithoutRook");
	}

	error = ::toError(status);

	if (status == Board::TooFewPiecesInHolding)
	{
		warnings.push_back(error);
		error = 0;
	}

	return error;
}


Board::Format
getFormat(int objc, Tcl_Obj* const* objv, int index)
{
	if (index >= objc)
		return Board::XFen;

	char const* format = stringFromObj(objc, objv, index);
	return ::toupper(*format) == 'S' ? Board::Shredder : Board::XFen;
}


static int
cmdAnalyseFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* error		= 0;
	Warnings		warnings;

	Board board;
	char const* fen = stringFromObj(objc, objv, 1);
	variant::Type variant = Scidb->game().variant();
	variant::Type testVariant;

	// Do not test check counts, this will be handled separately.
	testVariant = objc > 2 && variant::isThreeCheck(variant) ? variant::Normal : variant;

	if (!board.setup(fen, testVariant))
	{
		error = "InvalidFen";
	}
	else
	{
		// TODO: strip zeroes from first part

		if (objc > 2)
		{
			unsigned			rights	= castling::NoRights;
			char const*		castling	= stringFromObj(objc, objv, 2);
			char const*		fyles		= stringFromObj(objc, objv, 3);
			char const*		checks	= stringFromObj(objc, objv, 4);

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

			if (variant::isThreeCheck(variant) && *checks)
			{
				int nchecks[2] = { -1, -1 };

				for ( ; *checks; ++checks)
				{
					if (::isdigit(*checks))
						nchecks[nchecks[0] == -1 ? 0 : 1] = *checks - '0';
				}

				M_ASSERT(nchecks[0] <= 3);
				M_ASSERT(nchecks[1] <= 3);

				board.setChecksGiven(nchecks[0], nchecks[1]);
			}

			error = ::validate(board, variant, warnings);

			if (error == 0 && board.castlingRights() != castling::Rights(rights))
				error = "BadCastlingRights";

			board.setCastlingRights(castling::Rights(rights));
		}

		if (!error)
		{
			warnings.clear();
			error = ::validate(board, variant, warnings);
		}
	}

	if (!error && board.isStartPosition() && !board.isShuffleChessPosition(variant))
		warnings.push_back("UnsupportedVariant");

	Tcl_Obj* checksGiven[2] =
	{
		Tcl_NewIntObj(variant::isThreeCheck(variant) ? board.checksGiven(color::White) : 0),
		Tcl_NewIntObj(variant::isThreeCheck(variant) ? board.checksGiven(color::Black) : 0),
	};

	Tcl_Obj* promoted[64];
	unsigned n = 0;

	for (unsigned i = 0; i < 64; ++i)
	{
		if (board.hasPromoted(sq::ID(i)))
			promoted[n++] = Tcl_NewIntObj(i);
	}

	Tcl_Obj* w[warnings.size()];
	for (unsigned i = 0; i < warnings.size(); ++i)
		w[i] = Tcl_NewStringObj(warnings[i], -1);

	Tcl_Obj* objs[12];

	objs[ 0] = Tcl_NewStringObj(error ? error : "", -1);
	objs[ 1] = Tcl_NewListObj(warnings.size(), w);
	objs[ 2] = Tcl_NewIntObj(error ? 0 : board.computeIdn(variant));
	objs[ 3] = Tcl_NewBooleanObj(board.notDerivableFromStandardChess());
	objs[ 4] = Tcl_NewBooleanObj(board.notDerivableFromChess960());
	objs[ 5] = Tcl_NewStringObj(toCastling(board), -1);
	objs[ 6] = Tcl_NewStringObj(sq::printAlgebraic(board.enPassantSquare()), -1);
	objs[ 7] = Tcl_NewStringObj(color::isWhite(board.sideToMove()) ? "w" : "b", -1);
	objs[ 8] = Tcl_NewIntObj(board.moveNumber());
	objs[ 9] = Tcl_NewIntObj(board.halfMoveClock());
	objs[10] = Tcl_NewListObj(2, checksGiven);
	objs[11] = Tcl_NewListObj(n, promoted);

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdMakeFen(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* board			= stringFromObj(objc, objv, 1);
	char const* stm			= stringFromObj(objc, objv, 2);
	char const* ep				= stringFromObj(objc, objv, 3);
	char const* moveNo		= stringFromObj(objc, objv, 4);
	char const* halfMoves	= stringFromObj(objc, objv, 5);
	unsigned		checksW		= unsignedFromObj(objc, objv, 6);
	unsigned		checksB		= unsignedFromObj(objc, objv, 7);
	char const*	holding		= stringFromObj(objc, objv, 8);
	Tcl_Obj*		promoted		= objectFromObj(objc, objv, 9);

	color::ID		toMove	= ::tolower(*stm) == 'w' ? color::White : color::Black;
	variant::Type	variant	= Scidb->game().variant();

	Board pos(Board::emptyBoard());

	if (::strlen(board) != 64)
		return error(CmdMakeFen, nullptr, nullptr, "invalid board: %s", board);

	for (unsigned i = 0; i < 64; ++i)
		pos.setAt(i, piece::pieceFromLetter(board[i]), variant);

	if (variant::isZhouse(variant))
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
	pos.setHalfMoveClock(::strtoul(halfMoves, nullptr, 10));

	if (variant == variant::ThreeCheck)
		pos.setChecksGiven(checksW, checksB);

	char epFyle = ::tolower(*ep);

	if (epFyle >= 'a' && epFyle <= 'h')
		pos.setEnPassantFyle(sq::Fyle(sq::FyleA + epFyle - 'a'));

	setResult(pos.toFen(variant, getFormat(objc, objv, 10)));
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
	unsigned			idn(unsignedFromObj(objc, objv, 1));
	variant::Type	variant(Scidb->game().variant());

	Board board;
	board.setup(idn, variant);
	mstl::string result;

	Tcl_Obj* objs[2];

	objs[0] = Tcl_NewStringObj(board.toFen(variant, getFormat(objc, objv, 2)), -1);
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

	if (objc > 3)
	{
		if (::strcmp(Tcl_GetString(objv[3]), "-clearholding") != 0)
			return error(CmdNormalizeFen, nullptr, nullptr, "invalid option '%s'", Tcl_GetString(objv[3]));

		board.clearHolding();
	}

	setResult(board.toFen(variant, getFormat(objc, objv, 2)));
	return TCL_OK;
}


static int
cmdNearest(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* board = stringFromObj(objc, objv, 1);
	char const* piece = stringFromObj(objc, objv, 2);

	if (::strlen(board) != 64)
		return error(CmdNearest, nullptr, nullptr, "invalid board: %s", board);

	Board pos(Board::emptyBoard());
	variant::Type variant(Scidb->game().variant());

	for (unsigned i = 0; i < 64; ++i)
		pos.setAt(i, piece::pieceFromLetter(board[i]), variant);
	
	Square sq = sq::Null;

	switch (*piece)
	{
		case 'K': sq = pos.shortCastlingRook(color::White); break;
		case 'k': sq = pos.shortCastlingRook(color::Black); break;
		case 'Q': sq = pos.longCastlingRook(color::White); break;
		case 'q': sq = pos.longCastlingRook(color::Black); break;

		default: return error(CmdNearest, nullptr, nullptr, "invalid piece: %c", *piece);
	}

	char result = *piece;

	if (sq != sq::Null)
	{
		if (::isupper(*piece))
			result = sq::printFYLE(sq::fyle(sq));
		else
			result = sq::printFyle(sq::fyle(sq));
	}

	setResult(mstl::string(1, result));
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
	createCommand(ti, CmdNearest,				cmdNearest);
	createCommand(ti, CmdNormalizeFen,		cmdNormalizeFen);
	createCommand(ti, CmdPositionNumber,	cmdPositionNumber);
	createCommand(ti, CmdTransposeFen,		cmdTransposeFen);
}

} // namespace board
} // namespace tcl

// vi:set ts=3 sw=3:
