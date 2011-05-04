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

#include "T_RightBraceToken.h"
#include "T_LeftBraceToken.h"
#include "T_Environment.h"
#include "T_Messages.h"


using namespace TeXt;


RightBraceToken::RightBraceToken()
{
}


Token::Type
RightBraceToken::type() const
{
	return T_RightBrace;
}


mstl::string
RightBraceToken::name() const
{
	return mstl::string(1, RBraceChar);
}


mstl::string
RightBraceToken::meaning() const
{
	return "end-group character " + name();
}


void
RightBraceToken::perform(Environment& env)
{
	if (env.groupLevel() == 0)
	{
		Messages::errmessage(env, "Too many " + name() + "'s", Messages::Incorrigible);
	}
	else if (env.associatedValue(T_LeftBrace) != T_LeftBrace)
	{
		Messages::errmessage(env,
									"Extra " + name() + " or forgotten " + LeftBraceToken().name(),
									Messages::Incorrigible);
	}
	else
	{
		env.popGroup();
	}
}

// vi:set ts=3 sw=3:
