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

#include "tk_init.h"

#include "jpeg_image.h"
#include "jpeg_reader.h"
#include "jpeg_exception.h"

#include "u_base64_decoder.h"
#include "u_exception.h"

#include <string.h>
#include <assert.h>

#include <tcl.h>
#include <tk.h>

extern "C" { static Tcl_FreeProc* __tcl_static = TCL_STATIC; }


namespace {

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
	Base64Reader(unsigned char const* first, unsigned char const* last) :m_decoder(first, last) {}

	size_t read(unsigned char* buf, size_t len)	{ return m_decoder.read(buf, len); }
	bool skip(size_t nbytes)							{ return m_decoder.skip(nbytes); }
	void reset()											{ m_decoder.reset(); }

	::util::Base64Decoder m_decoder;
};


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

	return ::Tcl_Seek(m_chan, nbytes, SEEK_CUR) == Tcl_WideInt(nbytes);
}

} // namespace


template <typename Exception>
static int
handle_exception(Tcl_Interp* ti, Exception const& exc)
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
	catch (util::BasicException const& exc)
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
	catch (util::BasicException const&)
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
