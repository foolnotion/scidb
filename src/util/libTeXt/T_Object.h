// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C)2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _TeXt_Object_included
#define _TeXt_Object_included

#include "T_Config.h"

#include "m_ref_counter.h"
#include "m_assert.h"

namespace TeXt {

#ifdef USE_MEM_BLOCKS

class Memory;
class MemoryBlock;

class Object : public mstl::ref_counter
{
public:

	virtual ~Object();

	static void* operator new(size_t n);
	static void operator delete(void* obj);

private:

	friend class Memory;
	friend class MemoryBlock;

	// forbid these operators
	static void* operator new[](size_t n);
	static void operator delete[](void* obj);

	void prepend(Object* p);
	void unlink();

	Object* mem_next;
	Object* mem_prev;
};

#else

typedef mstl::ref_counter Object;

#endif

} // namespace TeXt

#ifdef USE_MEM_BLOCKS
# include "T_Object.ipp"
#endif

#endif // _TeXt_Object_included

// vi:set ts=3 sw=3:
