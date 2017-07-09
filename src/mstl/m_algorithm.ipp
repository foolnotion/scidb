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

#include "m_utility.h"
#include "m_type_traits.h"
#include "m_types.h"
#include "m_assert.h"

#include <stdlib.h>

namespace mstl {
namespace bits {

bool rotate_fast(void* first, void* last, size_t size);
bool rotate_fast(void* first, void* middle, void* last, size_t size);


template <typename ForwardIterator>
inline
void
rotate(ForwardIterator first, ForwardIterator last)
{
	if (first != last)
	{
		ForwardIterator prior = first++;

		for ( ; first != last; ++first)
		{
			ForwardIterator next = first++;
			swap(*prior, *next);
			prior = next;
		}
	}
}


template <typename ForwardIterator>
inline
void
rotate(ForwardIterator first, ForwardIterator middle, ForwardIterator last)
{
	if (first == middle || last == middle)
		return;

	ForwardIterator first2 = middle;

	do
	{
		swap(*first, *first2);
		++first;
		++first2;

		if (first == middle)
			middle = first2;
	}
	while (first2 != last);

	first2 = middle;

	while (first2 != last)
	{
		swap(*first, *first2);
		++first;
		++first2;

		if (first == middle)
			middle = first2;
		else if (first2 == last)
			first2 = middle;
	}
}


template <typename ForwardIterator1, typename ForwardIterator2>
inline
int
compare(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2)
{
	for ( ; first1 != last1; ++first1, ++first2)
	{
		int cmp = int(*first1) - int(*first2);
		if (cmp != 0)
			return cmp;
	}
	return 0;
}

} // namespace bits


/// Returns the first iterator i in the range [first, last) such that
/// *i == value. Returns last if no such iterator exists.
/// \ingroup SearchingAlgorithms
template <typename ForwardIterator, typename EqualityComparable>
inline
ForwardIterator
find(ForwardIterator first, ForwardIterator last, const EqualityComparable& value)
{
	M_REQUIRE(first <= last);

	while (first != last && !(*first == value))
		++first;

	return first;
}


template<class ForwardIterator, class UnaryPredicate>
inline
ForwardIterator
find_if(ForwardIterator first, ForwardIterator last, UnaryPredicate pred)
{
	for ( ; first != last; ++first)
	{
		if (pred(*first))
			return first;
	}

	return last;
}


/// Returns the furthermost iterator i in [first, last) such that,
/// for every iterator j in [first, i), *j < value.
/// Assumes the range is sorted.
/// \ingroup SearchingAlgorithms
template <typename ForwardIterator, typename LessThanComparable>
inline
ForwardIterator
lower_bound(ForwardIterator first, ForwardIterator last, LessThanComparable const& value)
{
	M_REQUIRE(first <= last);

	size_t len = distance(first, last);

	while (len > 0)
	{
		size_t half = div2(len);

		ForwardIterator middle = advance(first, half);

		if (*middle < value)
		{
			first = middle;
			++first;
			len = len - half - 1;
		}
		else
		{
			len = half;
		}
	}

	return first;
}


/// Returns the furthermost iterator i in [first,last) such that for
/// every iterator j in [first,i), value < *j is false.
/// Assumes the range is sorted.
/// \ingroup SearchingAlgorithms
template <typename ForwardIterator, typename LessThanComparable>
inline
ForwardIterator
upper_bound(ForwardIterator first, ForwardIterator last, LessThanComparable const& value)
{
	M_REQUIRE(first <= last);

	size_t len = distance(first, last);

	while (len > 0)
	{
		size_t half = len >> 1;

		ForwardIterator middle = advance(first, half);

		if (value < *middle)
		{
			len = half;
		}
		else
		{
			first = middle;
			++first;
			len = len - half - 1;
		}
	}

	return first;
}


/// Performs a binary search inside the sorted range.
/// \ingroup SearchingAlgorithms
template <typename ForwardIterator, typename LessThanComparable>
inline
ForwardIterator
binary_search(ForwardIterator first, ForwardIterator last, LessThanComparable const& value)
{
	M_REQUIRE(first <= last);

	ForwardIterator found = lower_bound(first, last, value);
	return found != last && !(value < *found) ? found : last;
}


//  \brief  Permute range into the next dictionary ordering.
//  \ingroup sorting_algorithms
//
//  Treats all permutations of the range as a set of dictionary sorted
//  sequences.  Permutes the current sequence into the next one of this set.
//  Returns true if there are more sequences to generate.  If the sequence
//  is the largest of the set, the smallest is generated and false returned.
template <typename BidirectionalIterator>
bool
next_permutation(BidirectionalIterator first, BidirectionalIterator last)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return false;

	BidirectionalIterator i = first;

	++i;
	if (i == last)
		return false;

	i = last;
	--i;

	while (true)
	{
		BidirectionalIterator k = i;

		--i;

		if (*i < *k)
		{
			BidirectionalIterator j = last;

			while (!(*i < *--j))
				;
			swap(*i, *j);
			reverse(k, last);
			return true;
		}

		if (i == first)
		{
			reverse(first, last);
			return false;
		}
	}
}


//  \brief Permute range into the next @e dictionary ordering using comparison functor.
//  \ingroup sorting_algorithms
//
//  Treats all permutations of the range [first,last) as a set of
//  dictionary sorted sequences ordered by comp. Permutes the current
//  sequence into the next one of this set.  Returns true if there are more
//  sequences to generate. If the sequence is the largest of the set, the
//  smallest is generated and false returned.
template<typename BidirectionalIterator, typename Compare>
bool
next_permutation(BidirectionalIterator first, BidirectionalIterator last, Compare comp)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return false;

	BidirectionalIterator i = first;

	++i;
	if (i == last)
		return false;

	i = last;
	--i;

	while (true)
	{
		BidirectionalIterator k = i;

		--i;

		if (comp(*i, *k))
		{
			BidirectionalIterator j = last;

			while (!bool(comp(*i, *--j)))
				;
			swap(*i, *j);
			reverse(k, last);
			return true;
		}

		if (i == first)
		{
			reverse(first, last);
			return false;
		}
	}
}


/// \brief Exchanges ranges [first, middle) and [middle, last)
/// \ingroup MutatingAlgorithms
///
/// Rotates the order of the elements in the range [first,last), in such
/// a way that the element pointed by middle becomes the new first element.
template <typename ForwardIterator>
void
rotate(ForwardIterator first, ForwardIterator middle, ForwardIterator last)
{
	return bits::rotate(first, middle, last);
}


/// \brief Exchanges ranges [first, first+1) and [first+1, last)
/// \ingroup MutatingAlgorithms
///
/// Rotates the order of the elements in the range [first,last), in such
/// a way that the first element becomes the new last element.
template <typename ForwardIterator>
void
rotate(ForwardIterator first, ForwardIterator last)
{
	return bits::rotate(first, last);
}


/// Specialization for pointers, which can be treated identically.
template <typename T>
inline
void
rotate(T* first, T* last)
{
	M_REQUIRE(first <= last);

	if (is_movable<T>::value && !bits::rotate_fast(first, last, sizeof(T)))
		bits::rotate(first, last);
}


/// Specialization for pointers, which can be treated identically.
template <typename T>
inline
void
rotate(T* first, T* middle, T* last)
{
	M_REQUIRE(first <= middle);
	M_REQUIRE(middle <= last);

	if (is_movable<T>::value && !bits::rotate_fast(first, middle, last, sizeof(T)))
		bits::rotate(first, middle, last);
}


template <typename ForwardIterator>
inline
ForwardIterator
min_element(ForwardIterator first, ForwardIterator last)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return first;

	ForwardIterator result(first);

	while (++first != last)
	{
		if (*first < *result)
			result = first;
	}

	return result;
}


template <typename ForwardIterator, typename LessThanCompare>
inline
ForwardIterator
min_element(ForwardIterator first, ForwardIterator last, LessThanCompare comp)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return first;

	ForwardIterator result(first);

	while (++first != last)
	{
		if (comp(*first, *result))
			result = first;
	}

	return result;
}


template <typename ForwardIterator>
inline
ForwardIterator
max_element(ForwardIterator first, ForwardIterator last)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return first;

	ForwardIterator result(first);

	while (++first != last)
	{
		if (*result < *first)
			result = first;
	}

	return result;
}


template <typename ForwardIterator, typename LessThanCompare>
inline
ForwardIterator
max_element(ForwardIterator first, ForwardIterator last, LessThanCompare comp)
{
	M_REQUIRE(first <= last);

	if (first == last)
		return first;

	ForwardIterator result(first);

	while (++first != last)
	{
		if (comp(*result, *first))
			result = first;
	}

	return result;
}


template <typename ForwardIterator1, typename ForwardIterator2>
inline
bool
equal(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2)
{
	for ( ; first1 != last1; ++first1, ++first2)
	{
		if (!(*first1 == *first2))
			return false;
	}
	return true;
}


template <typename ForwardIterator1, typename ForwardIterator2, typename BinaryPredicate>
bool
equal(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2, BinaryPredicate pred)
{
	for ( ; first1 != last1; ++first1, ++first2)
	{
		if (!pred(*first1, *first2))
			return false;
	}
	return true;
}


template <typename ForwardIterator1, typename ForwardIterator2>
inline
bool
less_equal(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2)
{
	for ( ; first1 != last1; ++first1, ++first2)
	{
		if (!(*first1 <= *first2))
			return false;
	}
	return true;
}


template <typename ForwardIterator1, typename ForwardIterator2>
inline
int
compare(ForwardIterator1 first1, ForwardIterator1 last1, ForwardIterator2 first2)
{
	if (	is_signed_integral<decltype(*first1)>::value
		&& is_signed_integral<decltype(*first2)>::value
		&& sizeof(*first1) <= sizeof(int)
		&& sizeof(*first2) <= sizeof(int))
	{
		return bits::compare(first1, last1, first2);
	}
	else if (	is_integral<decltype(*first1)>::value
				&& is_integral<decltype(*first2)>::value
				&& sizeof(*first1) < sizeof(int)
				&& sizeof(*first2) < sizeof(int))
	{
		return bits::compare(first1, last1, first2);
	}
	else
	{
		for ( ; first1 != last1; ++first1, ++first2)
		{
			if (*first1 < *first2)
				return -1;
			if (!(*first1 == *first2))
				return +1;
		}
		return 0;
	}
}


template <typename ForwardIterator>
ForwardIterator
unique(ForwardIterator first, ForwardIterator last)
{
	if (first == last)
		return last;

	ForwardIterator result = first;

	while (++first != last)
	{
		if (!(*result == *first))
		{
			result++;
			*result = *first;
		}
	}

	result++;
	return result;
}


template <typename ForwardIterator, typename BinaryPredicate>
ForwardIterator
unique(ForwardIterator first, ForwardIterator last, BinaryPredicate pred)
{
	if (first == last)
		return last;

	ForwardIterator result = first;

	while (++first != last)
	{
		if (!pred(*result, *first))
		{
			result++;
			*result = *first;
		}
	}

	result++;
	return result;
}


namespace bits {
namespace algo {

template <typename T, typename Arg>
struct argf
{
	int (*f)(T, T, Arg const& arg);
	Arg const& a;

	argf(int (*func)(T, T, Arg const& arg), Arg const& arg) :f(func), a(arg) {}

#if defined(__BSD__) || defined (__WIN32__) || defined (__WIN64__)
	static int doit(argf* arg, T const* lhs, T const* rhs) { return arg->f(*lhs, *rhs, arg->a); }
	static int dneg(argf* arg, T const* lhs, T const* rhs) { return arg->f(*rhs, *lhs, arg->a); }
#else
	static int doit(T const* lhs, T const* rhs, argf* arg) { return arg->f(*lhs, *rhs, arg->a); }
	static int dneg(T const* lhs, T const* rhs, argf* arg) { return arg->f(*rhs, *lhs, arg->a); }
#endif
};

template <typename T>
struct compare
{
	static int doit(T const* lhs, T const* rhs) { return ::mstl::compare(*lhs, *rhs); }
	static int dneg(T const* lhs, T const* rhs) { return ::mstl::compare(*rhs, *lhs); }

	static int doitf(T const* lhs, T const* rhs, int (*func)(T const&, T const&))
	{
		return (*func)(*lhs, *rhs);
	}

	static int doitf(T const* lhs, T const* rhs, int (*func)(T, T))
	{
		return (*func)(*lhs, *rhs);
	}

	static int dnegf(T const* lhs, T const* rhs, int (*func)(T const&, T const&))
	{
		return (*func)(*rhs, *lhs);
	}

	static int dnegf(T const* lhs, T const* rhs, int (*func)(T, T))
	{
		return (*func)(*rhs, *lhs);
	}
};

template <typename T, typename Comparison>
struct compare_obj
{
	static int doit(T const* lhs, T const* rhs, Comparison* comp) { return (*comp)(*lhs, *rhs); }
};

template <typename T>
struct compare_less
{
	static int doit(T const* lhs, T const* rhs) { return *lhs < *rhs ? -1 : (*rhs < *lhs ? +1 : 0); }
};

} // namespace algo

#if defined(__BSD__) || defined (__WIN32__) || defined (__WIN64__)
typedef int (*Comparison)(void*, void const*, void const*);
#elif defined(__unix__)
typedef int (*Comparison)(void const*, void const*, void*);
#else
# error "qsort_r/qsort_s available?"
#endif

inline
void
qsort(void* base, size_t nmemb, size_t size, Comparison compare, void* arg)
{
#if defined (__WIN32__) || defined (__WIN64__)
	::qsort_s(base, nmemb, size, compare, arg);
#elif defined(__BSD__)
	::qsort_r(base, nmemb, size, arg, compare);
#elif defined(__unix__)
	::qsort_r(base, nmemb, size, compare, arg);
#else
# error "qsort_r/qsort_s available?"
#endif
}

template <typename T>
void
bubblesort(T* base, size_t nmemb)
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (base[i + 1] < base[i])
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T>
void
bubblesort(T *base, size_t nmemb, int (*less)(T lhs, T rhs))
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base[i + 1], base[i]))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T>
void
bubblesort(T *base, size_t nmemb, int (*less)(T const& lhs, T const& rhs))
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base[i + 1], base[i]))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T>
void
bubblesort(T *base, size_t nmemb, int (*less)(T const* lhs, T const* rhs))
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base + i + 1, base + i))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T, typename Arg>
void
bubblesort(	T *base,
				size_t nmemb,
				int (*less)(T const& lhs, T const& rhs, Arg const& arg),
				Arg const& arg)
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base[i + 1], base[i], arg))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T, typename Less>
void
bubblesort(T* base, size_t nmemb, Less less)
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base[i + 1], base[i]))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}


template <typename T, typename Arg, typename Less>
void
bubblesort(T* base, size_t nmemb, Less less, Arg const& arg)
{
	M_ASSERT(nmemb > 1);

	do
	{
		size_t newn = 1;

		for (unsigned i = 0; i < nmemb - 1; ++i)
		{
			if (less(base[i + 1], base[i], arg))
			{
				::mstl::swap(base[i], base[i + 1]);
				newn = i + 1;
			}
		}

		nmemb = newn;
	}
	while (nmemb > 1);
}

} // namespace bits


template <typename T, int N>
inline
void
qsort(T (&array)[N])
{
	typedef int (*comp_func_t)(void const*, void const*, void*);

	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	::qsort(	&array[0],
				N,
				sizeof(T),
				reinterpret_cast<comp_func_t>(bits::algo::compare<T>::doit));
}


template <typename T>
inline
void
qsort(T* array, unsigned len)
{
	typedef int (*comp_func_t)(void const*, void const*, void*);

	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	M_REQUIRE(len == 0 || array);

	::qsort(	array,
				len,
				sizeof(T),
				reinterpret_cast<comp_func_t>(bits::algo::compare<T>::doit));
}


template <typename T, int N>
inline
void
qsort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::doitf),
					static_cast<void*>(compare));
}


template <typename T, int N>
inline
void
qsort(T (&array)[N], int (*compare)(T lhs, T rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::doitf),
					static_cast<void*>(compare));
}


template <typename T, int N>
inline
void
qsort(T (&array)[N], int (*compare)(T const* lhs, T const* rhs))
{
	typedef int (*comp_func_t)(void const*, void const*, void*);

	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	::qsort(&array[0], N, sizeof(T), reinterpret_cast<comp_func_t>(compare));
}


template <typename T>
inline
void
qsort(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::doitf),
					static_cast<void*>(compare));
}


template <typename T>
inline
void
qsort(T* array, unsigned len, int (*compare)(T lhs, T rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::doitf),
					static_cast<void*>(compare));
}


template <typename T>
inline
void
qsort(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs))
{
	typedef int (*comp_func_t)(void const*, void const*);

	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	::qsort(array, len, sizeof(T), reinterpret_cast<comp_func_t>(compare));
}


template <typename T, int N, typename Arg>
inline
void
qsort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T const&,Arg> argf(compare, arg);

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T const&,Arg>::doit),
					static_cast<void*>(&argf));
}


template <typename T, int N, typename Arg>
inline
void
qsort(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T,Arg> argf(compare, arg);

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T,Arg>::doit),
					static_cast<void*>(&argf));
}


template <typename T, typename Arg>
inline
void
qsort(T* array,
		unsigned len,
		int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
		Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T const&,Arg> argf(compare, arg);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T const&,Arg>::doit),
					static_cast<void*>(&argf));
}


template <typename T, typename Arg>
inline
void
qsort(T* array, unsigned len, int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T,Arg> argf(compare, arg);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T,Arg>::doit),
					static_cast<void*>(&argf));
}


template <typename T, int N, typename Comparison>
inline
void
qsort(T (&array)[N], Comparison comparison)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare_obj<T,Comparison>::doit),
					static_cast<void*>(&comparison));
}


template <typename T, typename Comparison>
inline
void
qsort(T* array, unsigned len, Comparison comparison)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	M_REQUIRE(len == 0 || array);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare_obj<T,Comparison>::doit),
					static_cast<void*>(&comparison));
}


template <typename T, int N>
inline
void
qsort_reverse(T (&array)[N], int (*compare)(T const& lhs, T const& rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::dnegf),
					static_cast<void*>(compare));
}


template <typename T, int N>
inline
void
qsort_reverse(T (&array)[N], int (*compare)(T lhs, T rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::dnegf),
					static_cast<void*>(compare));
}


template <typename T>
inline
void
qsort_reverse(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::dnegf),
					static_cast<void*>(compare));
}


template <typename T>
inline
void
qsort_reverse(T* array, unsigned len, int (*compare)(T lhs, T rhs))
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::dnegf),
					static_cast<void*>(compare));
}


template <typename T>
inline
void
qsort_reverse(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs))
{
	typedef int (*comp_func_t)(void const*, void const*);

	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare<T>::dnegf),
					reinterpret_cast<comp_func_t>(compare));
}


template <typename T, int N, typename Arg>
inline
void
qsort_reverse(T (&array)[N], int (*compare)(T const& lhs, T const& rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T const&,Arg> argf(compare, arg);

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T const&,Arg>::dneg),
					static_cast<void*>(&argf));
}


template <typename T, int N, typename Arg>
inline
void
qsort_reverse(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T,Arg> argf(compare, arg);

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T,Arg>::dneg),
					static_cast<void*>(&argf));
}


template <typename T, typename Arg>
inline
void
qsort_reverse(	T* array,
					unsigned len,
					int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
					Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T const&,Arg> argf(compare, arg);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T const&,Arg>::dneg),
					static_cast<void*>(&argf));
}


template <typename T, typename Arg>
inline
void
qsort_reverse(T* array, unsigned len, int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::algo::argf<T,Arg> argf(compare, arg);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::argf<T,Arg>::dneg),
					static_cast<void*>(&argf));
}


template <typename T, int N, typename Comparison>
inline
void
qsort_reverse(T (&array)[N], Comparison comparison)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	bits::qsort(&array[0],
					N,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare_obj<T,Comparison>::dneg),
					static_cast<void*>(&comparison));
}


template <typename T, typename Comparison>
inline
void
qsort_reverse(T* array, unsigned len, Comparison comparison)
{
	static_assert(::mstl::is_movable<T>::value, "cannot use qsort()");

	M_REQUIRE(len == 0 || array);

	bits::qsort(array,
					len,
					sizeof(T),
					reinterpret_cast<bits::Comparison>(bits::algo::compare_obj<T,Comparison>::dneg),
					static_cast<void*>(&comparison));
}


template <typename T, int N>
inline
void
bubblesort(T (&array)[N])
{
	if (N > 1)
		bits::bubblesort(&array[0], N);
}


template <typename T>
inline
void
bubblesort(T* array, unsigned len)
{
	M_REQUIRE(len == 0 || array);

	if (len > 1)
		bits::bubblesort(array, len);
}


template <typename T, int N>
inline
void
bubblesort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs))
{
	if (N > 1)
		bits::bubblesort(&array[0], N, compare);
}


template <typename T, int N>
inline
void
bubblesort(T (&array)[N], int (*compare)(T lhs, T rhs))
{
	if (N > 1)
		bits::bubblesort(&array[0], N, compare);
}


template <typename T, int N>
inline
void
bubblesort(T (&array)[N], int (*compare)(T const* lhs, T const* rhs))
{
	if (N > 1)
		bits::bubblesort(&array[0], N, compare);
}


template <typename T>
inline
void
bubblesort(T* array, unsigned len, int (*compare)(T const& lhs, T const& rhs))
{
	if (len > 1)
		bits::bubblesort(array, len, compare);
}


template <typename T>
inline
void
bubblesort(T* array, unsigned len, int (*compare)(T lhs, T rhs))
{
	if (len > 1)
		bits::bubblesort(array, len, compare);
}


template <typename T>
inline
void
bubblesort(T* array, unsigned len, int (*compare)(T const* lhs, T const* rhs))
{
	if (len > 1)
		bits::bubblesort(array, len, compare);
}


template <typename T, int N, typename Arg>
inline
void
bubblesort(T (&array)[N], int (*compare)(T const& lhs, T const& rhs, Arg const& arg), Arg const& arg)
{
	if (N > 1)
		bits::bubblesort(&array[0], N, compare, arg);
}


template <typename T, int N, typename Arg>
inline
void
bubblesort(T (&array)[N], int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	if (N > 1)
		bits::bubblesort(&array[0], N, compare, arg);
}


template <typename T, typename Arg>
inline
void
bubblesort(	T* array,
				unsigned len,
				int (*compare)(T const& lhs, T const& rhs, Arg const& arg),
				Arg const& arg)
{
	if (len > 1)
		bits::bubblesort(array, len, compare, arg);
}


template <typename T, typename Arg>
inline
void
bubblesort(T* array, unsigned len, int (*compare)(T lhs, T rhs, Arg const& arg), Arg const& arg)
{
	if (len > 1)
		bits::bubblesort(array, len, compare, arg);
}


template <typename T, int N, typename Comparison>
inline
void
bubblesort(T (&array)[N], Comparison comparison)
{
	if (N > 1)
		bits::bubblesort(&array[0], N, comparison);
}


template <typename T, typename Comparison>
inline
void
bubblesort(T* array, unsigned len, Comparison comparison)
{
	M_REQUIRE(len == 0 || array);

	if (len > 1)
		bits::bubblesort(array, len, comparison);
}

} // namespace mstl

// vi:set ts=3 sw=3:
