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

#ifndef _eco_node_included
#define _eco_node_included

#include "eco_id.h"
#include "eco_branch.h"
#include "eco_path.h"
#include "eco_path_node.h"
#include "eco_transition.h"
#include "eco_rules.h"

#include "db_move_buffer.h"

#include "m_map.h"
#include "m_set.h"
#include "m_stack.h"
#include "m_vector.h"
#include "m_string.h"

namespace db   { class Board; }
namespace mstl { class bitset; }

namespace eco {

class Name;
class Reader;
class Visitor;
class PathNode;

class Node
{
public:

	static constexpr unsigned Check_Ambiguity	= 1 << 0;
	static constexpr unsigned Inherit_Name		= 1 << 1;
	static constexpr unsigned Merge_Line		= 1 << 2;

	struct Backlink
	{
		Backlink() :count(0), done(false), node(0) {}
		Backlink(Node* n) :count(0), done(false), node(n) {}

		uint32_t	count:31;
		uint32_t	done:1;
		Node*		node;
	};

	using Key			= uint32_t;
	using HashSet		= mstl::map<uint64_t,Node const*>;
	using Backlinks	= mstl::vector<Backlink>;
	using Branches		= mstl::vector<Branch>;
	using BitLengths	= Path::BitLenghtList;

	Node();
	Node(Node* parent);
	~Node();

	auto parent() const -> Node*;
	auto find(db::Move const& move) const -> Node*;
	auto findBypass(db::Move const& move) const -> Node*;

	auto startOfSequence() const -> Node const*;
	auto firstBranch() const -> Branch const&;

	auto alreadyDone() const -> bool;
	auto isBypass() const -> bool;
	auto isFinal() const -> bool;
	auto isEqual() const -> bool;
	auto isRoot() const -> bool;
	auto isExtension() const -> bool;
	auto isEqual(db::MoveLine const& line) const -> bool;
	auto isParent(Node const* node) const -> bool;
	auto isLastBranch() const -> bool;
	auto shouldBeFinal() const -> bool;
	auto checkTranspositions() -> bool;
	auto checkLines() const -> bool;
	auto checkUnusedRules() const -> bool;

	auto countTranspositionDepth() const -> unsigned;
	auto countTranspositionLength() const -> unsigned;
	auto countMaxPathNodes() const -> unsigned;
	auto countMoves() const -> unsigned;
	auto countBranches() const -> unsigned;
	auto lineNo() const -> unsigned;
	auto numBypasses() const -> unsigned;
	auto numBranches() const -> unsigned;
	static auto countCodes() -> unsigned;
	static auto countLines() -> unsigned;
	static auto countMainCodes() -> unsigned;
	static auto countBacklinks() -> unsigned;

	auto prologue() const -> mstl::string const&;
	auto comment() const -> mstl::string const&;
	auto sign() const -> char;

	void done();
	void reset();

	auto id() const -> Id;
	auto key() const -> Key;
	auto line() const -> db::MoveLine const&;
	auto name() const -> Name const&;
	auto parentName() const -> Name const&;
	auto nameRef() const -> Name const*;
	auto name(unsigned n) const -> mstl::string const&;
	auto length() const -> unsigned;
	auto successors() const -> Branches const&;
	auto successors() -> Branches&;
	auto backlink(unsigned i) const -> Node const&;
	auto backlinks() const -> Backlinks const&;
	auto finalNode() const -> Node const*;
	auto findId(Id id) const -> Node const*;
	auto findSuccessor(Node const* node) const -> Branch const*;
	auto findMove(db::Move move) const -> Branch const*;
	auto ref() const -> unsigned;
	auto ref(unsigned level) const -> unsigned;

	static auto parse(Reader& reader, unsigned flags = 0) -> Node*;
	static auto parse(Reader& reader, Node* root, unsigned flags = 0) -> Node*;

	void computePathMaxima();

	auto findMissingMainlines() const -> bool;
	auto findUnresolvedNodes() -> bool;

	void extend();
	void renumber();
	void buildBypasses();
	void checkConsistence(db::Board& board, HashSet& hashSet, Path path);
	void sortBranches();
	void enumerateTranspositionPaths();
	void refineClassification(Key mainKey = 0);
	void printStats();
	void dumpPGN() const;
	void traverse(Visitor& visitor) const;
	void setOpeningFromParent(Name const& name);
	void setup(Id id, Name const& name);
	void eliminateRecursiveBacklinks();
	void eliminateBacklink(Node const* node);

	void setRule(Id eco, db::MoveLine const& line);
	void setExclusion(Id eco, db::MoveLine const& line);
	void setUnwantedTransposition(Id from, Id to);
	void addException(Id from, db::MoveLine const& line, Id to, unsigned lineNo);
	void addOmission(Id from, db::MoveLine const& line, unsigned lineNo);

	auto computePaths() -> PathNode*;

	static auto hasClash() -> bool;
	static void setClash();

	static auto epilogue() -> mstl::string const&;

private:

	struct BitInfo
	{
		BitInfo();

		unsigned	bits;
		Id			id;
	};

	using NodeList		= mstl::vector<Node const*>;
	using Numbers		= mstl::vector<unsigned>;
	using BitMaxima	= mstl::vector<BitInfo>;
	using BranchStack	= mstl::stack<Branch const*>;

	auto visited() const -> bool;

	auto checkLines(
		mstl::vector<uint8_t>& ecoSet,
		mstl::vector<Node const*>& path,
		mstl::vector<uint8_t>& ecoGroup) const
		-> bool;

	auto findSuccessor(db::Move const& move, Id id) -> Branch*;
	auto findSuccessor(Node* node) -> Branch*;
	auto findBypassLeaf() const -> Node const*;

	void enumerateTranspositionPaths(mstl::bitset& keySet);
	void buildBypasses(db::Board& board, unsigned weight);
	auto makeBypassGraph(
		db::Board& board,
		db::MoveLine& moves,
		Node const* root,
		unsigned size,
		unsigned weight) -> bool;
	auto addTransition(Reader const& reader, db::Board& board, Transition const& trans) -> void;
	void buildBypassSequence(Id eco, db::Board board, db::MoveLine& moves);
	void generateBypassTransitions(db::Board& board);
	void dumpGame(unsigned offset) const;
	void dumpPGN(Key key, unsigned offset) const;
	void collectFinalNodes(NodeList& nodes) const;
	void sortBranches(Id eco, Key key);
//	void findTranspositions(db::Board& board);
	void setOpeningFromParent(unsigned openingRef, Name const& name);
	void extend(db::Board& board, db::MoveLine& line);
	void renumber(Numbers& numbers);
	void doTraversal(Visitor& visitor, mstl::bitset& keySet, mstl::stack<Node const*>& stack) const;
	auto findUnresolvedNodes(BranchStack& stack) -> bool;
	void computePathMaxima(db::MoveList& line) const;
	void computePathMaxima(BranchStack& stack) const;
	void addBacklink(Node* node);
	void computePathBitLengths();
	void computePathBitLengthsBackward();
	void relinkBranchesToEqualLines(db::Board& board);
	auto checkTranspositions(bool extended) -> bool;
	void printNode(char const* arrow) const;

	auto countPathNodes(mstl::bitset& path, mstl::bitset& used, unsigned& count) const -> bool;
	auto countMoves(Node const* parent) const -> unsigned;
	auto countPathsBackward() -> uint64_t;
	void countPaths();

	void sort(Branches& list);

	Id						m_id;
	Key					m_key;
	db::MoveLine		m_line;
	Branches				m_branches;
	Backlinks			m_backlinks;
	Node*					m_parent;
	PathNode*			m_pathNode;
	BitLengths			m_bitLengths;
	mstl::string		m_prologue;
	mstl::string		m_comment;
	mstl::bitset*		m_keySet;

	uint32_t				m_count;
	uint32_t				m_lineNo;
	uint32_t				m_nameRef;
	uint32_t				m_numBypasses;
	mutable uint32_t	m_visited;

	uint32_t				m_sign:8;
	uint32_t				m_resolve:1;
	uint32_t				m_root:1;
	uint32_t				m_final:1;
	uint32_t				m_equal:1;
	uint32_t				m_hasTwin:1;
	uint32_t				m_checkLine:1;
	uint32_t				m_preParsed:1;
	uint32_t				m_isBypass:1;
	uint32_t				m_isExtension:1;
	uint32_t				m_isMerged:1;
	uint32_t				m_bitLengthIsComputed:1;
	uint32_t				m_isEnumerated:1;
	uint32_t				m_conflict:1;
	uint32_t				m_enPassant:1;
	uint32_t				m_myKeySet:1;
	uint32_t				m_myPathNode:1;
	uint32_t				m_extended:1;
	mutable uint32_t	m_done:1;

	static mstl::string	m_epilogue;
	static HashSet			m_bypassSet;
	static bool				m_clash;
	static BitMaxima		m_maxBitLength;
	static Rules			m_rules;

	static unsigned m_maxBranches;
	static unsigned m_maxBackLinks;
	static unsigned m_maxBypasses;
	static unsigned m_maxLineLength;
	static unsigned m_maxBacklinks;
	static unsigned m_transpositionCount;
	static unsigned m_nodeCount;
	static unsigned m_backlinkCount;
	static unsigned m_bypassCount;

	static Key m_maxMainKey;
};

} // namespace eco

#include "eco_node.ipp"

#endif // _eco_node_included

// vi:set ts=3 sw=3:
