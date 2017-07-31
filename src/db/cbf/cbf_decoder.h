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
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _cbf_decoder_included
#define _cbf_decoder_included

#include "cbf_decoder_position.h"

#include "db_move.h"

namespace util { class ByteStream; }
namespace sys  { namespace utf8 { class Codec; } }

namespace db {

class GameData;
class Consumer;
class TagSet;
class GameInfo;
class MoveNode;

namespace cbf {

class Decoder
{
public:

	Decoder(util::ByteStream& strm, sys::utf8::Codec& codec);

	void doDecoding(GameData& data);
	save::State doDecoding(db::Consumer& consumer, TagSet& tags);
	unsigned doDecoding(uint16_t* line, unsigned length, Board& startBoard, bool useStartBoard);

private:

	Decoder(Decoder const&);
	Decoder& operator=(Decoder const&);

	void prepareDecoding(util::ByteStream& moveArea, util::ByteStream* textArea = nullptr);

	void decodeAnnotation(util::ByteStream& strm);
	void decodeVariation(util::ByteStream& moves, util::ByteStream& text);
	void decodeVariation(db::Consumer& consumer, util::ByteStream& moves, util::ByteStream& text);
	unsigned decodeMainline(util::ByteStream& moves, uint16_t* line, unsigned length, Board* startBoard);

	::db::MoveNode*	m_currentNode;
	util::ByteStream&	m_strm;
	sys::utf8::Codec&	m_codec;
	decoder::Position	m_position;
};

} // namespace cbf
} // namespace db

#endif // _cbf_decoder_included

// vi:set ts=3 sw=3:
