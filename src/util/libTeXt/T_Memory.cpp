// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "T_Memory.h"

#ifdef USE_MEM_BLOCKS

#include "T_Object.h"
#include "T_Environment.h"
#include "T_Controller.h"

#include "T_ActiveToken.h"
#include "T_AsciiToken.h"
#include "T_ConditionalToken.h"
#include "T_ExpandableToken.h"
#include "T_FinalToken.h"
#include "T_GenericAssignmentToken.h"
#include "T_GenericConditionalToken.h"
#include "T_GenericExpandableToken.h"
#include "T_GenericFinalToken.h"
#include "T_GenericToken.h"
#include "T_GenericValueToken.h"
#include "T_InvalidToken.h"
#include "T_LeftBraceToken.h"
#include "T_ListToken.h"
#include "T_MacroToken.h"
#include "T_NumberToken.h"
#include "T_ParameterToken.h"
#include "T_RightBraceToken.h"
#include "T_TextToken.h"
#include "T_UnboundToken.h"
#include "T_UndefinedToken.h"
#include "T_VariableToken.h"

#include "T_TextConsumer.h"

#include "T_ReadAgainProducer.h"
#include "T_TextProducer.h"

#include "m_make_type_list.h"
#include "m_list.h"
#include "m_assert.h"

#include <stdlib.h>

using namespace TeXt;


enum { MaxProducerSize = mstl::tl::size_of<mstl::make_type_list<
	Controller::TokenConsumer,
	Environment::TokenProducer,
	ListToken::TokenProducer,
	MacroToken::Data,
	MacroToken::TokenProducer,
	ParameterToken::TokenProducer,
	ReadAgainProducer,
	TextConsumer,
	TextProducer
>::result>::value };

enum { MaxTokenSize = mstl::tl::size_of<mstl::make_type_list<
	ActiveToken,
	AsciiToken,
	ConditionalToken,
	ExpandableToken,
	FinalToken,
	GenericAssignmentToken,
	GenericConditionalToken,
	GenericExpandableToken,
	GenericFinalToken,
	GenericToken,
	GenericValueToken,
	InvalidToken,
	LeftBraceToken,
	ListToken,
	MacroToken,
	NumberToken,
	ParameterToken,
	RightBraceToken,
	TextToken,
	UnboundToken,
	UndefinedToken,
	VariableToken
>::result>::value };

enum { ObjectSize =
	size_t(MaxProducerSize) < size_t(MaxTokenSize) ? size_t(MaxTokenSize) : size_t(MaxProducerSize) };


struct TeXt::MemoryBlock
{
	typedef mstl::vector<Object*> ChunkList;

	MemoryBlock();

	size_t		numFree;
	Object		freeNode;
	ChunkList	chunkList;
#if !defined(NDEBUG) || !defined(NREQ)
	bool			destroyed;
#endif

	void alloc();
	void cleanup();

	static Object* succ(Object* obj);
};


MemoryBlock::MemoryBlock()
	:numFree(0)
#if !defined(NDEBUG) || !defined(NREQ)
	,destroyed(false)
#endif
{
}


Object*
MemoryBlock::succ(Object* obj)
{
	return reinterpret_cast<Object*>(reinterpret_cast<char*>(obj) + ::ObjectSize);
}


void
MemoryBlock::alloc()
{
	enum { ChunkSize		= 4096 };
	enum { BlocksInChunk	= ChunkSize/::ObjectSize };

	M_ASSERT(!(destroyed = false));	// initialization

	Object* base = static_cast<Object*>(::malloc(ChunkSize));
	Object* curr = base;
	Object* prev = 0;
	Object* next = MemoryBlock::succ(base);

	for (size_t i = 0; i < BlocksInChunk; ++i)
	{
		curr->mem_prev = prev;
		curr->mem_next = next;

		prev = curr;
		curr = next;
		next = MemoryBlock::succ(next);
	}

	M_ASSERT(reinterpret_cast<char*>(prev) <= reinterpret_cast<char*>(base) + ChunkSize);

	prev->mem_next = &freeNode;
	base->mem_prev = &freeNode;

	freeNode.mem_next = base;
	freeNode.mem_prev = prev;

	numFree += BlocksInChunk;
	chunkList.push_back(base);
}


void
MemoryBlock::cleanup()
{
	for (ChunkList::iterator i = chunkList.begin(); i != chunkList.end(); ++i)
		::free(*i);

	chunkList.clear();
	chunkList.release();

	numFree = 0;
	M_ASSERT(destroyed = true);
}


static MemoryBlock memBlock;


void*
Memory::alloc(size_t n)
{
	M_ASSERT(n <= ::ObjectSize);

	if (__builtin_expect(::memBlock.numFree == 0, 0))
		::memBlock.alloc();

	Object* p = ::memBlock.freeNode.mem_next;

	p->unlink();
	::memBlock.numFree--;

	return p;
}


void
Memory::release(void* obj)
{
	M_ASSERT(!::memBlock.destroyed);

	::memBlock.freeNode.prepend(static_cast<Object*>(obj));
	::memBlock.numFree++;
}


void
Memory::cleanup()
{
	::memBlock.cleanup();
}

#endif

// vi:set ts=3 sw=3:
