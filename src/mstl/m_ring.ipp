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
ring<T>::iterator::iterator()
	:m_node(0)
{
}


template <typename T>
inline
ring<T>::iterator::iterator(bits::node_base* n)
	:m_node(n)
{
}


template <typename T>
inline
bool
ring<T>::iterator::operator==(iterator const& i) const
{
	return m_node == i.m_node;
}


template <typename T>
inline
bool
ring<T>::iterator::operator!=(iterator const& i) const
{
	return m_node != i.m_node;
}


template <typename T>
inline
typename ring<T>::iterator::reference
ring<T>::iterator::operator*() const
{
	M_ASSERT(m_node);
	return static_cast<node*>(m_node)->m_data;
}


template <typename T>
inline
typename ring<T>::iterator::pointer
ring<T>::iterator::operator->() const
{
	M_ASSERT(m_node);
	return &static_cast<node*>(m_node)->m_data;
}


template <typename T>
inline
typename ring<T>::iterator::iterator&
ring<T>::iterator::operator++()
{
	M_ASSERT(m_node);

	m_node = m_node->m_next;
	return *this;
}


template <typename T>
inline
typename ring<T>::iterator::iterator
ring<T>::iterator::operator++(int)
{
	M_ASSERT(m_node);

	iterator tmp = *this;
	m_node = m_node->m_next;
	return tmp;
}


template <typename T>
inline
typename ring<T>::iterator::iterator&
ring<T>::iterator::operator--()
{
	M_ASSERT(m_node);

	m_node = m_node->m_prev;
	return *this;
}


template <typename T>
inline
typename ring<T>::iterator::iterator
ring<T>::iterator::operator--(int)
{
	M_ASSERT(m_node);

	iterator tmp = *this;
	m_node = m_node->m_prev;
	return tmp;
}


template <typename T>
inline
void
ring<T>::iterator::advance(int n)
{
	M_ASSERT(m_node);

	if (n < 0)
	{
		for ( ; n < 0; ++n)
			m_node = m_node->m_prev;
	}
	else
	{
		for ( ; n > 0; --n)
			m_node = m_node->m_next;
	}
}


template <typename T>
inline
typename ring<T>::iterator&
ring<T>::iterator::operator+=(int n)
{
	advance(n);
	return *this;
}


template <typename T>
inline
typename ring<T>::iterator&
ring<T>::iterator::operator-=(int n)
{
	advance(-n);
	return *this;
}


template <typename T>
inline
typename ring<T>::iterator
ring<T>::iterator::operator+(int n) const
{
	iterator i(*this);
	i.advance(n);
	return i;
}


template <typename T>
inline
typename ring<T>::iterator
ring<T>::iterator::operator-(int n) const
{
	iterator i(*this);
	i.advance(-n);
	return i;
}


template <typename T>
inline
bits::node_base*
ring<T>::iterator::base() const
{
	return m_node;
}


template <typename T>
inline
ring<T>::const_iterator::const_iterator()
	:m_node(0)
{
}


template <typename T>
inline
ring<T>::const_iterator::const_iterator(bits::node_base const* n)
	:m_node(n)
{
}


template <typename T>
inline
ring<T>::const_iterator::const_iterator(iterator const& i)
	:m_node(i.base())
{
}


template <typename T>
inline
typename ring<T>::const_iterator&
ring<T>::const_iterator::operator=(const_iterator const& i)
{
	m_node = i.m_node;
	return *this;
}


template <typename T>
inline
typename ring<T>::const_iterator&
ring<T>::const_iterator::operator=(iterator const& i)
{
	m_node = i.base();
	return *this;
}


template <typename T>
inline
bool
ring<T>::const_iterator::operator==(const_iterator const& i) const
{
	return m_node == i.m_node;
}


template <typename T>
inline
bool
ring<T>::const_iterator::operator!=(const_iterator const& i) const
{
	return m_node != i.m_node;
}


template <typename T>
inline
typename ring<T>::const_iterator::reference
ring<T>::const_iterator::operator*() const
{
	M_ASSERT(m_node);
	return static_cast<node const*>(m_node)->m_data;
}


template <typename T>
inline
typename ring<T>::const_iterator::pointer
ring<T>::const_iterator::operator->() const
{
	M_ASSERT(m_node);
	return &static_cast<node const*>(m_node)->m_data;
}


template <typename T>
inline
typename ring<T>::const_iterator::const_iterator&
ring<T>::const_iterator::operator++()
{
	M_ASSERT(m_node);

	m_node = m_node->m_next;
	return *this;
}


template <typename T>
inline
typename ring<T>::const_iterator::const_iterator
ring<T>::const_iterator::operator++(int)
{
	M_ASSERT(m_node);

	const_iterator tmp = *this;
	m_node = m_node->m_next;
	return tmp;
}


template <typename T>
inline
typename ring<T>::const_iterator::const_iterator&
ring<T>::const_iterator::operator--()
{
	M_ASSERT(m_node);

	m_node = m_node->m_prev;
	return *this;
}


template <typename T>
inline
void
ring<T>::const_iterator::advance(int n)
{
	M_ASSERT(m_node);

	if (n < 0)
	{
		for ( ; n < 0; ++n)
			m_node = m_node->m_prev;
	}
	else
	{
		for ( ; n > 0; --n)
			m_node = m_node->m_next;
	}
}


template <typename T>
inline
typename ring<T>::const_iterator&
ring<T>::const_iterator::operator+=(int n)
{
	advance(n);
	return *this;
}


template <typename T>
inline
typename ring<T>::const_iterator&
ring<T>::const_iterator::operator-=(int n)
{
	advance(-n);
	return *this;
}


template <typename T>
inline
typename ring<T>::const_iterator
ring<T>::const_iterator::operator+(int n) const
{
	const_iterator i(*this);
	i.advance(n);
	return i;
}


template <typename T>
inline
typename ring<T>::const_iterator::const_iterator
ring<T>::const_iterator::operator-(int n) const
{
	const_iterator i(*this);
	i.advance(-n);
	return i;
}


template <typename T>
inline
typename ring<T>::const_iterator::const_iterator
ring<T>::const_iterator::operator--(int)
{
	M_ASSERT(m_node);

	const_iterator tmp = *this;
	m_node = m_node->m_prev;
	return tmp;
}


template <typename T>
inline
bits::node_base const*
ring<T>::const_iterator::base() const
{
	return m_node;
}


template <typename T>
inline
void
ring<T>::clear()
{
	m_first = &m_list[0];
	m_last = &m_list[0];
}


template <typename T>
inline
void
ring<T>::init(size_type capacity)
{
	reserve(capacity);
	clear();
}


template <typename T>
inline
bool
ring<T>::empty() const
{
	return m_first == m_last;
}


template <typename T>
inline
typename ring<T>::size_type
ring<T>::capacity() const
{
	return m_list.size() - 1;
}


template <typename T>
inline
typename ring<T>::size_type
ring<T>::size() const
{
	if (m_first->m_index <= m_last->m_index)
		return m_last->m_index - m_first->m_index - 1;
	
	return m_list.size() - m_first->m_index - m_last->m_index - 1;
}


template <typename T>
inline
typename ring<T>::size_type
ring<T>::free() const
{
	return capacity() - size();
}


template <typename T>
inline
void
ring<T>::push_back(const_reference v)
{
	m_last->m_data = v;
	m_last = static_cast<node*>(m_last->m_next);
	if (m_first == m_last)
		m_first = static_cast<node*>(m_first->m_next);
}


template <typename T>
inline
void
ring<T>::push_back()
{
	push_back(T());
}


template <typename T>
inline
ring<T>::ring(size_type n, const_reference v)
{
	init(n);

	for ( ; n > 0; --n)
		push_back(v);
}


template <typename T>
inline
ring<T>::ring(size_type n)
{
	init(n);
}


template <typename T>
inline
ring<T>::ring(ring const& v)
{
	init(v.capacity());
	*this = v;
}


template <typename T>
inline
typename ring<T>::iterator
ring<T>::begin()
{
	return iterator(m_first);
}


template <typename T>
inline
typename ring<T>::const_iterator
ring<T>::begin() const
{
	return const_iterator(m_first);
}


template <typename T>
inline
typename ring<T>::iterator
ring<T>::end()
{
	return iterator(m_last);
}


template <typename T>
inline
typename ring<T>::const_iterator
ring<T>::end() const
{
	return const_iterator(m_last);
}


template <typename T>
inline
typename ring<T>::reference
ring<T>::front()
{
	M_REQUIRE(!empty());
	return m_first->m_data;
}


template <typename T>
inline
typename ring<T>::const_reference
ring<T>::front() const
{
	M_REQUIRE(!empty());
	return m_first->m_data;
}


template <typename T>
inline
typename ring<T>::reference
ring<T>::back()
{
	M_REQUIRE(!empty());
	return static_cast<node*>(m_last->m_prev)->m_data;
}


template <typename T>
inline
typename ring<T>::const_reference
ring<T>::back() const
{
	M_REQUIRE(!empty());
	return static_cast<node const*>(m_last->m_prev)->m_data;
}


template <typename T>
inline
void
ring<T>::prepare(size_type k)
{
	M_ASSERT(m_list.size() > 0);

	size_type n = m_list.size() - 1;

	if (k == 0)
	{
		m_list[0].m_index = k++;
		if (n > 0)
			m_list[0].m_next = &m_list[1];
		m_list[0].m_prev = &m_list[n];
	}

	for ( ; k < n; ++k)
	{
		m_list[k].m_index = k;
		m_list[k].m_next = &m_list[k + 1];
		m_list[k].m_prev = &m_list[k - 1];
	}

	m_list[n].m_index = n;
	m_list[n].m_next = &m_list[0];
	if (n > 0)
		m_list[n].m_prev = &m_list[n - 1];
}


template <typename T>
inline
void
ring<T>::reserve(unsigned n)
{
	size_type k = m_list.size();

	if (n < k)
		clear();

	m_list.resize(n + 1);
	prepare(k > 0 ? k - 1 : k);
}


template <typename T>
inline
void
ring<T>::resize(iterator i)
{
	m_last = i.base();
}


template <typename T>
inline
void
ring<T>::resize(const_iterator i)
{
	m_last = static_cast<node*>(const_cast<bits::node_base*>(i.base()));
}


template <typename T>
inline
void
ring<T>::swap(ring& v)
{
	m_list.swap(v.m_list);
	m_first.swap(v.m_first);
	m_last.swap(v.m_last);
}


template <typename T>
inline
ring<T>&
ring<T>::operator=(ring const& v)
{
	if (this != &v)
	{
		m_list = v.m_list;
		prepare(0);
		m_first = &m_list[v.m_first->m_index];
		m_last = &m_last[v.m_last->m_index];
	}

	return *this;
}


#if HAVE_0X_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename T>
inline
ring<T>&
ring<T>::operator=(ring&& v)
{
	swap(v);
	return *this;
}

#endif


template <typename T> inline void swap(ring<T>& lhs, ring<T>& rhs) { lhs.swap(rhs); }

} // namespace mstl

// vi:set ts=3 sw=3:
