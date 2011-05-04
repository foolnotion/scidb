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

#include "T_Nothing.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_UndefinedToken.h"
#include "T_Environment.h"


using namespace TeXt;


static void
perform(Environment&)
{
	// no action
}


void
Nothing::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken("\\relax", ::perform, Token::T_Relax));
	env.bindMacro(new GenericExpandableToken("\\empty", ::perform, Token::T_Empty));
	env.bindMacro(new UndefinedToken("\\undefined", Token::T_Undefined));
}

// vi:set ts=3 sw=3:
