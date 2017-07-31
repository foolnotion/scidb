// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"
#include "m_limits.h"
#include "m_assert.h"

namespace mstl {

template <typename T>
inline range<T>::iterator::iterator(value_type i) :m_i(i) {}

template <typename T>
inline bool range<T>::iterator::operator==(iterator const& i) const { return m_i == i.m_i; }
template <typename T>
inline bool range<T>::iterator::operator!=(iterator const& i) const { return m_i != i.m_i; }
template <typename T>
inline bool range<T>::iterator::operator<=(iterator const& i) const { return m_i <= i.m_i; }
template <typename T>
inline bool range<T>::iterator::operator< (iterator const& i) const { return m_i <  i.m_i; }

template <typename T> inline T const* range<T>::iterator::operator->() const	{ return &m_i; }
template <typename T> inline T range<T>::iterator::operator*() const				{ return m_i; }

template <typename T>
inline
typename range<T>::iterator&
range<T>::iterator::operator++()
{
	++m_i;
	return *this;
}

template <typename T>
inline
typename range<T>::iterator
range<T>::iterator::operator++(int)
{
	iterator i(m_i); ++m_i;
	return *this;
}

template <typename T>
inline range<T>::range() :m_left(0), m_right(0) {}

template <typename T> inline bool range<T>::empty() const	{ return m_left == m_right; }
template <typename T> inline bool range<T>::unit() const		{ return m_left + 1 == m_right; }

template <typename T>
inline bool range<T>::contains(value_type i) const	{ return m_left <= i && i < m_right; }

template <typename T> inline T range<T>::size() const		{ return m_right - m_left; }
template <typename T> inline T range<T>::left() const		{ return m_left; }
template <typename T> inline T range<T>::lower() const	{ return m_left; }
template <typename T> inline T range<T>::right() const	{ return m_right; }
template <typename T> inline T range<T>::upper() const	{ return m_right; }

template <typename T>
inline typename range<T>::iterator range<T>::begin() const	{ return iterator(m_left); }
template <typename T>
inline typename range<T>::iterator range<T>::end() const		{ return iterator(m_right); }

template <typename T> inline void range<T>::clear() { m_left = m_right = 0; }


template <typename T>
inline
range<T>::range(bool flag)
	:m_left(numeric_limits<T>::min())
	,m_right(numeric_limits<T>::max())
{
	if (!flag)
		m_left = m_right = 0;
}


template <typename T>
inline
range<T>::range(value_type left, value_type right)
	:m_left(left)
	,m_right(right)
{
	M_REQUIRE(left <= right);
}


template <typename T>
inline
bool
range<T>::range::operator==(range const& r) const
{
	return m_left == r.m_left && m_right == r.m_right;
}


template <typename T>
inline
bool
range<T>::range::operator!=(range const& r) const
{
	return m_left != r.m_left || m_right != r.m_right;
}


template <typename T>
inline
void
range<T>::swap(range& r)
{
	mstl::swap(m_left, r.m_left);
	mstl::swap(m_right, r.m_right);
}


template <typename T>
inline
bool
range<T>::adjacent(range const& r) const
{
	return m_right + 1 == r.m_left || r.m_right + 1 == m_left;
}


template <typename T>
inline
bool
range<T>::intersects(range const& r) const
{
	return m_left < m_right && m_left <= r.m_right && r.m_left <= m_right;
}


template <typename T>
inline
bool
range<T>::disjoint(range const& r) const
{
	return !intersects(r);
}


template <typename T>
inline
void
range<T>::set_left(value_type left)
{
	m_left = left;
}


template <typename T>
inline
void
range<T>::set_right(value_type right)
{
	m_right = right;
}


template <typename T>
inline
void
range<T>::setup(value_type left, value_type right)
{
	m_left = left;
	m_right = right;
}


template <typename T>
inline
void
range<T>::setup_widest()
{
	m_left = numeric_limits<T>::min();
	m_right = numeric_limits<T>::max();
}


template <typename T>
inline
void
range<T>::setup()
{
	m_left = numeric_limits<T>::max();
	m_right = numeric_limits<T>::min();
}


template <typename T>
inline
range<T>&
range<T>::operator|=(range const& r)
{
	M_REQUIRE(intersects(r) || adjacent(r));

	m_left = mstl::min(m_left, r.m_left);
	m_right = mstl::max(m_right, r.m_right);

	return *this;
}


template <typename T>
inline
range<T>&
range<T>::operator&=(range const& r)
{
	m_left = mstl::max(m_left, r.m_left);
	m_right = mstl::min(m_right, r.m_right);

	if (m_left > m_right)
		m_right = m_left;

	return *this;
}


template <typename T>
inline
range<T>&
range<T>::operator-=(range const& r)
{
	value_type left	= mstl::max(m_left, r.m_left);
	value_type right	= mstl::min(m_right, r.m_right);

	if (left < right)
	{
		if (left == r.m_left)
			m_right = right;
		else if (right == r.m_right)
			m_left = left;
	}

	return *this;
}


template <typename T>
inline
range<T>
range<T>::operator|(range const& r) const
{
	return range(*this) |= r;
}


template <typename T>
inline
range<T>
range<T>::operator&(range const& r) const
{
	return range(*this) &= r;
}


template <typename T>
inline
range<T>
range<T>::operator-(range const& r) const
{
	return range(*this) -= r;
}

} // namespace mstl

// vi:set ts=3 sw=3:
