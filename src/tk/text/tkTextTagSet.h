/*
 * tkTextTagSet.h --
 *
 *	This module implements a set for tagging information. The real type
 *	is either a bit field, or a set of integers, depending on the size
 *	of the tag set.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKTEXTTAGSET
#define _TKTEXTTAGSET

#include "tkBitField.h"
#include "tkIntSet.h"

#include <stdint.h>

#if defined(__GNUC__) || defined(__clang__)
# define __inline__ extern inline
# define __warn_unused__ __attribute__((warn_unused_result))
#else
# define __inline__
# define __warn_unused__
#endif

/*
 * Currently our implementation is using a shared bitfield/integer set implementation.
 * Bitfields will be used as long as the number of tags is below a certain limit
 * (will be satisfied in most applications), but in some sophisticated applications
 * this limit will be exceeded, and in this case the integer set comes into play,
 * because a bitfield is too memory hungry with a large number of tags. Bitfields
 * are very, very fast, and integer sets are moderate in speed. So a bitfield will be
 * preferred. Nevertheless this implementation might be a bit over the top, probably
 * an implementation only with integer sets is already satisfactory.
 *
 * NOTE: The bit field implementation shouldn't be removed, even if this implementation
 * will not be used, because it is required for testing the integer set (TkIntSet).
 *
 * We will use the following compiler constant for the choice (with or without bitfields):
 */

/* This is common to both implementations */
# define TK_TEXT_TAG_SET_NPOS TK_SET_NPOS


#if !TK_TEXT_DONT_USE_BITFIELDS /* shared implementation ****************************/

/*
 * The struct below is using C inheritance, this is portable due to C99 section
 * 6.7.2.1 bullet point 13:
 *
 *	Within a structure object, the non-bit-field members and the units 
 *	in which bit-fields reside have addresses that increase in the order
 *	in which they are declared. A pointer to a structure object, suitably
 *	converted, points to its initial member (or if that member is a
 *	bit-field, then to the unit in which it resides), and vice versa.
 *	There may be unnamed padding within a structure object, but not at
 *	beginning.
 *
 * This inheritance concept is also used in the portable GTK library.
 */

typedef struct TkTextTagSetBase {
    uint32_t refCount:31;
    uint32_t isSetFlag:1;
} TkTextTagSetBase;

typedef union TkTextTagSet {
    TkTextTagSetBase base;
    TkBitField bf;
    TkIntSet set;
} TkTextTagSet;


__inline__ TkTextTagSet *TkTextTagSetNew(unsigned size) __warn_unused__;
TkTextTagSet *TkTextTagSetResize(TkTextTagSet *ts, unsigned newSize) __warn_unused__;
void TkTextTagSetDestroy(TkTextTagSet **tsPtr);

__inline__ unsigned TkTextTagSetRefCount(const TkTextTagSet *ts);
__inline__ void TkTextTagSetIncrRefCount(TkTextTagSet *ts);
__inline__ unsigned TkTextTagSetDecrRefCount(TkTextTagSet *ts);

__inline__ TkTextTagSet *TkTextTagSetCopy(const TkTextTagSet *src) __warn_unused__;

TkTextTagSet *TkTextTagSetJoin(TkTextTagSet *dst, const TkTextTagSet *src) __warn_unused__;
TkTextTagSet *TkTextTagSetIntersect(TkTextTagSet *dst, const TkTextTagSet *src) __warn_unused__;
TkTextTagSet *TkTextTagSetRemove(TkTextTagSet *dst, const TkTextTagSet *src) __warn_unused__;

TkTextTagSet *TkTextTagSetIntersectBits(TkTextTagSet *dst, const TkBitField *src) __warn_unused__;
TkTextTagSet *TkTextTagSetRemoveBits(TkTextTagSet *dst, const TkBitField *src) __warn_unused__;

/* dst := dst + ts1 + ts2 */
TkTextTagSet *TkTextTagSetJoin2(TkTextTagSet *dst, const TkTextTagSet *ts1, const TkTextTagSet *ts2)
    __warn_unused__;
/* dst := src - dst */
TkTextTagSet *TkTextTagSetComplementTo(TkTextTagSet *dst, const TkTextTagSet *src) __warn_unused__;
/* dst := dst + (ts2 - ts1) */
TkTextTagSet *TkTextTagSetJoinComplementTo(TkTextTagSet *dst,
    const TkTextTagSet *ts1, const TkTextTagSet *ts2) __warn_unused__;
/* dst := dst + (ts1 - ts2) + (ts2 - ts1) */
TkTextTagSet *TkTextTagSetJoinNonIntersection(TkTextTagSet *dst,
    const TkTextTagSet *ts1, const TkTextTagSet *ts2) __warn_unused__;
/* dst := dst + add + ((ts1 + ts2) - (ts1 & ts2)) */
TkTextTagSet *TkTextTagSetJoin2ComplementToIntersection(TkTextTagSet *dst,
    const TkTextTagSet *add, const TkTextTagSet *ts1, const TkTextTagSet *ts2) __warn_unused__;
/* dst := (dst - ts1) + (ts1 - ts2) */
TkTextTagSet *TkTextTagSetJoinOfDifferences(TkTextTagSet *dst, const TkTextTagSet *ts1,
    const TkTextTagSet *ts2) __warn_unused__;

__inline__ bool TkTextTagSetIsEmpty(const TkTextTagSet *ts);
__inline__ bool TkTextTagSetIsBitField(const TkTextTagSet *ts);

__inline__ unsigned TkTextTagSetSize(const TkTextTagSet *ts);
__inline__ unsigned TkTextTagSetCount(const TkTextTagSet *ts);

__inline__ bool TkTextTagSetTest(const TkTextTagSet *ts, unsigned n);
__inline__ bool TkTextTagSetNone(const TkTextTagSet *ts);
__inline__ bool TkTextTagSetAny(const TkTextTagSet *ts);

__inline__ bool TkTextTagSetIsEqual(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
__inline__ bool TkTextTagSetContains(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
__inline__ bool TkTextTagSetDisjunctive(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
__inline__ bool TkTextTagSetIntersects(const TkTextTagSet *ts1, const TkTextTagSet *ts2);
/* (ts1 & bf) == (ts2 & bf) */
__inline__ bool TkTextTagSetIntersectionIsEqual(const TkTextTagSet *ts1, const TkTextTagSet *ts2,
    const TkBitField *bf);
__inline__ bool TkTextTagBitContainsSet(const TkBitField *bf, const TkTextTagSet *ts);

__inline__ bool TkTextTagSetIsEqualBits(const TkTextTagSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetContainsBits(const TkTextTagSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetDisjunctiveBits(const TkTextTagSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetIntersectsBits(const TkTextTagSet *ts, const TkBitField *bf);

__inline__ unsigned TkTextTagSetFindFirst(const TkTextTagSet *ts);
__inline__ unsigned TkTextTagSetFindNext(const TkTextTagSet *ts, unsigned prev);
unsigned TkTextTagSetFindFirstInIntersection(const TkTextTagSet *ts, const TkBitField *bf);

TkTextTagSet *TkTextTagSetAdd(TkTextTagSet *ts, unsigned n) __warn_unused__;
TkTextTagSet *TkTextTagSetErase(TkTextTagSet *ts, unsigned n) __warn_unused__;
__inline__ TkTextTagSet *TkTextTagSetAddOrErase(TkTextTagSet *ts, unsigned n, bool value)
    __warn_unused__;
TkTextTagSet *TkTextTagSetTestAndSet(TkTextTagSet *ts, unsigned n) __warn_unused__;
TkTextTagSet *TkTextTagSetTestAndUnset(TkTextTagSet *ts, unsigned n) __warn_unused__;
TkTextTagSet *TkTextTagSetClear(TkTextTagSet *ts) __warn_unused__;

__inline__ unsigned TkTextTagSetRangeSize(const TkTextTagSet *ts);

__inline__ const unsigned char *TkTextTagSetData(const TkTextTagSet *ts);
__inline__ unsigned TkTextTagSetByteSize(const TkTextTagSet *ts);

# if !NDEBUG
void TkTextTagSetPrint(const TkTextTagSet *set);
# endif


# if TK_TEXT_LINE_TAGGING

/*
 * These functions are not needed yet, but shouldn't be removed, because they will
 * be important if the text widget is supporting line based tagging (currently line
 * based tagging is not supported by the display functions).
 */

/* dst := (dst + (ts - sub)) & ts */
TkTextTagSet *TkTextTagSetInnerJoinDifference(TkTextTagSet *dst,
    const TkTextTagSet *ts, const TkTextTagSet *sub) __warn_unused__;
/* ((ts + (add - sub)) & add) == nil */
bool TkTextTagSetInnerJoinDifferenceIsEmpty(const TkTextTagSet *ts,
    const TkTextTagSet *add, const TkTextTagSet *sub);
/* ts1 == ts2 - sub2 */
bool TkTextTagSetIsEqualToDifference(const TkTextTagSet *ts1,
    const TkTextTagSet *ts2, const TkTextTagSet *sub2);
/* ts1 == ts2 + (add2 & ts2) */
bool TkTextTagSetIsEqualToInnerJoin(const TkTextTagSet *ts1, const TkTextTagSet *ts2,
    const TkTextTagSet *add2);
/* ts1 == ((ts2 + (add2 - sub2)) & add2) */
bool TkTextTagSetIsEqualToInnerJoinDifference(const TkTextTagSet *ts1, const TkTextTagSet *ts2,
    const TkTextTagSet *add2, const TkTextTagSet *sub2);
/* ((ts1 + (add - sub)) & add) == ((ts2 + (add - sub)) & add) */
bool TkTextTagSetInnerJoinDifferenceIsEqual(const TkTextTagSet *ts1, const TkTextTagSet *ts2,
    const TkTextTagSet *add, const TkTextTagSet *sub);

# endif /* TK_TEXT_LINE_TAGGING */

#else /* integer set only implementation **************************************/

# define TkTextTagSet TkIntSet

__inline__ TkIntSet *TkTextTagSetNew(unsigned size) __warn_unused__;
__inline__ TkIntSet *TkTextTagSetResize(TkIntSet *ts, unsigned newSize) __warn_unused__;
__inline__ void TkTextTagSetDestroy(TkIntSet **tsPtr);

__inline__ unsigned TkTextTagSetRefCount(const TkIntSet *ts);
__inline__ void TkTextTagSetIncrRefCount(TkIntSet *ts);
__inline__ unsigned TkTextTagSetDecrRefCount(TkIntSet *ts);

__inline__ TkIntSet *TkTextTagSetCopy(const TkIntSet *src) __warn_unused__;

TkIntSet *TkTextTagSetJoin(TkIntSet *dst, const TkIntSet *src) __warn_unused__;
TkIntSet *TkTextTagSetIntersect(TkIntSet *dst, const TkIntSet *src) __warn_unused__;
TkIntSet *TkTextTagSetRemove(TkIntSet *dst, const TkIntSet *src) __warn_unused__;

TkIntSet *TkTextTagSetIntersectBits(TkIntSet *dst, const TkBitField *src) __warn_unused__;
TkIntSet *TkTextTagSetRemoveBits(TkIntSet *dst, const TkBitField *src) __warn_unused__;

/* dst := dst + ts1 + ts2 */
TkIntSet *TkTextTagSetJoin2(TkIntSet *dst, const TkIntSet *ts1, const TkIntSet *ts2) __warn_unused__;
/* dst := src - dst */
TkIntSet *TkTextTagSetComplementTo(TkIntSet *dst, const TkIntSet *src) __warn_unused__;
/* dst := dst + (bf2 - bf1) */
TkIntSet *TkTextTagSetJoinComplementTo(TkIntSet *dst, const TkIntSet *ts1, const TkIntSet *ts2)
    __warn_unused__;
/* dst := dst + (set1 - set2) + (set2 - set1) */
TkIntSet *TkTextTagSetJoinNonIntersection(TkIntSet *dst, const TkIntSet *ts1, const TkIntSet *ts2)
    __warn_unused__;
/* dst := dst + add + ((ts1 + ts2) - (ts1 & ts2)) */
TkIntSet *TkTextTagSetJoin2ComplementToIntersection(TkIntSet *dst, const TkIntSet *add,
    const TkIntSet *ts1, const TkIntSet *ts2) __warn_unused__;
/* dst := (dst - ts1) + (ts1 - ts2) */
TkIntSet *TkTextTagSetJoinOfDifferences(TkIntSet *dst, const TkIntSet *ts1, const TkIntSet *ts2)
    __warn_unused__;

__inline__ bool TkTextTagSetIsEmpty(const TkIntSet *ts);
__inline__ bool TkTextTagSetIsBitField(const TkIntSet *ts);

__inline__ unsigned TkTextTagSetSize(const TkIntSet *ts);
__inline__ unsigned TkTextTagSetCount(const TkIntSet *ts);

__inline__ bool TkTextTagSetTest(const TkIntSet *ts, unsigned n);
__inline__ bool TkTextTagSetNone(const TkIntSet *ts);
__inline__ bool TkTextTagSetAny(const TkIntSet *ts);

__inline__ bool TkTextTagSetIsEqual(const TkIntSet *ts1, const TkIntSet *ts2);
__inline__ bool TkTextTagSetContains(const TkIntSet *ts1, const TkIntSet *ts2);
__inline__ bool TkTextTagSetDisjunctive(const TkIntSet *ts1, const TkIntSet *ts2);
__inline__ bool TkTextTagSetIntersects(const TkIntSet *ts1, const TkIntSet *ts2);
/* (ts1 & bf) == (ts2 & bf) */
__inline__ bool TkTextTagSetIntersectionIsEqual(const TkIntSet *ts1, const TkIntSet *ts2,
    const TkBitField *bf);
__inline__ bool TkTextTagBitContainsSet(const TkBitField *bf, const TkIntSet *ts);

__inline__ bool TkTextTagSetIsEqualBits(const TkIntSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetContainsBits(const TkIntSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetDisjunctiveBits(const TkIntSet *ts, const TkBitField *bf);
__inline__ bool TkTextTagSetIntersectsBits(const TkIntSet *ts, const TkBitField *bf);

__inline__ unsigned TkTextTagSetFindFirst(const TkIntSet *ts);
__inline__ unsigned TkTextTagSetFindNext(const TkIntSet *ts, unsigned prev);
__inline__ unsigned TkTextTagSetFindFirstInIntersection(const TkIntSet *ts, const TkBitField *bf);

TkIntSet *TkTextTagSetAdd(TkIntSet *ts, unsigned n) __warn_unused__;
TkIntSet *TkTextTagSetErase(TkIntSet *ts, unsigned n) __warn_unused__;
__inline__ TkIntSet *TkTextTagSetAddOrErase(TkIntSet *ts, unsigned n, bool value) __warn_unused__;
TkIntSet *TkTextTagSetTestAndSet(TkIntSet *ts, unsigned n) __warn_unused__;
TkIntSet *TkTextTagSetTestAndUnset(TkIntSet *ts, unsigned n) __warn_unused__;
__inline__ TkIntSet *TkTextTagSetClear(TkIntSet *ts) __warn_unused__;

__inline__ unsigned TkTextTagSetRangeSize(const TkIntSet *ts);

__inline__ const unsigned char *TkTextTagSetData(const TkIntSet *ts);
__inline__ unsigned TkTextTagSetByteSize(const TkIntSet *ts);

#endif /* !TK_TEXT_DONT_USE_BITFIELDS */

#if defined(__GNUC__) || defined(__clang__)
# include "tkTextTagSetPriv.h"
#endif

#undef __inline__
#undef __warn_unused__
#endif /* _TKTEXTTAGSET */
/* vi:set ts=8 sw=4: */
