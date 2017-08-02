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
// This class is loosely based on chessx/src/database/move.h
// ======================================================================

#ifndef _db_move_included
#define _db_move_included

#include "db_common.h"

#include "u_crc.h"

#include "m_string.h"

namespace db {

class Board;
class MoveList;

/** @ingroup Core
   Moves are dependent on current position, (remembers piece, check, capture etc)
   and don't make much sense when considered without a Board.
   However, you can create a move with only a source and destination square,
   Such moves are considered "illegal", but can be convenient when dealing with move entry.
*/

class Move
{
public:

	enum { Index_Field_Length	= 12 };
	enum { Index_Bit_Length		= 15 };

	enum
	{
		Shift_Promotion			= 12,
		Shift_Piece					= 15,	Shift_Action = Shift_Piece,
		Shift_PromotedPiece		= 18,
		Shift_Castling				= 19,
		Shift_TwoForward			= 20,
		Shift_Promote				= 21,
		Shift_PieceDrop			= 22,
		Shift_Capture				= 23,	Shift_Removal = Shift_Capture,
		Shift_EnPassant			= 26,
		Shift_SideToMove			= 27,
		Shift_Legality				= 31,

		Shift_HalfMoveClock		=  0,
		Shift_EpSquare				= 14,
		Shift_CastleRights		= 23,
		Shift_KingHasMoved		= 27,
		Shift_GivesCheck			= Shift_KingHasMoved,
		Shift_CapturePromoted	= 29,
		Shift_Prepared				= 30,
		Shift_Printable			= 31,

		Shift_Fyle					=  0,
		Shift_Rank					=  1,
		Shift_Destination			=  2,
		Shift_Disambiguated		=  3,
		Shift_Check					=  4,
		Shift_DoubleCheck			=  5,
		Shift_Mate					=  6,
		Shift_ChecksGiven			=  7,
	};

	enum
	{
		Bit_PromotedPiece		= 1u << Shift_PromotedPiece,
		Bit_Castling			= 1u << Shift_Castling,
		Bit_TwoForward			= 1u << Shift_TwoForward,
		Bit_Promote				= 1u << Shift_Promote,
		Bit_PieceDrop			= 1u << Shift_PieceDrop,
		Bit_EnPassant			= 1u << Shift_EnPassant,
		Bit_KingHasMoved		= 1u << Shift_KingHasMoved,
		Bit_BlackToMove		= 1u << Shift_SideToMove,
		Bit_Legality			= 1u << Shift_Legality,

		Bit_CapturePromoted	= 1u << Shift_CapturePromoted,
		Bit_Prepared			= 1u << Shift_Prepared,

		Bit_Fyle					= 1u << Shift_Fyle,
		Bit_Rank					= 1u << Shift_Rank,
		Bit_Destination		= 1u << Shift_Destination,
		Bit_Disambiguated		= 1u << Shift_Disambiguated,
		Bit_Check				= 1u << Shift_Check,
		Bit_DoubleCheck		= 1u << Shift_DoubleCheck,
		Bit_Mate					= 1u << Shift_Mate,
		Bit_Printable			= 1u << Shift_Printable,
	};

	static uint16_t const Null						= 0;
	static uint16_t const Empty					= 0;
	static uint16_t const Invalid					= 7u << Shift_Promotion;
	static uint32_t const Undefined				= 1u << Shift_Capture;

	static uint32_t const Mask_PieceType		= (1u << 3) - 1;
	static uint32_t const Mask_Removal			= (1u << 4) - 1;
	static uint32_t const Mask_Action			= (1u << 8) - 1;

	// NOTE: side to move is not comparable, this flag is a print information
	static uint32_t const Mask_Compare			= uint32_t(~0) >> (31 - Shift_EnPassant);

	static uint32_t const Mask_Index				= (1u << Index_Bit_Length) - 1;
	static uint32_t const Field_Index			= (1u << Index_Field_Length) - 1;
	static uint32_t const Mask_Null				= Bit_Legality | Mask_Index;

	static uint32_t const Mask_Undo				= (1u << 30) - 1;
	static uint32_t const Mask_HalfMoveClock	= (1u << 14) - 1;
	static uint32_t const Mask_EpSquare			= (1u <<  9) - 1;
	static uint32_t const Mask_CastlingRights	= (1u <<  4) - 1;
	static uint32_t const Mask_KingHasMoved	= (1u <<  2) - 1;
	static uint32_t const Mask_GivesCheck		= Mask_KingHasMoved;
	static uint32_t const Mask_ChecksGiven		= (1u <<  2) - 1;
	static uint32_t const Mask_Invalid			= (Invalid << 1) - 1;
	static uint32_t const Mask_Undefined		= (Undefined << 1) - 1;
	static uint32_t const Mask_Info				= Bit_Fyle
															| Bit_Rank
															| Bit_Destination
															| Bit_Disambiguated
															| Bit_Check
															| Bit_DoubleCheck
															| Bit_Mate
															| Bit_Printable
															| Mask_ChecksGiven;

	static uint32_t const Clear_PieceType		= ~(Mask_PieceType << Shift_Piece);
	static uint32_t const Clear_CaptureType	= ~(Mask_PieceType << Shift_Capture);
	static uint32_t const Clear_Promote			= ~((Mask_PieceType << Shift_Promotion) | Bit_Promote);

	static uint32_t const Clear_Undo				= ~Mask_Undo;

	static uint32_t const Bits_Special =
		Bit_Castling | Bit_TwoForward | Bit_Promote | Bit_EnPassant | Bit_PieceDrop;

	// action
	static unsigned const Null_Move		= 0;
	static unsigned const One_Forward	= piece::Pawn;
	static unsigned const Two_Forward	= piece::Pawn | (1u << (Shift_TwoForward - Shift_Action));
	static unsigned const Promote			= piece::Pawn | (1u << (Shift_Promote - Shift_Action));
	static unsigned const Castle			= piece::King | (1u << (Shift_Castling - Shift_Action));
	static unsigned const PieceDrop		= piece::None | (1u << (Shift_PieceDrop - Shift_Action));
	static unsigned const En_Passant		= piece::Pawn | (1 << (Shift_EnPassant - Shift_Removal));

	/// Default constructor, creates an empty move
	Move();
	/// Create move from move data (w/o undo data)
	explicit Move(uint32_t m);
	/// Create move with modified from field (used in transposed games)
	Move(Move const& m, sq::ID from);

	/// Moves are considered the same only if they match exactly (discarding info values).
	bool operator==(Move const& m) const;
	bool operator!=(Move const& m) const;
	/// Required for keeping moves in some map-like structures (discarding info values).
	bool operator<(Move const& m1) const;

	/// Check whether move is not empty.
	operator bool () const;
	/// Check whether move is empty.
	bool operator!() const;
	/// Check whether move is prepared for undo.
	bool preparedForUndo() const;

	/// Set promotion piece. Default promotion is to Queen, use this to change piece afterward.
	void setPromotionPiece(piece::Type type);

	/// Return square piece sits on after move.
	Square to() const;
	/// Return Square piece sat on before move.
	Square from() const;
	/// Return square where king was placed before castling.
	Square castlingKingFrom() const;
	/// Return square where rook was placed before castling.
	Square castlingRookFrom() const;
	/// Return square where king is placed after castling.
	Square castlingKingTo() const;
	/// Return square where rook is placed after castling.
	Square castlingRookTo() const;
	/// Return square when en-passant is captured. Undefined if there is no en-passant.
	Square enPassantSquare() const;
	/// Return square where captured piece was placed.
	Square capturedSquare() const;
	/// Return a value usable as an index (15 bit wide).
	unsigned index() const;
	/// Return the index of the from/to fields (12 bit wide).
	unsigned field() const;
	/// Return move data (w/o undo data).
	uint32_t data() const;
	/// Return action of this move.
	uint32_t action() const;
	/// Compute checksum fot this move.
	util::crc::checksum_t computeChecksum(util::crc::checksum_t crc) const;
	/// Return captured piece or en-passant (for doMove() and undoMove()).
	uint32_t removal() const;

	/// Get the piece type moving. Result is undefined for piece drops (Zhouse).
	piece::Type moved() const;
	/// Get the piece moving.
	piece::ID piece() const;
	/// Piece type captured from the opponent by this move.
	piece::Type captured() const;
	/// Piece captured from the opponent by this move.
	piece::ID capturedPiece() const;
	/// Return piece type of captured piece (or 0 if none).
	uint32_t capturedType() const;
	/// Piece type of captured or dropped by this move.
	piece::Type capturedOrDropped() const;
	/// Dropped piece type by this move.
	piece::Type dropped() const;
	/// If move is promotion, get promotion piece type. Result is undefined if there is no promotion.
	piece::Type promoted() const;
	/// If move is promotion, get promotion piece. Result is undefined if there is no promotion.
	piece::ID promotedPiece() const;
	/// If move is piece drop (Zhouse), get dropped piece. Result is undefined if not a piece drop.
	piece::ID droppedPiece() const;

	/// Get the color of the moving piece.
	color::ID color() const;
	/// Get the number of checks given (for Three-check only)
	unsigned checksGiven() const;

	/// Check whether move is empty.
	bool isEmpty() const;
	/// Check whether move is null move.
	bool isNull() const;
	/// Check whether move is an invalid move.
	bool isInvalid() const;
	/// Check whether move is a valid move.
	bool isValid() const;
	/// Check whether move is an invalid move or a null move.
	bool isNullOrInvalid() const;
	/// Check whether move is an undefined move.
	bool isUndefined() const;
	/// Check whether move is special (promotion, castling, en passant).
	bool isSpecial() const;
	/// Check whether move is a capture.
	bool isCapture() const;
	/// Check whether move is a pawn capture
	bool isPawnCapture() const;
	/// Check whether move is capture or promotion.
	bool isCaptureOrPromotion() const;
	/// Check whether move is capture or promotion or piece drop.
	bool isCaptureOrPromotionOrDrop() const;
	/// Check whether move is a promotion.
	bool isPromotion() const;
	/// Check whether this move is an obligation to capture (Antichess)
	bool isObligation() const;

	/// Check whether move is a castling.
	bool isCastling() const;
	/// Check whether move is a short castling.
	bool isShortCastling() const;
	/// Check whether move is a long castling.
	bool isLongCastling() const;
	/// Check whether the move is a pawn double advance.
	bool isDoubleAdvance() const;
	/// Check whether move is an en passant.
	bool isEnPassant() const;
	/// Check whether this move is a piece drop (Zhouse).
	bool isPieceDrop() const;
	/// Check if move is completely legal in the context it was created.
	bool isLegal() const;
	/// Check if move is illlegal in the position.
	bool isIllegal() const;
	/// Check if move is illlegal or invalid in the position.
	bool isIllegalOrInvalid() const;
	/// Check is move is prepared for printing.
	bool isPrintable() const;
	/// Check whether this move is disambuigated for descriptive notation
	bool isDisambiguated() const;

	/// Check whether move is giving check.
	bool givesCheck() const;
	/// Check whether move is giving double check.
	bool givesDoubleCheck() const;
	/// Check whether move is giving checkmate.
	bool givesMate() const;
	/// Check whether fyle is needed to dissolve disambiguation.
	bool needsFyle() const;
	/// Check whether rank is needed to dissolve disambiguation.
	bool needsRank() const;
	// Check whether square is needed to dissolve disambiguation of capturing.
	bool needsDestinationSquare() const;

	/// Print CAN (computer algebraic notation).
	mstl::string& printCAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print LAN (long algebraic notation).
	mstl::string& printLAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print RAN (reversible algebraic notation).
	mstl::string& printRAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print SAN (short algebraic notation).
	mstl::string& printSAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print German SAN (German short algebraic notation).
	mstl::string& printGAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print MAN (minimal algebraic notation).
	mstl::string& printMAN(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print Smith notation.
	mstl::string& printSmith(mstl::string& s, protocol::ID protocol, encoding::CharSet charSet) const;
	/// Print descriptive chess notation (English notation).
	mstl::string& printDescriptive(mstl::string& s, sq::Language lang) const;
	/// Print correspondence form.
	mstl::string& printNumeric(mstl::string& s) const;
	/// Print telegraphic form.
	mstl::string& printAlphabetic(mstl::string& s, encoding::CharSet charSet) const;
	/// Print in given notation style.
	mstl::string& print(	mstl::string& s,
								move::Notation style,
								protocol::ID protocol,
								encoding::CharSet charSet) const;
	/// Print in given notation style.
	mstl::string& printForDisplay(mstl::string& s, move::Notation style) const;

	/// Make empty move.
	void clear();
	/// Mark this move as validated and fully legal in position
	void setLegalMove();
	/// Mark this move as illegal in position
	void setIllegalMove();
	/// Mark this move as legal or illegal in position
	void setLegalMove(bool flag);
	/// Set the side to move (only set once, because setting White after Black is set does not work)
	void setColor(unsigned color);
	/// Set source and destination squares
	void setSquares(uint32_t from, uint32_t to);
	/// Transpose fyle.
	void transpose();
	/// Reset en passant marker.
	void unsetEnPassant();
	/// Clear info status, this is required before print information will be set.
	void clearInfoStatus();

	/// Returns an empty move.
	static Move const& empty();
	/// Returns a null move.
	static Move const& null();
	/// Returns an invalid move.
	static Move const& invalid();
	/// Returns an undefined move.
	static Move const& undefined();
	/// Returns a Pawn move of one forward.
	static Move genOneForward(uint32_t from, uint32_t to);
	/// Returns a two-squares forward move of pawn.
	static Move genTwoForward(uint32_t from, uint32_t to);
	/// Returns a pawn promotion move to given Piecetype.
	static Move genPromote(uint32_t from, uint32_t to, uint32_t type);
	/// Returns a pawn capture and promotion, promote to piece type, capturing type.
	static Move genCapturePromote(uint32_t from, uint32_t to, uint32_t type, uint32_t captured);
	/// Returns a pawn en passant capture of opponent pawn.
	static Move genEnPassant(uint32_t from, uint32_t to);
	/// Returns a simple pawn move with capture of piece type.
	static Move genPawnCapture(uint32_t from, uint32_t to, uint32_t captured);
	/// Returns a move, capturing piece type.
	static Move genMove(uint32_t from, uint32_t to, uint32_t pieceType, uint32_t captured);
	/// Returns a knight move, capturing piece type.
	static Move genKnightMove(uint32_t from, uint32_t to, uint32_t captured = piece::None);
	/// Returns a bishop move, capturing piece type.
	static Move genBishopMove(uint32_t from, uint32_t to, uint32_t captured = piece::None);
	/// Returns a rook move, capturing piece type.
	static Move genRookMove(uint32_t from, uint32_t to, uint32_t captured = piece::None);
	/// Returns a queen move, capturing piece type.
	static Move genQueenMove(uint32_t from, uint32_t to, uint32_t captured = piece::None);
	/// Returns a king move, capturing piece type.
	static Move genKingMove(uint32_t from, uint32_t to, uint32_t captured = piece::None);
	/// Returns a castling move - we are expecting KxR notation for the arguments.
	static Move genCastling(Square from, Square to);
	/// Return a piece dropping move (Zhouse)
	static Move genPieceDrop(Square to, uint32_t type);
	/// Return a move from generic arguments.
	static Move genMove(	uint32_t from,
								uint32_t to,
								uint32_t pieceType,
								uint32_t captured,
								uint32_t promotedType);

	// Convert to string.
	mstl::string asString() const;

	/// Dump move.
	mstl::string& dump(mstl::string& result) const;
	void dump() const;

	/// Make move index.
	static uint16_t makeIndex(uint16_t from, uint16_t to);

	friend class Board;
	friend class MoveList;

private:

	enum { Check, DoubleCheck, Mate };

	/// Move entry constructor, untested (illegal) move with only from, and to squares set.
	Move(Square from, Square to, unsigned color);

	/// Set source square for this move.
	void setFrom(uint32_t from);
	/// Set destination square for this move.
	void setTo(uint32_t to);
	/// Set type of piece (Queen, Rook, Bishop, Knight) pawn promoted to.
	void setPromoted(uint32_t p);
	/// Mark this move capturing a pawn en passant.
	void setEnPassant();
	/// Mark this move as giving check.
	void setCheck();
	/// Mark this move as giving double check.
	void setDoubleCheck();
	/// Mark this move as giving checkmate.
	void setMate();
	/// Set number of checks given (but only if this move gives check)
	void setChecksGiven(unsigned n);
	/// Mark this move that SAN needs fyle.
	void setNeedsFyle();
	/// Mark this move that SAN needs rank.
	void setNeedsRank();
	/// Mark this capturing move that descriptive notation needs destination square.
	void setNeedsDestinationSquare();
	/// Mark this move as an obligation to capture.
	void setIsObligation();
	/// Mark this move as disambuigated for descriptive notation
	void setDisambiguated();
	/// Mark move as prepared for printing.
	void setPrintable();
	/// Print SAN (short algebraic notation).
	mstl::string& printSAN(	mstl::string& s,
									protocol::ID protocol,
									encoding::CharSet charSet,
									bool compact,
									bool useGermanCaptureSign) const;
	mstl::string& printLAN(	mstl::string& s,
									protocol::ID protocol,
									encoding::CharSet charSet,
									bool reversible) const;

	void setUndo(	uint32_t halfMoves,
						uint32_t epSquare,
						uint32_t castlingRights,
						uint32_t kingHasMoved,
						uint32_t capturePromoted);

	uint32_t prevHalfMoves() const;
	Square prevEpSquare() const;
	Byte prevCastlingRights() const;
	Byte prevKingHasMoved() const;
	Byte prevGivesCheck() const;
	bool prevCapturePromoted() const;

	// The move definition 'm' bitfield layout:
	// - move is empty if all bits are zero
	// - move is null if only the legality status is set
	// - the first 12/15 bits are usable as a short move value
	// - group P contains flags for the print routine
	// - do not change the ordering of the groups A, B, and C
	// ----------------------------------------------------------------------------
	// bit mask                              description          bits        group
	// ----------------------------------------------------------------------------
	// 00000000 00000000 00000000 00111111 = from square        = bits  1-6   A
	// 00000000 00000000 00001111 11000000 = to square          = bits  7-12  A
	// 00000000 00000000 01110000 00000000 = promotion piece    = bits 13-15  A
	// 00000000 00000011 10000000 00000000 = piece type         = bits 16-18  B
	// 00000000 00000100 00000000 00000000 = promoted piece?    = bit  19     B
	// 00000000 00001000 00000000 00000000 = castle/successor?  = bit  20     B
	// 00000000 00010000 00000000 00000000 = pawn 2 forward     = bit  21     B
	// 00000000 00100000 00000000 00000000 = promotion?         = bit  22     B
	// 00000000 01000000 00000000 00000000 = piece drop?        = bit  23     B
	// 00000011 10000000 00000000 00000000 = captured piece     = bits 24-26  C
	// 00000100 00000000 00000000 00000000 = en passant?        = bit  27     C
	// 00001000 00000000 00000000 00000000 = side to move       = bit  28     C
	// 01110000 00000000 00000000 00000000 = <unused>           = bits 29-31
	// 10000000 00000000 00000000 00000000 = legality status    = bit  32
	uint32_t m;

	// The move undo 'u' bitfield layout:
	// - only group U belongs to undo
	// - group P contains flags for the print routine
	// NOTE: share king has moved (drop chess) with check given flag (three-checks)
	// ----------------------------------------------------------------------------
	// bit mask                              description          bits        group
	// ----------------------------------------------------------------------------
	// The undo definition 'u' bitfield layout:
	// 00000000 00000000 00111111 11111111 = half move clock    = bits  1-14  U
	// 00000000 01111111 11000000 00000000 = prev. ep square    = bits 15-23  U
	// 00000111 10000000 00000000 00000000 = castling rights    = bits 24-27  U
	// 00011000 00000000 00000000 00000000 = king has moved     = bit  28-29  U
	// 00100000 00000000 00000000 00000000 = capture promoted?  = bit  30     U
	// 01000000 00000000 00000000 00000000 = undo prepared?     = bit  31     U
	// 10000000 00000000 00000000 00000000 = printable?         = bit  32     P
	// -------- share with half move clock ----------------------------------------
	// 00000000 00000000 00000000 00000001 = SAN needs fyle     = bit   1     P
	// 00000000 00000000 00000000 00000010 = SAN needs rank     = bit   2     P
	// 00000000 00000000 00000000 00000100 = needs destination? = bit   3     P
	// 00000000 00000000 00000000 00001000 = disambiguated?     = bit   4     P
	// 00000000 00000000 00000000 00010000 = check?             = bit   5     P
	// 00000000 00000000 00000000 00100000 = double check?      = bit   6     P
	// 00000000 00000000 00000000 01000000 = mate?              = bit   7     P
	// 00000000 00000000 00000001 10000000 = checks given       = bits  8-9   P
	uint32_t u;

	static Move const m_null;
	static Move const m_empty;
	static Move const m_invalid;
	static Move const m_undefined;
};

} // namespace db

namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod<db::Move> { enum { value = 1 }; };

} // namespace mstl

#include "db_move.ipp"

#endif // _db_move_included

// vi:set ts=3 sw=3:
