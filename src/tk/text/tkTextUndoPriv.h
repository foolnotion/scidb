/*
 * tkTextUndoPriv.h --
 *
 *	Private implementation for undo stack.
 *
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef _TKTEXTUNDO
# error "do not include this private header file"
#endif

#include <assert.h>

#ifndef __inline__
# define __inline__
#endif


#ifndef IMPLEMENTATION

typedef struct TkTextUndoMyAtom {
    unsigned capacity;
    unsigned undoSize;
    struct TkTextUndoMyAtom* next;
    struct TkTextUndoMyAtom* prev;
    TkTextUndoAtom data;
} TkTextUndoMyAtom;

struct TkTextUndoStack {
    TkTextUndoPerformProc *undoProc;
    				/* Function for callback to perform undo/redo actions. */
    TkTextUndoFreeProc *freeProc;
    				/* Function which frees stack items, can be NULL. */
    TkTextUndoStackContentChangedProc *contentChangedProc;
    				/* Function which informs about stack changes. */
    TkTextUndoContext context;	/* User data. */
    TkTextUndoMyAtom *current;	/* Current undo atom (not yet pushed). */
    TkTextUndoMyAtom *root;	/* The root of the undo/redo stack. */
    TkTextUndoMyAtom *last;	/* Last added undo atom. */
    TkTextUndoMyAtom *iter;	/* Current atom in iteration loop. */
    TkTextUndoMyAtom *actual;	/* Current undo/redo atom in processing. */
    bool irreversible;		/* Whether undo actions has been released due to limited depth/size. */
    unsigned maxUndoDepth;	/* Maximal depth of the undo stack. */
    int maxRedoDepth;		/* Maximal depth of the redo stack. */
    unsigned maxSize;		/* Maximal size of the stack. */
    unsigned undoDepth;		/* Current depth of undo stack. */
    unsigned redoDepth;		/* Current depth of redo stack. */
    unsigned undoSize;		/* Total size of undo items. */
    unsigned redoSize;		/* Total size of redo items. */
    bool doingUndo;		/* Currently an undo action is performed? */
    bool doingRedo;		/* Currently an redo action is performed? */
};

#endif /* IMPLEMENTATION */


__inline__ unsigned
TkTextUndoGetMaxUndoDepth(const TkTextUndoStack stack)
{ assert(stack); return stack->maxUndoDepth; }

__inline__ unsigned
TkTextUndoGetMaxRedoDepth(const TkTextUndoStack stack)
{ assert(stack); return stack->maxRedoDepth; }

__inline__ unsigned
TkTextUndoGetMaxSize(const TkTextUndoStack stack)
{ assert(stack); return stack->maxSize; }

__inline__ bool
TkTextUndoContentIsModified(const TkTextUndoStack stack)
{ assert(stack); return stack->undoDepth > 0 || stack->irreversible; }

__inline__ bool
TkTextUndoContentIsIrreversible(const TkTextUndoStack stack)
{ assert(stack); return stack->irreversible; }

__inline__ bool
TkTextUndoIsPerformingUndo(const TkTextUndoStack stack)
{ assert(stack); return stack->doingUndo; }

__inline__ bool
TkTextUndoIsPerformingRedo(const TkTextUndoStack stack)
{ assert(stack); return stack->doingRedo; }

__inline__ bool
TkTextUndoIsPerformingUndoRedo(const TkTextUndoStack stack)
{ assert(stack); return stack->doingUndo || stack->doingRedo; }

__inline__ bool
TkTextUndoUndoStackIsFull(const TkTextUndoStack stack)
{ return !stack || (stack->maxUndoDepth > 0 && stack->undoDepth >= stack->maxUndoDepth); }

__inline__ bool
TkTextUndoRedoStackIsFull(const TkTextUndoStack stack)
{ return !stack || (stack->maxRedoDepth >= 0 && stack->redoDepth >= stack->maxRedoDepth); }

__inline__ unsigned
TkTextUndoCountCurrentUndoItems(const TkTextUndoStack stack)
{ assert(stack); return stack->current && !stack->doingUndo ? stack->current->data.arraySize : 0; }

__inline__ unsigned
TkTextUndoCountCurrentRedoItems(const TkTextUndoStack stack)
{ assert(stack); return stack->current && stack->doingUndo ? stack->current->data.arraySize : 0; }

__inline__ unsigned
TkTextUndoGetCurrentUndoStackDepth(const TkTextUndoStack stack)
{ assert(stack); return stack->undoDepth + (TkTextUndoCountCurrentUndoItems(stack) ? 1 : 0); }

__inline__ unsigned
TkTextUndoGetCurrentRedoStackDepth(const TkTextUndoStack stack)
{ assert(stack); return stack->redoDepth + (TkTextUndoCountCurrentRedoItems(stack) ? 1 : 0); }

__inline__ void
TkTextUndoSetContext(TkTextUndoStack stack, TkTextUndoContext context)
{ assert(stack); stack->context = context; }

__inline__ TkTextUndoContext
TkTextUndoGetContext(const TkTextUndoStack stack)
{ assert(stack); return stack->context; }

__inline__
unsigned
TkTextUndoGetCurrentDepth(
    const TkTextUndoStack stack)
{
    assert(stack);
    return stack->undoDepth + stack->redoDepth +
	    (stack->current && stack->current->data.arraySize > 0 ? 1 : 0);
}

__inline__
unsigned
TkTextUndoGetCurrentUndoSize(
    const TkTextUndoStack stack)
{
    assert(stack);
    return stack->undoSize + (!stack->doingUndo && stack->current ? stack->current->undoSize : 0);
}

__inline__
unsigned
TkTextUndoGetCurrentRedoSize(
    const TkTextUndoStack stack)
{
    assert(stack);
    return stack->redoSize + (!stack->doingRedo && stack->current ? stack->current->undoSize : 0);
}

__inline__
unsigned
TkTextUndoGetCurrentSize(
    const TkTextUndoStack stack)
{
    assert(stack);
    return stack->undoSize + stack->redoSize + (stack->current ? stack->current->undoSize : 0);
}

#undef __inline__
/* vi:set ts=8 sw=4: */
