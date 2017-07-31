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

// ======================================================================
// The implementation is loosely based on chessx/src/database/move.h
// ======================================================================

#include "u_crc.h"

#include "m_utility.h"

namespace db {

inline Move::Move() :m(0), u(0) {}
inline Move::Move(uint32_t m) :m(m), u(0) {}
inline Move::Move(Move const& m, sq::ID from) :m(m.m), u(0) { setFrom(from); }

inline Move::operator bool () const { return m != 0; }
inline bool Move::operator!() const { return m == 0; }

inline Move const& Move::empty()						{ return m_empty; }
inline Move const& Move::null()						{ return m_null; }
inline Move const& Move::invalid()					{ return m_invalid; }
inline Move const& Move::undefined()				{ return m_undefined; }

inline Square Move::from() const						{ return m & 0x3f; }
inline Square Move::to() const						{ return (m >> 6) & 0x3f; }
inline Square Move::castlingKingFrom() const		{ return from(); }
inline Square Move::castlingRookFrom() const		{ return to(); }
inline Square Move::enPassantSquare() const		{ return from() > 31 ? to() - 8 : to() + 8; }

inline bool Move::prevCapturePromoted() const	{ return u & Bit_CapturePromoted; }
inline Square Move::prevEpSquare() const			{ return (u >> Shift_EpSquare) & Mask_EpSquare; }

inline
uint32_t
Move::prevHalfMoves() const
{
	static_assert(Shift_HalfMoveClock == 0, "need shift");
	return u & Mask_HalfMoveClock;
}

inline
Byte
Move::prevCastlingRights() const
{
	return Square((u >> Shift_CastleRights) & Mask_CastlingRights);
}

inline
Byte
Move::prevKingHasMoved() const
{
	return Byte((u >> Shift_KingHasMoved) & Mask_KingHasMoved);
}

inline
Byte
Move::prevGivesCheck() const
{
	return Byte((u >> Shift_GivesCheck) & Mask_GivesCheck);
}

inline uint32_t Move::action() const					{ return (m >> Shift_Action) & Mask_Action; }
inline uint32_t Move::removal() const					{ return (m >> Shift_Removal) & Mask_Removal; }
inline uint32_t Move::data() const						{ return m; }
inline unsigned Move::index() const						{ return m & Mask_Index; }
inline unsigned Move::field() const						{ return m & Field_Index; }

inline bool Move::givesCheck() const					{ return u & Bit_Check; }
inline bool Move::givesDoubleCheck() const			{ return u & Bit_DoubleCheck; }
inline bool Move::givesMate() const						{ return u & Bit_Mate; }
inline bool Move::isCastling() const					{ return m & Bit_Castling; }
inline bool Move::isDoubleAdvance() const				{ return m & Bit_TwoForward; }
inline bool Move::isEmpty() const						{ return m == 0; }
inline bool Move::isEnPassant() const					{ return m & Bit_EnPassant; }
inline bool Move::isPieceDrop() const					{ return m & Bit_PieceDrop; }
inline bool Move::isLegal() const						{ return m & Bit_Legality; }
inline bool Move::isIllegal() const						{ return (m & Bit_Legality) == 0; }
inline bool Move::isNull() const							{ return (m & Mask_Null) == Bit_Legality; }
inline bool Move::isInvalid() const						{ return (m & Invalid) == Invalid; }
inline bool Move::isValid() const						{ return (m & Invalid) != Invalid; }
inline bool Move::isUndefined() const					{ return (m & Mask_Undefined) == Undefined; }
inline bool Move::isPromotion() const					{ return m & Bit_Promote; }
inline bool Move::isSpecial() const						{ return m & Bits_Special; }
inline bool Move::isPrintable() const					{ return u & Bit_Printable; }
inline bool Move::needsFyle() const						{ return u & Bit_Fyle; }
inline bool Move::needsRank() const						{ return u & Bit_Rank; }
inline bool Move::needsDestinationSquare() const	{ return u & Bit_Destination; }
inline bool Move::isDisambiguated() const				{ return u & Bit_Disambiguated; }

inline void Move::clear()							{ m = 0; }
inline bool Move::preparedForUndo() const		{ return u & Bit_Prepared; }

inline color::ID Move::color() const			{ return color::ID((m >> Shift_SideToMove) & 1); }
inline piece::ID Move::piece() const			{ return piece::piece(moved(), color()); }

inline void Move::unsetEnPassant()				{ m &= ~Bit_EnPassant; }
inline void Move::setFrom(uint32_t from)		{ m = ((m & (~0x3f)) | from) & ~Bit_Legality; }
inline void Move::setTo(uint32_t to)			{ m = ((m & (~(0x3f << 6))) | (to << 6)) & ~Bit_Legality; }
inline void Move::setLegalMove()					{ m |= Bit_Legality; }
inline void Move::setIllegalMove()				{ m &= ~Bit_Legality; }
inline void Move::setNeedsFyle()					{ u |= Bit_Fyle; }
inline void Move::setNeedsRank()					{ u |= Bit_Rank; }
inline void Move::setDisambiguated()			{ u |= Bit_Disambiguated; }
inline void Move::setCheck()						{ u |= Bit_Check; }
inline void Move::setDoubleCheck()				{ u |= Bit_DoubleCheck; }
inline void Move::setMate()						{ u |= Bit_Mate; }
inline void Move::setPrintable()					{ u |= Bit_Printable; }
inline void Move::setNeedsDestinationSquare(){ u |= Bit_Destination; }
inline void Move::clearInfoStatus()				{ u &= ~Mask_Info; }

inline piece::Type Move::moved() const		{ return piece::Type(Mask_PieceType & (m >> Shift_Piece)); }


inline
unsigned
Move::checksGiven() const
{
	return (u >> Shift_ChecksGiven) & Mask_ChecksGiven;
}


inline
bool
Move::isIllegalOrInvalid() const
{
	return (m & Bit_Legality) == 0 || (m & Invalid) == Invalid;
}


inline
bool
Move::isNullOrInvalid() const
{
	return (m & Mask_Null) == Bit_Legality || (m & Invalid) == Invalid;
}


inline
Move::Move(Square from, Square to, unsigned color)
	:m(from | (to << 6) | (color << Shift_SideToMove))
	,u(0)
{
}


inline
bool
Move::operator==(Move const& m) const
{
	return (this->m & Move::Mask_Compare) == (m.m & Move::Mask_Compare);
}


inline
bool
Move::operator!=(Move const& m) const
{
	return (this->m & Move::Mask_Compare) != (m.m & Move::Mask_Compare);
}


inline
bool
Move::operator<(Move const& m) const
{
	return (this->m & Move::Mask_Compare) < (m.m & Move::Mask_Compare);
}


inline
uint16_t
Move::makeIndex(uint16_t from, uint16_t to)
{
	return from | (to << 6);
}


inline
void
Move::setChecksGiven(unsigned n)
{
	M_REQUIRE(n <= 3);
	u |= (n << Shift_ChecksGiven);
}


inline
void
Move::setLegalMove(bool flag)
{
	if (flag)
		setLegalMove();
	else
		setIllegalMove();
}


inline
bool
Move::isShortCastling() const
{
	M_REQUIRE(isCastling());
	M_ASSERT(from() != to());

	return m & Invalid ? to() < from() : from() < to();
}


inline bool
Move::isLongCastling() const
{
	M_REQUIRE(isCastling());
	M_ASSERT(from() != to());

	return m & Invalid ? to() > from() : from() > to();
}


inline
bool
Move::isPawnCapture() const
{
	static_assert(Shift_PieceDrop + 1 == Shift_Capture, "reimplementation required");
	return ((m >> Shift_PieceDrop) & Mask_Removal) == (piece::Pawn << 1);
}


inline
bool
Move::isCapture() const
{
	return ((m >> Shift_Capture) & Mask_PieceType) && !(m & Bit_PieceDrop);
}


inline
bool
Move::isCaptureOrPromotion() const
{
	return (((m >> Shift_Capture) & Mask_PieceType) | (m & Bit_Promote)) && !(m & Bit_PieceDrop);
}


inline
bool
Move::isCaptureOrPromotionOrDrop() const
{
	return (((m >> Shift_Capture) & Mask_PieceType) | (m & Bit_Promote));
}


inline
Square
Move::capturedSquare() const
{
	M_REQUIRE(isCapture());
	return isEnPassant() ? enPassantSquare() : to();
}


inline
Square
Move::castlingKingTo() const
{
	if (m & Invalid)
		return sq::make(from() < to() ? sq::FyleF : sq::FyleB, sq::rank(from()));

	return sq::make(from() < to() ? sq::FyleG : sq::FyleC, sq::rank(from()));
}


inline
Square
Move::castlingRookTo() const
{
	if (m & Invalid)
		return sq::make(from() < to() ? sq::FyleE : sq::FyleC, sq::rank(from()));

	return sq::make(from() < to() ? sq::FyleF : sq::FyleD, sq::rank(from()));
}


inline
void
Move::setSquares(uint32_t from, uint32_t to)
{
	m = ((m & (~0xfff)) | from | (to << 6)) & ~Bit_Legality;
}


inline
void
Move::setColor(unsigned color)
{
	m |= (color << Shift_SideToMove);
}


inline
void
Move::setPromotionPiece(piece::Type type)
{
	M_REQUIRE(type != piece::None && type != piece::Pawn);
	M_REQUIRE(isPromotion());

	m &= ~(Mask_PieceType << Shift_Promotion);
	m |= (uint32_t(type) & Mask_PieceType) << Shift_Promotion;
}


inline
piece::Type Move::capturedOrDropped() const
{
	return piece::Type((m >> Shift_Capture) & Mask_PieceType);
}


inline
piece::Type Move::captured() const
{
	M_REQUIRE(isCapture());
	return piece::Type((m >> Shift_Capture) & Mask_PieceType);
}


inline
uint32_t
Move::capturedType() const
{
//	M_REQUIRE(isCapture()); not wanted!
	return (m >> Shift_Capture) & Mask_PieceType;
}


inline
piece::ID
Move::capturedPiece() const
{
	M_REQUIRE(isCapture());
	piece::Type type = captured();
	return type == piece::None ? piece::Empty : piece::piece(type, color::opposite(color()));
}


inline
piece::Type
Move::promoted() const
{
	return piece::Type((m >> Shift_Promotion) & Mask_PieceType);
}


inline
piece::Type
Move::dropped() const
{
	M_REQUIRE(isPieceDrop());
	return promoted();
}


inline
piece::ID
Move::droppedPiece() const
{
	M_REQUIRE(isPieceDrop());
	return piece::piece(dropped(), color::opposite(color()));
}


inline
piece::ID
Move::promotedPiece() const
{
	return piece::piece(promoted(), color());
}


inline
Move
Move::genOneForward(uint32_t from, uint32_t to)
{
	return Move(from | (to << 6) | (uint32_t(piece::Pawn) << Shift_Piece));
}


inline
Move
Move::genTwoForward(uint32_t from, uint32_t to)
{
	return Move(from | (to << 6) | (uint32_t(piece::Pawn) << Shift_Piece) | Bit_TwoForward);
}


inline
Move
Move::genPromote(uint32_t from, uint32_t to, uint32_t type)
{
	M_REQUIRE(type != piece::None && type != piece::Pawn);

	return Move(	from
					 | (to << 6)
					 | (type << Shift_Promotion)
					 | (uint32_t(piece::Pawn) << Shift_Piece)
					 | Bit_Promote);
}


inline
Move
Move::genCapturePromote(uint32_t from, uint32_t to, uint32_t type, uint32_t captured)
{
	M_REQUIRE(type != piece::None && type != piece::Pawn);

	return Move(	from
					 | (to << 6)
					 | (captured << Shift_Capture)
					 | (type << Shift_Promotion)
					 | (uint32_t(piece::Pawn) << Shift_Piece)
					 | Bit_Promote);
}


inline
Move
Move::genEnPassant(uint32_t from, uint32_t to)
{
	return Move(	from
					 | (to << 6)
					 | (uint32_t(piece::Pawn) << Shift_Piece)
					 | (uint32_t(piece::Pawn) << Shift_Capture)
					 | Bit_EnPassant);
}


inline
Move
Move::genPawnCapture(uint32_t from, uint32_t to, uint32_t captured)
{
	M_ASSERT(captured != piece::None);

	return Move(	from
					 | (to << 6)
					 | (captured << Shift_Capture)
					 | (uint32_t(piece::Pawn) << Shift_Piece));
}


inline
Move
Move::genMove(uint32_t from, uint32_t to, uint32_t pieceType, uint32_t captured)
{
	return Move(	from
					 | (to << 6)
					 | (captured << Shift_Capture)
					 | (pieceType << Shift_Piece));
}


inline
Move
Move::genKnightMove(uint32_t from, uint32_t to, uint32_t captured)
{
	return Move(	from
					 | (to << 6)
					 | (captured << Shift_Capture)
					 | (uint32_t(piece::Knight) << Shift_Piece));
}


inline
Move
Move::genBishopMove(uint32_t from, uint32_t to, uint32_t captured)
{
	return Move(	from
					 | (to << 6)
					 | (captured << Shift_Capture)
					 | (uint32_t(piece::Bishop) << Shift_Piece));
}


inline
Move
Move::genRookMove(uint32_t from, uint32_t to, uint32_t captured)
{
	return Move(from | (to << 6) | (captured << Shift_Capture) | (uint32_t(piece::Rook) << Shift_Piece));
}


inline
Move
Move::genQueenMove(uint32_t from, uint32_t to, uint32_t captured)
{
	return Move(from | (to << 6) | (captured << Shift_Capture) | (uint32_t(piece::Queen) << Shift_Piece));
}


inline
Move
Move::genKingMove(uint32_t from, uint32_t to, uint32_t captured)
{
	return Move(from | (to << 6) | (captured << Shift_Capture) | (uint32_t(piece::King) << Shift_Piece));
}


inline
Move
Move::genCastling(Square from, Square to)
{
	M_REQUIRE(from != to);

	return Move(	uint32_t(from)
					 | uint32_t(to) << 6
					 | (uint32_t(piece::King) << Shift_Piece)
					 | Bit_Castling);
}


inline
Move
Move::genPieceDrop(Square to, uint32_t type)
{
	M_REQUIRE(type != piece::None);
	return Move(uint32_t(to) | uint32_t(to) << 6 | (type << Shift_Promotion) | Bit_PieceDrop);
}


inline
void
Move::setEnPassant()
{
	(m &= Clear_CaptureType) |= ((piece::Pawn & Mask_PieceType) << Shift_Capture) | Bit_EnPassant;
}


inline
void
Move::setPromoted(uint32_t p)
{
	M_REQUIRE(p != piece::None);
	M_REQUIRE(p != piece::Pawn);

	m &= Clear_Promote;
	m |= Bit_Promote | ((p & Mask_PieceType) << Shift_Promotion);
}


inline
void
Move::setUndo(	uint32_t halfMoves,
					uint32_t epSquare,
					uint32_t castleRights,
					uint32_t kingMovedOrGivesCheck,
					uint32_t capturePromoted)
{
	M_ASSERT(epSquare <= sq::Null);
	M_ASSERT((castleRights & Mask_CastlingRights) == castleRights);
	M_ASSERT((kingMovedOrGivesCheck & (Mask_KingHasMoved | Mask_GivesCheck)) == kingMovedOrGivesCheck);
	M_ASSERT(capturePromoted <= 1);

	u = (halfMoves & Mask_HalfMoveClock)
	  | epSquare << Shift_EpSquare
	  | castleRights << Shift_CastleRights
	  | kingMovedOrGivesCheck << (Mask_KingHasMoved | Mask_GivesCheck)
	  | capturePromoted << Shift_CapturePromoted
	  | uint32_t(Bit_Prepared)
	  ;
}


inline
util::crc::checksum_t
Move::computeChecksum(util::crc::checksum_t crc) const
{
	return ::util::crc::compute(crc, index());
}


inline
mstl::string&
Move::printSAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	return printSAN(s, protocol, charSet, false, false);
}


inline
mstl::string&
Move::printMAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	return printSAN(s, protocol, charSet, true, false);
}


inline
mstl::string&
Move::printGAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	return printSAN(s, protocol, charSet, false, true);
}


inline
mstl::string&
Move::printLAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	return printLAN(s, protocol, charSet, false);
}


inline
mstl::string&
Move::printRAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const
{
	return printLAN(s, protocol, charSet, true);
}

} // namespace db

// vi:set ts=3 sw=3:
