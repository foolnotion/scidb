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

#include "db_eco_table.h"
#include "db_board.h"
#include "db_line.h"
#include "db_move.h"
#include "db_move_list.h"
#include "db_exception.h"

#include "u_byte_stream.h"

#include "sys_utf8_codec.h"

#include "m_istream.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_map.h"
#include "m_bitset.h"
#include "m_bitfield.h"
#include "m_assert.h"
#include "m_stdio.h"
#include "m_static_check.h"

#include <string.h>

#ifdef DEBUG
# undef DEBUG
# define DEBUG(stmt) stmt
#else
# define DEBUG(stmt)
#endif

using namespace db;
using namespace util;

typedef util::ByteStream::uint24_t uint24_t;

db::EcoTable db::EcoTable::m_specimen;


namespace mstl {

template <> struct hash_key<db::Eco>
{
	static size_t hash(db::Eco key) { return key.code(); }
};

} // namespace mstl


struct EcoTable::StoredLineNode
{
	struct Branch
	{
		uint16_t				move;
		StoredLineNode*	node;
	};

	typedef mstl::hash<uint64_t,uint8_t> Map;
	typedef mstl::hash<Eco,Eco> KeyMap;

	static uint64_t const KeyMask = (1 << Eco::Bit_Size_Per_Subcode) - 1;

	Eco key() const;
	Eco opening() const;

	StoredLineNode const* find(uint16_t) const;

	static uint64_t makeValue(Eco key, Eco opening);

	uint64_t	value;
	uint8_t	index;
	Branch*	branches;
	unsigned	numBranches;

	static Map					m_storedLineMap;
	static KeyMap				m_keyMap;
	static StoredLineNode*	m_storedLineRoot;
};


EcoTable::StoredLineNode::Map		EcoTable::StoredLineNode::m_storedLineMap;
EcoTable::StoredLineNode::KeyMap	EcoTable::StoredLineNode::m_keyMap;
EcoTable::StoredLineNode*			EcoTable::StoredLineNode::m_storedLineRoot = 0;


Eco EcoTable::StoredLineNode::key() const			{ return Eco(value & KeyMask); }
Eco EcoTable::StoredLineNode::opening() const	{ return Eco(value >> Eco::Bit_Size_Per_Subcode); }


uint64_t
EcoTable::StoredLineNode::makeValue(Eco key, Eco opening)
{
	return uint64_t(key) | (uint64_t(opening) << Eco::Bit_Size_Per_Subcode);
}


EcoTable::StoredLineNode const*
EcoTable::StoredLineNode::find(uint16_t move) const
{
	for (unsigned i = 0; i < numBranches; ++i)
	{
		if (branches[i].move == move)
			return branches[i].node;
	}

	return 0;
}


struct EcoTable::Branch
{
	uint16_t	move;
	uint8_t	weight;
	uint8_t	transposition;
	Node*		node;

	Branch() : move(0), weight(0), transposition(0), node(0) {}
};


struct EcoTable::Node
{
	struct Variation
	{
		typedef mstl::vector<Eco>	Codes;
		typedef mstl::vector<bool>	Transpositions;

		MoveList			moves;
		MoveList			branches;
		Codes				codes;
		Transpositions	transpositions;
	};

	typedef mstl::map<Eco,Variation*> Variations;
	typedef EcoTable::Entry Entry;
	typedef sys::utf8::Codec Codec;
	typedef EcoTable::Branch Branch;

	Eco		eco;
	Node*		pred;
	Entry*	entry;
	Branch*	branches;
	uint8_t	numBranches;
	uint8_t	length;
	uint8_t	ply;

	mutable uint8_t flags;

	Branch* const find(uint16_t move) const;
	Node* find(Eco eco) const;

	void getSuccessors(Successors& successors, bool wantDerivedCodes) const;
	void traverse(EcoSet& reachable, bool wantTransposed) const;
	void decreasePawnMoves();
	void reset();

	void printName(Codec& codec, Eco code, unsigned startLevel = 0) const;

	void dump(Codec& codec, Board& board, unsigned ply) const;
	void dump();

	void print(Board& board, Variations& variations, MoveList& moves, unsigned ply);
	void print();
};


EcoTable::Branch* const
EcoTable::Node::find(uint16_t move) const
{
	for (unsigned i = 0; i < numBranches; ++i)
	{
		if (branches[i].move == move)
			return &branches[i];
	}

	return 0;
}


EcoTable::Node*
EcoTable::Node::find(Eco eco) const
{
	for (unsigned i = 0; i < numBranches; ++i)
	{
		if (branches[i].node->eco == eco)
			return branches[i].node;
	}

	return 0;
}


void
EcoTable::Node::getSuccessors(Successors& successors, bool wantDerivedCodes) const
{
	M_ASSERT(numBranches <= Max_Successors);

	typedef Successors::Successor Successor;

	unsigned n = 0;

	for (unsigned i = 0; i < numBranches; ++i)
	{
		Branch const& branch = branches[n];

		if (!branch.transposition || (!wantDerivedCodes && branch.node->ply > ply))
		{
			Successor& succ = successors.list[n];

			succ.move = branch.move;
			succ.eco = branch.node->eco;
			succ.weight = branch.weight;

			if (wantDerivedCodes)
			{
				succ.reachable.resize(Eco::Max_Code + 1);
				branch.node->traverse(succ.reachable, !wantDerivedCodes);
			}

			++n;
		}
	}

	successors.length = n;
}


void
EcoTable::Node::traverse(EcoSet& reachable, bool wantTransposed) const
{
	reachable.set(eco);

	for (unsigned i = 0; i < numBranches; ++i)
	{
		Branch const& branch = branches[i];

		if (branch.transposition)
		{
			if (wantTransposed && ply + 1 == branch.node->ply)
				branch.node->traverse(reachable, wantTransposed);
		}
		else
		{
			branch.node->traverse(reachable, wantTransposed);
		}
	}
}


void
EcoTable::Node::reset()
{
	if (!flags)
		return;

	flags = 0;

	for (unsigned i = 0; i < numBranches; ++i)
		branches[i].node->reset();
}


void
EcoTable::Node::printName(Codec& codec, Eco code, unsigned startLevel) const
{
	Name const&		name = EcoTable::m_specimen.getName(code);
	mstl::string	s;

	for (unsigned i = startLevel; i < EcoTable::Num_Name_Parts && !name.part[i].empty(); ++i)
	{
		codec.convertFromUtf8(name.part[i], s);
		::printf(" \"%s\"", s.c_str());
	}
}


void
EcoTable::Node::dump(Codec& codec, Board& board, unsigned ply) const
{
	if (flags)
		return;

	flags = 1;

	for (unsigned i = 0; i < numBranches; ++i)
	{
		Branch const&	b = branches[i];
		mstl::string	s;

		Move move = board.makeMove(b.move);

		board.prepareForSan(move);
		board.prepareUndo(move);
		board.doMove(move);

		for (unsigned k = 0; k < ply; ++k)
			::printf("| ");

		::printf("%s: %c%s%c",
					move.printSan(s).c_str(),
					b.transposition ? '[' : '(',
					b.node->eco.asString().c_str(),
					b.transposition ? ']' : ')');
		printName(codec, b.node->eco, 1);
		::printf("\n");

		if (!b.transposition)
			b.node->dump(codec, board, ply + 1);

		board.undoMove(move);
	}
}


void
EcoTable::Node::dump()
{
	Codec codec(Codec::latin1());
	Board board(Board::standardBoard());
	::printf("(%s)", eco.asString().c_str());
	printName(codec, eco, 1);
	::printf("\n");
	dump(codec, board, 0);
	reset();
}


void
EcoTable::Node::print(Board& board, Variations& variations, MoveList& moves, unsigned ply)
{
	if (flags)
		return;

	Variation* var = 0;

	flags = 1;

	if (length == ply)
	{
		M_ASSERT(variations.find(eco) == variations.end());

		var = variations[eco] = new Variation;
		var->moves = moves;
	}

	for (unsigned i = 0; i < numBranches; ++i)
	{
		Branch const&	b		= branches[i];
		Move				move	= board.makeMove(b.move);

		board.prepareForSan(move);
		board.prepareUndo(move);
		board.doMove(move);
		moves.push(move);

		if (length == ply)
		{
			var->branches.append(move);
			var->codes.push_back(b.node->eco);
			var->transpositions.push_back(b.transposition);
		}

		if (!b.transposition)
			b.node->print(board, variations, moves, ply + 1);

		moves.pop();
		board.undoMove(move);
	}
}


void
EcoTable::Node::print()
{
	Variations		variations;
	MoveList			moves;
	Board				board(Board::standardBoard());
	mstl::string	str;
	Eco				prev(Eco::root());
	Codec				codec(Codec::latin1());

	variations.reserve(8192);
	print(board, variations, moves, 0);
	reset();

	for (Variations::const_iterator i = variations.begin(); i != variations.end(); ++i)
	{
		Variation const* v = i->second;

		if (!v->moves.isEmpty() || !v->branches.isEmpty())
		{
			Eco eco = i->first;

			if (prev != eco.basic())
			{
				prev = eco.basic();
				::printf("\n");
			}

			::printf("%s", eco.asString().c_str());
			printName(codec, eco);

			for (unsigned k = 0; k < v->moves.size(); ++k)
			{
				str.clear();

				::printf(" ");
				if ((k & 1) == 0) ::printf("%u.", (k + 2)/2);
				::printf("%s", v->moves[k].printSan(str).c_str());
			}

			for (unsigned k = 0; k < v->branches.size(); ++k)
			{
				str.clear();
				if (v->transpositions[k])
					::printf(" [%s] ", v->codes[k].asString().c_str());
				else
					::printf(" (%s) ", v->codes[k].asString().c_str());
				if ((v->moves.size() & 1) == 0) ::printf("%u.", (v->moves.size() + 2)/2);
				::printf("%s", v->branches[k].printSan(str).c_str());
			}

			printf("\n");
			delete v;
		}
	}
}


struct EcoTable::Loader
{
	typedef mstl::vector<int>					Lengths;
	typedef mstl::vector<mstl::string>		NameRef;
	typedef EcoTable::Lookup::value_type	Pair;
	typedef EcoTable::Entry						Entry;
	typedef sys::utf8::Codec					Codec;
	typedef StoredLineNode::Branch			StoredLineBranch;

	mstl::istream&		m_strm;
	EcoTable&			m_specimen;
	EcoSet				m_ecoInfo;
	Branch*				m_branchCurr;
	Branch*				m_branchEnd;
	Node*					m_nodeCurr;
	Node*					m_nodeEnd;
	StoredLineNode*	m_storedLineNodeCurr;
	StoredLineNode*	m_storedLineNodeEnd;
	StoredLineBranch*	m_storedLineBranchCurr;
	StoredLineBranch*	m_storedLineBranchEnd;
	uint16_t*			m_moveCurr;
	uint16_t*			m_moveEnd;
	uint16_t				m_line[opening::Max_Line_Length + 1];
	NameRef				m_nameRef;
	Board					m_board;
	Codec					m_codec;

	Loader(mstl::istream& strm, EcoTable& specimen);

	static void throwCorruptedData() { DB_RAISE("corrupted data in ECO file"); }

	void readNode(unsigned ply, Node* node, Eco storedLineKey, Entry const* pred = 0);
	void readNode(StoredLineNode* node);

	void loadStoredLines();
	void load();
};


EcoTable::Loader::Loader(mstl::istream& strm, EcoTable& specimen)
	:m_strm(strm)
	,m_specimen(specimen)
	,m_ecoInfo(Eco::Max_Code + 1)
	,m_board(Board::standardBoard())
	,m_codec(Codec::latin1())
{
}


void
EcoTable::Loader::readNode(unsigned ply, Node* node, Eco storedLineKey, Entry const* pred)
{
	if (__builtin_expect(ply > opening::Max_Line_Length, 0))
		throwCorruptedData();

	unsigned char buf[4];
	ByteStream bstrm(buf, 4);

	m_strm.read(buf, 3);
	Eco eco(bstrm.uint24());

	if (__builtin_expect(!eco || eco > Eco::Max_Code, 0))
		throwCorruptedData();

	EcoTable::Lookup::reference entry = m_specimen.m_lookup.find_or_insert(eco, 0);

	if (entry == 0)
	{
		if (__builtin_expect(m_moveEnd <= m_moveCurr, 0))
			throwCorruptedData();

		unsigned length = m_strm.get();

		entry = m_specimen.m_allocator.alloc();

		entry->line.moves = m_moveCurr;
		entry->line.length = length;

		m_moveCurr += length + 1;

		unsigned numLevels = m_strm.get();

		if (__builtin_expect(numLevels > Num_Name_Parts, 0))
			throwCorruptedData();

		for (unsigned i = 0; i < numLevels; ++i)
		{
			bstrm.resetg();
			m_strm.read(buf, 2);
			unsigned ref = bstrm.uint16();

			if (__builtin_expect(ref >= m_nameRef.size(), 0))
				throwCorruptedData();

			m_codec.convertToUtf8(m_nameRef[ref], entry->name.part[i]);
		}
	}

	M_ASSERT(entry);

	if (entry->line.length == ply)
		::memcpy(const_cast<uint16_t*>(entry->line.moves), m_line, ply*sizeof(uint16_t));

	if (node->eco == eco)
		return;

	if (__builtin_expect(m_branchEnd <= m_branchCurr, 0))
		throwCorruptedData();

	node->eco = eco;
	node->entry = entry;
	node->numBranches = m_strm.get();
	node->branches = m_branchCurr;
	node->length = entry->line.length;
	node->ply = ply;

	if (node->numBranches & 0x80)
	{
		node->numBranches &= 0x7f;
		storedLineKey = eco;
	}
	else if (storedLineKey)
	{
		StoredLineNode::m_keyMap[eco] = storedLineKey;
	}

	m_branchCurr += node->numBranches;

	if (__builtin_expect(node->numBranches > Max_Successors, 0))
		throwCorruptedData();

	for (unsigned i = 0; i < node->numBranches; ++i)
	{
		Branch& branch = node->branches[i];

		bstrm.resetg();
		m_strm.read(buf, 2);
		uint16_t m = bstrm.uint16();

		Move move = m_board.makeMove(m);

		if (move.isEmpty() || move.isNull() || !m_board.isValidMove(move))
			throwCorruptedData();

		move.setLegalMove();
		m_board.prepareUndo(move);
		m_board.doMove(move);

		uint64_t hash = m_board.hashNoEP();
		Node*& n = m_specimen.m_map[hash];

		if (n == 0)
		{
			if (__builtin_expect(m_nodeCurr == m_nodeEnd, 0))
				throwCorruptedData();

			n = m_nodeCurr++;
		}

		m_line[ply] = branch.move = move.index();
		branch.weight = m_strm.get();
		branch.transposition = branch.weight >> 7;
		branch.weight &= 0x7f;
		branch.node = n;

		if (!branch.transposition)
		{
			readNode(ply + 1, branch.node, storedLineKey, entry);
			branch.node->pred = node;
		}

		if (hash != m_board.hash())
		{
			Node*& m = m_specimen.m_map[m_board.hash()];

			if (m)
				throwCorruptedData();

			m = n;
		}

		m_board.undoMove(move);
	}
}


void
EcoTable::Loader::load()
{
	char buf[26];

	// used: 19322
	// collisions: 11797
	// max. bucket length: 8
	// average bucket length: 2.57
	// storage size: 756.184 bytes (~0.72 MB)
	m_specimen.m_lookup.rebuild(70000);

	// used: 18056
	// collisions: 13356
	// max. bucket length: 16
	// average bucket length: 3.84
	// storage size: 478.848 bytes (~0.45 MB)
	StoredLineNode::m_keyMap.rebuild(35000);

	try
	{
		ByteStream bstrm(buf, sizeof(buf));
		m_strm.read(buf, sizeof(buf));
		unsigned version = bstrm.uint16();

		if (version != 99)
			DB_RAISE("unknown ECO version (%u)", version);

		unsigned countCodes		= bstrm.uint32();
		unsigned countNodes		= bstrm.uint32();
		unsigned countMoves		= bstrm.uint32();
		unsigned countBranches	= bstrm.uint32();
		unsigned countStrings	= bstrm.uint32();
		unsigned countChars		= bstrm.uint32();

		m_specimen.m_branchBuffer	= new Branch[countBranches];
		m_specimen.m_nodeBuffer		= new Node[countNodes];
		m_specimen.m_nameBuffer		= new char[countChars + countStrings];
		m_specimen.m_moveBuffer		= new uint16_t[countMoves + countCodes];

		::memset(m_specimen.m_nodeBuffer, 0, sizeof(Node)*countNodes);
		::memset(m_specimen.m_nameBuffer, 0, countChars + countStrings);
		::memset(m_specimen.m_moveBuffer, 0, sizeof(uint16_t)*(countMoves + countCodes));

		m_branchCurr = m_specimen.m_branchBuffer;
		m_moveCurr = m_specimen.m_moveBuffer;
		m_nodeCurr = m_specimen.m_nodeBuffer;

		m_branchEnd = m_branchCurr + countBranches;
		m_moveEnd = m_moveCurr + countMoves + countCodes;
		m_nodeEnd = m_nodeCurr + countNodes;

		m_nameRef.resize(countChars + countCodes);

		char* nameCurr	= m_specimen.m_nameBuffer;
		char* nameEnd	= m_specimen.m_nameBuffer + countChars + countStrings;

		for (unsigned i = 0; i < countStrings; ++i)
		{
			char length = m_strm.get();

			if (__builtin_expect(nameCurr + length + 1 > nameEnd, 0))
				throwCorruptedData();

			m_strm.read(nameCurr, length);
			m_nameRef[i].hook(nameCurr, length);
			nameCurr += length + 1;
		}

		if (__builtin_expect(nameCurr != nameEnd, 0))
			throwCorruptedData();

		m_specimen.m_root = m_nodeCurr++;
		m_specimen.m_map[m_board.hash()] = m_specimen.m_root;
		readNode(0, m_specimen.m_root, Eco());

		if (m_branchCurr != m_branchEnd || m_moveCurr != m_moveEnd || m_nodeCurr != m_nodeEnd)
			throwCorruptedData();
	}
	catch (mstl::ios_base::failure const& exc)
	{
		DB_RAISE("error while reading ECO file");
	}

	DEBUG(::printf("### ECO Table #####################################\n"));
	DEBUG(::printf("lookup: used: %u\n", m_specimen.m_lookup.used()));
	DEBUG(::printf("lookup: collisions: %u\n", m_specimen.m_lookup.count_collisions()));
	DEBUG(::printf("lookup: max. bucket length: %u\n", m_specimen.m_lookup.max_bucket_length()));
	DEBUG(::printf("lookup: average bucket length: %0.2f\n",m_specimen.m_lookup.average_bucket_length()));
	DEBUG(::printf("lookup: storage size: %u\n", m_specimen.m_lookup.storage_size()));
	DEBUG(::printf("---------------------------------------------------\n"));
	DEBUG(::printf("key map: used: %u\n", StoredLineNode::m_keyMap.used()));
	DEBUG(::printf("key map: collisions: %u\n", StoredLineNode::m_keyMap.count_collisions()));
	DEBUG(::printf("key map: max. bucket length: %u\n", StoredLineNode::m_keyMap.max_bucket_length()));
	DEBUG(::printf("key map: average bucket length: %0.2f\n", StoredLineNode::m_keyMap.average_bucket_length()));
	DEBUG(::printf("key map: storage size: %u\n", StoredLineNode::m_keyMap.storage_size()));
	DEBUG(::printf("---------------------------------------------------\n"));
}


void
EcoTable::Loader::readNode(StoredLineNode* node)
{
	char buf[8];
	ByteStream bstrm(buf, sizeof(buf));
	m_strm.read(buf, 8);

	Eco key(bstrm.uint24());
	Eco opening(bstrm.uint24());

	node->value = StoredLineNode::makeValue(key, opening);
	node->index = bstrm.uint8();

	if (__builtin_expect(node->index == 255, 0))
		throwCorruptedData();

	if (node->index)
	{
		M_ASSERT(!StoredLineNode::m_storedLineMap.has_key(node->value));
		StoredLineNode::m_storedLineMap[node->value] = node->index;
	}

	unsigned numBranches = node->numBranches = bstrm.uint8();

	node->branches = m_storedLineBranchCurr;
	m_storedLineBranchCurr += numBranches;

	if (__builtin_expect(m_storedLineBranchCurr > m_storedLineBranchEnd, 0))
		throwCorruptedData();
	if (__builtin_expect(m_storedLineNodeCurr + numBranches > m_storedLineNodeEnd, 0))
		throwCorruptedData();

	for (unsigned i = 0; i < numBranches; ++i)
	{
		m_strm.read(buf, 2);
		bstrm.resetg();

		StoredLineNode::Branch& branch = node->branches[i];

		branch.move = bstrm.uint16();
		branch.node = m_storedLineNodeCurr++;

		readNode(branch.node);
	}
}


void
EcoTable::Loader::loadStoredLines()
{
	char buf[4];
	ByteStream bstrm(buf, sizeof(buf));
	m_strm.read(buf, 4);

	unsigned countNodes		= bstrm.uint16();
	unsigned countBranches	= bstrm.uint16();

	StoredLineNode::m_storedLineMap.rebuild(
		unsigned(((255.0)*200.0/StoredLineNode::Map::Load) + 1));

	m_storedLineNodeCurr = new StoredLineNode[countNodes];
	m_storedLineBranchCurr = new StoredLineNode::Branch[countBranches];

	m_storedLineNodeEnd = m_storedLineNodeCurr + countNodes;
	m_storedLineBranchEnd = m_storedLineBranchCurr + countBranches;
	StoredLineNode::m_storedLineRoot = m_storedLineNodeCurr++;

	readNode(StoredLineNode::m_storedLineRoot);

	if (m_storedLineNodeCurr < m_storedLineNodeEnd || m_storedLineBranchCurr < m_storedLineBranchEnd)
		throwCorruptedData();
}


int
EcoTable::Successors::find(uint16_t move) const
{
	for (unsigned i = 0; i < length; ++i)
	{
		if (list[i].move == move)
			return i;
	}

	return -1;
}


EcoTable::EcoTable()
	:m_branchBuffer(0)
	,m_nodeBuffer(0)
	,m_nameBuffer(0)
	,m_moveBuffer(0)
	,m_root(0)
	,m_allocator(65536)
{
}


EcoTable::~EcoTable()
{
	delete [] m_branchBuffer;
	delete [] m_nodeBuffer;
	delete [] m_nameBuffer;
	delete [] m_moveBuffer;
}


bool
EcoTable::isLoaded() const
{
	return m_branchBuffer != 0;
}


void
EcoTable::load(mstl::istream& stream)
{
	M_REQUIRE(stream.mode() & mstl::ios_base::binary);
	M_REQUIRE(!specimen().isLoaded());

	char buf[8];

	if (!stream.read(buf, 8) || ::memcmp(buf, "eco.bin", 8) != 0)
		DB_RAISE("seems not to be a (binary) ECO file");

	stream.exceptions(mstl::ios_base::failbit);

	Loader loader(stream, m_specimen);
	loader.load();
	loader.loadStoredLines();
}


bool
EcoTable::isUsed(Eco code) const
{
	return m_lookup.has_key(code);
}


EcoTable::Name const&
EcoTable::getName(Eco code) const
{
	M_REQUIRE(code <= Eco::Max_Code);
	M_REQUIRE(isLoaded());
	M_REQUIRE(isUsed(code));

	return (*m_lookup.find(code))->name;
}


void
EcoTable::getOpening(Eco code,
							mstl::string& openingLong,
							mstl::string& openingShort,
							mstl::string& variation,
							mstl::string& subVar) const
{
	if (code)
	{
		Name const& name = getName(code);

		openingShort = name.part[0];
		openingLong = name.part[1];
		variation = name.part[2];
		subVar = name.part[3];
	}
	else
	{
		openingLong.clear();
		openingShort.clear();
		variation.clear();
		subVar.clear();
	}
}


void
EcoTable::getOpening(Eco code,
							mstl::string& opening,
							mstl::string& variation,
							mstl::string& subVar) const
{
	mstl::string dummy;
	return getOpening(code, opening, dummy, variation, subVar);
}


Eco
EcoTable::getEco(Board const& board) const
{
	Map::const_iterator k = m_map.find(board.hash());

	if (k == m_map.end())
	{
		uint64_t hash = board.hashNoEP();

		if (hash != board.hash())
			k = m_map.find(board.hashNoEP());
	}

	return k == m_map.end() ? Eco() : k->second->eco;
}


Eco
EcoTable::getEco(Board const& startBoard, Line const& line, EcoSet* reachable) const
{
	M_REQUIRE(isLoaded());

	// IMPORTANT NOTE:
	// If the line contains null moves this function will return zero.

	Board		board(startBoard);
	MoveList	moves;
	unsigned	i;

	if (reachable)
		reachable->resize(Eco::Max_Code + 1);

	for (i = 0; i < line.length; ++i)
	{
		Move move = board.makeMove(line[i]);

		if (move.isNull())
			return Eco();

		if (move.isEmpty() || !board.isValidMove(move, move::DontAllowIllegalMove))
			break;

		board.prepareUndo(move);
		moves.push(move);
		board.doMove(move);
	}

	for ( ; i > 0; --i)
	{
		Map::const_iterator k = m_map.find(board.hash());

		if (k == m_map.end())
		{
			uint64_t hash = board.hashNoEP();

			if (hash != board.hash())
				k = m_map.find(board.hashNoEP());
		}

		if (k != m_map.end())
		{
			if (reachable)
				k->second->traverse(*reachable, true);

			return k->second->eco;
		}

		board.undoMove(moves[i - 1]);
	}

	return Eco::root();
}


Eco
EcoTable::getEco(Line const& line) const
{
	return getEco(Board::standardBoard(), line);
}


EcoTable::Entry const&
EcoTable::getEntry(Eco code) const
{
	M_REQUIRE(code <= Eco::Max_Code);
	M_REQUIRE(isLoaded());
	M_REQUIRE(isUsed(code));

	return **m_lookup.find(code);
}


uint8_t
EcoTable::getStoredLine(Eco key, Eco opening) const
{
	M_REQUIRE(isLoaded());
	M_REQUIRE(!key || isUsed(key));
	M_REQUIRE(!opening || isUsed(opening));

	StoredLineNode::KeyMap::const_pointer i;

	if ((i = StoredLineNode::m_keyMap.find(key)))
		key = *i;

	StoredLineNode::Map::const_pointer k;

	if ((k = StoredLineNode::m_storedLineMap.find(StoredLineNode::makeValue(key, opening))))
		return *k;

	return 0;
}


void
EcoTable::getSuccessors(uint64_t hash, Successors& successors) const
{
	Map::const_iterator i = m_map.find(hash);	// IMPORTANT NOTE: a clash may occur!

	if (i == m_map.end())
		successors.length = 0;
	else
		i->second->getSuccessors(successors, false);
}


Eco
EcoTable::lookup(	Line const& line,
						Eco& opening,
						unsigned* length,
						Successors* successors,
						EcoSet* reachable) const
{
	M_REQUIRE(isLoaded());
	M_REQUIRE(reachable == 0 || successors != 0);

	if (reachable)
		reachable->resize(Eco::Max_Code + 1);

	opening = Eco::root();

	Node const* last = m_root;

	if (line.length == 0)
	{
		if (reachable)
			reachable->set(1, Eco::Max_Code);

		if (successors)
			last->getSuccessors(*successors, true);

		if (length)
			*length = 0;
	}
	else if (line[0] == 0)
	{
		if (length)
			*length = 0;
		if (successors)
			successors->length = 0;

		return Eco();
	}
	else
	{
		bool							transposed	= false;
		Node const* 				prev			= last;
		Branch const*				branch		= m_root->find(line[0]);
		Node const*					node			= branch->node;
		StoredLineNode const*	storedLine	= StoredLineNode::m_storedLineRoot;

		M_ASSERT(branch);

		for (unsigned i = 1; branch; branch = (i == line.length) ? 0 : node->find(line[i]), ++i)
		{
			node = branch->node;

			if (branch->transposition)
			{
				prev = node;
				transposed = true;
			}
			else if (node->length == i)
			{
				if (!transposed)
					last = node;

				prev = node;
			}

			if (storedLine)
			{
				storedLine = storedLine->find(line[i - 1]);

				if (storedLine && storedLine->index)
					opening = storedLine->opening();
			}
		}

		if (successors)
		{
			if (!transposed && prev->length == line.length)
				 prev->getSuccessors(*successors, true);
			else
				successors->length = 0;
		}

		if (reachable)
			prev->traverse(*reachable, false);

		if (length)
			*length = last->length;
	}

	return last->eco;
}


void
EcoTable::print() const
{
	if (m_root)
	{
		m_root->print();
		fflush(stdout);
	}
}


void
EcoTable::dump() const
{
	if (m_root)
	{
		m_root->dump();
		fflush(stdout);
	}
}

// vi:set ts=3 sw=3:
