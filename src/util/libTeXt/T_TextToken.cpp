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

#include "T_TextToken.h"
#include "T_Environment.h"

#include "m_assert.h"

using namespace TeXt;


TextToken::TextToken()
{
}


TextToken::TextToken(mstl::string const& str)
	:m_str(str)
{
}


bool
TextToken::isEmpty() const
{
	return m_str.empty();
}


bool
TextToken::isEqualTo(Token const& token) const
{
	M_REQUIRE(dynamic_cast<TextToken const*>(&token));
	return m_str == static_cast<TextToken const&>(token).m_str;
}


RefID
TextToken::refID() const
{
	M_RAISE("unexpected invocation");
}


Token::Type
TextToken::type() const
{
	return T_Text;
}


mstl::string
TextToken::name() const
{
	return m_str;
}


mstl::string
TextToken::meaning() const
{
	return "the string \"" + m_str + "\"";
}


void
TextToken::perform(Environment& env)
{
	env.filter().put(env, m_str);
}


TokenP
TextToken::performThe(Environment& env) const
{
	return TokenP(new TextToken(m_str)); // MEMORY
}

// vi:set ts=3 sw=3:
