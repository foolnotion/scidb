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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "si3_encoder.h"
#include "si3_common.h"

#include "db_move_node.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_game_info.h"
#include "db_game_data.h"
#include "db_move.h"
#include "db_eco.h"
#include "db_pgn_writer.h"

#include "u_byte_stream.h"

#include "sys_utf8_codec.h"

#include "m_assert.h"
#include "m_bit_functions.h"

using namespace db;
using namespace db::si3;
using namespace util;


inline
static Byte
makeMoveByte(Byte pieceNumber, Byte value)
{
    M_ASSERT(pieceNumber <= 15);
    M_ASSERT(value <= 15);

    return Byte(pieceNumber << 4) | Byte(value);
}


Encoder::Encoder(ByteStream& strm, sys::utf8::Codec& codec)
	:m_strm(strm)
	,m_codec(codec)
{
}


void
Encoder::setup(Board const& board)
{
	if (!board.isStandardPosition())
	{
		mstl::string fen;
		board.toFen(fen);
		m_strm.put(fen, fen.size() + 1);
		m_position.setup(board);
	}
	else
	{
		m_position.setup();
	}
}


void
Encoder::doEncoding(Signature const& signature, GameData const& data)
{
	Byte flags = 0;

	if (!data.m_startBoard.isStandardPosition())	flags |= flags::Non_Standard_Start;
	if (signature.hasPromotion())						flags |= flags::Promotion;
	if (signature.hasUnderPromotion())				flags |= flags::Under_Promotion;

	setup(data.m_startBoard);
	encodeTags(data.m_tags);
	m_strm.put(flags);
	encodeVariation(data.m_startNode);
	encodeComments(data.m_startNode);
	m_strm.provide();
}


void
Encoder::encodeComments(MoveNode* node)
{
	M_ASSERT(node);

	mstl::string buf;

	for (node = node->next(); node; node = node->next())
	{
		if (node->hasSupplement())
		{
			if (node->hasComment() || node->hasMark())
			{
				mstl::string comment;

				if (node->hasComment())
				{
					node->comment().flatten(comment, m_codec.isUtf8() ? Comment::Unicode : Comment::Latin1);
					m_codec.fromUtf8(comment, comment);
//					PgnWriter::convertExtensions(comment, PgnWriter::Mode_Extended);
				}

				if (node->hasMark())
				{
					if (!comment.empty())
						comment += ' ';

					MarkSet const& marks = node->marks();

					for (unsigned i = 0; i < marks.count(); ++i)
						marks[i].toString(comment);
				}

				m_strm.put(comment, comment.size() + 1);
			}

			if (node->hasVariation())
			{
				for (unsigned i = 0; i < node->variationCount(); ++i)
					encodeComments(node->variation(i));
			}
		}
	}
}


void
Encoder::encodeTag(TagSet const& tags, tag::ID tagID)
{
	mstl::string const& name	= tag::toName(tagID);
	mstl::string const& value	= tags.value(tagID);

	// TODO: use m_codec?
	m_strm.put(name.size());
	m_strm.put(name, name.size());
	m_strm.put(value.size());
	m_strm.put(value, value.size());
}


bool
Encoder::skipTag(tag::ID tag)
{
	switch (unsigned(tag))
	{
		// belongs to index
		case tag::Event:		return true;
		case tag::Site:		return true;
		case tag::Date:		return true;
		case tag::Round:		return true;
		case tag::White:		return true;
		case tag::Black:		return true;
		case tag::Result:		return true;
		case tag::Eco:			return true;
		case tag::WhiteElo:	return true;
		case tag::BlackElo:	return true;
	}

	return false;
}


void
Encoder::encodeTags(TagSet const& tags)
{
	mstl::string buf;

	for (unsigned i = tag::FirstRatingTypeTag; i <= tag::LastRatingTypeTag; ++i)
	{
		tag::ID tag = tag::ID(i);

		switch (tags.significance(tag))
		{
			case 1:
				if (tag != tag::WhiteIPS && tag != tag::BlackIPS)
					break;
				// fallthru

			case 2:
				encodeTag(tags, tag);
				break;
		}
	}

	for (unsigned i = 0; i < tag::ExtraTag; ++i)
	{
		tag::ID tag = tag::ID(i);

		if (tags.contains(tag))
		{
			if (!skipTag(tag))
			{
				Byte key = 0;

				switch (i)
				{
					// not needed
					case tag::Fen:				// fallthru
					case tag::Idn:				// fallthru

					// makes the compiler shut up
					case tag::ExtraTag:		break;

					// common tag
					case tag::WhiteCountry:	key = 241; break;
					case tag::BlackCountry:	key = 242; break;
					case tag::Annotator:		key = 243; break;
					case tag::PlyCount:		key = 244; break;
					case tag::Opening:		key = 246; break;
					case tag::Variation:		key = 247; break;
					case tag::Source:			key = 249; break;
					case tag::SetUp:			key = 250; break;

					// special case
					case tag::EventDate:
						if (tags.contains(tag::Date))
						{
							Date date(tags.value(tag::Date));
							Date eventDate(tags.value(tag::EventDate));

							if (mstl::abs(int(eventDate.year()) - int(date.year())) > 3)
								key = 245;
						}
						else
						{
							key = 245;
						}
						break;

					// extra tag
					default:
						if (	tags.isUserSupplied(tag)
							&& (!tag::isRatingTag(tag) || tags.significance(tag) == 0))
						{
							encodeTag(tags, tag);
						}
						break;
				}

				if (key && tags.isUserSupplied(tag))
				{
					mstl::string const& value = tags.value(tag);

					// TODO: use m_codec?
					m_strm.put(key);
					m_strm.put(value.size());
					m_strm.put(value, value.size());
				}
			}
		}
	}

	for (unsigned i = 0; i < tags.countExtra(); ++i)
	{
		// we cannot store tags with a key length > 240 (should never happen)
		if (__builtin_expect(tags.extra(i).name.size() <= 240, 1))
		{
			mstl::string const& name	= tags.extra(i).name;
			mstl::string const& value	= tags.extra(i).value;

			// we cannot store tag values with a length > 255
			unsigned valueSize = mstl::min(size_t(255), value.size());

			// TODO: use m_codec?
			m_strm.put(name.size());
			m_strm.put(name, name.size());
			m_strm.put(valueSize);
			m_strm.put(value, valueSize);
		}
	}

	m_strm.put(0);
}


inline
void
Encoder::encodeNullMove(Move const&)
{
	m_strm.put(::makeMoveByte(0, 0));
}


inline
void
Encoder::encodeKing(Move const& move)
{
	// Valid King difference-from-old-square values are:
	// -9, -8, -7, -1, 1, 7, 8, 9, and -2 and 2 for castling.
	// To convert this to a value in the range [1-10], we add 9 and
	// then look up the Value[] table.
	// Coded values 1-8 are one-square moves; 9 and 10 are Castling.

	M_ASSERT(m_position[move.from()] == 0);  // Kings MUST be piece number zero.

	static const Byte Value[] =
	{
	//-9 -8 -7 -6 -5 -4 -3 -2 -1  0  1   2  3  4  5  6  7  8  9
		1, 2, 3, 0, 0, 0, 0, 9, 4, 0, 5, 10, 0, 0, 0, 0, 6, 7, 8
	};

	if (move.isCastling())
	{
		m_strm.put(move.isShortCastling() ? 10 : 9);
	}
	else
	{
		int diff = int(move.to()) - int(move.from());

		// Verify we have a valid King move:
		M_ASSERT(-9 <= diff && diff <= 9 && Value[diff + 9] != 0);
		m_strm.put(Value[diff + 9]);
	}
}


inline
void
Encoder::encodeQueen(Move const& move)
{
    // We cannot fit all Queen moves in one byte, so Rooklike moves
    // are in one byte (encoded the same way as Rook moves),
    // while diagonal moves are in two bytes.

    M_ASSERT(move.to() <= sq::h8 && move.from() <= sq::h8);

    if (sq::rank(move.from()) == sq::rank(move.to()))
	 {
        // Rook-horizontal move
        m_strm.put(::makeMoveByte(m_position[move.from()], sq::fyle(move.to())));

    }
	 else if (sq::fyle(move.from()) == sq::fyle(move.to()))
	 {
        // Rook-vertical move
        m_strm.put(::makeMoveByte(m_position[move.from()], sq::rank(move.to()) + 8));
    }
	 else
	 {
        // Diagonal move:
        // First, we put a rook-horizontal move to the from square (which
        // is illegal of course) to indicate it is NOT a rooklike move.
        m_strm.put(::makeMoveByte(m_position[move.from()], sq::fyle(move.from())));

        // Now we put the to-square in the next byte. We add a 64 to it
        // to make sure that it cannot clash with the Special tokens (which
        // are in the range 0 to 15, since they are special King moves).
        m_strm.put(move.to() + 64);
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

    Byte value;

    // Check if the two squares share the same rank
    if (sq::rank(move.from()) == sq::rank(move.to()))
        value = sq::fyle(move.to());
    else
        value = sq::rank(move.to()) + 8;

    m_strm.put(::makeMoveByte(m_position[move.from()], value));
}


inline
void
Encoder::encodeBishop(Move const& move)
{
    // We encode a Bishop move as the Fyle moved to, plus
    // a one-bit flag to indicate if the direction was
    // up-right/down-left or vice versa.

    Byte	value		= sq::fyle(move.to());
    int	rankDiff	= int(sq::rank(move.to())) - int(sq::rank(move.from()));
    int	fyleDiff	= int(sq::fyle(move.to())) - int(sq::fyle(move.from()));

    // If (rankdiff*fylediff) is negative, it's up-left/down-right
	 if ((rankDiff ^ fyleDiff) < 0)
		 value += 8;

    m_strm.put(::makeMoveByte(m_position[move.from()], value));
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

	int diff = int(move.to()) - int(move.from());

	// Verify we have a valid knight move:
	M_ASSERT(-17 <= diff && diff <= 17 && Value[diff + 17] != 0);
	m_strm.put(::makeMoveByte(m_position[move.from()], Value[diff + 17]));
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

	Byte value = 0;	// suppress gcc warning

	switch (mstl::abs(int(move.to()) - int(move.from())))
	{
		case  7:	value =  0; break;
		case  8:	value =  1; break;
		case  9: value =  2; break;
		case 16:	value = 15; break;	// move forward two squares
	}

	if (move.isPromotion())
	{
		// Handle promotions.
		// move.promotedPiece() must be Queen=2, Rook=3, Bishop=4 or Knight=5.
		// We add 3 for Queen, 6 for Rook, 9 for Bishop, 12 for Knight.

		M_ASSERT(2 <= move.promoted() && move.promoted() <= 5);
		value += 3*(move.promoted() - 1);
	}

	m_strm.put(::makeMoveByte(m_position[move.from()], value));
}


void
Encoder::encodeMove(Move const& move)
{
	M_ASSERT((move.pieceMoved() == piece::None) == move.isNull());

	switch (move.pieceMoved())
	{
		case piece::None:		encodeNullMove(move); break;
		case piece::King:		encodeKing(move); break;
		case piece::Queen:	encodeQueen(move); break;
		case piece::Rook:		encodeRook(move); break;
		case piece::Bishop:	encodeBishop(move); break;
		case piece::Knight:	encodeKnight(move); break;
		case piece::Pawn:		encodePawn(move); break;
	}
}


void
Encoder::encodeVariation(MoveNode const* node, unsigned level)
{
	if (node->hasComment() || node->hasMark())
		m_strm.put(token::Comment);

	for (node = node->next(); node; node = node->next())
	{
		encodeMove(node->move());
		m_position.doMove(node->move());

		Annotation const& annotation = node->annotation();

		for (unsigned i = 0; i < annotation.count(); ++i)
		{
			int nag = nag::toScid3(annotation[i]);

			if (nag != nag::Null)
			{
				m_strm.put(token::Nag);
				m_strm.put(nag);
			}
		}

		if (node->hasComment() || node->hasMark())
			m_strm.put(token::Comment);

		for (unsigned i = 0; i < node->variationCount(); ++i)
		{
			MoveNode const* var = node->variation(i);

			m_position.push();
			m_position.undoMove(node->move());
			m_strm.put(token::Start_Marker);
			encodeVariation(var, level + 1);
			m_position.pop();
		}
	}

	m_strm.put(level == 0 ? token::End_Game : token::End_Marker);
}


unsigned
Encoder::encodeType(type::ID type)
{
	switch (type)
	{
		case type::Unspecific:				return 0;
		case type::Temporary:				return 1;
		case type::Work:						return 0;	// Unknown
		case type::Clipbase:					return 2;
		case type::My_Games:					return 4;
		case type::Large_Database:			return 5;
		case type::Informant:				return 0;	// Unknown
		case type::Correspondence_Chess:	return 6;
		case type::Email_Chess:				return 0;	// Unknown
		case type::Internet_Chess:			return 6;	// Correspondence chess
		case type::Computer_Chess:			return 7;
		case type::Chess_960:				return 0;	// Unknown
		case type::Player_Collection:		return 9;
		case type::Tournament:				return 10;
		case type::Tournament_Swiss:		return 11;
		case type::GM_Games:					return 12;
		case type::IM_Games:					return 13;
		case type::Blitz_Games:				return 14;
		case type::Tactics:					return 15;
		case type::Endgames:					return 16;
		case type::Analysis:					return 0;	// Unknown
		case type::Training:					return 0;	// Unknown
		case type::Match:						return 0;	// Unknown
		case type::Studies:					return 0;	// Unknown
		case type::Jewels:					return 0;	// Unknown
		case type::Problems:					return 0;	// Unknown
		case type::Patzer:					return 0;	// Unknown
		case type::Gambit:					return 0;	// Unknown
		case type::Important:				return 0;	// Unknown
		case type::Openings_White:			return 17;
		case type::Openings_Black:			return 18;
		case type::Openings:					return 19;
	}

	return 0;	// satisfies the compiler
}

// vi:set ts=3 sw=3:
