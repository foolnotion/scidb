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

namespace mstl {

template <typename T, typename U> inline pair<T,U>::pair() : first(T()), second(U()) {}

template <typename T, typename U>
inline pair<T,U>::pair(T const& a, U const& b) : first(a), second(b) {}


template <typename T, typename U>
inline
pair<T,U>& pair<T,U>::operator=(pair const& p)
{
	first = p.first;
	second = p.second;

	return *this;
}


template <typename T, typename U>
inline
bool
operator==(pair<T,U> const& lhs, pair<T,U> const& rhs)
{
	return lhs.first == rhs.first && lhs.second == rhs.second;
}


template <typename T, typename U>
inline
bool
operator!=(pair<T,U> const& lhs, pair<T,U> const& rhs)
{
	return !(lhs.first == rhs.first && lhs.second == rhs.second);
}


template <typename T, typename U>
inline
bool
operator<(pair<T,U> const& lhs, pair<T,U> const& rhs)
{
	return lhs.first < rhs.first || (lhs.first == rhs.first && lhs.second < rhs.second);
}


template <typename T, typename U>
inline
pair<T,U>
make_pair(T const& a, U const& b)
{
	return pair<T,U>(a, b);
}

} // namespace mstl

// vi:set ts=3 sw=3:
