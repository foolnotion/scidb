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

#ifndef _mstl_vector_included
#define _mstl_vector_included

#include "m_type_traits.h"
#include "m_memblock.h"
#include "m_vector.h"

#include <stddef.h>

namespace mstl {

template <typename T>
class vector : protected memblock<T>
{
public:

	typedef T						value_type;
	typedef vector<value_type>	vector_type;
	typedef value_type*			pointer;
	typedef value_type const*	const_pointer;
	typedef pointer				iterator;
	typedef const_pointer		const_iterator;
	typedef value_type&			reference;
	typedef value_type const&	const_reference;
	typedef size_t					size_type;
	typedef ptrdiff_t				difference_type;

	class reverse_iterator
	{
	public:

		explicit reverse_iterator(iterator i);

		reverse_iterator& operator=(iterator i);

		bool operator==(reverse_iterator const& iter) const;
		bool operator!=(reverse_iterator const& iter) const;
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

	vector();
	explicit vector(size_type n);
	vector(size_type n, const_reference v);
	vector(vector const& v);
	vector(vector const& v, size_type n);
	template <typename Iter> vector(Iter* first, Iter* last);
	~vector() throw();

	vector& operator=(vector const& v);

	bool operator==(vector const& v) const;
	bool operator!=(vector const& v) const;

	reference operator[](size_type n);
	const_reference operator[](size_type n) const;
	reference at(size_type n);
	const_reference at(size_type n) const;
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

	reverse_iterator rbegin();
	reverse_iterator rend();

	void push_back(const_reference v);
	void push_back();
	void push_front(const_reference v);
	void push_front();
	void pop_back();
	void pop_front();

	bool equal(vector_type const& v) const;
	bool equal(vector_type const& v, size_type n) const;

	iterator insert(iterator position, const_reference value);
	void insert(iterator position, size_type n, const_reference value);
	template <typename Iterator>
	void insert(iterator position, Iterator first, Iterator last);

	iterator erase(iterator position);
	iterator erase(iterator first, iterator last);

	void fill(value_type const& value);

	void reserve(size_type n);
	void reserve_exact(size_type n);
	void resize(size_type n);
	void resize(size_type n, const_reference v);
	void clear();
	void swap(vector& v);
	void release();

private:

	void fill_insert(iterator position, size_type n, const_reference value);
	void insert_aux(iterator position, const_reference value);
};

template <typename T> void swap(vector<T>& lhs, vector<T>& rhs);

} // namespace mstl

#include "m_vector.ipp"

#endif // _mstl_vector_included

// vi:set ts=3 sw=3:
