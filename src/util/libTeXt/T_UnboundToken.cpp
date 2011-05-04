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

#include "T_UnboundToken.h"
#include "T_Environment.h"

#include "m_assert.h"

using namespace TeXt;


UnboundToken::UnboundToken(mstl::string const& name, RefID refID)
	:m_name(name)
	,m_refID(refID)
{
	M_REQUIRE(name.size() > 1);
}


mstl::string
UnboundToken::name() const
{
	return m_name;
}


RefID
UnboundToken::refID() const
{
	return m_refID;
}


void
UnboundToken::traceCommand(Environment&) const
{
	// no action
}


void
UnboundToken::execute(Environment& env)
{
	env.putUnboundToken(env.currentToken());
}

// vi:set ts=3 sw=3:
