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
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_selector.h"
#include "db_database.h"
#include "db_namebase.h"
#include "db_namebase_entry.h"
#include "db_date.h"
#include "db_player.h"
#include "db_filter.h"

#include "u_match.h"

#include "m_string.h"
#include "m_bit_functions.h"
#include "m_utility.h"
#include "m_algorithm.h"

#include "sys_utf8.h"

#include <string.h>

using namespace db;
using namespace db::color;

namespace game {

static int
compRound(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	if (l.round() == r.round())
		return mstl::compare(l.subround(), r.subround());

	return mstl::compare(l.round(), r.round());
}


static int
compAcv(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	return mstl::compare(l.countAnnotations() + l.countComments() + l.countVariations(),
								r.countAnnotations() + r.countComments() + r.countVariations());
}


static int
compRatingWhite(unsigned lhs, unsigned rhs, db::Database const& db, rating::Type type)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	return mstl::compare(mstl::abs(l.findRating(White, type)), mstl::abs(r.findRating(White, type)));
}


static int
compRatingBlack(unsigned lhs, unsigned rhs, db::Database const& db, rating::Type type)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	return mstl::compare(mstl::abs(l.findRating(Black, type)), mstl::abs(r.findRating(Black, type)));
}


static int
compWhiteAny(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	uint16_t eloL = mstl::abs(l.rating(White));
	uint16_t eloR = mstl::abs(r.rating(White));

	if (eloL == 0) eloL = mstl::abs(l.findElo(White));
	if (eloR == 0) eloR = mstl::abs(r.findElo(White));

	return mstl::compare(eloL, eloR);
}


static int
compBlackAny(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	uint16_t eloL = mstl::abs(l.rating(Black));
	uint16_t eloR = mstl::abs(r.rating(Black));

	if (eloL == 0) eloL = mstl::abs(l.findElo(Black));
	if (eloR == 0) eloR = mstl::abs(r.findElo(Black));

	return mstl::compare(eloL, eloR);
}


static int
compAverageElo(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	int lw = mstl::abs(l.findElo(White));
	int rw = mstl::abs(r.findElo(White));
	int lb = mstl::abs(l.findElo(Black));
	int rb = mstl::abs(r.findElo(Black));
	int av = lw + lb - rw - rb;

	return -(av ? av : mstl::compare(mstl::max(lw, lb), mstl::max(rw, rb)));
}


static int
compRatingAverage(unsigned lhs, unsigned rhs, db::Database const& db, rating::Type type)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	int lw = mstl::abs(l.findRating(White, type));
	int rw = mstl::abs(r.findRating(White, type));
	int lb = mstl::abs(l.findRating(Black, type));
	int rb = mstl::abs(r.findRating(Black, type));
	int av = lw + lb - rw - rb;

	return -(av ? av : mstl::compare(mstl::max(lw, lb), mstl::max(rw, rb)));
}


static int
compAverageAny(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& l = db.gameInfo(lhs);
	GameInfo const& r = db.gameInfo(rhs);

	int lw = mstl::abs(l.rating(White));
	int rw = mstl::abs(r.rating(White));
	int lb = mstl::abs(l.rating(Black));
	int rb = mstl::abs(r.rating(Black));

	if (lw == 0) lw = mstl::abs(l.findElo(White));
	if (rw == 0) rw = mstl::abs(r.findElo(White));
	if (lb == 0) lb = mstl::abs(l.findElo(Black));
	if (rb == 0) rb = mstl::abs(r.findElo(Black));

	int av = lw + lb - rw - rb;

	return -(av ? av : mstl::compare(mstl::max(lw, lb), mstl::max(rw, rb)));
}


#define DEF_COMPARE_RATING(Color,Type) \
	static int comp##Color##Type(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return compRating##Color(lhs, rhs, db, rating::Type); \
	}
#define DEF_COMPARE(Type) \
	DEF_COMPARE_RATING(White,Type) \
	DEF_COMPARE_RATING(Black,Type) \
	\
	static int compAverage##Type(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return compRatingAverage(lhs, rhs, db, rating::Type); \
	}

DEF_COMPARE(DWZ)
DEF_COMPARE(ECF)
DEF_COMPARE(ICCF)
DEF_COMPARE(IPS)
DEF_COMPARE(Rapid)
DEF_COMPARE(Rating)
DEF_COMPARE(USCF)

#undef DEF_COMPARE_RATING
#undef DEF_COMPARE


static int
compMaterial(unsigned lhs, unsigned rhs, db::Database const& db)
{
	material::Signature ml = db.gameInfo(lhs).signature().material();
	material::Signature mr = db.gameInfo(rhs).signature().material();

	unsigned l, r;

	// white ---------------------------------

	l = mstl::bf::count_bits(ml.part[0].queen);
	r = mstl::bf::count_bits(mr.part[0].queen);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[0].rook);
	r = mstl::bf::count_bits(mr.part[0].rook);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[0].minor);
	r = mstl::bf::count_bits(mr.part[0].minor);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[0].pawn);
	r = mstl::bf::count_bits(mr.part[0].pawn);

	if (l < r)	return -1;
	if (l > r)	return  1;

	// black ---------------------------------

	l = mstl::bf::count_bits(ml.part[1].queen);
	r = mstl::bf::count_bits(mr.part[1].queen);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[1].rook);
	r = mstl::bf::count_bits(mr.part[1].rook);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[1].minor);
	r = mstl::bf::count_bits(mr.part[1].minor);

	if (l < r)	return -1;
	if (l > r)	return  1;

	l = mstl::bf::count_bits(ml.part[1].pawn);
	r = mstl::bf::count_bits(mr.part[1].pawn);

	if (l < r)	return -1;
	if (l > r)	return  1;

	// white ---------------------------------

	l = mstl::bf::count_bits(ml.part[0].bishop);
	r = mstl::bf::count_bits(mr.part[0].bishop);

	if (l < r)	return -1;
	if (l > r)	return  1;

	// black ---------------------------------

	l = mstl::bf::count_bits(ml.part[1].bishop);
	r = mstl::bf::count_bits(mr.part[1].bishop);

	if (l < r)	return -1;
	if (l > r)	return  1;

	return 0;
}


static int
compUserEco(unsigned lhs, unsigned rhs, db::Database const& db)
{
	GameInfo const& il = db.gameInfo(lhs);
	GameInfo const& ir = db.gameInfo(rhs);

	if (il.idn() != variant::Standard)
		return ir.idn() == variant::Standard;

	if (ir.idn() != variant::Standard)
		return -1;

	return mstl::compare(il.userEco(db.variant()), ir.userEco(db.variant()));
}


static int
compFlags(unsigned lhs, unsigned rhs, db::Database const& db)
{
	uint32_t fl = db.gameInfo(lhs).flags();
	uint32_t fr = db.gameInfo(rhs).flags();

	int nl = mstl::bf::count_bits(fl);
	int nr = mstl::bf::count_bits(fr);

	M_ASSERT(nl >= 0);
	M_ASSERT(nr >= 0);

	if (nl != nr)
		return nl - nr;

	return mstl::compare(mstl::bf::lsb_index(fl), mstl::bf::lsb_index(fr));
}


static int
compStandardPosition(unsigned lhs, unsigned rhs, db::Database const& db)
{
	variant::Type variant = db.variant();

	bool lhsStandard = db.gameInfo(lhs).hasStandardPosition(variant);
	bool rhsStandard = db.gameInfo(rhs).hasStandardPosition(variant);

	return mstl::compare(lhsStandard, rhsStandard);
}


static int
compWhiteCountry(unsigned lhs, unsigned rhs, db::Database const& db)
{
	return country::compare(db.gameInfo(lhs).findFederation(White),
									db.gameInfo(rhs).findFederation(White));
}


static int
compBlackCountry(unsigned lhs, unsigned rhs, db::Database const& db)
{
	return country::compare(db.gameInfo(lhs).findFederation(Black),
									db.gameInfo(rhs).findFederation(Black));
}


static int
compEco(unsigned lhs, unsigned rhs, db::Database const& db)
{
	variant::Type variant = db.variant();
	return mstl::compare(db.gameInfo(lhs).eco(variant), db.gameInfo(rhs).eco(variant));
}


#define DEF_COMPARE(Func,Accessor) \
	static int \
	comp##Func(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.gameInfo(lhs).Accessor, db.gameInfo(rhs).Accessor); \
	}

DEF_COMPARE(WhitePlayer, playerName(White))
DEF_COMPARE(BlackPlayer, playerName(Black))
DEF_COMPARE(WhiteFideID, fideID(White))
DEF_COMPARE(BlackFideID, fideID(Black))
DEF_COMPARE(Event, event())
DEF_COMPARE(Site, site())
DEF_COMPARE(Date, date())
DEF_COMPARE(Result, result())
DEF_COMPARE(Annotator, annotator())
DEF_COMPARE(EventCountry, eventCountry())
DEF_COMPARE(EventType, eventType())
DEF_COMPARE(EventDate, eventDate())
DEF_COMPARE(Length, plyCount())
DEF_COMPARE(WhiteElo, findElo(White))
DEF_COMPARE(BlackElo, findElo(Black))
DEF_COMPARE(WhiteTitle, findTitle(White))
DEF_COMPARE(BlackTitle, findTitle(Black))
DEF_COMPARE(WhiteSex, findSex(White))
DEF_COMPARE(BlackSex, findSex(Black))
DEF_COMPARE(WhiteType, findPlayerType(White))
DEF_COMPARE(BlackType, findPlayerType(Black))
DEF_COMPARE(WhiteRatingType, findRatingType(White))
DEF_COMPARE(BlackRatingType, findRatingType(Black))
DEF_COMPARE(Idn, idn())
DEF_COMPARE(Position, position())
DEF_COMPARE(Termination, terminationReason())
DEF_COMPARE(Mode, eventMode())
DEF_COMPARE(TimeMode, timeMode())
DEF_COMPARE(Deleted, isDeleted())
DEF_COMPARE(Changed, isChanged())
DEF_COMPARE(Chess960Position, hasChess960Position())
DEF_COMPARE(Promotion, hasPromotion())
DEF_COMPARE(UnderPromotion, hasUnderPromotion())
DEF_COMPARE(EngFlag, containsEnglishLanguage())
DEF_COMPARE(OthFlag, containsOtherLanguage())

} // namespace game

#undef DEF_COMPARE

namespace player {

static int
compRatingAny(unsigned lhs, unsigned rhs, db::Database const& db)
{
	NamebasePlayer const& l = db.player(lhs);
	NamebasePlayer const& r = db.player(rhs);

	uint16_t eloL = l.playerHighestRating();
	uint16_t eloR = r.playerHighestRating();

	if (eloL == 0) eloL = l.playerHighestElo();
	if (eloR == 0) eloR = r.playerHighestElo();

	return mstl::compare(eloL, eloR);
}


static int
compRatingLatestAny(unsigned lhs, unsigned rhs, db::Database const& db)
{
	NamebasePlayer const& l = db.player(lhs);
	NamebasePlayer const& r = db.player(rhs);

	uint16_t eloL = l.playerLatestRating();
	uint16_t eloR = r.playerLatestRating();

	if (eloL == 0) eloL = l.playerLatestElo();
	if (eloR == 0) eloR = r.playerLatestElo();

	return mstl::compare(eloL, eloR);
}


static int
compCountry(unsigned lhs, unsigned rhs, db::Database const& db)
{
	return country::compare(db.player(lhs).findFederation(), db.player(rhs).findFederation());
}


static int
compSex(unsigned lhs, unsigned rhs, db::Database const& db)
{
	NamebasePlayer const& l = db.player(lhs);
	NamebasePlayer const& r = db.player(rhs);

	sex::ID sexL = l.findSex();
	sex::ID sexR = r.findSex();

	if (sexL != sexR)
		return int(sexL) - int(sexR);

	return mstl::compare(l.findType(), r.findType());
}


#define DEF_COMPARE(Type) \
	static int compRating##Type(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.player(lhs).playerHighestRating(rating::Type),  \
									db.player(rhs).playerHighestRating(rating::Type)); \
	} \
	\
	static int compRatingLatest##Type(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.player(lhs).playerLatestRating(rating::Type),  \
									db.player(rhs).playerLatestRating(rating::Type)); \
	}

DEF_COMPARE(DWZ)
DEF_COMPARE(ECF)
DEF_COMPARE(ICCF)
DEF_COMPARE(IPS)
DEF_COMPARE(Rapid)
DEF_COMPARE(Rating)
DEF_COMPARE(USCF)

#undef DEF_COMPARE

#define DEF_COMPARE(Func,Accessor) \
	static int \
	comp##Func(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.player(lhs).Accessor, db.player(rhs).Accessor); \
	}

//DEF_COMPARE(Sex, findSex());
DEF_COMPARE(Name, name());
DEF_COMPARE(FideID, fideID());
DEF_COMPARE(Elo, playerHighestElo());
DEF_COMPARE(EloLatest, playerLatestElo());
DEF_COMPARE(RatingType, playerRatingType());
DEF_COMPARE(Title, findTitle());
DEF_COMPARE(Type, findType());
DEF_COMPARE(PlayerInfo, havePlayerInfo());
DEF_COMPARE(Frequency, frequency());

} // namespace player

namespace event {

#undef DEF_COMPARE

#define DEF_COMPARE(Func,Accessor) \
	static int \
	comp##Func(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.event(lhs).Accessor, db.event(rhs).Accessor); \
	}

DEF_COMPARE(Country, site()->country());
DEF_COMPARE(Site, site()->name());
DEF_COMPARE(Title, name());
DEF_COMPARE(Type, type());
DEF_COMPARE(Date, date());
DEF_COMPARE(Mode, eventMode());
DEF_COMPARE(TimeMode, timeMode());
DEF_COMPARE(Frequency, frequency());

} // namespace event

namespace site {

#undef DEF_COMPARE

#define DEF_COMPARE(Func,Accessor) \
	static int \
	comp##Func(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.site(lhs).Accessor, db.site(rhs).Accessor); \
	}

DEF_COMPARE(Country, country());
DEF_COMPARE(Site, name());
DEF_COMPARE(Frequency, frequency());

} // namespace site

namespace annotator {

#undef DEF_COMPARE

#define DEF_COMPARE(Func,Accessor) \
	static int \
	comp##Func(unsigned lhs, unsigned rhs, db::Database const& db) \
	{ \
		return mstl::compare(db.annotator(lhs).Accessor, db.annotator(rhs).Accessor); \
	}

DEF_COMPARE(Name, name());
DEF_COMPARE(Frequency, frequency());

} // namespace annotator


Selector::Selector() :m_sizeOfMap(0), m_sizeOfList(0) {}


void
Selector::reserve(Database const& db, unsigned numEntries)
{
	M_ASSERT(m_sizeOfMap <= numEntries);

	if (numEntries != m_sizeOfMap)
	{
		unsigned prevSize = m_sizeOfMap;

		m_map.resize(m_sizeOfMap = numEntries);

		for (unsigned i = prevSize; i < numEntries; ++i)
			m_map[i] = i;
	}
}


void
Selector::finish(Database const& db, unsigned numEntries, order::ID order, Compar compFunc)
{
	M_ASSERT(m_sizeOfMap <= numEntries);
	M_ASSERT(compFunc);

	reserve(db, numEntries);

	if (order == order::Descending)
		m_map.qsort_reverse(compFunc, db);
	else
		m_map.qsort(compFunc, db);
}


void
Selector::sort(Database const& db, attribute::game::ID attr, order::ID order, rating::Type ratingType)
{
	Compar func = 0;

	switch (attr)
	{
		case attribute::game::WhitePlayer:				func = game::compWhitePlayer; break;
		case attribute::game::BlackPlayer:				func = game::compBlackPlayer; break;
		case attribute::game::WhiteFideID:				func = game::compWhiteFideID; break;
		case attribute::game::BlackFideID:				func = game::compBlackFideID; break;
		case attribute::game::Event:						func = game::compEvent; break;
		case attribute::game::Site:						func = game::compSite; break;
		case attribute::game::Date:						func = game::compDate; break;
		case attribute::game::Result:						func = game::compResult; break;
		case attribute::game::Round:						func = game::compRound; break;
		case attribute::game::Annotator:					func = game::compAnnotator; break;
		case attribute::game::WhiteElo:					func = game::compWhiteElo; break;
		case attribute::game::BlackElo:					func = game::compBlackElo; break;
		case attribute::game::AverageElo:				func = game::compAverageElo; break;
		case attribute::game::WhiteRatingType:			func = game::compWhiteRatingType; break;
		case attribute::game::BlackRatingType:			func = game::compBlackRatingType; break;
		case attribute::game::WhiteCountry:				func = game::compWhiteCountry; break;
		case attribute::game::BlackCountry:				func = game::compBlackCountry; break;
		case attribute::game::WhiteTitle:				func = game::compWhiteTitle; break;
		case attribute::game::BlackTitle:				func = game::compBlackTitle; break;
		case attribute::game::WhiteType:					func = game::compWhiteType; break;
		case attribute::game::BlackType:					func = game::compBlackType; break;
		case attribute::game::WhiteSex:					func = game::compWhiteSex; break;
		case attribute::game::BlackSex:					func = game::compBlackSex; break;
		case attribute::game::EventType:					func = game::compEventType; break;
		case attribute::game::EventCountry:				func = game::compEventCountry; break;
		case attribute::game::EventDate:					func = game::compEventDate; break;
		case attribute::game::Length:						func = game::compLength; break;
		case attribute::game::Flags:						func = game::compFlags; break;
		case attribute::game::Material:					func = game::compMaterial; break;
		case attribute::game::Idn:							func = game::compIdn; break;
		case attribute::game::Position:					func = game::compPosition; break;
		case attribute::game::MoveList:					func = game::compPosition; break; // TODO should be classification
		case attribute::game::Acv:							func = game::compAcv; break;
		case attribute::game::CommentEngFlag:			func = game::compEngFlag; break;
		case attribute::game::CommentOthFlag:			func = game::compOthFlag; break;
		case attribute::game::Termination:				func = game::compTermination; break;
		case attribute::game::Mode:						func = game::compMode; break;
		case attribute::game::TimeMode:					func = game::compTimeMode; break;
		case attribute::game::Deleted:					func = game::compDeleted; break;
		case attribute::game::Changed:					func = game::compChanged; break;
		case attribute::game::StandardPosition:		func = game::compStandardPosition; break;
		case attribute::game::Chess960Position:		func = game::compChess960Position; break;
		case attribute::game::Promotion:					func = game::compPromotion; break;
		case attribute::game::UnderPromotion:			func = game::compUnderPromotion; break;

		case attribute::game::Added:
			if (m_sizeOfMap > 0 && db.countGames() > db.countInitialGames())
			{
				unsigned numGames			= db.countGames();
				unsigned initialGames	= db.countInitialGames();
				unsigned k;
				unsigned j;

				reserve(db, numGames);

				Map map;
				map.resize(m_sizeOfMap = numGames);

				if (order == order::Ascending)
					k = 0, j = initialGames;
				else
					k = numGames - initialGames, j = 0;

				for (unsigned i = 0; i < numGames; ++i)
				{
					unsigned index = m_map[i];
					map[index < initialGames ? k++ : j++] = index;
				}

				m_map.swap(map);
			}
			return;

		case attribute::game::Number:
			reset(db);

			if (order == order::Descending)
				reverse(db);
			return;

		case attribute::game::Eco:
			func = db.format() == format::Scidb ? game::compUserEco : game::compEco;
			break;

		case attribute::game::WhiteRating:
			switch (ratingType)
			{
				case rating::DWZ:		func = game::compWhiteDWZ; break;
				case rating::ECF:		func = game::compWhiteECF; break;
				case rating::Elo:		func = game::compWhiteElo; break;
				case rating::ICCF:	func = game::compWhiteICCF; break;
				case rating::IPS:		func = game::compWhiteIPS; break;
				case rating::Rapid:	func = game::compWhiteRapid; break;
				case rating::Rating:	func = game::compWhiteRating; break;
				case rating::USCF:	func = game::compWhiteUSCF; break;
				case rating::Any:		func = game::compWhiteAny; break;
			}
			break;

		case attribute::game::BlackRating:
			switch (ratingType)
			{
				case rating::DWZ:		func = game::compBlackDWZ; break;
				case rating::ECF:		func = game::compBlackECF; break;
				case rating::Elo:		func = game::compBlackElo; break;
				case rating::ICCF:	func = game::compBlackICCF; break;
				case rating::IPS:		func = game::compBlackIPS; break;
				case rating::Rapid:	func = game::compBlackRapid; break;
				case rating::Rating:	func = game::compBlackRating; break;
				case rating::USCF:	func = game::compBlackUSCF; break;
				case rating::Any:		func = game::compBlackAny; break;
			}
			break;

		case attribute::game::AverageRating:
			switch (ratingType)
			{
				case rating::DWZ:		func = game::compAverageDWZ; break;
				case rating::ECF:		func = game::compAverageECF; break;
				case rating::Elo:		func = game::compAverageElo; break;
				case rating::ICCF:	func = game::compAverageICCF; break;
				case rating::IPS:		func = game::compAverageIPS; break;
				case rating::Rapid:	func = game::compAverageRapid; break;
				case rating::Rating:	func = game::compAverageRating; break;
				case rating::USCF:	func = game::compAverageUSCF; break;
				case rating::Any:		func = game::compAverageAny; break;
			}
			break;

		case attribute::game::WhiteRating1:
		case attribute::game::BlackRating1:
		case attribute::game::WhiteRating2:
		case attribute::game::BlackRating2:
		case attribute::game::Opening:
		case attribute::game::Variation:
		case attribute::game::SubVariation:
		case attribute::game::InternalEco:
			return;
	}

	M_ASSERT(func);

	finish(db, db.countGames(), order, func);
}


void
Selector::sort(Database const& db, attribute::player::ID attr, order::ID order, rating::Type ratingType)
{
	Compar func = 0;

	switch (attr)
	{
		case attribute::player::Name:				func = ::player::compName; break;
		case attribute::player::FideID:			func = player::compFideID; break;
		case attribute::player::Sex:				func = ::player::compSex; break;
		case attribute::player::EloHighest:		func = ::player::compElo; break;
		case attribute::player::EloLatest:		func = ::player::compEloLatest; break;
		case attribute::player::RatingType:		func = ::player::compRatingType; break;
		case attribute::player::Country:			func = ::player::compCountry; break;
		case attribute::player::Title:			func = ::player::compTitle; break;
		case attribute::player::Type:				func = ::player::compType; break;
		case attribute::player::PlayerInfo:		func = ::player::compPlayerInfo; break;
		case attribute::player::Frequency:		func = ::player::compFrequency; break;

		case attribute::player::RatingHighest:
			switch (ratingType)
			{
				case rating::DWZ:		func = ::player::compRatingDWZ; break;
				case rating::ECF:		func = ::player::compRatingECF; break;
				case rating::Elo:		func = ::player::compElo; break;
				case rating::ICCF:	func = ::player::compRatingICCF; break;
				case rating::IPS:		func = player::compRatingIPS; break;
				case rating::Rapid:	func = player::compRatingRapid; break;
				case rating::Rating:	func = ::player::compRatingRating; break;
				case rating::USCF:	func = ::player::compRatingUSCF; break;
				case rating::Any:		func = ::player::compRatingAny; break;
			}
			break;

		case attribute::player::RatingLatest:
			switch (ratingType)
			{
				case rating::DWZ:		func = ::player::compRatingLatestDWZ; break;
				case rating::ECF:		func = ::player::compRatingLatestECF; break;
				case rating::Elo:		func = ::player::compEloLatest; break;
				case rating::ICCF:	func = ::player::compRatingLatestICCF; break;
				case rating::IPS:		func = player::compRatingLatestIPS; break;
				case rating::Rapid:	func = player::compRatingLatestRapid; break;
				case rating::Rating:	func = player::compRatingLatestRating; break;
				case rating::USCF:	func = ::player::compRatingLatestUSCF; break;
				case rating::Any:		func = ::player::compRatingLatestAny; break;
			}
			break;

		case attribute::player::Rating1:
		case attribute::player::Rating2:
		case attribute::player::DateOfBirth:
		case attribute::player::DateOfDeath:
		case attribute::player::DsbID:
		case attribute::player::EcfID:
		case attribute::player::IccfID:
		case attribute::player::ViafID:
		case attribute::player::PndID:
		case attribute::player::ChessgComLink:
		case attribute::player::WikiLink:
		case attribute::player::Aliases:
			return;
	}

	finish(db, db.countPlayers(), order, reinterpret_cast<Compar>(func));
}


void
Selector::sort(Database const& db, attribute::event::ID attr, order::ID order)
{
	Compar func = 0;

	switch (attr)
	{
		case attribute::event::Country:		func = ::event::compCountry; break;
		case attribute::event::Site:			func = ::event::compSite; break;
		case attribute::event::Title:			func = ::event::compTitle; break;
		case attribute::event::Type:			func = ::event::compType; break;
		case attribute::event::Date:			func = ::event::compDate; break;
		case attribute::event::Mode:			func = ::event::compMode; break;
		case attribute::event::TimeMode:		func = ::event::compTimeMode; break;
		case attribute::event::Frequency:	func = ::event::compFrequency; break;
		case attribute::event::LastColumn:	return;
	}

	finish(db, db.countEvents(), order, func);
}


void
Selector::sort(Database const& db, attribute::site::ID attr, order::ID order)
{
	Compar func = 0;

	switch (attr)
	{
		case attribute::site::Country:		func = ::site::compCountry; break;
		case attribute::site::Site:			func = ::site::compSite; break;
		case attribute::site::Frequency:		func = ::site::compFrequency; break;
		case attribute::site::LastColumn:	return;
	}

	finish(db, db.countSites(), order, func);
}


void
Selector::sort(Database const& db, attribute::annotator::ID attr, order::ID order)
{
	Compar func = 0;

	switch (attr)
	{
		case attribute::annotator::Name:			func = annotator::compName; break;
		case attribute::annotator::Frequency:	func = annotator::compFrequency; break;
		case attribute::annotator::LastColumn:	return;
	}

	M_ASSERT(func);

	finish(db, db.countAnnotators(), order, func);
}


void
Selector::reverse(Database const& db)
{
	if (m_sizeOfMap == 0)
	{
		unsigned n = db.countGames();

		m_map.resize(m_sizeOfMap = n);

		for (unsigned i = 0; i < n; ++i)
			m_map[i] = n - i - 1;
	}
	else
	{
		mstl::reverse(m_map.begin(), m_map.end());
	}
}


void
Selector::reset()
{
	m_map.clear();
	m_lookup.release();
	m_find.release();
	m_sizeOfMap = 0;
	m_sizeOfList = 0;
}


int
Selector::find(Namebase const& namebase, mstl::string const& name) const
{
	int firstIndex = namebase.search(name);

	if (firstIndex == -1)
		return -1;

	unsigned numEntries	= namebase.size();
	unsigned found			= unsigned(-1);

	for (unsigned i = firstIndex; i < numEntries; ++i)
	{
		NamebaseEntry const* entry = namebase.entryAt(i);

		if (::strcmp(entry->name(), name) != 0)
			break;

		if (entry->used())
			found = mstl::min(found, find(i));
	}

	return int(found);
}


int
Selector::findPlayer(Database const& db, mstl::string const& name) const
{
	return find(db.namebase(Namebase::Player), name);
}


int
Selector::findEvent(Database const& db, mstl::string const& name) const
{
	return find(db.namebase(Namebase::Event), name);
}


int
Selector::findSite(Database const& db, mstl::string const& name) const
{
	return find(db.namebase(Namebase::Site), name);
}


int
Selector::findAnnotator(Database const& db, mstl::string const& name) const
{
	return find(db.namebase(Namebase::Annotator), name);
}


int
Selector::search(	Namebase const& namebase,
						mstl::string const& prefix,
						util::Pattern const& pattern,
						unsigned startIndex) const
{
	typedef int (*Compare)(char const* lhs, char const* rhs, size_t len);

	M_ASSERT(!prefix.empty());

	if (startIndex == namebase.used())
		startIndex = 0;

	int firstIndex = namebase.search(prefix, isUnsorted() ? namebase.realIndex(lookup(startIndex)) : 0);

	if (firstIndex == -1)
		return -1;
	
	Compare	cmp(pattern.ignoreCase() ? ::strncasecmp : ::strncmp);
	unsigned	numEntries(namebase.size());
	unsigned	found[2] = { unsigned(-1), unsigned(-1) };

	for (unsigned i = firstIndex; i < numEntries; ++i)
	{
		NamebaseEntry const* entry = namebase.entryAt(i);

		if (cmp(entry->name(), prefix, prefix.size()) != 0)
			break;

		if (entry->used() && pattern.match(entry->name()))
		{
			unsigned index = find(namebase.lookupIndex(i));
			unsigned which = index >= startIndex ? 0 : 1;
			found[which] = mstl::min(found[which], index);
		}
	}

	return int(found[0]) >= 0 ? int(found[0]) : int(found[1]);
}


int
Selector::search(Namebase const& namebase, util::Pattern const& pattern, unsigned startIndex) const
{
	if (namebase.used() == 0)
		return -1;

	if (!pattern.ignoreCase())
	{
		mstl::string prefix = pattern.prefix();

		if (!prefix.empty())
			return search(namebase, prefix, pattern, startIndex);
	}

	unsigned numEntries = namebase.used();

	if (m_sizeOfMap > 0)
		numEntries = mstl::min(m_sizeOfMap, numEntries);
	
	if (numEntries)
	{
		unsigned i = (startIndex = mstl::min(startIndex, numEntries));
		unsigned n = startIndex == 0 ? numEntries : startIndex;

		while (true)
		{
			if (i == numEntries)
				i = 0;

			if (pattern.match(namebase.lookupEntry(lookup(i))->name()))
				return i;

			if (++i == n)
				break;
		}
	}

	return -1;
}


int
Selector::searchPlayer(Database const& db, util::Pattern const& pattern, unsigned startIndex) const
{
	return db.mapPlayerIndex(search(db.namebase(Namebase::Player), pattern, startIndex));
}


int
Selector::searchEvent(Database const& db, util::Pattern const& pattern, unsigned startIndex) const
{
	return db.mapEventIndex(search(db.namebase(Namebase::Event), pattern, startIndex));
}


int
Selector::searchSite(Database const& db, util::Pattern const& pattern, unsigned startIndex) const
{
	return db.mapSiteIndex(search(db.namebase(Namebase::Site), pattern, startIndex));
}


int
Selector::searchAnnotator(Database const& db, util::Pattern const& pattern, unsigned startIndex) const
{
	return db.mapAnnotatorIndex(search(db.namebase(Namebase::Annotator), pattern, startIndex));
}


void
Selector::update(Filter const& filter)
{
	if (filter.isComplete())
	{
		m_lookup = m_map;
		m_sizeOfList = m_sizeOfMap;

		if (m_sizeOfMap > 0)
		{
			m_find.resize(m_sizeOfMap);
			m_find.zero();

			for (unsigned i = 0, n = m_sizeOfMap; i < n; ++i)
				m_find[m_map[i]] = i;
		}
	}
	else if (m_sizeOfMap > 0)
	{
		if (filter.size() >= m_sizeOfMap)
		{
			m_lookup.resize(m_sizeOfList = filter.count());
			m_lookup.zero();
			m_find.resize(m_sizeOfMap);
			m_find.zero();

			Map::iterator lookup = m_lookup.begin();

			for (unsigned i = 0, j = 0, n = m_sizeOfMap; i < n; ++i)
			{
				unsigned k = m_map[i];

				if (filter.contains(k))
				{
					*lookup++ = k;
					m_find[k] = j++;
				}
			}

			M_ASSERT(lookup == m_lookup.end());
		}
		else
		{
			m_map.release();
			m_lookup.release();
			m_find.release();
			m_sizeOfMap = 0;
			m_sizeOfList = 0;
		}
	}
	else
	{
		m_lookup.resize(m_sizeOfList = filter.count());
		m_lookup.zero();

		if (m_sizeOfList > 0)
		{
			Map::iterator lookup = m_lookup.begin();

			m_find.resize(filter.size());
			m_find.zero();

			for (unsigned i = 0, j = 0, n = filter.size(); i < n; ++i)
			{
				if (filter.contains(i))
				{
					*lookup++ = i;
					m_find[i] = j++;
				}
			}

			M_ASSERT(lookup == m_lookup.end());
		}
	}
}


void
Selector::update()
{
	if (m_sizeOfMap > 0)
	{
		m_lookup.resize(m_sizeOfList = m_sizeOfMap);

		Map::iterator lookup = m_lookup.begin();

		for (unsigned i = 0, n = m_sizeOfMap; i < n; ++i)
			*lookup++ = m_map[i];
	}
	else
	{
		m_lookup.release();
		m_sizeOfList = 0;
	}

	m_find.release();
}


void
Selector::swap(Selector& selector)
{
	m_map.swap(selector.m_map);
	m_lookup.swap(selector.m_lookup);
	m_find.swap(selector.m_find);
	mstl::swap(m_sizeOfMap, selector.m_sizeOfMap);
	mstl::swap(m_sizeOfList, selector.m_sizeOfList);
}

// vi:set ts=3 sw=3:
