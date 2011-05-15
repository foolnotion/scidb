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

inline MoveNode* MoveNode::prev() const					{ return m_prev; }
inline bool MoveNode::atLineStart() const					{ return m_prev == 0 || m_prev->m_next != this;}
inline bool MoveNode::atLineEnd() const					{ return m_next == 0; }
inline bool MoveNode::shouldHaveComment() const			{ return m_flags & HasComment; };
inline bool MoveNode::shouldHaveNote() const				{ return m_flags & HasNote; }
inline Move& MoveNode::move()									{ return m_move; }
inline Move const& MoveNode::move() const					{ return m_move; }
inline MoveNode* MoveNode::next() const					{ return m_next; }

inline void MoveNode::setComment()							{ m_flags |= HasComment; }
inline MoveNode* MoveNode::clone() const					{ return clone(0); }

inline MarkSet const& MoveNode::marks() const			{ return *m_marks; }
inline Comment const& MoveNode::comment() const			{ return m_comment; }
inline Annotation const& MoveNode::annotation() const	{ return *m_annotation; }


inline
bool
MoveNode::hasComment() const
{
	return m_flags & HasComment;
}


inline
bool
MoveNode::hasMark() const
{
	return m_flags & HasMark;
}


inline
bool
MoveNode::hasAnnotation() const
{
	return m_flags & HasAnnotation;
}


inline
bool
MoveNode::hasVariation() const
{
	return m_flags & HasVariation;
}


inline
bool
MoveNode::hasNote() const
{
	return m_flags & HasNote;
}


inline
bool
MoveNode::hasSupplement() const
{
	return m_flags & HasSupplement;
}


inline
unsigned
MoveNode::variationCount() const
{
	return m_variations.size();
}


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
MoveNode::swapComment(Comment& comment)
{
	m_comment.swap(comment);
	m_flags &= ~IsPrepared;

	if (m_comment.isEmpty())
		m_flags &= ~HasComment;
	else
		m_flags |= HasComment;
}


inline
void
MoveNode::swapComment(mstl::string& str)
{
	m_comment.swap(str);
	m_flags &= ~IsPrepared;

	if (m_comment.isEmpty())
		m_flags &= ~HasComment;
	else
		m_flags |= HasComment;
}


inline
void
MoveNode::setComment(mstl::string const& str)
{
	m_comment = str;
	m_flags &= ~IsPrepared;

	if (m_comment.isEmpty())
		m_flags &= ~HasComment;
	else
		m_flags |= HasComment;
}


inline
move::Constraint
MoveNode::constraint() const
{
	return m_move.isEmpty() || m_move.isLegal() ? move::DontAllowIllegalMove : move::AllowIllegalMove;
}

} // namespace db

// vi:set ts=3 sw=3:
