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

#ifndef db_player_included
#define db_player_included

#include "db_common.h"
#include "db_date.h"

#include "m_string.h"
#include "m_list.h"
#include "m_vector.h"
#include "m_pair.h"

namespace mstl { class istream; }
namespace TeXt { class Receptacle; }

namespace db {

class Namebase;
class NamebasePlayer;
class PlayerStats;

class Player
{
public:

	class PlayerCallback
	{
	public:

		virtual ~PlayerCallback();
		virtual void entry(unsigned index, Player const& player) = 0;
	};

	struct DsbID
	{
		DsbID();
		DsbID(char const* zps, char const* nr);

		operator uint32_t() const;

		void setup(char const* zps, char const* nr);
		mstl::string asString() const;

		union
		{
			struct
			{
				uint32_t zpsPrefix:5;	// 1. digit (0-9, A-L)
				uint32_t zpsSuffix:14;	// 4 digits
				uint32_t dsbMglNr	:11;	// 0..2000
			};

			uint32_t value;
		};
	};

	struct EcfID
	{
		EcfID();
		EcfID(char const* id);

		operator uint32_t() const;

		void setup(char const* id);
		mstl::string asString() const;

		union
		{
			struct
			{
				uint32_t prefix:19;	// 6 digits
				uint32_t suffix:4;	// A-L
			};

			uint32_t value;
		};
	};

	typedef mstl::pair<mstl::string,mstl::string> Assoc;
	typedef mstl::list<Assoc> AssocList;
	typedef mstl::vector<mstl::string> StringList;
	typedef mstl::vector<Player const*> Matches;

	/// Construct an empty player.
	Player();

	/// Returns whether player is an engine.
	bool isEngine() const;
	/// Returns whether player name is an unique name (not an ordinary last name).
	bool isUnique() const;
	/// Returns whether player name is an ordinary last name.
	bool isNotUnique() const;
	/// Returns whether UCI protocol is supported.
	bool supportsUciProtocol() const;
	/// Returns whether Winboard protocol is supported.
	bool supportsWinboardProtocol() const;
	/// Return whether Chess 960 is supported.
	bool supportsChess960() const;
	/// Return whether Shuffle Chess is supported.
	bool supportsShuffleChess() const;
	/// Return whether Bughouse Chess is supported.
	bool supportsBughouseChess() const;
	/// Return whether Crazyhouse Chess is supported.
	bool supportsCrazyhouseChess() const;
	/// Return whether Losers Chess is supported.
	bool supportsLosersChess() const;
	/// Return whether Suicide Chess is supported.
	bool supportsSuicideChess() const;
	/// Return whether Giveaway Chesss is supported.
	bool supportsGiveawayChess() const;
	/// Return whether Three-Check Chesss is supported.
	bool supportsThreeCheckChess() const;
	/// Returns whether given federation ID exists.
	bool hasID(federation::ID federation) const;

	/// Returns players name.
	mstl::string const& name() const;
	/// Return sex of player.
	sex::ID sex() const;
	/// Return type of player.
	species::ID type() const;
	/// Returns players date of birth, if known.
	Date dateOfBirth() const;
	/// Return players date of death, if known.
	Date dateOfDeath() const;
	/// Return players year of birth, if known.
	uint16_t birthYear() const;
	/// Return players year of death, if known.
	uint16_t deathYear() const;
	/// Returns players highest overall Elo rating achieved (< 0 if estimated).
	int16_t highestElo() const;
	/// Returns players latest Elo rating achieved  (< 0 if estimated).
	int16_t latestElo() const;
	/// Returns players highest overall rating achieved (< 0 if estimated).
	int16_t highestRating() const;
	/// Returns players latest rating achieved  (< 0 if estimated).
	int16_t latestRating() const;
	/// Returns players highest overall rating achieved (< 0 if estimated).
	int16_t highestRating(rating::Type type) const;
	/// Returns players latest rating achieved  (< 0 if estimated).
	int16_t latestRating(rating::Type type) const;
	/// Returns (best) rating type available (rating::Last if none available)
	rating::Type ratingType() const;
	/// Returns titles of player.
	unsigned titles() const;
	/// Returns federation of player.
	country::Code federation() const;
	/// Returns native country of player.
	country::Code nativeCountry() const;
	/// Return FIDE player ID.
	unsigned fideID() const;
	/// Return DSB player ID.
	DsbID dsbID() const;
	/// Return ECF player ID.
	EcfID ecfID() const;
	/// Return ICCF player ID.
	unsigned iccfID() const;
	/// Return wanted federation id (empty string id not exisiting)
	mstl::string federationID(federation::ID federation) const;
	/// Return VIAF (Virtual International Authority File) ID.
	unsigned viafID() const;
	/// Return PND (Personennamendatei) ID.
	mstl::string pndID() const;
	/// Return chessgames.com identifier
	mstl::string const& chessgamesID() const;
	/// Return wikipedia URL (if existing)
	unsigned wikipediaLinks(AssocList& result) const;
	/// Return list of aliases.
	StringList const& aliases() const;
	/// Returns asciified players name.
	mstl::string const& asciiName() const;
	/// Return region code of player name.
	unsigned region() const;
	//// Return URL of given player (chess engine).
	mstl::string const& url() const;

	void setSex(sex::ID id);
	void setType(species::ID id);
	void setDateOfBirth(Date const& date);
	void setDateOfDeath(Date const& date);
	void setHighestElo(int16_t rating);
	void setLatestElo(int16_t rating);
	void setHighestRating(rating::Type type, int16_t rating);
	void setLatestRating(rating::Type type, int16_t rating);
	void setTitles(unsigned titles);
	void addTitle(title::ID title);
	void setFederation(country::Code federation);
	void setNativeCountry(country::Code country);
	void setFideID(unsigned id);
	void setEcfID(EcfID id);
	void setDsbID(DsbID id);
	void setIccfID(unsigned id);
	void setViafID(unsigned id);
	void setPndID(char const* id);
	void setChess960Flag(bool flag);
	void setShuffleChessFlag(bool flag);
	void setBughouseChessFlag(bool flag);
	void setCrazyhouseChessFlag(bool flag);
	void setLosersChessFlag(bool flag);
	void setSuicideChessFlag(bool flag);
	void setGiveawayChessFlag(bool flag);
	void setThreeCheckChessFlag(bool flag);
	void setWinboardProtocol(bool flag);
	void setUciProtocol(bool flag);
	void setUnique(bool flag);

	static bool isNormalized(mstl::string const& name);
	static bool containsPlayer(mstl::string const& name, country::Code country, sex::ID sex);

	static Player const& getPlayer(unsigned index);
	static Player* findPlayer(	mstl::string const& name,
										country::Code federation = country::Unknown,
										sex::ID sex = sex::Unspecified);
	static Player* findPlayer(	mstl::string const& name,
										country::Code federation,
										Date const& birthDate,
										species::ID type,
										sex::ID sex);
	static Player* findEngine(mstl::string const& name);
	static Player* findFidePlayer(uint32_t fideID);
	static Player* findIccfPlayer(uint32_t iccfID);
	static Player* findDsbPlayer(DsbID dsbID);
	static Player* findEcfPlayer(EcfID ecfID);
	static mstl::string& normalize(mstl::string& name);
	static mstl::string& normalize(mstl::string const& name, mstl::string& result);
	static void standardizeNames(mstl::string& name);
	static unsigned findMatches(mstl::string const& name, Matches& result, unsigned maxMatches);
	static unsigned countPlayers();
	static Player* insertPlayer(uint32_t fideID, mstl::string const& name);
	static void enumerate(PlayerCallback& cb);

	static void parseSpellcheckFile(mstl::istream& stream);
	static void parseFideRating(mstl::istream& stream);
	static void parseEcfRating(mstl::istream& stream);
	static void parseDwzRating(mstl::istream& stream);
	static void parseIpsRatingList(mstl::istream& stream);
	static void parseIccfRating(mstl::istream& stream);
	static void parseWikipediaLinks(mstl::istream& stream);
	static void parseChessgamesDotComLinks(mstl::istream& stream);
	static void parseComputerList(mstl::istream& stream);
	static void loadDone();

	static void emitPlayerCard(TeXt::Receptacle& receptacle,
										NamebasePlayer const& player,
										PlayerStats const& stats);

	static void dump();

private:

	Player(Player const&);
	Player& operator=(Player const&);

	friend class Namebase;

	static Player* newPlayer(	mstl::string const& name,
										unsigned region,
										mstl::string const& ascii,
										country::Code federation = country::Unknown,
										sex::ID sex = sex::Unspecified);
	static bool newAlias(mstl::string const& name, mstl::string const& ascii, Player* player);
	static bool replaceName(mstl::string const& name, mstl::string const& ascii, Player* player);

	static Player* insertPlayer(	mstl::string& name,
											country::Code federation = country::Unknown,
											sex::ID sex = sex::Unspecified);
	static Player* insertPlayer(	mstl::string& name,
											unsigned region,
											country::Code federation = country::Unknown,
											sex::ID sex = sex::Unspecified);
	static bool insertAlias(mstl::string& name, Player* player);
	static bool insertAlias(mstl::string& name, unsigned region, Player* player);
	static bool replaceName(mstl::string& name, unsigned region, Player* player);

	typedef int16_t Ratings[rating::Last];

	mstl::string m_name;

	Ratings m_highestRating;
	Ratings m_latestRating;

	uint32_t m_titles			:14;
	uint32_t m_birthYear		:11;
	uint32_t m_deathMonth	:4;
	uint32_t m_sex				:2;

	uint32_t m_deathYear		:11;
	uint32_t m_nativeCountry:9;
	uint32_t m_birthDay		:5;
	uint32_t m_birthMonth	:4;
	uint32_t m_species		:2;
	uint32_t m_notUnique		:1;

	uint32_t m_federation	:9;
	uint32_t m_deathDay		:5;
	uint32_t m_ratingType	:4;
	uint32_t m_region			:3;
	uint32_t m_chess960		:1;
	uint32_t m_shuffle		:1;
	uint32_t m_bughouse		:1;
	uint32_t m_crazyhouse	:1;
	uint32_t m_losers			:1;
	uint32_t m_suicide		:1;
	uint32_t m_giveaway		:1;
	uint32_t m_threeCheck	:1;
	uint32_t m_winboard		:1;
	uint32_t m_uci				:1;
	// rest: 1

	uint32_t	m_fideID;	// 100.000..40.000.000
	uint32_t	m_iccfID;	// 10.000..1.000.000
	DsbID		m_dsbId;
	EcfID		m_ecfId;

	static unsigned m_minELO;
	static unsigned m_minDWZ;
	static unsigned m_minECF;
	static unsigned m_minICCF;
};

} // namespace db

#include "db_player.ipp"

#endif // _db_player_included

// vi:set ts=3 sw=3:
