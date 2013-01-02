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

#include "db_player.h"
#include "db_namebase_entry.h"

#include <tcl.h>
#include <string.h>
#include <ctype.h>

using namespace db;
using namespace tcl;


static char const* CmdInfo	= "::scidb::player::info";
static char const* CmdList	= "::scidb::player::list";


namespace {

struct CallbackLetter : public ::db::Player::PlayerCallback
{
	CallbackLetter(Tcl_Obj* obj, char letter) : m_list(obj), m_letter(letter) {}

	Tcl_Obj* m_list;
	char m_letter;

	void entry(unsigned index, ::db::Player const& player) override
	{
		if ((player.name().front()) == m_letter)
			Tcl_ListObjAppendElement(0, m_list, Tcl_NewIntObj(index));
	}
};

struct CallbackRest : public ::db::Player::PlayerCallback
{
	CallbackRest(Tcl_Obj* obj) : m_list(obj) {}

	Tcl_Obj* m_list;

	void entry(unsigned index, ::db::Player const& player) override
	{
		if (!isalpha(player.name().front()))
			Tcl_ListObjAppendElement(0, m_list, Tcl_NewIntObj(index));
	}
};

struct CallbackAll : public ::db::Player::PlayerCallback
{
	CallbackAll(Tcl_Obj* obj) : m_list(obj) {}

	Tcl_Obj* m_list;

	void entry(unsigned index, ::db::Player const& player) override
	{
		Tcl_ListObjAppendElement(0, m_list, Tcl_NewIntObj(index));
	}
};

}


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
cmdList(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	char		letter = toupper(*stringFromObj(objc, objv, 1));
	Tcl_Obj*	result = Tcl_NewListObj(0, 0);

	if (isalpha(letter))
	{
		CallbackLetter cb(result, letter);
		::db::Player::enumerate(cb);
	}
	else if (isspace(letter))
	{
		CallbackAll cb(result);
		::db::Player::enumerate(cb);
	}
	else
	{
		CallbackRest cb(result);
		::db::Player::enumerate(cb);
	}

	setResult(result);
	return TCL_OK;
}


static int
cmdInfo(ClientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Player const&	player = ::Player::getPlayer(unsignedFromObj(objc, objv, 1));

	Tcl_Obj* objs[12];
	Tcl_Obj* ratings[rating::Last];
	Tcl_Obj* titles[title::Last];
	int		numTitles = 0;
	char		sex;

	for (unsigned i = 0; i < rating::Last; ++i)
		ratings[i] = Tcl_NewIntObj(player.latestRating(rating::Type(i)));

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

	objs[ 0] = Tcl_NewStringObj(player.name(), player.name().size());
	objs[ 1] = Tcl_NewStringObj(country::toString(player.nativeCountry()), -1);
	objs[ 2] = Tcl_NewStringObj(country::toString(player.federation()), -1);
	objs[ 3] = Tcl_NewStringObj(&sex, 1);
	objs[ 4] = Tcl_NewStringObj(player.dateOfBirth().asShortString(), -1);
	objs[ 5] = Tcl_NewStringObj(player.dateOfDeath().asShortString(), -1);
	objs[ 6] = Tcl_NewListObj(numTitles, titles);
	objs[ 7] = Tcl_NewIntObj(player.fideID());
	objs[ 8] = Tcl_NewIntObj(player.iccfID());
	objs[ 9] = Tcl_NewStringObj(player.dsbID().asString(), -1);
	objs[10] = Tcl_NewStringObj(player.ecfID().asString(), -1);
	objs[11] = Tcl_NewListObj(U_NUMBER_OF(ratings), ratings);

	setResult(U_NUMBER_OF(objs), objs);
	return TCL_OK;
}


namespace tcl {
namespace player {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, CmdInfo,	cmdInfo);
	createCommand(ti, CmdList,	cmdList);
}

} // namespace player
} // namespace tcl

// vi:set ts=3 sw=3:
