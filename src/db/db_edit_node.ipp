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

#include "m_assert.h"

namespace db {
namespace edit {

inline KeyNode::KeyNode(Key const& key) :m_key(key) {}
inline KeyNode::KeyNode(Key const& key, char prefix) :m_key(key, prefix) {}
inline Variation::Variation(Key const& key) :KeyNode(key) {}
inline Variation::Variation(Key const& key, Key const& succ) :KeyNode(key), m_succ(succ) {}
inline Move::Move(Key const& key) :KeyNode(key), m_ply(0) {}
inline MovePart::MovePart() :m_state(Unchanged) {}


inline void MovePart::markAsInserted() const	{ m_state = Inserted; }
inline void MovePart::markAsChanged() const	{ m_state = Changed; }


inline
Space::Space()
	:m_level(-1)
	,m_varNo(0)
	,m_varCount(0)
	,m_bracket(Blank)
	,m_asNumber(false)
{
}


inline
Space::Space(Bracket bracket)
	:m_level(-1)
	,m_varNo(0)
	,m_varCount(0)
	,m_bracket(bracket)
	,m_asNumber(false)
{
}


inline
Space::Space(unsigned level)
	:m_level(level)
	,m_varNo(0)
	,m_varCount(0)
	,m_bracket(Open)
	,m_asNumber(false)
{
}


inline
Space::Space(Bracket bracket, unsigned varNo, unsigned varCount)
	:m_level(-1)
	,m_varNo(varNo)
	,m_varCount(varCount)
	,m_bracket(bracket)
	,m_asNumber(false)
{
	M_ASSERT(varNo > 0);
	M_ASSERT(varCount > 0);
}


inline
Space::Space(unsigned level, unsigned varNo, unsigned varCount, bool asNumber)
	:m_level(level)
	,m_varNo(varNo)
	,m_varCount(varCount)
	,m_bracket(Open)
	,m_asNumber(asNumber)
{
	M_ASSERT(varNo > 0);
	M_ASSERT(varCount > 0);
}


inline
Comment::Comment(db::Comment const& comment, move::Position position, VarPos varPos)
	:m_position(position)
	,m_varPos(varPos)
	,m_comment(comment)
{
}


inline
Opening::Opening(Board const& startBoard, variant::Type variant, uint16_t idn, Eco eco)
	:m_board(startBoard)
	,m_variant(variant)
	,m_idn(idn)
	,m_eco(eco)
{
}


inline Ply::Ply() :m_moveNo(0) {}

inline bool Annotation::isEmpty() const							{ return m_annotation.isEmpty(); }
inline Key const& KeyNode::key() const								{ return m_key; }
inline bool Variation::empty() const								{ return m_list.empty(); }
inline Key const& Variation::successor() const					{ return m_succ; }
inline unsigned Ply::moveNo() const									{ return m_moveNo; }
inline db::Move const& Ply::move() const							{ return m_move; }
inline Ply const* Move::ply() const									{ return m_ply; }
inline Node::LanguageSet const& Languages::langSet() const	{ return m_langSet; }
inline bool Node::operator!=(Node const* node) const			{ return !operator==(node); }
inline Action::Command Action::command() const					{ return m_command; }
inline Key Action::start() const										{ return m_key1; }
inline Key Action::end() const										{ return m_key2; }
inline unsigned Action::level() const								{ return m_level; }

inline bool Node::isRoot() const	{ return dynamic_cast<Root const*>(this) != 0; }

} // namespace edit
} // namespace db

// vi:set ts=3 sw=3:
