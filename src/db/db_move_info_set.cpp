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

#include "db_move_info_set.h"
#include "db_engine_list.h"

#include "m_algorithm.h"

#include <ctype.h>
#include <string.h>

using namespace db;


char const*
match(char const* s, char const* pattern, unsigned n)
{
	if (::strncmp(s, pattern, n) == 0 && s[n] == ' ')
	{
		s += n + 1;

		while (*s == ' ')
			++s;

		return s;
	}

	return 0;
}


static bool
seemsToBeMoveInfo(char const* s, char const* e)
{
	if (*e == ')' || isdigit(*e))
		return true;

	if (*e == 's' && isdigit(e[-1]))
	{
		e -= 2;

		while (e > s && isdigit(*e))
			--e;

		if (*e == ' ')
		{
			--e;

			while (e > s && *e == ' ')
				--e;

			return *e == ')' || isdigit(*e);
		}
	}

	return false;
}


static bool
seemsToBeEvaluation(char const* s)
{
	if (::isdigit(*s))
	{
		do
			++s;
		while (::isdigit(*s));

		if (*s++ != ':')
			return false;
	}

	return *s == '+' || *s == '-';
}


static bool
isDelim(char const* s)
{
	return *s == '\0' || *s == ' ';
}


static char const*
skipSpaces(char const* s)
{
	while (*s == ' ')
		++s;

	return s;
}


char const*
skipTimeInfo(char const* s)
{
	if (s)
	{
		char const* t = skipSpaces(s);

		if (isdigit(*t))
		{
			do
				++t;
			while (isdigit(*t));

			if (*t == 's')
			{
				if (t[1] == ' ' || t[1] == '\0')
					s = t + 1;
			}
		}
	}

	return s;
}


static int
compare(void const* lhs, void const* rhs)
{
	return static_cast<MoveInfo const*>(lhs)->compare(*static_cast<MoveInfo const*>(rhs));
}


bool
MoveInfoSet::operator==(MoveInfoSet const& info) const
{
	if (count() != info.count())
		return false;

	for (unsigned i = 0; i < count(); ++i)
	{
		if (!info.contains(m_row[i]))
			return false;
	}

	return true;
}


int
MoveInfoSet::find(MoveInfo const& info) const
{
	Row::const_iterator i = mstl::find(m_row.begin(), m_row.end(), info);
	return i == m_row.end() ? -1 : i - m_row.begin();
}


void
MoveInfoSet::sort()
{
	::qsort(m_row.begin(), m_row.size(), sizeof(Row::value_type), ::compare);
}


// Extract move information from comments:
// ------------------------------------------------------------------------------------------------------
// Players Clock:				[%clk 1:05:23]
// Elapsed Game Time:		[%egt 1:25:42]
// Elapsed Move Time:		[%emt 0:05:42]
// Elapsed Milliseconds		[%emt 102.34]
// Mechanical Clock Time:	[%mct 17:10:42]
// (Digital) Clock Time:	[%ct 17:10:42]
// Corres. Chess Sent:		[%ccsnt 2011.06.16]
// 								[%ccsnt 2011.06.16,17:53]
// 								[%ccsnt 2011.06.16,17:53:02]
// Evaluation information:	[%eval -6.05]
// 								"+0.92"
// 								"11:+0.00"
// 								"Crafty: 12:+0.61"
// 								"-11.78|d9"
// 								"+0.00/0"
// 								"[Stockfish 1.9.1] 21:+2.74"
// 								"[Stockfish 1.9.1] 66:M4"
// Time Information:			"1:40:25"
// 								"(1:40:25)"
// 								"Crafty: 1:40:25"
// 								"Rybka Aquarium (0:00:45)"
// Video Time:					"[vt 122.44]"
//
// NOTE:
// Evaluation information may be followed by a time value; e.g. " 4s".
// We will skip this time information.
bool
MoveInfoSet::extractFromComment(EngineList& engineList, mstl::string& comment)
{
	M_REQUIRE(comment.writeable() || comment.empty());

	MoveInfo			info;
	mstl::string	result;

	unsigned size = m_row.size();

	char const* s = comment;
	char const* p = ::strchr(s, '[');

	while (p)
	{
		if (p[1] == '%')
		{
			char const* q = 0;

			switch (p[2])
			{
				case 'c':
					switch (p[3])
					{
						case 'c':
							if ((q = ::match(p + 2, "ccsnt", 5)))
								q = info.parseCorrespondenceChessSent(q);
							break;

						case 'l':
							if ((q = ::match(p + 2, "clk", 3)))
									q = info.parsePlayersClock(q);
							break;

						case 't':
							if ((q = ::match(p + 2, "ct", 2)))
								q = info.parseClockTime(q);
							break;
					}
					break;

				case 'e':
					switch (p[3])
					{
						case 'g':
							if ((q = ::match(p + 2, "egt", 3)))
								q = info.parseElapsedGameTime(q);
							break;

						case 'm':
							if ((q = ::match(p + 2, "emt", 3)))
								q = info.parseElapsedMoveTime(q);
							break;

						case 'v':
							if ((q = ::match(p + 2, "eval", 4)))
								q = ::skipTimeInfo(info.parseEvaluation(q));
							break;
					}
					break;

				case 'm':
					if ((q = ::match(p + 2, "mct", 3)))
						q = info.parseClockTime(q);
					break;

				case 'v':
					if ((q = ::match(p + 2, "vt", 2)))
						q = info.parseVideoTime(q);
					break;
			}

			if (q)
				q = ::skipSpaces(q);

			if (q && *q == ']')
			{
				add(info);
				info.clear();
				result.append(s, p - s);
				s = p = q + 1;

				if (*p == '\0')
					p = 0;
			}
			else
			{
				p += 3;
			}
		}
		else
		{
			p = ::strchr(p + 1, '[');
		}
	}

	bool rc = size < m_row.size();

	if (rc)
	{
		result.append(s, comment.end());
		comment.swap(result);
		comment.trim();
	}

	s = ::skipSpaces(comment);

	if (::seemsToBeMoveInfo(s, comment.end() - 1))
	{
		if (::isalpha(*s))
		{
			// "Crafty: 12:+0.61"
			// "Crafty: 1:40:25"
			// "Rybka Aquarium (0:00:45)"

			char delim = '\0';

			while (::isalnum(*s) || *s == ' ')
				++s;

			if (*s == ':')
			{
				if (*++s == ' ')
					++s;
			}
			else if (*s == '(')
			{
				delim = ')';
				++s;
			}
			else
			{
				return false;
			}

			char const* q = info.parsePlayersClock(s);

			if (!q)
				q = ::skipTimeInfo(info.parseEvaluation(s));

			if (q == 0 || (delim ? q[0] != delim || q[1] : *q))
				return false;

			p = s - 1;
			if (*p == '(')
				--p;
			while (*p == ' ')
				--p;
			++p;
			s = ::skipSpaces(q + (delim == ')'));

			info.setAnalysisEngine(engineList.addEngine(mstl::string(comment.begin(), p)));
			rc = true;
		}
		else if (::seemsToBeEvaluation(s))
		{
			char const* e = ::skipTimeInfo(info.parseEvaluation(s));

			if (e && ::isDelim(::skipSpaces(e)))
			{
				s = e;
				rc = true;
			}
		}
		else if (::isdigit(*s))
		{
			char const* e = info.parsePlayersClock(s);

			if (e && ::isDelim(::skipSpaces(e)))
			{
				s = e;
				rc = true;
			}
		}
		else if (*s == '[')
		{
			// "[Stockfish 1.9.1] 66:M4"

			char const* q = s + 1;

			while (*q != ']')
			{
				if (!*++q)
					return false;
			}

			mstl::string engine(s + 1, q);

			s = ::skipSpaces(q + 1);

			if (!::isdigit(*s))
				return false;

			q = info.parseEvaluation(s);

			if (!q)
				return false;

			info.setAnalysisEngine(engineList.addEngine(engine));
			s = ::skipSpaces(q);
			rc = true;
		}

		if (rc)
		{
			add(info);
			result.append(s, comment.end());
			comment.swap(result);
			comment.trim();
		}
	}

	char const* e = s + comment.size() - 1;

	if (e > comment.c_str())
	{
		if (*e == 's')
		{
			--e;

			if (::isdigit(*e))
			{
				while (e > comment.c_str() && ::isdigit(e[-1]))
					--e;

				if (e == comment.c_str() || e[-1] == ' ')
				{
					comment.erase(e, comment.end());
					comment.trim();
				}
			}
		}
	}

	M_ASSERT(!isEmpty() || result.empty());

	return rc;
}


void
MoveInfoSet::print(EngineList const& engines, mstl::string& result, MoveInfo::Format format) const
{
	char const delim = format == MoveInfo::Text ? ';' : ' ';

	for (unsigned i = 0; i < m_row.size(); ++i)
	{
		if (!m_row[i].isEmpty())
		{
			if (!result.empty() && !result.back() != delim)
				result.append(delim);

			m_row[i].print(engines, result, format);
		}
	}
}


util::crc::checksum_t
MoveInfoSet::computeChecksum(EngineList const& engines, util::crc::checksum_t crc) const
{
	for (unsigned i = 0; i < m_row.size(); ++i)
		crc = m_row[i].computeChecksum(engines, crc);

	return crc;
}

// vi:set ts=3 sw=3:
