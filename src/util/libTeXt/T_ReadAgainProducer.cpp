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

#include "T_ReadAgainProducer.h"
#include "T_Token.h"

using namespace TeXt;


ReadAgainProducer::ReadAgainProducer(TokenP const& token)
	:m_token(token)
	,m_finished(false)
	,m_unused(true)
{
}


bool
ReadAgainProducer::finished() const
{
	return m_finished;
}


Producer::Source
ReadAgainProducer::source() const
{
	return ReadAgain;
}


TokenP
ReadAgainProducer::next(Environment&)
{
	TokenP t;

	if (!m_finished)
	{
		t = m_token;
		m_finished = true;
		m_unused = false;
	}

	return t;
}


mstl::string
ReadAgainProducer::currentDescription() const
{
	if (m_unused)
		return mstl::string::empty_string;

	return m_token->name();
}

// vi:set ts=3 sw=3:
