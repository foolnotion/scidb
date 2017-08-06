// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _mstl_chunk_vector_included
#define _mstl_chunk_vector_included

#include "m_vector.h"

namespace mstl {

template <typename T, unsigned Chunk_Shift = 16>
class chunk_vector
{
public:

	enum { Chunk_Size = 1u << 16 };

	typedef T						value_type;
	typedef value_type*			pointer;
	typedef value_type const*	const_pointer;
	typedef value_type&			reference;
	typedef value_type const&	const_reference;
	typedef ptrdiff_t				difference_type;
	typedef bits::size_t			size_type;

	class const_iterator;

	class iterator
	{
	public:

		typedef T				value_type;
		typedef value_type*	pointer;
		typedef value_type&	reference;
		typedef ptrdiff_t		difference_type;

		iterator& operator=(iterator i);

		bool operator==(iterator const& iter) const;
		bool operator!=(iterator const& iter) const;
		bool operator<=(iterator const& iter) const;
		bool operator< (iterator const& iter) const;

		reference operator*() const;
		pointer operator->() const;

		iterator& operator++();
		iterator& operator--();
		iterator  operator++(int);
		iterator  operator--(int);
		iterator& operator+=(size_type n);
		iterator& operator-=(size_type n);
		iterator  operator+(size_type n) const;
		iterator  operator-(size_type n) const;

		reference operator[](difference_type n) const;
		difference_type operator-(iterator const& i) const;

	protected:

		friend class chunk_vector;
		friend class const_iterator;

		iterator(value_type** chunks, size_type i);

		value_type**	m_chunks;
		size_type		m_i;
	};

	class const_iterator
	{
	public:

		typedef T						value_type;
		typedef value_type const*	const_pointer;
		typedef value_type const&	const_reference;
		typedef ptrdiff_t				difference_type;

		explicit const_iterator(iterator i);

		const_iterator& operator=(const_iterator i);

		bool operator==(const_iterator const& iter) const;
		bool operator!=(const_iterator const& iter) const;
		bool operator<=(const_iterator const& iter) const;
		bool operator< (const_iterator const& iter) const;

		const_reference operator*() const;
		const_pointer operator->() const;

		const_iterator& operator++();
		const_iterator& operator--();
		const_iterator  operator++(int);
		const_iterator  operator--(int);
		const_iterator& operator+=(size_type n);
		const_iterator& operator-=(size_type n);
		const_iterator  operator+(size_type n) const;
		const_iterator  operator-(size_type n) const;

		const_reference operator[](difference_type n) const;
		difference_type operator-(const_iterator const& i) const;

	protected:

		friend class chunk_vector;

		const_iterator(T const* const* chunks, size_type i);

		value_type const* const*	m_chunks;
		size_type						m_i;
	};

	chunk_vector();
	chunk_vector(chunk_vector const& v);
	explicit chunk_vector(size_type n);
	~chunk_vector() throw();

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR
   chunk_vector(chunk_vector&& v);
	chunk_vector& operator=(chunk_vector&& v);
#endif

	chunk_vector& operator=(chunk_vector const& v);

	reference operator[](size_type n);
	const_reference operator[](size_type n) const;

	reference at(size_type n);
	const_reference at(size_type n) const;

	reference back();
	const_reference back() const;

	bool empty() const;
	bool released(unsigned chunk_index) const;

	size_type size() const;
	size_type capacity() const;
	size_type chunk_size() const;
	size_type count_chunks() const;
	static size_type chunk_index(unsigned index);

	iterator begin();
	const_iterator begin() const;
	iterator end();
	const_iterator end() const;

	reference push_back();
	void push_back(const_reference v);
	void pop_back();

	void resize(size_type n);
	void reserve(size_type n);
	void clear();
	void clear_chunk(size_type chunk_index);
	void release_chunk(size_type chunk_index);
	void swap(chunk_vector& v);

private:

	enum { Chunk_Mask = (1u << Chunk_Shift) - 1u };

	friend class iterator;
	friend class const_iterator;

	vector<T*>	m_index;
	size_type	m_size;
	size_type	m_capacity;
};

} // namespace mstl

#include "m_chunk_vector.ipp"

#endif // _mstl_chunk_vector_included

// vi:set ts=3 sw=3:
