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

#ifndef _mstl_fixed_size_allocator_included
#define _mstl_fixed_size_allocator_included

#include "m_memblock.h"

namespace mstl {

template <typename T>
class fixed_size_allocator
{
public:

	typedef typename memblock<T>::size_type size_type;

	bool empty() const;

	fixed_size_allocator();
	fixed_size_allocator(size_type size);

	size_type size() const;
	size_type capacity() const;

	T* allocate();
	T* allocate(T const& x);

	void release();
	void reserve(size_type size);

private:

	memblock<T> m_mem;
};

} // namespace mstl

#include "m_fixed_size_allocator.ipp"

#endif // _mstl_fixed_size_allocator_included

// vi:set ts=3 sw=3:
