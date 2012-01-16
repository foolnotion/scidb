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

#ifndef _TeXt_Input_included
#define _TeXt_Input_included

#include "T_Producer.h"

#include "m_ref_counter.h"
#include "m_string.h"

namespace TeXt {

class Input : public mstl::ref_counter
{
public:

	typedef Producer::Source Source;

	Input();
	virtual ~Input() = 0;

	unsigned lineno() const;

	virtual Source source() const = 0;

	bool nextLine(mstl::string& result);

protected:

	virtual bool readNextLine(mstl::string& result) = 0;

private:

	unsigned m_lineNo;
};

} // namespace TeXt

#include "T_Input.ipp"

#endif // _TeXt_Input_included

// vi:set ts=3 sw=3:
