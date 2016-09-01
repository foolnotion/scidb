/*
 * tkTextUndo.c --
 *
 *	This module provides the implementation of an undo stack.
 *
 * Copyright (c) 2015-2016 Gregor Cramer.
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tkInt.h"
#include "tkTextUndo.h"
#include <assert.h>

#ifndef MAX
# define MAX(a,b) ((a) < (b) ? b : a)
#endif

#ifndef MIN
# define MIN(a,b) ((a) < (b) ? a : b)
#endif


typedef TkTextUndoMyAtom MyUndoAtom;


/*
 * Our list of undo/redo atoms is a circular double linked list.
 * It's circular beause the "last" pointer is connected with the
 * "root" pointer. The list starts either with the oldest undo atom,
 * or with the newest redo atom if no undo atom exists. The list
 * ends either with the newest undo atom, or with the newest undo
 * atom if no redo atom exists.
 *
 * 'stack->last' is always pointing to the newest undo item, or
 * NULL if no undo item exists.
 *
 * 'stack->root' is always pointing either to the oldest undo item,
 * or to the oldest redo item if no undo item exists.
 *
 * 'stack->current' is the current atom which receives all pushed
 * items (TkTextUndoPushItem), and is not yet linked into the list.
 * 'stack->current' can be NULL, in this case it has to be created
 * when the user is pushing an item.
 *
 * last ------------------+
 * root --+               |
 *        V               V
 *      +---+   +---+   +---+   +---+
 *   +->| A |-->| B |-->| C |-->| d |--+
 *   |  +---+   +---+   +---+   +---+  |
 *   ----------------------------------+
 *      undo: 3	                redo: 1
 */


#define ATOM_SIZE(n) (Tk_Offset(TkTextUndoMyAtom, data) \
	+ Tk_Offset(TkTextUndoAtom, array) + (n)*sizeof(TkTextUndoSubAtom))


enum { InitialCapacity = 20 };


static void
FreeItems(
    const TkTextUndoStack stack,
    const TkTextUndoAtom *atom)
{
    TkTextUndoFreeProc *freeProc = stack->freeProc;
    const TkTextUndoSubAtom *arr;
    unsigned i, n;

    assert(atom);

    if (!freeProc) {
	return;
    }

    arr = atom->array;
    n = atom->arraySize;

    for (i = 0; i < n; ++i) {
	freeProc(stack, &arr[i]);
    }
}


static void
Release(
    TkTextUndoStack stack,
    MyUndoAtom *atom)
{
    MyUndoAtom *first, *root, *prev;

    if (!atom) {
	return;
    }

    assert(stack->root);
    first = atom;
    root = stack->root;
    prev = atom->prev;

    /*
     * Now delete all atoms starting at 'atom' until we reach the end (inclusive).
     */

    do {
	MyUndoAtom *next = atom->next;
	FreeItems(stack, &atom->data);
	ckfree(atom);
	atom = next;
    } while (atom != root);

    /*
     * Update the list pointers accordingly.
     */

    if (first == root) {
	stack->root = stack->last = NULL;
    } else {
	root->prev = prev;
	prev->next = root;
    }
}


static void
ResetCurrent(
    TkTextUndoStack stack,
    bool force)
{
    TkTextUndoMyAtom *current = stack->current;

    if (current) {
	FreeItems(stack, &current->data);
    }

    if (force || !current || current->capacity > InitialCapacity) {
	static unsigned Size = ATOM_SIZE(InitialCapacity);
	current = stack->current = memset(ckrealloc(current, Size), 0, Size);
	current->capacity = InitialCapacity;
    }

    current->data.arraySize = 0;
    current->data.size = 0;
    current->undoSize = 0;
}


static MyUndoAtom*
SwapCurrent(
    TkTextUndoStack stack,
    MyUndoAtom *atom)
{
    MyUndoAtom *current = stack->current;

    assert(atom != current);

    if (current->capacity != current->data.size) {
	current = stack->current = ckrealloc(current, ATOM_SIZE(current->data.arraySize));
	current->capacity = current->data.arraySize;
    }

    if (!atom) {
	/*
	 * Just use the 'stack->current' item.
	 */
	stack->current = NULL;
	return current;
    }

    /*
     * Exchange given 'atom' with 'stack->current', this means that
     * 'stack->current' will be linked into the list replacing 'atom',
     * and 'atom' will become 'stack->current'.
     */

    if (atom->next == atom) {
	current->next = current;
	current->prev = current;
    } else {
	current->next = atom->next;
	current->prev = atom->prev;
	atom->next->prev = current;
	atom->prev->next = current;
    }

    stack->current = atom;
    atom->data.arraySize = 0;
    atom->data.size = 0;
    atom->undoSize = 0;
    atom->next = atom->prev = NULL;

    if (stack->root == atom) {
	stack->root = current;
    }
    if (stack->last == atom) {
	stack->last = current;
    }

    return current;
}


static bool
ClearRedoStack(
    TkTextUndoStack stack)
{
    MyUndoAtom *atom;

    if (stack->redoDepth == 0) {
	return false;
    }

    atom = stack->last ? stack->last->next : stack->root;

    assert(atom);
    stack->redoDepth = 0;
    stack->redoSize = 0;
    Release(stack, atom);

    return true;
}


static void
InsertCurrentAtom(
    TkTextUndoStack stack)
{
    MyUndoAtom *atom;
    MyUndoAtom *current = stack->current;

    if (!current || current->data.arraySize == 0) {
	assert(!stack->doingUndo && !stack->doingRedo);
	return;
    }

    if (stack->maxSize > 0 && !stack->doingRedo) {
	unsigned newStackSize = current->data.size;

	if (stack->doingUndo) {
	    newStackSize = MAX(current->undoSize, newStackSize);
	}
	newStackSize += stack->undoSize + stack->redoSize;

	if (newStackSize > stack->maxSize) {
	    /*
	     * We do not push this atom, because the addtional size would
	     * exceed the maximal content size.
	     *
	     * Note that we must push an undo atom while performing a redo,
	     * but this case is already catched, and the size of this atom
	     * has already been taken into account (with the check of
	     * 'current->undoSize' when inserting the reverting redo atom;
	     * we assume that the new undo atom size is the same as the
	     * undo size before the redo).
	     */
	    if (stack->doingUndo) {
		/*
		 * We do not push this redo atom while peforming an undo, so all
		 * redoes are expired, we have to delete them.
		 */
		ClearRedoStack(stack);
	    } else {
		/*
		 * We do not push this undo atom, so the content becomes irreversible.
		 */
		stack->irreversible = true;
	    }
	    FreeItems(stack, &stack->current->data);
	    ResetCurrent(stack, false);
	    return;
	}
    }

    if (stack->doingRedo) {
	/*
	 * We'll push an undo atom while performing a redo.
	 */
	if (!stack->last) {
	    stack->last = stack->root;
	}
	atom = stack->last;
	SwapCurrent(stack, atom);
	stack->undoDepth += 1;
	stack->undoSize += atom->data.size;
    } else if (stack->doingUndo) {
	/*
	 * We'll push a redo atom while performing an undo.
	 */
	assert(stack->maxRedoDepth <= 0 || stack->redoDepth < stack->maxRedoDepth);
	atom = stack->last ? stack->last->next : stack->root;
	SwapCurrent(stack, atom);
	stack->redoDepth += 1;
	stack->redoSize += atom->data.size;
    } else if (stack->last && stack->undoDepth == stack->maxUndoDepth) {
	/*
	 * We have reached the maximal stack limit, so delete the oldest undo
	 * before inserting the new item. The consequence is that now the content
	 * becomes irreversible. Furthermore all redo items will expire.
	 */
	ClearRedoStack(stack);
	assert(stack->last);
	atom = stack->last->next;
	stack->root = atom->next;
	stack->last = atom;
	stack->undoSize -= atom->data.size;
	stack->irreversible = true;
	FreeItems(stack, &atom->data);
	SwapCurrent(stack, atom);
	stack->undoSize += atom->data.size;
    } else {
	/*
	 * Just insert the newly undo atom. Furthermore all redo items will expire.
	 */
	ClearRedoStack(stack);
	if (stack->last == NULL) {
	    stack->last = stack->root;
	}
	atom = SwapCurrent(stack, NULL);
	if ((atom->prev = stack->last)) {
	    atom->next = stack->last->next;
	    stack->last->next->prev = atom;
	    stack->last->next = atom;
	} else {
	    atom->next = atom->prev = stack->root = atom;
	}
	stack->last = atom;
	stack->undoDepth += 1;
	stack->undoSize += atom->data.size;
    }

    if (!stack->doingUndo) {
	/*
	 * Remember the size of this undo atom, probably we need it for the
	 * decision whether to push a redo atom when performing an undo.
	 */
	atom->undoSize = atom->data.size;
    }

    /*
     * Reset the buffer for next action.
     */
    ResetCurrent(stack, false);
}


static int
ResetStack(
    TkTextUndoStack stack,
    bool irreversible)
{
    bool contentChanged;

    assert(stack);

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    contentChanged = stack->undoDepth > 0 || stack->redoDepth > 0 || stack->current;

    if (contentChanged) {
	Release(stack, stack->root);
	ResetCurrent(stack, true);
	stack->root = NULL;
	stack->last = NULL;
	stack->undoDepth = 0;
	stack->redoDepth = 0;
	stack->undoSize = 0;
	stack->redoSize = 0;
	stack->irreversible = irreversible;

	if (stack->contentChangedProc) {
	    stack->contentChangedProc(stack);
	}
    }

    return TCL_OK;
}


TkTextUndoStack
TkTextUndoCreateStack(
    unsigned maxUndoDepth,
    int maxRedoDepth,
    unsigned maxSize,
    TkTextUndoPerformProc undoProc,
    TkTextUndoFreeProc freeProc,
    TkTextUndoStackContentChangedProc contentChangedProc)
{
    TkTextUndoStack stack;

    assert(undoProc);

    stack = memset(ckalloc(sizeof(*stack)), 0, sizeof(*stack));
    stack->undoProc = undoProc;
    stack->freeProc = freeProc;
    stack->contentChangedProc = contentChangedProc;
    stack->maxUndoDepth = maxUndoDepth;
    stack->maxRedoDepth = MAX(maxRedoDepth, -1);
    stack->maxSize = maxSize;

    return stack;
}


void
TkTextUndoDestroyStack(
    TkTextUndoStack *stackPtr)
{
    if (stackPtr) {
	TkTextUndoStack stack = *stackPtr;

	if (stack) {
	    assert(stack);
	    TkTextUndoClearStack(stack);
	    if (stack->current) {
		FreeItems(stack, &stack->current->data);
	    }
	    ckfree(stack);
	    *stackPtr = NULL;
	}
    }
}


const TkTextUndoAtom *
TkTextUndoCurrentUndoAtom(
    const TkTextUndoStack stack)
{
    assert(stack);
    assert(stack->undoDepth == 0 || stack->last);

    if (stack->undoDepth > 0) {
	return &stack->last->data;
    }
    if (stack->doingUndo) {
	return NULL;
    }
    return stack->current ? &stack->current->data : NULL;
}


const TkTextUndoAtom *
TkTextUndoCurrentRedoAtom(
    const TkTextUndoStack stack)
{
    assert(stack);
    assert(stack->redoDepth == 0 || (stack->last ? stack->last->next : stack->root));

    if (stack->redoDepth > 0) {
	return &(stack->last ? stack->last->next : stack->root)->data;
    }
    if (stack->doingRedo) {
	return NULL;
    }
    return stack->current ? &stack->current->data : NULL;
}


int
TkTextUndoResetStack(
    TkTextUndoStack stack)
{
    return stack ? ResetStack(stack, false) : TCL_ERROR;
}


int
TkTextUndoClearStack(
    TkTextUndoStack stack)
{
    return stack ? ResetStack(stack, stack->undoDepth > 0) : TCL_ERROR;
}


int
TkTextUndoClearUndoStack(
    TkTextUndoStack stack)
{
    if (!stack) {
	return TCL_OK;
    }

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    if (stack->undoDepth > 0) {
	TkTextUndoMyAtom *atom;

	assert(stack->last);
	stack->undoDepth = 0;
	stack->undoSize = 0;
	atom = stack->root;
	stack->root = stack->last->next;
	stack->last = NULL;
	Release(stack, atom);
	ResetCurrent(stack, true);
	stack->irreversible = true;

	if (stack->contentChangedProc) {
	    stack->contentChangedProc(stack);
	}
    }

    return TCL_OK;
}


int
TkTextUndoClearRedoStack(
    TkTextUndoStack stack)
{
    if (!stack) {
	return TCL_OK;
    }

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    if (ClearRedoStack(stack) && stack->contentChangedProc) {
	stack->contentChangedProc(stack);
    }

    return TCL_OK;
}


int
TkTextUndoSetMaxStackDepth(
    TkTextUndoStack stack,
    unsigned maxUndoDepth,
    int maxRedoDepth)
{
    assert(stack);

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    if (maxUndoDepth > 0 || maxRedoDepth >= 0) {
	unsigned depth = stack->maxUndoDepth;

	if (depth == 0) {
	    depth = stack->undoDepth + stack->redoDepth;
	}

	if (maxUndoDepth < depth || (0 <= maxRedoDepth && maxRedoDepth < stack->maxRedoDepth)) {
	    unsigned deleteRedos = MIN(stack->redoDepth, depth - maxUndoDepth);
	    MyUndoAtom *atom = stack->root;

	    if (0 <= maxRedoDepth && maxRedoDepth < stack->maxRedoDepth) {
		deleteRedos = MIN(stack->redoDepth,
			MAX(deleteRedos, stack->maxRedoDepth - maxRedoDepth));
	    }

	    stack->redoDepth -= deleteRedos;
	    depth = maxUndoDepth - deleteRedos;

	    /*
	     * We have to reduce the stack size until the depth will not
	     * exceed the given limit. Start with the oldest redoes, and
	     * continue with the oldest undos if necessary.
	     */

	    for ( ; deleteRedos > 0; --deleteRedos) {
		atom = atom->prev;
		stack->redoSize -= atom->data.size;
	    }

	    if (0 < maxUndoDepth && stack->undoDepth > depth) {
		MyUndoAtom *root = stack->root;
		unsigned deleteUndos = stack->undoDepth - depth;

		stack->undoDepth -= deleteUndos;

		for ( ; deleteUndos > 0; --deleteUndos) {
		    stack->undoSize -= root->data.size;
		    root = root->next;
		}

		stack->root = root;

		/*
		 * We have to delete undos, so the content becomes irreversible.
		 */
		stack->irreversible = true;
	    }

	    Release(stack, atom);

	    if (stack->contentChangedProc) {
		stack->contentChangedProc(stack);
	    }
	}
    }

    stack->maxUndoDepth = maxUndoDepth;
    stack->maxRedoDepth = MAX(maxRedoDepth, -1);
    return TCL_OK;
}


int
TkTextUndoSetMaxStackSize(
    TkTextUndoStack stack,
    unsigned maxSize,
    bool applyImmediately)
{
    assert(stack);

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    if (applyImmediately
	    && 0 < maxSize
	    && maxSize < stack->undoSize + stack->redoSize) {
	unsigned size = stack->undoSize + stack->redoSize;
	MyUndoAtom *atom = stack->root;
	unsigned depth = stack->redoDepth;

	/*
	 * We have to reduce the stack size until the size will not exceed
	 * the given limit. Start with the oldest redoes, and continue with
	 * the oldest undoes if necessary.
	 */

	while (depth > 0 && maxSize < size) {
	    atom = atom->prev;
	    stack->redoSize -= atom->data.size;
	    depth -= 1;
	    size -= atom->data.size;
	}

	if (atom != stack->root || atom->data.size > 0) {
	    while (atom->data.size == 0 && atom != stack->root) {
		atom = atom->next;
		depth += 1;
	    }

	    if (depth < stack->redoDepth) {
		stack->redoDepth = depth;
		Release(stack, atom);
	    }
	}

	if (maxSize < size) {
	    MyUndoAtom *root = stack->root;

	    depth = stack->undoDepth;

	    while (depth > 0 && maxSize < size) {
		size -= root->data.size;
		stack->undoSize -= root->data.size;
		depth -= 1;
		root = root->next;
	    }

	    if (depth == 0) {
		while (depth < stack->redoDepth && root->next->prev == 0) {
		    root = root->prev;
		    depth += 1;
		}
	    }

	    if (depth < stack->undoDepth) {
		stack->undoDepth = depth;
		atom = stack->root;
		stack->root = root;
		/*
		 * We have to delete undoes, so the content becomes irreversible.
		 */
		stack->irreversible = true;
		Release(stack, atom);
	    }
	}

	if (stack->contentChangedProc) {
	    stack->contentChangedProc(stack);
	}
    }

    stack->maxSize = maxSize;
    return TCL_OK;
}


int
TkTextUndoPushItem(
    TkTextUndoStack stack,
    TkTextUndoItem item,
    unsigned size)
{
    MyUndoAtom *atom;
    TkTextUndoSubAtom *subAtom;

    assert(stack);
    assert(item);

    if (stack->doingUndo && TkTextUndoRedoStackIsFull(stack)) {
	if (stack->freeProc) {
	    stack->freeProc(stack, item);
	}
	return TCL_ERROR;
    }

    atom = stack->current;

    if (!atom) {
	ResetCurrent(stack, true);
	atom = stack->current;
    } else if (atom->data.arraySize == atom->capacity) {
	atom->capacity *= 2;
	atom = stack->current = ckrealloc(atom, ATOM_SIZE(atom->capacity));
    }

    subAtom = ((TkTextUndoSubAtom *) atom->data.array) + atom->data.arraySize++;
    subAtom->item = item;
    subAtom->size = size;
    subAtom->redo = stack->doingUndo;
    atom->data.size += size;
    atom->data.redo = stack->doingUndo;

    if (stack->contentChangedProc && !stack->doingUndo && !stack->doingRedo) {
	stack->contentChangedProc(stack);
    }

    return TCL_OK;
}


int
TkTextUndoPushRedoItem(
    TkTextUndoStack stack,
    TkTextUndoItem item,
    unsigned size)
{
    int rc;

    assert(stack);
    assert(!TkTextUndoIsPerformingUndoRedo(stack));

    TkTextUndoPushSeparator(stack);
    stack->doingUndo = true;
    rc = TkTextUndoPushItem(stack, item, size);
    stack->doingUndo = false;

    return rc;
}


void
TkTextUndoPushSeparator(
    TkTextUndoStack stack)
{
    assert(stack);

    /*
     * When performing an undo/redo, exact one reverting undo/redo atom has
     * to be inserted, not more. So we do not allow the push of separators
     * as long as an undo/redo action is in progress.
     */

    if (!stack->doingUndo && !stack->doingRedo) {
	/*
	 * Do not trigger stack->contentChangedProc here, because this has been
	 * already done via TkTextUndoPushItem/TkTextUndoPushRedoItem.
	 */
	InsertCurrentAtom(stack);
    }
}


int
TkTextUndoDoUndo(
    TkTextUndoStack stack)
{
    int rc;

    assert(stack);

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    InsertCurrentAtom(stack);

    if (stack->undoDepth == 0) {
	rc = TCL_ERROR;
    } else {
	assert(stack->last);

	stack->actual = stack->last;
	stack->doingUndo = true;
	stack->undoDepth -= 1;
	stack->undoSize -= stack->actual->data.size;
	stack->undoProc(stack, &stack->actual->data);
	FreeItems(stack, &stack->actual->data);
	stack->actual = NULL;
	stack->last = stack->undoDepth ? stack->last->prev : NULL;

	if (!stack->current || stack->current->data.arraySize == 0) {
	    /*
	     * We didn't receive reverting items while performing an undo.
	     * So all redo items are expired, we have to delete them.
	     */
	    stack->redoDepth = 0;
	    stack->redoSize = 0;
	    Release(stack, stack->last ? stack->last->next : stack->root);
	} else {
	    InsertCurrentAtom(stack);
	}

	stack->doingUndo = false;
	rc = TCL_OK;

	if (stack->contentChangedProc) {
	    stack->contentChangedProc(stack);
	}
    }
    return rc;
}


int
TkTextUndoDoRedo(
    TkTextUndoStack stack)
{
    int rc;

    assert(stack);

    if (stack->doingUndo || stack->doingRedo) {
	return TCL_ERROR;
    }

    InsertCurrentAtom(stack);

    if (stack->redoDepth == 0) {
	rc = TCL_ERROR;
    } else {
	MyUndoAtom *atom;

	stack->actual = atom = stack->last ? stack->last->next : stack->root;
	stack->doingRedo = true;
	stack->redoDepth -= 1;
	stack->redoSize -= stack->actual->data.size;
	stack->undoProc(stack, &stack->actual->data);
	FreeItems(stack, &stack->actual->data);
	stack->last = stack->actual;
	stack->actual = NULL;

	if (!stack->current || stack->current->data.arraySize == 0) {
	    /*
	     * Oops, we did not receive reverting items while performing a redo.
	     * So we cannot apply the preceding undoes, we have to remove them.
	     * Now the content will become irreversible.
	     */
	    if (stack->undoDepth > 0) {
		stack->undoDepth = 0;
		stack->undoSize = 0;
		atom = stack->root;
		stack->root = stack->last->next;
		stack->last = NULL;
	    } else {
		stack->root = atom->next;
	    }
	    Release(stack, atom);
	    stack->irreversible = true;
	} else {
	    InsertCurrentAtom(stack);
	}

	stack->doingRedo = false;
	rc = TCL_OK;

	if (stack->contentChangedProc) {
	    stack->contentChangedProc(stack);
	}
    }

    return rc;
}

bool
TkTextUndoStackIsFull(
    const TkTextUndoStack stack)
{
    if (!stack) {
	return true;
    }
    if (stack->doingUndo) {
	return stack->maxRedoDepth >= 0 && stack->redoDepth >= stack->maxRedoDepth;
    }
    return stack->maxUndoDepth > 0 && stack->undoDepth >= stack->maxUndoDepth;
}


const TkTextUndoAtom *
TkTextUndoFirstUndoAtom(
    TkTextUndoStack stack)
{
    assert(stack);
    
    if (stack->undoDepth > 0 && stack->last != stack->actual) {
	return &(stack->iter = stack->last)->data;
    }

    stack->iter = NULL;

    if (stack->current && stack->current->data.arraySize && !stack->doingUndo) {
	return &stack->current->data;
    }

    return NULL;
}


const TkTextUndoAtom *
TkTextUndoNextUndoAtom(
    TkTextUndoStack stack)
{
    assert(stack);
    
    if (stack->iter) {
	if (stack->iter != stack->root && (stack->iter = stack->iter->prev) != stack->actual) {
	    return &stack->iter->data;
	}

	stack->iter = NULL;

	if (stack->current && stack->current->data.arraySize && !stack->doingUndo) {
	    return &stack->current->data;
	}
    }

    return NULL;
}


const TkTextUndoAtom *
TkTextUndoFirstRedoAtom(
    TkTextUndoStack stack)
{
    assert(stack);
    
    if (stack->redoDepth > 0 && stack->root->prev != stack->actual) {
	return &(stack->iter = stack->root->prev)->data;
    }

    stack->iter = NULL;

    if (stack->current && stack->current->data.arraySize && stack->doingUndo) {
	return &stack->current->data;
    }

    return NULL;
}


const TkTextUndoAtom *
TkTextUndoNextRedoAtom(
    TkTextUndoStack stack)
{
    assert(stack);
    
    if (stack->iter) {
	if (stack->iter != stack->root
		&& (stack->iter = stack->iter->prev) != stack->last
		&& stack->iter != stack->actual) {
	    return &stack->iter->data;
	}

	stack->iter = NULL;

	if (stack->current && stack->current->data.arraySize && stack->doingUndo) {
	    return &stack->current->data;
	}
    }

    return NULL;
}


/* We need external linkage for our inline functions. */
#define IMPLEMENTATION
#include "tkTextUndoPriv.h"

/* vi:set ts=8 sw=4: */
