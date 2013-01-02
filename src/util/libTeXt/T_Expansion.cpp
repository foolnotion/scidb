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

#include "T_Expansion.h"
#include "T_GenericExpandableToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_ListToken.h"
#include "T_TextToken.h"
#include "T_ReadAgainProducer.h"
#include "T_Messages.h"


using namespace TeXt;


static void
performExpandafter(Environment& env)
{
	TokenP token1(env.getUndefinedToken());
	TokenP token2(env.getExpandableToken());

	switch (token2->type())
	{
		case Token::T_List:
			{
				ListToken* list = static_cast<ListToken*>(token2.get());

				if (!list->isEmpty())
					env.pushProducer(Environment::ProducerP(list->getProducer(token2)));
			}
			break;

		case Token::T_Text:
			{
				TextToken* list = static_cast<TextToken*>(token2.get());

				if (!list->isEmpty())
					env.pushProducer(Environment::ProducerP(list->getProducer(token2)));
			}
			break;

		default:
			{
				env.expand(token2);

				TokenP token3(env.getPendingToken());

				if (token3)
					env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token3))); // MEMORY
			}
			break;
	}

	env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token1))); // MEMORY
}


static void
performNoexpand(Environment& env)
{
	env.putFinalToken(env.getUndefinedToken());
}


static void
performThe(Environment& env)
{
	TokenP token = Expansion::performThe(env);

	if (token)
		env.putUnboundToken(token);
}


TokenP
Expansion::performThe(Environment& env)
{
	TokenP current = env.currentToken();

	while (true)
	{
		TokenP token(env.getFinalToken());
		TokenP clone(token->performThe(env));

		if (clone)
			return clone;

		Messages::errmessage(
				env,
				"You can't use `" + token->meaning() + "' after " + current->name(),
				Messages::Corrigible);
	}

	return TokenP();
}


void
Expansion::doRegister(Environment& env)
{
	env.bindMacro(new GenericExpandableToken("\\expandafter",	::performExpandafter));
	env.bindMacro(new GenericExpandableToken("\\noexpand",		::performNoexpand));
	env.bindMacro(new GenericExpandableToken("\\the",				::performThe));
}

// vi:set ts=3 sw=3:
