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

#include "sci_consumer.h"
#include "sci_codec.h"
#include "sci_common.h"

#include "db_game_info.h"
#include "db_tag_set.h"
#include "db_mark_set.h"
#include "db_move_info_set.h"
#include "db_annotation.h"
#include "db_move.h"
#include "db_pgn_reader.h"

#include "sys_utf8_codec.h"

#include <ctype.h>
#include <string.h>

#ifdef NREQ
# define DEBUG(x)
#else
# define DEBUG(x) x
#endif


using namespace util;

namespace db {
namespace sci {

typedef ByteStream::uint24_t uint24_t;


Consumer::Codecs::Codecs()
	:m_codec(0)
	,m_variant(variant::Undetermined)
	,m_empty(true)
{
	::memset(m_codecs, 0, sizeof(m_codecs));
}


Consumer::Codecs::Codecs(Codec* codec)
	:m_codec(codec)
	,m_empty(false)
{
	M_REQUIRE(codec);

	::memset(m_codecs, 0, sizeof(m_codecs));
	m_variant = codec->variant();
	M_ASSERT(variant::isMainVariant(m_variant));
	m_codecs[variant::toIndex(m_variant)] = codec;
}


bool Consumer::Codecs::isEmpty() const	{ return m_empty; }


bool
Consumer::Codecs::supports(variant::Type variant) const
{
	M_ASSERT(variant::isMainVariant(variant));
	return m_codecs[variant::toIndex(variant)];
}


Codec&
Consumer::Codecs::operator[](db::variant::Type variant) const
{
	M_ASSERT(variant::isMainVariant(variant));
	M_ASSERT(supports(variant));

	if (m_variant == variant)
		return *m_codec;

	return *(m_codec = m_codecs[variant::toIndex(m_variant = variant)]);
}


void
Consumer::Codecs::add(Codec* codec)
{
	M_REQUIRE(codec);
	M_REQUIRE(codec->variant() != variant::Undetermined);

	m_empty = false;
	m_codecs[variant::toIndex(codec->variant())] = codec;

	if (m_variant == variant::Undetermined)
	{
		m_variant = codec->variant();
		m_codec = codec;
	}
}


Consumer::Consumer(	format::Type srcFormat,
							Codecs const& codecs,
							TagBits const& allowedTags,
							bool allowExtraTags)
	:Encoder(m_stream, variant::Normal)
	,db::InfoConsumer(srcFormat, sys::utf8::Codec::utf8(), allowedTags, allowExtraTags)
	,m_stream(m_buffer, sizeof(m_buffer))
	,m_codecs(codecs)
	,m_endOfRun(false)
	,m_danglingPop(false)
	,m_danglingEndMarker(0)
	,m_lastCommentPos(0)
	,m_plyCount(0)
{
//	M_REQUIRE(!codecs.isEmpty());
}


void
Consumer::variantHasChanged(db::variant::Type variant)
{
	Encoder::changeVariant(variant);
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
	Encoder::setup(board(), variant(), !timeTable().isEmpty());
	Encoder::changeVariant(variant());
	m_data.resetp();
	m_text.resetp();
	prepareEncoding();
	m_move = Move::empty();
	m_endOfRun = false;
	m_danglingPop = false;
	m_danglingEndMarker = 1;
	m_lastCommentPos = 0;
	m_plyCount = 0;
	m_timeTable.clear();

	return true;
}


save::State
Consumer::endGame(TagSet const& tags)
{
	variant::Type variant = variant::toMainVariant(getVariant());

	if (!m_codecs.supports(variant))
		return save::UnsupportedVariant;

	encodeDataSection(tags, allowedTags(), allowExtraTags(), engines(), timeTable());
	return m_codecs[variant].addGame(m_stream, tags, *this);
}


save::State
Consumer::skipGame(TagSet const&)
{
	return save::Ok;
}


void Consumer::start() {}
void Consumer::finish() {}
void Consumer::beginMoveSection() {}


void
Consumer::endMoveSection(result::ID)
{
	while (m_danglingEndMarker--)
	{
		m_strm.put(token::End_Marker);
		m_strm.put(token::End_Marker);
	}
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

		if (isMainline())
			m_lastCommentPos = plyCount() + 1;
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
Consumer::sendTrailingComment(Comment const& comment, bool variationIsEmpty)
{
	if (!comment.isEmpty())
	{
#ifndef ALLOW_EMPTY_VARS
		if (variationIsEmpty)
			putMove(m_move = Move::null());
#endif

		if (m_danglingEndMarker)
		{
			m_strm.put(token::End_Marker);
			m_danglingEndMarker--;
		}

		Byte flag = writeComment(comm::Post, comment);

		M_ASSERT(flag);

		m_strm.put(token::Comment);
		m_data.put(flag);
		m_endOfRun = true;

		if (isMainline())
			m_lastCommentPos = plyCount() + 1;
	}
}


void
Consumer::sendMoveInfo(MoveInfoSet const& moveInfo)
{
	for (unsigned i = 0; i < moveInfo.count(); ++i)
	{
		m_strm.put(token::Mark);
		moveInfo[i].encode(m_data);

		if (!m_endOfRun)
		{
			m_endOfRun = true;

			if (m_runLength)
				--m_runLength;	// otherwise sci_decoder::decodeVariation() won't work
		}
	}
}


void
Consumer::preparseComment(mstl::string& comment)
{
	char const* str = comment;

	if (	str[0] == 'S'
		&& str[1] == 'P'
		&& str[2] == ' '
		&& ::isdigit(str[3])
		&& ::isdigit(str[4])
		&& ::isdigit(str[5])
		&& (str[6] == ' ' || str[6] == '\0'))
	{
		// Eliminate this silly "SP 386" comment from "Week in chess" PGN files.
		if (str[6] == '\0')
		{
			comment.clear();
			return;
		}

		str += 6;
		while (*str == ' ' || *str == '-')
			++str;

		comment.erase(comment.begin(), str);

		if (comment.empty())
			return;
	}

	InfoConsumer::preparseComment(comment);
	int i = m_moveInfoSet.findElapsedMilliSeconds();

	if (i >= 0 && (!m_timeTable.isEmpty() || m_plyCount == 0))
	{
		m_timeTable.set(m_plyCount, m_moveInfoSet[i]);
		m_moveInfoSet.remove(i);
	}
}


void
Consumer::beginVariation()
{
	if (m_danglingPop)
	{
		m_danglingPop = false;
		m_move.clear();
	}
	else
	{
		if (m_move)
		{
			m_position.push();
			m_position.doMove(m_position.previous(), m_move);
			m_move.clear();
		}
		else
		{
			m_position.push();
		}
	}

	if (!m_endOfRun)
	{
		if (m_runLength)
			--m_runLength;	// otherwise sci_decoder::decodeVariation() won't work

		m_endOfRun = true;
	}

	m_position.push();
	m_strm.put(token::Start_Marker);
	m_danglingEndMarker++;
}


void
Consumer::endVariation(bool isEmpty)
{
#ifndef ALLOW_EMPTY_VARS
	if (isEmpty)
		putMove(Move::null());
#endif

	if (m_danglingEndMarker > 1)
	{
		if (m_danglingPop)
			m_position.pop();

		m_position.pop();
		m_strm.put(token::End_Marker);
		m_strm.put(token::End_Marker);
		m_danglingEndMarker--;
	}

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

	m_plyCount++;
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

	m_plyCount++;
	return true;
}

} // namespace sci
} // namespace db

// vi:set ts=3 sw=3:
