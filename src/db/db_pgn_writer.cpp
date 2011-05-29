// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
//    _/|            __
//   // o\         /    )           ,        /    /
//   || ._)    ----\---------__----------__-/----/__-
//   //__\          \      /   '  /    /   /    /   )
//   )___(     _(____/____(___ __/____(___/____(___/_
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

#include "db_pgn_writer.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_move.h"

#include "sys_utf8_codec.h"

#include "m_ostream.h"
#include "m_assert.h"

#include <string.h>
#include <stdlib.h>
#include <ctype.h>

using namespace db;


enum { IndentSize = 4, SpaceAfterBracket = 0 };


static mstl::string&
replaceCurlyBraces(mstl::string& s)
{
	mstl::string::size_type n = s.find_first_of("{}");

	while (n != mstl::string::npos)
	{
		// TODO: replace with \{, \} ?
		s[n] = (s[n] == '{' ? '[' : ']');
		n = s.find_first_of("{}", n + 1);
	}

	return s;
}


PgnWriter::PgnWriter(format::Type srcFormat,
							mstl::ostream& strm,
							mstl::string const& encoding,
							unsigned flags,
							unsigned lineLength)
	:Writer(srcFormat, flags, encoding)
	,m_strm(strm)
	,m_lineLength(lineLength)
	,m_length(0)
	,m_pendingSpace(0)
{
}


format::Type
PgnWriter::format() const
{
	return format::Pgn;
}


void
PgnWriter::putSpace()
{
	if (m_length > 0)
		m_pendingSpace = 1;
}


void
PgnWriter::putNewline()
{
	if (m_length)
	{
		if (m_pendingSpace)
			--m_pendingSpace;

		m_length = 0;
		m_strm.put('\n');
	}

	if (test(Flag_Indent_Variations))
		m_pendingSpace = variationLevel()*::IndentSize;
	else
		m_pendingSpace = 0;
}


void
PgnWriter::putDelim(char c)
{
	if (m_length >= m_lineLength)
		putNewline();

	m_length += m_pendingSpace + 1;

	while (m_pendingSpace)
	{
		m_strm.put(' ');
		--m_pendingSpace;
	}

	m_strm.put(c);
}


void
PgnWriter::putToken(char const* s, unsigned length)
{
	if (length == 0)
		return;

	if (m_length + length >= m_lineLength)
		putNewline();

	m_length += m_pendingSpace;

	while (m_pendingSpace)
	{
		m_strm.put(' ');
		--m_pendingSpace;
	}

	m_strm.write(s, length);
	m_length += length;
}


void
PgnWriter::putToken(mstl::string const& s)
{
	putToken(s, s.size());
}


void
PgnWriter::putTokens(mstl::string const& s)
{
	char const* p = s.c_str();
	char const* q = ::strchr(p, ' ');

	while (q)
	{
		while (*q == ' ')
			++q;

		putToken(p, q - p);
		p = q;
		q = ::strchr(p, ' ');
	}

	putToken(p, s.size() - (p - s.c_str()));
}


void
PgnWriter::writeBeginGame(unsigned number)
{
	if (number > 1 || test(Flag_Append_Games))
		m_strm.put('\n');

	m_pendingSpace = 0;
	m_length = 0;

	m_move.clear();
	m_annotation.clear();
	m_marks.clear();
}


void
PgnWriter::writeEndGame()
{
	m_strm.put('\n');
}


void
PgnWriter::writeTag(mstl::string const& name, mstl::string const& value)
{
	m_strm.write("[", 1);
	m_strm.write(name, name.size());
	m_strm.write(" \"", 2);
	m_strm.write(value, value.size());
	m_strm.write("\"]\n", 3);
}


void
PgnWriter::writeBeginMoveSection()
{
	m_strm.put('\n');
	m_length = 0;
}


void
PgnWriter::writeEndMoveSection(result::ID result)
{
	putSpace();
	putToken(result::toString(result));
	m_strm.put('\n');
}


void
PgnWriter::writeBeginComment()
{
	if (!insideComment())
		putDelim('{');
}


void
PgnWriter::writeEndComment()
{
	if (!insideComment())
		putDelim('}');
}


void
PgnWriter::writeComment(mstl::string const& comment)
{
	unsigned indent = mstl::numeric_limits<unsigned>::max();

	if (!insideComment())
	{
		if (m_length > 0 && test(Flag_Indent_Comments))
		{
			putNewline();
		}
		else
		{
			putSpace();
			indent = variationLevel()*::IndentSize;
		}
	}

	if (mstl::min(m_length, indent) + m_pendingSpace + comment.size() + 2 < m_lineLength)
	{
		if (m_length + m_pendingSpace + comment.size() + 2 >= m_lineLength)
			putNewline();

		m_length += m_pendingSpace;

		while (m_pendingSpace)
		{
			m_strm.put(' ');
			--m_pendingSpace;
		}

		m_strm.put(insideComment() ? ' ' : '{');
		m_strm.write(comment, comment.size());
		m_strm.put(insideComment() ? ' ' : '}');
		m_length += comment.size() + 2;
	}
	else
	{
		char const* s = comment.c_str();
		char const* e = s + comment.size();
		char const* t = s;

		while (t < e && *t == ' ')
			++t;
		while (t < e && *t != ' ')
			++t;

		unsigned length = t - s;

		if (m_length + length + m_pendingSpace + 1 + (t == e ? 1 : 0) >= m_lineLength)
		{
			if (insideComment())
				m_strm.put('\n');
			else
				putNewline();
		}

		m_length += m_pendingSpace;

		while (m_pendingSpace)
		{
			m_strm.put(' ');
			--m_pendingSpace;
		}

		if (!insideComment())
			m_strm.put('{');
		else if (m_length > 0)
			m_strm.put(' ');

		m_strm.write(s, t - s);
		m_length += t - s + 1;

		if ((s = t) == e)
		{
			m_strm.put(insideComment() ? ' ' : '}');
			++m_length;
		}
		else
		{
			while (s < e)
			{
				unsigned spaces = 0;

				for ( ; s < e && *s == ' '; ++s)
					++spaces;

				char const* t = s + 1;

				while (t < e && *t != ' ')
					++t;

				length = t - s;

				unsigned delim = (t == e && !insideComment() ? 1 : 0);

				if (m_length + length + spaces + delim >= m_lineLength)
				{
					m_strm.put('\n');
					m_length = 0;

					if (spaces)
						--spaces;
				}

				m_length += spaces;

				while (spaces--)
					m_strm.put(' ');

				m_strm.write(s, length);
				m_length += length;

				if ((s = t) == e)
				{
					m_strm.put(insideComment() ? ' ' : '}');
					++m_length;
				}
			}
		}
	}

	if (test(Flag_Indent_Comments))
		putNewline();
}


void
PgnWriter::writeComment(Comment const& comment)
{
	if (comment.isEmpty())
		return;

	mstl::string text;

	if (test(Flag_Comment_To_Html))
	{
		comment.toHtml(text);
	}
	else if (codec().isUtf8())
	{
		comment.flatten(text, encoding::Utf8);
	}
	else
	{
		comment.flatten(text, encoding::Latin1);
		codec().fromUtf8(text);
	}

	replaceCurlyBraces(text);
	writeComment(text);
	putSpace();
}


void
PgnWriter::writeMarks(MarkSet const& marks)
{
	if (!marks.isEmpty())
	{
		m_marks.clear();

		for (unsigned i = 0; i < marks.count(); ++i)
		{
			if (i > 0)
				m_marks += ' ';

			marks[i].toString(m_marks);
		}

		writeComment(m_marks);
	}
}


void
PgnWriter::writeComment(Comment const& comment, MarkSet const& marks)
{
	writeComment(comment);
	writeMarks(marks);
}


void
PgnWriter::writeMove(Move const& move,
							mstl::string const& moveNumber,
							Annotation const& annotation,
							MarkSet const& marks,
							Comment const& preComment,
							Comment const& comment)
{
	if (needSpace())
		putSpace();

	m_annotation.clear();
	m_move.clear();

	if (test(Flag_Space_After_Move_Number))
	{
		putToken(moveNumber);
		putSpace();
	}
	else
	{
		m_move += moveNumber;
	}

	move.printSan(m_move);

	if (!annotation.isEmpty())
	{
		unsigned f = 0;

		if (test(Flag_Symbolic_Annotation_Style))
			f |= Annotation::Flag_Symbolic_Annotation_Style;
		if (test(Flag_Extended_Symbolic_Annotation_Style))
			f |= Annotation::Flag_Extended_Symbolic_Annotation_Style;

		// XXX what should we do with non-PGN-Standard Nags (>= Pgn_Last) ?
		annotation.print(m_move, f);
	}

	writeComment(preComment);
	putToken(m_move);
	putTokens(m_annotation);
	writeComment(comment);
	writeMarks(marks);
}


void
PgnWriter::writeBeginVariation(unsigned)
{
	if (test(Flag_Indent_Variations))
	{
		m_pendingSpace = 0;
		putNewline();
		putDelim('(');
	}
	else
	{
		putSpace();
		putDelim('(');
		m_pendingSpace = 0;
	}

	if (::SpaceAfterBracket)
		putSpace();
}


void
PgnWriter::writeEndVariation(unsigned)
{
	if (::SpaceAfterBracket)
		putSpace();

	putDelim(')');

	if (test(Flag_Indent_Variations))
	{
		putNewline();
		m_pendingSpace -= ::IndentSize;
	}
}


void PgnWriter::start() {}
void PgnWriter::finish() {}

// vi:set ts=3 sw=3:
