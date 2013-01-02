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

#include "T_GenericValueToken.h"
#include "T_Environment.h"
#include "T_Messages.h"
#include "T_NumberToken.h"
#include "T_Verify.h"

using namespace TeXt;


static void
perform(Environment& env)
{
	// NOTE: env.associate(env.currentToken()->type(), ...) doesn't work due to a gcc-3.x bug!
	Token::Type type = env.currentToken()->type();
	env.associate(type, env.getFinalToken(Verify::numericalToken)->value());
}


GenericValueToken::GenericValueToken(mstl::string const& name, Type type)
	:Generic(type, name, ::perform)
{
}


TokenP
GenericValueToken::performThe(Environment& env) const
{
	return env.numberToken(env.associatedValue(Generic::type()));
}


mstl::string
GenericValueToken::description(Environment& env) const
{
	return NumberToken(env.associatedValue(Generic::type())).description(env);
}


GenericValueToken::Type
GenericValueToken::type() const
{
	return Generic::type();
}


mstl::string
GenericValueToken::name() const
{
	return Generic::name();
}


void
GenericValueToken::perform(Environment& env)
{
	Generic::perform(env);
}

// vi:set ts=3 sw=3:
