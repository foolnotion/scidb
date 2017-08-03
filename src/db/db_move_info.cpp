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
// Copyright: (C) 2011-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_move_info.h"
#include "db_engine_list.h"
#include "db_exception.h"
#include "db_common.h"

#include "u_byte_stream.h"

#include "m_utility.h"
#include "m_assert.h"

#include <ctype.h>
#include <stdlib.h>

using namespace db;
using namespace util;

typedef ByteStream::uint24_t uint24_t;


inline
static char const*
skipSpaces(char const* s)
{
	while (*s == ' ')
		++s;

	return s;
}


MoveInfo::AnalysisInfo::AnalysisInfo()
	:m_depth(0)
	,m_pawns(0)
	,m_centipawns(0)
{
}


MoveInfo::ElapsedTime::ElapsedTime()
	:m_seconds(0)
	,m_milliSeconds(0)
{
}


MoveInfo::MoveInfo()
	:m_content(None)
	,m_engine(0)
{
}


MoveInfo::Type
MoveInfo::type(unsigned char firstByte)
{
	M_REQUIRE(firstByte == 0 || isMoveInfo(firstByte));

	if (firstByte == 0)
		return None;

	return Type(((firstByte >> 4) & 0x07) + 1);
}


bool
MoveInfo::hasTimeInfo() const
{
	switch (int(m_content))
	{
		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ElapsedMilliSeconds:
		case ClockTime:
			return true;
	}

	return false;
}


int
MoveInfo::compare(MoveInfo const& mi) const
{
	if (int cmp = int(m_content) - int(mi.m_content))
		return cmp;

	switch (m_content)
	{
		case None:
			return 0;

		case CorrespondenceChessSent:
			if (int cmp = mstl::compare(m_time.m_date, mi.m_time.m_date))
				return cmp;
			// fallthru

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ClockTime:
			if (int cmp = mstl::compare(m_time.m_clock, mi.m_time.m_clock))
				return cmp;
			break;

		case ElapsedMilliSeconds:
			if (int cmp = int(m_elapsed.m_seconds)      - int(mi.m_elapsed.m_seconds     )) return cmp;
			if (int cmp = int(m_elapsed.m_milliSeconds) - int(mi.m_elapsed.m_milliSeconds)) return cmp;
			break;

		case VideoTime:
			return int(m_centiSeconds) - int(mi.m_centiSeconds);

		case Evaluation:
			if (int cmp = int(m_analysis.m_depth)      - int(mi.m_analysis.m_depth     )) return cmp;
			if (int cmp = int(m_analysis.m_sign)       - int(mi.m_analysis.m_sign      )) return cmp;
			if (int cmp = int(m_analysis.m_pawns)      - int(mi.m_analysis.m_pawns     )) return cmp;
			if (int cmp = int(m_analysis.m_centipawns) - int(mi.m_analysis.m_centipawns)) return cmp;
			break;
	}

	return 0;
}


void
MoveInfo::setAnalysisEngine(unsigned engine)
{
	M_REQUIRE(	content() == Evaluation
				|| content() == ElapsedMoveTime
				|| content() == ElapsedMilliSeconds
				|| content() == PlayersClock);

	if (m_content == PlayersClock)
		m_content = ElapsedMoveTime;

	m_engine = engine;
}


void
MoveInfo::setClockEngine(unsigned engine)
{
	M_REQUIRE(content() == PlayersClock);

	if (engine)
	{
		m_engine = engine;
		m_content = ElapsedMoveTime;
	}
}


char const*
MoveInfo::parseCentiSeconds(char const* s)
{
	M_REQUIRE(s);

	char const* c = s;

	while (::isdigit(*c))
		++c;

	if (c == s)
		return 0;

	char* e;

	m_centiSeconds = ::strtoul(s, &e, 10)*100;

	M_ASSERT(e);

	if (c[0] == '.' && ::isdigit(c[1]))
	{
		char buf[3] = { c[1], ::isdigit(c[2]) ? c[2] : '0', '\0' };
		m_centiSeconds += ::strtoul(buf, 0, 10);

		do
			++c;
		while (::isdigit(*c));

		e = const_cast<char*>(c);
	}

	m_content = VideoTime;
	return e;
}


char const*
MoveInfo::parseTime(Type type, char const* s)
{
	M_REQUIRE(s);

	char const* e = m_time.m_clock.parse(s);

	if (e)
		m_content = type;

	return e;
}


char const*
MoveInfo::parseElapsedTime(char const* s)
{
	M_REQUIRE(s);

	if (::strchr(s, ':'))
		return parseTime(ElapsedMoveTime, s);

	char* e = 0;

	m_elapsed.m_milliSeconds = 0;
	m_elapsed.m_seconds = strtoul(::skipSpaces(s), &e, 10);

	if (*::skipSpaces(e) != ']')
	{
		if (*e != '.')
			return 0;

		m_elapsed.m_milliSeconds = strtoul(e + 1, &e, 10);
	}

	m_content = ElapsedMilliSeconds;

	return ::skipSpaces(e);
}


char const*
MoveInfo::parseTimeInfo(char const* s)
{
	M_REQUIRE(s);

	char* e = 0;

	m_elapsed.m_milliSeconds = 0;
	m_elapsed.m_seconds = strtoul(::skipSpaces(s), &e, 10);

	if (*e != 's')
		return 0;

	m_content = ElapsedMilliSeconds;
	return ::skipSpaces(e + 1);
}


char const*
MoveInfo::parseCorrespondenceChessSent(char const* s)
{
	M_REQUIRE(s);

	char const* e = (s = ::skipSpaces(s));

	while (::isdigit(*e) || *e == '.')
		++e;

	if (!m_time.m_date.parseFromString(s, e - s))
		return 0;

	if (*(s = ::skipSpaces(e)) != ',')
		return s;

	s = m_time.m_clock.parse(::skipSpaces(s + 1));

	if (s == 0)
		return 0;

	m_content = CorrespondenceChessSent;

	return s ? ::skipSpaces(s) : 0;
}


char const*
MoveInfo::parseEvaluation(char const* s)
{
	M_REQUIRE(s);

	char* e = 0;

	s = ::skipSpaces(s);

	if (::isdigit(*s))
	{
		m_analysis.m_depth = ::strtoul(s, &e, 10);

		if (*e != ':')
			return 0;

		s = e + 1;
	}
	else
	{
		m_analysis.m_depth = 0;
	}

	char sign = *s;

	switch (sign)
	{
		case '+':	m_analysis.m_sign = 0; break;
		case '-':	m_analysis.m_sign = 1; break;
		case 'M':	m_analysis.m_sign = 0; break;
		case 'm':	m_analysis.m_sign = 1; break;
		default:		return 0;
	}

	unsigned pawns = ::strtoul(++s, &e, 10);

	if (!::isalpha(sign))
	{
		if (s == e || *e != '.')
			return 0;

		s = e + 1;

		unsigned centipawns = ::strtoul(s, &e, 10);

		if (s == e)
			return 0;

		m_analysis.m_pawns = mstl::min(pawns, (1u << 10) - 2u);
		m_analysis.m_centipawns = mstl::min(centipawns, 99u);

		switch (*e)
		{
			case '|':
				if (::isdigit(e[1]))
					m_analysis.m_depth = ::strtoul(e + 1, &e, 10);
				else if (e[1] == 'd' && ::isdigit(e[2]))
					m_analysis.m_depth = ::strtoul(e + 2, &e, 10);
				break;

			case '/':
				if (::isdigit(e[1]))
					m_analysis.m_depth = ::strtoul(e + 1, &e, 10);
				break;
		}
	}
	else
	{
		m_analysis.m_pawns = (1u << 10) - 1;
		m_analysis.m_centipawns = pawns;
	}

	m_analysis.m_depth = mstl::min(uint8_t((1 << 6) - 1), m_analysis.m_depth);
	m_content = Evaluation;

	return ::skipSpaces(e);
}


util::crc::checksum_t
MoveInfo::computeChecksum(EngineList const& engines, util::crc::checksum_t crc) const
{
	crc = ::util::crc::compute(crc, Byte(m_content));

	switch (m_content)
	{
		case None:
			break;

		case CorrespondenceChessSent:
			crc = m_time.m_date.computeChecksum(crc);
			// fallthru

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ClockTime:
			crc = m_time.m_clock.computeChecksum(crc);
			break;

		case ElapsedMilliSeconds:
			crc = ::util::crc::compute(crc, m_elapsed.m_seconds);
			crc = ::util::crc::compute(crc, m_elapsed.m_milliSeconds);
			break;

		case VideoTime:
			crc = ::util::crc::compute(crc, m_centiSeconds);
			break;

		case Evaluation:
			crc = ::util::crc::compute(crc, Byte(m_analysis.m_depth));
			crc = ::util::crc::compute(crc, Byte(m_analysis.m_sign));
			crc = ::util::crc::compute(crc, uint16_t(m_analysis.m_pawns));
			crc = ::util::crc::compute(crc, Byte(m_analysis.m_centipawns));
			break;
	}

	if (m_engine)
	{
		mstl::string const& engine = engines.engine(m_engine);
		crc = ::util::crc::compute(crc, engine, engine.size());
	}

	return crc;
}


void
MoveInfo::printClock(char const* id, mstl::string& result, Format format) const
{
	if (format == Pgn)
		result.append("[%", 2);

	result.append(id);
	result.append(' ');

	result.format(	"%u:%02u:%02u",
						m_time.m_clock.hour(),
						m_time.m_clock.minute(),
						m_time.m_clock.second());
}


void
MoveInfo::print(	EngineList const& engines,
						mstl::string& result,
						Format format) const
{
	if (m_engine)
	{
		switch (int(m_content))
		{
			case ElapsedMoveTime:
			case Evaluation:
				result.append(engines[m_engine - 1]);
				result.append(' ');
				format = Text;	// cannot use PGN format
				break;
		}
	}

	switch (m_content)
	{
		case None:
			return;

		case PlayersClock:		printClock("clk", result, format); break;
		case ElapsedGameTime:	printClock("egt", result, format); break;
		case ElapsedMoveTime:	printClock("emt", result, format); break;
		case ClockTime:			printClock("ct",  result, format); break;

		case ElapsedMilliSeconds:
			if (format == Pgn)
				result.append("[%");
			result.append("emt ", 4);
			result.format("%u.%u", unsigned(m_elapsed.m_seconds), unsigned(m_elapsed.m_milliSeconds));
			break;

		case CorrespondenceChessSent:
			if (format == Pgn)
				result.append("[%ccsnt ", 8);
			result.format(	"%04u.%02u.%02u",
								m_time.m_date.year(),
								m_time.m_date.month(),
								m_time.m_date.day());
			if (!m_time.m_clock.isEmpty())
			{
				result.append(',');
				if (format == Text)
					result.append(' ');
				result.format("%u", m_time.m_clock.hour());
				if (m_time.m_clock.minute())
					result.format(":%02u", m_time.m_clock.minute());
				if (m_time.m_clock.second())
					result.format(":%02u", m_time.m_clock.second());
			}
			break;

		case VideoTime:
			if (format == Pgn)
				result.append("[%");
			result.append("vt ", 3);
			result.format("%u.%u", unsigned(m_centiSeconds/1000), unsigned(m_centiSeconds % 1000));
			break;

		case Evaluation:
			if (format == Pgn)
				result.append("[%eval ", 7);
			if (m_analysis.m_depth)
				result.format("%u:", m_analysis.m_depth);
			if (m_analysis.m_pawns == (1 << 10) - 1)
			{
				result.format(	"%cM%u",
									m_analysis.m_sign ? '-' : '+',
									unsigned(m_analysis.m_centipawns));
			}
			else
			{
				result.format(	"%c%u.%02u",
									m_analysis.m_sign ? '-' : '+',
									unsigned(m_analysis.m_pawns),
									unsigned(m_analysis.m_centipawns));
			}
			if (format == Text)
				return;
			break;
	}

	if (format == Pgn)
		result.append(']');
}


void
MoveInfo::decode(ByteStream& strm)
{
	M_REQUIRE(strm.peek() == 0 || isMoveInfo(strm.peek()));

	uint8_t	u = strm.get();
	uint32_t	v;

	switch (m_content = type(u))
	{
		case None:
			// nothing to do
			break;

		case CorrespondenceChessSent:
			v = strm.uint32();
			m_time.m_date.setYMD(
				Date::decodeYearFrom10Bits((v >> 21) & 0x03ff),
				((v >> 17) & 0x000f),
				((v >> 12) & 0x001f));
			m_time.m_clock.setHMS(
				((u >> 4) & 0x000f),
				((v >> 6) & 0x003f),
				((v     ) & 0x003f));
			break;

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ClockTime:
			v = strm.uint16();
			m_engine = u & 0x0f;
			m_time.m_clock.setHMS(
				((v >> 12) & 0x000f),
				((v >>  6) & 0x003f),
				((v      ) & 0x003f));
			break;

		case ElapsedMilliSeconds:
			v = strm.uint24();
			m_elapsed.m_seconds = (v >> 10);
			m_elapsed.m_milliSeconds	= (v & 0x000003ff);
			m_elapsed.m_seconds |= ((u & 0x0f) << 14);
			break;

		case VideoTime:
			m_centiSeconds = ((uint32_t(u) & 0x000f) << 24) | strm.uint24();
			break;

		case Evaluation:
			v = strm.uint24();
			m_engine = u & 0x0f;
			m_analysis.m_depth      = ((v >> 18) & 0x003f);
			m_analysis.m_sign       = ((v >> 17) & 0x0001);
			m_analysis.m_pawns      = ((v >>  7) & 0x03ff);
			m_analysis.m_centipawns = ((v      ) & 0x007f);
			break;
	}
}


void
MoveInfo::skip(ByteStream& strm)
{
	M_REQUIRE(isMoveInfo(strm.peek()));
	strm.skip(length(strm.peek()));
}


unsigned
MoveInfo::length(unsigned char firstByte)
{
	M_REQUIRE(isMoveInfo(firstByte));

	switch (type(firstByte))
	{
		case None:							return 1;
		case PlayersClock:				// fallthru
		case ElapsedGameTime:			// fallthru
		case ElapsedMoveTime:			// fallthru
		case ClockTime:					return 3;
		case Evaluation:					// fallthru
		case ElapsedMilliSeconds:		// fallthru
		case VideoTime:					return 4;
		case CorrespondenceChessSent:	return 5;
	}

	return 1; // never reached
}


unsigned char const*
MoveInfo::skip(unsigned char const* strm, unsigned char const* eos)
{
	M_REQUIRE(isMoveInfo(*strm));

	if ((strm += length(*strm)) > eos)
		IO_RAISE(Game, Corrupted, "corrupted stream");

	return strm;
}


void
MoveInfo::encode(ByteStream& strm) const
{
	switch (m_content)
	{
		case None:
			// should only happen in time tables
			strm << uint8_t(0);
			break;

		case CorrespondenceChessSent:
		{
			strm << uint8_t
			(
				  0x80																//  1 bit
				| (uint8_t(m_content - 1) << 4)								//  3 bit
				| (uint8_t(m_time.m_clock.hour() & 0x000f))				//  4 bit
			);
			uint32_t year = Date::encodeYearTo10Bits(m_time.m_date.year());
			strm << uint32_t
			(
				  (uint32_t(year & 0x03ff) << 21)							// 10 bit
				| (uint32_t(m_time.m_date.month() & 0x000f) << 17)		//  4 bit
				| (uint32_t(m_time.m_date.day() & 0x001f) << 12)		//  5 bit
				| (uint32_t(m_time.m_clock.minute() & 0x003f) << 6)	//  6 bit
				| (uint32_t(m_time.m_clock.second() & 0x003f))			//  6 bit
			);
			break;
		}

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ClockTime:
			strm << uint8_t
			(
				  0x80																//  1 bit
				| (uint8_t(m_content - 1) << 4)								//  3 bit
				| (uint8_t(m_engine) & 0x0f)									//  4 bit
			);
			strm << uint16_t
			(
				  (uint16_t(m_time.m_clock.hour() & 0x000f) << 12)		//  4 bit
				| (uint16_t(m_time.m_clock.minute() & 0x003f) << 6)	//  6 bit
				| (uint16_t(m_time.m_clock.second() & 0x003f))			//  6 bit
			);
			break;

		case ElapsedMilliSeconds:
			strm << uint8_t
			(
				  0x80																//  1 bit
				| (uint8_t(m_content - 1) << 4)								//  3 bit
				| (uint8_t(m_elapsed.m_seconds >> 14) & 0x0f)			//  4 bit
			);
			strm << uint24_t
			(
				  (uint32_t(m_elapsed.m_seconds & 0x0003fff) << 10)	// 14 bits
				| (uint32_t(m_elapsed.m_milliSeconds))						// 10 bits
			);
			break;

		case VideoTime:
			strm << uint8_t
			(
				  0x80																//  1 bit
				| (uint8_t(m_content - 1) << 4)								//  3 bit
				| (uint8_t(m_centiSeconds >> 24) & 0x0f)					//  4 bit
			);
			strm << uint24_t(m_centiSeconds & 0x0fff);					// 24 bit
			break;

		case Evaluation:
			strm << uint8_t
			(
					0x80																//  1 bit
				 | (uint8_t(m_content - 1) << 4)								//  3 bit
				 | (uint8_t(m_engine & 0x0f))									//  4 bit
			);
			strm << uint24_t
			(
					(uint32_t(m_analysis.m_depth & 0x003f) << 18)		//  6 bit
				 | (uint32_t(m_analysis.m_sign & 0x0001) << 17)			//  1 bit
				 | (uint32_t(m_analysis.m_pawns & 0x03ff) << 7)			// 10 bit
				 | (uint32_t(m_analysis.m_centipawns & 0x007f))			//  7 bit
			);
			break;
	}
}


void
MoveInfo::decodeVersion92(ByteStream& strm)
{
	M_REQUIRE(strm.peek() & 0x80);

	uint8_t	u = strm.get();
	uint32_t	v;

	switch (m_content = Type((u >> 4) & 0x07))
	{
		case None:	// should not happen
			break;

		case CorrespondenceChessSent:
			v = strm.uint32();
			m_time.m_date.setYMD(	((v >>  4) & 0x0fff),
											((v      ) & 0x000f),
											((u      ) & 0x000f));

			m_time.m_clock.setHMS(	((v >> 16) & 0x000f),
											((v >> 20) & 0x003f),
											((v >> 26) & 0x003f));
			break;

		case PlayersClock:
		case ElapsedGameTime:
		case ElapsedMoveTime:
		case ClockTime:
			v = strm.uint16();
			m_engine = u & 0x0f;
			m_time.m_clock.setHMS(	((v      ) & 0x000f),
											((v >>  4) & 0x003f),
											((v >> 10) & 0x003f));
			break;

		case Evaluation:
			v = strm.uint24();
			m_engine = u & 0x0f;
			m_analysis.m_depth      = ((v      ) & 0x003f);
			m_analysis.m_sign       = ((v >>  6) & 0x0001);
			m_analysis.m_pawns      = ((v >>  7) & 0x03ff);
			m_analysis.m_centipawns = ((v >> 17) & 0x007f);
			break;

		default:
			IO_RAISE(Game, Corrupted, "corrupted game data");
	}
}

// vi:set ts=3 sw=3:
