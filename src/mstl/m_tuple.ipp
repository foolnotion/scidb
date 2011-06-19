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

#include "m_static_check.h"

namespace mstl {

template <typename T0, typename T1, typename T2>
inline
tuple<T0,T1,T2>::tuple()
{
}


template <typename T0, typename T1, typename T2>
inline
tuple<T0,T1,T2>::tuple(T0 const& t0)
	:m_members(t0, null_type(), null_type())
{
	M_STATIC_CHECK(tl::length<type_list>::Value == 1, Wrong_Numbers_Of_Arguments);
}


template <typename T0, typename T1, typename T2>
inline
tuple<T0,T1,T2>::tuple(T0 const& t0, T1 const& t1)
	:m_members(t0, t1, null_type())
{
	M_STATIC_CHECK(tl::length<type_list>::Value == 2, Wrong_Numbers_Of_Arguments);
}


template <typename T0, typename T1, typename T2>
inline
tuple<T0,T1,T2>::tuple(T0 const& t0, T1 const& t1, T2 const& t2)
	:m_members(t0, t1, t2)
{
	M_STATIC_CHECK(tl::length<type_list>::Value == 3, Wrong_Numbers_Of_Arguments);
}


template <typename T0, typename T1, typename T2>
inline
tuple<T0,T1,T2>&
tuple<T0,T1,T2>::operator=(tuple const& t)
{
	get<0>() = t.get<0>();
	get<1>() = t.get<1>();
	get<2>() = t.get<2>();
	return *this;
}


template <typename T0, typename T1, typename T2>
template <int N>
inline
typename tl::type_at<typename tuple<T0,T1,T2>::type_list,N>::result const&
tuple<T0,T1,T2>::get() const
{
	M_STATIC_CHECK(N >= 0, Negative_Index_Not_Allowed);
	M_STATIC_CHECK(N < tl::length<type_list>::Value, Index_Too_Large);

	return tl::bits::accessor<members,N>::get(m_members);
}


template <typename T0, typename T1, typename T2>
template <int N>
inline
typename tl::type_at<typename tuple<T0,T1,T2>::type_list,N>::result&
tuple<T0,T1,T2>::get()
{
	M_STATIC_CHECK(N >= 0, Negative_Index_Not_Allowed);
	M_STATIC_CHECK(N < tl::length<type_list>::Value, Index_Too_Large);

	return tl::bits::accessor<members,N>::get(m_members);
}


template <typename T0, typename T1, typename T2>
inline
bool
tuple<T0,T1,T2>::operator==(tuple const& t) const
{
	return get<0>() == t.get<0>() && get<1>() == t.get<1>() && get<2>() == t.get<2>();
}


template <typename T0, typename T1, typename T2>
inline
bool
tuple<T0,T1,T2>::operator!=(tuple const& t) const
{
	return !operator==(t);
}

} // namespace mstl

// vi:set ts=3 sw=3:
