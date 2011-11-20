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
		case HPDF_BINARY_LENGTH_ERR:					return "The length of the data exceeds HPDF_LIMIT_MAX_STRING_LEN.";
		case HPDF_CANNOT_GET_PALLET:					return "Cannot get a pallet data from PNG image.";
		case HPDF_DICT_COUNT_ERR:						return "The count of elements of a dictionary exceeds HPDF_LIMIT_MAX_DICT_ELEMENT";
		case HPDF_DOC_ENCRYPTDICT_NOT_FOUND:		return "HPDF_SetPermission() or HPDF_SetEncryptMode() was called before a password is set.";
		case HPDF_DUPLICATE_REGISTRATION:			return "Tried to register a font that has been registered.";
		case HPDF_EXCEED_JWW_CODE_NUM_LIMIT:		return "Cannot register a character to the japanese word wrap characters list.";
		case HPDF_ENCRYPT_INVALID_PASSWORD:			return	"1. Tried to set the owner password to NULL.\n"
																			"2. The owner password and user password is the same.";
		case HPDF_EXCEED_GSTATE_LIMIT:				return "The depth of the stack exceeded HPDF_LIMIT_MAX_GSTATE.";
		case HPDF_FAILD_TO_ALLOC_MEM:					return "Memory allocation failed.";
		case HPDF_FILE_IO_ERROR:						return "File processing failed. (A detailed code is set.)";
		case HPDF_FILE_OPEN_ERROR:						return "Cannot open a file. (A detailed code is set.)";
		case HPDF_FONT_EXISTS:							return "Tried to load a font that has been registered.";
		case HPDF_FONT_INVALID_WIDTHS_TABLE:		return	"1. The format of a font-file is invalid.\n"
																			"2. Internal error. The consistency of the data was lost.";
		case HPDF_INVALID_AFM_HEADER:					return "Cannot recognize a header of an afm file.";
		case HPDF_INVALID_ANNOTATION:					return "The specified annotation handle is invalid.";
		case HPDF_INVALID_BIT_PER_COMPONENT:		return "Bit-per-component of a image which was set as mask-image is invalid.";
		case HPDF_INVALID_CHAR_MATRICS_DATA:		return "Cannot recognize char-matrics-data  of an afm file.";
		case HPDF_INVALID_COLOR_SPACE:				return	"1. The color_space parameter of HPDF_LoadRawImage is invalid.\n"
																			"2. Color-space of a image which was set as mask-image is invalid.\n"
																			"3. The function which is invalid in the present color-space was invoked.";
		case HPDF_INVALID_COMPRESSION_MODE:			return "Invalid value was set when invoking HPDF_SetCommpressionMode().";
		case HPDF_INVALID_DATE_TIME:					return "An invalid date-time value was set.";
		case HPDF_INVALID_DESTINATION:				return "An invalid destination handle was set.";
		case HPDF_INVALID_DOCUMENT:					return "An invalid document handle was set.";
		case HPDF_INVALID_DOCUMENT_STATE:			return "The function which is invalid in the present state was invoked.";
		case HPDF_INVALID_ENCODER:						return "An invalid encoder handle was set.";
		case HPDF_INVALID_ENCODER_TYPE:				return "A combination between font and encoder is wrong.";
		case HPDF_INVALID_ENCODING_NAME:				return "An Invalid encoding name is specified.";
		case HPDF_INVALID_ENCRYPT_KEY_LEN:			return "The lengh of the key of encryption is invalid.";
		case HPDF_INVALID_FONTDEF_DATA:				return	"1. An invalid font handle was set.\n"
																			"2. Unsupported font format.";
		case HPDF_INVALID_FONT_NAME:					return "A font which has the specified name is not found.";
		case HPDF_INVALID_IMAGE:						return "Unsupported image format.";
		case HPDF_INVALID_JPEG_DATA:					return "Unsupported JPEG image format.";
		case HPDF_INVALID_N_DATA:						return "Cannot read a postscript-name from an afm file.";
		case HPDF_INVALID_OBJECT:						return	"1. An invalid object is set.\n"
																			"2. Internal error. The consistency of the data was lost.";
		case HPDF_INVALID_OPERATION:					return "Invoked HPDF_Image_SetColorMask() against the image-object which was set a mask-image.";
		case HPDF_INVALID_OUTLINE:						return "An invalid outline-handle was specified.";
		case HPDF_INVALID_PAGE:							return "An invalid page-handle was specified.";
		case HPDF_INVALID_PAGES:						return "An invalid pages-handle was specified. (internel error)";
		case HPDF_INVALID_PARAMETER:					return "An invalid value is set.";
		case HPDF_INVALID_PNG_IMAGE:					return "Invalid PNG image format.";
		case HPDF_MISSING_FILE_NAME_ENTRY:			return "Internal error. The \"_FILE_NAME\" entry for delayed loading is missing.";
		case HPDF_INVALID_TTC_FILE:					return "Invalid .TTC file format.";
		case HPDF_INVALID_TTC_INDEX:					return "The index parameter was exceed the number of included fonts.";
		case HPDF_INVALID_WX_DATA:						return "Cannot read a width-data from an afm file.";
		case HPDF_LIBPNG_ERROR:							return "An error has returned from PNGLIB while loading an image.";
		case HPDF_PAGE_CANNOT_RESTORE_GSTATE:		return "There are no graphics-states to be restored.";
		case HPDF_PAGE_FONT_NOT_FOUND:				return "The current font is not set.";
		case HPDF_PAGE_INVALID_FONT:					return "An invalid font-handle was spacified.";
		case HPDF_PAGE_INVALID_FONT_SIZE:			return "An invalid font-size was set.";
		case HPDF_PAGE_INVALID_GMODE:					return "See Graphics mode.";
		case HPDF_PAGE_INVALID_ROTATE_VALUE:		return "The specified value is not a multiple of 90.";
		case HPDF_PAGE_INVALID_SIZE:					return "An invalid page-size was set.";
		case HPDF_PAGE_INVALID_XOBJECT:				return "An invalid image-handle was set.";
		case HPDF_PAGE_OUT_OF_RANGE:					return "The specified value is out of range.";
		case HPDF_REAL_OUT_OF_RANGE:					return "The specified value is out of range.";
		case HPDF_STREAM_EOF:							return "Unexpected EOF marker was detected.";
		case HPDF_STRING_OUT_OF_RANGE:				return "The length of the specified text is too long.";
		case HPDF_THIS_FUNC_WAS_SKIPPED:				return "The execution of a function was skipped because of other errors.";
		case HPDF_TTF_CANNOT_EMBEDDING_FONT:		return "This font cannot be embedded (restricted by license).";
		case HPDF_TTF_INVALID_CMAP:					return "Unsupported ttf format (cannot find unicode cmap).";
		case HPDF_TTF_INVALID_FOMAT:					return "Unsupported ttf format.";
		case HPDF_TTF_MISSING_TABLE:					return "Unsupported ttf format (cannot find a necessary table).";
		case HPDF_UNSUPPORTED_FUNC:					return	"1. The library is not configured to use PNGLIB.\n"
																			"2. Internal error. The consistency of the data was lost.";
		case HPDF_UNSUPPORTED_JPEG_FORMAT:			return "Unsupported JPEG format.";
		case HPDF_UNSUPPORTED_TYPE1_FONT:			return "Failed to parse .PFB file.";
		case HPDF_ZLIB_ERROR:							return "An error has occurred while executing a function of Zlib.";
		case HPDF_INVALID_PAGE_INDEX:					return "An invalid page index was passed.";
		case HPDF_INVALID_URI:							return "An invalid URI was set.";
		case HPDF_PAGE_LAYOUT_OUT_OF_RANGE:			return "An invalid page-layout was set.";
		case HPDF_PAGE_MODE_OUT_OF_RANGE:			return "An invalid page-mode was set.";
		case HPDF_PAGE_NUM_STYLE_OUT_OF_RANGE:		return "An invalid page-num-style was set.";
		case HPDF_ANNOT_INVALID_ICON:					return "An invalid icon was set.";
		case HPDF_ANNOT_INVALID_BORDER_STYLE:		return "An invalid border-style was set.";
		case HPDF_PAGE_INVALID_DIRECTION:			return "An invalid page-direction was set.";
		case HPDF_INVALID_FONT:							return "An invalid font-handle was specified.";
		case HPDF_UNKOWN_FONT:							return "Font creation failed (unknown font)";
		case HPDF_FAMILY_NAME_TOO_LONG:				return "HPDF_GetTTFontDef() failed because family name is too long.";

		case HPDF_PAGE_INVALID_PARAM_COUNT:			return "HPDF_PAGE_INVALID_PARAM_COUNT: unspecified error.";
		case HPDF_PAGE_INSUFFICIENT_SPACE:			return "HPDF_PAGE_INSUFFICIENT_SPACE: unspecified error.";
		case HPDF_PAGE_INVALID_DISPLAY_TIME:		return "HPDF_PAGE_INVALID_DISPLAY_TIME: unspecified error.";
		case HPDF_PAGE_INVALID_TRANSITION_TIME:	return "HPDF_PAGE_INVALID_TRANSITION_TIME: unspecified error.";
		case HPDF_INVALID_PAGE_SLIDESHOW_TYPE:		return "HPDF_INVALID_PAGE_SLIDESHOW_TYPE: unspecified error.";
		case HPDF_EXT_GSTATE_OUT_OF_RANGE:			return "HPDF_EXT_GSTATE_OUT_OF_RANGE: unspecified error.";
		case HPDF_INVALID_EXT_GSTATE:					return "HPDF_INVALID_EXT_GSTATE: unspecified error.";
		case HPDF_EXT_GSTATE_READ_ONLY:				return "HPDF_EXT_GSTATE_READ_ONLY: unspecified error.";
		case HPDF_INVALID_U3D_DATA:					return "HPDF_INVALID_U3D_DATA: unspecified error.";
		case HPDF_NAME_CANNOT_GET_NAMES:				return "HPDF_NAME_CANNOT_GET_NAMES: unspecified error.";
		case HPDF_INVALID_ICC_COMPONENT_NUM:		return "HPDF_INVALID_ICC_COMPONENT_NUM: unspecified error.";

		case HPDF_ARRAY_COUNT_ERR:						// fallthru
		case HPDF_ARRAY_ITEM_NOT_FOUND:				// fallthru
		case HPDF_ARRAY_ITEM_UNEXPECTED_TYPE:		// fallthru
		case HPDF_DICT_ITEM_NOT_FOUND:				// fallthru
		case HPDF_DICT_ITEM_UNEXPECTED_TYPE:		// fallthru
		case HPDF_DICT_STREAM_LENGTH_NOT_FOUND:	// fallthru
		case HPDF_NAME_INVALID_VALUE:					// fallthru
		case HPDF_NAME_OUT_OF_RANGE:					// fallthru
		case HPDF_PAGES_MISSING_KIDS_ENTRY:			// fallthru
		case HPDF_PAGE_CANNOT_FIND_OBJECT:			// fallthru
		case HPDF_PAGE_CANNOT_GET_ROOT_PAGES:		// fallthru
		case HPDF_UNSUPPORTED_FONT_TYPE:				// fallthru
		case HPDF_DOC_INVALID_OBJECT:					// fallthru
		case HPDF_ERR_UNKNOWN_CLASS:					// fallthru
		case HPDF_INVALID_FONTDEF_TYPE:				// fallthru
		case HPDF_INVALID_OBJ_ID:						// fallthru
		case HPDF_INVALID_STREAM:						// fallthru
		case HPDF_ITEM_NOT_FOUND:						// fallthru
		case HPDF_PAGE_CANNOT_SET_PARENT:			// fallthru
		case HPDF_PAGE_INVALID_INDEX:					// fallthru
		case HPDF_STREAM_READLN_CONTINUE:			// fallthru
		case HPDF_XREF_COUNT_ERR:						return "Internal error. The consistency of the data was lost.";
	}

	char buf[200];
	::snprintf(buf, sizeof(buf), "<unknown detail number %04X>", detailNo);
	return buf;
}

// vi:set ts=3 sw=3:
