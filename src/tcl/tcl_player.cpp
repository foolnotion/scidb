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
// Copyright: (C) 2012-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tcl_player.h"
#include "tcl_base.h"

#include "app_player_dictionary.h"

#include "db_player.h"
#include "db_namebase_entry.h"

#include "m_utility.h"

#include <tcl.h>
#include <string.h>
#include <ctype.h>

using namespace db;
using namespace tcl;


static char const* CmdCount	= "::scidb::player::count";
static char const* CmdDict		= "::scidb::player::dict";
static char const* CmdFilter	= "::scidb::player::filter";
static char const* CmdLetter	= "::scidb::player::letter";
static char const* CmdInfo		= "::scidb::player::info";
static char const* CmdSearch	= "::scidb::player::search";
static char const* CmdSort		= "::scidb::player::sort";

static app::PlayerDictionary* m_dictionary = 0;


__attribute__((unused))
static bool
checkNonZero(Tcl_Obj** objv, unsigned size)
{
	for (unsigned i = 0; i < size; ++i)
	{
		if (!objv[i])
			return false;
	}

	return true;
}


static tcl::player::Ratings
convRatings(char const* s)
{
	M_ASSERT(s);

	char const* t = s;

	while (*t && !::isspace(*t))
		++t;

	while (::isspace(*t))
		++t;

	return tcl::player::Ratings(rating::fromString(s), rating::fromString(t));
}


static Tcl_Obj*
wikiLinkList(Player const* player)
{
	typedef Player::AssocList AssocList;

	AssocList wikiLinks;

	if (player->wikipediaLinks(wikiLinks))
	{
		Tcl_Obj* objs[mstl::mul2(wikiLinks.size())];
		unsigned n = 0;

		Player::AssocList::const_iterator i = wikiLinks.begin();
		Player::AssocList::const_iterator e = wikiLinks.end();

		for ( ; i != e; ++i)
		{
			Player::Assoc const& assoc = *i;

			objs[n++] = Tcl_NewStringObj(assoc.first, -1);
			objs[n++] = Tcl_NewStringObj(assoc.second, -1);
		}

		return Tcl_NewListObj(n, objs);
	}

	return Tcl_NewListObj(0, 0);
}


static void
playerRatings(NamebasePlayer const& player, rating::Type& type, int16_t* ratings)
{
	if (type == rating::Any)
		type = player.findRatingType();

	ratings[0] = player.playerHighestRating(type);
	ratings[1] = player.playerLatestRating(type);

	if (!player.isPlayerRating(type))
	{
		ratings[0] = -ratings[0];
		ratings[1] = -ratings[1];
	}
}


int
tcl::player::getInfo(NamebasePlayer const& player, Ratings& ratings, bool info, bool idCard)
{
	M_ASSERT(!idCard || info);

	Tcl_Obj* objv[info ? attribute::player::LastInfo : attribute::player::LastColumn];

	M_ASSERT(::memset(objv, 0, sizeof(objv)));

	mstl::string			title;
	char const*				federation(mstl::string::empty_string.c_str());
	mstl::string const*	name(&player.name());
	mstl::string			sex(sex::toString(player.sex()));
	int32_t					fideID(player.fideID());
	Player const*			p(player.player());

	if (p)
	{
		if (idCard || player.title() == title::None)
		{
			unsigned titles = p->titles();

			while (titles)
			{
				unsigned t = 1u << mstl::bf::lsb_index(titles);

				if (!title.empty())
					title += ' ';

				title += title::toString(title::toID(t));
				titles &= ~t;
			}
		}

		if (idCard || player.federation() == country::Unknown)
			federation = country::toString(p->federation());

		if (idCard || player.sex() == sex::Unspecified)
			sex = sex::toString(p->sex());

		if (idCard)
			name = &p->name();

		if (fideID == 0)
		{
			fideID = p->fideID();

			if (!idCard)
				fideID = -fideID;
		}
	}

	if (title.empty())
		title = title::toString(player.title());

	if (!*federation)
		federation = country::toString(player.federation());

	int16_t rating1[2];
	int16_t rating2[2];

	::playerRatings(player, ratings.first,  rating1);
	::playerRatings(player, ratings.second, rating2);

	Tcl_Obj* ratingObj1[3] =
	{
		Tcl_NewIntObj(rating1[0]),
		Tcl_NewIntObj(rating1[1]),
		Tcl_NewStringObj(rating::toString(ratings.first), -1),
	};
	Tcl_Obj* ratingObj2[3] =
	{
		Tcl_NewIntObj(rating2[0]),
		Tcl_NewIntObj(rating2[1]),
		Tcl_NewStringObj(rating::toString(ratings.second), -1),
	};

	mstl::string const ratingType = rating::toString(player.playerRatingType());

	objv[attribute::player::Name      ] = Tcl_NewStringObj(*name, name->size());
	objv[attribute::player::FideID    ] = fideID ? Tcl_NewIntObj(fideID) : Tcl_NewListObj(0, 0);
	objv[attribute::player::Sex       ] = Tcl_NewStringObj(sex, -1);
	objv[attribute::player::Rating1   ] = Tcl_NewListObj(3, ratingObj1);
	objv[attribute::player::Rating2   ] = Tcl_NewListObj(3, ratingObj2);
	objv[attribute::player::RatingType] = Tcl_NewStringObj(ratingType, ratingType.size());
	objv[attribute::player::Country   ] = Tcl_NewStringObj(federation, -1);
	objv[attribute::player::Title     ] = Tcl_NewStringObj(title, -1);
	objv[attribute::player::Type      ] = Tcl_NewStringObj(species::toString(player.findType()), -1);
	objv[attribute::player::PlayerInfo] = Tcl_NewBooleanObj(player.havePlayerInfo());
	objv[attribute::player::Frequency ] = Tcl_NewIntObj(player.frequency());

	M_ASSERT(::checkNonZero(objv, attribute::player::LastColumn));

	if (info)
	{
		unsigned			viafID(0);
		unsigned			iccfID(0);
		mstl::string	dsbID;
		mstl::string	ecfID;
		mstl::string	pndID;
		mstl::string	chessgamesID;
		Date				dateOfBirth;
		Date				dateOfDeath;
		Tcl_Obj*			wikiLinkList(0);
		Tcl_Obj*			aliasList(0);

		if (p)
		{
			typedef Player::StringList	StringList;

			dateOfBirth = p->dateOfBirth();
			dateOfDeath = p->dateOfDeath();
			iccfID = p->iccfID();
			dsbID = p->dsbID();
			ecfID = p->ecfID();
			viafID = p->viafID();
			pndID = p->pndID();
			chessgamesID = p->chessgamesID();
			wikiLinkList = ::wikiLinkList(p);

			StringList const& aliases = p->aliases();

			if (!aliases.empty())
			{
				Tcl_Obj* objs[aliases.size()];

				for (unsigned i = 0; i < aliases.size(); ++i)
					objs[i] = Tcl_NewStringObj(aliases[i], aliases[i].size());

				aliasList = Tcl_NewListObj(aliases.size(), objs);
			}
		}

		objv[attribute::player::DateOfBirth  ] = Tcl_NewStringObj(dateOfBirth.asShortString(), -1);
		objv[attribute::player::DateOfDeath  ] = Tcl_NewStringObj(dateOfDeath.asShortString(), -1);
		objv[attribute::player::DsbID        ] = Tcl_NewStringObj(dsbID, dsbID.size());
		objv[attribute::player::EcfID        ] = Tcl_NewStringObj(ecfID, ecfID.size());
		objv[attribute::player::IccfID       ] = iccfID ? Tcl_NewIntObj(iccfID) : Tcl_NewStringObj(0, 0);
		objv[attribute::player::ViafID       ] = viafID ? Tcl_NewIntObj(viafID) : Tcl_NewStringObj(0, 0);
		objv[attribute::player::PndID        ] = Tcl_NewStringObj(pndID, pndID.size());
		objv[attribute::player::ChessgComLink] = Tcl_NewStringObj(chessgamesID, chessgamesID.size());
		objv[attribute::player::WikiLink     ] = wikiLinkList ? wikiLinkList : Tcl_NewListObj(0, 0);
		objv[attribute::player::Aliases      ] = aliasList ? aliasList : Tcl_NewListObj(0, 0);

		M_ASSERT(::checkNonZero(objv, attribute::player::LastInfo));
	}

	setResult(info ? attribute::player::LastInfo : attribute::player::LastColumn, objv);
	return TCL_OK;
}


static int
cmdCount(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	setResult(Tcl_NewIntObj(m_dictionary ? m_dictionary->count() : 0));
	return TCL_OK;
}


static int
cmdDict(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char const* cmd = stringFromObj(objc, objv, 1);

	if (strcmp(cmd, "open") == 0)
	{
		app::PlayerDictionary::Mode mode;
		char const* modeStr = stringFromObj(objc, objv, 2);

		if (strcmp(modeStr, "all") == 0)
			mode = app::PlayerDictionary::All;
		else if (strcmp(modeStr, "player") == 0)
			mode = app::PlayerDictionary::PlayersOnly;
		else if (strcmp(modeStr, "engine") == 0)
			mode = app::PlayerDictionary::EnginesOnly;
		else
			return error(CmdDict, nullptr, nullptr, "Unknown dictionary mode '%s'", modeStr);

		if (m_dictionary == 0)
		{
			m_dictionary = new app::PlayerDictionary(mode);
			m_dictionary->sort(app::PlayerDictionary::Name, order::Ascending);
		}
	}
	else if (strcmp(cmd, "close") == 0)
	{
		delete m_dictionary;
		m_dictionary = 0;
	}
	else
	{
		return error(CmdDict, nullptr, nullptr, "Unknown command '%s'", cmd);
	}

	return TCL_OK;
}


static int
cmdInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (!m_dictionary)
		return error(CmdInfo, nullptr, nullptr, "player dictionary is closed");

	tcl::player::Ratings ratings(rating::Elo, rating::DWZ);
	federation::ID federation = federation::Fide;

	while (objc > 2)
	{
		char const* arg = stringFromObj(objc, objv, objc - 2);

		if (::strcmp(arg, "-ratings") == 0)
			ratings = ::convRatings(stringFromObj(objc, objv, objc - 1));
		else if (::strcmp(arg, "-federation") == 0)
			federation = federation::fromString(stringFromObj(objc, objv, objc - 1));
		else
			return error(::CmdInfo, nullptr, nullptr, "invalid argument %s", arg);

		objc -= 2;
	}

	Player const&	player = m_dictionary->getPlayer(unsignedFromObj(objc, objv, 1));

	Tcl_Obj* objs[10];
	Tcl_Obj* titles[title::Last];
	int		numTitles = 0;
	char		sex;

	if (player.type() == species::Program)
		sex = 'c';
	else if (player.sex() == sex::Male)
		sex = 'm';
	else if (player.sex() == sex::Female)
		sex = 'f';
	else
		sex = ' ';

	for (unsigned i = 0; i < title::Last; ++i)
	{
		if (title::contains(player.titles(), title::ID(i)))
			titles[numTitles++] = Tcl_NewStringObj(title::toString(title::ID(i)), -1);
	}

	objs[0] = Tcl_NewStringObj(country::toString(player.nativeCountry()), -1);
	objs[1] = Tcl_NewStringObj(player.name(), player.name().size());
	objs[2] = Tcl_NewStringObj(player.federationID(federation), -1);
	objs[3] = Tcl_NewStringObj(country::toString(player.federation()), -1);
	objs[4] = Tcl_NewStringObj(&sex, 1);
	objs[5] = Tcl_NewIntObj(mstl::max(int16_t(0), player.latestRating(ratings.first)));
	objs[6] = Tcl_NewIntObj(mstl::max(int16_t(0), player.latestRating(ratings.second)));
	objs[7] = Tcl_NewListObj(numTitles, titles);
	objs[8] = Tcl_NewIntObj(player.birthYear());
	objs[9] = Tcl_NewIntObj(player.deathYear());

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


static int
cmdLetter(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (!m_dictionary)
		return error(CmdInfo, nullptr, nullptr, "player dictionary is closed");

	m_dictionary->filterLetter(toupper(*stringFromObj(objc, objv, 1)));
	m_dictionary->finishOperation();
	return TCL_OK;
}


static int
cmdFilter(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (!m_dictionary)
		return error(CmdInfo, nullptr, nullptr, "player dictionary is closed");

	char const*	opStr		= stringFromObj(objc, objv, 1);
	Tcl_Obj*		filter	= objectFromObj(objc, objv, 2);
	int			length;

	if (Tcl_ListObjLength(ti, filter, &length) != TCL_OK || mstl::is_odd(length))
		return error(CmdInfo, nullptr, nullptr, "list of name/value pairs expected");

	app::PlayerDictionary::Operator op = app::PlayerDictionary::Reset;

	switch (tolower(*opStr))
	{
		case 'n':
			switch (tolower(opStr[1]))
			{
				case 'u': op = op = app::PlayerDictionary::Null; break;
				case 'o': op = op = app::PlayerDictionary::Not; break;
			}
			break;

		case 'r':
			if (tolower(opStr[1]) == 'e')
			{
				switch (tolower(opStr[2]))
				{
					case 's': op = op = app::PlayerDictionary::Reset; break;
					case 'm': op = op = app::PlayerDictionary::Remove; break;
				}
			}
			break;

		case 'a': op = app::PlayerDictionary::And; break;
		case 'o': op = app::PlayerDictionary::Or; break;
	}

	if (length > 0)
	{
		for (int i = 0; i < length; i += 2)
		{
			Tcl_Obj* key;
			Tcl_Obj* val;

			Tcl_ListObjIndex(nullptr, filter, i, &key);
			Tcl_ListObjIndex(nullptr, filter, i + 1, &val);

			char const* attr = Tcl_GetString(key);

			switch (tolower(*attr))
			{
				case 'c': // country
					m_dictionary->filterNativeCountry(op, ::country::fromString(Tcl_GetString(val)));
					break;

				case 'f':
					if (strcasecmp(attr, "federationId") == 0)
					{
						federation::ID federation = federation::None;

						switch (::toupper(*Tcl_GetString(val)))
						{
							case 'F': federation = federation::Fide; break;
							case 'I': federation = federation::ICCF; break;
							case 'D': federation = federation::DSB; break;
							case 'E': federation = federation::ECF; break;
						}

						m_dictionary->filterFederationID(op, federation);
					}
					else // federation
					{
						m_dictionary->filterFederation(op, ::country::fromString(Tcl_GetString(val)));
					}
					break;

				case 'n': // name
					m_dictionary->filterName(op, Tcl_GetString(val));
					break;

				case 's': // sex
					m_dictionary->filterSex(op, sex::fromString(Tcl_GetString(val)));
					break;

				case 'r': // rating
				{
					Tcl_Obj** objs;
					int len, min, max;
					rating::Type type;
					if (	Tcl_ListObjGetElements(ti, val, &len, &objs) != TCL_OK
						|| len != 3
						|| (type = rating::fromString(Tcl_GetString(objs[0]))) == rating::Any
						|| Tcl_GetIntFromObj(ti, objs[1], &min) != TCL_OK
						|| Tcl_GetIntFromObj(ti, objs[2], &max) != TCL_OK)
					{
						return error(CmdFilter, nullptr, nullptr, "'rating min-score max-score' expected");
					}
					m_dictionary->filterScore(op, type, min, max);
					break;
				}

				case 't': // titles
				{
					Tcl_Obj** objs;
					int len;
					unsigned titles = 0;
					if (Tcl_ListObjGetElements(ti, val, &len, &objs) != TCL_OK)
						return error(CmdFilter, nullptr, nullptr, "list of titles expected");
					for (int i = 0; i < len; ++i)
					{
						char const* s = Tcl_GetString(objs[i]);
						title::ID title = title::fromString(s);
						if (title == title::None && *s != '\0')
							return error(CmdFilter, nullptr, nullptr, "invalid title '%s'", s);
						titles |= title::fromID(title);
					}
					m_dictionary->filterTitles(op, titles);
					break;
				}

				case 'b': // birthYear
				case 'd': // birthYear
				{
					Tcl_Obj** objs;
					int len, min, max;
					if (	Tcl_ListObjGetElements(ti, val, &len, &objs) != TCL_OK
						|| len != 2
						|| Tcl_GetIntFromObj(ti, objs[0], &min) != TCL_OK
						|| Tcl_GetIntFromObj(ti, objs[0], &max) != TCL_OK)
					{
						return error(CmdFilter, nullptr, nullptr, "'min-year max-year' expected");
					}
					if (tolower(*attr) == 'b')
						m_dictionary->filterBirthYear(op, min, max);
					else
						m_dictionary->filterDeathYear(op, min, max);
					break;
				}
			}

			if (op == app::PlayerDictionary::Reset)
				op = app::PlayerDictionary::And;
			else if (op == app::PlayerDictionary::Null)
				op = app::PlayerDictionary::Not;
		}
	}
	else
	{
		m_dictionary->resetFilter();
	}

	m_dictionary->finishOperation();
	return TCL_OK;
}


static int
cmdSearch(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (!m_dictionary)
		return error(CmdInfo, nullptr, nullptr, "player dictionary is closed");

	setResult(m_dictionary->search(stringFromObj(objc, objv, 1)));
	return TCL_OK;
}


static int
cmdSort(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (!m_dictionary)
		return error(CmdInfo, nullptr, nullptr, "player dictionary is closed");

	char const* order	= stringFromObj(objc, objv, 1);

	if (strcmp(order, "reverse") == 0)
	{
		m_dictionary->reverseOrder();
	}
	else if (strcmp(order, "cancel") == 0)
	{
		m_dictionary->cancelSort();
		m_dictionary->sort(app::PlayerDictionary::Name, order::Ascending);
	}
	else
	{
		char const* attr	= stringFromObj(objc, objv, 2);

		app::PlayerDictionary::Attribute attribute;
		order::ID ordering = order::Ascending;

		switch (*attr)
		{
			case 'c': attribute = app::PlayerDictionary::NativeCountry; break;
			case 'n': attribute = app::PlayerDictionary::Name; break;
			case 'b': attribute = app::PlayerDictionary::DateOfBirth; break;
			case 'd': attribute = app::PlayerDictionary::DateOfDeath; break;
			case 's': attribute = app::PlayerDictionary::Sex; break;
			case 'f': attribute = app::PlayerDictionary::Federation; break;

			case 'F': attribute = app::PlayerDictionary::FideID; break;
			case 'U': attribute = app::PlayerDictionary::LatestUSCF; break;

			case 't':
				if (attr[1] == 'y')
					attribute = app::PlayerDictionary::Type;
				else
					attribute = app::PlayerDictionary::Titles;
				break;

			case 'D':
				if (attr[1] == 'W')
					attribute = app::PlayerDictionary::LatestDWZ;
				else
					attribute = app::PlayerDictionary::DsbId;
				break;

			case 'E':
				if (attr[1] != 'C')
					attribute = app::PlayerDictionary::LatestElo;
				else if (strlen(attr) == 3)
					attribute = app::PlayerDictionary::LatestECF;
				else
					attribute = app::PlayerDictionary::EcfId;
				break;

			case 'I':
				if (attr[1] == 'P')
					attribute = app::PlayerDictionary::LatestIPS;
				else if (strlen(attr) == 4)
					attribute = app::PlayerDictionary::LatestICCF;
				else
					attribute = app::PlayerDictionary::IccfId;
				break;

			case 'R':
				if (attr[1] == 'a' && attr[2] == 'p')
					attribute = app::PlayerDictionary::LatestRapid;
				else
					attribute = app::PlayerDictionary::LatestRating;
				break;
		}

		switch (tolower(*order))
		{
			case 'a': ordering = order::Ascending; break;
			case 'd': ordering = order::Descending; break;
		}

		m_dictionary->sort(attribute, ordering);
	}

	m_dictionary->finishOperation();
	return TCL_OK;
}


namespace tcl {
namespace player {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdCount,		cmdCount);
	createCommand(ti, CmdDict,		cmdDict);
	createCommand(ti, CmdInfo,		cmdInfo);
	createCommand(ti, CmdFilter,	cmdFilter);
	createCommand(ti, CmdLetter,	cmdLetter);
	createCommand(ti, CmdSearch,	cmdSearch);
	createCommand(ti, CmdSort,		cmdSort);
}

} // namespace player
} // namespace tcl

// vi:set ts=3 sw=3:
