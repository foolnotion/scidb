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

#include "T_Char.h"
#include "T_GenericExpandableToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_Messages.h"

#include "m_assert.h"


using namespace TeXt;


static bool
verifyToken(Environment& env, TokenP const& token, char const* message)
{
	if (token->type() == Token::T_Ascii || token->type() == Token::T_Number)
		return true;

	Messages::errmessage(env, message, Messages::Corrigible);
	return false;
}


static bool
verifyCodeToken(Environment& env, TokenP const& token)
{
	return verifyToken(env, token, "Missing character");
}


static bool
verifyCharToken(Environment& env, TokenP const& token)
{
	return verifyToken(env, token, "Missing number");
}


static void
performChar(Environment& env)
{
	TokenP token = env.getFinalToken(::verifyCharToken);

	switch (token->type())
	{
		case Token::T_Ascii:		env.putUnboundToken(token); break;
		case Token::T_Number:	env.putUnboundToken(env.asciiToken(token->value() % 256)); break;
		default:						M_RAISE("unexpected invocation");
	}
}


static void
performCode(Environment& env)
{
	TokenP token = env.getFinalToken(::verifyCodeToken);

	switch (token->type())
	{
		case Token::T_Number:	env.putUnboundToken(token); break;
		case Token::T_Ascii:		env.putUnboundToken(env.numberToken(token->value())); break;
		default:						M_RAISE("unexpected invocation");
	}
}


void
Char::doRegister(Environment& env)
{
	env.bindMacro(new GenericExpandableToken("\\char",	::performChar));
	env.bindMacro(new GenericExpandableToken("\\code",	::performCode));
}

// vi:set ts=3 sw=3:
