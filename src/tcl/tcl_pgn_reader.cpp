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

#include "tcl_pgn_reader.h"

#include "tcl_progress.h"
#include "tcl_tree.h"
#include "tcl_log.h"
#include "tcl_base.h"

#include "sys_utf8_codec.h"

#include "m_istream.h"
#include "m_string.h"
#include "m_assert.h"

#include <tcl.h>


using namespace tcl;


PgnReader::PgnReader(mstl::istream& strm,
							db::variant::Type variant,
							mstl::string const& encoding,
							Tcl_Obj* cmd,
							Tcl_Obj* arg,
							Modification modification,
							ReadMode readMode,
							::db::permission::ReadMode permission,
							GameCount const* firstGameNumber,
							unsigned lineOffset,
							bool trialMode)
	:db::PgnReader(strm,
						variant,
						encoding.empty() ? sys::utf8::Codec::automatic() : encoding,
						readMode,
						firstGameNumber,
						modification,
						lineOffset ? InMoveSection : UseResultTag)
	,m_cmd(cmd)
	,m_arg(arg)
	,m_warning(Tcl_NewStringObj("warning", -1))
	,m_error(Tcl_NewStringObj("error", -1))
	,m_mode(readMode)
	,m_lineOffset(lineOffset)
	,m_countErrors(0)
	,m_countWarnings(0)
	,m_trialModeFlag(trialMode)
	,m_lastError(LastError)
{
	M_REQUIRE(cmd == 0 || arg != 0);
	M_REQUIRE(permission == ::db::permission::ReadOnly || readMode == File);

	if (permission == ::db::permission::ReadWrite)
		setup(&m_fileOffsets);

	Tcl_IncrRefCount(m_warning);
	Tcl_IncrRefCount(m_error);
}


PgnReader::~PgnReader() throw()
{
	Tcl_DecrRefCount(m_warning);
	Tcl_DecrRefCount(m_error);
}


unsigned PgnReader::countErrors() const				{ return m_countErrors; }
unsigned PgnReader::countWarnings() const				{ return m_countWarnings; }

PgnReader::Error PgnReader::lastErrorCode() const	{ return m_lastError; }
PgnReader::FileOffsets const& PgnReader::fileOffsets() const { return m_fileOffsets; }


void
PgnReader::warning(	Warning code,
							unsigned lineNo,
							unsigned column,
							unsigned gameNo,
							::db::variant::Type variant,
							mstl::string const& info,
							mstl::string const& item)
{
	char const* msg = 0;

	++m_countWarnings;

	if (m_trialModeFlag || m_cmd == 0)
		return;

	switch (code)
	{
		case MissingWhitePlayerTag:			msg = "MissingWhitePlayerTag"; break;
		case MissingBlackPlayerTag:			msg = "MissingBlackPlayerTag"; break;
		case MissingPlayerTags:					msg = "MissingPlayerTags"; break;
		case MissingResult:						msg = "MissingResult"; break;
		case MissingResultTag:					msg = "MissingResultTag"; break;
		case InvalidRoundTag:					msg = "InvalidRoundTag"; break;
		case InvalidResultTag:					msg = "InvalidResultTag"; break;
		case InvalidDateTag:						msg = "InvalidDateTag"; break;
		case InvalidEventDateTag:				msg = "InvalidEventDateTag"; break;
		case InvalidTimeModeTag:				msg = "InvalidTimeModeTag"; break;
		case InvalidEcoTag:						msg = "InvalidEcoTag"; break;
		case InvalidTagName:						msg = "InvalidTagName"; break;
		case InvalidCountryCode:				msg = "InvalidCountryCode"; break;
		case InvalidRating:						msg = "InvalidRating"; break;
		case InvalidNag:							msg = "InvalidNag"; break;
		case BraceSeenOutsideComment:			msg = "BraceSeenOutsideComment"; break;
		case MissingFen:							msg = "MissingFen"; break;
		case UnknownEventType:					msg = "UnknownEventType"; break;
		case UnknownTitle:						msg = "UnknownTitle"; break;
		case UnknownPlayerType:					msg = "UnknownPlayerType"; break;
		case UnknownSex:							msg = "UnknownSex"; break;
		case UnknownTermination:				msg = "UnknownTermination"; break;
		case UnknownMode:							msg = "UnknownMode"; break;
		case RatingTooHigh:						msg = "RatingTooHigh"; break;
		case EncodingFailed:						msg = "EncodingFailed"; break;
		case TooManyNags:							msg = "TooManyNags"; break;
		case IllegalCastling:					msg = "IllegalCastling"; break;
		case IllegalMove:							msg = "IllegalMove"; break;
		case CastlingCorrection:				msg = "CastlingCorrection"; break;
		case ResultDidNotMatchHeaderResult: msg = "ResultDidNotMatchHeaderResult"; break;
		case ValueTooLong:						msg = "ValueTooLong"; break;
		case NotSuicideNotGiveaway:			msg = "NotSuicideNotGiveaway"; break;
		case VariantChangedToGiveaway:		msg = "VariantChangedToGiveaway"; break;
		case VariantChangedToSuicide:			msg = "VariantChangedToSuicide"; break;
		case ResultCorrection:					msg = "ResultCorrection"; break;
		case MaximalErrorCountExceeded:		msg = "MaximalErrorCountExceeded"; break;
		case MaximalWarningCountExceeded:	msg = "MaximalWarningCountExceeded"; break;
	}

	if (lineNo >= m_lineOffset)
		lineNo -= m_lineOffset;

	if (lineNo == 0)
	{
		lineNo = 1;
		column = 0;
	}

	Tcl_Obj* objv[9];

	objv[0] = m_warning;
	objv[1] = Tcl_NewIntObj(lineNo);
	objv[2] = Tcl_NewIntObj(column);
	objv[3] = gameNo > 0 ? Tcl_NewIntObj(gameNo) : Tcl_NewStringObj("", 0);
	objv[4] = tree::variantToString(variant),
	objv[5] = Tcl_NewStringObj(mstl::string::empty_string, 0);
	objv[6] = Tcl_NewStringObj(msg, -1);
	objv[7] = Tcl_NewStringObj(info, info.size());
	objv[8] = Tcl_NewStringObj(item, item.size());

	invoke(__func__, m_cmd, m_arg, nullptr, U_NUMBER_OF(objv), objv);
}


void
PgnReader::error(	Error code,
						unsigned lineNo,
						unsigned column,
						unsigned gameNo,
						::db::variant::Type variant,
						mstl::string const& message,
						mstl::string const& info,
						mstl::string const& item)
{
	char const* msg = 0;

	if (m_trialModeFlag)
		m_lastError = code;

	++m_countErrors;

	if (m_cmd == 0)
		return;

	switch (code)
	{
		case InvalidToken:					msg = "InvalidToken"; break;
		case UnexpectedSymbol:				msg = "UnexpectedSymbol"; break;
		case UnexpectedEndOfInput:			msg = "UnexpectedEndOfInput"; break;
		case UnexpectedTag:					msg = "UnexpectedTag"; break;
		case UnexpectedEndOfGame:			msg = "UnexpectedEndOfGame"; break;
		case TagNameExpected:				msg = "TagNameExpected"; break;
		case TagValueExpected:				msg = "TagValueExpected"; break;
		case InvalidFen:						msg = "InvalidFen"; break;
		case UnterminatedString:			msg = "UnterminatedString"; break;
		case UnterminatedVariation:		msg = "UnterminatedVariation"; break;
		case InvalidMove:						msg = "InvalidMove"; break;
		case UnsupportedVariant:			msg = "UnsupportedVariant"; break;
		case TooManyGames:					msg = "TooManyGames"; break;
		case FileSizeExeeded:				msg = "FileSizeExeeded"; break;
		case GameTooLong:						msg = "GameTooLong"; break;
		case TooManyPlayerNames:			msg = "TooManyPlayerNames"; break;
		case TooManyEventNames:				msg = "TooManyEventNames"; break;
		case TooManySiteNames:				msg = "TooManySiteNames"; break;
		case TooManyAnnotatorNames:		msg = "TooManyAnnotatorNames"; break;
		case TooManySourceNames:			msg = "TooManySourceNames"; break;
		case SeemsNotToBePgnText:			msg = "SeemsNotToBePgnText"; break;
		case UnexpectedResultToken:		msg = "UnexpectedResultToken"; break;
		case UnexpectedCastling:			msg = "UnexpectedCastling"; break;
		case ContinuationsNotSupported:	msg = "ContinuationsNotSupported"; break;

		case TooManyRoundNames:
			if (m_tooManyRoundNames)
				return;
			m_tooManyRoundNames = true;
			msg = "TooManyRoundNames"; break;
			break;
	}

	if (lineNo >= m_lineOffset)
		lineNo -= m_lineOffset;

	if (lineNo == 0)
	{
		lineNo = 1;
		column = 0;
	}

	Tcl_Obj* objv[9];

	objv[0] = m_error;
	objv[1] = Tcl_NewIntObj(lineNo);
	objv[2] = Tcl_NewIntObj(column);
	objv[3] = gameNo > 0 ? Tcl_NewIntObj(gameNo) : Tcl_NewStringObj("", 0);
	objv[4] = tree::variantToString(variant),
	objv[5] = Tcl_NewStringObj(message, message.size());
	objv[6] = Tcl_NewStringObj(msg, -1);
	objv[7] = Tcl_NewStringObj(info, info.size());
	objv[8] = Tcl_NewStringObj(item, item.size());

	invoke(__func__, m_cmd, m_arg, nullptr, U_NUMBER_OF(objv), objv);
}


void
PgnReader::setResult(int n, int illegal) const
{
	setResult(n, illegal, accepted(), rejected(), &unsupportedVariants());
}


void
PgnReader::setResult(int n,
							int illegal,
							GameCount const& accepted,
							GameCount const& rejected,
							Variants const* unsupported)
{
	Tcl_Obj* objs[5];
	Tcl_Obj* acc[db::variant::NumberOfVariants];
	Tcl_Obj* rej[db::variant::NumberOfVariants];

	for (unsigned v = 0; v < db::variant::NumberOfVariants; ++v)
		acc[v] = Tcl_NewIntObj(accepted[v]);

	for (unsigned v = 0; v < db::variant::NumberOfVariants; ++v)
		rej[v] = Tcl_NewIntObj(rejected[v]);

	objs[0] = Tcl_NewIntObj(n);
	objs[1] = Tcl_NewIntObj(illegal);
	objs[2] = Tcl_NewListObj(db::variant::NumberOfVariants, acc);
	objs[3] = Tcl_NewListObj(db::variant::NumberOfVariants, rej);

	if (unsupported)
	{
		Tcl_Obj* uns[mstl::mul2(unsupported->size())];

		for (unsigned i = 0; i < unsupported->size(); ++i)
		{
			::tcl::PgnReader::Variants::value_type item = unsupported->container()[i];
			uns[mstl::mul2(i)] = Tcl_NewStringObj(item.first, item.first.size());
			uns[mstl::mul2(i) + 1] = Tcl_NewIntObj(item.second);
		}

		objs[4] = Tcl_NewListObj(mstl::mul2(unsupported->size()), uns);
	}
	else
	{
		objs[4] = Tcl_NewListObj(0, 0);
	}

	::tcl::setResult(U_NUMBER_OF(objs), objs);
}

// vi:set ts=3 sw=3:
