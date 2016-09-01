/*
 * tkBitFieldPriv.h --
 *
 *	Private implementation for bit field.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKBITFIELD
# error "do not include this private header file"
#endif

#include <assert.h>

#ifndef __inline__
# define __inline__
#endif

#define TK_BIT_WORD_INDEX(n)	((n) >> ((TK_BIT_NBITS + 128) >> 5))
#define TK_BIT_INDEX(n)		((n) & (TK_BIT_NBITS - 1))
#define TK_BIT_MASK(n)		(((TkBitWord) 1) << (n))
#define TK_BIT_COUNT_WORDS(n)	((n + TK_BIT_NBITS - 1)/TK_BIT_NBITS)


MODULE_SCOPE bool TkBitNone_(const TkBitWord *buf, unsigned words);


__inline__
const unsigned char *
TkBitData(
    const TkBitField *bf)
{
    assert(bf);
    return (const void *) bf->bits;
}


__inline__
unsigned
TkBitByteSize(
    const TkBitField *bf)
{
    assert(bf);
    return TK_BIT_COUNT_WORDS(bf->size);
}


__inline__
unsigned
TkBitAdjustSize(
    unsigned size)
{
    return ((size + (TK_BIT_NBITS - 1))/TK_BIT_NBITS)*TK_BIT_NBITS;
}


__inline__
TkBitField *
TkBitNew(
    unsigned size)
{
    TkBitField *bf = TkBitResize(NULL, size);
    bf->refCount = 0;
    return bf;
}


__inline__
unsigned
TkBitRefCount(
    const TkBitField *bf)
{
    assert(bf);
    return bf->refCount;
}


__inline__
void
TkBitIncrRefCount(
    TkBitField *bf)
{
    assert(bf);
    bf->refCount += 1;
}


__inline__
unsigned
TkBitDecrRefCount(
    TkBitField *bf)
{
    unsigned refCount;

    assert(bf);
    assert(TkBitRefCount(bf) > 0);

    if ((refCount = --bf->refCount) == 0) {
	TkBitDestroy(&bf);
    }
    return refCount;
}


__inline__
unsigned
TkBitSize(
    const TkBitField *bf)
{
    assert(bf);
    return bf->size;
}


__inline__
bool
TkBitIsEmpty(
    const TkBitField *bf)
{
    assert(bf);
    return bf->size == 0;
}


__inline__
bool
TkBitNone(
    const TkBitField *bf)
{
    assert(bf);
    return bf->size == 0 || TkBitNone_(bf->bits, TK_BIT_COUNT_WORDS(bf->size));
}


__inline__
bool
TkBitIntersects(
    const TkBitField *bf1,
    const TkBitField *bf2)
{
    return !TkBitDisjunctive(bf1, bf2);
}


__inline__
bool
TkBitTest(
    const TkBitField *bf,
    unsigned n)
{
    assert(bf);
    assert(n < TkBitSize(bf));
    return !!(bf->bits[TK_BIT_WORD_INDEX(n)] & TK_BIT_MASK(TK_BIT_INDEX(n)));
}


__inline__
void
TkBitSet(
    TkBitField *bf,
    unsigned n)
{
    assert(bf);
    assert(n < TkBitSize(bf));
    bf->bits[TK_BIT_WORD_INDEX(n)] |= TK_BIT_MASK(TK_BIT_INDEX(n));
}


__inline__
void
TkBitUnset(
    TkBitField *bf,
    unsigned n)
{
    assert(bf);
    assert(n < TkBitSize(bf));
    bf->bits[TK_BIT_WORD_INDEX(n)] &= ~TK_BIT_MASK(TK_BIT_INDEX(n));
}


__inline__
void
TkBitPut(
    TkBitField *bf,
    unsigned n,
    bool value)
{
    if (value) {
	TkBitSet(bf, n);
    } else {
	TkBitUnset(bf, n);
    }
}

#undef __inline__
/* vi:set ts=8 sw=4: */
