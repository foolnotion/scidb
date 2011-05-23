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

#include "db_pdf_writer.h"
#include "db_annotation.h"
#include "db_mark_set.h"
#include "db_move.h"

#include "hpdf.h"

#include "m_stdio.h"

using namespace db;


static void
errorHandler(HPDF_STATUS errorNo, HPDF_STATUS detailNo, void* user_data)
{
	static_cast<PdfWriter*>(user_data)->errorHandler(errorNo, PdfWriter::errorMessage(detailNo));
}


PdfWriter::PdfWriter(format::Type srcFormat,
							mstl::string fname,
							mstl::string const& encoding, unsigned flags)
	:Writer(srcFormat, flags, encoding)
	,m_fname(fname)
	,m_doc(HPDF_New(::errorHandler, this))
{
}


PdfWriter::~PdfWriter() throw()
{
	HPDF_Free(m_doc);
}


void
PdfWriter::writeTag(mstl::string const& name, mstl::string const& value)
{
}


void
PdfWriter::writeComment(Comment const& comment, MarkSet const& marks)
{
}


void
PdfWriter::writeMove(Move const& move,
							mstl::string const& moveNumber,
							Annotation const& annotation,
							MarkSet const& marks,
							Comment const& preComment,
							Comment const& comment)
{
}


void
PdfWriter::writeBeginGame(unsigned number)
{
}


void
PdfWriter::writeEndGame()
{
}


void
PdfWriter::writeBeginMoveSection()
{
}


void
PdfWriter::writeEndMoveSection(result::ID result)
{
}


void
PdfWriter::writeBeginVariation(unsigned level)
{
}


void
PdfWriter::writeEndVariation(unsigned level)
{
}


void
PdfWriter::writeBeginComment()
{
}


void
PdfWriter::writeEndComment()
{
}


void PdfWriter::start() {}


void
PdfWriter::finish()
{
	HPDF_SaveToFile(m_doc, m_fname);
}


void
PdfWriter::errorHandler(unsigned code, mstl::string const& message)
{
	::fprintf(stderr, "[%s] error %04X: %s\n", __func__, code, message.c_str());
}


mstl::string
PdfWriter::errorMessage(unsigned detailNo)
{
	switch (detailNo)
	{
		case 0x1004: return "The length of the data exceeds HPDF_LIMIT_MAX_STRING_LEN.";
		case 0x1005: return "Cannot get a pallet data from PNG image.";
		case 0x1007: return "The count of elements of a dictionary exceeds HPDF_LIMIT_MAX_DICT_ELEMENT";
		case 0x100B: return "HPDF_SetPermission() or HPDF_SetEncryptMode() was called "
									"before a password is set.";
		case 0x100E: return "Tried to register a font that has been registered.";
		case 0x100F: return "Cannot register a character to the japanese word wrap characters list.";
		case 0x1011: return "Tried to set the owner password to NULL.  "
									"The owner password and user password is the same.";
		case 0x1014: return "The depth of the stack exceeded HPDF_LIMIT_MAX_GSTATE.";
		case 0x1015: return "Memory allocation failed.";
		case 0x1016: return "File processing failed. (A detailed code is set.)";
		case 0x1017: return "Cannot open a file. (A detailed code is set.)";
		case 0x1019: return "Tried to load a font that has been registered.";
		case 0x101A: return "The format of a font-file is invalid .  "
									"Internal error. The consistency of the data was lost.";
		case 0x101B: return "Cannot recognize a header of an afm file.";
		case 0x101C: return "The specified annotation handle is invalid.";
		case 0x101E: return "Bit-per-component of a image which was set as mask-image is invalid.";
		case 0x101F: return "Cannot recognize char-matrics-data  of an afm file.";
		case 0x1020: return "1. The color_space parameter of HPDF_LoadRawImage is invalid.  "
									"2. Color-space of a image which was set as mask-image is invalid.  "
									"3. The function which is invalid in the present color-space was invoked.";
		case 0x1021: return "Invalid value was set when invoking HPDF_SetCommpressionMode().";
		case 0x1022: return "An invalid date-time value was set.";
		case 0x1023: return "An invalid destination handle was set.";
		case 0x1025: return "An invalid document handle is set.";
		case 0x1026: return "The function which is invalid in the present state was invoked.";
		case 0x1027: return "An invalid encoder handle is set.";
		case 0x1028: return "A combination between font and encoder is wrong.";
		case 0x102B: return "An Invalid encoding name is specified.";
		case 0x102C: return "The lengh of the key of encryption is invalid.";
		case 0x102D: return "1. An invalid font handle was set.  2. Unsupported font format.";
		case 0x102F: return "A font which has the specified name is not found.";
		case 0x1030: return "Unsupported image format.";
		case 0x1031: return "Unsupported image format.";
		case 0x1032: return "Cannot read a postscript-name from an afm file.";
		case 0x1033: return "1. An invalid object is set.  "
									"2. Internal error. The consistency of the data was lost.";
		case 0x1035: return "1. Invoked HPDF_Image_SetColorMask() against the image-object "
									"which was set a mask-image.";
		case 0x1036: return "An invalid outline-handle was specified.";
		case 0x1037: return "An invalid page-handle was specified.";
		case 0x1038: return "An invalid pages-handle was specified. (internel error)";
		case 0x1039: return "An invalid value is set.";
		case 0x103B: return "Invalid PNG image format.";
		case 0x103D: return "Internal error. The \"_FILE_NAME\" entry for delayed loading is missing.";
		case 0x103F: return "Invalid .TTC file format.";
		case 0x1040: return "The index parameter was exceed the number of included fonts";
		case 0x1041: return "Cannot read a width-data from an afm file.";
		case 0x1043: return "An error has returned from PNGLIB while loading an image.";
		case 0x104C: return "There are no graphics-states to be restored.";
		case 0x104E: return "The current font is not set.";
		case 0x104F: return "An invalid font-handle was spacified.";
		case 0x1050: return "An invalid font-size was set.";
		case 0x1051: return "See Graphics mode.";
		case 0x1053: return "The specified value is not a multiple of 90.";
		case 0x1054: return "An invalid page-size was set.";
		case 0x1055: return "An invalid image-handle was set.";
		case 0x1056: return "The specified value is out of range.";
		case 0x1057: return "The specified value is out of range.";
		case 0x1058: return "Unexpected EOF marker was detected.";
		case 0x105B: return "The length of the specified text is too long.";
		case 0x105C: return "The execution of a function was skipped because of other errors.";
		case 0x105D: return "This font cannot be embedded. (restricted by license)";
		case 0x105E: return "Unsupported ttf format. (cannot find unicode cmap.)";
		case 0x105F: return "Unsupported ttf format.";
		case 0x1060: return "Unsupported ttf format. (cannot find a necessary table)";
		case 0x1062: return "1. The library is not configured to use PNGLIB.  "
									"2. Internal error. The consistency of the data was lost.";
		case 0x1063: return "Unsupported Jpeg format.";
		case 0x1064: return "Failed to parse .PFB file.";
		case 0x1066: return "An error has occurred while executing a function of Zlib.";
		case 0x1067: return "An error returned from Zlib.";
		case 0x1068: return "An invalid URI was set.";
		case 0x1069: return "An invalid page-layout was set.";
		case 0x1070: return "An invalid page-mode was set.";
		case 0x1071: return "An invalid page-num-style was set.";
		case 0x1072: return "An invalid icon was set.";
		case 0x1073: return "An invalid border-style was set.";
		case 0x1074: return "An invalid page-direction was set.";
		case 0x1075: return "An invalid font-handle was specified.";

		case 0x1001: // fallthru
		case 0x1002: // fallthru
		case 0x1003: // fallthru
		case 0x1008: // fallthru
		case 0x1009: // fallthru
		case 0x100A: // fallthru
		case 0x1044: // fallthru
		case 0x1045: // fallthru
		case 0x1049: // fallthru
		case 0x104A: // fallthru
		case 0x104B: // fallthru
		case 0x1061: // fallthru
		case 0x100C: // fallthru
		case 0x1013: // fallthru
		case 0x102E: // fallthru
		case 0x1034: // fallthru
		case 0x103C: // fallthru
		case 0x1042: // fallthru
		case 0x104D: // fallthru
		case 0x1052: // fallthru
		case 0x1059: // fallthru
		case 0x1065: return "Internal error. The consistency of the data was lost.";
	}

	char buf[200];
	::snprintf(buf, sizeof(buf), "<unknown detail number %04X>", detailNo);
	return buf;
}

// vi:set ts=3 sw=3:
