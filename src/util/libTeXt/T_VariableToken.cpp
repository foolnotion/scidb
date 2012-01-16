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

#include "T_VariableToken.h"
#include "T_Environment.h"
#include "T_Messages.h"

#include "m_assert.h"
#include "m_string.h"

using namespace TeXt;


VariableToken::VariableToken(mstl::string const& name, RefID id)
	:UnboundToken(name, id)
	,m_level(-1)
{
	M_REQUIRE(!name.empty());
	M_REQUIRE(name[0] == VarChar);
}


bool
VariableToken::isBound() const
{
	return m_macro;
}


bool
VariableToken::isResolved() const
{
	return false;
}


Token::Type
VariableToken::type() const
{
	return T_Variable;
}


Value
VariableToken::value() const
{
	static_assert((sizeof(Value) >= sizeof(m_refID)), "illegal return type");
	return m_refID;
}


mstl::string
VariableToken::name() const
{
	mstl::string::size_type n = m_name.rfind(Token::ParamChar);
	return n == mstl::string::npos ? m_name : m_name.substr(0, n);
}


mstl::string
VariableToken::meaning() const
{
	mstl::string s("undefined(");

	if (m_macro)
	{
		s.append("bound to ");
		s.append(m_macro->name());
	}
	else
	{
		s.append("<unbound>");
	}

	s.append(")");

	return s;
}


void
VariableToken::bind(Environment& env)
{
	if (m_name.find_first_not_of(VarChar) > env.nestingLevel())
	{
		env.putUnboundToken(env.currentToken());
	}
	else if (!env.contextMacro())
	{
		Messages::errmessage(env, "Illegal variable", Messages::Incorrigible);
	}
	else if (!m_macro)
	{
		mstl::string	name(m_name);
		unsigned			context = m_level == -1 ? env.contextLevel() : m_level;

		name += Token::ParamChar;
		name.format("%u", context);
		env.putUnboundToken(env.newVariableToken(name, env.contextMacro()));
	}
}


void
VariableToken::resolve(Environment& env)
{
	unsigned level = m_name.find_first_not_of(VarChar);

	if (level > env.nestingLevel())
	{
		env.putUnboundToken(env.currentToken());
	}
	else if (!m_macro)
	{
		Messages::errmessage(env, "Illegal variable", Messages::Incorrigible);
	}
	else
	{
		TokenP token = env.lookupVariable(m_refID, level);

		if (!token)
			token = env.currentToken();

		env.putUnboundToken(token);
	}
}


void
VariableToken::expand(Environment& env)
{
	mstl::string msg;

	if (m_macro)
	{
		msg.append("Undefined variable in definition of ");
		msg.append(m_macro->name());
	}
	else
	{
		msg.append("Illegal variable");
	}

	Messages::errmessage(env, msg, Messages::Incorrigible);
}


void
VariableToken::fixLevel(unsigned level)
{
	m_level = level;
}


void
VariableToken::setup(TokenP const& macro)
{
	m_macro = macro;
}

// vi:set ts=3 sw=3:
