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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_eco_table.h"
#include "db_database.h"
#include "db_pgn_reader.h"
#include "db_log.h"

#include "sci/sci_consumer.h"
#include "sci/sci_encoder.h"
#include "sci/sci_codec.h"

#include "u_progress.h"

#include "sys_utf8_codec.h"

#include "tcl_base.h"

#include "m_ifstream.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <tcl.h>

//#ifndef BROKEN_LINKER_HACK
//# define BROKEN_LINKER_HACK
//#endif

#ifdef BROKEN_LINKER_HACK
# include "db_board.h"
# include "db_board_base.h"
# include "db_home_pawns.h"
# include "db_signature.h"
# include "sci_encoder.h"
# include "si3_encoder.h"
#endif

using namespace db;


static unsigned rejected = 0;


namespace tcl { namespace bits { Tcl_Interp* interp; } }


struct TclInterpreter
{
	TclInterpreter()	{ tcl::bits::interp = Tcl_CreateInterp(); }
	~TclInterpreter()	{ Tcl_DeleteInterp(tcl::bits::interp); }
};


struct Progress : public util::Progress
{
	void update(unsigned progress) override
	{
		::printf(".");
		::fflush(stdout);
	}

	void finish() throw() override {}
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
			case save::GameTooLong:					msg = "Game too long"; break; // should not happen
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

	void warning(Warning code, unsigned gameNumber) {}
};


typedef sci::Consumer::TagBits TagBits;

static char const* ConvertFrom = "auto";


static TagBits
getDefaultTags()
{
	TagBits defaultTags;

	defaultTags.set(tag::Board);
	defaultTags.set(tag::EventCategory);
	defaultTags.set(tag::EventRounds);
	defaultTags.set(tag::Remark);
	defaultTags.set(tag::Source);
	defaultTags.set(tag::SourceDate);
	defaultTags.set(tag::TimeControl);
	defaultTags.set(tag::WhiteClock);
	defaultTags.set(tag::BlackClock);
	defaultTags.set(tag::WhiteTeam);
	defaultTags.set(tag::BlackTeam);

	return defaultTags;
}


static format::Type
getFormat(mstl::string& path)
{
	format::Type fmt = format::Invalid;

	if (path.size() >= 7 && strcmp(path.c_str() + path.size() - 7, ".pgn.gz") == 0)
	{
		fmt = format::Pgn;
	}
	else if (path.size() >= 4)
	{
		char const* s = path.c_str() + path.size() - 4;

		if			(strcmp(s, ".si4") == 0) fmt = format::Scid4;
		else if	(strcmp(s, ".si3") == 0) fmt = format::Scid3;
		else if	(strcmp(s, ".sci") == 0) fmt = format::Scidb;
		else if	(strcmp(s, ".cbh") == 0) fmt = format::ChessBase;
		else if	(strcmp(s, ".cbf") == 0) fmt = format::ChessBaseDOS;
		else if	(strcmp(s, ".CBF") == 0) fmt = format::ChessBaseDOS;
		else if	(strcmp(s, ".pgn") == 0) fmt = format::Pgn;
		else if	(strcmp(s, ".PGN") == 0) fmt = format::Pgn;
		else if	(strcmp(s, ".zip") == 0) fmt = format::Pgn;
		else if	(strcmp(s, ".ZIP") == 0) fmt = format::Pgn;
	}

	return fmt;
}


static void
stripSuffix(mstl::string& path)
{
	if (path.size() >= 7 && strcmp(path.c_str() + path.size() - 7, ".pgn.gz") == 0)
	{
		path.erase(path.size() - 7);
	}
	else if (path.size() >= 4)
	{
		char const* s = path.c_str() + path.size() - 4;

		if (	strcmp(s, ".si4") == 0
			|| strcmp(s, ".si3") == 0
			|| strcmp(s, ".sci") == 0
			|| strcmp(s, ".cbh") == 0
			|| strcmp(s, ".cbf") == 0
			|| strcmp(s, ".CBF") == 0
			|| strcmp(s, ".pgn") == 0
			|| strcmp(s, ".PGN") == 0
			|| strcmp(s, ".zip") == 0
			|| strcmp(s, ".ZIP") == 0)
		{
			path.erase(path.size() - 4);
		}
	}
}


static void
loadEcoFile()
{
	mstl::string path(SHAREDIR "/data/eco.bin");
	mstl::ifstream stream(path, mstl::ios_base::in | mstl::ios_base::binary);

	if (!stream)
	{
		fprintf(stderr, "cannot open ECO file '%s'", path.c_str());
		exit(1);
	}

	EcoTable::specimen(variant::Normal).load(stream, variant::Normal);
}


static void
printHelpAndExit(int rc)
{
	printf("Usage: cdb2sci [options ...] <source database> [destination database]\n");
	printf("\n");
	printf("Options:\n");
	printf("  --              Only file names after this\n");
	printf("  --help          Print Help (this message) and exit\n");
	printf("  --force         Overwrite existing destination files\n");
	printf("  --convertfrom <encoding>\n");
	printf("                  The encoding of the source database\n");
	printf("                  (default is %s)\n", ::ConvertFrom);
	printf("  --tags <comma-separated-tag-list>\n");
	printf("                  Export only the tags given with this list\n");
	printf("                  (but mandatory tags are always exported)\n");
	printf("  --unusual-tags  Export unusual tags (otherwise ignore these tags)\n");
	printf("  --all-tags      Export all tags (overrules option --tags)\n");
	printf("                  (but ignore unusual tags except --unusual-tags is given)\n");
	printf("  --no-tags       Do not export any tag (except mandatory tags)\n");
	printf("                  (overrules --tags, --all-tags, but not --unusual-tags)\n");
	printf("  --list-encodings\n");
	printf("                  List all known encodings\n");
	printf("  --list-mandatory-tags\n");
	printf("                  List all mandatory tags\n");
	printf("  --list-default-tags\n");
	printf("                  List all default tags\n");
	printf("  --list-usual-tags\n");
	printf("                  List all usual tags (includes mandatory tags)\n");
	printf("\n");
	exit(rc);
}


static bool
isForbiddenEncoding(mstl::string const& encoding)
{
	return	encoding == "identity"
			|| encoding == "dingbats"
			|| encoding == "ebcdic"
			|| encoding == "symbol"
			|| encoding == "unicode";
}


static void
printEncodingsAndExit(int rc)
{
	sys::utf8::Codec::EncodingList encodings;
	sys::utf8::Codec::getEncodingList(encodings);

	sys::utf8::Codec::EncodingList::const_iterator i = encodings.begin();
	sys::utf8::Codec::EncodingList::const_iterator e = encodings.end();

	while (i != e)
	{
		sys::utf8::Codec::EncodingList::const_iterator next = i + 1;

		if (!isForbiddenEncoding(*i))
		{
			printf(i->c_str());

			if (next != e)
				printf(", ");
		}

		i = next;
	}

	printf("\n");
	exit(rc);
}


static void
checkEncoding(mstl::string const& encoding)
{
	if (isForbiddenEncoding(encoding))
	{
		fprintf(stderr, "Encoding '%s' is not allowed\n", encoding.c_str());
		exit(1);
	}

	sys::utf8::Codec::EncodingList encodings;
	sys::utf8::Codec::getEncodingList(encodings);

	sys::utf8::Codec::EncodingList::const_iterator i = encodings.begin();
	sys::utf8::Codec::EncodingList::const_iterator e = encodings.end();

	for ( ; i != e; ++i)
	{
		if (*i == encoding)
			return;
	}

	fprintf(stderr, "Unknown encoding '%s'\n", encoding.c_str());
	exit(1);
}


static void
printDefaultTagsAndExit(int rc)
{
	char const* comma = "";
	TagBits defaultTags = getDefaultTags();

	for (unsigned i = 0; i < 64; ++i)
	{
		if (defaultTags.test(i))
		{
			printf("%s%s", comma, tag::toName(tag::ID(i)).c_str());
			comma = ",";
		}
	}

	printf("\n");
	exit(rc);
}


static void
printUsualTagsAndExit(int rc)
{
	for (unsigned i = 0; i < tag::BughouseTag; ++i)
	{
		if (i > 0)
			printf(",");
		printf("%s", tag::toName(tag::ID(i)).c_str());
	}

	printf("\n");
	exit(rc);
}


static void
printMandatoryTagsAndExit(int rc)
{
	mstl::string	tagList;
	tag::TagSet		mandatoryTags(sci::Encoder::infoTags());

	for (unsigned i = mandatoryTags.find_first(); i != tag::TagSet::npos; i = mandatoryTags.find_next(i))
	{
		if (!tagList.empty())
			tagList += ',';
		tagList += tag::toName(tag::ID(i));
	}

	printf("%s\n", tagList.c_str());
	::exit(rc);
}


static void
checkTagList(mstl::string& tagList)
{
	char* s = tagList.data();
	char* e = s;

	while (true)
	{
		while (*e && *e != ',')
			++e;

		if (!PgnReader::validateTagName(s, e - s))
		{
			fprintf(stderr, "Invalid tag name '%s'.\n", mstl::string(s, e).c_str());
			exit(1);
		}

		if (tag::fromName(s, e - s) == tag::ExtraTag)
		{
			fprintf(stderr, "'%s' is an unusual tag and cannot be included.\n", mstl::string(s, e).c_str());
			fprintf(stderr, "Probably you might use option --unusual-tags.\n");
			exit(1);
		}

		if (*e == '\0')
			return;

		s = ++e;
	}
}


static void
setTagList(TagBits& result, mstl::string const& tagList)
{
	char const* s = tagList;
	char const* e = s;

	while (true)
	{
		while (*e && *e != ',')
			++e;

		result.set(tag::fromName(s, e - s));

		if (*e == '\0')
			return;

		s = ++e;
	}
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
#ifdef BROKEN_LINKER_HACK

		// HACK!
		// This hack is required for insane systems like Debian Wheezy,
		// and Ubuntu Oneiric. The static object initialization is not
		// properly working on these systems (among other problems).
		db::tag::initialize();
		db::castling::initialize();
		db::board::base::initialize();
		db::Board::initialize();
		db::HomePawns::initialize();
		db::Signature::initialize();
		db::sci::Encoder::initialize();
		db::si3::Encoder::initialize();

#endif

	TclInterpreter	tclInterpreter;
	mstl::string	convertfrom(::ConvertFrom);
	bool				force(false);
	bool				allTags(false);
	bool				noTags(false);
	bool				defaultTags(true);
	bool				extraTags(false);
	mstl::string	givenTags;

	int i = 1;

	for ( ; i < argc && argv[i][0] == '-'; ++i)
	{
		if (strcmp(argv[i], "--") == 0)
			break;

		if (strcmp(argv[i], "--help") == 0)
		{
			printHelpAndExit(0);
		}
		else if (strcmp(argv[i], "--convertfrom") == 0)
		{
			if (++i == argc)
				printHelpAndExit(1);
			checkEncoding(argv[i]);
			convertfrom.assign(argv[i]);
		}
		else if (strcmp(argv[i], "--tags") == 0)
		{
			if (++i == argc)
				printHelpAndExit(1);
			givenTags = argv[i];
			checkTagList(givenTags);
			defaultTags = false;
		}
		else if (strcmp(argv[i], "--all-tags") == 0)
		{
			allTags = true;
		}
		else if (strcmp(argv[i], "--no-tags") == 0)
		{
			noTags = true;
		}
		else if (strcmp(argv[i], "--unusual-tags") == 0)
		{
			extraTags = true;
		}
		else if (strcmp(argv[i], "--list-encodings") == 0)
		{
			printEncodingsAndExit(0);
		}
		else if (strcmp(argv[i], "--list-default-tags") == 0)
		{
			printDefaultTagsAndExit(0);
		}
		else if (strcmp(argv[i], "--list-mandatory-tags") == 0)
		{
			printMandatoryTagsAndExit(0);
		}
		else if (strcmp(argv[i], "--list-usual-tags") == 0)
		{
			printUsualTagsAndExit(0);
		}
		else if (strcmp(argv[i], "--force") == 0)
		{
			force = true;
		}
		else
		{
			fprintf(stderr, "Unrecognized option '%s'.\n\n", argv[i]);
			printHelpAndExit(1);
		}
	}

	if (convertfrom != "auto" && !sys::utf8::Codec::checkEncoding(convertfrom))
	{
		fprintf(stderr, "Unknown encoding '%s'.\n\n", convertfrom.c_str());
		printEncodingsAndExit(1);
	}

	if (i == argc)
	{
		fprintf(stderr, "No input database specified.\n\n");
		printHelpAndExit(1);
	}

	mstl::string cdbPath(argv[i++]);
	format::Type cdbFormat = getFormat(cdbPath);

	if (cdbFormat == format::Invalid)
	{
		fprintf(stderr, "'%s' is not an Scidb database.\n", cdbPath.c_str());
		exit(1);
	}

	mstl::ifstream	stream(cdbPath);

	if (!stream)
	{
		fprintf(stderr, "Cannot open file '%s'.\n", cdbPath.c_str());
		exit(1);
	}

	mstl::string sciPath;

	if (i < argc)
	{
		sciPath.append(argv[i]);
	}
	else
	{
		sciPath.assign(cdbPath);
		mstl::string::size_type n = sciPath.rfind('/');

		if (n != mstl::string::npos)
			sciPath.erase(mstl::string::size_type(0), n + 1);

		stripSuffix(sciPath);
	}

	if (sciPath.empty())
	{
		fprintf(stderr, "Empty destination file name is not allowed.\n");
		exit(1);
	}

	if (sciPath.size() < 4 || strcmp(sciPath.c_str() + sciPath.size() - 4, ".sci") != 0)
		sciPath.append(".sci");
	
	if ((!force || cdbPath == sciPath) && access(sciPath, R_OK) == 0)
	{
		fprintf(stderr, "Database '%s' already exists.\n", sciPath.c_str());
		exit(1);
	}

	TagBits tagList;

	if (!noTags)
	{
		if (allTags)
			tagList.set();
		else if (defaultTags)
			tagList = getDefaultTags();
		else
			setTagList(tagList, givenTags);
	}

	try
	{
		loadEcoFile();

		Progress	progress;

		Database	src(cdbPath, convertfrom, permission::ReadOnly, progress);
		Database	dst(sciPath, sys::utf8::Codec::utf8(), storage::OnDisk);
		sci::Consumer consumer(	cdbFormat,
										sci::Consumer::Codecs(&dynamic_cast<sci::Codec&>(dst.codec())),
										tagList,
										extraTags);

		dst.setType(src.type());
		unsigned numGames = exportGames(src, consumer, progress);
		dst.save(progress);
		printf("\n%u game(s) written.\n", numGames);
		if (rejected > 0)
			printf("%u game(s) rejected.\n", rejected);
		fflush(stdout);
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
