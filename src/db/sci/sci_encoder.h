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

#ifndef _sci_encoder_included
#define _sci_encoder_included

#include "sci_encoder_position.h"

#include "db_consumer.h"

#include "u_byte_stream.h"

namespace util { class ByteStream; }

namespace db {

class Move;
class MoveNode;
class MoveInfoTable;
class EngineList;
class TimeTable;
class Signature;
class GameData;
class Board;
class TagSet;

namespace sci {

class Encoder
{
public:

	Encoder(util::ByteStream& strm, db::variant::Type variant);

	void doEncoding(	Signature const& signature,
							GameData const& data,
							db::Consumer::TagBits const& allowedTags,
							bool allowExtraTags);
	void doEncoding(	Signature const& signature,
							GameData const& data1,
							GameData const& data2,
							db::Consumer::TagBits const& allowedTags,
							bool allowExtraTags);

	void changeVariant(db::variant::Type variant);

	static bool isExtraTag(tag::ID tag);
	static db::tag::TagSet const& infoTags();

protected:

	typedef encoder::Position Position;

	void setup(Board const& board, db::variant::Type variant, bool hasTimeTable);

	void prepareEncoding();
	void finishMoveSection(uint16_t runLength);
	void encodeDataSection(	TagSet const& tags,
									db::Consumer::TagBits const& allowedTags,
									bool allowExtraTags,
									EngineList const& engines,
									TimeTable const& timeTable);

	bool encodeMove(Move const& move);

	util::ByteStream&	m_strm;
	util::ByteStream	m_data;
	util::ByteStream	m_text;
	Position				m_position;
	uint16_t				m_runLength;

private:

	bool doEncoding(Move const& move);

	void encodeNullOrDropMove(Move const& move);
	void encodeKing(Move const& move);
	void encodeQueen(Move const& move);
	void encodeRook(Move const& move);
	void encodeBishop(Move const& move);
	void encodeKnight(Move const& move);
	void encodePawn(Move const& move);
	void encodePieceDrop(Move const& move);

	void encodeMainline(MoveNode const* node);
	void encodeVariation(MoveNode const* node);
	void encodeNote(MoveNode const* node);
	void encodeComment(MoveNode const* node);

	uint16_t encodeTextSection();
	uint16_t encodeTagSection(	TagSet const& tags,
										db::Consumer::TagBits allowedTags,
										bool allowExtraTags);
	uint16_t encodeEngineSection(EngineList const& engines);
	uint16_t encodeTimeTableSection(TimeTable const& timeTable);

	void setup(GameData const& data);
	void setup(Board const& board, uint16_t idn, db::variant::Type variant, bool hasTimeTable);
	void putMoveByte(Square from, Byte value);

	unsigned				m_offset;
	db::variant::Type	m_variant;
	bool					m_hasTimeTable;
	unsigned char		m_buffer[2][4096];
};


} // namespace sci
} // namespace db

#include "sci_encoder.ipp"

#endif // _sci_encoder_included

// vi:set ts=3 sw=3:
