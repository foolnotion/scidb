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

#ifndef _db_move_info_included
#define _db_move_info_included

#include "db_date.h"
#include "db_clock.h"

#include "m_string.h"

namespace util { class ByteStream; }

namespace db {

class MoveInfo
{
public:

	enum Type
	{
		None,
		PlayersClock,
		ElapsedGameTime,
		ElapsedMoveTime,
		MechanicalClockTime,
		DigitalClockTime,
		CorrespondenceChessSent,
		AnalysisInformation,
	};

	bool isEmpty() const;
	bool hasTimeInfo() const;
	bool hasAnalysisInfo() const;

	Type content() const;

	Clock const& clock() const;
	Date const& date() const;

	unsigned engine() const;
	unsigned depth() const;
	unsigned pawns() const;
	unsigned centipawns() const;
	float value() const;

	uint8_t decode(util::ByteStream& strm);
	void encode(util::ByteStream& strm, uint8_t skip) const;

private:

	struct TimeInfo
	{
		Clock	m_clock;
		Date	m_date;
	};

	struct AnalysisInfo
	{
		AnalysisInfo();

		uint8_t m_engine;
		uint8_t m_depth;
		uint8_t m_pawns;
		uint8_t m_centipawns;
	};

	Type m_content;

#if HAVE_0X_UNRESTRICTED_UNIONS
	union {
#endif

		TimeInfo			m_time;
		AnalysisInfo	m_analysis;

#if HAVE_0X_UNRESTRICTED_UNIONS
	};
#endif
};

} // namespace db

#include "db_move_info.ipp"

#endif // _db_move_info_included

// vi:set ts=3 sw=3:
