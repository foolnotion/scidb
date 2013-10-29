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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "cbf_decoder.h"

#include "db_game_data.h"
#include "db_move_node.h"
#include "db_consumer.h"
#include "db_exception.h"

#include "u_byte_stream.h"

#include "sys_utf8_codec.h"
#include "sys_utf8.h"

#include "m_assert.h"

#include <ctype.h>

using namespace db;
using namespace db::cbf;
using namespace util;


enum { Start_Marker = 0xff, End_Marker = 0x80 };


__attribute__((noreturn))
inline static void
throwCorruptData()
{
	IO_RAISE(Game, Corrupted, "error while decoding game data");
}


static void
xorBuffer(Byte* buf, unsigned bufLen, Byte xorMask)
{
	for (int i = bufLen - 1; i >= 0; --i, xorMask *= 7)
		buf[i] ^= xorMask;
}


Decoder::Decoder(util::ByteStream& strm, sys::utf8::Codec& codec)
	:m_currentNode(0)
	,m_strm(strm)
	,m_codec(codec)
{
}


void
Decoder::decodeAnnotation(ByteStream& strm)
{
	if (!strm.remaining())
		return; // Cb3.exe: "Formaterror in annotations"

	if (Byte evaluation = strm.get())
	{
		static nag::ID Lookup[] =
		{
			nag::GoodMove,
			nag::PoorMove,
			nag::SpeculativeMove,
			nag::QuestionableMove,
			nag::VeryGoodMove,
			nag::VeryPoorMove,
			nag::Null, // ignore mate symbol
			nag::WithTheIdea,
			nag::BetterMove,
		};

		if (evaluation <= U_NUMBER_OF(Lookup))
			m_currentNode->addAnnotation(Lookup[evaluation - 1]);
		else if (evaluation == 0xff)
			return;
	}

	if (Byte estimation = strm.get())
	{
		static nag::ID Lookup[] =
		{
			nag::WhiteHasADecisiveAdvantage,
			nag::WhiteHasAModerateAdvantage,
			nag::WhiteHasASlightAdvantage,
			nag::DrawishPosition,
			nag::UnclearPosition,
			nag::BlackHasASlightAdvantage,
			nag::BlackHasAModerateAdvantage,
			nag::BlackHasADecisiveAdvantage,
			nag::WhiteHasSufficientCompensationForMaterialDeficit,
			nag::BlackHasSufficientCompensationForMaterialDeficit,
			nag::Counterplay,
			nag::Initiative,
			nag::Attack,
			nag::Zeitnot,
			nag::SingularMove,
		};

		if (estimation <= U_NUMBER_OF(Lookup))
			m_currentNode->addAnnotation(Lookup[estimation - 1]);
		else if (estimation == 0xff)
			return;
	}

	if (Byte remark = strm.get())
	{
		static nag::ID Lookup[] =
		{
			nag::EditorsRemark,
			nag::BetterMove,
			nag::WithTheIdea,
			nag::EquivalentMove,
			nag::BetterMove,
			nag::WorseMove,
			nag::Null,	// ignore "Break"
		};

		if (remark <= U_NUMBER_OF(Lookup))
			m_currentNode->addAnnotation(Lookup[remark - 1]);
		else if (remark == 0xff)
			return;
	}

	Byte c(strm.get());

	if (c == 0xff)
		return;

	while (c == 0 && strm.remaining())
		c = strm.get();

	mstl::string str;
	bool useXml(false);

	for ( ; c != 0xff && strm.remaining(); c = strm.get())
	{
		switch (c)
		{
			case 0x00:	str.append(' '); break;
			case 0xfe:	str.append(' '); break; // we don't use '\n' here
			case 0xb1:	useXml = true; str.append("<sym>K</sym>"); break;
			case 0xb2:	useXml = true; str.append("<sym>Q</sym>"); break;
			case 0xb3:	useXml = true; str.append("<sym>N</sym>"); break;
			case 0xb4:	useXml = true; str.append("<sym>B</sym>"); break;
			case 0xb5:	useXml = true; str.append("<sym>R</sym>"); break;
			case 0xb6:	useXml = true; str.append("<sym>P</sym>"); break;
			default:		str.append(c); break;
		}
	}

	str.trim();

	if (!str.empty())
	{
		if (useXml)
		{
			mstl::string tmp;
			tmp.swap(str);
			str.reserve(2*tmp.size() + 20);
			str.append("<xml><:>", 8);

			for (char const* s = tmp; *s; ++s)
			{
				switch (*s)
				{
					case '<':   str.append("&lt;",   4); break;
					case '>':   str.append("&gt;",   4); break;
					case '&':   str.append("&amp;",  5); break;
					case '\'':  str.append("&apos;", 6); break;
					case '"':   str.append("&quot;", 6); break;
					default:    str.append(*s); break;
				}
			}

			str.append("</:></xml>", 10);
		}

		m_codec.toUtf8(str);

		if (!sys::utf8::validate(str))
			m_codec.forceValidUtf8(str);

		m_currentNode->setComment(Comment(str, false, false), move::Post);
	}
}


void
Decoder::decodeVariation(ByteStream& moves, ByteStream& text)
{
	Move move;

	while (moves.remaining())
	{
		Byte b = moves.get();

		switch (b)
		{
			case Start_Marker:
			{
				MoveNode* current = m_currentNode;

				if (!move)
					throwCorruptData();

				m_position.push();
				m_position.undoMove(move);
				current->addVariation(m_currentNode = new MoveNode);
				decodeVariation(moves, text);
				m_currentNode = current;
				m_position.pop();
				break;
			}

			case End_Marker:
				m_currentNode->setNext(new MoveNode);
				return;

			default:
			{
				if ((b & 0x7f) == 0)
					return; // end of game (bug in ChessBase?)

				move = m_position.doMove(b & 0x7f);

				if (!move)
					throwCorruptData();

				MoveNode* node = new MoveNode(move);
				m_currentNode->setNext(node);
				m_currentNode = node;

				if (b & 0x80)
					decodeAnnotation(text);
				break;
			}
		}
	}
}


void
Decoder::decodeVariation(Consumer& consumer, ByteStream& moves, ByteStream& text)
{
	Move move;

	while (moves.remaining())
	{
		Byte b = moves.get();

		switch (b)
		{
			case Start_Marker:
			{
				if (!move)
					throwCorruptData();

				m_position.push();
				m_position.undoMove(move);
				consumer.startVariation();
				decodeVariation(consumer, moves, text);
				consumer.finishVariation();
				m_position.pop();
				break;
			}

			case End_Marker:
				return;

			default:
				if ((b & 0x7f) == 0)
					return; // end of game (bug in ChessBase?)

				move = m_position.doMove(b & 0x7f);

				if (!move)
					throwCorruptData();

				if (b & 0x80)
				{
					MoveNode node;
					m_currentNode = &node;
					decodeAnnotation(text);
					consumer.putMove(	move,
											node.annotation(),
											node.comment(move::Ante),
											node.comment(move::Post),
											node.marks());
					if (node.hasMoveInfo())
						consumer.putMoveInfo(node.moveInfo());
				}
				else
				{
					consumer.putMove(move);
				}
				break;
		}
	}
}


void
Decoder::prepareDecoding(ByteStream& moveArea, ByteStream& textArea)
{
	Byte* buf = m_strm.base();

	unsigned moveAreaLength	= (buf[2] << 8) + buf[3];
	unsigned playersLen		= buf[4] & 0x3f;
	unsigned sourceLen		= buf[5] & 0x3f;
	unsigned totalMoveNum	= (buf[2] << 8) + buf[3];
	unsigned movePos			= playersLen + sourceLen + 14;
	unsigned textPos			= movePos + totalMoveNum;
	unsigned boardPos			= textPos + (buf[6] << 8) + buf[7] - 1;
	unsigned endPos			= buf[10] & 1 ? boardPos + 33 : boardPos;

	if (endPos > m_strm.size())
		throwCorruptData();

	ByteStream boardArea(buf + boardPos, m_strm.end());
	m_position.setup(boardArea, buf[10], buf[11]);

	textArea.setup(m_strm.base() + textPos, boardPos - textPos);
	moveArea.setup(m_strm.base() + movePos, textPos - movePos);

	if (moveAreaLength > 0)
	{
		if (moveAreaLength > 1)
			::xorBuffer(moveArea.base() + 1, moveAreaLength - 2, 49*moveAreaLength);

		moveArea.reset(mstl::min(moveAreaLength - 1, moveArea.size()));
	}
}


void
Decoder::doDecoding(GameData& data)
{
	ByteStream moves, text;

	prepareDecoding(moves, text);
	data.m_startBoard = m_position.board();
	m_currentNode = data.m_startNode;
	decodeVariation(moves, text);
	m_currentNode->setNext(new MoveNode);
}


save::State
Decoder::doDecoding(Consumer& consumer, TagSet& tags)
{
	ByteStream moves, text;

	prepareDecoding(moves, text);
	consumer.startGame(tags, m_position.board());
	consumer.startMoveSection();
	decodeVariation(consumer, moves, text);
	consumer.finishMoveSection(result::fromString(tags.value(tag::Result)));

	return consumer.finishGame(tags);
}

// vi:set ts=3 sw=3:
