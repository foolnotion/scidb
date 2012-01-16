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

#include "T_ActiveToken.h"
#include "T_Environment.h"

#include "m_assert.h"

using namespace TeXt;


static void foo(Environment&) {}


ActiveToken::ActiveToken(unsigned char c, Func const& func)
	:m_value(c)
	,m_func(func)
{
}


ActiveToken::ActiveToken(unsigned char c, TokenP const& macro)
	:m_value(c)
	,m_func(::foo)
	,m_macro(macro)
{
}


bool
ActiveToken::isBound() const
{
	return false;
}


bool
ActiveToken::isEqualTo(Token const& token) const
{
	return &token == this;
}


RefID
ActiveToken::refID() const
{
	return m_value;
}


Token::Type
ActiveToken::type() const
{
	return T_Active;
}


mstl::string
ActiveToken::name() const
{
	return mstl::string(1, m_value);
}


void
ActiveToken::bind(Environment& env)
{
	if (!m_macro)
		m_func(env);
	else if (m_macro->type() == T_Macro)
		env.performMacro(m_macro);
	else
		env.putUnboundToken(m_macro);
}


void
ActiveToken::resolve(Environment&)
{
	M_RAISE("unexpected invocation");
}


void
ActiveToken::expand(Environment& env)
{
	env.putUnboundToken(env.lookupMacro(Token::T_Relax));
}


void
ActiveToken::execute(Environment&)
{
	M_RAISE("unexpected invocation");
}

// vi:set ts=3 sw=3:
