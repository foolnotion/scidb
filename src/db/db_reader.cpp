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

#include "db_pgn_reader.h"
#include "db_bpgn_reader.h"
#include "db_site.h"
#include "db_tag_set.h"

#include "u_nul_string.h"
#include "u_zstream.h"
#include "u_misc.h"

#include "m_string.h"
#include "m_utility.h"

#include "sys_file.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

using namespace db;


static bool
equal(char const* lhs, char const* rhs, unsigned len)
{
	return strncmp(lhs, rhs, len) == 0;
}


static bool
caseEqual(char const* lhs, char const* rhs, unsigned len)
{
	return strncasecmp(lhs, rhs, len) == 0;
}


static bool
isdelim(char c)
{
	return c == '\0' || ispunct(c) || isspace(c);
}


static bool
matchSuffix(mstl::string const& str, mstl::string const& suffix)
{
	if (str.size() < suffix.size())
		return false;

	return strcasecmp(str.c_str() + suffix.size() - str.size(), suffix) == 0;
}


static void
removeValue(mstl::string& str, char* p, char delim)
{
	while (*p != delim)
		--p;
	while (p > str.c_str() && ::isspace(p[-1]))
		--p;

	*p = '\0';
	str.set_size(p - str.begin());
}


inline static
country::Code
checkCountry(mstl::string const& site, country::Code original, country::Code possible)
{
	db::Site const* p = db::Site::searchSite(site);

	if (p && p->containsCountry(possible) && !p->containsCountry(original))
		return possible;

	return original;
}


Reader::Tag
Reader::extractPlayerData(mstl::string& data, mstl::string& value)
{
	if (data.size() <= 5)
		return None;

	if (data.back() == ')')
	{
		mstl::string::size_type k = data.rfind('(');

		if (k != mstl::string::npos)
		{
			char* s = data.begin() + k + 1;
			char* e = data.end() - 1;

			while (::isspace(*e))
				--e;
			while (::isspace(*s))
				++s;

			if (s < e)
			{
				if (rating::isElo(s, e) && ::strtoul(s, nullptr, 10) <= rating::Max_Value)
				{
					if (*s == '0')
						value.hook(s + 1, e - (s + 1));
					else
						value.hook(s, e - s);
					::removeValue(data, s, '(');
					*e = '\0';
					return Elo;
				}

				if (country::validate(s, e))
				{
					value.hook(s, e - s);
					::removeValue(data, s, '(');
					*e = '\0';
					return Country;
				}

				if (title::validate(s, e))
				{
					value.hook(s, e - s);
					::removeValue(data, s, '(');
					*e = '\0';
					return Title;
				}

				if (species::isHuman(s, e))
				{
					::removeValue(data, s, '(');
					*e = '\0';
					return Human;
				}

				if (sex::validate(s, e))
				{
					::removeValue(data, s, '(');
					*e = '\0';
					return Sex;
				}

				if (species::isProgram(s, e))
				{
					::removeValue(data, s, '(');
					*e = '\0';
					return Program;
				}
			}
		}
	}
	else if (::isupper(data.back()))
	{
		char* s = data.end() - 3;
		char* e = data.end();

		if (::isspace(s[-1]))
		{
			if (country::validate(s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
					*e = '\0';
				return Country;
			}

			if (title::validate(s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
					*e = '\0';
				return Title;
			}
		}

		if (::isspace(s[0]))
		{
			if (title::validate(++s, e))
			{
				value.hook(s, e - s);
				::removeValue(data, s, ' ');
					*e = '\0';
				return Title;
			}
		}
	}

	return None;
}


country::Code
Reader::extractCountryFromSite(mstl::string& data)
{
	if (data.size() < 3)
		return country::Unknown;

	country::Code country;

	if (data[0] == 'I')
	{
		switch (data[1])
		{
			case 'n':
				if (::equal(data, "Internet", 8) && ::isdelim(data[8]))
					return country::The_Internet;
				break;

			case 'N':
				if (data[2] == 'T' && ::isdelim(data[3]))
					return country::The_Internet;
				break;
		}
	}

	char* e = data.end() - 1;
	char* s;

	if (*e == ')')
	{
		s = e - 3;

		if (s < data.begin())
			return country::Unknown;

		if (*s == '(')
		{
			if ((country = country::fromString(s + 1)) == country::Unknown)
				return country::Unknown;
		}
		else if (s[1] == '(' || s[2] == '(')
		{
			return country::Unknown;
		}
		else
		{
			while (*s != '(')
			{
				if (s == data.begin())
					return country::Unknown;

				--s;
			}

			util::NulString str(s + 1, e - s - 1);
			country = Site::findCountryCode(str);

			if (country == country::Unknown)
				return country::Unknown;
		}
	}
	else
	{
		s = e - 2;

		if (s < data.begin())
			return country::Unknown;

		if (s == data.begin())
			return country::fromString(s);

		if (::isspace(s[-1]))
		{
			if ((country = country::fromString(s)) == country::Unknown)
				return country::Unknown;
		}
		else
		{
			while (*s != ',')
			{
				if (*s == '/')
					return country::Unknown;

				if (s == data.begin())
				{
					Site const* site = Site::findSite(s);
					if (site && site->countCountries() == 1)
					{
						if (data.size() == 3)
							data = "";
						return site->country(0);
					}
					return country::Unknown;
				}

				--s;
			}

			++s;
			while (::isspace(*s))
				++s;

			::util::NulString str(s, e - s + 1);

			Site const* site = Site::findSite(str);

			if (site == 0 || site->countCountries() > 1)
				return country::Unknown;

			country = site->country(0);

			if (Site::findCountryCode(str) == country::Unknown)
				return country;
		}
	}

	if (s > data.begin())
	{
		--s;

		while (s > data.begin() && ::isspace(*s))
			--s;

		if (*s == '/')
			return country::Unknown;

		if (*s == ',')
		{
			--s;

			while (s > data.begin() && ::isspace(*s))
				--s;
		}

		data.set_size(s - data.begin() + 1);
	}

	return country;
}


event::Mode
Reader::getEventMode(char const* event, char const* site)
{
	M_REQUIRE(event);
	M_REQUIRE(site);

	event::Mode mode = event::Undetermined;

	switch (event[0])
	{
		case 'F':
			if (::equal(event, "FICGS_", 6))
				mode = event::PaperMail;
			else if (::equal(event, "FICS ", 5))
				mode = event::Internet;
			break;

		case 'I':
			if (::equal(event, "ICS: ", 5))
				mode = event::Internet;
			// fallthru

		case 'i':
			if (::caseEqual(event, "internet", 5) && ::isdelim(event[5]))
				mode = event::Internet;
			break;

		case 'w':
			if (::equal(event, "www.", 4))
				mode = event::Internet;
			break;

		case 'E': case 'e':
			if (::caseEqual(event, "email", 5) && ::isdelim(event[5]))
				mode = event::Email;
			break;
	}

	if (mode == event::Undetermined)
	{
		switch (site[0])
		{
			case 'A':
				if (::equal(site, "AJEC", 4) && ::isdelim(site[4]))
					mode = event::PaperMail;
				break;

			case 'B':
				if ((site[1] == 'd' || site[1] == 'D') && site[2] == 'F' && ::isdelim(event[3]))
					mode = event::PaperMail;
				break;

			case 'C':
				switch (site[1])
				{
					case 'C':
						if (::equal(site, "CCLA", 4) && ::isdelim(site[4]))
					mode = event::PaperMail;
						break;

					case 'o':
						if (site[2] == 'r' && site[3] == 'r')
						{
							if (::isdelim(site[4]) || ::equal(site + 4, "espondence", 10))
								mode = event::PaperMail;
						}
						break;
				}
				break;

			case 'D':
				switch (site[1])
				{
					case 'E':
						if (::equal(site, "DESC", 4) && ::isdelim(site[4]))
							mode = event::Email;
						break;

					case 'I':
						if (::equal(site, "DICS", 4) && ::isdelim(site[4]))
							mode = event::Email;
						break;
				}
				break;

			case 'F':
				if (::equal(site, "FICGS", 5) && ::isdelim(site[5]))
					mode = event::PaperMail;
				break;

			case 'I':
				switch (site[1])
				{
					case 'C':
						if (::equal(site, "ICCF", 4) && ::isdelim(site[4]))
							mode = event::PaperMail;
					break;

					case 'E':
						if (	(::equal(site, "IECC", 4) || ::equal(site, "IECG", 4))
							&& ::isdelim(site[4]))
						{
							mode = event::Email;
						}
						break;
				}
				break;

			case 'O':
				if (::equal(site, "OCC", 3) && ::isdelim(site[3]))
					mode = event::Internet;
				break;

			case 'U':
				switch (site[1])
				{
					case 'E':
						if (::equal(site, "UECC", 4) && ::isdelim(site[4]))
							mode = event::Email;
						break;

					case 'S':
						if (::equal(site, "USCF", 4) && ::isdelim(site[4]))
							mode = event::PaperMail;
						break;
				}
				break;

			case 'W':
				if (::equal(site, "WCCF", 4) && ::isdelim(site[4]))
					mode = event::PaperMail;
				break;
		}
	}

	return mode;
}


void
Reader::parseDescription(mstl::istream& strm, mstl::string& result)
{
	unsigned n = 0;

	while (1)
	{
		int c = strm.peek();

		switch (c)
		{
			case '\0':
			case '[':
				return;

			case EOF:
				return;

			case '\n':
				if (++n == 10)
					return;
				// fallthru

			default:
				result.append(strm.get());
				break;
		}
	}
}


bool
Reader::getAttributes(mstl::string const& filename, int& numGames, mstl::string* description)
{
	if (description)
	{
		util::ZStream strm(sys::file::internalName(filename), mstl::ios_base::in);

		if (!strm.is_open())
			return false;

		numGames = strm.size();
		parseDescription(strm, *description);
		description->trim();
		strm.close();
	}
	else
	{
		int64_t fileSize;

		if (!util::ZStream::size(sys::file::internalName(filename), fileSize, 0))
			return false;

		numGames = fileSize;
	}

	if (numGames > 0)
	{
		mstl::string ext(util::misc::file::suffix(filename));

		if (ext == "zip" || ext == "ZIP")
		{
			if (util::ZStream::containsSuffix(filename, "pgn"))
				numGames = PgnReader::estimateNumberOfGames(numGames);
			else
				numGames = -1;
		}
		else if (ext == "gz")
		{
			ext = util::misc::file::suffix(util::misc::file::rootname(filename));
		}
		else if (ext == "pgn" || ext == "PGN")
		{
			numGames = PgnReader::estimateNumberOfGames(numGames);
		}
		else if (ext == "bpgn")
		{
			numGames = BpgnReader::estimateNumberOfGames(numGames);
		}
	}

	return true;
}


time::Mode
Reader::getTimeModeFromTimeControl(mstl::string const& value)
{
	mstl::string::size_type field = 0;

	unsigned seconds	= 0;
	unsigned moves		= 0;

	do
	{
		if (field >= value.size() || (value[field] == '*' && !::isdigit(value[field + 1])))
			return time::Unknown;

		unsigned nextDelim = value.find(':', field);
		unsigned n;

		if ((n = value.find('/', field)) < nextDelim)
		{
			moves += ::strtoul(value.c_str() + field, nullptr, 10);
			seconds += ::strtoul(value.c_str() + n + 1, nullptr, 10);
		}
		else
		{
			if (value[field] == '*')
				++field;

			seconds += ::strtoul(value.c_str() + field, nullptr, 10);

			if ((n = value.find('+', field)) < nextDelim)
			{
				unsigned increment = ::strtoul(value.c_str() + n + 1, nullptr, 10);
				seconds += mstl::max(0, 60 - int(moves))*increment;
			}
		}

		field = nextDelim;
	}
	while (field++ != mstl::string::npos);

	if (seconds == 0)
		return time::Unknown;

	// Bullet: 1 or 2 minutes per side.
	if (seconds <= 120)
		return time::Bullet;

	// Blitz:  All the moves must be made in a fixed time of less
	//         than 15 minutes for each player; or the allotted time
	//         + 60 times any increment is less than 15 minutes.
	if (seconds < 900)
		return time::Blitz;

	// Rapid:  15 to less than 60 minutes per player, or the
	//         allotted time + 60 times any increment is at least
	//         15 minutes, but less than 60 minutes for each player.
	if (seconds < 3600)
		return time::Rapid;

	return time::Normal;
}


bool
Reader::parseRound(mstl::string const& data, unsigned& round, unsigned& subround)
{
	char* s = const_cast<char*>(data.c_str());

	if (*s == '?' || *s == '-')
	{
		round = subround = 0;
	}
	else
	{
		while (::isspace(*s))
			++s;

		if (*s == '\0')
		{
			round = subround = 0;
		}
		else
		{
			if (*s == '(')
				++s;
			while (*s == '0')
				++s;

			if (::isdigit(*s))
			{
				round = ::strtoul(s, &s, 10);

				if (round > 255)
				{
					round = subround = 0;
					return false;
				}
			}
			else if (s == data.c_str() || s[-1] != '0')
			{
				round = subround = 0;
				return false;
			}
			else
			{
				round = subround = 0;
				return true;
			}

			if (*s == '.')
			{
				subround = ::strtoul(s + 1, &s, 10);

				if (subround > 255)
				{
					subround = 0;
					return false;
				}

				if (*s == '.')
				{
					round = subround;
					subround = ::strtoul(s + 1, &s, 10);

					if (subround > 255)
					{
						round = subround = 0;
						return false;
					}
				}

				if (*s == ')' && data[0] == '(')
					++s;

				if (*s)
				{
					round = subround = 0;
					return false;
				}
			}
			else
			{
				subround = 0;
			}
		}
	}

	return true;
}


bool
Reader::validateTagName(char* tag, unsigned len)
{
	if (len == 0)
		return false;

	while (len--)
	{
		char c = *tag;

		if (c == '\0')
			return true;

		// NOTE: Character '-' is not allowed due to the PGN specification, but
		// is used in some PGN games (e.g. PGN files from www.remoteschach.de).
		// We replace this character silently to be PGN conform.

		if (c == '-')
			*tag = '_';
		else if (!::isalnum(c))
			return false;

		++tag;
	}

	return true;
}


bool
Reader::validateTagName(char const* s, char const* e)
{
	if (s == e)
		return false;

	for ( ; s < e; ++s)
	{
		char c = *s;

		if (c == '\0')
			return true;

		// NOTE: Character '-' is not allowed due to the PGN specification, but
		// is used in some PGN games (e.g. PGN files from www.remoteschach.de).
		// We replace this character silently to be PGN conform.

		if (c != '_' && !::isalnum(c))
			return false;
	}

	return true;
}


termination::Reason
Reader::getTerminationReason(mstl::string const& value)
{
	termination::Reason reason = termination::fromString(value);

	if (reason == termination::Unknown)
	{
		static mstl::string const Resigned("resigned");
		static mstl::string const WonByResignation("won by resignation");

		if (::matchSuffix(value, Resigned) || ::matchSuffix(value, WonByResignation))
			return termination::Normal;

		if (value.size() > 1)
		{
			mstl::string v(value);
			v.strip('-');

			return termination::fromString(value);
		}
	}

	return reason;
}


void
Reader::checkSite(TagSet& tags, country::Code eventCountry, bool sourceIsPossiblyChessBase)
{
	mstl::string const& site = tags.value(tag::Site);

	if (eventCountry == country::Unknown)
	{
//		db::Site const* s = db::Site::searchSite(site);
//
//		if (s && s->countCountries() == 1)
//			eventCountry = s->country(0);
	}
	else
	{
		// sometimes wrong country codes will be used; we'll try to fix this:

		switch (int(eventCountry))
		{
			case country::Cambodia:		// CAM: sometimes confused with Cameroon (CMR)
				eventCountry = ::checkCountry(site, country::Cambodia, country::Cameroon);
				break;

			case country::Antigua:		// ANT: often confused with Netherlands_Antilles (AHO)
				eventCountry = ::checkCountry(site, country::Antigua, country::Netherlands_Antilles);
				break;

			case country::England:		// ENG: sometimes Gibraltar will be confused with England
				eventCountry = ::checkCountry(site, country::England, country::Gibraltar);
				break;

			case country::France:		// FRA: sometimes Monaco will be confused with France
				eventCountry = ::checkCountry(site, country::France, country::Monaco);
				break;

			case country::Ireland:		// IRL: probably it belongs to Northern_Ireland (NIR)
				eventCountry = ::checkCountry(site, country::Ireland, country::Northern_Ireland);
				break;

			case country::Kiribati:		// KIR: often confused with Kyrgyzstan (KGZ)
				eventCountry = ::checkCountry(site, country::Kiribati, country::Kyrgyzstan);
				break;

			case country::Lebanon:		// LIB: often confused with Libya (LBA)
				eventCountry = ::checkCountry(site, country::Lebanon, country::Libya);
				break;

			case country::Monaco:		// MON: sometimes confused with Mongolia (MGL)
				eventCountry = ::checkCountry(site, country::Monaco, country::Mongolia);
				break;

			case country::Niger:			// NIG: often confused with Nigeria (NGR)
				eventCountry = ::checkCountry(site, country::Niger, country::Nigeria);
				break;

			case country::Swaziland:	// SWZ: often confused with Switzerland (SUI)
				eventCountry = ::checkCountry(site, country::Swaziland, country::Switzerland);
				break;

			case country::The_Internet:	// NET: sometimes confused with Netherlands (NED)
				eventCountry = ::checkCountry(site, country::The_Internet, country::Netherlands);
				break;

			case country::Serbia_and_Montenegro:	// SCG: Scid is confusing this with Yugoslavia (YUG)
				eventCountry = ::checkCountry(	site,
															country::Serbia_and_Montenegro,
															country::Bosnia_and_Herzegovina);
				break;

			case country::United_Arab_Emirates:	// UAE: sometimes Bahrain will be confused with UAE
				eventCountry = ::checkCountry(site, country::United_Arab_Emirates, country::Bahrain);
				break;
		}

		if (sourceIsPossiblyChessBase)
		{
			// ChessBases ignores the PGN standard in case of the country codes.
			// We try to fix wrong country code mappings (should only happen if
			// the PGN source is ChessBase).
			//
			// We will verify the corrections. We cannot be sure that the source
			// of the data is ChessBase.

			switch (int(eventCountry))
			{
#if 0	// already handled
				case country::Cambodia:			// CAM
					eventCountry = ::checkCountry(site, country::Cambodia, country::Cameroon);
					break;
#endif

				case country::Palestine:		// PLE
					eventCountry = ::checkCountry(site, country::Palestine, country::Palau);
					break;

				case country::El_Salvador:		// SAL
					eventCountry = ::checkCountry(site, country::El_Salvador, country::Solomon_Islands);
					break;

				case country::Switzerland:		// SUI
					eventCountry = ::checkCountry(	site,
																country::Switzerland,
																country::Saint_Vincent_and_the_Grenadines);
					break;

				case country::Slovenia:			// SVN
					eventCountry = ::checkCountry(site, country::Slovenia, country::Jan_Mayen_and_Svalbard);
					break;

				case country::Czech_Republic:	// CZE
					eventCountry = ::checkCountry(site, country::Czech_Republic, country::Czechoslovakia);
					break;

				case country::West_Germany:	// FRG
					eventCountry = ::checkCountry(site, country::Germany, country::French_Guiana);
					break;

				case country::The_Internet:	// NET
					eventCountry = ::checkCountry(site, country::The_Internet, country::American_Samoa);
					break;

				case country::DR_Congo:			// ZAR
					eventCountry = ::checkCountry(site, country::DR_Congo, country::Russia);
					break;
			}

			// Possibly the mapping of the country code is still incorrect.
			// Complain this to ChessBase!
		}

		tags.add(tag::EventCountry, country::toString(eventCountry));
	}

// NOTE:
// The tags "WhiteCountry", "BlackCountry" do not exist if source is "ChessBase".
//
//	if (tags.contains(Source))
//	{
//		if (::strcasecmp(tags.value(Source), "chessbase") == 0 || !eventCountry.empty())
//		{
//			if (tags.contains(WhiteCountry))
//			{
//				tags.set(	WhiteCountry,
//								country::toString(
//									country::remapToChessbaseCoding(
//										country::fromString(tags.value(WhiteCountry)))));
//			}
//
//			if (tags.contains(BlackCountry))
//			{
//				tags.set(	BlackCountry,
//								country::toString(
//									country::remapToChessbaseCoding(
//										country::fromString(tags.value(BlackCountry)))));
//			}
//		}
//	}
}

// vi:set ts=3 sw=3:
