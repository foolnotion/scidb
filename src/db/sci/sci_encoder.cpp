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

#include "sci_encoder.h"
#include "sci_common.h"

#include "db_move.h"
#include "db_move_node.h"
#include "db_mark_set.h"
#include "db_move_info_set.h"
#include "db_annotation.h"
#include "db_board.h"
#include "db_game_data.h"
#include "db_exception.h"

#include "m_assert.h"

using namespace db;
using namespace db::sci;
using namespace util;


typedef ByteStream::uint24_t uint24_t;


namespace {

struct TagLookup
{
	static void initialize()
	{
		m_info.set(tag::Event);
		m_info.set(tag::Site);
		m_info.set(tag::Date);
		m_info.set(tag::Round);
		m_info.set(tag::White);
		m_info.set(tag::Black);
		m_info.set(tag::Result);
		m_info.set(tag::Annotator);
		m_info.set(tag::Eco);
		m_info.set(tag::WhiteElo);
		m_info.set(tag::BlackElo);
		m_info.set(tag::WhiteCountry);
		m_info.set(tag::BlackCountry);
		m_info.set(tag::WhiteTitle);
		m_info.set(tag::BlackTitle);
		m_info.set(tag::WhiteType);
		m_info.set(tag::BlackType);
		m_info.set(tag::WhiteSex);
		m_info.set(tag::BlackSex);
		m_info.set(tag::WhiteFideId);
		m_info.set(tag::BlackFideId);
		m_info.set(tag::EventDate);
		m_info.set(tag::EventCountry);
		m_info.set(tag::EventType);
		m_info.set(tag::Mode);
		m_info.set(tag::TimeMode);
		m_info.set(tag::Termination);
		m_info.set(tag::Variant);
		m_info.set(tag::SetUp);
		m_info.set(tag::Fen);

		m_ignore = m_info;
		m_ignore.set(tag::Idn);
		m_ignore.set(tag::PlyCount);
		m_ignore.set(tag::EventDate);
	}

	static db::tag::TagSet m_info;
	static db::tag::TagSet m_ignore;

	static db::tag::TagSet const& infoTags()		{ return m_info; }
	static db::tag::TagSet const& ignoreTags()	{ return m_ignore; }

	static bool skipTag(tag::ID tag) 				{ return m_info.test(tag); }
};

db::tag::TagSet TagLookup::m_info;
db::tag::TagSet TagLookup::m_ignore;

static void
__attribute__((constructor))
initialize()
{
	TagLookup::initialize();
}

} // namespace


Encoder::Encoder(ByteStream& strm, variant::Type variant)
	:m_strm(strm)
	,m_data(m_buffer[0], sizeof(m_buffer[0]))
	,m_text(m_buffer[1], sizeof(m_buffer[1]))
	,m_runLength(0)
	,m_variant(variant)
{
}


inline
void
Encoder::putMoveByte(Square from, Byte value)
{
	M_ASSERT(value <= 15);

	Byte pieceNum = m_position[from];

	if (pieceNum & 0x10)
	{
		m_strm.put(token::Special_Move);
		pieceNum &= 0x0f;
	}

	M_ASSERT(((pieceNum << 4) | value) > token::Special_Move);

   m_strm.put((pieceNum << 4) | value);
}


void
Encoder::encodePieceDrop(Move const& move)
{
	M_ASSERT(move.isPieceDrop());

	Byte pieceNum = m_position.dropPiece(move);

	if (pieceNum >= 16)
	{
		pieceNum &= 0x0f;
		pieceNum |= 0x20;
	}

	M_ASSERT(pieceNum < 64);
	// Make sure that it cannot clash with the special tokens.
	m_strm.put(move.dropped() | 8);
	m_strm.put(pieceNum | 64);
	m_strm.put(move.to() | 64);
}


inline
void
Encoder::encodeNullOrDropMove(Move const& move)
{
	M_ASSERT(move.isNull() || variant::isZhouse(m_variant));

	m_strm.put(token::Special_Move);

	if (variant::isZhouse(m_variant))
	{
		if (move.isNull())
			m_strm.put(token::Special_Move);
		else
			encodePieceDrop(move);
	}
}


inline
void
Encoder::encodeKing(Move const& move)
{
	// Valid King difference-from-old-square values are:
	// -9, -8, -7, -1, 1, 7, 8, 9 (w/o castling).
	// To convert this to a value in the range [1-9], we add 9 and
	// then look up the Value[] table.

	static Byte const Value[] =
	{
	//-9  -8  -7  -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6   7   8   9
		6,  7,  8,  0,  0,  0,  0,  0,  9,  0, 10,  0,  0,  0,  0,  0, 11, 12, 13
	};

	Square from = move.from();

	if (move.isCastling())
	{
		putMoveByte(from, move.isShortCastling() ? 14 : 15);
	}
	else
	{
		unsigned diff = 9 + move.to() - from;

		// Verify we have a valid King move:
		M_ASSERT(diff < U_NUMBER_OF(Value) && Value[diff] != 0);
		putMoveByte(from, Value[diff]);
	}
}


inline
void
Encoder::encodeQueen(Move const& move)
{
	// We cannot fit all Queen moves in one byte, so Rooklike moves
	// are in one byte (encoded the same way as Rook moves),
	// while diagonal moves are in two bytes.

	Square from	= move.from();
	Square to	= move.to();

	M_ASSERT(to <= sq::h8 && from <= sq::h8);

	if (sq::rank(from) == sq::rank(to))
	{
		// Rook-horizontal move
		putMoveByte(from, sq::fyle(to));
	}
	else if (sq::fyle(from) == sq::fyle(to))
	{
		// Rook-vertical move
		putMoveByte(from, sq::rank(to) + 8);
	}
	else
	{
		// Diagonal move:
		// First, we put a rook-horizontal move to the from square (which
		// is illegal of course) to indicate it is NOT a rooklike move.
		putMoveByte(from, sq::fyle(from));

		M_ASSERT(to < 64);
		// Now we put the to-square in the next byte. We make sure that it
		// cannot clash with the special tokens.
		m_strm.put(to | 64);
	}
}


inline
void
Encoder::encodeRook(Move const& move)
{
	// Valid Rook moves are to same rank, OR to same fyle.
	// We encode the 8 squares on the same rank 0-8, and the 8
	// squares on the same fyle 9-15. This means that for any particular
	// rook move, two of the values in the range [0-15] will be
	// meaningless, as they will represent the from-square.

	Square	from	= move.from();
	Square 	to		= move.to();
	Byte		value;

	// Check if the two squares share the same rank
	if (sq::rank(from) == sq::rank(to))
		value = sq::fyle(to);
	else
		value = sq::rank(to) + 8;

	putMoveByte(from, value);
}


inline
void
Encoder::encodeBishop(Move const& move)
{
	// We encode a Bishop move as the Fyle moved to, plus
	// a one-bit flag to indicate if the direction was
	// up-right/down-left or vice versa.

	Square	from		= move.from();
	Square 	to			= move.to();
	Byte		value		= sq::fyle(to);
	int		rankDiff	= int(sq::rank(to)) - int(sq::rank(from));
	int		fyleDiff	= int(sq::fyle(to)) - int(sq::fyle(from));

	// If (rankdiff*fylediff) is negative, it's up-left/down-right
	if ((rankDiff ^ fyleDiff) < 0)
		value += 8;

	putMoveByte(from, value);
}


inline
void
Encoder::encodeKnight(Move const& move)
{
	// Valid Knight difference-from-old-square values are:
	// -17, -15, -10, -6, 6, 10, 15, 17.
	// To convert this to a value in the range [1-8], we add 17 to
	// the difference and then look up the value[] table.

	static Byte const Value[] =
	{
	//-17 -16 -15 -14 -13 -12 -11 -10  -9  -8  -7  -6  -5  -4  -3  -2  -1   0
		 1,  0,  2,  0,  0,  0,  0,  3,  0,  0,  0,  4,  0,  0,  0,  0,  0,  0,
	//  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17
		 0,  0,  0,  0,  0,  5,  0,  0,  0,  6,  0,  0,  0,  0,  7,  0 , 8
	};

	int from	= move.from();
	int diff	= int(move.to()) - from;

	// Verify we have a valid knight move:
	M_ASSERT(-17 <= diff && diff <= 17 && Value[diff + 17] != 0);
	putMoveByte(from, Value[diff + 17]);
}


void
Encoder::encodePawn(Move const& move)
{
	// Pawn moves require a promotion encoding.
	// The pawn moves are:
	// 0 = capture-left,
	// 1 = forward,
	// 2 = capture-right (all no promotion);
	//         3/4/5 = 0/1/2 with Queen promo;
	//         6/7/8 = 0/1/2 with Rook promo;
	//       9/10/11 = 0/1/2 with Bishop promo;
	//      12/13/14 = 0/1/2 with Knight promo;
	// 15 = forward TWO squares.

	Square	from	= move.from();
	Byte		value = mstl::abs(int(move.to()) - int(from));	// suppress gcc warning

	if (move.isPromotion())
	{
		if (move.promoted() == piece::King)
		{
			M_ASSERT(variant::isAntichessExceptLosers(m_variant));
			// Anti-chess in general allows promotion to a king.
			putMoveByte(from, 15);
			m_strm.put(value);
			return;
		}

		// Handle promotions.
		// move.promotedPiece() must be Queen=2, Rook=3, Bishop=4 or Knight=5.
		// We add 3 for Queen, 6 for Rook, 9 for Bishop, 12 for Knight.

		static_assert(		piece::Queen == 2
							&& piece::Rook == 3
							&& piece::Bishop == 4
							&& piece::Knight == 5,
							"reimplementation required");

		M_ASSERT(2 <= move.promoted() && move.promoted() <= 5);
		M_ASSERT(value != 16);

		putMoveByte(from, value + 3*(move.promoted() - 1) - 7);
	}
	else if (value == 16)
	{
		putMoveByte(from, 15);
	}
	else
	{
		putMoveByte(from, value - 7);
	}
}


bool
Encoder::encodeMove(Move const& move)
{
	M_ASSERT(	(	move.pieceMoved() == piece::None
					&& (!move.isPieceDrop() || move.dropped() == piece::None))
				== move.isNull());

	switch (move.pieceMoved())
	{
		case piece::None:		encodeNullOrDropMove(move); break;
		case piece::King:		encodeKing(move); break;
		case piece::Queen:	encodeQueen(move); break;
		case piece::Rook:		encodeRook(move); break;
		case piece::Bishop:	encodeBishop(move); break;
		case piece::Knight:	encodeKnight(move); break;
		case piece::Pawn:		encodePawn(move); break;
	}

	if (move.isLegal())
		return true;

	m_strm.put(token::Nag);
	m_data.put(0);

	return false;
}


void
Encoder::encodeMainline(MoveNode const* node, TimeTable const& timeTable)
{
	if (node->hasSupplement())
	{
		encodeNote(node, &timeTable);
		encodeVariation(node->next(), timeTable);
	}
	else
	{
		for (node = node->next(); node->isBeforeLineEnd(); node = node->next())
		{
			if (node->hasSupplement())
				return encodeVariation(node, timeTable);

			if (!doEncoding(node->move()))
				return encodeVariation(node->next(), timeTable);

			++m_runLength;
		}

		encodeVariation(node, timeTable);
	}
}


void
Encoder::encodeVariation(MoveNode const* node, TimeTable const& timeTable)
{
	for ( ; node->isBeforeLineEnd(); node = node->next())
	{
		encodeMove(node->move());

		if (node->hasSupplement())
		{
			if (node->hasNote())
				encodeNote(node, &timeTable);

			for (unsigned i = 0; i < node->variationCount(); ++i)
			{
				MoveNode const* var = node->variation(i);

				m_position.push();
				m_strm.put(token::Start_Marker);
				if (var->hasNote())
					encodeNote(var);
				encodeVariation(var->next(), timeTable);
				m_position.pop();
			}
		}

		m_position.doMove(node->move());
	}

	m_strm.put(token::End_Marker);

	if (node->hasComment(move::Post))
		encodeComment(node);
	else
		m_strm.put(token::End_Marker);
}


void
Encoder::encodeNote(MoveNode const* node, TimeTable const* timeTable)
{
	if (node->hasAnnotation())
	{
		Annotation const& annotation = node->annotation();

		for (unsigned i = 0; i < annotation.count(); ++i)
		{
			m_strm.put(token::Nag);
			m_data.put(annotation[i]);
		}
	}

	if (node->hasMark())
	{
		MarkSet const& marks = node->marks();

		for (unsigned i = 0; i < marks.count(); ++i)
		{
			m_strm.put(token::Mark);
			marks[i].encode(m_data);
		}
	}

	if (node->hasMoveInfo())
	{
		MoveInfoSet const& moveInfoSet = node->moveInfo();

		for (unsigned i = 0; i < moveInfoSet.count(); ++i)
		{
			MoveInfo const& info = moveInfoSet[i];

			if (timeTable == 0 || timeTable->size(info.content() - 1) == 0)
			{
				m_strm.put(token::Mark);
				info.encode(m_data);
			}
		}
	}

	if (node->hasAnyComment())
		encodeComment(node);
}


void
Encoder::encodeComment(MoveNode const* node)
{
	uint8_t flag = 0;

	if (node->hasComment(move::Ante))
	{
		flag |= comm::Ante;
		if (node->comment(move::Ante).engFlag())
			flag |= comm::Ante_Eng;
		if (node->comment(move::Ante).othFlag())
			flag |= comm::Ante_Oth;
	}

	if (node->hasComment(move::Post))
	{
		flag |= comm::Post;
		if (node->comment(move::Post).engFlag())
			flag |= comm::Post_Eng;
		if (node->comment(move::Post).othFlag())
			flag |= comm::Post_Oth;
	}

	if (flag & comm::Ante)
		m_text.put(node->comment(move::Ante).content(), node->comment(move::Ante).size() + 1);

	if (flag & comm::Post)
		m_text.put(node->comment(move::Post).content(), node->comment(move::Post).size() + 1);

	m_data.put(flag);
	m_strm.put(token::Comment);
}


db::tag::TagSet const&
Encoder::infoTags()
{
	return ::TagLookup::infoTags();
}


bool
Encoder::isExtraTag(tag::ID tag)
{
	bool skip = TagLookup::skipTag(tag);

	if (!skip)
		return true;

	return !skip && isRatingTag(tag);
}


void
Encoder::setup(Board const& board, uint16_t idn, variant::Type variant)
{
	uint16_t flags = idn;

	switch (flags)
	{
		case 0:
			m_position.setupZero(board, variant);
			break;

		case variant::Standard:
		case variant::NoCastling:
			m_position.setupStandard();
			break;

		default:
			if (flags <= 4*960)
				m_position.setupShuffle(board, variant);
			else
				m_position.setup(flags);
			break;
	}

	m_strm << uint16_t(flags);

	if ((flags & 0x0fff) == 0)
	{
		mstl::string fen;
		board.toFen(fen, variant);
		m_strm.put(fen);
	}
}


void
Encoder::setup(Board const& board, variant::Type variant)
{
	setup(board, board.computeIdn(variant), variant);
}


void
Encoder::setup(GameData const& data)
{
	M_ASSERT(data.m_idn == data.m_startBoard.computeIdn(data.m_variant));
	setup(data.m_startBoard, data.m_idn, data.m_variant);
}


uint16_t
Encoder::encodeTagSection(TagSet const& tags, tag::TagSet allowedTags, bool allowExtraTags)
{
	bool haveTags = false;

	allowedTags -= ::TagLookup::ignoreTags();

	for (tag::ID tag = tags.findFirst(); tag < tag::ExtraTag; tag = tags.findNext(tag))
	{
		if (	allowedTags.test(tag)
			&& tags.isUserSupplied(tag)
			&& (!tag::isRatingTag(tag) || tags.significance(tag) == 0))
		{
			mstl::string const& value = tags.value(tag);

			m_strm.put(tag);
			m_strm.put(value, value.size() + 1);
			haveTags = true;
		}
	}

	if (allowExtraTags)
	{
		for (unsigned i = 0; i < tags.countExtra(); ++i)
		{
			mstl::string const& name  = tags.extra(i).name;
			mstl::string const& value = tags.extra(i).value;

			m_strm.put(tag::ExtraTag);
			m_strm.put(name, name.size() + 1);
			m_strm.put(value, value.size() + 1);
			haveTags = true;
		}
	}

	if (!haveTags)
		return 0;

	m_strm.put(0);
	return flags::TagSection;
}


uint16_t
Encoder::encodeEngineSection(EngineList const& engines)
{
	if (engines.count() == 0)
		return 0;

	m_strm.put(engines.count());

	for (unsigned i = 0; i < engines.count(); ++i)
		m_strm.put(engines[i]);

	return flags::EngineSection;
}


uint16_t
Encoder::encodeTimeTableSection(TimeTable const& timeTable)
{
	if (timeTable.isEmpty())
		return 0;

	for (unsigned col = 0; col < MoveInfo::LAST; ++col)
	{
		if (unsigned size = timeTable.size(col))
		{
			while (size >= 255)
			{
				m_strm << uint8_t(255);
				size -= 255;
			}

			m_strm << uint8_t(size);
			size = timeTable.size(col);

			for (unsigned i = 0; i < size; ++i)
				timeTable[i][col].encode(m_strm);
		}
	}

	m_strm << uint8_t(0);

	return flags::TimeTableSection;
}


uint16_t
Encoder::encodeTextSection()
{
	unsigned size = m_text.tellp();

	if (size == 0)
		return 0;

	if (size >= (1 << 24))
		IO_RAISE(Game, Encoding_Failed, "text section is too large");

	m_strm << uint24_t(size);
	m_strm.put(m_text.base(), size);

	return flags::TextSection;
}


void
Encoder::prepareEncoding()
{
	m_runLength = 0;
	m_offset = m_strm.tellp();
	m_strm << uint24_t(0);		// place holder for offset to text section
	m_strm << uint16_t(0);		// place holder for run length
}


void
Encoder::encodeDataSection(TagSet const& tags,
									tag::TagSet const& allowedTags,
									bool allowExtraTags,
									EngineList const& engines,
									TimeTable const& timeTable)
{
	uint16_t flags = ByteStream::uint16(m_strm.base());

	if (m_strm.tellp() >= (1 << 24))
		IO_RAISE(Game, Encoding_Failed, "move data section is too large");

	ByteStream::set(m_strm.base() + m_offset, uint24_t(m_strm.tellp()));
	ByteStream::set(m_strm.base() + m_offset + 3, uint16_t(m_runLength));

	flags |= encodeTextSection();
	flags |= encodeTagSection(tags, allowedTags, allowExtraTags);
	flags |= encodeEngineSection(engines);
	flags |= encodeTimeTableSection(timeTable);

	ByteStream::set(m_strm.base(), flags);
	m_strm.put(m_data.base(), m_data.tellp());
	m_strm.provide();
}


void
Encoder::doEncoding(	Signature const&,
							GameData const& data,
							tag::TagSet const& allowedTags,
							bool allowExtraTags)
{
	setup(data);
	prepareEncoding();
	encodeMainline(data.m_startNode, data.m_timeTable);
	encodeDataSection(data.m_tags, allowedTags, allowExtraTags, data.m_engines, data.m_timeTable);
}


void
Encoder::initialize()
{
	TagLookup::initialize();
}

// vi:set ts=3 sw=3:
