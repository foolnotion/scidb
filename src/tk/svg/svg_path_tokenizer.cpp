// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

//----------------------------------------------------------------------------
// Anti-Grain Geometry - Version 2.3
// Copyright (C) 2002-2005 Maxim Shemanarev (http://www.antigrain.com)
//
// Permission to copy, use, modify, sell and distribute this software
// is granted provided this copyright notice appears in all copies.
// This software is provided "as is" without express or implied
// warranty, and with no claim as to its suitability for any purpose.
//
//----------------------------------------------------------------------------

// ======================================================================
// Copyright (C) 2008-2011 Gregor Cramer
// ======================================================================

#include "svg_path_tokenizer.h"
#include "svg_exception.h"

#include <string.h>
#include <stdlib.h>

using namespace svg;

char const path_tokenizer::s_commands[]	= "+-MmZzLlHhVvCcSsQqTtAaFfPp";
char const path_tokenizer::s_numeric[]		= ".Ee0123456789";
char const path_tokenizer::s_separators[]	= " ,\t\n\r";


path_tokenizer::path_tokenizer()
	:m_path(0)
	,m_last_number(0.0)
	,m_last_command(0)
{
	init_char_mask(m_commands_mask, s_commands);
	init_char_mask(m_numeric_mask, s_numeric);
	init_char_mask(m_separators_mask, s_separators);
}


void
path_tokenizer::set_path_str(char const* str)
{
	m_path = str;
	m_last_command = 0;
	m_last_number = 0.0;
}


void
path_tokenizer::init_char_mask(char* mask, char const* char_set)
{
	::memset(mask, 0, 256/8);

	while (*char_set)
	{
		unsigned c = unsigned(*char_set++) & 0xFF;
		mask[c >> 3] |= 1 << (c & 7);
	}
}


bool
path_tokenizer::next()
{
	if (m_path == 0)
		return false;

	// Skip all white spaces and other garbage
	while (*m_path && !is_command(*m_path) && !is_numeric(*m_path))
	{
		if (__builtin_expect(!is_separator(*m_path), 0))
			SVG_RAISE("path_tokenizer::next : invalid character %c", *m_path);

		m_path++;
	}

	if (*m_path == 0)
		return false;

	if (is_command(*m_path))
	{
		// Check if the command is a numeric sign character
		if(*m_path == '-' || *m_path == '+')
			return parse_number();

		m_last_command = *m_path++;

		while (*m_path && is_separator(*m_path))
			m_path++;

		if(*m_path == 0)
			return true;
	}

	return parse_number();
}


double
path_tokenizer::next(char cmd)
{
	if (__builtin_expect(!next(), 0))
		SVG_RAISE("parse_path: unexpected end of path");

	if (__builtin_expect(last_command() != cmd, 0))
		SVG_RAISE("parse_path: command '%c': bad or missing parameters", cmd);

	return last_number();
}


bool
path_tokenizer::parse_number()
{
	char buf[256]; // Should be enough for any number
	char* buf_ptr = buf;

	// Copy all sign characters
	while (buf_ptr < buf + (sizeof(buf) - 1) && (*m_path == '-' || *m_path == '+'))
		*buf_ptr++ = *m_path++;

	// Copy all numeric characters
	while (buf_ptr < buf + (sizeof(buf) - 1) && is_numeric(*m_path))
		*buf_ptr++ = *m_path++;

	*buf_ptr = 0;
	m_last_number = ::atof(buf);
	return true;
}

// vi:set ts=3 sw=3:
