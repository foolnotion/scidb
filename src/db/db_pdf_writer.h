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

#ifndef _db_pdf_writer_included
#define _db_pdf_writer_included

#include "db_writer.h"

#include "m_string.h"

extern "C" { struct _HPDF_Doc_Rec; }

namespace db {

class PdfWriter : public Writer
{
public:

	static unsigned const Default_Flags =	Flag_Include_Variations
													 | Flag_Include_Comments
													 | Flag_Indent_Variations;

	PdfWriter(	format::Type srcFormat,
					mstl::string fname,
					mstl::string const& encoding, unsigned flags = Default_Flags);
	~PdfWriter() throw();

	void writeTag(mstl::string const& name, mstl::string const& value) override;
	void writeComment(Comment const& comment, MarkSet const& marks) override;
	void writeMove(Move const& move,
						mstl::string const& moveNumber,
						Annotation const& annotation,
						MarkSet const& marks,
						Comment const& preComment,
						Comment const& comment) override;

	void writeBeginGame(unsigned number) override;
	void writeEndGame() override;
	void writeBeginMoveSection() override;
	void writeEndMoveSection(result::ID result) override;
	void writeBeginVariation(unsigned level) override;
	void writeEndVariation(unsigned level) override;
	void writeBeginComment() override;
	void writeEndComment() override;

	void start() override;
	void finish() override;

	virtual void errorHandler(unsigned code, mstl::string const& message);

	static mstl::string errorMessage(unsigned detailNo);

private:

	mstl::string	m_fname;
	mstl::string	m_move;
	mstl::string	m_annotation;
	mstl::string	m_marks;
	_HPDF_Doc_Rec*	m_doc;
};

} // namespace db

#endif // _db_pdf_writer_included

// vi:set ts=3 sw=3:
