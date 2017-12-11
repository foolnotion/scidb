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
namespace tl {
namespace bits {

template <typename Head, typename Tail>
template <typename T0, typename T1, typename T2, typename T3>
inline
member_list< type_list<Head, Tail> >::member_list(T0 const& t0, T1 const& t1, T2 const& t2, T3 const& t3)
	:m_head(t0)
	,m_tail(t1, t2, t3, null_type())
{
}

template <typename Head>
template <typename T0, typename T1, typename T2, typename T3>
inline
member_list< type_list<Head, null_type> >::member_list(T0 const& t0, T1 const&, T2 const&, T3 const&)
	:m_head(t0)
{
}


template <typename Head, typename Tail>
inline
bool
member_list< type_list<Head, Tail> >::compare(member_list const& t) const
{
	return m_head == t.m_head && m_tail.compare(t.m_tail);
}


template <typename Head>
inline
bool
member_list< type_list<Head, null_type> >::compare(member_list const& t) const
{
	return m_head == t.m_head;
}


#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

template <typename Head, typename Tail>
inline
member_list< type_list<Head, Tail> >::member_list(member_list&& ml)
	:m_head(mstl::move(ml.m_head))
	,m_tail(mstl::move(ml.m_tail))
{
}


template <typename Head, typename Tail>
inline
member_list< type_list<Head, Tail> >&
member_list< type_list<Head, Tail> >::operator=(member_list&& ml)
{
	m_head = mstl::move(ml.m_head);
	m_tail = mstl::move(ml.m_tail);
	return *this;
}


template <typename Head>
inline
member_list< type_list<Head, null_type> >::member_list(member_list&& ml)
	:m_head(mstl::move(ml.m_head))
{
}


template <typename Head>
inline
member_list< type_list<Head, null_type> >&
member_list< type_list<Head, null_type> >::operator=(member_list&& ml)
{
	m_head = mstl::move(ml.m_head);
	return *this;
}

#endif


template <typename MemberList, int N>
inline
typename tl::type_at<typename MemberList::type_list_t,N>::result const&
accessor<MemberList,N>::get(MemberList const& list)
{
	return accessor<typename MemberList::tail,N - 1>::get(list.m_tail);
}


template <typename MemberList, int N>
inline
typename tl::type_at<typename MemberList::type_list_t,N>::result&
accessor<MemberList,N>::get(MemberList& list)
{
	return accessor<typename MemberList::tail,N - 1>::get(list.m_tail);
}


template <typename MemberList>
inline
typename MemberList::head const&
accessor<MemberList, 0>::get(MemberList const& list)
{
	return list.m_head;
}


template <typename MemberList>
inline
typename MemberList::head&
accessor<MemberList, 0>::get(MemberList& list)
{
	return list.m_head;
}


#if 0
template <int N> struct compare {};

template <>
struct compare<0>
{
	template <typename Tuple>
	static inline bool
	cmp(Tuple const& lhs, Tuple const& rhs)
	{
		return true;
	}
};

template <>
struct compare<1>
{
	template <typename Tuple>
	static inline bool
	cmp(Tuple const& lhs, Tuple const& rhs)
	{
		return lhs.get<0>() == rhs.get<0>();
	}
};

template <>
struct compare<2>
{
	template <typename Tuple>
	static inline bool
	cmp(Tuple const& lhs, Tuple const& rhs)
	{
		return lhs.get<0>() == rhs.get<0>() && lhs.get<1>() == rhs.get<1>();
	}
};

template <>
struct compare<3>
{
	template <typename Tuple>
	static inline bool
	cmp(Tuple const& lhs, Tuple const& rhs)
	{
		return	lhs.get<0>() == rhs.get<0>()
				&& lhs.get<1>() == rhs.get<1>()
				&& lhs.get<2>() == rhs.get<2>();
	}
};

template <>
struct compare<4>
{
	template <typename Tuple>
	static inline bool
	cmp(Tuple const& lhs, Tuple const& rhs)
	{
		return	lhs.get<0>() == rhs.get<0>()
				&& lhs.get<1>() == rhs.get<1>()
				&& lhs.get<2>() == rhs.get<2>()
				&& lhs.get<3>() == rhs.get<3>();
	}
};
#endif

} // namespace bits
} // namespace tl
} // namespace mstl

// vi:set ts=3 sw=3:
