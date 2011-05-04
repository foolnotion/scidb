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

#include "T_GenericExpandableToken.h"

using namespace TeXt;


GenericExpandableToken::GenericExpandableToken(mstl::string const& name, Func func, Type type)
	:Generic(type, name, func)
{
}


GenericExpandableToken::Type
GenericExpandableToken::type() const
{
	return Generic::type();
}


mstl::string
GenericExpandableToken::name() const
{
	return Generic::name();
}


void
GenericExpandableToken::perform(Environment& env)
{
	Generic::perform(env);
}

// vi:set ts=3 sw=3:
