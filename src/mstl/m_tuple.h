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

#ifndef _mstl_tuple_included
#define _mstl_tuple_included

#include "m_make_type_list.h"
#include "m_member_list.h"

namespace mstl {

template <typename T0, typename T1 = null_type, typename T2 = null_type, typename T3 = null_type>
class tuple
{
public:

	typedef typename make_type_list<T0,T1,T2,T3>::result type_list;

	tuple();
	tuple(T0 const& t0);
	tuple(T0 const& t0, T1 const& t1);
	tuple(T0 const& t0, T1 const& t1, T2 const& t2);
	tuple(T0 const& t0, T1 const& t1, T2 const& t2, T3 const& t3);

#if HAVE_C11_EXPLICITLY_DEFAULTED_AND_DELETED_SPECIAL_MEMBER_FUNCTIONS
	tuple(tuple const&) = default;
	tuple& operator=(tuple const&) = default;
#endif

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR
	tuple(tuple&& t);
	tuple& operator=(tuple&& t);
#endif

	bool operator==(tuple const& t) const;
	bool operator!=(tuple const& t) const;

	template <int N> typename tl::type_at<type_list,N>::result const& get() const;
	template <int N> typename tl::type_at<type_list,N>::result& get();

private:

	typedef typename tl::bits::member_list<type_list> members;

	members m_members;
};

template <typename T> struct is_pod;
template <typename T> struct is_movable;

template <typename T0, typename T1, typename T2, typename T3>
struct
is_pod< tuple<T0,T1,T2,T3> >
{
	enum { value = is_pod<T0>::value & is_pod<T1>::value & is_pod<T2>::value & is_pod<T3>::value };
};

template <typename T0, typename T1, typename T2, typename T3>
struct
is_movable< tuple<T0,T1,T2,T3> >
{
	enum { value = is_movable<T0>::value & is_movable<T1>::value
					 & is_movable<T2>::value & is_movable<T3>::value };
};

} // namespace mstl

#include "m_tuple.ipp"

#endif // _mstl_tuple_included

// vi:set ts=3 sw=3:
