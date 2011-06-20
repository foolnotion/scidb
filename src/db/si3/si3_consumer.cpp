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

#include "si3_consumer.h"
#include "si3_codec.h"
#include "si3_common.h"

#include "db_game_info.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_move.h"

#include "sys_utf8_codec.h"

using namespace util;

namespace db {
namespace si3 {

Consumer::Consumer(format::Type srcFormat, Codec& codec, mstl::string const& encoding)
	:Encoder(m_stream, codec.codec())
	,db::Consumer(srcFormat, encoding)
	,m_stream(m_buffer, codec.blockSize())
	,m_codec(codec)
	,m_flagPos(0)
	,m_encoding(this->codec().isUtf8() ? encoding::Utf8 : encoding::Latin1)
	,m_afterVar(false)
	,m_appendComment(false)
{
}


format::Type
Consumer::format() const
{
	return m_codec.format();
}


bool
Consumer::beginGame(TagSet const& tags)
{
	if (board().notDerivableFromStandardChess())
		return false;

	m_stream.reset(m_codec.blockSize());
	m_stream.resetp();
	encodeTags(tags);
	m_flagPos = m_strm.tellp();
	m_strm.put(0);	// place holder for flags
	Encoder::setup(board());
	m_comments.clear();
	m_move = Move::empty();
	m_afterVar = false;
	m_afterMove = true;
	m_appendComment = false;

	return true;
}


save::State
Consumer::endGame(TagSet const& tags)
{
	mstl::vector<mstl::string>::iterator i = m_comments.begin();
	mstl::vector<mstl::string>::iterator e = m_comments.end();

	mstl::string buf;

	for ( ; i != e; ++i)
	{
		m_codec.codec().fromUtf8(*i, buf);
		m_strm.put(buf.c_str(), buf.size() + 1);
	}

	if (!startBoard().isStandardPosition())
		m_stream[m_flagPos] |= flags::Non_Standard_Start;

	if (board().signature().hasPromotion())
		m_stream[m_flagPos] |= flags::Promotion;
	if (board().signature().hasUnderPromotion())
		m_stream[m_flagPos] |= flags::Under_Promotion;

	m_stream.provide();

	return m_codec.addGame(m_stream, tags, *this);
}


void Consumer::start() {}
void Consumer::finish() {}
void Consumer::beginMoveSection() {}


void
Consumer::endMoveSection(result::ID)
{
	m_strm.put(token::End_Game);
}


void
Consumer::pushComment(Comment const& comment)
{
	mstl::string text;
	comment.flatten(text, m_encoding);
	m_comments.push_back(text);
}


void
Consumer::sendPreComment(Comment const& comment)
{
	if (!comment.isEmpty())
	{
		if (m_afterVar)
		{
			m_strm.put(token::Start_Marker);
			m_strm.put(token::Comment);
			m_strm.put(token::End_Marker);
			m_appendComment = false;
			pushComment(comment);
		}
		else if (m_appendComment)
		{
			m_comments.back() += ' ';
			comment.flatten(m_comments.back(), m_encoding);
		}
		else
		{
			pushComment(comment);
			m_strm.put(token::Comment);
			m_appendComment = true;
		}
	}
}


void
Consumer::sendComment(Comment const& comment,
							Annotation const& annotation,
							MarkSet const& marks,
							bool isPreComment)
{
	if (!annotation.isEmpty())
	{
		if (isPreComment)
		{
			if (annotation.contains(nag::Diagram) || annotation.contains(nag::DiagramFromBlack))
			{
				m_strm.put(token::Comment);
				m_comments.push_back("D");
			}
		}
		else
		{
			for (unsigned i = 0; i < annotation.count(); ++i)
			{
				Byte nag = nag::toScid3(annotation[i]);

				if (nag != nag::Null)
				{
					m_strm.put(token::Nag);
					m_strm.put(nag);
				}
			}
		}
	}

	if (!marks.isEmpty())
	{
		pushComment(comment);
		mstl::string& text = m_comments.back();

		if (!text.empty())
			text += ' ';
		marks.toString(text);
		m_appendComment = true;
	}
	else if (!comment.isEmpty())
	{
		m_strm.put(token::Comment);
		pushComment(comment);
		m_appendComment = true;
		m_afterMove = false;
	}
}


void
Consumer::sendComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
{
	sendComment(comment, annotation, marks, true);
}


void
Consumer::sendFinalComment(Comment const& comment)
{
	if (m_afterMove)
	{
		m_strm.put(token::Comment);
		pushComment(comment);
		m_appendComment = true;
		m_afterMove = false;
	}
	else
	{
		sendMove(Move::null(), Annotation(), MarkSet(), comment, Comment());
	}
}


void
Consumer::beginVariation()
{
	M_ASSERT(m_move);

	m_moveStack.push(m_move);
	m_position.push();
	m_position.undoMove(m_move);
	m_strm.put(token::Start_Marker);
	m_afterVar = false;
	m_appendComment = false;
	m_afterMove = true;
}


void
Consumer::endVariation()
{
	M_ASSERT(!m_moveStack.empty());

	m_move = m_moveStack.top();
	m_moveStack.pop();
	m_position.pop();
	m_strm.put(token::End_Marker);
	m_afterVar = true;
	m_appendComment = false;
	m_afterMove = false;
}


bool
Consumer::checkMove(Move const& move)
{
	if (move.isLegal())
		return true;

	Board board(this->board());

	board.tryCastleShort(board.sideToMove());
	board.tryCastleLong(board.sideToMove());

	if (board.isValidMove(move, move::AllowIllegalMove) && !board.isIntoCheck(move))
		return true;

	mstl::string msg("Invalid move: ");	// TODo: i18n
	Move m(move);

	board.prepareForSan(m);
	m.printSan(msg);
	m_strm.put(token::Comment);
	m_comments.push_back(msg);

	return false;
}


bool
Consumer::sendMove(Move const& move)
{
	M_REQUIRE(move);

	if (!move.isLegal() && !checkMove(move))
		return false;

	m_position.doMove(move);
	encodeMove(m_move = move);
	m_appendComment = false;
	m_afterVar = false;
	m_afterMove = true;

	return true;
}


bool
Consumer::sendMove(	Move const& move,
							Annotation const& annotation,
							MarkSet const& marks,
							Comment const& preComment,
							Comment const& comment)
{
	M_REQUIRE(move);

	if (!move.isLegal() && !checkMove(move))
		return false;

	m_position.doMove(move);

	sendPreComment(preComment);
	encodeMove(m_move = move);
	m_appendComment = false;
	m_afterVar = false;
	m_afterMove = true;
	sendComment(comment, annotation, marks, false);

	return true;
}

} // namespace si3
} // namespace db

// vi:set ts=3 sw=3:
