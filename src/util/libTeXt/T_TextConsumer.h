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

#ifndef _TeXt_TextConsumer_included
#define _TeXt_TextConsumer_included

#include "T_Consumer.h"

namespace TeXt {

class TextConsumer : public Consumer
{
public:

	TextConsumer(mstl::string& result, Consumer* next = 0);

	void put(unsigned char c) override;
	void put(mstl::string const& s) override;

	void out(mstl::string const& text) override;
	void log(mstl::string const& text, bool copyToOut) override;

private:

	mstl::string&	m_result;
	Consumer*		m_next;
};

} // namespace TeXt

#endif //_TeXt_TextConsumer_included

// vi:set ts=3 sw=3:
