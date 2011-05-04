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

#ifndef _sci_decoder_included
#define _sci_decoder_included

#include "sci_decoder_position.h"

#include "db_common.h"
#include "db_move.h"
#include "db_eco.h"

namespace sys { namespace utf8 { class Codec; } }

namespace util { class ByteStream; }

namespace db {

class Board;
class GameData;
class MoveNode;
class Consumer;
class TagSet;

namespace sci {

class Decoder
{
public:

	Decoder(util::ByteStream& strm);
	Decoder(util::ByteStream& strm, unsigned ensuredStreamSize);

	Move findExactPosition(Board const& position, bool skipVariations);

	void doDecoding(unsigned flags, GameData& data);
	save::State doDecoding(db::Consumer& consumer, unsigned flags, TagSet& tags);

	void recode(util::ByteStream& dst, sys::utf8::Codec& oldCodec, sys::utf8::Codec& newCodec);

private:

	void decodeRun(unsigned count);
	void decodeRun(unsigned count, Consumer& consumer);
	void decodeVariation(unsigned flags, unsigned level = 0);
	void decodeVariation(Consumer& consumer, util::ByteStream& text, unsigned flags, unsigned level = 0);
	void decodeComments(MoveNode* node);
	void decodeTags(util::ByteStream& strm, TagSet& tags);
	void skipTags();
	void decodeTextSection(unsigned flags, GameData& data);
	void decodeMark();

	unsigned decodeMove(Byte value, Move& move);
	Move nextMove(unsigned runLength = 0);
	void skipVariations();

	Move decodeKing(sq::ID from, Byte nybble);
	Move decodeQueen(sq::ID from, Byte nybble);
	Move decodeRook(sq::ID from, Byte nybble);
	Move decodeBishop(sq::ID from, Byte nybble);
	Move decodeKnight(sq::ID from, Byte nybble);
	Move decodePawn(sq::ID from, Byte nybble);

	Decoder(Decoder const&);
	Decoder& operator=(Decoder const&);

	util::ByteStream&	m_strm;
	unsigned				m_ensuredStreamSize;
	decoder::Position	m_position;
	MoveNode*			m_currentNode;
};

} // namespace sci
} // namespace db

#endif // _sci_decoder_included

// vi:set ts=3 sw=3:
