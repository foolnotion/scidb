// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _mstl_match_included
#define _mstl_match_included

#include "m_string.h"

namespace mstl {

class pattern
{
public:

	pattern();
	pattern(mstl::string const& pattern);
	pattern(char const* s, char const* e);

	bool is_ascii() const;
	bool is_utf8() const;
	bool match_any() const;
	bool match_none() const;

	bool match(char const* s, char const* e) const;
	bool match(string const& s) const;
	bool match_ignore_case(char const* s, char const* e) const;
	bool match_ignore_case(string const& s) const;

	char const* search(char const* s, char const* e) const;
	char const* search(string const& s) const;
	char const* search_ignore_case(char const* s, char const* e) const;
	char const* search_ignore_case(string const& s) const;

private:

	string	m_pattern;
	unsigned	m_min_length;
	bool		m_is_plain;
	bool		m_is_ascii;
};

} // namespace mstl

#include "m_match.ipp"

#endif // _mstl_match_included

// vi:set ts=3 sw=3:
