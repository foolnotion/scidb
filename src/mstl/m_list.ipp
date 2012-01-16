// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_utility.h"

namespace mstl {

template <typename T> inline void swap(list<T>& lhs, list<T>& rhs) { lhs.swap(rhs); }

template <typename T> inline list<T>::list() {}
template <typename T> inline list<T>::list(size_type n) { m_vec.resize(n, 0); }

template <typename T> inline bool list<T>::empty() const { return m_vec.empty(); }
template <typename T> inline typename list<T>::size_type list<T>::size() const { return m_vec.size(); }


template <typename T>
list<T>::list(size_type n, const_reference v)
{
	m_vec.reserve(n);

	for (size_type i = 0; i < n; ++i)
		m_vec.push_back(new T(v));
}


template <typename T>
inline
list<T>::list(list const& v)
{
	*this = v;
}


template <typename T>
inline
list<T>::~list() throw()
{
	size_type n = size();

	for (size_type i = 0; i < n; ++i)
		delete m_vec[i];
}


template <typename T>
inline
list<T>&
list<T>::operator=(list const& v)
{
	if (this != &v)
	{
		size_type n = v.size();

		m_vec.clear();
		m_vec.reserve(n);

		for (size_type i = 0; i < n; ++i)
			m_vec.push_back(new T(*v.m_vec[i]));
	}

	return *this;
}


template <typename T>
inline
typename list<T>::size_type
list<T>::capacity() const
{
	return m_vec.capacity();
}


template <typename T>
inline
typename list<T>::reference
list<T>::operator[](size_type n)
{
	return *m_vec[n];
}


template <typename T>
inline
typename list<T>::const_reference
list<T>::operator[](size_type n) const
{
	return *m_vec[n];
}


template <typename T>
inline
typename list<T>::reference
list<T>::front()
{
	return *m_vec.front();
}


template <typename T>
inline
typename list<T>::const_reference
list<T>::front() const
{
	return *m_vec.front();
}


template <typename T>
inline
typename list<T>::reference
list<T>::back()
{
	return *m_vec.back();
}


template <typename T>
inline
typename list<T>::const_reference
list<T>::back() const
{
	return *m_vec.back();
}


template <typename T>
inline
typename list<T>::iterator
list<T>::begin()
{
	return m_vec.begin();
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::begin() const
{
	return m_vec.begin();
}


template <typename T>
inline
typename list<T>::iterator
list<T>::end()
{
	return m_vec.end();
}


template <typename T>
inline
typename list<T>::const_iterator
list<T>::end() const
{
	return m_vec.end();
}


template <typename T>
inline
void
list<T>::push_back(const_reference v)
{
	m_vec.push_back(new T(v));
}


template <typename T>
inline
void
list<T>::push_back()
{
	m_vec.push_back(new T());
}


template <typename T>
inline
void
list<T>::pop_back()
{
	delete m_vec.back();
	m_vec.pop_back();
}


template <typename T>
inline
typename list<T>::iterator
list<T>::insert(iterator i, const_reference value)
{
	return m_vec.insert(i.ref(), new T(value));
}


template <typename T>
inline
typename list<T>::iterator
list<T>::erase(iterator i)
{
	delete *i.ref();
	m_vec.erase(i);
}


template <typename T>
inline
void
list<T>::reserve(size_type n)
{
	m_vec.reserve(n);
}


template <typename T>
inline
void
list<T>::reserve_exact(size_type n)
{
	m_vec.reserve_exact(n);
}


template <typename T>
void
list<T>::resize(size_type n)
{
	if (n > size())
	{
		m_vec.reserve(n);
		n -= size();

		while (n--)
			m_vec.push_back(new T());
	}
}


template <typename T>
void
list<T>::resize(size_type n, const_reference v)
{
	if (n > size())
	{
		m_vec.reserve(n);
		n -= size();

		while (n--)
			m_vec.push_back(new T(v));
	}
}


template <typename T>
inline
void
list<T>::clear()
{
	size_type n = size();

	for (size_type i = 0; i < n; ++i)
		delete m_vec[i];

	m_vec.clear();
}


template <typename T>
inline
void
list<T>::swap(list& v)
{
	m_swap(v.m_vec);
}


template <typename T>
inline
void
list<T>::release()
{
	clear();
	m_vec.release();
}


template <typename T>
inline
typename list<T>::vector_type const&
list<T>::base() const
{
	return m_vec;
}


template <typename T>
inline
typename list<T>::vector_type&
list<T>::base()
{
	return m_vec;
}

#if HAVE_0X_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

//template <typename T>
//inline list<T>::list(list&& v) : mstl::move(m_vec) {}


template <typename T>
inline
list<T>&
list<T>::operator=(list&& v)
{
	m_vec = mstl::move(v.m_vec);
	return *this;
}

#endif

} // namespace mstl

// vi:set ts=3 sw=3:
