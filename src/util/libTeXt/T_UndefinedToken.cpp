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

#include "T_UndefinedToken.h"
#include "T_Environment.h"
#include "T_Messages.h"

#include "m_static_check.h"
#include "m_assert.h"

#include <string>


using namespace TeXt;


UndefinedToken::UndefinedToken(mstl::string const& name, RefID id)
	:UnboundToken(name, id)
{
	M_REQUIRE(!name.empty());
}


Token::Type
UndefinedToken::type() const
{
	return T_Undefined;
}


bool
UndefinedToken::isResolved() const
{
	return false;
}


Value
UndefinedToken::value() const
{
	return T_Undefined;
}


mstl::string
UndefinedToken::meaning() const
{
	return "undefined";
}


void
UndefinedToken::bind(Environment& env)
{
	env.putUnboundToken(env.currentToken());
}


void
UndefinedToken::resolve(Environment& env)
{
	TokenP token = env.lookupMacro(m_refID);

	if (!token)
		token = env.currentToken();

	env.putUnboundToken(token);
}


void
UndefinedToken::expand(Environment& env)
{
	Messages::errmessage(env, "Undefined control sequence", Messages::Corrigible);
}

// vi:set ts=3 sw=3:
