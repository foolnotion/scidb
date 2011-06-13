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

#include "sci_consumer.h"
#include "sci_codec.h"
#include "sci_common.h"

#include "db_game_info.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_annotation.h"
#include "db_move.h"
#include "db_pgn_reader.h"

#include "sys_utf8_codec.h"

#ifdef NREQ
# define DEBUG(x)
#else
# define DEBUG(x) x
#endif


using namespace util;

namespace db {
namespace sci {

typedef ByteStream::uint24_t uint24_t;


Consumer::Consumer(format::Type srcFormat, Codec& codec)
	:Encoder(m_stream)
	,db::Consumer(srcFormat, sys::utf8::Codec::utf8())
	,m_stream(m_buffer, sizeof(m_buffer))
	,m_codec(codec)
	,m_streamPos(0)
	,m_runLength(0)
	,m_endOfRun(false)
	,m_danglingPop(false)
{
	DEBUG(m_putComment = true);
}


format::Type
Consumer::format() const
{
	return format::Scidb;
}


bool
Consumer::beginGame(TagSet const& tags)
{
	if (board().notDerivableFromChess960())
		return false;

	m_stream.reset(sizeof(m_buffer));
	m_stream.resetp();
	m_data.resetp();
	m_text.resetp();
	Encoder::setup(board());
	m_streamPos = m_strm.tellp();
	m_strm << uint24_t(0);	// place holder for offset to text section
	m_strm << uint16_t(0);	// place holder for run length
	encodeTags(tags);
	m_move = Move::empty();
	m_runLength = 0;
	m_endOfRun = false;
	m_danglingPop = false;
	DEBUG(m_putComment = true;)
	return true;
}


save::State
Consumer::endGame(TagSet const& tags)
{
	encodeTextSection(m_streamPos);
	encodeDataSection();
	m_stream.provide();
	return m_codec.addGame(m_stream, tags, *this);
}


void Consumer::start() {}
void Consumer::finish() {}
void Consumer::beginMoveSection() {}


void
Consumer::endMoveSection(result::ID)
{
	m_strm.put(token::End_Marker);
	ByteStream(m_stream.base() + m_streamPos + 3, 2) << uint16_t(m_runLength);
}


void
Consumer::sendComment(	Comment const& preComment,
								Comment const& comment,
								Annotation const& annotation,
								MarkSet const& marks)
{
	if (!annotation.isEmpty())
	{
		for (unsigned i = 0; i < annotation.count(); ++i)
		{
			m_strm.put(token::Nag);
			m_strm.put(annotation[i]);
		}

		m_endOfRun = true;
	}

	if (!marks.isEmpty())
	{
		for (unsigned i = 0; i < marks.count(); ++i)
		{
			m_strm.put(token::Mark);
			marks[i].encode(m_data);
		}

		m_endOfRun = true;
	}

	Byte flag = 0;

	if (!preComment.isEmpty())
	{
		if (preComment.engFlag())
			flag |= comm::Ante_Eng;
		if (preComment.othFlag())
			flag |= comm::Ante_Oth;
		flag |= comm::Ante;
		m_text.put(preComment.content(), preComment.size() + 1);
	}

	if (!comment.isEmpty())
	{
		if (comment.engFlag())
			flag |= comm::Post_Eng;
		if (comment.othFlag())
			flag |= comm::Post_Oth;
		flag |= comm::Post;
		m_text.put(comment.content(), comment.size() + 1);
	}

	if (flag)
	{
		DEBUG(M_ASSERT(m_putComment));

		m_strm.put(token::Comment);
		m_data.put(flag);

		DEBUG(m_putComment = false);
		m_endOfRun = true;
	}
}


void
Consumer::sendComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
{
	sendComment(Comment(), comment, annotation, marks);
}


void
Consumer::beginVariation()
{
	if (m_danglingPop)
	{
		M_ASSERT(!m_move);
		m_danglingPop = false;
	}
	else
	{
		if (m_move)
		{
			m_position.push();
			m_position.doMove(m_position.previous(), m_move);
		}
		else
		{
			m_position.push();
		}

		m_move = Move::empty();
	}

	if (!m_endOfRun)
	{
		if (m_runLength)
			--m_runLength;	// otherwise sci_decoder::decodeVariation() won't work

		m_endOfRun = true;
	}

	m_position.push();
	m_strm.put(token::Start_Marker);
	DEBUG(m_putComment = true);
}


void
Consumer::endVariation()
{
	if (m_danglingPop)
		m_position.pop();

	m_position.pop();
	m_strm.put(token::End_Marker);
	m_move = Move::empty();
	m_danglingPop = true;
	DEBUG(m_putComment = true);
}


bool
Consumer::sendMove(Move const& move)
{
	if (m_danglingPop)
	{
		m_position.pop();
		m_danglingPop = false;
	}
	else if (__builtin_expect(m_move, 1))
	{
		m_position.doMove(m_move);
	}

	DEBUG(m_putComment = true);

	if (!encodeMove(m_move = move))
		m_endOfRun = true;

	if (!m_endOfRun)
		++m_runLength;

	return true;
}


bool
Consumer::sendMove(	Move const& move,
							Annotation const& annotation,
							MarkSet const& marks,
							Comment const& preComment,
							Comment const& comment)
{
	if (m_danglingPop)
	{
		m_position.pop();
		m_danglingPop = false;
	}
	else if (__builtin_expect(m_move, 1))
	{
		m_position.doMove(m_move);
	}

	DEBUG(m_putComment = true);

	if (!encodeMove(m_move = move))
		m_endOfRun = true;

	sendComment(preComment, comment, annotation, marks);

	if (!m_endOfRun)
		++m_runLength;

	return true;
}

} // namespace sci
} // namespace db

// vi:set ts=3 sw=3:
