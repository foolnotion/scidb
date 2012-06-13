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

class ListToken;
class Producer;

class TextToken : public FinalToken
{
public:

	typedef mstl::ref_counted_ptr<ListToken> ListP;
	typedef mstl::ref_counted_ptr<TextToken> TextP;

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

	void map(Environment& env, ListP const& mapping);

	Producer* getProducer(TokenP const& self) const;

	static TextP convert(Environment& env, TokenP token);

private:

	mstl::string m_str;
};

} // namespace TeXt

#include "T_TextToken.ipp"

#endif // _TeXt_TextToken_included

// vi:set ts=3 sw=3:
