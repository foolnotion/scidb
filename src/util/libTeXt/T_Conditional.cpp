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

#include "T_Conditional.h"
#include "T_GenericExpandableToken.h"
#include "T_GenericConditionalToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_Messages.h"
#include "T_Verify.h"

#include "m_assert.h"

using namespace TeXt;


namespace {

struct FiException {};
struct ElseException {};

} // namespace


template <typename T> inline bool isOdd(T value) { return value & 1; }


struct Conditional::ThrowMonitor
{
	ThrowMonitor(Conditional& cond) :fCond(cond)	{ fCond.m_throw = true; }
	~ThrowMonitor()										{ fCond.m_throw = false; }

	Conditional& fCond;
};


static void
trace(Environment& env, bool cond)
{
	static mstl::string const True("{true}\n");
	static mstl::string const False("{false}\n");

	if (env.associatedValue(Token::T_Tracingcommands) > 1)
		Messages::logmessage(env, cond ? True : False);
}


bool
verifyControlSequenceToken(Environment& env, TokenP const& token)
{
	switch (token->type())
	{
		case Token::T_Undefined:
		case Token::T_Parameter:
		case Token::T_Variable:
			return true;

		default:
			Messages::errmessage(env, "Missing control sequence", Messages::Corrigible);
			break;
	}

	return false;
}


Conditional::Conditional()
	:Package("conditional", Package::Mandatory)
	,m_throw(false)
	,m_unless(false)
{
	m_condStack.push(State(Token::T_Undefined, 0));
}


TokenP
Conditional::getFinalToken(Environment& env, VerifyFunc func)
{
	ThrowMonitor(*this);

	try
	{
		while (true)
		{
			TokenP token = env.getFinalToken();

			if (!func || func(env, token))
				return token;
		}
	}
	catch (ElseException)
	{
		return env.getToken(m_fi);
	}
	catch (FiException)
	{
		return env.getToken(m_else);
	}
	catch (...)
	{
		throw;
	}

	return TokenP();	// satisfies the compiler
}


void
Conditional::doFinish(Environment& env)
{
	State	state	= m_condStack.top();
	bool	empty	= m_condStack.size() == 1;

	while (m_condStack.size() > 1)
		m_condStack.pop();

	if (!empty)
	{
		Messages::message(env,
								"End of input occured when "
									+ env.getToken(state.first)->name()
									+ " on line "
									+ mstl::string::cast(state.second)
									+ " was incomplete\n");

		throw Token::AbortException();
	}
}


void
Conditional::skipElseBranch(Environment& env)
{
	TokenP	token;
	unsigned	level		= 1;

	do
	{
		if (!(token = env.getExpandableToken(Environment::AllowNull)))
		{
			Messages::message(env,
									"Incomplete "
										+ env.getToken(m_condStack.top().first)->name()
										+ "; all text was ignored after line "
										+ mstl::string::cast(m_condStack.top().second)
										+ "\n");

			throw Token::AbortException();
		}

		if (token->type() == m_fi)
		{
			if (--level == 0 && env.associatedValue(Token::T_Tracingcommands) > 0)
				token->traceCommand(env);
		}
		else if (token->isConditional())
		{
			++level;
		}
	}
	while (level > 0);

	m_condStack.pop();
}


//void
//Conditional::expandIfcase(Environment& env, Value skipCount)
//{
//	unsigned	lineno	= env.lineno();
//	Value		value		= skipCount;
//
//	while (skipCount != 0)
//	{
//		size_t level = 1;
//
//		do
//		{
//			TokenP token = env.getExpandableToken(Environment::AllowNull);
//
//			if (!token)
//			{
//				Messages::message(env,
//										"Incomplete "
//											+ env.currentToken()->name()
//											+ "; all text was ignored after line "
//											+ boost::lexical_cast<mstl::string>(lineno)
//											+ "\n");
//
//				throw Token::AbortException();	// XXX
//			}
//
//			Token::Type type = token->type();
//
//			if (type == m_else)
//			{
//				if (level == 1)
//				{
//					m_condStack.top().first = m_else;
//					return;
//				}
//			}
//			else if (type == m_or)
//			{
//				if (level == 1)
//				{
//					if (m_condStack.top().first != m_ifCase)
//						Messages::errmessage(env, "Extra " + token->name(), Messages::Incorrigible);
//
//					--level;
//				}
//			}
//			else if (type == kWhen)
//			{
//				if (level == 1)
//				{
//					if (m_condStack.top().first != m_ifCase)
//						Messages::errmessage(env, "Extra " + token->name(), Messages::Incorrigible);
//
//					if (n == getFinalToken(env, Verify::finalToken)->value())
//						return;
//				}
//			}
//			else if (type == m_fi)
//			{
//				if (--level == 0)
//				{
//					m_condStack.pop();
//					return;
//				}
//			}
//			else
//			{
//				if (token->isConditional())
//					++level;
//			}
//		}
//		while (level > 0);
//
//		if (skipCount > 0)
//			--skipCount;
//	}
//}


void
Conditional::expandIfThenElse(Environment& env, bool condition)
{
	bool unless = m_unless;

	m_unless = false;
	::trace(env, condition);

	if (env.getToken(m_condStack.top().first)->isConditional())
	{
		if (unless)
			condition = !condition;

//		expandIfcase(env, condition ? 0 : 1);

		if (!condition)
		{
			unsigned	lineno	= env.lineno();
			size_t	level		= 1;

			do
			{
				TokenP token = env.getExpandableToken(Environment::AllowNull);

				if (!token)
				{
					Messages::message(env,
											"Incomplete "
												+ env.currentToken()->name()
												+ "; all text was ignored after line "
												+ mstl::string::cast(lineno)
												+ "\n");

					throw Token::AbortException();	// XXX
				}

				Token::Type type = token->type();

				if (type == m_else)
				{
					if (level == 1)
					{
						m_condStack.top().first = m_else;
						return;
					}
				}
				else if (type == m_fi)
				{
					if (--level == 0)
						m_condStack.pop();
				}
				else
				{
					if (token->isConditional())
						++level;
				}
			}
			while (level > 0);
		}
	}
	else
	{
		env.getToken(m_fi)->traceCommand(env);
	}
}


void
Conditional::performElse(Environment& env)
{
	if (!env.getToken(m_condStack.top().first)->isConditional())
		return Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);

	skipElseBranch(env);

	if (m_throw)
		throw ElseException();
}


//void
//Conditional::performOr(Environment& env)
//{
//	if (m_condStack.top().first != m_ifCase)
//		return Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);
//
//	skipElseBranch(env);
//}


void
Conditional::performWhen(Environment& env)
{
	if (m_condStack.top().first != m_ifCase)
		return Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);

	skipElseBranch(env);
}


void
Conditional::performFi(Environment& env)
{
	if (m_condStack.top().first == Token::T_Undefined)
		return Messages::errmessage(env, "Extra " + env.currentToken()->name(), Messages::Incorrigible);

	m_condStack.pop();

	if (m_throw)
		throw FiException();
}


void
Conditional::performUnless(Environment& env)
{
	TokenP token = env.getExpandableToken();

	while (!token->isConditional())
	{
		if (token->isFinal())
		{
			Messages::errmessage(env,
										"You can't use a prefix with " + token->name(),
										Messages::Incorrigible);
		}
		else
		{
			env.expand(token);
		}

		token = env.getExpandableToken();
	}

	m_unless = true;
	env.putExpandableToken(token);
}


void
Conditional::performIf(Environment& env, Token::Type type)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, getFinalToken(env)->type() == type);
}


void
Conditional::performIffalse(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, false);
}


void
Conditional::performIftrue(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, true);
}


void
Conditional::performIfmacro(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, env.getUndefinedToken()->type() == Token::T_Undefined);
}


void
Conditional::performIftext(Environment& env)
{
	performIf(env, Token::T_Text);
}


void
Conditional::performIfempty(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));

	TokenP	token		= env.getUnboundToken();
	bool		unless	= m_unless;
	bool		result;

	m_unless = false;

	if (token->type() == Token::T_Parameter)
	{
		TokenP value = env.lookupParameter(token->refID());

		if (!value)
			Messages::errmessage(env, "Illegal parameter '" + token->name() + "'", Messages::Incorrigible);

		result = value->isEmpty();
	}
	else
	{
		env.putUnboundToken(token);
		token = env.getExpandableToken();
		result = token->isEmpty();
	}

	expandIfThenElse(env, unless != result);
}


void
Conditional::performIfnum(Environment& env)
{
	performIf(env, Token::T_Number);
}


void
Conditional::performIfodd(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, ::isOdd(getFinalToken(env, Verify::finalToken)->value()));
}


void
Conditional::performIfequal(Environment& env)
{
	Value lhs = getFinalToken(env, Verify::finalToken)->value();
	Value rhs = getFinalToken(env, Verify::finalToken)->value();

	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, lhs == rhs);
}


void
Conditional::performIfgreater(Environment& env)
{
	Value lhs = getFinalToken(env, Verify::finalToken)->value();
	Value rhs = getFinalToken(env, Verify::finalToken)->value();

	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, lhs > rhs);
}


void
Conditional::performIflower(Environment& env)
{
	Value lhs = getFinalToken(env, Verify::finalToken)->value();
	Value rhs = getFinalToken(env, Verify::finalToken)->value();

	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, lhs < rhs);
}


void
Conditional::performIfcase(Environment& env)
{
	Value		n			= getFinalToken(env, Verify::finalToken)->value();
	unsigned	lineno	= env.lineno();

	m_condStack.push(State(env.currentToken()->type(), lineno));

//	if (m_unless)
//		expandIfcase(env, -1);
//	else
//		expandIfcase(env, getFinalToken(env, Verify::finalToken)->value());

	while (true)
	{
		size_t level = 1;

		do
		{
			TokenP token = env.getExpandableToken(Environment::AllowNull);

			if (!token)
			{
				Messages::message(env,
										"Incomplete "
											+ env.currentToken()->name()
											+ "; all text was ignored after line "
											+ mstl::string::cast(lineno)
											+ "\n");

				throw Token::AbortException();	// XXX
			}

			Token::Type type = token->type();

			if (type == m_else)
			{
				if (level == 1)
				{
					m_condStack.top().first = m_else;
					return;
				}
			}
			else if (type == m_when)
			{
				if (level == 1 && n == getFinalToken(env, Verify::finalToken)->value())
					return;
			}
			else if (type == m_fi)
			{
				if (--level == 0)
				{
					m_condStack.pop();
					return;
				}
			}
			else
			{
				if (token->isConditional())
					++level;
			}
		}
		while (level > 0);
	}
}


void
Conditional::performIf(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));

	TokenP token1 = getFinalToken(env);
	TokenP token2 = token1;

	if (token1->type() != m_fi)
		token2 = getFinalToken(env);

	bool isValue1 = token1->type() == Token::T_Ascii || token1->type() == Token::T_Number;
	bool isValue2 = token2->type() == Token::T_Ascii || token1->type() == Token::T_Number;

	if (isValue1 && isValue2)
		expandIfThenElse(env, token1->value() == token2->value());
	else
		expandIfThenElse(env, !isValue1 && !isValue2);
}


void
Conditional::performIfx(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));
	expandIfThenElse(env, *env.getExpandableToken() == *env.getExpandableToken());
}


void
Conditional::performIfbound(Environment& env)
{
	m_condStack.push(State(env.currentToken()->type(), env.lineno()));

	TokenP token = env.getUndefinedToken(verifyControlSequenceToken);

	switch (token->type())
	{
		case Token::T_Undefined:
			expandIfThenElse(env, env.lookupMacro(token->refID()) != 0);
			break;

		case Token::T_Parameter:
			env.expand(token);	// forces error message!
			break;

		default:
			M_ASSERT(0);
			break;
	}
}


void
Conditional::doRegister(Environment& env)
{
	typedef GenericConditionalToken GenCondTok;

	env.bindMacro(new GenCondTok("\\ifbound",		Func(&Conditional::performIfbound, this)));
	env.bindMacro(new GenCondTok("\\iffalse",		Func(&Conditional::performIffalse, this)));
	env.bindMacro(new GenCondTok("\\ifmacro",		Func(&Conditional::performIfmacro, this)));
	env.bindMacro(new GenCondTok("\\iftext",		Func(&Conditional::performIftext, this)));
	env.bindMacro(new GenCondTok("\\ifempty",		Func(&Conditional::performIfempty, this)));
	env.bindMacro(new GenCondTok("\\ifnum",		Func(&Conditional::performIfnum, this)));
	env.bindMacro(new GenCondTok("\\ifodd",		Func(&Conditional::performIfodd, this)));
	env.bindMacro(new GenCondTok("\\iftrue",		Func(&Conditional::performIftrue, this)));
	env.bindMacro(new GenCondTok("\\ifx",			Func(&Conditional::performIfx, this)));
	m_if =
	bindMacro(env, new GenCondTok("\\if",			Func(&Conditional::performIf, this)));
	m_ifCase =
	bindMacro(env, new GenCondTok("\\ifcase",		Func(&Conditional::performIfcase, this)));
	env.bindMacro(new GenCondTok("\\ifequal",		Func(&Conditional::performIfequal, this)));
	env.bindMacro(new GenCondTok("\\ifgreater",	Func(&Conditional::performIfgreater, this)));
	env.bindMacro(new GenCondTok("\\iflower",		Func(&Conditional::performIflower, this)));

	env.bindMacro(new GenericExpandableToken("\\unless",	Func(&Conditional::performUnless, this)));
	m_else =
	bindMacro(env, new GenericExpandableToken("\\else",	Func(&Conditional::performElse, this)));
//	m_or =
//	bindMacro(env, new GenericExpandableToken("\\or",		Func(&Conditional::performOr, this)));
	m_when =
	bindMacro(env, new GenericExpandableToken("\\when",	Func(&Conditional::performWhen, this)));
	m_fi =
	bindMacro(env, new GenericExpandableToken("\\fi",		Func(&Conditional::performFi, this)));
}

// vi:set ts=3 sw=3:
