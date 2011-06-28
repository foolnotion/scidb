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

#ifndef _sci_consumer_included
#define _sci_consumer_included

#include "sci_encoder.h"
#include "sci_common.h"

#include "db_consumer.h"
#include "db_move.h"

#include "u_byte_stream.h"

namespace mstl { class string; }

namespace db {

class TagSet;
class MarkSet;
class Annotation;

namespace sci {

class Codec;

class Consumer : private Encoder, public db::Consumer
{
public:

	Consumer(format::Type srcFormat, Codec& codec);

private:

	format::Type format() const;

	void start();
	void finish();

	bool beginGame(TagSet const& tags);
	save::State endGame(TagSet const& tags);

	void sendPrecedingComment(Comment const& comment, Annotation const& annotation, MarkSet const& marks);
	void sendTrailingComment(Comment const& comment);
	bool sendMove(Move const& move);
	bool sendMove(	Move const& move,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment);

	void writeComment(Comment const& preComment,
							Comment const& comment,
							Annotation const& annotation,
							MarkSet const& marks);
	Byte writeComment(Byte position, Comment const& comment);

	void beginMoveSection();
	void endMoveSection(result::ID result);
	void beginVariation();
	void endVariation(bool isEmpty);

	util::ByteStream	m_stream;
	Byte					m_buffer[Block_Size];
	Codec&				m_codec;
	unsigned				m_streamPos;
	Move					m_move;
	unsigned				m_runLength;
	bool					m_endOfRun;
	bool					m_danglingPop;
	bool					m_danglindEndMarker;
};

} // namespace sci
} // namespace db

#endif // _sci_consumer_included

// vi:set ts=3 sw=3:
