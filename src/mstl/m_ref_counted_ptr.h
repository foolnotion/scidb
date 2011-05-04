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

#ifndef _mstl_ref_counted_ptr_included
#define _mstl_ref_counted_ptr_included

#include "m_ref_counted_traits.h"

namespace mstl {

template <class T>
class ref_counted_ptr
{
public:

	// types
	typedef T element_type;
	typedef T* pointer;
	typedef T const* const_pointer;
	typedef T& reference;
	typedef T const& const_reference;

	// structors
	explicit ref_counted_ptr(T* p = 0);
	ref_counted_ptr(ref_counted_ptr const& sp);
	template <class U> ref_counted_ptr(ref_counted_ptr<U> const& sp);
	~ref_counted_ptr();

	// assignment
	ref_counted_ptr& operator=(ref_counted_ptr const& sp);
	template <class U> ref_counted_ptr<T>& operator=(ref_counted_ptr<U> const& sp);

	// queries
	bool operator!() const;
	bool unique() const;
	bool expired() const;

	// accessors
	T* operator->();
	T const* operator->() const;

	T& operator*();
	T const& operator*() const;

	T* get();
	T const* get() const;

	// for comparison; e.g. 'if (p)'
	operator void const* () const;

	// modifiers
	T* release();
	void reset(T* p = 0);
	void swap(ref_counted_ptr& p);

private:

	template <class U>
	struct by_ref
	{
		by_ref(U* p);

		U* m_p;
	};

public:

	// structors
	ref_counted_ptr(by_ref<T> ref);

	// assignment
	ref_counted_ptr& operator=(by_ref<T> ref);

	// accessors
	template <class U> operator by_ref<U>();

#if (__GNUC__ >= 3)
private:

	// friends
	template <class> friend class ref_counted_ptr;
#endif

	// attributes
	T* m_p;
};

template <class T> void swap(ref_counted_ptr<T>& lhs, ref_counted_ptr<T>& rhs);

} // namespace mstl


#include "m_ref_counted_ptr.ipp"

#endif // _mstl_ref_counted_ptr_included

// vi:set ts=3 sw=3:
