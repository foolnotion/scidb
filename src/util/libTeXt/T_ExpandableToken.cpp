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

#include "T_ExpandableToken.h"
#include "T_Environment.h"

using namespace TeXt;


void
ExpandableToken::bind(Environment& env)
{
	env.putExpandableToken(env.currentToken());
}


void
ExpandableToken::resolve(Environment& env)
{
	env.putExpandableToken(env.currentToken());
}


void
ExpandableToken::expand(Environment& env)
{
	if (env.associatedValue(T_Tracingcommands) > 0)
		traceCommand(env);

	perform(env);
}


void
ExpandableToken::execute(Environment& env)
{
	env.putUnboundToken(env.getToken(T_Empty));
}

// vi:set ts=3 sw=3:
