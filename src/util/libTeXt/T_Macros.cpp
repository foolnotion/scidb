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

#include "T_Macros.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_GenericAssignmentToken.h"
#include "T_MacroToken.h"
#include "T_ParameterToken.h"
#include "T_VariableToken.h"
#include "T_ListToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_ReadAgainProducer.h"
#include "T_TextConsumer.h"
#include "T_Messages.h"
#include "T_Verify.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_string.h"
#include "m_vector.h"
#include "m_algorithm.h"

using namespace TeXt;


static mstl::string const Csname("\\csname");
static mstl::string const Endcsname("\\endcsname");


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


struct PopToken
{
	virtual ~PopToken() {}
	virtual TokenP operator()(Environment& env) const = 0;
};


struct PopUnboundToken : public PopToken
{
	TokenP operator()(Environment& env) const
	{
		TokenP token = env.getUnboundToken();

		if (token->type() == Token::T_Parameter)
		{
			env.bind(token);
			token = env.getUnboundToken();
		}

		return token;
	}
};


struct PopFinalToken : public PopToken
{
	// TODO: we have to expand TextToken and ListToken to avoid recursions!?
	TokenP operator()(Environment& env) const { return env.getFinalToken(); }
};


typedef mstl::vector<TokenP> TokenList;

} // namespace


namespace TeXt {

static inline bool
operator==(TokenP const& token, mstl::string const& name)
{
	return token->name() == name;
}

} // namespace TeXt


static void
popParameterTokens(Environment& env, TokenList& result)
{
	unsigned position = 1;

	while (true)
	{
		TokenP token = env.getUndefinedToken();

		switch (token->type())
		{
			case Token::T_LeftBrace:
				return;

			case Token::T_RightBrace:
				return Messages::errmessage(env, "Unexpected }", Messages::Incorrigible);

			case Token::T_Parameter:
				if (token->name().find_first_not_of(Token::ParamChar) > env.nestingLevel() + 1)
				{
					return Messages::errmessage(	env,
															"Parameters must be numbered consecutively",
															Messages::Incorrigible);
				}

				if (mstl::find(result.begin(), result.end(), token->name()) != result.end())
				{
					return Messages::errmessage(	env,
															"Multiple definition of parameter " + token->name(),
															Messages::Incorrigible);
				}

				result.push_back(TokenP(new ParameterToken(token->name(), token->refID(), position++))); // MEMORY
				break;

			default:
				result.push_back(token);
				break;
		}
	}
}


static TokenP
popBodyTokens(	Environment& env,
					TokenList const& paramList,
					TokenP const& macro,
					PopToken const& popToken)
{
	M_ASSERT(macro);

	TokenList tokenList;

	unsigned level = 1;

	do
	{
		TokenP token = popToken(env);

		switch (token->type())
		{
			case Token::T_LeftBrace:
				++level;
				tokenList.push_back(token);
				break;

			case Token::T_RightBrace:
				if (--level > 0)
					tokenList.push_back(token);
				break;

			case Token::T_Parameter:
				{
					unsigned level = token->name().find_first_not_of(Token::ParamChar);

					if (	(	level == env.nestingLevel() + 1
							&& mstl::find(paramList.begin(), paramList.end(), token->name()) == paramList.end())
						|| (	level <= env.nestingLevel()
							&& !env.lookupParameter(token->refID())))
					{
						Messages::errmessage(
							env,
							"Illegal parameter '" + token->name() + "' in definition of " + macro->name(),
							Messages::Incorrigible);

						return TokenP();	// never reached
					}
				}
				tokenList.push_back(token);
				break;

			case Token::T_Variable:
				{
					unsigned level = token->name().find_first_not_of(Token::VarChar);

					if (level <= env.nestingLevel())
					{
						env.bind(token);
						tokenList.push_back(env.getUnboundToken());
					}
					else // if (level == env.nestingLevel() + 1)
					{
						tokenList.push_back(token);
					}
				}
				break;

			default:
				tokenList.push_back(token);
				break;
		}
	}
	while (level > 0);

	return TokenP(new ListToken(tokenList.begin(), tokenList.end())); // MEMORY
}


static void
define(Environment& env, PopToken const& popToken)
{
	TokenP		cs(env.getUndefinedToken());
	bool			isChar(cs->type() == Token::T_Number || cs->type() == Token::T_Ascii);
	TokenList	paramList;

	if (isChar)
	{
		if (env.getUndefinedToken()->type() != Token::T_LeftBrace)
		{
			Messages::errmessage(
				env,
				"macro body expected in definition of active character",
				Messages::Incorrigible);
		}
	}
	else
	{
		Verify::controlSequenceToken(env, cs);
		popParameterTokens(env, paramList);	// XXX may return with errmessage!
		M_ASSERT(dynamic_cast<GenericAssignmentToken const*>(env.currentToken().get()));
	}

	TokenP body(popBodyTokens(env, paramList, cs, popToken));
	TokenP macro(new MacroToken(cs->name(), paramList, body, env.nestingLevel() + 1)); // MEMORY

	if (isChar)
		env.bindMacro(cs->value(), TokenP(new ActiveToken(cs->value(), macro))); // MEMORY
	else
		Macros::bindMacro(env, cs, macro);
}


static void
performLet(Environment& env)
{
	TokenP cs = env.getUndefinedToken();

	if (cs->type() == Token::T_Number || cs->type() == Token::T_Ascii)
	{
		env.bindMacro(cs->value(), TokenP(new ActiveToken(cs->value(), env.getExpandableToken()))); // MEMORY
	}
	else
	{
		Verify::controlSequenceToken(env, cs);
		Macros::bindMacro(env, cs, env.getExpandableToken());
	}
}


static void
performXlet(Environment& env)
{
	TokenP self	= env.currentToken();
	TokenP cs	= env.getUndefinedToken();

	bool isChar = cs->type() == Token::T_Number || cs->type() == Token::T_Ascii;

	if (!isChar)
		Verify::controlSequenceToken(env, cs);

	TokenP arg = env.getFinalToken();

	if (!arg->isFinal())
	{
		env.expand(arg);

		TokenP token = env.getFinalToken();

		if (!token->isFinal())
		{
			Messages::errmessage(
				env,
				"You can't use `" + arg->meaning() + "' after " + self->name(),
				Messages::Corrigible);
		}

		arg = token;
	}

	if (isChar)
		env.bindMacro(cs->value(), TokenP(new ActiveToken(cs->value(), arg))); // MEMORY
	else
		Macros::bindMacro(env, cs, arg);
}


static void
performFuturelet(Environment& env)
{
	TokenP cs = env.getUndefinedToken();

	bool isChar = cs->type() == Token::T_Number || cs->type() == Token::T_Ascii;

	if (!isChar)
		Verify::controlSequenceToken(env, cs);

	TokenP token1 = env.getUndefinedToken();
	TokenP token2 = env.getExpandableToken();

	if (isChar)
		env.bindMacro(cs->value(), TokenP(new ActiveToken(cs->value(), token2))); // MEMORY
	else
		Macros::bindMacro(env, cs, token2);

	env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token2))); // MEMORY
	env.pushProducer(Environment::ProducerP(new ReadAgainProducer(token1))); // MEMORY
}


static void
performDef(Environment& env)
{
	define(env, PopUnboundToken());
}


static void
performEdef(Environment& env)
{
	define(env, PopFinalToken());
}


static void
performXdef(Environment& env)
{
	typedef Environment::ConsumerP ConsumerP;

	TokenP		cs(env.getUndefinedToken(Verify::controlSequenceToken));
	bool			isChar(cs->type() == Token::T_Number || cs->type() == Token::T_Ascii);
	TokenList	paramList;

	if (isChar)
	{
		if (env.getUndefinedToken()->type() != Token::T_LeftBrace)
		{
			Messages::errmessage(
				env,
				"macro body expected in definition of active character",
				Messages::Incorrigible);
		}
	}
	else
	{
		Verify::controlSequenceToken(env, cs);
		popParameterTokens(env, paramList);	// XXX may return with errmessage!
		M_ASSERT(dynamic_cast<GenericAssignmentToken const*>(env.currentToken().get()));
	}

	TokenP body(popBodyTokens(env, paramList, cs, PopUnboundToken()));
	TokenP macro(new MacroToken(cs->name(), paramList, body, env.nestingLevel() + 1)); // MEMORY

	MyConsumer consumer(env);
	env.perform(macro);

	TokenP result(new TextToken(consumer.m_result)); // MEMORY

	if (isChar)
		env.bindMacro(cs->value(), result);
	else
		Macros::bindMacro(env, cs, result);
}


static void
performEndcsname(Environment& env)
{
	Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);
}


void
Macros::performCsname(Environment& env)
{
	mstl::string csname("\\");

	while (true)
	{
		TokenP token = env.getUnboundToken();

		switch (token->type())
		{
			case Token::T_Invalid:
			case Token::T_Active:
			case Token::T_Ascii:
			case Token::T_LeftBrace:
			case Token::T_RightBrace:
			case Token::T_Number:
			case Token::T_List:
				csname += token->name();
				break;

			case Token::T_Text:
				csname += static_cast<TextToken*>(token.get())->content();
				break;

			case Token::T_Parameter:
				env.bind(token);
				break;

			default:
				if (token->type() == m_endcsname)
				{
					if (csname.size() == 1)
						csname = ::Csname + ::Endcsname;

					token = env.newUndefinedToken(csname);

					if (!env.lookupMacro(token->refID()))
						env.bindMacro(token->refID(), env.getToken(Token::T_Relax));

					return env.putUnboundToken(token);
				}
				else if (!token->isResolved())
				{
					env.putUnboundToken(token);
					env.putFinalToken(env.getFinalToken());
				}
				else
				{
					Messages::errmessage(env, "Missing " + ::Endcsname, Messages::Corrigible);
				}
				break;
		}
	}
}


void
Macros::bindMacro(Environment& env, TokenP const& cs, TokenP const& newToken)
{
	M_REQUIRE(dynamic_cast<GenericAssignmentToken const*>(env.currentToken().get()));

	int uplevel = static_cast<GenericAssignmentToken*>(env.currentToken().get())->uplevel();

	if (cs->type() == Token::T_Variable)
	{
		if (cs->name().find_first_not_of(Token::VarChar) > env.nestingLevel())
			Messages::errmessage(env, "Variables must be numbered consecutively", Messages::Incorrigible);

		env.bindVariable(cs->refID(), newToken, cs->name().find_first_not_of(Token::VarChar), uplevel);
	}
	else
	{
		env.bindMacro(cs->refID(), newToken, uplevel);
	}
}


void
Macros::doRegister(Environment& env)
{
	env.bindMacro(new GenericAssignmentToken("\\let",			::performLet));
	env.bindMacro(new GenericAssignmentToken("\\xlet",			::performXlet));
	env.bindMacro(new GenericAssignmentToken("\\futurelet",	::performFuturelet));
	env.bindMacro(new GenericAssignmentToken("\\def",			::performDef));
	env.bindMacro(new GenericAssignmentToken("\\edef",			::performEdef));
	env.bindMacro(new GenericAssignmentToken("\\xdef",			::performXdef));

	env.bindMacro(new GenericExpandableToken(::Csname, Func(&Macros::performCsname, this)));
	m_endcsname = Package::bindMacro(env, new GenericFinalToken(::Endcsname, ::performEndcsname));
}

// vi:set ts=3 sw=3:
