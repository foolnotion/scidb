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
// This class is loosely based on chessx/src/database/bitboard.h
// ======================================================================

#ifndef _db_board_included
#define _db_board_included

#include "db_move_list.h"
#include "db_signature.h"
#include "db_common.h"

#include "m_string.h"

namespace db {
namespace board {

class Guess;

struct Position
{
	bool operator==(Position const& position) const;
	bool operator!=(Position const& position) const;

	uint64_t m_occupiedBy[2];			// square mask of those occupied by each color
	uint64_t m_pawns;
	uint64_t m_knights;
	uint64_t m_bishops;
	uint64_t m_rooks;
	uint64_t m_queens;
	uint64_t m_kings;
}
__attribute__((packed));

struct ExactPosition : public Position
{
	bool operator==(ExactPosition const& position) const;
	bool operator!=(ExactPosition const& position) const;

	Square	m_castleRookCurrent[4];	// squares of the castling rooks
	Byte		m_stm;						// side to move
	Byte		m_castle;					// flags for castle legality (these can be merged)
	Square	m_epSquare;					// square of a possible ep capture
	Byte		__alignment;				// needed for alignment (otherwise memcmp() won't work)
}
__attribute__((packed));

struct ExactZHPosition : public ExactPosition
{
	typedef material::Count Material;

	bool operator==(ExactZHPosition const& position) const;
	bool operator!=(ExactZHPosition const& position) const;

	union
	{
		// Zhouse
		struct
		{
			Material m_holding[2];		// pieces in hand
			uint32_t m_kingHasMoved;	// boolean flags whether king has moved
		}
		__attribute__((packed));

		// Three-check
		struct
		{
			uint32_t m_checksGiven[2];	// number of checks given
		}
		__attribute__((packed));
	};
}
__attribute__((packed));

struct UniquePosition : public ExactZHPosition
{
	uint32_t	m_halfMoveClock;	// number of moves since last pawn move or capture
	uint32_t	m_plyNumber;		// ply number in game (incremented after each half move)
}
__attribute__((packed));

} // namespace board

class Board : protected board::UniquePosition, protected Signature
{
public:

	enum
	{
		NoCheck		= 0,			///< side to move is not in check
		Check			= 1 << 0,	///< side to move is in check
		DoubleCheck	= 1 << 1,	///< side to move is in double check
		Checkmate	= 1 << 2,	///< side to move is check mate
		Stalemate	= 1 << 3,	///< side to move is stale mate
		Losing		= 1 << 4,	///< side to move has lost all pieces
		ThreeChecks	= 1 << 5,	///< side to move got three checks
	};

	enum SetupStatus
	{
		Valid,							///< position seems to be valid (cannot detect all invalid cases)
		EmptyBoard,						///< board is empty (Anti-Chess)
		NoWhiteKing,					///< white king is missing
		NoBlackKing,					///< black king is missing
		BothInCheck,					///< both kings are in check
		OppositeCheck,					///< opposite king is in check
		OppositeLosing,				///< opponent has lost all pieces
		TooManyWhitePawns,			///< more than eight white pawns
		TooManyBlackPawns,			///< more than eight black pawns
		TooManyWhitePieces,			///< too many white queens, rooks, bishops, or knights
		TooManyBlackPieces,			///< too many black queens, rooks, bishops, or knights
		PawnsOn18,						///< pawn on 1st or 8th rank
		TooManyKings,					///< more than 2 kings
		TooManyWhite,					///< more than sixteen white pieces
		TooManyBlack,					///< more than sixteen black pieces
		BadCastlingRights,			///< can't castle
		InvalidCastlingRights,		///< unreasonable rook fyles (or ranks)
		AmbiguousCastlingFyles,		///< castling rook fyles are ambiguous
		InvalidEnPassant,				///< unreasonable en passant square
		MultiPawnCheck,				///< two or more pawns give check
		TripleCheck,					///< three or more pieces give check
		TooManyPiecesInHolding,		///< too many pieces in holding
		TooFewPiecesInHolding,		///< too few pieces in holding
		TooManyPromotedPieces,		///< too many pieces marked as promoted
		TooFewPromotedPieces,		///< too many pieces marked as promoted
		IllegalCheckCount,			///< illegal check count
	};

	enum Representation
	{
		InternalRepresentation,
		ExternalRepresentation,
	};

	enum Format { XFen, Shredder };

	typedef material::Count Material;

	Board();
	Board(Board const& board);

	Board& operator=(Board const& board);

	// Play moves on board

	/// Play given move, updating board state appropriately
	void doMove(Move const& m, variant::Type variant);
	/// Play back given move, updating board state appropriately
	void undoMove(Move const& m, variant::Type variant);
	/// Play given moves; returns whether the moves are valid
	bool doMoves(char const* text);

	// Setup board

	/// Remove all pieces and state from board
	void clear();
	/// Clear holding.
	void clearHolding();
	/// Set the given piece on the board at the given square
	bool setAt(Square s, piece::ID p, variant::Type variant);
	/// Remove any piece sitting on given square
	void removeAt(Square s, variant::Type variant);
	/// Set side to move as that of given color (NOTE: does bot affect the ply number)
	void setToMove(color::ID color);
	/// Set initial chess game position on the board
	void setStandardPosition();
	/// Set initial chess game position on the board
	void setStandardPosition(variant::Type variant);
	/// Parse given FEN, return true if loaded properly otherwise false
	char const* setup(char const* fen, variant::Type variant);
	/// Setup board from given IDN (unique IDentification Number)
	void setup(unsigned idn, variant::Type variant);
	/// Setup board from given position
	void setup(ExactZHPosition const& position, variant::Type variant);
	/// Set En Passant fyle
	void setEnPassantFyle(sq::Fyle fyle);
	/// Set En Passant fyle
	void setEnPassantFyle(color::ID color, sq::Fyle fyle);
	/// Set En Passant square
	void setEnPassantSquare(Square sq);
	/// Set En Passant square
	void setEnPassantSquare(color::ID color, Square sq);
	/// Set the ply number.
	void setPlyNumber(unsigned number);
	/// Set the move number (NOTE: side to move must be set before).
	void setMoveNumber(unsigned number);
	/// Set the half move clock,
	void setHalfMoveClock(unsigned number);
	/// Set the number of checks given for both sides.
	void setChecksGiven(unsigned white, unsigned black);
	/// Transpose board position.
	void transpose(variant::Type variant);

	// Move factories

	/// Return a null move (side to move will be set)
	Move makeNullMove() const;
	/// Parse any (LAN, SAN, or algebraic) representation of move, and return proper Move() object
	Move parseMove(char const* algebraic,
						variant::Type variant,
						move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Parse any (LAN, SAN, or algebraic) representation of move, and return string position after move
	char const* parseMove(	char const* algebraic,
									Move& move,
									variant::Type variant,
									move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Parse LAN representation of move, and return string position after move
	Move parseLAN(char const* algebraic, move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Parse LAN representation of move, and return string position after move
	char const* parseLAN(	char const* algebraic,
									Move& move,
									move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Return a proper Move() object given only a from-to move specification
	Move prepareMove(	Square from,
							Square to,
							variant::Type variant,
							move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Return a proper Move() object given only a to-piece move specification
	Move preparePieceDrop(	Square to,
									piece::Type piece,
									move::Constraint flag = move::DontAllowIllegalMove) const;
	/// Return a move object given only a from-to move specification (cannot handle promotions)
	Move makeMove(uint16_t move) const;
	/// Return a move object given only a from-to move specification
	Move makeMove(Square from, Square to, piece::Type promotedOrDrop = piece::Queen) const;
	/// Prepare a move for undo operation.
	void prepareUndo(Move& move) const;
	/// Generate all possible moves in a given position
	void generateMoves(variant::Type variant, MoveList& result) const;
	/// Generate all possible capturing piece (not pawns) moves in a given position
	void generateCapturingPieceMoves(variant::Type variant, MoveList& result) const;
	/// Generate all possible capturing pawn moves in a given position
	void generateCapturingPawnMoves(variant::Type variant, MoveList& result) const;
	/// Generate all possible castling moves in a given position.
	void generateCastlingMoves(MoveList& result) const;
	/// Remove all illegal moves from given move list (king remains in check).
	void filterLegalMoves(MoveList& result, variant::Type variant) const;

	// Query

	/// Return true if this is an empty board.
	bool isEmpty() const;
	/// Return true if position is same, but don't consider side to move, castling rights and e.p. fyle
	bool isSamePosition(Board const& target) const;
	/// Return true if position is equal
	bool isEqualPosition(Board const& target) const;
	/// Return true if ZH position is equal
	bool isEqualZHPosition(Board const& target) const;
	/// Return true if side to move is in check
	bool isInCheck() const;
	/// Return true if given side is in check
	bool isInCheck(color::ID color) const;
	/// Return true if given move is a contact check or double check
	bool isUnblockableCheck(Move const& move, variant::Type variant) const;
	/// Return true if side not to move gives a contact check
	bool isContactCheck() const;
	/// Return true if side to move is mate
	bool isMate(variant::Type variant) const;
	/// Return true if side not to move is in check
	bool givesCheck() const;
	/// Return true if side to move is in double check
	bool isDoubleCheck() const;
	/// Test to see if given color has the right to castle on kingside
	bool canCastleShort(color::ID color) const;
	/// Test to see if given color has the right to castle on queenside
	bool canCastleLong(color::ID color) const;
	/// Test to see if given color has any castling rights remaining
	bool canCastle(color::ID color) const;
	/// Return whether side next to move is white
	bool whiteToMove() const;
	/// Return whether side next to move is black
	bool blackToMove() const;
	/// Return true if the standard start position is on the board
	bool isStandardPosition(variant::Type variant) const;
	/// Return true if a start position is on the board
	bool isStartPosition() const;
	/// Return true if a chess 960 start position is on the board
	bool isChess960Position(variant::Type variant) const;
	/// Returns true is a shuffle chess start position (without castling rights) is on the board
	bool isShuffleChessPosition(variant::Type variant) const;
	/// Return whether opponent side is not in check (then last move is legal)
	bool isLegal() const;
	/// Return whether the move is valid (and legal)
	bool isValidMove(	Move const& move,
							variant::Type variant,
							move::Constraint flag = move::AllowIllegalMove) const;
	/// Return whether castling rook position is ambiguous
	bool needCastlingFyles() const;
	/// Return whether position cannot be derived from standard chess position
	bool notDerivableFromStandardChess() const;
	/// return whether position cannot be derived from chess 960 start position
	bool notDerivableFromChess960() const;
	/// Return true if making move would put oneself into check
	bool isIntoCheck(Move const& move, variant::Type variant) const;
	/// Check whether given castling is unambiguous
	bool isUnambiguous(castling::Index castling) const;
	/// Check whether the kings are on board
	bool kingOnBoard() const;
	/// Check whether the king of given side is on board
	bool kingOnBoard(color::ID color) const;
	/// Check whether game is over for given color
	bool gameIsOver(variant::Type variant) const;
	/// Returns whether piece at given square is marked as promoted
	bool hasPromoted(Square sq) const;
	/// Returns whether given side has a bishop on dark squares
	bool hasBishopOnDark(color::ID side) const;
	/// Returns whether given side has a bishop on lite squares
	bool hasBishopOnLite(color::ID side) const;
	/// Returns whether the partner board (Bughouse) is set
	bool hasPartnerBoard() const;
	/// Returns whether any of the given squares is occupied
	bool anyOccupied(uint64_t squares) const;
	/// Returns whether this game is drawn due to bishops of opposite colors
	bool drawnDueToBishopsOfOppositeColors(variant::Type variant) const;
	/// Returns whether neither player has mating material
	bool neitherPlayerHasMatingMaterial(variant::Type variant) const;
	/// Returns whether given side cannot win.
	bool cannotWin(color::ID color, variant::Type variant) const;

	/// Returns current board state (check mate, stale mate, ...)
	unsigned checkState(variant::Type variant) const;
	/// Returns current board state after moving (check mate, stale mate, ...)
	unsigned checkState(Move const& move, variant::Type variant) const;
	/// Return number of ply since a pawn move or capture
	unsigned halfMoveClock() const;
	/// Return the current ply number in the game
	unsigned plyNumber() const;
	/// Return the current move number in the game
	unsigned moveNumber() const;
	/// Return color of side next to move
	color::ID sideToMove() const;
	/// Return opponent color of side next to move
	color::ID notToMove() const;
	/// Return current castling rights
	castling::Rights currentCastlingRights() const;
	/// Return the castling rights data
	castling::Rights castlingRights() const;
	/// Return the castling rights data for given color
	castling::Rights castlingRights(color::ID color) const;
	/// Return piece sitting at given square on the board
	piece::ID pieceAt(Square s) const;
	/// Return piece type sitting at given square on the board (None if Null is given)
	piece::Type piece(Square s) const;
	/// Return square where en passant capture may occur, or null square
	Square enPassantSquare() const;
	/// Returns the signature
	Signature const& signature() const;
	/// Returns the signature
	Signature& signature();
	/// Returns the hash value
	uint64_t hash() const;
	/// Returns the pawn hash value
	uint64_t pawnHash() const;
	/// Returns the hash value w/o en passant hashing
	uint64_t hashNoEP() const;
	/// Return number of pieces of given color (exluding pawns)
	unsigned countPieces(color::ID color) const;
	/// Return rook right from king (or null square)
	Square shortCastlingRook(color::ID color) const;
	/// Return rook left from king (or null square)
	Square longCastlingRook(color::ID color) const;
	/// Return board position
	board::Position const& position() const;
	/// Return exact board position (includes castling rights, en passant, side to move)
	board::ExactPosition const& exactPosition() const;
	/// Return exact board position for bughouse games
	board::ExactZHPosition const& exactZHPosition() const;
	/// Return unique board position(castling rights, en passant, side to move, ply number, e.p. fyle)
	board::UniquePosition const& uniquePosition() const;
	/// Return material count.
	material::Count materialCount(color::ID color) const;
	/// Return square of castling square (maybe Null).
	Square castlingRookSquare(castling::Index index) const;
	/// Return square of king.
	Square kingSquare(color::ID color) const;
	/// Return whether the move is valid
	bool checkMove(Move const& move,
						variant::Type variant,
						move::Constraint flag = move::AllowIllegalMove) const;
	/// Return the number of checks given for specified side.
	unsigned checksGiven(color::ID color) const;
	/// Returns the current board status.
	board::Status status(variant::Type variant) const;

	// Query other formats

	/// Return a FEN string based on current board position
	mstl::string toFen(variant::Type variant, Format format = XFen) const;
	/// Return a FEN string based on current board position
	mstl::string& toFen(mstl::string& result, variant::Type variant, Format format = XFen) const;
	/// Return a position description based on current board position
	mstl::string asString() const;
	/// Prepare move for printing a SAN
	Move& prepareForPrint(Move& move, variant::Type variant, Representation representation) const;
	/// Returns the IDN (chess 960 unique IDentification Number)
	unsigned computeIdn(variant::Type variant) const;
	/// Returns the material in hand for side to move.
	Material holding() const;
	/// Returns the material in hand for given color.
	Material holding(color::ID color) const;

	// Castling rights

	/// Grant castling rights on the kingside to the given color
	void setCastleShort(color::ID color);
	/// Grant castling rights on the queenside to the given color
	void setCastleLong(color::ID color);
	/// Remove castling rights on the kingside to the given color
	void tryCastleShort(color::ID color);
	/// Grant castling rights on the queenside to the given color
	void tryCastleLong(color::ID color);
	/// Set castling file for the given color, but only if the specified rook exists
	void setCastlingFyle(color::ID color, sq::Fyle fyle);
	/// Remove all castling rights
	void removeCastlingRights();
	/// Remove castling rights for given color
	void removeCastlingRights(color::ID color);
	/// Remove castling rights for given castling index
	void removeCastlingRights(castling::Index index);
	/// Remove castling rights for given rook
	void removeCastlingRights(Square rook);
	/// Fix bad castling rights (may happen in Scid or in PGN files)
	void fixBadCastlingRights();
	/// Mark piece at given position as promoted
	void setPromoted(Square sq, variant::Type variant);
	/// Setup the holding.
	void setHolding(char const* pieces);
	/// Setup castling rook for short castling from given fen
	void setupShortCastlingRook(color::ID color, char const* fen);
	/// Setup castling rook for short castling from given fen
	void setupLongCastlingRook(color::ID color, char const* fen);

	// Bit fields

	/// Return all sqaures occupied by any piece of any color
	uint64_t pieces() const;
	/// Return all sqaures occupied by any piece of given color
	uint64_t pieces(color::ID color) const;
	/// Return all sqaures occupied by kings of given color
	uint64_t kings(color::ID color) const;
	/// Return all sqaures occupied by queens of given color
	uint64_t queens(color::ID color) const;
	/// Return all sqaures occupied by rooks of given color
	uint64_t rooks(color::ID color) const;
	/// Return all sqaures occupied by bishops of given color
	uint64_t bishops(color::ID color) const;
	/// Return all sqaures occupied by knights of given color
	uint64_t knights(color::ID color) const;
	/// Return all sqaures occupied by pawns of given color
	uint64_t pawns(color::ID color) const;
	/// Return all empty squares
	uint64_t empty() const;
	/// Return all squares attacked by any piece of given color on given square
	uint64_t attacks(unsigned color, Square square) const;

	// Miscellaneous

	/// Swap the side to move
	void swapToMove();

	/// Static Exchange Evaluator (SSE): is used to analyze capture moves.
	int staticExchangeEvaluator(Move const& move, int const* pieceValues) const;

	// Validation

	/// Check current position and return "Valid" or problem
	SetupStatus validate(variant::Type variant,
								castling::Handicap handicap = castling::AllowHandicap,
								move::Constraint flag = move::AllowIllegalMove) const;
	/// Set given castling rights (do not use except for generating FEN's)
	void setCastlingRights(castling::Rights rights);
	/// Check (and possibly correct) pieces in holding.
	void checkHolding();

	// Helpers

	/// Dump board, useful for debugging
	void dump() const;

	/// Return the standard position
	static Board const& standardBoard(variant::Type variant);
	/// Return an empty board
	static Board const& emptyBoard();
	/// Return whether FEN is valid
	static bool isValidFen(	char const* fen,
									variant::Type variant,
									castling::Handicap handicap = castling::AllowHandicap,
									move::Constraint flag = move::AllowIllegalMove);

	static void initialize();

private:

	friend class Guess;

	typedef Byte (*ChangeSide)(Byte);

	uint64_t king(color::ID color) const;

	uint64_t whitePieces() const;
	uint64_t blackPieces() const;

	sq::ID kingSq(color::ID side) const;

	bool enPassantMoveExists(Byte color) const;
	bool checkShuffleChessPosition() const;

	/// Return true if side not to move gives a contact check (cannot be blocked by a piece)
	bool checkContactCheck() const;
	/// Return true if the given square is attacked by the given color
	bool isAttackedBy(unsigned color, Square square) const;
	/// Return true if the given squares are attacked by the given color
	bool isAttackedBy(unsigned color, uint64_t square) const;
	/// Return whether the move is legal; and sets move legal if it is legal
	bool checkIfLegalMove(Move& move) const;
	/// Return whether check cannot be blocked with a pawn
	bool checkNotBlockableWithPawn() const;
	/// Return true if a chess 960 start position is on the board
	bool isChess960Position() const;

	uint64_t rankAttacks(Square square, uint64_t occupied) const;
	uint64_t fyleAttacks(Square square, uint64_t occupied) const;

	uint64_t rankAttacks(Square square) const;
	uint64_t fyleAttacks(Square square) const;
	uint64_t diagA1H8Attacks(Square square) const;
	uint64_t diagH1A8Attacks(Square square) const;

	unsigned countChecks() const;

	/// Return all possible pawn moves from given square
	uint64_t pawnMovesFrom(Square square) const;
	/// Return all possible pawn moves capturing pawn on given square
	uint64_t pawnCapturesTo(Square square) const;

	/// Return all squares attacked by a knight on given square
	uint64_t knightAttacks(Square square) const;
	/// Return all squares attacked by a bishop on given square
	uint64_t bishopAttacks(Square square) const;
	/// Return all squares attacked by a rook on given square
	uint64_t rookAttacks(Square square) const;
	/// Return all squares attacked by a queen on given square
	uint64_t queenAttacks(Square square) const;
	/// Return all squares attacked by a king on given square
	uint64_t kingAttacks(Square square) const;

	/// Remove impossible moves from given board to aid disambiguation
	void removeIllegalTo(Move move, uint64_t& b, variant::Type variant) const;
	/// Remove impossible moves from given board to aid disambiguation
	void removeIllegalFrom(Move move, uint64_t& b, variant::Type variant) const;
	/// Return move with castling details, return empty move if no castle is possible
	Move prepareCastle(Square from, Square to, move::Constraint flag) const;

   void filterCheckMoves(Move move, uint64_t& movers, variant::Type variant) const;
   void filterCheckmateMoves(Move move, uint64_t& movers, variant::Type variant) const;

	/// Revoke all castling rights from the given color
	void destroyCastle(color::ID color);
	/// Restore castling rights after undo.
	void restoreCastlingRights(uint8_t prevCastlingRights);
	/// Restore half move clock and en passant after undo.
	void restoreStates(Move const& m);

	/// set the given piece on the board at the given square
	void setupAt(Square s, piece::Type p, color::ID color, variant::Type variant);
	/// set move color
	Move setMoveColor(Move move) const;
	/// set move legal
	Move setLegalMove(Move move) const;
	/// Reset holding.
	void resetHolding();

	// pawn progressing
	void pawnProgressMove(unsigned color, unsigned from, unsigned to);
	void pawnProgressRemove(unsigned color, unsigned at);
	void pawnProgressAdd(unsigned color, unsigned at);

	// helpers
	void generatePieceDropMoves(MoveList& result) const;
	void generateNonCapturingPieceMoves(variant::Type variant, MoveList& result) const;
	void generateNonCapturingPawnMoves(variant::Type variant, MoveList& result) const;

	void genCastleShort(MoveList& result, color::ID side) const;
	void genCastleLong(MoveList& result, color::ID side) const;

	void setCastleShort(color::ID color, unsigned square);
	void setCastleLong(color::ID color, unsigned square);

	bool shortCastlingIsLegal() const;
	bool longCastlingIsLegal() const;
	bool shortCastlingWhiteIsLegal() const;
	bool shortCastlingBlackIsLegal() const;
	bool longCastlingWhiteIsLegal() const;
	bool longCastlingBlackIsLegal() const;

	bool shortCastlingIsPossible() const;
	bool longCastlingIsPossible() const;
	bool shortCastlingWhiteIsPossible() const;
	bool shortCastlingBlackIsPossible() const;
	bool longCastlingWhiteIsPossible() const;
	bool longCastlingBlackIsPossible() const;

	bool findAnyLegalMove(variant::Type variant) const;
	bool containsAnyLegalMove(MoveList const& moves, variant::Type variant) const;

	uint64_t addXrayPiece(unsigned from, unsigned target) const;

	char const* parsePieceDrop(char const* s,
										Move& move,
										variant::Type variant,
										piece::Type pieceType,
										unsigned count,
										move::Constraint flag) const;
	Move prepareMove(Move& move, variant::Type variant, move::Constraint flag) const;
	void filterMoves(MoveList& list, unsigned state, variant::Type variant) const;
	char const* parseHolding(char const* s);
	void hashHolding(Material white, Material black);

	// hashing functions
	void hashPiece(Square s, piece::ID piece);
	void hashPiece(Square s, Square t, piece::ID piece);
	void hashPromotedPiece(Square s, piece::ID piece, variant::Type variant);
	void hashPawn(Square s, piece::ID piece);
	void hashPawn(Square s, Square t, piece::ID piece);
	void hashEnPassant();
	void hashToMove();
	void hashCastlingKingside(color::ID color);
	void hashCastlingQueenside(color::ID color);
	void hashCastling(castling::Index right);
	void hashCastling(color::ID color);
	void hashChecksGiven(color::ID color, unsigned n);
	void hashChecksGiven(unsigned white, unsigned black);
	void hashHoldingChanged(piece::ID piece, Byte count);
	void hashHolding(piece::ID piece, Byte count);
	template <piece::Type Piece>
	void addToHolding(variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void addToHolding(uint64_t toMask, variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void addToMyHolding(variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void removeFromHolding(variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void removeFromHolding(uint64_t fromMask, variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void removeFromMyHolding(variant::Type variant, unsigned color);
	template <piece::Type Piece>
	void possiblyRemoveFromHolding(variant::Type variant, unsigned color);
	template <piece::Type Piece> void incrMaterial(unsigned color);
	template <piece::Type Piece> void decrMaterial(unsigned color);

	// Additional board data
	uint64_t	m_occupied;					// square is empty or holds a piece
	uint64_t	m_occupiedL90;				// rotated counter clockwise 90 deg
	uint64_t	m_occupiedL45;				// an odd transformation, to straighten out diagonals
	uint64_t	m_occupiedR45;				// the opposite odd transformation, just as messy

	// Extra state data
	Board*	m_partner;					// partner board in Bughouse
	Byte		m_piece[64];				// type of piece on this square
	Byte		m_destroyCastle[64];		// inverted castle mask for each square
	Byte		m_unambiguous[4];			// whether castling rook fyles are unambiguous
	Square	m_ksq[2];					// square of the kings
	bool		m_capturePromoted;		// position after a pawn capture with promotion
	uint64_t	m_hash;						// hash value
	uint64_t	m_pawnHash;					// pawn hash value
	uint64_t	m_promoted[2];				// positions of promoted pieces
	uint32_t	m_countKingMoves[2];		// count king moves
	Square	m_castleRookAtStart[4];	// initial squares of the castling rooks
	Material	m_material[2];				// material count

	// ========================================================================
	// NOTE: for (general) position search the following members are relevant:
	// ========================================================================
	// ------------------------------------------------------------------------
	// Position:
	// ------------------------------------------------------------------------
	// m_occupiedBy
	// m_pawns
	// m_knights
	// m_bishops
	// m_rooks
	// m_queens
	// m_kings
	// ------------------------------------------------------------------------
	// ExactPosition:
	// ------------------------------------------------------------------------
	// m_stm
	// m_castle
	// m_epSquare
	// ------------------------------------------------------------------------
	// ExactZHPosition:
	// ------------------------------------------------------------------------
	// m_holding			(Zhouse)
	// m_checksGiven		(Three-Check)
	// ------------------------------------------------------------------------
	// Board:
	// ------------------------------------------------------------------------
	// m_hash
	// m_pawnHash
	// m_material
	// m_promoted			(Zhouse)
	// ------------------------------------------------------------------------
	// Signature:
	// ------------------------------------------------------------------------
	// m_promotions
	// m_underPromotions
	// m_castling
	// ========================================================================

	// Class data
	static Board m_emptyBoard;
	static Board m_standardBoard;
	static Board m_shuffleChessBoard;
	static Board m_antichessBoard;
	static Board m_littleGame;
	static Board m_pawnsOn4thRank;
	static Board m_pyramid;
	static Board m_KNNvsKP;
	static Board m_pawnsOnly;
	static Board m_knightsOnly;
	static Board m_bishopsOnly;
	static Board m_rooksOnly;
	static Board m_queensOnly;
	static Board m_noQueens;
	static Board m_wildFive;
	static Board m_kbnk;
	static Board m_kbbk;
	static Board m_runaway;
	static Board m_queenVsRooks;
	static Board m_upsideDown;
}
__attribute__((packed));

} // namespace db

namespace mstl {

template <typename T> struct is_pod;

template <> struct is_pod<db::Board> 						{ enum { value = 1 }; };
template <> struct is_pod<db::board::Position>			{ enum { value = 1 }; };
template <> struct is_pod<db::board::ExactPosition>	{ enum { value = 1 }; };
template <> struct is_pod<db::board::ExactZHPosition>	{ enum { value = 1 }; };
template <> struct is_pod<db::board::UniquePosition>	{ enum { value = 1 }; };

} // namespace mstl

#include "db_board.ipp"

#endif // _db_board_included

// vi:set ts=3 sw=3:
