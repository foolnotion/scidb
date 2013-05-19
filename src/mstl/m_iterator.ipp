// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
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

namespace mstl {

template <typename T> inline reverse_iterator<T>::reverse_iterator(iterator i) :m_i(i) {}


template <typename T>
inline
typename reverse_iterator<T>::iterator
reverse_iterator<T>::base() const
{
	return m_i - 1;
}


template <typename T>
inline
reverse_iterator<T>&
reverse_iterator<T>::operator=(iterator i)
{
	m_i = i + 1;
	return *this;
}


template <typename T>
inline
bool
reverse_iterator<T>::operator==(reverse_iterator const& iter) const
{
	return m_i == iter.m_i;
}


template <typename T>
inline
bool
reverse_iterator<T>::operator!=(reverse_iterator const& iter) const
{
	return m_i != iter.m_i;
}


template <typename T>
inline
bool
reverse_iterator<T>::operator<=(reverse_iterator const& iter) const
{
	return iter.m_i <= m_i;
}


template <typename T>
inline
bool
reverse_iterator<T>::operator<(reverse_iterator const& iter) const
{
	return iter.m_i < m_i;
}


template <typename T>
inline
typename reverse_iterator<T>::reference
reverse_iterator<T>::operator*() const
{
	iterator prev = m_i;
	return *--prev;
}


template <typename T>
inline
typename reverse_iterator<T>::pointer
reverse_iterator<T>::operator->() const
{
	return &(operator*());
}


template <typename T>
inline
reverse_iterator<T>&
reverse_iterator<T>::operator++()
{
	--m_i;
	return *this;
}


template <typename T>
inline
reverse_iterator<T>&
reverse_iterator<T>::operator--()
{
	++m_i;
	return *this;
}


template <typename T>
inline
reverse_iterator<T>
reverse_iterator<T>::operator++(int)
{
	reverse_iterator prev = *this;
	--m_i;
	return prev;
}


template <typename T>
inline
reverse_iterator<T>
reverse_iterator<T>::operator--(int)
{
	reverse_iterator prev = *this;
	++m_i;
	return prev;
}


template <typename T>
inline
reverse_iterator<T>&
reverse_iterator<T>::operator+=(size_t n)
{
	m_i -= n;
	return *this;
}


template <typename T>
inline
reverse_iterator<T>&
reverse_iterator<T>::operator-=(size_t n)
{
	m_i += n;
	return *this;
}


template <typename T>
inline
reverse_iterator<T>
reverse_iterator<T>::operator+(size_t n) const
{
	return reverse_iterator(m_i - n);
}


template <typename T>
inline
reverse_iterator<T>
reverse_iterator<T>::operator-(size_t n) const
{
	return reverse_iterator(m_i + n);
}


template <typename T>
inline
typename reverse_iterator<T>::reference
reverse_iterator<T>::operator[](difference_type n) const
{
	return *(*this + n);
}


template <typename T>
inline
typename reverse_iterator<T>::difference_type
reverse_iterator<T>::operator-(reverse_iterator const& i) const
{
	return i.m_i - m_i;
}


template <typename T>
inline
const_reverse_iterator<T>::const_reverse_iterator(iterator i)
	:m_i(i)
{
}


template <typename T>
inline
const_reverse_iterator<T>::const_reverse_iterator(const_iterator i)
	:m_i(i)
{
}


template <typename T>
inline
typename const_reverse_iterator<T>::const_iterator
const_reverse_iterator<T>::base() const
{
	return m_i - 1;
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator=(iterator i)
{
	m_i = i + 1;
	return *this;
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator=(const_iterator i)
{
	m_i = i + 1;
	return *this;
}


template <typename T>
inline
bool
const_reverse_iterator<T>::operator==(const_reverse_iterator const& iter) const
{
	return m_i == iter.m_i;
}


template <typename T>
inline
bool
const_reverse_iterator<T>::operator!=(const_reverse_iterator const& iter) const
{
	return m_i != iter.m_i;
}


template <typename T>
inline
bool
const_reverse_iterator<T>::operator<=(const_reverse_iterator const& iter) const
{
	return iter.m_i <= m_i;
}


template <typename T>
inline
bool
const_reverse_iterator<T>::operator<(const_reverse_iterator const& iter) const
{
	return iter.m_i < m_i;
}


template <typename T>
inline
typename const_reverse_iterator<T>::reference
const_reverse_iterator<T>::operator*() const
{
	const_iterator prev  = m_i;
	return *--prev;
}


template <typename T>
inline
typename const_reverse_iterator<T>::pointer
const_reverse_iterator<T>::operator->() const
{
	return &(operator*());
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator++()
{
	--m_i;
	return *this;
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator--()
{
	++m_i;
	return *this;
}


template <typename T>
inline
const_reverse_iterator<T>
const_reverse_iterator<T>::operator++(int)
{
	const_reverse_iterator prev = *this;
	--m_i;
	return prev;
}


template <typename T>
inline
const_reverse_iterator<T>
const_reverse_iterator<T>::operator--(int)
{
	const_reverse_iterator prev = *this;
	++m_i;
	return prev;
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator+=(size_t n)
{
	m_i -= n;
	return *this;
}


template <typename T>
inline
const_reverse_iterator<T>&
const_reverse_iterator<T>::operator-=(size_t n)
{
	m_i += n;
	return *this;
}


template <typename T>
inline
const_reverse_iterator<T>
const_reverse_iterator<T>::operator+(size_t n) const
{
	return const_reverse_iterator(m_i - n);
}


template <typename T>
inline
const_reverse_iterator<T>
const_reverse_iterator<T>::operator-(size_t n) const
{
	return const_reverse_iterator(m_i + n);
}


template <typename T>
inline
typename const_reverse_iterator<T>::reference
const_reverse_iterator<T>::operator[](difference_type n) const
{
	return *(*this + n);
}


template <typename T>
inline
typename const_reverse_iterator<T>::difference_type
const_reverse_iterator<T>::operator-(const_reverse_iterator const& i) const
{
	return i.m_i - m_i;
}


template <class Container>
inline
back_insert_iterator<Container>::back_insert_iterator(Container& ctr) : m_container(ctr) {}


template <class Container>
inline
back_insert_iterator<Container>&
back_insert_iterator<Container>::operator=(typename Container::const_reference v)
{
	m_container.push_back(v);
	return *this;
}


template <class Container>
inline
back_insert_iterator<Container>&
back_insert_iterator<Container>::operator*()
{
	return *this;
}


template <class Container>
inline
back_insert_iterator<Container>&
back_insert_iterator<Container>::operator++()
{
	return *this;
}


template <class Container>
inline
back_insert_iterator<Container>
back_insert_iterator<Container>::operator++(int)
{
	return *this;
}


/// Returns the back_insert_iterator for \p ctr.
template <class Container>
inline
back_insert_iterator<Container>
back_inserter(Container& ctr)
{
	return back_insert_iterator<Container>(ctr);
}

} // namespace mstl

// vi:set ts=3 sw=3:
