// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "jpeg_base.h"

#include <string.h>
#include <stdio.h>

using namespace JPEG;


char Base::m_buffer[64];

namespace {

inline
bool
eq(unsigned char const* lhs, int lenLHS, char const* rhs, int lenRHS)
{
	return lenLHS >= lenRHS && ::memcmp(lhs, rhs, lenRHS) == 0;
}

} // namespace


int
Base::dstChannels(Colorspace colorspace)
{
	switch (colorspace)
	{
		case Unknown:		return 0;
		case Grayscale:	return 1;
		case GrayAlpha:	return 2;

		case RGB:			// fall thru
		case YCC:			// fall thru
		case PhotoYCC:		// fall thru
		case CMY:			// fall thru
		case YCCK_Adobe:	// fall thru
		case YCCK_JPEG:	// fall thru
		case CMYK_Adobe:	// fall thru
		case CMYK_JPEG:	return 3;

		case RGBA:			// fall thru
		case YCCA:			// fall thru
		case PhotoYCCA:	return 4;
	}

	return 0;	// not reached
}


int
Base::srcChannels(Colorspace colorspace)
{
	switch (colorspace)
	{
		case Unknown:		return 0;
		case Grayscale:	return 1;
		case GrayAlpha:	return 2;

		case RGB:			// fall thru
		case YCC:			// fall thru
		case PhotoYCC:		// fall thru
		case CMY:			return 3;

		case RGBA:			// fall thru
		case YCCA:			// fall thru
		case PhotoYCCA:	// fall thru
		case YCCK_Adobe:	// fall thru
		case YCCK_JPEG:	// fall thru
		case CMYK_Adobe:	// fall thru
		case CMYK_JPEG:	return 4;
	}

	return 0;	// not reached
}


bool
Base::hasAlphaChannel(Colorspace colorspace)
{
	switch (colorspace)
	{
		case Unknown:		// fall thru
		case Grayscale:	// fall thru
		case RGB:			// fall thru
		case YCC:			// fall thru
		case YCCK_Adobe:	// fall thru
		case YCCK_JPEG:	// fall thru
		case PhotoYCC:		// fall thru
		case CMY:			// fall thru
		case CMYK_Adobe:	// fall thru
		case CMYK_JPEG:	return false;

		case GrayAlpha:	// fall thru
		case RGBA:			// fall thru
		case YCCA:			// fall thru
		case PhotoYCCA:	return true;
	}

	return false;	// not reached
}


char const*
Base::colorspaceName(Colorspace colorspace)
{
	switch (colorspace)
	{
		case Unknown:		return "unknown";
		case Grayscale:	return "Grayscale";
		case GrayAlpha:	return "GrayAlpha";
		case RGB:			return "RGB";
		case RGBA:			return "RGBA";
		case YCC:			return "YCbCr";
		case YCCA:			return "YCbCrA";
		case YCCK_Adobe:	return "YCbCrK (Adobe)";
		case YCCK_JPEG:	return "YCbCrK (JPEG)";
		case PhotoYCC:		return "PhotoYCC";
		case PhotoYCCA:	return "PhotoYCCA";
		case CMY:			return "CMY";
		case CMYK_Adobe:	return "CMYK (Adobe)";
		case CMYK_JPEG:	return "CMYK (JPEG)";
	}

	return 0;	// not reached
}


bool
Base::isValidMarker(unsigned char marker)
{
	return 0xc0 <= marker;
}


char const*
Base::nameOfMarker(unsigned char marker)
{
	switch (marker)
	{
		case 0xc0: return "SOF0";
		case 0xc1: return "SOF1";
		case 0xc2: return "SOF2";
		case 0xc3: return "SOF3";
		case 0xc4: return "DHT";
		case 0xc5: return "SOF5";
		case 0xc6: return "SOF6";
		case 0xc7: return "SOF7";
		case 0xc8: return "JPG";
		case 0xc9: return "SOF9";
		case 0xca: return "SOF10";
		case 0xcb: return "SOF11";
		case 0xcc: return "DAC";
		case 0xcd: return "SOF13";
		case 0xce: return "SOF14";
		case 0xcf: return "SOF15";
		case 0xd0: return "RST0";
		case 0xd1: return "RST1";
		case 0xd2: return "RST2";
		case 0xd3: return "RST3";
		case 0xd4: return "RST4";
		case 0xd5: return "RST5";
		case 0xd6: return "RST6";
		case 0xd7: return "RST7";
		case 0xd8: return "SOI";
		case 0xd9: return "EOI";
		case 0xda: return "SOS";
		case 0xdb: return "DQT";
		case 0xdc: return "DNL";
		case 0xdd: return "DRI";
		case 0xde: return "DHP";
		case 0xdf: return "EXP";
		case 0xe0: return "APP0";
		case 0xe1: return "APP1";
		case 0xe2: return "APP2";
		case 0xe3: return "APP3";
		case 0xe4: return "APP4";
		case 0xe5: return "APP5";
		case 0xe6: return "APP6";
		case 0xe7: return "APP7";
		case 0xe8: return "APP8";
		case 0xe9: return "APP9";
		case 0xea: return "APP10";
		case 0xeb: return "APP11";
		case 0xec: return "APP12";
		case 0xed: return "APP13";
		case 0xee: return "APP14";
		case 0xef: return "APP15";
		case 0xf0: return "JPG0";
		case 0xf1: return "JPG1";
		case 0xf2: return "JPG2";
		case 0xf3: return "JPG3";
		case 0xf4: return "JPG4";
		case 0xf5: return "JPG5";
		case 0xf6: return "JPG6";
		case 0xf7: return "SOF48";
		case 0xf8: return "LSE";
		case 0xf9: return "JPG9";
		case 0xfa: return "JPG10";
		case 0xfb: return "JPG11";
		case 0xfc: return "JPG12";
		case 0xfd: return "JPG13";
		case 0xfe: return "COM";
		case 0xff: return "SOB";
	}

	snprintf(m_buffer, sizeof(m_buffer), "0X%x", int(marker));

	return m_buffer;
}


char const*
Base::descriptionOfMarker(unsigned char marker)
{
	switch (marker)
	{
		case 0xc0: return "Baseline DCT";
		case 0xc1: return "Extended Sequential DCT";
		case 0xc2: return "Progressive DCT";
		case 0xc3: return "Lossless (sequential)";
		case 0xc4: return "Define Huffman Table";
		case 0xc5: return "Differential sequential DCT";
		case 0xc6: return "Differential progressive DCT";
		case 0xc7: return "Differential lossless (sequential)";
		case 0xc8: return "JPEG Extensions";
		case 0xc9: return "Extended sequential DCT, Arithmetic coding";
		case 0xca: return "Progressive DCT, Arithmetic coding";
		case 0xcb: return "Lossless (sequential), Arithmetic coding";
		case 0xcc: return "Define Arithmetic Coding";
		case 0xcd: return "Differential sequential DCT, Arithmetic coding";
		case 0xce: return "Differential progressive DCT, Arithmetic coding";
		case 0xcf: return "Differential lossless (sequential), Arithmetic coding";
		case 0xd0: return "Restart Marker 0";
		case 0xd1: return "Restart Marker 1";
		case 0xd2: return "Restart Marker 2";
		case 0xd3: return "Restart Marker 3";
		case 0xd4: return "Restart Marker 4";
		case 0xd5: return "Restart Marker 5";
		case 0xd6: return "Restart Marker 6";
		case 0xd7: return "Restart Marker 7";
		case 0xd8: return "Start of Image";
		case 0xd9: return "End of Image";
		case 0xda: return "Start of Scan";
		case 0xdb: return "Define Quantization Table";
		case 0xdc: return "Define Number of Lines";
		case 0xdd: return "Define Restart Interval ";
		case 0xde: return "Define Hierarchical Progression";
		case 0xdf: return "Expand Reference Component";
		case 0xe0: return "Application Segment 0";
		case 0xe1: return "Application Segment 1";
		case 0xe2: return "Application Segment 2";
		case 0xe3: return "Application Segment 3";
		case 0xe4: return "Application Segment 4";
		case 0xe5: return "Application Segment 5";
		case 0xe6: return "Application Segment 6";
		case 0xe7: return "Application Segment 7";
		case 0xe8: return "Application Segment 8";
		case 0xe9: return "Application Segment 9";
		case 0xea: return "Application Segment 10";
		case 0xeb: return "Application Segment 11";
		case 0xec: return "Application Segment 12";
		case 0xed: return "Application Segment 13";
		case 0xee: return "Application Segment 14";
		case 0xef: return "Application Segment 15";
		case 0xf0: return "JPEG Extension 0";
		case 0xf1: return "JPEG Extension 1";
		case 0xf2: return "JPEG Extension 2";
		case 0xf3: return "JPEG Extension 3";
		case 0xf4: return "JPEG Extension 4";
		case 0xf5: return "JPEG Extension 5";
		case 0xf6: return "JPEG Extension 6";
		case 0xf7: return "Lossless JPEG";
		case 0xf8: return "Lossless JPEG Extension Parameters";
		case 0xf9: return "JPEG Extension 9";
		case 0xfa: return "JPEG Extension 10";
		case 0xfb: return "JPEG Extension 11";
		case 0xfc: return "JPEG Extension 12";
		case 0xfd: return "JPEG Extension 13";
		case 0xfe: return "Comment";
		case 0xff: return "(Stuff Byte)";
	}

	snprintf(m_buffer, sizeof(m_buffer), "Invalid Marker: 0X%x", int(marker));

	return m_buffer;
}


Base::Tag
Base::findTag(unsigned char marker, unsigned char const* tag, int lenOfTag)
{
	switch (marker)
	{
		case APP0:
			if (eq(tag, lenOfTag, "JFIF\0", 5)) return TagJFIF;
			if (eq(tag, lenOfTag, "JFXX\0", 5)) return TagJFXX;
			if (eq(tag + 6, lenOfTag - 6, "HEAPJPGM", 8)) return TagCIFF;
			break;

		case APP1:
			if (eq(tag, lenOfTag, "Exif\0", 5)) return TagEXIF;
			if (eq(tag, lenOfTag, "<exif:", 6)) return TagXMP;
			if (eq(tag, lenOfTag, "http://ns.adobe.com/xap/1.0/\0", 29)) return TagXMP;
			break;

		case APP2:
			if (eq(tag, lenOfTag, "ICC_PROFILE\0", 12)) return TagICCProfile;
			if (eq(tag, lenOfTag, "FPXR\0", 5)) return TagFlashPix;
			break;

		case APP3:
			if (eq(tag, lenOfTag, "Meta\0", 5)) return TagKodak;
			if (eq(tag, lenOfTag, "META\0", 5)) return TagKodak;
			if (eq(tag, lenOfTag, "Exif\0", 5)) return TagKodak;
			break;

		case APP5:
			if (eq(tag, lenOfTag, "RMETA\0", 6)) return TagRMETA;
			break;

		case APP6:
			if (eq(tag, lenOfTag, "EPPIM\0", 6)) return TagEPPIM;
			break;

		case APP8:
			if (eq(tag, lenOfTag, "SPIFF\0", 6)) return TagSPIFF;
			break;

		case APP10:
			if (eq(tag, lenOfTag, "UNICODE\0", 8)) return TagUnicode;
			break;

		case APP12:
			if (eq(tag, lenOfTag, "picture info", 12)) return TagPictureInfo;
			if (eq(tag, lenOfTag, "Type=", 5)) return TagPictureInfo;
			if (eq(tag, lenOfTag, "Ducky\0", 6)) return TagDucky;
			break;

		case APP13:
			if (eq(tag, lenOfTag, "Photoshop 3.0\0", 14)) return TagIRB;
			if (eq(tag, lenOfTag, "Adobe_Photoshop2.5:", 19)) return TagIRB;
			break;

		case APP14:
			if (eq(tag, lenOfTag, "Adobe", 5)) return TagAdobe;
			break;

		case APP15:
			if (eq(tag, lenOfTag, "GraphicConverter", 16)) return TagGraphicConverter;
			break;
	};

	return TagUnknown;
};


char const*
Base::tagDescription(Tag tag)
{
	switch (tag)
	{
		case TagJFIF:					return "JPEG File Interchange Format (JFIF)";
		case TagJFXX:					return "JPEG File Interchange Format Extension (JFXX)";
		case TagCIFF:					return "Camera Image File Format (CIFF)";
		case TagEXIF:					return "Exchangeable Image File Format (EXIF)";
		case TagXMP:					return "Adobe Extensible Metadata Platform (XMP)";
		case TagICCProfile:			return "ICC Color Profile";
		case TagFlashPix:				return "FlashPix Ready";
		case TagKodak:					return "Kodak Meta Info";
		case TagRMETA:					return "Ricoh RMETA";
		case TagEPPIM:					return "Toshiba PrintIM Info (EPPIM)";
		case TagSPIFF:					return "Still Picture Interchange File Format (SPIFF)";
		case TagUnicode:				return "PhotoStudio Unicode Comment";
		case TagPictureInfo:			return "ASCII-based Picture Info";
		case TagDucky:					return "Photoshop \"Save for Web\" Info (Ducky)";
		case TagIRB:					return "Photoshop Image Resource Block (IRB)";
		case TagAdobe:					return "Adobe DCT Filter Info";
		case TagGraphicConverter:	return "GraphicConverter Quality Info";
		case TagUnknown:				return "(Unknown)";
	}

	return "";	// not reached
};

// vi:set ts=3 sw=3:
