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

#ifndef _sci_consumer_included
#define _sci_consumer_included

#include "sci_encoder.h"
#include "sci_common.h"

#include "db_info_consumer.h"
#include "db_move.h"

#include "u_byte_stream.h"

namespace mstl { class string; }

namespace db {

class TagSet;
class MarkSet;
class Annotation;
class TimeTable;

namespace sci {

class Codec;

class Consumer : private Encoder, public db::InfoConsumer
{
public:

	class Codecs
	{
	public:

		Codecs();
		Codecs(Codec* codec);

		bool isEmpty() const;
		bool supports(db::variant::Type variant) const;

		Codec& operator[](db::variant::Type variant) const;

		void add(Codec* codec);

	private:

		typedef db::variant::Type Variant;

		mutable Codec*		m_codecs[db::variant::NumberOfVariants];
		mutable Codec*		m_codec;
		mutable Variant	m_variant;
		bool					m_empty;
	};

	Consumer(format::Type srcFormat,
				Codecs const& codecs,
				TagBits const& allowedTags,
				bool allowExtraTags);

	format::Type format() const override;

private:

	void start() override;
	void finish() override;

	bool beginGame(TagSet const& tags) override;
	save::State endGame(TagSet const& tags) override;
	save::State skipGame(TagSet const& tags) override;

	void sendPrecedingComment(	Comment const& comment,
										Annotation const& annotation,
										MarkSet const& marks) override;
	void sendTrailingComment(Comment const& comment, bool variationIsEmpty) override;
	void sendMoveInfo(MoveInfoSet const& moveInfo) override;
	bool sendMove(Move const& move) override;
	bool sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment) override;

	void writeComment(Comment const& preComment,
							Comment const& comment,
							Annotation const& annotation,
							MarkSet const& marks);
	Byte writeComment(Byte position, Comment const& comment);

	bool preparseComment(mstl::string& comment) override;
	void beginMoveSection() override;
	void endMoveSection(result::ID result) override;
	void beginVariation() override;
	void endVariation(bool isEmpty) override;

	void variantHasChanged(db::variant::Type variant) override;

	util::ByteStream	m_stream;
	Byte					m_buffer[Block_Size];
	Codecs				m_codecs;
	Move					m_move;
	unsigned				m_plyCount;
	bool					m_endOfRun;
	bool					m_danglingPop;
	unsigned				m_danglingEndMarker;
	unsigned				m_trailingComment;
	unsigned				m_lastCommentPos;
};

} // namespace sci
} // namespace db

#endif // _sci_consumer_included

// vi:set ts=3 sw=3:
