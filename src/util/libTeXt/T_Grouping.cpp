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

#include "T_Grouping.h"
#include "T_GenericFinalToken.h"
#include "T_Environment.h"
#include "T_Messages.h"

#include "m_utility.h"

using namespace TeXt;


namespace {

struct Monitor
{
	Monitor(TokenP token) :fToken(token) {}
	~Monitor() { fToken->setUplevel(0); }

	TokenP fToken;
};

} // namespace


static bool
verifyGlobalToken(Environment& env, TokenP const& token)
{
	if (TokenP(token)->setUplevel(0))
		return true;

	Messages::errmessage(env, "You can't use a prefix with " + token->name(), Messages::Corrigible);
	return false;
}


static void
performGlobal(Environment& env)
{
	Monitor monitor(env.getFinalToken(::verifyGlobalToken));
	env.execute(monitor.fToken);
}


static void
performUplevel(Environment& env)
{
	TokenP	token		= env.getFinalToken();
	Value		nlevels	= 1;

	if (token->isNumber())
	{
		nlevels = token->value();
		token = env.getFinalToken();
	}

	Monitor monitor(token);
	token->setUplevel(nlevels);
	env.execute(monitor.fToken);
}


static void
performUpToken(Environment& env)
{
	TokenP	token		= env.getUndefinedToken();
	unsigned	nlevels	= 1;

	if (token->isNumber())
	{
		nlevels = token->value();
		token = env.getUndefinedToken();
	}

	if (token->isFinal())
	{
		Messages::errmessage(
			env,
			"You can't use a " + token->meaning() + " after " + env.currentToken()->name(),
			Messages::Incorrigible);
	}
	else if ((nlevels = mstl::min(env.groupLevel(), nlevels)))
	{
		env.upToken(token->refID(), nlevels);
	}
}


void
Grouping::performBegingroup(Environment& env)
{
	env.pushGroup();
	env.associate(Token::T_LeftBrace, Value(m_begingroup));
}


void
Grouping::performEndgroup(Environment& env)
{
	if (env.groupLevel() == 0)
	{
		Messages::errmessage(env,
									"Too many " + env.currentToken()->name() + "'s",
									Messages::Incorrigible);
	}
	else if (env.associatedValue(Token::T_LeftBrace) != m_begingroup)
	{
		Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);
	}
	else
	{
		env.popGroup();
	}
}


void
Grouping::doRegister(Environment& env)
{
	m_begingroup =
	bindMacro(env, new GenericFinalToken("\\begingroup",	Func(&Grouping::performBegingroup, this)));
	env.bindMacro(new GenericFinalToken("\\endgroup",		Func(&Grouping::performEndgroup, this)));
	env.bindMacro(new GenericFinalToken("\\uptoken", 		::performUpToken));
	env.bindMacro(new GenericFinalToken("\\uplevel", 		::performUplevel));
	env.bindMacro(new GenericFinalToken("\\global",			::performGlobal));
}

// vi:set ts=3 sw=3:
