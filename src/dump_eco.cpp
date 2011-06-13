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
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "db_board.h"
#include "db_move_list.h"
#include "db_line.h"
#include "db_eco.h"
#include "db_eco_table.h"

#include "si3_stored_line.h"

#include "u_byte_stream.h"

#include "m_ifstream.h"
#include "m_ofstream.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_exception.h"
#include "m_map.h"
#include "m_bitset.h"
#include "m_hash.h"

#include <string.h>
#include <stdio.h>
#include <ctype.h>

using namespace db;


enum { Max_Move_Length = 60 };


typedef util::ByteStream::uint24_t uint24_t;

static unsigned countCodes = 0;
static unsigned countNodes = 0;
static unsigned countChars = 0;
static unsigned countMoves = 0;
static unsigned countBranches = 0;

static mstl::vector<mstl::string> strings;


static char const*
endOfWord(char const* s)
{
	while (*s && *s != ' ')
		++s;

	return s;
}


static char const*
nextWord(char const* s)
{
	s = endOfWord(s);

	while (*s == ' ')
		++s;

	if (!*s)
		return 0;

	while (::isdigit(*s))
		++s;

	if (*s == '.')
		++s;

	while (*s == ' ')
		++s;

	return s;
}


__attribute__((noreturn))
static void
throwCorrupted(unsigned lineNo)
{
	M_RAISE("ECO file corrupted (line %u)", lineNo);
}


__attribute__((noreturn))
static void
throwInvalidEco(unsigned lineNo, char const* eco)
{
	M_RAISE(	"invalid ECO code '%s' (line %u)",
				mstl::string(eco, eco + mstl::min(7u, strlen(eco))).c_str(), lineNo);
}


class Name
{
public:

	static unsigned const Invalid = unsigned(-1);

	Name() :m_size(0) { init(); }
	Name(char const* s) :m_size(0) { init(); set(0, s); }

	unsigned size() const { return m_size; }
	unsigned ref(unsigned level) const;

	void set(unsigned level, mstl::string const& s);

	mstl::string const& str(unsigned level) const { return strings[ref(level)]; }

private:

	void init();

	unsigned m_ref[6];
	unsigned m_size;

	static mstl::hash<mstl::string,unsigned> m_hash;
};

mstl::hash<mstl::string,unsigned> Name::m_hash(4000);


void
Name::set(unsigned level, mstl::string const& s)
{
	M_ASSERT(level < U_NUMBER_OF(m_ref));
	M_ASSERT(m_ref[level] == Invalid);
	M_ASSERT(s.size() < 256);

	if (level && m_ref[level - 1] == Invalid)
		M_RAISE("level %u too high (%s)", level, s.c_str());

	unsigned n = m_hash.find_or_insert(s, strings.size());

	if (n == strings.size())
	{
		strings.push_back(s);
		countChars += s.size();
	}

	m_ref[level] = n;
	m_size = mstl::max(m_size, level + 1);
}


inline
unsigned
Name::ref(unsigned level) const
{
	M_ASSERT(level < size());
	M_ASSERT(m_ref[level] != Invalid);

	return m_ref[level];
}


void
Name::init()
{
	for (unsigned i = 0; i < U_NUMBER_OF(m_ref); ++i)
		m_ref[i] = Invalid;
}


class StoredLine
{
public:

	struct Successor
	{
		uint16_t		move;
		StoredLine*	node;
	};

	typedef mstl::vector<Successor> Successors;

	StoredLine();
	StoredLine(Eco key, Eco opening);

	unsigned index() const;
	Eco key() const;
	Eco opening() const;
	Successors const& successors() const;

	StoredLine* addSuccessor(uint16_t move, Eco key, Eco opening);
	void setIndex(unsigned index);
	void setKey(Eco key, Eco opening);

	static unsigned countNodes();
	static unsigned countBranches();

private:

	typedef mstl::hash<uint64_t,StoredLine*> Set;

	unsigned		m_index;
	Eco			m_key;
	Eco			m_opening;
	Successors	m_successors;

	static unsigned m_countNodes;
	static unsigned m_countBranches;

	static Set m_set;
};

unsigned StoredLine::m_countNodes = 0;
unsigned StoredLine::m_countBranches = 0;
StoredLine::Set StoredLine::m_set;


StoredLine::StoredLine() :m_index(0) { ++m_countNodes; }

Eco StoredLine::key() const { return m_key; }
Eco StoredLine::opening() const { return m_opening; }
unsigned StoredLine::index() const { return m_index; }
StoredLine::Successors const& StoredLine::successors() const { return m_successors; }
unsigned StoredLine::countNodes() { return m_countNodes; }
unsigned StoredLine::countBranches() { return m_countBranches; }

void StoredLine::setIndex(unsigned index) { m_index = index; }
void StoredLine::setKey(Eco key, Eco opening) { m_key = key; m_opening = opening; }


StoredLine::StoredLine(Eco key, Eco opening)
	:m_index(0)
	,m_key(key)
	,m_opening(opening)
{
	++m_countNodes;
}


StoredLine*
StoredLine::addSuccessor(uint16_t move, Eco key, Eco opening)
{
	for (unsigned i = 0; i < m_successors.size(); ++i)
	{
		if (m_successors[i].move == move)
			return m_successors[i].node;
	}

	uint64_t hash = uint64_t(key) | (uint64_t(opening) << Eco::Bit_Size_Per_Subcode);
	StoredLine*& i = m_set.find_or_insert(hash, 0);

	if (i == 0)
	{
		++m_countBranches;
		m_successors.push_back();
		m_successors.back().move = move;
		m_successors.back().node = new StoredLine(key, opening);
		i = m_successors.back().node;
	}

	return i;
}


class Node
{
public:

	typedef board::Position Position;

	Node(Eco eco, Position const& position, Line const& line);
	Node(Eco eco, Name const* name, unsigned length, Position const& position, Line const& line);

	Node* find(uint16_t move) const;

	struct Successor
	{
		Successor();
		Successor(uint16_t m, Node* n, bool isTrans);

		uint16_t	move;
		uint8_t	transposition;
		uint8_t	weight;
		Node*		node;
	};

	typedef mstl::vector<Successor> Successors;

	bool alreadyDone() const;
	bool isEqual(Position const& position) const;
	bool isStoredLineKey() const;

	unsigned countTranspositionDepth() const;

	void done();
	void reset();

	Eco eco() const;
	Line const& line() const;
	Name const& name() const;
	Name const* nameRef() const;
	unsigned ref(unsigned level) const;
	mstl::string const& name(unsigned n) const;
	unsigned length() const;
	Successors const& successors() const;
	Successors& successors();

	void setup(Name const* name, Eco eco);
	void setup(Eco eco, Name const* name, unsigned length);
	void setNode(uint16_t move, Node* node);
	void setIsStoredLineKey();
	void sort();

private:

	Eco				m_eco;
	unsigned			m_length;
	uint16_t			m_linebuf[Max_Move_Length];
	Line				m_line;
	Name const*		m_name;
	Successors		m_successors;
	bool				m_isStoredLineKey;
	mutable bool	m_done;
	Position			m_position;
};


struct Resolve
{
	Node*		node;
	uint16_t	move;
	Eco		eco;
	Board		board;

	Resolve(Node* n, uint16_t m, Eco code, Board const& b) : node(n), move(m), eco(code), board(b) {}
};


typedef mstl::map<uint64_t,Node*> Lookup;

Lookup lookup;


namespace mstl {

template <typename T> struct is_pod;
template <> struct is_pod< ::Resolve> { enum { value = 1 }; };

} // namespace mstl

Eco Node::eco() const										{ return m_eco; }
Name const& Node::name() const							{ M_ASSERT(m_name); return *m_name; }
Name const* Node::nameRef() const						{ return m_name; }
mstl::string const& Node::name(unsigned n) const	{ M_ASSERT(m_name); return m_name->str(n); }
unsigned Node::ref(unsigned n) const					{ M_ASSERT(m_name); return m_name->ref(n); }
unsigned Node::length() const								{ return m_length; }
Line const& Node::line() const							{ return m_line; }
Node::Successors const& Node::successors() const	{ return m_successors; }
Node::Successors& Node::successors()					{ return m_successors; }


Node::Successor::Successor()
	:move(0)
	,transposition(0)
	,weight(0)
	,node(0)
{
}


Node::Successor::Successor(uint16_t m, Node* n, bool isTrans)
	:move(m)
	,transposition(isTrans)
	,weight(0)
	,node(n)
{
}


Node::Node(Eco eco, Position const& position, Line const& line)
	:m_eco(eco)
	,m_length(0)
	,m_line(m_linebuf)
	,m_isStoredLineKey(false)
	,m_done(false)
	,m_position(position)
{
	++countNodes;

	::memcpy(m_linebuf, line.moves, line.length*sizeof(line.moves[0]));
	m_line.length = line.length;
}


Node::Node(Eco eco, Name const* name, unsigned length, Position const& position, Line const& line)
	:m_eco(eco)
	,m_length(length)
	,m_line(m_linebuf)
	,m_name(name)
	,m_isStoredLineKey(false)
	,m_done(false)
	,m_position(position)
{
	++countNodes;

	::memcpy(m_linebuf, line.moves, line.length*sizeof(line.moves[0]));
	m_line.length = line.length;
}


bool Node::alreadyDone() const { return m_done; }
bool Node::isStoredLineKey() const { return m_isStoredLineKey; }
void Node::done() { m_done = true; }
void Node::setIsStoredLineKey() { m_isStoredLineKey = true; }


bool
Node::isEqual(Position const& position) const
{
	return ::memcmp(&m_position, &position, sizeof(m_position)) == 0;
}


void
Node::reset()
{
	if (!m_done)
		return;

	m_done = false;

	for (Successors::iterator i = m_successors.begin(); i != m_successors.end(); ++i)
		i->node->reset();
}


unsigned
Node::countTranspositionDepth() const
{
	unsigned count = 0;

	if (m_done)
		return 0;

	m_done = true;

	for (Successors::const_iterator i = m_successors.begin(); i != m_successors.end(); ++i)
		count = mstl::max(count, i->node->countTranspositionDepth() + (i->transposition == true));

	m_done = false;

	return count;
}


void
Node::setup(Name const* name, Eco eco)
{
	if (m_name == 0)
		m_name = name;
	if (!m_eco)
		m_eco = eco;
}


void
Node::setup(Eco eco, Name const* name, unsigned length)
{
	m_name = name;
	m_eco = eco;
	m_length = length;
}


Node*
Node::find(uint16_t move) const
{
	for (Successors::const_iterator i = m_successors.begin(); i != m_successors.end(); ++i)
	{
		if (move == i->move)
			return i->node;
	}

	return 0;
}


void
Node::setNode(uint16_t move, Node* node)
{
	M_ASSERT(node);

	for (Successors::iterator i = m_successors.begin(); i != m_successors.end(); ++i)
	{
		if (move == i->move)
		{
			M_ASSERT(i->node == 0);
			i->node = node;
			return;
		}
	}

	M_ASSERT(0);
}


void
Node::sort()
{
	if (m_successors.empty())
		return;

	unsigned n = m_successors.size() - 1;

	for (unsigned i = 0; i < n; ++i)
	{
		unsigned index = i;

		for (unsigned k = i + 1; k <= n; ++k)
		{
			if (m_successors[index].weight < m_successors[k].weight)
				index = k;
		}

		if (index != i)
			mstl::swap(m_successors[index], m_successors[i]);
	}
}


void
dumpAscii(	Board& board,
				mstl::bitset& done,
				Node* node,
				unsigned level,
				bool transposition,
				unsigned ply)
{
	M_ASSERT(node->name().size() >= 2);

	printf(	"%c%s%c \"%s\"",
				transposition ? '[' : '(',
				node->eco().asString().c_str(),
				transposition ? ']' : ')',
				node->name(1).c_str());

	for (unsigned i = 2; i < node->name().size(); ++i)
		printf(" \"%s\"", node->name(i).c_str());

	printf("\n");

	if (transposition || node->alreadyDone())
		return;

	node->done();

	for (Node::Successors::iterator i = node->successors().begin(); i != node->successors().end(); ++i)
	{
		Move move = board.makeMove(Move(i->move).from(), Move(i->move).to());
		mstl::string s;

		board.prepareUndo(move);
		board.prepareForSan(move);
		board.doMove(move);
		for (unsigned k = 0; k < level; ++k) printf("| ");
		printf("%s: ", move.printSan(s).c_str());
		dumpAscii(board, done, i->node, level + 1, i->transposition, ply + 1);
		board.undoMove(move);
	}
}


void
dumpAscii(Node* node)
{
	mstl::bitset done(Eco::Max_Code + 1);
	Board board(Board::standardBoard());
	dumpAscii(board, done, node, 0, false, 0);
}


void
dumpBinary(	mstl::ostream& strm,
				Board& board,
				mstl::bitset& info,
				mstl::bitset& done,
				Node* node)
{
	M_ASSERT(node->name(0).size() < 256);
	M_ASSERT(node->successors().size() < 256);
	M_ASSERT(node->length() < 256);

	unsigned char buf[4];
	util::ByteStream bstrm(buf, sizeof(buf));

	bstrm << uint24_t(node->eco());
	strm.write(buf, 3);

	M_ASSERT(!node->alreadyDone());
	node->done();

	if (!info.test_and_set(node->eco()))
	{
		strm.put(node->length());
		strm.put(node->name().size());

		for (unsigned i = 0; i < node->name().size(); ++i)
		{
			bstrm.resetp();
			bstrm << uint16_t(node->ref(i));
			strm.write(buf, 2);
		}
	}

	M_ASSERT(node->successors().size() < 128);

	strm.put(node->successors().size() | (node->isStoredLineKey() << 7));
	Node::Successors::const_iterator i;

	node->sort();

	for (i = node->successors().begin(); i != node->successors().end(); ++i)
	{
		Move m(i->move);
		Move move(board.makeMove(m.from(), m.to()));

		board.prepareUndo(move);
		board.doMove(move);

		uint64_t hash = board.hashNoEP();
		Lookup::const_iterator n = lookup.find(hash);

		if (n == lookup.end())
		{
			lookup[hash] = new Node(i->node->eco(), board.position(), node->line());
		}
		else if (!n->second->isEqual(board.position()))
		{
			M_RAISE(	"hash clash: %s - %s",
						n->second->eco().asString().c_str(),
						node->eco().asString().c_str());
		}

		if (board.hash() != hash)
		{
			n = lookup.find(board.hash());

			if (n == lookup.end())
			{
				lookup[hash] = new Node(i->node->eco(), board.position(), node->line());
			}
			else if (!n->second->isEqual(board.position()))
			{
				M_RAISE(	"hash clash (ep): %s - %s",
							n->second->eco().asString().c_str(),
							node->eco().asString().c_str());
			}
		}

		bstrm.resetp();
		bstrm << uint16_t(i->move);
		bstrm << uint8_t(i->weight | (i->transposition << 7));
		strm.write(buf, 3);

		if (!i->transposition)
			dumpBinary(strm, board, info, done, i->node);

		board.undoMove(move);
	}
}


void
dumpBinary(Node* node)
{
	unsigned char buf[26];
	util::ByteStream bstrm(buf, sizeof(buf));
	mstl::bitset done(Eco::Max_Code + 1);
	mstl::bitset info(Eco::Max_Code + 1);

	mstl::cout.write("eco.bin", 8);

	bstrm << uint16_t(EcoTable::FileVersion);
	bstrm << uint32_t(countCodes);
	bstrm << uint32_t(countNodes);
	bstrm << uint32_t(countMoves);
	bstrm << uint32_t(countBranches);
	bstrm << uint32_t(strings.size());
	bstrm << uint32_t(countChars);
	mstl::cout.write(buf, sizeof(buf));

	for (unsigned i = 0; i < strings.size(); ++i)
	{
		mstl::cout.put(strings[i].size());
		mstl::cout.write(strings[i], strings[i].size());
	}

	Board board(Board::standardBoard());
	dumpBinary(mstl::cout, board, info, done, node);
}


void
buildStoredLines(Node* root, StoredLine* myRoot)
{
	for (unsigned i = 1; i < si3::StoredLine::count(); ++i)
	{
		Line const&	line			= si3::StoredLine::getLine(i).line();
		Node*			node			= root;
		StoredLine*	myNode		= myRoot;
		bool			transposed	= false;
		Eco			key			= root->eco();

		for (unsigned k = 0; k < line.length; ++k)
		{
			Node::Successors::const_iterator s = node->successors().begin();

			while (s != node->successors().end() && s->move != line.moves[k])
				++s;

			if (s == node->successors().end())
				M_RAISE("cannot find stored line %u (%s)", i, si3::StoredLine::getText(i));

			if (s->transposition)
				transposed = true;
			else if (!transposed)
				key = node->eco();

			node = s->node;
			myNode = myNode->addSuccessor(line.moves[k], key, node->eco());
		}

		myNode->setIndex(i);
		node->setIsStoredLineKey();
	}
}


void
dumpStoredLineNodes(mstl::ostream& strm, StoredLine const* node)
{
	StoredLine::Successors successors = node->successors();

	unsigned char buf[8];
	util::ByteStream bstrm(buf, sizeof(buf));

	bstrm << uint24_t(node->key());
	bstrm << uint24_t(node->opening());
	bstrm << uint8_t(node->index());
	bstrm << uint8_t(successors.size());

	strm.write(buf, 8);

	for (unsigned i = 0; i < successors.size(); ++i)
	{
		StoredLine::Successor const& successor = successors[i];

		bstrm.resetp();
		bstrm << uint16_t(successor.move);
		strm.write(buf, 2);

		dumpStoredLineNodes(strm, successor.node);
	}
}


void
dumpStoredLines(StoredLine* root)
{
	unsigned char buf[4];
	util::ByteStream bstrm(buf, sizeof(buf));

	bstrm << uint16_t(StoredLine::countNodes());
	bstrm << uint16_t(StoredLine::countBranches());
	mstl::cout.write(buf, 4);

	dumpStoredLineNodes(mstl::cout, root);
}


void
resolveNames(Node* node, Name const* name, Eco eco)
{
	node->setup(name, eco);

	Node::Successors::const_iterator i;
	for (i = node->successors().begin(); i != node->successors().end(); ++i)
	{
		if (!i->transposition)
			resolveNames(i->node, node->nameRef(), node->eco());
	}
}


void
prepare(mstl::bitset& done, Node* node, unsigned ply)
{
	if (node->name().size() == 0)
		M_RAISE("%s not initialized\n", node->eco().asString().c_str());

	M_ASSERT(!node->name(0).empty());

	if (node->alreadyDone())
		return;

	node->done();

	Node::Successors::const_iterator i;
	countBranches += node->successors().size();

	for (i = node->successors().begin(); i != node->successors().end(); ++i)
	{
		if (!i->transposition)
			prepare(done, i->node, ply + 1);
	}
}


Node*
load(mstl::istream& strm)
{
	typedef mstl::vector<Resolve> Resolvers;

	mstl::string	buf;
	unsigned			lineNo(0);
	Node*				root = 0;
	unsigned			maxLength(0);
	unsigned			maxSuccessors(0);
	Resolvers		resolve;

	while (true)
	{
		do
		{
			if (!strm.getline(buf))
			{
				for (unsigned i = 0; i < resolve.size(); ++i)
				{
					Resolve const& r = resolve[i];
					uint64_t hash = r.board.hashNoEP();
					Node* node = lookup[hash];
					r.node->setNode(r.move, node);
//					M_ASSERT(r.eco == node->eco());
				}

				resolveNames(root, root->nameRef(), root->eco());
				mstl::bitset done(Eco::Max_Code + 1);
				prepare(done, root, 0);
				root->reset();

				fprintf(stderr, "\n");
				fprintf(stderr, "# Codes:     %6u\n", countCodes);
				fprintf(stderr, "# Nodes:     %6u\n", countNodes);
				fprintf(stderr, "# Moves:     %6u\n", countMoves);
				fprintf(stderr, "# Chars:     %6u\n", countChars);
				fprintf(stderr, "# Branches:  %6u\n", countBranches);
				fprintf(stderr, "\n");
				fprintf(stderr, "Max. move length:   %u\n", maxLength);
				fprintf(stderr, "Max. successors:    %u\n", maxSuccessors);
				fprintf(stderr, "Max. transp. depth: %u\n", root->countTranspositionDepth());
				fprintf(stderr, "\n");

				return root;
			}

			++lineNo;
		}
		while (buf.empty() || buf[0] == '#');

		if (buf.size() < 10)
			throwCorrupted(lineNo);

		char const* s = buf.c_str();

		Eco eco(s);

		if (eco == 0)
			throwInvalidEco(lineNo, s);

		s = ::strchr(s + 8, '"');

		if (!s)
			throwCorrupted(lineNo);

		Name* name = new Name;
		unsigned level = 0;

		while (*s == '"')
		{
			if (level >= 6)
				M_RAISE("too many levels in ECO file (line %u)", lineNo);

			char const* e = ::strchr(s + 1, '"');

			if (!e)
				M_RAISE("unterminated string in ECO file (line %u)", lineNo);

			name->set(level++, mstl::string(s + 1, e));
			char const* t = ::strchr(e + 1, '"');
			s = t ? t : e - 1;
		}

		if (name->size() <= 1)
			M_RAISE("at least two levels needed (line %u)", lineNo);

		++countCodes;

		Board board(Board::standardBoard());
		MoveList moves;
		uint16_t linebuf[Max_Move_Length];
		Line line(linebuf);

		if (root == 0)
		{
			M_ASSERT(eco == Eco("A00"));
			M_ASSERT(moves.isEmpty());

			root = new Node(eco, name, 0, Board::standardBoard().position(), Line());
			lookup[Board::standardBoard().hash()] = root;
		}

		while ((s = ::nextWord(s + 1)) && ::isalpha(*s))
		{
			Move move = board.parseMove(s);

			if (!move.isLegal())
			{
				*const_cast<char*>(::endOfWord(s)) = '\0';
				M_RAISE("illegal move '%s' in ECO file (line %u)", s, lineNo);
			}

			board.doMove(move);
			moves.append(move);
		}

		countMoves += moves.size();

		if (moves.size() > maxLength)
			maxLength = moves.size();

		Node* node = root;
		Name* myName = 0;
		Eco myEco;

		board = Board::standardBoard();

		for (unsigned i = 0; i < moves.size(); ++i)
		{
			M_ASSERT(line.length < Max_Move_Length);
			linebuf[line.length++] = moves[i].index();

			board.doMove(moves[i]);

			uint64_t hash = board.hashNoEP();

			if (i + 1 == moves.size())
			{
				myName = name;
				myEco = eco;
			}

			Node* succ = lookup[hash];

			if (succ == 0)
			{
				Node*	n = new Node(myEco, myName, moves.size(), board.position(), line);
				lookup[hash] = n;
				node->successors().push_back(Node::Successor(moves[i].index(), n, false));
				succ = node->successors().back().node;
			}
			else if (succ->length() == 0 || moves.size() < succ->length())
			{
				succ->setup(myEco, myName, moves.size());
			}

			node = succ;
		}

		char paren = s ? *s : 0;
		bool first = true;

		for ( ; paren == '(' || paren == '['; s = ::nextWord(s + 1), paren = s ? *s : 0)
		{
			Eco next(s + 1);

			if (next == 0)
				throwInvalidEco(lineNo, s + 1);

			s = ::nextWord(s + 1);
			if (!s)
				throwCorrupted(lineNo);

			Move move = board.parseMove(s);

			if (!move.isLegal())
			{
				*const_cast<char*>(::endOfWord(s)) = '\0';
				M_RAISE("illegal move '%s' in ECO file (line %u)", s, lineNo);
			}

			board.prepareUndo(move);
			board.doMove(move);

			if (first)
			{
				M_ASSERT(line.length < Max_Move_Length);
				++line.length;
				first = false;
			}

			linebuf[line.length - 1] = move.index();

			uint64_t hash = board.hashNoEP();

			if (paren == '[')
			{
				M_ASSERT(node->find(move.index()) == 0);
				node->successors().push_back(Node::Successor(move.index(), 0, true));
				resolve.push_back(Resolve(node, move.index(), Eco(), board));
			}
			else
			{
				Node* succ = lookup[hash];

				if (succ == 0)
				{
					Node*	n = new Node(Eco(), board.position(), line);
					node->successors().push_back(Node::Successor(move.index(), n, false));
					lookup[hash] = n;
				}
			}

			board.undoMove(move);
		}

		if (node->successors().size() > maxSuccessors)
			maxSuccessors = node->successors().size();

		if (s)
			throwCorrupted(lineNo);
	}

	return 0;	// not reached
}


int
main(int argc, char const* argv[])
{
	try
	{
		if (argc < 2 || 3 < argc || (argc == 3 && ::strcmp(argv[1], "--ascii") != 0))
			M_RAISE("Usage: %s [--ascii] <eco-file>", argv[0]);

		si3::StoredLine::initialize();

		mstl::ifstream stream(argv[argc - 1]);
		Node* root = load(stream);

		if (argc == 2)
		{
			StoredLine* sroot = new StoredLine;

			buildStoredLines(root, sroot);
			dumpBinary(root);
			dumpStoredLines(sroot);
			root->reset();
		}
		else
		{
			dumpAscii(root);
		}
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
