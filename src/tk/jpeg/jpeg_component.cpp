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

#include "jpeg_component.h"
#include "jpeg_huffman.h"
#include "jpeg_bit_stream.h"
#include "jpeg_dct.h"
#include "jpeg_exception.h"

#include <string.h>
#include <assert.h>

using namespace JPEG;

int const Component::ZigZagOrder[DCTSize] =
{
    0,  1,  8, 16,  9,  2,  3, 10,
   17, 24, 32, 25, 18, 11,  4,  5,
   12, 19, 26, 33, 40, 48, 41, 34,
   27, 20, 13,  6,  7, 14, 21, 28,
   35, 42, 49, 56, 57, 50, 43, 36,
   29, 22, 15, 23, 30, 37, 44, 51,
   58, 59, 52, 45, 38, 31, 39, 46,
   53, 60, 61, 54, 47, 55, 62, 63,
};

namespace {

template <typename T> inline T min(T a, T b) { return a < b ? a : b; }
template <typename T> inline T max(T a, T b) { return a < b ? b : a; }

inline int mul2 (int v) { return v << 1; }
inline int mul3 (int v) { return (v << 1) + v; }
inline int mul4 (int v) { return v << 2; }
inline int div2 (int v) { return v >> 1; }
inline int div4 (int v) { return v >> 2; }
inline int div16(int v) { return v >> 4; }

inline int div_round_up(int x, int y) { return (x + y - 1)/y; }

int
align_up(int value, int alignment)
{
	if (alignment == 0)
		return value;

	int m = value % alignment;
	return m ? value + alignment - m : value;
}

} // namespace


Component::Component(int id,
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
							bool fancyUpsampling)
	:m_componentID(id)
	,m_quantTableIndex(quantTableIndex)
	,m_bitsInSample(bitsInSample)
	,m_vertFreq(vertFrequency)
	,m_horzFreq(horzFrequency)
	,m_vertSampling(maxVertFrequency/m_vertFreq)
	,m_horzSampling(maxHorzFrequency/m_horzFreq)
	,m_usefulNoninterleavedRows(::div_round_up(imageHeight, m_vertSampling*DCTWidth))
	,m_usefulNoninterleavedCols(::div_round_up(imageWidth, m_horzSampling*DCTWidth))
	,m_usefulDataUnitRows(::div_round_up(imageHeight, DCTWidth))
	,m_usefulDataUnitCols(::div_round_up(imageWidth, DCTWidth))
	,m_blocksPerRow(::div_round_up(imageHeight, m_vertFreq*DCTWidth)*m_vertFreq)
	,m_blocksPerCol(::div_round_up(imageWidth, m_horzFreq*DCTWidth)*m_horzFreq)
	,m_rowsPerMCU(maxVertFrequency*DCTWidth)
	,m_outRowsPerMCU(maxVertFrequency*m_vertSampling*DCTWidth)
	,m_samplesPerRow(::align_up((m_usefulDataUnitCols*DCTWidth)/m_horzSampling, DCTWidth))
	,m_eobRun(0)
	,m_lastDCValue(0)
	,m_spectralSelectionStart(0)
	,m_spectralSelectionEnd(0)
	,m_succApprox(0)
	,m_state(Ok)
	,m_dct(m_bitsInSample)
	,m_progressive(progressive)
	,m_fancyUpsampling(fancyUpsampling)
	,m_bitStream(bitStream)
	,m_decodingMethod(0)
	,m_upsampleMethod(0)
	,m_upsampledRows(0)
	,m_dataUnits(0)
	,m_dataUnitsBuffer(0)
	,m_sampleRows(0)
	,m_sampleRowsBuffer(0)
	,m_sampleColsBuffer(0)
	,m_sampleBuffer(0)
	,m_upsampleBuffer(0)
	,m_acTable(0)
	,m_dcTable(0)
{
	if (m_vertFreq > 4 || m_horzFreq > 4)
		throw Exception("unsupported frequency (higher than 4)");

	if (	m_vertSampling*m_vertFreq != maxVertFrequency
		|| m_horzSampling*m_horzFreq != maxHorzFrequency)
	{
		throw Exception("fractional sampling not supported");
	}

	setupBuffers(m_usefulDataUnitCols*DCTWidth*m_horzSampling);

	if (m_horzSampling == 1 && m_vertSampling == 1)
	{
		m_upsampleMethod = &Component::upsampleH1V1;
	}
	else if (m_horzSampling == 2 && m_vertSampling == 1)
	{
		if (m_fancyUpsampling && m_samplesPerRow >= 2)
			m_upsampleMethod = &Component::upsampleH2V1Fancy;
		else
			m_upsampleMethod = &Component::upsampleH2V1;
	}
	else if (m_horzSampling == 1 && m_vertSampling == 2)
	{
//	XXX not working!
//		if (m_fancyUpsampling && m_outRowsPerMCU >= 2)
//			m_upsampleMethod = &Component::upsampleH1V2Fancy;
//		else
			m_upsampleMethod = &Component::upsampleH1V2;
	}
	else if (m_horzSampling == 2 && m_vertSampling == 2)
	{
//	XXX not working!
//		if (m_fancyUpsampling && m_samplesPerRow >= 2 && m_outRowsPerMCU >= 2)
//			m_upsampleMethod = &Component::upsampleH2V2Fancy;
//		else
			m_upsampleMethod = &Component::upsampleH2V2;
	}
	else	// m_horzSampling == 4 || m_vertSampling == 4
	{
		m_upsampleMethod = &Component::upsampleGeneric;
	}
}


void
Component::setup(	JPEGSample const quantValues[DCTSize],
						HuffmanDecoder const* acTable,
						HuffmanDecoder const* dcTable,
						int spectralSelectionStart, int spectralSelectionEnd,
						int succApproxLo, int succApproxHi)
{
	if (	(acTable == 0 && (!m_progressive || spectralSelectionStart > 0))
		|| (dcTable == 0 && (!m_progressive || spectralSelectionStart == 0)))
	{
		throw Exception("undefined Huffman table used in scan");
	}

	DCT::QuantValues qvalues;

	for (int i = 0; i < DCTSize; ++i)
		qvalues[ZigZagOrder[i]] = quantValues[i];

	m_dct.setupQuantization(qvalues);

	m_acTable						= acTable;
	m_dcTable						= dcTable;
	m_spectralSelectionStart	= spectralSelectionStart;
	m_spectralSelectionEnd		= spectralSelectionEnd;
	m_succApprox					= succApproxLo;
	m_eobRun							= 0;
	m_lastDCValue					= 0;

	if (!m_progressive)
		m_decodingMethod = &Component::decodeSequentialDataUnit;
	else if (m_spectralSelectionStart == 0)
		m_decodingMethod = succApproxHi ? &Component::decodeDCRefine : &Component::decodeDCFirst;
	else
		m_decodingMethod = succApproxHi ? &Component::decodeACRefine : &Component::decodeACFirst;
}


Component::~Component()
{
	delete [] m_upsampledRows;
	delete [] m_dataUnits;
	delete [] m_dataUnitRowsBuffer;
	delete [] m_dataUnitsBuffer;
	delete [] m_sampleRows;
	delete [] m_sampleRowsBuffer;
	delete [] m_sampleColsBuffer;
	delete [] m_sampleBuffer;
	delete [] m_upsampleBuffer;
}


void
Component::setupUnitLineBuffer(int numRows)
{
	int rowSize = m_samplesPerRow*DCTWidth;

	m_sampleBuffer = new JPEGSample[numRows*rowSize];

	JPEGSample***	sampleRowsBuffer	= m_sampleRowsBuffer;
	JPEGSample**	sampleColsBuffer	= m_sampleColsBuffer;
	JPEGSample*		sampleBuffer		= m_sampleBuffer;

	for (int i = 0; i < numRows; ++i, sampleBuffer += rowSize)
	{
		m_sampleRows[i] = sampleRowsBuffer;

		JPEGSample* buffer = sampleBuffer;

		for (int j = 0; j < m_blocksPerCol; ++j, buffer += DCTWidth)
		{
			*sampleRowsBuffer++ = sampleColsBuffer;

			JPEGSample* b = buffer;

			for (int k = 0; k < DCTWidth; ++k, b += m_samplesPerRow)
				*sampleColsBuffer++ = b;
		}
	}

	for (int i = numRows, k = 0; i < m_blocksPerRow; ++i)
	{
		m_sampleRows[i] = m_sampleRows[k];

		if (++k == numRows)
			k = 0;
	}
}


void
Component::setupUnitBuffer(int dataUnitSize)
{
	JPEGSample**	dataUnitRowsBuffer	= m_dataUnitRowsBuffer;
	JPEGSample*		dataUnitsBuffer		= m_dataUnitsBuffer;

	for (int i = 0; i < m_blocksPerRow; ++i, dataUnitRowsBuffer += m_blocksPerCol)
	{
		m_dataUnits[i] = dataUnitRowsBuffer;

		for (int k = 0; k < m_blocksPerCol; ++k, dataUnitsBuffer += dataUnitSize)
			dataUnitRowsBuffer[k] = dataUnitsBuffer;
	}

	if (m_progressive)
	{
		::memset(m_dataUnitsBuffer, 0, m_blocksPerRow*m_blocksPerCol*DataUnitSize*sizeof(JPEGSample));

		JPEGSample* p = m_dataUnitsBuffer;
		JPEGSample* e = p + m_blocksPerRow*m_blocksPerCol*DataUnitSize;

		for ( ; p < e; p += DataUnitSize)
			setDCOnly(p);
	}
	else
	{
		setDCOnly(m_dataUnitsBuffer, false);
	}
}


void
Component::setupBuffers(int pixelsPerRow)
{
	int numDataUnits = m_blocksPerRow*m_blocksPerCol;

	m_upsampledRows		= new JPEGSample*[m_outRowsPerMCU];
	m_sampleRows			= new JPEGSample***[m_blocksPerRow];
	m_dataUnits				= new JPEGSample**[m_blocksPerRow];

	m_dataUnitRowsBuffer	= new JPEGSample*[numDataUnits];
	m_dataUnitsBuffer		= new JPEGSample[m_progressive ? numDataUnits*DataUnitSize : DataUnitSize];

	m_sampleRowsBuffer	= new JPEGSample**[numDataUnits];
	m_sampleColsBuffer	= new JPEGSample*[numDataUnits*DCTWidth];

	setupUnitLineBuffer(::min(m_blocksPerRow, m_vertFreq));
	setupUnitBuffer(m_progressive ? DataUnitSize : 0);

#if !defined(NDEBUG) && !defined(__OPTIMIZE__)
	::memset(m_upsampledRows, 0, m_outRowsPerMCU*sizeof(m_upsampledRows[0]));
#endif

	if (m_horzSampling > 1 || m_vertSampling > 1 + (m_fancyUpsampling ? 0 : 1))
	{
		int rowsPerMCU = m_fancyUpsampling ? m_outRowsPerMCU : m_rowsPerMCU;
		m_upsampleBuffer = new JPEGSample[pixelsPerRow*rowsPerMCU];
	}
}


Component::State
Component::getState(int code)
{
	switch (code)
	{
		case HuffmanDecoder::UnexpectedEndOfStream:	return PrematureEndOfScan;
		case HuffmanDecoder::BadCodeLength:				return BadCodeLength;
		case HuffmanDecoder::BadCode:						return BadCode;
	}

	return InternalError;
}


void
Component::setState(State state)
{
	if (m_state == Ok)
		m_state = state;
}


inline
int
Component::nextCode(HuffmanDecoder const* decoder)
{
	int rc = decoder->nextCode(m_bitStream);

	if (rc < 0)
	{
		if (rc == HuffmanDecoder::BadCodeLength)
		{
			setState(BadCodeLength);
			return 0;
		}

		throw getState(rc);
	}

	return rc;
}


int
Component::readBits(int n)
{
	if (n == 0)
		return 0;

	assert(n <= m_bitStream.MaxBits);

	if (m_bitStream.fetchBits(n) < n)
		throw PrematureEndOfScan;

	return m_bitStream.nextBits(n);
}


int
Component::readExtendedBits(int n)
{
	if (n == 0)
		return 0;

	assert(n <= m_bitStream.MaxBits);

	if (m_bitStream.fetchBits(n) < n)
		throw PrematureEndOfScan;

	int s = m_bitStream.nextBits(n);

	return s < (1 << (n - 1)) ? s + (-1 << n) + 1 : s;
}


void
Component::decodeDataUnit(int duRow, int duCol, Mode mode, bool useful)
{
	assert(duRow < m_blocksPerRow);
	assert(duCol < m_blocksPerCol);

	JPEGSample*	dataUnit	= m_dataUnits[duRow][duCol];

	if (mode == Decode)
		(this->*m_decodingMethod)(dataUnit);

	if (useful && (mode == Update || !m_progressive))
	{
		m_dct.inverseDCT(
			isDCOnly(dataUnit) ? DCT::FirstCoeffOnly : DCT::AllCoeffs,
			dataUnit,
			m_sampleRows[duRow][duCol]);
	}
}


Component::State
Component::processMCU(int mcuRow, int mcuCol, Mode mode, bool interleaved)
{
	assert(m_decodingMethod);

	State rc = Ok;

	try
	{
		if (interleaved)
		{
			int duRow		= mcuRow*m_vertFreq;
			int duColOffs	= mcuCol*m_horzFreq;

			for (int y = 0; y < m_vertFreq; ++y, ++duRow)
			{
				int	duCol		= duColOffs;
				bool	useful	= duRow < m_usefulDataUnitRows;

				for (int x = 0; x < m_horzFreq; ++x, ++duCol)
					decodeDataUnit(duRow, duCol, mode, useful && duCol < m_usefulDataUnitCols);
			}
		}
		else
		{
			decodeDataUnit(mcuRow,
								mcuCol,
								mode,
								mcuRow < m_usefulNoninterleavedRows && mcuCol < m_usefulNoninterleavedCols);
		}
	}
	catch (State state)
	{
		rc = state;
	}

	return rc;
}


void
Component::upsampleMCURow(int mcuRow __attribute__((unused)), int outputRows)
{
	assert(outputRows <= m_outRowsPerMCU);
	assert(mcuRow < m_blocksPerRow);

	(this->*m_upsampleMethod)(m_sampleBuffer, outputRows);
}


void
Component::decodeSequentialDataUnit(JPEGSample* dataUnit)
{
	::memset(dataUnit, 0, DCTSize*sizeof(dataUnit[0]));
	setDCOnly(dataUnit);

	m_lastDCValue += readExtendedBits(nextCode(m_dcTable));
	dataUnit[0] = m_lastDCValue;

	for (int i = 1; i < DCTSize; )
	{
		int bits = nextCode(m_acTable);
		int code = bits & 0xf;
		int skip = (bits >> 4) & 0xf;

		if (code == 0)
		{
			if (skip != 15)
				return;

			i += 16;
		}
		else
		{
			if ((i += skip) >= DCTSize)
				throw InvalidCodeInSequentialData;

			dataUnit[ZigZagOrder[i++]] = readExtendedBits(code);
			setDCOnly(dataUnit, false);
		}
	}
}


bool
Component::updateCoeff(JPEGSample* dataUnit, JPEGSample* coeff)
{
	// NOTE gcc-3.4 error: compilation of 'if (readBits(1) && (...) == 0)' fails
	if (readBits(1) != 0 && (*coeff & (1 << m_succApprox)) == 0)
	{
		*coeff += (*coeff >= 0 ? 1 : -1) << m_succApprox;
		setDCOnly(dataUnit, false);
	}

	return true;
}


inline
bool
Component::refineCoeff(JPEGSample* dataUnit, int pos)
{
	JPEGSample* thisCoeff = &dataUnit[pos];
	return *thisCoeff == 0 ? false : updateCoeff(dataUnit, thisCoeff);
}


void
Component::decodeACFirst(JPEGSample* dataUnit)
{
	if (m_eobRun > 0)
	{
		--m_eobRun;
	}
	else
	{
		for (int i = m_spectralSelectionStart; i <= m_spectralSelectionEnd; ++i)
		{
			int bits = nextCode(m_acTable);
			int code = bits & 0xf;
			int skip = (bits >> 4) & 0xf;

			if (code == 0)
			{
				if (skip == 15)
				{
					i += 15;
				}
				else
				{
					m_eobRun = skip ? (1 << skip) + readBits(skip) - 1 : 0;
					return;
				}
			}
			else
			{
				if ((i += skip) >= DCTSize)
					throw InvalidCodeInProgressiveScan;

				dataUnit[ZigZagOrder[i]] = readExtendedBits(code) << m_succApprox;
				setDCOnly(dataUnit, false);
			}
		}
	}
}


int
Component::refineAC(JPEGSample* dataUnit)
{
	int i = m_spectralSelectionStart;

	for ( ; i <= m_spectralSelectionEnd; ++i)
	{
		int bits = nextCode(m_acTable);
		int code = bits & 0xf;
		int skip = (bits >> 4) & 0xf;

		if (code == 0)
		{
			if (skip != 15)
			{
				m_eobRun = skip ? (1 << skip) + readBits(skip) : 1;
				return i;
			}
		}
		else if (code == 1)
		{
			code = (readBits(1) ? 1 : -1) << m_succApprox;
		}
		else
		{
			throw InvalidCodeInProgressiveScan;
		}

		while (refineCoeff(dataUnit, ZigZagOrder[i]) || --skip >= 0)
		{
			if (++i > m_spectralSelectionEnd)
			{
				setState(ErrorInProgressiveScan);
				return m_spectralSelectionEnd;
			}
		}

		if (code)
		{
			dataUnit[ZigZagOrder[i]] = code;
			setDCOnly(dataUnit, false);
		}
	}

	return i;
}


void
Component::decodeACRefine(JPEGSample* dataUnit)
{
	int i = m_eobRun == 0 ? refineAC(dataUnit) : m_spectralSelectionStart;

	if (m_eobRun > 0)
	{
		for ( ; i <= m_spectralSelectionEnd; ++i)
			refineCoeff(dataUnit, ZigZagOrder[i]);

		--m_eobRun;
	}
}


void
Component::decodeDCFirst(JPEGSample* dataUnit)
{
	dataUnit[0] = (m_lastDCValue += readExtendedBits(nextCode(m_dcTable))) << m_succApprox;
}


void
Component::decodeDCRefine(JPEGSample* dataUnit)
{
	if (readBits(1))
		dataUnit[0] |= 1 << m_succApprox;
}


void
Component::upsampleH1V1(JPEGSample* source, int outputRows)
{
	JPEGSample** e = m_upsampledRows + outputRows;

	for (JPEGSample** p = m_upsampledRows; p < e; ++p, source += m_samplesPerRow)
		*p = source;
}


void
Component::upsampleH1V2(JPEGSample* source, int outputRows)
{
	JPEGSample** e = m_upsampledRows + outputRows;

	for (JPEGSample** p = m_upsampledRows; p < e; source += m_samplesPerRow)
	{
		*p++ = source;
		*p++ = source;
	}
}


void
Component::upsampleH2V1(JPEGSample* source, int outputRows)
{
	JPEGSample**	e = m_upsampledRows + outputRows;
	JPEGSample*		b = m_upsampleBuffer;

	for (JPEGSample** p = m_upsampledRows; p < e; ++p)
	{
		*p = b;

		for (JPEGSample* f = source + m_samplesPerRow; source < f; ++source)
		{
			*b++ = *source;
			*b++ = *source;
		}
	}
}


void
Component::upsampleH2V2(JPEGSample* source, int outputRows)
{
	JPEGSample**	e = m_upsampledRows + outputRows;
	JPEGSample*		b = m_upsampleBuffer;

	for (JPEGSample** p = m_upsampledRows; p < e; )
	{
		*p++ = b;
		*p++ = b;

		for (JPEGSample* f = source + m_samplesPerRow; source < f; ++source)
		{
			*b++ = *source;
			*b++ = *source;
		}
	}
}


void
Component::upsampleGeneric(JPEGSample* source, int outputRows)
{
	JPEGSample**	p = m_upsampledRows;
	JPEGSample**	e = m_upsampledRows + outputRows;
	JPEGSample*		b = m_upsampleBuffer;

	while (p < e)
	{
		for (JPEGSample** e = p + m_vertSampling; p < e; ++p)
			*p = b;

		for (JPEGSample* f = source + m_samplesPerRow; source < f; ++source)
		{
			for (JPEGSample* g = b + m_horzSampling; b < g; ++b)
				*b = *source;
		}
	}
}


void
Component::upsampleH2V1Fancy(JPEGSample* source, int outputRows)
{
	assert(m_samplesPerRow >= 2);

	JPEGSample**	e = m_upsampledRows + outputRows;
	JPEGSample*		b = m_upsampleBuffer;
	JPEGSample		v;

	for (JPEGSample** p = m_upsampledRows; p < e; ++p)
	{
		*p = b;

		v = *source++;

		*b++ = v;
		*b++ = ::div4(::mul3(v) + source[0] + 2);

		for (JPEGSample* f = source + m_samplesPerRow - 2; source < f; )
		{
			v = ::mul3(*source++);

			*b++ = ::div4(v + source[-2] + 1);
			*b++ = ::div4(v + source[ 0] + 2);
		}

		v = *source++;

		*b++ = ::div4(::mul3(v) + source[-1] + 1);
		*b++ = v;
	}
}


void
Component::upsampleH1V2Fancy(JPEGSample* source, int outputRows)
{
	if (outputRows <= 1)
		return upsampleH1V2(source, outputRows);

	JPEGSample**	p = m_upsampledRows;
	JPEGSample**	e = m_upsampledRows + outputRows;
	JPEGSample*		b = m_upsampleBuffer;

	JPEGSample* curr = source;
	JPEGSample* prev = source;
	JPEGSample* next = source + m_samplesPerRow;

	JPEGSample* b0;
	JPEGSample* b1;

	*p++ = b;
	*p++ = b1 = (b += m_samplesPerRow);

	for (JPEGSample* f = curr + m_samplesPerRow; curr < f; ++curr, ++prev)
		*b1++ = ::div4(::mul3(*curr) + *prev + 2);

	for (JPEGSample** p = m_upsampledRows; p < e ; )
	{
		*p++ = b0 = (b += m_samplesPerRow);
		*p++ = b1 = (b += m_samplesPerRow);

		for (JPEGSample* f = curr + m_samplesPerRow; curr < f; ++curr, ++prev, ++next)
		{
			JPEGSample v = ::mul3(*curr);

			*b0++ = ::div4(v + *prev + 1);
			*b1++ = ::div4(v + *next + 2);
		}
	}

	*p++ = b0 = (b += m_samplesPerRow);
	*p++ = (b += m_samplesPerRow);

	for (JPEGSample* f = curr + m_samplesPerRow; curr < f; ++curr, ++next)
		*b0++ = ::div4(::mul3(*curr) + *next + 1);
}


void
Component::upsampleH2V2Fancy(JPEGSample* source, int outputRows)
{
	if (outputRows == 1)
		return upsampleH2V2(source, outputRows);

	assert(m_samplesPerRow >= 2);

	JPEGSample*		b = m_upsampleBuffer;
	JPEGSample**	e = m_upsampledRows + outputRows;

	JPEGSample* srcBeforeLast = source + (outputRows - 1)*m_samplesPerRow;

	int curr_col_sum;
	int next_col_sum;
	int prev_col_sum;

	for (JPEGSample** p = m_upsampledRows; p < e; )
	{
		JPEGSample* curr = source;
		JPEGSample* prev = ::max(curr - m_samplesPerRow, source);
		JPEGSample* next = ::min(curr + m_samplesPerRow, srcBeforeLast);

		for (int n = 0; n < 2; ++n)
		{
			*p++ = b;

			JPEGSample* src0 = curr;
			JPEGSample* src1 = (n == 0 ? prev : next);

			curr_col_sum = ::mul3(*src0++) + *src1++;
			next_col_sum = ::mul3(*src0++) + *src1++;

			*b++ = ::div16(::mul4(curr_col_sum) + 8);
			*b++ = ::div16(::mul3(curr_col_sum) + next_col_sum + 7);

			for (JPEGSample* f = curr + m_samplesPerRow; src0 < f; ++src0, ++src1)
			{
				prev_col_sum = curr_col_sum;
				curr_col_sum = next_col_sum;
				next_col_sum = mul3(*src0) + *src1;

				*b++ = ::div16(::mul3(curr_col_sum) + prev_col_sum + 8);
				*b++ = ::div16(::mul3(curr_col_sum) + next_col_sum + 7);

			}

			prev_col_sum = curr_col_sum;
			curr_col_sum = next_col_sum;

			*b++ = ::div16(::mul3(curr_col_sum) + prev_col_sum + 8);
			*b++ = ::div16(::mul4(curr_col_sum) + 7);
		}

		source = next;
	}
}


char const*
Component::errorMessage(State state)
{
	switch (state)
	{
		case Ok:										return "<no error>";
		case PrematureEndOfScan:				return "premature end of scan";
		case BadCodeLength:						return "bad code length";
		case BadCode:								return "bad code";
		case CorruptScanData:					return "corrupt scan data";
		case ErrorInProgressiveScan:			return "error in progressive scan";
		case InvalidCodeInProgressiveScan:	return "invalid code in progressive scan";
		case InvalidCodeInSequentialData:	return "invalid code in sequential data";
		case InternalError:						return "internal error in Huffman decoder";
	}

	return "";	// satisfies the compiler
}

// vi:set ts=3 sw=3:
