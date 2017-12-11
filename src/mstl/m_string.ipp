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
#include "m_assert.h"

#include <string.h>

namespace mstl {
namespace bits
{
	bool eq(char const* lhs, char const* rhs, size_t len);
	inline bool ne(char const* lhs, char const* rhs, size_t len) { return !eq(lhs, rhs, len); }

	bool ceq(char const* lhs, char const* rhs, size_t len);
	inline bool nce(char const* lhs, char const* rhs, size_t len) { return !ceq(lhs, rhs, len); }
}

inline string::reference::reference(string& str, size_type pos) : m_str(str), m_pos(pos) {}

inline string::reference::operator value_type () const { return m_str.m_data[m_pos]; }

inline string::string() :m_size(0), m_capacity(0), m_data(const_cast<char*>(m_empty)) {}

inline string& string::operator+=(const_reference c) { append(c); return *this; }

inline bool string::empty() const		{ return m_size == 0; }
inline bool string::readonly() const	{ return m_capacity == 0 && m_size > 0; }
inline bool string::writable() const	{ return !readonly(); }
inline bool string::is_7bit() const		{ return is_7bit(m_data, m_size); }


inline string::value_type string::back() const	{ M_REQUIRE(!empty()); return m_data[m_size - 1]; }
inline string::value_type& string::back()			{ M_REQUIRE(!empty()); return m_data[m_size - 1]; }

inline string::size_type string::size() const				{ return m_size; }
inline string::pointer string::data()							{ return m_data; }
inline string::const_pointer string::begin() const			{ return m_data; }
inline string::pointer string::begin()							{ return m_data; }
inline string::pointer string::end()							{ return m_data + m_size; }
inline string::const_pointer string::end() const			{ return m_data + m_size; }
inline string::operator string::const_pointer () const	{ return m_data; }
inline string::value_type string::front() const				{ return *m_data; }
inline string::value_type& string::front()					{ return *m_data; }

inline string::value_type string::operator*() const		{ return *m_data; }

inline void string::push_back(const_reference c)			{ append(c); }
inline void string::clone()										{ if (m_capacity == 0) copy(); }

inline mstl::string& string::trim() { return rtrim().ltrim(); }


inline
string::value_type
string::back(int offset) const
{
	M_REQUIRE(offset <= 0);
	M_REQUIRE(size_type(mstl::abs(offset)) < size());

	return m_data[m_size + offset - 1];
}


inline
string::value_type&
string::back(int offset)
{
	M_REQUIRE(offset <= 0);
	M_REQUIRE(size_type(mstl::abs(offset)) < size());

	return m_data[m_size + offset - 1];
}


inline string::size_type
string::capacity() const
{
	return m_capacity ? m_capacity - 1 : m_capacity;
}


inline
string&
string::operator+=(string const& s)
{
	append(s.m_data, s.m_size);
	return *this;
}


inline string operator+(char lhs, string const& rhs)			{ return string(1, lhs) += rhs; }
inline string operator+(char const* lhs, string const& rhs)	{ return string(lhs) += rhs; }


inline
string::const_pointer
string::c_str() const
{
	return m_data ? m_data : const_cast<char*>(m_empty);
}


inline
string::const_pointer
string::data() const
{
	return m_data ? m_data : const_cast<char*>(m_empty);
}


inline
string::value_type&
string::reference::get()
{
	if (m_str.m_capacity == 0)
		m_str.copy();

	return m_str.m_data[m_pos];
}


inline string::value_type string::reference::operator=(value_type c) { return get() = c; }

template <typename T> inline string::value_type string::reference::operator+=(T v){ return get() += v; }
template <typename T> inline string::value_type string::reference::operator-=(T v){ return get() -= v; }
template <typename T> inline string::value_type string::reference::operator*=(T v){ return get() *= v; }
template <typename T> inline string::value_type string::reference::operator/=(T v){ return get() /= v; }
template <typename T> inline string::value_type string::reference::operator^=(T v){ return get() ^= v; }
template <typename T> inline string::value_type string::reference::operator|=(T v){ return get() |= v; }
template <typename T> inline string::value_type string::reference::operator&=(T v){ return get() &= v; }


inline
void
string::set_size(size_type n)
{
	M_REQUIRE(capacity() == 0 || n <= capacity());
	// require: n < #m_data

	m_data[m_size = n] = '\0';
}


inline
string::value_type
string::at(size_type pos) const
{
	M_REQUIRE(size_type(pos) <= size());
	return m_data[size_type(pos)];
}


inline
string::reference
string::at(size_type pos)
{
	M_REQUIRE(size_type(pos) <= size());
	return reference(*this, pos);
}


inline
string::value_type
string::operator[](int pos) const
{
	return at(pos);
}


inline
string::reference
string::operator[](int pos)
{
	return at(pos);
}


inline
void
string::hook(string const& str)
{
	hook(str.m_data, str.m_size);
}


inline
void
string::make_writable()
{
	if (m_capacity == 0)
		copy();
}


inline
string
string::substr(const_iterator first, const_iterator last) const
{
	M_REQUIRE(first >= begin());
	M_REQUIRE(first <= end());
	M_REQUIRE(first <= last);
	M_REQUIRE(last <= end());

	return mstl::string(first, last);
}


inline
string&
string::append(const_iterator i1, const_iterator i2)
{
	M_REQUIRE(i1 <= i2);
	return append(i1, i2 - i1);
}


inline
string&
string::append(const_pointer s)
{
	M_REQUIRE(s);
	return append(s, ::strlen(s));
}


inline
string&
string::append(string const& s, size_type sp, size_type len)
{
	M_REQUIRE(sp <= s.size());
	M_REQUIRE(len == npos || sp + len <= s.size());

	return append(s.c_str() + sp, len == npos ? s.size() - sp : len);
}


inline
string&
string::assign(const_pointer s)
{
	M_REQUIRE(s);
	return assign(s, ::strlen(s));
}


inline
string&
string::assign(const_iterator i1, const_iterator i2)
{
	M_REQUIRE(i1 <= i2);
	return assign(i1, i2 - i1);
}


inline
string::iterator
string::erase(const_iterator first, const_iterator last)
{
	M_REQUIRE(first <= last);
	return erase(first, last - first);
}


inline
string&
string::insert(size_type ip, const_pointer s)
{
	M_REQUIRE(s);
	return insert(ip, s, ::strlen(s));
}


inline
string::iterator
string::insert(iterator ip, const_pointer s)
{
	M_REQUIRE(s);
	return insert(ip, s, ::strlen(s));
}


inline
string&
string::replace(size_type rp, size_type n, const_reference c)
{
	return replace(rp, n, &c, 1);
}


inline
string&
string::replace(size_type rp, size_type n, const_pointer s)
{
	M_REQUIRE(s);
	return replace(rp, n, s, ::strlen(s));
}


inline
string&
string::replace(size_type rp, size_type n, mstl::string const& s)
{
	return replace(rp, n, s.c_str(), s.size());
}


inline
string::iterator
string::replace(iterator first, iterator last, const_reference c)
{
	return replace(first, last, &c, 1);
}


inline
string::iterator
string::replace(iterator first, iterator last, const_pointer s)
{
	M_REQUIRE(s);
	return replace(first, last, s, ::strlen(s));
}


inline
string::iterator
string::replace(iterator first, iterator last, mstl::string const& s)
{
	return replace(first, last, s.c_str(), s.size());
}


inline
string::size_type
string::find_first_of(string const& s, size_type pos) const
{
	return find_first_of(s.m_data, pos);
}


inline
string::size_type
string::find_last_of(string const& s, size_type pos) const
{
	return find_first_of(s.m_data, pos);
}


inline
string::size_type
string::find_first_not_of(string const& s, size_type pos) const
{
	return find_first_not_of(s.m_data, pos);
}


inline
string::size_type
string::find_last_not_of(string const& s, size_type pos) const
{
	return find_last_not_of(s.m_data, pos);
}


inline bool
string::equal(mstl::string const& s) const
{
	return m_size == s.m_size && bits::eq(m_data, s.m_data, m_size);
}


inline bool
string::equal(char const* s) const
{
	M_REQUIRE(s);
	return m_size == ::strlen(s) && bits::eq(m_data, s, m_size);
}


inline bool
string::equal(mstl::string const& s, size_type len) const
{
	return m_size >= len && bits::eq(m_data, s.m_data, mstl::min(m_size, len));
}


inline bool
string::equal(char const* s, size_type len) const
{
	M_REQUIRE(s || len == 0);
	return m_size >= len && bits::eq(m_data, s, mstl::min(m_size, len));
}


inline bool
string::not_equal(mstl::string const& s) const
{
	return m_size == s.m_size && bits::ne(m_data, s.m_data, m_size);
}


inline bool
string::not_equal(char const* s) const
{
	M_REQUIRE(s);
	return m_size == ::strlen(s) && bits::ne(m_data, s, m_size);
}


inline bool
string::not_equal(mstl::string const& s, size_type len) const
{
	return m_size >= len && bits::ne(m_data, s.m_data, mstl::min(m_size, len));
}


inline bool
string::not_equal(char const* s, size_type len) const
{
	M_REQUIRE(s || len == 0);
	return m_size >= len && bits::ne(m_data, s, mstl::min(m_size, len));
}


inline bool
string::case_equal(mstl::string const& s) const
{
	return m_size == s.m_size && bits::ceq(m_data, s.m_data, m_size);
}


inline bool
string::case_equal(char const* s) const
{
	M_REQUIRE(s);
	return m_size == ::strlen(s) && bits::ceq(m_data, s, m_size);
}


inline bool
string::case_equal(mstl::string const& s, size_type len) const
{
	return m_size >= len && bits::ceq(m_data, s.m_data, mstl::min(m_size, len));
}


inline bool
string::case_equal(char const* s, size_type len) const
{
	M_REQUIRE(s || len == 0);
	return m_size >= len && bits::ceq(m_data, s, mstl::min(m_size, len));
}


inline bool
string::not_case_equal(mstl::string const& s) const
{
	return m_size == s.m_size && bits::nce(m_data, s.m_data, m_size);
}


inline bool
string::not_case_equal(char const* s) const
{
	M_REQUIRE(s);
	return m_size == ::strlen(s) && bits::nce(m_data, s, m_size);
}


inline bool
string::not_case_equal(mstl::string const& s, size_type len) const
{
	return m_size >= len && bits::nce(m_data, s.m_data, mstl::min(m_size, len));
}


inline bool
string::not_case_equal(char const* s, size_type len) const
{
	M_REQUIRE(s || len == 0);
	return m_size >= len && bits::nce(m_data, s, mstl::min(m_size, len));
}

namespace bits {

inline
bool
eq(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	return lhsSize == rhsSize && bits::eq(lhs, rhs, lhsSize);
}


inline
bool
ne(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	return lhsSize != rhsSize || bits::ne(lhs, rhs, lhsSize);
}


inline
bool
le(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	unsigned len = mstl::min(lhsSize, rhsSize);
	int cmp = ::strncmp(lhs, rhs, len);
	return cmp <= 0 || (cmp == 0 && rhsSize > len);
}


inline
bool
lt(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	unsigned len = mstl::min(lhsSize, rhsSize);

	int cmp = ::strncmp(lhs, rhs, len);
	return cmp < 0 || (cmp == 0 && rhsSize > len);
}


inline
bool
ge(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	unsigned len = mstl::min(lhsSize, rhsSize);
	int cmp = ::strncmp(lhs, rhs, len);
	return cmp >= 0 || (cmp == 0 && lhsSize > len);
}


inline
bool
gt(char const* lhs, unsigned lhsSize, char const* rhs, unsigned rhsSize)
{
	unsigned len = mstl::min(lhsSize, rhsSize);
	int cmp = ::strncmp(lhs, rhs, len);
	return cmp > 0 || (cmp == 0 && lhsSize > len);
}

} // namespace bits

inline
bool
operator==(string const& lhs, string const& rhs)
{
	return bits::eq(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator!=(string const& lhs, string const& rhs)
{
	return bits::ne(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator<=(string const& lhs, string const& rhs)
{
	return bits::le(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator<(string const& lhs, string const& rhs)
{
	return bits::lt(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator>=(string const& lhs, string const& rhs)
{
	return bits::ge(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator>(string const& lhs, string const& rhs)
{
	return bits::gt(lhs, lhs.size(), rhs, rhs.size());
}


inline
bool
operator==(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) == 0;

	return bits::eq(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator!=(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) != 0;

	return bits::ne(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator<=(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) <= 0;

	return bits::le(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator<(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) <  0;

	return bits::lt(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator>=(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) >= 0;

	return bits::ge(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator>(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);

	if (lhs.writable())
		return ::strcmp(lhs, rhs) >  0;

	return bits::gt(lhs, lhs.size(), rhs, ::strlen(rhs));
}


inline
bool
operator==(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) == 0;
	
	return bits::eq(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline
bool
operator!=(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) != 0;
	
	return bits::ne(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline
bool
operator<=(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) <= 0;
	
	return bits::le(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline
bool
operator<(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) < 0;
	
	return bits::lt(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline
bool
operator>=(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) >= 0;
	
	return bits::ge(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline
bool
operator>(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);

	if (rhs.writable())
		return ::strcmp(lhs, rhs) > 0;
	
	return bits::gt(lhs, ::strlen(lhs), rhs, rhs.size());
}


inline void swap(string& lhs, string& rhs) { lhs.swap(rhs); }

inline
void
swap(string::reference lhs, string::reference rhs)
{
	string::value_type c = static_cast<string::value_type>(lhs);
	lhs = static_cast<string::value_type>(rhs);
	rhs = c;
}

#if HAVE_C11_MOVE_CONSTRCUTOR_AND_ASSIGMENT_OPERATOR

inline
string::string(string&& str)
	:m_size(str.m_size)
	,m_capacity(str.m_capacity)
	,m_data(str.m_data)
{
	str.m_data = 0;
}


inline
string& string::operator=(string&& str)
{
	if (this != &str)
	{
		m_size = str.m_size;
		mstl::swap(m_capacity, str.m_capacity);
		mstl::swap(m_data, str.m_data);
	}

	return *this;
}

#endif


inline int compare(string const& lhs, string const& rhs)	{ return ::strcmp(lhs, rhs); }


inline
int
compare(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);
	return ::strcmp(lhs, rhs);
}


inline
int
compare(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);
	return ::strcmp(lhs, rhs);
}


inline
int
compare(char const* lhs, char const* rhs)
{
	M_REQUIRE(lhs);
	M_REQUIRE(rhs);

	return ::strcmp(lhs, rhs);
}


inline
int
compare(string const& lhs, string const& rhs, string::size_type len)
{
	return ::strncmp(lhs, rhs, len);
}


inline
int
compare(string const& lhs, char const* rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || rhs);
	return ::strncmp(lhs, rhs, len);
}


inline
int
compare(char const* lhs, string const& rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || lhs);
	return ::strncmp(lhs, rhs, len);
}


inline
int
compare(char const* lhs, char const* rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || lhs);
	M_REQUIRE(len == 0 || rhs);

	return ::strncmp(lhs, rhs, len);
}


inline int case_compare(string const& lhs, string const& rhs)	{ return ::strcasecmp(lhs, rhs); }


inline
int
case_compare(string const& lhs, char const* rhs)
{
	M_REQUIRE(rhs);
	return ::strcasecmp(lhs, rhs);
}


inline
int
case_compare(char const* lhs, string const& rhs)
{
	M_REQUIRE(lhs);
	return ::strcasecmp(lhs, rhs);
}


inline
int
case_compare(char const* lhs, char const* rhs)
{
	M_REQUIRE(lhs);
	M_REQUIRE(rhs);

	return ::strcasecmp(lhs, rhs);
}


inline
int
case_compare(string const& lhs, string const& rhs, string::size_type len)
{
	return ::strncmp(lhs, rhs, len);
}


inline
int
case_compare(string const& lhs, char const* rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || rhs);
	return ::strncasecmp(lhs, rhs, len);
}


inline
int
case_compare(char const* lhs, string const& rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || lhs);
	return ::strncasecmp(lhs, rhs, len);
}


inline
int
case_compare(char const* lhs, char const* rhs, string::size_type len)
{
	M_REQUIRE(len == 0 || lhs);
	M_REQUIRE(len == 0 || rhs);

	return ::strncasecmp(lhs, rhs, len);
}

} // namespace mstl

// vi:set ts=3 sw=3:
