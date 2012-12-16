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

#ifndef _mstl_iterator_included
#define _mstl_iterator_included

#include <stddef.h>

namespace mstl {

template <typename T>
class reverse_iterator
{
public:

	typedef T				value_type;
	typedef value_type*	pointer;
	typedef pointer		iterator;
	typedef value_type&	reference;
	typedef ptrdiff_t		difference_type;

	explicit reverse_iterator(iterator i);

	reverse_iterator& operator=(iterator i);

	bool operator==(reverse_iterator const& iter) const;
	bool operator!=(reverse_iterator const& iter) const;
	bool operator<=(reverse_iterator const& iter) const;
	bool operator< (reverse_iterator const& iter) const;

	iterator base() const;

	reference operator*() const;
	pointer operator->() const;

	reverse_iterator& operator++();
	reverse_iterator& operator--();
	reverse_iterator  operator++(int);
	reverse_iterator  operator--(int);
	reverse_iterator& operator+=(size_t n);
	reverse_iterator& operator-=(size_t n);
	reverse_iterator  operator+(size_t n) const;
	reverse_iterator  operator-(size_t n) const;

	reference operator[](difference_type n) const;
	difference_type operator-(reverse_iterator const& i) const;

protected:

	iterator m_i;
};


template <typename T>
class const_reverse_iterator
{
public:

	typedef T						value_type;
	typedef value_type const*	const_pointer;
	typedef value_type*			iterator;
	typedef const_pointer		const_iterator;
	typedef value_type const&	const_reference;
	typedef ptrdiff_t				difference_type;

	explicit const_reverse_iterator(const_iterator i);
	explicit const_reverse_iterator(iterator i);

	const_reverse_iterator& operator=(const_iterator i);
	const_reverse_iterator& operator=(iterator i);

	bool operator==(const_reverse_iterator const& iter) const;
	bool operator!=(const_reverse_iterator const& iter) const;
	bool operator<=(const_reverse_iterator const& iter) const;
	bool operator< (const_reverse_iterator const& iter) const;

	const_iterator base() const;

	const_reference operator*() const;
	const_pointer operator->() const;

	const_reverse_iterator& operator++();
	const_reverse_iterator& operator--();
	const_reverse_iterator  operator++(int);
	const_reverse_iterator  operator--(int);
	const_reverse_iterator& operator+=(size_t n);
	const_reverse_iterator& operator-=(size_t n);
	const_reverse_iterator  operator+(size_t n) const;
	const_reverse_iterator  operator-(size_t n) const;

	const_reference operator[](difference_type n) const;
	difference_type operator-(const_reverse_iterator const& i) const;

protected:

	const_iterator m_i;
};


/// \class back_insert_iterator
/// \ingroup IteratorAdaptors
/// \brief Calls push_back on bound container for each assignment.
template <class Container>
class back_insert_iterator
{
public:

	typedef typename Container::value_type			value_type;
	typedef typename Container::difference_type	difference_type;
	typedef typename Container::pointer				pointer;
	typedef typename Container::reference			reference;

	explicit back_insert_iterator(Container& ctr);

	back_insert_iterator& operator=(typename Container::const_reference v);

	back_insert_iterator& operator*();
	back_insert_iterator& operator++();
	back_insert_iterator  operator++(int);

protected:

	Container& m_container;
};


template <class Container> back_insert_iterator<Container> back_inserter(Container& ctr);

} // namespace mstl

#include "m_iterator.ipp"

#endif // _mstl_iterator_included

// vi:set ts=3 sw=3:
