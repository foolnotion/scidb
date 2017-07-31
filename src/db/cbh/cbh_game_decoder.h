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
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _cbh_game_decoder_included
#define _cbh_game_decoder_included

#include "cbh_decoder.h"

#include "m_string.h"

#include "m_fixed_size_allocator.h"

namespace sys  { namespace utf8 { class Codec; } }
namespace mstl { template <typename T, typename U> class map; }

namespace db {

class GameData;
class Consumer;
class TagSet;
class MoveNode;
class GameInfo;

namespace cbh {

class GameDecoder : public Decoder
{
public:

	typedef mstl::fixed_size_allocator<db::MoveNode> MoveNodeAllocator;

	GameDecoder(util::ByteStream& gStrm,
					util::ByteStream& aStrm,
					sys::utf8::Codec& codec,
					bool isChess960);

	Move findExactPosition(Board const& position, bool skipVariations);

	unsigned doDecoding(GameData& data);
	save::State doDecoding(	db::Consumer& consumer,
									TagSet& tags,
									GameInfo const& info,
									MoveNodeAllocator& allocator);
	unsigned doDecoding(uint16_t* moves, unsigned length, Board& startBoard);

private:


	void startDecoding(TagSet* tags = 0);
	MoveNode* decodeMoves(MoveNode* root);
	MoveNode* decodeMoves(MoveNodeAllocator& allocator);
	void decodeMoves(MoveNode* root, unsigned& count);
	void decodeMoves(MoveNode* root, unsigned& count, MoveNodeAllocator& allocator);
	void traverse(Consumer& consumer, MoveNode const* root);
	void getAnnotation(MoveNode* node, int moveNo);
	void decodeComment(MoveNode* node, unsigned length, move::Position position);
	void decodeSymbols(MoveNode* node, unsigned length);
	void decodeSquares(MoveNode* node, unsigned length);
	void decodeArrows(MoveNode* node, unsigned length);

	util::ByteStream&	m_aStrm;
	sys::utf8::Codec&	m_codec;
	int					m_moveNo;
};

} // namespace cbh
} // namespace db

#endif // _cbh_game_decoder_included

// vi:set ts=3 sw=3:
