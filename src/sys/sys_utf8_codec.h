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

#ifndef _sys_utf8_codec_included
#define _sys_utf8_codec_included

#include "m_string.h"
#include "m_list.h"

extern "C" { struct Tcl_Encoding_; }

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
	bool error() const;
	unsigned unknown() const;

	mstl::string const& encoding() const;

	bool isConvertibleToLatin1(mstl::string const& s) const;

	bool fromUtf8(mstl::string& s);
	bool fromUtf8(mstl::string const& in, mstl::string& out);
	bool toUtf8(mstl::string& s);
	bool toUtf8(mstl::string const& in, mstl::string& out);

	bool convertFromUtf8(mstl::string const& in, mstl::string& out);
	bool convertToUtf8(mstl::string const& in, mstl::string& out);
	void convertFromDOS(mstl::string const& in, mstl::string& out);
	void convertFromWindows(mstl::string const& in, mstl::string& out);

	unsigned forceValidUtf8(mstl::string& str,
									mstl::string const& replacement = mstl::string::empty_string);

	void reset();
	void reset(mstl::string const& encoding);
	void setError(bool flag = true);
	void setUnknown(unsigned count);

	static mstl::string const& automatic();
	static mstl::string const& utf8();
	static mstl::string const& latin1();
	static mstl::string const& windows();
	static mstl::string const& dos();
	static mstl::string const& ascii();

	static bool matchAscii(mstl::string const& utf8, mstl::string const& ascii, bool noCase = false);
	static bool matchGerman(mstl::string const& utf8, mstl::string const& ascii, bool noCase = false);
	static bool fitsRegion(mstl::string const& s, unsigned region);
	static unsigned removeInvalidSequences(mstl::string& str,
														mstl::string const& replacement = mstl::string::empty_string);
	static void mapFromGerman(mstl::string const& name, mstl::string& result);
	static void makeShortName(mstl::string const& name, mstl::string& result);
	static unsigned firstCharToUpper(mstl::string& name);
	static unsigned firstCharToUpper(mstl::string const& name, mstl::string& result);
	static mstl::string const& convertToNonDiacritics(	unsigned region,
																		mstl::string const& s,
																		mstl::string& buffer);
	static mstl::string const& convertToShortNonDiacritics(	unsigned region,
																				mstl::string const& s,
																				mstl::string& buffer);
	static unsigned findRegion(mstl::string const& name);
	static bool checkEncoding(mstl::string const& name);
	static unsigned getEncodingList(EncodingList& result);

private:

	enum { Other, UTF8, DOS, Windows };

	void setupType();

	struct Tcl_Encoding_*	m_codec;
	mstl::string				m_buf;
	mstl::string				m_encoding;
	unsigned						m_unknown;
	bool							m_error;
	unsigned						m_type;
};

} // namespace utf8
} // namespace sys

#include "sys_utf8_codec.ipp"

#endif // _sys_utf8_codec_included

// vi:set ts=3 sw=3:
