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

#ifndef _cbh_decoder_included
#define _cbh_decoder_included

#include "cbh_decoder_position.h"
#include "db_move.h"

namespace util { class ByteStream; }

namespace db {

class TagSet;
class MoveNode;

namespace cbh {

class Decoder
{
public:

	Decoder(util::ByteStream& gStrm, bool isChess960);

	Move findExactPosition(Board const& position, bool skipVariations);

	unsigned doDecoding(uint16_t* moves, unsigned length, Board& startBoard, bool useStartBoard);

protected:

	enum { Token_Move, Token_Push, Token_Pop, Token_Skip };

	unsigned decodeMove(db::Move& move, unsigned& count, bool skipVariations = false);
	void startDecoding(TagSet* tags = 0);

	util::ByteStream&	m_gStrm;
	decoder::Position	m_position;
	bool					m_isChess960;

private:

	Decoder(Decoder const&);
	Decoder& operator=(Decoder const&);

	unsigned decodeMoves(uint16_t* line, unsigned length, Board* startBoard);
};

} // namespace cbh
} // namespace db

#endif // _cbh_decoder_included

// vi:set ts=3 sw=3:
