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

#include "T_Token.h"
#include "T_Environment.h"
#include "T_Messages.h"

#include "m_assert.h"


using namespace TeXt;


Token::~Token()
{
	// no action
}


mstl::string Token::meaning() const							{ return name(); }
mstl::string Token::description(Environment&) const	{ return name(); }

bool Token::isNumber() const			{ return false; }
bool Token::isBound() const			{ return true; }
bool Token::isResolved() const		{ return true; }
bool Token::isFinal() const			{ return false; }
bool Token::isConditional() const	{ return false; }
Value Token::value() const				{ return 0; }
bool Token::isEmpty() const			{ return type() == T_Empty; }


RefID
Token::refID() const
{
	return RefID(type());
}


bool
Token::isEqualTo(Token const& token) const
{
	return value() == token.value();
}


bool
Token::operator==(Token const& token) const
{
	return type() == token.type() && isEqualTo(token);
}


mstl::string
Token::name(Environment& env) const
{
	mstl::string result = name();

	if (result.size() > 1 && result[0] == EscapeChar)
	{
		Value escapeChar = env.associatedValue(T_Escapechar);

		if (0 <= escapeChar && escapeChar <= 255)
			result[0] = escapeChar;
		else
			result.erase(mstl::string::size_type(0), mstl::string::size_type(1));
	}

	return result;
}


mstl::string
Token::text() const
{
	return name();
}


TokenP
Token::performThe(Environment&) const
{
	return TokenP();
}


bool
Token::setUplevel(int)
{
	return false;
}


void
Token::traceCommand(Environment& env, mstl::string const& meaning)
{
	Messages::logmessage(env, "{" + meaning + "}\n");
}


void
Token::traceCommand(Environment& env) const
{
	traceCommand(env, meaning());
}

// vi:set ts=3 sw=3:
