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

#ifndef _si3_consumer_included
#define _si3_consumer_included

#include "si3_encoder.h"
#include "si3_common.h"

#include "db_consumer.h"
#include "db_move.h"
#include "db_comment.h"

#include "u_byte_stream.h"

#include "m_vector.h"
#include "m_stack.h"
#include "m_string.h"

namespace db {

class TagSet;
class MarkSet;
class Annotation;

namespace si3 {

class Codec;

class Consumer : private Encoder, public db::Consumer
{
public:

	Consumer(format::Type srcFormat,
				Codec& codec,
				mstl::string const& encoding,
				TagBits const& allowedTags,
				bool allowExtraTags,
				LanguageList const* languages = nullptr,
				unsigned significantLanguages = 0);

	format::Type format() const override;

private:

	typedef mstl::vector<Comment>	Comments;
	typedef mstl::stack<Move>		MoveStack;

	void start();
	void finish();

	bool supportsVariant(variant::Type variant) const override;

	bool beginGame(TagSet const& tags) override;
	save::State endGame(TagSet const& tags) override;
	save::State skipGame(TagSet const& tags) override;

	void sendTrailingComment(Comment const& comment, bool variationIsEmpty) override;
	void sendComment(Comment const& comment) override;
	void sendPrecedingComment(	Comment const& comment,
										Annotation const& annotation,
										MarkSet const& marks) override;
	void sendMoveInfo(MoveInfoSet const& moveInfo) override;
	bool sendMove(Move const& move) override;
	bool sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment) override;

	void sendPreComment(Comment const& comment);
	void sendComment( Comment const& comment,
							Annotation const& annotation,
							MarkSet const& marks,
							bool isPreComment);

	void beginMoveSection() override;
	void endMoveSection(result::ID result) override;
	void beginVariation() override;
	void endVariation(bool isEmpty) override;

	bool checkMove(Move const& move);

	util::ByteStream	m_stream;
	Byte					m_buffer[131072];
	Codec&				m_codec;
	unsigned				m_flagPos;
	encoding::CharSet	m_encoding;
	Comments				m_comments;
	MoveStack			m_moveStack;
	Move					m_move;
	bool					m_afterVar;
	bool					m_afterMove;
	bool					m_appendComment;
};

} // namespace si3
} // namespace db

#endif // _si3_consumer_included

// vi:set ts=3 sw=3:
