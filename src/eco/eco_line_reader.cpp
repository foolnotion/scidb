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

#include "eco_line_reader.h"
#include "eco_node.h"
#include "eco_name.h"

#include "db_board.h"
#include "db_move_buffer.h"

#include "m_map.h"
#include "m_istream.h"
#include "m_exception.h"
#include "m_assert.h"

#include <ctype.h>
#include <stdlib.h>

using namespace eco;
using namespace db;


template <typename T>
static
auto skipNonSpaces(T* s) -> T*
{
	while (*s && !isspace(*s))
		++s;
	return s;
}


template <typename T>
static
auto skipSpaces(T* s) -> T*
{
	while (isspace(*s))
		++s;
	return s;
}


template <typename T>
static
auto skipComma(T* s) -> T*
{
	if (*s == ',')
		++s;
	return s;
}


template <typename T>
static
auto skipMoveNumber(T* s) -> T*
{
	if (isdigit(*s))
	{
		do
			++s;
		while (isdigit(*s));

		while (*s == '.')
			++s;
	}

	return s;
}


static
auto isComment(char const* s, char const* start) -> bool
{
	return *s == '#' && (s == start || ::isspace(s[-1]));
}


LineReader::LineReader(mstl::istream& strm, unsigned flags)
	:Reader(Line)
	,m_strm(strm)
	,m_flags(flags)
	,m_lineLength(0)
{
}


auto LineReader::readLine(
	MoveLine& line,
	Transitions& transitions,
	Name& name,
	mstl::string& prologue,
	mstl::string& epilogue,
	char& sign,
	Node* root
) -> Id
{
	mstl::string comment(m_comment);
	mstl::string buf;

	while (m_strm.getline(buf))
	{
		Node const* node = root;
		Node const* last = root;

		++m_lineNo;

		char const* movP = buf.c_str();

		if (::isupper(buf[0]) || ::isdigit(buf[0]))
		{
			Id id;
			char const* ecoP = movP;

			if (::isupper(*ecoP))
			{
				char const* ecoP = movP;
				char const* ecoE = ecoP + 1;

				movP = ecoE = ::skipNonSpaces(ecoE);

				if (!(m_flags & Ignore_ECO))
				{
					mstl::string eco(ecoP, ecoE);

					try { id.setup(eco); } catch (...) { M_RAISE("invalid ECO code %s", eco.c_str()); }

					if (m_lastId.basic() > id.basic() && m_lastId != Id("E60"))
						M_RAISE("invalid ECO sequence (line %u)", m_lineNo);

					if (m_lastId.basic() != id.basic())
						m_lineLength = 0;

					m_lastId = id;
				}
			}

			movP = ::skipSpaces(movP);

			if (::strncmp(movP, "without", 7) == 0)
			{
				Board board(m_board);
				MoveLine line;

				movP = ::skipSpaces(movP + 7);

				while (*movP)
				{
					movP = ::skipSpaces(::skipMoveNumber(movP));

					Move m = board.parseMove(movP, move::MustBeUnambiguous);

					if (!m.isLegal() || m.isNull())
						M_RAISE("illegal move in ECO file (line %u)", m_lineNo);

					movP = ::skipSpaces(::skipNonSpaces(movP));

					board.doMove(m);
					line.append(m);
				}

				root->setExclusion(Id(id.basic(), 0), line);
			}
			else if (::strncmp(movP, "exclude", 7) == 0)
			{
				movP = ::skipSpaces(movP + 7);

				while (*movP)
				{
					if (movP + 3 > buf.end())
						M_RAISE("invalid ECO code %s (line %u)", movP, m_lineNo);

					mstl::string eco(movP, movP + 3);
					Id from, to;

					try { from.setup(eco); }
					catch (...) { M_RAISE("invalid ECO code %s (line %u)", eco.c_str(), m_lineNo); }

					if (movP[3] == '-')
					{
						if (movP + 6 > buf.end())
							M_RAISE("invalid ECO code %s (line %u)", movP, m_lineNo);

						movP += 4;

						eco[1] = movP[0];
						eco[2] = movP[1];

						try
						{
							to.setup(eco);
						}
						catch (...)
						{
							eco.assign(movP, movP + 6);
							M_RAISE("invalid ECO code %s (line %u)", eco.c_str(), m_lineNo);
						}
					}
					else
					{
						to = from;
					}

					for (Id::Code code = from.basic(); code <= to.basic(); ++code)
					{
						if (code == id.basic())
							M_RAISE("cannot forbid transition to self (line %u)", m_lineNo);

						root->setUnwantedTransposition(id, Id(code, 0));
					}

					movP = ::skipSpaces(::skipComma(::skipSpaces(movP + 3)));
				}
			}
			else
			{
				char const* movE = movP;

				for ( ; *movE && *movE != '"' && !::isComment(movE, buf.c_str()); ++movE)
					continue;

				char const* namP = movE;

				while (::isspace(movE[-1]))
					--movE;

				m_board = Board::standardBoard(variant::Normal);

				bool skip = false;
				bool isComment = false;

				while (movP < movE)
				{
					if (movP[0] == '-' && movP[1] == '-' && movP[2] == '-')
					{
						if (movP[3] == '-')
						{
							movP = ::skipSpaces(movP + 4);
							root->addOmission(Id(id.basic(), 0), line, m_lineNo);
							skip = true;
							break;
						}
						if (movP[3] == '>')
						{
							movP = ::skipSpaces(movP + 4);

							if (movP + 3 > buf.end())
								M_RAISE("invalid ECO code %s (line %u)", movP, m_lineNo);

							mstl::string eco(movP, movP + 3);
							Id to;

							try { to.setup(eco); }
							catch (...) { M_RAISE("invalid ECO code %s (line %u)", eco.c_str(), m_lineNo); }

							movP = ::skipSpaces(movP + 3);
							root->addException(Id(id.basic(), 0), line, to, m_lineNo);
							sign = Skip;
							m_comment.clear();
							return id;
						}
					}
					if (movP[0] == '-' && movP[1] == '>')
					{
						sign = Skip;
						m_comment.clear();
						return id;
					}
					if (movP[0] == '+' && movP[1] == '+')
					{
						movP = ::skipSpaces(movP + 2);
						break;
					}
					if (movP[0] == '!' && movP[1] == '!')
					{
						movP = ::skipSpaces(movP + 2);
						isComment = true;
						sign = PreParsed;
						break;
					}
					if (movP[0] == '*' && movP[1] == '*')
					{
						movP = ::skipSpaces(movP + 2);
						sign = Equal;
						break;
					}

					movP = ::skipSpaces(::skipMoveNumber(movP));

					Move m = m_board.parseMove(movP, move::MustBeUnambiguous);

					if (!m.isLegal() || m.isNull())
						M_RAISE("illegal move in ECO file (line %u)", m_lineNo);

					m_board.prepareForPrint(m, Board::ExternalRepresentation);
					line.append(m);

					if (last && (last = last->find(m)) && last->ref() != Name::Invalid)
						node = last;

					movP = ::skipSpaces(::skipNonSpaces(movP));
					m_board.doMove(m);
				}

				if (!skip)
				{
					if (m_lineLength == 0 || line.size() == m_lineLength)
					{
						root->setRule(Id(id.basic(), 0), line);
						m_lineLength = line.size();
					}

					if (m_flags & Ignore_ECO)
						id = m_lastId = node->id();

					mstl::string longName;
					mstl::string shortName;

					if (*namP == '"')
					{
						unsigned		level	= 0;
						char const*	namE	= ++namP + 1;

						for ( ; *namE != '"'; ++namE)
						{
							if (!*namE)
								throwCorrupted();
						}

						longName.assign(namP, namE - namP);
						namP = namE + 1;

						if (longName.empty())
							M_RAISE("empty string (line %u)", m_lineNo);

						namP = ::skipSpaces(namP);

						if (*namP == '"')
						{
							char const* namE = ++namP + 1;

							for ( ; *namE != '"'; ++namE)
							{
								if (!*namE)
									throwCorrupted();
							}

							shortName.assign(namP, namE - namP);
							namP = namE + 1;

							if (shortName.empty())
								M_RAISE("empty string (line %u)", m_lineNo);
						}

						namP = ::skipSpaces(namP);

						if (*namP != '{')
							 M_RAISE("ECO file corrupted: level expected (line %u)", m_lineNo);

						level = ::strtoul(namP + 1, const_cast<char**>(&namE), 10);

						if (*namE != '}')
							M_RAISE("invalid level specification (line %u)", m_lineNo);

						movP = ::skipSpaces(namE + 1);

						if (level == 0)
						{
							name.set(0, longName);
							name.set(1, shortName);
						}
						else if (level >= Name::NumEntries - 1)
						{
							M_RAISE("level %u too high (line %u)", level, m_lineNo);
						}
						else
						{
							if (!shortName.empty())
								M_RAISE("unexpected short name (line %u)", m_lineNo);

							if (!node->isRoot())
								name = node->name();

							if (name.isEmpty(level))
								M_RAISE("gap before level %u (line %u)", level, m_lineNo);

							name.set(level + 1, longName);
						}
					}

					if (movP[0] == '#' && movP[1])
					{
						if (movP[2] == '\0')
							sign = movP[1];
						else
							epilogue.assign(movP + 2);
					}

					if (isComment)
					{
						m_comment.swap(comment);
						m_comment.append(buf);
						m_comment.append('\n');
					}
					else
					{
						prologue.swap(comment);
						m_comment.clear();
					}

					return id;
				}
			}
		}

		comment.append(buf);
		comment.append('\n');
		line.clear();
	}

	m_epilogue.swap(comment);
	return Id();
}

// vi:set ts=3 sw=3:
