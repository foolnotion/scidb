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

#ifndef _sci_decoder_included
#define _sci_decoder_included

#include "sci_decoder_position.h"

#include "db_common.h"
#include "db_move.h"
#include "db_eco.h"

#include "m_map.h"

//#define SCI_IGNORE_DECODING_ERRORS

namespace mstl { template <typename T, typename U> class map; }

namespace sys { namespace utf8 { class Codec; } }

namespace util { class ByteStream; }

namespace db {

class Board;
class GameData;
class MoveNode;
class Consumer;
class TagSet;
class EngineList;
class TimeTable;

namespace sci {

class Decoder
{
public:

	typedef mstl::map<mstl::string,unsigned> TagMap;
	typedef mstl::map<mstl::string,unsigned> LanguageSet;

	Decoder(util::ByteStream& strm, variant::Type variant);
	Decoder(util::ByteStream& strm, unsigned guaranteedStreamSize, variant::Type variant);

	Move findExactPosition(Board const& position, bool skipVariations);
	void findTags(TagMap& tags);

	void doDecoding(GameData& data);
	save::State doDecoding(db::Consumer& consumer, TagSet& tags);
	unsigned doDecoding(uint16_t* line, unsigned length, Board& startBoard, bool useStartBoard);

	bool stripMoveInformation(unsigned halfMoveCount, unsigned types);
	bool stripTags(TagMap const& tags);

private:

	void decodeRun(unsigned count);
	void decodeRun(unsigned count, Consumer& consumer);
	void decodeVariation(util::ByteStream& data);
	void decodeVariation(Consumer& consumer, util::ByteStream& data, util::ByteStream& text);
	void decodeTextSection(MoveNode* node, util::ByteStream& text);
	void decodeMark();

	Byte const* skipTags(Byte const* p, Byte const* eos);
	Byte const* skipEngines(Byte const* p, Byte const* eos);
	Byte const* skipMoveInfo(Byte const* p, Byte const* eos);

	void skipVariations();

	unsigned decodeMove(Byte value, Move& move);
	unsigned decodeZhouseMove(Move& move);
	Move nextMove(unsigned runLength = 0);

	Move decodeKing(sq::ID from, Byte nybble);
	Move decodeQueen(sq::ID from, Byte nybble);
	Move decodeRook(sq::ID from, Byte nybble);
	Move decodeBishop(sq::ID from, Byte nybble);
	Move decodeKnight(sq::ID from, Byte nybble);
	Move decodePawn(sq::ID from, Byte nybble);

	Move searchForPosition(Board const& position, bool skipVariations);

	static void decodeEngines(util::ByteStream& strm, EngineList& engines);
	static void decodeTags(util::ByteStream& strm, TagSet& tags);
	static void decodeTimeTable(util::ByteStream& strm, TimeTable& timeTable);

	static void collectLanguages(LanguageSet& langs, util::ByteStream text);

#ifdef SCI_IGNORE_DECODING_ERRORS
	void skipEndOfVariation(util::ByteStream& data);
	void skipEndOfVariation(Consumer& consumer, util::ByteStream& data, util::ByteStream& text, db::Move& move);
#endif

	Decoder(Decoder const&);
	Decoder& operator=(Decoder const&);

	util::ByteStream&	m_strm;
	unsigned				m_guaranteedStreamSize;
	decoder::Position	m_position;
	MoveNode*			m_currentNode;
	variant::Type		m_variant;
};

} // namespace sci
} // namespace db

#endif // _sci_decoder_included

// vi:set ts=3 sw=3:
