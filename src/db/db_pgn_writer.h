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

#ifndef _db_pgn_writer_included
#define _db_pgn_writer_included

#include "db_writer.h"

namespace mstl { class ostream; }

namespace db {

class PgnWriter : public Writer
{
public:

	static unsigned const Mode_PGN_Standard	= 0;
	static unsigned const Mode_PGN_Extended	= 1;
	static unsigned const Mode_Extended			= 3;

	static unsigned const Default_Flags =	Flag_Include_Variations
													 | Flag_Include_Comments
													 | Flag_Include_Termination_Tag
													 | Flag_Include_Mode_Tag
													 | Flag_Include_Opening_Tag
													 | Flag_Include_Variation_Tag
													 | Flag_Include_Sub_Variation_Tag
													 | Flag_Indent_Variations
													 | Flag_Convert_Lost_Result_To_Comment;

	static unsigned const Flag_Append_Games = Flag_LAST << 1;

	PgnWriter(	format::Type srcFormat,
					mstl::ostream& strm,
					mstl::string const& encoding,
					unsigned flags = Default_Flags,
					unsigned lineLength = 80);

	format::Type format() const;

	void writeTag(mstl::string const& name, mstl::string const& value);
	void writeComment(Comment const& comment, MarkSet const& marks);
	void writeMove(Move const& move,
						mstl::string const& moveNumber,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& comment);

	void writeBeginGame(unsigned number);
	void writeEndGame();
	void writeBeginMoveSection();
	void writeEndMoveSection(result::ID result);
	void writeBeginVariation(unsigned level);
	void writeEndVariation(unsigned level);
	void writeBeginComment();
	void writeEndComment();

	void start();
	void finish();

private:

	void writeComment(mstl::string const& comment);

	void putSpace();
	void putNewline();
	void putToken(char const* s, unsigned length);
	void putToken(mstl::string const& s);
	void putTokens(mstl::string const& s);
	void putDelim(char c);

	mstl::ostream&	m_strm;
	mstl::string	m_move;
	mstl::string	m_annotation;
	mstl::string	m_marks;
	unsigned			m_lineLength;
	unsigned			m_length;
	unsigned			m_pendingSpace;
};

} // namespace db

#endif // _db_pgn_writer_included

// vi:set ts=3 sw=3:
