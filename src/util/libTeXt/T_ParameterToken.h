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

#ifndef _TeXt_ParameterToken_included
#define _TeXt_ParameterToken_included

#include "T_UnboundToken.h"
#include "T_Producer.h"

#include "m_string.h"
#include "m_scoped_ptr.h"

namespace TeXt {

class ParameterToken : public UnboundToken
{
public:

	class TokenProducer : public Producer
	{
	public:

		TokenProducer(TokenP const& token);

		bool finished() const override;
		bool reset() override;

		Source source() const override;
		TokenP next(Environment& env) override;
		mstl::string currentDescription() const override;

	private:

		typedef mstl::scoped_ptr<Producer> ProducerP;

		ProducerP m_producer;
	};

	ParameterToken(mstl::string const& name, RefID id, unsigned position = 0);

	bool isBound() const override;

	Type type() const override;
	Value value() const override;
	mstl::string meaning() const override;

	void bind(Environment& env) override;
	void resolve(Environment& env) override;
	void expand(Environment& env) override;

private:

	unsigned m_position;
};

} // namespace TeXt

#endif // _TeXt_ParameterToken_included

// vi:set ts=3 sw=3:
