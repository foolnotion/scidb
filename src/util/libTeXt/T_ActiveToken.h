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

#ifndef _TeXt_ActiveToken_included
#define _TeXt_ActiveToken_included

#include "T_Token.h"

#include "m_function.h"

namespace TeXt {

class ActiveToken : public Token
{
public:

	typedef mstl::function<void (Environment&)> Func;

	ActiveToken(unsigned char c, Func const& func);
	ActiveToken(unsigned char c, TokenP const& macro);

	bool isBound() const override;
	bool isEqualTo(Token const& token) const override;

	RefID refID() const override;
	Type type() const override;
	mstl::string name() const override;

	void bind(Environment& env) override;
	void resolve(Environment& env) override;
	void expand(Environment& env) override;
	void execute(Environment& env) override;

private:

	unsigned char	m_value;
	Func				m_func;
	TokenP			m_macro;
};

} // namespace TeXt

#endif // _TeXt_ActiveToken_included

// vi:set ts=3 sw=3:
