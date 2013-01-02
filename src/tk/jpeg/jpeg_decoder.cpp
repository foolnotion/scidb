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

#include "jpeg_decoder.h"
#include "jpeg_color_conv.h"
#include "jpeg_huffman.h"
#include "jpeg_exception.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>


using namespace JPEG;

namespace {

struct DeallocArray
{
	DeallocArray(unsigned char* p) :m_ptr(p) {}
	~DeallocArray() { delete [] m_ptr; }
	unsigned char* m_ptr;
};


enum { SkipWarnings = 1 };

enum
{
	JFIFMarker	= 1 << 0,
	SPIFFMarker	= 1 << 1,
	ExifMarker	= 1 << 2,
	AdobeMarker	= 1 << 3,
};


bool
compareIDs(Component** components, char const* id)
{
	if (id[0] && components[0]->id() != id[0]) return false;
	if (id[1] && components[1]->id() != id[1]) return false;
	if (id[2] && components[2]->id() != id[2]) return false;
	if (id[3] && components[3]->id() != id[3]) return false;

	return true;
}


inline
uint16_t
convToUint16(unsigned char const* buf)
{
	return (int16_t(buf[0]) << 8) | int16_t(buf[1]);
}


#if 0
inline
uint32_t
convToUint32(unsigned char const* buf)
{
	return (int32_t(buf[0]) << 24) | (int32_t(buf[1]) << 16) | (int32_t(buf[2]) << 8) | int32_t(buf[3]);
}
#endif


inline
JPEGSample const*
scanline(Component const* component, int row)
{
	return component ? component->upsampledRow(row) : 0;
}


inline int divRoundUp(int x, int y)	{ return (x + y - 1)/y; }
inline int isEven(int x)				{ return (x & 1) == 0; }
inline int min(int a, int b)			{ return a < b ? a : b; }
inline int max(int a, int b)			{ return a < b ? b : a; }

} // namespace


Decoder::Decoder(Stream& stream, Image& image)
		:m_image(image)
		,m_stream(stream)
		,m_bitStream(stream)
		,m_fancyUpsampling(false)
		,m_sofMarker(0)
		,m_bitsInJPEGSample(0)
		,m_imageWidth(0)
		,m_imageHeight(0)
		,m_sawMarker(0)
		,m_scanCount(0)
		,m_scanComponentCount(0)
		,m_maxVertFreq(0)
		,m_maxHorzFreq(0)
		,m_mcuRows(0)
		,m_mcuCols(0)
		,m_currentMCURow(-1)
		,m_currentMCUCol(0)
		,m_restartIndex(0)
		,m_restartInterval(0)
		,m_mcuCount(0)
		,m_outRow(0)
		,m_colorspace(Unknown)
		,m_colorspaceAdobe(-1)
		,m_subSampled(false)
		,m_interleaved(false)
		,m_colorConverter(0)
{
	::memset(m_quantValues, 0, sizeof(m_quantValues));
	::memset(m_components, 0, sizeof(m_components));
	::memset(m_acTable, 0, sizeof(m_acTable));
	::memset(m_dcTable, 0, sizeof(m_dcTable));
}


Decoder::~Decoder()
{
	releaseComponents();
	releaseHuffmanTables();
}


void
Decoder::releaseComponents()
{
	for (int i = 0; i < MaxComponents; ++i)
	{
		delete m_components[i];
		m_components[i] = 0;
	}
}


void
Decoder::releaseHuffmanTables()
{
	for (int i = 0; i < MaxComponents; ++i)
	{
		delete m_acTable[i];
		delete m_dcTable[i];
		m_acTable[i] = 0;
		m_dcTable[i] = 0;
	}
}


char const*
Decoder::description(unsigned char marker)
{
	char buf[sizeof(m_buffer)];
	snprintf(buf, sizeof(m_buffer), "'%s'", Base::descriptionOfMarker(marker));
	strncpy(m_buffer, buf, sizeof(m_buffer));
	return m_buffer;
}


void
Decoder::parseStartOfImage()
{
	if (m_sawMarker)
		throw Exception("unexpected %s encountered", description(SOI));
}


void
Decoder::warning(char const* format __attribute__((unused)), ...)
{
	if (m_stream.state() == Stream::ProcessUncompressedData || (m_restartInterval > 0 && SkipWarnings))
		return;

#ifndef NDEBUG
	char fmt[512];

	if (m_stream.state() == Stream::ProcessCompressedData)
	{
		snprintf(fmt,
					sizeof(fmt),
					"JPEG warning: %s [MCU row=%d, col=%d]\n",
					format,
					m_currentMCUCol == 0 ? ::max(0, m_currentMCURow - 1) : m_currentMCURow,
					::max(0, m_currentMCUCol - 1));
	}
	else
	{
		snprintf(fmt, sizeof(fmt), "JPEG warning: %s\n", format);
	}

	va_list args;
	va_start(args, format);
	vfprintf(stderr, fmt, args);
	va_end(args);
#endif
}


unsigned char
Decoder::readMarker()
{
	unsigned char marker = m_stream.getByte();

	if (marker != SOB)
		throw Exception("corrupted stream (SOB marker expected)");

	return m_stream.getByte();
}


bool
Decoder::decode(bool headerOnly)
{
	if (headerOnly)
	{
		unsigned char marker = m_stream.getByte();
		if (marker != SOB)
			return false;
		marker = m_stream.getByte();
		if (marker != SOI)
			return false;
		parseStartOfImage();
	}

	while (!headerOnly || !m_sofMarker)
	{
		unsigned char marker = readMarker();

		switch (marker)
		{
			case DHT:	parseHuffmanTable(); break;
			case SOI:	parseStartOfImage(); break;
			case SOS:	parseStartOfScan(); break;
			case DQT:	parseQuantization(); break;
			case DRI:	parseRestartInterval(); break;
			case COM:	parseComment(); break;
			case EOI:	finishFrame(); return true;

			case APP0:	// fall thru
			case APP1:	// fall thru
			case APP2:	// fall thru
			case APP3:	// fall thru
			case APP4:	// fall thru
			case APP5:	// fall thru
			case APP6:	// fall thru
			case APP7:	// fall thru
			case APP8:	// fall thru
			case APP9:	// fall thru
			case APP10:	// fall thru
			case APP11:	// fall thru
			case APP12:	// fall thru
			case APP13:	// fall thru
			case APP14:	// fall thru
			case APP15:	parseApplicationSegment(marker); break;

			case SOF0:	// fall thru
			case SOF1:	// fall thru
			case SOF2:	parseStartOfFrame(marker); break;

			case SOF3:	// fall thru
			case SOF5:	// fall thru
			case SOF6:	// fall thru
			case SOF7:	// fall thru
			case JPG:	// fall thru
			case SOF9:	// fall thru
			case SOF10:	// fall thru
			case SOF11:	// fall thru
			case SOF13:	// fall thru
			case SOF14:	// fall thru
			case SOF15:	// fall thru
			case SOF48:	throw Exception("%s not supported", description(marker));

			case RST0:	// fall thru
			case RST1:	// fall thru
			case RST2:	// fall thru
			case RST3:	// fall thru
			case RST4:	// fall thru
			case RST5:	// fall thru
			case RST6:	// fall thru
			case RST7:	throw Exception("unexpected %s outside of scan data", description(marker));

			default:
				if (!isValidMarker(marker))
					throw Exception("corrupted stream (bogus marker %s encountered)", description(marker));
				m_stream.skip(m_stream.getInt16() - 2);
				break;
		}
	}

	return true;
}


bool
Decoder::processRestartMarker(unsigned char marker, Mode mode)
{
	int	restartIndex	= marker - RST0;
	int	missingUnits	= 0;
	bool	rc					= true;

	if (restartIndex != m_restartIndex)
		missingUnits = ((m_restartIndex - restartIndex + 8) % 8)*m_restartInterval;
	else if (m_mcuCount < m_restartInterval)
		missingUnits = m_restartInterval - m_mcuCount;

	if (missingUnits)
	{
		if (mode == CountMissingUnits)
			warning("corrupt scan (missing %d units before %s)", missingUnits, nameOfMarker(marker));
		else if (mode == CountSkippedUnits)
			warning("skipping %d units", missingUnits);

		int currentMCURow = m_currentMCURow;

		m_currentMCUCol += missingUnits;
		m_currentMCURow += m_currentMCUCol/m_mcuCols;
		m_currentMCUCol %= m_mcuCols;

		if (mode == CountMissingUnits && !isProgressive())
		{
			for (int row = currentMCURow; row < m_currentMCURow; ++row)
				produceScanlines(currentMCURow);
		}

		rc = false;
	}

	m_mcuCount = 0;

	if (++m_restartIndex == 8)
		m_restartIndex = 0;

	for (int i = 0; i < m_scanComponentCount; ++i)
		m_scanComponents[i]->restart();

	m_bitStream.clear();

	return rc;
}


Component::State
Decoder::decodeMCU()
{
	for (int i = 0; i < m_scanComponentCount; ++i)
	{
		Component::State rc = m_scanComponents[i]->processMCU(m_currentMCURow,
																				m_currentMCUCol,
																				Component::Decode,
																				m_interleaved);

		if (rc != Component::Ok)
			return rc;

		if ((rc = m_scanComponents[i]->getState()) != Component::Ok)
			warning(Component::errorMessage(rc));
	}

	return Component::Ok;
}


void
Decoder::processCurrentMCU()
{
	if (++m_currentMCUCol == m_mcuCols)
	{
		if (!isProgressive())
			produceScanlines(m_currentMCURow);

		++m_currentMCURow;
	}

	++m_mcuCount;
}


void
Decoder::decodeCurrentMCU()
{
	Component::State rc = decodeMCU();

	switch (rc)
	{
		case Component::Ok:
			processCurrentMCU();
			if (m_mcuCount == m_restartInterval)
				parseRestartMarker(CountExtraneousBytes);
			break;

		case Component::PrematureEndOfScan:
			processCurrentMCU();
			if (m_restartInterval == 0)
				warning("premature end of scan data");
			else
				parseRestartMarker(CountMissingUnits);
			break;

		case Component::BadCodeLength:
		case Component::BadCode:
		case Component::CorruptScanData:
		case Component::ErrorInProgressiveScan:
		case Component::InvalidCodeInSequentialData:
		case Component::InvalidCodeInProgressiveScan:
			processCurrentMCU();
			if (m_restartInterval == 0)
				throw Exception(Component::errorMessage(rc));
			warning(Component::errorMessage(rc));
			parseRestartMarker(CountSkippedUnits);
			break;

		case Component::InternalError:
			throw Exception("internal error in Huffman decoder");
	}
}


void
Decoder::processImageData()
{
	m_stream.setState(Stream::ProcessCompressedData);

	m_currentMCURow = 0;

	while (m_currentMCURow < m_mcuRows)
	{
		m_currentMCUCol = 0;

		while (m_currentMCUCol < m_mcuCols)
			decodeCurrentMCU();
	}

	m_stream.setState(Stream::ProcessUncompressedData);

	unsigned			extraneous	= m_bitStream.bytesLeft();
	unsigned char	marker		= m_stream.peekByte();

	do
	{
		while (marker != SOB)
		{
			m_stream.getByte();
			++extraneous;
			marker = m_stream.peekByte();
		}

		m_stream.getByte();
		marker = m_stream.peekByte();
	}
	while (marker == 0);

	m_bitStream.clear();
	m_stream.putbackStuffByte();

	if (extraneous)
		warning("corrupt scan (%d extraneous byte%s)", extraneous, extraneous > 1 ? "s" : "");
}


void
Decoder::finishFrame()
{
	if (isProgressive())
	{
		m_mcuCols = ::divRoundUp(m_imageWidth, m_maxHorzFreq*DCTWidth);
		m_mcuRows = ::divRoundUp(m_imageHeight, m_maxVertFreq*DCTWidth);

		for (int mcuRow = 0; mcuRow < m_mcuRows; ++mcuRow)
		{
			for (int mcuCol = 0; mcuCol < m_mcuCols; ++mcuCol)
			{
				for (int i = 0; i < m_numComponents; ++i)
					m_components[i]->processMCU(mcuRow, mcuCol, Component::Update, true);
			}

			produceScanlines(mcuRow);
		}
	}
}


void
Decoder::parseRestartMarker(Mode mode)
{
	enum { MaxExtraneousBytes = 1536 };	// arbitrarily choosen

	if (m_currentMCURow == m_mcuRows)
		return;

	unsigned extraneous = 0;

	m_stream.setState(Stream::ProcessUncompressedData);

	while (true)
	{
		unsigned char marker = m_stream.getByte();

		if (marker == SOB)
		{
			marker = m_stream.getByte();

			switch (marker)
			{
				case 0:
					if (++extraneous > MaxExtraneousBytes)
						throw Exception("corrupt scan");
					break;

				case RST0:
				case RST1:
				case RST2:
				case RST3:
				case RST4:
				case RST5:
				case RST6:
				case RST7:
					if (processRestartMarker(marker, mode) && mode == CountExtraneousBytes && extraneous)
					{
						warning(	"corrupt scan (%d extraneous byte%s before %s marker)",
									extraneous,
									extraneous > 1 ? "s" : "",
									nameOfMarker(marker));
					}
					m_stream.setState(Stream::ProcessCompressedData);
					return;

				default:
					throw Exception("corrupt scan (cannot find %s)", description(RST0 + m_restartIndex));
			}
		}
		else if (++extraneous > MaxExtraneousBytes)
		{
			throw Exception("corrupt scan");
		}
	}
}


void
Decoder::parseAdobeColorspace(unsigned char const* data, size_t length)
{
	if (length != 12 && length != 31 && length != 36)
	{
		warning("%s has bad length", tagDescription(TagAdobe));
	}
	else if (data[9] | data[10])
	{
		warning("unsupported 'Picky' option in %s", tagDescription(TagAdobe));
	}
	else
	{
		m_colorspaceAdobe = data[11];
		m_sawMarker |= AdobeMarker;
	}
}


void
Decoder::parseSPIFFHeader(unsigned char const* data, size_t length)
{
	if (m_sawMarker & JFIFMarker)
	{
		warning("useless SPIFF header encountered (JFIF header detected before)");
	}
	else if (length != 24)
	{
		if (m_sawMarker == 0)
			throw Exception("does not appear to be JPEG (SPIFF) stream");

		throw Exception("corrupt SPIFF header (bad length)");
	}
	else
	{
		// see <http://www.fileformat.info/format/spiff/> for SPIFF header format
		// see also: <http://www.digitalpreservation.gov/formats/fdd/fdd000019.shtml>
//		unsigned version			= convToUint16(&data[0]);
//		unsigned profileID		= data[2];
//		unsigned numComponents	= data[3];
//		unsigned imageHeight		= convToUint32(&data[4]);
//		unsigned imageWidth		= convToUint32(&data[8]);
		unsigned colorSpace		= data[12];
//		unsigned bitsPerSample	= data[13];
		unsigned compression		= data[14];

		switch (colorSpace)
		{
			case 0:	throw Exception("'Bi-level' color space not supported");
			case 1:	throw Exception("'YCbCr ITU-R BT 709, video' color space not supported");
			case 2:	warning("no color space defined in SPIFF header"); break;
			case 3:	m_colorspace = YCC; break;	// ITU-R BT 601-1, RGB
			case 4:	throw Exception("'YCbCr ITU-R BT 601-1, video' color space not supported");
			case 8:	m_colorspace = Grayscale; break;
			case 9:	m_colorspace = PhotoYCC; break;
			case 10:	m_colorspace = RGB; break;
			case 11:	m_colorspace = CMY; break;
			case 12:	m_colorspace = CMYK_JPEG; break;
			case 13:	m_colorspace = YCCK_JPEG; break;
			case 14:	throw Exception("'CIELab' color space not supported");
			default:	throw Exception("bogus color space in SPIFF header");
		}

		switch (compression)
		{
			case 0:	throw Exception("compression method 0 (uncompressed, interleaved, 8 bit) not supported");
			case 1:	throw Exception("compression method 1 (modified Huffman) not supported");
			case 2:	throw Exception("compression method 2 (modified READ) not supported");
			case 3:	throw Exception("compression method 3 (modified modified READ) not supported");
			case 4:	throw Exception("compression method 4 (JBIG) not supported");
			case 5:	break;	// JPEG
			default:	throw Exception("bogus compression method in SPIFF header");
		}

		m_sawMarker = SPIFFMarker;
	}
}


void
Decoder::parseJFIFHeader(unsigned char const* data, size_t length)
{
	if (m_sawMarker & JFIFMarker)
		throw Exception("duplicate JFIF header encountered");
	if (length < 14)
		throw Exception("corrupt JFIF header (bad length)");
	if (m_sawMarker & SPIFFMarker)
		warning("useless SPIFF header skipped");

	if (data[5] != 1 || data[6] > 2)
		warning("unexpected JFIF revision number %d.%d", int(data[5]), data[6] < 10 ? 0 : int(data[6]));

	m_sawMarker |= JFIFMarker;
}


void
Decoder::parseApplicationSegment(unsigned char marker)
{
	assert(APP0 <= marker && marker <= APP15);

	int				length	= m_stream.getInt16() - 2;
	unsigned char*	data		= new unsigned char[length];
	int				nbytes	= m_stream.fetch(data, length);

	DeallocArray delloc(data);

	if (nbytes < length)
	{
		if (m_sawMarker == 0)
			throw Exception("does not appear to be JPEG stream");

		throw Exception("corrupt %s (premature end of stream)", descriptionOfMarker(marker));
	}

	Tag tag = findTag(marker, data, nbytes);

	switch (tag)
	{
		case TagJFIF:	parseJFIFHeader(data, length); break;
		case TagAdobe:	parseAdobeColorspace(data, length); break;
		case TagSPIFF:	parseSPIFFHeader(data, length); break;
		default:			break;
	}
}


void
Decoder::parseComment()
{
	m_stream.skip(m_stream.getInt16() - 2);
}


void
Decoder::setupColorModel()
{
	if (m_colorspaceAdobe >= 0)
	{
		bool valid = true;

		switch (m_numComponents)
		{
			case 3:
				switch (m_colorspaceAdobe)
				{
					case 0:	m_colorspace = RGB; break;
					case 1:	m_colorspace = YCC; break;
					default:	m_colorspace = RGB; valid = false; break;
				}
				break;

			case 4:
				switch (m_colorspaceAdobe)
				{
					case 0:	m_colorspace = CMYK_Adobe; break;
					case 2:	m_colorspace = YCCK_Adobe; break;
					default:	m_colorspace = CMYK_Adobe; valid = false; break;
				}
				break;

			default:
				valid = false;
				break;
		}

		if (!valid)
			warning("%s: unknown color transform code %d", tagDescription(TagAdobe), m_colorspaceAdobe);
	}

	if (m_colorspace == Unknown)
	{
		switch (m_numComponents)
		{
			case 1:
				m_colorspace = Grayscale;
				break;

			case 2:
				m_colorspace = GrayAlpha;
				break;

			case 3:
				if (::compareIDs(m_components, "RGB"))
					m_colorspace = RGB;
				else if (::compareIDs(m_components, "YCC") || ::compareIDs(m_components, "YCc"))
					m_colorspace = PhotoYCC;
				else if (m_subSampled || ::compareIDs(m_components, "\001\002\003"))
					m_colorspace = YCC;
				else
					m_colorspace = RGB;
				break;

			case 4:
				if (::compareIDs(m_components, "RGBA"))
					m_colorspace = RGBA;
				else if (::compareIDs(m_components, "YCCA") || ::compareIDs(m_components, "YCcA"))
					m_colorspace = PhotoYCCA;
				else if (::compareIDs(m_components, "\001\002\003\004"))
					m_colorspace = YCCA;
				else if (m_subSampled)
					m_colorspace = YCCK_JPEG;
				else
					m_colorspace = CMYK_JPEG;
				break;
		}
	}
	else if (srcChannels(m_colorspace) != m_numComponents)
	{
		throw Exception("bogus component count (%d)", m_numComponents);
	}

	if (m_sawMarker == JFIFMarker && ::isEven(m_numComponents))
		warning("component count %d encountered in JFIF stream", m_numComponents);
}


void
Decoder::setupColorConversion()
{
#ifdef JPEG_SUPPORT_12_BIT
	if (m_bitsInJPEGSample == 12)
	{
		switch (m_colorspace)
		{
			case Grayscale:	m_colorConverter = &Converter<Grayscale,	12>::processRow; break;
			case GrayAlpha:	m_colorConverter = &Converter<GrayAlpha,	12>::processRow; break;
			case RGB:			m_colorConverter = &Converter<RGB,			12>::processRow; break;
			case RGBA:			m_colorConverter = &Converter<RGBA,			12>::processRow; break;
			case YCC:			m_colorConverter = &Converter<YCC,			12>::processRow; break;
			case YCCA:			m_colorConverter = &Converter<YCCA,			12>::processRow; break;
			case YCCK_Adobe:	m_colorConverter = &Converter<YCCK_Adobe,	12>::processRow; break;
			case YCCK_JPEG:	m_colorConverter = &Converter<YCCK_JPEG,	12>::processRow; break;
			case PhotoYCC:		m_colorConverter = &Converter<PhotoYCC,	12>::processRow; break;
			case PhotoYCCA:	m_colorConverter = &Converter<PhotoYCCA,	12>::processRow; break;
			case CMY:			m_colorConverter = &Converter<CMY,			12>::processRow; break;
			case CMYK_Adobe:	m_colorConverter = &Converter<CMYK_Adobe,	12>::processRow; break;
			case CMYK_JPEG:	m_colorConverter = &Converter<CMYK_JPEG,	12>::processRow; break;
			case Unknown:		assert(0);
		}

		return;
	}
#endif
	assert(m_bitsInJPEGSample == 8);

	switch (m_colorspace)
	{
		case Grayscale:	m_colorConverter = &Converter<Grayscale,	8>::processRow; break;
		case GrayAlpha:	m_colorConverter = &Converter<GrayAlpha,	8>::processRow; break;
		case RGB:			m_colorConverter = &Converter<RGB,			8>::processRow; break;
		case RGBA:			m_colorConverter = &Converter<RGBA,			8>::processRow; break;
		case YCC:			m_colorConverter = &Converter<YCC,			8>::processRow; break;
		case YCCA:			m_colorConverter = &Converter<YCCA,			8>::processRow; break;
		case YCCK_Adobe:	m_colorConverter = &Converter<YCCK_Adobe,	8>::processRow; break;
		case YCCK_JPEG:	m_colorConverter = &Converter<YCCK_JPEG,	8>::processRow; break;
		case PhotoYCC:		m_colorConverter = &Converter<PhotoYCC,	8>::processRow; break;
		case PhotoYCCA:	m_colorConverter = &Converter<PhotoYCCA,	8>::processRow; break;
		case CMY:			m_colorConverter = &Converter<CMY,			8>::processRow; break;
		case CMYK_Adobe:	m_colorConverter = &Converter<CMYK_Adobe,	8>::processRow; break;
		case CMYK_JPEG:	m_colorConverter = &Converter<CMYK_JPEG,	8>::processRow; break;
		case Unknown:		assert(0);
	}
}


void
Decoder::parseStartOfFrame(unsigned char marker)
{
	if (m_sofMarker)
		warning("duplicate %s marker", description(marker));
	if (m_scanCount)
		throw Exception("%s must precede %s", description(marker), description(SOS));

	m_sofMarker = marker;

	int length = m_stream.getInt16();
	m_bitsInJPEGSample = m_stream.getByte();
	m_imageHeight = m_stream.getInt16();
	m_imageWidth = m_stream.getInt16();

#ifndef JPEG_SUPPORT_12_BIT
	if (m_bitsInJPEGSample == 12)
		throw Exception("12 bit samples not supported");
#endif

	if (m_imageHeight <= 0 || m_imageWidth <= 0)
		throw Exception("empty image");
	if (m_bitsInJPEGSample != 8 && m_bitsInJPEGSample != 12)
		throw Exception("bogus sample precision (%d)", m_bitsInJPEGSample);
	if (isBaseline() && m_bitsInJPEGSample != 8)
		warning("sample precision (%d) not allowed for baseline JPEG", m_bitsInJPEGSample);

	parseComponents(length - 8);
	setupColorModel();
	setupColorConversion();

	m_image.setup(m_imageWidth, m_imageHeight, dstChannels(m_colorspace), m_bitsInJPEGSample);
}


void
Decoder::parseComponents(int remainingBytes)
{
	struct MyComponent
	{
		unsigned char	id;
		int				horzFreq;
		int				fVertFreq;
		unsigned char	quantTblIndex;
	};

	m_numComponents = m_stream.getByte();

	if (m_numComponents == 0)
		throw Exception("empty image");
	if (remainingBytes != m_numComponents*3)
		throw Exception("bogus frame size");
	if (m_numComponents > 4)
		throw Exception("more than 4 components");

	MyComponent components[4];

	for (int i = 0; i < m_numComponents; ++i)
	{
		MyComponent& component = components[i];

		component.id = m_stream.getByte();

		unsigned char c = m_stream.getByte();

		component.horzFreq = (c >> 4) & 0x0f;
		component.fVertFreq = c & 0x0f;

		if (component.horzFreq == 0 || component.horzFreq > 4)
			throw Exception("invalid horizontal frequency (%d) in frame", component.horzFreq);
		if (component.fVertFreq == 0 || component.fVertFreq > 4)
			throw Exception("invalid vertical frequency (%d) in frame", component.fVertFreq);
		if (component.horzFreq == 3 || component.fVertFreq == 3)
			throw Exception("unsupported frequency of 3 in frame");

		m_maxHorzFreq = ::max(m_maxHorzFreq, component.horzFreq);
		m_maxVertFreq = ::max(m_maxVertFreq, component.fVertFreq);

		component.quantTblIndex = m_stream.getByte();

		if (component.quantTblIndex >= sizeof(m_quantValues)/sizeof(m_quantValues[0]))
			throw Exception("bogus quantization table index (%d)", component.quantTblIndex);
	}

	releaseComponents();

	for (int i = 0; i < m_numComponents; ++i)
	{
		m_components[i] = new Component(
			components[i].id,
			m_imageHeight,
			m_imageWidth,
			m_maxVertFreq,
			m_maxHorzFreq,
			components[i].fVertFreq,
			components[i].horzFreq,
			m_bitsInJPEGSample,
			isProgressive(),
			m_bitStream,
			components[i].quantTblIndex,
			m_fancyUpsampling);

		if (components[i].fVertFreq > 1 || components[i].horzFreq > 1)
			m_subSampled = true;
	}
}


void
Decoder::parseStartOfScan()
{
	if (m_sawMarker == 0)
		warning("no JPEG header found");
	if (m_sofMarker == 0)
		throw Exception("scan found before frame defined");
	if (m_scanCount > 0 && !isProgressive())
		throw Exception("didn't expect more than one scan");

	m_scanCount++;

	int spectralSelectionStart, spectralSelectionEnd, succApproxLo, succApproxHi;
	int acIndices[MaxComponents], dcIndices[MaxComponents];

	parseScanComponents(acIndices, dcIndices);
	parseSpectralSelection(spectralSelectionStart, spectralSelectionEnd, succApproxLo, succApproxHi);

	for (int i = 0; i < m_scanComponentCount; ++i)
	{
		int quantTableIndex = m_scanComponents[i]->quantTableIndex();

		if (m_quantValues[quantTableIndex] == 0)
			throw Exception("undefined quantization table (%d)", quantTableIndex);

		m_scanComponents[i]->setup(m_quantValues[quantTableIndex],
											m_acTable[acIndices[i]],
											m_dcTable[dcIndices[i]],
											spectralSelectionStart,
											spectralSelectionEnd,
											succApproxLo,
											succApproxHi);
	}

	m_restartIndex = 0;
	m_outRow = 0;
	m_mcuCount = 0;
	m_currentMCUCol = 0;
	m_interleaved = (m_scanComponentCount > 1);

	if (m_interleaved)
	{
		m_mcuCols = ::divRoundUp(m_imageWidth, m_maxHorzFreq*DCTWidth);
		m_mcuRows = ::divRoundUp(m_imageHeight, m_maxVertFreq*DCTWidth);
	}
	else
	{
		m_mcuCols = ::divRoundUp(m_imageWidth, m_scanComponents[0]->horzSampling()*DCTWidth);
		m_mcuRows = ::divRoundUp(m_imageHeight, m_scanComponents[0]->vertSampling()*DCTWidth);
	}

	processImageData();
}


void
Decoder::parseScanComponents(int* acIndices, int* dcIndices)
{
	int length = m_stream.getInt16() - 2;

	m_scanComponentCount = m_stream.getByte();

	if (m_scanComponentCount == 0 || m_scanComponentCount > m_numComponents)
		throw Exception("bogus component count (%d) in scan", m_scanComponentCount);

	if (length != m_scanComponentCount*2 + 4)
		throw Exception("bad length in %s marker", description(SOS));

	::memset(m_scanComponents, 0, sizeof(m_scanComponents));

	for (int i = 0; i < m_scanComponentCount; ++i)
	{
		unsigned char	componentID	= m_stream.getByte();
		int 				index			= 0;

		while (m_components[index]->id() != componentID)
		{
			if (++index == MaxComponents)
				throw Exception("bogus component id (%d) in scan", componentID);
		}

		m_scanComponents[i] = m_components[index];

		unsigned char c = m_stream.getByte();

		acIndices[i] = c & 0x0f;
		dcIndices[i] = c >> 4;

		if (acIndices[i] >= MaxComponents || dcIndices[i] >= MaxComponents)
			throw Exception("bogus Huffman table index (%d) in scan", acIndices[i]);

		if (isBaseline())
		{
			if (acIndices[i] > 1)
				warning("bogus Huffman code table number (AC: %d)", acIndices[i]);
			if (dcIndices[i] > 1)
				warning("bogus Huffman code table number (DC: %d)", dcIndices[i]);
		}
	}
}


void
Decoder::parseSpectralSelection(	int& spectralSelectionStart, int& spectralSelectionEnd,
													int& succApproxLo, int& succApproxHi)
{
	spectralSelectionStart = m_stream.getByte();
	spectralSelectionEnd = m_stream.getByte();

	unsigned int c = m_stream.getByte();

	succApproxLo = c & 0x0f;
	succApproxHi = c >> 4;

	if (isProgressive())
	{
		if (spectralSelectionEnd > 63)
			throw Exception("spectral selection exceeds 63");
		if (spectralSelectionStart != 0 && m_scanComponentCount != 1)
			throw Exception("bogus spectral selection/component count combination");
		if (spectralSelectionEnd < spectralSelectionStart)
			throw Exception("bogus spectral selection");
		if (spectralSelectionStart == 0 && spectralSelectionEnd != 0)
			throw Exception("progressive scan cannot contain both AC and DC values");
		if (m_scanCount == 1 && spectralSelectionStart != 0)
			throw Exception("first scan must contain the DC coefficients");
		if (succApproxLo > 13 || succApproxHi > 13)
			throw Exception("bogus progressive parameters in scan");
		if (succApproxHi != 0 && succApproxHi != succApproxLo + 1)
			throw Exception("bogus progressive parameters in scan");
	}
	else
	{
		if (spectralSelectionStart != 0 || spectralSelectionEnd != 63)
			throw Exception("bogus spectral selection in scan");
		if (succApproxLo != 0 || succApproxHi != 0)
			throw Exception("bogus progressive parameters in scan");
	}
}


void
Decoder::parseRestartInterval()
{
	if (m_stream.getInt16() != 4)
		throw Exception("bad length of %s segment", description(DRI));

	m_restartInterval = m_stream.getInt16();
}


void
Decoder::parseQuantization()
{
	unsigned remaining = m_stream.getInt16() - 2;

	while (remaining)
	{
		unsigned c			= m_stream.getByte();
		unsigned index		= c & 0x0f;
		unsigned numBytes	= (c >> 4) ? 2 : 1;

		if (index >= sizeof(m_quantValues)/sizeof(m_quantValues[0]))
			throw Exception("bogus quantization table index (%d)", index);
#ifndef JPEG_SUPPORT_12_BIT
		if (numBytes == 2)
			throw Exception("12 bit samples not supported");
#endif
		if (isBaseline() && numBytes == 2)
			warning("12 bit quantization table precision not allowed for baseline JPEG");

		QuantValues& quantValues = m_quantValues[index];

		for (int i = 0; i < DCTSize; ++i)
		{
			int value = (numBytes == 2) ? m_stream.getInt16() : m_stream.getByte();

			if (value == 0)
				throw Exception("zero value in quantization table");

			quantValues[i] = value;
		}

		remaining -= numBytes*DCTSize + 1;
	}
}


void
Decoder::parseHuffmanTable()
{
	int remaining = m_stream.getInt16() - 2;

	while (remaining)
	{
		unsigned char	huffBits[HuffmanDecoder::MaxCodeLength];
		unsigned char	huffValues[HuffmanDecoder::MaxCodes];

		unsigned firstByte	= m_stream.getByte();
		unsigned index			= firstByte & 0x0f;

		m_stream.get(huffBits, sizeof(huffBits));

		int count = 0;
		for (size_t i = 0; i < sizeof(huffBits); ++i)
			count += huffBits[i];

		if (count > HuffmanDecoder::MaxCodes)
			throw Exception("Huffman table too large");
		if (index >= sizeof(m_acTable)/sizeof(m_acTable[0]))
			throw Exception("bogus Huffman table index (%d)", index);
		if (count > ::min(HuffmanDecoder::MaxCodes, remaining))
			throw Exception("too many codes in Huffman table");

		m_stream.get(huffValues, count);
		remaining -= sizeof(huffBits) + count + 1;
		HuffmanDecoder* decoder = new HuffmanDecoder(huffBits, huffValues, count);

		if (firstByte & 0x10)
		{
			delete m_acTable[index];
			m_acTable[index] = decoder;
		}
		else
		{
			delete m_dcTable[index];
			m_dcTable[index] = decoder;
		}
	}
}


void
Decoder::produceScanlines(int mcuRow)
{
	int numRows = ::min(m_maxVertFreq*DCTWidth, m_imageHeight - m_outRow);

	for (int i = 0; i < m_numComponents; ++i)
		m_components[i]->upsampleMCURow(mcuRow, numRows);

	for (int r = 0; r < numRows; ++r, ++m_outRow)
	{
		m_colorConverter(	::scanline(m_components[0], r),
								::scanline(m_components[1], r),
								::scanline(m_components[2], r),
								::scanline(m_components[3], r),
								m_image.scanline(m_outRow));
	}
}


bool
Decoder::testIfJPEG(Stream& reader)
{
	unsigned char buf[512];

	if (	reader.fetch(buf, 2) < 2
		|| buf[0] != SOB
		|| buf[1] != SOI
		|| reader.fetch(buf, 2) < 2)
	{
		return false;
	}

	int sob	= buf[0];
	int type	= buf[1];

	// NOTE:
	// The JFIF standard says, that the JPEG FIF APP0 marker is mandatory right after
	// the SOI marker, but Adobe Photoshop writes miscellaneous application segments
	// between SOI and JPEG FIF APP0.
	// Therefore we will skip these miscellaneous application segments, otherwise we
	// cannot decode files written with Adobe Photoshop.

	while (sob == SOB && (APP0 <= type && type <= APP15))
	{
		if (reader.fetch(buf, 2) < 2)
			return 0;

		unsigned length		= ::convToUint16(buf) - 2;
		unsigned bytesRead	= reader.fetch(buf, ::min(length, MaxTagLength));

		switch (findTag(type, buf, bytesRead))
		{
			case TagJFIF:	// fall thru
			case TagEXIF:	// fall thru
			case TagIRB:	// fall thru
			case TagAdobe:	return true;
			case TagSPIFF:	return buf[14] == 5;	// compression = JPEG
			default:			break;
		}

		length -= bytesRead;

		while (length > 0)
		{
			unsigned n = ::min(length, sizeof(buf));

			if (reader.fetch(buf, n) < n)
				return false;

			length -= n;
		}

		if (reader.fetch(buf, 2) < 2)
			return false;

		sob	= buf[0];
		type	= buf[1];
	}

	return false;
}

// vi:set ts=3 sw=3:
