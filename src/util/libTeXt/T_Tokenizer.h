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

#ifndef _TeXt_Tokenizer_included
#define _TeXt_Tokenizer_included

#include "T_Input.h"

#include "m_ref_counted_ptr.h"
#include "m_string.h"
#include "m_stack.h"

namespace TeXt {


class Tokenizer
{
public:

	enum TokenType
	{
		Undefined,
		Number,
		Invalid,
		Parameter,
		Variable,
		LeftBrace,
		RightBrace,
		Char,
		EscapedChar,
		Unicode,
		Empty,
	};

	typedef mstl::ref_counted_ptr<Input>	InputP;
	typedef Input::Source						Source;

	Tokenizer();

	Source source() const;
	mstl::string currentDescription() const;
	unsigned lineno() const;
	unsigned stackSize() const;

	void pushInput(InputP const& input);
	void popInput();

	TokenType parseToken(mstl::string& name);

private:

	typedef mstl::stack<InputP> InputStack;
	typedef mstl::string::size_type size_type;

	bool advance();

	TokenType parseControlSequence(mstl::string& name);
	TokenType parseNumber(mstl::string& name);
	TokenType parseParameter(mstl::string& name);
	TokenType parseVariable(mstl::string& name);

	void fixLine();

	InputStack		m_inputStack;
	mstl::string	m_line;
	size_type		m_pos;
	size_type		m_offset;
	bool				m_skipSpaces;
};

} // namespace TeXt

#endif // _TeXt_Tokenizer_included

// vi:set ts=3 sw=3:
