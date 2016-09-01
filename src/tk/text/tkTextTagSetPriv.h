/*
 * tkTextTagSetPriv.h --
 *
 *	Private implementation.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKTEXTTAGSET
# error "do not include this private header file"
#endif

#ifndef _TK
#include "tk.h"
#endif

#include <assert.h>

#ifndef __inline__
# define __inline__
#endif


#if !TK_TEXT_DONT_USE_BITFIELDS /* shared implementation ****************************/

/*
 * The constant TK_TEXT_SET_MAX_BIT_SIZE is defining the upper bound of
 * the bit size in bit fields. This means that if more than TK_TEXT_SET_MAX_BIT_SIZE
 * tags are in usage, the tag set is using integer sets instead of bit fields,
 * because large bit fields are exploding the memory usage.
 *
 * The constant TK_TEXT_SET_MAX_BIT_SIZE must be a multiple of TK_BIT_NBITS.
 */

#ifdef TCL_WIDE_INT_IS_LONG

/*
 * On 64 bit systems this is the optimal size and it is not recommended to
 * choose a lower size.
 */
# define TK_TEXT_SET_MAX_BIT_SIZE (((512 + TK_BIT_NBITS - 1)/TK_BIT_NBITS)*TK_BIT_NBITS)

#else /* TCL_WIDE_INT_IS_LONG */

/*
 * On 32 bit systems the current size (512) might be too large. If so it should
 * be reduced to 256, but it is not recommended to define a lower constant than
 * 256.
 */
# define TK_TEXT_SET_MAX_BIT_SIZE (((512 + TK_BIT_NBITS - 1)/TK_BIT_NBITS)*TK_BIT_NBITS)

#endif /* TCL_WIDE_INT_IS_LONG */


MODULE_SCOPE bool TkTextTagSetIsEqual_(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
MODULE_SCOPE bool TkTextTagSetContains_(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
MODULE_SCOPE bool TkTextTagSetDisjunctive_(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
MODULE_SCOPE bool TkTextTagSetIntersectionIsEqual_(const TkTextTagSet *ts1, const TkTextTagSet *ts2,
		    const TkBitField *bf);


__inline__
TkTextTagSet *
TkTextTagSetNew(
    unsigned size)
{
    if (size <= TK_TEXT_SET_MAX_BIT_SIZE) {
	return (TkTextTagSet *) TkBitNew(size);
    }
    return (TkTextTagSet *) TkIntSetNew();
}


__inline__
unsigned
TkTextTagSetRefCount(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.refCount;
}


__inline__
void
TkTextTagSetIncrRefCount(
    TkTextTagSet *ts)
{
    assert(ts);
    ts->base.refCount += 1;
}


__inline__
unsigned
TkTextTagSetDecrRefCount(
    TkTextTagSet *ts)
{
    unsigned refCount;

    assert(ts);
    assert(TkTextTagSetRefCount(ts) > 0);

    if ((refCount = --ts->base.refCount) == 0) {
	TkTextTagSetDestroy(&ts);
    }
    return refCount;
}


__inline__
bool
TkTextTagSetIsEmpty(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetIsEmpty(&ts->set) : TkBitNone(&ts->bf);
}


__inline__
bool
TkTextTagSetIsBitField(
    const TkTextTagSet *ts)
{
    assert(ts);
    return !ts->base.isSetFlag;
}


__inline__
unsigned
TkTextTagSetSize(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TK_TEXT_TAG_SET_NPOS - 1 : TkBitSize(&ts->bf);
}


__inline__
unsigned
TkTextTagSetRangeSize(
    const TkTextTagSet *ts)
{
    assert(ts);

    if (!ts->base.isSetFlag) {
	return TkBitSize(&ts->bf);
    }
    return TkIntSetIsEmpty(&ts->set) ? 0 : TkIntSetMax(&ts->set) + 1;
}


__inline__
unsigned
TkTextTagSetCount(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetSize(&ts->set) : TkBitCount(&ts->bf);
}


__inline__
bool
TkTextTagSetIsEqual(
    const TkTextTagSet *ts1,
    const TkTextTagSet *ts2)
{
    assert(ts1);
    assert(ts2);

    if (ts1->base.isSetFlag || ts2->base.isSetFlag) {
	return TkTextTagSetIsEqual_(ts1, ts2);
    }
    return TkBitIsEqual(&ts1->bf, &ts2->bf);
}


__inline__
bool
TkTextTagSetContains(
    const TkTextTagSet *ts1,
    const TkTextTagSet *ts2)
{
    assert(ts1);
    assert(ts2);

    if (ts1->base.isSetFlag || ts2->base.isSetFlag) {
	return TkTextTagSetContains_(ts1, ts2);
    }
    return TkBitContains(&ts1->bf, &ts2->bf);
}


__inline__
bool
TkTextTagSetDisjunctive(
    const TkTextTagSet *ts1,
    const TkTextTagSet *ts2)
{
    assert(ts1);
    assert(ts2);

    if (ts1->base.isSetFlag || ts2->base.isSetFlag) {
	return TkTextTagSetDisjunctive_(ts1, ts2);
    }
    return TkBitDisjunctive(&ts1->bf, &ts2->bf);
}


__inline__
bool
TkTextTagSetIntersects(
    const TkTextTagSet *ts1,
    const TkTextTagSet *ts2)
{
    return !TkTextTagSetDisjunctive(ts1, ts2);
}


__inline__
bool
TkTextTagSetIntersectionIsEqual(
    const TkTextTagSet *ts1,
    const TkTextTagSet *ts2,
    const TkBitField *bf)
{
    assert(ts1);
    assert(ts2);

    if (ts1->base.isSetFlag || ts2->base.isSetFlag) {
	return TkTextTagSetIntersectionIsEqual_(ts1, ts2, bf);
    }
    return TkBitIntersectionIsEqual(&ts1->bf, &ts2->bf, bf);
}


__inline__
bool
TkTextTagBitContainsSet(
    const TkBitField *bf,
    const TkTextTagSet *ts)
{
    return ts->base.isSetFlag ? TkBitContainsSet(bf, &ts->set) : TkBitContains(bf, &ts->bf);
}


__inline__
bool
TkTextTagSetIsEqualBits(
    const TkTextTagSet *ts,
    const TkBitField *bf)
{
    assert(ts);
    assert(bf);
    return ts->base.isSetFlag ? TkIntSetIsEqualBits(&ts->set, bf) : TkBitIsEqual(&ts->bf, bf);
}


__inline__
bool
TkTextTagSetContainsBits(
    const TkTextTagSet *ts,
    const TkBitField *bf)
{
    assert(ts);
    assert(bf);
    return ts->base.isSetFlag ? TkIntSetContainsBits(&ts->set, bf) : TkBitContains(&ts->bf, bf);
}


__inline__
bool
TkTextTagSetDisjunctiveBits(
    const TkTextTagSet *ts,
    const TkBitField *bf)
{
    assert(ts);
    assert(bf);
    return ts->base.isSetFlag ? TkIntSetDisjunctiveBits(&ts->set, bf) : TkBitDisjunctive(&ts->bf, bf);
}


__inline__
bool
TkTextTagSetIntersectsBits(
    const TkTextTagSet *ts,
    const TkBitField *bf)
{
    return !TkTextTagSetDisjunctiveBits(ts, bf);
}


__inline__
bool
TkTextTagSetTest(
    const TkTextTagSet *ts,
    unsigned n)
{
    assert(ts);

    if (ts->base.isSetFlag) {
	return TkIntSetTest(&ts->set, n);
    }
    return n < TkBitSize(&ts->bf) && TkBitTest(&ts->bf, n);
}


__inline__
bool
TkTextTagSetNone(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetAny(&ts->set) : TkBitAny(&ts->bf);
}


__inline__
bool
TkTextTagSetAny(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetNone(&ts->set) : TkBitNone(&ts->bf);
}


__inline__
TkTextTagSet *
TkTextTagSetCopy(
    const TkTextTagSet *src)
{
    assert(src);

    if (src->base.isSetFlag) {
	return (TkTextTagSet *) TkIntSetCopy(&src->set);
    }
    return (TkTextTagSet *) TkBitCopy(&src->bf, -1);
}


__inline__
unsigned
TkTextTagSetFindFirst(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetFindFirst(&ts->set) : TkBitFindFirst(&ts->bf);
}


__inline__
unsigned
TkTextTagSetFindNext(
    const TkTextTagSet *ts,
    unsigned prev)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetFindNext(&ts->set) :  TkBitFindNext(&ts->bf, prev);
}


__inline__
TkTextTagSet *
TkTextTagSetAddOrErase(
    TkTextTagSet *ts,
    unsigned n,
    bool value)
{
    assert(ts);
    return value ? TkTextTagSetAdd(ts, n) : TkTextTagSetErase(ts, n);
}


__inline__
const unsigned char *
TkTextTagSetData(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetData(&ts->set) : TkBitData(&ts->bf);
}


__inline__
unsigned
TkTextTagSetByteSize(
    const TkTextTagSet *ts)
{
    assert(ts);
    return ts->base.isSetFlag ? TkIntSetByteSize(&ts->set) : TkBitByteSize(&ts->bf);
}

#else /* integer set only implementation **************************************/

__inline__
TkIntSet *TkTextTagSetNew(unsigned size) { return TkIntSetNew(); }

__inline__
TkIntSet *TkTextTagSetResize(TkIntSet *ts, unsigned newSize)
{ if (!ts) { (ts = TkIntSetNew())->refCount = 1; }; return ts; }

__inline__
void TkTextTagSetDestroy(TkIntSet **tsPtr) { TkIntSetDestroy(tsPtr); }

__inline__
unsigned TkTextTagSetRefCount(const TkIntSet *ts) { return TkIntSetRefCount(ts); }

__inline__
void TkTextTagSetIncrRefCount(TkIntSet *ts) { TkIntSetIncrRefCount(ts); }

__inline__
unsigned TkTextTagSetDecrRefCount(TkIntSet *ts) { return TkIntSetDecrRefCount(ts); }

__inline__
TkIntSet *TkTextTagSetCopy(const TkIntSet *src) { return TkIntSetCopy(src); }

__inline__
bool TkTextTagSetIsEmpty(const TkIntSet *ts) { return TkIntSetIsEmpty(ts); }

__inline__
bool TkTextTagSetIsBitField(const TkIntSet *ts) { assert(ts); return true; }

__inline__
unsigned TkTextTagSetSize(const TkIntSet *ts) { return TK_TEXT_TAG_SET_NPOS - 1; }

__inline__
unsigned TkTextTagSetCount(const TkIntSet *ts) { return TkIntSetSize(ts); }

__inline__
bool TkTextTagSetTest(const TkIntSet *ts, unsigned n) { return TkIntSetTest(ts, n); }

__inline__
bool TkTextTagSetNone(const TkIntSet *ts) { return TkIntSetNone(ts); }

__inline__
bool TkTextTagSetAny(const TkIntSet *ts) { return TkIntSetAny(ts); }

__inline__
bool TkTextTagSetIsEqual(const TkIntSet *ts1, const TkIntSet *ts2)
{ return TkIntSetIsEqual(ts1, ts2); }

__inline__
bool TkTextTagSetContains(const TkIntSet *ts1, const TkIntSet *ts2)
{ return TkIntSetContains(ts1, ts2); }

__inline__
bool TkTextTagSetDisjunctive(const TkIntSet *ts1, const TkIntSet *ts2)
{ return TkIntSetDisjunctive(ts1, ts2); }

__inline__
bool TkTextTagSetIntersects(const TkIntSet *ts1, const TkIntSet *ts2)
{ return TkIntSetIntersects(ts1, ts2); }

__inline__
bool TkTextTagSetIntersectionIsEqual(const TkIntSet *ts1, const TkIntSet *ts2,
    const TkBitField *src)
{ return TkIntSetIntersectionIsEqual(ts1, ts2, src); }

__inline__
bool TkTextTagBitContainsSet(const TkBitField *bf, const TkIntSet *ts)
{ return TkBitContainsSet(bf, ts); }

__inline__
bool TkTextTagSetIsEqualBits(const TkIntSet *ts, const TkBitField *bf)
{ return TkIntSetIsEqualBits(ts, bf); }

__inline__
bool TkTextTagSetContainsBits(const TkIntSet *ts, const TkBitField *bf)
{ return TkIntSetContainsBits(ts, bf); }

__inline__
bool TkTextTagSetDisjunctiveBits(const TkIntSet *ts, const TkBitField *bf)
{ return TkIntSetDisjunctiveBits(ts, bf); }

__inline__
bool TkTextTagSetIntersectsBits(const TkIntSet *ts, const TkBitField *bf)
{ return !TkTextTagSetDisjunctiveBits(ts, bf); }

__inline__
unsigned TkTextTagSetFindFirst(const TkIntSet *ts) { return TkIntSetFindFirst(ts); }

__inline__
unsigned TkTextTagSetFindNext(const TkIntSet *ts, unsigned prev)
{ return TkIntSetFindNext(ts); }

__inline__
unsigned TkTextTagSetFindFirstInIntersection(const TkIntSet *ts, const TkBitField *bf)
{ return TkIntSetFindFirstInIntersection(ts, bf); }

__inline__
TkIntSet *TkTextTagSetAddOrErase(TkIntSet *ts, unsigned n, bool value)
{ return value ? TkTextTagSetAdd(ts, n) : TkTextTagSetErase(ts, n); }

__inline__
TkIntSet *TkTextTagSetClear(TkIntSet *ts) { return TkIntSetClear(ts); }

__inline__
unsigned TkTextTagSetRangeSize(const TkIntSet *ts)
{ return TkIntSetIsEmpty(ts) ? 0 : TkIntSetMax(ts) + 1; }

__inline__
unsigned char *TkTextTagSetData(const TkTextTagSet *ts)
{ assert(ts); return TkIntSetData(&ts->set); }

__inline__
unsigned
TkTextTagSetByteSize(const TkTextTagSet *ts)
{ assert(ts); return TkIntSetByteSize(&ts->set); }


#endif /* !TK_TEXT_USE_BITFIELDS */

#undef __inline__
/* vi:set ts=8 sw=4: */
