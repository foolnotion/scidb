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

#include "m_assert.h"
#include "m_utility.h"

namespace db {

inline Player::DsbID::operator uint32_t() const { return value; }
inline Player::EcfID::operator uint32_t() const { return value; }

inline void Player::setFederation(country::Code federation)		{ m_federation = federation; }
inline void Player::setNativeCountry(country::Code country)		{ m_nativeCountry = country; }
inline void Player::setFideID(unsigned id)							{ m_fideID = id; }
inline void Player::setIccfID(unsigned id)							{ m_iccfID = id; }
inline void Player::setSex(sex::ID id)									{ m_sex = id; }
inline void Player::setType(species::ID id)							{ m_species = id; }
inline void Player::setChess960Flag(bool flag)						{ m_chess960 = flag; }
inline void Player::setShuffleChessFlag(bool flag)					{ m_shuffle = flag; }
inline void Player::setBughouseChessFlag(bool flag)				{ m_bughouse = flag; }
inline void Player::setCrazyhouseChessFlag(bool flag)				{ m_crazyhouse = flag; }
inline void Player::setLosersChessFlag(bool flag)					{ m_losers = flag; }
inline void Player::setSuicideChessFlag(bool flag)					{ m_suicide = flag; }
inline void Player::setGiveawayChessFlag(bool flag)				{ m_giveaway = flag; }
inline void Player::setThreeCheckChessFlag(bool flag)				{ m_threeCheck = flag; }
inline void Player::setWinboardProtocol(bool flag)					{ m_winboard = flag; }
inline void Player::setUciProtocol(bool flag)						{ m_uci = flag; }
inline void Player::setUnique(bool flag)								{ m_notUnique = !flag; }
inline void Player::setEcfID(EcfID id)									{ m_ecfId = id; }
inline void Player::setDsbID(DsbID id)									{ m_dsbId = id; }

inline bool Player::supportsUciProtocol() const						{ return m_uci; }
inline bool Player::supportsWinboardProtocol() const				{ return m_winboard; }
inline bool Player::supportsChess960() const							{ return m_chess960; }
inline bool Player::supportsShuffleChess() const					{ return m_shuffle; }
inline bool Player::supportsBughouseChess() const					{ return m_bughouse; }
inline bool Player::supportsCrazyhouseChess() const				{ return m_crazyhouse; }
inline bool Player::supportsLosersChess() const						{ return m_losers; }
inline bool Player::supportsSuicideChess() const					{ return m_suicide; }
inline bool Player::supportsGiveawayChess() const					{ return m_giveaway; }
inline bool Player::supportsThreeCheckChess() const				{ return m_threeCheck; }

inline sex::ID Player::sex() const						{ return sex::ID(m_sex); }
inline species::ID Player::type() const				{ return species::ID(m_species); }
inline mstl::string const& Player::name() const		{ return m_name; }
inline unsigned Player::titles() const					{ return m_titles; }
inline country::Code Player::federation() const		{ return country::Code(m_federation); }
inline country::Code Player::nativeCountry() const	{ return country::Code(m_nativeCountry); }
inline unsigned Player::fideID() const					{ return m_fideID; }
inline unsigned Player::iccfID() const					{ return m_iccfID; }
inline int16_t Player::highestElo() const				{ return m_highestRating[rating::Elo]; }
inline int16_t Player::latestElo() const				{ return m_latestRating[rating::Elo]; }
inline bool Player::isEngine() const					{ return m_species == species::Program; }
inline bool Player::isUnique() const					{ return !m_notUnique; }
inline bool Player::isNotUnique() const				{ return m_notUnique; }
inline uint16_t Player::birthYear() const				{ return m_birthYear; }
inline uint16_t Player::deathYear() const				{ return m_deathYear; }
inline unsigned Player::region() const					{ return m_region; }
inline Player::EcfID Player::ecfID() const			{ return m_ecfId; }
inline Player::DsbID Player::dsbID() const			{ return m_dsbId; }


inline
void
Player::addTitle(title::ID title)
{
	M_REQUIRE(title != title::Last);

	if (title != title::None)
	{
		m_titles |= fromID(title);
		m_titles &= ~title::Mask_None;
	}
}


inline
void
Player::setTitles(unsigned titles)
{
	M_REQUIRE(titles < (1 << (title::Last)));

	if (titles & title::Mask_Any)
	{
		m_titles = titles;
		m_titles &= ~title::Mask_None;
	}
}


inline
Date
Player::dateOfBirth() const
{
	return Date(m_birthYear, m_birthMonth, m_birthDay);
}


inline
Date
Player::dateOfDeath() const
{
	return Date(m_deathYear, m_deathMonth, m_deathDay);
}


inline
void
Player::setDateOfBirth(Date const& date)
{
	m_birthYear = date.year();
	m_birthMonth = date.month();
	m_birthDay = date.day();
}


inline
void
Player::setDateOfDeath(Date const& date)
{
	m_deathYear = date.year();
	m_deathMonth = date.month();
	m_deathDay = date.day();
}


inline
Player*
Player::findEngine(mstl::string const& name)
{
	Player* p = findPlayer(name);
	return p && p->type() == species::Program ? p : 0;
}


inline
rating::Type
Player::ratingType() const
{
	if (m_ratingType != rating::Any)
		return rating::Type(m_ratingType);

	if (m_highestRating[rating::Elo])
		return rating::Elo;

	return rating::Any;
}


inline
int16_t
Player::highestRating() const
{
	return m_ratingType == rating::Last ? 0 : m_highestRating[m_ratingType];
}


inline
int16_t
Player::latestRating() const
{
	return m_ratingType == rating::Last ? 0 : m_latestRating[m_ratingType];
}


inline
int16_t
Player::highestRating(rating::Type type) const
{
	if (type != rating::Any)
		return m_highestRating[type];

	if (m_ratingType != rating::Any)
		return m_highestRating[m_ratingType];

	return m_highestRating[rating::Elo];
}


inline
int16_t
Player::latestRating(rating::Type type) const
{
	if (type != rating::Any)
		return m_latestRating[type];

	if (m_ratingType != rating::Any)
		return m_latestRating[m_ratingType];

	return m_latestRating[rating::Elo];
}


inline
void
Player::setHighestElo(int16_t rating)
{
	M_REQUIRE(mstl::abs(rating) <= rating::Max_Value);
	m_highestRating[rating::Elo] = rating;
}


inline
void
Player::setLatestElo(int16_t rating)
{
	M_REQUIRE(mstl::abs(rating) <= rating::Max_Value);
	m_latestRating[rating::Elo] = rating;
}


inline
void
Player::setHighestRating(rating::Type type, int16_t rating)
{
	M_REQUIRE(type != rating::Any);
	M_REQUIRE(mstl::abs(rating) <= rating::Max_Value);

	if (rating)
	{
		m_highestRating[type] = rating;

		if (type != rating::Elo)
			m_ratingType = mstl::min(rating::Type(m_ratingType), type);
	}
}


inline
void
Player::setLatestRating(rating::Type type, int16_t rating)
{
	M_REQUIRE(type != rating::Any);
	M_REQUIRE(mstl::abs(rating) <= rating::Max_Value);

	if (rating)
	{
		m_latestRating[type] = rating;

		if (type != rating::Elo)
			m_ratingType = mstl::min(rating::Type(m_ratingType), type);
	}
}

} // namespace db

// vi:set ts=3 sw=3:
