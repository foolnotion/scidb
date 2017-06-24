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

#ifndef _mstl_carray_included
#define _mstl_carray_included

#include "m_types.h"
#include "m_type_traits.h"
#include "m_pointer_iterator.h"
#include "m_iterator.h"

namespace mstl {

template <typename T>
class carray
{
public:

	typedef T						value_type;
	typedef value_type const*	const_pointer;
	typedef value_type const&	const_reference;
	typedef ptrdiff_t				difference_type;
	typedef bits::size_t			size_type;
	typedef carray<value_type>	array_type;

	typedef pointer_const_iterator<T> const_iterator;
	typedef mstl::const_reverse_iterator<const_iterator> const_reverse_iterator;

	carray();
	carray(const_pointer elems, size_type size);
	carray(carray const& a);

	carray& operator=(carray const& a);

	bool operator==(carray const& a) const;
	bool operator!=(carray const& a) const;

	const_reference operator[](size_type n) const;
	const_reference at(size_type n) const;
	const_reference front() const;
	const_reference back() const;

	bool empty() const;

	size_type size() const;

	const_iterator begin() const;
	const_iterator end() const;

	const_reverse_iterator rbegin() const;
	const_reverse_iterator rend() const;

	const_pointer data() const;

	bool equal(array_type const& v) const;
	bool equal(array_type const& v, size_type n) const;

private:

	value_type const*	m_arr;
	size_type			m_size;
};


template <typename T> struct is_movable;
template <typename T> struct is_pod;

template <typename T> struct is_movable< carray<T> >	{ enum { value = 1 }; };
template <typename T> struct is_pod< carray<T> >		{ enum { value = 1 }; };

template <typename T> struct memory_is_contiguous< carray<T> > { enum { value = 1 }; };

} // namespace mstl

#include "m_carray.ipp"

#endif // _mstl_carray_included

// vi:set ts=3 sw=3:
