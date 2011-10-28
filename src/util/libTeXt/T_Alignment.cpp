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

#include "T_Alignment.h"
#include "T_GenericFinalToken.h"
#include "T_GenericValueToken.h"
#include "T_ListToken.h"
#include "T_NumberToken.h"
#include "T_Environment.h"
#include "T_TokenP.h"
#include "T_OutputFilter.h"
#include "T_Messages.h"

#include "m_utility.h"
#include "m_iostream.h"
#include "m_assert.h"

#include <ctype.h>


using namespace TeXt;


static unsigned char const kNewline		= '\n';
static unsigned char const kLinefeed	= '\r';
static unsigned char const kTab			= '\t';
static unsigned char const kSpace		= ' ';


struct Alignment::AlignmentFilter : public OutputFilter
{
	enum Mode { kInsidePreamble, kInsideEverycr, kNormalText };

	typedef mstl::ref_counted_ptr<NumberToken> NumberP;

	static Value const kNull = 0;

	AlignmentFilter()
		:OutputFilter(100)
		,m_mode(kInsidePreamble)
		,m_previous(kNull)
		,m_lineno(new NumberToken(1))
		,m_everycr(Token::T_Undefined)
		,m_everycrContents(Token::T_Undefined)
	{
	}

	char previous() const
	{
		return m_previous;
	}

	void reset()
	{
		m_previous = kNull;
	}

	void put(Environment& env, unsigned char c) override
	{
		if (c == kLinefeed)
			c = kNewline;

		switch (m_mode)
		{
			case kInsidePreamble:
				if (::isspace(c))
				{
					if (c == kNewline)
						m_buffer.erase();
					else
						m_buffer += c;
				}
				else
				{
					m_mode = kNormalText;
					output(env, c, c);
				}
				break;

			case kInsideEverycr:
				output(env, c, c);
				break;

			case kNormalText:
				flushBuffer(env);

				if (m_previous == kNewline && c != kNewline)
				{
					try
					{
						TokenP indent = env.lookupMacro(m_indent);

						if (indent->type() == Token::T_Number && indent->value() > 0)
						{
							Value indentchar = env.associatedValue(m_indentchar);

							if (indentchar)
							{
								Value indentstep = mstl::max(env.associatedValue(m_indentstep), 1);
								m_previous = indentchar;
								next().put(env, mstl::string(indentstep*indent->value(), m_previous));
							}
						}

						m_mode = kInsideEverycr;

						TokenP everycr(env.getToken(m_everycrContents));

						if (!everycr->isEmpty())
						{
							if (env.associatedValue(Token::T_Tracingcommands) > 0)
							{
								Messages::logmessage(
									env,
									env.getToken(m_everycr)->name() + "->" + everycr->meaning() + "\n");
							}

							env.perform(everycr);
						}

						m_mode = kNormalText;
					}
					catch (...)
					{
						m_mode = kNormalText;
						throw;
					}
				}

				output(env, c, c);
				break;
		}
	}

	void put(Environment& env, mstl::string const& s) override
	{
		for (size_t i = 0; i < s.size(); ++i)
			put(env, static_cast<unsigned char>(s[i]));
	}

	void put(Environment& env, Value number) override
	{
		output(env, number, '0');
	}

	void flush(Environment& env)
	{
		if (m_previous != kNewline)
			env.filter().put(env, kNewline);
	}

	void flushBuffer(Environment& env)
	{
		if (!m_buffer.empty())
		{
			for (size_t i = 0; i < m_buffer.size(); ++i)
				next().put(env, static_cast<unsigned char>(m_buffer[i]));

			m_buffer.clear();
		}
	}

	template <class Value>
	void output(Environment& env, Value value, unsigned char c)
	{
		flushBuffer(env);
		m_previous = c;
		next().put(env, value);

		if (c == kNewline)
			m_lineno->increment();
	}

	Mode				m_mode;
	Value				m_previous;
	NumberP			m_lineno;
	mstl::string	m_buffer;
	Token::Type		m_everycr;
	Token::Type		m_everycrContents;
	Token::Type		m_indent;
	Token::Type		m_indentchar;
	Token::Type		m_indentstep;
};


Alignment::Alignment()
	:m_filter(new AlignmentFilter)
{
}


Alignment::~Alignment()
{
	// needed for ~AlignmentFilter
}


void
Alignment::doFinish(Environment& env)
{
	m_filter->flush(env);
}


void
Alignment::performCrcr(Environment& env)
{
	if (m_filter->previous() != kNewline)
		env.filter().put(env, kNewline);
}


void
Alignment::performSpace(Environment& env)
{
	if (m_filter->previous() != kSpace && m_filter->previous() != kTab)
		env.filter().put(env, kSpace);
}


void
Alignment::performTab(Environment& env)
{
	if (m_filter->previous() != kSpace && m_filter->previous() != kTab)
		env.filter().put(env, kTab);
}


void
Alignment::performEps(Environment&)
{
	m_filter->reset();
}


void
Alignment::performEverycr(Environment& env)
{
	TokenP token = env.getUndefinedToken();

	if (token->type() == Token::T_LeftBrace)
		token.reset(new ListToken(env));	// MEMORY

	env.bindMacro(m_filter->m_everycrContents, token);
}


void
Alignment::doRegister(Environment& env)
{
	env.pushFilter(m_filter);

	env.bindMacro(new GenericFinalToken("\\crcr",			Func(&Alignment::performCrcr, this)));
	env.bindMacro(new GenericFinalToken("\\space",			Func(&Alignment::performSpace, this)));
	env.bindMacro(new GenericFinalToken("\\tab",				Func(&Alignment::performTab, this)));
	env.bindMacro(new GenericFinalToken("\\eps",				Func(&Alignment::performEps, this)));
	m_filter->m_everycr =
	env.bindMacro(new GenericFinalToken("\\everycr",		Func(&Alignment::performEverycr, this)));

	env.bindMacro("\\lineno", m_filter->m_lineno);
	m_filter->m_everycrContents = env.bindMacro("everycr", new ListToken);
	m_filter->m_indent = env.bindMacro("\\indent", env.numberToken(0));
	m_filter->m_indentchar = env.bindMacro(new GenericValueToken("\\indentchar"));
	m_filter->m_indentstep = env.bindMacro(new GenericValueToken("\\indentstep"));
}

// vi:set ts=3 sw=3:
