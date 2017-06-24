// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _mstl_algorithm_included
#define _mstl_algorithm_included

#include "m_algobase.h"

namespace mstl {

template <typename ForwardIterator, typename EqualityComparable>
ForwardIterator
find(ForwardIterator first, ForwardIterator last, const EqualityComparable& value);

template<class ForwardIterator, class UnaryPredicate>
ForwardIterator
find_if(ForwardIterator first, ForwardIterator last, UnaryPredicate pred);

template <typename ForwardIterator, typename LessThanComparable>
ForwardIterator
lower_bound(ForwardIterator first, ForwardIterator last, LessThanComparable const& value);

template <typename ForwardIterator, typename LessThanComparable>
ForwardIterator
upper_bound(ForwardIterator first, ForwardIterator last, LessThanComparable const& value);

template <typename ForwardIterator, typename LessThanComparable>
ForwardIterator
binary_search(ForwardIterator first, ForwardIterator last, LessThanComparable const& value);

template <typename ForwardIterator>
void
rotate(ForwardIterator first, ForwardIterator middle, ForwardIterator last);

template <typename ForwardIterator>
void
rotate(ForwardIterator first, ForwardIterator last);

template <typename BidirectionalIterator>
bool
next_permutation(BidirectionalIterator first, BidirectionalIterator last);

template <typename BidirectionalIterator, typename Compare>
bool
next_permutation(BidirectionalIterator first, BidirectionalIterator last, Compare comp);

template <typename ForwardIterator>
ForwardIterator min_element(ForwardIterator first, ForwardIterator last);

template <typename ForwardIterator, typename LessThanCompare>
ForwardIterator min_element(ForwardIterator first, ForwardIterator last, LessThanCompare comp);

template <typename ForwardIterator>
ForwardIterator max_element(ForwardIterator first, ForwardIterator last);

template <typename ForwardIterator, typename LessThanCompare>
ForwardIterator max_element(ForwardIterator first, ForwardIterator last, LessThanCompare comp);

template <typename ForwardIterator1, typename ForwardIterator2>
bool equal(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2);

template <typename ForwardIterator1, typename ForwardIterator2, typename BinaryPredicate>
bool equal(	ForwardIterator1 first1,
				ForwardIterator1 last1,
				ForwardIterator2 first2,
				BinaryPredicate pred);

template <typename ForwardIterator1, typename ForwardIterator2>
bool less_equal(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2);

template <typename ForwardIterator1, typename ForwardIterator2>
int compare(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2);

template <typename ForwardIterator>
ForwardIterator unique(ForwardIterator first, ForwardIterator last);

template <typename ForwardIterator, typename BinaryPredicate>
ForwardIterator unique(ForwardIterator first, ForwardIterator last, BinaryPredicate pred);

template <typename T, int N>
void qsort(T (&array)[N]);

template <typename T>
void qsort(T* array, unsigned len);

template <typename T, int N>
void qsort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs));

template <typename T, int N>
void qsort(T (&array)[N], int (*compare)(T const* lhs, T const* rhs));

template <typename T>
void qsort(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs));

template <typename T>
void qsort(T* array, unsigned len, int (*compare)(T lhs, T rhs));

template <typename T>
void qsort(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs));

template <typename T, int N, typename Arg>
void qsort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs, Arg const& arg), Arg const& arg);

template <typename T, int N, typename Arg>
void qsort(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg);

template <typename T, typename Arg>
void qsort(	T* array,
				unsigned len,
				int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
				Arg const& arg);

template <typename T, typename Arg>
void qsort(T* array, unsigned len, int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg);

template <typename T, int N, typename Comparison>
void qsort(T (&array)[N], Comparison comparison);

template <typename T, typename Comparison>
void qsort(T* array, unsigned len, Comparison comparison);

template <typename T, int N>
void qsort_reverse(T (&array)[N], int (*compare)(T const& lhs, T const& rhs));

template <typename T, int N>
void qsort_reverse(T (&array)[N], int (*compare)(T lhs, T rhs));

template <typename T, int N>
void qsort_reverse(T (&array)[N], int (*compare)(T const* lhs, T const* rhs));

template <typename T>
void qsort_reverse(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs));

template <typename T>
void qsort_reverse(T* array, unsigned len, int (*compare)(T lhs, T rhs));

template <typename T>
void qsort_reverse(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs));

template <typename T, int N, typename Arg>
void qsort_reverse(	T (&array)[N],
							int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
							Arg const& arg);

template <typename T, int N, typename Arg>
void qsort_reverse(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg);

template <typename T, typename Arg>
void qsort_reverse(	T* array,
							unsigned len,
							int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
							Arg const& arg);

template <typename T, typename Arg>
void qsort_reverse(	T* array,
							unsigned len,
							int (*compare)(T lhs, T rhs, Arg const& arg),
							Arg const& arg);

template <typename T, int N, typename Comparison>
void qsort_reverse(T (&array)[N], Comparison comparison);

template <typename T, typename Comparison>
void qsort_reverse(T* array, unsigned len, Comparison comparison);

template <typename T, int N>
void bubblesort(T (&array)[N]);

template <typename T>
void bubblesort(T* array, unsigned len);

template <typename T, int N>
void bubblesort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs));

template <typename T, int N>
void bubblesort(T (&array)[N], int (*compare)(T const* lhs, T const* rhs));

template <typename T>
void bubblesort(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs));

template <typename T>
void bubblesort(T* array, unsigned len, int (*compare)(T lhs, T rhs));

template <typename T>
void bubblesort(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs));

template <typename T, int N, typename Arg>
void bubblesort(	T (&array)[N],
						int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
						Arg const& arg);

template <typename T, int N, typename Arg>
void bubblesort(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg);

template <typename T, typename Arg>
void bubblesort(	T* array,
						unsigned len,
						int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
						Arg const& arg);

template <typename T, typename Arg>
void bubblesort(T* array, unsigned len, int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg);

template <typename T, int N, typename Comparison>
void bubblesort(T (&array)[N], Comparison comparison);

template <typename T, typename Comparison>
void bubblesort(T* array, unsigned len, Comparison comparison);

} // namespace mstl

#include "m_algorithm.ipp"

#endif // _mstl_algorithm_included

// vi:set ts=3 sw=3:
