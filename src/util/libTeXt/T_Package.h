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

#ifndef _TeXt_Package_included
#define _TeXt_Package_included

#include "T_Generic.h"

#include "m_ref_counter.h"
#include "m_string.h"

namespace TeXt {

class Environment;

class Package : public mstl::ref_counter
{
public:

	typedef Generic::Func Func;

	enum Category { Optional, Mandatory };

	Package(Category category = Mandatory);
	Package(mstl::string const& name, Category category);
	virtual ~Package() = 0;

	bool isMandatory() const;
	bool isOptional() const;
	bool isRegistered() const;
	bool hasName() const;

	mstl::string const& name() const;

	void registerTokens(Environment& env);
	void finish(Environment& env);

protected:

	virtual void doRegister(Environment& env) = 0;
	virtual void doFinish(Environment& env);

private:

	Category			m_category;
	mstl::string	m_name;
	bool				m_isRegistered;
};

} // namespace TeXt

#include "T_Package.ipp"

#endif // _TeXt_Package_included

// vi:set ts=3 sw=3:
