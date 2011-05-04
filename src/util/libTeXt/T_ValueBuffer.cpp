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

#include "T_ValueBuffer.h"

#include "m_assert.h"


using namespace TeXt;


ValueBuffer::ValueBuffer()
{
	m_valuesStack.push_back(ValuesP(new Values));
}


void
ValueBuffer::push()
{
	M_REQUIRE(!m_valuesStack.empty());
	m_valuesStack.push_back(m_valuesStack.back());
}


void
ValueBuffer::pop()
{
	M_REQUIRE(size() > 1);
	m_valuesStack.pop_back();
}


void
ValueBuffer::setupValue(RefID refID, Value value)
{
	M_REQUIRE(!m_valuesStack.empty());

	if (refID >= m_valuesStack.front()->size())
		m_valuesStack.front()->resize(refID + 1, 0);

	(*m_valuesStack.front())[refID] = value;
}


void
ValueBuffer::set(unsigned level, RefID refID, Value value)
{
	M_REQUIRE(level < size());
	M_REQUIRE(refID < m_valuesStack.front()->size());

	if (!m_valuesStack[level].unique())
		m_valuesStack[level].reset(new Values(*m_valuesStack[level]));

	(*m_valuesStack[level])[refID] = value;
}


Value
ValueBuffer::get(unsigned level, RefID refID) const
{
	M_REQUIRE(level < size());
	M_REQUIRE(refID < m_valuesStack.front()->size());

	return (*m_valuesStack[level])[refID];
}

// vi:set ts=3 sw=3:
