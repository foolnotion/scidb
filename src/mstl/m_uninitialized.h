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

#ifndef _mstl_uninitialized_included
#define _mstl_uninitialized_included

#include <stddef.h>

namespace mstl {

template <typename T> struct pointer_iterator;
template <typename T> struct pointer_const_iterator;

template<typename T> T* uninitialized_copy(T const* first, T const* last, T* result);
template<typename T> T* uninitialized_move(T const* first, T const* last, T* result);
template<typename T> T* uninitialized_fill_n(T* first, size_t n, T const& value);

template<typename T> T* uninitialized_copy(T* first, T* last, T* result);
template<typename T> T* uninitialized_move(T* first, T* last, T* result);

template<typename T>
T* uninitialized_copy(pointer_iterator<T> first, pointer_iterator<T> last, T* result);
template<typename T>
T* uninitialized_move(pointer_iterator<T> first, pointer_iterator<T> last, T* result);
template<typename T>
T* uninitialized_fill_n(pointer_iterator<T*> first, size_t n, T const& value);

template<typename T>
T* uninitialized_copy(pointer_const_iterator<T> first, pointer_const_iterator<T> last, T* result);
template<typename T>
T* uninitialized_move(pointer_const_iterator<T> first, pointer_const_iterator<T> last, T* result);

template<typename Iterator, typename T>
T* uninitialized_copy(Iterator first, Iterator last, T* result);

template<typename Iterator, typename T>
T* uninitialized_move(Iterator first, Iterator last, T* result);

} // namespace mstl

#include "m_uninitialized.ipp"

#endif // _mstl_uninitialized_included

// vi:set ts=3 sw=3:
