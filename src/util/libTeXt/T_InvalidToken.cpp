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

#include "T_InvalidToken.h"
#include "T_Messages.h"

#include "m_assert.h"

using namespace TeXt;


InvalidToken::InvalidToken(unsigned char c)
	:m_value(c)
{
}


Token::Type
InvalidToken::type() const
{
	return T_Invalid;
}


mstl::string
InvalidToken::name() const
{
	return mstl::string(1, m_value);
}


mstl::string
InvalidToken::meaning() const
{
	return "invalid character " + name();
}


Value
InvalidToken::value() const
{
	return m_value;
}


void
InvalidToken::perform(Environment& env)
{
	mstl::string msg;

	if (m_value == ParamChar)
		msg = "You can't use macro parameter # in text mode";
	else
		msg = "Invalid character " + name();

	Messages::errmessage(env, msg, Messages::Incorrigible);
}

// vi:set ts=3 sw=3:
