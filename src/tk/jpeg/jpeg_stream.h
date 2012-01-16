// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _jpeg_stream_included
#define _jpeg_stream_included

#include "jpeg_exception.h"

#include <stddef.h>

extern "C" { struct Tcl_Channel_; }

namespace JPEG {

class Reader;

class Stream
{
public:

	// types
	enum State
	{
		ProcessCompressedData,
		ProcessUncompressedData,
	};

	// structors
	Stream(Reader& reader);
	~Stream();

	// accessors
	State state() const { return m_state; }

	// modifiers
	void setState(State state);
	void putbackStuffByte();

	unsigned char peekByte()
	{
		if (m_gptr == m_egptr && underflow() < 1)
			throw Exception("premature end of image data");

		return *m_gptr;
	}

	unsigned char getByte()
	{
		if (m_gptr == m_egptr && underflow() < 1)
			throw Exception("premature end of image data");

		return *m_gptr++;
	}

	int readByte()
	{
		if (m_gptr == m_egptr && underflow() < 1)
			return -1;

		return *m_gptr++;
	}

	int getInt16();
	size_t fetch(unsigned char* buf, size_t len);
	void skip(size_t nbytes);

	void get(unsigned char* buf, size_t len)
	{
		if (fetch(buf, len) < len)
			throw Exception("premature end of image data");
	}

private:

	// constants
	static size_t const BufSize = 8192;

	// modifiers
	bool fetchFromReader();
	size_t underflow();

	bool findStuffByte();
	bool skipStuffByte();

	// attributes
	Reader&			m_reader;
	State				m_state;
	unsigned char*	m_eback;
	unsigned char*	m_gptr;
	unsigned char*	m_egptr;
	unsigned char*	m_endOfBuf;
	bool				m_eos;
	unsigned char	m_buffer[BufSize + 1];
};

} // namespace JPEG

#endif // _jpeg_stream_included

// vi:set ts=3 sw=3:
