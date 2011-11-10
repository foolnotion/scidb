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

#include "T_Tokenizer.h"
#include "T_Token.h"

#include "m_assert.h"

#include <ctype.h>


using namespace TeXt;


Tokenizer::Tokenizer()
	:m_pos(0)
	,m_offset(0)
	,m_skipSpaces(false)
{
}


void
Tokenizer::pushInput(InputP const& input)
{
	M_REQUIRE(input);
	m_inputStack.push(input);
}


void
Tokenizer::popInput()
{
	if (!m_inputStack.empty())
		m_inputStack.pop();
}


unsigned
Tokenizer::stackSize() const
{
	return m_inputStack.size();
}


void
Tokenizer::fixLine()
{
	m_line += '\n';
	m_offset = 0;

	while (m_offset < m_line.size() && ::isspace(m_line[m_offset]))
		++m_offset;

	if (m_offset == m_line.size())
	{
		m_line = "\n";
	}
	else
	{
		mstl::string::size_type m = m_offset;

//		if (m_line[m] == '^')
//			++m;

		if (m > 0)
			m_line.erase(mstl::string::size_type(0), m);

		mstl::string::size_type n = 0;
		m = mstl::string::npos;

		while (n < m_line.size() - 1)
		{
			switch (m_line[n])
			{
				case '%':
					m_line.erase(n);
					return;

//				case '$':
//					m_line.erase(n);
//					return;

				case Token::EscapeChar:
					n += 2;
					m = mstl::string::npos;
					break;

				default:
					if (!::isspace(m_line[n]))
						m = mstl::string::npos;
					else if (m == mstl::string::npos)
						m = n;
					++n;
					break;
			}
		}

		if (m != mstl::string::npos)
			m_line.erase(m, m_line.size() - m - 1);
	}
}


Tokenizer::Source
Tokenizer::source() const
{
	return m_inputStack.empty() ? Producer::Insert : m_inputStack.top()->source();
}


mstl::string
Tokenizer::currentDescription() const
{
	mstl::string result;

	if (!m_inputStack.empty())
	{
		unsigned pos = mstl::min(m_pos + m_offset, m_line.size());

		result += m_line.substr(0, pos);

		if (pos + 1 < m_line.size())
		{
			result += "\n";
			result += m_line.substr(pos);
		}
	}

	return result;
}


unsigned
Tokenizer::lineno() const
{
	return m_inputStack.empty() ? 0 : m_inputStack.top()->lineno();
}


bool
Tokenizer::advance()
{
	bool rc;

	unsigned skipSpaces = m_skipSpaces ? 2 : 0;
	m_skipSpaces = false;

	do
	{
		while (m_pos >= m_line.size())
		{
			if (m_inputStack.empty())
				return false;

			while (!m_inputStack.top()->nextLine(m_line))
			{
				m_pos = mstl::string::npos;
				m_inputStack.pop();

				if (m_inputStack.empty())
					return false;
			}

			fixLine();
			m_pos = 0;
		}

		if (skipSpaces)
		{
			while (m_pos < m_line.size() && ::isspace(m_line[m_pos]))
				++m_pos;

			if (m_pos < m_line.size())
				skipSpaces = 0;
			else if (m_pos > 0 && m_line[m_pos - 1] == '\n' && --skipSpaces == 0)
				--m_pos;
		}
	}
	while (skipSpaces);

	M_ASSERT(m_pos < m_line.size());

	rc = true;

	return rc;
}


Tokenizer::TokenType
Tokenizer::parseControlSequence(mstl::string& name)
{
	mstl::string::size_type pos = m_pos;

	do
		++m_pos;
	while (::isalnum(m_line[m_pos]) || m_line[m_pos] == '-');

	while (m_line[m_pos - 1] == '-')
		--m_pos;

	m_skipSpaces = true;
	name = m_line.substr(pos, m_pos - pos);

	return Undefined;
}


Tokenizer::TokenType
Tokenizer::parseNumber(mstl::string& name)
{
	mstl::string::size_type pos = ++m_pos;

	do
		++m_pos;
	while (::isdigit(m_line[m_pos]));

	m_skipSpaces = true;
	name.assign(m_line.c_str() + pos, m_pos - pos);

	return Number;
}


Tokenizer::TokenType
Tokenizer::parseParameter(mstl::string& name)
{
	mstl::string::size_type pos = m_pos;

	do
		++m_pos;
	while (m_line[m_pos] == Token::ParamChar);

	if (::isdigit(m_line[m_pos]))
	{
		do
			++m_pos;
		while (::isdigit(m_line[m_pos]));
	}
	else if (::isalpha(m_line[m_pos]))
	{
		do
			++m_pos;
		while (::isalnum(m_line[m_pos]) || m_line[m_pos] == '-');

		while (m_line[m_pos - 1] == '-')
			--m_pos;
	}
	else
	{
		m_pos = pos + 1;
		name.assign(1, Token::ParamChar);

		return Invalid;
	}

	name = m_line.substr(pos, m_pos - pos);

	return Parameter;
}


Tokenizer::TokenType
Tokenizer::parseVariable(mstl::string& name)
{
	mstl::string::size_type pos = m_pos;

	do
		++m_pos;
	while (m_line[m_pos] == Token::VarChar);

	if (::isalpha(m_line[m_pos]))
	{
		do
			++m_pos;
		while (::isalnum(m_line[m_pos]) || m_line[m_pos] == '-');

		while (m_line[m_pos - 1] == '-')
			--m_pos;
	}
	else
	{
		m_pos = pos + 1;
		name.assign(1, Token::ParamChar);

		return Invalid;
	}

	name = m_line.substr(pos, m_pos - pos);
	m_skipSpaces = true;

	return Variable;
}


Tokenizer::TokenType
Tokenizer::parseToken(mstl::string& name)
{
	if (!advance())
		return Empty;

	M_ASSERT(!m_line.empty());

	// Comment:				'%' (~['\n'])* '\n'
	// Identifier:			[a-zA-Z] | [a-zA-Z] [a-za-Z0-9-]* [a-zA-Z0-9]
	// ControlSequence:	'\' Identifier
	// Parameter:			'#'+ Identifier
	// Variable:			'@' + Identifier
	//	EscapedAlpha:		'\' ~[a-zA-Z0-9+-]
	// LeftBrace:			'{'
	// RightBrace:			'}'
	//	Alpha					~[%#\{}]

	TokenType result;

	switch (m_line[m_pos])
	{
		case Token::LBraceChar:
			result = LeftBrace;
			++m_pos;
			break;

		case Token::RBraceChar:
			result = RightBrace;
			++m_pos;
			break;

		case Token::EscapeChar:
			if (::isalpha(m_line[m_pos + 1]))
			{
				result = parseControlSequence(name);
			}
			else if (	::isdigit(m_line[m_pos + 1])
						|| (	(m_line[m_pos + 1] == '-' || m_line[m_pos + 1] == '+')
							&& ::isdigit(m_line[m_pos + 2])))
			{
				result = parseNumber(name);
			}
			else
			{
				name = m_line[m_pos + 1];
				result = EscapedChar;
				m_pos += 2;
			}
			break;

		case Token::ParamChar:
			result = parseParameter(name);
			break;

		case Token::VarChar:
			result = parseVariable(name);
			break;

		case '%':
			M_RAISE("should not be reached");
			result = Empty;
			break;

		case '^':
			if (	m_pos + 2 < m_line.size()
				&& m_line[m_pos + 1] == '^'
				&& 64 <= m_line[m_pos + 2]
				&& m_line[m_pos + 2] <= 96)
			{
				char c = m_line[m_pos + 2] - 64;

				if (c == '\r')
					c = '\n';

				name = c;
				result = Char;
				m_pos += 3;
			}
			else
			{
				name = m_line[m_pos++];
				result = Invalid;
			}
			break;

		default:
			{
				char c = m_line[m_pos++];

				if ((c & 0x80) == 0)
				{
					name = c;
					result = Char;
				}
				else
				{
					name += c;

					while (((c = m_line[m_pos]) & 0xc0) == 0x80)
					{
						name += c;
						++m_pos;
					}

					result = Unicode;
				}
			}
			break;
	}

	return result;
}

// vi:set ts=3 sw=3:
