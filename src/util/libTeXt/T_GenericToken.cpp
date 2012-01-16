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

#include "T_GenericToken.h"

#include "m_assert.h"

using namespace TeXt;


GenericToken::GenericToken(Type type, mstl::string const& name, Func func)
	:m_type(type)
	,m_name(name)
	,m_func(func)
{
	M_REQUIRE(!name.empty() && name[0] == EscapeChar);
}


GenericToken::~GenericToken()
{
	// no action
}


Token::Type
GenericToken::type() const
{
	return m_type;
}


mstl::string
GenericToken::name() const
{
	return m_name;
}


void
GenericToken::setType(Type type)
{
	m_type = type;
}


void
GenericToken::perform(Environment& env)
{
	m_func(env);
}

// vi:set ts=3 sw=3:
