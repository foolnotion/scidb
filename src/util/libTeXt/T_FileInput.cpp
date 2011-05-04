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

#include "T_FileInput.h"

#include "m_assert.h"
#include "m_iostream.h"

using namespace TeXt;


FileInput::FileInput(mstl::istream* stream, bool owner)
	:m_stream(stream)
	,m_owner(owner)
{
}


FileInput::~FileInput()
{
	if (m_owner)
		delete m_stream;
}


FileInput&
FileInput::operator=(FileInput const& stream)
{
	if (this != &stream)
	{
		m_stream = stream.m_stream;
		m_owner = stream.m_owner;
		stream.m_owner = false;
	}

	return *this;
}


FileInput::Source
FileInput::source() const
{
	return Producer::File;
}


bool
FileInput::readNextLine(mstl::string& result)
{
	return m_stream ? bool(m_stream->getline(result)) : false;
}

// vi:set ts=3 sw=3:
