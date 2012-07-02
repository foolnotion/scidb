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

#ifndef _sys_utf8_codec_included
#define _sys_utf8_codec_included

#include "m_string.h"
#include "m_list.h"

extern "C" { struct Tcl_Encoding_; };

namespace sys {
namespace utf8 {

class Codec
{
public:

	typedef mstl::list<mstl::string> EncodingList;

	Codec(mstl::string const& encoding);
	~Codec();

	bool hasEncoding() const;
	bool isUtf8() const;
	bool failed() const;

	mstl::string const& encoding() const;

	bool isLatin1(mstl::string const& s) const;

	bool fromUtf8(mstl::string& s);
	bool fromUtf8(mstl::string const& in, mstl::string& out);
	bool toUtf8(mstl::string& s);
	bool toUtf8(mstl::string const& in, mstl::string& out);

	bool convertFromUtf8(mstl::string const& in, mstl::string& out);
	bool convertToUtf8(mstl::string const& in, mstl::string& out);

	void forceValidUtf8(mstl::string& str);

	void reset();
	void reset(mstl::string const& encoding);
	void setFailed(bool flag = true);

	static mstl::string const& automatic();
	static mstl::string const& utf8();
	static mstl::string const& latin1();
	static mstl::string const& windows();
	static mstl::string const& ascii();

	static bool is7BitAscii(mstl::string const& s);
	static bool is7BitAscii(char const* s, unsigned nbytes);
	static bool matchAscii(mstl::string const& utf8, mstl::string const& ascii);
	static bool matchGerman(mstl::string const& utf8, mstl::string const& ascii);
	static bool fitsRegion(mstl::string const& s, unsigned region);
	static unsigned removeOverlongSequences(char* s, unsigned size);
	static void mapFromGerman(mstl::string const& name, mstl::string& result);
	static void makeShortName(mstl::string const& name, mstl::string& result);
	static unsigned firstCharToUpper(mstl::string& name);
	static unsigned firstCharToUpper(mstl::string const& name, mstl::string& result);
	static mstl::string const& convertToNonDiacritics(	unsigned region,
																		mstl::string const& s,
																		mstl::string& buffer);
	static bool checkEncoding(mstl::string const& name);
	static unsigned getEncodingList(EncodingList& result);

private:

	struct Tcl_Encoding_*	m_codec;
	mstl::string				m_buf;
	mstl::string				m_encoding;
	bool							m_failed;
	bool							m_isUtf8;
};

} // namespace utf8
} // namespace sys

#include "sys_utf8_codec.ipp"

#endif // _sys_utf8_codec_included

// vi:set ts=3 sw=3:
