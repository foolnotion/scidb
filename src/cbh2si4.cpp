// ======================================================================
// $RCSfile: tk_image.cpp,v $
// $Revision$
// $Date$
// $Author: gregor $
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_eco_table.h"
#include "db_database.h"
#include "db_log.h"

#include "si3/si3_consumer.h"
#include "si3/si3_codec.h"

#include "u_progress.h"

#include "sys_utf8_codec.h"

#include "tcl_base.h"

#include "m_ifstream.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <tcl.h>

using namespace db;


static unsigned rejected = 0;


struct Progress : public util::Progress
{
	void update(unsigned progress)
	{
		::printf(".");
		::fflush(stdout);
	}

	void finish() { }
};


struct Log : public db::Log
{
	bool error(save::State code, unsigned gameNumber)
	{
		char const* msg = 0;

		switch (code)
		{
			case save::Ok:								return true;
			case save::UnsupportedVariant:		++rejected; return true;
			case save::DecodingFailed:				++rejected; return true;
			case save::GameTooLong:					msg = "Game too long"; break;
			case save::FileSizeExeeded:			msg = "File size exeeded"; break;
			case save::TooManyGames:				msg = "Too many games"; break;
			case save::TooManyPlayerNames:		msg = "Too many player names"; break;
			case save::TooManyEventNames:			msg = "Too many event names"; break;
			case save::TooManySiteNames:			msg = "Too many site names"; break;
			case save::TooManyRoundNames:			msg = "Too many round names"; break;
			case save::TooManyAnnotatorNames:	msg = "Too many annotator names"; break;
		}

		::fprintf(	stderr,
						"%s: %s (#%u)\n",
						code == db::save::GameTooLong ? "Warning" : "Error",
						msg,
						gameNumber);

		return code == save::GameTooLong;
	}
};


static void
loadEcoFile()
{
	mstl::string path(SHAREDIR "/data/eco.bin");
	mstl::ifstream stream(path, mstl::ios_base::in | mstl::ios_base::binary);

	if (!stream)
	{
		::fprintf(stderr, "cannot open ECO file '%s'", path.c_str());
		::exit(1);
	}

	EcoTable::specimen().load(stream);
}


static void
printHelpAndExit(int rc)
{
	::printf("Usage: cbh2si4 [options ...] <ChessBase database> [destination database]\n");
	::printf("\n");
	::printf("Options:\n");
	::printf("  --            Only file names after this\n");
	::printf("  --help        Print Help (this message) and exit\n");
	::printf("  --force       overwrite existing destination files\n");
	::printf("  --encoding <encoding>\n");
	::printf("                Use this encoding for output database\n");
	::printf("                (default is iso8859-1)\n");
	::printf("  --encoded <encoding>\n");
	::printf("                The encoding of the ChessBase database\n");
	::printf("                (default is cp1252)\n");
	::printf("  --list-encodings\n");
	::printf("                List all known encodings\n");
	::printf("\n");
	::exit(rc);
}


static void
printEncodingsAndExit(int rc)
{
	sys::utf8::Codec::EncodingList encodings;
	unsigned n = sys::utf8::Codec::getEncodingList(encodings);

	printf("Existing encodings: ");

	for (unsigned i = 0; i < n; ++i)
	{
		::printf(encodings[i].c_str());
		if (i + 1 < n)
			::printf(", ");
	}

	::printf("\n");
	::exit(rc);
}


static unsigned
exportGames(Database& src, Consumer& dst, Progress& progress)
{
	unsigned numGames		= src.countGames();

	util::ProgressWatcher watcher(progress, numGames);
	progress.setFrequency(mstl::min(5000u, mstl::max(numGames/100, 1u)));

	unsigned reportAfter	= progress.frequency();
	unsigned count			= 0;
	unsigned countGames	= 0;

	::Log log;

	for (unsigned i = 0; i < numGames; ++i)
	{
		if (reportAfter == count++)
		{
			progress.update(count);
			reportAfter += progress.frequency();
		}

		save::State state = src.exportGame(i, dst);

		if (state == save::Ok)
			++countGames;
		else if (!log.error(state, i))
			return countGames;
	}

	return countGames;
}


int
main(int argc, char* argv[])
{
	::tcl::bits::interp = Tcl_CreateInterp();

	mstl::string	encoding("iso8859-1");
	mstl::string	encoded("cp1252");
	bool				force(false);

	int i = 1;

	for ( ; i < argc && argv[i][0] == '-'; ++i)
	{
		if (::strcmp(argv[i], "--") == 0)
			break;

		if (::strcmp(argv[i], "--help") == 0)
		{
			printHelpAndExit(0);
		}
		else if (::strcmp(argv[i], "--encoding") == 0)
		{
			if (++i == argc)
				printHelpAndExit(1);
			encoding.assign(argv[i]);

		}
		else if (::strcmp(argv[i], "--encoded") == 0)
		{
			if (++i == argc)
				printHelpAndExit(1);
			encoded.assign(argv[i]);
		}
		else if (::strcmp(argv[i], "--list-encodings") == 0)
		{
			printEncodingsAndExit(0);
		}
		else if (::strcmp(argv[i], "--force") == 0)
		{
			force = true;
		}
		else
		{
			::fprintf(stderr, "Unrecognized option '%s'.\n\n", argv[i]);
			printHelpAndExit(1);
		}
	}

	if (!sys::utf8::Codec::checkEncoding(encoding))
	{
		::fprintf(stderr, "Unknown encoding '%s'.\n\n", encoding.c_str());
		printEncodingsAndExit(1);
	}

	if (!sys::utf8::Codec::checkEncoding(encoded))
	{
		::fprintf(stderr, "Unknown encoding '%s'.\n\n", encoded.c_str());
		printEncodingsAndExit(1);
	}

	if (i == argc)
	{
		::fprintf(stderr, "No input database specified.\n\n");
		printHelpAndExit(1);
	}

	mstl::string cbhPath(argv[i++]);

	if (cbhPath.size() < 4 || ::strcmp(cbhPath.c_str() + cbhPath.size() - 4, ".cbh") != 0)
		cbhPath.append(".cbh");

	mstl::ifstream	stream(cbhPath);

	if (!stream)
	{
		::fprintf(stderr, "Cannot open file '%s'.\n", cbhPath.c_str());
		::exit(1);
	}

	mstl::string si4Path;

	if (i < argc)
	{
		si4Path.append(argv[i]);
	}
	else
	{
		si4Path.append(cbhPath);
		if (si4Path.size() >= 4 && ::strcmp(si4Path.c_str() + si4Path.size() - 4, ".cbh") == 0)
			si4Path.erase(si4Path.size() - 4);
	}

	if (si4Path.size() < 4 || ::strcmp(si4Path.c_str() + si4Path.size() - 4, ".si4") != 0)
		si4Path.append(".si4");
	
	if (!force && ::access(si4Path.c_str(), R_OK) == 0)
	{
		::fprintf(stderr, "Database '%s' already exists.\n", si4Path.c_str());
		::exit(1);
	}

	try
	{
		loadEcoFile();

		Progress	progress;

		Database	src(cbhPath, encoded, Database::ReadOnly, progress);
		Database	dst(si4Path, encoding, Database::OnDisk);
		si3::Consumer consumer(format::Scid4, dynamic_cast<si3::Codec&>(dst.codec()), encoding);

		dst.setType(src.type());
		unsigned numGames = exportGames(src, consumer, progress);
		dst.save(progress);
		::printf("\n%u game(s) written.\n", numGames);
		if (rejected > 0)
			::printf("%u game(s) rejected.\n", rejected);
		::fflush(stdout);
		dst.close();
		src.close();
	}
	catch (mstl::exception const& exc)
	{
		fflush(stdout);
		fprintf(stderr, "\n%s\n", exc.what());
		exit(1);
	}

	return 0;
}

// vi:set ts=3 sw=3:
