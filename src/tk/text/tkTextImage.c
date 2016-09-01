/*
 * tkImage.c --
 *
 *	This file contains code that allows images to be nested inside text
 *	widgets. It also implements the "image" widget command for texts.
 *
 * Copyright (c) 1997 Sun Microsystems, Inc.
 * Copyright (c) 2015-2016 Gregor Cramer
 *
 * See the file "license.terms" for information on usage and redistribution of
 * this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#include "tkPort.h"
#include "tkText.h"
#include "tkTextTagSet.h"
#include "tkTextUndo.h"
#include <assert.h>

#ifndef MIN
# define MIN(a,b) ((a) < (b) ? a : b)
#endif
#ifndef MAX
# define MAX(a,b) ((a) < (b) ? b : a)
#endif

#if NDEBUG
# define DEBUG(expr)
#else
# define DEBUG(expr) expr
#endif

/*
 * Prototypes for functions defined in this file:
 */

static void		EmbImageCheckProc(const TkSharedText *sharedTextPtr,
			    const TkTextSegment *segPtr);
static Tcl_Obj *	EmbImageInspectProc(const TkSharedText *sharedTextPtr,
			    const TkTextSegment *segPtr);
static void		EmbImageBboxProc(TkText *textPtr, TkTextDispChunk *chunkPtr, int index, int y,
			    int lineHeight, int baseline, int *xPtr, int *yPtr, int *widthPtr,
			    int *heightPtr);
static int		EmbImageConfigure(TkText *textPtr, TkTextSegment *eiPtr, int objc,
			    Tcl_Obj *const objv[]);
static bool		EmbImageDeleteProc(TkTextBTree tree, TkTextSegment *segPtr, int treeGone);
static void		EmbImageRestoreProc(TkTextSegment *segPtr);
static void		EmbImageDisplayProc(TkText *textPtr, TkTextDispChunk *chunkPtr, int x, int y,
			    int lineHeight, int baseline, Display *display, Drawable dst, int screenY);
static int		EmbImageLayoutProc(const TkTextIndex *indexPtr, TkTextSegment *segPtr,
			    int offset, int maxX, int maxChars, bool noCharsYet, TkWrapMode wrapMode,
			    TkTextDispChunk *chunkPtr);
static void		EmbImageProc(ClientData clientData, int x, int y, int width, int height,
			    int imageWidth, int imageHeight);
static TkTextSegment *	MakeImage(TkText *textPtr);

static const TkTextDispChunkProcs layoutImageProcs = {
    TEXT_DISP_IMAGE,		/* type */
    EmbImageDisplayProc,	/* displayProc */
    NULL,			/* undisplayProc */
    NULL,			/* measureProc */
    EmbImageBboxProc,	        /* bboxProc */
};

/*
 * We need some private undo/redo stuff.
 */

static void UndoLinkSegmentPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void RedoLinkSegmentPerform(TkSharedText *, TkTextUndoInfo *, TkTextUndoInfo *, bool);
static void UndoLinkSegmentDestroy(TkSharedText *, TkTextUndoToken *);
static void UndoLinkSegmentGetRange(TkSharedText *, const TkTextUndoToken *,
	TkTextIndex *, TkTextIndex *);
static void RedoLinkSegmentGetRange(TkSharedText *, const TkTextUndoToken *,
	TkTextIndex *, TkTextIndex *);
static Tcl_Obj *UndoLinkSegmentGetCommand(const TkSharedText *, const TkTextUndoToken *);
static Tcl_Obj *UndoLinkSegmentInspect(const TkSharedText *, const TkTextUndoToken *);
static Tcl_Obj *RedoLinkSegmentInspect(const TkSharedText *, const TkTextUndoToken *);

static const Tk_UndoType undoTokenLinkSegmentType = {
    TK_TEXT_UNDO_IMAGE,		/* action */
    UndoLinkSegmentGetCommand,	/* commandProc */
    UndoLinkSegmentPerform,	/* undoProc */
    UndoLinkSegmentDestroy,	/* destroyProc */
    UndoLinkSegmentGetRange,	/* rangeProc */
    UndoLinkSegmentInspect	/* inspectProc */
};

static const Tk_UndoType redoTokenLinkSegmentType = {
    TK_TEXT_REDO_IMAGE,		/* action */
    UndoLinkSegmentGetCommand,	/* commandProc */
    RedoLinkSegmentPerform,	/* undoProc */
    UndoLinkSegmentDestroy,	/* destroyProc */
    RedoLinkSegmentGetRange,	/* rangeProc */
    RedoLinkSegmentInspect	/* inspectProc */
};

typedef struct UndoTokenLinkSegment {
    const Tk_UndoType *undoType;
    TkTextSegment *segPtr;
} UndoTokenLinkSegment;

typedef struct RedoTokenLinkSegment {
    const Tk_UndoType *undoType;
    TkTextSegment *segPtr;
    TkTextUndoIndex index;
} RedoTokenLinkSegment;

/*
 * The following structure declares the "embedded image" segment type.
 */

const Tk_SegType tkTextEmbImageType = {
    "image",			/* name */
    SEG_GROUP_IMAGE,		/* group */
    GRAVITY_NEUTRAL,		/* gravity */
    EmbImageDeleteProc,		/* deleteProc */
    EmbImageRestoreProc,	/* restoreProc */
    EmbImageLayoutProc,		/* layoutProc */
    EmbImageCheckProc,		/* checkProc */
    EmbImageInspectProc		/* inspectProc */
};

/*
 * Definitions for alignment values:
 */

static const char *const alignStrings[] = {
    "baseline", "bottom", "center", "top", NULL
};

typedef enum {
    ALIGN_BASELINE, ALIGN_BOTTOM, ALIGN_CENTER, ALIGN_TOP
} alignMode;

/*
 * Information used for parsing image configuration options:
 */

static const Tk_OptionSpec optionSpecs[] = {
    {TK_OPTION_STRING_TABLE, "-align", NULL, NULL,
	"center", -1, Tk_Offset(TkTextEmbImage, align), 0, alignStrings, 0},
    {TK_OPTION_PIXELS, "-padx", NULL, NULL,
	"0", -1, Tk_Offset(TkTextEmbImage, padX), 0, 0, 0},
    {TK_OPTION_PIXELS, "-pady", NULL, NULL,
	"0", -1, Tk_Offset(TkTextEmbImage, padY), 0, 0, 0},
    {TK_OPTION_STRING, "-image", NULL, NULL,
	NULL, -1, Tk_Offset(TkTextEmbImage, imageString), TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_STRING, "-name", NULL, NULL,
	NULL, -1, Tk_Offset(TkTextEmbImage, imageName), TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_END, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0}
};

DEBUG_ALLOC(extern unsigned tkTextCountDestroySegment);
DEBUG_ALLOC(extern unsigned tkTextCountNewUndoToken);
DEBUG_ALLOC(extern unsigned tkTextCountNewSegment);

/*
 * Some functions for the undo/redo mechanism.
 */

static Tcl_Obj *
UndoLinkSegmentGetCommand(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    Tcl_Obj *objPtr = Tcl_NewListObj(0, NULL);
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj("image", -1));
    return objPtr;
}

static Tcl_Obj *
UndoLinkSegmentInspect(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    const UndoTokenLinkSegment *token = (const UndoTokenLinkSegment *) item;
    Tcl_Obj *objPtr = UndoLinkSegmentGetCommand(sharedTextPtr, item);
    char buf[TK_POS_CHARS];
    TkTextIndex index;

    TkTextIndexClear2(&index, NULL,sharedTextPtr->tree);
    TkTextIndexSetSegment(&index, token->segPtr);
    TkTextIndexPrint(sharedTextPtr, NULL, &index, buf);
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj(buf, -1));
    return objPtr;
}

static void
UndoLinkSegmentPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    const UndoTokenLinkSegment *token = (const UndoTokenLinkSegment *) undoInfo->token;
    TkTextSegment *segPtr = token->segPtr;

    if (redoInfo) {
	RedoTokenLinkSegment *redoToken;
	redoToken = ckalloc(sizeof(RedoTokenLinkSegment));
	redoToken->undoType = &redoTokenLinkSegmentType;
	TkBTreeMakeUndoIndex(sharedTextPtr, segPtr, &redoToken->index);
	redoToken->segPtr = segPtr;
	redoInfo->token = (TkTextUndoToken *) token;
	DEBUG_ALLOC(tkTextCountNewUndoToken++);
    }

    TkBTreeUnlinkSegment(sharedTextPtr, segPtr);
    EmbImageDeleteProc(sharedTextPtr->tree, segPtr, 0);
}

static void
UndoLinkSegmentDestroy(
    TkSharedText *sharedTextPtr,
    TkTextUndoToken *item)
{
    UndoTokenLinkSegment *token = (UndoTokenLinkSegment *) item;
    EmbImageDeleteProc(sharedTextPtr->tree, token->segPtr, 0);
}

static void
UndoLinkSegmentGetRange(
    TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item,
    TkTextIndex *startIndex,
    TkTextIndex *endIndex)
{
    const UndoTokenLinkSegment *token = (const UndoTokenLinkSegment *) item;
    TkTextIndexClear2(startIndex, NULL, sharedTextPtr->tree);
    TkTextIndexSetSegment(startIndex, token->segPtr);
    *endIndex = *startIndex;
}

static Tcl_Obj *
RedoLinkSegmentInspect(
    const TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item)
{
    const RedoTokenLinkSegment *token = (const RedoTokenLinkSegment *) item;
    Tcl_Obj *objPtr = EmbImageInspectProc(sharedTextPtr, token->segPtr);
    char buf[TK_POS_CHARS];
    TkTextIndex index;
    Tcl_Obj *idxPtr;

    TkBTreeUndoIndexToIndex(sharedTextPtr, &token->index, &index);
    TkTextIndexPrint(sharedTextPtr, NULL, &index, buf);
    idxPtr = Tcl_NewStringObj(buf, -1);
    Tcl_ListObjReplace(NULL, objPtr, 0, 0, 1, &idxPtr);
    return objPtr;
}

static void
RedoLinkSegmentPerform(
    TkSharedText *sharedTextPtr,
    TkTextUndoInfo *undoInfo,
    TkTextUndoInfo *redoInfo,
    bool isRedo)
{
    RedoTokenLinkSegment *token = (RedoTokenLinkSegment *) undoInfo->token;

    TkBTreeReInsertSegment(sharedTextPtr, &token->index, token->segPtr);

    if (redoInfo) {
	redoInfo->token = undoInfo->token;
	token->undoType = &undoTokenLinkSegmentType;
    }
}

static void
RedoLinkSegmentGetRange(
    TkSharedText *sharedTextPtr,
    const TkTextUndoToken *item,
    TkTextIndex *startIndex,
    TkTextIndex *endIndex)
{
    const RedoTokenLinkSegment *token = (const RedoTokenLinkSegment *) item;
    TkBTreeUndoIndexToIndex(sharedTextPtr, &token->index, startIndex);
    *endIndex = *startIndex;
}

/*
 *--------------------------------------------------------------
 *
 * TkTextPushImageUndo --
 *
 *	This function is pushing an undo item for given image
 *	segment.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushUndoToken.
 *
 *--------------------------------------------------------------
 */

void
TkTextPushImageUndo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *eiPtr)
{
    UndoTokenLinkSegment *token;

    assert(sharedTextPtr->undoStack);
    assert(eiPtr->typePtr == &tkTextEmbImageType);

    token = ckalloc(sizeof(UndoTokenLinkSegment));
    token->undoType = &undoTokenLinkSegmentType;
    token->segPtr = eiPtr;
    eiPtr->refCount += 1;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushUndoToken(sharedTextPtr, token, 0);
}

/*
 *--------------------------------------------------------------
 *
 * TkTextPushImageRedo --
 *
 *	This function is pushing a redo item for given image
 *	segment.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Some memory will be allocated, and see TkTextPushRedoToken.
 *
 *--------------------------------------------------------------
 */

void
TkTextPushImageRedo(
    TkSharedText *sharedTextPtr,
    TkTextSegment *eiPtr,
    const TkTextIndex *indexPtr)
{
    RedoTokenLinkSegment *token;

    assert(sharedTextPtr->undoStack);
    assert(eiPtr->typePtr == &tkTextEmbImageType);
    assert(eiPtr->refCount == 1);

    token = ckalloc(sizeof(UndoTokenLinkSegment));
    token->undoType = &undoTokenLinkSegmentType;
    token->index.lineIndex = TkTextIndexGetLineNumber(indexPtr, NULL);
    token->index.u.byteIndex = TkTextIndexGetByteIndex(indexPtr);
    token->segPtr = eiPtr;
    DEBUG_ALLOC(tkTextCountNewUndoToken++);

    TkTextPushRedoToken(sharedTextPtr, token, 1);
}

/*
 *--------------------------------------------------------------
 *
 * TkTextImageCmd --
 *
 *	This function implements the "image" widget command for text widgets.
 *	See the user documentation for details on what it does.
 *
 * Results:
 *	A standard Tcl result or error.
 *
 * Side effects:
 *	See the user documentation.
 *
 *--------------------------------------------------------------
 */

int
TkTextImageCmd(
    TkText *textPtr,		/* Information about text widget. */
    Tcl_Interp *interp,		/* Current interpreter. */
    int objc,			/* Number of arguments. */
    Tcl_Obj *const objv[])	/* Argument objects. Someone else has already
				 * parsed this command enough to know that
				 * objv[1] is "image". */
{
    int idx;
    TkTextSegment *eiPtr;
    TkSharedText *sharedTextPtr;
    TkTextIndex index;
    static const char *const optionStrings[] = {
	"bind", "cget", "configure", "create", "names", NULL
    };
    enum opts {
	CMD_BIND, CMD_CGET, CMD_CONF, CMD_CREATE, CMD_NAMES
    };

    if (objc < 3) {
	Tcl_WrongNumArgs(interp, 2, objv, "option ?arg arg ...?");
	return TCL_ERROR;
    }
    if (Tcl_GetIndexFromObj(interp, objv[2], optionStrings, "option", 0, &idx) != TCL_OK) {
	return TCL_ERROR;
    }

    sharedTextPtr = textPtr->sharedTextPtr;

    switch ((enum opts) idx) {
    case CMD_BIND: {
	TkTextEmbImage *img;
	int rc;

	if (objc < 4 || objc > 6) {
	    Tcl_WrongNumArgs(interp, 3, objv, "index ?sequence? ?command?");
	    return TCL_ERROR;
	}
	if (!TkTextGetIndexFromObj(interp, textPtr, objv[3], &index)) {
	    return TCL_ERROR;
	}
	eiPtr = TkTextIndexGetContentSegment(&index, NULL);
	if (eiPtr->typePtr != &tkTextEmbImageType) {
	    Tcl_AppendResult(interp, "no embedded image at index \"",
		    Tcl_GetString(objv[3]), "\"", NULL);
	    Tcl_SetErrorCode(interp, "TK", "TEXT", "NO_IMAGE", NULL);
	    return TCL_ERROR;
	}
	img = &eiPtr->body.ei;
	rc = TkTextBindEvent(interp, objc - 4, objv + 4, sharedTextPtr,
		&sharedTextPtr->imageBindingTable, img->name);
	if (rc == TCL_OK) {
	    img->haveBindings = true;
	    if (!textPtr->imageBboxTree) {
		if (img->displayed) {
		    TkQTreeRect bbox;
		    int dx, dy;

		    /*
		     * This image is already displayed, so we have to insert the bounding
		     * box of this image in the lookup tree, but this tree must be
		     * configured before we can add the bbox.
		     */

		    TkTextGetViewOffset(textPtr, &dx, &dy);
		    TkQTreeRectSet(&bbox, dx, dy,
			    Tk_Width(textPtr->tkwin) + dx, Tk_Height(textPtr->tkwin) + dy);
		    TkQTreeConfigure(&textPtr->imageBboxTree, &bbox);
		    textPtr->configureBboxTree = false;
		    TkQTreeInsertRect(textPtr->imageBboxTree, &img->bbox, (TkQTreeUid) img, 0);
		} else {
		    textPtr->configureBboxTree = true;
		}
	    }
	}
	return rc;
    }
    case CMD_CGET: {
	Tcl_Obj *objPtr;

	if (objc != 5) {
	    Tcl_WrongNumArgs(interp, 3, objv, "index option");
	    return TCL_ERROR;
	}
	if (!TkTextGetIndexFromObj(interp, textPtr, objv[3], &index)) {
	    return TCL_ERROR;
	}
	eiPtr = TkTextIndexGetContentSegment(&index, NULL);
	if (eiPtr->typePtr != &tkTextEmbImageType) {
	    Tcl_AppendResult(interp, "no embedded image at index \"",
		    Tcl_GetString(objv[3]), "\"", NULL);
	    return TCL_ERROR;
	}
	objPtr = Tk_GetOptionValue(interp, (char *) &eiPtr->body.ei,
		eiPtr->body.ei.optionTable, objv[4], textPtr->tkwin);
	if (!objPtr) {
	    return TCL_ERROR;
	} else {
	    Tcl_SetObjResult(interp, objPtr);
	    return TCL_OK;
	}
    }
    case CMD_CONF:
	if (objc < 4) {
	    Tcl_WrongNumArgs(interp, 3, objv, "index ?option value ...?");
	    return TCL_ERROR;
	}
	if (!TkTextGetIndexFromObj(interp, textPtr, objv[3], &index)) {
	    return TCL_ERROR;
	}
	eiPtr = TkTextIndexGetContentSegment(&index, NULL);
	if (eiPtr->typePtr != &tkTextEmbImageType) {
	    Tcl_AppendResult(interp, "no embedded image at index \"",
		    Tcl_GetString(objv[3]), "\"", NULL);
	    return TCL_ERROR;
	}
	if (objc <= 5) {
	    Tcl_Obj *objPtr = Tk_GetOptionInfo(interp,
		    (char *) &eiPtr->body.ei, eiPtr->body.ei.optionTable,
		    objc == 5 ? objv[4] : NULL, textPtr->tkwin);

	    if (!objPtr) {
		return TCL_ERROR;
	    } else {
		Tcl_SetObjResult(interp, objPtr);
		return TCL_OK;
	    }
	} else {
	    TkTextChanged(sharedTextPtr, NULL, &index, &index);

	    /*
	     * It's probably not true that all window configuration can change
	     * the line height, so we could be more efficient here and only
	     * call this when necessary.
	     */

	    TkTextInvalidateLineMetrics(sharedTextPtr, NULL,
		    TkTextIndexGetLine(&index), 0, TK_TEXT_INVALIDATE_ONLY);
	    return EmbImageConfigure(textPtr, eiPtr, objc - 4, objv + 4);
	}
    case CMD_CREATE: {
	    /*
	     * Add a new image. Find where to put the new image, and mark that
	     * position for redisplay.
	     */

	    if (objc < 4) {
		Tcl_WrongNumArgs(interp, 3, objv, "index ?option value ...?");
		return TCL_ERROR;
	    }
	    if (!TkTextGetIndexFromObj(interp, textPtr, objv[3], &index)) {
		return TCL_ERROR;
	    }

	    if (textPtr->state == TK_TEXT_STATE_DISABLED) {
#if !TK_TEXT_DEPRECATED_MODS_OF_DISABLED_WIDGET
		Tcl_SetObjResult(interp, Tcl_ObjPrintf("attempt to modify disabled widget"));
		Tcl_SetErrorCode(interp, "TK", "TEXT", "NOT_ALLOWED", NULL);
		return TCL_ERROR;
#endif
		return TCL_OK;
	    }

	    /*
	     * Don't allow insertions on the last line of the text.
	     */

	    if (!TkTextIndexEnsureBeforeLastChar(&index)) {
		Tcl_SetObjResult(textPtr->interp, Tcl_NewStringObj(
			"cannot insert image into empty peer", -1));
		Tcl_SetErrorCode(textPtr->interp, "TK", "TEXT", "IMAGE_CREATE_USAGE", NULL);
		return TCL_ERROR;
	    }

	    /*
	     * Create the new image segment and initialize it.
	     */

	    eiPtr = MakeImage(textPtr);

	    /*
	     * Link the segment into the text widget, then configure it (delete it
	     * again if the configuration fails).
	     */

	    TkTextChanged(sharedTextPtr, NULL, &index, &index);
	    TkBTreeLinkSegment(sharedTextPtr, eiPtr, &index);
	    if (EmbImageConfigure(textPtr, eiPtr, objc - 4, objv + 4) != TCL_OK) {
		TkBTreeUnlinkSegment(sharedTextPtr, eiPtr);
		EmbImageDeleteProc(sharedTextPtr->tree, eiPtr, 0);
		return TCL_ERROR;
	    }
	    TkTextInvalidateLineMetrics(sharedTextPtr, NULL,
		    TkTextIndexGetLine(&index), 0, TK_TEXT_INVALIDATE_ONLY);

	    if (!TkTextUndoStackIsFull(sharedTextPtr->undoStack)) {
		TkTextPushImageUndo(sharedTextPtr, eiPtr);
	    }
	}
	return TCL_OK;
    case CMD_NAMES: {
	Tcl_HashSearch search;
	Tcl_HashEntry *hPtr;

	if (objc != 3) {
	    Tcl_WrongNumArgs(interp, 3, objv, NULL);
	    return TCL_ERROR;
	}
	for (hPtr = Tcl_FirstHashEntry(&sharedTextPtr->imageTable, &search);
		hPtr;
		hPtr = Tcl_NextHashEntry(&search)) {
	    Tcl_AppendElement(interp, Tcl_GetHashKey(&sharedTextPtr->markTable, hPtr));
	}
	return TCL_OK;
    }
    }
    assert(!"unexpected switch fallthrough");
    return TCL_ERROR; /* shouldn't be reached */
}

/*
 *--------------------------------------------------------------
 *
 * MakeImage --
 *
 *	This function is called to create an image segment.
 *
 * Results:
 *	The return value is the newly created image.
 *
 * Side effects:
 *	Some memory will be allocated.
 *
 *--------------------------------------------------------------
 */

static TkTextSegment *
MakeImage(
    TkText *textPtr)		/* Information about text widget that contains embedded image. */
{
    TkTextSegment *eiPtr;

    eiPtr = memset(ckalloc(SEG_SIZE(TkTextEmbImage)), 0, SEG_SIZE(TkTextEmbImage));
    eiPtr->typePtr = &tkTextEmbImageType;
    eiPtr->size = 1;
    eiPtr->refCount = 1;
    eiPtr->body.ei.sharedTextPtr = textPtr->sharedTextPtr;
    eiPtr->body.ei.align = ALIGN_CENTER;
    eiPtr->body.ei.optionTable = Tk_CreateOptionTable(textPtr->interp, optionSpecs);
    DEBUG_ALLOC(tkTextCountNewSegment++);

    return eiPtr;
}

/*
 *--------------------------------------------------------------
 *
 * TkTextMakeImage --
 *
 *	This function is called to create an image segment.
 *
 * Results:
 *	The return value is a standard Tcl result. If TCL_ERROR is returned,
 *	then the interp's result contains an error message.
 *
 * Side effects:
 *	Some memory will be allocated.
 *
 *--------------------------------------------------------------
 */

TkTextSegment *
TkTextMakeImage(
    TkText *textPtr,		/* Information about text widget that contains embedded image. */
    Tcl_Obj *options)		/* Options for this image. */
{
    TkTextSegment *eiPtr;
    Tcl_Obj **objv;
    int objc;

    assert(options);

    if (Tcl_ListObjGetElements(textPtr->interp, options, &objc, &objv) != TCL_OK) {
	return NULL;
    }

    eiPtr = MakeImage(textPtr);

    if (EmbImageConfigure(textPtr, eiPtr, objc, objv) == TCL_OK) {
	Tcl_ResetResult(textPtr->interp);
    } else {
	EmbImageDeleteProc(textPtr->sharedTextPtr->tree, eiPtr, 0);
	eiPtr = NULL;
    }

    return eiPtr;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageConfigure --
 *
 *	This function is called to handle configuration options for an
 *	embedded image, using an objc/objv list.
 *
 * Results:
 *	The return value is a standard Tcl result. If TCL_ERROR is returned,
 *	then the interp's result contains an error message.
 *
 * Side effects:
 *	Configuration information for the embedded image changes, such as
 *	alignment, or name of the image.
 *
 *--------------------------------------------------------------
 */

static void
SetImageName(
    TkText *textPtr,
    TkTextSegment *eiPtr,
    const char *name)
{
    Tcl_DString newName;
    TkTextEmbImage *img;
    int dummy, length;

    assert(name);
    assert(!eiPtr->body.ei.name);
    assert(!eiPtr->body.ei.hPtr);

    /*
     * Create a unique name for this image.
     */

    Tcl_DStringInit(&newName);
    if (Tcl_FindHashEntry(&textPtr->sharedTextPtr->imageTable, name)) {
	char buf[4 + TCL_INTEGER_SPACE];
	snprintf(buf, sizeof(buf), "#%d", ++textPtr->sharedTextPtr->imageCount);
	Tcl_DStringAppend(&newName, name, -1);
	Tcl_DStringAppend(&newName, buf, -1);
	name = Tcl_DStringValue(&newName);
    }
    length = strlen(name);

    img = &eiPtr->body.ei;
    img->hPtr = Tcl_CreateHashEntry(&textPtr->sharedTextPtr->imageTable, name, &dummy);
    textPtr->sharedTextPtr->numImages += 1;
    Tcl_SetHashValue(img->hPtr, eiPtr);
    img->name = ckalloc(length + 1);
    memcpy(img->name, name, length + 1);
    Tcl_SetObjResult(textPtr->interp, Tcl_NewStringObj(name, -1));
    Tcl_DStringFree(&newName);
}

static int
EmbImageConfigure(
    TkText *textPtr,		/* Information about text widget that contains embedded image. */
    TkTextSegment *eiPtr,	/* Embedded image to be configured. */
    int objc,			/* Number of strings in objv. */
    Tcl_Obj *const objv[])	/* Array of strings describing configuration options. */
{
    Tk_Image image;
    char *name;
    TkTextEmbImage *img = &eiPtr->body.ei;

    if (Tk_SetOptions(textPtr->interp, (char *) img, img->optionTable, objc, objv, textPtr->tkwin,
		NULL, NULL) != TCL_OK) {
	return TCL_ERROR;
    }

    /*
     * Create the image. Save the old image around and don't free it until
     * after the new one is allocated. This keeps the reference count from
     * going to zero so the image doesn't have to be recreated if it hasn't
     * changed.
     */

    if (img->imageString) {
	image = Tk_GetImage(textPtr->interp, textPtr->tkwin, img->imageString, EmbImageProc, eiPtr);
	if (!image) {
	    return TCL_ERROR;
	}
    } else {
	image = NULL;
    }
    if (img->image) {
	Tk_FreeImage(img->image);
    }
    img->image = image;

    if (!img->name) {
	if (!(name = img->imageName) && !(name = img->imageString)) {
	    Tcl_SetObjResult(textPtr->interp, Tcl_NewStringObj(
		    "Either a \"-name\" or a \"-image\" argument must be"
		    " provided to the \"image create\" subcommand", -1));
	    Tcl_SetErrorCode(textPtr->interp, "TK", "TEXT", "IMAGE_CREATE_USAGE", NULL);
	    return TCL_ERROR;
	}

	Tcl_SetObjResult(textPtr->interp, Tcl_NewStringObj(img->name, -1));
	SetImageName(textPtr, eiPtr, name);
    }

    return TCL_OK;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageInspectProc --
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
EmbImageInspectProc(
    const TkSharedText *sharedTextPtr,
    const TkTextSegment *segPtr)
{
    Tcl_Obj *objPtr = Tcl_NewListObj(0, NULL);
    Tcl_Obj *objPtr2 = Tcl_NewListObj(0, NULL);
    TkTextTag **tagLookup = sharedTextPtr->tagLookup;
    const TkTextTagSet *tagInfoPtr = segPtr->tagInfoPtr;
    unsigned i = TkTextTagSetFindFirst(tagInfoPtr);
    Tcl_DString opts;

    assert(sharedTextPtr->peers);

    for ( ; i != TK_TEXT_TAG_SET_NPOS; i = TkTextTagSetFindNext(tagInfoPtr, i)) {
	const TkTextTag *tagPtr = tagLookup[i];
	Tcl_ListObjAppendElement(NULL, objPtr2, Tcl_NewStringObj(tagPtr->name, -1));
    }

    Tcl_DStringInit(&opts);
    TkTextInspectOptions(sharedTextPtr->peers, &segPtr->body.ei, segPtr->body.ei.optionTable,
	    &opts, false);

    Tcl_ListObjAppendElement(NULL, objPtr, objPtr2);
    Tcl_ListObjAppendElement(NULL, objPtr, Tcl_NewStringObj(Tcl_DStringValue(&opts),
	    Tcl_DStringLength(&opts)));

    Tcl_DStringFree(&opts);
    return objPtr;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageDeleteProc --
 *
 *	This function is invoked by the text B-tree code whenever an
 *	embedded image lies in a range of characters being deleted.
 *
 * Results:
 *	Returns true to indicate that the deletion has been accepted.
 *
 * Side effects:
 *	The embedded image is deleted, if it exists, and any resources
 *	associated with it are released.
 *
 *--------------------------------------------------------------
 */

static bool
EmbImageDeleteProc(
    TkTextBTree tree,
    TkTextSegment *eiPtr,	/* Segment being deleted. */
    int flags)			/* Flags controlling the deletion. */
{
    TkTextEmbImage *img = &eiPtr->body.ei;

    assert(eiPtr->refCount > 0);

    if (img->hPtr) {
	img->sharedTextPtr->numImages -= 1;
	Tcl_DeleteHashEntry(img->hPtr);
	img->hPtr = NULL;
    }

    /*
     * Remove this image from bounding box tree in all peers, and clear
     * the information about the currently hovered image if necessary.
     */

    if (img->displayed && img->haveBindings) {
	TkText *peer = img->sharedTextPtr->peers;

	for ( ; peer; peer = peer->next) {
	    if (!(peer->flags & DESTROYED)) {
		if (peer->hoveredImageArrSize) {
		    unsigned i;

		    for (i = 0; i < peer->hoveredImageArrSize; ++i) {
			if (peer->hoveredImageArr[i] == img) {
			    /*
			     * One problem here, the mouse leave event will not be
			     * triggered anymore. The user should avoid this situation.
			     */
			    memmove(peer->hoveredImageArr + i, peer->hoveredImageArr + i + 1,
				    --peer->hoveredImageArrSize - i);
			    break;
			}
		    }
		}
		if (peer->imageBboxTree) {
		    TkQTreeDeleteRect(peer->imageBboxTree, &img->bbox, (TkQTreeUid) img);
		}
	    }
	}
    }

    if (--eiPtr->refCount == 0) {
	if (img->image) {
	    Tk_FreeImage(img->image);
	}
	if (img->sharedTextPtr->imageBindingTable) {
	    Tk_DeleteAllBindings(img->sharedTextPtr->imageBindingTable, (ClientData) img->name);
	}

	/*
	 * No need to supply a tkwin argument, since we have no window-specific options.
	 */

	Tk_FreeConfigOptions((char *) img, img->optionTable, NULL);
	if (img->name) {
	    ckfree(img->name);
	}
	TkTextTagSetDecrRefCount(eiPtr->tagInfoPtr);
	FREE_SEGMENT(eiPtr);
	DEBUG_ALLOC(tkTextCountDestroySegment++);
    }
    return true;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageRestoreProc --
 *
 *	This function is called when an image segment will be
 *	restored from the undo chain.
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
EmbImageRestoreProc(
    TkTextSegment *eiPtr)	/* Segment to reuse. */
{
    TkTextEmbImage *img = &eiPtr->body.ei;
    int isNew;

    if (img->image) {
	assert(!img->hPtr);
	img->hPtr = Tcl_CreateHashEntry(&img->sharedTextPtr->imageTable, img->name, &isNew);
	img->sharedTextPtr->numImages += 1;
	assert(isNew);
	Tcl_SetHashValue(img->hPtr, eiPtr);
    }
    img->displayed = false;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageLayoutProc --
 *
 *	This function is the "layoutProc" for embedded image segments.
 *
 * Results:
 *	1 is returned to indicate that the segment should be displayed. The
 *	chunkPtr structure is filled in.
 *
 * Side effects:
 *	None, except for filling in chunkPtr.
 *
 *--------------------------------------------------------------
 */

static int
EmbImageLayoutProc(
    const TkTextIndex *indexPtr,/* Identifies first character in chunk. */
    TkTextSegment *eiPtr,	/* Segment corresponding to indexPtr. */
    int offset,			/* Offset within segPtr corresponding to indexPtr (always 0). */
    int maxX,			/* Chunk must not occupy pixels at this position or higher. */
    int maxChars,		/* Chunk must not include more than this many characters. */
    bool noCharsYet,		/* 'true' means no characters have been assigned to this line yet. */
    TkWrapMode wrapMode,	/* Wrap mode to use for line:
				 * TEXT_WRAPMODE_CHAR, TEXT_WRAPMODE_NONE, or TEXT_WRAPMODE_WORD. */
    TkTextDispChunk *chunkPtr)	/* Structure to fill in with information about this chunk. The x
				 * field has already been set by the caller. */
{
    TkTextEmbImage *img = &eiPtr->body.ei;
    int width, height;

    assert(indexPtr->textPtr);
    assert(offset == 0);

    /*
     * See if there's room for this image on this line.
     */

    if (!img->image) {
	width = 0;
	height = 0;
    } else {
	Tk_SizeOfImage(img->image, &width, &height);
	width += 2*img->padX;
	height += 2*img->padY;
    }
    if ((width > maxX - chunkPtr->x)
	    && !noCharsYet
	    && (indexPtr->textPtr->wrapMode != TEXT_WRAPMODE_NONE)) {
	return 0;
    }

    /*
     * Fill in the chunk structure.
     */

    chunkPtr->layoutProcs = &layoutImageProcs;
    chunkPtr->numBytes = 1;
    if (img->align == ALIGN_BASELINE) {
	chunkPtr->minAscent = height - img->padY;
	chunkPtr->minDescent = img->padY;
	chunkPtr->minHeight = 0;
    } else {
	chunkPtr->minAscent = 0;
	chunkPtr->minDescent = 0;
	chunkPtr->minHeight = height;
    }
    chunkPtr->width = width;
    chunkPtr->breakIndex = (wrapMode == TEXT_WRAPMODE_NONE) ? -1 : 1;
    chunkPtr->clientData = eiPtr;
    return 1;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageCheckProc --
 *
 *	This function is invoked by the B-tree code to perform consistency
 *	checks on embedded images.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The function panics if it detects anything wrong with the embedded
 *	image.
 *
 *--------------------------------------------------------------
 */

static void
EmbImageCheckProc(
    const TkSharedText *sharedTextPtr,	/* Handle to shared text resource. */
    const TkTextSegment *eiPtr)		/* Segment to check. */
{
    if (!eiPtr->nextPtr) {
	Tcl_Panic("EmbImageCheckProc: embedded image is last segment in line");
    }
    if (eiPtr->size != 1) {
	Tcl_Panic("EmbImageCheckProc: embedded image has size %d", eiPtr->size);
    }
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageDisplayProc --
 *
 *	This function is invoked by the text displaying code when it is time
 *	to actually draw an embedded image chunk on the screen.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The embedded image gets moved to the correct location and drawn onto
 *	the display.
 *
 *--------------------------------------------------------------
 */

static void
EmbImageDisplayProc(
    TkText *textPtr,
    TkTextDispChunk *chunkPtr,	/* Chunk that is to be drawn. */
    int x,			/* X-position in dst at which to draw this
				 * chunk (differs from the x-position in the
				 * chunk because of scrolling). */
    int y,			/* Top of rectangular bounding box for line:
				 * tells where to draw this chunk in dst
				 * (x-position is in the chunk itself). */
    int lineHeight,		/* Total height of line. */
    int baseline,		/* Offset of baseline from y. */
    Display *display,		/* Display to use for drawing. */
    Drawable dst,		/* Pixmap or window in which to draw */
    int screenY)		/* Y-coordinate in text window that corresponds to y. */
{
    TkTextSegment *eiPtr = chunkPtr->clientData;
    TkTextEmbImage *img = &eiPtr->body.ei;
    int lineX, imageX, imageY, width, height;
    TkQTreeRect oldBbox;
    Tk_Image image;
    int dx, dy;

    if (!(image = img->image)) {
	return;
    }

    /*
     * Compute the image's location and size in the text widget, taking into
     * account the align value for the image.
     */

    EmbImageBboxProc(textPtr, chunkPtr, 0, y, lineHeight, baseline, &lineX, &imageY, &width, &height);
    imageX = lineX - chunkPtr->x + x;

    TkTextGetViewOffset(textPtr, &dx, &dy);

    if (textPtr->configureBboxTree) {
	TkQTreeRect bbox;

	/*
	 * The view of the widget has changed. This is the appropriate place to
	 * re-configure the bounding box tree.
	 */

	TkQTreeRectSet(&bbox, dx, dy, Tk_Width(textPtr->tkwin) + dx, Tk_Height(textPtr->tkwin) + dy);
	TkQTreeConfigure(&textPtr->imageBboxTree, &bbox);
	textPtr->configureBboxTree = false;
    }

    /*
     * Update the bounding box, used for detection of mouse hovering.
     */

    oldBbox = img->bbox;
    img->bbox.xmin = imageX + dx;
    img->bbox.xmax = img->bbox.xmin + width;
    img->bbox.ymin = screenY + imageY + dy;
    img->bbox.ymax = img->bbox.ymin + height;

    if (img->haveBindings && textPtr->imageBboxTree) {
	const TkQTreeRect *oldBboxPtr = img->displayed ? &oldBbox : NULL;
	TkQTreeUpdateRect(textPtr->imageBboxTree, oldBboxPtr, &img->bbox, (TkQTreeUid) img, 0);
    }

    img->displayed = true;

    if (x + chunkPtr->width > 0) {
	/*
	 * Finally, redraw the image if inside widget area.
	 */

	Tk_RedrawImage(image, 0, 0, width, height, dst, imageX, imageY);
    }
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageBboxProc --
 *
 *	This function is called to compute the bounding box of the area
 *	occupied by an embedded image.
 *
 * Results:
 *	There is no return value. *xPtr and *yPtr are filled in with the
 *	coordinates of the upper left corner of the image, and *widthPtr and
 *	*heightPtr are filled in with the dimensions of the image in pixels.
 *	Note: not all of the returned bbox is necessarily visible on the
 *	screen (the rightmost part might be off-screen to the right, and the
 *	bottommost part might be off-screen to the bottom).
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

static void
EmbImageBboxProc(
    TkText *textPtr,
    TkTextDispChunk *chunkPtr,	/* Chunk containing desired char. */
    int index,			/* Index of desired character within the chunk. */
    int y,			/* Topmost pixel in area allocated for this line. */
    int lineHeight,		/* Total height of line. */
    int baseline,		/* Location of line's baseline, in pixels measured down from y. */
    int *xPtr, int *yPtr,	/* Gets filled in with coords of character's upper-left pixel. */
    int *widthPtr,		/* Gets filled in with width of image, in pixels. */
    int *heightPtr)		/* Gets filled in with height of image, in pixels. */
{
    TkTextSegment *eiPtr = chunkPtr->clientData;
    TkTextEmbImage *img = &eiPtr->body.ei;
    Tk_Image image = img->image;

    if (image) {
	Tk_SizeOfImage(image, widthPtr, heightPtr);
    } else {
	*widthPtr = *heightPtr = 0;
    }

    *xPtr = chunkPtr->x + img->padX;

    switch (img->align) {
    case ALIGN_BOTTOM:
	*yPtr = y + (lineHeight - *heightPtr - img->padY);
	break;
    case ALIGN_CENTER:
	*yPtr = y + (lineHeight - *heightPtr)/2;
	break;
    case ALIGN_TOP:
	*yPtr = y + img->padY;
	break;
    case ALIGN_BASELINE:
	*yPtr = y + (baseline - *heightPtr);
	break;
    }
}

/*
 *--------------------------------------------------------------
 *
 * TkTextImageIndex --
 *
 *	Given the name of an embedded image within a text widget, returns an
 *	index corresponding to the image's position in the text.
 *
 * Results:
 *	The return value is true if there is an embedded image by the given name
 *	in the text widget, false otherwise. If the image exists, *indexPtr is
 *	filled in with its index.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */

bool
TkTextImageIndex(
    TkText *textPtr,		/* Text widget containing image. */
    const char *name,		/* Name of image. */
    TkTextIndex *indexPtr)	/* Index information gets stored here. */
{
    Tcl_HashEntry *hPtr;
    TkTextSegment *eiPtr;

    assert(textPtr);

    if (!(hPtr = Tcl_FindHashEntry(&textPtr->sharedTextPtr->imageTable, name))) {
	return false;
    }
    eiPtr = Tcl_GetHashValue(hPtr);
    TkTextIndexClear(indexPtr, textPtr);
    TkTextIndexSetSegment(indexPtr, eiPtr);
    return true;
}

/*
 *--------------------------------------------------------------
 *
 * EmbImageProc --
 *
 *	This function is called by the image code whenever an image or its
 *	contents changes.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The image will be redisplayed.
 *
 *--------------------------------------------------------------
 */

static void
EmbImageProc(
    ClientData clientData,	/* Pointer to widget record. */
    int x, int y,		/* Upper left pixel (within image) that must be redisplayed. */
    int width, int height,	/* Dimensions of area to redisplay (may be <= 0). */
    int imgWidth, int imgHeight)/* New dimensions of image. */

{
    TkTextSegment *eiPtr = clientData;
    TkTextEmbImage *img = &eiPtr->body.ei;
    TkTextIndex index;

    TkTextIndexClear2(&index, NULL, img->sharedTextPtr->tree);
    TkTextIndexSetSegment(&index, eiPtr);
    TkTextChanged(img->sharedTextPtr, NULL, &index, &index);

    /*
     * It's probably not true that all image changes can change the line
     * height, so we could be more efficient here and only call this when
     * necessary.
     */

    TkTextInvalidateLineMetrics(img->sharedTextPtr, NULL,
	    TkTextIndexGetLine(&index), 0, TK_TEXT_INVALIDATE_ONLY);
}

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 * vi:set ts=8 sw=4:
 */
