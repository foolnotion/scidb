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

#ifndef _TeXt_ReadAgainProducer_included
#define _TeXt_ReadAgainProducer_included

#include "T_Producer.h"

namespace TeXt {

class ReadAgainProducer : public Producer
{
public:

	ReadAgainProducer(TokenP const& token);

	bool finished() const override;

	mstl::string currentDescription() const override;
	Source source() const override;

	TokenP next(Environment& env) override;

private:

	TokenP	m_token;
	bool		m_finished;
	bool		m_unused;
};

} // namespace TeXt

#endif // _TeXt_ReadAgainProducer_included

// vi:set ts=3 sw=3:
