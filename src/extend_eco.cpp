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
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_board.h"
#include "db_move_list.h"
#include "db_eco.h"

#include "u_base.h"

#include "m_assert.h"
#include "m_string.h"
#include "m_map.h"
#include "m_set.h"
#include "m_ifstream.h"
#include "m_bitset.h"
#include "m_pair.h"
#include "m_algorithm.h"
#include "m_chunk_allocator.h"

#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>


extern "C" { struct Tcl_Interp; }
namespace tcl { Tcl_Interp* interp() { return 0; } }

using namespace db;


typedef mstl::vector<uint32_t> Line;
typedef mstl::chunk_allocator<char,true> Allocator;

struct Name
{
	mstl::string s[6];
};

struct NamePair
{
	unsigned			level;
	unsigned			plyNumber;
	mstl::string	longName;
	mstl::string	shortName;

	NamePair() :level(0) {}
	NamePair(unsigned l, unsigned p, mstl::string const& ln, mstl::string const& sn)
		: level(l), plyNumber(p), longName(ln), shortName(sn) {}
};

struct Position
{
	Eco		eco;
	Line		line;
	unsigned	size;

	Position(Eco e, Line l, unsigned s) :eco(e), line(l), size(s) {}
};

namespace mstl { template <> struct is_pod<Position> { enum { value = 1 }; }; }

typedef mstl::map<uint64_t,Eco> Lookup;
typedef mstl::map<uint64_t,Position*> LineMap;
typedef mstl::map<uint64_t,NamePair> NameMap;
typedef mstl::vector<mstl::bitset*> TransSet;
typedef mstl::vector<uint32_t> LineNumbers;
typedef mstl::vector<Line> Lines;
typedef mstl::vector<Name> Names;

Lookup lookup;
Lines lines;
Names names;
LineNumbers lineNumbers;
Allocator stringAllocator(8192);
mstl::bitset newLine(Eco::Max_Code + 1);
bool checkTransitions = false;
TransSet transitions;


__attribute__((__format__(__printf__, 1, 2)))
void
error(char const* fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	vfprintf(stderr, fmt, args);
	fprintf(stderr, "\n");
	va_end(args);

	exit(1);
}


int
cmpMove(void const* lhs, void const* rhs)
{
	return *static_cast<uint32_t const*>(lhs) - *static_cast<uint32_t const*>(rhs);
}


bool
equal(Eco lhs, Eco rhs, unsigned size)
{
	uint32_t line1[size];
	uint32_t line2[size];

	memcpy(line1, lines[lhs].begin(), size*sizeof(uint32_t));
	memcpy(line2, lines[rhs].begin(), size*sizeof(uint32_t));

	qsort(line1, size, sizeof(uint32_t), cmpMove);
	qsort(line2, size, sizeof(uint32_t), cmpMove);

	return memcmp(line1, line2, size*sizeof(uint32_t)) == 0;
}


void
checkCriticalLine(Eco eco, unsigned size)
{
	Line const& line = lines[eco];

	M_ASSERT(size <= line.size());

	mstl::bitset used(1 << 16);

	for (unsigned i = 0; i < size; ++i)
	{
		if (used.test(line[i] & 0xffff))
		{
			fprintf(	stderr,
						"warning: line %u (%s) should contain position repetition\n",
						lineNumbers[eco],
						eco.asString().c_str());
		}

		used.set(line[i] & 0xffff);
	}
}


void
printMove(unsigned ply, Move const& move)
{
	mstl::string s;
	printf(" ");
	if ((ply & 1) == 0)
		printf("%u.", (ply + 2) >> 1);
	printf("%s", move.printSan(s).c_str());
}


void
printMoves(MoveList const& moves)
{
	for (unsigned k = 0; k < moves.size(); ++k)
		printMove(k, moves[k]);
}


void
printLine(Line const& line)
{
	for (unsigned k = 0; k < line.size(); ++k)
	{
		Move m(line[k]);

		fprintf(stderr, "%s%s", sq::printAlgebraic(m.from()), sq::printAlgebraic(m.to()));
		fprintf(stderr, k == line.size() - 1 ? "\n" : " ");
	}
}


void
transform(uint32_t const* line, MoveList& moves, unsigned size)
{
	moves.clear();

	for (unsigned k = 0; k < size; ++k)
		moves.append(Move(line[k]));
}


void
extend()
{
	mstl::string prevEco("A00");

	if (checkTransitions)
		transitions.resize(Eco::Max_Code + 1);

	for (unsigned i = 0; i <= Eco::Max_Code; ++i)
	{
		if (i == 1 || !lines[i].empty())
		{
			mstl::string eco(Eco(i).asString());
			mstl::string shortEco(eco.c_str(), 3);

			if (shortEco != prevEco)
			{
				printf("\n");
				prevEco = shortEco;
			}

			if (newLine.test(i))
				printf("# NEW\n");
			printf(Eco(i).asString().c_str());

			for (unsigned k = 0; k < 6 && !names[i].s[k].empty(); ++k)
				printf(" \"%s\"", names[i].s[k].c_str());

			MoveList moves;
			MoveList more;

			Board board(Board::standardBoard());

			transform(lines[i].begin(), moves, lines[i].size());

			for (unsigned k = 0; k < moves.size(); ++k)
			{
				board.prepareForPrint(moves[k], variant::Normal);
				board.doMove(moves[k], variant::Normal);
			}

			printMoves(moves);

			if (!board.gameIsOver(variant::Normal))
				board.generateMoves(variant::Normal, more);

			for (unsigned k = 0; k < more.size(); ++k)
			{
				__attribute__((unused)) uint64_t h = board.hashNoEP();

				board.prepareUndo(more[k]);
				board.prepareForPrint(more[k], variant::Normal);
				board.doMove(more[k], variant::Normal);

				if (board.isLegal())
				{
					Lookup::const_iterator e = lookup.find(board.hashNoEP());

					if (e != lookup.end())
					{
						if (equal(Eco(i), e->second, lines[i].size()))
						{
							printf(" (%s)", e->second.asString().c_str());
						}
						else
						{
							checkCriticalLine(Eco(i), board.plyNumber() - 1);
							printf(" [%s]", e->second.asString().c_str());
						}

						printMove(moves.size(), more[k]);

						if (checkTransitions)
						{
							if (transitions[i] == 0)
								transitions[i] = new mstl::bitset(Eco::Max_Code + 1);
							transitions[i]->set(e->second);
						}
					}
				}

				board.undoMove(more[k], variant::Normal);
				M_ASSERT(board.hashNoEP() == h);
			}

			printf("\n");
			fflush(stdout);
		}
	}
}


bool
prepare()
{
	typedef mstl::map<uint64_t,mstl::pair<Eco,uint16_t> > Bookmark;

	Bookmark			bookmark;
	LineMap			position;
	mstl::bitset	exists(Eco::Max_Code + 1);

	lookup[Board::standardBoard().hashNoEP()] = Eco(1);

	for (unsigned i = 0; i <= Eco::Max_Code; ++i)
	{
		if (!lines[i].empty())
		{
			Board board(Board::standardBoard());
			Line const& line = lines[i];

			board.doMove(Move(line[0]), variant::Normal);

			for (unsigned k = 1; k < line.size(); ++k)
			{
				board.doMove(Move(line[k]), variant::Normal);

				uint64_t hash = board.hashNoEP();
				LineMap::const_iterator p = position.find(hash);

				if (p == position.end())
				{
					position[hash] = new Position(Eco(i), Line(line, k + 1), line.size());
				}
				else if (k < p->second->line.size())
				{
					if (	k == line.size() - 1
						&& k == p->second->line.size() - 1
						&& line.size() == p->second->size)
					{
						error("duplicate entries: %u (%s) - %u (%s)",
								lineNumbers[p->second->eco],
								p->second->eco.asString().c_str(),
								lineNumbers[i],
								Eco(i).asString().c_str());
					}
					else if (	!(		k == mstl::min(line.size(), p->second->line.size()) - 1
										&& mstl::abs(int(line.size()) - int(p->second->line.size())) == 1)
								&& !line.equal(p->second->line, k + 1))
					{
						error("ambigous entries: %u (%s) - %u (%s)",
								lineNumbers[p->second->eco],
								p->second->eco.asString().c_str(),
								lineNumbers[i],
								Eco(i).asString().c_str());
					}
				}
			}

			lookup[board.hashNoEP()] = Eco(i);
		}
	}

	lookup.clear();
	bookmark[Board::standardBoard().hashNoEP()] = mstl::make_pair(Eco(1), uint16_t(0));
	lookup[Board::standardBoard().hashNoEP()] = Eco(1);

	for (unsigned i = 0; i <= Eco::Max_Code; ++i)
	{
		if (!lines[i].empty())
		{
			Bookmark::const_iterator last = 0;
			Board board(Board::standardBoard());
			MoveList moves;
			Line const& line = lines[i];

			for (unsigned k = 0; k < line.size(); ++k)
			{
				Move move = Move(line[k]);

				moves.append(move);
				board.prepareForPrint(move, variant::Normal);
				board.doMove(move, variant::Normal);

				if (k + 1 < line.size())
				{
					uint64_t hash = board.hashNoEP();
					Bookmark::const_iterator b = bookmark.find(hash);

					if (b == bookmark.end())
					{
						bookmark[hash] = mstl::make_pair(Eco(i), uint16_t(Move(line[k + 1]).index()));
					}
					else if (b->second.second == 0)
					{
						last = b;
					}
					else if (	last
								&& !exists.test_and_set(last->second.first)
								&& b->second.second != Move(line[k + 1]).index()
								&& position.find(hash) == position.end())
					{
						uint32_t code = last->second.first;
						uint32_t next = last->second.first + 1;

						if (Eco(next).basic() != Eco(code).basic())
							error("base %s is full", Eco(Eco(code).basic()).asString().c_str());

						while (Eco(next + 1).basic() == Eco(code).basic())
							++next;

						while (next > code && lines[next].size() == 0)
							--next;

						for ( ; next > code; --next)
						{
							lines[next + 1] = lines[next];
							names[next + 1] = names[next];
						}

						code += 1;

						lines[code].clear();
						for (unsigned j = 0; j < moves.size(); ++j)
							lines[code].push_back(moves[j].data());
//						printLine(lines[code]);

						names[code] = names[last->second.first];
						newLine.set(code);
						fprintf(	stderr,
									"inserting new line: %u (%s)\n",
									lineNumbers[code],
									Eco(code).asString().c_str());
						lookup.clear();
						return false;
					}
				}

				uint64_t hash = board.hashNoEP();
				Lookup::const_iterator e = lookup.find(hash);

				if (e != lookup.end() && !equal(Eco(i), e->second, k + 1))
				{
					error("Hash clash: %u (%s) - %u (%s)",
							lineNumbers[i],
							Eco(i).asString().c_str(),
							lineNumbers[e->second],
							e->second.asString().c_str());
				}

				if (e == lookup.end() || lines[e->second].size() > line.size())
					lookup.replace(Lookup::value_type(hash, Eco(i)));
			}

			bookmark[board.hashNoEP()] = mstl::make_pair(Eco(i), uint16_t(0));
		}
	}

	return true;
}


void
checkLines()
{
	typedef mstl::vector<Eco> List;
	typedef mstl::map<Eco,List> Map;

	if (!checkTransitions)
		return;

	char c = '\0';

	for (unsigned i = 0; i <= Eco::Max_Code; ++i)
	{
		mstl::bitset* ti = transitions[i];

		if (ti)
		{
			char d = Eco(i).asString().front();

			if (c != d)
			{
				fprintf(stderr, "extending %c...\n", d);
				c = d;
			}

			for (unsigned k = 0; k <= Eco::Max_Code; ++k)
			{
				mstl::bitset* tk = transitions[k];

				if (tk)
				{
					if (ti->test(k))
					{
						for (unsigned j = 0; j <= Eco::Max_Code; ++j)
						{
							if (tk->test(j))
								ti->set(j);
						}
					}
					else if (tk->test(i))
					{
						for (unsigned j = 0; j <= Eco::Max_Code; ++j)
						{
							if (ti->test(j))
								tk->set(j);
						}
					}
				}
			}
		}
	}

	Map map;

	for (unsigned i = 0; i <= Eco::Max_Code; ++i)
	{
		mstl::bitset const* ti = transitions[i];

		if (ti)
		{
			char d = Eco(i).asString().front();

			if (c != d)
			{
				fprintf(stderr, "checking %c....\n", d);
				c = d;
			}

			for (unsigned k = 0; k <= Eco::Max_Code; ++k)
			{
				if (i != k)
				{
					mstl::bitset const* tk = transitions[k];

					if (tk)
					{
						if (	!ti->test(k)
							&& !tk->test(i)
							&& equal(Eco(i), Eco(k), mstl::min(lines[i].size(), lines[k].size())))
						{
							if (lines[i].size() < lines[k].size())
								map[Eco(i)].push_back(Eco(k));
							else
								map[Eco(k)].push_back(Eco(i));
						}
					}
				}
			}
		}
	}

	for (Map::iterator i = map.begin(); i != map.end(); ++i)
	{
		List& list = i->second;

		for (unsigned k = 0; k < list.size(); ++k)
		{
			if (list[k])
			{
				for (unsigned j = 0; j < list.size(); ++j)
				{
					if (list[j])
					{
						mstl::bitset const* t = transitions[list[k]];

						if (t && t->test(list[j]))
							list[j] = Eco();
					}
				}
			}
		}
	}

	for (Map::iterator i = map.begin(); i != map.end(); ++i)
	{
		Eco eco = i->first;

		if (eco)
		{
			List& list = i->second;

			for (unsigned k = 0; k < list.size(); ++k)
			{
				if (list[k])
				{
					for (Map::iterator j = map.begin(); j != map.end(); ++j)
					{
						mstl::bitset const* t = transitions[eco];

						if (	j->first
							&& t && t->test(j->first)
							&& mstl::find(j->second.begin(), j->second.end(), list[k]))
						{
							list[k] = Eco();
						}
					}
				}
			}
		}
	}

	for (Map::iterator i = map.begin(); i != map.end(); ++i)
	{
		Eco eco = i->first;

		if (eco)
		{
			List& list = i->second;

			mstl::bitset set(Eco::Max_Code + 1);

			for (unsigned k = 0; k < list.size(); ++k)
			{
				if (list[k] && !set.test(list[k]))
				{
					fprintf(	stderr,
								"missing transition: %u (%s) -> %u (%s)\n",
								lineNumbers[eco],
								eco.asString().c_str(),
								lineNumbers[list[k]],
								list[k].asString().c_str());
					set.set(list[k]);
				}
			}
		}
	}
}


void
parse(char const* filename)
{
	lines.resize(Eco::Max_Code + 1);
	names.resize(Eco::Max_Code + 1);
	lineNumbers.resize(Eco::Max_Code + 1);

	mstl::ifstream stream(filename);

	if (!stream)
		error("cannot open '%s'", filename);

	mstl::string	buf;
	unsigned			lineNo = 0;
	unsigned			count = 0;
	Eco				lastCode;
	Name				currentName;
	unsigned			pos[6];
	uint16_t			lastMoves[6];
	NameMap			nameLookup;

	::memset(pos, 0, sizeof(pos));
	::memset(lastMoves, 0, sizeof(lastMoves));

	while (1)
	{
		if (!stream.getline(buf))
			return;

		++lineNo;

		if (::isupper(buf[0]))
		{
			char const* ecoP = buf.c_str();
			char const* ecoE = ecoP + 1;

			while (!::isspace(*ecoE))
			{
				if (!*ecoE)
					error("ECO file corrupted (line %u)", lineNo);

				++ecoE;
			}

			char const* movP = ecoE;

			while (::isspace(*movP))
				++movP;

			char const* movE = movP;

			for ( ; *movE != '"' && *movE; ++movE)
				continue;

			char const* namP = movE;

			while (::isspace(movE[-1]))
				--movE;

			mstl::string eco(ecoP, ecoE);
			Eco ecoCode;

			try
			{
				ecoCode.setup(eco);
			}
			catch (...)
			{
				error("invalid ECO code %s", eco.c_str());
			}

			if (lastCode.basic() == ecoCode.basic())
			{
				ecoCode = Eco(lastCode.code() + 1);

				if (ecoCode.basic() != lastCode.basic())
				{
					error("too many lines in %s (line %u)",
							lastCode.asString().c_str(),
							lineNo);
				}
			}

			lineNumbers[ecoCode] = lineNo;
			lastCode = ecoCode;

			Board board(Board::standardBoard());
			MoveList	moves;
			Line& line = lines[ecoCode];

			while (movP < movE)
			{
				if (board.whiteToMove())
				{
					while (::isdigit(*movP))
						++movP;

					if (*movP++ != '.')
						error("ECO file corrupted (line %u)", lineNo);

					while (::isspace(*movP))
						++movP;
				}

				Move m = board.parseMove(movP, variant::Normal);

				if (!m.isLegal())
					error("illegal move in ECO file (line %u)", lineNo);

				M_ASSERT(board.isValidMove(m, variant::Normal));

				++count;
				board.doMove(m, variant::Normal);
				moves.append(m);
				line.push_back(m.data());

				while (*movP && !::isspace(*movP))
					++movP;
				while (::isspace(*movP))
					++movP;
			}

			mstl::string longName;
			mstl::string shortName;

			bool	clearNames	= true;
			int	maxLevel		= -1;

			for (unsigned i = 0; i < 6; ++i)
			{
				if (	pos[i] > board.plyNumber()
					|| (	!moves.isEmpty()
						&& pos[i] == board.plyNumber()
						&& lastMoves[i] != moves.back().index()))
				{
					currentName.s[i].clear();
					pos[i] = 0;
					lastMoves[i] = 0;
				}
			}

			if (*namP == '"')
			{
				unsigned		level	= 0;
				char const*	namE	= ++namP + 1;

				for ( ; *namE != '"'; ++namE)
				{
					if (!*namE)
						error("ECO file corrupted (line %u)", lineNo);
				}

				char* s = stringAllocator.alloc(namE - namP + 1);
				memcpy(s, namP, namE - namP);
				longName.hook(s);
				namP = namE + 1;

				if (longName.empty())
					error("empty string (line %u)", lineNo);

				while (::isspace(*namP))
					++namP;

				if (*namP == '"')
				{
					char const* namE = ++namP + 1;

					for ( ; *namE != '"'; ++namE)
					{
						if (!*namE)
							error("ECO file corrupted (line %u)", lineNo);
					}

					char* s = stringAllocator.alloc(namE - namP + 1);
					memcpy(s, namP, namE - namP);
					shortName.hook(s);
					namP = namE + 1;

					if (shortName.empty())
						error("empty string (line %u)", lineNo);
				}

				while (::isspace(*namP))
					++namP;

				if (*namP != '{')
					 error("ECO file corrupted: level expected (line %u)", lineNo);

				level = ::strtoul(namP + 1, const_cast<char**>(&namE), 10);

				if (*namE != '}')
					error("invalid level specification (line %u)", lineNo);
				if (level > 4)
					error("level too high  (line %u)", lineNo);
				if (level > 0 && !shortName.empty())
					error("short names allowed only for level 0 (line %u)", lineNo);

				if (clearNames)
				{
					for (unsigned i = level + 1; i < 6; ++i)
					{
						currentName.s[i].clear();
						pos[i] = 0;
						lastMoves[i] = 0;
					}

					clearNames = false;
				}

				if (level == 0 && shortName.empty() && !longName.empty())
					shortName = longName;

				currentName.s[++level] = longName;
				pos[level] = board.plyNumber();
				nameLookup[board.hashNoEP()] = NamePair(level, board.plyNumber(), longName, shortName);
				if (!moves.isEmpty())
					lastMoves[level] = moves.back();
				maxLevel = mstl::max(int(level), maxLevel);

				if (!shortName.empty())
				{
					currentName.s[0] = shortName;
					pos[0] = board.plyNumber();
					if (!moves.isEmpty())
						lastMoves[0] = moves.back();
				}
			}

			board = Board::standardBoard();

			for (unsigned i = 0; i < moves.size(); ++i)
			{
				board.doMove(moves[i], variant::Normal);

				NameMap::iterator np = nameLookup.find(board.hashNoEP());

				if (np != nameLookup.end())
				{
					NamePair& pair = np->second;

					if ((maxLevel == -1 || int(pair.level) < maxLevel) && pair.plyNumber <= moves.size())
					{
						unsigned level = pair.level;

						currentName.s[level] = pair.longName;
						pos[level] = board.plyNumber();
						lastMoves[level] = moves[i].index();
						if (!pair.shortName.empty())
						{
							currentName.s[0] = pair.shortName;
							pos[0] = board.plyNumber();
							lastMoves[0] = moves[i].index();
						}

						for (++level; level < 6; ++level)
						{
							if (int(level) != maxLevel)
							{
								currentName.s[level].clear();
								if (level == 1)
									currentName.s[0].clear();
							}
						}
					}
				}
			}

			names[ecoCode] = currentName;

			{
				int idx = 5;

				while (idx >= 0 && currentName.s[idx].empty())
					--idx;
				while (idx >= 0 && !currentName.s[idx].empty())
					--idx;

				if (idx >= 0)
				{
					error("gap before level %d (line %u, eco %s)",
							idx,
							lineNo,
							ecoCode.asString().c_str());
				}
			}
		}
	}
}


int
main(int argc, char const* argv[])
{
	if (argc < 2 || 3 < argc)
	{
		fprintf(stderr, "Usage: %s [--check] <eco-file>\n", argv[0]);
		return -1;
	}

	if (argc == 3)
	{
		if (::strcmp(argv[1], "--check") == 0)
		{
			checkTransitions = true;
		}
		else
		{
			fprintf(stderr, "Usage: %s [--check] <eco-file>\n", argv[0]);
			return -1;
		}
	}

	try
	{
		parse(argv[argc - 1]);

		while (!prepare())
			continue;

		extend();
		checkLines();
	}
	catch (mstl::exception const& exc)
	{
		fflush(stdout);
		fprintf(stderr, "\n%s\n", exc.what());
		exit(1);
	}

	return 0;
}

// vi:set ts=3 sw=3:
