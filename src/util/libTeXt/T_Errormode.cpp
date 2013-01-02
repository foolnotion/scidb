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

#include "T_Errormode.h"
#include "T_GenericFinalToken.h"
#include "T_Environment.h"

using namespace TeXt;


static mstl::string const Batchmode			= "\\batchmode";
static mstl::string const Scrollmode		= "\\scrollmode";
static mstl::string const Nonstopmode		= "\\nonstopmode";
static mstl::string const Abortmode			= "\\abortmode";
static mstl::string const Errorstopmode	= "\\errorstopmode";


static void
performAbortmode(Environment& env)
{
	env.setErrorMode(Environment::AbortMode);
}


static void
performBatchmode(Environment& env)
{
	env.setErrorMode(Environment::BatchMode);
}


static void
performErrorstopmode(Environment& env)
{
	env.setErrorMode(Environment::ErrorStopMode);
}


static void
performScrollmode(Environment& env)
{
	env.setErrorMode(Environment::ScrollMode);
}


static void
performNonstopmode(Environment& env)
{
	env.setErrorMode(Environment::NonStopMode);
}


mstl::string
Errormode::setAbortmode(Environment& env)
{
	env.setErrorMode(Environment::AbortMode);
	return ::Abortmode;
}


mstl::string
Errormode::setBatchmode(Environment& env)
{
	env.setErrorMode(Environment::BatchMode);
	return ::Batchmode;
}


mstl::string
Errormode::setErrorstopmode(Environment& env)
{
	env.setErrorMode(Environment::ErrorStopMode);
	return ::Errorstopmode;
}


mstl::string
Errormode::setScrollmode(Environment& env)
{
	env.setErrorMode(Environment::ScrollMode);
	return ::Scrollmode;
}


mstl::string
Errormode::setNonstopmode(Environment& env)
{
	env.setErrorMode(Environment::NonStopMode);
	return ::Nonstopmode;
}


void
Errormode::doRegister(Environment& env)
{
	env.bindMacro(new GenericFinalToken(::Batchmode,		::performBatchmode));
	env.bindMacro(new GenericFinalToken(::Scrollmode,		::performScrollmode));
	env.bindMacro(new GenericFinalToken(::Nonstopmode,		::performNonstopmode));
	env.bindMacro(new GenericFinalToken(::Abortmode,		::performAbortmode));
	env.bindMacro(new GenericFinalToken(::Errorstopmode,	::performErrorstopmode));
}

// vi:set ts=3 sw=3:
