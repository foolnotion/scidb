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

#include "tcl_base.h"

#include "db_pgn_reader.h"
#include "db_pgn_writer.h"
#include "db_eco_table.h"

#include "u_zstream.h"
#include "u_progress.h"

#include "sys_utf8_codec.h"

#include "m_exception.h"
#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_sstream.h"

#include <stdio.h>
#include <stdlib.h>
#include <tcl.h>

using namespace db;
using namespace util;


static bool				g_error	= false;
static int				g_argc	= 0;
static char const**	g_argv	= 0;

static unsigned const g_Flags = Writer::Flag_Include_Variations
										| Writer::Flag_Include_Comments
										| Writer::Flag_Include_Annotation
										| Writer::Flag_Include_Marks
										| Writer::Flag_Include_Ply_Count_Tag
										| Writer::Flag_Include_Termination_Tag
										| Writer::Flag_Include_Mode_Tag
										| Writer::Flag_Include_Setup_Tag
										| Writer::Flag_Include_Variant_Tag
										| Writer::Flag_Include_Time_Mode_Tag
										| Writer::Flag_Exclude_Extra_Tags
										| Writer::Flag_Symbolic_Annotation_Style;

namespace {

typedef sys::utf8::Codec Codec;

struct MyReader : public PgnReader
{
	MyReader(mstl::istream& stream, Codec& codec);

	void warning(	Warning code,
						unsigned lineNo,
						unsigned column,
						unsigned gameNo,
						mstl::string const& info,
						mstl::string const& item);
	void error(		Error code,
						unsigned lineNo,
						unsigned column,
						int gameNo,
						mstl::string const& message,
						mstl::string const& info,
						mstl::string const& item);
};


MyReader::MyReader(mstl::istream& stream, Codec& codec) :PgnReader(stream, codec) {}


void
MyReader::warning(Warning code,
						unsigned lineNo,
						unsigned column,
						unsigned gameNo,
						mstl::string const& info,
						mstl::string const& item)
{
	char const* msg = 0;

	switch (code)
	{
		case MissingWhitePlayerTag:			msg = "Missing White Player Tag"; break;
		case MissingBlackPlayerTag:			msg = "Missing Black Player Tag"; break;
		case MissingPlayerTags:					msg = "Missing Player Tags"; break;
		case MissingResult:						msg = "Missing Result"; break;
		case MissingResultTag:					msg = "Missing Result Tag"; break;
		case InvalidResultTag:					msg = "Invalid Result Tag"; break;
		case InvalidDateTag:						msg = "Invalid Date Tag"; break;
		case InvalidEventDateTag:				msg = "Invalid Event Date Tag"; break;
		case InvalidTimeModeTag:				msg = "Invalid Time Mode Tag"; break;
		case InvalidEcoTag:						msg = "Invalid Eco Tag"; break;
		case InvalidTagName:						msg = "Invalid Tag Name"; break;
		case InvalidCountryCode:				msg = "Invalid Country Code"; break;
		case InvalidRating:						msg = "Invalid Rating"; break;
		case InvalidNag:							msg = "Invalid Nag"; break;
		case UnknownEventType:					msg = "Unknown Event Type"; break;
		case UnknownTitle:						msg = "Unknown Title"; break;
		case UnknownPlayerType:					msg = "Unknown Player Type"; break;
		case UnknownTermination:				msg = "Unknown Termination"; break;
		case UnknownMode:							msg = "Unknown Mode"; break;
		case RatingTooHigh:						msg = "Rating Too High"; break;
		case EncodingFailed:						msg = "Encoding Failed"; break;
		case TooManyNags:							msg = "Too Many Nags"; break;
		case IllegalCastling:					msg = "Illegal Castling"; break;
		case ResultDidNotMatchHeaderResult: msg = "Result Did Not Match Header Result"; break;
		case MaximalErrorCountExeeded:		msg = "Maximal Error Count Exeeded"; break;
		case MaximalWarningCountExeeded:		msg = "Maximal Warning Count Exeeded"; break;
	}

	fprintf(stderr, "Warning (#%u,%u,%u): %s (%s)\n", gameNo, lineNo, column, msg, item.c_str());
}


void
MyReader::error(	Error code,
						unsigned lineNo,
						unsigned column,
						int gameNo,
						mstl::string const& message,
						mstl::string const& info,
						mstl::string const& item)
{
	if (g_error)
		return;

	char const* msg = 0;

	switch (code)
	{
		case InvalidToken:				msg = "Invalid Token"; break;
		case UnexpectedSymbol:			msg = "Unexpected Symbol"; break;
		case UnexpectedEndOfInput:		msg = "Unexpected End Of Input"; break;
		case UnexpectedTag:				msg = "Unexpected Tag"; break;
		case UnexpectedEndOfGame:		msg = "Unexpected End Of Game"; break;
		case TagNameExpected:			msg = "Tag Name Expected"; break;
		case TagValueExpected:			msg = "Tag Value Expected"; break;
		case InvalidFen:					msg = "Invalid Fen"; break;
		case UnterminatedString:		msg = "Unterminated String"; break;
		case UnterminatedVariation:	msg = "Unterminated Variation"; break;
		case IllegalMove:					msg = "Illegal Move"; break;
		case UnsupportedVariant:		msg = "Unsupported Variant"; break;
		case TooManyGames:				msg = "Too Many Games"; break;
		case FileSizeExeeded:			msg = "File Size Exeeded"; break;
		case GameTooLong:					msg = "Game Too Long"; break;
		case TooManyPlayerNames:		msg = "Too Many Player Names"; break;
		case TooManyEventNames:			msg = "Too Many Event Names"; break;
		case TooManySiteNames:			msg = "Too Many Site Names"; break;
		case TooManyRoundNames:			msg = "Too Many Round Names"; break;
		case TooManyAnnotatorNames:	msg = "Too Many Annotator Names"; break;
		case TooManySourceNames:		msg = "Too Many Source Names"; break;
		case SeemsNotToBePgnText:		msg = "Seems Not To Be Pgn Text"; break;
	}

	fprintf(	stderr,
				"Error (#%u,%u,%u): %s (%s)\n",
				gameNo, lineNo, column,
				msg, item.c_str());
	g_error = true;
}


struct MyWriter : public PgnWriter
{
	MyWriter();

	void start();
	void finish();

	bool beginGame(TagSet const& tags);
	save::State endGame(TagSet const& tags);

	mstl::ostringstream m_stream;
};


MyWriter::MyWriter() :PgnWriter(m_stream, Codec::latin1(), g_Flags) {}

void MyWriter::start() {}
void MyWriter::finish() {}


bool
MyWriter::beginGame(TagSet const& tags)
{
	g_error = false;
	m_stream.str(mstl::string::empty_string);

	return PgnWriter::beginGame(tags);
}


save::State
MyWriter::endGame(TagSet const& tags)
{
	if (g_error)
		return save::Ok;
	
	save::State rc = PgnWriter::endGame(tags);

	Eco eco = EcoTable::specimen().getEco(openingLine());
	mstl::ofstream stream(eco.asShortString() + ".pgn", mstl::ios_base::out | mstl::ios_base::app);

	if (!stream.write(m_stream.str()))
		M_RAISE("write failed");
	
	return rc;
}

} // namespace


static int
init(Tcl_Interp* ti)
{
	try
	{
		if (g_argc < 3)
			M_RAISE("Usage: <eco-file> <pgn-file> ...");

		ZStream::setZipFileSuffixes(ZStream::Strings(1, "pgn"));

		if (Tcl_Init(ti) == TCL_ERROR)
			M_RAISE("Tcl_Init() failed");

		tcl::init(ti);

		{
			mstl::ifstream stream(g_argv[1], mstl::ios_base::in | mstl::ios_base::binary);
			if (!stream)
				M_RAISE("cannot open ECO file %s", g_argv[1]);
			EcoTable::specimen().load(stream);
		}

		Codec			codec(Codec::latin1());
		MyWriter		writer;
		Progress		progress;

		for (int i = 2; i < g_argc; ++i)
		{
			ZStream	stream(g_argv[i]);
			MyReader	reader(stream, codec);

			if (!stream)
				M_RAISE("cannot open file '%s'", g_argv[i]);

			printf("parsing %s\n", g_argv[i]);

			codec.reset();
			reader.setConsumer(&writer);
			reader.process(progress);
		}
	}
	catch (mstl::exception const& exc)
	{
		fflush(stdout);
		fprintf(stderr, "\n%s\n", exc.what());
		exit(1);
	}

	exit(0);
	return 0;
}


int
main(int argc, char const* argv[])
{
	g_argc = argc;
	g_argv = argv;
	Tcl_Main(argc, const_cast<char**>(argv), init);
	return 0;
}

// vi:set ts=3 sw=3:
