// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _jpeg_base_included
#define _jpeg_base_included

#include <stdint.h>

namespace JPEG {

typedef int16_t JPEGSample;

enum Colorspace
{
	Grayscale,
	GrayAlpha,
	RGB,
	RGBA,
	YCC,			// CCIR 601
	YCCA,			// CCIR 601
	YCCK_Adobe,	// CCIR 601
	YCCK_JPEG,	// CCIR 601
	PhotoYCC,
	PhotoYCCA,
	CMY,
	CMYK_Adobe,
	CMYK_JPEG,
	Unknown,
};

class Base
{
public:

	// constants
#if defined(JPEG_BGRA)
	enum { B, G, R, A };
#else // if defined(JPEG_RGBA)
	enum { R, G, B, A };
#endif

	enum Tag
	{
		TagUnknown,
		TagJFIF,
		TagJFXX,
		TagCIFF,
		TagEXIF,
		TagXMP,
		TagICCProfile,
		TagFlashPix,
		TagKodak,
		TagRMETA,
		TagEPPIM,
		TagSPIFF,
		TagUnicode,
		TagPictureInfo,
		TagDucky,
		TagIRB,
		TagAdobe,
		TagGraphicConverter,
	};

	// constants
	static int const DCTWidth			= 8;
	static int const DCTSize			= DCTWidth*DCTWidth;

	static int const MaxTagLength		= 29;

	static unsigned char const SOF0	= 0xc0;	// 192
	static unsigned char const SOF1	= 0xc1;	// 193
	static unsigned char const SOF2	= 0xc2;	// 194
	static unsigned char const SOF3	= 0xc3;	// 195
	static unsigned char const DHT	= 0xc4;	// 196
	static unsigned char const SOF5	= 0xc5;	// 197
	static unsigned char const SOF6	= 0xc6;	// 198
	static unsigned char const SOF7	= 0xc7;	// 199
	static unsigned char const JPG	= 0xc8;	// 200
	static unsigned char const SOF9	= 0xc9;	// 201
	static unsigned char const SOF10	= 0xca;	// 202
	static unsigned char const SOF11	= 0xcb;	// 203
	static unsigned char const SOF13	= 0xcd;	// 205
	static unsigned char const SOF14	= 0xce;	// 206
	static unsigned char const SOF15	= 0xcf;	// 207
	static unsigned char const RST0	= 0xd0;	// 208
	static unsigned char const RST1	= 0xd1;	// 209
	static unsigned char const RST2	= 0xd2;	// 210
	static unsigned char const RST3	= 0xd3;	// 211
	static unsigned char const RST4	= 0xd4;	// 212
	static unsigned char const RST5	= 0xd5;	// 213
	static unsigned char const RST6	= 0xd6;	// 214
	static unsigned char const RST7	= 0xd7;	// 215
	static unsigned char const SOI	= 0xd8;	// 216
	static unsigned char const EOI	= 0xd9;	// 217
	static unsigned char const SOS	= 0xda;	// 218
	static unsigned char const DQT	= 0xdb;	// 219
	static unsigned char const DNL	= 0xdc;	// 220
	static unsigned char const DRI	= 0xdd;	// 221
	static unsigned char const APP0	= 0xe0;	// 224
	static unsigned char const APP1	= 0xe1;	// 225
	static unsigned char const APP2	= 0xe2;	// 226
	static unsigned char const APP3	= 0xe3;	// 227
	static unsigned char const APP4	= 0xe4;	// 228
	static unsigned char const APP5	= 0xe5;	// 229
	static unsigned char const APP6	= 0xe6;	// 230
	static unsigned char const APP7	= 0xe7;	// 231
	static unsigned char const APP8	= 0xe8;	// 232
	static unsigned char const APP9	= 0xe9;	// 233
	static unsigned char const APP10	= 0xea;	// 234
	static unsigned char const APP11	= 0xeb;	// 235
	static unsigned char const APP12	= 0xec;	// 236
	static unsigned char const APP13	= 0xed;	// 237
	static unsigned char const APP14	= 0xee;	// 238
	static unsigned char const APP15	= 0xef;	// 239
	static unsigned char const SOF48	= 0xf7;	// 247
	static unsigned char const COM	= 0xfe;	// 254
	static unsigned char const SOB	= 0xff;	// 255

	// queries
	static bool isValidMarker(unsigned char marker);

	// accessors
	static char const* colorspaceName(Colorspace colorspace);
	static char const* tagDescription(Tag tag);
	static char const* nameOfMarker(unsigned char marker);
	static char const* descriptionOfMarker(unsigned char marker);
	static int srcChannels(Colorspace colorspace);
	static int dstChannels(Colorspace colorspace);
	static bool hasAlphaChannel(Colorspace colorspace);

	// searching
	static Tag findTag(unsigned char marker, unsigned char const* tag, int lenOfTag);

protected:

	static char m_buffer[64];
};

} // namespace JPEG

#endif // _jpeg_base_included

// vi:set ts=3 sw=3:
