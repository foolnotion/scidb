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

#include "u_match.h"

#include "m_utility.h"
#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace app;
using namespace db;


struct Arg
{
	Arg(rating::Type rt, order::ID order)
		:ratingType(rt)
		,signum(order == order::Ascending ? +1 : -1)
	{
	}

	rating::Type	ratingType;
	int				signum;
};


struct CompareAsciiName
{
	CompareAsciiName(order::ID order) :m_signum(order::signum(order)) {}
	int m_signum;

	int operator()(unsigned lhs, unsigned rhs)
	{
		return m_signum*mstl::case_compare(	Player::getPlayer(lhs).asciiName(),
														Player::getPlayer(rhs).asciiName());
	}
};

struct CompareLatestScore
{
	CompareLatestScore(order::ID order, db::rating::Type rt) :m_signum(order::signum(order)), m_rt(rt) {}

	int m_signum;
	db::rating::Type m_rt;

	int operator()(unsigned lhs, unsigned rhs)
	{
		return m_signum*mstl::compare(Player::getPlayer(lhs).latestRating(m_rt),
												Player::getPlayer(rhs).latestRating(m_rt));
	}
};

struct CompareTitles
{
	CompareTitles(order::ID order) :m_sig(order::signum(order)) {}
	int m_sig;

	int operator()(unsigned lhs, unsigned rhs)
	{
		Player const& lp = Player::getPlayer(lhs);
		Player const& rp = Player::getPlayer(rhs);

		int cmp = mstl::compare(lp.title(), rp.title());

#if 0
		if (cmp == 0)
			cmp = mstl::compare(lp.title2(), rp.title2());
#endif

		return m_sig*cmp;
	}
};


#define MAKE_COMP_STRUCT(Attr, Accessor) \
	struct Compare##Attr \
	{ \
		Compare##Attr(order::ID order) :m_sig(order::signum(order)) {} \
		int m_sig; \
		int operator()(unsigned lhs, unsigned rhs) \
		{ \
			return m_sig*mstl::compare(Player::getPlayer(lhs).Accessor, Player::getPlayer(rhs).Accessor); \
		} \
	};


MAKE_COMP_STRUCT(FideID, fideID())
MAKE_COMP_STRUCT(DsbID, dsbID().value)
MAKE_COMP_STRUCT(EcfID, ecfID().value)
MAKE_COMP_STRUCT(IccfID, iccfID())
MAKE_COMP_STRUCT(Type, type())
MAKE_COMP_STRUCT(Sex, sex())
MAKE_COMP_STRUCT(DateOfBirth, dateOfBirth())
MAKE_COMP_STRUCT(DateOfDeath, dateOfDeath())
MAKE_COMP_STRUCT(Federation, federation())
MAKE_COMP_STRUCT(NativeCountry, nativeCountry())
MAKE_COMP_STRUCT(Frequency, frequency())


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
PlayerDictionary::search(util::Pattern const& namePattern, unsigned startIndex) const
{
	if (count() == 0)
		return -1;

	unsigned numEntries = m_selector.size();

	unsigned k = 0;
	unsigned i = 0;

	if (startIndex < numEntries)
	{
		for ( ; k < startIndex; ++i)
		{
			if (m_filter.test(m_selector[i]))
				++k;
		}
	}
	else
	{
		i = mstl::min(startIndex, numEntries);
	}
	
	unsigned n = i == 0 ? numEntries : i - 1;

	while (true)
	{
		if (i == numEntries)
			i = k = 0;

		unsigned index = m_selector[i];

		if (m_filter.test(index))
		{
			if (namePattern.match(Player::getPlayer(index).asciiName()))
				return k;

			++k;
		}

		if (++i == n)
			break;
	}

	return -1;
}


void
PlayerDictionary::sort(Attribute attr, order::ID order, rating::Type ratingType)
{
	switch (attr)
	{
		case Name:				m_selector.qsort(::CompareAsciiName(order)); break;
		case FideID:			m_selector.qsort(::CompareFideID(order)); break;
		case DsbId:				m_selector.qsort(::CompareDsbID(order)); break;
		case EcfId:				m_selector.qsort(::CompareEcfID(order)); break;
		case IccfId:			m_selector.qsort(::CompareIccfID(order)); break;
		case Type:				m_selector.qsort(::CompareType(order)); break;
		case Sex:				m_selector.qsort(::CompareSex(order)); break;
		case DateOfBirth:		m_selector.qsort(::CompareDateOfBirth(order)); break;
		case DateOfDeath:		m_selector.qsort(::CompareDateOfDeath(order)); break;
		case Federation:		m_selector.qsort(::CompareFederation(order)); break;
		case Titles:			m_selector.qsort(::CompareTitles(order)); break;
		case NativeCountry:	m_selector.qsort(::CompareNativeCountry(order)); break;
		case Frequency:		m_selector.qsort(::CompareFrequency(order)); break;
		case LatestRating:	m_selector.qsort(::CompareLatestScore(order, ratingType)); break;
	}
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
PlayerDictionary::filterName(Operator op, util::Pattern const& pattern)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if ((pattern.matchAny() || pattern.matchNone()) && positive)
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
PlayerDictionary::filterTitles(Operator op, unsigned titles, uint16_t minYear, uint16_t maxYear)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (titles)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i))
			{
				Player const& player = Player::getPlayer(i);

				if (minYear == 0)
				{
					unsigned t = title::fromID(player.title()); // | title::fromID(player.title2());

					if (bool(t & titles) == positive)
						(m_attrFilter.*setter)(i);
				}
#if 0
				else if (player.title() != title::None)
				{
					unsigned title = title::fromID(player.title());

					if ((	bool(titles & title)
						&& (	!bool(title & title::Mask_Fide)
							|| mstl::is_between(player.titleYear(), minYear, maxYear))) == positive)
					{
						(m_attrFilter.*setter)(i);
					}
					else if (player.title2() != title::None)
					{
						unsigned title = title::fromID(player.title2());

						if ((	bool(titles & title)
							&& (	!bool(title & title::Mask_Fide)
								|| mstl::is_between(player.title2Year(), minYear, maxYear))) == positive)
						{
							(m_attrFilter.*setter)(i);
						}
					}
				}
#endif
			}
		}
	}
}


void
PlayerDictionary::filterOrganization(Operator op, organization::ID organization)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	if (organization != organization::Unspecified)
	{
		for (unsigned i = 0; i < m_attrFilter.size(); ++i)
		{
			if (m_baseFilter.test(i) && (Player::getPlayer(i).hasID(organization) == positive))
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


void
PlayerDictionary::filterFrequency(Operator op, unsigned minFrequency, unsigned maxFrequency)
{
	Setter	setter(&mstl::bitset::set); // g++ complains w/o initialization
	bool		positive = prepareForOp(op, setter);

	for (unsigned i = 0; i < m_attrFilter.size(); ++i)
	{
		if (	m_baseFilter.test(i)
			&& mstl::is_between(Player::getPlayer(i).frequency(), minFrequency, maxFrequency) == positive)
		{
			(m_attrFilter.*setter)(i);
		}
	}
}

// vi:set ts=3 sw=3:
