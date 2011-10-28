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

#include "T_MacroToken.h"
#include "T_ListToken.h"
#include "T_ParameterToken.h"
#include "T_LeftBraceToken.h"
#include "T_RightBraceToken.h"
#include "T_AsciiToken.h"
#include "T_VariableToken.h"
#include "T_Environment.h"
#include "T_Producer.h"
#include "T_Messages.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_vector.h"

#include <ctype.h>

using namespace TeXt;


MacroToken::TokenProducer::TokenProducer(TokenP const& macro)
	:m_macro(macro)
	,m_producer(m_macro->getProducer())
{
}


bool
MacroToken::TokenProducer::finished() const
{
	return m_producer->finished();
}


Producer::Source
MacroToken::TokenProducer::source() const
{
	return Macro;
}


TokenP
MacroToken::TokenProducer::next(Environment& env)
{
	return m_producer->next(env);
}


mstl::string
MacroToken::TokenProducer::currentDescription() const
{
	mstl::string descr = m_producer->currentDescription();

	if (descr.empty())
		return mstl::string::empty_string;

	return m_macro->name() + " " + m_macro->parameterDescription() + "->" + descr;
}


bool
MacroToken::TokenProducer::reset()
{
	bool rc = m_producer->reset();
	M_ASSERT(rc);
	return rc;
}


namespace {

struct Match
{
	Match() :m_first(0), m_last(0) {}

	void set(size_t first, size_t last)
	{
		m_first = first;
		m_last = last;
	}

	size_t m_first;
	size_t m_last;
};

typedef mstl::vector<Match> MatchList;
typedef mstl::vector<bool> ListMarkers;

} // namespace


static void
ensureParameter(Environment& env, TokenP& token)
{
	token = env.newParameterToken(Token::ParamChar + token->name());
}


static TokenP
popList(Environment& env)
{
	unsigned level = 0;
	mstl::ref_counted_ptr<ListToken> result(new ListToken); // MEMORY

	while (true)
	{
		TokenP token = env.getUndefinedToken();

		switch (token->type())
		{
			case Token::T_LeftBrace:
				++level;
				break;

			case Token::T_RightBrace:
				if (level-- == 0)
					return result;
				break;

			case Token::T_Parameter:
				ensureParameter(env, token);
				break;

			case Token::T_Variable:
				token = env.newVariableToken(token->name());
				break;

			default:
				break;
		}

		result->append(token);
	}

	return TokenP();	// satisfies the compiler
}


static TokenP
popArgument(Environment& env, ListMarkers& markers)
{
	TokenP token = env.getUndefinedToken(Environment::AllowNull);

	if (token)
	{
		switch (token->type())
		{
			case Token::T_LeftBrace:
				token = popList(env);
				markers.push_back(true);
				break;

			case Token::T_RightBrace:
				Messages::errmessage(env, "unexpected }", Messages::Incorrigible);
				break;

			case Token::T_Parameter:
				ensureParameter(env, token);
				markers.push_back(false);
				break;

			case Token::T_Variable:
				static_cast<VariableToken*>(token.get())->fixLevel(env.contextLevel());
				markers.push_back(false);
				break;

			default:
				markers.push_back(false);
				break;
		}
	}

	return token;
}


inline static bool
isSpaceToken(TokenP const& token)
{
	return token->type() == Token::T_Ascii && ::isspace(token->value());
}


static bool
match(MacroToken::TokenList const& params,
		MacroToken::TokenList const& args,
		size_t paramIndex,
		size_t argIndex,
		MatchList& matchList)
{
	if (paramIndex == params.size())
		return true;

	if (argIndex == args.size())
		return false;

	if (params[paramIndex]->type() == Token::T_Parameter)
	{
		if (paramIndex == params.size() - 1 || params[paramIndex + 1]->type() == Token::T_Parameter)
		{
			while (isSpaceToken(args[argIndex]))
			{
				if (++argIndex == args.size())
					return false;
			}

			matchList[paramIndex].set(argIndex, argIndex + 1);

			if (match(params, args, paramIndex + 1, argIndex + 1, matchList))
				return true;
		}
		else
		{
			for (size_t i = argIndex; i < args.size(); ++i)
			{
				matchList[paramIndex].set(argIndex, i);

				if (match(params, args, paramIndex + 1, i, matchList))
					return true;
			}

			return false;
		}
	}
	else if (isSpaceToken(params[paramIndex]))
	{
		if (!isSpaceToken(args[argIndex]))
			return false;

		++paramIndex;
		++argIndex;

		while (paramIndex < params.size() && isSpaceToken(params[paramIndex]))
			++paramIndex;

		while (argIndex < args.size() && isSpaceToken(args[argIndex]))
			++argIndex;

		return match(params, args, paramIndex, argIndex, matchList);
	}
	else if (	*params[paramIndex] == *args[argIndex]
				&& params[paramIndex]->name() == args[argIndex]->name())
	{
		return match(params, args, paramIndex + 1, argIndex + 1, matchList);
	}

	return false;
}


inline static bool
match(MacroToken::TokenList const& params, MacroToken::TokenList const& args, MatchList& matchList)
{
	M_ASSERT(matchList.size() == params.size());
	return match(params, args, 0, 0, matchList);
}


MacroToken::Data::Data(TokenList const& paramList, TokenP const& body, int nestingLevel)
	:m_body(body)
	,m_nestingLevel(nestingLevel)
{
	for (size_t i = 0; i < paramList.size(); ++i)
	{
		if (m_parameters.empty() || !isSpaceToken(m_parameters[0]) || !isSpaceToken(paramList[0]))
			m_parameters.push_back(paramList[i]);
	}
}


MacroToken::MacroToken(	mstl::string const& ident,
								TokenList const& paramList,
								TokenP const& body,
								int nestingLevel)
	:m_ident(ident)
	,m_data(new Data(paramList, body, nestingLevel)) // MEMORY
{
	M_REQUIRE(body);
}


MacroToken::MacroToken(mstl::string const& name, DataP const& data)
	:m_ident(name)
	,m_data(data)
{
}


bool
MacroToken::isEqualTo(Token const& token) const
{
	M_REQUIRE(dynamic_cast<MacroToken const*>(&token));

	return	m_data->m_parameters == static_cast<MacroToken const&>(token).m_data->m_parameters
			&& *m_data->m_body == *static_cast<MacroToken const&>(token).m_data->m_body;
}


bool
MacroToken::isEmpty() const
{
	return m_data->m_body->isEmpty();
}


Token::Type
MacroToken::type() const
{
	return T_Macro;
}


mstl::string
MacroToken::name() const
{
	return m_ident;
}


Value
MacroToken::value() const
{
	M_RAISE("unexpected call of MacroToken::value()");
}


mstl::string
MacroToken::meaning() const
{
	return "macro:\n" + parameterDescription() + "->" + m_data->m_body->meaning();
}


mstl::string
MacroToken::parameterDescription() const
{
	mstl::string result;

	for (size_t i = 0; i < m_data->m_parameters.size(); ++i)
		result += m_data->m_parameters[i]->name();

	return result;
}


Producer*
MacroToken::getProducer() const
{
	return mstl::safe_cast_ref<ListToken const>(*m_data->m_body).getProducer(m_data->m_body);
}


void
MacroToken::traceCommand(Environment&) const
{
	// no action
}


void
MacroToken::bindParameter(	Environment& env,
									TokenP const& parameter,
									TokenList::iterator first,
									TokenList::iterator last,
									ListMarkers::iterator firstMarker,
									ListMarkers::iterator lastMarker __attribute__ ((unused)))
{
	M_REQUIRE(parameter);
	M_REQUIRE(last - first == lastMarker - firstMarker);

	mstl::ref_counted_ptr<ListToken> list;

	if (first == last)
	{
		list.reset(new ListToken); // MEMORY
	}
	else if (first + 1 == last)
	{
		if (*firstMarker)
			list = *first;
		else
			list.reset(new ListToken(*first)); // MEMORY
	}
	else
	{
		list.reset(new ListToken); // MEMORY

		for ( ; first != last; ++first, ++firstMarker)
		{
			if (*firstMarker)
			{
				list->append(env.getToken(T_LeftBrace));
				mstl::safe_cast_ref<ListToken>(**first).appendTo(*list);
				list->append(env.getToken(T_RightBrace));
			}
			else
			{
				list->append(*first);
			}
		}
	}

	if (env.associatedValue(T_Tracingmacros) > 0)
		Messages::logmessage(env, parameter->name() + "->" + list->meaning() + "\n");

	env.bindParameter(parameter->refID(), list);
}


void
MacroToken::perform(Environment& env)
{
	if (env.associatedValue(T_Tracingmacros) > 0)
	{
		Messages::logmessage(
				env,
				m_ident + " " + parameterDescription() + "->" + m_data->m_body->meaning() + '\n');
	}

	TokenList	argList;
	MatchList	matchList;
	ListMarkers	markers;
	TokenList&	paramList	= m_data->m_parameters;
	unsigned		lineno		= env.lineno();

	matchList.resize(paramList.size());

	while (!match(paramList, argList, matchList))
	{
		TokenP token = ::popArgument(env, markers);

		if (!token)
		{
			Messages::errmessage(
				env,
				"Input ended while scanning use of " + name() + " (l." + ::mstl::string::cast(lineno) + ")",
				Messages::Incorrigible);
		}

		argList.push_back(token);
	}

	if (m_data->m_body->isEmpty())
		return;

	bool tailRecursionDetected = false;

	if (env.contextMacro() == this)
	{
		while (env.producer().source() != Producer::Macro && env.producer().finished())
			env.popProducer();

		if (env.producer().source() == Producer::Macro && env.producer().finished())
			tailRecursionDetected = true;
	}

	if (tailRecursionDetected)
	{
		dynamic_cast<TokenProducer&>(env.producer()).reset();
	}
	else
	{
		M_ASSERT(env.currentToken() == this);

		env.pushProducer(	Environment::ProducerP(new TokenProducer(env.currentToken())), // MEMORY
								env.currentToken(),
								m_data->m_nestingLevel);
	}

	for (size_t i = 0; i < paramList.size(); ++i)
	{
		if (paramList[i]->type() == T_Parameter)
		{
			bindParameter(
					env,
					paramList[i],
					argList.begin() + matchList[i].m_first,
					argList.begin() + matchList[i].m_last,
					markers.begin() + matchList[i].m_first,
					markers.begin() + matchList[i].m_last);
		}
	}
}

// vi:set ts=3 sw=3:
