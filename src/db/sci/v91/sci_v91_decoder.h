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

#ifndef _sci_v91_decoder_included
#define _sci_v91_decoder_included

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
namespace v91 {

class Decoder
{
public:

	Decoder(util::ByteStream& strm);
	Decoder(util::ByteStream& strm, unsigned ensuredStreamSize);

	Move findExactPosition(Board const& position, bool skipVariations);

	void doDecoding(GameData& data);
	save::State doDecoding(db::Consumer& consumer, TagSet& tags);

private:

	void decodeRun(unsigned count);
	void decodeRun(unsigned count, Consumer& consumer);
	void decodeVariation();
	void decodeVariation(Consumer& consumer, util::ByteStream& data, util::ByteStream& text);
	void decodeComments(MoveNode* node, util::ByteStream& data);
	void decodeTags(util::ByteStream& strm, TagSet& tags);
	void decodeTextSection(GameData& data);
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

	Move searchForPosition(Board const& position, bool skipVariations);

	Decoder(Decoder const&);
	Decoder& operator=(Decoder const&);

	util::ByteStream&	m_strm;
	unsigned				m_ensuredStreamSize;
	decoder::Position	m_position;
	MoveNode*			m_currentNode;
};

} // namespace v91
} // namespace sci
} // namespace db

#endif // _sci_v91_decoder_included

// vi:set ts=3 sw=3:
