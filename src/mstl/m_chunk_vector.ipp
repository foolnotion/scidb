// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
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

#include "m_uninitialized.h"
#include "m_construct.h"
#include "m_utility.h"
#include "m_assert.h"

namespace mstl {

template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::iterator::iterator(value_type** chunks, size_type i)
	:m_chunks(chunks)
	,m_i(i)
{
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator&
chunk_vector<T,Chunk_Shift>::iterator::operator=(iterator i)
{
	m_chunks = i.m_chunks;
	m_i = i.m_i;
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::iterator::operator==(iterator const& iter) const
{
	return m_i == iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::iterator::operator!=(iterator const& iter) const
{
	return m_i != iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::iterator::operator<=(iterator const& iter) const
{
	return m_i <= iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::iterator::operator<(iterator const& iter) const
{
	return m_i < iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator&
chunk_vector<T,Chunk_Shift>::iterator::operator++()
{
	if ((++m_i & Chunk_Mask) == 0)
		++m_chunks;

	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator&
chunk_vector<T,Chunk_Shift>::iterator::operator--()
{
	if ((m_i-- & Chunk_Mask) == 0)
		--m_chunks;

	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::iterator::operator++(int)
{
	iterator my = *this;

	if ((++m_i & Chunk_Mask) == 0)
		++m_chunks;

	return my;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::iterator::operator--(int)
{
	iterator my = *this;

	if ((m_i-- & Chunk_Mask) == 0)
		--m_chunks;

	return my;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator&
chunk_vector<T,Chunk_Shift>::iterator::operator+=(size_type n)
{
	size_type old_sub_idx = m_i >> Chunk_Shift;
	size_type new_sub_idx = (m_i += n) >> Chunk_Shift;

	m_chunks += (new_sub_idx - old_sub_idx);
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator&
chunk_vector<T,Chunk_Shift>::iterator::operator-=(size_type n)
{
	size_type old_sub_idx = m_i >> Chunk_Shift;
	size_type new_sub_idx = (m_i += n) >> Chunk_Shift;

	m_chunks -= (old_sub_idx - new_sub_idx);
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::iterator::operator+(size_type n) const
{
	return iterator(*this) += n;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::iterator::operator-(size_type n) const
{
	return iterator(*this) += n;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::iterator::operator[](difference_type n) const
{
	difference_type cur_sub_index	= m_i >> Chunk_Shift;
	difference_type new_sub_index	= (difference_type(m_i) + n) >> Chunk_Shift;
	difference_type skip_index		= new_sub_index - cur_sub_index;
	difference_type index			= (difference_type(m_i) + n) & Chunk_Mask;

	return (*(m_chunks + skip_index))[index];
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::difference_type
chunk_vector<T,Chunk_Shift>::iterator::operator-(iterator const& i) const
{
	return difference_type(m_i) - difference_type(i.m_i);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::iterator::operator*() const
{
	return (*m_chunks)[m_i & Chunk_Mask];
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::pointer
chunk_vector<T,Chunk_Shift>::iterator::operator->() const
{
	return *m_chunks + (m_i & Chunk_Mask);
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::const_iterator::const_iterator(iterator i)
	:m_chunks(i.m_chunks)
	,m_i(i.m_i)
{
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::const_iterator::const_iterator(value_type const*const* chunks, size_type i)
	:m_chunks(chunks)
	,m_i(i)
{
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator&
chunk_vector<T,Chunk_Shift>::const_iterator::operator=(const_iterator i)
{
	m_chunks = i.m_chunks;
	m_i = i.m_i;
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::const_iterator::operator==(const_iterator const& iter) const
{
	return m_i == iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::const_iterator::operator!=(const_iterator const& iter) const
{
	return m_i != iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::const_iterator::operator<=(const_iterator const& iter) const
{
	return m_i <= iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::const_iterator::operator<(const_iterator const& iter) const
{
	return m_i < iter.m_i;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator&
chunk_vector<T,Chunk_Shift>::const_iterator::operator++()
{
	if ((++m_i & Chunk_Mask) == 0)
		++m_chunks;

	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator&
chunk_vector<T,Chunk_Shift>::const_iterator::operator--()
{
	if ((m_i-- & Chunk_Mask) == 0)
		--m_chunks;

	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::const_iterator::operator++(int)
{
	const_iterator my = *this;

	if ((++m_i & Chunk_Mask) == 0)
		++m_chunks;

	return my;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::const_iterator::operator--(int)
{
	const_iterator my = *this;

	if ((m_i-- & Chunk_Mask) == 0)
		--m_chunks;

	return my;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator&
chunk_vector<T,Chunk_Shift>::const_iterator::operator+=(size_type n)
{
	size_type old_sub_idx = m_i >> Chunk_Shift;
	size_type new_sub_idx = (m_i += n) >> Chunk_Shift;

	m_chunks += (new_sub_idx - old_sub_idx);
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator&
chunk_vector<T,Chunk_Shift>::const_iterator::operator-=(size_type n)
{
	size_type old_sub_idx = m_i >> Chunk_Shift;
	size_type new_sub_idx = (m_i += n) >> Chunk_Shift;

	m_chunks -= (old_sub_idx - new_sub_idx);
	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::const_iterator::operator+(size_type n) const
{
	return const_iterator(*this) += n;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::const_iterator::operator-(size_type n) const
{
	return const_iterator(*this) -= n;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_reference
chunk_vector<T,Chunk_Shift>::const_iterator::operator[](difference_type n) const
{
	difference_type cur_sub_index	= m_i >> Chunk_Shift;
	difference_type new_sub_index	= (difference_type(m_i) + n) >> Chunk_Shift;
	difference_type skip_index		= new_sub_index - cur_sub_index;
	difference_type index			= (difference_type(m_i) + n) & Chunk_Mask;

	return (*(m_chunks + skip_index))[index];
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::difference_type
chunk_vector<T,Chunk_Shift>::const_iterator::operator-(const_iterator const& i) const
{
	return difference_type(m_i) - difference_type(i.m_i);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_reference
chunk_vector<T,Chunk_Shift>::const_iterator::operator*() const
{
	return (*m_chunks)[m_i & Chunk_Mask];
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_pointer
chunk_vector<T,Chunk_Shift>::const_iterator::operator->() const
{
	return (*m_chunks) + (m_i & Chunk_Mask);
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::empty() const
{
	return m_size == 0;
}


template <typename T, unsigned Chunk_Shift>
inline
bool
chunk_vector<T,Chunk_Shift>::released(unsigned chunk_index) const
{
	M_REQUIRE(chunk_index < count_chunks());
	return m_index[chunk_index] == 0;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::at(size_type n)
{
	M_REQUIRE(n < size());
	M_REQUIRE(!released(chunk_index(n)));

	return m_index[n >> Chunk_Shift][n & Chunk_Mask];
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_reference
chunk_vector<T,Chunk_Shift>::at(size_type n) const
{
	M_REQUIRE(n < size());
	M_REQUIRE(!released(chunk_index(n)));

	return m_index[n >> Chunk_Shift][n & Chunk_Mask];
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::chunk_vector()
	:m_size(0)
	,m_capacity(0)
{
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::chunk_vector(size_type n)
	:m_size(0)
	,m_capacity(0)
{
	resize(n);
}

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::chunk_vector(chunk_vector&& v)
	:m_index(mstl::move(v.m_index))
	,m_size(v.m_size)
	,m_capacity(v.m_capacity)
{
}


template <typename T, unsigned Chunk_Shift>
chunk_vector<T,Chunk_Shift>&
chunk_vector<T,Chunk_Shift>::operator=(chunk_vector&& v)
{
	m_index = mstl::move(v.m_index);
	m_size = v.m_size;
	m_capacity = v.m_capacity;
	return *this;
}

#endif

template <typename T, unsigned Chunk_Shift>
chunk_vector<T,Chunk_Shift>&
chunk_vector<T,Chunk_Shift>::operator=(chunk_vector const& v)
{
	resize(v.size());

	for (size_t i = 0, n = v.size(); i < n; ++i)
		at(i) = v.at(i);

	return *this;
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::chunk_vector(chunk_vector const& v)
	:m_size(0)
	,m_capacity(0)
{
	*this = v;
}


template <typename T, unsigned Chunk_Shift>
inline
chunk_vector<T,Chunk_Shift>::~chunk_vector() throw()
{
	clear();
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::size_type
chunk_vector<T,Chunk_Shift>::size() const
{
	return m_size;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::size_type
chunk_vector<T,Chunk_Shift>::capacity() const
{
	return m_capacity;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::size_type
chunk_vector<T,Chunk_Shift>::chunk_size() const
{
	return size_type(1) << Chunk_Shift;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::size_type
chunk_vector<T,Chunk_Shift>::count_chunks() const
{
	return (size() + chunk_size() - 1) >> Chunk_Shift;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::size_type
chunk_vector<T,Chunk_Shift>::chunk_index(unsigned index)
{
	return index >> Chunk_Shift;
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::begin()
{
	return iterator(const_cast<value_type**>(m_index.data()), 0);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::begin() const
{
	return const_iterator(m_index.data(), 0);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::iterator
chunk_vector<T,Chunk_Shift>::end()
{
	return iterator(0, m_size);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_iterator
chunk_vector<T,Chunk_Shift>::end() const
{
	return const_iterator(0, m_size);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::operator[](size_type n)
{
	return at(n);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_reference
chunk_vector<T,Chunk_Shift>::operator[](size_type n) const
{
	return at(n);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::back()
{
	M_REQUIRE(!empty());
	M_REQUIRE(!released(chunk_index(size() - 1)));

	return at(m_size - 1);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::const_reference
chunk_vector<T,Chunk_Shift>::back() const
{
	M_REQUIRE(!empty());
	M_REQUIRE(!released(chunk_index(size() - 1)));

	return at(m_size - 1);
}


template <typename T, unsigned Chunk_Shift>
inline
typename chunk_vector<T,Chunk_Shift>::reference
chunk_vector<T,Chunk_Shift>::push_back()
{
	size_type size		= m_size;
	size_type sub_idx	= m_size++ >> Chunk_Shift;

	if (sub_idx >= m_index.size())
		reserve(m_size);

	return m_index[sub_idx][size & Chunk_Mask];
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::push_back(const_reference v)
{
	push_back() = v;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::pop_back()
{
	M_REQUIRE(!empty());
	resize(size() - 1);
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::reserve(size_type n)
{
	if (n <= m_capacity)
		return;

	size_type old_sub_size = m_index.size();
	size_type new_sub_size = n ? 1 + ((n - 1) >> Chunk_Shift) : 0;

	if (new_sub_size > m_index.capacity())
		m_index.reserve_exact(mstl::max(new_sub_size, old_sub_size + mstl::div4(old_sub_size)));

	m_index.resize(new_sub_size);

	for (size_t i = old_sub_size; i < new_sub_size; ++i)
		m_index[i] = new value_type[1 << Chunk_Shift];

	m_capacity = new_sub_size << Chunk_Shift;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::resize(size_type n)
{
	if (m_capacity > n)
	{
		size_type old_sub_size = m_index.capacity();
		size_type new_sub_size = n ? 1 + ((n - 1) >> Chunk_Shift) : 0;

		for (size_t i = new_sub_size; i < old_sub_size; ++i)
			delete [] m_index[i];

		m_index.shrink(new_sub_size);
		m_capacity = new_sub_size << Chunk_Shift;
	}
	else
	{
		reserve(n);
	}

	m_size = n;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::clear()
{
	for (size_t i = 0; i < m_index.size(); ++i)
		delete [] m_index[i];

	m_index.release();
	m_size = m_capacity = 0;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::clear_chunk(size_type chunk_index)
{
	M_REQUIRE(chunk_index < count_chunks());

	value_type* chunk = m_index[chunk_index];
	mstl::bits::destroy(chunk, chunk + chunk_size());
	mstl::uninitialized_fill_n(chunk, chunk_size(), T());
	m_size = chunk_index ? mstl::min(chunk_size()*(chunk_index - 1), m_size) : 0;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::release_chunk(size_type chunk_index)
{
	M_REQUIRE(chunk_index < count_chunks());

	delete [] m_index[chunk_index];
	m_index[chunk_index] = 0;
}


template <typename T, unsigned Chunk_Shift>
inline
void
chunk_vector<T,Chunk_Shift>::swap(chunk_vector& v)
{
	m_index.swap(v.m_index);
	mstl::swap(m_size, v.m_size);
	mstl::swap(m_capacity, v.m_capacity);
}

} // namespace mstl

// vi:set ts=3 sw=3:
