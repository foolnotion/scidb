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

#include "T_Generic.h"

#include "m_assert.h"

using namespace TeXt;


Generic::Generic(Type type, const mstl::string& name, Func func)
	:m_type(type)
	,m_name(name)
	,m_func(func)
{
	M_REQUIRE(!name.empty() && name[0] == Token::EscapeChar);
}


Generic::~Generic()
{
	// no action
}


Token::Type
Generic::type() const
{
	return m_type;
}


mstl::string
Generic::name() const
{
	return m_name;
}


void
Generic::setType(Type type)
{
	m_type = type;
}


void
Generic::perform(Environment& env)
{
	m_func(env);
}

// vi:set ts=3 sw=3:
