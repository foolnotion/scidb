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

#include "db_consumer.h"
#include "db_tag_set.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_game_info.h"

#include "sys_utf8_codec.h"

#include "m_assert.h"

#include <stdlib.h>

using namespace db;


Consumer::Consumer(format::Type srcFormat, mstl::string const& encoding)
	:m_format(srcFormat)
	,m_stack(1)
	,m_variationCount(0)
	,m_commentCount(0)
	,m_annotationCount(0)
	,m_markCount(0)
	,m_terminated(false)
	,m_flags(0)
	,m_line(m_moveBuffer)
	,m_encoding(encoding)
	,m_codec(new sys::utf8::Codec(encoding))
	,m_consumer(0)
	,m_setupBoard(true)
	,m_hasPreComment(false)
	,m_afterVariation(false)
{
}


Consumer::~Consumer() throw()
{
	delete m_codec;
}


Board const&
Consumer::getFinalBoard() const
{
	return board();
}


Board const&
Consumer::getStartBoard() const
{
	return startBoard();
}


unsigned
Consumer::plyCount() const
{
	return m_stack.top().board.plyNumber() - m_stack.bottom().board.plyNumber();
}


void
Consumer::setup(Board const& startPosition)
{
	m_stack.bottom().board = startPosition;
}


void
Consumer::setup(unsigned idn)
{
	m_stack.bottom().board.setup(idn);
}


void
Consumer::setup(mstl::string const& fen)
{
	// XXX possibly we should allow:
	// 1. handicap games
	// 2. illegal positions (king in check)
	M_ASSERT(Board::isValidFen(fen, variant::Unknown));

	m_stack.bottom().board.setup(fen);
}


bool
Consumer::startGame(TagSet const& tags, Board const* board)
{
	while (m_stack.size() > 1)
		m_stack.pop();

	m_variationCount = 0;
	m_commentCount = 0;
	m_annotationCount = 0;
	m_markCount = 0;
	m_terminated = false;
	m_line.length = 0;
	m_hasPreComment = false;
	m_afterVariation = false;
	m_homePawns.clear();

	if (board)
		m_stack.bottom().board = *board;
	else if (tags.contains(tag::Fen))
		setup(tags.value(tag::Fen));
	else if (tags.contains(tag::Idn))
		setup(::strtoul(tags.value(tag::Idn), 0, 10));
	else if (m_setupBoard)
		setup(Board::standardBoard());

	if (getStartBoard().notDerivableFromChess960())
		return false;

	m_stack.dup();
	m_stack.top().empty = true;

	return beginGame(tags);
}


save::State
Consumer::finishGame(TagSet const& tags)
{
	M_REQUIRE(variationLevel() == 0);

	if (startBoard().isStartPosition())
		m_stack.top().board.signature().setHomePawns(m_homePawns.used(), m_homePawns.data());

	save::State state = endGame(tags);
	m_stack.pop();
	return state;
}


void
Consumer::finishMoveSection(result::ID result)
{
	sendPreComment();	// send dangling pre-comment

	if (m_terminated)
	{
		while (variationLevel() > 0)
		{
			endVariation();
			m_stack.pop();
		}
	}

	endMoveSection(result);
}


void
Consumer::putPreComment(Comment const& comment)
{
	if (m_afterVariation)
	{
		sendComment(comment);
	}
	else
	{
		m_preComment = comment;
		m_preAnnotation.clear();
		m_preMarks.clear();
		m_hasPreComment = !comment.isEmpty();
	}
}


void
Consumer::putPreComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
{
	m_preComment = comment;
	m_preAnnotation = annotation;
	m_preMarks = marks;
	m_hasPreComment = !comment.isEmpty() || !annotation.isEmpty() || !marks.isEmpty();
}


void
Consumer::sendPreComment()
{
	if (m_hasPreComment)
	{
		if (!m_terminated)
		{
			if (!m_preComment.isEmpty())
				++m_commentCount;
			m_annotationCount += m_preAnnotation.count();
			m_markCount += m_preMarks.count();

			sendComment(m_preComment, m_preAnnotation, m_preMarks);
		}

		m_hasPreComment = false;
	}
}


void
Consumer::putMove(Move const& move,
						Annotation const& annotation,
						Comment const& comment,
						MarkSet const& marks)
{
	M_REQUIRE(terminated() || board().isValidMove(move));

	if (m_terminated)
		return;

	Entry& entry = m_stack.top();

	if (entry.empty)
	{
		if (!isMainline())
		{
			++m_variationCount;
			beginVariation();
		}

		sendPreComment();
		entry.empty = false;
	}

	if (!comment.isEmpty())
		++m_commentCount;
	m_annotationCount += annotation.count();
	m_markCount += marks.count();
	m_afterVariation = false;

	entry.move = move;
	entry.board.prepareUndo(entry.move);

	if (sendMove(entry.move, annotation, marks, comment))
	{
		entry.board.doMove(entry.move);

		if (!move.isLegal())
			m_flags |= GameInfo::Flag_Illegal_Move;

		if (isMainline())
		{
			m_homePawns.move(move);

			if (m_line.length < opening::Max_Line_Length)
				m_moveBuffer[m_line.length++] = move.index();
		}
	}
	else
	{
		m_terminated = true;
	}
}


void
Consumer::putMove(Move const& move)
{
	M_REQUIRE(terminated() || board().isValidMove(move));

	if (m_terminated)
		return;

	Entry& entry = m_stack.top();

	if (entry.empty)
	{
		if (!isMainline())
		{
			++m_variationCount;
			beginVariation();
		}

		sendPreComment();
		entry.empty = false;
	}

	entry.move = move;
	entry.board.prepareUndo(entry.move);
	m_afterVariation = false;

	if (sendMove(entry.move))
	{
		entry.board.doMove(entry.move);

		if (!move.isLegal())
			m_flags |= GameInfo::Flag_Illegal_Move;

		if (isMainline())
		{
			m_homePawns.move(move);

			if (m_line.length < opening::Max_Line_Length)
				m_moveBuffer[m_line.length++] = move.index();
		}
	}
	else
	{
		m_terminated = true;
	}
}


void
Consumer::sendComment(Comment const& comment)
{
	m_preAnnotation.clear();
	m_preMarks.clear();
	sendComment(comment, m_preAnnotation, m_preMarks);
}


void
Consumer::startVariation()
{
	M_REQUIRE(!variationIsEmpty());

	if (m_terminated)
		return;

	m_stack.dup();
	Entry& entry = m_stack.top();
	entry.empty = true;
	entry.board.undoMove(entry.move);
}


void
Consumer::finishVariation()
{
	M_REQUIRE(terminated() || variationLevel() > 0);

	if (m_terminated)
		return;

	if (!m_stack.top().empty)
		endVariation();

	m_stack.pop();
	sendPreComment();	// send dangling pre-comment (if variation is empty)
	m_afterVariation = true;
}


void
Consumer::setStartBoard(Board const& board)
{
	m_stack.bottom().board = board;
	m_setupBoard = false;
}

// vi:set ts=3 sw=3:
