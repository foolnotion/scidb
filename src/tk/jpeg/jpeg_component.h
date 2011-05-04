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

#ifndef _jpeg_component_included
#define _jpeg_component_included

#include "jpeg_base.h"
#include "jpeg_dct.h"

namespace JPEG {

class BitStream;
class HuffmanDecoder;
class DCT;

class Component : public Base
{
public:

	typedef DCT::QuantValues QuantValues;

	enum State
	{
		Ok,
		PrematureEndOfScan,
		BadCodeLength,
		BadCode,
		CorruptScanData,
		ErrorInProgressiveScan,
		InvalidCodeInProgressiveScan,
		InvalidCodeInSequentialData,
		InternalError,
	};

	enum Mode { Decode, Update, };

	// structors
	Component(	int id,
					int imageHeight,
					int imageWidth,
					int maxVertFrequency,
					int maxHorzFrequency,
					int vertFrequency,
					int horzFrequency,
					int bitsInSample,
					bool progressive,
					BitStream& bitStream,
					int quantTableIndex,
					bool fancyUpsampling);
	~Component();

	// accessors
	int id() const						{ return m_componentID; }
	int horzFrequency() const		{ return m_horzFreq; }
	int vertFrequency() const		{ return m_vertFreq; }
	int horzSampling() const		{ return m_horzSampling; }
	int vertSampling() const		{ return m_vertSampling; }
	int quantTableIndex() const	{ return m_quantTableIndex; }

	JPEGSample const* upsampledRow(int row) const { return m_upsampledRows[row]; }

	State getState() const			{ return m_state; }

	// modifiers
	void setup(	JPEGSample const quantValues[DCTSize],
					HuffmanDecoder const* acTable,
					HuffmanDecoder const* dcTable,
					int spectralSelectionStart, int spectralSelectionEnd,
					int succApproxLo, int succApproxHi);

	void restart() { m_lastDCValue = 0; }

	// decoding
	State processMCU(int mcuRow, int mcuCol, Mode mode, bool interleaved);
	void upsampleMCURow(int mcuRow, int outputRows);

	// helpers
	static char const* errorMessage(State state);

private:

	// types
	typedef void (Component::*UpsampleMethod)(JPEGSample*, int);
	typedef void (Component::*DecodingMethod)(JPEGSample*);
	typedef HuffmanDecoder const* HuffmanDecoderP;

	// constants
	static int const DataUnitSize = DCTSize + 1;
	static int const ZigZagOrder[DCTSize];

	// setup
	void setupBuffers(int pixelsPerRow);
	void setupUnitBuffer(int dataUnitSize);
	void setupUnitLineBuffer(int numRows);

	// decoding
	void decodeSequentialDataUnit(JPEGSample* dataUnit);
	void decodeACFirst(JPEGSample* dataUnit);
	void decodeACRefine(JPEGSample* dataUnit);
	void decodeDCFirst(JPEGSample* dataUnit);
	void decodeDCRefine(JPEGSample* dataUnit);

	bool refineCoeff(JPEGSample* dataUnit, int pos);
	bool updateCoeff(JPEGSample* dataUnit, JPEGSample* coeff);
	int refineAC(JPEGSample* dataUnit);

	int readBits(int n);
	int readExtendedBits(int n);
	int nextCode(HuffmanDecoder const* decoder);

	void decodeDataUnit(int duRow, int duCol, Mode mode, bool useful);

	// modifiers
	void setState(State state);

	// sampling
	void upsampleH1V1(JPEGSample* source, int outputRows);
	void upsampleH1V2(JPEGSample* source, int outputRows);
	void upsampleH2V1(JPEGSample* source, int outputRows);
	void upsampleH2V2(JPEGSample* source, int outputRows);
	void upsampleGeneric(JPEGSample* source, int outputRows);

	void upsampleH1V2Fancy(JPEGSample* source, int outputRows);
	void upsampleH2V1Fancy(JPEGSample* source, int outputRows);
	void upsampleH2V2Fancy(JPEGSample* source, int outputRows);

	// helpers
	static bool isDCOnly(JPEGSample const* dataUnit) { return dataUnit[DataUnitSize - 1] == 1; }

	static void setDCOnly(JPEGSample* dataUnit, bool flag = true)
	{
		dataUnit[DataUnitSize - 1] = flag ? 1 : 0;
	}

	static State getState(int code);

	// attributes
	int m_componentID;
	int m_quantTableIndex;
	int m_bitsInSample;
	int m_vertFreq;
	int m_horzFreq;
	int m_vertSampling;
	int m_horzSampling;
	int m_usefulNoninterleavedRows;
	int m_usefulNoninterleavedCols;
	int m_usefulDataUnitRows;
	int m_usefulDataUnitCols;
	int m_blocksPerRow;
	int m_blocksPerCol;
	int m_rowsPerMCU;
	int m_outRowsPerMCU;
	int m_samplesPerRow;
	int m_eobRun;
	int m_lastDCValue;
	int m_spectralSelectionStart;
	int m_spectralSelectionEnd;
	int m_succApprox;

	State				m_state;
	DCT				m_dct;
	bool				m_progressive;
	bool				m_fancyUpsampling;
	BitStream&		m_bitStream;
	DecodingMethod	m_decodingMethod;
	UpsampleMethod	m_upsampleMethod;

	JPEGSample**	m_upsampledRows;
	JPEGSample***	m_dataUnits;
	JPEGSample**	m_dataUnitRowsBuffer;
	JPEGSample*		m_dataUnitsBuffer;
	JPEGSample****	m_sampleRows;
	JPEGSample***	m_sampleRowsBuffer;
	JPEGSample**	m_sampleColsBuffer;
	JPEGSample*		m_sampleBuffer;
	JPEGSample*		m_upsampleBuffer;

	HuffmanDecoder const* m_acTable;
	HuffmanDecoder const* m_dcTable;
};

} // namespace JPEG

#endif // _jpeg_component_included

// vi:set ts=3 sw=3:
