// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "m_istream.h"
#include "m_string.h"
#include "m_stdio.h"
#include "m_assert.h"

#include <stdlib.h>
#include <string.h>

using namespace mstl;


istream::istream()
	:m_data(0)
	,m_size(0)
{
}


istream::~istream() throw()
{
	::free(m_data);
}


istream&
istream::get(char& c)
{
	int ch = fgetc(m_fp);

	if (ch == EOF)
		setstate(feof(m_fp) ? failbit | eofbit : badbit);
	else
		c = ch;

	return *this;
}


istream&
istream::getline(char* buf, size_t n)
{
	switch (n)
	{
		case 0:
			setstate(failbit);
			break;

		case 1:
			buf[0] = '\0';

			if (!fgets(buf, n, m_fp))
				setstate(feof(m_fp) ? failbit | eofbit : badbit);
			else if (buf[0] == '\n')
				buf[0] = '\0';
			else
				setstate(failbit);
			break;

		default:
			buf[0] = '\0';
			buf[n - 1] = '\n';

			if (!fgets(buf, n, m_fp))
				setstate(feof(m_fp) ? failbit | eofbit : badbit);
			else if (buf[0] == '\n')
				buf[0] = '\0';
			else if (buf[n - 1] == '\0' && buf[n - 2] != '\n')
				setstate(failbit);
			break;
	}

	return *this;
}


istream&
istream::getline(string& buf)
{
	long size = ::getline(&m_data, &m_size, m_fp);

	if (size == -1)
	{
		setstate(feof(m_fp) ? failbit | eofbit : badbit);
	}
	else if (size == 0)
	{
		buf.clear();
	}
	else if (m_data[size - 1] == '\n')
	{
		m_data[size - 1] = '\0';
		buf.hook(m_data, size - 1);
	}
	else
	{
		buf.hook(m_data, size);
	}

	return *this;
}


istream&
istream::get(string& buf)
{
	long size = ::getdelim(&m_data, &m_size, '\0', m_fp);

	if (size == -1)
	{
		setstate(feof(m_fp) ? failbit | eofbit : badbit);
	}
	else if (size == 0)
	{
		buf.clear();
	}
	else if (m_data[size - 1] == '\0')
	{
		m_data[size - 1] = '\0';
		buf.hook(m_data, size - 1);
	}
	else
	{
		buf.hook(m_data, size);
	}

	return *this;
}


bool
istream::eof()
{
	if (ios_base::eof())
		return true;

	if (!feof(m_fp))
		return false;

	setstate(eofbit);
	return true;
}


istream&
istream::read(char* buf, size_t n)
{
	size_t bytes_read = fread(buf, 1, n, m_fp);

	if (bytes_read < n)
		setstate(feof(m_fp) ? failbit | eofbit : badbit);

	return *this;
}


size_t
istream::readsome(char* buf, size_t n)
{
	if (eof())
		return 0;

	size_t bytes_read = fread(buf, 1, n, m_fp);

	if (bytes_read < n && !feof(m_fp))
		setstate(badbit);

	return bytes_read;
}


istream&
istream::ignore(unsigned long n, int delim)
{
	if (delim != traits::eof || fseek(m_fp, n, SEEK_CUR) != 0)
	{
		while (n--)
		{
			if (fgetc(m_fp) == delim)
				return *this;
		}
	}

	return *this;
}


int
istream::get()
{
	return fgetc(m_fp);
}


int
istream::peek()
{
	int c = fgetc(m_fp);

	if (c != EOF)
		::ungetc(c, m_fp);

	return c;
}


istream&
istream::putback(char c)
{
	if (::ungetc(c, m_fp) == EOF)
		setstate(failbit);

	return *this;
}


istream&
istream::unget()
{
	if (fseek(m_fp, -1, SEEK_CUR) == -1)
		setstate(failbit);

	return *this;
}


unsigned long
istream::tellg()
{
	return ftell(m_fp);
}


istream&
istream::seekg(unsigned long offset)
{
	if (fseek(m_fp, offset, SEEK_CUR) == -1)
		setstate(failbit);

	return *this;
}


istream&
istream::seekg(long offset, seekdir dir)
{
	if (fseek(m_fp, offset, fdir(dir)) == -1)
		setstate(failbit);

	return *this;
}


int64_t
istream::size() const
{
	return -1;
}

// vi:set ts=3 sw=3:
