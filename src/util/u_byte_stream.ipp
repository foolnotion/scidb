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

#include "m_assert.h"

namespace util {

inline ByteStream::ByRef::ByRef(ByteStream* strm) :ref(strm) {}

inline ByteStream::operator ByteStream::ByRef () { return ByRef(this); }

inline ByteStream::uint24_t::uint24_t(uint32_t n) : i(n) {}
inline ByteStream::uint24_t::operator uint32_t () const { return i; }
inline ByteStream::uint24_t& ByteStream::uint24_t::operator=(uint32_t n) { i = n; return *this; }
inline ByteStream::uint48_t::uint48_t(uint64_t n) : i(n) {}
inline ByteStream::uint48_t::operator uint64_t () const { return i; }
inline ByteStream::uint48_t& ByteStream::uint48_t::operator=(uint64_t n) { i = n; return *this; }

inline bool ByteStream::isEmpty() const			{ return m_getp == m_endp; }
inline bool ByteStream::isFull() const				{ return m_putp == m_endp; }
inline unsigned ByteStream::capacity() const		{ return m_endp - m_base; }
inline unsigned ByteStream::size() const			{ return m_endp - m_getp; }
inline unsigned ByteStream::remaining() const	{ return m_endp - m_getp; }
inline unsigned ByteStream::free() const			{ return m_endp - m_putp; }
inline unsigned ByteStream::tellp() const			{ return m_putp - m_base; }
inline unsigned ByteStream::tellg() const			{ return m_getp - m_base; }

inline ByteStream::Byte* ByteStream::base()					{ return m_base; }
inline ByteStream::Byte const* ByteStream::base() const	{ return m_base; }
inline ByteStream::Byte const* ByteStream::data() const	{ return m_getp; }
inline ByteStream::Byte* ByteStream::buffer()				{ return m_putp; }
inline ByteStream::Byte const* ByteStream::end() const	{ return m_endp; }

inline void ByteStream::reset(unsigned size)					{ m_endp = m_base + size; }

inline ByteStream& ByteStream::operator>>(uint16_t& i)	{ i = uint16(); return *this; }
inline ByteStream& ByteStream::operator>>(uint24_t& i)	{ i = uint24(); return *this; }
inline ByteStream& ByteStream::operator>>(uint48_t& i)	{ i = uint48(); return *this; }
inline ByteStream& ByteStream::operator>>(uint32_t& i)	{ i = uint32(); return *this; }
inline ByteStream& ByteStream::operator>>(uint64_t& i)	{ i = uint64(); return *this; }

inline void ByteStream::resetp() { m_putp = m_base; }
inline void ByteStream::resetg() { m_getp = m_base; }


inline
ByteStream::Byte
ByteStream::operator[](unsigned at) const
{
	M_REQUIRE(at < capacity());
	return m_base[at];
}


inline
ByteStream::Byte&
ByteStream::operator[](unsigned at)
{
	M_REQUIRE(at < capacity());
	return m_base[at];
}


inline
ByteStream::Byte
ByteStream::peek()
{
	if (__builtin_expect(m_getp == m_endp, 0))
		underflow(1);

	return *m_getp;
}


inline
ByteStream::Byte
ByteStream::get()
{
	if (__builtin_expect(m_getp == m_endp, 0))
		underflow(1);

	return *m_getp++;
}


inline
ByteStream::Byte
ByteStream::unsafeGet()
{
	M_REQUIRE(data() < end());
	return *m_getp++;
}


inline
void
ByteStream::get(char* buf, unsigned size)
{
	get(reinterpret_cast<Byte*>(buf), size);
}


inline
void
ByteStream::put(char const* p, unsigned size)
{
	put(reinterpret_cast<Byte const*>(p), size);
}


inline
ByteStream& ByteStream::operator>>(uint8_t& i)
{
	i = get();
	return *this;
}


inline
uint8_t
ByteStream::uint8()
{
	return get();
}


inline
void
ByteStream::put(Byte c)
{
	if (__builtin_expect(m_putp == m_endp, 0))
		overflow(1);

	*m_putp++ = c;
}


inline
ByteStream&
ByteStream::operator<<(uint8_t i)
{
	put(i);
	return *this;
}


inline
void
ByteStream::advance(unsigned n)
{
	if (__builtin_expect(free() < n, 0))
		overflow(n);

	M_REQUIRE(free() >= n);
	m_putp += n;
}


inline
void
ByteStream::skip(unsigned n)
{
	M_REQUIRE(n <= capacity());

	if (__builtin_expect(remaining() < n, 0))
		underflow(n);

	M_REQUIRE(remaining() >= n);
	m_getp += n;
}


inline
void
ByteStream::seekg(unsigned offset)
{
	M_REQUIRE(offset <= capacity());
	m_getp = m_base + offset;
}

} // namespace db

// vi:set ts=3 sw=3:
