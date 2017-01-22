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
#include "m_match.h"
#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace app;
using namespace db;


#define PLAYER(p) Player::getPlayer(*reinterpret_cast<unsigned const*>(p))

static int m_sign = 1;
static rating::Type m_rating = rating::Any;


static int
cmpName(void const* lhs, void const* rhs)
{
	return m_sign*::strcasecmp(PLAYER(lhs).asciiName(), PLAYER(rhs).asciiName());
}

static int
cmpFideID(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).fideID()) - int(PLAYER(rhs).fideID()));
}

static int
cmpDsbId(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).dsbID().value) - int(PLAYER(rhs).dsbID().value));
}

static int
cmpEcfId(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).ecfID().value) - int(PLAYER(rhs).ecfID().value));
}

static int
cmpIccfId(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).iccfID()) - int(PLAYER(rhs).iccfID()));
}

static int
cmpType(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).type()) - int(PLAYER(rhs).type()));
}

static int
cmpSex(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).sex()) - int(PLAYER(rhs).sex()));
}

static int
cmpDateOfBirth(void const* lhs, void const* rhs)
{
	return m_sign*PLAYER(lhs).dateOfBirth().compare(PLAYER(rhs).dateOfBirth());
}

static int
cmpDateOfDeath(void const* lhs, void const* rhs)
{
	return m_sign*PLAYER(lhs).dateOfDeath().compare(PLAYER(rhs).dateOfDeath());
}

static int
cmpFederation(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).federation()) - int(PLAYER(rhs).federation()));
}

static int
cmpNativeCountry(void const* lhs, void const* rhs)
{
	return m_sign*(int(PLAYER(lhs).nativeCountry()) - int(PLAYER(rhs).nativeCountry()));
}

static int
cmpLatestScore(void const* lhs, void const* rhs)
{
	return m_sign*(	mstl::max(int16_t(0), PLAYER(lhs).latestRating(m_rating))
						 - mstl::max(int16_t(0), PLAYER(rhs).latestRating(m_rating)));
}


static int
cmpTitles(void const* lhs, void const* rhs)
{
	return m_sign*(int(title::best(PLAYER(lhs).titles())) - int(title::best(PLAYER(rhs).titles())));
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

	m_filter = m_nameFilter = m_attrFilter = m_baseFilter;
	m_count = m_filter.count();

	for (unsigned i = 0; i < m_selector.size(); ++i)
		m_selector[i] = i;

	m_map = m_selector;
}


Player const&
PlayerDictionary::getPlayer(unsigned number) const
{
	M_REQUIRE(number < count());
	return Player::getPlayer(m_map[number]);
}


int
PlayerDictionary::search(mstl::string const& name) const
{
	if (name.empty())
		return 0;

	char letter = ::toupper(name.front());

	for (unsigned i = 0, k = 0; i < m_selector.size(); ++i)
	{
		unsigned index = m_selector[i];

		if (m_filter.test(index))
		{
			char const* s = Player::getPlayer(index).asciiName();

			if (*s == letter && ::strncasecmp(name, s, name.size()) == 0)
				return k;

			++k;
		}
	}

	return -1;
}


void
PlayerDictionary::sort(Attribute attr, ::db::order::ID order)
{
	typedef int (*Compare)(void const*, void const*);

	Compare cmpFunc = ::cmpLatestScore;

	switch (order)
	{
		case order::Ascending:	::m_sign = +1; break;
		case order::Descending:	::m_sign = -1; break;
	}

	switch (attr)
	{
		case Name:				cmpFunc = ::cmpName; break;
		case FideID:			cmpFunc = ::cmpFideID; break;
		case DsbId:				cmpFunc = ::cmpDsbId; break;
		case EcfId:				cmpFunc = ::cmpEcfId; break;
		case IccfId:			cmpFunc = ::cmpIccfId; break;
		case Type:				cmpFunc = ::cmpType; break;
		case Sex:				cmpFunc = ::cmpSex; break;
		case DateOfBirth:		cmpFunc = ::cmpDateOfBirth; break;
		case DateOfDeath:		cmpFunc = ::cmpDateOfDeath; break;
		case Federation:		cmpFunc = ::cmpFederation; break;
		case Titles:			cmpFunc = ::cmpTitles; break;
		case NativeCountry:	cmpFunc = ::cmpNativeCountry; break;
		case LatestElo:		::m_rating = rating::Elo; break;
		case LatestRating:	::m_rating = rating::Rating; break;
		case LatestRapid:		::m_rating = rating::Rapid; break;
		case LatestICCF:		::m_rating = rating::ICCF; break;
		case LatestUSCF:		::m_rating = rating::USCF; break;
		case LatestDWZ:		::m_rating = rating::DWZ; break;
		case LatestECF:		::m_rating = rating::ECF; break;
		case LatestIPS:		::m_rating = rating::IPS; break;
	}

	::qsort(m_selector.begin(), m_selector.size(), sizeof(Selector::value_type), cmpFunc);
}


void
PlayerDictionary::reverseOrder()
{
	unsigned n		= m_selector.size();
	unsigned mid	= mstl::div2(n);

	for (unsigned i = 0; i < mid; ++i)
		mstl::swap(m_selector[i], m_selector[n - i - 1]);
}


void
PlayerDictionary::cancelSort()
{
	for (unsigned i = 0; i < m_selector.size(); ++i)
		m_selector[i] = i;
}


void
PlayerDictionary::finishOperation()
{
	m_filter = m_nameFilter;
	m_filter &= m_attrFilter;
	m_count = m_filter.count();

	for (unsigned i = 0, k = 0; i < m_selector.size(); ++i)
	{
		unsigned index = m_selector[i];

		if (m_filter.test(index))
			m_map[k++] = index;
	}
}


void
PlayerDictionary::resetFilter()
{
	m_attrFilter = m_baseFilter;
}


void
PlayerDictionary::negateFilter()
{
	m_attrFilter.flip();
	m_attrFilter &= m_baseFilter;
}


bool
PlayerDictionary::prepareForOp(Operator op, Setter& setter)
{
	switch (op)
	{
		case Reset:
			m_attrFilter.reset();
			// fallthru

		case Or:
			setter = &mstl::bitset::set;
			return true;

		case And:
			setter = &mstl::bitset::reset;
			return false;

		case Null:
			m_attrFilter = m_baseFilter;
			// fallthru

		case Remove:
			setter = &mstl::bitset::reset;
			return true;

		case Not:
			setter = &mstl::bitset::set;
			return false;
	}

	return false; // satisfies the compiler
}


void
PlayerDictionary::filterLetter(char letter)
{
	if (letter == '\0')
	{
		m_nameFilter = m_baseFilter;
	}
	else
	{
		m_nameFilter.reset();

		for (unsigned i = 0; i < m_nameFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && ::toupper(*Player::getPlayer(i).asciiName().c_str()) == letter)
				m_nameFilter.set(i);
		}
	}
}


void
PlayerDictionary::filterName(Operator op, mstl::pattern const& pattern)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if ((pattern.match_any() || pattern.match_none()) && positive)
	{
		if (positive)
			m_attrFilter = m_baseFilter;
		else
			m_attrFilter.reset();
	}
	else
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && pattern.match(Player::getPlayer(i).asciiName()) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterFederation(Operator op, country::Code country)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (country != country::Unknown)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).federation() == country) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterNativeCountry(Operator op, country::Code country)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (country != country::Unknown)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).nativeCountry() == country) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterType(Operator op, species::ID type)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (type != species::Unspecified)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).type() == type) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterSex(Operator op, sex::ID sex)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (sex != sex::Unspecified)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).sex() == sex) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterTitles(Operator op, unsigned titles)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (titles)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && bool(Player::getPlayer(i).titles() & titles) == positive)
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterFederationID(Operator op, federation::ID federation)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (federation != federation::None)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).hasID(federation) == positive))
				(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterScore(Operator op, ::db::rating::Type rating, uint16_t min, uint16_t max)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_attrFilter.size(); ++i)
	{
		uint16_t score = Player::getPlayer(i).latestRating(rating);

		if (m_baseFilter.test(i) && (min <= score && score <= max) == positive)
			(m_attrFilter.*setter)(i);
	}
}


void
PlayerDictionary::filterBirthYear(Operator op, uint16_t minYear, uint16_t maxYear)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_attrFilter.size(); ++i)
	{
		if (	m_baseFilter.test(i)
			&& mstl::is_between(Player::getPlayer(i).birthYear(), minYear, maxYear) == positive)
		{
			(m_attrFilter.*setter)(i);
		}
	}
}


void
PlayerDictionary::filterDeathYear(Operator op, uint16_t minYear, uint16_t maxYear)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_attrFilter.size(); ++i)
	{
		if (	m_baseFilter.test(i)
			&& mstl::is_between(Player::getPlayer(i).deathYear(), minYear, maxYear) == positive)
		{
			(m_attrFilter.*setter)(i);
		}
	}
}

// vi:set ts=3 sw=3:
