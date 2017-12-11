// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"
#include "m_construct.h"
#include "m_assert.h"

namespace mstl {

template <typename T>
inline
list<T>::iterator::iterator()
	:m_node(0)
{
}


template <typename T>
inline
list<T>::iterator::iterator(bits::node_base* n)
	:m_node(n)
{
}


template <typename T>
inline
bool
list<T>::iterator::operator==(iterator const& i) const
{
	return m_node == i.m_node;
}


template <typename T>
inline
bool
list<T>::iterator::operator!=(iterator const& i) const
{
	return m_node != i.m_node;
}


template <typename T>
inline
typename list<T>::iterator::reference
list<T>::iterator::operator*() const
{
	M_ASSERT(m_node);
	return static_cast<node*>(m_node)->m_data;
}


template <typename T>
inline
typename list<T>::iterator::pointer
list<T>::iterator::operator->() const
{
	M_ASSERT(m_node);
	return &static_cast<node*>(m_node)->m_data;
}


template <typename T>
inline
typename list<T>::iterator&
list<T>::iterator::operator++()
{
	M_ASSERT(m_node);

	m_node = m_node->m_next;
	return *this;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::iterator::operator++(int)
{
	M_ASSERT(m_node);

	iterator tmp = *this;
	m_node = m_node->m_next;
	return tmp;
}


template <typename T>
inline
typename list<T>::iterator&
list<T>::iterator::operator--()
{
	M_ASSERT(m_node);

	m_node = m_node->m_prev;
	return *this;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::iterator::operator--(int)
{
	M_ASSERT(m_node);

	iterator tmp = *this;
	m_node = m_node->m_prev;
	return tmp;
}


template <typename T>
inline
void
list<T>::iterator::advance(int n)
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
typename list<T>::iterator&
list<T>::iterator::operator+=(int n)
{
	advance(n);
	return *this;
}


template <typename T>
inline
typename list<T>::iterator&
list<T>::iterator::operator-=(int n)
{
	advance(-n);
	return *this;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::iterator::operator+(int n) const
{
	iterator i(*this);
	i.advance(n);
	return i;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::iterator::operator-(int n) const
{
	iterator i(*this);
	i.advance(-n);
	return i;
}


template <typename T>
inline
bits::node_base*
list<T>::iterator::base() const
{
	return m_node;
}


template <typename T>
inline
list<T>::const_iterator::const_iterator()
	:m_node(0)
{
}


template <typename T>
inline
list<T>::const_iterator::const_iterator(bits::node_base const* n)
	:m_node(n)
{
}


template <typename T>
inline
list<T>::const_iterator::const_iterator(iterator const& i)
	:m_node(i.base())
{
}


template <typename T>
inline
typename list<T>::const_iterator&
list<T>::const_iterator::operator=(const_iterator const& i)
{
	m_node = i.m_node;
	return *this;
}


template <typename T>
inline
typename list<T>::const_iterator&
list<T>::const_iterator::operator=(iterator const& i)
{
	m_node = i.base();
	return *this;
}


template <typename T>
inline
bool
list<T>::const_iterator::operator==(const_iterator const& i) const
{
	return m_node == i.m_node;
}


template <typename T>
inline
bool
list<T>::const_iterator::operator!=(const_iterator const& i) const
{
	return m_node != i.m_node;
}


template <typename T>
inline
typename list<T>::const_iterator::reference
list<T>::const_iterator::operator*() const
{
	M_ASSERT(m_node);
	return static_cast<node const*>(m_node)->m_data;
}


template <typename T>
inline
typename list<T>::const_iterator::pointer
list<T>::const_iterator::operator->() const
{
	M_ASSERT(m_node);
	return &static_cast<node const*>(m_node)->m_data;
}


template <typename T>
inline
typename list<T>::const_iterator&
list<T>::const_iterator::operator++()
{
	M_ASSERT(m_node);

	m_node = m_node->m_next;
	return *this;
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::const_iterator::operator++(int)
{
	M_ASSERT(m_node);

	const_iterator tmp = *this;
	m_node = m_node->m_next;
	return tmp;
}


template <typename T>
inline
typename list<T>::const_iterator&
list<T>::const_iterator::operator--()
{
	M_ASSERT(m_node);

	m_node = m_node->m_prev;
	return *this;
}


template <typename T>
inline
void
list<T>::const_iterator::advance(int n)
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
typename list<T>::const_iterator&
list<T>::const_iterator::operator+=(int n)
{
	advance(n);
	return *this;
}


template <typename T>
inline
typename list<T>::const_iterator&
list<T>::const_iterator::operator-=(int n)
{
	advance(-n);
	return *this;
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::const_iterator::operator+(int n) const
{
	const_iterator i(*this);
	i.advance(n);
	return i;
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::const_iterator::operator-(int n) const
{
	const_iterator i(*this);
	i.advance(-n);
	return i;
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::const_iterator::operator--(int)
{
	M_ASSERT(m_node);

	const_iterator tmp = *this;
	m_node = m_node->m_prev;
	return tmp;
}


template <typename T>
inline
void
list<T>::init()
{
	m_size = 0;
	m_node.m_next = &m_node;
	m_node.m_prev = &m_node;
}


template <typename T>
inline
void
list<T>::push_back(const_reference v)
{
	create_node(v)->hook(&m_node);
}


template <typename T>
inline
typename list<T>::reference
list<T>::push_back()
{
	node* p = create_node(T());
	p->hook(&m_node);
	return p->m_data;
}


template <typename T>
inline
void
list<T>::pop_back()
{
	M_REQUIRE(!empty());
	erase(m_node.m_prev);
}


template <typename T>
inline
void
list<T>::push_front(const_reference v)
{
	create_node(v)->hook(m_node.m_next);
}


template <typename T>
inline
typename list<T>::reference
list<T>::push_front()
{
	node* p = create_node(T());
	p->hook(m_node.m_next);
	return p->m_data;
}


template <typename T>
inline
void
list<T>::pop_front()
{
	M_REQUIRE(!empty());
	erase(m_node.m_next);
}


template <typename T>
inline
list<T>::list(size_type n, const_reference v)
{
	init();

	for ( ; n > 0; --n)
		push_back(v);
}


template <typename T>
inline
list<T>::list(size_type n)
{
	T v;

	init();

	for ( ; n > 0; --n)
		push_back(v);
}


template <typename T>
inline
list<T>::list(list const& v)
{
	init();
	*this = v;
}


template <typename T>
inline
list<T>::~list()
{
	clear();
}


template <typename T>
inline
typename list<T>::size_type
list<T>::size() const
{
	return m_size;
}


template <typename T>
inline
typename list<T>::size_type
list<T>::capacity() const
{
	return size_type(-1);
}


template <typename T>
inline
typename list<T>::iterator
list<T>::begin()
{
	return iterator(m_node.m_next);
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::begin() const
{
	return const_iterator(m_node.m_next);
}


template <typename T>
inline
typename list<T>::iterator
list<T>::end()
{
	return iterator(&m_node);
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::end() const
{
	return const_iterator(&m_node);
}


template <typename T>
inline
typename list<T>::reverse_iterator
list<T>::rbegin()
{
	return reverse_iterator(end());
}


template <typename T>
inline
typename list<T>::reverse_iterator
list<T>::rend()
{
	return reverse_iterator(begin());
}


template <typename T>
inline
typename list<T>::const_reverse_iterator
list<T>::rbegin() const
{
	return const_reverse_iterator(end());
}


template <typename T>
inline
typename list<T>::const_reverse_iterator
list<T>::rend() const
{
	return const_reverse_iterator(begin());
}


template <typename T>
inline
bool
list<T>::empty() const
{
	return m_size == 0;
}


template <typename T>
inline
typename list<T>::reference
list<T>::front()
{
	M_REQUIRE(!empty());
	return static_cast<node*>(m_node.m_next)->m_data;
}


template <typename T>
inline
typename list<T>::const_reference
list<T>::front() const
{
	M_REQUIRE(!empty());
	return static_cast<node const*>(m_node.m_next)->m_data;
}


template <typename T>
inline
typename list<T>::reference
list<T>::back()
{
	M_REQUIRE(!empty());
	return static_cast<node*>(m_node.m_prev)->m_data;
}


template <typename T>
inline
typename list<T>::const_reference
list<T>::back() const
{
	M_REQUIRE(!empty());
	return static_cast<node const*>(m_node.m_prev)->m_data;
}


template <typename T>
inline
typename list<T>::node*
list<T>::create_node(T const& x)
{
	node* p = static_cast<node*>(::operator new(sizeof(node)));

	try
	{
		mstl::bits::construct(&p->m_data, x);
	}
	catch (...)
	{
		::operator delete(p);
		throw;
	}

	++m_size;
	return p;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::insert(iterator i, const_reference value)
{
	node* n = create_node(value);
	n->hook(i.base());
	return iterator(n);
}


template <typename T>
inline
void
list<T>::insert(iterator i, size_type n, const_reference value)
{
	for ( ; n > 0; --n)
		create_node(value)->hook(i.base());
}


template <typename T>
inline
void
list<T>::insert(iterator pos, const_iterator first, const_iterator last)
{
	for ( ; first != last; ++first)
		create_node(*first)->hook(pos.base());
}


template <typename T>
inline
void
list<T>::erase(bits::node_base* n)
{
	--m_size;
	n->unhook();
	node* tmp = static_cast<node*>(n);
	mstl::bits::destroy(&tmp->m_data);
	::operator delete(tmp);
}


template <typename T>
inline
typename list<T>::iterator
list<T>::erase(iterator i)
{
	iterator ret = iterator(i.base()->m_next);
	erase(i.base());
	return ret;
}


template <typename T>
inline
typename list<T>::iterator
list<T>::erase(iterator first, iterator last)
{
	while (first != last)
		first = erase(first);

	return last;
}


template <typename T>
inline
void
list<T>::resize(size_type n, const_reference v)
{
	if (n == size())
		return;

	iterator		i		= begin();
	size_type	len	= 0;

	while (i != end() && len < n)
		++i, ++len;

	if (len == n)
		erase(i, end());
	else
		insert(end(), n - len, v);
}


template <typename T>
inline
void
list<T>::resize(size_type n)
{
	resize(n, T());
}


template <typename T>
inline
void
list<T>::clear()
{
	node* curr = static_cast<node*>(m_node.m_next);

	while (curr != &m_node)
	{
		node* n = curr;
		curr = static_cast<node*>(curr->m_next);
		mstl::bits::destroy(&n->m_data);
		::operator delete(n);
	}

	init();
}


template <typename T>
inline
void
list<T>::swap(list& v)
{
	m_node.swap(v.m_node);
	swap(m_size, v.m_size);
}


template <typename T>
inline
list<T>&
list<T>::operator=(list const& v)
{
	if (this != &v)
	{
		iterator first1	= begin();
		iterator last1		= end();

		const_iterator first2	= v.begin();
		const_iterator last2		= v.end();

		for ( ; first1 != last1 && first2 != last2; ++first1, ++first2)
			*first1 = *first2;

		if (first2 == last2)
			erase(first1, last1);
		else
			insert(last1, first2, last2);
	}

	return *this;
}


template <typename T>
inline
list<T>&
list<T>::operator+=(list const& v)
{
	const_iterator first	= v.begin();
	const_iterator last	= v.end();

	for ( ; first != last; ++first)
		push_back(*first);

	return *this;
}

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename T>
inline
list<T>&
list<T>::operator=(list&& v)
{
	swap(v);
	return *this;
}

#endif


template <typename T> inline void swap(list<T>& lhs, list<T>& rhs) { lhs.swap(rhs); }

template <typename T> inline list<T>::list() { init(); }

} // namespace mstl

// vi:set ts=3 sw=3:
