// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2013 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _util_rkiss_included
#define _util_rkiss_included

#include "m_types.h"

/// RKISS is our pseudo random number generator (PRNG) used to compute hash keys.
/// George Marsaglia invented the RNG-Kiss-family in the early 90's. This is a
/// specific version that Heinz van Saanen derived from some public domain code
/// by Bob Jenkins. Following the feature list, as tested by Heinz.
///
/// - Quite platform independent
/// - Passes ALL dieharder tests! Here *nix sys-rand() e.g. fails miserably:-)
/// - ~12 times faster than my *nix sys-rand()
/// - ~4 times faster than SSE2-version of Mersenne twister
/// - Average cycle length: ~2^126
/// - 64 bit seed
/// - Return doubles with a full 53 bit mantissa
/// - Thread safe

namespace util {

class RKiss
{
public:

	enum { Seed = 0xf1ea5eed };

	RKiss();
	explicit RKiss(uint64_t seed);

	uint64_t rand64();
	uint64_t rand64(uint64_t n);

	uint32_t rand32();
	uint32_t rand32(uint32_t n);

private:

	void initialize(uint64_t seed);

	uint64_t m_a;
	uint64_t m_b;
	uint64_t m_c;
	uint64_t m_d;
};

} // namespace util

#endif // _util_rkiss_included

// vi:set ts=3 sw=3:
