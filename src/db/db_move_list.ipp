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
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"
#include "m_assert.h"

namespace db {

template <unsigned N>
inline MoveBuffer<N>::MoveBuffer() :m_size(0) {}

template <unsigned N>
inline bool MoveBuffer<N>::isEmpty()	const 		{ return m_size == 0; }
template <unsigned N>
inline bool MoveBuffer<N>::isFull() const				{ return m_size == Maximum_Moves; }
template <unsigned N>
inline bool MoveBuffer<N>::notFull() const			{ return m_size < Maximum_Moves; }
template <unsigned N>
inline unsigned MoveBuffer<N>::size()	const 		{ return m_size; }
template <unsigned N>
inline void MoveBuffer<N>::clear()						{ m_size = 0; }


template <unsigned N>
inline
bool
MoveBuffer<N>::operator==(MoveBuffer const& list) const
{
	return m_size == list.m_size && match(list, m_size) == m_size;
}


template <unsigned N>
inline
bool
MoveBuffer<N>::operator!=(MoveBuffer const& list) const
{
	return m_size != list.m_size || match(list, m_size) < m_size;
}


template <unsigned N>
inline
unsigned
MoveBuffer<N>::match(MoveBuffer const& list) const
{
	return match(list, mstl::min(list.m_size, m_size));
}


template <unsigned N>
inline
typename MoveBuffer<N>::iterator
MoveBuffer<N>::begin()
{
	return iterator(m_buffer + 0);
}


template <unsigned N>
inline
typename MoveBuffer<N>::iterator
MoveBuffer<N>::end()
{
	return iterator(m_buffer + m_size);
}


template <unsigned N>
inline
typename MoveBuffer<N>::const_iterator
MoveBuffer<N>::begin() const
{
	return const_iterator(m_buffer);
}


template <unsigned N>
inline
typename MoveBuffer<N>::const_iterator
MoveBuffer<N>::end() const
{
	return const_iterator(m_buffer + m_size);
}


template <unsigned N>
inline
typename MoveBuffer<N>::const_reverse_iterator
MoveBuffer<N>::rbegin() const
{
	return const_reverse_iterator(end());
}


template <unsigned N>
inline
typename MoveBuffer<N>::const_reverse_iterator
MoveBuffer<N>::rend() const
{
	return const_reverse_iterator(begin());
}


template <unsigned N>
inline
typename MoveBuffer<N>::reverse_iterator
MoveBuffer<N>::rbegin()
{
	return reverse_iterator(end());
}


template <unsigned N>
inline
typename MoveBuffer<N>::reverse_iterator
MoveBuffer<N>::rend()
{
	return reverse_iterator(begin());
}


template <unsigned N>
inline
Move&
MoveBuffer<N>::pop()
{
	M_REQUIRE(!isEmpty());
	return m_buffer[--m_size];
}


template <unsigned N>
inline
void
MoveBuffer<N>::cut(unsigned size)
{
	M_REQUIRE(size <= this->size());
	m_size = size;
}


template <unsigned N>
inline
void
MoveBuffer<N>::swap(unsigned index1, unsigned index2)
{
	M_REQUIRE(index1 <= size());
	M_REQUIRE(index2 <= size());

	mstl::swap(m_buffer[index1], m_buffer[index2]);
}


template <unsigned N>
inline
Move const&
MoveBuffer<N>::operator[](unsigned n) const
{
	M_REQUIRE(n < size());
	return m_buffer[n];
}


template <unsigned N>
inline
Move&
MoveBuffer<N>::operator[](unsigned n)
{
	M_REQUIRE(n < size());
	return m_buffer[n];
}


template <unsigned N>
inline
Move const&
MoveBuffer<N>::front() const
{
	M_REQUIRE(!isEmpty());
	return m_buffer[0];
}


template <unsigned N>
inline
Move const&
MoveBuffer<N>::back() const
{
	M_REQUIRE(!isEmpty());
	return m_buffer[m_size - 1];
}


template <unsigned N>
inline
void
MoveBuffer<N>::append(Move const& m)
{
	M_ASSERT(m_size < U_NUMBER_OF(m_buffer));
	m_buffer[m_size++] = m;
}


template <unsigned N>
inline
void
MoveBuffer<N>::push(Move const& m)
{
	append(m);
}


template <unsigned N>
inline
mstl::string&
MoveBuffer<N>::print(mstl::string& result, unsigned halfMoveNo, unsigned maxMoveNo) const
{
	return print(result, halfMoveNo, maxMoveNo, true);
}


template <unsigned N>
inline
mstl::string&
MoveBuffer<N>::dump(mstl::string& result, unsigned halfMoveNo, unsigned maxMoveNo) const
{
	return print(result, halfMoveNo, maxMoveNo, false);
}

} // namespace db

// vi:set ts=3 sw=3:
