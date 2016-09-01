/*
 * tkRangeListPriv.h --
 *
 *	Private implementation for range list.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKRANGELIST
# error "do not include this private header file"
#endif

#include <stddef.h>
#include <assert.h>

#ifndef __inline__
# define __inline__
#endif


__inline__
int
TkRangeSpan(
    const TkRange *range)
{
    assert(range);
    return range->high - range->low + 1;
}


__inline__
bool
TkRangeTest(
    const TkRange *range,
    int value)
{
    assert(range);
    return range->low <= value && value <= range->high;
}


__inline__
bool
TkRangeListIsEmpty(
    const TkRangeList *ranges)
{
    assert(ranges);
    return ranges->size == 0;
}


__inline__
int
TkRangeListLow(
    const TkRangeList *ranges)
{
    assert(ranges);
    assert(!TkRangeListIsEmpty(ranges));
    return ranges->items[0].low;
}


__inline__
int
TkRangeListHigh(
    const TkRangeList *ranges)
{
    assert(ranges);
    assert(!TkRangeListIsEmpty(ranges));
    return ranges->items[ranges->size - 1].high;
}


__inline__
unsigned
TkRangeListSpan(
    const TkRangeList *ranges)
{
    assert(ranges);
    return ranges->size ? TkRangeListHigh(ranges) - TkRangeListLow(ranges) + 1 : 0;
}


__inline__
unsigned
TkRangeListSize(
    const TkRangeList *ranges)
{
    assert(ranges);
    return ranges->size;
}


__inline__
unsigned
TkRangeListCount(
    const TkRangeList *ranges)
{
    assert(ranges);
    return ranges->count;
}


__inline__
const TkRange *
TkRangeListAccess(
    const TkRangeList *ranges,
    unsigned index)
{
    assert(ranges);
    assert(index < TkRangeListSize(ranges));
    return &ranges->items[index];
}


__inline__
bool
TkRangeListContains(
    const TkRangeList *ranges,
    int value)
{
    return !!TkRangeListFind(ranges, value);
}


__inline__
bool
TkRangeListContainsRange(
    const TkRangeList *ranges,
    int low,
    int high)
{
    const TkRange *range = TkRangeListFind(ranges, low);
    return range && range->high <= high;
}


__inline__
const TkRange *
TkRangeListFirst(
    const TkRangeList *ranges)
{
    assert(ranges);
    return ranges->size == 0 ? NULL : ranges->items;
}


__inline__
const TkRange *
TkRangeListNext(
    const TkRangeList *ranges,
    const TkRange *item)
{
    assert(item);
    assert(ranges);
    assert(ranges->items <= item && item < ranges->items + ranges->size);
    return ++item == ranges->items + ranges->size ? NULL : item;
}

#undef __inline__
/* vi:set ts=8 sw=4: */
