// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_assert.h"

namespace mstl {

template <typename T>
inline
fixed_size_allocator<T>::fixed_size_allocator()
{
}


template <typename T>
inline
fixed_size_allocator<T>::fixed_size_allocator(size_type size)
	:m_mem(size)
{
}


template <typename T>
inline
bool
fixed_size_allocator<T>::empty() const
{
	return m_mem.m_finish == m_mem.m_start;
}


template <typename T>
inline
typename fixed_size_allocator<T>::size_type
fixed_size_allocator<T>::size() const
{
	return m_mem.size();
}


template <typename T>
inline
typename fixed_size_allocator<T>::size_type
fixed_size_allocator<T>::capacity() const
{
	return m_mem.capacity();
}


template <typename T>
inline
T*
fixed_size_allocator<T>::allocate()
{
	M_REQUIRE(size() < capacity());
	return new(m_mem.m_finish++) T();
}


template <typename T>
inline
T*
fixed_size_allocator<T>::allocate(T const& x)
{
	M_REQUIRE(size() < capacity());
	return new(m_mem.m_finish++) T(x);
}


template <typename T>
inline
void
fixed_size_allocator<T>::release()
{
	m_mem.m_finish = m_mem.m_start;
}


template <typename T>
inline
void
fixed_size_allocator<T>::reserve(size_type size)
{
	M_REQUIRE(empty());

	size_type old_size = m_mem.size();

	if (old_size < size)
	{
		memblock<T> mem(size);
		m_mem.swap(mem);
	}
}

} // namespace mstl

// vi:set ts=3 sw=3:
