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

#include "u_rkiss.h"

#include "sys_time.h"

#include "m_utility.h"
#include "m_bit_functions.h"

using namespace util;


inline static uint64_t
rotate(uint64_t x, uint64_t k)
{
	return (x << k) | (x >> (64 - k));
}


RKiss::RKiss(uint64_t seed) { initialize(seed); }
RKiss::RKiss() { initialize(::sys::time::timestamp()); }


void
RKiss::initialize(uint64_t seed)
{
	m_a = seed;
	m_b = m_c = m_d = 0xd4e12c77;

	for (unsigned i = 0; i < 73; i++)
		rand64();
}


uint64_t
RKiss::rand64()
{
	uint64_t const e = m_a - ::rotate(m_b,  7);

	m_a = m_b ^ ::rotate(m_c, 13);
	m_b = m_c + ::rotate(m_d, 37);
	m_c = m_d + e;

	return m_d = e + m_a;
}


uint64_t
RKiss::rand64(uint64_t n)
{
	if (mstl::is_pow_2(n))
		return rand64() & (n - 1);

	uint64_t mask = (uint64_t(1) << mstl::bf::msb_index(n - 1)) - 1;
	uint64_t result;

	// see: Knuth Vol 2, Ch 3.4.1, p 138, Exercises 1-3.
	do
		result = rand64() & mask;
	while (result >= n);

	return result;
}


uint32_t
RKiss::rand32(uint32_t n)
{
	if (mstl::is_pow_2(n))
		return rand64() & (n - 1);

	uint32_t mask = (uint32_t(1) << mstl::bf::msb_index(n - 1)) - 1;
	uint32_t result;

	// see: Knuth Vol 2, Ch 3.4.1, p 138, Exercises 1-3.
	do
		result = uint32_t(rand64()) & mask;
	while (result >= n);

	return result;
}

// vi:set ts=3 sw=3:
