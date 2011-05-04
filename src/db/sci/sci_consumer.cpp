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

using namespace util;

namespace db {
namespace sci {

typedef ByteStream::uint24_t uint24_t;


Consumer::Consumer(format::Type srcFormat, Codec& codec)
	:Encoder(m_stream)
	,db::Consumer(srcFormat)
	,m_stream(m_buffer, sizeof(m_buffer))
	,m_codec(codec)
	,m_streamPos(0)
	,m_runLength(0)
	,m_endOfRun(false)
	,m_danglingPop(false)
	,m_putComment(true)
{
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
	Encoder::setup(board());
	m_streamPos = m_strm.tellp();
	m_strm << uint24_t(0);	// place holder for offset to text section
	m_strm << uint16_t(0);	// place holder for run length
	encodeTags(tags);
	m_move = Move::empty();
	m_runLength = 0;
	m_endOfRun = false;
	m_danglingPop = false;
	m_putComment = true;
	return true;
}


save::State
Consumer::endGame(TagSet const& tags)
{
	encodeTextSection(m_streamPos);
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
Consumer::sendComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks)
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

	if (!comment.isEmpty())
	{
		if (m_putComment)
		{
			m_strm.put(token::Comment);
			m_putComment = false;
		}
		else
		{
			M_ASSERT(m_data.tellp() > 0);
			m_data.buffer()[-1] = '\n';
		}

		mstl::string text;
		PgnReader::convertCommentToXml(comment, text);
		m_data.put(text, text.size() + 1);
		m_endOfRun = true;
	}
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
	m_putComment = true;
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
	m_putComment = true;
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

	m_putComment = true;

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

	m_putComment = true;

	if (!encodeMove(m_move = move))
		m_endOfRun = true;

	sendComment(comment, annotation, marks);

	if (!m_endOfRun)
		++m_runLength;

	return true;
}

} // namespace sci
} // namespace db

// vi:set ts=3 sw=3:
