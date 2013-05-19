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
// Copyright: (C) 2009-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace db {

inline MoveList::MoveList() :m_size(0) {}

inline bool MoveList::isEmpty()	const 		{ return m_size == 0; }
inline bool MoveList::isFull() const			{ return m_size == Maximum_Moves; }
inline bool MoveList::notFull() const			{ return m_size < Maximum_Moves; }
inline unsigned MoveList::size()	const 		{ return m_size; }
inline void MoveList::clear()						{ m_size = 0; }
inline MoveList::iterator MoveList::begin()	{ return iterator(m_buffer + 0); }
inline MoveList::iterator MoveList::end()		{ return iterator(m_buffer + m_size); }

inline MoveList::const_iterator MoveList::begin() const	{ return const_iterator(m_buffer); }
inline MoveList::const_iterator MoveList::end() const		{ return const_iterator(m_buffer + m_size); }


inline
MoveList::const_reverse_iterator
MoveList::rbegin() const
{
	return const_reverse_iterator(end());
}


inline
MoveList::const_reverse_iterator
MoveList::rend() const
{
	return const_reverse_iterator(begin());
}


inline
MoveList::reverse_iterator
MoveList::rbegin()
{
	return reverse_iterator(end());
}


inline
MoveList::reverse_iterator
MoveList::rend()
{
	return reverse_iterator(begin());
}


inline
Move&
MoveList::pop()
{
	M_REQUIRE(!isEmpty());
	return m_buffer[--m_size];
}


inline
void
MoveList::cut(unsigned size)
{
	M_REQUIRE(size <= m_size);
	m_size = size;
}


inline
Move const&
MoveList::operator[](unsigned n) const
{
	M_REQUIRE(n < size());
	return m_buffer[n];
}


inline
Move&
MoveList::operator[](unsigned n)
{
	M_REQUIRE(n < size());
	return m_buffer[n];
}


inline
Move const&
MoveList::front() const
{
	M_REQUIRE(!isEmpty());
	return m_buffer[0];
}


inline
Move const&
MoveList::back() const
{
	M_REQUIRE(!isEmpty());
	return m_buffer[m_size - 1];
}


inline
void
MoveList::append(Move const& m)
{
	M_ASSERT(m_size < U_NUMBER_OF(m_buffer));
	m_buffer[m_size++] = m;
}


inline
void
MoveList::push(Move const& m)
{
	append(m);
}

} // namespace db

// vi:set ts=3 sw=3:
