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

#include "m_assert.h"

namespace db {

inline bool MoveNode::atLineStart() const					{ return m_prev == 0 || m_prev->m_next != this;}
inline bool MoveNode::atLineEnd() const					{ return m_next == 0; }
inline bool MoveNode::hasComment() const					{ return m_flags & HasComment; }
inline bool MoveNode::hasPreComment() const				{ return m_flags & HasPreComment; }
inline bool MoveNode::hasAnyComment() const				{ return m_flags & (HasComment | HasPreComment); }
inline bool MoveNode::hasMark() const						{ return m_flags & HasMark; }
inline bool MoveNode::hasAnnotation() const				{ return m_flags & HasAnnotation; }
inline bool MoveNode::hasVariation() const				{ return m_flags & HasVariation; }
inline bool MoveNode::hasNote() const						{ return m_flags & HasNote; }
inline bool MoveNode::hasSupplement() const				{ return m_flags & HasSupplement; }

inline MoveNode* MoveNode::prev() const					{ return m_prev; }
inline Move& MoveNode::move()									{ return m_move; }
inline Move const& MoveNode::move() const					{ return m_move; }
inline MoveNode* MoveNode::next() const					{ return m_next; }

inline MarkSet const& MoveNode::marks() const			{ return *m_marks; }
inline Comment const& MoveNode::comment() const			{ return m_comment; }
inline Comment const& MoveNode::preComment() const		{ return m_preComment; }
inline Annotation const& MoveNode::annotation() const	{ return *m_annotation; }
inline unsigned MoveNode::variationCount() const		{ return m_variations.size(); }

inline void MoveNode::setComment()							{ m_flags |= HasComment; }
inline void MoveNode::setPreComment()						{ m_flags |= HasPreComment; }
inline void MoveNode::unsetComment()						{ m_flags &= ~HasComment; }
inline void MoveNode::unsetPreComment()					{ m_flags &= ~HasPreComment; }
inline MoveNode* MoveNode::clone() const					{ return clone(0); }


inline
MoveNode*
MoveNode::variation(unsigned i) const
{
	M_REQUIRE(i < variationCount());
	return m_variations[i];
}


inline
MoveNode::Nodes const&
MoveNode::variations() const
{
	return m_variations;
}


inline
void
MoveNode::updateCommentFlags()
{
	m_flags &= ~IsPrepared;

	if (m_comment.isEmpty())
		m_flags &= ~HasComment;
	else
		m_flags |= HasComment;
}


inline
void
MoveNode::updatePreCommentFlags()
{
	m_flags &= ~IsPrepared;

	if (m_preComment.isEmpty())
		m_flags &= ~HasPreComment;
	else
		m_flags |= HasPreComment;
}


inline
void
MoveNode::swapComment(Comment& comment)
{
	m_comment.swap(comment);
	updateCommentFlags();
}


inline
void
MoveNode::swapComment(mstl::string& str)
{
	m_comment.swap(str);
	updateCommentFlags();
}


inline
void
MoveNode::swapPreComment(mstl::string& str)
{
	m_preComment.swap(str);
	updatePreCommentFlags();
}


inline
void
MoveNode::setComment(mstl::string const& str)
{
	m_comment = str;
	updateCommentFlags();
}


inline
void
MoveNode::setPreComment(mstl::string const& str)
{
	m_preComment = str;
	updatePreCommentFlags();
}


inline
move::Constraint
MoveNode::constraint() const
{
	return m_move.isEmpty() || m_move.isLegal() ? move::DontAllowIllegalMove : move::AllowIllegalMove;
}

} // namespace db

// vi:set ts=3 sw=3:
