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

#include "T_Miscellaneous.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_Environment.h"
#include "T_Messages.h"
#include "T_ReadAgainProducer.h"
#include "T_TextToken.h"
#include "T_ListToken.h"
#include "T_TextConsumer.h"
#include "T_List.h"

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
			return env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token))); // MEMORY

		char c = token->value();

		if (!::isdigit(c))
			return env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token))); // MEMORY

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
			env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token))); // MEMORY
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
									Environment::ProducerP(new ReadAgainProducer(env.numberToken(value)))); // MEMORY
					}
				}
			}
			// fallthru

		default:
			env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token))); // MEMORY
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
	env.putFinalToken(TokenP(new NumberToken(consumer.m_result.size()))); // MEMORY
}


static void
performMap(Environment& env)
{
	TokenP		text		= Miscellaneous::getTextToken(env);
	List::ListP mapping	= List::getListToken(env);

	if (!text || !mapping)
		Messages::errmessage(env, "unterminated map definition", Messages::Incorrigible);

	static_cast<TextToken*>(text.get())->map(env, mapping);
	env.putFinalToken(text);
}


Miscellaneous::TextTokenP
Miscellaneous::getTextToken(Environment& env)
{
	TokenP token = env.getExpandableToken(Environment::AllowNull);
	return token ? TextToken::convert(env, token) : TextTokenP();
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
	env.bindMacro(new GenericExpandableToken("\\tmap",		::performMap));
}

// vi:set ts=3 sw=3:
