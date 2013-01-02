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

#include "T_LeftBraceToken.h"
#include "T_Environment.h"

using namespace TeXt;


LeftBraceToken::LeftBraceToken()
{
}


Token::Type
LeftBraceToken::type() const
{
	return T_LeftBrace;
}


mstl::string
LeftBraceToken::name() const
{
	return mstl::string(1, LBraceChar);
}


mstl::string
LeftBraceToken::meaning() const
{
	return "begin-group character " + name();
}


void
LeftBraceToken::perform(Environment& env)
{
	env.pushGroup();
	env.associate(T_LeftBrace, Value(T_LeftBrace));
}

// vi:set ts=3 sw=3:
