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

#include "T_GenericFinalToken.h"

using namespace TeXt;


GenericFinalToken::GenericFinalToken(mstl::string const& name, Func func, Type type)
	:Generic(type, name, func)
{
}


GenericFinalToken::Type
GenericFinalToken::type() const
{
	return Generic::type();
}


bool
GenericFinalToken::isFinal() const
{
	return true;
}


mstl::string
GenericFinalToken::name() const
{
	return Generic::name();
}


void
GenericFinalToken::perform(Environment& env)
{
	Generic::perform(env);
}

// vi:set ts=3 sw=3:
