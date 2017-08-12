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

#ifndef _eco_text_reader_included
#define _eco_text_reader_included

#include "eco_id.h"
#include "eco_reader.h"

namespace mstl { class istream; }

namespace eco {

class TextReader : public Reader
{
public:

	static constexpr unsigned SkipInsertedLines = 1 << 0;

	TextReader(mstl::istream& strm, unsigned flags = 0);

	auto readLine(
		db::MoveLine& line,
		Transitions& transitions,
		Name& name,
		mstl::string& prologue,
		mstl::string& epilogue,
		char& sign,
		Node* root) -> Id override;

private:

	mstl::istream&	m_strm;
	unsigned			m_flags;
	Id					m_lastId;
	mstl::string	m_comment;
};

} // namespace eco

#endif // _eco_text_reader_included

// vi:set ts=3 sw=3:
