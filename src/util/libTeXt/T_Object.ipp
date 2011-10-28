// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifdef USE_MEM_BLOCKS

#include "T_Memory.h"

namespace TeXt {

inline Object::~Object() {}

inline void* Object::operator new(size_t n)			{ return Memory::alloc(n); }
inline void Object::operator delete(void* obj)		{ Memory::release(obj); }


inline
void
Object::prepend(Object* p)
{
	p->mem_next = mem_next;
	p->mem_prev = this;

	mem_next->mem_prev = p;
	mem_next = p;
}


inline
void
Object::unlink()
{
	mem_next->mem_prev = mem_prev;
	mem_prev->mem_next = mem_next;
}

} // namespace TeXt

#endif

// vi:set ts=3 sw=3:
