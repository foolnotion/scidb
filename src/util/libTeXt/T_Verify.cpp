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

#include "T_Verify.h"
#include "T_Token.h"
#include "T_Environment.h"
#include "T_Messages.h"

using namespace TeXt;


static void
cantUseMessage(Environment& env, TokenP const& token)
{
	Messages::errmessage(
		env,
		"You can't use `" + token->meaning() + "' after " + env.currentToken()->name(),
		Messages::Corrigible);
}


bool
TeXt::Verify::controlSequenceToken(Environment& env, TokenP const& token)
{
	switch (token->type())
	{
		case Token::T_Ascii:
		case Token::T_Undefined:
			return true;

		case Token::T_Variable:
			return env.contextMacro();

		default:
			Messages::errmessage(env, "Missing control sequence", Messages::Corrigible);
			break;
	}

	return false;
}


bool
TeXt::Verify::finalToken(Environment& env, TokenP const& token)
{
	if (token->type() == Token::T_Number)
		return true;

	cantUseMessage(env, token);
	return false;
}


bool
TeXt::Verify::unresolvedToken(Environment& env, TokenP const& token)
{
	if (!token->isResolved())
		return true;

	cantUseMessage(env, token);
	return false;
}


bool
TeXt::Verify::numericalToken(Environment& env, TokenP const& token)
{
	if (token->type() == Token::T_Number || token->type() == Token::T_Ascii)
		return true;

	cantUseMessage(env, token);
	return false;
}


bool
TeXt::Verify::numberToken(Environment& env, TokenP const& token)
{
	if (token->type() == Token::T_Number)
		return true;

	Messages::errmessage(env, "Missing number", Messages::Corrigible);
	return false;
}

// vi:set ts=3 sw=3:
