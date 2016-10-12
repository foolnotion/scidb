/*
 * tkTextMark.c --
 *
 *	This file contains the functions that implement marks for text
 *	widgets.
 *
 * Copyright (c) 1994 The Regents of the University of California.
 * Copyright (c) 1994-1997 Sun Microsystems, Inc.
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tkInt.h"
#include "tkText.h"
#include "tk3d.h"
#include <assert.h>

#ifndef MAX
# define MAX(a,b) ((a) < (b) ? b : a)
#endif
#ifndef MIN
# define MIN(a,b) ((a) < (b) ? a : b)
#endif

#if NDEBUG
# define DEBUG(expr)
#else
# define DEBUG(expr) expr
#endif

/*
 * Forward references for functions defined in this file:
 */

static void		InsertUndisplayProc(TkText *textPtr, TkTextDispChunk *chunkPtr);
static bool		MarkDeleteProc(TkTextBTree tree, TkTextSegment *segPtr, int flags);
static Tcl_Obj *	MarkInspectProc(const TkSharedText *textPtr, const TkTextSegment *segPtr);
static void		MarkRestoreProc(TkTextSegment *segPtr);
static void		MarkCheckProc(const TkSharedText *sharedTextPtr, const TkTextSegment *segPtr);
static int		MarkLayoutProc(const TkTextIndex *indexPtr,
			    TkTextSegment *segPtr, int offset, int maxX,
			    int maxChars, bool noCharsYet, TkWrapMode wrapMode,
			    TkTextDispChunk *chunkPtr);
static int		MarkFindNext(Tcl_Interp *interp, TkText *textPtr, const char *markName,
			    bool forward);
static void		ChangeGravity(TkSharedText *sharedTextPtr, TkText *textPtr,
			    TkTextSegment *markPtr, const Tk_SegType *newTypePtr,
			    TkTextUndoInfo *redoInfo);
static struct TkTextSegment *SetMark(struct TkText *textPtr, const char *name,
			    const Tk_SegType *typePtr, struct TkTextIndex *indexPtr);
static void		UnsetMark(TkSharedText *sharedTextPtr, TkTextSegment *markPtr,
			    TkTextUndoInfo *redoInfo);

static const TkTextDispChunkProcs layoutInsertProcs = {
    TEXT_DISP_CURSOR,		/* type */
    TkTextInsertDisplayProc,	/* displayProc */
    InsertUndisplayProc,	/* undisplayProc */
    NULL,	                /* measureProc */
    NULL,		        /* bboxProc */
};
/*
 * We need some private undo/redo stuff.
 */

static void UndoToggleGravityPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void UndoSetMarkPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void RedoSetMarkPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void UndoMoveMarkPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void UndoToggleGravityDestroy(TkSharedText *, TkTextUndoToken *);
static void UndoSetMarkDestroy(TkSharedText *, TkTextUndoToken *);
static void RedoSetMarkDestroy(TkSharedText *, TkTextUndoToken *);
static void UndoMoveMarkDestroy(TkSharedText *, TkTextUndoToken *);
static void UndoMarkGetRange(TkSharedText *, const TkTextUndoToken *,
	TkTextIndex *, TkTextIndex *);
static void RedoSetMarkGetRange(TkSharedText *, const TkTextUndoToken *,
	TkTextIndex *, TkTextIndex *);
static void RedoMoveMarkGetRange(TkSharedText *, const TkTextUndoToken *,
	TkTextIndex *, TkTextIndex *);
static Tcl_Obj *UndoToggleGravityGetCommand(const TkSharedText *, const TkTextUndoToken *);
static Tcl_Obj *UndoSetMarkGetCommand(const TkSharedText *, const TkTextUndoToken *);
static Tcl_Obj *UndoToggleGravityInspect(const TkSharedText *, const TkTextUndoToken *);
static Tcl_Obj *UndoSetMarkInspect(const TkSharedText *, const TkTextUndoToken *);

static const Tk_UndoType undoTokenToggleGravityType = {
    TK_TEXT_UNDO_MARK_GRAVITY,	/* action */
    UndoToggleGravityGetCommand,/* commandProc */
    UndoToggleGravityPerform,	/* undoProc */
    UndoToggleGravityDestroy,	/* destroyProc */
    UndoMarkGetRange,		/* rangeProc */
    UndoToggleGravityInspect	/* inspectProc */
};

static const Tk_UndoType redoTokenToggleGravityType = {
    TK_TEXT_REDO_MARK_GRAVITY,	/* action */
    UndoToggleGravityGetCommand,/* commandProc */
    UndoToggleGravityPerform,	/* undoProc */
    UndoToggleGravityDestroy,	/* destroyProc */
    UndoMarkGetRange,		/* rangeProc */
    UndoToggleGravityInspect	/* inspectProc */
};

static const Tk_UndoType undoTokenSetMarkType = {
    TK_TEXT_UNDO_MARK_SET,	/* action */
    UndoSetMarkGetCommand,	/* commandProc */
    UndoSetMarkPerform,		/* undoProc */
    UndoSetMarkDestroy,		/* destroyProc */
    UndoMarkGetRange,		/* rangeProc */
    UndoSetMarkInspect		/* inspectProc */
};

static const Tk_UndoType redoTokenSetMarkType = {
    TK_TEXT_REDO_MARK_SET,	/* action */
    UndoSetMarkGetCommand,	/* commandProc */
    RedoSetMarkPerform,		/* undoProc */
    RedoSetMarkDestroy,		/* destroyProc */
    RedoSetMarkGetRange,	/* rangeProc */
    UndoSetMarkInspect		/* inspectProc */
};

static const Tk_UndoType undoTokenMoveMarkType = {
    TK_TEXT_UNDO_MARK_MOVE,	/* action */
    UndoSetMarkGetCommand,	/* commandProc */
    UndoMoveMarkPerform,	/* undoProc */
    UndoMoveMarkDestroy,	/* destroyProc */
    RedoMoveMarkGetRange,	/* rangeProc */
    UndoSetMarkInspect		/* inspectProc */
};

static const Tk_UndoType redoTokenMoveMarkType = {
    TK_TEXT_REDO_MARK_MOVE,	/* action */
    UndoSetMarkGetCommand,	/* commandProc */
    UndoMoveMarkPerform,	/* undoProc */
    UndoMoveMarkDestroy,	/* destroyProc */
    RedoMoveMarkGetRange,	/* rangeProc */
    UndoSetMarkInspect		/* inspectProc */
};

typedef struct UndoTokenToggleMark {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
} UndoTokenToggleMark;

typedef struct UndoTokenToggleIndex {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
} UndoTokenToggleIndex;

/* derivation of UndoTokenToggleMark */
typedef struct UndoTokenToggleGravity {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
} UndoTokenToggleGravity;

/* derivation of UndoTokenToggleMark */
typedef struct UndoTokenSetMark {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
} UndoTokenSetMark;

/* derivation of UndoTokenSetMark */
typedef struct RedoTokenSetMark {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
    TkTextUndoIndex index;
} RedoTokenSetMark;

/* derivation of UndoTokenSetMark */
typedef struct UndoTokenMoveMark {
    const Tk_UndoType *undoType;
    TkTextSegment *markPtr;
    TkTextUndoIndex index;
} UndoTokenMoveMark;

/*
 * The following structures declare the "mark" segment types. There are
 * actually two types for marks, one with left gravity and one with right
 * gravity. They are identical except for their gravity property.
 */

const Tk_SegType tkTextRightMarkType = {
    "mark",		/* name */
    SEG_GROUP_MARK,	/* group */
    GRAVITY_RIGHT,	/* gravity */
    MarkDeleteProc,	/* deleteProc */
    MarkRestoreProc,	/* restoreProc */
    MarkLayoutProc,	/* layoutProc */
    MarkCheckProc,	/* checkProc */
    MarkInspectProc	/* inspectProc */
};

const Tk_SegType tkTextLeftMarkType = {
    "mark",		/* name */
    SEG_GROUP_MARK,	/* group */
    GRAVITY_LEFT,	/* gravity */
    MarkDeleteProc,	/* deleteProc */
    MarkRestoreProc,	/* restoreProc */
    MarkLayoutProc,	/* layoutProc */
    MarkCheckProc,	/* checkProc */
    MarkInspectProc	/* inspectProc */
};

/*
 * Pointer to int, for some portable pointer hacks - it's guaranteed that
 * 'uintptr_t' and 'void *' are convertible in both directions (C99 7.18.1.4).
 */

typedef union {
    void *ptr;
    uintptr_t flag;
} __ptr_to_int;

#define MARK_POINTER(ptr)	(((__ptr_to_int *) &ptr)->flag |= (uintptr_t) 1)
#define UNMARK_POINTER(ptr)	(((__ptr_to_int *) &ptr)->flag &= ~(uintptr_t) 1)
#define POINTER_IS_MARKED(ptr)	(((__ptr_to_int *) &ptr)->flag & (uintptr_t) 1)

#define IS_PRESERVED(ptr)	POINTER_IS_MARKED(ptr)
#define MAKE_PRESERVED(ptr)	MARK_POINTER(ptr)
#define MAKE_UNPRESERVED(ptr)	UNMARK_POINTER(ptr)

#define GET_POINTER(ptr)	((void *) (((__ptr_to_int *) &ptr)->flag & ~(uintptr_t) 1))

#define NAME(ptr)		((char *) GET_POINTER(ptr))
#define HPTR(ptr)		((Tcl_HashEntry *) ptr)
#define PTR_TO_INT(ptr)		((uintptr_t) ptr)

#if !NDEBUG

# undef HPTR
# undef NAME

Tcl_HashEntry *HPTR(uintptr_t ptr)
{ assert(!IS_PRESERVED(ptr)); return (Tcl_HashEntry *) ptr; }

char *NAME(uintptr_t ptr)
{ assert(IS_PRESERVED(ptr)); return (char *) GET_POINTER(ptr); }

#endif /* !NDEBUG */

DEBUG_ALLOC(extern unsigned tkTextCountNewSegment);
DEBUG_ALLOC(extern unsigned tkTextCountDestroySegment);
DEBUG_ALLOC(extern unsigned tkTextCountNewUndoToken);
DEBUG_ALLOC(extern unsigned tkTextCountDestroyUndoToken);

/*
 * Some functions for the undo/redo mechanism.
 */

Tcl_Obj *
AppendName(
    Tcl_Obj *objPtr,
    const TkTextSegment *markPtr)
{
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj(NAME(markPtr->body.mark.ptr), -1));
    return objPtr;
}

static Tcl_Obj *
UndoToggleGravityGetCommand(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    Tcl_Obj *objPtr = Tcl_NewListObj(0, NULL);
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj("mark", -1));
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj("gravity", -1));
    return objPtr;
}

static Tcl_Obj *
UndoToggleGravityInspect(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    const UndoTokenToggleGravity *token = (const UndoTokenToggleGravity *) item;
    return AppendName(UndoToggleGravityGetCommand(sharedTextPtr, item), token->markPtr);
}

static void
UndoToggleGravityPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    UndoTokenToggleGravity *token = (UndoTokenToggleGravity *) undoInfo->token;
    const Tk_SegType *newTypePtr;
    const Tk_SegType *oldTypePtr;

    oldTypePtr = token->markPtr->typePtr;
    newTypePtr = (oldTypePtr == &tkTextRightMarkType) ? &tkTextLeftMarkType : &tkTextRightMarkType;

    assert(token->markPtr->body.mark.changePtr);
    token->markPtr->body.mark.changePtr->toggleGravity = NULL;
    ChangeGravity(sharedTextPtr, NULL, token->markPtr, newTypePtr, NULL);

    if (redoInfo) {
	redoInfo->token = undoInfo->token;
	redoInfo->token->undoType = isRedo ? &undoTokenToggleGravityType : &redoTokenToggleGravityType;
    }
}

static void
UndoToggleGravityDestroy(
    TkSharedText *sharedTextPtr,
    TkTextUndoToken *item)
{
    UndoTokenToggleGravity *token = (UndoTokenToggleGravity *) item;

    assert(token->markPtr->body.mark.changePtr);
    assert(token->markPtr->body.mark.changePtr->toggleGravity);
    assert(token->markPtr->refCount > 1);

    ckfree(token->markPtr->body.mark.changePtr->toggleGravity);
    token->markPtr->body.mark.changePtr->toggleGravity = NULL;
    token->markPtr->refCount -= 1;
    DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
    sharedTextPtr->markUndoTokenCount -= 1;
    if (token->markPtr->refCount == 1) {
	MarkDeleteProc(sharedTextPtr->tree, token->markPtr, DELETE_MARKS);
    }
}

static void
UndoMoveMarkPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    UndoTokenMoveMark *token = (UndoTokenMoveMark *) undoInfo->token;
    TkTextUndoIndex index = token->index;

    assert(token->markPtr->body.mark.changePtr);
    token->markPtr->body.mark.changePtr->moveMark = NULL;

    if (redoInfo) {
	TkBTreeMakeUndoIndex(sharedTextPtr, token->markPtr, &index);
	token->index = index;
	redoInfo->token = undoInfo->token;
	redoInfo->token->undoType = isRedo ? &undoTokenMoveMarkType : &redoTokenMoveMarkType;
    }

    TkBTreeUnlinkSegment(sharedTextPtr, token->markPtr);
    TkBTreeReInsertSegment(sharedTextPtr, &index, token->markPtr);
}

static void
UndoMoveMarkDestroy(
    TkSharedText *sharedTextPtr,
    TkTextUndoToken *item)
{
    UndoTokenMoveMark *token = (UndoTokenMoveMark *) item;

    assert(token->markPtr->body.mark.changePtr);
    assert(token->markPtr->body.mark.changePtr->moveMark);
    assert(token->markPtr->refCount > 1);

    ckfree(token->markPtr->body.mark.changePtr->moveMark);
    token->markPtr->body.mark.changePtr->moveMark = NULL;
    DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
    sharedTextPtr->markUndoTokenCount -= 1;
    if (token->markPtr->refCount == 1) {
	MarkDeleteProc(sharedTextPtr->tree, token->markPtr, DELETE_MARKS);
    }
}

static Tcl_Obj *
UndoSetMarkGetCommand(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    Tcl_Obj *objPtr = Tcl_NewListObj(0, NULL);
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj("mark", -1));
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj("set", -1));
    return objPtr;
}

static Tcl_Obj *
UndoSetMarkInspect(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    const UndoTokenSetMark *token = (const UndoTokenSetMark *) item;
    return AppendName(UndoSetMarkGetCommand(sharedTextPtr, item), token->markPtr);
}

static void
UndoSetMarkPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    const UndoTokenSetMark *token = (const UndoTokenSetMark *) undoInfo->token;

    assert(token->markPtr->body.mark.changePtr);
    token->markPtr->body.mark.changePtr->setMark = NULL;
    UnsetMark(sharedTextPtr, token->markPtr, redoInfo);
}

static void
UndoSetMarkDestroy(
    TkSharedText *sharedTextPtr,
    TkTextUndoToken *item)
{
    UndoTokenSetMark *token = (UndoTokenSetMark *) item;

    assert(token->markPtr->body.mark.changePtr);
    assert(token->markPtr->body.mark.changePtr->setMark);
    assert(token->markPtr->refCount > 1);

    ckfree(token->markPtr->body.mark.changePtr->setMark);
    token->markPtr->body.mark.changePtr->setMark = NULL;
    sharedTextPtr->markUndoTokenCount -= 1;
    if (token->markPtr->refCount == 1) {
	MarkDeleteProc(sharedTextPtr->tree, token->markPtr, DELETE_MARKS);
    }
}

static void
RedoSetMarkPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    RedoTokenSetMark *token = (RedoTokenSetMark *) undoInfo->token;

    assert(TkTextIsNormalMark(token->markPtr));

    TkBTreeReInsertSegment(sharedTextPtr, &token->index, token->markPtr);

    if (redoInfo) {
	UndoTokenSetMark *redoToken;

	redoToken = ckalloc(sizeof(UndoTokenSetMark));
	redoToken->markPtr = token->markPtr;
	redoToken->undoType = &undoTokenSetMarkType;
	redoInfo->token = (TkTextUndoToken *) redoToken;
	DEBUG_ALLOC(tkTextCountNewUndoToken++);
    }
}

static void
RedoSetMarkDestroy(
    TkSharedText *sharedTextPtr,
    TkTextUndoToken *item)
{
    RedoTokenSetMark *token = (RedoTokenSetMark *) item;

    assert(token->markPtr->body.mark.changePtr);
    assert(token->markPtr->body.mark.changePtr->setMark);
    assert(token->markPtr->refCount > 1);

    ckfree(token->markPtr->body.mark.changePtr->setMark);
    token->markPtr->body.mark.changePtr->setMark = NULL;
    sharedTextPtr->markUndoTokenCount -= 1;
    if (token->markPtr->refCount == 1) {
	MarkDeleteProc(sharedTextPtr->tree, token->markPtr, DELETE_MARKS);
    }
}

static void
UndoMarkGetRange(
    TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item,
    TkTextIndex *startIndex,
    TkTextIndex *endIndex)
{
    UndoTokenToggleMark *token = (UndoTokenToggleMark *) item;
    TkTextIndexClear2(startIndex, NULL, sharedTextPtr->tree);
    TkTextIndexSetSegment(startIndex, token->markPtr);
    *endIndex = *startIndex;
}

static void
RedoSetMarkGetRange(
    TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item,
    TkTextIndex *startIndex,
    TkTextIndex *endIndex)
{
    RedoTokenSetMark *token = (RedoTokenSetMark *) item;
    TkBTreeUndoIndexToIndex(sharedTextPtr, &token->index, startIndex);
    *endIndex = *startIndex;
}

static void
RedoMoveMarkGetRange(
    TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item,
    TkTextIndex *startIndex,
    TkTextIndex *endIndex)
{
    UndoTokenMoveMark *token = (UndoTokenMoveMark *) item;
    TkBTreeUndoIndexToIndex(sharedTextPtr, &token->index, startIndex);
    TkTextIndexClear2(endIndex, NULL, sharedTextPtr->tree);
    TkTextIndexSetSegment(endIndex, token->markPtr);
}

/*
 *--------------------------------------------------------------
 *
 * TkTextMarkCmd --
 *
 *	This function is invoked to process the "mark" options of the widget
 *	command for text widgets. See the user documentation for details on
 *	what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

static int
SetResultNoMarkNamed(Tcl_Interp *interp, const char* name) {
    Tcl_SetObjResult(interp, Tcl_ObjPrintf("there is no mark named \"%s\"", name));
    Tcl_SetErrorCode(interp, "TK", "LOOKUP", "TEXT_MARK", name, NULL);
    return TCL_ERROR;
}

int
TkTextMarkCmd(
    TkText *textPtr,		/* Information about text widget. */
    Tcl_Interp *interp,		/* Current interpreter. */
    int objc,			/* Number of arguments. */
    Tcl_Obj *const objv[])	/* Argument objects. Someone else has already parsed this command
    				 * enough to know that objv[1] is "mark". */
{
    Tcl_HashEntry *hPtr;
    TkTextSegment *markPtr;
    Tcl_HashSearch search;
    TkTextIndex index;
    const Tk_SegType *newTypePtr;
    int optionIndex;
    static const char *const markOptionStrings[] = {
	"compare", "exists", "generate", "gravity", "names", "next", "previous",
	"set", "unset", NULL
    };
    enum markOptions {
	MARK_COMPARE, MARK_EXISTS, MARK_GENERATE, MARK_GRAVITY, MARK_NAMES, MARK_NEXT, MARK_PREVIOUS,
	MARK_SET, MARK_UNSET
    };

    if (objc < 3) {
	Tcl_WrongNumArgs(interp, 2, objv, "option ?arg arg ...?");
	return TCL_ERROR;
    }

    if (Tcl_GetIndexFromObjStruct(interp, objv[2], markOptionStrings,
	    sizeof(char *), "mark option", 0, &optionIndex) != TCL_OK) {
	return TCL_ERROR;
    }

    switch ((enum markOptions) optionIndex) {
    case MARK_COMPARE: {
	TkTextSegment *markPtr1, *markPtr2;
	int relation, value;

	if (objc != 5) {
	    Tcl_WrongNumArgs(interp, 2, objv, "markName1 op markName2");
	    return TCL_ERROR;
	}
	if (!(markPtr1 = TkTextFindMark(textPtr, Tcl_GetString(objv[2])))) {
	    Tcl_SetObjResult(interp, Tcl_ObjPrintf("bad comparison operand \"%s\": "
		    "must be an existing mark", Tcl_GetString(objv[2])));
	    Tcl_SetErrorCode(interp, "TK", "VALUE", "MARK_COMPARISON", NULL);
	    return TCL_ERROR;
	}
	if (!(markPtr2 = TkTextFindMark(textPtr, Tcl_GetString(objv[4])))) {
	    Tcl_SetObjResult(interp, Tcl_ObjPrintf("bad comparison operand \"%s\": "
		    "must be an existing mark", Tcl_GetString(objv[4])));
	    Tcl_SetErrorCode(interp, "TK", "VALUE", "MARK_COMPARISON", NULL);
	    return TCL_ERROR;
	}

	if (markPtr1 == markPtr2) {
	    relation = 0;
	} else {
	    TkTextIndex index1, index2;

	    TkTextIndexClear(&index1, textPtr);
	    TkTextIndexClear(&index2, textPtr);
	    TkTextIndexSetSegment(&index1, markPtr1);
	    TkTextIndexSetSegment(&index2, markPtr2);
	    relation = TkTextIndexCompare(&index1, &index2);

	    if (relation == 0) {
		TkTextSegment *segPtr = markPtr1->nextPtr;

		while (segPtr && segPtr != markPtr2 && segPtr->size == 0) {
		    segPtr = segPtr->nextPtr;
		}
		relation = (segPtr == markPtr2) ? -1 : +1;
	    }
	}

	value = TkTextTestRelation(interp, relation, Tcl_GetString(objv[3]));
	if (value == -1) {
	    return TCL_ERROR;
	}
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(value));
	break;
    }
    case MARK_EXISTS: {
	if (objc != 4) {
	    Tcl_WrongNumArgs(interp, 3, objv, "markName");
	    return TCL_ERROR;
	}
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(!!TkTextFindMark(textPtr, Tcl_GetString(objv[3]))));
	break;
    }
    case MARK_GENERATE: {
	TkTextSegment *markPtr;
	TkTextIndex index;
	char uniqName[100];

	TkTextIndexClear(&index, textPtr);
	TkTextIndexSetSegment(&index, textPtr->startMarker);
	snprintf(uniqName, sizeof(uniqName), "##ID##%p##%p##%08u##", textPtr,
		textPtr->sharedTextPtr, ++textPtr->uniqueIdCounter);
	assert(!TkTextFindMark(textPtr, uniqName));
    	markPtr = TkTextMakeMark(textPtr, uniqName);
    	markPtr->privateMarkFlag = true;
	textPtr->sharedTextPtr->numMarks -= 1; /* take back counting */
	textPtr->sharedTextPtr->numPrivateMarks += 1;
	TkBTreeLinkSegment(textPtr->sharedTextPtr, markPtr, &index);
	Tcl_SetObjResult(textPtr->interp, Tcl_NewStringObj(uniqName, -1));
	break;
    }
    case MARK_GRAVITY: {
	int length;
	const char *str;

	if (objc < 4 || objc > 5) {
	    Tcl_WrongNumArgs(interp, 3, objv, "markName ?gravity?");
	    return TCL_ERROR;
	}
	str = Tcl_GetStringFromObj(objv[3], &length);
	if (strcmp(str, "insert") == 0) {
	    markPtr = textPtr->insertMarkPtr;
	} else if (strcmp(str, "current") == 0) {
	    markPtr = textPtr->currentMarkPtr;
	} else {
	    if (!(hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->markTable, str))) {
		return SetResultNoMarkNamed(interp, Tcl_GetString(objv[3]));
	    }
	    markPtr = Tcl_GetHashValue(hPtr);
	}
	if (objc == 4) {
	    const char *typeStr;
	    typeStr = markPtr->typePtr == &tkTextRightMarkType ? "right" : "left";
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(typeStr, -1));
	    return TCL_OK;
	}
	str = Tcl_GetStringFromObj(objv[4],&length);
	if (strncmp(str, "left", length) == 0) {
	    newTypePtr = &tkTextLeftMarkType;
	} else if (strncmp(str, "right", length) == 0) {
	    newTypePtr = &tkTextRightMarkType;
	} else {
	    Tcl_SetObjResult(interp, Tcl_ObjPrintf(
		    "bad mark gravity \"%s\": must be left or right", str));
	    Tcl_SetErrorCode(interp, "TK", "VALUE", "MARK_GRAVITY", NULL);
	    return TCL_ERROR;
	}
	/*
	 * We have to force the re-insertion of the mark when steadyMarks is not enabled.
	 */
	if (markPtr->typePtr != newTypePtr || !textPtr->sharedTextPtr->steadyMarks) {
	    TkTextUndoInfo undoInfo;
	    TkTextUndoInfo *undoInfoPtr = NULL;

	    if (textPtr->sharedTextPtr->steadyMarks
		    && TkTextIsNormalMark(markPtr)
		    && !TkTextUndoUndoStackIsFull(textPtr->sharedTextPtr->undoStack)) {
		undoInfoPtr = &undoInfo;
	    }
	    ChangeGravity(textPtr->sharedTextPtr, textPtr, markPtr, newTypePtr, undoInfoPtr);
	}
	break;
    }
    case MARK_NAMES: {
	Tcl_Obj *resultObj;

	if (objc != 3) {
	    Tcl_WrongNumArgs(interp, 3, objv, NULL);
	    return TCL_ERROR;
	}

	resultObj = Tcl_NewObj();
	Tcl_ListObjAppendElement(NULL, resultObj, Tcl_NewStringObj("insert", -1));
	Tcl_ListObjAppendElement(NULL, resultObj, Tcl_NewStringObj("current", -1));

	for (hPtr = Tcl_FirstHashEntry(&textPtr->sharedTextPtr->markTable, &search);
		hPtr;
		hPtr = Tcl_NextHashEntry(&search)) {
	    TkTextSegment *markPtr = Tcl_GetHashValue(hPtr);

	    if (!markPtr->privateMarkFlag) {
		Tcl_ListObjAppendElement(NULL, resultObj, Tcl_NewStringObj(
			Tcl_GetHashKey(&textPtr->sharedTextPtr->markTable, hPtr), -1));
	    }
	}

	Tcl_SetObjResult(interp, resultObj);
	break;
    }
    case MARK_NEXT:
	if (objc != 4) {
	    Tcl_WrongNumArgs(interp, 3, objv, "index");
	    return TCL_ERROR;
	}
	return MarkFindNext(interp, textPtr, Tcl_GetString(objv[3]), true);
    case MARK_PREVIOUS:
	if (objc != 4) {
	    Tcl_WrongNumArgs(interp, 3, objv, "index");
	    return TCL_ERROR;
	}
	return MarkFindNext(interp, textPtr, Tcl_GetString(objv[3]), false);
    case MARK_SET: {
	const Tk_SegType *typePtr = NULL;
	char const *name;

	if (objc != 5 && objc != 6) {
	    Tcl_WrongNumArgs(interp, 3, objv, "markName index ?direction?");
	    return TCL_ERROR;
	}
	if (!TkTextGetIndexFromObj(interp, textPtr, objv[4], &index)) {
	    return TCL_ERROR;
	}
	if (objc == 6) {
	    const char *direction = Tcl_GetString(objv[5]);

	    if (strcmp(direction, "left") == 0) {
		typePtr = &tkTextLeftMarkType;
	    } else if (strcmp(direction, "right") == 0) {
		typePtr = &tkTextRightMarkType;
	    } else {
		Tcl_SetObjResult(interp, Tcl_ObjPrintf(
			"bad mark gravity \"%s\": must be left or right", direction));
		Tcl_SetErrorCode(interp, "TK", "VALUE", "MARK_GRAVITY", NULL);
		return TCL_ERROR;
	    }
	}

	name = Tcl_GetString(objv[3]);

	if (!SetMark(textPtr, name, typePtr, &index)) {
	    Tcl_Obj *msgPtr;

	    if (strcmp(name, "insert") == 0) {
		return TCL_OK; /* the "watch" command did destroy the widget */
	    }
	    msgPtr = Tcl_ObjPrintf("\"%s\" is an expired generated mark", name);
	    Tcl_SetObjResult(interp, msgPtr);
	    Tcl_SetErrorCode(interp, "TK", "SET", "TEXT_MARK", name, NULL);
	    return TCL_ERROR;
	}
	break;
    }
    case MARK_UNSET: {
	TkTextUndoInfo undoInfo;
	TkTextUndoInfo *undoInfoPtr = NULL;
	int i;

	if (textPtr->sharedTextPtr->steadyMarks
		&& !TkTextUndoUndoStackIsFull(textPtr->sharedTextPtr->undoStack)) {
	    undoInfoPtr = &undoInfo;
	}

	for (i = 3; i < objc; i++) {
	    if ((hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->markTable, Tcl_GetString(objv[i])))) {
		TkTextSegment *markPtr = Tcl_GetHashValue(hPtr);

		if (TkTextIsPrivateMark(markPtr)) {
		    UnsetMark(textPtr->sharedTextPtr, markPtr, NULL);
		} else if (!TkTextIsSpecialMark(markPtr)) {
		    UnsetMark(textPtr->sharedTextPtr, markPtr, undoInfoPtr);
		    if (undoInfoPtr && undoInfo.token) {
			TkTextPushUndoToken(textPtr->sharedTextPtr, undoInfo.token, 0);
		    }
		}
	    }
	}
	break;
    }
    }
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextPushMarkGravityUndo --
 *
 *	This function is pushing an undo item for toggle of gravity.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushUndoToken.
 *
 *----------------------------------------------------------------------
 */

void
TkTextPushMarkGravityUndo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr)
{
    UndoTokenToggleGravity *token;

    token = ckalloc(sizeof(UndoTokenToggleGravity));
    token->undoType = &undoTokenToggleGravityType;
    (token->markPtr = markPtr)->refCount += 1;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushUndoToken(sharedTextPtr, token, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextPushMarkGravityRedo --
 *
 *	This function is pushing a redo item for toggle of gravity.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushRedoToken.
 *
 *----------------------------------------------------------------------
 */

void
TkTextPushMarkGravityRedo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr)
{
    UndoTokenToggleGravity *token;

    token = ckalloc(sizeof(UndoTokenToggleGravity));
    token->undoType = &undoTokenToggleGravityType;
    (token->markPtr = markPtr)->refCount += 1;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushRedoToken(sharedTextPtr, token, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextPushMarkSetUndo --
 *
 *	This function is pushing an undo item for setting a mark.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushUndoToken.
 *
 *----------------------------------------------------------------------
 */

void
TkTextPushMarkSetUndo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr)
{
    UndoTokenSetMark *token;

    assert(markPtr->refCount == 1);

    token = ckalloc(sizeof(UndoTokenSetMark));
    token->undoType = &undoTokenSetMarkType;
    (token->markPtr = markPtr)->refCount += 1;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushUndoToken(sharedTextPtr, token, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextPushMarkSetRedo --
 *
 *	This function is pushing a redo item for setting a mark.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushRedoToken.
 *
 *----------------------------------------------------------------------
 */

void
TkTextPushMarkSetRedo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr,
    const TkTextIndex *indexPtr)
{
    RedoTokenSetMark *token;

    assert(markPtr->refCount == 1);

    token = ckalloc(sizeof(RedoTokenSetMark));
    token->undoType = &undoTokenSetMarkType;
    token->index.lineIndex = TkTextIndexGetLineNumber(indexPtr, NULL);
    token->index.u.byteIndex = TkTextIndexGetByteIndex(indexPtr);
    token->markPtr = markPtr;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushRedoToken(sharedTextPtr, token, 0);
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextFindMark --
 *
 *	Return mark segment of given name, if exisiting.
 *
 * Results:
 *	The mark with this name, or NULL if not existing.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

TkTextSegment *
TkTextFindMark(
    const TkText *textPtr,
    const char *name)
{
    Tcl_HashEntry *hPtr;

    assert(textPtr);
    assert(name);

    switch (name[0]) {
    case 'i':
	if (strcmp(name, "insert") == 0) {
	    return textPtr->insertMarkPtr;
	}
	break;
    case 'c':
	if (strcmp(name, "current") == 0) {
	    return textPtr->currentMarkPtr;
	}
	break;
    }
    hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->markTable, name);
    return hPtr ? Tcl_GetHashValue(hPtr) : NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextFreeMarks --
 *
 *	Free all used marks, also the hash table for marks will be
 *	destroyed. But do not free private marks if 'retainPrivateMarks'
 *	is true, in this case a new hash table will be built, only
 *	with the remaining private marks.
 *
 * Results:
 *	If 'retainPrivateMarks' is false, then return NULL. Otherwise
 *	the chain of retained private marks will be returned.
 *
 * Side effects:
 *	Free some memory, the old hash table for marks will be destroyed,
 *	and a new one will be created if 'retainPrivateMarks' is true.
 *
 *----------------------------------------------------------------------
 */

TkTextSegment *
TkTextFreeMarks(
    TkSharedText *sharedTextPtr,	/* Handle to shared text resource. */
    bool retainPrivateMarks)		/* Priate marks will be retained? */
{
    Tcl_HashSearch search;
    Tcl_HashEntry *hPtr = Tcl_FirstHashEntry(&sharedTextPtr->markTable, &search);
    TkTextSegment *chainPtr = NULL;

    for ( ; hPtr; hPtr = Tcl_NextHashEntry(&search)) {
	TkTextSegment *markPtr = Tcl_GetHashValue(hPtr);

	if (!retainPrivateMarks || !TkTextIsPrivateMark(markPtr)) {
	    MarkDeleteProc(sharedTextPtr->tree, markPtr, DELETE_CLEANUP);
	} else {
	    const char *name = Tcl_GetHashKey(&sharedTextPtr->markTable, hPtr);
	    char *dup;

	    MarkDeleteProc(sharedTextPtr->tree, markPtr, 0);
	    markPtr->nextPtr = NULL;
	    markPtr->prevPtr = NULL;
	    markPtr->sectionPtr = NULL;
	    markPtr->nextPtr = chainPtr;
	    dup = ckalloc(strlen(name) + 1);
	    markPtr->body.mark.ptr = PTR_TO_INT(strcpy(dup, name));
	    MAKE_PRESERVED(markPtr->body.mark.ptr);
	    chainPtr = markPtr;
	}
    }

    Tcl_DeleteHashTable(&sharedTextPtr->markTable);
    sharedTextPtr->numMarks = 0;

    if (retainPrivateMarks) {
	TkTextSegment *markPtr;

	Tcl_InitHashTable(&sharedTextPtr->markTable, TCL_STRING_KEYS);

	for (markPtr = chainPtr; markPtr; markPtr = markPtr->nextPtr) {
	    const char *name;
	    bool isNew;

	    name = NAME(markPtr->body.mark.ptr);
	    hPtr = Tcl_CreateHashEntry(&sharedTextPtr->markTable, name, (int *) &isNew);
	    ckfree(name);
	    Tcl_SetHashValue(hPtr, markPtr);
	    markPtr->body.mark.ptr = PTR_TO_INT(hPtr);
	}
    } else {
	sharedTextPtr->numPrivateMarks = 0;
    }

    return chainPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextUpdateCurrentMark --
 *
 *	If a position change of the "current" mark has been postponed
 *	we will do now the update.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The "current" mark will change the position.
 *
 *----------------------------------------------------------------------
 */

void
TkTextUpdateCurrentMark(
    TkSharedText *sharedTextPtr)	/* Shared text resource. */
{
    TkText *tPtr;

    assert(sharedTextPtr->haveToSetCurrentMark);

    sharedTextPtr->haveToSetCurrentMark = false;

    for (tPtr = sharedTextPtr->peers; tPtr; tPtr = tPtr->next) {
	if (tPtr->haveToSetCurrentMark) {
	    tPtr->haveToSetCurrentMark = false;
	    /* TODO: only link and unlink if a real position change has occured */
	    TkBTreeUnlinkSegment(sharedTextPtr, tPtr->currentMarkPtr);
	    TkBTreeLinkSegment(sharedTextPtr, tPtr->currentMarkPtr, &tPtr->currentMarkIndex);
	}
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextMakeStartEndMark --
 *
 *	Make (allocate) a new start/end mark.
 *
 * Results:
 *	The return value is a pointer to the new mark.
 *
 * Side effects:
 *	A new mark is created.
 *
 *----------------------------------------------------------------------
 */

TkTextSegment *
TkTextMakeStartEndMark(
    TkText *textPtr,		/* can be NULL */
    Tk_SegType const* typePtr)
{
    TkTextSegment *markPtr = TkTextMakeMark(NULL, NULL);

    assert(typePtr == &tkTextLeftMarkType || typePtr == &tkTextRightMarkType);

    markPtr->typePtr = typePtr;
    markPtr->startEndMarkFlag = true;
    markPtr->body.mark.textPtr = textPtr;
    return markPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextMakeMark --
 *
 *	Make (allocate) a new mark, the gravity default to right.
 *
 * Results:
 *	The return value is a pointer to the new mark.
 *
 * Side effects:
 *	A new mark is created.
 *
 *----------------------------------------------------------------------
 */

static TkTextSegment *
MakeMark(
    TkText *textPtr)		/* Text widget in which to create mark. */
{
    TkTextSegment *markPtr;

    markPtr = memset(ckalloc(SEG_SIZE(TkTextMark)), 0, SEG_SIZE(TkTextMark));
    markPtr->typePtr = &tkTextRightMarkType;
    markPtr->refCount = 1;
    markPtr->body.mark.textPtr = textPtr;
    DEBUG_ALLOC(tkTextCountNewSegment++);
    return markPtr;
}

TkTextSegment *
TkTextMakeMark(
    TkText *textPtr,		/* Text widget in which to create mark, can be NULL. */
    const char *name)		/* Name of this mark, can be NULL. */
{
    TkTextSegment *markPtr;
    Tcl_HashEntry *hPtr;
    bool isNew;

    assert(!name || textPtr);
    assert(!name || strcmp(name, "insert") != 0);
    assert(!name || strcmp(name, "current") != 0);

    if (!name) {
	markPtr = MakeMark(textPtr);
	markPtr->privateMarkFlag = true;
	return markPtr;
    }

    hPtr = Tcl_CreateHashEntry(&textPtr->sharedTextPtr->markTable, name, (int *) &isNew);

    if (isNew) {
	textPtr->sharedTextPtr->isVirgin = false;
	markPtr = MakeMark(textPtr);
	markPtr->body.mark.ptr = PTR_TO_INT(hPtr);
	Tcl_SetHashValue(hPtr, markPtr);
	textPtr->sharedTextPtr->numMarks += 1;
    } else {
	markPtr = Tcl_GetHashValue(hPtr);
    }

    return markPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextMakeNewMark --
 *
 *	Make (allocate) a new mark, the gravity default to right. This
 *	function will return NULL if the mark name already exists.
 *
 * Results:
 *	The return value is a pointer to the new mark, and will be NULL
 *	if the mark already exists.
 *
 * Side effects:
 *	A new mark is created.
 *
 *----------------------------------------------------------------------
 */

TkTextSegment *
TkTextMakeNewMark(
    TkText *textPtr,		/* Text widget in which to create mark. */
    const char *name)		/* Name of this mark. */
{
    TkTextSegment *markPtr;
    Tcl_HashEntry *hPtr;
    bool isNew;

    assert(textPtr);
    assert(name);

    hPtr = Tcl_CreateHashEntry(&textPtr->sharedTextPtr->markTable, name, (int *) &isNew);

    if (!isNew) {
	return NULL;
    }

    textPtr->sharedTextPtr->isVirgin = false;
    markPtr = MakeMark(textPtr);
    markPtr->body.mark.ptr = PTR_TO_INT(hPtr);
    Tcl_SetHashValue(hPtr, markPtr);
    textPtr->sharedTextPtr->numMarks += 1;

    return markPtr;
}

/*
 *----------------------------------------------------------------------
 *
 * ChangeGravity --
 *
 *	Change the gravity of a given mark.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Reset the type pointer of the mark, and set the undo information.
 *
 *----------------------------------------------------------------------
 */

static TkTextMarkChange *
MakeChangeItem(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr)
{
    TkTextMarkChange *changePtr = markPtr->body.mark.changePtr;

    assert(TkTextIsNormalMark(markPtr));

    if (!changePtr) {
	if (sharedTextPtr->undoMarkListCount == sharedTextPtr->undoMarkListSize) {
	    sharedTextPtr->undoMarkListSize = MAX(20, 2*sharedTextPtr->undoMarkListSize);
	    sharedTextPtr->undoMarkList = ckrealloc(sharedTextPtr->undoMarkList,
		    sharedTextPtr->undoMarkListSize*sizeof(sharedTextPtr->undoMarkList[0]));
	}
	changePtr = &sharedTextPtr->undoMarkList[sharedTextPtr->undoMarkListCount++];
	memset(changePtr, 0, sizeof(*changePtr));
	markPtr->body.mark.changePtr = changePtr;
	(changePtr->markPtr = markPtr)->refCount += 1;
    }

    return changePtr;
} 

static void
ChangeGravity(
    TkSharedText *sharedTextPtr,	/* Shared text resource. */
    TkText *textPtr,			/* The text widget, can be NULL. */
    TkTextSegment *markPtr,		/* Change toggle of this mark. */
    const Tk_SegType *newTypePtr,	/* This is the new toggle type. */
    TkTextUndoInfo *undoInfo)		/* Undo information, can be NULL */
{
    const Tk_SegType *oldTypePtr;
    bool keepOrder;

    assert(markPtr);
    assert(markPtr->typePtr->group == SEG_GROUP_MARK);
    assert(sharedTextPtr);
    assert(!undoInfo || TkTextIsNormalMark(markPtr));

    oldTypePtr = markPtr->typePtr;
    markPtr->typePtr = newTypePtr;
    keepOrder = sharedTextPtr->steadyMarks && (!textPtr || markPtr != textPtr->insertMarkPtr);

    if (!keepOrder) {
	/*
	 * We must re-insert the mark, the old rules of gravity may force
	 * a shuffle of the existing marks.
	 */

	TkTextIndex index;

	if (textPtr) {
	    TkTextIndexClear(&index, textPtr);
	} else {
	    TkTextIndexClear2(&index, NULL, sharedTextPtr->tree);
	}
	TkTextIndexSetSegment(&index, markPtr);
	TkTextIndexToByteIndex(&index);
	TkBTreeUnlinkSegment(sharedTextPtr, markPtr);
	TkBTreeLinkSegment(sharedTextPtr, markPtr, &index);
    }

    /* TODO: we cannot amalgamate in any case */
    if (undoInfo
	    && (!markPtr->body.mark.changePtr
		|| (!markPtr->body.mark.changePtr->setMark
		    && !markPtr->body.mark.changePtr->toggleGravity))) {
	TkTextMarkChange *changePtr = MakeChangeItem(sharedTextPtr, markPtr);
	UndoTokenToggleGravity *token;

	token = memset(ckalloc(sizeof(UndoTokenToggleGravity)), 0, sizeof(UndoTokenToggleGravity));
	token->undoType = &undoTokenToggleGravityType;
	(token->markPtr = markPtr)->refCount += 1;
	undoInfo->token = (TkTextUndoToken *) token;
	DEBUG_ALLOC(tkTextCountNewUndoToken++);
	changePtr->toggleGravity = (TkTextUndoToken *) token;
	changePtr->savedMarkType = oldTypePtr;
	sharedTextPtr->markUndoTokenCount += 1;
    }

    if (sharedTextPtr->steadyMarks) {
	/* TODO: only if a normal mark is affected */
	TkTextUpdateAlteredFlag(sharedTextPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * UnsetMark --
 *
 *	Unset given mark.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Free some memory, and add a token to the undo/redo stack.
 *
 *----------------------------------------------------------------------
 */

static void
UnsetMark(
    TkSharedText *sharedTextPtr,
    TkTextSegment *markPtr,
    TkTextUndoInfo *redoInfo)
{
    assert(markPtr);
    assert(markPtr->typePtr->group == SEG_GROUP_MARK);
    assert(!TkTextIsSpecialMark(markPtr));
    assert(!TkTextIsPrivateMark(markPtr) || !redoInfo);

    if (redoInfo) {
	TkTextMarkChange *changePtr;

	if ((changePtr = markPtr->body.mark.changePtr)) {
	    memset(redoInfo, 0, sizeof(*redoInfo));

	    if (changePtr->toggleGravity) {
		ckfree(changePtr->toggleGravity);
		changePtr->toggleGravity = NULL;
		DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
		assert(markPtr->refCount > 1);
		markPtr->refCount -= 1;
		sharedTextPtr->markUndoTokenCount -= 1;
		markPtr->typePtr = (markPtr->typePtr == &tkTextRightMarkType) ?
			&tkTextLeftMarkType : &tkTextRightMarkType;
	    } 
	    if (changePtr->moveMark) {
		ckfree(changePtr->moveMark);
		changePtr->moveMark = NULL;
		DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
		assert(markPtr->refCount > 1);
		markPtr->refCount -= 1;
		sharedTextPtr->markUndoTokenCount -= 1;
	    }
	    if (changePtr->setMark) {
		ckfree(changePtr->setMark);
		changePtr->setMark = NULL;
		DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
		assert(markPtr->refCount > 1);
		markPtr->refCount -= 1;
		sharedTextPtr->markUndoTokenCount -= 1;
	    }
	} else {
	    RedoTokenSetMark *token;

	    token = ckalloc(sizeof(RedoTokenSetMark));
	    token->undoType = &redoTokenSetMarkType;
	    (token->markPtr = markPtr)->refCount += 1;
	    TkBTreeMakeUndoIndex(sharedTextPtr, markPtr, &token->index);
	    DEBUG_ALLOC(tkTextCountNewUndoToken++);
	    sharedTextPtr->markUndoTokenCount += 1;
	    redoInfo->token = (TkTextUndoToken *) token;
	    redoInfo->byteSize = 0;
	}
    }

    TkBTreeUnlinkSegment(sharedTextPtr, markPtr);
    MarkDeleteProc(sharedTextPtr->tree, markPtr, DELETE_CLEANUP);
}

/*
 *----------------------------------------------------------------------
 *
 * TriggerWatchCursor --
 *
 *	Trigger the watch command for movements of the insert cursor.
 *
 * Results:
 *	Returns 'false' if the referenced widget has been destroyed, otherwise
 *	'true' will be returned.
 *
 * Side effects:
 *	It might happen that the receiver of the "watch" command is destroying the widget.
 *
 *----------------------------------------------------------------------
 */

static bool
TriggerWatchCursor(
    TkText *textPtr,
    const TkTextIndex* oldCursorIndexPtr,
    const TkTextIndex* newCursorIndexPtr)	/* NULL is allowed. */
{
    TkTextIndex index, newIndex;
    char idx[2][TK_POS_CHARS];
    TkTextTag *tagPtr;
    TkTextTag *tagArrayBuffer[32];
    TkTextTag **tagArrayPtr;
    unsigned tagArraySize;
    unsigned numTags, i;
    Tcl_DString buf;
    bool rc;

    assert(oldCursorIndexPtr);
    assert(!TkTextIndexIsEmpty(oldCursorIndexPtr));
    assert(!newCursorIndexPtr || !TkTextIndexIsEmpty(newCursorIndexPtr));

    if (!newCursorIndexPtr) {
	TkTextIndexClear(&newIndex, textPtr);
	TkTextIndexSetSegment(&newIndex, textPtr->insertMarkPtr);
	newCursorIndexPtr = &newIndex;
    }

    if (TkTextIndexIsEqual(oldCursorIndexPtr, newCursorIndexPtr)) {
	return true;
    }

    Tcl_DStringInit(&buf);
    if (TkTextIndexIsEmpty(oldCursorIndexPtr)) {
	idx[0][0] = '\0';
    } else {
	TkTextPrintIndex(textPtr, oldCursorIndexPtr, idx[0]);
    }
    TkTextPrintIndex(textPtr, newCursorIndexPtr, idx[1]);
    if (textPtr->insertMarkPtr->typePtr == &tkTextLeftMarkType) {
	index = *newCursorIndexPtr;
    } else {
	TkTextIndexBackChars(textPtr, newCursorIndexPtr, 1, &index, COUNT_INDICES);
    }

    numTags = 0;
    tagArrayPtr = tagArrayBuffer;
    tagArraySize = sizeof(tagArrayBuffer)/sizeof(tagArrayBuffer[0]);
    tagPtr = TkBTreeGetTags(&index);
    for ( ; tagPtr; tagPtr = tagPtr->nextPtr) {
	if (numTags == tagArraySize) {
	    tagArraySize *= 2;
	    tagArrayPtr = ckrealloc(tagArrayPtr == tagArrayBuffer ? NULL : tagArrayPtr, tagArraySize);
	}
	tagArrayPtr[numTags++] = tagPtr;
    }
    TkTextSortTags(numTags, tagArrayPtr);
    for (i = 0; i < numTags; ++i) {
	Tcl_DStringAppendElement(&buf, tagArrayPtr[i]->name);
    }
    if (tagArrayPtr != tagArrayBuffer) {
	ckfree(tagArrayPtr);
    }

    rc = TkTriggerWatchCmd(textPtr, "cursor", idx[0], idx[1], Tcl_DStringValue(&buf), false);
    Tcl_DStringFree(&buf);
    return rc;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextReleaseUndoMarkTokens --
 *
 *	Release retained undo tokens for mark operations.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Free some memory.
 *
 *----------------------------------------------------------------------
 */

void
TkTextReleaseUndoMarkTokens(
    TkSharedText *sharedTextPtr,
    TkTextMarkChange *changePtr)
{
    assert(sharedTextPtr);
    assert(changePtr);

    if (!changePtr->markPtr) {
	return; /* already released */
    }

    assert(changePtr->markPtr->body.mark.changePtr);

    if (changePtr->toggleGravity) {
	ckfree(changePtr->toggleGravity);
	DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
	sharedTextPtr->markUndoTokenCount -= 1;
	assert(changePtr->markPtr->refCount > 1);
	changePtr->markPtr->refCount -= 1;
    }
    if (changePtr->moveMark) {
	ckfree(changePtr->moveMark);
	DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
	sharedTextPtr->markUndoTokenCount -= 1;
	assert(changePtr->markPtr->refCount > 1);
	changePtr->markPtr->refCount -= 1;
    }
    if (changePtr->setMark) {
	ckfree(changePtr->setMark);
	DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
	sharedTextPtr->markUndoTokenCount -= 1;
	assert(changePtr->markPtr->refCount > 1);
	changePtr->markPtr->refCount -= 1;
    }

    assert(changePtr->markPtr->refCount > 1);
    changePtr->markPtr->refCount -= 1;
    changePtr->markPtr->body.mark.changePtr = NULL;
    changePtr->markPtr = NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextPushUndoMarkTokens --
 *
 *	Push retained undo tokens for mark operations onto the undo stack.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Same as TkTextUndoPushItem.
 *
 *----------------------------------------------------------------------
 */

void
TkTextPushUndoMarkTokens(
    TkSharedText *sharedTextPtr,
    TkTextMarkChange *changePtr)
{
    assert(sharedTextPtr);
    assert(sharedTextPtr->undoStack);

    if (changePtr->toggleGravity) {
	UndoTokenToggleGravity *token = (UndoTokenToggleGravity *) changePtr->toggleGravity;

	if (changePtr->savedMarkType != token->markPtr->typePtr) {
	    TkTextUndoPushItem(sharedTextPtr->undoStack, (TkTextUndoToken *) token, 0);
	} else {
	    ckfree(token);
	    DEBUG_ALLOC(tkTextCountDestroyUndoToken++);
	    assert(changePtr->markPtr->refCount > 1);
	    changePtr->markPtr->refCount -= 1;
	    sharedTextPtr->markUndoTokenCount -= 1;
	}
	changePtr->toggleGravity = NULL;
    } 
    if (changePtr->moveMark) {
	TkTextUndoPushItem(sharedTextPtr->undoStack, changePtr->moveMark, 0);
	changePtr->moveMark = NULL;
    }
    if (changePtr->setMark) {
	TkTextUndoPushItem(sharedTextPtr->undoStack, changePtr->setMark, 0);
	changePtr->setMark = NULL;
    }

    assert(changePtr->markPtr->refCount > 1);
    changePtr->markPtr->refCount -= 1;
    changePtr->markPtr->body.mark.changePtr = NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextSetMark -- SetMark --
 *
 *	Set a mark to a particular position, creating a new mark if one
 *	doesn't already exist.
 *
 *	Take care when setting the "insert" mark. In this case it might
 *	happen that the receiver of the "watch" command is destroying the
 *	widget. In this case this function will return NULL (otherwise
 *	this function will always return non-NULL in case of setting the
 *	"insert" mark).
 *
 *	The footprint of this function is public, so we cannot extend it
 *	without changing tkIntDecls.h, and I will not touch this file. So
 *	I gave parameter 'name' an additional flag: if this parameter is
 *	marked, then it's a private mark.
 *
 * Results:
 *	The return value is a pointer to the mark that was just set.
 *
 * Side effects:
 *	A new mark is created, or an existing mark is moved.
 *
 *----------------------------------------------------------------------
 */

static TkTextSegment *
SetMark(
    TkText *textPtr,		/* Text widget in which to create mark. */
    const char *name,		/* Name of mark to set. */
    const Tk_SegType *typePtr,	/* Sepcifies the gravity, either tkTextLeftMarkType, 
    				 * tkTextRightMarkType, or NULL. */
    TkTextIndex *indexPtr)	/* Where to set mark. */
{
    Tcl_HashEntry *hPtr = NULL;
    TkSharedText *sharedTextPtr;
    TkTextSegment *markPtr;
    TkTextIndex oldIndex;
    TkTextUndoIndex undoIndex;
    bool pushUndoToken, widgetSpecific;

    assert(textPtr);
    assert(indexPtr->textPtr == textPtr);

    widgetSpecific = false;
    markPtr = NULL;

    switch (*name) {
    case 'i':
	if (strcmp(name, "insert") == 0) {
	    widgetSpecific = true;
	    markPtr = textPtr->insertMarkPtr;
	    if (TkTextIsElided(indexPtr)) {
		TkTextSkipElidedRegion(indexPtr);
	    }
	}
	break;
    case 'c':
	if (strcmp(name, "current") == 0) {
	    widgetSpecific = true;
	    markPtr = textPtr->currentMarkPtr;
	}
	break;
    }

    sharedTextPtr = textPtr->sharedTextPtr;
    TkTextIndexClear(&oldIndex, textPtr);

    if (!widgetSpecific) {
	int dummy;
	hPtr = Tcl_CreateHashEntry(&sharedTextPtr->markTable, name, &dummy);
	markPtr = Tcl_GetHashValue(hPtr);
    }

    if (!markPtr) {
	if (name[0] == '#' && name[1] == '#') {
	    void *sPtr, *tPtr;
	    unsigned num;

	    if (sscanf(name, "##ID##%p##%p##%u##", &sPtr, &tPtr, &num) == 3) {
		/* XXX here the chance of a clash is relatively high. */
		/* XXX We should bookkeeping all generated marks. */
		return NULL; /* this is an expired generated mark */
	    }
	}

	markPtr = MakeMark(textPtr);

	if (widgetSpecific) {
	    /*
	     * This is a special mark.
	     */
	    if (*name == 'i') { /* "insert" */
		textPtr->insertMarkPtr = markPtr;
		markPtr->insertMarkFlag = true;
	    } else {
		textPtr->currentMarkPtr = markPtr;
		markPtr->currentMarkFlag = true;
	    }
	    pushUndoToken = false;
	} else { /* "current" */
	    sharedTextPtr->isVirgin = false;
	    markPtr->body.mark.ptr = PTR_TO_INT(hPtr);
	    Tcl_SetHashValue(hPtr, markPtr);
	    pushUndoToken = sharedTextPtr->steadyMarks && sharedTextPtr->undoStack;
	    textPtr->sharedTextPtr->numMarks += 1;
	}
    } else {
	TkTextMarkSegToIndex(textPtr, markPtr, &oldIndex);

	if (markPtr == textPtr->insertMarkPtr && TkTextIndexIsEndOfText(indexPtr)) {
	    /*
	     * The index is outside of visible text, so backup one char.
	     */
	    TkTextIndexBackChars(textPtr, indexPtr, 1, indexPtr, COUNT_INDICES);
	}

	if (!sharedTextPtr->steadyMarks
		&& (!typePtr || typePtr == markPtr->typePtr)
		&& TkTextIndexIsEqual(&oldIndex, indexPtr)) {
	    return markPtr; /* this mark did not change the position */
	}

	TkTextIndexToByteIndex(&oldIndex);
	pushUndoToken = sharedTextPtr->steadyMarks
		&& sharedTextPtr->undoStack
		&& TkTextIsNormalMark(markPtr);

	/*
	 * If this is the insertion point that's being moved, be sure to force
	 * a display update at the old position. Also, don't let the insertion
	 * cursor be after the final newline of the file.
	 */

	if (markPtr == textPtr->insertMarkPtr) {
	    TkTextIndex index2;

	    TkTextIndexToByteIndex(indexPtr);

	    if (textPtr->state == TK_TEXT_STATE_NORMAL) {
		/*
		 * Test whether cursor is inside the actual range.
		 */
		if (TkTextIndexRestrictToStartRange(&oldIndex) >= 0
			&& TkTextIndexRestrictToEndRange(&oldIndex) <= 0
			&& TkTextIndexForwChars(textPtr, &oldIndex, 1, &index2, COUNT_INDICES)) {
		    /*
		     * While we wish to redisplay, no heights have changed, so no need
		     * to call TkTextInvalidateLineMetrics.
		     */

		    TkTextChanged(NULL, textPtr, &oldIndex, &index2);
		}
	    }
	} else if (markPtr == textPtr->currentMarkPtr) {
	    textPtr->haveToSetCurrentMark = false;
	} else if (pushUndoToken) {
	    TkBTreeMakeUndoIndex(sharedTextPtr, markPtr, &undoIndex);
	}

	assert(TkTextIndexGetSegment(indexPtr) != markPtr);

	if (TkTextIndexGetSegment(indexPtr) && TkTextIndexGetSegment(indexPtr)->size > 1) {
	    /* because TkBTreeUnlinkSegment may invalidate this index */
	    TkTextIndexToByteIndex(indexPtr);
	}
	TkBTreeUnlinkSegment(sharedTextPtr, markPtr);
    }

    if (typePtr) {
	/* TODO: also record change of gravity on undo stack, if mark is not new */
	markPtr->typePtr = typePtr;
    }

    /* this function will also update 'sectionPtr' */
    TkBTreeLinkSegment(sharedTextPtr, markPtr, indexPtr);

    if (pushUndoToken) {
	TkTextMarkChange *changePtr = MakeChangeItem(sharedTextPtr, markPtr);

	/* TODO: we cannot amalgamate in any case */
	if (!changePtr->setMark && !changePtr->moveMark) {
	    if (TkTextIndexIsEmpty(&oldIndex)) {
		UndoTokenSetMark *token;

		token = ckalloc(sizeof(UndoTokenSetMark));
		token->undoType = &undoTokenSetMarkType;
		(token->markPtr = markPtr)->refCount += 1;
		DEBUG_ALLOC(tkTextCountNewUndoToken++);
		changePtr->setMark = (TkTextUndoToken *) token;
		sharedTextPtr->markUndoTokenCount += 1;
	    } else {
		UndoTokenMoveMark *token;

		token = ckalloc(sizeof(UndoTokenMoveMark));
		token->undoType = &undoTokenMoveMarkType;
		(token->markPtr = markPtr)->refCount += 1;
		token->index = undoIndex;
		DEBUG_ALLOC(tkTextCountNewUndoToken++);
		changePtr->setMark = (TkTextUndoToken *) token;
		sharedTextPtr->markUndoTokenCount += 1;
	    }
	}
    }

    if (sharedTextPtr->steadyMarks) {
	/* TODO: only if a normal mark is affected */
	TkTextUpdateAlteredFlag(sharedTextPtr);
    }

    if (textPtr->state == TK_TEXT_STATE_NORMAL) {
	/*
	 * If the mark is the insertion cursor, then update the screen at the mark's new location.
	 */

	if (markPtr == textPtr->insertMarkPtr) {
	    TkTextIndex index2;

	    TkTextIndexForwChars(textPtr, indexPtr, 1, &index2, COUNT_INDICES);

	    /*
	     * While we wish to redisplay, no heights have changed, so no need to
	     * call TkTextInvalidateLineMetrics.
	     */

	    /* TODO: this is very inefficient, it would be more appopriate to trigger
	     * a special cursor redraw function (see DisplayDLine in tkTextDisp).
	     * Instead of inserting a cursor chunk (not needed) we want to overlay
	     * with a cursor. This will speed up cursor movement.
	     */
	    TkTextChanged(NULL, textPtr, indexPtr, &index2);

	    /*
	     * Finally trigger the "watch" command for the "insert" cursor,
	     * this must be the last action.
	     */

	    if (textPtr->watchCmd && !TriggerWatchCursor(textPtr, &oldIndex, indexPtr)) {
		return NULL; /* the receiver did destroy the widget */
	    }
	}
    }

    return markPtr;
}

TkTextSegment *
TkTextSetMark(
    TkText *textPtr,		/* Text widget in which to create mark. */
    const char *name,		/* Name of mark to set. */
    TkTextIndex *indexPtr)	/* Where to set mark. */
{
    return SetMark(textPtr, name, NULL, indexPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * TkTextUnsetMark --
 *
 *	Unset (delete) given mark.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A mark will be deleted.
 *
 *----------------------------------------------------------------------
 */

void
TkTextUnsetMark(
    TkText *textPtr,		/* Text widget in which to create mark. */
    TkTextSegment *markPtr)	/* Delete this mark. */
{
    TkTextUndoInfo undoInfo;
    TkTextUndoInfo *undoInfoPtr = NULL;

    assert(TkTextIsNormalMark(markPtr));

    if (textPtr->sharedTextPtr->steadyMarks
	    && !TkTextUndoUndoStackIsFull(textPtr->sharedTextPtr->undoStack)) {
	undoInfoPtr = &undoInfo;
    }
    UnsetMark(textPtr->sharedTextPtr, markPtr, undoInfoPtr);
    if (undoInfoPtr && undoInfo.token) {
	TkTextPushUndoToken(textPtr->sharedTextPtr, undoInfo.token, 0);
    }
    if (textPtr->sharedTextPtr->steadyMarks) {
	/* TODO: only if a normal mark is affected */
	TkTextUpdateAlteredFlag(textPtr->sharedTextPtr);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkSaveCursorIndex --
 *
 *	Save the current position of the insert cursor, but only if
 *	it is not yet saved. Use this function only if a trigger of
 *	the "watch" command is wanted in case of cursor movement.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

void
TkSaveCursorIndex(
    TkText *textPtr)
{
    if (TkTextIndexIsEmpty(&textPtr->insertIndex)) {
	TkTextIndexSetSegment(&textPtr->insertIndex, textPtr->insertMarkPtr);
	TkTextIndexSave(&textPtr->insertIndex);
    }
}

/*
 *----------------------------------------------------------------------
 *
 * TkTriggerWatchCursor --
 *
 *	Trigger the watch command for movements of the insert cursor.
 *
 * Results:
 *	Returns 'false' if the referenced widget has been destroyed, otherwise
 *	'true' will be returned.
 *
 * Side effects:
 *	It might happen that the receiver of the "watch" command is destroying the widget.
 *
 *----------------------------------------------------------------------
 */

bool
TkTriggerWatchCursor(
    TkText *textPtr)
{
    assert(textPtr->watchCmd);

    if (TkTextIndexIsEmpty(&textPtr->insertIndex)) {
	return true;
    }

    TkTextIndexRebuild(&textPtr->insertIndex);
    return TriggerWatchCursor(textPtr, &textPtr->insertIndex, NULL);
}

/*
 *--------------------------------------------------------------
 *
 * TkTextMarkSegToIndex --
 *
 *	Given a segment that is a mark, create an index that refers to the
 *	next text character (or other text segment with non-zero size) after
 *	the mark.
 *
 * Results:
 *	*IndexPtr is filled in with index information.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

void
TkTextMarkSegToIndex(
    TkText *textPtr,		/* Text widget containing mark, can be NULL. */
    TkTextSegment *markPtr,	/* Mark segment. */
    TkTextIndex *indexPtr)	/* Index information gets stored here.  */
{
    assert(textPtr);
    assert(markPtr);
    assert(markPtr->sectionPtr); /* otherwise not linked */

    TkTextIndexClear(indexPtr, textPtr);
    /* disable range checks, because here its is allowed that the index is out of range. */
    DEBUG(indexPtr->discardConsistencyCheck = true);
    TkTextIndexSetSegment(indexPtr, markPtr);
}

/*
 *--------------------------------------------------------------
 *
 * TkTextMarkNameToIndex --
 *
 *	Given the name of a mark, return an index corresponding to the mark
 *	name.
 *
 * Results:
 *	The return value is 'true' if "name" exists as a mark in the text
 *	widget and is located within its -starline/-endline range. In this
 *	case *indexPtr is filled in with the next segment who is after the
 *	mark whose size is non-zero. 'false' is returned if the mark
 *	doesn't exist in the text widget, or if it is out of its -starline/
 *	-endline range. In this latter case *indexPtr still contains valid
 *	information, in particular TkTextMarkNameToIndex called with the
 *	"insert" or "current" mark name may return TCL_ERROR, but *indexPtr
 *	contains the correct index of this mark before -startline or after
 *	-endline.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

static bool
MarkToIndex(
    TkText *textPtr,		/* Text widget containing mark. */
    TkTextSegment *markPtr,	/* Pointer to mark segment. */
    TkTextIndex *indexPtr)	/* Index information gets stored here. */
{
    TkTextIndex index;

    assert(textPtr);
    TkTextMarkSegToIndex(textPtr, markPtr, indexPtr);
    indexPtr->textPtr = textPtr;

    /*
     * If indexPtr refers to somewhere outside the -start/-end range
     * limits of the widget, error out since the mark indeed is not
     * reachable from this text widget (it may be reachable from a peer)
     * (bug 1630271).
     */

    if (textPtr->startMarker != textPtr->sharedTextPtr->startMarker) {
	TkTextIndexClear(&index, textPtr);
	TkTextIndexSetSegment(&index, textPtr->startMarker);
	if (TkTextIndexCompare(indexPtr, &index) < 0) {
	    return false;
	}
    }
    if (textPtr->endMarker != textPtr->sharedTextPtr->endMarker) {
	if (TkTextIndexGetLine(indexPtr) == textPtr->endMarker->sectionPtr->linePtr) {
	    TkTextIndexClear(&index, textPtr);
	    TkTextIndexSetSegment(&index, textPtr->endMarker);
	} else {
	    TkTextIndexSetupToEndOfText(&index, textPtr, indexPtr->tree);
	}
	if (TkTextIndexCompare(indexPtr, &index) > 0) {
	    return false;
	}
    }

    return true;
}

bool
TkTextMarkNameToIndex(
    TkText *textPtr,		/* Text widget containing mark. */
    const char *name,		/* Name of mark. */
    TkTextIndex *indexPtr)	/* Index information gets stored here. */
{
    TkTextSegment *segPtr;

    assert(textPtr);

    if (strcmp(name, "insert") == 0) {
	segPtr = textPtr->insertMarkPtr;
    } else if (strcmp(name, "current") == 0) {
	segPtr = textPtr->currentMarkPtr;
    } else {
	Tcl_HashEntry *hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->markTable, name);

	if (hPtr == NULL) {
	    return false;
	}
	segPtr = Tcl_GetHashValue(hPtr);
    }

    return MarkToIndex(textPtr, segPtr, indexPtr);
}

/*
 *--------------------------------------------------------------
 *
 * MarkInspectProc --
 *
 *	This function is invoked to build the information for
 *	"inspect".
 *
 * Results:
 *	Return a TCL object containing the information for
 *	"inspect".
 *
 * Side effects:
 *	Storage is allocated.
 *
 *--------------------------------------------------------------
 */

static Tcl_Obj *
MarkInspectProc(
    const TkSharedText *sharedTextPtr,
    const TkTextSegment *segPtr)
{
    Tcl_Obj *objPtr = Tcl_NewListObj(0, NULL);
    const char *gravity = (segPtr->typePtr == &tkTextLeftMarkType) ? "left" : "right";
    const char *name = TkTextMarkName(sharedTextPtr, NULL, segPtr);

    assert(!TkTextIsPrivateMark(segPtr));
    assert(name);

    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj(gravity, -1));
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj(name, -1));
    return objPtr;
}

/*
 *--------------------------------------------------------------
 *
 * MarkDeleteProc --
 *
 *	This function is invoked by the text B-tree code whenever a mark lies
 *	in a range being deleted.
 *
 * Results:
 *	Returns false to indicate that deletion has been rejected. Otherwise, if
 *	deletion has been done (virtually) because DELETE_MARKS is set, true
 *	will be returned. If the reference count of this segment is not going
 *	to zero then this segment will be preserved for undo.
 *
 * Side effects:
 *	None when this functions returns false (even if the whole tree is being
 *	deleted we don't free up the mark; it will be done elsewhere). But
 *	if a deletion has been done the hash entry of this mark will be
 *	removed.
 *
 *--------------------------------------------------------------
 */

static bool
MarkDeleteProc(
    TkTextBTree tree,
    TkTextSegment *segPtr,	/* Segment being deleted. */
    int flags)			/* The deletion flags. */
{
    TkSharedText *sharedTextPtr;

    assert(segPtr->refCount > 0);

    if (TkTextIsSpecialMark(segPtr)) {
	return false;
    }

    assert(segPtr->refCount > 0);

    if (TkTextIsPrivateMark(segPtr)) {
	if (!(flags & DELETE_CLEANUP)) {
	    return false;
	}
	if (--segPtr->refCount == 0) {
	    if (segPtr->body.mark.ptr) {
		Tcl_DeleteHashEntry(HPTR(segPtr->body.mark.ptr));
		segPtr->body.mark.textPtr->sharedTextPtr->numPrivateMarks -= 1;
	    }
	    FREE_SEGMENT(segPtr);
	    DEBUG_ALLOC(tkTextCountDestroySegment++);
	}
	return true;
    }

    if (!(flags & (DELETE_MARKS|DELETE_CLEANUP))) {
	return false;
    }

    assert(segPtr->body.mark.ptr);
    assert(segPtr->body.mark.textPtr);

    sharedTextPtr = segPtr->body.mark.textPtr->sharedTextPtr;

    if (segPtr->body.mark.changePtr) {
	TkTextReleaseUndoMarkTokens(sharedTextPtr, segPtr->body.mark.changePtr);
    }

    if (--segPtr->refCount == 0) {
	if (IS_PRESERVED(segPtr->body.mark.ptr)) {
	    ckfree(NAME(segPtr->body.mark.ptr));
	} else {
	    sharedTextPtr->numMarks -= 1;
	    Tcl_DeleteHashEntry(HPTR(segPtr->body.mark.ptr));
	}
	FREE_SEGMENT(segPtr);
	DEBUG_ALLOC(tkTextCountDestroySegment++);
    } else if (!IS_PRESERVED(segPtr->body.mark.ptr)) {
	Tcl_HashEntry *hPtr;
	const char *name;
	unsigned size;

	name = Tcl_GetHashKey(&sharedTextPtr->markTable, hPtr = HPTR(segPtr->body.mark.ptr));
	size = strlen(name) + 1;
	segPtr->body.mark.ptr = PTR_TO_INT(memcpy(ckalloc(size), name, size));
	MAKE_PRESERVED(segPtr->body.mark.ptr);
	Tcl_DeleteHashEntry(hPtr);
	sharedTextPtr->numMarks -= 1;
    }

    return true;
}

/*
 *--------------------------------------------------------------
 *
 * MarkRestoreProc --
 *
 *	This function is called when a mark segment will be resused
 *	from the undo chain.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The name of the mark will be freed, and the mark will be
 *	re-entered into the hash table.
 *
 *--------------------------------------------------------------
 */

static void
MarkRestoreProc(
    TkTextSegment *segPtr)	/* Segment to restore. */
{
    int isNew;

    assert(TkTextIsNormalMark(segPtr));

    if (IS_PRESERVED(segPtr->body.mark.ptr)) {
	Tcl_HashEntry *hPtr;

	hPtr = Tcl_CreateHashEntry(
		&segPtr->body.mark.textPtr->sharedTextPtr->markTable,
		NAME(segPtr->body.mark.ptr),
		&isNew);
	assert(isNew);
	Tcl_SetHashValue(hPtr, segPtr);
	ckfree(NAME(segPtr->body.mark.ptr));
	segPtr->body.mark.ptr = PTR_TO_INT(hPtr);
	segPtr->body.mark.textPtr->sharedTextPtr->numMarks += 1;
    }
}

/*
 *--------------------------------------------------------------
 *
 * MarkCheckProc --
 *
 *	This function is invoked by the B-tree code to perform consistency
 *	checks on mark segments.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The function panics if it detects anything wrong with
 *	the mark.
 *
 *--------------------------------------------------------------
 */

static void
MarkCheckProc(
    const TkSharedText *sharedTextPtr,	/* Handle to shared text resource. */
    const TkTextSegment *markPtr)	/* Segment to check. */
{
    Tcl_HashSearch search;
    Tcl_HashEntry *hPtr;

    if (!markPtr->nextPtr) {
	Tcl_Panic("MarkCheckProc: mark is last segment in line");
    }
    if (markPtr->size != 0) {
	Tcl_Panic("MarkCheckProc: mark has size %d", markPtr->size);
    }

    if (markPtr->body.mark.changePtr) {
	/*
	 * Private marks and special marks will not have undo/redo data.
	 */

	if (TkTextIsSpecialOrPrivateMark(markPtr)) {
	    Tcl_Panic("MarkCheckProc: private/special marks should not have undo/redo data");
	}
    }

    /*
     * The special marks ("insert", "current") are not in the hash table,
     * the same with the start/end markers.
     */

    if (markPtr->body.mark.ptr) {
	if (IS_PRESERVED(markPtr->body.mark.ptr)) {
	    Tcl_Panic("MarkCheckProc: detected preserved mark outside of the undo chain");
	}

	/*
	 * Make sure that the mark is still present in the text's mark hash table.
	 */

	for (hPtr = Tcl_FirstHashEntry(&((TkSharedText *) sharedTextPtr)->markTable, &search);
		hPtr != HPTR(markPtr->body.mark.ptr);
		hPtr = Tcl_NextHashEntry(&search)) {
	    if (!hPtr) {
		Tcl_Panic("MarkCheckProc: couldn't find hash table entry for mark");
	    }
	}
    }

    if (markPtr->startEndMarkFlag) {
	if (markPtr->typePtr == &tkTextLeftMarkType) {
	    if (markPtr->prevPtr
		    && markPtr->prevPtr->typePtr->group == SEG_GROUP_MARK
		    && (!markPtr->prevPtr->startEndMarkFlag
			|| markPtr->prevPtr->typePtr != &tkTextLeftMarkType)) {
		Tcl_Panic("MarkCheckProc: start marker must be left most mark");
	    }
	} else {
	    if (markPtr->nextPtr
		    && markPtr->nextPtr->typePtr->group == SEG_GROUP_MARK
		    && (!markPtr->nextPtr->startEndMarkFlag
			|| markPtr->nextPtr->typePtr != &tkTextRightMarkType)) {
		Tcl_Panic("MarkCheckProc: end marker must be right most mark");
	    }
	}
    }
}

/*
 *--------------------------------------------------------------
 *
 * MarkLayoutProc --
 *
 *	This function is the "layoutProc" for mark segments.
 *
 * Results:
 *	If the mark isn't the insertion cursor then the return value is -1 to
 *	indicate that this segment shouldn't be displayed. If the mark is the
 *	insertion character then 1 is returned and the chunkPtr structure is
 *	filled in.
 *
 * Side effects:
 *	None, except for filling in chunkPtr.
 *
 *--------------------------------------------------------------
 */

static int
MarkLayoutProc(
    const TkTextIndex *indexPtr,/* Identifies first character in chunk. */
    TkTextSegment *segPtr,	/* Segment corresponding to indexPtr. */
    int offset,			/* Offset within segPtr corresponding to indexPtr (always 0). */
    int maxX,			/* Chunk must not occupy pixels at this position or higher. */
    int maxChars,		/* Chunk must not include more than this many characters. */
    bool noCharsYet,		/* 'true' means no characters have been assigned to this line yet. */
    TkWrapMode wrapMode,	/* Not used. */
    TkTextDispChunk *chunkPtr)	/* Structure to fill in with information about this chunk. The x
    				 * field has already been set by the caller. */
{
    TkText *textPtr = indexPtr->textPtr;

    assert(indexPtr->textPtr);

    if (segPtr != textPtr->insertMarkPtr) {
	return -1;
    }

    chunkPtr->layoutProcs = &layoutInsertProcs;
    chunkPtr->numBytes = 0;
    chunkPtr->minAscent = 0;
    chunkPtr->minDescent = 0;
    chunkPtr->minHeight = 0;
    chunkPtr->width = 0;

    /*
     * Note: can't break a line after the insertion cursor: this prevents the
     * insertion cursor from being stranded at the end of a line.
     */

    chunkPtr->breakIndex = -1;
    chunkPtr->clientData = textPtr;
    return 1;
}

/*
 *--------------------------------------------------------------
 *
 * TkDrawBlockCursor --
 *
 *	This function returns whether a block will be drawn, which covers
 *	characters.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

bool
TkDrawBlockCursor(
    TkText *textPtr)		/* The current text widget. */
{
    if (textPtr->insertCursorType) {
	if (textPtr->flags & HAVE_FOCUS) {
	    if ((textPtr->flags & INSERT_ON) || textPtr->selBorder == textPtr->insertBorder) {
		return true;
	    }
	} else if (textPtr->insertUnfocussed == TK_TEXT_INSERT_NOFOCUS_SOLID) {
	    return true;
	}
    }
    return false;
}

/*
 *--------------------------------------------------------------
 *
 * TkGetCursorWidth --
 *
 *	This function computes the cursor dimensions.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

unsigned
TkGetCursorWidth(
    TkText *textPtr,		/* The current text widget. */
    int *x,			/* Shift x coordinate, can be NULL. */
    int *offs)			/* Offset in x-direction, can be NULL. */
{
    TkTextIndex index;
    int ix = 0, iy = 0, iw = 0, ih = 0;
    int charWidth = 0;

    if (offs) {
	*offs = -(textPtr->insertWidth/2);
    }

    if (textPtr->insertCursorType) {
	TkTextMarkSegToIndex(textPtr, textPtr->insertMarkPtr, &index);
	TkTextIndexBbox(textPtr, &index, &ix, &iy, &iw, &ih, &charWidth);

	/*
	 * Don't draw the full lengh of a tab, in this case we are drawing
	 * a cursor at the right boundary with a standard with.
	 */

	if (TkTextIndexGetChar(&index) == '\t') {
	    if (x) { *x += charWidth; }
	    charWidth = MIN(textPtr->charWidth, charWidth);
	    if (x) { *x -= charWidth; }
	}
    }

    return charWidth + textPtr->insertWidth;
}

/*
 *--------------------------------------------------------------
 *
 * TkTextInsertDisplayProc --
 *
 *	This function is called to display the insertion cursor.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Graphics are drawn.
 *
 *--------------------------------------------------------------
 */

void
TkTextInsertDisplayProc(
    TkText *textPtr,		/* The current text widget. */
    TkTextDispChunk *chunkPtr,	/* Chunk that is to be drawn. */
    int x,			/* X-position in dst at which to draw this chunk (may differ
    				 * from the x-position in the chunk because of scrolling). */
    int y,			/* Y-position at which to draw this chunk in dst (x-position
    				 * is in the chunk itself). */
    int height,			/* Total height of line. */
    int baseline,		/* Offset of baseline from y. */
    Display *display,		/* Display to use for drawing. */
    Drawable dst,		/* Pixmap or window in which to draw chunk. */
    int screenY)		/* Y-coordinate in text window that corresponds to y. */
{
    int halfWidth = textPtr->insertWidth/2;
    int width = TkGetCursorWidth(textPtr, &x, NULL);
    int rightSideWidth = width + halfWidth - textPtr->insertWidth;

    if ((x + rightSideWidth) < 0) {
	/*
	 * The insertion cursor is off-screen. Indicate caret at 0,0 and return.
	 */

	Tk_SetCaretPos(textPtr->tkwin, 0, 0, height);
	return;
    }

    x -= halfWidth;

    Tk_SetCaretPos(textPtr->tkwin, x, screenY, height);

    if (POINTER_IS_MARKED(chunkPtr)) {
	/*
	 * HACK: We are drawing into a tailored pixmap, because Tk has no clipping;
	 * see DisplayDLine().
	 */
	
	x = y = 0;
    }

    /*
     * As a special hack to keep the cursor visible on mono displays (or
     * anywhere else that the selection and insertion cursors have the same
     * color) write the default background in the cursor area (instead of
     * nothing) when the cursor isn't on. Otherwise the selection might hide
     * the cursor.
     */

    if (textPtr->flags & HAVE_FOCUS) {
	if (textPtr->flags & INSERT_ON) {
	    Tk_Fill3DRectangle(textPtr->tkwin, dst, textPtr->insertBorder, x, y,
		    width, height, textPtr->insertBorderWidth, TK_RELIEF_RAISED);
	} else if (textPtr->selBorder == textPtr->insertBorder) {
	    Tk_Fill3DRectangle(textPtr->tkwin, dst, textPtr->border, x, y,
		    width, height, 0, TK_RELIEF_FLAT);
	}
    } else if (textPtr->insertUnfocussed == TK_TEXT_INSERT_NOFOCUS_HOLLOW) {
	if (textPtr->insertBorderWidth < 1) {
	    /*
	     * Hack to work around the fact that a "solid" border always paints in black.
	     */

	    TkBorder *borderPtr = (TkBorder *) textPtr->insertBorder;

	    XDrawRectangle(Tk_Display(textPtr->tkwin), dst, borderPtr->bgGC, x, y,
		    width - 1, height - 1);
	} else {
	    Tk_Draw3DRectangle(textPtr->tkwin, dst, textPtr->insertBorder, x, y,
		    width, height, textPtr->insertBorderWidth, TK_RELIEF_RAISED);
	}
    } else if (textPtr->insertUnfocussed == TK_TEXT_INSERT_NOFOCUS_SOLID) {
	Tk_Fill3DRectangle(textPtr->tkwin, dst, textPtr->insertBorder, x, y,
		width, height, textPtr->insertBorderWidth, TK_RELIEF_RAISED);
    }
}

/*
 *--------------------------------------------------------------
 *
 * InsertUndisplayProc --
 *
 *	This function is called when the insertion cursor is no longer at a
 *	visible point on the display. It does nothing right now.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

static void
InsertUndisplayProc(
    TkText *textPtr,		/* Overall information about text widget. */
    TkTextDispChunk *chunkPtr)	/* Chunk that is about to be freed. */
{
    chunkPtr->clientData = NULL;
    return;
}

/*
 *--------------------------------------------------------------
 *
 * MarkFindNext --
 *
 *	This function searches forward for the next mark.
 *
 * Results:
 *	A standard Tcl result, which is a mark name or an empty string.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

static int
MarkFindNext(
    Tcl_Interp *interp,		/* For error reporting */
    TkText *textPtr,		/* The widget */
    const char *string,		/* The starting index or mark name */
    bool forward)		/* Search forward. */
{
    TkTextIndex index;
    Tcl_HashEntry *hPtr;
    TkTextSegment *segPtr;
    TkTextLine *linePtr;

    if (strcmp(string, "insert") == 0) {
	segPtr = textPtr->insertMarkPtr;
	linePtr = segPtr->sectionPtr->linePtr;
	segPtr = forward ? segPtr->nextPtr : segPtr->prevPtr;
    } else if (strcmp(string, "current") == 0) {
	segPtr = textPtr->currentMarkPtr;
	linePtr = segPtr->sectionPtr->linePtr;
	segPtr = forward ? segPtr->nextPtr : segPtr->prevPtr;
    } else {
	if ((hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->markTable, string))) {
	    /*
	     * If given a mark name, return the next/prev mark in the list of segments, even
	     * if it happens to be at the same character position.
	     */

	    segPtr = Tcl_GetHashValue(hPtr);
	    if (!MarkToIndex(textPtr, segPtr, &index)) {
		return SetResultNoMarkNamed(interp, string);
	    }
	    linePtr = segPtr->sectionPtr->linePtr;
	    segPtr = forward ? segPtr->nextPtr : segPtr->prevPtr;
	} else {
	    /*
	     * For non-mark name indices we want to return any marks that are
	     * right at the index, when searching forward, otherwise we do not
	     * return any marks that are right at the index.
	     */

	    if (TkTextGetIndex(interp, textPtr, string, &index) != TCL_OK) {
		return TCL_ERROR;
	    }
	    segPtr = TkTextIndexGetFirstSegment(&index, NULL);
	    linePtr = segPtr->sectionPtr->linePtr;

	    /* TODO: this means that TkTextIndexGetFirstSegment don't give us the first segment! */
	    if (!forward) {
		while (segPtr && segPtr->size == 0) {
		    segPtr = segPtr->prevPtr;
		}
	    }
	}
    }

    if (forward) {
	TkTextSegment *lastPtr = textPtr->endMarker;

	/*
	 * Ensure that we can reach 'lastPtr'.
	 */

	while (lastPtr->size == 0) {
	    lastPtr = lastPtr->nextPtr;
	}

	while (true) {
	    /*
	     * 'segPtr' points at the first possible candidate, or NULL if we ran
	     * off the end of the line.
	     */

	    for ( ; segPtr; segPtr = segPtr->nextPtr) {
		if (segPtr == lastPtr) {
		    return TCL_OK;
		}
		if (TkTextIsNormalOrSpecialMark(segPtr)) {
		    const char *name = TkTextMarkName(textPtr->sharedTextPtr, textPtr, segPtr);

		    if (name) {
			Tcl_SetObjResult(interp, Tcl_NewStringObj(name, -1));
			return TCL_OK;
		    }
		}
	    }

	    if (!(linePtr = linePtr->nextPtr)) {
		return TCL_OK;
	    }
	    segPtr = linePtr->segPtr;
	}
    } else {
	TkTextSegment *firstPtr = textPtr->startMarker;

	/*
	 * Ensure that we can reach 'firstPtr'.
	 */

	while (firstPtr->prevPtr && firstPtr->prevPtr->size == 0) {
	    firstPtr = firstPtr->prevPtr;
	}

	while (true) {
	    /*
	     * 'segPtr' points at the first possible candidate, or NULL if we ran
	     * off the start of the line.
	     */

	    for ( ; segPtr; segPtr = segPtr->prevPtr) {
		if (segPtr == firstPtr) {
		    return TCL_OK;
		}
		if (TkTextIsNormalOrSpecialMark(segPtr)) {
		    const char *name = TkTextMarkName(textPtr->sharedTextPtr, textPtr, segPtr);

		    if (name) {
			Tcl_SetObjResult(interp, Tcl_NewStringObj(name, -1));
			return TCL_OK;
		    }
		}
	    }

	    if (!(linePtr = linePtr->prevPtr)) {
		return TCL_OK;
	    }
	    segPtr = linePtr->lastPtr;
	}
    }

    return TCL_OK; /* never reached */
}

/*
 * ------------------------------------------------------------------------
 *
 * TkTextMarkName --
 *
 *	Returns the name of the mark that is the given text segment, or NULL
 *	if it is unnamed (i.e., a widget-specific mark that isn't "current" or
 *	"insert").
 *
 * Results:
 *	The name of the mark, or NULL.
 *
 * Side effects:
 *	None.
 *
 * ------------------------------------------------------------------------
 */

const char *
TkTextMarkName(
    const TkSharedText *sharedTextPtr,
    const TkText *textPtr,		/* can be NULL */
    const TkTextSegment *markPtr)
{
    assert(!IS_PRESERVED(markPtr));

    if (markPtr->insertMarkFlag) {
	return !textPtr || textPtr == markPtr->body.mark.textPtr ? "insert" : NULL;
    }
    if (markPtr->currentMarkFlag) {
	return !textPtr || textPtr == markPtr->body.mark.textPtr ? "current" : NULL;
    }
    if (!markPtr->body.mark.ptr) {
	return NULL;
    }
    return Tcl_GetHashKey(&sharedTextPtr->markTable, (Tcl_HashEntry *) markPtr->body.mark.ptr);
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 105
 * End:
 * vi:set ts=8 sw=4:
 */
