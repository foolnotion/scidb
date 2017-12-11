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
#include "m_algorithm.h"
#include "m_assert.h"

namespace mstl {

template <typename K, typename V> inline void swap(map<K,V>& lhs, map<K,V>& rhs) { lhs.swap(rhs); }

template <typename K, typename V> inline map<K,V>::map(size_type n) { m_v.reserve(n); }
template <typename K, typename V> inline map<K,V>::map(map const& v) : m_v(v.m_v) {}

template <typename K, typename V> inline bool map<K,V>::empty() const { return m_v.empty(); }
template <typename K, typename V> inline void map<K,V>::clear() { m_v.clear(); }
template <typename K, typename V> inline void map<K,V>::reserve(size_type n) { m_v.reserve(n); }

template <typename K, typename V> inline map<K,V>::map() {}

template <typename K, typename V>
inline map<K,V>::map(const_iterator first, const_iterator last) { insert(first, last); }

template <typename K, typename V>
inline typename map<K,V>::size_type map<K,V>::size() const { return m_v.size(); }

template <typename K, typename V>
inline typename map<K,V>::size_type map<K,V>::capacity() const { return m_v.capacity(); }

template <typename K, typename V>
inline typename map<K,V>::iterator map<K,V>::begin() { return m_v.begin(); }

template <typename K, typename V>
inline typename map<K,V>::const_iterator map<K,V>::begin() const { return m_v.begin(); }

template <typename K, typename V>
inline typename map<K,V>::iterator map<K,V>::end() { return m_v.end(); }

template <typename K, typename V>
inline typename map<K,V>::const_iterator map<K,V>::end() const { return m_v.end(); }

template <typename K, typename V>
inline typename map<K,V>::iterator map<K,V>::erase(iterator ep) { return m_v.erase(ep); }

template <typename K, typename V>
inline typename map<K,V>::container_type const& map<K,V>::container() const { return m_v; }

template <typename K, typename V>
inline typename map<K,V>::container_type& map<K,V>::container() { return m_v; }


template <typename K, typename V>
inline
typename map<K,V>::reverse_iterator
map<K,V>::rbegin()
{
	return m_v.rbegin();
}


template <typename K, typename V>
inline
typename map<K,V>::reverse_iterator
map<K,V>::rend()
{
	return m_v.rend();
}


template <typename K, typename V>
inline
typename map<K,V>::const_reverse_iterator
map<K,V>::rbegin() const
{
	return m_v.rbegin();
}


template <typename K, typename V>
inline
typename map<K,V>::const_reverse_iterator
map<K,V>::rend() const
{
	return m_v.rend();
}


template <typename K, typename V>
inline
map<K,V> const&
map<K,V>::operator=(map const& v)
{
	m_v = v.m_v;
	return *this;
}


template <typename K, typename V>
inline
bool
map<K,V>::operator==(map const& v) const
{
	return m_v == v.m_v;
}


template <typename K, typename V>
inline
bool
map<K,V>::operator!=(map const& v) const
{
	return m_v != v.m_v;
}


template <typename K, typename V>
inline
void
map<K,V>::assign(const_iterator first, const_iterator last)
{
	clear();
	insert(first, last);
}


template <typename K, typename V>
inline
typename map<K,V>::const_iterator
map<K,V>::find_data(const_data_ref v, const_iterator first, const_iterator last) const
{
	if (!first) first = begin();
	if (!last) last = end();

	while (first != last && first->second != v)
		++first;

	return first;
}


template <typename K, typename V>
inline
typename map<K,V>::iterator
map<K,V>::find_data(const_data_ref v, iterator first, iterator last)
{
	return const_cast<iterator>(
				find_data(v, const_cast<const_iterator>(first), const_cast<const_iterator>(last)));
}


template <typename K, typename V>
inline
typename map<K,V>::iterator
map<K,V>::erase(iterator first, iterator last)
{
	return m_v.erase(first, last);
}


template <typename K, typename V>
typename map<K,V>::iterator
map<K,V>::lower_bound(const_key_ref k)
{
	iterator first(begin());
	iterator last(end());

	while (first != last)
	{
		iterator mid = ::mstl::advance(first, ::mstl::div2(::mstl::distance(first, last)));

		if (mid->first < k)
			first = ::mstl::advance(mid, 1);
		else
			last = mid;
	}

	return first;
}


template <typename K, typename V>
inline
typename map<K,V>::iterator
map<K,V>::find(const_key_ref k)
{
	iterator i = lower_bound(k);
	return (i < end() && k < i->first) ? end() : i;
}


template <typename K, typename V>
inline
typename map<K,V>::const_iterator
map<K,V>::find(const_key_ref k) const
{
	return const_cast<map*>(this)->find(k);
}


template <typename K, typename V>
inline
typename map<K,V>::mapped_type const&
map<K,V>::operator[](const_key_ref k) const
{
	M_REQUIRE(find(k) != end());
	return find(k)->second;
}


template <typename K, typename V>
inline
typename map<K,V>::mapped_type&
map<K,V>::operator[](const_key_ref k)
{
	iterator i = lower_bound(k);

	if (i == end() || k < i->first)
		i = m_v.insert(i, make_pair(k, V()));

	return i->second;
}


template <typename K, typename V>
inline
bool
map<K,V>::has_key(const_key_ref k) const
{
	const_iterator i = const_cast<map*>(this)->lower_bound(k);
	return i < end() && !(k < i->first);
}


template <typename K, typename V>
inline
typename map<K,V>::iterator
map<K,V>::replace(const_reference v)
{
	iterator i = lower_bound(v.first);

	if (i == end() || v.first < i->first)
		i = m_v.insert(i, v);
	else
		*i = v;

	return i;
}


template <typename K, typename V>
inline
void
map<K,V>::insert(const_iterator first, const_iterator last)
{
	M_REQUIRE(first <= last);

	m_v.reserve(size() + ::mstl::distance(first, last));

	for ( ; first != last; ++first)
		insert(*first);
}


template <typename K, typename V>
inline
typename map<K,V>::result_t
map<K,V>::insert(const_reference v)
{
	iterator	i		= lower_bound(v.first);
	bool		exist	= i != end() && !(v.first < i->first);

	if (!exist)
		i = m_v.insert(i, v);

	return make_pair(i, exist);
}


template <typename K, typename V>
inline
void
map<K,V>::erase(const_key_ref k)
{
	iterator i = find(k);

	if (i != end())
		erase(i);
}


template <typename K, typename V>
inline
void
map<K,V>::swap(map& m)
{
	m_v.swap(m.m_v);
}


template <typename K, typename V>
inline
map<K,V>&
map<K,V>::operator+=(map const& m)
{
	if (!m.empty())
	{
		if (empty())
		{
			m_v = m.m_v;
		}
		else
		{
			container_type v;

			typename container_type::const_iterator k = m.m_v.begin();
			typename container_type::const_iterator e = m.m_v.end();

			for (typename container_type::const_iterator i = m_v.begin(); i != m_v.end(); ++i)
			{
				for ( ; k != e && k->first < i->first; ++k)
					v.push_back(*k);

				v.push_back(*i);
			}

			for ( ; k != e; ++k)
				v.push_back(*k);

			m_v.swap(v);
		}
	}

	return *this;
}


#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename K, typename V>
inline
map<K,V>::map(map&& m) : m_v(mstl::move(m.m_v)) {}


template <typename K, typename V>
inline
map<K,V>&
map<K,V>::operator=(map&& m)
{
	mstl::swap(m_v, m.m_v);
	return *this;
}

#endif


namespace bits {
namespace map {

template <typename T>
struct key_pred
{
	bool operator()(T const& lhs, T const& rhs) const
	{
		return lhs.first < rhs.first;
	}
};


template <typename T>
struct compare
{
	static int cmp_fst(T const* lhs, T const* rhs)
	{
		return ::mstl::compare(lhs->first, rhs->first);
	}

	static int comp_snd(T const* lhs, T const* rhs)
	{
		return ::mstl::compare(lhs->second, rhs->second);
	}
};

} // namespace map
} // namespace bits


template <typename K, typename V>
inline
void
map<K,V>::qsort_key()
{
	static_assert(::mstl::is_movable<value_type>::value, "cannot use qsort()");

	m_v.qsort(bits::map::compare<value_type>::cmp_fst);
}


template <typename K, typename V>
inline
void
map<K,V>::qsort_value()
{
	static_assert(::mstl::is_movable<value_type>::value, "cannot use qsort()");

	m_v.qsort(bits::map::compare<value_type>::comp_snd);
}


template <typename K, typename V>
inline
void
map<K,V>::qsort()
{
	static_assert(::mstl::is_movable<value_type>::value, "cannot use qsort()");
	qsort_key();
}


template <typename K, typename V>
inline
void
map<K,V>::unique()
{
	m_v.unique(bits::map::key_pred<value_type>());
}

} // namespace mstl

// vi:set ts=3 sw=3:
