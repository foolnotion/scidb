/*
 * tkBitField.h --
 *
 *	This module implements bit field operations.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKBITFIELD
#define _TKBITFIELD

#ifndef _TK
#include "tk.h"
#endif

#include <stdint.h>

#if !defined(TK_BOOL_IS_DEFINED) && !defined(__cplusplus)
typedef int bool;
enum { true = (int) 1, false = (int) 0 };
# define TK_BOOL_IS_DEFINED
#endif

#if defined(__GNUC__) || defined(__clang__)
# define __inline__ extern inline
#else
# define __inline__
#endif


#ifdef TCL_WIDE_INT_IS_LONG
typedef uint64_t TkBitWord;
#else
typedef uint32_t TkBitWord;
#endif

#define TK_BIT_NBITS (sizeof(TkBitWord)*8) /* Number of bits in one word. */

struct TkIntSet;


/*
 * The struct below will be shared with the struct TkIntSet, so the first two
 * members must exactly match the first two members in struct TkIntSet. In this
 * way we have a struct inheritance, based on the first two members. This
 * is portable due to C99 section 6.7.2.1 bullet point 13:
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

typedef struct TkBitField {
    uint32_t refCount:31;
    uint32_t isSetFlag:1;
    uint32_t size;
#if TK_CHECK_ALLOCS
    struct TkBitField *next;
    struct TkBitField *prev;
    unsigned number;
#endif
    TkBitWord bits[1];
} TkBitField;


#define TK_BIT_NPOS ((unsigned) -1)


__inline__ TkBitField *TkBitNew(unsigned size);
TkBitField *TkBitResize(TkBitField *bf, unsigned newSize);
TkBitField *TkBitFromSet(const struct TkIntSet *set, unsigned size);
void TkBitDestroy(TkBitField **bfPtr);

__inline__ const unsigned char *TkBitData(const TkBitField *bf);
__inline__ unsigned TkBitByteSize(const TkBitField *bf);

__inline__ unsigned TkBitRefCount(const TkBitField *bf);
__inline__ void TkBitIncrRefCount(TkBitField *bf);
__inline__ unsigned TkBitDecrRefCount(TkBitField *bf);

TkBitField *TkBitCopy(const TkBitField *bf, int size);

void TkBitJoin(TkBitField *dst, const TkBitField *src);
void TkBitIntersect(TkBitField *dst, const TkBitField *src);
void TkBitRemove(TkBitField *dst, const TkBitField *src);

/* dst := dst + bf1 + bf2 */
void TkBitJoin2(TkBitField *dst, const TkBitField *bf1, const TkBitField *bf2);
/* dst := src - dst */
void TkBitComplementTo(TkBitField *dst, const TkBitField *src);
/* dst := dst + (bf2 - bf1) */
void TkBitJoinComplementTo(TkBitField *dst, const TkBitField *bf1, const TkBitField *bf2);
/* dst := dst + (bf1 - bf2) + (bf2 - bf1) */
void TkBitJoinNonIntersection(TkBitField *dst, const TkBitField *bf1, const TkBitField *bf2);
/* dst := dst + add + ((bf1 + bf2) - (bf1 & bf2)) */
void TkBitJoin2ComplementToIntersection(TkBitField *dst,
    const TkBitField *add, const TkBitField *bf1, const TkBitField *bf2);
/* dst := (dst - bf1) + (bf1 - bf2) */
void TkBitJoinOfDifferences(TkBitField *dst, const TkBitField *bf1, const TkBitField *bf2);

__inline__ bool TkBitIsEmpty(const TkBitField *bf);
__inline__ unsigned TkBitSize(const TkBitField *bf);
unsigned TkBitCount(const TkBitField *bf);

__inline__ bool TkBitTest(const TkBitField *bf, unsigned n);
__inline__ bool TkBitNone(const TkBitField *bf);
bool TkBitAny(const TkBitField *bf);
bool TkBitComplete(const TkBitField *bf);

bool TkBitIsEqual(const TkBitField *bf1, const TkBitField *bf2);
bool TkBitContains(const TkBitField *bf1, const TkBitField *bf2);
bool TkBitDisjunctive(const TkBitField *bf1, const TkBitField *bf2);
__inline__ bool TkBitIntersects(const TkBitField *bf1, const TkBitField *bf2);
bool TkBitIntersectionIsEqual(const TkBitField *bf1, const TkBitField *bf2, const TkBitField *del);

// TODO: should be rewritten to TkIntSetIsContainedBits
bool TkBitContainsSet(const TkBitField *bf, const struct TkIntSet *set);

unsigned TkBitFindFirst(const TkBitField *bf);
unsigned TkBitFindLast(const TkBitField *bf);
unsigned TkBitFindFirstNot(const TkBitField *bf);
unsigned TkBitFindLastNot(const TkBitField *bf);
unsigned TkBitFindNext(const TkBitField *bf, unsigned prev);
unsigned TkBitFindPrev(const TkBitField *bf, unsigned prev);
unsigned TkBitFindFirstInIntersection(const TkBitField* bf1, const TkBitField *bf2);

__inline__ void TkBitSet(TkBitField *bf, unsigned n);
__inline__ void TkBitUnset(TkBitField *bf, unsigned n);
__inline__ void TkBitPut(TkBitField *bf, unsigned n, bool value);
bool TkBitTestAndSet(TkBitField *bf, unsigned n);
bool TkBitTestAndUnset(TkBitField *bf, unsigned n);
void TkBitFill(TkBitField *bf);
void TkBitClear(TkBitField *bf);

/* Return nearest multiple of TK_BIT_NBITS which is greater or equal to given argument. */
__inline__ unsigned TkBitAdjustSize(unsigned size);

#if !NDEBUG
void TkBitPrint(const TkBitField *bf);
#endif

#if TK_CHECK_ALLOCS
void TkBitCheckAllocs();
#endif


#if TK_TEXT_LINE_TAGGING

/*
 * These functions are not yet needed, but shouldn't be removed, because they will
 * be important if the text widget is supporting line based tagging (currently line
 * based tagging is not supported by the display functions).
 */

/* dst := (dst + (add - sub)) & add */
void TkBitInnerJoinDifference(TkBitField *dst, const TkBitField *add, const TkBitField *sub);
/* ((bf + (add - sub)) & add) == nil */
bool TkBitInnerJoinDifferenceIsEmpty(const TkBitField *bf, const TkBitField *add, const TkBitField *sub);
/* bf1 == bf2 - sub2 */
bool TkBitIsEqualToDifference(const TkBitField *bf1, const TkBitField *bf2, const TkBitField *sub2);
/* bf1 == ((bf2 + add2) & bf2) */
bool TkBitIsEqualToInnerJoin(const TkBitField *bf1, const TkBitField *bf2, const TkBitField *add2);
/* bf1 == ((bf2 + (add2 - sub2) & add) */
bool TkBitIsEqualToInnerJoinDifference(const TkBitField *bf1, const TkBitField *bf2,
    const TkBitField *add2, const TkBitField *sub2);
/* ((bf1 + (add - sub)) & add) == ((bf2 + (add - sub)) & add) */
bool TkBitInnerJoinDifferenceIsEqual(const TkBitField *bf1, const TkBitField *bf2,
    const TkBitField *add, const TkBitField *sub);

#endif /* TK_TEXT_LINE_TAGGING */


#if defined(__GNUC__) || defined(__clang__)
# include "tkBitFieldPriv.h"
#endif

#undef __inline__
#endif /* _TKBITFIELD */
/* vi:set ts=8 sw=4: */
