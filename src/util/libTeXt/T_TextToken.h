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

#ifndef _TeXt_TextToken_included
#define _TeXt_TextToken_included

#include "T_FinalToken.h"

namespace TeXt {

class TextToken : public FinalToken
{
public:

	TextToken();
	TextToken(mstl::string const& str);

	Type type() const override;
	RefID refID() const override;
	mstl::string name() const override;
	mstl::string meaning() const override;
	mstl::string const& content() const override;
	bool isEqualTo(Token const& token) const override;
	bool isEmpty() const override;

	TokenP performThe(Environment& env) const override;
	void perform(Environment& env) override;

private:

	mstl::string m_str;
};

} // namespace TeXt

#include "T_TextToken.ipp"

#endif // _TeXt_TextToken_included

// vi:set ts=3 sw=3:
