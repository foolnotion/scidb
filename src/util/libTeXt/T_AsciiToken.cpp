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

#include "T_AsciiToken.h"
#include "T_Environment.h"

#include <ctype.h>

using namespace TeXt;


AsciiToken::AsciiToken(unsigned char c)
	:m_value(c)
{
}


RefID
AsciiToken::refID() const
{
	return m_value;
}


Token::Type
AsciiToken::type() const
{
	return T_Ascii;
}


mstl::string
AsciiToken::name() const
{
	if (m_value >= ' ')
		return mstl::string(1, m_value);

	char c = m_value;

	if (c == '\n')
		c = '\r';

	return mstl::string("^^") += c + 64;
}


Value
AsciiToken::value() const
{
	return m_value;
}


mstl::string
AsciiToken::meaning() const
{
	mstl::string result;

	if (m_value == ' ')
		result = "blank space";
	else if (m_value == '\r' || m_value == '\n')
		result = "linefeed";
	else if (::isprint(m_value))
		(result += "the character ") += m_value;
	else
		(result += "character code ") += mstl::string::cast(m_value);

	return result;
}


void
AsciiToken::traceCommand(Environment& env) const
{
	if (::isspace(env.associatedValue(T_Ascii)) != ::isspace(m_value))
		Super::traceCommand(env);

	env.associate(T_Ascii, m_value);
}


void
AsciiToken::perform(Environment& env)
{
	env.filter().put(env, m_value);
}


TokenP
AsciiToken::performThe(Environment& env)
{
	return env.asciiToken(m_value);
}

// vi:set ts=3 sw=3:
