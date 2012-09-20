// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_TextProducer.h"
#include "T_Environment.h"
#include "T_Token.h"

using namespace TeXt;


TextProducer::TextProducer(mstl::string const& text)
	:m_text(text)
	,m_pos(m_text.begin())
{
}


Producer::Source
TextProducer::source() const
{
	return Text;
}


bool
TextProducer::finished() const
{
	return m_pos == m_text.end();
}


mstl::string
TextProducer::currentDescription() const
{
	return m_text.substr(m_text.begin(), m_pos);
}


TokenP
TextProducer::next(Environment& env)
{
	return m_pos == m_text.end() ? TokenP() : env.asciiToken(*m_pos++);
}


bool
TextProducer::reset()
{
	 m_pos = m_text.begin();
	 return true;
}

// vi:set ts=3 sw=3:
