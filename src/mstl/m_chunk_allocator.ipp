// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

#include "m_utility.h"
#include "m_bit_functions.h"
#include "m_construct.h"
#include "m_assert.h"
#include "m_static_check.h"

#include <string.h>
#include <stdlib.h>

namespace mstl {

template <typename T>
chunk_allocator<T>::chunk_allocator(size_t chunk_size)
	:m_zero(false)
{
	static size_t const page_size				= 4096;					// must be power of 2
	static size_t const malloc_header_size	= 4*sizeof(void*);	// should be always sufficient

	m_chunk_size = mstl::max(chunk_size, page_size);

	if ((chunk_size & (chunk_size - 1)) != 0)
	{
		// chunk_size is not power of 2. we round up to next power of 2.
		chunk_size = 1 << (bf::msb_index(chunk_size) + 1);
	}

	m_chunk_size -= malloc_header_size;	// take overhead of memory allocation into account
	m_num_elems = m_chunk_size/sizeof(T);
	m_chunk_size = m_num_elems*sizeof(T);

	new_chunk();
}


template <typename T>
chunk_allocator<T>::~chunk_allocator()
{
	for (typename chunk_list::iterator i = m_chunk_list.begin(); i != m_chunk_list.end(); ++i)
	{
		bits::destroy(i->base, i->curr);
		::free(i->base);
	}
}


template <typename T>
bool
chunk_allocator<T>::canRelease() const
{
	M_ASSERT(!m_chunk_list.empty());
	return m_chunk_list.top().curr > m_chunk_list.top().base;
}


template <typename T>
bool
chunk_allocator<T>::canShrink(size_t size) const
{
	M_ASSERT(!m_chunk_list.empty());
	return m_chunk_list.top().curr >= m_chunk_list.top().base + size;
}



template <typename T>
bool
chunk_allocator<T>::empty() const
{
	return m_chunk_list.size() == 1 && m_chunk_list.top().base == m_chunk_list.top().curr;
}


template <typename T>
inline
size_t
chunk_allocator<T>::chunk_size() const
{
	return m_chunk_size;
}


template <typename T>
inline
size_t
chunk_allocator<T>::elems_per_chunk() const
{
	return m_num_elems;
}


template <typename T>
inline
void
chunk_allocator<T>::set_zero()
{
	M_STATIC_CHECK(is_pod<T>::value, Value_Type_Not_Plain_Old_Data);

	m_zero = true;
	::memset(m_chunk_list.top().base, 0, m_chunk_size);
}


template <typename T>
inline
void
chunk_allocator<T>::clear()
{
	for (typename chunk_list::iterator i = m_chunk_list.begin(); i != m_chunk_list.end(); ++i)
	{
		bits::destroy(i->base, i->curr);
		::free(i->base);
	}

	m_chunk_list.clear();
	new_chunk();
}


template <typename T>
typename chunk_allocator<T>::chunk*
chunk_allocator<T>::new_chunk()
{
	m_chunk_list.push();
	chunk& c = m_chunk_list.top();
	c.curr = c.base = static_cast<T*>(::malloc(m_chunk_size));

	if (m_zero)
		::memset(c.base, 0, m_chunk_size);

	return &c;
}


template <typename T>
inline
T*
chunk_allocator<T>::alloc()
{
	M_ASSERT(!m_chunk_list.empty());

	chunk* c = &m_chunk_list.top();

	if (c->base + m_num_elems == c->curr)
		c = new_chunk();

	T* obj = c->curr++;
	bits::construct(obj);
	return obj;
}


template <typename T>
T*
chunk_allocator<T>::alloc(size_t length)
{
	// otherwise uninitialized_fill_n(p, length, T()) is required
	M_STATIC_CHECK(is_pod<T>::value, Value_Type_Not_Plain_Old_Data);
	M_REQUIRE(length <= chunk_size());
	M_ASSERT(!m_chunk_list.empty());

	chunk*	c = &m_chunk_list.top();
	T*			p = c->curr;

	if ((c->curr += length) >= c->base + m_num_elems)
	{
		c = new_chunk();
		p = c->curr;
		c->curr += length;
	}

	return p;
}


template <typename T>
void
chunk_allocator<T>::release()
{
	M_REQUIRE(canRelease());

	chunk* c = &m_chunk_list.top();
	bits::destroy(--c->curr);
}


template <typename T>
void
chunk_allocator<T>::shrink(size_t allocatedLength, size_t newLength)
{
	M_STATIC_CHECK(is_pod<T>::value, Value_Type_Not_Plain_Old_Data);
	M_REQUIRE(newLength <= allocatedLength);
	M_ASSERT(!m_chunk_list.empty());

	if (canShrink(allocatedLength - newLength))
	{
		chunk* c = &m_chunk_list.top();
		c->curr -= allocatedLength - newLength;
	}
}


template <typename T>
unsigned
chunk_allocator<T>::lookup(T const* p) const
{
	for (unsigned i = 0; i < m_chunk_list.size(); ++i)
	{
		chunk const& chunk = m_chunk_list[i];

		if (chunk.base <= p && p < chunk.curr)
			return i*m_num_elems + (p - chunk.base);
	}

	return NotFound;
}

} // namespace mstl

// vi:set ts=3 sw=3:
