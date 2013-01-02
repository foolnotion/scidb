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

#ifndef _jpeg_dct_included
#define _jpeg_dct_included

#include "jpeg_base.h"

namespace JPEG {

class DCT
{
public:

	// types
	typedef JPEGSample QuantValues[64];

	enum Mode { FirstCoeffOnly, AllCoeffs };

	// nested classes
	struct Impl
	{
		// types
		typedef float QuantTable[Base::DCTSize];

		// structors
		virtual ~Impl() = 0;

		// modifiers
		virtual void setupQuantization(QuantTable const& quantValues) = 0;

		// computation
		virtual void idct(JPEGSample** result, JPEGSample const* coefBlock) = 0;
	};

	// structors
	DCT(int bitsInSample);
	~DCT();

	// modifiers
	void setupQuantization(QuantValues const& quantValues);

	// conversion
	void inverseDCT(Mode mode, JPEGSample const* coefBlock, JPEGSample** result);

private:

	// conversion
	JPEGSample idct8(JPEGSample coef);
	void idct8(JPEGSample** result, JPEGSample const* coefBlock);

	JPEGSample idct12(JPEGSample coef);
	void idct12(JPEGSample** result, JPEGSample const* coefBlock);

	// attributes
	Impl*	m_impl;
	float	m_quant0;
	int	m_bitsInSample;
};

} // namespace JPEG

#endif // _jpeg_dct_included

// vi:set ts=3 sw=3:
