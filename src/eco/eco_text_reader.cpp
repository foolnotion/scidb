// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "eco_text_reader.h"
#include "eco_name.h"

#include "db_board.h"
#include "db_move_buffer.h"

#include "m_istream.h"
#include "m_exception.h"
#include "m_bitset.h"
#include "m_assert.h"

#include <string.h>
#include <ctype.h>

using namespace eco;
using namespace db;


__m_no_return
static
void throwInvalidEco(unsigned lineNo, char const* eco)
{
	M_RAISE(	"invalid ECO code '%s' (line %u)",
				mstl::string(eco, eco + mstl::min(7u, strlen(eco))).c_str(), lineNo);
}


static
auto endOfWord(char const* s) -> char const*
{
	while (*s && *s != ' ' && *s != '}')
		++s;

	return s;
}


static
auto nextWord(char const* s) -> char const*
{
	s = endOfWord(s);

	while (*s == ' ')
		++s;

	if (!*s)
		return 0;

	while (isdigit(*s))
		++s;

	if (*s == '.')
		++s;

	while (*s == ' ')
		++s;

	return s;
}


TextReader::TextReader(mstl::istream& strm, unsigned flags)
	:Reader(Extended)
	,m_strm(strm)
	,m_flags(flags)
{
}


auto TextReader::readLine(
	MoveLine& line,
	Transitions& transitions,
	Name& name,
	mstl::string&,
	mstl::string&,
	char&,
	Node*
) -> Id
{
	mstl::string comment;
	mstl::string buf;

	bool skipNextLine = false;

	while (m_strm.getline(buf))
	{
		++m_lineNo;

		if (::isupper(buf[0]))
		{
			if (skipNextLine)
			{
				skipNextLine = false;
			}
			else
			{
				if (buf.size() < 10)
					throwCorrupted();

				char const* s = buf.c_str();

				Id id(s);

				if (id == 0)
					::throwInvalidEco(m_lineNo, s);

				s = ::strchr(s + 8, '"');

				if (!s)
					throwCorrupted();

				unsigned level = 0;

				while (*s == '"')
				{
					if (level >= Name::NumEntries)
						M_RAISE("too many levels in ECO file (line %u)", m_lineNo);

					char const* e = ::strchr(s + 1, '"');

					if (!e)
						M_RAISE("unterminated string in ECO file (line %u)", m_lineNo);

					name.set(level++, mstl::string(s + 1, e));
					char const* t = ::strchr(e + 1, '"');
					s = t ? t : e - 1;
				}

				if (name.size() <= 1)
					M_RAISE("at least two levels needed (line %u)", m_lineNo);

				Board board(Board::standardBoard(variant::Normal));
				Board standardBoard(Board::standardBoard(variant::Normal));

				while ((s = ::nextWord(s + 1)) && ::isalpha(*s))
				{
					Move move = board.parseMove(s, move::MustBeUnambiguous);

					if (!move.isLegal())
					{
						*const_cast<char*>(::endOfWord(s)) = '\0';
						M_RAISE("illegal move '%s' in ECO file (line %u)", s, m_lineNo);
					}

					board.doMove(move);
					line.append(move);
				}

				char paren = s ? *s : 0;

				for ( ; s && (paren == '(' || paren == '['); s = ::nextWord(s + 1), paren = s ? *s : 0)
				{
					Id next(s + 1);

					if (next == 0)
						::throwInvalidEco(m_lineNo, s + 1);

					s = ::nextWord(s + 1);
					if (!s)
						throwCorrupted();

					Move move = board.parseMove(s, move::MustBeUnambiguous);

					if (!move.isLegal())
					{
						*const_cast<char*>(::endOfWord(s)) = '\0';
						M_RAISE("illegal move '%s' in ECO file (line %u)", s, m_lineNo);
					}

					Transition::Type type = (paren == '[') ? Transition::Transposition : Transition::NextMove;
					transitions.push_back(Transition(next, move, type));
				}

				if (s)
					throwCorrupted();

				return id;
			}
		}
		else if ((m_flags & SkipInsertedLines) && ::strncmp(buf, "# Line automatically", 20) == 0)
		{
			skipNextLine = true;
		}

		if (!skipNextLine)
		{
			comment.append('\n');
			comment.append(buf);
		}
	}

	m_epilogue.swap(comment);
	return Id();
}

// vi:set ts=3 sw=3:
