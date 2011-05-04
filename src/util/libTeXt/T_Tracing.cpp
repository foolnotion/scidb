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

#include "T_Tracing.h"
#include "T_GenericValueToken.h"
#include "T_Environment.h"


using namespace TeXt;


void
Tracing::doRegister(Environment& env)
{
	env.bindMacro(new GenericValueToken("\\tracingcommands",	Token::T_Tracingcommands));
	env.bindMacro(new GenericValueToken("\\tracingmacros",	Token::T_Tracingmacros));
	env.bindMacro(new GenericValueToken("\\tracingonline",	Token::T_Tracingonline));
}

// vi:set ts=3 sw=3:
