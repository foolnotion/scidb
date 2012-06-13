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

#include "T_Receptacle.h"
#include "T_NumberToken.h"
#include "T_AsciiToken.h"
#include "T_TextToken.h"
#include "T_Token.h"

using namespace TeXt;


Receptacle::~Receptacle()
{
	// no action
}


void
Receptacle::add(mstl::string const& name, Token* token)
{
	add(name, TokenP(token));
}


void
Receptacle::add(mstl::string const& name, Value value)
{
	add(name, new NumberToken(value));
}


void
Receptacle::add(mstl::string const& name, char c)
{
	add(name, new AsciiToken(c));
}


void
Receptacle::add(mstl::string const& name, mstl::string const& s)
{
	add(name, new TextToken(s));
}

// vi:set ts=3 sw=3:
