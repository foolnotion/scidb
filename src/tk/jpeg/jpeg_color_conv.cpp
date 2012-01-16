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

#include "jpeg_color_conv.h"
#include "jpeg_scanline.h"

#include <stdint.h>
#include <string.h>
#include <assert.h>

#if defined(__i386__) || defined(__x86_64__)
# define HAS_UNALIGNED_WORD_ACCESS 1
#endif


using namespace JPEG;

extern "C" {

static struct
{
	int32_t CrToR[256];
	int32_t CbToB[256];
	int32_t CbToG[256];
	int32_t CrToG[256];
}
YCC8 =
{
#include "data/jpeg_ycc_to_rgb_8.dat"
};

static struct
{
	int32_t YtoL[256];
	int32_t VtoR[256];
	int32_t UtoB[256];
	int32_t VtoG[256];
	int32_t UtoG[256];
}
PYCC8 =
{
#include "data/jpeg_pycc_to_rgb_8.dat"
};

#ifdef JPEG_SUPPORT_12_BIT

static struct
{
	int32_t CrToR[4096];
	int32_t CbToB[4096];
	int32_t CbToG[4096];
	int32_t CrToG[4096];
}
YCC12 =
{
#include "data/jpeg_ycc_to_rgb_12.dat"
};

static struct
{
	int32_t YtoL[4096];
	int32_t VtoR[4096];
	int32_t UtoB[4096];
	int32_t VtoG[4096];
	int32_t UtoG[4096];
}
PYCC12 =
{
#include "data/jpeg_pycc_to_rgb_12.dat"
};

#endif

} // extern "C"


namespace {

typedef unsigned char Byte;
typedef Byte const* Bytes;
typedef JPEGSample* Samples;


template <int> struct Sample;
template <> struct Sample< 8> { typedef uint8_t Type; };
template <> struct Sample<12> { typedef uint16_t Type; };

template <int> struct Int;
template <> struct Int< 8> { typedef uint32_t Type; };
template <> struct Int<16> { typedef uint64_t Type; };


template <int ColorSpace,int N> struct Mapper;

template <>
struct Mapper<YCC,8>
{
	inline static int32_t vToR(JPEGSample v) { return YCC8.CrToR[v]; }
	inline static int32_t uToB(JPEGSample v) { return YCC8.CbToB[v]; }
	inline static int32_t utoG(JPEGSample v) { return YCC8.CbToG[v]; }
	inline static int32_t vToG(JPEGSample v) { return YCC8.CrToG[v]; }
};

template <>
struct Mapper<PhotoYCC,8>
{
	inline static int32_t yToL(JPEGSample v) { return PYCC8.YtoL[v]; }
	inline static int32_t vToR(JPEGSample v) { return PYCC8.VtoR[v]; }
	inline static int32_t uToB(JPEGSample v) { return PYCC8.UtoB[v]; }
	inline static int32_t vToG(JPEGSample v) { return PYCC8.VtoG[v]; }
	inline static int32_t uToG(JPEGSample v) { return PYCC8.UtoG[v]; }
};

#ifdef JPEG_SUPPORT_12_BIT

template <>
struct Mapper<YCC,12>
{
	inline static int32_t vToR(JPEGSample v) { return YCC12.CrToR[v];}
	inline static int32_t uToB(JPEGSample v) { return YCC12.CbToB[v];}
	inline static int32_t utoG(JPEGSample v) { return YCC12.CbToG[v];}
	inline static int32_t vToG(JPEGSample v) { return YCC12.CrToG[v];}
};

template <>
struct Mapper<PhotoYCC,12>
{
	inline static int32_t yToL(JPEGSample v) { return PYCC12.YtoL[v]; }
	inline static int32_t vToR(JPEGSample v) { return PYCC12.VtoR[v]; }
	inline static int32_t uToB(JPEGSample v) { return PYCC12.UtoB[v]; }
	inline static int32_t vToG(JPEGSample v) { return PYCC12.VtoG[v]; }
	inline static int32_t uToG(JPEGSample v) { return PYCC12.UtoG[v]; }
};

#endif

template <int N> int32_t clamp(int32_t sample);
template <int N, int M> int32_t resample(JPEGSample v);

template <> inline int32_t resample< 8, 8>(JPEGSample v) { return v; }
template <> inline int32_t resample< 8,16>(JPEGSample v) { return (v << 8) + v; }
template <> inline int32_t resample<12,16>(JPEGSample v) { return (v << 4) + (v + 136)/273; }

template <>
inline
int32_t
clamp<8>(int32_t sample)
{
	return sample & 0xffffff00 ? (~sample >> (sizeof(JPEGSample)*8 - 1)) & 0x000000ff : sample;
}

template <>
inline
int32_t
clamp<12>(int32_t sample)
{
	return sample & 0xfffff000 ? (~sample >> (sizeof(JPEGSample)*8 - 1)) & 0x00000fff : sample;
}


inline
int32_t
__attribute__((always_inline))
descale(int32_t sample)
{
	return sample >> 16;
}

} // namespace


namespace JPEG {

template <int N, int M>
typename Pixel<M>::Type
convRGBtoRGB(typename JPEG<N>::Sample r, typename JPEG<N>::Sample g, typename JPEG<N>::Sample b)
{
	return Pixel<M>::pixel(resample<N,M>(r), resample<N,M>(g), resample<N,M>(b));
}


template <int N, int M>
typename Pixel<M>::Type
convRGBAtoRGBA(typename JPEG<N>::Sample r,
					typename JPEG<N>::Sample g,
					typename JPEG<N>::Sample b,
					typename JPEG<N>::Sample a)
{
	return Pixel<M>::pixel(resample<N,M>(r), resample<N,M>(g), resample<N,M>(b), resample<N,M>(a));
}


template <int N, int M>
typename Pixel<M>::Type
convCMYtoRGB(typename JPEG<N>::Sample c, typename JPEG<N>::Sample m, typename JPEG<N>::Sample y)
{
	return Pixel<M>::pixel( resample<N,M>(Pixel<M>::MaxSample - c),
									resample<N,M>(Pixel<M>::MaxSample - m),
									resample<N,M>(Pixel<M>::MaxSample - y));
}


template <int N, int M>
typename Pixel<M>::Type
convCMYKtoRGB_JPEG(	typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k)
{
	int32_t km = Pixel<M>::MaxSample - k;

	return Pixel<M>::pixel(
				resample<N,M>((km*int32_t(Pixel<M>::MaxSample - c))/Pixel<M>::MaxSample),
				resample<N,M>((km*int32_t(Pixel<M>::MaxSample - m))/Pixel<M>::MaxSample),
				resample<N,M>((km*int32_t(Pixel<M>::MaxSample - y))/Pixel<M>::MaxSample));
}


template <int N, int M>
typename Pixel<M>::Type
convCMYKtoRGB_Adobe(	typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k)
{
	return Pixel<M>::pixel(	resample<N,M>((int32_t(k)*int32_t(c))/Pixel<M>::MaxSample),
									resample<N,M>((int32_t(m)*int32_t(c))/Pixel<M>::MaxSample),
									resample<N,M>((int32_t(y)*int32_t(c))/Pixel<M>::MaxSample));
}


template <int N, int M>
typename Pixel<M>::Type
convYCCtoRGB(typename JPEG<N>::Sample y, typename JPEG<N>::Sample u, typename JPEG<N>::Sample v)
{
	return Pixel<M>::pixel(
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::vToR(v)))),
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::uToB(u)))));
}


template <int N, int M>
typename Pixel<M>::Type
convYCCAtoRGBA(typename JPEG<N>::Sample y,
					typename JPEG<N>::Sample u,
					typename JPEG<N>::Sample v,
					typename JPEG<N>::Sample a)
{
	return Pixel<M>::pixel(
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::vToR(v)))),
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
					resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::uToB(u)))),
					resample<N,M>(a));
}


template <int N, int M>
typename Pixel<M>::Type
convYCCKtoRGB_Adobe(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k)
{
	static const int32_t MaxSample = (int32_t(1) << N) - 1;

	return convCMYKtoRGB_Adobe<N,M>(
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::vToR(v)))),
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::uToB(u)))),
					k);
}


template <int N, int M>
typename Pixel<M>::Type
convYCCKtoRGB_JPEG(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k)
{
	static const int32_t MaxSample = (int32_t(1) << N) - 1;

	return convCMYKtoRGB_JPEG<N,M>(
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::vToR(v)))),
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
					clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::uToB(u)))),
					k);
}


template <int N, int M>
typename Pixel<M>::Type
convPhotoYCCtoRGB(typename JPEG<N>::Sample y,
						typename JPEG<N>::Sample u,
						typename JPEG<N>::Sample v)
{
	int32_t L = Mapper<PhotoYCC,N>::yToL(y);

	// NOTE
	// The code values can range from 0 to 346. If simply clipped to the eight bit
	// per color code value range (i.e. 0 to 255), the displayed image would suffer
	// a significant loss of highlight information.
	return Pixel<M>::pixel(
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::vToR(v)))),
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToG(u) + Mapper<PhotoYCC,N>::vToG(u)))),
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToB(u)))));
}


template <int N, int M>
typename Pixel<M>::Type
convPhotoYCCAtoRGBA(	typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample a)
{
	int32_t L = Mapper<PhotoYCC,N>::yToL(y);

	// NOTE
	// The code values can range from 0 to 346. If simply clipped to the eight bit
	// per color code value range (i.e. 0 to 255), the displayed image would suffer
	// a significant loss of highlight information.
	return Pixel<M>::pixel(
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::vToR(v)))),
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToG(u) + Mapper<PhotoYCC,N>::vToG(u)))),
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToB(u)))),
		resample<N,M>(a));
}

#ifndef HAS_UNALIGNED_WORD_ACCESS

template <int M, int Channel> struct Copy;


template <int Channel>
struct Copy<8, Channel>
{
	inline static void set(Byte* dst, uint8_t sample) { dst[Channel] = sample; }
};


template <int Channel>
struct Copy<16, Channel>
{
	inline static void
	set(Byte* dst, uint16_t sample)
	{
		dst[2*Channel    ] = reinterpret_cast<char*>(sample)[0];
		dst[2*Channel + 1] = reinterpret_cast<char*>(sample)[1];
	}
};


template <int N, int M>
void
convRGBtoRGB(	Byte* dst,
					typename JPEG<N>::Sample r,
					typename JPEG<N>::Sample g,
					typename JPEG<N>::Sample b)
{
	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>(r));
	Copy<M,Pixel<M>::G>::set(dst, resample<N,M>(g));
	Copy<M,Pixel<M>::G>::set(dst, resample<N,M>(b));
}


template <int N, int M>
void
convCMYtoRGB(	Byte* dst,
					typename JPEG<N>::Sample c,
					typename JPEG<N>::Sample m,
					typename JPEG<N>::Sample y)
{
	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>(Pixel<M>::MaxSample - c));
	Copy<M,Pixel<M>::G>::set(dst, resample<N,M>(Pixel<M>::MaxSample - m));
	Copy<M,Pixel<M>::B>::set(dst, resample<N,M>(Pixel<M>::MaxSample - y));
}


template <int N, int M>
void
convCMYKtoRGB_JPEG(	Byte* dst,
							typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k)
{
	static int32_t const MaxSample = Pixel<M>::MaxSample;

	int32_t km = MaxSample - k;

	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>((km*int32_t(MaxSample - c))/MaxSample));
	Copy<M,Pixel<M>::G>::set(dst, resample<N,M>((km*int32_t(MaxSample - m))/MaxSample));
	Copy<M,Pixel<M>::B>::set(dst, resample<N,M>((km*int32_t(MaxSample - y))/MaxSample));
}


template <int N, int M>
void
convCMYKtoRGB_Adobe(	Byte* dst,
							typename JPEG<N>::Sample c,
							typename JPEG<N>::Sample m,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample k)
{
	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>((int32_t(k)*int32_t(c))/Pixel<M>::MaxSample));
	Copy<M,Pixel<M>::G>::set(dst, resample<N,M>((int32_t(m)*int32_t(c))/Pixel<M>::MaxSample));
	Copy<M,Pixel<M>::B>::set(dst, resample<N,M>((int32_t(y)*int32_t(c))/Pixel<M>::MaxSample));
}


template <int N, int M>
void
convYCCtoRGB(	Byte* dst,
					typename JPEG<N>::Sample y,
					typename JPEG<N>::Sample u,
					typename JPEG<N>::Sample v)
{
	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::vToR(v)))));
	Copy<M,Pixel<M>::G>::set(dst,
						resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))));
	Copy<M,Pixel<M>::B>::set(dst, resample<N,M>(clamp<N>(y + descale(Mapper<YCC,N>::uToB(u)))));
}


template <int N, int M>
void
convYCCKtoRGB_Adobe(	Byte* dst,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k)
{
	static const int32_t MaxSample = (int32_t(1) << N) - 1;

	convCMYKtoRGB_Adobe<N,M>(
			dst,
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::vToR(v)))),
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::uToB(u)))),
			k);
}


template <int N, int M>
void
convYCCKtoRGB_JPEG(	Byte* dst,
							typename JPEG<N>::Sample y,
							typename JPEG<N>::Sample u,
							typename JPEG<N>::Sample v,
							typename JPEG<N>::Sample k)
{
	static const int32_t MaxSample = (int32_t(1) << N) - 1;

	convCMYKtoRGB_JPEG<N,M>(
			dst,
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::vToR(v)))),
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::utoG(u) + Mapper<YCC,N>::vToG(v)))),
			clamp<N>(MaxSample - (y + descale(Mapper<YCC,N>::uToB(u)))),
			k);
}


template <int N, int M>
void
convPhotoYCCtoRGB(Byte* dst,
						typename JPEG<N>::Sample y,
						typename JPEG<N>::Sample u,
						typename JPEG<N>::Sample v)
{
	int32_t L = Mapper<PhotoYCC,N>::yToL(y);

	Copy<M,Pixel<M>::R>::set(dst, resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::vToR(v)))));
	Copy<M,Pixel<M>::G>::set(
		dst,
		resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToG(u) + Mapper<PhotoYCC,N>::vToG(u)))));
	Copy<M,Pixel<M>::B>::set(dst, resample<N,M>(clamp<N>(descale(L + Mapper<PhotoYCC,N>::uToB(u)))));
}

#endif

template <int Colorspace, int N, int M> struct Conv;

template <int N, int M>
struct Conv<RGB,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c)
	{
		return convRGBtoRGB<N,M>(a, b, c);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c)
	{
		convRGBtoRGB<N,M>(dst, a, b, c);
	}
#endif
};

template <int N, int M>
struct Conv<RGBA,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convRGBAtoRGBA<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte*, JPEGSample, JPEGSample, JPEGSample, JPEGSample)
	{
		// not needed
	}
#endif
};

template <int N, int M>
struct Conv<YCC,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c)
	{
		return convYCCtoRGB<N,M>(a, b, c);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c)
	{
		convYCCtoRGB<N,M>(dst, a, b, c);
	}
#endif
};

template <int N, int M>
struct Conv<YCCA,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convYCCAtoRGBA<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte*, JPEGSample, JPEGSample, JPEGSample, JPEGSample)
	{
		// not needed
	}
#endif
};

template <int N, int M>
struct Conv<YCCK_Adobe,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convYCCKtoRGB_Adobe<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		convYCCKtoRGB_Adobe<N,M>(dst, a, b, c, d);
	}
#endif
};

template <int N, int M>
struct Conv<YCCK_JPEG,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convYCCKtoRGB_JPEG<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		convYCCKtoRGB_JPEG<N,M>(dst, a, b, c, d);
	}
#endif
};

template <int N, int M>
struct Conv<PhotoYCC,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c)
	{
		return convPhotoYCCtoRGB<N,M>(a, b, c);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c)
	{
		convPhotoYCCtoRGB<N,M>(dst, a, b, c);
	}
#endif
};

template <int N, int M>
struct Conv<PhotoYCCA,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convPhotoYCCAtoRGBA<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte*, JPEGSample, JPEGSample, JPEGSample, JPEGSample)
	{
		// not needed
	}
#endif
};

template <int N, int M>
struct Conv<CMY,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c)
	{
		return convCMYtoRGB<N,M>(a, b, c);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c)
	{
		convCMYtoRGB<N,M>(dst, a, b, c);
	}
#endif
};

template <int N, int M>
struct Conv<CMYK_Adobe,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convCMYKtoRGB_Adobe<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		convCMYKtoRGB_Adobe<N,M>(dst, a, b, c, d);
	}
#endif
};

template <int N, int M>
struct Conv<CMYK_JPEG,N,M>
{
	inline static typename Pixel<M>::Type
	map(JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		return convCMYKtoRGB_JPEG<N,M>(a, b, c, d);
	}
#ifndef HAS_UNALIGNED_WORD_ACCESS
	inline static void
	map(Byte* dst, JPEGSample a, JPEGSample b, JPEGSample c, JPEGSample d)
	{
		convCMYKtoRGB_JPEG<N,M>(dst, a, b, c, d);
	}
#endif
};


template <int Colorspace, int N>
void
convertRow(typename JPEG<N,Colorspace>::Sample const* src, Scanline& dst)
{
	assert(dst.bytesPerPixel() == (N == 8 ? 1 : 2));
	assert(dst.channels() == 1);
	assert(src);

	typedef typename Sample<N>::Type Sample;

	enum { M = (N == 8 ? 8 : 16) };

	JPEGSample const*	e = src + dst.length();
	Sample*				p = reinterpret_cast<Sample*>(dst.data());

	for ( ; src < e; ++src, ++p)
		*p = resample<N,M>(*src);
}


template <int Colorspace, int N>
inline
void
__attribute__((always_inline))
convertRow(	typename JPEG<N,Colorspace>::Sample const* src0,
				typename JPEG<N,Colorspace>::Sample const* src1,
				Scanline& dst)
{
	assert(dst.bytesPerPixel() == (N == 8 ? 2 : 4));
	assert(dst.channels() == 2);
	assert(src0);
	assert(src1);

	enum { M = (N == 8 ? 8 : 16) };

	typedef typename Sample<N>::Type Sample;

	JPEGSample const*	e = src0 + dst.length();
	Sample*				p = reinterpret_cast<Sample*>(dst.data());

	for ( ; src0 < e; ++src0, ++src1, ++p)
		*p = resample<N,M>(*src0) | (resample<N,M>(*src1) << M);
}


template <int Colorspace, int N>
inline
void
__attribute__((always_inline))
convertRow(	typename JPEG<N,Colorspace>::Sample const* src0,
				typename JPEG<N,Colorspace>::Sample const* src1,
				typename JPEG<N,Colorspace>::Sample const* src2,
				Scanline& dst)
{
	enum { M = (N == 8 ? 8 : 16) };

	typedef typename JPEG<N,Colorspace>::Sample Sample;

	assert(dst.channels() == 3);
	assert(src0 && src1 && src2);

	if (dst.bytesPerPixel() == (N == 8 ? 4 : 8))
	{
		enum { BytesPerPixel = (N == 8 ? 4 : 8) };

		typedef typename Int<M>::Type IntType;

		IntType* q = reinterpret_cast<IntType*>(dst.data());	// 32/64 bit alignment is granted

		for (Sample const* e = src0 + dst.length(); src0 < e; ++src0, ++src1, ++src2, q++)
			*q = Conv<Colorspace,N,M>::map(*src0, *src1, *src2);
	}
	else
	{
		enum { BytesPerPixel = (N == 8 ? 3 : 6) };

		assert(dst.bytesPerPixel() == BytesPerPixel);

		typedef typename Pixel<M>::Type Pixel;
		typedef typename JPEG<N,Colorspace>::Sample Sample;

		Byte* q = dst.data();

		for (Sample const* e = src0 + dst.length(); src0 < e; ++src0, ++src1, ++src2, q += BytesPerPixel)
		{
#ifdef HAS_UNALIGNED_WORD_ACCESS
			// additional data overhead is granted
			*reinterpret_cast<Pixel*>(q) = Conv<Colorspace,N,M>::map(*src0, *src1, *src2);
#else
			Conv<Colorspace,N,M>::map(q, *src0, *src1, *src2);
#endif
		}
	}
}


template <int Colorspace, int N>
inline
void
__attribute__((always_inline))
convertRow(	typename JPEG<N,Colorspace>::Sample const* src0,
				typename JPEG<N,Colorspace>::Sample const* src1,
				typename JPEG<N,Colorspace>::Sample const* src2,
				typename JPEG<N,Colorspace>::Sample const* src3,
				Scanline& dst)
{
	enum { M = (N == 8 ? 8 : 16) };

	typedef typename Pixel<M>::Type Pixel;
	typedef typename JPEG<N,Colorspace>::Sample Sample;

	assert(src0 && src1 && src2 && src3);

	if (dst.channels() == 4 || dst.bytesPerPixel() == (N == 8 ? 4 : 8))
	{
		enum { BytesPerPixel = (N == 8 ? 4 : 8) };

		typedef typename Int<M>::Type IntType;

		IntType* q = reinterpret_cast<IntType*>(dst.data());	// 32/64 bit alignment is granted

		for (Sample const* e = src0 + dst.length(); src0 < e; ++src0, ++src1, ++src2, ++src3, q++)
			*q = Conv<Colorspace,N,M>::map(*src0, *src1, *src2, *src3);
	}
	else
	{
		enum { BytesPerPixel = (N == 8 ? 3 : 6) };

		assert(dst.bytesPerPixel() == BytesPerPixel);

		Byte*				q = dst.data();
		Sample const*	e = src0 + dst.length();

		for ( ; src0 < e; ++src0, ++src1, ++src2, ++src3, q += BytesPerPixel)
		{
#ifdef HAS_UNALIGNED_WORD_ACCESS
			// additional data overhead is granted
			*reinterpret_cast<Pixel*>(q) = Conv<Colorspace,N,M>::map(*src0, *src1, *src2, *src3);
#else
			Conv<Colorspace,N,M>::map(q, *src0, *src1, *src2, *src3);
#endif
		}
	}
}


template <int N>
struct Converter<Grayscale,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const*,
					JPEGSample const*,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 1);
		convertRow<Grayscale,N>(src0, dst);
	}
};


template <int N>
struct Converter<GrayAlpha,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const*,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 2);
		convertRow<GrayAlpha,N>(src0, src1, dst);
	}
};


template <int N>
struct Converter<RGB,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<RGB,N>(src0, src1, src2, dst);
	}
};


template <int N>
struct Converter<RGBA,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 4);
		convertRow<RGBA,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<YCC,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<YCC,N>(src0, src1, src2, dst);
	}
};


template <int N>
struct Converter<YCCA,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 4);
		convertRow<YCCA,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<PhotoYCC,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<PhotoYCC,N>(src0, src1, src2, dst);
	}
};


template <int N>
struct Converter<PhotoYCCA,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 4);
		convertRow<PhotoYCCA,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<CMY,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const*,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<CMY,N>(src0, src1, src2, dst);
	}
};


template <int N>
struct Converter<CMYK_Adobe,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<CMYK_Adobe,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<CMYK_JPEG,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<CMYK_JPEG,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<YCCK_Adobe,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<YCCK_Adobe,N>(src0, src1, src2, src3, dst);
	}
};


template <int N>
struct Converter<YCCK_JPEG,N>
{
	static void
	processRow(	JPEGSample const* src0,
					JPEGSample const* src1,
					JPEGSample const* src2,
					JPEGSample const* src3,
					Scanline& dst)
	{
		assert(dst.channels() == 3);
		convertRow<YCCK_JPEG,N>(src0, src1, src2, src3, dst);
	}
};


typedef JPEGSample	S;
typedef S const*		Line;

template Pixel<8>::Type convRGBtoRGB			<8,8>(S, S, S);
template Pixel<8>::Type convRGBAtoRGBA			<8,8>(S, S, S, S);
template Pixel<8>::Type convYCCtoRGB			<8,8>(S, S, S);
template Pixel<8>::Type convYCCAtoRGBA			<8,8>(S, S, S, S);
template Pixel<8>::Type convPhotoYCCtoRGB		<8,8>(S, S, S);
template Pixel<8>::Type convPhotoYCCAtoRGBA	<8,8>(S, S, S, S);
template Pixel<8>::Type convYCCKtoRGB_Adobe	<8,8>(S, S, S, S);
template Pixel<8>::Type convYCCKtoRGB_JPEG	<8,8>(S, S, S, S);
template Pixel<8>::Type convCMYtoRGB			<8,8>(S, S, S);
template Pixel<8>::Type convCMYKtoRGB_JPEG	<8,8>(S, S, S, S);
template Pixel<8>::Type convCMYKtoRGB_Adobe	<8,8>(S, S, S, S);

template void convertRow<Grayscale, 8>(Line, Scanline&);
template void convertRow<GrayAlpha, 8>(Line, Line, Scanline&);
template void convertRow<RGB,			8>(Line, Line, Line, Scanline&);
template void convertRow<YCC,			8>(Line, Line, Line, Scanline&);
template void convertRow<PhotoYCC,	8>(Line, Line, Line, Scanline&);
template void convertRow<CMY,			8>(Line, Line, Line, Scanline&);
template void convertRow<RGBA,		8>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCA,		8>(Line, Line, Line, Line, Scanline&);
template void convertRow<PhotoYCCA,	8>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCK_Adobe,8>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCK_JPEG,	8>(Line, Line, Line, Line, Scanline&);
template void convertRow<CMYK_Adobe,8>(Line, Line, Line, Line, Scanline&);
template void convertRow<CMYK_JPEG,	8>(Line, Line, Line, Line, Scanline&);

template class Converter<Grayscale, 8>;
template class Converter<GrayAlpha, 8>;
template class Converter<RGB,       8>;
template class Converter<RGBA,      8>;
template class Converter<YCC,       8>;
template class Converter<YCCA,      8>;
template class Converter<YCCK_Adobe,8>;
template class Converter<YCCK_JPEG, 8>;
template class Converter<PhotoYCC,  8>;
template class Converter<PhotoYCCA, 8>;
template class Converter<CMY,       8>;
template class Converter<CMYK_Adobe,8>;
template class Converter<CMYK_JPEG, 8>;

#ifndef HAS_UNALIGNED_WORD_ACCESS

template void convRGBtoRGB				<8,8>(Byte*, S, S, S);
template void convYCCtoRGB				<8,8>(Byte*, S, S, S);
template void convPhotoYCCtoRGB		<8,8>(Byte*, S, S, S);
template void convYCCKtoRGB_Adobe	<8,8>(Byte*, S, S, S, S);
template void convYCCKtoRGB_JPEG		<8,8>(Byte*, S, S, S, S);
template void convCMYtoRGB				<8,8>(Byte*, S, S, S);
template void convCMYKtoRGB_JPEG		<8,8>(Byte*, S, S, S, S);
template void convCMYKtoRGB_Adobe	<8,8>(Byte*, S, S, S, S);

#endif

#ifdef JPEG_SUPPORT_12_BIT

template Pixel<16>::Type convRGBtoRGB			<12,16>(S, S, S);
template Pixel<16>::Type convRGBAtoRGBA		<12,16>(S, S, S, S);
template Pixel<16>::Type convYCCtoRGB			<12,16>(S, S, S);
template Pixel<16>::Type convYCCAtoRGBA		<12,16>(S, S, S, S);
template Pixel<16>::Type convPhotoYCCtoRGB	<12,16>(S, S, S);
template Pixel<16>::Type convPhotoYCCAtoRGBA	<12,16>(S, S, S, S);
template Pixel<16>::Type convYCCKtoRGB_Adobe	<12,16>(S, S, S, S);
template Pixel<16>::Type convYCCKtoRGB_JPEG	<12,16>(S, S, S, S);
template Pixel<16>::Type convCMYtoRGB			<12,16>(S, S, S);
template Pixel<16>::Type convCMYKtoRGB_JPEG	<12,16>(S, S, S, S);
template Pixel<16>::Type convCMYKtoRGB_Adobe	<12,16>(S, S, S, S);

template void convertRow<Grayscale,	12>(Line, Scanline&);
template void convertRow<GrayAlpha,	12>(Line, Line, Scanline&);
template void convertRow<RGB,			12>(Line, Line, Line, Scanline&);
template void convertRow<YCC,			12>(Line, Line, Line, Scanline&);
template void convertRow<PhotoYCC,	12>(Line, Line, Line, Scanline&);
template void convertRow<CMY,			12>(Line, Line, Line, Scanline&);
template void convertRow<RGBA,		12>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCA,		12>(Line, Line, Line, Line, Scanline&);
template void convertRow<PhotoYCCA,	12>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCK_Adobe,12>(Line, Line, Line, Line, Scanline&);
template void convertRow<YCCK_JPEG,	12>(Line, Line, Line, Line, Scanline&);
template void convertRow<CMYK_Adobe,12>(Line, Line, Line, Line, Scanline&);
template void convertRow<CMYK_JPEG,	12>(Line, Line, Line, Line, Scanline&);

template class Converter<Grayscale, 12>;
template class Converter<GrayAlpha, 12>;
template class Converter<RGB,       12>;
template class Converter<RGBA,      12>;
template class Converter<YCC,       12>;
template class Converter<YCCA,      12>;
template class Converter<YCCK_Adobe,12>;
template class Converter<YCCK_JPEG, 12>;
template class Converter<PhotoYCC,  12>;
template class Converter<PhotoYCCA, 12>;
template class Converter<CMY,       12>;
template class Converter<CMYK_Adobe,12>;
template class Converter<CMYK_JPEG, 12>;

# ifndef HAS_UNALIGNED_WORD_ACCESS

template void convRGBtoRGB				<12,16>(Byte*, S, S, S);
template void convYCCtoRGB				<12,16>(Byte*, S, S, S);
template void convPhotoYCCtoRGB		<12,16>(Byte*, S, S, S);
template void convYCCKtoRGB_Adobe	<12,16>(Byte*, S, S, S, S);
template void convYCCKtoRGB_JPEG		<12,16>(Byte*, S, S, S, S);
template void convCMYtoRGB				<12,16>(Byte*, S, S, S);
template void convCMYKtoRGB_JPEG		<12,16>(Byte*, S, S, S, S);
template void convCMYKtoRGB_Adobe	<12,16>(Byte*, S, S, S, S);

# endif

#endif // JPEG_SUPPORT_12_BIT

} // namespace JPEG

// vi:set ts=3 sw=3:
