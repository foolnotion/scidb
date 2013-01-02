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

#include "T_Format.h"
#include "T_GenericFinalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_GenericValueToken.h"
#include "T_Environment.h"
#include "T_Messages.h"
#include "T_OutputFilter.h"

#include "m_sstream.h"

#include <ctype.h>


using namespace TeXt;


struct Format::NumberFilter : public OutputFilter
{
	enum Base { Oct = 'o', Dec = 'd', Hex = 'x', };

	NumberFilter() :OutputFilter(1000) {}

	void put(Environment& env, Value number)
	{
		mstl::ostringstream ostr;
		mstl::string fmt;

		Value adjust = env.associatedValue(m_adjustnum);
		Value filler = env.associatedValue(m_fillchar);

		if (adjust < 0)
			fmt += '-';

		if (number > 0 && env.associatedValue(m_showpos))
			fmt += '+';

		fmt += '%';

		if (adjust > 0)
			fmt.format("%d", adjust);

		fmt += env.associatedValue(m_base);
		ostr.format(fmt, number);

		if (adjust > 0 && filler && filler != ' ')
		{
			mstl::string s = ostr.str();

			for (size_t i = 0; i < s.size(); ++i)
			{
				if (s[i] == ' ')
					s[i] = filler;
			}

			next().put(env, s);
		}
		else
		{
			next().put(env, ostr.str());
		}
	}

	void put(Environment& env, mstl::string const& s)
	{
		Value adjust = env.associatedValue(m_adjustnum);

		if (adjust > Value(s.size()))
		{
			next().put(env, s);
			next().put(env, mstl::string(adjust - Value(s.size()), env.associatedValue(m_fillchar)));
		}
		else if (-adjust > Value(s.size()))
		{
			next().put(env, mstl::string((-adjust) - Value(s.size()), env.associatedValue(m_fillchar)));
			next().put(env, s);
		}
		else
		{
			next().put(env, s);
		}
	}

	Token::Type m_base;
	Token::Type m_fillchar;
	Token::Type m_adjustnum;
	Token::Type m_showpos;
};


struct Format::FormatFilter : public OutputFilter
{
	enum FormatCase { kIgnore, kUpper, kLower, };

	FormatFilter() :OutputFilter(1000) {}

	void put(Environment& env, unsigned char c)
	{
		switch (env.associatedValue(m_case))
		{
			case kLower:	c = ::tolower(c); break;
			case kUpper:	c = ::toupper(c); break;
			case kIgnore:	break;
		}

		next().put(env, c);
	}

	void put(Environment& env, mstl::string const& s)
	{
		switch (env.associatedValue(m_case))
		{
			case kLower:
				{
					mstl::string result(s);

					for (size_t i = 0; i < s.size(); ++i)
						result[i] = ::tolower(s[i]);

					next().put(env, result);
				}
				break;

			case kUpper:
				{
					mstl::string result(s);

					for (size_t i = 0; i < s.size(); ++i)
						result[i] = ::toupper(s[i]);

					next().put(env, result);
				}
				break;

			case kIgnore:
				next().put(env, s);
				break;
		}
	}

	Token::Type m_case;
};


Format::Format()
	:m_numberFilter(new NumberFilter)
	,m_formatFilter(new FormatFilter)
{
}


Format::~Format()
{
	// needed for ~FormatFilter
}


void
Format::performIgnorecase(Environment& env)
{
	env.associate(m_formatFilter->m_case, FormatFilter::kIgnore);
}


void
Format::performLowercase(Environment& env)
{
	env.associate(m_formatFilter->m_case, FormatFilter::kLower);
}


void
Format::performUppercase(Environment& env)
{
	env.associate(m_formatFilter->m_case, FormatFilter::kUpper);
}


void
Format::performShowpos(Environment& env)
{
	env.associate(m_numberFilter->m_showpos, true);
}


void
Format::performNoshowpos(Environment& env)
{
	env.associate(m_numberFilter->m_showpos, false);
}


void
Format::performDec(Environment& env)
{
	env.associate(m_numberFilter->m_base, NumberFilter::Dec);
}


void
Format::performOct(Environment& env)
{
	env.associate(m_numberFilter->m_base, NumberFilter::Oct);
}


void
Format::performHex(Environment& env)
{
	env.associate(m_numberFilter->m_base, NumberFilter::Hex);
}


void
Format::doRegister(Environment& env)
{
	env.pushFilter(m_numberFilter);
	env.pushFilter(m_formatFilter);

	m_numberFilter->m_base =
	bindMacro(env, new GenericFinalToken("\\dec",			Func(&Format::performDec, this)));
	env.bindMacro(new GenericFinalToken("\\hex",				Func(&Format::performHex, this)));
	env.bindMacro(new GenericFinalToken("\\oct",				Func(&Format::performOct, this)));
	m_formatFilter->m_case =
	bindMacro(env, new GenericFinalToken("\\ignorecase",	Func(&Format::performIgnorecase, this)));
	env.bindMacro(new GenericFinalToken("\\lowercase",		Func(&Format::performLowercase, this)));
	env.bindMacro(new GenericFinalToken("\\uppercase",		Func(&Format::performUppercase, this)));
	m_numberFilter->m_showpos =
	bindMacro(env, new GenericFinalToken("\\showpos",		Func(&Format::performShowpos, this)));
	env.bindMacro(new GenericFinalToken("\\noshowpos",		Func(&Format::performNoshowpos, this)));

	m_numberFilter->m_fillchar	=	bindMacro(env, new GenericValueToken("\\fillchar"));
	m_numberFilter->m_adjustnum	=	bindMacro(env, new GenericValueToken("\\adjustnum"));

	// initialise
	performDec(env);
	performIgnorecase(env);
}

// vi:set ts=3 sw=3:
