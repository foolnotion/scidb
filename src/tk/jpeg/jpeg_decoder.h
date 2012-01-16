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

#ifndef _jpeg_decoder_included
#define _jpeg_decoder_included

#include "jpeg_base.h"
#include "jpeg_stream.h"
#include "jpeg_component.h"
#include "jpeg_image.h"
#include "jpeg_bit_stream.h"

namespace JPEG {

class HuffmanDecoder;
class Scanline;

class Decoder : Base
{
public:

	// structors
	Decoder(Stream& stream, Image& image);
	~Decoder();

	// decoding
	bool decode(bool headerOnly = false);
	static bool testIfJPEG(Stream& reader);

	// modifiers
	void setFancyUpsampling(bool flag = true) { m_fancyUpsampling = flag; }

private:

	// constants
	static int const MaxComponents = 4;

	enum Mode
	{
		CountExtraneousBytes,
		CountMissingUnits,
		CountSkippedUnits,
	};

	// types
	typedef Component::QuantValues QuantValues;

	typedef void (*ColorConverter)(	JPEGSample const*,
												JPEGSample const*,
												JPEGSample const*,
												JPEGSample const*,
												Scanline&);

	// queries
	bool isProgressive() const	{ return m_sofMarker == SOF2; }
	bool isBaseline() const		{ return m_sofMarker == SOF0; }

	// reading
	unsigned char readMarker();

	// parsing
	void processImageData();
	void parseRestartMarker(Mode mode);
	void parseComment();
	void parseApplicationSegment(unsigned char marker);
	void parseAdobeColorspace(unsigned char const* data, size_t length);
	void parseJFIFHeader(unsigned char const* data, size_t length);
	void parseSPIFFHeader(unsigned char const* data, size_t length);
	void parseStartOfFrame(unsigned char marker);
	void parseStartOfImage();
	void parseComponents(int remainingBytes);
	void parseStartOfScan();
	void parseScanComponents(int* acIndices, int* dcIndices);
	void parseSpectralSelection(	int& spectralSelectionStart, int& spectralSelectionEnd,
											int& succApproxLo, int& succApproxHi);
	void parseRestartInterval();
	void parseQuantization();
	void parseHuffmanTable();

	// decoding
	Component::State decodeMCU();
	void decodeCurrentMCU();
	void processCurrentMCU();
	void decodeMCURow();
	bool processRestartMarker(unsigned char marker, Mode mode);

	// setup
	void setupColorModel();
	void setupColorConversion();

	// production
	void finishFrame();

	void produceImage();
	void produceScanlines(int mcuRow);

	// miscellaneous
	char const* description(unsigned char marker);
	void releaseComponents();
	void releaseHuffmanTables();

	// error handling
	void warning(char const* format, ...);

	// attributes
	Image&				m_image;
	Stream&				m_stream;
	BitStream			m_bitStream;
	bool					m_fancyUpsampling;
	unsigned char		m_sofMarker;
	unsigned				m_bitsInJPEGSample;
	int					m_imageWidth;
	int					m_imageHeight;
	unsigned				m_sawMarker;
	int					m_scanCount;
	int					m_scanComponentCount;
	int					m_maxVertFreq;
	int					m_maxHorzFreq;
	int					m_mcuRows;
	int					m_mcuCols;
	int					m_currentMCURow;
	int					m_currentMCUCol;
	int					m_restartIndex;
	int					m_restartInterval;
	int					m_mcuCount;
	int					m_outRow;
	Colorspace			m_colorspace;
	int					m_colorspaceAdobe;
	bool					m_subSampled;
	bool					m_interleaved;
	QuantValues			m_quantValues[4];
	int					m_numComponents;
	Component*			m_components[MaxComponents];
	Component*			m_scanComponents[MaxComponents];
	HuffmanDecoder*	m_acTable[MaxComponents];
	HuffmanDecoder*	m_dcTable[MaxComponents];
	ColorConverter		m_colorConverter;
};

} // namespace JPEG

#endif // _jpeg_decoder_included

// vi:set ts=3 sw=3:
