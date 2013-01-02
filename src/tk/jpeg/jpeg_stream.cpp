// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "jpeg_stream.h"
#include "jpeg_exception.h"
#include "jpeg_reader.h"

#include <string.h>
#include <stdint.h>
#include <assert.h>

using namespace JPEG;


template <typename T> inline T min(T a, T b) { return a < b ? a : b; }


Stream::Stream(Reader& reader)
	:m_reader(reader)
	,m_state(ProcessUncompressedData)
	,m_eback(m_buffer + 1)
	,m_gptr(0)
	,m_egptr(0)
	,m_endOfBuf(0)
	,m_eos(false)
{
	m_buffer[0] = 0xff;
	m_reader.attach();
}


Stream::~Stream()
{
	m_reader.detach();
}


int
Stream::getInt16()
{
	unsigned char c1 = getByte();
	unsigned char c2 = getByte();

	return (int16_t(c1) << 8) | int16_t(c2);
}


size_t
Stream::fetch(unsigned char* buf, size_t len)
{
	size_t available = ::min(size_t(m_egptr - m_gptr), len);
	size_t n;

	::memcpy(buf, m_gptr, available);
	m_gptr += available;

	while (available < len && (n = underflow()))
	{
		size_t nbytes = ::min(len - available, n);
		::memcpy(buf + available, m_gptr, nbytes);
		m_gptr += nbytes;
		available += nbytes;
	}

	return available;
}


void
Stream::skip(size_t nbytes)
{
	if ((m_gptr += nbytes) > m_egptr)
	{
		if (!m_reader.skip(m_gptr - m_egptr))
			throw Exception("premature end of image data");

		m_gptr = m_egptr;
	}
}


bool
Stream::fetchFromReader()
{
	size_t available = m_reader.read(m_eback, BufSize);

	m_gptr = m_eback;
	m_endOfBuf = m_egptr = m_gptr + available;

	return available > 0;
}


void
Stream::setState(State state)
{
	switch (m_state = state)
	{
		case ProcessCompressedData:
			m_eos = !findStuffByte();
			break;

		case ProcessUncompressedData:
			m_egptr = m_endOfBuf;
			m_eos = false;
			break;
	}
}


size_t
Stream::underflow()
{
	if (m_eos)
		return 0;

	assert(m_gptr == m_egptr);

	if (m_egptr < m_endOfBuf)
	{
		assert(m_state == ProcessCompressedData);

		if (!skipStuffByte())
			return 0;
	}
	else if (!fetchFromReader())
	{
		m_eos = true;
	}
	else if (m_state == ProcessCompressedData)
	{
		findStuffByte();

		if (m_egptr == m_gptr && !skipStuffByte())
			return 0;
	}

	return m_egptr - m_gptr;
}


bool
Stream::findStuffByte()
{
	assert(m_state == ProcessCompressedData);

	unsigned char* p = m_gptr;

	if (p == m_endOfBuf)
	{
		if (!fetchFromReader())
			return false;

		p = m_gptr;
	}

	while (p < m_endOfBuf && *p != 0xff)
		++p;

	m_egptr = p;

	return true;
}


bool
Stream::skipStuffByte()
{
	assert(m_state == ProcessCompressedData);
	assert(m_egptr < m_endOfBuf);
	assert(m_gptr == m_egptr);

	while (true)
	{
		unsigned char* p = m_gptr;

		while (p < m_endOfBuf && *p == 0xff)
			++p;

		if (p < m_endOfBuf)
		{
			if (*p == 0)
			{
				m_gptr = p;
				m_egptr = m_endOfBuf;
				findStuffByte();
				*p = 0xff;

				return true;
			}

			m_gptr = p - 1;
			m_egptr = m_endOfBuf;
			m_eos = true;

			return false;
		}
		else if (!fetchFromReader())
		{
			m_eos = true;
			return false;
		}
	}
}


void
Stream::putbackStuffByte()
{
	if (m_gptr == m_buffer)
		throw Exception("internal error (putbackStuffByte() failed)");

	*--m_gptr = 0xff;
}

// vi:set ts=3 sw=3:
