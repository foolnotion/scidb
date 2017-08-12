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

#include "eco_node.h"
#include "eco_reader.h"
#include "eco_visitor.h"

#include "db_move_buffer.h"
#include "db_guess.h"
#include "db_board.h"

#include "m_bitset.h"
#include "m_bitfield.h"
#include "m_equiv_classes.h"
#include "m_bit_functions.h"
#include "m_utility.h"
#include "m_algorithm.h"
#include "m_set.h"
#include "m_exception.h"
#include "m_assert.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

using namespace eco;
using namespace db;


using FinalSet	= mstl::set<uint64_t>;
using Nodes		= mstl::vector<Node*>;
using Lookup	= mstl::map<uint64_t,Node*>;


unsigned Node::m_maxBranches			= 0;
unsigned Node::m_maxBackLinks			= 0;
unsigned Node::m_maxLineLength		= 0;
unsigned Node::m_maxBacklinks			= 0;
unsigned Node::m_transpositionCount	= 0;

unsigned	Node::m_nodeCount				= 0;
unsigned	Node::m_backlinkCount		= 0;
unsigned	Node::m_bypassCount			= 0;

Node::HashSet		Node::m_bypassSet;
mstl::string		Node::m_epilogue;
Node::BitMaxima	Node::m_maxBitLength;
Rules					Node::m_rules;

bool Node::m_clash = false;

Node::Key Node::m_maxMainKey = 0;

static Nodes		m_nodeList;
static Lookup		m_nodeLookup;
static Lookup		m_nodeLookup2;
static uint16_t	m_moveCache[1 << Move::Index_Field_Length];


static
auto log2(unsigned n) -> unsigned
{
	return n ? mstl::bf::msb_index(n) + 1 : 1;
}


static
auto compare(Square lhs, Square rhs, int less) -> bool
{
	if (sq::fyle(lhs) < sq::fyle(rhs)) return true;
	if (sq::fyle(rhs) < sq::fyle(lhs)) return false;
	if (sq::rank(lhs) < sq::rank(rhs)) return less == -1;
	if (sq::rank(rhs) < sq::rank(lhs)) return less == +1;
	return false;
}


static
auto isValidMove(Board const& board, Move const& move) -> bool
{
	if (!move.isEnPassant())
		return true;

	// exclude invalid en-passant moves
	return board.isValidMove(move, move::DontAllowIllegalMove);
}


static
auto isValidMove(MoveLine const& line, Move const& nextMove) -> bool
{
	if (!nextMove.isEnPassant())
		return true;

	Board board(Board::standardBoard(variant::Normal));

	for (unsigned i = 0; i < line.size(); ++i)
		board.doMove(line[i]);

	// exclude invalid en-passant moves
	return board.isValidMove(nextMove, move::DontAllowIllegalMove);
}


static
auto isGoodMove(Board const& board) -> bool
{
return true;
	// TODO: this is not working
	return (Guess(board, variant::Normal).myThreatenedSquares(150) & ~board.kings(board.notToMove())) == 0;
}


static
auto isReversalMove(MoveLine const& line, Move const& move) -> bool
{
	for (int i = line.size() - 1; i >= 0; --i)
	{
		Move const& m = line[i];

		if (move.to() == m.from() && move.from() == m.to() && move.moved() == m.moved())
			return true;
	}

	return false;
}


static
auto isEvasingMove(Board const& board, Move const& move) -> bool
{
	if (move.moved() == piece::King)
		return board.isInCheck();
return false; // XXX else too slow!

	Guess	guess(board, variant::Standard);
	int score = guess.evaluate(2);

	guess.doMove(move);
	int evasingScore = guess.evaluate(2);

	return evasingScore - 100 >= score;
}


Node::BitInfo::BitInfo() :bits(0) {}


Node::Node()
	:m_id("A00")
	,m_key(0)
	,m_parent(nullptr)
	,m_pathNode(nullptr)
	,m_keySet(nullptr)
	,m_count(0)
	,m_lineNo(0)
	,m_nameRef(Name::Invalid)
	,m_numBypasses(0)
	,m_visited(0)
	,m_sign('\0')
	,m_resolve(false)
	,m_root(true)
	,m_final(false)
	,m_equal(false)
	,m_hasTwin(false)
	,m_checkLine(true)
	,m_preParsed(false)
	,m_isBypass(false)
	,m_isExtension(false)
	,m_isMerged(false)
	,m_bitLengthIsComputed(false)
	,m_isEnumerated(false)
	,m_conflict(false)
	,m_enPassant(false)
	,m_myKeySet(false)
	,m_myPathNode(false)
	,m_extended(false)
	,m_done(false)
{
	m_nodeList.push_back(this);
}


Node::Node(Node* parent)
	:m_key(0)
	,m_parent(parent)
	,m_pathNode(nullptr)
	,m_keySet(nullptr)
	,m_count(0)
	,m_lineNo(0)
	,m_nameRef(Name::Invalid)
	,m_numBypasses(0)
	,m_visited(0)
	,m_sign('\0')
	,m_resolve(false)
	,m_root(false)
	,m_final(false)
	,m_equal(false)
	,m_hasTwin(false)
	,m_checkLine(true)
	,m_preParsed(false)
	,m_isBypass(false)
	,m_isExtension(false)
	,m_isMerged(false)
	,m_bitLengthIsComputed(false)
	,m_isEnumerated(false)
	,m_conflict(false)
	,m_enPassant(false)
	,m_myKeySet(false)
	,m_myPathNode(false)
	,m_extended(false)
	,m_done(false)
{
	m_nodeList.push_back(this);
}


Node::~Node()
{
	m_nodeList.pop_back();
	delete m_keySet;
	delete m_pathNode;
}


auto Node::startOfSequence() const -> Node const*
{
	Node const* node = this;

	if (m_parent && m_final && !m_parent->m_final && m_parent->m_parent)
		node = node->m_parent;

	while (node->m_parent && !node->m_final && !node->m_parent->m_final && m_parent->m_parent)
		node = node->m_parent;

	return node;
}


auto Node::parentName() const -> Name const&
{
	Node const* node = startOfSequence();
	return node->m_parent ? node->m_parent->name() : Name::empty();
}


auto Node::shouldBeFinal() const -> bool
{
	if (m_final)
		return true;
	
	if (m_equal && m_branches.empty())
		return false;
	
	if (m_parent == 0 || m_nameRef != m_parent->m_nameRef)
		return true;

	unsigned numBranches = this->numBranches();
	return numBranches == 0 || numBranches > 1 || firstBranch().transposition;
}


auto Node::firstBranch() const -> Branch const&
{
	M_REQUIRE(numBranches() >= 1);

	for (Branches::const_iterator i = m_branches.begin(); i != m_branches.end(); ++i)
	{
		if (!i->bypass)
			return *i;
	}

	M_ASSERT(!"should not happen");
	return m_branches[0]; // never reached
}


auto Node::isLastBranch() const -> bool
{
	M_REQUIRE(parent() && parent()->numBranches() > 0);
	return m_parent->m_branches[m_parent->m_branches.size() - m_numBypasses - 1].node == this;
}


void Node::reset()
{
	if (!m_done)
		return;

	m_done = false;

	for (Branches::iterator i = m_branches.begin(); i != m_branches.end(); ++i)
		i->node->reset();
}


void Node::setup(Id id, Name const& name)
{
	m_id = id;
	m_nameRef = Name::insert(name);
}


void Node::setOpeningFromParent(unsigned openingRef, Name const& name)
{
	if (this->name().ref(0) == openingRef)
	{
		Name n(this->name());
		n.setOpening(name);
		m_nameRef = Name::insert(n);

		for (Branches::iterator i = m_branches.begin(); i != m_branches.end(); ++i)
		{
			if (!i->transposition)
				i->node->setOpeningFromParent(openingRef, name);
		}
	}
}


void Node::setOpeningFromParent(Name const& name)
{
	setOpeningFromParent(this->name().ref(0), name);
}


auto Node::countTranspositionDepth() const -> unsigned
{
	unsigned count = 0;

	if (m_done)
		return 0;

	m_done = true;

	for (Branches::const_iterator i = m_branches.begin(); i != m_branches.end(); ++i)
		count = mstl::max(count, i->node->countTranspositionDepth() + (i->transposition == true));

	m_done = false;

	return count;
}


auto Node::countMoves(Node const* parent) const -> unsigned
{
	unsigned count = 0;
	unsigned k = 0;

	for (Branches::const_iterator i = m_branches.begin(); i != m_branches.end(); ++i)
	{
		if (!i->transposition)
		{
			++k;
			count += i->node->countMoves(this);
		}
	}

	if (k == 0)
		count += m_line.size();

	return count;
}


auto Node::countBranches() const -> unsigned
{
	unsigned count = m_branches.size();

	for (Branches::const_iterator i = m_branches.begin(); i != m_branches.end(); ++i)
	{
		if (!i->transposition)
			count += i->node->countBranches();
	}

	return count;
}


void Node::eliminateBacklink(Node const* node)
{
	for (Backlinks::iterator i = m_backlinks.begin(); i != m_backlinks.end(); ++i)
	{
		if (i->node == node)
		{
			m_backlinks.erase(i);
			--m_backlinkCount;
			return;
		}
	}

	M_ASSERT(!"should not happen");
}


void Node::eliminateRecursiveBacklinks()
{
	m_done = true;

	for (Branches::iterator i = m_branches.begin(); i != m_branches.end(); ++i)
	{
		if (!i->transposition)
			i->node->eliminateRecursiveBacklinks();
		else if (i->node->m_done)
			i->node->eliminateBacklink(this);
	}

	m_done = false;
}

#if 0

void Node::dumpBitLengths() const
{
	char const* comma = "";
	unsigned total = 0;

	fprintf(stderr, "Bit lengths: ");

	for (unsigned i = 0; i < m_bitLengths.size(); ++i)
	{
		fprintf(stderr, "%s%u", comma, m_bitLengths[i]);
		total += m_bitLengths[i];
		comma = ", ";
	}

	fprintf(stderr, " (total: %u) (length: %u)\n\n", total, m_bitLengths.size());

	for (unsigned i = 0; i < m_maxBitLength.size() && m_maxBitLength[i].bits; ++i)
	{
		fprintf(	stderr,
					"Bit length maxima at level %2u: %s\n",
					i + 1,
					m_maxBitLength[i].id.asString().c_str());
	}
}

#endif

static uint64_t N = 0;
static unsigned K = 0;

auto Node::countPathsBackward() -> uint64_t
{
	if (m_isEnumerated)
		return m_count;

	if (m_done)
		return 0;

	m_done = true;

	if (m_parent)
		m_count += m_parent->countPathsBackward();

	for (auto const& backlink : m_backlinks)
	{
		if (!backlink.node->m_done)
			m_count += backlink.node->countPathsBackward() + 1; // 229.793.307
	}

	m_done = false;
	m_isEnumerated = true;

	return m_count;
}


void Node::countPaths()
{
	if (m_branches.empty())
	{
		uint64_t n = countPathsBackward();
N = mstl::max(n, N);
fprintf(stderr, "%u: %llu (%llu)\n", K++, n, N);
	}
	else
	{
		for (Branches::iterator i = m_branches.begin(); i != m_branches.end(); ++i)
		{
			if (!i->transposition)
				i->node->countPaths();
		}
	}
}

#if 1

void Node::computePathBitLengthsBackward()
{
	if (m_bitLengthIsComputed)
		return;

	if (m_done)
		return; // will be postponed

	m_done = true;

	if (m_parent)
	{
		m_parent->computePathBitLengthsBackward();
		m_bitLengths = m_parent->m_bitLengths;
	}

	if (!m_backlinks.empty())
	{
		for (auto const& backlink : m_backlinks)
		{
			backlink.node->computePathBitLengthsBackward();

			BitLengths const& lengths = backlink.node->m_bitLengths;

			for (unsigned k = 0; k < lengths.size(); ++k)
			{
				if (k == m_bitLengths.size())
					m_bitLengths.push_back(lengths[k]);
				else
					m_bitLengths[k] = mstl::max(m_bitLengths[k], lengths[k]);
			}
		}

		m_bitLengths.push_back(::log2(m_backlinks.size()));
	}

	m_done = false;
	m_bitLengthIsComputed = true;
}


void Node::computePathBitLengths()
{
	// Bit lengths: 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1 (total: 33) (length: 19)

	// Bit lengths: (total: 105) (length: 37)
	// 2, 2, 2, 2, 3, 2, 3, 3, 3, 3,
	// 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	// 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	// 4, 4, 3, 2, 2, 2, 3

	if (m_branches.empty())
	{
		computePathBitLengthsBackward();
		Path::setBitLengthList(m_bitLengths);
	}
	else
	{
		for (auto const& branch : m_branches)
		{
			if (!branch.transposition)
				branch.node->computePathBitLengths();
		}
	}
}

#else

auto Node::computePathBitLengths() -> unsigned
{
	if (m_bitLengthIsComputed || m_done)
		return m_bitLengths.size();

	m_done = true;

	uint8_t bits = 0;

	for (auto& branch : m_branches)
	{
		if (branch.useBits)
			bits = mstl::max(branch.bits, bits);

		branch.pathLength = mstl::max(unsigned(branch.pathLength), branch.node->computePathBitLengths());
	}

	if (bits)
		m_bitLengths.push_back(::log2(bits));

	unsigned startIndex = m_bitLengths.size();

	for (auto const& branch : m_branches)
	{
		BitLengths const& bitLengths = branch.node->m_bitLengths;

		unsigned maxIndex = mstl::min(m_bitLengths.size() - startIndex, bitLengths.size());
		unsigned k;

		for (k = 0; k < maxIndex; ++k)
			m_bitLengths[k + startIndex] = mstl::max(bitLengths[k], m_bitLengths[k + startIndex]);

		for ( ; k < bitLengths.size(); ++k)
			m_bitLengths.push_back(bitLengths[k]);
	}

	m_bitLengthIsComputed = true;
	m_done = false;

	return m_bitLengths.size();
}

#endif
#if 1

void Node::computePathMaxima(BranchStack& stack) const
{
	Node const* node = m_parent;

	if (!m_backlinks.empty())
	{
		M_ASSERT(!m_bitLengths.empty());

		for (auto const& branch : m_branches)
		{
			if (branch.node->m_bitLengths.size() + 1 == m_bitLengths.size())
				node = branch.node;
		}
	}

	if (node)
	{
		stack.push(node->findSuccessor(this));
		node->computePathMaxima(stack);
	}

	mstl::string s;
	m_line.dump(s);
	fprintf(stderr, "%2u: %s\n", m_bitLengths.size(), s.c_str());
}


void Node::computePathMaxima(MoveList& line) const
{
	NodeList finalNodes;
	collectFinalNodes(finalNodes);

	M_ASSERT(!finalNodes.empty());

	Node const* maxNode = finalNodes[0];

	for (unsigned i = 1; i < finalNodes.size(); ++i)
	{
		if (finalNodes[i]->m_bitLengths.size() > maxNode->m_bitLengths.size())
			maxNode = finalNodes[i];
	}

	BranchStack stack;
	maxNode->computePathMaxima(stack);

	for (int i = stack.size() - 1; i >= 0; --i)
	{
		line.append(stack[i]->move);
	}
}

#else
static unsigned N = 0;

void Node::computePathMaxima(MoveList& line, unsigned level)
{
	if (m_done)
		return;

	m_done = true;

	if (level >= 35)
	{
		mstl::string s;
		fprintf(stderr, "deep recursion detected: %s\n", line.dump(s).c_str());
		::exit(1);
	}

++N;
//if (++N % 1000000 == 0) fprintf(stderr, "computePathMaxima: %u\n", N);
if (m_line.size() == 1)
{
	mstl::string s;
	fprintf(stderr, "computePathMaxima: %s\n", m_line.dump(s).c_str());
}

	for (auto const& branch : m_branches)
	{
		BitInfo& info = m_maxBitLength[level];

		if (branch.bits > info.bits)
		{
			info.bits = branch.bits;
			info.id = m_id;
		}

		line.append(branch.move);
		i->node->computePathMaxima(line, level + branch.useBits);
		line.pop();
	}

	m_done = false;
}

#endif

auto Node::computePaths() -> PathNode*
{
	if (!m_pathNode && !m_branches.empty())
	{
		m_done = true;

		// clean up memory
		if (m_myKeySet)
		{
			delete m_keySet;
			m_myKeySet = false;
			m_keySet = nullptr;
			m_bitLengths.release();
		}

		m_pathNode = new PathNode;

		for (auto const& branch : m_branches)
		{
			if (!branch.node->m_done)
			{
				PathNode* node = branch.node->computePaths();

				if (branch.useBits)
					m_pathNode->add(branch.bits, node);
				else
					m_pathNode->add(node);
			}
		}

		if (m_pathNode->single())
		{
			PathNode* node = m_pathNode->front();
			delete m_pathNode;
			m_pathNode = node;
		}
		else
		{
			m_myPathNode = true;
		}

		m_done = false;
	}

	return m_pathNode;
}


void Node::enumerateTranspositionPaths(mstl::bitset& keySet)
{
	if (m_keySet)
	{
		keySet |= *m_keySet;
		return;
	}

	if (m_done)
		return;

	if (keySet.test_and_set(m_key))
		return;

	m_done = true;

	unsigned size = m_branches.size();

	if (size > 1)
	{
		mstl::bitset sets[size];

		for (unsigned i = 0; i < size; ++i)
			sets[i].resize(m_nodeCount + 1);

		unsigned k = 0;

		for (auto const& branch : m_branches)
		{
			branch.node->enumerateTranspositionPaths(sets[k]);
			keySet |= sets[k++];
		}

		mstl::equiv_classes equiv(size);

		for (unsigned i = 0; i < size; ++i)
		{
			for (k = i + 1; k < size; ++k)
			{
				if (!sets[i].disjunctive(sets[k]))
					equiv.add_relation(i, k);
			}
		}

		if (equiv.ngroups() < size)
		{
			k = 0;
			for (unsigned i = 0; i < equiv.ngroups(); ++i)
				k = mstl::max(k, equiv.count(i));

			if (k > 1)
			{
				// Bit lengths (length: 34) (total bits: 122)
				// 5, 5, 5, 4, 5, 4, 5, 5, 5, 5,
				// 5, 4, 4, 4, 4, 4, 4, 4, 4, 4,
				// 3, 3, 3, 3, 3, 3, 3, 3, 2, 2,
				// 2, 1, 1, 1

				k = 0;

				unsigned count[equiv.ngroups()];
				::memset(count, 0, sizeof(unsigned)*equiv.ngroups());

				for (auto& branch : m_branches)
					branch.bits = count[equiv.get_group(k++)]++;

				k = 0;

				for (auto& branch : m_branches)
				{
					if (count[equiv.get_group(k++)] > 1)
						branch.useBits = true;
				}
			}
		}

		m_keySet = new mstl::bitset(keySet);
		m_myKeySet = true;
	}
	else if (m_branches.size() == 1)
	{
		m_branches.front().node->enumerateTranspositionPaths(keySet);

		if (!(m_keySet = m_branches.front().node->m_keySet))
		{
			m_keySet = new mstl::bitset(keySet.size());
			m_myKeySet = true;
		}

		m_keySet->set(m_key);
	}

	m_done = false;
}


void Node::enumerateTranspositionPaths()
{
	mstl::bitset keySet(m_nodeCount + 1);
	eliminateRecursiveBacklinks();
//	countPaths();
// maximal possible number:	    4.194.304 (= 2^22)
// current maximal number:		1.992.109.989 (< 2^31)
//fprintf(stderr, "maximal path number: %u\n", N);
//	enumerateTranspositionPaths(keySet);
m_maxBitLength.resize(50);//opening::Max_Line_Length);
fprintf(stderr, "computePathBitLengths\n");
computePathBitLengths();
Path::dumpBitLengths();
MoveList line;
computePathMaxima(line);
{
	mstl::string s;
	line.dump(s);
	fprintf(stderr, "maximal path: %s\n", s.c_str());
}
::exit(1);
//fprintf(stderr, "makePaths\n");
//PathNode* root = computePaths();
//fprintf(stderr, "computeBitlengths: %u (%u)\n", PathNode::count(), Branch::count);
//root->computeBitlengths(m_bitLengths);
//fprintf(stderr, "makePathMap\n");
//root->makePathMap();
}


void Node::refineClassification(Key mainKey)
{
	Key key(m_key);

	if (m_key == 0 || m_key == mainKey)
	{
		M_ASSERT(m_key <= m_maxMainKey);
		m_key = ++m_nodeCount;
	}

	for (auto& branch : m_branches)
	{
		if (!branch.transposition && !branch.bypass)
			branch.node->refineClassification(key);
	}

	for (auto const& branch : m_branches)
	{
		if (!branch.transposition && branch.bypass)
			branch.node->refineClassification(key);
	}
}


auto Node::countTranspositionLength() const -> unsigned
{
	M_ASSERT(!m_done);

	unsigned count = 0;

	m_done = true;

	for (auto const& branch : m_branches)
	{
		if (branch.transposition)
			++count;
	}

	for (auto const& branch : m_branches)
	{
		if (!branch.transposition)
			count = mstl::max(count, branch.node->countTranspositionLength());
	}

	m_done = false;

	return count;
}


void Node::collectFinalNodes(NodeList& nodes) const
{
	if (m_branches.empty())
	{
		nodes.push_back(this);
	}
	else
	{
		for (auto const& branch : m_branches)
		{
			if (!branch.transposition)
				branch.node->collectFinalNodes(nodes);
		}
	}
}


auto Node::findId(Id id) const -> Node const*
{
	if (m_id == id)
		return this;

	for (auto const& branch : m_branches)
	{
		if (Node const* n = branch.node->findId(id))
			return n;
	}

	return nullptr;
}


auto Node::findSuccessor(Node* node) -> Branch*
{
	for (auto& branch : m_branches)
	{
		if (branch.node == node)
			return &branch;
	}

	return nullptr;
}


auto Node::findSuccessor(Node const* node) const -> Branch const*
{
	for (auto const& branch : m_branches)
	{
		if (branch.node == node)
			return &branch;
	}

	return nullptr;
}


auto Node::findMove(Move move) const -> Branch const*
{
	for (auto const& branch : m_branches)
	{
		if (branch.move == move)
			return &branch;
	}

	return nullptr;
}


auto Node::countPathNodes(mstl::bitset& path, mstl::bitset& used, unsigned& count) const -> bool
{
	if (path.test_and_set(m_key))
		return false;

	bool rc = false;

	if (!m_parent)
	{
		rc = true;
	}
	else if (used.test_and_set(m_key))
	{
		rc = true;
	}
	else if (m_parent->countPathNodes(path, used, count))
	{
		Branch const* succ = m_parent->findSuccessor(this);

		M_ASSERT(succ);

		if (succ->useBits)
			++count;

		for (auto const& backlink : m_backlinks)
		{
			Node const* link = backlink.node;

			if (link->countPathNodes(path, used, count))
			{
				Branch const* succ = link->findSuccessor(this);

				M_ASSERT(succ);

				if (succ->useBits)
					++count;
			}
		}

		rc = true;
	}

	path.reset(m_key);
	return rc;
}


auto Node::countMaxPathNodes() const -> unsigned
{
	NodeList finalNodes;
	collectFinalNodes(finalNodes);

	unsigned maxCount = 0;

	for (auto node : finalNodes)
	{
		mstl::bitset used(m_nodeCount + 1);
		mstl::bitset path(m_nodeCount + 1);

		unsigned count(1); // for root element
		node->countPathNodes(path, used, count);
		maxCount = mstl::max(count, maxCount);
	}

	return maxCount;
}


auto Node::find(Move const& move) const -> Node*
{
	for (auto const& branch : m_branches)
	{
		if (move == branch.move)
			return branch.node;
	}

	return nullptr;
}


auto Node::findSuccessor(Move const& move, Id id) -> Branch*
{
	for (auto& branch : m_branches)
	{
		if (move == branch.move)
		{
			if (!branch.codes.empty())
				branch.codes.set(id.basic());

			return &branch;
		}
	}

	return nullptr;
}


auto Node::finalNode() const -> Node const*
{
	Node const* node = this;

	while (!node->m_final && node->m_branches.size() == 1 && !node->m_branches.front().transposition)
		node = node->m_branches.front().node;

	return node;
}


void Node::sortBranches(Id eco, Key key)
{
	M_ASSERT(!m_done);

	m_done = true;

	sort(m_branches);

	for (auto& branch : m_branches)
	{
		if (!branch.transposition)
			branch.node->sortBranches(m_id, m_key);
	}

	m_done = false;
}


void Node::sortBranches()
{
	sortBranches(Id(), Key());
}


auto Node::findBypassLeaf() const -> Node const*
{
	Node const* node = this;

	while (node->m_numBypasses > 0)
		node = node->m_branches.back().node;

	return node;
}


void Node::buildBypassSequence(Id eco, Board board, MoveLine& moves)
{
	Node* node = this;
	unsigned final = 1;

	while (	node->m_branches.size() == 1
			/*&& !node->m_final*/
			&& !node->m_branches.front().transposition
			&& (node->m_branches.front().node->m_id == eco || final--))
	{
		Branch& succ = node->m_branches.front();
		succ.move.setColor(board.sideToMove());
		board.doMove(succ.move);
		moves.append(succ.move);
		node = succ.node;
	}
}


auto Node::makeBypassGraph(
	Board& board,
	MoveLine& moves,
	Node const* root,
	unsigned size,
	unsigned weight
) -> bool
{
	enum { EvalDepth		= 2   };
	enum { EvalThreshold	= 125 };

	M_ASSERT(size > 0);
	M_ASSERT(root);

	unsigned numBypasses = m_numBypasses;

	if (size > 1 && mstl::is_odd(size))
		moves.rotate(0, 1, size);

	for (unsigned i = 1; i <= size; i += 2)
	{
		if (mstl::is_even(size))
			moves.rotate(0, i, size);
		else if (i < size)
			moves.swap(i, size - 1);

		Move move(moves[size - 1]);

		if (	(m_branches.empty() || move != m_branches.front().move)
			&& board.isValidMove(move, move::DontAllowIllegalMove))
		{
			board.prepareUndo(move);
			board.doMove(move);

			Lookup::const_iterator n = m_nodeLookup.find(board.hash());

			Node* node = nullptr;
			unsigned w = 0;

			if (n == m_nodeLookup.end())
			{
				Guess	guess(board, variant::Standard);
				int	score = 0; //(mstl::abs(guess.evaluate(EvalDepth)));

				if (score <= EvalThreshold)
				{
					node = new Node(this);
					node->m_id = m_id;
					node->m_line = m_line;
					node->m_line.append(move);
					node->m_nameRef = m_nameRef;
					node->m_isBypass = true;

					w = unsigned(double(weight)*(double(EvalThreshold - score)/double(EvalThreshold)));
					m_nodeLookup[board.hash()] = node;
				}
			}
			else
			{
				node = n->second;
			}

			if (node)
			{
				Branch& succ = m_branches.push_back();
				succ.move = move;
				succ.node = node;
				succ.weight = w;
				succ.transposition = true;
				succ.bypass = true;
				++m_numBypasses;

				bool rc = size <= 1 || node->makeBypassGraph(board, moves, root, size - 1, 100);

				if (n == m_nodeLookup.end())
				{
					if (rc)
					{
						if (size == 1)
						{
							mstl::string s;
							moves.dump(s);

							fprintf(stderr, "cannot find final node for bypass %s\n", s.c_str());
							::exit(1);
						}

						m_bypassSet[board.hash()] = node;
						m_maxLineLength = mstl::max(m_line.size(), m_maxLineLength);

						if (size > 1 && m_id != node->m_id)
						{
							MoveLine			line(m_line);
							mstl::string	str[2];

							line.append(move);
							line.dump(str[0]);
							node->m_line.dump(str[1]);

							fprintf(	stderr,
										"bypass clash: %s: %s\n              %s: %s\n",
										m_id.asString().c_str(),
										str[0].c_str(),
										node->m_id.asString().c_str(),
										str[1].c_str());
							m_clash = true;
						}
					}
					else
					{
						M_ASSERT(m_numBypasses > 0);
						delete node;
						m_nodeLookup.erase(board.hash());
						m_branches.pop_back();
						--m_numBypasses;
					}
				}
				else if (!rc)
				{
					m_branches.pop_back();
					--m_numBypasses;
				}
			}

			board.undoMove(move);
		}

		if (mstl::is_even(size))
			moves.rotate(0, size - i, size);
		else if (i < size)
			moves.swap(i, size - 1);
	}

	if (size > 1 && mstl::is_odd(size))
		moves.rotate(0, size - 1, size);

	if (m_numBypasses == numBypasses)
		return false;

	if (m_branches.size() - m_numBypasses > 1)
	{
		Node const* leaf = findBypassLeaf();
		mstl::string str[3];

		m_line.dump(str[0]);
		root->m_line.dump(str[1]);
		leaf->m_line.dump(str[2]);
		m_clash = true;

		fprintf(	stderr,
					"clash: %s: %s\n       %s: %s\n                (%s)\n",
					m_id.asString().c_str(),
					str[0].c_str(),
					root->m_id.asString().c_str(),
					str[1].c_str(),
					str[2].c_str());
	}

	return true;
}


void Node::buildBypasses(Board& board, unsigned weight)
{
	MoveLine moves;

	buildBypassSequence(m_id, board, moves);

	if (moves.size() > 2)
	{
		if (makeBypassGraph(board, moves, this, moves.size(), weight))
			++m_bypassCount;
	}

	for (auto const& succ : m_branches)
	{
		if (!succ.transposition && !succ.bypass)
		{
			Move m(succ.move);
			board.prepareUndo(m);
			board.doMove(m);
			succ.node->buildBypasses(board, succ.weight);
			board.undoMove(m);
		}
	}

	m_maxBranches = mstl::max(m_maxBranches, m_branches.size());
}


void Node::buildBypasses()
{
	Board startBoard(Board::standardBoard(variant::Normal));
	buildBypasses(startBoard, 0);
	generateBypassTransitions(startBoard);
}


void Node::generateBypassTransitions(Board& board)
{
	if (m_done)
		return;

	m_done = true;

	MoveList more;
	board.generateMoves(more);

	for (Move m : more)
	{
		if (!findMove(m) && board.isValidMove(m, move::DontAllowIllegalMove))
		{
			board.prepareUndo(m);
			board.prepareForPrint(m, Board::ExternalRepresentation);
			board.doMove(m);

			HashSet::const_iterator p = m_bypassSet.find(board.hash());

			if (p != m_bypassSet.end())
			{
				mstl::string s1, s2, s3;

				m_line.dump(s1);
				p->second->m_line.dump(s2);
				m.printSAN(s3, protocol::Scidb, encoding::Latin1);

				// TODO: resolve bypass ambiguities:
				//
				//   # transition 'Bb2' found from '1.c4 b6 2.Nc3 Bb7 3.Nf3 e6 4.g3 f5 5.Bg2 Nf6 6.O-O Be7 7.b3 O-O'
				//   to bypass '1.Nf3 f5 2.b3 Nf6 3.Bb2 e6 4.g3 b6 5.Bg2 Bb7 6.O-O Be7 7.c4 O-O 8.Nc3'
				//
				// A10 1.c4 b6 2.Nc3 Bb7 3.Nf3 e6 4.g3 f5 5.Bg2 Nf6 6.O-O Be7 7.b3 O-O
				// A04 1.Nf3 f5 2.b3 Nf6 3.Bb2 e6 4.g3 b6 5.Bg2 Bb7 6.O-O Be7 7.c4 O-O 8.d4 d6 9.Nc3 Ne4 10.Qc2 Nxc3
				//
				// Shorten bypass sequence:
				//   A10 1.c4 b6 2.Nc3 Bb7 3.Nf3 e6 4.g3 f5 5.Bg2 Nf6 6.O-O Be7 7.b3 O-O
				// and add new line:
				//   A04 1.c4 b6 2.Nc3 Bb7 3.Nf3 e6 4.g3 f5 5.Bg2 Nf6 6.O-O Be7 7.b3 O-O 8.Bb2 d6 9.d4 Ne4 10.Qc2 Nxc3
				fprintf(	stderr,
							"# transition '%s' found from '%s' to bypass\n%s\n",
							s3.c_str(), s1.c_str(), s2.c_str());

				Branch& succ = m_branches.push_back();
				succ.move = m;
				succ.transposition = true;
				succ.bypass = true;
				succ.weight = 0;
				succ.node = const_cast<Node*>(p->second);
				++m_numBypasses;
			}

			board.undoMove(m);
		}
	}

	for (auto& branch : m_branches)
	{
		if (!branch.bypass && !branch.transposition)
		{
			Move m(branch.move);
			board.prepareUndo(m);
			board.doMove(m);
			branch.node->generateBypassTransitions(board);
			board.undoMove(m);
		}
	}

	m_done = false;
}


void Node::checkConsistence(Board& board, HashSet& hashSet, Path path)
{
	using MoveSet = mstl::set<uint16_t>;

	if (m_done)
		return;

	MoveSet moveSet;

	::PathNode::lookup(path);

	m_done = true;

	if (m_branches.empty())
	{
		if (!hashSet.insert(HashSet::value_type(board.hash(), this)).second)
		{
			Node const* that = hashSet.find(board.hash())->second;

			if (this != that)
			{
				fprintf(stderr, "hash clash: %u -- %u\n", this->m_key, that->m_key);
				exit(1);
			}
		}
	}

	for (auto& branch : m_branches)
	{
		if (!moveSet.insert_unique(branch.move.field()).second)
		{
			fprintf(stderr, "move exists twice\n");
			exit(1);
		}

		Path myPath(path);

		M_ASSERT(board.isValidMove(branch.move, move::DontAllowIllegalMove));

		if (branch.useBits)
			myPath.append(branch.bits);

		board.prepareUndo(branch.move);
		board.doMove(branch.move);

		if (branch.transposition && m_maxMainKey < branch.node->key())
		{
			mstl::string s1, s2;
			m_line.dump(s1);
			branch.node->m_line.dump(s2);
			fprintf(	stderr,
						"%s (%s): main key expected in transposition: %u (%s)\n",
						m_id.asString().c_str(),
						s1.c_str(),
						branch.node->m_key,
						s2.c_str());
			exit(1);
		}

		branch.node->checkConsistence(board, hashSet, myPath);
		board.undoMove(branch.move);
	}

	m_done = false;
}


void Node::sort(Branches& list)
{
	if (list.empty())
		return;

	// [@KQRBNP][a-h][1-8]

	unsigned n = list.size() - 1;

	int less = color::isWhite(list[0].move.color()) ? -1 : +1;

	for (unsigned i = 0; i < n; ++i)
	{
		unsigned index = i;
		Move lhs = list[index].move;

		for (unsigned k = i + 1; k <= n; ++k)
		{
			Move rhs = list[k].move;

			if (lhs.isPieceDrop())
			{
				if (	rhs.isPieceDrop()
					&& (	rhs.dropped() < lhs.dropped()
						|| (	rhs.dropped() == lhs.dropped()
							&& ::compare(rhs.from(), lhs.from(), less))))
				{
					lhs = list[index = k].move;
				}
			}
			else if (rhs.isPieceDrop())
			{
				if (	!lhs.isPieceDrop()
					|| rhs.dropped() < lhs.dropped()
					|| (	rhs.dropped() == lhs.dropped()
						&& ::compare(rhs.from(), lhs.from(), less)))
				{
					lhs = list[index = k].move;
				}
			}
			else if (lhs.isCastling())
			{
				if (rhs.isCastling() && rhs.isShortCastling())
					lhs = list[index = k].move;
			}
			else if (rhs.isCastling())
			{
				if (!lhs.isCastling() || lhs.isShortCastling())
					lhs = list[index = k].move;
			}
			else
			{
				if (	rhs.moved() < lhs.moved()
					|| (	rhs.moved() == lhs.moved()
						&& (	::compare(rhs.from(), lhs.from(), less)
							|| (	rhs.from() == lhs.from()
								&& (	::compare(rhs.to(), lhs.to(), less)
									|| (	rhs.to() == lhs.to()
										&& rhs.promoted() < lhs.promoted()))))))
				{
					lhs = list[index = k].move;
				}
			}
		}

		if (index > i)
			mstl::swap(list[index], list[i]);
	}
}

#if 0

void Node::findTranspositions(Board& board)
{
	if (m_done)
		return;

	m_done = true;

	Branches newBranches;
	MoveList more;

	board.generateMoves(more);

	for (Move m : more)
	{
		if (!findMove(m))
		{
			board.prepareUndo(m);
			board.doMove(m);

			if (board.isLegal())
			{
				uint64_t hash = board.hash();
				Lookup::const_iterator e = m_nodeLookup.find(hash);

				if (e != m_nodeLookup.end())
				{
					newBranches.push_back(Branch(m, e->second, Branch::Transposition));
					m_nodeLookup[hash] = e->second;
				}
			}

			board.undoMove(m);
		}
	}

	for (auto& branch : m_branches)
	{
		if (!branch.transposition)
		{
			board.prepareUndo(branch.move);
			board.doMove(branch.move);
			branch.node->findTranspositions(board);
			board.undoMove(branch.move);
		}
	}

	m_branches += newBranches;
	m_done = false;
}

#endif

auto Node::findMissingMainlines() const -> bool
{
	bool rc = false;

	if (!m_final && m_branches.size() - m_numBypasses > 1)
	{
		char const* comma = "";

		fprintf(stderr, "missing mainline in line %u, branches to ", m_lineNo);

		for (auto const& branch : m_branches)
		{
			if (branch.node->m_key != m_key)
			{
				fprintf(stderr, "%s%u", comma, branch.node->m_lineNo);
				comma = ", ";
			}
		}

		fprintf(stderr, "\n");
		rc = true;
	}

	for (auto const& branch : m_branches)
	{
		if (!branch.transposition && branch.node->findMissingMainlines())
			rc = true;
	}

	return rc;
}


auto Node::findUnresolvedNodes(BranchStack& stack) -> bool
{
	if (m_done)
	{
		fprintf(stderr, "fatal(%s): recursion in transition found:", m_id.asString().c_str());

		for (auto const branch : stack)
		{
			mstl::string s;
			branch->move.printSAN(s, protocol::Scidb, encoding::Latin1);
			fprintf(stderr, " %s (%s)", s.c_str(), branch->node->m_id.asString().c_str());
		}

		fprintf(stderr, "\n");
		::exit(1);
	}

	m_done = true;

	bool rc = false;

	for (auto const& branch : m_branches)
	{
		if (!branch.transposition)
		{
			if (branch.node->m_resolve)
			{
				mstl::string s;
				branch.move.printSAN(s, protocol::Scidb, encoding::Latin1);
				fprintf(stderr, "unresolved node in line %u: %s", branch.node->m_lineNo, s.c_str());
				rc = true;
			}
			else
			{
				stack.push(&branch);
				if (branch.node->findUnresolvedNodes(stack))
					rc = true;
				stack.pop();
			}
		}
	}

	return rc;
}


auto Node::findUnresolvedNodes() -> bool
{
	BranchStack stack;
	bool rc = findUnresolvedNodes(stack);
	reset();
	return rc;
}


void Node::renumber(Numbers& numbers)
{
	if (m_id)
	{
		Id::Code basic = m_id.basic();
		unsigned& subcode = numbers[basic];

		m_id = Id(basic, subcode);

		if (shouldBeFinal())
			subcode++;
	}

	for (auto& branch : m_branches)
	{
		if (!branch.transposition)
			branch.node->renumber(numbers);
	}
}


void Node::renumber()
{
	Numbers numbers(Id::Num_Basic_Codes, 0u);
	renumber(numbers);
}



auto Node::isParent(Node const* node) const -> bool
{
	for (Node const* n = m_parent; n; n = n->m_parent)
	{
		if (n == node)
			return true;
	}

	return false;
}


void Node::addBacklink(Node* node)
{
	for (auto const& backlink : m_backlinks)
	{
		if (backlink.node == node)
			return;
	}

	m_backlinks.push_back(node);
	m_maxBackLinks = mstl::max(m_maxBackLinks, m_backlinks.size());
	++m_backlinkCount;
}


void Node::extend(Board& board, MoveLine& line)
{
	using Bits = mstl::bitfield<uint64_t>;

	static_assert(MoveLine::Maximum_Moves <= 64, "bit field is too small");

	if (board.cannotMove() || (m_equal && !m_enPassant))
		return;

	MoveList	more;
	Bits		bits;

	board.generateMoves(more);

	for (unsigned k = 0, n = more.size(); k < n; ++k)
	{
		Move move(more[k]);

		if (m_equal)
		{
			if (move.isEnPassant())
				bits.set(k);
		}
		// TODO: possibly we should not allow to move a piece a second time; e.g. Bd3-d4
		else if (	m_moveCache[move.field()] == 0
					|| !::isReversalMove(line, move)
					|| ::isEvasingMove(board, move))
		{
			bits.set(k);
		}
	}

	for (unsigned k = bits.find_first(); k != Bits::npos; k = bits.find_next(k))
	{
		Move move(more[k]);

		if (::isValidMove(board, move))
		{
			board.prepareUndo(move);
			board.prepareForPrint(move, Board::ExternalRepresentation);
			board.doMove(move);

			if (board.isLegal())
			{
				uint64_t hash = board.hash();
				Lookup::const_iterator i = m_nodeLookup.find(hash);
				Node *node = nullptr;

				if (i != m_nodeLookup.end())
					node = i->second;
				else if ((i = m_nodeLookup2.find(hash)) != m_nodeLookup2.end())
					node = i->second;

				if (node && node->m_parent != this)
				{
					MoveLine line(m_line);
					line.append(move);

					if (!find(move))
					{
						if (!m_rules.omit(m_id, line))
						{
							if (::isGoodMove(board))
							{
								if (m_rules.transpositionIsAllowed(m_id, node->m_id, line))
								{
									m_branches.push_back(Branch(move, node, Branch::Transposition));
									m_branches.back().setAll();

									if (!m_final)
										m_final = m_isExtension = true;

									if (isParent(node))
										m_branches.back().recursion = true;
								}
								else
								{
									mstl::string s1, s2;
									fprintf(	stderr,
												"cannot extend from %s (%u) to %s (%u):\n"
												"   %s\n"
												"-> %s\n",
												m_id.asString().c_str(),
												m_lineNo,
												node->m_id.asString().c_str(),
												node->m_lineNo,
												line.dump(s1).c_str(),
												node->m_line.dump(s2).c_str());
								}
							}
							else if (m_rules.transpositionIsAllowed(m_id, node->m_id, line))
							{
								mstl::string s1, s2;
								fprintf(	stderr,
											"cannot use transpositon rule from %s (%u) to %s (%u):\n"
											"   %s\n"
											"-> %s\n",
											m_id.asString().c_str(),
											m_lineNo,
											node->m_id.asString().c_str(),
											node->m_lineNo,
											line.dump(s1).c_str(),
											node->m_line.dump(s2).c_str());
							}
						}
					}
				}
			}

			board.undoMove(move);
		}
	}

	if (line.size() < MoveLine::Maximum_Moves - 1)
	{
		for (auto& branch : m_branches)
		{
			if (!branch.transposition)
			{
				Move move(branch.move);
				Move reversal(Move::genMove(move.to(), move.from(), move.moved(), piece::None));

				board.prepareUndo(move);
				board.doMove(move);
				++m_moveCache[reversal.field()];
				line.append(move);
				branch.node->extend(board, line);
				line.pop();
				--m_moveCache[reversal.field()];
				board.undoMove(move);
			}
		}
	}
}


void Node::extend()
{
	Board board(Board::standardBoard(variant::Normal));
	MoveLine line;

	::memset(m_moveCache, 0, sizeof(m_moveCache));
	extend(board, line);
	m_extended = true;
}


auto Node::visited() const -> bool
{
	Node const* node = this;

	for ( ; !node->m_root; node = node->m_parent)
	{
		if (node->m_visited)
			return true;
	}

	return false;
}


void Node::printNode(char const* arrow) const
{
	mstl::string s;

	fprintf(	stderr,
				"%s %s (%-5u): %s\n",
				arrow,
				m_id.asShortString().c_str(),
				m_lineNo,
				m_line.dump(s).c_str());
}


auto Node::checkLines(
	mstl::vector<uint8_t>& ecoSet,
	mstl::vector<Node const*>& path,
	mstl::vector<uint8_t>& ecoGroup) const
	-> bool
{
	bool rc = true;

	if (!m_root)
		m_visited += 1;

	if (m_final && !m_rules.isValid(m_id, m_line))
	{
		mstl::string s;
		fprintf(stderr, "invalid ECO code for line %s (%u)\n", m_line.dump(s).c_str(), m_lineNo);
		rc = false;
	}

	if (!m_branches.empty())
	{
		Id::Code		eco	= m_id.basic();
		Id::Group	group	= m_id.group();

		ecoSet[eco] += 1;

		for (auto const& branch : m_branches)
		{
			Id::Code		otherEco		= branch.node->m_id.basic();
			Id::Group	otherGroup	= branch.node->m_id.group();

			path.push_back(branch.node);

			if (group != otherGroup && ecoGroup[unsigned(otherGroup)])
			{
				mstl::string s;
				Node const* prevNode = nullptr;

				fprintf(stderr, "cyclic path detected:\n");

				for (Node const* node : path)
				{
					node->printNode(prevNode ? (node->m_parent == prevNode ? "->" : "=>") : "  ");
					prevNode = node;
				}
			}
			else if (!m_equal && !branch.node->m_equal && otherEco != eco && ecoSet[otherEco])
			{
				mstl::string s1, s2;

				fprintf(	stderr,
							"transposition back from %s to %s:\n"
							"   %s (%u)\n"
							"-> %s (%u)\n",
							m_id.asShortString().c_str(),
							branch.node->m_id.asShortString().c_str(),
							m_line.dump(s1).c_str(),
							m_lineNo,
							branch.node->m_line.dump(s2).c_str(),
							branch.node->m_lineNo);
			}
			else if (branch.transposition)
			{
				// The following test is a bit superfluous, because a transposition warning
				// will already be printed while parsing, but here the warning contains a
				// complete backtrace.

				if (	eco == otherEco
					&& !m_equal
					&& !branch.node->m_isExtension
					&& branch.node->visited())
				{
					fprintf(stderr, "re-entering line:\n");

					unsigned i = 0;

					for ( ; path[i]->m_id.basic() != otherEco; ++i)
						M_ASSERT(i < path.size());

					Node const* prevNode = nullptr;

					for ( ; i < path.size(); ++i)
					{
						Node const* node = path[i];
						node->printNode(prevNode ? (node->m_parent == prevNode ? "->" : "=>") : "  ");
						prevNode = node;
					}
				}
			}
			else if (!branch.bypass && !branch.node->checkLines(ecoSet, path, ecoGroup))
			{
				rc = false;
			}

			path.pop_back();
		}

		ecoSet[eco] -= 1;
	}

	if (!m_root)
		m_visited -= 1;

	return rc;
}


auto Node::checkLines() const -> bool
{
	mstl::vector<uint8_t> ecoSet(Id::Num_Basic_Codes, 0u);
	mstl::vector<uint8_t> ecoGroup(Id::Num_Groups, 0u);
	mstl::vector<Node const*> path;

	return checkLines(ecoSet, path, ecoGroup);
}


auto Node::checkUnusedRules() const -> bool
{
	return m_rules.traceUnusedRules();
}


auto Node::checkTranspositions(bool extended) -> bool
{
	if (m_conflict)
		return true;
	
	bool rc = true;

	if (m_equal)
	{
		if (!m_hasTwin)
		{
			mstl::string s;

			fprintf(stderr, "line %u (%s) %s: don't has equal position\n",
				m_lineNo, m_id.asString().c_str(), s.c_str());
			rc = false;
			m_conflict = true;
		}

		if (m_enPassant)
		{
			Branch const* nullBranch = m_branches.size() > 0 ? &m_branches[0] : nullptr;
			Branch const* epBranch   = m_branches.size() > 1 ? &m_branches[1] : nullptr;

			if (nullBranch && nullBranch->move.isEnPassant())
				mstl::swap(nullBranch, epBranch);

			unsigned count = 0;

			if (nullBranch)
				count += 1;
			if (epBranch)
				count += 1;

			if (!nullBranch)
			{
				mstl::string s;

				m_line.dump(s);
				fprintf(stderr, "line %u (%s) %s: missing null branch\n",
					m_lineNo, m_id.asString().c_str(), s.c_str());
				rc = false;
				m_conflict = true;
			}
			if (extended && !epBranch)
			{
				mstl::string s;

				m_line.dump(s);
				fprintf(stderr, "line %u (%s) %s: missing en passant continuation\n",
					m_lineNo, m_id.asString().c_str(), s.c_str());
				rc = false;
				m_conflict = true;
			}
			if (m_branches.size() > count)
			{
				Branch const* branch = nullptr;

				for (auto const& b : m_branches)
				{
					if (!b.move.isNull() && !b.move.isEnPassant())
					{
						branch = &b;
						break;
					}
				}

				M_ASSERT(branch);

				mstl::string s;

				fprintf(	stderr,
							"line %u: line %s (%u) cannot have successor (except en-passant move)\n",
							branch->node->m_lineNo,
							m_line.dump(s).c_str(),
							m_lineNo);
				m_conflict = true;
			}
		}
		else if (!m_branches.empty())
		{
			mstl::string s;

			fprintf(	stderr,
						"line %u: line %s (%u) cannot have successor\n",
						m_lineNo,
						m_line.dump(s).c_str(),
						m_lineNo);
			m_conflict = true;
		}
	}
	else if (!m_branches.empty())
	{
		for (auto const& branch : m_branches)
		{
			if (m_equal && m_enPassant)
			{
				mstl::string s;

				fprintf(	stderr,
							"line %u: line %s (%u) cannot have successor (except en-passant move)\n",
							branch.node->m_lineNo,
							m_line.dump(s).c_str(),
							m_lineNo);
				m_conflict = true;
			}

			M_ASSERT(!branch.move.isNull());

			MoveLine line(m_line);
			line.append(branch.move);

			if (!m_rules.transpositionIsAllowed(m_id, branch.node->m_id, line))
			{
				unsigned match = m_line.match(branch.node->m_line);

				mstl::string s1, s2;

				if (match > 0)
				{
					m_line.dump(s1, 0, match);
					s1.append(" | ");
				}
				line.dump(s1, match);

				if (match > 0)
				{
					branch.node->m_line.dump(s2, 0, match);
					s2.append(" | ");
				}
				branch.node->m_line.dump(s2, match);

				fprintf(	stderr,
							"transposition from %s (%5u) to %s (%5u): %s -> %s\n",
							m_id.asString().c_str(),
							m_lineNo,
							branch.node->m_id.asString().c_str(),
							branch.node->m_lineNo,
							s1.c_str(),
							s2.c_str());

				m_conflict = true;
				rc = false;
			}

			if (!branch.transposition && !branch.node->checkTranspositions(extended))
				rc = false;
		}
	}

	return rc;
}


void Node::relinkBranchesToEqualLines(Board& board)
{
	if (!m_done)
	{
		for (auto& branch : m_branches)
		{
			if (!branch.node->m_equal)
			{
				m_done = true;
				board.prepareUndo(branch.move);
				board.prepareForPrint(branch.move, Board::ExternalRepresentation);
				board.doMove(branch.move);
				branch.node->relinkBranchesToEqualLines(board);
				board.undoMove(branch.move);
				m_done = false;
			}
#if 0 // XXX
			else if (!branch.node->m_enPassant)
			{
				board.prepareUndo(branch.move);
				board.prepareForPrint(branch.move, Board::ExternalRepresentation);
				board.doMove(branch.move);

				auto i = m_nodeLookup2.find(board.hashNoEP());

				M_ASSERT(i != m_nodeLookup2.end());
				branch.node = i->second;
				branch.transposition = true;
				board.undoMove(branch.move);
			}
#endif
		}
	}
}


auto Node::parse(Reader& reader, Node* root, unsigned flags) -> Node*
{
	MoveLine			line;
	Transitions		transitions;
	Name				name;
	mstl::string	prologue;
	mstl::string	comment;
	char				sign('\0');
	unsigned			color(0);
	Id					id;

	if (!root)
		root = new Node;

	while ((id = reader.readLine(line, transitions, name, prologue, comment, sign, root)))
	{
		Board board(Board::standardBoard(variant::Normal));

		unsigned	nameRef	= Name::insert(name);
		Node*		node		= root;

		if (line.isEmpty())
			m_nodeLookup[board.hash()] = root;

		m_maxMainKey = ++m_nodeCount;

		for (unsigned i = 0; i < line.size(); ++i)
		{
			Move& move = line[i];

			if (mstl::is_even(++color))
				move.setColor(color::Black);

			board.prepareForPrint(move, Board::ExternalRepresentation);
			board.doMove(move);

			Branch*	succ(node->findSuccessor(move, id));
			Node*		nextNode(nullptr);

			if (!succ || succ->node->m_resolve)
			{
				uint64_t hash(board.hash());
				Node*&	n(succ ? succ->node : m_nodeLookup[hash]);

				if (!n || n->m_resolve)
				{
					if (!n)
						m_nodeLookup[hash] = n = new Node(node);
					else
						n->m_parent = node;

					if (flags & Merge_Line)
					{
						if (n->m_parent)
							n->m_line.fill(n->m_parent->m_line, n->m_parent->m_line.size());

						n->m_line.append(move);
						n->m_isMerged = true;

						if (flags & Inherit_Name)
							n->m_isExtension = true;
					}
					else
					{
						n->m_line.fill(line, i + 1);
					}

					n->m_id = node->m_id;
					n->m_key = m_nodeCount;
					n->m_lineNo = reader.lineNo();
					n->m_nameRef = node->m_nameRef;
					n->m_resolve = false;

					if (!succ)
					{
						M_ASSERT(!node->find(move));

						node->m_branches.push_back(Branch(move, n, Branch::NextMove));

						if (reader.isLineReader())
						{
							if (i < line.size() - 1)
								node->m_branches.back().setId(n->m_id);

							node->m_branches.back().setId(id);
						}
					}
				}
				else if (!succ && !(flags & Merge_Line) && ::isValidMove(node->m_line, move))
				{
					// We've found a transposition
					M_ASSERT(!node->find(move));

					node->m_branches.push_back(Branch(move, n, Branch::Transposition));
					n->addBacklink(node);
				}

				static Id const D00 = Id("D00");

				static Move const Ng8f6	= Move::genKnightMove(sq::g8, sq::f6, piece::None);
				static Move const d7d5	= Move::genTwoForward(sq::d7, sq::d5);

				//   D00 1.d4 d5
				// should be dumped before
				//   D00 1.d4 Nf6 2.Bg5 d5
				// This does not happen without re-sorting because
				//   A45 1.d4 Nf6
				// is parsed prior to D00.
				if (id == D00 && i == 1 && move == d7d5)
				{
					for (unsigned i = 0, n = node->m_branches.size() - 1; i < n; ++i)
					{
						if (node->m_branches[i].move == Ng8f6)
							mstl::swap(node->m_branches[i], node->m_branches.back());
					}
				}

				nextNode = n;
			}
			else
			{
				nextNode = succ->node;
			}

			M_ASSERT(nextNode);

			if (	(flags & Check_Ambiguity)
				&& nextNode->m_key != m_nodeCount
				&& !nextNode->m_conflict
				&& mstl::is_even(i + 1) == mstl::is_even(nextNode->m_line.size())
				&& (	nextNode->m_line.size() < i + 1
					|| nextNode->m_line.match(line, i + 1) != i + 1))
			{
				if (nextNode->m_preParsed)
				{
					nextNode->m_checkLine = false;
					nextNode->m_preParsed = false;
				}
				else if (nextNode->m_checkLine)
				{
					char const*		what(i == line.size() ? "duplicate" : "ambiguous");
					mstl::string	s1, s2;

					fprintf(	stderr,
								"%s: %s (%u)\n           %s (%u)\n",
								what,
								line.dump(s1, 0, i + 1).c_str(),
								reader.lineNo(),
								nextNode->m_line.dump(s2).c_str(),
								nextNode->m_lineNo);
					reader.countConflict();
					nextNode->m_conflict = true;
				}
			}

			m_maxBranches = mstl::max(m_maxBranches, unsigned(node->m_branches.size()));
			node = nextNode;
		}

		node->m_final = sign != Reader::Equal;
		node->m_enPassant = board.enPassantSquare() != sq::Null;

		{
			uint64_t hash(board.hashNoEP());
			Node* n = nullptr;

			if (sign == Reader::Equal)
			{
				auto i = m_nodeLookup2.find(hash);

				if (i == m_nodeLookup2.end())
				{
					auto i = m_nodeLookup.find(hash);

					if (i != m_nodeLookup.end())
						n = i->second;
				}
				else
				{
					n = i->second;
				}
			}

			if (!n)
			{
				if (board.hash() != hash)
				{
					Node*& nn(m_nodeLookup2[hash]);

					if (!nn)
						nn = node;
					else
						n = nn;
				}
				else
				{
					auto i = m_nodeLookup2.find(hash);

					if (i != m_nodeLookup2.end())
						n = i->second;
				}
			}

			if (n)
			{
				if (sign == Reader::Equal)
				{
					if (n->m_equal)
					{
						mstl::string s1, s2;

						fprintf(	stderr,
									"Both lines are signed as equal: %s (%u)\n"
									"                                %s (%u)\n",
									node->m_line.dump(s1).c_str(),
									node->m_lineNo,
									n->m_line.dump(s2).c_str(),
									n->m_lineNo);
						n->m_conflict = node->m_conflict = true;
					}
					if (n != node)
					{
						if (node->m_enPassant)
						{
							Move null(Move::null());
							board.prepareForPrint(null, Board::ExternalRepresentation);
							node->m_branches.push_back(Branch(null, n, Branch::Transposition));
						}
						node->m_hasTwin = true;
					}
					m_nodeLookup2[hash] = n;
				}
				else if (n->m_equal)
				{
					if (n->m_enPassant)
					{
						Move null(Move::null());
						board.prepareForPrint(null, Board::ExternalRepresentation);
						n->m_branches.push_back(Branch(null, node, Branch::Transposition));
					}
					m_nodeLookup2[hash] = node;
					n->m_hasTwin = true;
				}
				else
				{
					mstl::string s1, s2;

					fprintf(	stderr,
								"Equal: %s (%u)\n"
								"       %s (%u)\n",
								node->m_line.dump(s1).c_str(),
								node->m_lineNo,
								n->m_line.dump(s2).c_str(),
								n->m_lineNo);
				}
			}
		}

		for (auto const& trans : transitions)
		{
			Move move(trans.move);

			board.prepareUndo(move);
			board.prepareForPrint(move, Board::ExternalRepresentation);
			board.doMove(move);

			Node* succ = node->find(move);

			if (!succ)
			{
				Node*& n = m_nodeLookup[board.hash()];

				if (!n)
				{
					n = new Node(nullptr);
					n->m_lineNo = reader.lineNo();
					n->m_resolve = true;
					n->m_id = trans.id;
				}

				M_ASSERT(!node->find(move));
				M_ASSERT(::isValidMove(node->m_line, move));

				node->m_branches.push_back(
					Branch(move, n, trans.transposition ? Branch::Transposition : Branch::NextMove));

				if (trans.transposition)
					n->addBacklink(node);

				if (reader.isLineReader())
					node->m_branches.back().setAll();
			}

			board.undoMove(move);

			if (trans.transposition)
				++m_transpositionCount;
		}

		if (::isprint(sign))
		{
			node->m_sign = sign;
		}
		else if (sign == Reader::PreParsed)
		{
			node->m_preParsed = true;
			node->m_checkLine = false;
		}
		else if (sign == Reader::Equal)
		{
			node->m_equal = true;
		}

		if (!(flags & Merge_Line))
			node->m_id = id;

		if (flags & Merge_Line)
		{
			node->m_isBypass = false;

			for (Node* p = node->m_parent; p && p->m_isBypass; p = p->m_parent)
			{
				Branch* branch = p->findSuccessor(node);
				M_ASSERT(branch);

				if (branch->bypass)
				{
					branch->bypass = false;
					--p->m_numBypasses;
				}

				p->m_isBypass = false;
				node = p;
			}
		}

		if (node->m_prologue.empty())
			node->m_prologue.swap(prologue);
		node->m_comment.swap(comment);

		if (nameRef == Name::Invalid)
		{
			if (!node->m_parent)
			{
				fprintf(stderr, "Empty moves in line %u\n", reader.lineNo());
				reader.countConflict();
			}

			nameRef = node->m_nameRef;
		}

		// TODO: we have to give a warning in these cases:
		// --------------------------------------------------------------------
		// 1.d3 					-> 1.d3					Mieses Opening
		// 1.d3 Nf6				-> 1.d3 Nf6				Mieses Opening
		//	1.d3 Nf6 2.c4		-> 1.c4 Nf6 2.d3		English: Anglo-Indian Defence
		//	1.d3 Nf6 2.c4 d6	-> 1.d3 d6 2.c4 Nf6	Mieses Opening

		if (node != root && node->m_key != m_nodeCount)
		{
			if ((flags & Merge_Line))
			{
				if (nameRef != Name::Invalid && nameRef != node->m_nameRef)
				{
					M_ASSERT(node->m_nameRef != Name::Invalid);

					Name* myName = Name::lookup(node->m_nameRef);
					Name const* newName = Name::lookup(nameRef);

					if (!myName->hasMark() && newName->lastRef() != myName->lastRef())
					{
						fprintf(	stderr,
									"Change of name in %s: %s (%u) -> %s (%u)\n",
									id.asShortString().c_str(),
									Name::lookup(node->m_nameRef)->opening().c_str(),
									node->m_lineNo,
									Name::lookup(nameRef)->opening().c_str(),
									reader.lineNo());
						myName->setMark();
					}
				}
			}
			else
			{
				mstl::string s1, s2;
				line.dump(s1);

				if (node->m_checkLine)
				{
					fprintf(	stderr,
								"conflict:  %s (%u)\n           %s (%u)\n",
								s1.c_str(),
								reader.lineNo(),
								node->m_line.dump(s2).c_str(),
								node->m_lineNo);
					reader.countConflict();
				}
				else
				{
					node->m_id = id;
					node->m_preParsed = false;

					if (name.isEmpty())
						name = node->m_parent->name();

					node->setOpeningFromParent(name);
				}
			}
		}

		node->m_nameRef = nameRef;
		line.clear();
		transitions.clear();
		name.clear();
		prologue.clear();
		comment.clear();
		sign = '\0';
	}

	if (!root)
		M_RAISE("file is empty");

	if (!(flags & Merge_Line))
		root->m_epilogue.assign(reader.epilogue());
	
	Board board(Board::standardBoard(variant::Normal));
	root->relinkBranchesToEqualLines(board);

	return root;
}


void Node::doTraversal(Visitor& visitor, unsigned& count) const
{
	if (++count > 300000)
	{
		fprintf(stderr, "overflow (due to an undetected cycle?)\n");
		::exit(1);
	}

	if (visitor.level() > opening::Max_Line_Length)
	{
		fprintf(	stderr,
					"maximal level exceeded in %s: %u\n",
					m_id.asString().c_str(),
					unsigned(opening::Max_Line_Length));
		::exit(1);
	}

	m_done = true;

	for (auto const& branch : m_branches)
	{
		// we need a little hack for e.p. moves
		if (branch.move.isEnPassant())
			const_cast<Board&>(visitor.board()).setEnPassantSquare(branch.move.to());

		visitor.board().prepareForPrint(const_cast<Move&>(branch.move), Board::ExternalRepresentation);
	}

	visitor.visit(*this);

	for (auto const& branch : m_branches)
	{
		if (visitor.branch(branch))
		{
			visitor.doMove(const_cast<Move&>(branch.move));
			branch.node->doTraversal(visitor, count);
			visitor.undoMove(branch.move);
			visitor.finishBranch(branch);
		}
	}

	m_done = false;
}


void Node::traverse(Visitor& visitor) const
{
	unsigned count = 0;

	visitor.reset();
	doTraversal(visitor, count);
}

// vi:set ts=3 sw=3:
