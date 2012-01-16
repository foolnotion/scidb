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

#ifndef _TeXt_ValueBuffer_included
#define _TeXt_ValueBuffer_included

#include "T_Base.h"

#include "m_shared_ptr.h"
#include "m_vector.h"

namespace TeXt {

class ValueBuffer
{
public:

	ValueBuffer();

	unsigned size() const;

	Value get(unsigned level, RefID refID) const;

	void push();
	void pop();
	void set(unsigned level, RefID refID, Value value);
	void setupValue(RefID refID, Value value);

private:

	typedef mstl::vector<Value>		Values;
	typedef mstl::shared_ptr<Values>	ValuesP;
	typedef mstl::vector<ValuesP>		ValuesStack;

	ValuesStack m_valuesStack;
};

} // namespace TeXt

#include "T_ValueBuffer.ipp"

#endif // _TeXt_ValueBuffer_included

// vi:set ts=3 sw=3:
