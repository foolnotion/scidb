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

#ifndef _TeXt_Producer_included
#define _TeXt_Producer_included

#include "T_TokenP.h"

#include "m_ref_counter.h"
#include "m_string.h"

namespace TeXt {

class Environment;

class Producer : public mstl::ref_counter
{
public:

	enum Source
	{
		File,
		Macro,
		Parameter,
		List,
		Text,
		Insert,
		InsertedText,
		ReadAgain,
	};

	virtual ~Producer() = 0;

	virtual bool finished() const;

	virtual unsigned lineno() const;
	virtual mstl::string currentDescription() const = 0;
	virtual Source source() const = 0;

	virtual TokenP next(Environment& env) = 0;
	virtual bool reset();
};

} // namespace TeXt

#endif // _TeXt_Producer_included

// vi:set ts=3 sw=3:
