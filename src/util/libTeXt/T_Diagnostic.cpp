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

#include "T_Diagnostic.h"
#include "T_GenericFinalToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_Expansion.h"
#include "T_Messages.h"

#include "m_auto_ptr.h"
#include "m_string.h"
#include "m_assert.h"


using namespace TeXt;


static void
performShow(Environment& env)
{
	TokenP unresolved = env.getUndefinedToken();
	env.putUnboundToken(unresolved);
	TokenP resolved = env.getExpandableToken();

	mstl::string meaning("> ");

	if (!unresolved->isResolved())
	{
		meaning += unresolved->name();
		meaning += "=";
	}

	meaning += resolved->meaning();
	meaning += ".\n";
//	meaning += env.backtrace();

	Messages::message(env, meaning);
}


static void
performShowthe(Environment& env)
{
	TokenP token(Expansion::performThe(env));

	if (token)
	{
		mstl::string text("> ");
		text += token->description(env);
		text += ".\n";
//		text += env.backtrace();

		Messages::message(env, text);
	}
}


void
Diagnostic::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken("\\show",		::performShow));
	env.bindMacro(new GenericFinalToken("\\showthe",	::performShowthe));
}

// vi:set ts=3 sw=3:
