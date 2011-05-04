// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2010-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _u_crc_included
#define _u_crc_included

#include "u_base.h"

namespace util {
namespace crc {

uint32_t compute(uint32_t crc, char const* bytes, unsigned len);
uint32_t compute(uint32_t crc, unsigned char* const bytes, unsigned len);
uint32_t combine(uint32_t crc1, uint32_t crc2, unsigned len2);

} // namespace crc
} // namespace util

#include "u_crc.ipp"

#endif // _u_crc_included

// vi:set ts=3 sw=3:
