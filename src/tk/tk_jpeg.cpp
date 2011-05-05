// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2008-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "jpeg_image.h"
#include "jpeg_reader.h"
#include "jpeg_exception.h"

#include <string.h>
#include <assert.h>

#include <tcl.h>
#include <tk.h>

extern "C" { static Tcl_FreeProc* __tcl_static = TCL_STATIC; }


namespace {

enum
{
	B64_Special	= 0x80,
	B64_Space	= 0x80,
	B64_Pad		= 0x81,
	B64_Done		= 0x82,
	B64_Bad		= 0x83,
};


static unsigned char Base64Tbl[256] =
{
//  NUL   SOH   STX   ETX   EOT   ENQ   ACK   BEL    BS    HT    LF    VT    FF    CR    SO    SI
	0x82, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x80, 0x80, 0x83, 0x80, 0x80, 0x83, 0x83,
//  DLE   DC1   DC2   DC3   DC4   NAK   SYN   ETB   CAN    EM   SUB   ESC    FS    GS    RS    US
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
//         !     "     #     $     %     &     '     (     )     *     +     ,     -     .     /
	0x80, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x3e, 0x83, 0x83, 0x83, 0x3f,
//   0     1     2     3     4     5     6     7     8     9     :     ;     <     =     >     ?
	0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x83, 0x83, 0x83, 0x81, 0x83, 0x83,
//   @     A     B     C     D     E     F     G     H     I     J     K     L     M     N     O
	0x83, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
//   P     Q     R     S     T     U     V     W     X     Y     Z     [     \     ]     ^     _
	0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x83, 0x83, 0x83, 0x83, 0x83,
//   `     a     b     c     d     e     f     g     h     i     j     k     l     m     n     o
	0x83, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
//   p     q     r     s     t     u     v     w     x     y     z     {     |     }     ~    DEL
	0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x83, 0x83, 0x83, 0x83, 0x83,
// 128 .. 255
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
	0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83, 0x83,
};


template <typename T> T min(T a, T b) { return a < b ? a : b; }


struct StringReader : public JPEG::Reader
{
	StringReader(unsigned char const* first, unsigned char const* last);

	size_t read(unsigned char* buf, size_t len);
	bool skip(size_t nbytes);

	unsigned char const*	m_current;
	unsigned char const*	m_end;
};


StringReader::StringReader(unsigned char const* first, unsigned char const* last)
	:m_current(first)
	,m_end(last)
{
}


size_t
StringReader::read(unsigned char* buf, size_t len)
{
	size_t nbytes = ::min(size_t(m_end - m_current), len);
	::memcpy(buf, m_current, nbytes);
	m_current += nbytes;
	return nbytes;
}


bool
StringReader::skip(size_t nbytes)
{
	size_t n = ::min(size_t(m_end - m_current), nbytes);
	m_current += n;
	return n == nbytes;
}


struct Base64Reader : public JPEG::Reader
{
	Base64Reader(unsigned char const* first, unsigned char const* last);

	size_t read(unsigned char* buf, size_t len);
	bool skip(size_t nbytes);

	void reset();

	unsigned char const*	m_base;
	unsigned char const*	m_current;
	unsigned char const*	m_end;
	unsigned char			m_last;
	unsigned					m_state;
};


Base64Reader::Base64Reader(unsigned char const* first, unsigned char const* last)
	:m_base(first)
	,m_current(first)
	,m_end(last)
	,m_last(0)
	,m_state(0)
{
}


void
Base64Reader::reset()
{
	m_current = m_base;
	m_last = 0;
	m_state = 0;
}


size_t
Base64Reader::read(unsigned char* buf, size_t len)
{
	unsigned char* p = buf;
	unsigned char* e = buf + len;

	for ( ; p < e && m_current < m_end; ++m_current)
	{
		unsigned char c64 = Base64Tbl[*m_current];

		if (__builtin_expect(c64 & B64_Special, 0))
		{
#ifdef NDBUG
			// ignore character
#else
			switch (c64)
			{
				case B64_Pad:
					if (m_last)
						throw JPEG::Exception("couldn't recognize image data");
					break;

				case B64_Space:	break;	// ignore spaces
				case B64_Done:		throw JPEG::Exception("unexpected nul byte in Base-64 stream");
				default:				throw JPEG::Exception("illegal character in Base-64 stream");
			}
#endif
		}
		else
		{
			switch (m_state++)
			{
				case 0:
					m_last = c64 << 2;
					break;

				case 1:
					*p++ = m_last | (c64 >> 4);
					m_last = (c64 & 0xF) << 4;
					break;

				case 2:
					*p++ = m_last | (c64 >> 2);
					m_last = (c64 & 0x3) << 6;
					break;

				case 3:
					*p++ = m_last | c64;
					m_last = m_state = 0;
					break;
			}
		}
	}

	return p - buf;
}


bool
Base64Reader::skip(size_t nbytes)
{
	for ( ; nbytes && m_current < m_end; ++m_current)
	{
		unsigned char c64 = Base64Tbl[*m_current];

		if (__builtin_expect(c64 & B64_Special, 0))
		{
#ifdef NDBUG
			// ignore character
#else
			switch (c64)
			{
				case B64_Pad:
					if (m_last == 0)
						throw JPEG::Exception("incomplete Base-64 stream");
					break;

				case B64_Space:	break; // ignore spaces
				case B64_Done:		throw JPEG::Exception("unexpected nul byte in Base-64 stream");
				default:				throw JPEG::Exception("illegal character in Base-64 stream");
			}
#endif
		}
		else
		{
			switch (m_state++)
			{
				case 0:
					m_last = c64 << 2;
					break;

				case 1:
					m_last = (c64 & 0xF) << 4;
					--nbytes;
					break;

				case 2:
					m_last = (c64 & 0x3) << 6;
					--nbytes;
					break;

				case 3:
					m_last = m_state = 0;
					--nbytes;
					break;
			}
		}
	}

	return nbytes == 0;
}


struct ChannelReader : public JPEG::Reader
{
	ChannelReader(Tcl_Channel channel);

	size_t read(unsigned char* buf, size_t len);
	bool skip(size_t nbytes);

	::Tcl_Channel m_chan;
};


ChannelReader::ChannelReader(Tcl_Channel channel)
	:m_chan(channel)
{
}


size_t
ChannelReader::read(unsigned char* buf, size_t len)
{
	if (::Tcl_Eof(m_chan))
		return 0;

	int nbytes = ::Tcl_Read(m_chan, reinterpret_cast<char*>(buf), len);

	if (__builtin_expect(nbytes < 0, 0))
		throw JPEG::Exception("channel read failed");

	return nbytes;
}


bool
ChannelReader::skip(size_t nbytes)
{
	if (::Tcl_Eof(m_chan))
		return false;

	return ::Tcl_Seek(m_chan, nbytes, SEEK_CUR) == nbytes;
}

} // namespace


static int
handle_exception(Tcl_Interp* ti, JPEG::Exception const& exc)
{
	static char msg[1024];
	strncpy(msg, exc.what(), sizeof(msg));
	msg[sizeof(msg) - 1] = '\0';
	Tcl_SetResult(ti, msg, __tcl_static);
	return TCL_ERROR;
}


static int
process_image(	Tcl_Interp* ti,
					JPEG::Reader& reader,
					Tk_PhotoHandle image_handle,
					int width, int height,
					int src_x, int src_y,
					int dst_x, int dst_y)
{
	if (width <= 0 || height <= 0)
		return TCL_OK;

	// TODO
	// should have an option like "-fancy";
	// at the moment we always want fancy upsampling (but only 2h:1v is working!)
	JPEG::Image image(true);
	image.processHeader(reader);

	if (src_x >= image.width() || src_y >= image.height())
		return TCL_OK;
	if (src_x + width > image.width())
		width = image.width() - src_x;
	if (src_y + width > image.height())
		height = image.height() - src_y;

	if (Tk_PhotoExpand(ti, image_handle, dst_x + width, dst_y + height) == TCL_ERROR)
		return TCL_ERROR;

	image.process(reader);

	Tk_PhotoImageBlock block;
	block.pixelSize = image.bytesPerPixel();
	block.width = width;
	block.height = height;
	block.pitch = image.pitch();
	image.getOffsets(block.offset);

	block.pixelPtr =
		const_cast<unsigned char*>(image.data()) + src_y*block.pitch + src_x*block.pixelSize;

	return Tk_PhotoPutBlock(ti,
									image_handle,
									&block,
									dst_x,
									dst_y,
									width,
									height,
									TK_PHOTO_COMPOSITE_SET);

	return TCL_OK;
}


static int
process_header(Tcl_Interp*, JPEG::Reader& reader, int* width, int* height)
{
	assert(width);
	assert(height);

	JPEG::Image image;

	if (image.processHeader(reader))
	{
		*width = image.width();
		*height = image.height();

		return 1;
	}

	return 0;
}


static int
file_read_jpeg(Tcl_Interp* ti,
					Tcl_Channel chan,
					char const*,
					Tcl_Obj *,
					Tk_PhotoHandle image_handle,
					int dst_x, int dst_y,
					int width, int height,
					int src_x, int src_y)
{
	try
	{
		ChannelReader reader(chan);
		return process_image(ti, reader, image_handle, width, height, src_x, src_y, dst_x, dst_y);
	}
	catch (JPEG::Exception const& exc)
	{
		return handle_exception(ti, exc);
	}
}


static int
file_match_jpeg(Tcl_Channel chan, char const*, Tcl_Obj*, int* width, int* height, Tcl_Interp* ti)
{
	try
	{
		ChannelReader reader(chan);
		return process_header(ti, reader, width, height);
	}
	catch (JPEG::Exception const& exc)
	{
	}

	return 0;
}


static int
str_read_jpeg(	Tcl_Interp* ti,
					Tcl_Obj* dataObj,
					Tcl_Obj*,
					Tk_PhotoHandle image_handle,
					int dst_x, int dst_y,
					int width, int height,
					int src_x, int src_y)
{
	int length;
	unsigned char* data = Tcl_GetByteArrayFromObj(dataObj, &length);

	JPEG::Image::Magic magic;
	memcpy(&magic, data, sizeof(JPEG::Image::Magic));

	try
	{
		if (JPEG::Image::testMagicNumber(magic))
		{
			StringReader reader(data, data + length);
			return process_image(ti, reader, image_handle, width, height, src_x, src_y, dst_x, dst_y);
		}

		Base64Reader reader(data, data + length);

		reader.read(magic, sizeof(magic));
		reader.reset();

		if (JPEG::Image::testMagicNumber(magic))
			return process_image(ti, reader, image_handle, width, height, src_x, src_y, dst_x, dst_y);
	}
	catch (JPEG::Exception const& exc)
	{
		return handle_exception(ti, exc);
	}

	return TCL_ERROR;
}


static int
str_match_jpeg(Tcl_Obj* dataObj, Tcl_Obj*, int* width, int* height, Tcl_Interp* ti)
{
	int length;
	unsigned char* data = Tcl_GetByteArrayFromObj(dataObj, &length);

	if (length < int(sizeof(JPEG::Image::Magic)))
		return 0;

	JPEG::Image::Magic magic;
	memcpy(&magic, data, sizeof(magic));

	try
	{
		if (JPEG::Image::testMagicNumber(magic))
		{
			StringReader reader(data, data + length);
			return process_header(ti, reader, width, height);
		}

		Base64Reader reader(data, data + length);
		reader.read(magic, sizeof(magic));
		reader.reset();

		if (JPEG::Image::testMagicNumber(magic))
			return process_header(ti, reader, width, height);
	}
	catch (JPEG::Exception const& exc)
	{
	}

	return 0;
}


void
tk::jpeg_init(Tcl_Interp* ti)
{
	static char* Jpeg = const_cast<char*>("jpeg");
	static Tk_PhotoImageFormat imgFmt =
	{
		Jpeg,					// name
		file_match_jpeg,	// fileMatchProc
		str_match_jpeg,	// stringMatchProc
		file_read_jpeg,	// fileReadProc
		str_read_jpeg,		// stringReadProc
		0,						// fileWriteProc
		0,						// stringWriteProc
		0,
	};

	Tk_CreatePhotoImageFormat(&imgFmt);
	Tcl_PkgProvide(ti, "tkjpeg", "1.0");
}

// vi:set ts=3 sw=3:
