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

#include "si3_decoder.h"
#include "si3_common.h"

#include "db_game_data.h"
#include "db_consumer.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_comment.h"
#include "db_move_node.h"
#include "db_database_codec.h"
#include "db_pgn_reader.h"
#include "db_exception.h"
#include "db_date.h"

#include "u_byte_stream.h"

#include "m_string.h"

#ifdef DEBUG_SI4
# include "m_stdio.h"
#endif

#include "sys_utf8_codec.h"

using namespace db;
using namespace db::si3;
using namespace util;


enum { Max_Tag_Length = 240, };


static tag::ID CommonTags[255 - Max_Tag_Length] =
{
	// 241, 242
	tag::WhiteCountry, tag::BlackCountry,
	// 243
	tag::Annotator,
	// 244
	tag::PlyCount,
	// 245 (plain text encoding)
	tag::EventDate,
	// 246, 247
	tag::Opening, tag::Variation,
	// 248-250
	tag::SetUp, tag::Source, tag::SetUp,	// NOTE: Scid is using "Setup" for entry #248
	// 252-254: spare for future use
	tag::ExtraTag, tag::ExtraTag, tag::ExtraTag, tag::ExtraTag,
	// 255: Reserved for compact EventDate encoding (obsolete since 3.x)
	tag::ExtraTag
};


inline static uint32_t min(uint32_t a, uint32_t b) { return mstl::min(a, b); }


__attribute__((noreturn))
inline static void
throwCorruptData()
{
	IO_RAISE(Game, Corrupted, "error while decoding game data");
}


Decoder::Decoder(ByteStream& strm, sys::utf8::Codec& codec)
	:m_strm(strm)
	,m_codec(codec)
	,m_currentNode(0)
	,m_hasVariantTag(false)
{
}


inline
void
Decoder::decodeKing(sq::ID from, Byte nybble)
{
	static int const Offset[16] = { 0, -9, -8, -7, -1, 1, 7, 8, 9, -2, 2 };

	if (__builtin_expect(nybble == 0, 0))
	{
		m_move = Move::null();
	}
	else
	{
		M_ASSERT(nybble < U_NUMBER_OF(Offset));

		int offset	= Offset[nybble];
		int to		= from + offset;

		if (abs(offset) == 2)
			m_move = m_position.makeCastlingMove(from, to & 63);
		else
			m_move = m_position.makeKingMove(from, to & 63);
	}
}


inline
void
Decoder::decodeQueen(sq::ID from, Byte nybble)
{
	if (nybble >= 8)
	{
		// rook-vertical move
		m_move = m_position.makeQueenMove(from, sq::make(sq::fyle(from), sq::Rank(nybble & 7)));
	}
	else if (nybble != sq::fyle(from))
	{
		// rook-horizontal move
		m_move = m_position.makeQueenMove(from, sq::make(sq::Fyle(nybble), sq::rank(from)));
	}
	else
	{
		// diagonal move: coded in two bytes
		m_move = m_position.makeQueenMove(from, (int(m_strm.get()) - 64) & 63);
	}
}


inline
void
Decoder::decodeRook(sq::ID from, Byte nybble)
{
	if (nybble >= 8)	// this is a move along a fyle, to a different rank
		m_move = m_position.makeRookMove(from, sq::make(sq::fyle(from), nybble & 7));
	else
		m_move = m_position.makeRookMove(from, sq::make(nybble, sq::rank(from)));
}


inline
void
Decoder::decodeBishop(sq::ID from, Byte nybble)
{
	int diff = int(nybble & 7) - int(sq::fyle(from));
	m_move = m_position.makeBishopMove(from, (nybble < 8 ? int(from) + 9*diff : int(from) - 7*diff) & 63);
}


inline
void
Decoder::decodeKnight(sq::ID from, Byte nybble)
{
	static int const Offset[16] = { 0, -17, -15, -10, -6, 6, 10, 15, 17, 0, 0, 0, 0, 0, 0, 0 };
	m_move = m_position.makeKnightMove(from, (from + Offset[nybble]) & 63);
}


void
Decoder::decodePawn(sq::ID from, Byte nybble)
{
	static int const Offset[16] = { 7,8,9, 7,8,9, 7,8,9, 7,8,9, 7,8,9, 16 };

	static piece::Type const PromotedPiece[16] =
	{
		piece::None,	piece::None,	piece::None,
		piece::Queen,	piece::Queen,	piece::Queen,
		piece::Rook,	piece::Rook,	piece::Rook,
		piece::Bishop,	piece::Bishop,	piece::Bishop,
		piece::Knight,	piece::Knight,	piece::Knight,
		piece::None,
	};

	int offset = Offset[nybble];

	if (m_position.whiteToMove())
	{
		Square to = (from + offset) & 63;

		switch (offset)
		{
			case 8:
				if (to >= sq::a8)
					m_move = Move::genPromote(from, to, PromotedPiece[nybble]);
				else
					m_move = Move::genOneForward(from, to);
				return;

			case 16:
				m_move = Move::genTwoForward(from, to);
				return;
		}

		if (to >= sq::a8)
			m_move = Move::genCapturePromote(from, to, PromotedPiece[nybble], m_position.piece(to));
		else if (to == m_position.board().enPassantSquare())
			m_move = Move::genEnPassant(from, to);
		else
			m_move = Move::genPawnCapture(from, to, m_position.piece(to));
	}
	else
	{
		// black to move

		Square to = (from - offset) & 63;

		switch (offset)
		{
			case 8:
				if (__builtin_expect(to <= sq::h1, 0))
					m_move = Move::genPromote(from, to, PromotedPiece[nybble]);
				else
					m_move = Move::genOneForward(from, to);
				return;

			case 16:
				m_move = Move::genTwoForward(from, to);
				return;
		}

		if (to <= sq::h1)
			m_move = Move::genCapturePromote(from, to, PromotedPiece[nybble], m_position.piece(to));
		else if (to == m_position.board().enPassantSquare())
			m_move = Move::genEnPassant(from, to);
		else
			m_move = Move::genPawnCapture(from, to, m_position.piece(to));
	}

#ifdef DEBUG_SI4
	m_homePawns.move(m_move);
#endif
}


Byte
Decoder::decodeMove(Byte value)
{
	unsigned	pieceNum = (value >> 4);

	if (m_position.blackToMove())
		pieceNum |= 0x10;

	sq::ID from = sq::ID(m_position[pieceNum]);

	switch (m_position.piece(from))
	{
		case piece::King:		decodeKing(from, value & 15); break;
		case piece::Queen:	decodeQueen(from, value & 15); break;
		case piece::Rook:		decodeRook(from, value & 15); break;
		case piece::Bishop:	decodeBishop(from, value & 15); break;
		case piece::Knight:	decodeKnight(from, value & 15); break;
		case piece::Pawn:		decodePawn(from, value & 15); break;
		case piece::None:		::throwCorruptData();
	}

	return pieceNum;
}


void
Decoder::decodeVariation(unsigned level)
{
	bool preComment = false;

	while (true)
	{
		Byte b;

		while (__builtin_expect((b = m_strm.get()) > token::Last, 1))
		{
			m_position.doMove(m_move, decodeMove(b));
			m_currentNode->setNext(new MoveNode(m_move));
			m_currentNode = m_currentNode->next();

			if (preComment)
			{
				m_currentNode->setComment(move::Ante);
				preComment = false;
			}
		}

		if (b < token::First)
		{
			m_position.doMove(m_move, decodeMove(b));
			m_currentNode->setNext(new MoveNode(m_move));
			m_currentNode = m_currentNode->next();

			if (preComment)
			{
				m_currentNode->setComment(move::Ante);
				preComment = false;
			}
		}
		else
		{
			switch (b)
			{
				case token::End_Game:
					if (level > 0)
					{
						::throwCorruptData();
					}
					else
					{
						MoveNode* node = new MoveNode;
						m_currentNode->setNext(node);

						if (preComment)
							node->setComment(move::Post);
					}
					return;

				case token::End_Marker:
					if (level == 0)
					{
						::throwCorruptData();
					}
					else
					{
						MoveNode* node = new MoveNode;
						m_currentNode->setNext(node);

						if (preComment)
							node->setComment(move::Post);
					}
					return;

				case token::Start_Marker:
					{
						MoveNode* current = m_currentNode;

						m_position.push();
						m_position.undoMove(current->move());
						current->addVariation(m_currentNode = new MoveNode);
						decodeVariation(level + 1);

						if (m_currentNode->atLineStart())
						{
							// Scidb does not support empty variations...

							if (m_currentNode->hasNote() || m_currentNode->next()->hasNote())
							{
								// ...but we cannot delete the variation if an annotation/comment exists.

								if (	!m_currentNode->annotation().isEmpty()
									|| m_strm.peek() == token::Start_Marker)
								{
#ifndef DONT_ALLOW_EMPTY_VARS
									// As a workaround we insert a null move.

									MoveNode* node = new MoveNode(m_position.board().makeNullMove());
									node->setNext(m_currentNode->removeNext());
									m_currentNode->setNext(node);
#endif
								}
								else
								{
									// This is the last variation. Handle this comment as a pre-comment.
									current->deleteVariation(current->countVariations() - 1);
									preComment = true;
								}
							}
							else
							{
								current->deleteVariation(current->countVariations() - 1);
							}
						}

						m_currentNode = current;
						m_position.pop();
					}
					break;

				case token::Nag:
					M_STATIC_CHECK(Annotation::Max_Nags >= 7, ScidNeedsAtLeastSeven);
					m_currentNode->addAnnotation(nag::fromScid3(nag::ID(m_strm.get())));
					break;

				case token::Comment:
					m_currentNode->setComment(move::Post);
					break;
			}
		}
	}
}


void
Decoder::skipTags()
{
	Byte b;

	while ((b = m_strm.get()))
	{
		if (__builtin_expect(b == 255, 0))
		{
			// special binary 3-byte encoding of EventDate (obsolete since 3.x)
			m_strm.skip(3);
		}
		else
		{
			if (b <= ::Max_Tag_Length)
				m_strm.skip(b);
			m_strm.skip(m_strm.get());
		}
	}
}


void
Decoder::decodeTags(TagSet& tags)
{
	Byte significance[2] = { 2, 2 };
	mstl::string out;
	Byte b;

	while ((b = m_strm.get()))
	{
		if (b <= ::Max_Tag_Length)
		{
			char*	tag = const_cast<char*>(reinterpret_cast<char const*>(m_strm.data()));

			m_strm.skip(b);
			Byte c = m_strm.get();

			// NOTE: we ignore invalid tags (Scid bug)
			if (PgnReader::validateTagName(tag, b))
			{
				// look if this is a known tag with an unusual notation

				switch (tag::ID id = tag::fromName(tag, b))
				{
					case tag::TimeControl:
						if (!tags.contains(tag::TimeMode))
						{
							mstl::string s(reinterpret_cast<char const*>(m_strm.data()), b);
							time::Mode mode = PgnReader::getTimeModeFromTimeControl(s);

							if (mode != time::Unknown)
								tags.set(tag::TimeMode, time::toString(mode));
						}
						tags.set(id, reinterpret_cast<char const*>(m_strm.data()), c);
						break;

					case tag::Variant:
						m_hasVariantTag = true;
						break;

					case tag::Fen: // should not happen
						break;

					case tag::ExtraTag:
						{
							mstl::string in;
							in.hook(reinterpret_cast<char*>(m_strm.data()), c);
							m_codec.convertToUtf8(in, out);
							if (!sys::utf8::Codec::validateUtf8(out))
								m_codec.forceValidUtf8(out);
							tags.setExtra(tag, out);
						}
						break;

					case tag::EventDate:
						// this case happens if a tag like "Eventdate" is detetcted
						{
							Date date;
							date.parseFromString(reinterpret_cast<char const*>(m_strm.data()), b);
							if (date)
								tags.set(tag::EventDate, date.asString());
						}
						break;

					default:
						{
							mstl::string in;
							in.hook(reinterpret_cast<char*>(m_strm.data()), c);
							m_codec.convertToUtf8(in, out);
							if (!sys::utf8::Codec::validateUtf8(out))
								m_codec.forceValidUtf8(out);

							tags.set(id, out);

							if (tag::isRatingTag(id))
							{
								color::ID color = tag::isWhiteRatingTag(id) ? color::White : color::Black;

								tags.setSignificance(id, significance[color]);
								significance[color] = 0;
							}
						}
						break;
				}
			}

			m_strm.skip(c);
		}
		else
		{
			switch (b)
			{
				case 245:	// event date
					{
						char const*	data = reinterpret_cast<char const*>(m_strm.data());
						Date date;

						b = m_strm.get();
						date.parseFromString(data, b);
						if (date)
							tags.set(tag::EventDate, date.asString());
						m_strm.skip(b);
					}
					break;

				case 255:	// special binary 3-byte encoding of EventDate (obsolete since 3.x)
					{
						unsigned value = (((m_strm.get() << 8) | m_strm.get()) << 8) | m_strm.get();
						Date		date;

						date.setYMD(value >> 9, (value >> 5) & 15, value & 31);
						if (date)
							tags.set(tag::EventDate, mstl::string(date.asString(), b));
					}
					break;

				default:	// a common tag name, not explicitly stored
					{
						tag::ID tag = ::CommonTags[b - ::Max_Tag_Length - 1];

						if (__builtin_expect(tag == tag::ExtraTag, 0))
							throwCorruptData();

						unsigned b = m_strm.get();

						switch (unsigned(tag))
						{
							case tag::Annotator:
							case tag::Source:
							case tag::Opening:
							case tag::Variation:
								{
									mstl::string in;

									Byte&	c = m_strm[m_strm.tellg() + b];
									Byte	d = c;

									c = '\0';
									in.hook(const_cast<char*>(reinterpret_cast<char const*>(m_strm.data())), b);
									m_codec.convertToUtf8(in, out);
									if (!sys::utf8::Codec::validateUtf8(out))
										m_codec.forceValidUtf8(out);
									tags.set(tag, out);
									c = d;
									tag = tag::ExtraTag;
								}
								break;

							case tag::SetUp:	// not needed
								tag = tag::ExtraTag;
								break;
						}

						if (tag != tag::ExtraTag)
							tags.set(tag::toName(tag), reinterpret_cast<char const*>(m_strm.data()), b);
						m_strm.skip(b);
					}
					break;
			}
		}
	}
}


void
Decoder::decodeComments(MoveNode* node)
{
	mstl::string buffer;

	if (node->hasComment(move::Post))
	{
		mstl::string	content;
		Comment			comment;
		MarkSet			marks;

		buffer.clear();
		m_strm.get(content);
		marks.extractFromComment(content);
		m_codec.toUtf8(content, buffer);

		if (!sys::utf8::Codec::validateUtf8(buffer))
			m_codec.forceValidUtf8(buffer);

		if (Comment::convertCommentToXml(buffer, comment, encoding::Utf8))
			node->addAnnotation(nag::Diagram);

		node->swapMarks(marks);

		if (node->next()->atLineEnd())
			node->swapComment(comment, move::Post);
		else
			node->swapComment(comment, move::Ante);
	}

	for (node = node->next(); node; node = node->next())
	{
		if (node->hasSupplement())
		{
			if (node->hasComment(move::Ante))
			{
				mstl::string content;
				Comment comment;

				buffer.clear();
				m_strm.get(content);
				m_codec.toUtf8(content, buffer);

				if (!sys::utf8::Codec::validateUtf8(buffer))
					m_codec.forceValidUtf8(buffer);

				if (Comment::convertCommentToXml(buffer, comment, encoding::Utf8))
					node->addAnnotation(nag::Diagram);

				if (	node->prev()->atLineStart()
					&& node->isBeforeLineEnd()
					&& node->prev()->hasComment(move::Ante))
				{
					Comment total;
					node->prev()->swapComment(total, move::Ante);
					total.append(comment, ' ');
					node->swapComment(total, move::Ante);
				}
				else
				{
					node->swapComment(comment, move::Ante);
				}
			}
			else if (	node->prev()->atLineStart()
						&& node->isBeforeLineEnd()
						&& node->prev()->hasComment(move::Ante))
			{
				Comment comment;
				node->prev()->swapComment(comment, move::Ante);
				node->swapComment(comment, move::Ante);
			}

			if (node->hasComment(move::Post))
			{
				mstl::string	content;
				Comment			comment;
				MarkSet			marks;

				buffer.clear();
				m_strm.get(content);
				marks.extractFromComment(content);
				m_codec.toUtf8(content, buffer);

				if (!sys::utf8::Codec::validateUtf8(buffer))
					m_codec.forceValidUtf8(buffer);

				if (Comment::convertCommentToXml(buffer, comment, encoding::Utf8))
					node->addAnnotation(nag::Diagram);

				node->swapMarks(marks);
				node->swapComment(comment, move::Post);
			}

			for (unsigned i = 0; i < node->variationCount(); ++i)
				decodeComments(node->variation(i));
		}
		else if (	node->prev()->atLineStart()
					&& node->isBeforeLineEnd()
					&& node->prev()->hasComment(move::Ante))
		{
			Comment comment;
			node->prev()->swapComment(comment, move::Ante);
			node->prev()->swapComment(comment, move::Post);
		}
	}
}


void
Decoder::checkVariant(TagSet& tags)
{
	Board const& startBoard = m_position.startBoard();

	if (!startBoard.isStandardPosition())
	{
		if (startBoard.isChess960Position())
		{
			tags.set(tag::Variant, chess960::identifier());
		}
		else if (startBoard.isShuffleChessPosition())
		{
			tags.set(tag::Variant, shuffle::identifier());
		}
		else if (m_hasVariantTag)
		{
			if (!startBoard.notDerivableFromChess960())
				tags.set(tag::Variant, shuffle::identifier());
			else if (!startBoard.notDerivableFromStandardChess())
				tags.set(tag::Variant, chess960::identifier());
		}
	}
}


save::State
Decoder::doDecoding(db::Consumer& consumer, TagSet& tags)
{
	decodeTags(tags);

	if (m_strm.get() & flags::Non_Standard_Start)
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen);
		tags.set(tag::SetUp, "1");	// bad PGN design
		tags.set(tag::Fen, fen);
	}
	else
	{
		m_position.setup();
	}

	checkVariant(tags);

	if (!consumer.startGame(tags, m_position.board()))
		return save::UnsupportedVariant;

	consumer.startMoveSection();

	MoveNode start;
	m_currentNode = &start;

	decodeVariation();
	decodeComments(&start);
	decodeVariation(consumer, &start);
	consumer.finishMoveSection(result::fromString(tags.value(tag::Result)));

#ifdef DEBUG_SI4
	if (	m_position.startBoard().isStandardPosition()
		&& m_homePawns.used() != m_position.board().signature().hpCount())
	{
		::fprintf(	stderr,
						"WARNING(%u): invalid home pawn count %u (%u is expected)\n",
						consumer.m_index,
						unsigned(m_position.board().signature().hpCount()),
						unsigned(m_homePawns.used()));
	}
#endif

	return consumer.finishGame(tags);
}


unsigned
Decoder::doDecoding(GameData& data)
{
	decodeTags(data.m_tags);

	if (m_strm.get() & flags::Non_Standard_Start)
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen);
	}
	else
	{
		m_position.setup();
	}

	checkVariant(data.m_tags);

	unsigned plyNumber = m_position.board().plyNumber();

	data.m_startBoard = m_position.board();
	m_currentNode = data.m_startNode;

	M_ASSERT(m_currentNode);

	decodeVariation();
	decodeComments(data.m_startNode);

	return m_position.board().plyNumber() - plyNumber;
}


void
Decoder::decodeVariation(Consumer& consumer, MoveNode const* node)
{
	M_ASSERT(node);

	if (node->hasNote())
		consumer.putPrecedingComment(node->comment(move::Post), node->annotation(), node->marks());

	for (node = node->next(); node; node = node->next())
	{
		if (node->atLineEnd())
		{
			if (node->hasComment(move::Post))
				consumer.putTrailingComment(node->comment(move::Post));
		}
		else
		{
			if (node->hasNote())
			{
				consumer.putMove(	node->move(),
										node->annotation(),
										node->comment(move::Ante),
										node->comment(move::Post),
										node->marks());
			}
			else
			{
				consumer.putMove(node->move());
			}

			for (unsigned i = 0; i < node->variationCount(); ++i)
			{
				consumer.startVariation();
				decodeVariation(consumer, node->variation(i));
				consumer.finishVariation();
			}
		}
	}
}


void
Decoder::skipVariations()
{
	unsigned count = 1;

	while (true)
	{
		Byte b = m_strm.get();

		if (__builtin_expect(b <= token::Last, 0))
		{
			switch (b)
			{
				case token::End_Game:
					::throwCorruptData();
					// not reached

				case token::Start_Marker:
					++count;
					break;

				case token::End_Marker:
					if (--count == 0)
						return;
					break;

				case token::Nag:
					m_strm.skip(1);
					break;
			}
		}
	}
}


Move
Decoder::nextMove()
{
	while (true)
	{
		Byte b;

		if (__builtin_expect((b = m_strm.get()) > token::Last, 1) || b < token::First)
		{
			m_position.doMove(m_move, decodeMove(b));
			return m_move;
		}

		switch (b)
		{
			case token::End_Game:
				return Move::empty();

			case token::End_Marker:
				::throwCorruptData();
				// not reached

			case token::Start_Marker:
				skipVariations();
				break;

			case token::Nag:
				m_strm.skip(1);
				break;
		}
	}

	return m_move;	// not reached
}


Move
Decoder::findExactPosition(Board const& position, bool skipVariations)
{
	skipTags();

	if (m_strm.get() & flags::Non_Standard_Start)
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen);
	}
	else
	{
		m_position.setup();
	}

	if (m_position.board().isEqualPosition(position))
		return nextMove();

	while (true)
	{
		Byte b;

		while (__builtin_expect((b = m_strm.get()) > token::Last, 1))
		{
			m_position.doMove(m_move, decodeMove(b));

			if (m_position.board().isEqualPosition(position))
				return nextMove();

			if (!m_position.board().signature().isReachablePawns(position.signature()))
				return Move::invalid();
		}

		if (b < token::First)
		{
			m_position.doMove(m_move, decodeMove(b));

			if (m_position.board().isEqualPosition(position))
				return nextMove();

			if (!m_position.board().signature().isReachablePawns(position.signature()))
				return Move::invalid();
		}
		else
		{
			switch (b)
			{
				case token::End_Game:
					return Move::invalid();

				case token::End_Marker:
					::throwCorruptData();
					// not reached

				case token::Start_Marker:
					if (skipVariations)
					{
						this->skipVariations();
					}
					else
					{
						m_position.push();
						m_position.undoMove(m_move);
						m_move = findExactPosition(position, false);
						m_position.pop();

						if (m_move)
							return m_move;
					}
					break;

				case token::Nag:
					m_strm.skip(1);
					break;
			}
		}
	}

	return m_move;	// not reached
}


type::ID
Decoder::decodeType(unsigned type)
{
	switch (type)
	{
		case  0: return type::Unspecific;				// Unspecific
		case  1: return type::Temporary;					// Temporary Database
		case  2: return type::Clipbase;					// Clipbase
		case  3: return type::Unspecific;				// PGN format file
		case  4: return type::My_Games;					// My games
		case  5: return type::Large_Database;			// Large database
		case  6: return type::Correspondence_Chess;	// Correspondence chess
		case  7: return type::Computer_Chess;			// Computer chess
		case  8: return type::Unspecific;				// Sorted index of games
		case  9: return type::Player_Collection;		// Player collection
		case 10: return type::Tournament;				// Tournament: All-play-all
		case 11: return type::Tournament_Swiss;		// Tournament: Swiss
		case 12: return type::GM_Games;					// Grandmaster games
		case 13: return type::IM_Games;					// International master games
		case 14: return type::Blitz_Games;				// Blitz (fast) games
		case 15: return type::Tactics;					// Tactics
		case 16: return type::Endgames;					// Endgames
		case 17: return type::Openings_White;			// Openings for White
		case 18: return type::Openings_Black;			// Openings for Black
		case 19: return type::Openings;					// Openings for either color
	};

	return type::Openings;									// Theory ...
}

// vi:set ts=3 sw=3:
