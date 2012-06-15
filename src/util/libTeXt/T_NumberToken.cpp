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

#include "T_NumberToken.h"
#include "T_Environment.h"

#include "m_string.h"
#include "m_assert.h"

using namespace TeXt;


NumberToken::NumberToken(Value value)
	:m_value(value)
{
}


bool
NumberToken::isNumber() const
{
	return true;
}


Token::Type
NumberToken::type() const
{
	return T_Number;
}


mstl::string
NumberToken::name() const
{
	return "\\" + mstl::string::cast(m_value);
}


mstl::string
NumberToken::meaning() const
{
	return "the number " + mstl::string::cast(m_value);
}


mstl::string
NumberToken::text() const
{
	return mstl::string::cast(m_value);
}


mstl::string
NumberToken::description(Environment&) const
{
	return mstl::string::cast(m_value);
}


Value
NumberToken::value() const
{
	return m_value;
}


RefID
NumberToken::refID() const
{
	M_RAISE("unexpected invocation");
}


TokenP
NumberToken::performThe(Environment& env) const
{
	return env.numberToken(m_value);
}


void
NumberToken::perform(Environment& env)
{
	env.filter().put(env, m_value);
}

// vi:set ts=3 sw=3:
