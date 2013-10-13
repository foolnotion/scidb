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

#include "db_consumer.h"
#include "db_tag_set.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_move_info_set.h"
#include "db_game_info.h"
#include "db_comment.h"
#include "db_producer.h"

#include "sys_utf8_codec.h"

#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


Consumer::Consumer(	format::Type srcFormat,
							mstl::string const& encoding,
							TagBits const& allowedTags,
							bool allowExtraTags)
	:Provider(srcFormat)
	,m_allowedTags(allowedTags)
	,m_allowExtraTags(allowExtraTags)
	,m_stack(1)
	,m_variationCount(0)
	,m_commentCount(0)
	,m_annotationCount(0)
	,m_moveInfoCount(0)
	,m_markCount(0)
	,m_terminated(false)
	,m_mainVariant(variant::Normal)
	,m_variant(variant::Normal)
	,m_useVariant(variant::Normal)
	,m_idn(0)
	,m_gameFlags(0)
	,m_updateFlags(0)
	,m_line(m_moveBuffer)
	,m_encoding(encoding)
	,m_codec(new sys::utf8::Codec(encoding))
	,m_consumer(0)
	,m_producer(0)
	,m_setupBoard(true)
	,m_commentEngFlag(false)
	,m_commentOthFlag(false)
{
}


Consumer::~Consumer() throw()
{
	delete m_codec;
}


void
Consumer::variantHasChanged(variant::Type)
{
	// no action
}


bool
Consumer::supportsVariant(variant::Type) const
{
	return true;
}


void
Consumer::setVariant(variant::Type variant)
{
	M_REQUIRE(variant == variant::Undetermined || supportsVariant(variant));

	m_useVariant = m_variant = variant;

	if (m_producer && m_producer->variant() == variant::Undetermined)
	{
		m_producer->setVariant(
			variant == variant::Undetermined ? variant : variant::toMainVariant(variant));
	}

	variantHasChanged(variant);
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


variant::Type
Consumer::variant() const
{
	return m_variant;
}


uint16_t
Consumer::idn() const
{
	return m_idn;
}


void
Consumer::setGameFlags(uint32_t flags)
{
	m_updateFlags = flags & ~(GameInfo::Flag_Dirty | GameInfo::Flag_Changed);
}


void
Consumer::setup(Board const& startPosition)
{
	m_stack.bottom().board = startPosition;
}


void
Consumer::setup(unsigned idn)
{
	m_stack.bottom().board.setup(idn, m_useVariant);
}


void
Consumer::setup(mstl::string const& fen)
{
	// XXX possibly we should allow:
	// 1. handicap games
	// 2. illegal positions (king in check)
	M_ASSERT(Board::isValidFen(fen, m_useVariant));

	m_stack.bottom().board.setup(fen, m_useVariant);
}


void
Consumer::swapMoveInfo(MoveInfoSet& moveInfo)
{
	moveInfo.swap(m_moveInfoSet);
}


bool
Consumer::startGame(TagSet const& tags, Board const* board, uint16_t* idn)
{
	while (m_stack.size() > 1)
		m_stack.pop();

	m_variationCount = 0;
	m_commentCount = 0;
	m_annotationCount = 0;
	m_moveInfoCount = 0;
	m_markCount = 0;
	m_terminated = false;
	m_line.length = 0;
	m_commentEngFlag = false;
	m_commentOthFlag = false;
	m_gameFlags = m_updateFlags;
	m_variant = m_mainVariant;
	m_useVariant = m_mainVariant;
	m_moveInfoSet.clear();
	m_engines.clear();
	m_homePawns.clear();
	m_sendTimeTable.clear();
	m_updateFlags = 0;

	if (board)
	{
		if (board->notDerivableFromChess960())
			return false;

		m_stack.bottom().board = *board;
		m_idn = startBoard().computeIdn(m_useVariant);
	}
	else if (tags.contains(tag::Fen))
	{
		setup(tags.value(tag::Fen));

		if (startBoard().notDerivableFromChess960())
			return false;

		m_idn = startBoard().computeIdn(m_useVariant);
	}
	else if (idn)
	{
		M_ASSERT(*idn > 0);
		setup(m_idn = *idn);
	}
	else if (m_setupBoard)
	{
		// In this case we have to use Crazyhouse setup,
		// because we don't know yet whether its's standard
		// chess or Crazyhouse. The hash code of the board
		// doesn't matter here.
		setup(Board::standardBoard(variant::Crazyhouse));
		m_idn = variant::Standard;
	}

	m_stack.dup();
	m_stack.top().empty = true;
	m_stack.top().move.clear();

	return beginGame(tags);
}


save::State
Consumer::finishGame(TagSet const& tags)
{
	M_REQUIRE(variationLevel() == 0);

	if (startBoard().isStartPosition())
		m_stack.top().board.signature().setHomePawns(m_homePawns.used(), m_homePawns.data());
	else
		m_stack.top().board.signature().setHomePawns(0, hp::Pawns());

	save::State state = endGame(tags);
	m_stack.pop();
	m_setupBoard = true;

	return state;
}


save::State
Consumer::skipGame(TagSet const& tags)
{
	return finishGame(tags);
}


void
Consumer::finishMoveSection(result::ID result)
{
	if (m_terminated)
	{
		while (variationLevel() > 0)
		{
			endVariation(m_stack.top().move.isEmpty());
			m_stack.pop();
		}
	}

	endMoveSection(result);

	// we don't like to have null moves in the opening line
	unsigned i = 0;
	while (i < m_line.length && m_line[i])
		++i;
	m_line.length = i;
}


void
Consumer::putPrecedingComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
{
	if (!m_terminated)
	{
		Entry& entry = m_stack.top();

		if (entry.empty)
		{
			if (!isMainline())
			{
				++m_variationCount;
				beginVariation();
			}

			entry.empty = false;
		}

		++m_commentCount;
		if (comment.engFlag())
			m_commentEngFlag = true;
		if (comment.othFlag())
			m_commentOthFlag = true;
		m_annotationCount += annotation.count();
		m_markCount += marks.count();

		sendPrecedingComment(comment, annotation, marks);
	}
}


void
Consumer::putTrailingComment(Comment const& comment)
{
	M_REQUIRE(!comment.isEmpty());

	if (!m_terminated)
	{
		++m_commentCount;
		if (comment.engFlag())
			m_commentEngFlag = true;
		if (comment.othFlag())
			m_commentOthFlag = true;

		sendTrailingComment(comment, m_stack.top().empty);
	}
}


void
Consumer::putMove(Move const& move,
						Annotation const& annotation,
						Comment const& preComment,
						Comment const& comment,
						MarkSet const& marks)
{
	M_REQUIRE(terminated() || board().isValidMove(move, m_useVariant));

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

		entry.empty = false;
	}

	if (!preComment.isEmpty())
	{
		if (preComment.engFlag())
			m_commentEngFlag = true;
		if (preComment.othFlag())
			m_commentOthFlag = true;
		++m_commentCount;
	}

	if (!comment.isEmpty())
	{
		if (comment.engFlag())
			m_commentEngFlag = true;
		if (comment.othFlag())
			m_commentOthFlag = true;
		++m_commentCount;
	}

	m_annotationCount += annotation.count();
	m_markCount += marks.count();

	entry.move = move;
	entry.board.prepareUndo(entry.move);

	if (sendMove(entry.move, annotation, marks, preComment, comment))
		afterSendMove(entry);
	else
		m_terminated = true;
}


void
Consumer::putMove(Move const& move)
{
	M_REQUIRE(terminated() || board().isValidMove(move, m_useVariant));

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

		entry.empty = false;
	}

	entry.move = move;
	entry.board.prepareUndo(entry.move);

	if (sendMove(entry.move))
		afterSendMove(entry);
	else
		m_terminated = true;
}


void
Consumer::afterSendMove(Entry& entry)
{
	Move const& move = entry.move;

	if (!m_moveInfoSet.isEmpty())
	{
		sendMoveInfo(m_moveInfoSet);
		m_moveInfoCount += m_moveInfoSet.count();
		m_moveInfoSet.clear();
	}

	if (isMainline())
	{
		if (!m_sendTimeTable.isEmpty())
		{
			MoveInfoSet const& m_moveInfoSet = m_sendTimeTable[m_line.length];
			sendMoveInfo(m_moveInfoSet);
			m_moveInfoCount += m_moveInfoSet.count();
		}

		if (!move.isLegal())
		{
			if (move.isCastling() && !entry.board.isInCheck())
				m_gameFlags |= GameInfo::Flag_Illegal_Castling;
			else
				m_gameFlags |= GameInfo::Flag_Illegal_Move;
		}

		m_homePawns.move(move);

		if (m_line.length < opening::Max_Line_Length)
			m_moveBuffer[m_line.length++] = move.index();
	}

	entry.board.doMove(move, m_useVariant);
}


void
Consumer::startVariation()
{
	M_REQUIRE(!variationIsEmpty());

	if (m_terminated)
		return;

	m_stack.dup();
	Entry& entry = m_stack.top();
	entry.board.undoMove(entry.move, m_useVariant);
	entry.empty = true;
	entry.move.clear();
}


void
Consumer::finishVariation()
{
	M_REQUIRE(terminated() || variationLevel() > 0);

	if (m_terminated)
		return;

	if (!m_stack.top().empty)
		endVariation(m_stack.top().move.isEmpty());

	m_stack.pop();
}


void
Consumer::setStartBoard(Board const& board)
{
	m_stack.bottom().board = board;
	m_setupBoard = false;
}


bool
Consumer::preparseComment(mstl::string&)
{
	return false;
}


void
Consumer::setEngines(EngineList const& engines)
{
	m_engines = engines;
}


void
Consumer::swapEngines(EngineList& engines)
{
	m_engines.swap(engines);
}


void
Consumer::sendMoveInfo(MoveInfoSet const& moveInfoSet)
{
	mstl::string info;
	moveInfoSet.print(m_engines, info);
	sendComment(Comment(info, false, false));
	++m_commentCount;
}

// vi:set ts=3 sw=3:
