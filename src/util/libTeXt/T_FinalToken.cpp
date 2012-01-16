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

#include "T_FinalToken.h"
#include "T_Environment.h"

using namespace TeXt;


bool
FinalToken::isFinal() const
{
	return true;
}


void
FinalToken::bind(Environment& env)
{
	env.putFinalToken(env.currentToken());
}


void
FinalToken::resolve(Environment& env)
{
	env.putFinalToken(env.currentToken());
}


void
FinalToken::execute(Environment& env)
{
	if (env.associatedValue(T_Tracingcommands) > 0)
		traceCommand(env);

	perform(env);
}


void
FinalToken::expand(Environment& env)
{
	env.putFinalToken(env.currentToken());
}

// vi:set ts=3 sw=3:
