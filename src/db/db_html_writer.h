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

#ifndef _db_hrml_writer_included
#define _db_html_writer_included

#include "db_writer.h"

#include "m_string.h"
#include "m_scoped_ptr.h"

namespace TeXt { class Controller; }

namespace db {

class HtmlWriter : public Writer
{
public:

	static unsigned const Default_Flags =	Flag_Include_Variations
													 | Flag_Include_Comments
													 | Flag_Indent_Variations;

	HtmlWriter(	format::Type srcFormat,
					mstl::string fname,
					mstl::string const& encoding, unsigned flags = Default_Flags);
	~HtmlWriter() throw();

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

	typedef mstl::scoped_ptr<TeXt::Controller> ControllerP;

	ControllerP		m_controller;
	mstl::string	m_fname;
	mstl::string	m_move;
	mstl::string	m_annotation;
	mstl::string	m_marks;
};

} // namespace db

#endif // _db_html_writer_included

// vi:set ts=3 sw=3:
