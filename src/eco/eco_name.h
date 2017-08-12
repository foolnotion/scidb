// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $HeadURL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
// ======================================================================

// ======================================================================
// Copyright: (C) 2014-2017 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _eco_name_included
#define _eco_name_included

#include "m_string.h"
#include "m_vector.h"
#include "m_hash.h"

namespace mstl { class ostream; }

namespace eco {

class Name
{
public:

	static constexpr unsigned Invalid		= unsigned(-1);
	static constexpr unsigned NumEntries	= 6;

	Name();
	Name(char const* s);

	auto operator==(Name const& name) const -> bool;
	auto operator!=(Name const& name) const -> bool;
	auto operator< (Name const& name) const -> bool;

	auto isEmpty() const -> bool;
	auto isEmpty(unsigned level) const -> bool;
	auto hasMark() const -> bool;

	auto size() const -> unsigned;
	auto ref(unsigned level) const -> unsigned;
	auto lastRef() const -> unsigned;
	auto number(unsigned level) const -> unsigned;

	void set(unsigned level, mstl::string const& s);
	void setOpening(Name const& name);
	void setMark();
	void clear(unsigned level);
	void clear();

	auto str(unsigned level) const -> mstl::string const&;

	auto variation() const -> mstl::string;
	auto opening() const -> mstl::string;

	static auto countNames() -> unsigned;
	static auto countStrings() -> unsigned;
	static auto countChars() -> unsigned;
	static auto insert(Name const& name) -> unsigned;
	static void dump(mstl::ostream& strm);
	static auto lookup(unsigned ref) -> Name*;

	static Name const& empty();

private:

	using StringList = mstl::vector<mstl::string>;
	using Lookup = mstl::vector<Name*>;

	void init();

	uint16_t	m_ref[NumEntries];
	uint8_t	m_size;
	uint8_t	m_mark;

	static Name const m_empty;
	static Lookup m_lookup;
	static mstl::hash<mstl::string,unsigned> m_hash;
	static StringList m_strings;
	static unsigned m_numChars;
};

} // namespace eco

#include "eco_name.ipp"

#endif // _eco_name_included

// vi:set ts=3 sw=3:
