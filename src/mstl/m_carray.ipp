// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"
#include "m_algorithm.h"
#include "m_type_traits.h"
#include "m_assert.h"

#include <string.h>

namespace mstl {

template <typename T>
inline
carray<T>::carray()
	:m_size(0)
{
	static_assert(is_pod<T>::value, "value type must be POD");
}


template <typename T>
inline
carray<T>::carray(const_pointer elems, size_type size)
{
	static_assert(is_pod<T>::value, "value type must be POD");

	m_arr = elems;
	m_size = size;
}


template <typename T>
inline
carray<T>::carray(carray const& a)
{
	m_arr = a.m_arr;
	m_size = a.m_size;
}


template <typename T>
inline
bool
carray<T>::empty() const
{
	return m_size == 0;
}


template <typename T>
inline
typename carray<T>::size_type
carray<T>::size() const
{
	return m_size;
}


template <typename T>
inline
carray<T>&
carray<T>::operator=(carray const& a)
{
	m_arr = a.m_arr;
	m_size = a.m_size;
	return *this;
}


template <typename T>
inline
bool
carray<T>::equal(array_type const& a) const
{
	return m_size == a.m_size && mstl::equal(m_arr, m_arr + m_size, a.m_arr);
}


template <typename T>
inline
bool
carray<T>::equal(array_type const& a, size_type n) const
{
	M_REQUIRE(n < size());
	return mstl::equal(m_arr, m_arr + n, a.m_arr);
}


template <typename T>
inline
bool
carray<T>::operator==(carray const& a) const
{
	return equal(a);
}


template <typename T>
inline
bool
carray<T>::operator!=(carray const& a) const
{
	return !equal(a);
}


template <typename T>
inline
typename carray<T>::const_reference
carray<T>::operator[](size_type n) const
{
	M_REQUIRE(n < size());
	return m_arr[n];
}


template <typename T>
inline
typename carray<T>::const_reference
carray<T>::at(size_type n) const
{
	M_REQUIRE(n < size());
	return m_arr[n];
}


template <typename T>
inline
typename carray<T>::const_reference
carray<T>::front() const
{
	M_REQUIRE(!empty());
	return m_arr[0];
}


template <typename T>
inline
typename carray<T>::const_reference
carray<T>::back() const
{
	M_REQUIRE(!empty());
	return m_arr[m_size - 1];
}


template <typename T>
inline
typename carray<T>::const_iterator
carray<T>::begin() const
{
	return m_arr;
}


template <typename T>
inline
typename carray<T>::const_iterator
carray<T>::end() const
{
	return &m_arr[m_size];
}


template <typename T>
inline
typename carray<T>::const_reverse_iterator
carray<T>::rbegin() const
{
	return const_reverse_iterator(end());
}


template <typename T>
inline
typename carray<T>::const_reverse_iterator
carray<T>::rend() const
{
	return const_reverse_iterator(begin());
}


template <typename T>
inline
typename carray<T>::const_pointer
carray<T>::data() const
{
	return m_arr;
}

} // namespace mstl

// vi:set ts=3 sw=3:
