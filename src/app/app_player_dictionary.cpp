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

#include "app_player_dictionary.h"

#include "db_player.h"
#include "db_query.h"
#include "db_date.h"

#include "m_utility.h"

#include <string.h>
#include <stdlib.h>

using namespace app;
using namespace db;


#define PLAYER(p) Player::getPlayer(*reinterpret_cast<unsigned const*>(p))


static int
cmpName(void const* lhs, void const* rhs)
{
	return ::strcasecmp(PLAYER(lhs).asciiName(), PLAYER(rhs).asciiName());
}

static int
cmpFideID(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).fideID()) - int(PLAYER(rhs).fideID());
}

static int
cmpDsbId(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).dsbID().value) - int(PLAYER(rhs).dsbID().value);
}

static int
cmpEcfId(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).ecfID().value) - int(PLAYER(rhs).ecfID().value);
}

static int
cmpIccfId(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).iccfID()) - int(PLAYER(rhs).iccfID());
}

static int
cmpType(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).type()) - int(PLAYER(rhs).type());
}

static int
cmpSex(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).sex()) - int(PLAYER(rhs).sex());
}

static int
cmpDateOfBirth(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).dateOfBirth().compare(PLAYER(rhs).dateOfBirth());
}

static int
cmpDateOfDeath(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).dateOfDeath().compare(PLAYER(rhs).dateOfDeath());
}

static int
cmpFederation(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).federation()) - int(PLAYER(rhs).federation());
}

static int
cmpNativeCountry(void const* lhs, void const* rhs)
{
	return int(PLAYER(lhs).nativeCountry()) - int(PLAYER(rhs).nativeCountry());
}

static int
cmpLatestElo(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::Elo) - PLAYER(rhs).latestRating(rating::Elo);
}

static int
cmpLatestRating(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::Rating) - PLAYER(rhs).latestRating(rating::Rating);
}

static int
cmpLatestRapid(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::Rapid) - PLAYER(rhs).latestRating(rating::Rapid);
}

static int
cmpLatestICCF(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::ICCF) - PLAYER(rhs).latestRating(rating::ICCF);
}

static int
cmpLatestUSCF(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::USCF) - PLAYER(rhs).latestRating(rating::USCF);
}

static int
cmpLatestDWZ(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::DWZ) - PLAYER(rhs).latestRating(rating::DWZ);
}

static int
cmpLatestECF(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::ECF) - PLAYER(rhs).latestRating(rating::ECF);
}

static int
cmpLatestIPS(void const* lhs, void const* rhs)
{
	return PLAYER(lhs).latestRating(rating::IPS) - PLAYER(rhs).latestRating(rating::IPS);
}


static bool
match(char const* pattern, char const* s)
{
	while (true)
	{
		switch (*pattern)
		{
			case '\0':
				return *s == '\0';

			case '?':
				if (*s == '\0')
					return false;
				break;

			case '*':
				while (*s)
				{
					if (match(pattern + 1, s))
						return true;
					++s;
				}
				return *pattern == '\0';

			default:
				if (*pattern != *s)
					return false;
				break;
		}

		++pattern;
		++s;
	}

	return false;
}


PlayerDictionary::PlayerDictionary(Mode mode)
	:m_baseFilter(Player::countPlayers())
{
	m_selector.resize(Player::countPlayers());

	switch (mode)
	{
		case EnginesOnly:
			for (unsigned i = 0; i < m_baseFilter.size(); ++i)
			{
				if (Player::getPlayer(i).isEngine())
					m_baseFilter.set(i);
			}
			break;

		case PlayersOnly:
			for (unsigned i = 0; i < m_baseFilter.size(); ++i)
			{
				if (!Player::getPlayer(i).isEngine())
					m_baseFilter.set(i);
			}
			break;

		case All:
			m_baseFilter.set();
			break;
	}

	m_filter = m_baseFilter;
	m_count = m_filter.count();

	for (unsigned i = 0; i < m_selector.size(); ++i)
		m_selector[i] = i;
}


Player const&
PlayerDictionary::getPlayer(unsigned number) const
{
	unsigned index;

	if (number <= mstl::div2(m_filter.size()))
		index = m_filter.index(number);
	else
		index = m_filter.rindex(m_filter.size() - number - 1);

	return Player::getPlayer(index);
}


void
PlayerDictionary::sort(Attribute attr)
{
	typedef int (*Compare)(void const*, void const*);

	Compare cmpFunc;

	switch (attr)
	{
		case Name:				cmpFunc = ::cmpName; break;
		case FideID:			cmpFunc = ::cmpFideID; break;
		case DsbId:				cmpFunc = ::cmpDsbId; break;
		case EcfId:				cmpFunc = ::cmpEcfId; break;
		case IccfId:			cmpFunc = ::cmpIccfId; break;
		case Type:				cmpFunc = ::cmpType; break;
		case Sex:				cmpFunc = ::cmpSex; break;
		case DateOfBirth:		cmpFunc = ::cmpDateOfBirth;; break;
		case DateOfDeath:		cmpFunc = ::cmpDateOfDeath;; break;
		case Federation:		cmpFunc = ::cmpFederation; break;
		case NativeCountry:	cmpFunc = ::cmpNativeCountry; break;
		case LatestElo:		cmpFunc = ::cmpLatestElo; break;
		case LatestRating:	cmpFunc = ::cmpLatestRating; break;
		case LatestRapid:		cmpFunc = ::cmpLatestRapid; break;
		case LatestICCF:		cmpFunc = ::cmpLatestICCF; break;
		case LatestUSCF:		cmpFunc = ::cmpLatestUSCF; break;
		case LatestDWZ:		cmpFunc = ::cmpLatestDWZ; break;
		case LatestECF:		cmpFunc = ::cmpLatestECF; break;
		case LatestIPS:		cmpFunc = ::cmpLatestIPS; break;
	}

	::qsort(m_selector.begin(), m_selector.size(), sizeof(Selector::value_type), cmpFunc);
}


void
PlayerDictionary::reset()
{
	m_filter = m_baseFilter;
	m_count = m_filter.count();
}


bool
PlayerDictionary::prepareForOp(Operator op, Setter& setter)
{
	switch (op)
	{
		case Null:
			m_filter.reset();
			// fallthru

		case Or:
			setter = &mstl::bitset::set;
			return false;

		case And:
			setter = &mstl::bitset::reset;
			return true;

		case Reset:
			m_filter = m_baseFilter;
			// fallthru

		case Remove:
			setter = &mstl::bitset::reset;
			return false;

		case Not:
			setter = &mstl::bitset::reset;
			return true;
	}

	return false; // satisfies the compiler
}


void
PlayerDictionary::filterName(Operator op, mstl::string const& pattern)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if (::match(pattern, Player::getPlayer(i).asciiName()) == positive)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterFederation(Operator op, country::Code country)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	if (country != country::Unknown)
	{
		for (unsigned i = 0; i < m_filter.size(); ++i)
		{
			if ((Player::getPlayer(i).federation() == country) == positive)
				(m_filter.*setter)(i);
		}
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterNativeCountry(Operator op, country::Code country)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	if (country != country::Unknown)
	{
		for (unsigned i = 0; i < m_filter.size(); ++i)
		{
			if ((Player::getPlayer(i).nativeCountry() == country) == positive)
				(m_filter.*setter)(i);
		}
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterType(Operator op, species::ID type)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	if (type != species::Unspecified)
	{
		for (unsigned i = 0; i < m_filter.size(); ++i)
		{
			if ((Player::getPlayer(i).type() == type) == positive)
				(m_filter.*setter)(i);
		}
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterSex(Operator op, sex::ID sex)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	if (sex != sex::Unspecified)
	{
		for (unsigned i = 0; i < m_filter.size(); ++i)
		{
			if ((Player::getPlayer(i).sex() == sex) == positive)
				(m_filter.*setter)(i);
		}
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterFideID(Operator op)
{
	Setter	setter;
	bool		negative = !prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if ((Player::getPlayer(i).fideID() == 0) == negative)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterIccfID(Operator op)
{
	Setter	setter;
	bool		negative = !prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if ((Player::getPlayer(i).iccfID() == 0) == negative)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterDsbID(Operator op)
{
	Setter	setter;
	bool		negative = !prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if ((Player::getPlayer(i).dsbID().value == 0) == negative)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterEcfID(Operator op)
{
	Setter	setter;
	bool		negative = !prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if ((Player::getPlayer(i).ecfID() == 0) == negative)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterScore(Operator op, ::db::rating::Type rating, uint16_t min, uint16_t max)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		uint16_t score = Player::getPlayer(i).latestRating(rating);

		if ((min <= score && score <= max) == positive)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterDateOfBirth(Operator op, ::db::Date const& min, ::db::Date const& max)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if (Player::getPlayer(i).dateOfBirth().isBetween(min, max) == positive)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}


void
PlayerDictionary::filterDateOfDeath(Operator op, ::db::Date const& min, ::db::Date const& max)
{
	Setter	setter;
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_filter.size(); ++i)
	{
		if (Player::getPlayer(i).dateOfDeath().isBetween(min, max) == positive)
			(m_filter.*setter)(i);
	}

	m_count = m_filter.count();
}

// vi:set ts=3 sw=3:
