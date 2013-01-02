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

#include "T_TextConsumer.h"

#include "m_string.h"

using namespace TeXt;


TextConsumer::TextConsumer(mstl::string& result, Consumer* next) :m_result(result), m_next(next) {}


void TextConsumer::put(unsigned char c)			{ m_result += c; }
void TextConsumer::put(mstl::string const& s)	{ m_result += s; }


void
TextConsumer::out(mstl::string const& s)
{
	if (m_next)
		m_next->out(s);
}


void
TextConsumer::log(mstl::string const& s, bool copyToOut)
{
	if (m_next)
		m_next->log(s, copyToOut);
}

// vi:set ts=3 sw=3:
