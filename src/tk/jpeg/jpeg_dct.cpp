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

#include "jpeg_dct.h"

#include <string.h>
#include <assert.h>

#ifdef __SSE2__

extern "C" {
#include <emmintrin.h>

// need some wrappers because compiler will complain of C style casts in macro _mm_shuffle_ps
inline static __m128 __attribute__((always_inline))
__mm_shuffle_ps_44(__m128 u, __m128 v) { return _mm_shuffle_ps(u, v, 0x44); }
inline static __m128 __attribute__((always_inline))
__mm_shuffle_ps_88(__m128 u, __m128 v) { return _mm_shuffle_ps(u, v, 0x88); }
inline static __m128 __attribute__((always_inline))
__mm_shuffle_ps_DD(__m128 u, __m128 v) { return _mm_shuffle_ps(u, v, 0xDD); }
inline static __m128 __attribute__((always_inline))
__mm_shuffle_ps_EE(__m128 u, __m128 v) { return _mm_shuffle_ps(u, v, 0xEE); }

#ifdef __clang__
// missing builtin function:
static __v4sf
__builtin_ia32_movlhps(__v4sf __r, __v4sf __s)
{
	(reinterpret_cast<__m64*>(&__r))[1] = (reinterpret_cast<__m64*>(&__s))[0];
	return __r;
}
#endif

} // extern "C"

#include <stdint.h>

namespace simd {

inline void __attribute__((always_inline)) clear() { _mm_empty(); }

namespace flt { typedef __m128 vec; }

namespace i16 {

typedef __m64 vec;

inline vec __attribute__((always_inline)) zero()				{ return _mm_setzero_si64(); }
inline vec __attribute__((always_inline)) set(int16_t x)		{ return _mm_set1_pi16(x); }
inline vec __attribute__((always_inline)) set(flt::vec v)	{ return _mm_cvtps_pi16(v); }

inline vec __attribute__((always_inline)) add(vec x, vec y)	{ return _mm_add_pi16(x, y); }
inline vec __attribute__((always_inline)) rsh(vec x, int n)	{ return _mm_srai_pi16(x, n); }
inline vec __attribute__((always_inline)) min(vec x, vec y)	{ return _mm_min_pi16(x, y); }
inline vec __attribute__((always_inline)) max(vec x, vec y)	{ return _mm_max_pi16(x, y); }

inline vec __attribute__((always_inline))
load(int16_t const* p) { return *reinterpret_cast<__m64 const*>(p); }

void
transpose8x8(vec const* v, int16_t** r)
{
	__m128i t0 = *(reinterpret_cast<__m128i const*>(v     ));	// a0 b0 c0 d0 e0 f0 g0 h0
	__m128i t1 = *(reinterpret_cast<__m128i const*>(v +  2));	// a1 b1 c1 d1 e1 f1 g1 h1
	__m128i t2 = *(reinterpret_cast<__m128i const*>(v +  4));	// a2 b2 c2 d2 e2 f2 g2 h2
	__m128i t3 = *(reinterpret_cast<__m128i const*>(v +  6));	// a3 b3 c3 d3 e3 f3 g3 h3
	__m128i t4 = *(reinterpret_cast<__m128i const*>(v +  8));	// a4 b4 c4 d4 e4 f4 g4 h4
	__m128i t5 = *(reinterpret_cast<__m128i const*>(v + 10));	// a5 b5 c5 d5 e5 f5 g5 h5
	__m128i t6 = *(reinterpret_cast<__m128i const*>(v + 12));	// a6 b6 c6 d6 e6 f6 g6 h6
	__m128i t7 = *(reinterpret_cast<__m128i const*>(v + 14));	// a7 b7 c7 d7 e7 f7 g7 h7

	__m128i tA0B0C0D0 = _mm_unpacklo_epi16(t0, t1);			// a0 a1 | b0 b1 | c0 c1 | d0 d1
	__m128i tA1B1C1D1 = _mm_unpacklo_epi16(t2, t3);			// a2 a3 | b2 b3 | c2 c3 | d2 d3
																			// ------+-------+-------+------
	__m128i tA2B2C2D2 = _mm_unpacklo_epi16(t4, t5);			// a4 a5 | b4 b5 | c4 c5 | d4 d5
	__m128i tA3B3C3D3 = _mm_unpacklo_epi16(t6, t7);			// a6 a7 | b6 b7 | c6 c7 | d6 d7
																			// ------+-------+-------+------
	__m128i tE0F0G0H0 = _mm_unpackhi_epi16(t0, t1);			// e0 e1 | f0 f1 | g0 g1 | h0 h1
	__m128i tE1F1G1H1 = _mm_unpackhi_epi16(t2, t3);			// e2 e3 | f2 f3 | g2 g3 | h2 h3
																			// ------+-------+-------+------
	__m128i tE2F2G2H2 = _mm_unpackhi_epi16(t4, t5);			// e4 e5 | f4 f5 | g4 g5 | h4 h5
	__m128i tE3F3G3H3 = _mm_unpackhi_epi16(t6, t7);			// e6 e7 | f6 f7 | g6 g7 | h6 h7

	__m128i tA0B0 = _mm_unpacklo_epi32(tA0B0C0D0, tA1B1C1D1);	// a0 a1 a2 a3 | b0 b1 b2 b3
	__m128i tA1B1 = _mm_unpacklo_epi32(tA2B2C2D2, tA3B3C3D3);	// a4 a5 a6 a7 | b4 b5 b6 b7
																					// ------------+------------
	__m128i tC0D0 = _mm_unpackhi_epi32(tA0B0C0D0, tA1B1C1D1);	// c0 c1 c2 c3 | d0 d1 d2 d3
	__m128i tC1D1 = _mm_unpackhi_epi32(tA2B2C2D2, tA3B3C3D3);	// c4 c5 c6 c7 | d4 d5 d6 d7
																					// ------------+------------
	__m128i tE0F0 = _mm_unpacklo_epi32(tE0F0G0H0, tE1F1G1H1);	// e0 e1 e2 e3 | f0 f1 f2 f3
	__m128i tE1F1 = _mm_unpacklo_epi32(tE2F2G2H2, tE3F3G3H3);	// e4 e5 e6 e7 | f4 f5 f6 f7
																					// ------------+------------
	__m128i tG0H0 = _mm_unpackhi_epi32(tE0F0G0H0, tE1F1G1H1);	// g0 g1 g2 g3 | h0 h1 h2 h3
	__m128i tG1H1 = _mm_unpackhi_epi32(tE2F2G2H2, tE3F3G3H3);	// g4 g5 g6 g7 | h4 h5 h6 h7

	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[0]), _mm_unpacklo_epi64(tA0B0, tA1B1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[1]), _mm_unpackhi_epi64(tA0B0, tA1B1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[2]), _mm_unpacklo_epi64(tC0D0, tC1D1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[3]), _mm_unpackhi_epi64(tC0D0, tC1D1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[4]), _mm_unpacklo_epi64(tE0F0, tE1F1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[5]), _mm_unpackhi_epi64(tE0F0, tE1F1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[6]), _mm_unpacklo_epi64(tG0H0, tG1H1));
	_mm_storeu_si128(reinterpret_cast<__m128i*>(r[7]), _mm_unpackhi_epi64(tG0H0, tG1H1));
}

} // namespace i16

// The version in /usr/lib/gcc/i486-linux-gnu/4.4.3/include/xmmintrin.h is not working!
static __inline __m128
_mm_cvtpi16_ps (__m64 __A)
{
	__v4hi __sign;
	__v2si __hisi, __losi;
	__v4sf __r;

	__sign = __builtin_ia32_pcmpgtw ((__v4hi)0LL, (__v4hi)__A);

	__hisi = (__v2si) __builtin_ia32_punpckhwd ((__v4hi)__A, __sign);
	__losi = (__v2si) __builtin_ia32_punpcklwd ((__v4hi)__A, __sign);

	__r = (__v4sf) _mm_setzero_ps ();
	__r = __builtin_ia32_cvtpi2ps (__r, __hisi);
	__r = __builtin_ia32_movlhps (__r, __r);
	__r = __builtin_ia32_cvtpi2ps (__r, __losi);

	return (__m128) __r;
}


namespace flt {

inline vec __attribute__((always_inline)) set(float x)			{ return _mm_set1_ps(x); }
inline vec __attribute__((always_inline)) set(i16::vec v)		{ return _mm_cvtpi16_ps(v); }
inline vec __attribute__((always_inline)) load(float const* p)	{ return _mm_loadu_ps(p); }

inline vec __attribute__((always_inline)) add(vec x, vec y)		{ return _mm_add_ps(x, y); }
inline vec __attribute__((always_inline)) sub(vec x, vec y)		{ return _mm_sub_ps(x, y); }
inline vec __attribute__((always_inline)) mul(vec x, vec y)		{ return _mm_mul_ps(x, y); }

void
transpose(vec& a, vec& b, vec& c, vec& d)
{
	__m128 t0 = __mm_shuffle_ps_44(a, b);	// 01000100 -> a[0],a[1],b[0],b[1]
	__m128 t2 = __mm_shuffle_ps_EE(a, b);	// 11101110 -> a[2],a[3],b[2],b[3]
	__m128 t1 = __mm_shuffle_ps_44(c, d);	// 01000100 -> c[0],c[1],d[0],d[1]
	__m128 t3 = __mm_shuffle_ps_EE(c, d);	// 11101110 -> c[2],c[3],d[2],d[3]

	a = __mm_shuffle_ps_88(t0, t1);		// 10001000 -> t0[0],t0[2],t1[0],t1[2]
	b = __mm_shuffle_ps_DD(t0, t1);		// 11011101 -> t0[1],t0[3],t1[1],t1[3]
	c = __mm_shuffle_ps_88(t2, t3);		// 10001000 -> t2[0],t2[2],t3[0],t3[2]
	d = __mm_shuffle_ps_DD(t2, t3);		// 11011101 -> t2[1],t2[3],t3[1],t3[3]
}

} // namespace flt
} // namespace simd


#ifdef __i386__

static void
cpuid(int op, uint32_t& eax, uint32_t& ebx, uint32_t& ecx, uint32_t& edx)
{
	// Execute CPUID with the feature request bit set
	__asm__ __volatile__
	(
		"push   %%ebx    \n\t"	// Save EBX
		"cpuid           \n\t"	// Call CPUID
		"movl   %%ebx,%1 \n\t"  // Store EBX into ebx
		"pop    %%ebx    \n\t"	// Restore EBX

		: "=a"(eax), "=r"(ebx), "=c"(ecx), "=d"(edx)
		: "a"(op)					// Set EAX (features request)
		: "cc"
	);
}

#endif


static bool
cpu_provides_sse2()
{
#if defined(__x86_64__)

	return true;

#elif !defined(__i386__)

	return false;

#else

	static bool first_time = true;

	static bool caps = false;

	if (!first_time)
		return caps;

	bool haveCPUID;

	// First check if the CPU supports the CPUID instruction
	__asm__ __volatile__
	(
		// Try to toggle the CPUID bit in the EFLAGS register
		"pushf                       \n\t"   // Push the EFLAGS register onto the stack
		"popl   %%ecx                \n\t"   // Pop the value into ECX
		"movl   %%ecx, %%edx         \n\t"   // Copy ECX to EDX
		"xorl   $0x00200000, %%ecx   \n\t"   // Toggle bit 21 (CPUID) in ECX
		"pushl  %%ecx                \n\t"   // Push the modified value onto the stack
		"popf                        \n\t"   // Pop it back into EFLAGS

		// Check if the CPUID bit was successfully toggled
		"pushf                       \n\t"   // Push EFLAGS back onto the stack
		"popl   %%ecx                \n\t"   // Pop the value into ECX
		"xorl   %%eax, %%eax         \n\t"   // Zero out the EAX register
		"cmpl   %%ecx, %%edx         \n\t"   // Compare ECX with EDX
		"je     .Lno_cpuid_support%= \n\t"   // Jump if they're identical
		"movl   $1, %%eax            \n\t"   // Set EAX to true
		".Lno_cpuid_support%=:       \n\t"

		: "=a"(haveCPUID)
		:
		: "%ecx", "%edx"
	);

	// If we don't have CPUID we won't have the other extensions either
	if (haveCPUID)
	{
		uint32_t eax;
		uint32_t ebx;
		uint32_t ecx;
		uint32_t edx;

		cpuid(0x00000001, eax, ebx, ecx, edx);

		if (edx & (1 << 23))
		{
			if (edx & (1 << 26)) caps = true;	// SSE2
			if (ecx & (1 <<  0)) caps = true;	// SSE3
			if (ecx & (1 <<  9)) caps = true;	// SSSE3
		}
	}

	first_time = false;

	return caps;

#endif
}


namespace i16 = simd::i16;
namespace flt = simd::flt;

#endif	// __SSE2__

// This implementation is based on Arai, Agui, and Nakajima's algorithm for
// scaled DCT.  Their original paper (Trans. IEICE E-71(11):1095) is in
// Japanese, but the algorithm is described in the textbook "JPEG Still Image
// Data Compression Standard" by William B. Pennebaker and Joan L. Mitchell,
// published by Van Nostrand Reinhold, 1993, ISBN 0-442-01272-1.
//
// While an 8-point DCT cannot be done in less than 11 multiplies, it is
// possible to arrange the computation so that many of the multiplies are
// simple scalings of the final outputs.  These multiplies can then be
// folded into the multiplications or divisions by the JPEG quantization
// table entries.  The AA&N method leaves only 5 multiplies and 29 adds
// to be done in the DCT itself.


using namespace JPEG;

namespace {

static int const Shift = 3;

template <bool> class ConcreteDCT;

} // namespace


#ifdef __SSE2__

namespace {

// constants
static flt::vec Flt_1_414213562;
static flt::vec Flt_1_847759065;
static flt::vec Flt_1_082392200;
static flt::vec Fltn2_613125930;
static flt::vec Flt_0_500000000;

static i16::vec Align;
static i16::vec Zero;


#if 0
inline
i16::vec
__attribute__((always_inline))
load(int8_t const* p)
{
	int16_t v[4] = { p[0], p[1], p[2], p[3] };
	return i16::load(v);
}
#endif


inline
i16::vec
__attribute__((always_inline))
load(int16_t const* p)
{
	return i16::load(p);
}


inline
flt::vec
__attribute__((always_inline))
load(float const* p)
{
	return flt::load(p);
}


inline
i16::vec
__attribute__((always_inline))
descale(flt::vec v)
{
	return i16::rsh((i16::add(i16::set(v), Align)), Shift);
}


inline
i16::vec
__attribute__((always_inline))
clip(i16::vec x, i16::vec lower, i16::vec upper)
{
	return i16::min(i16::max(x, lower), upper);
}


template <>
class ConcreteDCT<true> : public DCT::Impl
{
public:

	// structors
	ConcreteDCT(int bitsInSample)
		:m_maxSample(i16::set((1 << bitsInSample) - 1))
		,m_center(i16::rsh(i16::add(m_maxSample, i16::set(1)), 1))
	{
		if (m_initialize)
		{
			::Flt_1_414213562 = flt::set( 1.414213562);
			::Flt_1_847759065 = flt::set( 1.847759065);
			::Flt_1_082392200 = flt::set( 1.082392200);
			::Fltn2_613125930 = flt::set(-2.613125930);
			::Flt_0_500000000 = flt::set( 0.500000000);

			::Align = i16::set(1 << (::Shift - 1));
			::Zero = i16::zero();

			m_initialize = false;
		}

		simd::clear();
	}

	// modifiers
	void setupQuantization(QuantTable const& quantValues)
	{
		setup(quantValues, m_quantTable);
		simd::clear();
	}

	void idct(JPEGSample** result, JPEGSample const* coefBlock)
	{
		flt::vec workspace[16];
		i16::vec coeffs[16];

		setup(coefBlock, coeffs);

		idctRow(coeffs, m_quantTable, workspace);
		idctRow(coeffs + 8, m_quantTable + 8, workspace + 4);

		idctCol(coeffs, workspace);
		idctCol(coeffs + 1, workspace + 8);

		i16::transpose8x8(coeffs, result);	// NOTE: requires SSE2 capability
		simd::clear();
	}

	// the instances must be 16 bit aligned
	static void* operator new(size_t n)
	{
		char* p = new char[n + 16];
		char* q;

		if ((long(p) & long(~15)) == long(p))
			q = p + 16;
		else
			q = reinterpret_cast<char*>((long(p) + 15) & ~15);

		q[-1] = int(q - p);	// offset to p

		return q;
	}

	static void operator delete(void* p)
	{
		long offset = static_cast<char*>(p)[-1];
		delete [] (static_cast<char*>(p) - (offset ? offset : 256));
	}

private:

	template <typename T, typename V>
	void setup(T const* src, V* dst)
	{
		dst[ 0] = ::load(src +  0); dst[ 8] = ::load(src +  4);
		dst[ 1] = ::load(src +  8); dst[ 9] = ::load(src + 12);
		dst[ 2] = ::load(src + 16); dst[10] = ::load(src + 20);
		dst[ 3] = ::load(src + 24); dst[11] = ::load(src + 28);
		dst[ 4] = ::load(src + 32); dst[12] = ::load(src + 36);
		dst[ 5] = ::load(src + 40); dst[13] = ::load(src + 44);
		dst[ 6] = ::load(src + 48); dst[14] = ::load(src + 52);
		dst[ 7] = ::load(src + 56); dst[15] = ::load(src + 60);
	}

	// computation
	static void idctRow(i16::vec const* c, flt::vec const* q, flt::vec* w)
	{
		// even part
		flt::vec a0 = flt::mul(q[0], flt::set(c[0]));
		flt::vec a1 = flt::mul(q[2], flt::set(c[2]));
		flt::vec a2 = flt::mul(q[4], flt::set(c[4]));
		flt::vec a3 = flt::mul(q[6], flt::set(c[6]));

		flt::vec b0 = flt::add(a0, a2);		// phase 3
		flt::vec b1 = flt::sub(a0, a2);

		flt::vec b3 = flt::add(a1, a3);		// phase 5-3
		flt::vec b2 = flt::sub(flt::mul(flt::sub(a1, a3), ::Flt_1_414213562), b3);

		a0 = flt::add(b0, b3);					// phase 2
		a1 = flt::add(b1, b2);
		a2 = flt::sub(b1, b2);
		a3 = flt::sub(b0, b3);

		// odd part
		flt::vec a4 = flt::mul(q[1], flt::set(c[1]));
		flt::vec a5 = flt::mul(q[3], flt::set(c[3]));
		flt::vec a6 = flt::mul(q[5], flt::set(c[5]));
		flt::vec a7 = flt::mul(q[7], flt::set(c[7]));

		flt::vec z10 = flt::sub(a6, a5);		// phase 6
		flt::vec z11 = flt::add(a4, a7);
		flt::vec z12 = flt::sub(a4, a7);
		flt::vec z13 = flt::add(a6, a5);

		a7 = flt::add(z11, z13);				// phase 5
		b1 = flt::mul(flt::sub(z11, z13), ::Flt_1_414213562);

		flt::vec z5 = flt::mul(flt::add(z10, z12), ::Flt_1_847759065);

		b0 = flt::sub(flt::mul(::Flt_1_082392200, z12), z5);
		b2 = flt::add(flt::mul(::Fltn2_613125930, z10), z5);

		a6 = flt::sub(b2, a7);					// phase 2
		a5 = flt::sub(b1, a6);
		a4 = flt::add(b0, a5);

		// transpose for column operation
		flt::transpose(w[ 0] = flt::add(a0, a7),
							w[ 1] = flt::add(a1, a6),
							w[ 2] = flt::add(a2, a5),
							w[ 3] = flt::sub(a3, a4));
		flt::transpose(w[ 8] = flt::add(a3, a4),
							w[ 9] = flt::sub(a2, a5),
							w[10] = flt::sub(a1, a6),
							w[11] = flt::sub(a0, a7));
	}

	void idctCol(i16::vec* c, flt::vec const* w)
	{
		// even part
		flt::vec b0 = flt::add(w[0], w[4]);
		flt::vec b1 = flt::sub(w[0], w[4]);

		flt::vec b3 = flt::add(w[2], w[6]);
		flt::vec b2 = flt::sub(flt::mul(flt::sub(w[2], w[6]), ::Flt_1_414213562), b3);

		flt::vec a0 = flt::add(b0, b3);
		flt::vec a1 = flt::add(b1, b2);
		flt::vec a2 = flt::sub(b1, b2);
		flt::vec a3 = flt::sub(b0, b3);

		// odd part
		flt::vec z10 = flt::sub(w[5], w[3]);
		flt::vec z11 = flt::add(w[1], w[7]);
		flt::vec z12 = flt::sub(w[1], w[7]);
		flt::vec z13 = flt::add(w[5], w[3]);

		flt::vec a7 = flt::add(z11, z13);

		b1 = flt::mul(flt::sub(z11, z13), ::Flt_1_414213562);

		flt::vec z5 = flt::mul(flt::add(z10, z12), ::Flt_1_847759065);

		b0 = flt::sub(flt::mul(::Flt_1_082392200, z12), z5);
		b2 = flt::add(flt::mul(::Fltn2_613125930, z10), z5);

		flt::vec a6 = flt::sub(b2, a7);
		flt::vec a5 = flt::sub(b1, a6);
		flt::vec a4 = flt::add(b0, a5);

		// scale down and clip
		c[ 0] = ::clip(i16::add(::descale(flt::add(a0, a7)), m_center), ::Zero, m_maxSample);
		c[ 2] = ::clip(i16::add(::descale(flt::add(a1, a6)), m_center), ::Zero, m_maxSample);
		c[ 4] = ::clip(i16::add(::descale(flt::add(a2, a5)), m_center), ::Zero, m_maxSample);
		c[ 6] = ::clip(i16::add(::descale(flt::sub(a3, a4)), m_center), ::Zero, m_maxSample);
		c[ 8] = ::clip(i16::add(::descale(flt::add(a3, a4)), m_center), ::Zero, m_maxSample);
		c[10] = ::clip(i16::add(::descale(flt::sub(a2, a5)), m_center), ::Zero, m_maxSample);
		c[12] = ::clip(i16::add(::descale(flt::sub(a1, a6)), m_center), ::Zero, m_maxSample);
		c[14] = ::clip(i16::add(::descale(flt::sub(a0, a7)), m_center), ::Zero, m_maxSample);
	}

	// attributes
	i16::vec m_maxSample;
	i16::vec m_center;
	flt::vec m_quantTable[16];

	static bool m_initialize;
};

bool ConcreteDCT<true>::m_initialize = true;

} // namespace

#endif // __SSE2__


namespace {

inline
static JPEGSample
asInt(float x)
{
	return (static_cast<JPEGSample>(x + 0.5) + (1 << (Shift - 1))) >> Shift;
}


inline
static JPEGSample
clip(JPEGSample val, JPEGSample min, JPEGSample max)
{
	return val < min ? min : (val < max ? val : max);
}


template <>
class ConcreteDCT<false> : public DCT::Impl
{
public:

	// structors
	ConcreteDCT(int bitsInSample __attribute__((unused)))
#ifdef JPEG_SUPPORT_12_BIT
		:m_maxSample((1 << bitsInSample) - 1)
#endif
	{
	}

	// modifiers
	void setupQuantization(QuantTable const& quantValues)
	{
		::memcpy(m_quantTable, quantValues, sizeof(QuantTable));
	}

	// computation
	void idct(JPEGSample** result, JPEGSample const* coefBlock)
	{
#ifdef JPEG_SUPPORT_12_BIT
		JPEGSample center = (m_maxSample + 1)/2;
#else
		enum { m_maxSample = 255, center = 128, };
#endif

		float workspace[64];

		JPEGSample const*	p = coefBlock;
		float const*		q = m_quantTable;
		float*				w = workspace;

		for (int i = 0; i < 8; ++i, ++p, ++q, ++w)
		{
			if (	p[ 8] == 0 && p[16] == 0 && p[24] == 0
				&& p[32] == 0 && p[40] == 0 && p[48] == 0 && p[56] == 0)
			{
				w[0] = w[8] = w[16] = w[24] = w[32] = w[40] = w[48] = w[56] = p[0]*q[0];
			}
			else
			{
				// even part
				float a0 = p[ 0]*q[ 0];
				float a1 = p[16]*q[16];
				float a2 = p[32]*q[32];
				float a3 = p[48]*q[48];

				float b0 = a0 + a2;	// phase 3
				float b1 = a0 - a2;

				float b3 = a1 + a3;	// phase 5-3
				float b2 = (a1 - a3)*1.414213562 - b3;

				a0 = b0 + b3;			// phase 2
				a1 = b1 + b2;
				a2 = b1 - b2;
				a3 = b0 - b3;

				// odd part
				float a4 = p[ 8]*q[ 8];
				float a5 = p[24]*q[24];
				float a6 = p[40]*q[40];
				float a7 = p[56]*q[56];

				float z10 = a6 - a5;	// phase 6
				float z11 = a4 + a7;
				float z12 = a4 - a7;
				float z13 = a6 + a5;

				a7 = z11 + z13;		// phase 5
				b1 = (z11 - z13)*1.414213562;

				float z5 = (z10 + z12)*1.847759065;

				b0 = 1.082392200*z12 - z5;
				b2 = -2.613125930*z10 + z5;

				a6 = b2 - a7;			// phase 2
				a5 = b1 - a6;
				a4 = b0 + a5;

				w[ 0] = a0 + a7;
				w[ 8] = a1 + a6;
				w[16] = a2 + a5;
				w[24] = a3 - a4;
				w[32] = a3 + a4;
				w[40] = a2 - a5;
				w[48] = a1 - a6;
				w[56] = a0 - a7;
			}
		}

		for (int i = 0; i < 8; ++i)
		{
			JPEGSample* p = result[i];

			w = workspace + (i << 3);

			// even part
			float b0 = w[0] + w[4];
			float b1 = w[0] - w[4];

			float b3 = w[2] + w[6];
			float b2 = (w[2] - w[6])*1.414213562 - b3;

			float a0 = b0 + b3;
			float a1 = b1 + b2;
			float a2 = b1 - b2;
			float a3 = b0 - b3;

			// odd part
			float z10 = w[5] - w[3];
			float z11 = w[1] + w[7];
			float z12 = w[1] - w[7];
			float z13 = w[5] + w[3];

			float a7 = z11 + z13;

			b1 = (z11 - z13)*1.414213562;

			float z5 = (z10 + z12)*1.847759065;

			b0 = 1.082392200*z12 - z5;
			b2 = -2.613125930*z10 + z5;

			float a6 = b2 - a7;
			float a5 = b1 - a6;
			float a4 = b0 + a5;

			// scale down and clip
			p[0] = ::clip(::asInt(a0 + a7) + center, 0, m_maxSample);
			p[1] = ::clip(::asInt(a1 + a6) + center, 0, m_maxSample);
			p[2] = ::clip(::asInt(a2 + a5) + center, 0, m_maxSample);
			p[3] = ::clip(::asInt(a3 - a4) + center, 0, m_maxSample);
			p[4] = ::clip(::asInt(a3 + a4) + center, 0, m_maxSample);
			p[5] = ::clip(::asInt(a2 - a5) + center, 0, m_maxSample);
			p[6] = ::clip(::asInt(a1 - a6) + center, 0, m_maxSample);
			p[7] = ::clip(::asInt(a0 - a7) + center, 0, m_maxSample);
		}
	}

private:

	// attributes
	QuantTable	m_quantTable;
#ifdef JPEG_SUPPORT_12_BIT
	JPEGSample	m_maxSample;
#endif
};

} // namespace


DCT::Impl::~Impl()
{
	// no action
}


DCT::DCT(int bitsInSample)
#ifdef __SSE2__
	:m_impl(cpu_provides_sse2()
				? static_cast<Impl*>(new ConcreteDCT<true>(bitsInSample))
				: static_cast<Impl*>(new ConcreteDCT<false>(bitsInSample)))
#else
	:m_impl(new ConcreteDCT<false>(bitsInSample))
#endif
	,m_quant0(0.0)
	,m_bitsInSample(bitsInSample)
{
}


DCT::~DCT()
{
	delete m_impl;
}


void
DCT::setupQuantization(QuantValues const& quantValues)
{
   static const float ScaleTbl[8] =
   {
		1.0, 1.387039845, 1.306562965, 1.175875602,
		1.0, 0.785694958, 0.541196100, 0.275899379
   };

	Impl::QuantTable table;

	for (int i = 0; i < Base::DCTSize; ++i)
	{
		assert(quantValues[i] != 0.0);
		table[i] = quantValues[i]*ScaleTbl[i >> 3]*ScaleTbl[i & 0x7];
	}

	m_quant0 = table[0];
	m_impl->setupQuantization(table);
}


JPEGSample
DCT::idct8(JPEGSample coef)
{
	return ::clip(::asInt(coef*m_quant0) + 128, 0, 255);
}


void
DCT::idct8(JPEGSample** result, JPEGSample const* coefBlock)
{
	m_impl->idct(result, coefBlock);
}


JPEGSample
DCT::idct12(JPEGSample coef)
{
	return ::clip(::asInt(coef*m_quant0) + 2048, 0, 4095);
}


void
DCT::idct12(JPEGSample** result, JPEGSample const* coefBlock)
{
	m_impl->idct(result, coefBlock);
}


void
DCT::inverseDCT(Mode mode, JPEGSample const* coefBlock, JPEGSample** result)
{
#ifdef JPEG_SUPPORT_12_BIT
	assert(m_bitsInSample == 8 || m_bitsInSample == 12);
#else
	enum { m_bitsInSample = 8 };
#endif

   if (mode == FirstCoeffOnly)
   {
      JPEGSample v = (m_bitsInSample == 8 ? idct8(coefBlock[0]) : idct12(coefBlock[0]));

      for (int i = 0; i < 8; ++i)
      {
         JPEGSample* p = result[i];
         p[0] = p[1] = p[2] = p[3] = p[4] = p[5] = p[6] = p[7] = v;
      }
   }
   else if (m_bitsInSample == 8)
   {
		idct8(result, coefBlock);
	}
	else
	{
		idct12(result, coefBlock);
   }
}

// vi:set ts=3 sw=3:
