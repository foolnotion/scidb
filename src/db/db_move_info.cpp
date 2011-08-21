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
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_move_info.h"

#include "u_byte_stream.h"

#include <math.h>

using namespace db;
using namespace util;

typedef ByteStream::uint24_t uint24_t;


MoveInfo::AnalysisInfo::AnalysisInfo()
	:m_engine(0)
	,m_depth(0)
	,m_pawns(0)
	,m_centipawns(0)
{
}


uint8_t
MoveInfo::decode(ByteStream& strm)
{
	uint8_t skip = strm.get();

	m_content = Type(skip & 0x0f);
	skip >>= 4;

	switch (m_content)
	{
		case None:
			break;

		case CorrespondenceChessSent:
			{
				uint32_t v = strm.uint24();

				m_time.m_date.setYMD(	(v & uint32_t(0xfffe00)) >> 13,
											(v & uint32_t(0x0001e0)) >> 9,
											v & uint32_t(0x00001f));
			}
			// fallthru

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case MechanicalClockTime:
		case DigitalClockTime:
			{
				uint16_t v = strm.uint16();

				m_time.m_clock.set(	(v & uint16_t(0xf000)) >> 10,
											(v & uint16_t(0x0fc0)) >> 6,
											v & uint16_t(0x003f));
			}
			break;

		case AnalysisInformation:
			{
				uint32_t v = strm.uint24();

				m_analysis.m_engine     = (v & uint32_t(0xf00000)) >> 20;
				m_analysis.m_depth      = (v & uint32_t(0x0fe000)) >> 13;
				m_analysis.m_pawns      = (v & uint32_t(0x001f80)) >> 7;
				m_analysis.m_centipawns = v & uint32_t(0x00007f);
			}
			break;
	}

	return skip;
}


void
MoveInfo::encode(ByteStream& strm, uint8_t skip) const
{
	strm.put(skip <<= 4 | m_content);

	switch (m_content)
	{
		case None:
			break;

		case CorrespondenceChessSent:
			strm << uint24_t(	(uint32_t(m_time.m_date.year()) << 13)
								 | (uint32_t(m_time.m_date.month()) << 9)
								 | (uint32_t(m_time.m_date.day())));
			// fallthru

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case MechanicalClockTime:
		case DigitalClockTime:
			strm << uint16_t(	(uint16_t(m_time.m_clock.hour()) << 20)
								 | (uint16_t(m_time.m_clock.minute()) << 13)
								 | (uint16_t(m_time.m_clock.second())));
			break;

		case AnalysisInformation:
			strm << uint24_t(	(uint32_t(m_analysis.m_engine) << 20)
								 | (uint32_t(m_analysis.m_depth) << 13)
								 | (uint32_t(m_analysis.m_pawns) << 7)
								 | uint32_t(m_analysis.m_centipawns));
			break;
	}
}

// vi:set ts=3 sw=3:
