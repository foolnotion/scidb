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

namespace mstl {

template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple()
{
}


template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple(T0 const& t0)
	:m_members(t0, null_type(), null_type(), null_type())
{
	static_assert(tl::length<type_list>::Value == 1, "wrong numbers of arguments");
}


template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple(T0 const& t0, T1 const& t1)
	:m_members(t0, t1, null_type(), null_type())
{
	static_assert(tl::length<type_list>::Value == 2, "wrong numbers of arguments");
}


template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple(T0 const& t0, T1 const& t1, T2 const& t2)
	:m_members(t0, t1, t2, null_type())
{
	static_assert(tl::length<type_list>::Value == 3, "wrong numbers of arguments");
}


template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple(T0 const& t0, T1 const& t1, T2 const& t2, T3 const& t3)
	:m_members(t0, t1, t2, t3)
{
	static_assert(tl::length<type_list>::Value == 4, "wrong numbers of arguments");
}


template <typename T0, typename T1, typename T2, typename T3>
template <int N>
inline
typename tl::type_at<typename tuple<T0,T1,T2,T3>::type_list,N>::result const&
tuple<T0,T1,T2,T3>::get() const
{
	static_assert(N >= 0, "negative index is not allowed");
	static_assert(N < tl::length<type_list>::Value, "index too large");

	return tl::bits::accessor<members,N>::get(m_members);
}


template <typename T0, typename T1, typename T2, typename T3>
template <int N>
inline
typename tl::type_at<typename tuple<T0,T1,T2,T3>::type_list,N>::result&
tuple<T0,T1,T2,T3>::get()
{
	static_assert(N >= 0, "negative index is not allowed");
	static_assert(N < tl::length<type_list>::Value, "index too large");

	return tl::bits::accessor<members,N>::get(m_members);
}


template <typename T0, typename T1, typename T2, typename T3>
inline
bool
tuple<T0,T1,T2,T3>::operator==(tuple const& t) const
{
	return m_members.compare(t.m_members);
}


template <typename T0, typename T1, typename T2, typename T3>
inline
bool
tuple<T0,T1,T2,T3>::operator!=(tuple const& t) const
{
	return !m_members.compare(t.m_members);
}


#if HAVE_0X_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>::tuple(tuple&& t) : m_members(mstl::move(t.m_members)) {}


template <typename T0, typename T1, typename T2, typename T3>
inline
tuple<T0,T1,T2,T3>&
tuple<T0,T1,T2,T3>::operator=(tuple&& t)
{
	m_members = mstl::move(t.m_members);
	return *this;
}

#endif

} // namespace mstl

// vi:set ts=3 sw=3:
