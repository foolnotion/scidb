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

#include "eco_name.h"

#include "m_assert.h"

#include <string.h>

namespace eco {

inline auto Node::alreadyDone() const -> bool	{ return m_done; }
inline auto Node::isRoot() const -> bool			{ return m_root; }
inline auto Node::isFinal() const -> bool			{ return m_final; }
inline auto Node::isEqual() const -> bool			{ return m_equal; }
inline auto Node::isBypass() const -> bool		{ return m_isBypass; }
inline auto Node::isExtension() const -> bool	{ return m_isExtension; }
inline auto Node::hasClash() -> bool				{ return m_clash; }

inline auto Node::isEqual(db::MoveLine const& line) const -> bool { return m_line == line;}

inline auto Node::id() const -> Id									{ return m_id; }
inline auto Node::key() const -> Key								{ return m_key; }
inline auto Node::ref() const -> unsigned							{ return m_nameRef; }
inline auto Node::length() const -> unsigned						{ return m_line.size(); }
inline auto Node::line() const -> db::MoveLine const&			{ return m_line; }
inline auto Node::countMoves() const -> unsigned				{ return countMoves(0); }
inline auto Node::countCodes() -> unsigned						{ return m_nodeCount; }
inline auto Node::countMainCodes() -> unsigned					{ return m_maxMainKey; }
inline auto Node::countBacklinks() -> unsigned					{ return m_backlinkCount; }
inline auto Node::successors() const -> Branches const&		{ return m_branches; }
inline auto Node::successors() -> Branches&						{ return m_branches; }
inline auto Node::backlinks() const -> Backlinks const&		{ return m_backlinks; }
inline auto Node::epilogue() -> mstl::string const&			{ return m_epilogue; }
inline auto Node::prologue() const -> mstl::string const&	{ return m_prologue; }
inline auto Node::comment() const -> mstl::string const&		{ return m_comment; }
inline auto Node::parent() const -> Node*							{ return m_parent; }
inline auto Node::lineNo() const -> unsigned						{ return m_lineNo; }
inline auto Node::numBranches() const -> unsigned				{ return m_branches.size() - m_numBypasses; }
inline auto Node::numBypasses() const -> unsigned				{ return m_numBypasses; }
inline auto Node::sign() const -> char								{ return m_sign; }

inline void Node::done() { m_done = true; }


inline
auto Node::checkTranspositions() -> bool
{
	return checkTranspositions(m_extended);
}


inline
auto Node::countLines() -> unsigned
{
	return unsigned(m_maxMainKey) + m_transpositionCount;
}


inline
auto Node::backlink(unsigned i) const -> Node const&
{
	M_REQUIRE(i < backlinks().size());
	return *m_backlinks[i].node;
}


inline
auto Node::nameRef() const -> Name const*
{
	M_REQUIRE(ref() != Name::Invalid);
	return Name::lookup(m_nameRef);
}


inline auto Node::name() const -> Name const&							{ return *nameRef(); }
inline auto Node::name(unsigned n) const -> mstl::string const&	{ return nameRef()->str(n); }
inline auto Node::ref(unsigned n) const -> unsigned					{ return nameRef()->ref(n); }


inline
auto Node::parse(Reader& reader, unsigned flags) -> Node*
{
	return parse(reader, 0, flags);
}


inline
void Node::setRule(Id eco, db::MoveLine const& line)
{
	m_rules.add(eco, line);
}


inline
void Node::setExclusion(Id eco, db::MoveLine const& line)
{
	m_rules.addExclusion(eco, line);
}


inline
void Node::addOmission(Id eco, db::MoveLine const& line, unsigned lineNo)
{
	m_rules.addOmission(eco, line, lineNo);
}


inline
void Node::setUnwantedTransposition(Id from, Id to)
{
	m_rules.setUnwantedTransposition(from, to);
}


inline
void Node::addException(Id from, db::MoveLine const& line, Id to, unsigned lineNo)
{
	m_rules.addException(from, line, to, lineNo);
}

} // namespace eco

// vi:set ts=3 sw=3:
