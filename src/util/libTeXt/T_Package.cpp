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

#include "T_Package.h"
#include "T_Environment.h"

#include "m_assert.h"


using namespace TeXt;


Package::Package(Category category)
	:m_category(category)
	,m_isRegistered(false)
{
}


Package::Package(mstl::string const& name, Category category)
	:m_category(category)
	,m_name(name)
	,m_isRegistered(false)
{
}


Package::~Package()
{
	// no action
}


void
Package::doFinish(Environment&)
{
	// no action
}


mstl::string const&
Package::name() const
{
	static mstl::string const NoName("<no name>");
	return m_name.empty() ? NoName : m_name;
}


void
Package::registerTokens(Environment& env)
{
	if (!m_isRegistered)
	{
		doRegister(env);
		m_isRegistered = true;
	}
}


void
Package::finish(Environment& env)
{
	if (m_isRegistered)
		doFinish(env);
}


Token::Type
Package::bindMacro(Environment& env, Token* token)
{
	M_REQUIRE(token);

	env.bindMacro(token);
	return token->type();
}

// vi:set ts=3 sw=3:
