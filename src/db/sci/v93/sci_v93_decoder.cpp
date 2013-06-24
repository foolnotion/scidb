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

#include "sci_v93_decoder.h"
#include "sci_v93_common.h"

#include "db_game_data.h"
#include "db_move_node.h"
#include "db_mark_set.h"
#include "db_move_info_set.h"
#include "db_annotation.h"
#include "db_database_codec.h"
#include "db_tag_set.h"
#include "db_time_table.h"
#include "db_consumer.h"
#include "db_exception.h"

#include "u_byte_stream.h"

#include "sys_utf8_codec.h"

#include "m_bit_functions.h"
#include "m_utility.h"
#include "m_assert.h"

#include <string.h>

using namespace db;
using namespace db::sci::v93;
using namespace util;


__attribute__((noreturn))
inline static void
throwCorruptData()
{
	IO_RAISE(Game, Corrupted, "error while decoding game data");
}


static Byte const*
skipString(Byte const* p)
{
	while (*p)
		++p;
	return p + 1;
}


Decoder::Decoder(ByteStream& strm, variant::Type variant)
	:m_strm(strm)
	,m_guaranteedStreamSize(strm.size())
	,m_currentNode(0)
	,m_variant(variant)
{
}


Decoder::Decoder(ByteStream& strm, unsigned guaranteedStreamSize, variant::Type variant)
	:m_strm(strm)
	,m_guaranteedStreamSize(guaranteedStreamSize)
	,m_currentNode(0)
	,m_variant(variant)
{
}


Move
Decoder::decodeKing(sq::ID from, Byte nybble)
{
	static int const Offset[] =
	{
		0,	// reserved for token::Mark
		0,	// reserved for token::Nag
		0,	// reserved for token::Comment
		0,	// reserved for token::Start_Marker
		0,	// reserved for token::End_Marker
		0,	// reserved for token::Special_Move
		-9, -8, -7, -1, 1, 7, 8, 9,
		0,	// short castling
		0,	// long castling
	};

	M_ASSERT(nybble < U_NUMBER_OF(Offset));
	M_ASSERT(nybble > token::Special_Move);

	int offset = Offset[nybble];

	if (offset == 0)
	{
		switch (nybble)
		{
			case 14:	return m_position.makeShortCastlingMove(from);
			case 15:	return m_position.makeLongCastlingMove(from);
		}
	}

	return m_position.makeKingMove(from, (from + offset) & 63);
}


inline
Move
Decoder::decodeQueen(sq::ID from, Byte nybble)
{
	if (nybble >= 8)					// rook-vertical move
		return m_position.makeQueenMove(from, sq::make(sq::fyle(from), sq::Rank(nybble & 7)));

	if (nybble != sq::fyle(from))	// rook-horizontal move
		return m_position.makeQueenMove(from, sq::make(sq::Fyle(nybble), sq::rank(from)));

	// diagonal move: coded in two bytes
#ifdef CORRECTION
	return m_position.makeQueenMove(from, m_strm.get() & 63);
#else
	return m_position.makeQueenMove(from, (int(m_strm.get()) - 64) & 63);
#endif
}


inline
Move
Decoder::decodeRook(sq::ID from, Byte nybble)
{
	if (nybble >= 8)	// this is a move along a fyle, to a different rank
		return m_position.makeRookMove(from, sq::make(sq::fyle(from), nybble & 7));

	return m_position.makeRookMove(from, sq::make(nybble, sq::rank(from)));
}


inline
Move
Decoder::decodeBishop(sq::ID from, Byte nybble)
{
	int diff = int(nybble & 7) - int(sq::fyle(from));
	return m_position.makeBishopMove(from, (nybble < 8 ? int(from) + 9*diff : int(from) - 7*diff) & 63);
}


inline
Move
Decoder::decodeKnight(sq::ID from, Byte nybble)
{
	static int const Offset[16] = { 0, -17, -15, -10, -6, 6, 10, 15, 17, 0, 0, 0, 0, 0, 0, 0 };
	return m_position.makeKnightMove(from, (from + Offset[nybble]) & 63);
}


Move
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

	// white to move ///////////////////////////////////////////////////////////////////////////////

	if (m_position.whiteToMove())
	{
		if (nybble == 15)
		{
			if (from > sq::h2)
			{
				// Promotion to king (Antichess).
				Square to = (from + m_strm.get()) & 63;
				return Move::genCapturePromote(from, to, piece::King, m_position.piece(to));
			}

			return Move::genTwoForward(from, (from + 16) & 63);
		}

		int offset = Offset[nybble];
		Square to = (from + offset) & 63;

		if (to >= sq::a8)
			return Move::genCapturePromote(from, to, PromotedPiece[nybble], m_position.piece(to));

		if (offset == 8)
			return Move::genOneForward(from, to);

		if (to == m_position.board().enPassantSquare())
			return Move::genEnPassant(from, to);

		return Move::genPawnCapture(from, to, m_position.piece(to));
	}

	// black to move ///////////////////////////////////////////////////////////////////////////////

	if (nybble == 15)
	{
		if (from < sq::a7)
		{
			// Promotion to king (Antichess).
			Square to = (from - m_strm.get()) & 63;
			return Move::genCapturePromote(from, to, piece::King, m_position.piece(to));
		}

		return Move::genTwoForward(from, (from - 16) & 63);
	}

	int offset = Offset[nybble];
	Square to = (from - offset) & 63;

	if (to <= sq::h1)
		return Move::genCapturePromote(from, to, PromotedPiece[nybble], m_position.piece(to));

	if (offset == 8)
		return Move::genOneForward(from, to);

	if (to == m_position.board().enPassantSquare())
		return Move::genEnPassant(from, to);

	return Move::genPawnCapture(from, to, m_position.piece(to));
}


unsigned
Decoder::decodeZhouseMove(Move& move)
{
	unsigned value = m_strm.get();

#ifdef CORRECTION
	if (value == token::Special_Move)
#else
	if (value == 0)
#endif
	{
		move = Move::null();
		return 0;
	}

#ifdef CORRECTION
	M_ASSERT(value > token::Special_Move);
#endif

	unsigned pieceNum = (value >> 4);

	if (pieceNum == 0)
	{
#ifdef CORRECTION
		pieceNum = m_strm.get() & 63;
#else
		pieceNum = m_strm.get();
#endif

		if (m_position.blackToMove())
			pieceNum |= 0x10;

#ifdef CORRECTION
		if ((value &= 7) < piece::Queen)
			throwCorruptData();
#else
		value &= 15;

		if (value < piece::Queen || piece::Pawn < value)
			throwCorruptData();
#endif

#ifdef CORRECTION
		move = m_position.makePieceDropMove(m_strm.get() & 63, piece::Type(value));
#else
		move = m_position.makePieceDropMove(m_strm.get(), piece::Type(value));
#endif
	}
	else
	{
		value &= 15;
		pieceNum |= m_position.blackToMove() ? 0x30 : 0x20;

		sq::ID square = sq::ID(m_position[pieceNum]);

		switch (m_position.piece(square))
		{
			case piece::None:		throwCorruptData();
			case piece::King:		throwCorruptData();
			case piece::Queen:	move = decodeQueen(square, value); break;
			case piece::Rook:		move = decodeRook(square, value); break;
			case piece::Bishop:	move = decodeBishop(square, value); break;
			case piece::Knight:	move = decodeKnight(square, value); break;
			case piece::Pawn:		move = decodePawn(square, value); break;
		}
	}

	return pieceNum;
}


unsigned
Decoder::decodeMove(Byte value, Move& move)
{
	M_ASSERT(value >= token::Special_Move);

	unsigned	pieceNum;

	if (value == token::Special_Move)
	{
		if (variant::isZhouse(m_variant))
		{
			pieceNum = decodeZhouseMove(move);
		}
		else
		{
			pieceNum = 0;
			move = Move::null();
		}
	}
	else
	{
		pieceNum = (value >> 4);
		value &= 15;

		if (m_position.blackToMove())
			pieceNum |= 0x10;

		sq::ID square = sq::ID(m_position[pieceNum]);

		switch (m_position.piece(square))
		{
			case piece::King:		move = decodeKing(square, value); break;
			case piece::Queen:	move = decodeQueen(square, value); break;
			case piece::Rook:		move = decodeRook(square, value); break;
			case piece::Bishop:	move = decodeBishop(square, value); break;
			case piece::Knight:	move = decodeKnight(square, value); break;
			case piece::Pawn:		move = decodePawn(square, value); break;
			case piece::None:		throwCorruptData();
		}
	}

	Board& board = m_position.board();

	board.prepareUndo(move);
	move.setColor(board.sideToMove());
	M_ASSERT(board.isValidMove(move, m_variant));
	move.setLegalMove();
	board.doMove(move, m_variant);

	return pieceNum;
}


void
Decoder::decodeVariation(ByteStream& data)
{
	unsigned	pieceNum	= 0;	// satisfies the compiler
	Move		move;

	while (true)
	{
		Byte b;

		while ((b = m_strm.get()) >= token::Special_Move)
		{
			if (move)
				m_position.doMove(move, pieceNum);

			pieceNum = decodeMove(b, move);

			MoveNode* node = new MoveNode(move);
			m_currentNode->setNext(node);
			m_currentNode = node;
		}

		switch (b)
		{
			case token::End_Marker:
				{
					MoveNode* node = new MoveNode;
					m_currentNode->setNext(node);

					switch (m_strm.get())
					{
						case token::Comment:
							node->setCommentFlag(data.get());
							break;

						case token::End_Marker: break;
						default: IO_RAISE(Game, Corrupted, "unexpected token");
					}
				}
				return;

			case token::Start_Marker:
				{
					MoveNode* current = m_currentNode;

					m_position.push();
					m_position.board().undoMove(move, m_variant);
					current->addVariation(m_currentNode = new MoveNode);
					decodeVariation(data);
					m_currentNode = current;
					m_position.pop();
				}
				break;

			case token::Nag:
				static_assert(Annotation::Max_Nags >= 7, "Scidb needs at least seven entries");
				{
					nag::ID nag = nag::ID(m_strm.get());

					if (nag == 0)
						move.setLegalMove(false);
					else
						m_currentNode->addAnnotation(nag);
				}
				break;

			case token::Mark:
				if (MoveInfo::isMoveInfo(data.peek()))
				{
					MoveInfo info;
					info.decode(data);
					m_currentNode->addMoveInfo(info);
				}
				else
				{
					Mark mark;
					mark.decode(data);
					m_currentNode->addMark(mark);
				}
				break;

			case token::Comment:
				m_currentNode->setCommentFlag(data.get());
				break;
		}
	}
}


void
Decoder::decodeVariation(Consumer& consumer, util::ByteStream& data, ByteStream& text)
{
	MarkSet			marks;
	MoveInfoSet		moveInfo;
	Annotation		annotation;
	mstl::string	buf;
	Comment			comment;
	Comment			preComment;
	bool				hasNote(false);	// satisfies the compiler
	unsigned			pieceNum(0);		// satisfies the compiler
	Move				move;
	Move				lastMove;

	while (true)
	{
		Byte b = m_strm.get();

		if (__builtin_expect(b >= token::Special_Move, 1))
		{
			if (move)
			{
				if (hasNote)
				{
					consumer.putMove(move, annotation, preComment, comment, marks);
					if (!moveInfo.isEmpty())
					{
						consumer.putMoveInfo(moveInfo);
						moveInfo.clear();
					}
					marks.clear();
					annotation.clear();
					comment.clear();
					preComment.clear();
					hasNote = false;
				}
				else
				{
					consumer.putMove(move);
				}

				m_position.doMove(move, pieceNum);
			}
			else
			{
				if (lastMove)
				{
					m_position.doMove(lastMove, pieceNum);
					lastMove.clear();
				}

				if (hasNote)
				{
					consumer.putPrecedingComment(comment, annotation, marks);
					marks.clear();
					annotation.clear();
					comment.clear();
					hasNote = false;
				}
			}

			pieceNum = decodeMove(b, move);
		}
		else
		{
			switch (b)
			{
				case token::End_Marker:
					if (move)
					{
						if (hasNote)
						{
							consumer.putMove(move, annotation, preComment, comment, marks);
							if (!moveInfo.isEmpty())
								consumer.putMoveInfo(moveInfo);
						}
						else
						{
							consumer.putMove(move);
						}
					}
					else if (hasNote)
					{
						consumer.putPrecedingComment(comment, annotation, marks);
						hasNote = false;
					}
					switch (m_strm.get())
					{
						case token::Comment:
							{
								uint8_t flag = data.get();

								buf.clear();
								text.get(buf);
								comment.swap(buf, bool(flag & comm::Ante_Eng), bool(flag & comm::Ante_Oth));
								consumer.putTrailingComment(comment);
								break;
							}

						case token::End_Marker: break;
						default: IO_RAISE(Game, Corrupted, "unexpected token");
					}
					return;

				case token::Start_Marker:
					if (move)
					{
						if (hasNote)
						{
							consumer.putMove(move, annotation, preComment, comment, marks);
							if (!moveInfo.isEmpty())
							{
								consumer.putMoveInfo(moveInfo);
								moveInfo.clear();
							}
							marks.clear();
							annotation.clear();
							comment.clear();
							preComment.clear();
							hasNote = false;
						}
						else
						{
							consumer.putMove(move);
						}

						lastMove = move;
						move.clear();
					}

					M_ASSERT(!hasNote);

					m_position.push();
					m_position.board().undoMove(lastMove, m_variant);
					consumer.startVariation();
					decodeVariation(consumer, data, text);
					consumer.finishVariation();
					m_position.pop();
					break;

				case token::Nag:
					{
						nag::ID nag = nag::ID(m_strm.get());

						if (nag == 0)
						{
							move.setLegalMove(false);
						}
						else
						{
							annotation.add(nag);
							hasNote = true;
						}
					}
					break;

				case token::Mark:
					if (MoveInfo::isMoveInfo(data.peek()))
						moveInfo.add().decode(data);
					else
						marks.add().decode(data);
					hasNote = true;
					break;

				case token::Comment:
					{
						uint8_t flag = data.get();

						if (flag & comm::Ante)
						{
							buf.clear();
							text.get(buf);
							preComment.swap(buf, bool(flag & comm::Ante_Eng), bool(flag & comm::Ante_Oth));
						}

						if (flag & comm::Post)
						{
							buf.clear();
							text.get(buf);
							comment.swap(buf, bool(flag & comm::Post_Eng), bool(flag & comm::Post_Oth));
						}

						hasNote = true;
					}
					break;
			}
		}
	}
}


void
Decoder::decodeRun(unsigned count)
{
	Move move;

	for ( ; count > 0; --count)
	{
		static_assert((1 << 16)/* Maximal Run Size */ <= Block_Size, "unsafeGet() is unsafe");

		// unsafeGet() is ok because the block file is buffered with doubled size
		m_position.doMove(move, decodeMove(m_strm.unsafeGet(), move));
		MoveNode* node = new MoveNode(move);
		m_currentNode->setNext(node);
		m_currentNode = node;
	}
}


void
Decoder::decodeRun(unsigned count, Consumer& consumer)
{
	Move move;

	for (unsigned i = 0; i < count; ++i)
	{
		static_assert((1 << 16)/* Maximal Run Size */ <= Block_Size, "unsafeGet() is unsafe");

		// unsafeGet() is ok because the block file is buffered with doubled size
		unsigned pieceNum = decodeMove(m_strm.unsafeGet(), move);
		m_position.doMove(move, pieceNum);
		consumer.putMove(move);
	}
}


void
Decoder::decodeTextSection(MoveNode* node, ByteStream& text)
{
	for ( ; node; node = node->next())
	{
		if (node->hasSupplement())
		{
			if (uint8_t flag = node->commentFlag())
			{
				mstl::string	buf;
				Comment			comment;

				if (flag & comm::Ante)
				{
					text.get(buf);
					comment.swap(buf, bool(flag & comm::Ante_Eng), bool(flag & comm::Ante_Oth));
					node->setComment(comment, move::Ante);
				}

				if (flag & comm::Post)
				{
					text.get(buf);
					comment.swap(buf,  bool(flag & comm::Post_Eng), bool(flag & comm::Post_Oth));
					node->setComment(comment, move::Post);
				}
			}

			for (unsigned i = 0; i < node->variationCount(); ++i)
				decodeTextSection(node->variation(i), text);
		}
	}
}


void
Decoder::decodeTags(ByteStream& strm, TagSet& tags)
{
	mstl::string name;
	mstl::string value;

	for (tag::ID id = tag::ID(strm.get()); id; id = tag::ID(strm.get()))
	{
		if (id == 75)
		{
			value.clear();
			strm.get(value);
			tags.setExtra("NIC", value);
		}
		else if (id == tag::ExtraTag)
		{
			name.clear();
			value.clear();
			strm.get(name);
			strm.get(value);
			tags.setExtra(name, value);
		}
		else if (tag::isValid(id))
		{
			value.clear();
			strm.get(value);
			tags.set(id, value);

			if (tag::isRatingTag(id))
				tags.setSignificance(id, 0);
		}
	}
}


void
Decoder::decodeTimeTable(util::ByteStream& strm, TimeTable& timeTable)
{
	uint16_t length = strm.uint16();

	timeTable.reserve(length);

	for (unsigned i = 0; i < length; ++i)
	{
		MoveInfo info;
		info.decode(strm);
		timeTable.set(i, info);
	}
}


void
Decoder::decodeEngines(ByteStream& strm, EngineList& engines)
{
	uint8_t count = strm.get();

	engines.reserve(count);

	for (unsigned i = 0; i < count; ++i)
	{
		mstl::string engine;
		strm.get(engine);
		engines.addEngine(engine);
	}
}


save::State
Decoder::doDecoding(db::Consumer& consumer, TagSet& tags)
{
	uint16_t flags	= m_strm.uint16();
	uint16_t idn	= flags & 0x0fff;

	if (idn)
	{
		m_position.setup(idn, m_variant);
	}
	else
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen, m_variant);
		tags.set(tag::SetUp, "1");	// bad PGN design
		tags.set(tag::Fen, fen);
	}

	Byte* dataSection = m_strm.base() + m_strm.uint24();
	ByteStream text, data;

	if (flags & flags::TextSection)
	{
		unsigned size = ByteStream::uint24(dataSection);

		text.setup(dataSection + 3, size);
		data.setup(text.end(), m_strm.end());
	}
	else
	{
		data.setup(dataSection, m_strm.end());
	}

	if (flags & flags::TagSection)
		decodeTags(data, tags);

	if (!consumer.startGame(tags, m_position.board()))
		return save::UnsupportedVariant;

	if (flags & flags::EngineSection)
	{
		EngineList engines;
		decodeEngines(data, engines);
		consumer.swapEngines(engines);
	}

	if (flags & flags::TimeTableSection)
		decodeTimeTable(data, consumer.timeTable());

	consumer.startMoveSection();
	decodeRun(m_strm.uint16(), consumer);
	decodeVariation(consumer, data, text);
	consumer.finishMoveSection(result::fromString(tags.value(tag::Result)));

	return consumer.finishGame(tags);
}


void
Decoder::doDecoding(GameData& gameData)
{
	uint16_t flags	= m_strm.uint16();
	uint16_t idn	= flags & 0x0fff;

	if (idn)
	{
		m_position.setup(idn, m_variant);
	}
	else
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen, m_variant);
	}

	gameData.m_startBoard = m_position.board();
	m_currentNode = gameData.m_startNode;

	M_ASSERT(m_currentNode);

	Byte* dataSection = m_strm.base() + m_strm.uint24();
	ByteStream data, text;

	if (flags & flags::TextSection)
	{
		unsigned size = ByteStream::uint24(dataSection);

		text.setup(dataSection + 3, size);
		data.setup(text.end(), m_strm.end());
	}
	else
	{
		data.setup(dataSection, m_strm.end());
	}

	if (flags & flags::TagSection)
		decodeTags(data, gameData.m_tags);

	if (flags & flags::EngineSection)
		decodeEngines(data, gameData.m_engines);

	if (flags & flags::TimeTableSection)
		decodeTimeTable(data, gameData.m_timeTable);

	decodeRun(m_strm.uint16());
	decodeVariation(data);

	if (text.remaining())
		decodeTextSection(gameData.m_startNode, text);
}


Byte const*
Decoder::skipTags(Byte const* p)
{
	for (tag::ID id = tag::ID(*p++); id; id = tag::ID(*p++))
	{
		p = ::skipString(p);

		if (id == tag::ExtraTag)
			p = ::skipString(p);
	}

	return p;
}


Byte const*
Decoder::skipEngines(Byte const* p)
{
	for (unsigned i = 0, count = *p++; i < count; ++i)
		p = ::skipString(p);

	return p;
}


Byte const*
Decoder::skipMoveInfo(Byte const* p, Byte const* eos)
{
	unsigned length = ByteStream::uint16(p);

	for (p += 2; length; length--)
		p = MoveInfo::skip(p, eos);

	return p;
}


bool
Decoder::stripMoveInformation(unsigned halfMoveCount, unsigned types)
{
	uint16_t flags = m_strm.uint16();

	if ((flags & 0x0fff) == 0)
		m_strm.skipString();

	unsigned position		= m_strm.tellg();
	unsigned offset		= m_strm.uint24();
	unsigned runLength	= m_strm.uint16();

	if (	runLength == halfMoveCount
		&& (	!(flags & flags::TimeTableSection)
			|| !(types & (1 << MoveInfo::ElapsedMilliSeconds))))
	{
		return false;
	}

	bool stripped = false;

	Byte const* data = m_strm.base() + offset;

	if (flags & flags::TextSection)
		data += m_strm.uint24() + 3;

	if (flags & flags::TagSection)
		data = skipTags(data);

	if (flags & flags::EngineSection)
		data = skipEngines(data);

	if (flags & flags::TimeTableSection)
	{
		Byte const* p = skipMoveInfo(data, m_strm.end());

		if (types & (1 << MoveInfo::ElapsedMilliSeconds))
		{
			m_strm.strip(data - m_strm.base(), p - data);
			ByteStream::set(m_strm.base(), uint16_t(flags & ~flags::TimeTableSection));
			stripped = true;
		}
		else
		{
			data = p;
		}
	}

	if (runLength != halfMoveCount)
	{
		Byte const* dp = data;
		Byte const* dq = dp;
		Byte const* de = m_strm.end();
		Byte const* mp = m_strm.data();
		Byte const* mq = mp;
		Byte const* me = m_strm.base() + offset;

		Byte* dr = const_cast<Byte*>(data);
		Byte* mr = m_strm.data();

		unsigned n;

		while (mq < me)
		{
			switch (*mq++)
			{
				case token::End_Marker:
					if (*mq++ == token::Comment)
						++dq;
					break;

				case token::Nag:
					++mq; // TODO: move NAG's to data section
					break;

				case token::Comment:
					++dq;
					break;

				case token::Mark:
					if (MoveInfo::isMoveInfo(*dq))
					{
						if (types & (1 << MoveInfo::type(*dq)))
						{
							n = dq - dp;
							::memmove(dr, dp, n);
							dr += n;
							dp = dq = MoveInfo::skip(dq, de);

							n = mq - mp - 1;
							::memmove(mr, mp, n);
							mr += n;
							mp = mq;
						}
						else
						{
							dq = MoveInfo::skip(dq, de);
						}
					}
					else
					{
						dq = Mark::skip(dq, de);
					}
					break;
			}
		}

		if (mp != m_strm.data())
		{
			stripped = true;

			n = mq - mp;
			::memmove(mr, mp, n);
			mr += n;

			n = dq - dp;
			::memmove(dr, dp, n);
			dr += n;

			n = me - mr;
			dr -= n;
			m_strm.strip(mr - m_strm.base(), n);
			m_strm.strip(dr - m_strm.base(), m_strm.end() - dr);
			ByteStream::set(m_strm.base() + position, ByteStream::uint24_t(mr - m_strm.base()));
		}
	}

	return stripped;
}


void
Decoder::findTags(TagMap& tags)
{
	uint16_t flags = m_strm.uint16();

	if (!(flags & flags::TagSection))
		return;

	uint16_t idn = flags & 0x0fff;

	if (idn == 0)
		m_strm.skipString();

	Byte* dataSection = m_strm.base() + m_strm.uint24();

	if (flags & flags::TextSection)
		dataSection += ByteStream::uint24(dataSection) + 3;

	ByteStream		data(dataSection, m_strm.end());
	mstl::string	name;

	for (tag::ID id = tag::ID(data.get()); id; id = tag::ID(data.get()))
	{
		if (id == tag::ExtraTag)
		{
			name.clear();
			data.get(name);
			++tags[name];
		}
		else
		{
			++tags[tag::toName(id)];
		}

		data.skipString();
	}
}


bool
Decoder::stripTags(TagMap const& tags)
{
	uint16_t flags = m_strm.uint16();

	if (!(flags & flags::TagSection))
		return false;

	if ((flags & 0x0fff) == 0)
		m_strm.skipString();

	bool stripped = false;

	Byte* data = m_strm.base() + m_strm.uint24();

	if (flags & flags::TextSection)
		data += m_strm.uint24() + 3;

	Byte const*	q = data;
	Byte const*	p = data;
	Byte*			r = data;

	mstl::string name;

	for (tag::ID id = tag::ID(*q++); id; id = tag::ID(*q++))
	{
		if (id == tag::ExtraTag)
		{
			char* s = const_cast<char*>(reinterpret_cast<char const*>(q));
			name.hook(s, ::strlen(s));
		}
		else
		{
			mstl::string const& s = tag::toName(id);
			name.hook(const_cast<mstl::string&>(s).data(), s.size());
		}

		if (tags.find(name) != tags.end())
		{
			unsigned n = q - p - 1;

			stripped = true;
			::memmove(r, p, n);
			r += n;
			q = ::skipString(q);

			if (id == tag::ExtraTag)
				q = ::skipString(q);

			p = q;
		}
		else
		{
			q = ::skipString(q);

			if (id == tag::ExtraTag)
				q = ::skipString(q);
		}
	}

	if (stripped)
	{
		if (r == data)
		{
			m_strm.strip(data - m_strm.base(), q - data);
			ByteStream::set(m_strm.base(), uint16_t(flags & ~flags::TagSection));
		}
		else
		{
			unsigned n = q - p;
			::memmove(r, p, n);
			r += n;
			m_strm.strip(r - m_strm.base(), q - r);
		}
	}

	return stripped;
}


void
Decoder::skipVariations()
{
	unsigned count = 0;

	while (true)
	{
		Byte b = m_strm.get();

		if (__builtin_expect(b < token::Special_Move, 0))
		{
			switch (b)
			{
				case token::Start_Marker:
					++count;
					break;

				case token::End_Marker:
					m_strm.skip(1);

					if (count > 0)
						--count;
					else if (m_strm.peek() == token::Start_Marker)
						m_strm.skip(1);
					else
						return;
					break;

				case token::Nag:
					m_strm.skip(1);
					break;

				case token::Mark:
					if (MoveInfo::isMoveInfo(m_strm.peek()))
						MoveInfo::skip(m_strm);
					else
						Mark::skip(m_strm);
					break;
			}
		}
	}
}


Move
Decoder::nextMove(unsigned runLength)
{
	Move move;

	if (runLength)
	{
		m_position.doMove(move, decodeMove(m_strm.get(), move));
	}
	else
	{
		while (true)
		{
			Byte b = m_strm.get();

			if (__builtin_expect(b >= token::Special_Move, 1))
			{
				m_position.doMove(move, decodeMove(b, move));
				return move;
			}
			else
			{
				switch (b)
				{
					case token::End_Marker:
						return Move::empty();

					case token::Start_Marker:
						skipVariations();
						break;

					case token::Nag:
						m_strm.skip(1);
						break;

					case token::Mark:
						if (MoveInfo::isMoveInfo(m_strm.peek()))
							MoveInfo::skip(m_strm);
						else
							Mark::skip(m_strm);
						break;
				}
			}
		}
	}

	return move;
}


Move
Decoder::findExactPosition(Board const& position, bool skipVariations)
{
	uint16_t idn = m_strm.uint16() & 0x0fff;

	if (idn)
	{
		m_position.setup(idn, m_variant);
	}
	else
	{
		mstl::string fen;
		m_strm.get(fen);
		m_position.setup(fen, m_variant);
	}

	m_strm.skip(3);	// skip offset to text section

	unsigned runLength = m_strm.uint16();

	if (position.isEqualZHPosition(m_position.board()))
		return nextMove(runLength);

	Move move;

	for ( ; runLength > 0; --runLength)
	{
		static_assert((1 << 16)/* Maximal Run Size */ <= Block_Size, "unsafeGet() is unsafe");

		// unsafeGet() is ok because the block file is buffered with doubled size
		m_position.doMove(move, decodeMove(m_strm.unsafeGet(), move));

		if (position.isEqualZHPosition(m_position.board()))
			return nextMove(runLength - 1);

		if (!m_position.board().signature().isReachablePawns(position.signature()))
			return Move::invalid();
	}

	return searchForPosition(position, skipVariations);
}


Move
Decoder::searchForPosition(Board const& position, bool skipVariations)
{
	Move move;

	while (true)
	{
		Byte b = m_strm.get();

		if (__builtin_expect(b >= token::Special_Move, 1))
		{
			m_position.doMove(move, decodeMove(b, move));

			if (position.isEqualZHPosition(m_position.board()))
				return nextMove();

			if (!m_position.board().signature().isReachablePawns(position.signature()))
				return Move::invalid();
		}
		else
		{
			switch (b)
			{
				case token::End_Marker:
					return Move::invalid();

				case token::Start_Marker:
					if (skipVariations)
					{
						this->skipVariations();
					}
					else
					{
						m_position.push();
						m_position.board().undoMove(move, m_variant);
						move = findExactPosition(position, false);
						m_position.pop();

						if (move)
							return move;

						m_strm.skip(1);
					}
					break;

				case token::Nag:
					m_strm.skip(1);
					break;
			}
		}
	}

	return move;	// never reached
}

// vi:set ts=3 sw=3:
