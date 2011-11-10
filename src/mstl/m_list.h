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

#ifndef _mstl_list_included
#define _mstl_list_included

#include "m_vector.h"
#include "m_pointer_iterator.h"

namespace mstl {

template <typename T>
class list
{
public:

	typedef T									value_type;
	typedef vector<T*>						vector_type;
	typedef list<T>							list_type;
	typedef value_type*						pointer;
	typedef value_type const*				const_pointer;
	typedef pointer_iterator<T>			iterator;
	typedef pointer_const_iterator<T>	const_iterator;
	typedef value_type&						reference;
	typedef value_type const&				const_reference;
	typedef ptrdiff_t							difference_type;
	typedef bits::size_t						size_type;

	list();
	explicit list(size_type n);
	list(size_type n, const_reference v);
	list(list const& v);
	~list() throw();

#if HAVE_0X_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR
	list(list&& v);
	list& operator=(list&& v);
#endif

	list& operator=(list const& v);

	reference operator[](size_type n);
	const_reference operator[](size_type n) const;
	reference front();
	const_reference front() const;
	reference back();
	const_reference back() const;

	bool empty() const;

	size_type size() const;
	size_type capacity() const;

	iterator begin();
	const_iterator begin() const;
	iterator end();
	const_iterator end() const;

	void push_back(const_reference v);
	void push_back();
	void pop_back();

	iterator insert(iterator i, const_reference value);
	iterator erase(iterator i);

	void reserve(size_type n);
	void reserve_exact(size_type n);
	void resize(size_type n);
	void resize(size_type n, const_reference v);
	void clear();
	void swap(list& v);
	void release();

	vector_type const& base() const;
	vector_type& base();	// use with care!

private:

	vector_type m_vec;
};

template <typename T> void swap(list<T>& lhs, list<T>& rhs);

} // namespace mstl

#include "m_list.ipp"

#endif // _mstl_list_included

// vi:set ts=3 sw=3:
