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
	,m_danglindEndMarker(true)
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
	m_danglindEndMarker = true;
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
	if (m_danglindEndMarker)
	{
		m_strm.put(token::End_Marker);
		m_strm.put(token::End_Marker);
	}

	ByteStream(m_stream.base() + m_streamPos + 3, 2) << uint16_t(m_runLength);
}


Byte
Consumer::writeComment(Byte position, Comment const& comment)
{
	M_ASSERT(position == comm::Ante || position == comm::Post);

	Byte flag = 0;

	if (!comment.isEmpty())
	{
		if (comment.engFlag())
			flag |= comm::Ante_Eng;
		if (comment.othFlag())
			flag |= comm::Ante_Oth;
		flag |= position;
		m_text.put(comment.content(), comment.size() + 1);
	}

	return flag;
}


void
Consumer::writeComment(	Comment const& preComment,
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

	Byte flag = writeComment(comm::Ante, preComment) | writeComment(comm::Post, comment);

	if (flag)
	{
		m_strm.put(token::Comment);
		m_data.put(flag);
		m_endOfRun = true;
	}
}


void
Consumer::sendPrecedingComment(	Comment const& comment,
											Annotation const& annotation,
											MarkSet const& marks)
{
	writeComment(Comment(), comment, annotation, marks);
}


void
Consumer::sendTrailingComment(Comment const& comment)
{
	m_strm.put(token::End_Marker);

	if (Byte flag = writeComment(comm::Post, comment))
	{
		m_strm.put(token::Comment);
		m_data.put(flag);
		m_endOfRun = true;
		m_danglindEndMarker = false;
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

		m_move.clear();
	}

	if (!m_endOfRun)
	{
		if (m_runLength)
			--m_runLength;	// otherwise sci_decoder::decodeVariation() won't work

		m_endOfRun = true;
	}

	m_position.push();
	m_strm.put(token::Start_Marker);
	m_danglindEndMarker = true;
}


void
Consumer::endVariation(bool isEmpty)
{
	if (isEmpty)
		putMove(Move::null());

	if (m_danglindEndMarker)
	{
		if (m_danglingPop)
			m_position.pop();

		m_position.pop();
		m_strm.put(token::End_Marker);
		m_strm.put(token::End_Marker);
	}
	else
	{
		m_danglindEndMarker = true;
	}

	m_move.clear();
	m_danglingPop = true;
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

	if (!encodeMove(m_move = move))
		m_endOfRun = true;

	writeComment(preComment, comment, annotation, marks);

	if (!m_endOfRun)
		++m_runLength;

	return true;
}

} // namespace sci
} // namespace db

// vi:set ts=3 sw=3:
