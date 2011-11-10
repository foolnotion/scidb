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

#include "T_UserInput.h"

#include "m_string.h"


using namespace TeXt;


UserInput::UserInput(mstl::string const& text)
	:m_text(text)
{
}


UserInput::Source
UserInput::source() const
{
	return Producer::Insert;
}


bool
UserInput::readNextLine(mstl::string& result)
{
	if (m_text.empty())
		return false;

	mstl::string::size_type n = m_text.find('\n');

	result.assign(m_text, 0, n);
	m_text.erase(mstl::string::size_type(0), n);

	return true;
}

// vi:set ts=3 sw=3:
