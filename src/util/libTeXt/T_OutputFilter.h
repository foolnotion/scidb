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

#ifndef _TeXt_OutputFilter_included
#define _TeXt_OutputFilter_included

#include "T_Base.h"

#include "m_ref_counted_ptr.h"
#include "m_ref_counter.h"
#include "m_string.h"

namespace TeXt {

class Environment;


class OutputFilter : public mstl::ref_counter
{
public:

	virtual ~OutputFilter() = 0;

	OutputFilter(unsigned priority);

	OutputFilter& next();

	virtual void put(Environment& env, unsigned char c);
	virtual void put(Environment& env, mstl::string const& s);
	virtual void put(Environment& env, Value number);

private:

	typedef mstl::ref_counted_ptr<OutputFilter> FilterP;

	FilterP	m_next;
	unsigned	m_priority;	// TODO: unused yet

	friend class Environment;
};

} // namespace TeXt

#endif // _TeXt_OutputFilter_included

// vi:set ts=3 sw=3:
