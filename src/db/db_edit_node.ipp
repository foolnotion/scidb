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
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

namespace db {
namespace edit {

inline Root::Root() :m_opening(0), m_languages(0), m_variation(0) {}
inline KeyNode::KeyNode(Key const& key) :m_key(key) {}
inline KeyNode::KeyNode(Key const& key, char prefix) :m_key(key, prefix) {}
inline Comment::Comment(db::Comment const& comment) :m_comment(comment) {}
inline Variation::Variation(Key const& key) :KeyNode(key) {}
inline Annotation::Annotation(db::Annotation const& annotation) :m_annotation(annotation) {}
inline Marks::Marks(MarkSet const& marks) :m_marks(marks) {}
inline Space::Space(Bracket bracket) :m_level(-1), m_bracket(bracket) {}
inline Space::Space(unsigned level, Bracket bracket) :m_level(level), m_bracket(bracket) {}


inline
Opening::Opening(Board const& startBoard, uint16_t idn, Eco eco)
	:m_board(startBoard)
	,m_idn(idn)
	,m_eco(eco)
{
}


inline edit::Key const Root::lastKey() const						{ return m_last; }
inline Key const& KeyNode::key() const								{ return m_key; }
inline unsigned Ply::moveNo() const									{ return m_moveNo; }
inline db::Move const& Ply::move() const							{ return m_move; }
inline Ply const* Move::ply() const									{ return m_ply; }
inline Node::LanguageSet const& Languages::langSet() const	{ return m_langSet; }
inline bool Node::operator!=(Node const* node) const			{ return !operator==(node); }

inline bool Node::isRoot() const	{ return dynamic_cast<Root const*>(this) != 0; }

inline void Node::setStyle(DisplayStyle style) { m_style = style; }

inline edit::Key Move::key(Key const& key) { return edit::Key(key, PrefixMove); }

} // namespace edit
} // namespace db

// vi:set ts=3 sw=3:
