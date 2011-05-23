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

#ifndef _jpeg_color_conv_included
#define _jpeg_color_conv_included

#include "jpeg_base.h"

#include <stdint.h>

namespace JPEG {

class Scanline;

// helper struct that makes template instantiation possible
template <int N,int Colorspace=0> struct JPEG { typedef JPEGSample Sample; };

// possible instances:
// -------------------
// Colorspace = kGrayscale,  N = 8/12 bps; output =  8/16 bpp
// Colorspace = kGrayAlpha,  N = 8/12 bps; output = 16/32 bpp
// Colorspace = kRGB,        N = 8/12 bps; output = 24/48 bpp
// Colorspace = kRGBA,       N = 8/12 bps; output = 32/64 bpp
// Colorspace = kYCC,        N = 8/12 bps; output = 24/48 bpp
// Colorspace = kYCCA,       N = 8/12 bps; output = 32/64 bpp
// Colorspace = kYCCK_Adobe, N = 8/12 bps; output = 24/48 bpp
// Colorspace = kYCCK_JPEG,  N = 8/12 bps; output = 24/48 bpp
// Colorspace = kPhotoYCC,   N = 8/12 bps; output = 24/48 bpp
// Colorspace = kPhotoYCCA,  N = 8/12 bps; output = 32/64 bpp
// Colorspace = kCMY,        N = 8/12 bps; output = 24/48 bpp
// Colorspace = kCMYK_Adobe, N = 8/12 bps; output = 24/48 bpp
// Colorspace = kCMYK_JPEG,  N = 8/12 bps; output = 24/48 bpp
template <int Colorspace, int N>
struct Converter
{
	static void processRow(	JPEGSample const* src0,
									JPEGSample const* src1,
									JPEGSample const* src2,
									JPEGSample const* src3,
									Scanline& dst);
};

template<int> struct PixelBase;
template<> struct PixelBase<8 > { typedef uint32_t Type; typedef uint8_t  Sample; };
template<> struct PixelBase<16> { typedef uint64_t Type; typedef uint16_t Sample; };

template <int N>
struct Pixel
{
	enum { R = Base::R, G = Base::G, B = Base::B, A = Base::A };

	typedef typename PixelBase<N>::Sample	Sample;
	typedef typename PixelBase<N>::Type		Type;

	static int32_t const MaxSample = Sample(~Sample(0));

	static Type pixel(int32_t r, int32_t g, int32_t b)
	{
		return (Type(r) << R*N) | (Type(g) << G*N) | (Type(b) << B*N) | (Type(MaxSample) << A*N);
	}

	static Type pixel(int32_t r, int32_t g, int32_t b, int32_t a)
	{
		return (Type(r) << R*N) | (Type(g) << G*N) | (Type(b) << B*N) | (Type(a) << A*N);
	}
};

// Following instances are defined:
// < 8, 8> means: expecting  8 bit samples, returning 4*8 bit color pixel
// <12,16> means: expecting 12 bit samples, returning 4*16 bit color pixel

template <int N, int M>
typename Pixel<M>::Type
convRGBtoRGB(	typename JPEG<N>::Sample r,
					typename JPEG<N>::Sample g,
					typename JPEG<N>::Sample b);

template <int N, int M>
typename Pixel<M>::Type
convRGBAtoRGBA(typename JPEG<N>::Sample r,
					typename JPEG<N>::Sample g,
					typename JPEG<N>::Sample b,
					typename JPEG<N>::Sample a);

template <int N, int M>
typename Pixel<M>::Type
convYCCtoRGB(	typename JPEG<N>::Sample y,
					typename JPEG<N>::Sample u,
					typename JPEG<N>::Sample v);

template <int N, int M>
typename Pixel<M>::Type
convYCCAtoRGBA(typename JPEG<N>::Sample y,
					typename JPEG<N>::Sample u,
					typename JPEG<N>::Sample v,
					typename JPEG<N>::Sample a);

template <int N, int M>
typename Pixel<M>::Type
convCMYtoRGB_Adobe(	typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y);

template <int N, int M>
typename Pixel<M>::Type
convCMYKtoRGB_Adobe(	typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k);

template <int N, int M>
typename Pixel<M>::Type
convCMYKtoRGB_JPEG(	typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k);

template <int N, int M>
typename Pixel<M>::Type
convYCCKtoRGB_Adobe(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k);

template <int N, int M>
typename Pixel<M>::Type
convYCCKtoRGB_JPEG(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k);

template <int N, int M>
typename Pixel<M>::Type
convPhotoYCCtoRGB(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v);

template <int N, int M>
typename Pixel<M>::Type
convPhotoYCCAtoRGBA(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample a);

} // namespace JPEG

#endif // _jpeg_color_conv_included

// vi:set ts=3 sw=3:
