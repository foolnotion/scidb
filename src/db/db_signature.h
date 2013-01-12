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

#ifndef _db_signature_included
#define _db_signature_included

#include "db_common.h"

namespace db {

class GameInfo;

namespace sci { namespace v91  { class Codec; } }
namespace sci { namespace v92  { class Codec; } }
namespace sci { class Codec; }
namespace si3 { class Codec; }
namespace cbh { class Codec; }

class Signature
{
public:

	/// Return whether promotion(s) has been detected
	bool hasPromotion() const;
	/// Return whether under-promotion(s) has been detected
	bool hasUnderPromotion() const;

	material::Signature material() const;
	material::SigPart material(color::ID color) const;
	pawns::Side progress(color::ID color) const;
	castling::Rights castling() const;
	unsigned hpCount() const;
	hp::Pawns homePawnsData() const;
	unsigned countKings(color::ID color) const;

	/// Returns whether current signature can reach final signature \target.
	bool isReachableFinal(Signature const& target) const;
	bool isReachableFinal(Signature const& target, uint16_t currentHpSig) const;
	bool isReachableFinalPosition(Signature const& target, uint16_t currentHpSig) const;
	bool isReachableFinalMaterial(Signature const& target) const;
	bool isReachablePawns(Signature const& target) const;

	void addCastling(castling::Rights rights);
	void removeCastling(castling::Rights rights);
	void addKing(color::ID color);
	void removeKing(color::ID color);

	void setHomePawns(unsigned hpCount, hp::Pawns data);
	void clearHomePawns();
	void transpose();

	void debug(unsigned spaces = 0) const;

	static bool isReachable(Signature const& current, Signature const& target);
	static bool isReachable(Signature const& current, Signature const& target, uint16_t currentHpSig);
	static bool isReachablePosition(	Signature const& current,
												Signature const& target,
												uint16_t currentHpSig);
	static bool isReachablePawnStructure(pawns::Side lhs, pawns::Side rhs);
	static bool isReachablePawnStructure(pawns::Progress lhs, pawns::Progress rhs);

	static void initialize();

	friend class sci::v91::Codec;
	friend class sci::v92::Codec;
	friend class sci::Codec;
	friend class si3::Codec;
	friend class cbh::Codec;

protected:

	friend class GameInfo;

	typedef material::Signature	MatSig;
	typedef pawns::Progress			Progress;

	hp::Pawns	m_homePawns;	// home pawns
	MatSig		m_matSig;		// material signature
	Progress		m_progress;		// pawn progress per side for each fyle

	// TODO:
	// we need (at least) 2 bits for number of checks given (for three-check only)
	// probably we should (mis)use m_underPromotions for this purpose:
	//		- 0011 for under-promotions
	//		- 1100 for checks given

	union __attribute__((packed))
	{
		struct __attribute__((packed))
		{
			uint16_t m_promotions		:4;	// count promotions
			uint16_t m_underPromotions	:4;	// count under-promotions
			uint16_t m_castling			:4;	// castling flags
			uint16_t m_hpCount			:4;	// length of home pawns (in nybbles)
		};
		struct __attribute__((packed))
		{
			uint16_t __skip1				:8;
			uint16_t m_whiteKing			:2;	// count kings on board (Antichess)
			uint16_t m_blackKing			:2;	// count kings on board (Antichess)
			uint16_t __skip2				:4;
		};
	};
}
__attribute__((packed));

} // namespace db

namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod<db::Signature> { enum { value = 1 }; };

} // namespace mstl

#include "db_signature.ipp"

#endif // _db_signature_included

// vi:set ts=3 sw=3:
