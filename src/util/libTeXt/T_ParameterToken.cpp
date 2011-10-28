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

#include "T_ParameterToken.h"
#include "T_Environment.h"
#include "T_ListToken.h"
#include "T_Producer.h"
#include "T_Messages.h"

#include "m_assert.h"
#include "m_cast.h"
#include "m_string.h"

using namespace TeXt;


ParameterToken::TokenProducer::TokenProducer(TokenP const& token)
	:m_producer(mstl::safe_cast_ref<ListToken const>(*token).getProducer(token))
{
}


bool
ParameterToken::TokenProducer::finished() const
{
	return m_producer->finished();
}


Producer::Source
ParameterToken::TokenProducer::source() const
{
	return Parameter;
}


TokenP
ParameterToken::TokenProducer::next(Environment& env)
{
	return m_producer->next(env);
}


mstl::string
ParameterToken::TokenProducer::currentDescription() const
{
	return m_producer->currentDescription();
}


bool
ParameterToken::TokenProducer::reset()
{
	return m_producer->reset();
}


ParameterToken::ParameterToken(mstl::string const& name, RefID id, unsigned position)
	:UnboundToken(name, id)
	,m_position(position)
{
	M_REQUIRE(!name.empty());
	M_REQUIRE(name[0] == ParamChar);
}


bool
ParameterToken::isBound() const
{
	return false;
}


Token::Type
ParameterToken::type() const
{
	return T_Parameter;
}


Value
ParameterToken::value() const
{
	return m_position;
}


mstl::string
ParameterToken::meaning() const
{
	return "unbound parameter";
}


void
ParameterToken::bind(Environment& env)
{
	if (m_name.find_first_not_of(ParamChar) > env.nestingLevel())
	{
		env.putUnboundToken(env.currentToken());
	}
	else
	{
		TokenP token = env.lookupParameter(m_refID);

		if (!token)
		{
			mstl::string msg = "Illegal parameter '" + m_name + "'";

			if (env.contextMacro())
				msg += " in definition of " + env.contextMacro()->name();

			Messages::errmessage(env, msg, Messages::Incorrigible);
		}
		else
		{
			M_ASSERT(dynamic_cast<ListToken*>(token.get()));

			if (!token->isEmpty())
				env.pushProducer(Environment::ProducerP(new TokenProducer(token))); // MEMORY
		}
	}
}


void
ParameterToken::resolve(Environment& env)
{
	Messages::errmessage(env, "Illegal parameter", Messages::Incorrigible);
}


void
ParameterToken::expand(Environment& env)
{
	Messages::errmessage(env, "Illegal parameter", Messages::Incorrigible);
}

// vi:set ts=3 sw=3:
