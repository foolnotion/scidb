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

#ifndef _mstl_ring_included
#define _mstl_ring_included

#include "m_vector.h"
#include "m_list_node.h"
#include "m_types.h"

namespace mstl {

template <class T>
class ring
{
public:

	typedef T						value_type;
	typedef ring<T>				ring_type;
	typedef value_type*			pointer;
	typedef value_type const*	const_pointer;
	typedef value_type&			reference;
	typedef value_type const&	const_reference;
	typedef ptrdiff_t				difference_type;
	typedef bits::size_t			size_type;

	class iterator
	{
	public:

		typedef ptrdiff_t	difference_type;
		typedef T			value_type;
		typedef T*			pointer;
		typedef T&			reference;

		iterator();
		explicit iterator(bits::node_base* n);

		bool operator==(iterator const& i) const;
		bool operator!=(iterator const& i) const;

		reference operator*() const;
		pointer operator->() const;

		iterator& operator++();
		iterator  operator++(int);
		iterator& operator--();
		iterator  operator--(int);

		iterator& operator+=(int n);
		iterator& operator-=(int n);
		iterator  operator+ (int n) const;
		iterator  operator- (int n) const;

		bits::node_base* base() const;

	private:

		void advance(int n);

		bits::node_base* m_node;
	};

	class const_iterator
	{
	public:

		typedef ptrdiff_t	difference_type;
		typedef T			value_type;
		typedef T const*	pointer;
		typedef T const&	reference;

		const_iterator();
		explicit const_iterator(bits::node_base const* n);
		const_iterator(iterator const& i);

		const_iterator& operator=(const_iterator const& i);
		const_iterator& operator=(iterator const& i);

		bool operator==(const_iterator const& i) const;
		bool operator!=(const_iterator const& i) const;

		reference operator*() const;
		pointer operator->() const;

		const_iterator& operator++();
		const_iterator  operator++(int);
		const_iterator& operator--();
		const_iterator  operator--(int);

		const_iterator& operator+=(int n);
		const_iterator& operator-=(int n);
		const_iterator  operator+ (int n) const;
		const_iterator  operator- (int n) const;

		bits::node_base const* base() const;

	private:

		void advance(int n);

		bits::node_base const* m_node;
	};

	explicit ring(size_type n = 0);
	ring(size_type n, const_reference v);
	ring(ring const& v);

#if HAVE_0X_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR
	ring(ring&& v);
	ring& operator=(ring&& v);
#endif

	ring& operator=(ring const& v);

	reference front();
	const_reference front() const;
	reference back();
	const_reference back() const;

	bool empty() const;

	size_type size() const;
	size_type capacity() const;
	size_type free() const;

	iterator begin();
	const_iterator begin() const;
	iterator end();
	const_iterator end() const;

	void push_back();
	void push_back(const_reference v);

	void resize(iterator i);
	void resize(const_iterator i);
	void reserve(size_type n);
	void clear();
	void swap(ring& v);

private:

	struct node : public bits::node_base
	{
		T m_data;
		unsigned m_index;
	};

	void init(size_type capacity);
	void prepare(size_type k);

	vector<node>	m_list;
	node*				m_first;
	node*				m_last;
};

} // namespace mstl

#include "m_ring.ipp"

#endif // _mstl_ring_included

// vi:set ts=3 sw=3:
