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

#ifndef _TeXt_Format_included
#define _TeXt_Format_included

#include "T_Package.h"

#include "m_ref_counted_ptr.h"

namespace TeXt {

class Format : public Package
{
public:

	Format();
	~Format();

private:

	class NumberFilter;
	class FormatFilter;

	typedef mstl::ref_counted_ptr<FormatFilter> FormatFilterP;
	typedef mstl::ref_counted_ptr<NumberFilter> NumberFilterP;

	void doRegister(Environment& env) override;
	void performIgnorecase(Environment& env);
	void performNoshowpos(Environment& env);
	void performDec(Environment& env);
	void performOct(Environment& env);
	void performHex(Environment& env);
	void performLowercase(Environment& env);
	void performUppercase(Environment& env);
	void performShowpos(Environment& env);
	void performFillchar(Environment& env);
	void performAdjustnum(Environment& env);

	NumberFilterP m_numberFilter;
	FormatFilterP m_formatFilter;
};

} // namespace TeXt

#endif // _TeXt_Format_included

// vi:set ts=3 sw=3:
