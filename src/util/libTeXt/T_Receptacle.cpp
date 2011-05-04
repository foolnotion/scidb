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

#include "T_Receptacle.h"
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

// vi:set ts=3 sw=3:
