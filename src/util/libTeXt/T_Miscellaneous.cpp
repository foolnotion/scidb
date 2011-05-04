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

#include "T_Miscellaneous.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_Environment.h"
#include "T_Messages.h"
#include "T_ReadAgainProducer.h"
#include "T_TextToken.h"
#include "T_ListToken.h"
#include "T_TextConsumer.h"

#include "m_limits.h"

#include <ctype.h>


using namespace TeXt;


namespace {

struct MyConsumer
{
	typedef Environment::ConsumerP ConsumerP;

	MyConsumer(Environment& env)
		:m_env(env)
		,m_consumer(env.getConsumer())
	{
		env.setConsumer(ConsumerP(new TextConsumer(m_result, m_consumer.get())));
	}

	~MyConsumer()
	{
		m_env.setConsumer(m_consumer);
	}

	Environment&	m_env;
	mstl::string 	m_result;
	ConsumerP		m_consumer;
};

} // namespace


static void
readNumber(Environment& env, BigValue& value)
{
	static BigValue const Min = mstl::numeric_limits<Value>::min();
	static BigValue const Max = mstl::numeric_limits<Value>::max();

	Environment::Nullability nullability = Environment::ExcludeNull;

	while (true)
	{
		TokenP token = env.getFinalToken(nullability);

		if (!token || token->type() != Token::T_Ascii)
			return env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token)));

		char c = token->value();

		if (!::isdigit(c))
			return env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token)));

		value *= 10;
		value += c - '0';

		if (Min > value || value > Max)
			Messages::errmessage(env, "Arithmetic overflow", Messages::Incorrigible);

		nullability = Environment::AllowNull;
	}
}


static void
performNumber(Environment& env)
{
	TokenP token = env.getFinalToken();

	switch (token->type())
	{
		case Token::T_Number:
			env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token)));
			break;

		case Token::T_Ascii:
			{
				char c = token->value();

				if (::isdigit(c) || c == '-' || c == '+')
				{
					if (::isdigit(c))
						env.putFinalToken(token);

					BigValue value = mstl::numeric_limits<BigValue>::min();

					readNumber(env, value);

					if (value != mstl::numeric_limits<BigValue>::min())
					{
						if (c == '-')
							value = - value;

						return env.pushProducer(
									Environment::ProducerP(new ReadAgainProducer(env.numberToken(value))));
					}
				}
			}
			// fallthru

		default:
			env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token)));
			Messages::errmessage(env, "Missing number, treated as zero", Messages::Corrigible);
			break;
	}
}


static void
performText(Environment& env)
{
	TokenP token = Miscellaneous::getTextToken(env);

	if (!token)
		Messages::errmessage(env, "unterminated text definition", Messages::Incorrigible);

	env.putFinalToken(token);
}


static void
performBye(Environment& env)
{
	env.terminateProduction();
}


static void
performCompare(Environment& env)
{
	Value value1 = env.getFinalToken()->value();
	Value value2 = env.getFinalToken()->value();
	Value result = 0;

	if (value1 < value2)
		result = -1;
	else if (value1 > value2)
		result = 1;

	env.putUnboundToken(env.numberToken(result));
}


static void
performUse(Environment& env)
{
	TokenP			token	= env.getUndefinedToken();
	mstl::string	name;

	if (token->type() == Token::T_Undefined)
	{
		name = token->name();

		if (!name.empty() && name[0] == Token::EscapeChar)
			name.erase(name.begin());
	}
	else
	{
		env.putUnboundToken(token);
		env.perform(env.getExpandableToken(), name);
	}

	if (!env.usePackage(name))
		Messages::errmessage(env, "Unknown package '" + name + "'", Messages::Incorrigible);
}


static void
performContext(Environment& env)
{
	env.putFinalToken(env.numberToken(env.contextLevel()));
}


static void
performLength(Environment& env)
{
	MyConsumer consumer(env);
	env.perform(env.getExpandableToken());
	env.putFinalToken(TokenP(new NumberToken(consumer.m_result.size())));
}


Miscellaneous::TextTokenP
Miscellaneous::getTextToken(Environment& env)
{
	TokenP token = env.getUndefinedToken(Environment::AllowNull);

	if (token)
	{
		switch (token->type())
		{
			case Token::T_Text:
				// no action
				break;

			case Token::T_Ascii:
				token.reset(new TextToken(token->name()));
				break;

			case Token::T_Number:
				token.reset(new TextToken(token->description(env)));
				break;

			default:
				switch (token->type())
				{
					case Token::T_List:			token = token->performThe(env); break;
					case Token::T_LeftBrace:	token.reset(new ListToken(env)); break;
					default:							token.reset(new ListToken(token)); break;
				}
				static_cast<ListToken*>(token.get())->flatten();
				token.reset(new TextToken(token->description(env)));
				break;
		}
	}

	return token;
}


void
Miscellaneous::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken("\\bye", ::performBye));
	env.bindMacro(new GenericFinalToken("\\use", ::performUse));

	env.bindMacro(new GenericExpandableToken("\\number",	::performNumber));
	env.bindMacro(new GenericExpandableToken("\\text",		::performText));
	env.bindMacro(new GenericExpandableToken("\\context",	::performContext));
	env.bindMacro(new GenericExpandableToken("\\compare",	::performCompare));
	env.bindMacro(new GenericExpandableToken("\\length",	::performLength));
}

// vi:set ts=3 sw=3:
