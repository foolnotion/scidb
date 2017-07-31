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

// ChessBase format description:
// http://talkchess.com/forum/viewtopic.php?t=29468&highlight=cbh
// http://talkchess.com/forum/viewtopic.php?topic_view=threads&p=287896&t=29468&sid=a535ba2e9a17395e2582bdddf57c2425

#include "cbh_decoder.h"

#include "db_tag_set.h"
#include "db_exception.h"

#include "u_byte_stream.h"
#include "u_bit_stream.h"

using namespace util;
using namespace db;
using namespace db::cbh;


static Byte MoveNumberLookup[256] =
{
	0xa2, 0x95, 0x43, 0xf5, 0xc1, 0x3d, 0x4a, 0x6c,	//   0 -   7
	0x53, 0x83, 0xcc, 0x7c, 0xff, 0xae, 0x68, 0xad,	//   8 -  15
	0xd1, 0x92, 0x8b, 0x8d, 0x35, 0x81, 0x5e, 0x74,	//  16 -  23
	0x26, 0x8e, 0xab, 0xca, 0xfd, 0x9a, 0xf3, 0xa0,	//  24 -  31
	0xa5, 0x15, 0xfc, 0xb1, 0x1e, 0xed, 0x30, 0xea,	//  32 -  39
	0x22, 0xeb, 0xa7, 0xcd, 0x4e, 0x6f, 0x2e, 0x24,	//  40 -  47
	0x32, 0x94, 0x41, 0x8c, 0x6e, 0x58, 0x82, 0x50,	//  48 -  55
	0xbb, 0x02, 0x8a, 0xd8, 0xfa, 0x60, 0xde, 0x52,	//  56 -  63
	0xba, 0x46, 0xac, 0x29, 0x9d, 0xd7, 0xdf, 0x08,	//  64 -  71
	0x21, 0x01, 0x66, 0xa3, 0xf1, 0x19, 0x27, 0xb5,	//  72 -  79
	0x91, 0xd5, 0x42, 0x0e, 0xb4, 0x4c, 0xd9, 0x18,	//  80 -  87
	0x5f, 0xbc, 0x25, 0xa6, 0x96, 0x04, 0x56, 0x6a,	//  88 -  95
	0xaa, 0x33, 0x1c, 0x2b, 0x73, 0xf0, 0xdd, 0xa4,	//  96 - 103
	0x37, 0xd3, 0xc5, 0x10, 0xbf, 0x5a, 0x23, 0x34,	// 104 - 111
	0x75, 0x5b, 0xb8, 0x55, 0xd2, 0x6b, 0x09, 0x3a,	// 112 - 119
	0x57, 0x12, 0xb3, 0x77, 0x48, 0x85, 0x9b, 0x0f,	// 120 - 127
	0x9e, 0xc7, 0xc8, 0xa1, 0x7f, 0x7a, 0xc0, 0xbd,	// 128 - 135
	0x31, 0x6d, 0xf6, 0x3e, 0xc3, 0x11, 0x71, 0xce,	// 136 - 143
	0x7d, 0xda, 0xa8, 0x54, 0x90, 0x97, 0x1f, 0x44,	// 144 - 151
	0x40, 0x16, 0xc9, 0xe3, 0x2c, 0xcb, 0x84, 0xec,	// 152 - 159
	0x9f, 0x3f, 0x5c, 0xe6, 0x76, 0x0b, 0x3c, 0x20,	// 160 - 167
	0xb7, 0x36, 0x00, 0xdc, 0xe7, 0xf9, 0x4f, 0xf7,	// 168 - 175
	0xaf, 0x06, 0x07, 0xe0, 0x1a, 0x0a, 0xa9, 0x4b,	// 176 - 183
	0x0c, 0xd6, 0x63, 0x87, 0x89, 0x1d, 0x13, 0x1b,	// 184 - 191
	0xe4, 0x70, 0x05, 0x47, 0x67, 0x7b, 0x2f, 0xee,	// 192 - 199
	0xe2, 0xe8, 0x98, 0x0d, 0xef, 0xcf, 0xc4, 0xf4,	// 200 - 207
	0xfb, 0xb0, 0x17, 0x99, 0x64, 0xf2, 0xd4, 0x2a,	// 208 - 215
	0x03, 0x4d, 0x78, 0xc6, 0xfe, 0x65, 0x86, 0x88,	// 216 - 223
	0x79, 0x45, 0x3b, 0xe5, 0x49, 0x8f, 0x2d, 0xb9,	// 224 - 231
	0xbe, 0x62, 0x93, 0x14, 0xe9, 0xd0, 0x38, 0x9c,	// 232 - 239
	0xb2, 0xc2, 0x59, 0x5d, 0xb6, 0x72, 0x51, 0xf8,	// 240 - 247
	0x28, 0x7e, 0x61, 0x39, 0xe1, 0xdb, 0x69, 0x80,	// 248 - 255
};


Decoder::Decoder(ByteStream& gStrm, bool isChess960)
	:m_gStrm(gStrm)
	,m_isChess960(isChess960)
{
}


unsigned
Decoder::decodeMove(Move& move, unsigned& count, bool skipVariations)
{
	switch (::MoveNumberLookup[Byte(m_gStrm.get() - count)])
	{
#define OFFSET(x, y) ((x) + (y)*8)

		// Null move ###########################
		case 0x00: move = m_position.doNullMove(); break;

		// King ################################
		case 0x01: move = m_position.doKingMove(OFFSET(0, 1)); break;
		case 0x02: move = m_position.doKingMove(OFFSET(1, 1)); break;
		case 0x03: move = m_position.doKingMove(OFFSET(1, 0)); break;
		case 0x04: move = m_position.doKingMove(OFFSET(1, 7)); break;
		case 0x05: move = m_position.doKingMove(OFFSET(0, 7)); break;
		case 0x06: move = m_position.doKingMove(OFFSET(7, 7)); break;
		case 0x07: move = m_position.doKingMove(OFFSET(7, 0)); break;
		case 0x08: move = m_position.doKingMove(OFFSET(7, 1)); break;
		case 0x09: move = m_position.doCastling(Byte(+2)); break;
		case 0x0a: move = m_position.doCastling(Byte(-2)); break;

		// First Queen #########################
		case 0x0b: move = m_position.doQueenMove(0, OFFSET(0, 1)); break;
		case 0x0c: move = m_position.doQueenMove(0, OFFSET(0, 2)); break;
		case 0x0d: move = m_position.doQueenMove(0, OFFSET(0, 3)); break;
		case 0x0e: move = m_position.doQueenMove(0, OFFSET(0, 4)); break;
		case 0x0f: move = m_position.doQueenMove(0, OFFSET(0, 5)); break;
		case 0x10: move = m_position.doQueenMove(0, OFFSET(0, 6)); break;
		case 0x11: move = m_position.doQueenMove(0, OFFSET(0, 7)); break;
		case 0x12: move = m_position.doQueenMove(0, OFFSET(1, 0)); break;
		case 0x13: move = m_position.doQueenMove(0, OFFSET(2, 0)); break;
		case 0x14: move = m_position.doQueenMove(0, OFFSET(3, 0)); break;
		case 0x15: move = m_position.doQueenMove(0, OFFSET(4, 0)); break;
		case 0x16: move = m_position.doQueenMove(0, OFFSET(5, 0)); break;
		case 0x17: move = m_position.doQueenMove(0, OFFSET(6, 0)); break;
		case 0x18: move = m_position.doQueenMove(0, OFFSET(7, 0)); break;
		case 0x19: move = m_position.doQueenMove(0, OFFSET(1, 1)); break;
		case 0x1a: move = m_position.doQueenMove(0, OFFSET(2, 2)); break;
		case 0x1b: move = m_position.doQueenMove(0, OFFSET(3, 3)); break;
		case 0x1c: move = m_position.doQueenMove(0, OFFSET(4, 4)); break;
		case 0x1d: move = m_position.doQueenMove(0, OFFSET(5, 5)); break;
		case 0x1e: move = m_position.doQueenMove(0, OFFSET(6, 6)); break;
		case 0x1f: move = m_position.doQueenMove(0, OFFSET(7, 7)); break;
		case 0x20: move = m_position.doQueenMove(0, OFFSET(1, 7)); break;
		case 0x21: move = m_position.doQueenMove(0, OFFSET(2, 6)); break;
		case 0x22: move = m_position.doQueenMove(0, OFFSET(3, 5)); break;
		case 0x23: move = m_position.doQueenMove(0, OFFSET(4, 4)); break;
		case 0x24: move = m_position.doQueenMove(0, OFFSET(5, 3)); break;
		case 0x25: move = m_position.doQueenMove(0, OFFSET(6, 2)); break;
		case 0x26: move = m_position.doQueenMove(0, OFFSET(7, 1)); break;

		// First Rook ##########################
		case 0x27: move = m_position.doRookMove(0, OFFSET(0, 1)); break;
		case 0x28: move = m_position.doRookMove(0, OFFSET(0, 2)); break;
		case 0x29: move = m_position.doRookMove(0, OFFSET(0, 3)); break;
		case 0x2a: move = m_position.doRookMove(0, OFFSET(0, 4)); break;
		case 0x2b: move = m_position.doRookMove(0, OFFSET(0, 5)); break;
		case 0x2c: move = m_position.doRookMove(0, OFFSET(0, 6)); break;
		case 0x2d: move = m_position.doRookMove(0, OFFSET(0, 7)); break;
		case 0x2e: move = m_position.doRookMove(0, OFFSET(1, 0)); break;
		case 0x2f: move = m_position.doRookMove(0, OFFSET(2, 0)); break;
		case 0x30: move = m_position.doRookMove(0, OFFSET(3, 0)); break;
		case 0x31: move = m_position.doRookMove(0, OFFSET(4, 0)); break;
		case 0x32: move = m_position.doRookMove(0, OFFSET(5, 0)); break;
		case 0x33: move = m_position.doRookMove(0, OFFSET(6, 0)); break;
		case 0x34: move = m_position.doRookMove(0, OFFSET(7, 0)); break;

		// Second Rook #########################
		case 0x35: move = m_position.doRookMove(1, OFFSET(0, 1)); break;
		case 0x36: move = m_position.doRookMove(1, OFFSET(0, 2)); break;
		case 0x37: move = m_position.doRookMove(1, OFFSET(0, 3)); break;
		case 0x38: move = m_position.doRookMove(1, OFFSET(0, 4)); break;
		case 0x39: move = m_position.doRookMove(1, OFFSET(0, 5)); break;
		case 0x3a: move = m_position.doRookMove(1, OFFSET(0, 6)); break;
		case 0x3b: move = m_position.doRookMove(1, OFFSET(0, 7)); break;
		case 0x3c: move = m_position.doRookMove(1, OFFSET(1, 0)); break;
		case 0x3d: move = m_position.doRookMove(1, OFFSET(2, 0)); break;
		case 0x3e: move = m_position.doRookMove(1, OFFSET(3, 0)); break;
		case 0x3f: move = m_position.doRookMove(1, OFFSET(4, 0)); break;
		case 0x40: move = m_position.doRookMove(1, OFFSET(5, 0)); break;
		case 0x41: move = m_position.doRookMove(1, OFFSET(6, 0)); break;
		case 0x42: move = m_position.doRookMove(1, OFFSET(7, 0)); break;

		// First Bishop ########################
		case 0x43: move = m_position.doBishopMove(0, OFFSET(1, 1)); break;
		case 0x44: move = m_position.doBishopMove(0, OFFSET(2, 2)); break;
		case 0x45: move = m_position.doBishopMove(0, OFFSET(3, 3)); break;
		case 0x46: move = m_position.doBishopMove(0, OFFSET(4, 4)); break;
		case 0x47: move = m_position.doBishopMove(0, OFFSET(5, 5)); break;
		case 0x48: move = m_position.doBishopMove(0, OFFSET(6, 6)); break;
		case 0x49: move = m_position.doBishopMove(0, OFFSET(7, 7)); break;
		case 0x4a: move = m_position.doBishopMove(0, OFFSET(1, 7)); break;
		case 0x4b: move = m_position.doBishopMove(0, OFFSET(2, 6)); break;
		case 0x4c: move = m_position.doBishopMove(0, OFFSET(3, 5)); break;
		case 0x4d: move = m_position.doBishopMove(0, OFFSET(4, 4)); break;
		case 0x4e: move = m_position.doBishopMove(0, OFFSET(5, 3)); break;
		case 0x4f: move = m_position.doBishopMove(0, OFFSET(6, 2)); break;
		case 0x50: move = m_position.doBishopMove(0, OFFSET(7, 1)); break;

		// Second Bishop #######################
		case 0x51: move = m_position.doBishopMove(1, OFFSET(1, 1)); break;
		case 0x52: move = m_position.doBishopMove(1, OFFSET(2, 2)); break;
		case 0x53: move = m_position.doBishopMove(1, OFFSET(3, 3)); break;
		case 0x54: move = m_position.doBishopMove(1, OFFSET(4, 4)); break;
		case 0x55: move = m_position.doBishopMove(1, OFFSET(5, 5)); break;
		case 0x56: move = m_position.doBishopMove(1, OFFSET(6, 6)); break;
		case 0x57: move = m_position.doBishopMove(1, OFFSET(7, 7)); break;
		case 0x58: move = m_position.doBishopMove(1, OFFSET(1, 7)); break;
		case 0x59: move = m_position.doBishopMove(1, OFFSET(2, 6)); break;
		case 0x5a: move = m_position.doBishopMove(1, OFFSET(3, 5)); break;
		case 0x5b: move = m_position.doBishopMove(1, OFFSET(4, 4)); break;
		case 0x5c: move = m_position.doBishopMove(1, OFFSET(5, 3)); break;
		case 0x5d: move = m_position.doBishopMove(1, OFFSET(6, 2)); break;
		case 0x5e: move = m_position.doBishopMove(1, OFFSET(7, 1)); break;

		// First Knight ########################
		case 0x5f: move = m_position.doKnightMove(0, OFFSET(+2, +1)); break;
		case 0x60: move = m_position.doKnightMove(0, OFFSET(+1, +2)); break;
		case 0x61: move = m_position.doKnightMove(0, OFFSET(-1, +2)); break;
		case 0x62: move = m_position.doKnightMove(0, OFFSET(-2, +1)); break;
		case 0x63: move = m_position.doKnightMove(0, OFFSET(-2, -1)); break;
		case 0x64: move = m_position.doKnightMove(0, OFFSET(-1, -2)); break;
		case 0x65: move = m_position.doKnightMove(0, OFFSET(+1, -2)); break;
		case 0x66: move = m_position.doKnightMove(0, OFFSET(+2, -1)); break;

		// Second Knight #######################
		case 0x67: move = m_position.doKnightMove(1, OFFSET(+2, +1)); break;
		case 0x68: move = m_position.doKnightMove(1, OFFSET(+1, +2)); break;
		case 0x69: move = m_position.doKnightMove(1, OFFSET(-1, +2)); break;
		case 0x6a: move = m_position.doKnightMove(1, OFFSET(-2, +1)); break;
		case 0x6b: move = m_position.doKnightMove(1, OFFSET(-2, -1)); break;
		case 0x6c: move = m_position.doKnightMove(1, OFFSET(-1, -2)); break;
		case 0x6d: move = m_position.doKnightMove(1, OFFSET(+1, -2)); break;
		case 0x6e: move = m_position.doKnightMove(1, OFFSET(+2, -1)); break;

		// a2/a7 Pawn ##########################
		case 0x6f: move = m_position.doPawnOneForward(0); break;
		case 0x70: move = m_position.doPawnTwoForward(0); break;
		case 0x71: move = m_position.doCaptureRight(0); break;
		case 0x72: move = m_position.doCaptureLeft(0); break;

		// b2/b7 Pawn ##########################
		case 0x73: move = m_position.doPawnOneForward(1); break;
		case 0x74: move = m_position.doPawnTwoForward(1); break;
		case 0x75: move = m_position.doCaptureRight(1); break;
		case 0x76: move = m_position.doCaptureLeft(1); break;

		// c2/c7 Pawn ##########################
		case 0x77: move = m_position.doPawnOneForward(2); break;
		case 0x78: move = m_position.doPawnTwoForward(2); break;
		case 0x79: move = m_position.doCaptureRight(2); break;
		case 0x7a: move = m_position.doCaptureLeft(2); break;

		// d2/d7 Pawn ##########################
		case 0x7b: move = m_position.doPawnOneForward(3); break;
		case 0x7c: move = m_position.doPawnTwoForward(3); break;
		case 0x7d: move = m_position.doCaptureRight(3); break;
		case 0x7e: move = m_position.doCaptureLeft(3); break;

		// e2/e7 Pawn ##########################
		case 0x7f: move = m_position.doPawnOneForward(4); break;
		case 0x80: move = m_position.doPawnTwoForward(4); break;
		case 0x81: move = m_position.doCaptureRight(4); break;
		case 0x82: move = m_position.doCaptureLeft(4); break;

		// f2/f7 Pawn ##########################
		case 0x83: move = m_position.doPawnOneForward(5); break;
		case 0x84: move = m_position.doPawnTwoForward(5); break;
		case 0x85: move = m_position.doCaptureRight(5); break;
		case 0x86: move = m_position.doCaptureLeft(5); break;

		// g2/g7 Pawn ##########################
		case 0x87: move = m_position.doPawnOneForward(6); break;
		case 0x88: move = m_position.doPawnTwoForward(6); break;
		case 0x89: move = m_position.doCaptureRight(6); break;
		case 0x8a: move = m_position.doCaptureLeft(6); break;

		// h2/h7 Pawn ##########################
		case 0x8b: move = m_position.doPawnOneForward(7); break;
		case 0x8c: move = m_position.doPawnTwoForward(7); break;
		case 0x8d: move = m_position.doCaptureRight(7); break;
		case 0x8e: move = m_position.doCaptureLeft(7); break;

		// Second Queen #########################
		case 0x8f: move = m_position.doQueenMove(1, OFFSET(0, 1)); break;
		case 0x90: move = m_position.doQueenMove(1, OFFSET(0, 2)); break;
		case 0x91: move = m_position.doQueenMove(1, OFFSET(0, 3)); break;
		case 0x92: move = m_position.doQueenMove(1, OFFSET(0, 4)); break;
		case 0x93: move = m_position.doQueenMove(1, OFFSET(0, 5)); break;
		case 0x94: move = m_position.doQueenMove(1, OFFSET(0, 6)); break;
		case 0x95: move = m_position.doQueenMove(1, OFFSET(0, 7)); break;
		case 0x96: move = m_position.doQueenMove(1, OFFSET(1, 0)); break;
		case 0x97: move = m_position.doQueenMove(1, OFFSET(2, 0)); break;
		case 0x98: move = m_position.doQueenMove(1, OFFSET(3, 0)); break;
		case 0x99: move = m_position.doQueenMove(1, OFFSET(4, 0)); break;
		case 0x9a: move = m_position.doQueenMove(1, OFFSET(5, 0)); break;
		case 0x9b: move = m_position.doQueenMove(1, OFFSET(6, 0)); break;
		case 0x9c: move = m_position.doQueenMove(1, OFFSET(7, 0)); break;
		case 0x9d: move = m_position.doQueenMove(1, OFFSET(1, 1)); break;
		case 0x9e: move = m_position.doQueenMove(1, OFFSET(2, 2)); break;
		case 0x9f: move = m_position.doQueenMove(1, OFFSET(3, 3)); break;
		case 0xa0: move = m_position.doQueenMove(1, OFFSET(4, 4)); break;
		case 0xa1: move = m_position.doQueenMove(1, OFFSET(5, 5)); break;
		case 0xa2: move = m_position.doQueenMove(1, OFFSET(6, 6)); break;
		case 0xa3: move = m_position.doQueenMove(1, OFFSET(7, 7)); break;
		case 0xa4: move = m_position.doQueenMove(1, OFFSET(1, 7)); break;
		case 0xa5: move = m_position.doQueenMove(1, OFFSET(2, 6)); break;
		case 0xa6: move = m_position.doQueenMove(1, OFFSET(3, 5)); break;
		case 0xa7: move = m_position.doQueenMove(1, OFFSET(4, 4)); break;
		case 0xa8: move = m_position.doQueenMove(1, OFFSET(5, 3)); break;
		case 0xa9: move = m_position.doQueenMove(1, OFFSET(6, 2)); break;
		case 0xaa: move = m_position.doQueenMove(1, OFFSET(7, 1)); break;

		// Third Queen ##########################
		case 0xab: move = m_position.doQueenMove(2, OFFSET(0, 1)); break;
		case 0xac: move = m_position.doQueenMove(2, OFFSET(0, 2)); break;
		case 0xad: move = m_position.doQueenMove(2, OFFSET(0, 3)); break;
		case 0xae: move = m_position.doQueenMove(2, OFFSET(0, 4)); break;
		case 0xaf: move = m_position.doQueenMove(2, OFFSET(0, 5)); break;
		case 0xb0: move = m_position.doQueenMove(2, OFFSET(0, 6)); break;
		case 0xb1: move = m_position.doQueenMove(2, OFFSET(0, 7)); break;
		case 0xb2: move = m_position.doQueenMove(2, OFFSET(1, 0)); break;
		case 0xb3: move = m_position.doQueenMove(2, OFFSET(2, 0)); break;
		case 0xb4: move = m_position.doQueenMove(2, OFFSET(3, 0)); break;
		case 0xb5: move = m_position.doQueenMove(2, OFFSET(4, 0)); break;
		case 0xb6: move = m_position.doQueenMove(2, OFFSET(5, 0)); break;
		case 0xb7: move = m_position.doQueenMove(2, OFFSET(6, 0)); break;
		case 0xb8: move = m_position.doQueenMove(2, OFFSET(7, 0)); break;
		case 0xb9: move = m_position.doQueenMove(2, OFFSET(1, 1)); break;
		case 0xba: move = m_position.doQueenMove(2, OFFSET(2, 2)); break;
		case 0xbb: move = m_position.doQueenMove(2, OFFSET(3, 3)); break;
		case 0xbc: move = m_position.doQueenMove(2, OFFSET(4, 4)); break;
		case 0xbd: move = m_position.doQueenMove(2, OFFSET(5, 5)); break;
		case 0xbe: move = m_position.doQueenMove(2, OFFSET(6, 6)); break;
		case 0xbf: move = m_position.doQueenMove(2, OFFSET(7, 7)); break;
		case 0xc0: move = m_position.doQueenMove(2, OFFSET(1, 7)); break;
		case 0xc1: move = m_position.doQueenMove(2, OFFSET(2, 6)); break;
		case 0xc2: move = m_position.doQueenMove(2, OFFSET(3, 5)); break;
		case 0xc3: move = m_position.doQueenMove(2, OFFSET(4, 4)); break;
		case 0xc4: move = m_position.doQueenMove(2, OFFSET(5, 3)); break;
		case 0xc5: move = m_position.doQueenMove(2, OFFSET(6, 2)); break;
		case 0xc6: move = m_position.doQueenMove(2, OFFSET(7, 1)); break;

		// Third Rook ##########################
		case 0xc7: move = m_position.doRookMove(2, OFFSET(0, 1)); break;
		case 0xc8: move = m_position.doRookMove(2, OFFSET(0, 2)); break;
		case 0xc9: move = m_position.doRookMove(2, OFFSET(0, 3)); break;
		case 0xca: move = m_position.doRookMove(2, OFFSET(0, 4)); break;
		case 0xcb: move = m_position.doRookMove(2, OFFSET(0, 5)); break;
		case 0xcc: move = m_position.doRookMove(2, OFFSET(0, 6)); break;
		case 0xcd: move = m_position.doRookMove(2, OFFSET(0, 7)); break;
		case 0xce: move = m_position.doRookMove(2, OFFSET(1, 0)); break;
		case 0xcf: move = m_position.doRookMove(2, OFFSET(2, 0)); break;
		case 0xd0: move = m_position.doRookMove(2, OFFSET(3, 0)); break;
		case 0xd1: move = m_position.doRookMove(2, OFFSET(4, 0)); break;
		case 0xd2: move = m_position.doRookMove(2, OFFSET(5, 0)); break;
		case 0xd3: move = m_position.doRookMove(2, OFFSET(6, 0)); break;
		case 0xd4: move = m_position.doRookMove(2, OFFSET(7, 0)); break;

		// Third Bishop ########################
		case 0xd5: move = m_position.doBishopMove(2, OFFSET(1, 1)); break;
		case 0xd6: move = m_position.doBishopMove(2, OFFSET(2, 2)); break;
		case 0xd7: move = m_position.doBishopMove(2, OFFSET(3, 3)); break;
		case 0xd8: move = m_position.doBishopMove(2, OFFSET(4, 4)); break;
		case 0xd9: move = m_position.doBishopMove(2, OFFSET(5, 5)); break;
		case 0xda: move = m_position.doBishopMove(2, OFFSET(6, 6)); break;
		case 0xdb: move = m_position.doBishopMove(2, OFFSET(7, 7)); break;
		case 0xdc: move = m_position.doBishopMove(2, OFFSET(1, 7)); break;
		case 0xdd: move = m_position.doBishopMove(2, OFFSET(2, 6)); break;
		case 0xde: move = m_position.doBishopMove(2, OFFSET(3, 5)); break;
		case 0xdf: move = m_position.doBishopMove(2, OFFSET(4, 4)); break;
		case 0xe0: move = m_position.doBishopMove(2, OFFSET(5, 3)); break;
		case 0xe1: move = m_position.doBishopMove(2, OFFSET(6, 2)); break;
		case 0xe2: move = m_position.doBishopMove(2, OFFSET(7, 1)); break;

		// Third Knight ########################
		case 0xe3: move = m_position.doKnightMove(2, OFFSET(+2, +1)); break;
		case 0xe4: move = m_position.doKnightMove(2, OFFSET(+1, +2)); break;
		case 0xe5: move = m_position.doKnightMove(2, OFFSET(-1, +2)); break;
		case 0xe6: move = m_position.doKnightMove(2, OFFSET(-2, +1)); break;
		case 0xe7: move = m_position.doKnightMove(2, OFFSET(-2, -1)); break;
		case 0xe8: move = m_position.doKnightMove(2, OFFSET(-1, -2)); break;
		case 0xe9: move = m_position.doKnightMove(2, OFFSET(+1, -2)); break;
		case 0xea: move = m_position.doKnightMove(2, OFFSET(+2, -1)); break;

		// Multiple byte move ##################
		case 0xeb:
			{
				unsigned word = ::MoveNumberLookup[Byte(m_gStrm.get() - count)] << 8;
				word |= ::MoveNumberLookup[Byte(m_gStrm.get() - count)];
				move = m_position.doMove(word & 63, (word >> 6) & 63, ((word >> 12) & 3) + piece::Queen);
			}
			break;

		// Padding #############################
		case 0xec: return Token_Skip;

		// Unused ##############################
		case 0xed: // fallthru
		case 0xee: // fallthru
		case 0xef: // fallthru
		case 0xf0: // fallthru
		case 0xf1: // fallthru
		case 0xf2: // fallthru
		case 0xf3: // fallthru
		case 0xf4: // fallthru
		case 0xf5: // fallthru
		case 0xf6: // fallthru
		case 0xf7: // fallthru
		case 0xf8: // fallthru
		case 0xf9: // fallthru
		case 0xfa: // fallthru
		case 0xfb: // fallthru
		case 0xfc: // fallthru
		case 0xfd: return Token_Skip;

		// Push position #######################
		case 0xfe:
			if (!skipVariations)
				m_position.push();
			return Token_Push;

		// Pop position ########################
		case 0xff:
			if (m_position.variationLevel())
				m_position.pop();
			return Token_Pop;

#undef OFFSET
	}

	++count;
	return Token_Move;
}


unsigned
Decoder::decodeMoves(uint16_t* line, unsigned length, Board* startBoard)
{
	unsigned	count	= 0;
	Move		move;

	for (unsigned index = 0; index < length; )
	{
		switch (decodeMove(move, count, true))
		{
			case Token_Move:
				if (!startBoard)
				{
					line[index++] = move.index();
				}
				else if (startBoard->isEqualZHPosition(m_position.board()))
				{
					startBoard->setPlyNumber(m_position.board().plyNumber());
					startBoard = nullptr;
				}
				break;

			case Token_Pop:
				return index;
		}
	}

	return length;
}


void
Decoder::startDecoding(TagSet* tags)
{
	unsigned word = m_gStrm.uint32();

	if (word & 0x40000000)
	{
		unsigned size = m_isChess960 ? 36 : 28;

		if (m_gStrm.remaining() < size)
			throw DecodingFailedException("corrupted data");

		BitStream bstrm(m_gStrm.data(), size);
		m_position.setup(bstrm);
		m_gStrm.skip(size);

		if (tags)
		{
			tags->set(tag::SetUp, "1");	// bad PGN design
			tags->set(tag::Fen, m_position.board().toFen(variant::Normal, Board::Shredder));
		}
	}
	else
	{
		m_position.setup();
	}
}


unsigned
Decoder::doDecoding(uint16_t* moves, unsigned length, Board& startBoard, bool useStartBoard)
{
	startDecoding();

	if (!useStartBoard)
		startBoard = m_position.board();
	else if (startBoard.isEqualZHPosition(m_position.board()))
		useStartBoard = false;

	if (!useStartBoard)
		return decodeMoves(moves, length, nullptr);
	
	Board board(startBoard);
	return decodeMoves(moves, length, &board);
}


db::Move
Decoder::findExactPosition(Board const& position, bool skipVariations)
{
	startDecoding();

	unsigned	count = 0;
	bool		found	= false;
	Move		move;

	if (m_position.board().isEqualPosition(position))
		found = true;

	while (true)
	{
		unsigned tag = decodeMove(move, count);

		if (found)
			return move;

		switch (tag)
		{
			case Token_Move:
				if (!move || !m_position.board().signature().isReachablePawns(position.signature()))
					return Move::invalid();
				if (m_position.board().isEqualPosition(position))
					found = true;
				break;

			case Token_Pop:
				if (skipVariations)
					return Move::invalid();
				break;
		}
	}

	return move;	// not reached
}

// vi:set ts=3 sw=3:
