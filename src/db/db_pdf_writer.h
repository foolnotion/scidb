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
#include "db_common.h"

#include "m_string.h"

extern "C" { struct _HPDF_Doc_Rec; }
extern "C" { struct _HPDF_Dict_Rec; }

namespace db {

class Board;

class PdfWriter : public Writer
{
public:

	static unsigned const Default_Flags =	Flag_Include_Variations
													 | Flag_Include_Comments
													 | Flag_Indent_Variations;

	PdfWriter(	format::Type srcFormat,
					mstl::string fname,
					mstl::string const& encoding,
					unsigned flags = Default_Flags);
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

	enum Style
	{
		// Game Info
		GameInfo,

		// Game Text - Moves
		Move_Text_MainLine,
		Move_Text_Variation,
		Move_Text_SubVariation,
		Move_Figurine_MainLine,
		Move_Figurine_Variation,
		Move_Figurine_SubVariation,
		Move_Symbol_MainLine,
		Move_Symbol_Variation,
		Move_Symbol_SubVariation,

		// Game Text - Comments
		Comment_MainLine,
		Comment_Variation,
		Comment_SubVariation,

		// Game Text - Result
		Result,

		// Diagram
		Diagram,

		// MARKER
		LAST,
	};

	enum Part
	{
		Piece_LiteWK = piece::WK,
		Piece_LiteWQ = piece::WQ,
		Piece_LiteWR = piece::WR,
		Piece_LiteWB = piece::WB,
		Piece_LiteWN = piece::WN,
		Piece_LiteWP = piece::WP,

		Piece_LiteBK = piece::BK,
		Piece_LiteBQ = piece::BQ,
		Piece_LiteBR = piece::BR,
		Piece_LiteBB = piece::BB,
		Piece_LiteBN = piece::BN,
		Piece_LiteBP = piece::BP,

		Piece_DarkWK = piece::WK << 4,
		Piece_DarkWQ = piece::WQ << 4,
		Piece_DarkWR = piece::WR << 4,
		Piece_DarkWB = piece::WB << 4,
		Piece_DarkWN = piece::WN << 4,
		Piece_DarkWP = piece::WP << 4,

		Piece_DarkBK = piece::BK << 4,
		Piece_DarkBQ = piece::BQ << 4,
		Piece_DarkBR = piece::BR << 4,
		Piece_DarkBB = piece::BB << 4,
		Piece_DarkBN = piece::BN << 4,
		Piece_DarkBP = piece::BP << 4,

		Square_Lite = piece::Empty,
		Square_Dark = 255,

		Border_Top         = 240,
		Border_Bottom      = 241,
		Border_Left        = 242,
		Border_Right       = 243,
		Border_TopLeft     = 244,
		Border_TopRight    = 245,
		Border_BottomLeft  = 246,
		Border_BottomRight = 247,
	};

	void writeDiagram(Board const& board, double x0, double y0);
	void setFont(Style style);
	void loadImages();

	void loadImage(Part part,
						mstl::string const& style,
						mstl::string const& pieceSet,
						mstl::string const& id);
	void loadPiece(Part part, mstl::string const& id);
	void loadSquare(Part part, mstl::string const& id);
	void loadBorder(Part part, mstl::string const& id);

	mstl::string		m_fname;
	mstl::string		m_move;
	mstl::string		m_annotation;
	mstl::string		m_marks;
	_HPDF_Doc_Rec*		m_doc;
	_HPDF_Dict_Rec*	m_page;
	_HPDF_Dict_Rec*	m_font[LAST];
	unsigned				m_fontSize[LAST];
	_HPDF_Dict_Rec*	m_image[256];
	Style					m_currentStyle;
	mstl::string		m_imagePath;
	mstl::string		m_boardStyle;
	mstl::string		m_pieceSet;
};

} // namespace db

#include "db_pdf_writer.ipp"

#endif // _db_pdf_writer_included

// vi:set ts=3 sw=3:
