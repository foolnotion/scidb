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

#ifndef _mstl_istream_included
#define _mstl_istream_included

#include "m_ios.h"

namespace mstl {

class string;

class istream : virtual public ios_base
{
public:

	struct traits { static const int eof = -1; };

	istream();
	~istream() throw();

	istream& get(char& c);
	istream& get(string& buf);
	istream& getline(char* buf, size_t size);
	istream& getline(string& buf);
	istream& read(char* buf, size_t size);
	istream& read(unsigned char* buf, size_t size);
	istream& seek_and_read(uint64_t pos, unsigned char* buf, size_t size);
	istream& ignore(unsigned long n, int delim = traits::eof);

	size_t readsome(char* buf, size_t size);
	size_t readsome(unsigned char* buf, size_t size);

	virtual int64_t size() const;
	virtual uint64_t goffset();

	bool eof();

	int get();
	int peek();

	istream& putback(char c);
	istream& unget();

	uint64_t tellg();
	istream& seekg(uint64_t offset);
	istream& seekg(int64_t, seekdir dir);

private:

	istream(istream const&);
	istream& operator=(istream const&);

	char*		m_data;
	size_t	m_size;
};

} // namespace mstl

#include "m_istream.ipp"

#endif // _mstl_istream_included

// vi:set ts=3 sw=3:
