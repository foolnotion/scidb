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

#include "m_string.h"
#include "m_utility.h"
#include "m_memblock.h"
#include "m_type_traits.h"
#include "m_bit_functions.h"
#include "m_ios.h"
#include "m_assert.h"
#include "m_stdio.h"

#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>

#if __WORDSIZE == 64
# define __PRI64_PREFIX "l"
#else
# define __PRI64_PREFIX "ll"
#endif

#define PRId8  "d"
#define PRId16 "d"
#define PRId32	"d"
#define PRId64 __PRI64_PREFIX "d"
#define PRIu8  "u"
#define PRIu16 "u"
#define PRIu32 "u"
#define PRIu64 __PRI64_PREFIX "u"

using namespace mstl;


static char const* Roman[] =
{
	"M",	// 1000
	"CM",	// 900
	"D",	// 500
	"CD",	// 400
	"C",	// 100
	"XC",	// 90
	"L",	// 50
	"XL",	// 40
	"X",	// 10
	"IX",	// 9
	"V",	// 5
	"IV",	// 4
	"I",	// 1
};

static unsigned const Arabic[] =
{
	1000, // M
	 900, // CM
	 500, // D
	 400, // CD
	 100, // C
	  90, // XC
	  50, // L
	  40, // XL
	  10, // X
	   9, // IX
	   5, // V
	   4, // IV
	   1, // I
};


char const* string::m_empty = "";

__attribute__((init_priority(101)))
string const string::empty_string(static_cast<__EMPTY__ const&>(string::__EMPTY__()));


template <typename T>
static inline
string
cast(T value, char const* format)
{
	char buf[100];
	sprintf(buf, format, value);
	return buf;
}


inline static string cast(int8_t   v) { return cast(v, "%" PRId8);  }
inline static string cast(int16_t  v) { return cast(v, "%" PRId16); }
inline static string cast(int32_t  v) { return cast(v, "%" PRId32); }
inline static string cast(int64_t  v) { return cast(v, "%" PRId64); }
inline static string cast(uint8_t  v) { return cast(v, "%" PRIu8);  }
inline static string cast(uint16_t v) { return cast(v, "%" PRIu16); }
inline static string cast(uint32_t v) { return cast(v, "%" PRIu32); }
inline static string cast(uint64_t v) { return cast(v, "%" PRIu64); }


template <typename T>
inline
static void
copy(T* dst, T const* src, size_t n)
{
	memcpy(dst, src, n*sizeof(T));
}


template <typename T>
inline
static void
move(T* dst, T const* src, size_t n)
{
	memmove(dst, src, n*sizeof(T));
}


template <typename T>
inline
static void
fill(T* dst, size_t n, T value)
{
	fill_n(dst, n, value);
}


inline static void copy(unsigned char* dst, unsigned char const* src, size_t n) { memcpy(dst, src, n); }
inline static void move(unsigned char* dst, unsigned char const* src, size_t n) { memmove(dst, src, n); }
inline static void fill(unsigned char* dst, size_t n, char value) { memset(dst, value, n); }

inline static void copy(char* dst, char const* src, size_t n)	{ memcpy(dst, src, n); }
inline static void move(char* dst, char const* src, size_t n)	{ memmove(dst, src, n); }
inline static void fill(char* dst, size_t n, char value)			{ memset(dst, value, n); }


string::string(__EMPTY__)
	:m_size(0)
	,m_capacity(0)
	,m_data(const_cast<char *>(m_empty))
{
}


string::string(const_pointer s)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	static_assert(mstl::is_pod<value_type>::value, "value type must be POD");
	M_REQUIRE(s);

	init(s, ::strlen(s));
}


string::string(const_pointer s, size_type len)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	M_REQUIRE(s);
	init(s, len);
}


string::string(const_iterator i1, const_iterator i2)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	M_REQUIRE(i1 <= i2);
	init(i1, i2 - i1);
}


string::string(size_type n, value_type c)
	:m_size(n)
	,m_capacity(0)
	,m_data(0)
{
	if (m_size)
	{
		m_capacity = m_size + 1;
		m_data = new value_type[m_capacity];
		m_data[m_size] = '\0';
		::fill(m_data, m_size, c);
	}
	else
	{
		m_data = const_cast<char *>(m_empty);
	}
}


string::string(size_type n, mstl::string const& s)
	:m_size(n*s.m_size)
	,m_capacity(0)
	,m_data(0)
{
	if (m_size)
	{
		m_capacity = m_size + 1;
		m_data = new value_type[m_capacity];

		char* data = m_data;
		char* end  = data + m_size;

		for ( ; data < end; data += n)
			::copy(data, s.m_data, s.m_size);

		*end = '\0';
	}
	else
	{
		m_data = const_cast<char *>(m_empty);
	}
}


string::string(string const& s)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	if (s.empty())
	{
		m_data = empty_string.m_data;
	}
	else
	{
		if (s.m_capacity == 0)
		{
			m_data = s.m_data;
			m_size = s.m_size;
		}
		else
		{
			resize(s.m_size);
			::copy(m_data, s.m_data, s.m_size + 1);
		}
	}
}


string::string(string const& s, size_type len)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	M_REQUIRE(len == npos || len <= s.size());

	if (len == 0 || (len == npos && s.empty()))
	{
		m_data = const_cast<char *>(m_empty);
	}
	else
	{
		if (s.m_capacity == 0)
		{
			m_data = s.m_data;
			m_size = mstl::min(s.m_size, len);
		}
		else
		{
			resize(len);
			::copy(m_data, s.m_data, mstl::min(s.m_size, len));
			m_data[len] = '\0';
		}
	}
}


string::string(string const& s, size_type pos, size_type len)
	:m_size(0)
	,m_capacity(0)
	,m_data(0)
{
	M_REQUIRE(len == npos ? pos <= s.size() : pos + len <= s.size());

	if (len == 0 || (len == npos && s.empty()))
	{
		m_data = const_cast<char *>(m_empty);
	}
	else if (pos == 0 && s.m_capacity == 0)
	{
		m_data = s.m_data;
		m_size = mstl::min(s.m_size, len);
	}
	else
	{
		len = mstl::min(s.m_size - pos, len);
		resize(len);
		::copy(m_data, s.m_data + pos, len);
		m_data[len] = '\0';
	}
}


string::string(size_type n)
	:m_size(n)
	,m_capacity(0)
	,m_data(0)
{
	if (n)
	{
		m_capacity = n + 1;
		m_data = new value_type[m_capacity];
		m_data[m_size] = '\0';
	}
	else
	{
		m_data = const_cast<char *>(m_empty);
	}
}


string::~string() throw()
{
	if (m_capacity)
		delete [] m_data;
}


string string::cast(int8_t  value) { return ::cast(value); }
string string::cast(int16_t value) { return ::cast(value); }
string string::cast(int32_t value) { return ::cast(value); }
string string::cast(int64_t value) { return ::cast(value); }

string string::cast(uint8_t  value) { return ::cast(value); }
string string::cast(uint16_t value) { return ::cast(value); }
string string::cast(uint32_t value) { return ::cast(value); }
string string::cast(uint64_t value) { return ::cast(value); }


string&
string::operator=(const_reference c)
{
	resize(1);
	m_data[0] = c;
	return *this;
}


string&
string::operator=(const_pointer s)
{
	M_REQUIRE(s);
	assign(s, ::strlen(s));
	return *this;
}


string&
string::operator=(string const& s)
{
	if (this != &s)
		assign(s);

	return *this;
}


string&
string::append(const_reference c)
{
	resize(m_size + 1);
	m_data[m_size - 1] = c;
	return *this;
}


string&
string::append(size_type n, const_reference c)
{
	if (n)
	{
		resize(m_size + n);
		::fill(m_data + m_size - n, n, c);
	}
	return *this;
}


string&
string::append(const_pointer s, size_type len)
{
	M_REQUIRE(s);

	if (len)
	{
		reserve(m_size + len);
		::copy(m_data + m_size, s, len);
		m_data[m_size += len] = '\0';
	}

	return *this;
}


string&
string::operator+=(const_pointer s)
{
	M_REQUIRE(s);
	append(s, ::strlen(s));
	return *this;
}


string
string::operator+(const_reference c) const
{
	string result(m_size + 1);
	::copy(result.m_data, m_data, m_size);
	result.m_data[m_size] = c;
	return result;
}


string
string::operator+(const_pointer s) const
{
	M_REQUIRE(s);

	size_type n = ::strlen(s);
	string result(m_size + n);
	::copy(result.m_data, m_data, m_size);
	::copy(result.m_data + m_size, s, n);
	return result;
}


string
string::operator+(string const& s) const
{
	string result(m_size + s.m_size);
	::copy(result.m_data, m_data, m_size);
	::copy(result.m_data + m_size, s.m_data, s.m_size);
	return result;
}


void
string::init(const_pointer s, size_type len)
{
	M_ASSERT(s);

	if (len)
	{
		reserve(len);
		::copy(m_data, s, len);
		m_data[m_size = len] = '\0';
	}
	else
	{
		m_data = const_cast<char *>(m_empty);
	}
}


string&
string::assign(const_pointer s, size_type len)
{
	M_REQUIRE(s);

	if (len)
	{
		reserve(len);
		::copy(m_data, s, len);
		m_data[m_size = len] = '\0';
	}
	else if (!empty())
	{
		clear();
	}

	return *this;
}


string&
string::assign(string const& s)
{
	if (!s.empty())
	{
		if ((m_capacity | s.m_capacity) == 0)
		{
			m_data = s.m_data;
			m_size = s.m_size;
		}
		else
		{
			resize(s.m_size);
			::copy(m_data, s.m_data, s.m_size);
		}
	}
	else if (!empty())
	{
		clear();
	}

	return *this;
}


string&
string::assign(string const& s, size_type len)
{
	M_REQUIRE(len <= s.size());

	if (len > 0)
	{
		if ((m_capacity | s.m_capacity) == 0 && len == m_size)
		{
			m_data = s.m_data;
			m_size = len;
		}
		else
		{
			resize(len);
			::copy(m_data, s.m_data, len);
		}
	}
	else if (!empty())
	{
		clear();
	}

	return *this;
}


string&
string::assign(string const& s, size_type pos, size_type len)
{
	M_REQUIRE(len == npos ? pos <= s.size() : pos + len <= s.size());

	if (len == npos)
		len = s.size() - pos;

	return assign(s.m_data + pos, len);
}


string&
string::assign(size_type n, const_reference c)
{
	if (n > 0)
	{
		resize(n);
		::fill(m_data, n, c);
	}
	else if (!empty())
	{
		clear();
	}

	return *this;
}


string&
string::assign(size_type n, string const& s)
{
	if (!s.empty())
	{
		unsigned nbytes = n*s.m_size;

		resize(nbytes);

		char* data = m_data;
		char* end  = data + nbytes;

		for ( ; data < end; data += n)
			::copy(data, s.m_data, s.m_size);

		*end = '\0';
	}
	else if (!empty())
	{
		clear();
	}

	return *this;
}


string&
string::insert(size_type ip, const_reference c)
{
	M_REQUIRE(ip == npos || ip <= size());

	if (ip == npos || ip == size())
	{
		append(c);
	}
	else
	{
		resize(m_size + 1);
		iterator pos = m_data + ip;
		::move(pos + 1, pos, m_size - ip - 1);
		m_data[ip] = c;
	}

	return *this;
}


string&
string::insert(size_type ip, const_pointer s, size_type slen)
{
	M_REQUIRE(s);
	M_REQUIRE(ip == npos || ip <= size());

	if (ip == npos || ip == size())
	{
		append(s, slen);
	}
	else
	{
		resize(m_size + slen);
		iterator pos = m_data + ip;
		::move(pos + slen, pos, m_size - ip - slen);
		::copy(pos, s, slen);
	}

	return *this;
}


string&
string::insert(size_type ip, string const& s, size_type sp, size_type slen)
{
	M_REQUIRE(slen == npos ? sp <= s.size() : sp + slen <= s.size());
	M_REQUIRE(ip == npos || ip <= size());

	if (ip != npos && ip != size())
		return insert(ip, s.m_data + sp, slen);

	return append(s.m_data + (sp == npos ? s.m_size : sp), slen);
}


string::iterator
string::insert(iterator ip, const_pointer s, size_type slen)
{
	M_REQUIRE(s);
	M_REQUIRE(ip >= begin());
	M_REQUIRE(ip <= end());

	unsigned offs = ip - m_data;
	resize(m_size + slen);
	iterator pos = m_data + offs;
	::move(pos + slen, pos, m_size - distance(begin(), pos) - slen);
	::copy(pos, s, slen);
	return pos;
}


string::iterator
string::insert(iterator ip, string const& s, size_type sp, size_type slen)
{
	M_REQUIRE(slen == npos ? sp <= s.size() : sp + slen <= s.size());
	return insert(ip, sp == npos ? s.end() : s.c_str() + sp, slen);
}


void
string::clear()
{
	if (m_capacity == 0)
	{
		if (!empty())
		{
			m_data = const_cast<char *>(m_empty);
			m_size = 0;
			m_capacity = 0;
		}
	}
	else if (m_size)
	{
		m_data[m_size = 0] = '\0';
	}
}


void
string::swap(string& s)
{
	::mstl::swap(m_size, s.m_size);
	::mstl::swap(m_capacity, s.m_capacity);
	::mstl::swap(m_data, s.m_data);
}


void
string::reserve(size_type n)
{
	if (n < m_capacity)
		return;

	size_type	capacity;
	pointer		p;

	if (m_capacity == 0)
	{
		capacity = mstl::max(m_size, n) + 1;
		p = new value_type[capacity];
		::copy(p, m_data, m_size);
	}
	else
	{
		capacity = memblock<value_type>::compute_capacity(m_capacity, n + 1, 20);

		M_ASSERT(capacity > m_size);
		M_ASSERT(m_size < m_capacity);

		p = new value_type[capacity];
		::copy(p, m_data, m_size);
		delete [] m_data;
	}

	p[m_size] = '\0';
	m_data = p;
	m_capacity = capacity;
}


void
string::reserve_exact(size_type n)
{
	M_REQUIRE(n >= size());

	pointer p = new value_type[n + 1];
	::copy(p, m_data, m_size);

	if (m_capacity)
		delete [] m_data;

	p[m_size] = '\0';
	m_data = p;
	m_capacity = n + 1;
}


void
string::resize(size_type n)
{
	reserve(n);

	if ((m_size = n))
		m_data[m_size] = '\0';
}


void
string::copy()
{
	M_ASSERT(empty() || readonly());

	m_capacity = m_size + 1;
	pointer p = new value_type[m_capacity];
	::copy(p, m_data, m_capacity);
	m_data = p;
}


string::iterator
string::erase(const_iterator start, size_type n)
{
	M_REQUIRE(n != npos);
	M_REQUIRE(start + n <= end());

	string::iterator s = const_cast<iterator>(start);

	if (n > 0 && !empty())
	{
		size_type i = s - m_data;

		if (m_capacity == 0)
			copy();

		m_size -= n;
		s = m_data + i;

		::move(s, s + n, m_size - i + 1);
	}

	return s;
}


string&
string::erase(size_type pos, size_type n)
{
	M_REQUIRE(pos <= size());
	M_REQUIRE(n == npos || pos + n <= size());

	if (empty() || n == 0)
		return *this;

	if (m_capacity == 0)
		copy();

	if (n == npos)
	{
		m_size = pos;
	}
	else
	{
		if (pos + n < m_size)
			::move(m_data + pos, m_data + pos + n, m_size - n - pos);

		m_size -= n;
	}

	m_data[m_size] = '\0';
	return *this;
}


string&
string::replace(size_type rp, size_type k, const_pointer s, size_type n)
{
	M_REQUIRE(rp == npos || rp <= size());
	M_REQUIRE(n == npos || rp == npos ? k == 0 : rp + k <= size());
	M_REQUIRE(s);

	if (n < k)
	{
		erase(rp, k - n);
	}
	else if (k < n)
	{
		insert(rp, s, n -= k);
		rp += n;
		s += n;
		n = k;
	}

	::copy(begin() + rp, s, n);

	return *this;
}


string::iterator
string::replace(iterator first, iterator last, const_pointer s, size_type n)
{
	M_REQUIRE(first <= last);
	M_REQUIRE(first == last || first >= begin());
	M_REQUIRE(first == last || last <= end());
	M_REQUIRE(s);

	size_type k = distance(first, last);

	if (n < k)
		first = erase(first, k - n);
	else if (k < n)
		first = insert(first, s, n -= k);

	::copy(first, s, n);

	return first;
}


void
string::pop_back()
{
	M_REQUIRE(!empty());

	if (m_capacity == 0)
		copy();

	m_data[--m_size] = '\0';
}


int
string::vformat(const_pointer fmt, va_list args)
{
	M_REQUIRE(fmt);

	value_type buffer[2048];

	int size = ::vsnprintf(buffer, sizeof(buffer), fmt, args);

	if (size >= (int)sizeof(buffer))
	{
		value_type* buf = nullptr;
		size = ::vasprintf(&buf, fmt, args);
		if (size)
			append(buf, size);
		::free(buf);
	}
	else if (size)
	{
		append(buffer, size);
	}

	return size;
}


int
string::format(const_pointer fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	int size = vformat(fmt, args);
	va_end(args);
	return size;
}


string::size_type
string::find(const_reference c, size_type pos) const
{
	M_REQUIRE(pos <= size());

	const_pointer p = ::strchr(m_data + pos, c);
	return p ? p - m_data : npos;
}


string::size_type
string::find(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos <= size());

	const_pointer p = ::strstr(m_data + pos, s);
	return p ? p - m_data : npos;
}


string::size_type
string::find(string const& s, size_type pos) const
{
	M_REQUIRE(pos <= size());

	const_pointer p = ::strstr(m_data + pos, s);
	return p ? p - m_data : npos;
}


string::size_type
string::find_ignore_case(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos <= size());

	size_type		len	= ::strlen(s);

	if (len > m_size)
		return npos;

	value_type		first	= ::toupper(*s);
	const_pointer	p		= m_data + pos;
	const_pointer	e		= m_data + m_size - len;

	for ( ; p < e; ++p)
	{
		if (::toupper(*p) == first)
		{
			if (::strncasecmp(p, s, len) == 0)
				return p - m_data;
		}
	}

	return npos;
}


string::size_type
string::find_ignore_case(string const& s, size_type pos) const
{
	M_REQUIRE(pos <= size());

	if (s.m_size > m_size)
		return npos;

	value_type		first	= ::toupper(*s.m_data);
	const_pointer	p		= m_data + pos;
	const_pointer	e		= m_data + m_size - s.m_size;

	for ( ; p < e; ++p)
	{
		if (::toupper(*p) == first)
		{
			if (::strncasecmp(p, s.m_data, s.m_size) == 0)
				return p - m_data;
		}
	}

	return npos;
}


string::size_type
string::rfind(const_reference c, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	const_pointer p = m_data + (pos == npos ? m_size : pos);

	while (p >= m_data && *p != c)
		--p;

	return p >= m_data ? p - m_data : npos;
}


string::size_type
string::find_first_of(const_reference c, size_type pos) const
{
	M_REQUIRE(pos <= size());

	value_type const* p = ::strchr(m_data + pos, c);
	return p ? p - m_data : npos;
}


string::size_type
string::find_first_of(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos <= size());

	size_t n = ::strcspn(m_data + pos, s);
	return n >= size() - pos ? npos : n + pos;
}


string::size_type
string::find_last_of(const_reference c, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	for (char const* p = m_data + mstl::min(m_size, pos) - 1; p >= m_data; --p)
	{
		if (*p == c)
			return p - m_data;
	}

	return npos;
}


string::size_type
string::find_last_of(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	for (char const* p = m_data + mstl::min(m_size, pos) - 1; p >= m_data; --p)
	{
		if (::strchr(s, *p))
			return p - m_data;
	}

	return npos;
}


string::size_type
string::find_first_not_of(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	if (m_size == 0)
		return npos;

	pos = mstl::min(m_size - 1, pos);

	size_t n = ::strspn(m_data + pos, s);
	return n >= size() - pos ? npos : n + pos;
}


string::size_type
string::find_first_not_of(const_reference c, size_type pos) const
{
	M_REQUIRE(pos <= size());

	char const* e = m_data + m_size;

	for (char const* p = m_data + pos; p < e; ++p)
	{
		if (*p != c)
			return p - m_data;
	}

	return npos;
}


string::size_type
string::find_last_not_of(const_pointer s, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	for (char const* p = m_data + mstl::min(m_size, pos) - 1; p >= m_data; --p)
	{
		if (::strchr(s, *p) == 0)
			return p - m_data;
	}

	return npos;
}


string::size_type
string::find_last_not_of(const_reference c, size_type pos) const
{
	M_REQUIRE(pos == npos || pos <= size());

	for (char const* p = m_data + mstl::min(m_size, pos) - 1; p >= m_data; --p)
	{
		if (*p != c)
			return p - m_data;
	}

	return npos;
}


void
string::hook(pointer s)
{
	M_REQUIRE(s);

	if (m_capacity)
		delete [] m_data;

	m_data = s;
	m_size = ::strlen(s);
	m_capacity = 0;
}


void
string::hook(pointer s, size_type slen)
{
	M_REQUIRE(s);

	if (m_capacity)
		delete [] m_data;

	m_data = s;
	m_size = slen;
	m_capacity = 0;
}


mstl::string&
string::unhook()
{
	if (m_capacity == 0)
	{
		m_capacity = m_size + 1;
		value_type* s = new value_type[m_capacity];
		::memcpy(s, m_data, m_capacity);
		m_data = s;
	}

	return *this;
}


mstl::string&
string::ltrim()
{
	value_type const* s = begin();

	while (::isspace(*s))
		++s;

	if (s > begin())
		erase(begin(), s);

	return *this;
}


mstl::string&
string::rtrim()
{
	if (empty())
		return *this;

	value_type* s = end();

	while (s > begin() && ::isspace(s[-1]))
		--s;

	if (s < end())
		erase(s, end());

	return *this;
}


void
string::strip()
{
	char* s = m_data;

	while (*s && !::isspace(*s))
		++s;

	if (*s)
	{
		char* t = s;

		for ( ; *s ; ++s)
		{
			if (!::isspace(*s))
				*t++ = *s;
		}

		*t = '\0';
		m_size = t - m_data;
	}
}


void
string::strip(const_reference c)
{
	char* s = m_data;

	while (*s && *s != c)
		++s;

	if (*s)
	{
		char* t = s;

		for ( ; *s ; ++s)
		{
			if (*s != c)
				*t++ = *s;
		}

		*t = '\0';
		m_size = t - m_data;
	}
}


string
string::substr(size_type pos, size_type len) const
{
	M_REQUIRE(pos <= size());
	M_REQUIRE(len == npos || pos + len <= size());

	return mstl::string(m_data + pos, len == npos ? m_size - pos : len);
}


unsigned
string::appendRomanNumber(unsigned n, int (*caseconv)(int))
{
	if (n == 0 || n > 3999)
		return 0;

	unsigned	remainder	= n;
	unsigned	len			= 0;
	char		buf[100];

	for (unsigned i = 0; i < sizeof(::Roman)/sizeof(::Roman[0]) && remainder > 0; ++i)
	{
		while (remainder >= ::Arabic[i])
		{
			M_ASSERT(len < sizeof(buf) - 2);

			char const* rn = ::Roman[i];

			buf[len++] = caseconv(rn[0]);
			if (rn[1])
				buf[len++] = caseconv(rn[1]);

			remainder -= ::Arabic[i];
		}
	}

	append(buf, len);
	return len;
}


unsigned
string::appendRomanNumber(unsigned n)
{
	return appendRomanNumber(n, ::toupper);
}


unsigned
string::appendSmallRomanNumber(unsigned n)
{
	return appendRomanNumber(n, ::tolower);
}


int
string::toArabic(size_type pos, size_type len) const
{
	M_REQUIRE(pos <= m_size);
	M_REQUIRE(len == npos || pos + len <= m_size);

	if (len == npos)
		len = m_size - pos;

	char const* s = m_data + pos;
	char const* e = s + len;

	int arabic = 0;

	for (unsigned i = 0; i < sizeof(::Roman)/sizeof(::Roman[0]) && s < e; ++i)
	{
		char const* rn = ::Roman[i];

		while (::toupper(s[0]) == rn[0] && (rn[1] == '\0' || (s + 1 < e && ::toupper(s[1]) == rn[1])))
		{
			arabic += ::Arabic[i];
			s += (rn[1] ? 2 : 1);
		}
	}

	return s == e ? arabic : -1;
}


string&
string::tolower(size_type pos, size_type len)
{
	M_REQUIRE(pos <= m_size);
	M_REQUIRE(len == npos || pos + len <= m_size);

	char* s = m_data + pos;
	char* e = (len == npos) ? m_data + m_size : s + len;

	for ( ; s < e; ++s)
		*s = ::tolower(*s);

	return *this;
}


string&
string::toupper(size_type pos, size_type len)
{
	M_REQUIRE(pos <= m_size);
	M_REQUIRE(len == npos || pos + len <= m_size);

	char* s = m_data + pos;
	char* e = (len == npos) ? m_data + m_size : s + len;

	for ( ; s < e; ++s)
		*s = ::toupper(*s);

	return *this;
}


string::size_type
string::map(value_type mapping, value_type c, size_type occurrence)
{
	if (occurrence == 0)
		return 0;

	size_type n = 0;

	for (size_type i = 0; i < m_size; ++i)
	{
		if (m_data[i] == mapping)
		{
			unhook();
			m_data[i] = c;

			if (++n == occurrence)
				return n;
		}
	}

	return n;
}


bool
string::is_7bit(char const* s)
{
	M_REQUIRE(s);

	for ( ; *s; ++s)
	{
		if (*s & 0x80)
			return false;
	}

	return true;
}


bool
string::is_7bit(char const* s, unsigned length)
{
	M_REQUIRE(s);

	char const* e = s + length;

	for ( ; s < e; ++s)
	{
		if (*s & 0x80)
			return false;
	}

	return true;
}


bool
bits::eq(char const* lhs, char const* rhs, size_t len)
{
	M_ASSERT(lhs);
	M_ASSERT(rhs);

	while (len--)
	{
		if (*lhs++ != *rhs++)
			return false;
	}

	return true;
}


bool
bits::ceq(char const* lhs, char const* rhs, size_t len)
{
	M_ASSERT(lhs);
	M_ASSERT(rhs);

	while (len--)
	{
		if (::tolower(*lhs++) != ::tolower(*rhs++))
			return false;
	}

	return true;
}


unsigned
string::levenshtein_distance(mstl::string const& s, unsigned ins, unsigned del, unsigned sub) const
{
	if (m_data == s.m_data)
		return 0;
	if (m_size == 0)
		return m_size*ins;
	if (s.m_size == 0)
		return s.m_size*ins;

	// algorithm from http://en.wikipedia.org/wiki/Levenshtein_distance

	unsigned d[m_size + 1][s.m_size + 1];

	::memset(d, 0, sizeof(d[0][0])*(m_size+ 1)*(s.m_size + 1));

	for (size_type i = 0; i <= m_size; ++i)
		d[i][0] = i;
	for (size_type j = 0; j <= s.m_size; ++j)
		d[0][j] = j;

	for (unsigned j = 0; j < s.m_size; ++j)
	{
		value_type c = s.m_data[j];

		for (unsigned i = 0; i < m_size; ++i)
		{
			if (c == m_data[i])
				d[i + 1][j + 1] = d[i][j];
			else
				d[i + 1][j + 1] = mstl::min(d[i][j + 1] + del, d[i + 1][j] + ins, d[i][j] + sub);
		}
	}

	return d[m_size][s.m_size];
}


unsigned
string::levenshtein_distance_fast(mstl::string const& s) const
{
	if (m_data == s.m_data)
		return 0;
	if (m_size == 0)
		return s.m_size;
	if (s.m_size == 0)
		return m_size;

	// algorithm from http://en.wikipedia.org/wiki/Levenshtein_distance

	unsigned v0[s.m_size + 1];
	unsigned v1[s.m_size + 1];

	for (unsigned i = 0; i <= s.m_size; ++i)
		v0[i] = i;

	for (size_type i = 0; i < m_size; ++i)
	{
		v1[0] = i + 1;

		for (size_type j = 0; j < s.m_size; ++j)
		{
			unsigned cost = (m_data[i] == s.m_data[j]) ? 0 : 1;
			v1[j + 1] = mstl::min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
		}

		for (size_type j = 0; j <= s.m_size; ++j)
			v0[j] = v1[j];
	}

	return v1[s.m_size];
}

// vi:set ts=3 sw=3:
