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

namespace db {

inline bool Consumer::isMainline() const					{ return m_stack.size() == 2; }
inline bool Consumer::variationIsEmpty() const			{ return m_stack.top().empty; }
inline bool Consumer::terminated() const					{ return m_terminated; }

inline format::Type Consumer::sourceFormat() const		{ return m_format; }
inline Board& Consumer::getBoard()							{ return m_stack.top().board; }
inline Board const& Consumer::board() const				{ return m_stack.top().board; }
inline Board const& Consumer::startBoard() const		{ return m_stack.bottom().board; }
inline unsigned Consumer::variationLevel() const		{ return m_stack.size() - 2; }
inline unsigned Consumer::countVariations() const		{ return m_variationCount; }
inline unsigned Consumer::countComments() const			{ return m_commentCount; }
inline unsigned Consumer::countAnnotations() const		{ return m_annotationCount; }
inline unsigned Consumer::countMarks() const				{ return m_markCount; }
inline Line const& Consumer::openingLine() const		{ return m_line; }
inline mstl::string const& Consumer::encoding() const	{ return m_encoding; }
inline sys::utf8::Codec& Consumer::codec() const		{ return *m_codec; }
inline uint32_t Consumer::flags() const					{ return m_flags; }
inline Consumer* Consumer::consumer() const				{ return m_consumer; }

inline void Consumer::setFlags(uint32_t flags)			{ m_flags = flags; }
inline void Consumer::setConsumer(Consumer* consumer)	{ m_consumer = consumer; }
inline void Consumer::startMoveSection()					{ beginMoveSection(); }

inline
bool
Consumer::startGame(TagSet const& tags)
{
	return startGame(tags, 0);
}


inline
bool
Consumer::startGame(TagSet const& tags, Board const& board)
{
	return startGame(tags, &board);
}

} // namespace db

// vi:set ts=3 sw=3:
