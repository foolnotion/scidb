// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#define namespace namespace_ // bug in tk8.6/tkInt.h
#include <tk.h>
#include <tkInt.h>
#undef namespace_

//#define FIX_TK_POINTER_EVENTS
#define FIX_TK_GRAB_STATE


#ifdef FIX_TK_POINTER_EVENTS

# if defined(__unix__) && !defined(__MacOSX__)

#define GENERATED_EVENT_MAGIC ((Bool) 0x147321ac)

#define ALL_BUTTONS \
	(Button1Mask|Button2Mask|Button3Mask|Button4Mask|Button5Mask)
static unsigned int buttonStates[] = {
    Button1Mask, Button2Mask, Button3Mask, Button4Mask, Button5Mask
};

extern void TkpSync (Display * display);

extern "C" int TkPointerEvent(XEvent *eventPtr, TkWindow *winPtr);


static void
TransferXEventsToTcl(
    Display *display)
{
    XEvent event;

    /*
     * Transfer events from the X event queue to the Tk event queue after XIM
     * event filtering. KeyPress and KeyRelease events are filtered in
     * Tk_HandleEvent instead of here, so that Tk's focus management code can
     * redirect them.
     */

    while (QLength(display) > 0) {
	XNextEvent(display, &event);
	if (event.type != KeyPress && event.type != KeyRelease) {
	    if (XFilterEvent(&event, None)) {
		continue;
	    }
	}
	Tk_QueueWindowEvent(&event, TCL_QUEUE_TAIL);
    }
}


static void
Sync(Display *display)
{
    XSync(display, False);

    /*
     * Transfer events from the X event queue to the Tk event queue.
     */

    TransferXEventsToTcl(display);
}

# else

static void
Sync(Display *display)
{
    /* nothing to do */
}

# endif // __unix__ && !__MacOSX__


static Tk_RestrictAction
GrabRestrictProc(
    ClientData arg,
    XEvent *eventPtr)
{
    GrabInfo *info = (GrabInfo *) arg;
    int mode, diff;

    /*
     * The diff caculation is trickier than it may seem. Don't forget that
     * serial numbers can wrap around, so can't compare the two serial numbers
     * directly.
     */

    diff = eventPtr->xany.serial - info->serial;
    if ((eventPtr->type == EnterNotify)
	    || (eventPtr->type == LeaveNotify)) {
	mode = eventPtr->xcrossing.mode;
    } else if ((eventPtr->type == FocusIn)
	    || (eventPtr->type == FocusOut)) {
	mode = eventPtr->xfocus.mode;
    } else {
	mode = NotifyNormal;
    }
    if ((info->display != eventPtr->xany.display) || (mode == NotifyNormal)
	    || (diff < 0)) {
	return TK_DEFER_EVENT;
    } else {
	return TK_DISCARD_EVENT;
    }
}


static void
EatGrabEvents(
    TkDisplay *dispPtr,		/* Display from which to consume events. */
    unsigned int serial)	/* Only discard events that have a serial
				 * number at least this great. */
{
    Tk_RestrictProc *oldProc;
    GrabInfo info;
    ClientData oldArg, dummy;

    info.display = dispPtr->display;
    info.serial = serial;
    Sync(info.display);
    oldProc = Tk_RestrictEvents(GrabRestrictProc, (ClientData)&info, &oldArg);
    while (Tcl_ServiceEvent(TCL_WINDOW_EVENTS)) {
    }
    Tk_RestrictEvents(oldProc, oldArg, &dummy);
}


static void
MovePointer2(
    TkWindow *sourcePtr,	/* Window currently containing pointer (NULL
				 * means it's not one managed by this
				 * process). */
    TkWindow *destPtr,		/* Window that is to end up containing the
				 * pointer (NULL means it's not one managed by
				 * this process). */
    int mode,			/* Mode for enter/leave events, such as
				 * NotifyNormal or NotifyUngrab. */
    int leaveEvents,		/* Non-zero means generate leave events for
				 * the windows being left. Zero means don't
				 * generate leave events. */
    int enterEvents)		/* Non-zero means generate enter events for
				 * the windows being entered. Zero means don't
				 * generate enter events. */
{
    XEvent event;
    Window dummy1, dummy2;
    int dummy3, dummy4;
    TkWindow *winPtr;

    winPtr = sourcePtr;
    if ((winPtr == NULL) || (winPtr->window == None)) {
	winPtr = destPtr;
	if ((winPtr == NULL) || (winPtr->window == None)) {
	    return;
	}
    }

    event.xcrossing.serial = LastKnownRequestProcessed(winPtr->display);
    event.xcrossing.send_event = GENERATED_EVENT_MAGIC;
    event.xcrossing.display = winPtr->display;
    event.xcrossing.root = RootWindow(winPtr->display, winPtr->screenNum);
    event.xcrossing.time = TkCurrentTime(winPtr->dispPtr);
    XQueryPointer(winPtr->display, winPtr->window, &dummy1, &dummy2,
	    &event.xcrossing.x_root, &event.xcrossing.y_root,
	    &dummy3, &dummy4, &event.xcrossing.state);
    event.xcrossing.mode = mode;
    event.xcrossing.focus = False;
    TkInOutEvents(&event, sourcePtr, destPtr, (leaveEvents) ? LeaveNotify : 0,
	    (enterEvents) ? EnterNotify : 0, TCL_QUEUE_MARK);
}



static void
ReleaseButtonGrab(
    register TkDisplay *dispPtr)/* Display whose button grab is to be
				 * released. */
{
    unsigned int serial;

    if (dispPtr->buttonWinPtr != NULL) {
	if (dispPtr->buttonWinPtr != dispPtr->serverWinPtr) {
	    MovePointer2(dispPtr->buttonWinPtr, dispPtr->serverWinPtr,
		    NotifyUngrab, 1, 1);
	}
	dispPtr->buttonWinPtr = NULL;
    }
    if (dispPtr->grabFlags & GRAB_TEMP_GLOBAL) {
	dispPtr->grabFlags &= ~GRAB_TEMP_GLOBAL;
	serial = NextRequest(dispPtr->display);
	XUngrabPointer(dispPtr->display, CurrentTime);
	XUngrabKeyboard(dispPtr->display, CurrentTime);
	EatGrabEvents(dispPtr, serial);
    }
}


int
TkPointerEvent(
    register XEvent *eventPtr,	/* Pointer to the event. */
    TkWindow *winPtr)		/* Tk's information for window where event was
				 * reported. */
{
    register TkWindow *winPtr2;
    TkDisplay *dispPtr = winPtr->dispPtr;
    unsigned int serial;
    int outsideGrabTree = 0;
    int ancestorOfGrab = 0;
    int appGrabbed = 0;		/* Non-zero means event is being reported to
				 * an application that is affected by the
				 * grab. */

    /*
     * Collect information about the grab (if any).
     */

    switch (TkGrabState(winPtr)) {
    case TK_GRAB_IN_TREE:
	appGrabbed = 1;
	break;
    case TK_GRAB_ANCESTOR:
	appGrabbed = 1;
	outsideGrabTree = 1;
	ancestorOfGrab = 1;
	break;
    case TK_GRAB_EXCLUDED:
	appGrabbed = 1;
	outsideGrabTree = 1;
	break;
    }

    if ((eventPtr->type == EnterNotify) || (eventPtr->type == LeaveNotify)) {
	/*
	 * Keep track of what window the mouse is *really* over. Any events
	 * that we generate have a special send_event value, which is detected
	 * below and used to ignore the event for purposes of setting
	 * serverWinPtr.
	 */

	if (eventPtr->xcrossing.send_event != GENERATED_EVENT_MAGIC) {
	    if ((eventPtr->type == LeaveNotify) &&
		    (winPtr->flags & TK_TOP_HIERARCHY)) {
		dispPtr->serverWinPtr = NULL;
	    } else {
		dispPtr->serverWinPtr = winPtr;
	    }
	}

	/*
	 * When a grab is active, X continues to report enter and leave events
	 * for windows outside the tree of the grab window:
	 * 1. Detect these events and ignore them except for windows above the
	 *    grab window.
	 * 2. Allow Enter and Leave events to pass through the windows above
	 *    the grab window, but never let them end up with the pointer *in*
	 *    one of those windows.
	 */

	if (dispPtr->grabWinPtr != NULL) {
	    if (outsideGrabTree && appGrabbed) {
		if (!ancestorOfGrab) {
		    return 0;
		}
		switch (eventPtr->xcrossing.detail) {
		case NotifyInferior:
		    return 0;
		case NotifyAncestor:
		    eventPtr->xcrossing.detail = NotifyVirtual;
		    break;
		case NotifyNonlinear:
		    eventPtr->xcrossing.detail = NotifyNonlinearVirtual;
		    break;
		}
	    }

	    /*
	     * Make buttons have the same grab-like behavior inside a grab as
	     * they do outside a grab: do this by ignoring enter and leave
	     * events except for the window in which the button was pressed.
	     */

	    if ((dispPtr->buttonWinPtr != NULL)
		    && (winPtr != dispPtr->buttonWinPtr)) {
		return 0;
	    }
	}
	return 1;
    }

    if (!appGrabbed) {
	return 1;
    }

    if (eventPtr->type == MotionNotify) {
	/*
	 * When grabs are active, X reports motion events relative to the
	 * window under the pointer. Instead, it should report the events
	 * relative to the window the button went down in, if there is a
	 * button down. Otherwise, if the pointer window is outside the
	 * subtree of the grab window, the events should be reported relative
	 * to the grab window. Otherwise, the event should be reported to the
	 * pointer window.
	 */

	winPtr2 = winPtr;
	if (dispPtr->buttonWinPtr != NULL) {
	    winPtr2 = dispPtr->buttonWinPtr;
	} else if (outsideGrabTree || (dispPtr->serverWinPtr == NULL)) {
	    winPtr2 = dispPtr->grabWinPtr;
	}
	if (winPtr2 != winPtr) {
	    TkChangeEventWindow(eventPtr, winPtr2);
	    Tk_QueueWindowEvent(eventPtr, TCL_QUEUE_HEAD);
	    return 0;
	}
	return 1;
    }

    /*
     * Process ButtonPress and ButtonRelease events:
     * 1. Keep track of whether a button is down and what window it went down
     *    in.
     * 2. If the first button goes down outside the grab tree, pretend it went
     *    down in the grab window. Note: it's important to redirect events to
     *    the grab window like this in order to make things like menus work,
     *    where button presses outside the grabbed menu need to be seen. An
     *    application can always ignore the events if they occur outside its
     *    window.
     * 3. If a button press or release occurs outside the window where the
     *    first button was pressed, retarget the event so it's reported to the
     *    window where the first button was pressed.
     * 4. If the last button is released in a window different than where the
     *    first button was pressed, generate Enter/Leave events to move the
     *    mouse from the button window to its current window.
     * 5. If the grab is set at a time when a button is already down, or if
     *    the window where the button was pressed was deleted, then
     *    dispPtr->buttonWinPtr will stay NULL. Just forget about the
     *    auto-grab for the button press; events will go to whatever window
     *    contains the pointer. If this window isn't in the grab tree then
     *    redirect events to the grab window.
     * 6. When a button is pressed during a local grab, the X server sets a
     *    grab of its own, since it doesn't even know about our local grab.
     *    This causes enter and leave events no longer to be generated in the
     *    same way as for global grabs. To eliminate this problem, set a
     *    temporary global grab when the first button goes down and release it
     *    when the last button comes up.
     */

    if ((eventPtr->type == ButtonPress) || (eventPtr->type == ButtonRelease)) {
	winPtr2 = dispPtr->buttonWinPtr;
	if (winPtr2 == NULL) {
	    if (outsideGrabTree) {
		winPtr2 = dispPtr->grabWinPtr;			/* Note 5. */
	    } else {
		winPtr2 = winPtr;				/* Note 5. */
	    }
	}
	if (eventPtr->type == ButtonPress) {
	    if ((eventPtr->xbutton.state & ALL_BUTTONS) == 0) {
		if (outsideGrabTree) {
		    TkChangeEventWindow(eventPtr, dispPtr->grabWinPtr);
		    Tk_QueueWindowEvent(eventPtr, TCL_QUEUE_HEAD);
		    return 0;					/* Note 2. */
		}
		if (!(dispPtr->grabFlags & GRAB_GLOBAL)) {	/* Note 6. */
		    serial = NextRequest(dispPtr->display);
		    if (XGrabPointer(dispPtr->display,
			    dispPtr->grabWinPtr->window, True,
			    ButtonPressMask|ButtonReleaseMask|ButtonMotionMask,
			    GrabModeAsync, GrabModeAsync, None, None,
			    CurrentTime) == 0) {
			EatGrabEvents(dispPtr, serial);
			if (XGrabKeyboard(dispPtr->display, winPtr->window,
				False, GrabModeAsync, GrabModeAsync,
				CurrentTime) == 0) {
			    dispPtr->grabFlags |= GRAB_TEMP_GLOBAL;
			} else {
			    XUngrabPointer(dispPtr->display, CurrentTime);
			}
		    }
		}
		dispPtr->buttonWinPtr = winPtr;
		return 1;
	    }
	} else {
	    if ((eventPtr->xbutton.state & ALL_BUTTONS)
		    == buttonStates[eventPtr->xbutton.button - Button1]) {
		ReleaseButtonGrab(dispPtr);			/* Note 4. */
	    }
	}
	if (winPtr2 != winPtr) {
/********** FIX of endless loop *********************************/
	    if (eventPtr->xbutton.send_event == True) {
	       /* already redirected */
	       return 1;
	    }
/********** END fix of endless loop *****************************/
	    TkChangeEventWindow(eventPtr, winPtr2);
/********** FIX of endless loop *********************************/
	    /* mark as redirected */
	    eventPtr->xbutton.send_event = True;
/********** END fix of endless loop *****************************/
	    Tk_QueueWindowEvent(eventPtr, TCL_QUEUE_HEAD);
	    return 0;						/* Note 3. */
	}
    }

    return 1;
}

#endif // FIX_TK_POINTER_EVENTS

#ifdef FIX_TK_GRAB_STATE

#define GRAB_GLOBAL		1
#define GRAB_TEMP_GLOBAL	4

extern "C" int TkPositionInTree(TkWindow *winPtr, TkWindow *treePtr);
extern "C" int TkGrabState(TkWindow *winPtr);


static TkWindow *
TopLevelWindow(
    TkWindow *winPtr)		/* Window for which the toplevel is needed. */
{
    TkWindow *topLevelWinPtr = winPtr;

    while (winPtr) {
	if (winPtr->flags & TK_TOP_HIERARCHY) {
	    return winPtr;
	}
	winPtr = winPtr->parentPtr;
    }

    return topLevelWinPtr;
}


static int
CanDerive(
    TkWindow *winPtr1,
    TkWindow *winPtr2)
{
    for ( ; winPtr1; winPtr1 = winPtr1->parentPtr) {
	if (winPtr1 == winPtr2) {
	    return 1;
	}
    }
    return 0;
}


static int
CannotDerive(
    TkWindow *winPtr1,
    TkWindow *winPtr2)
{
    if (CanDerive(winPtr1, winPtr2))
	return 0;
    if (CanDerive(winPtr2, winPtr1))
	return 0;
    return 1;
}


int
TkGrabState(
    TkWindow *winPtr)		/* Window for which grab information is
				 * needed. */
{
    TkWindow *grabWinPtr = winPtr->dispPtr->grabWinPtr;

    if (grabWinPtr == NULL) {
	return TK_GRAB_NONE;
    }
    if (!(winPtr->dispPtr->grabFlags & GRAB_GLOBAL) &&
	    winPtr != grabWinPtr && /* this is an often case (which is false) */
	    CannotDerive(TopLevelWindow(winPtr), TopLevelWindow(grabWinPtr))) {
	return TK_GRAB_NONE;
    }

    return TkPositionInTree(winPtr, grabWinPtr);
}

#endif // FIX_TK_GRAB_STATE

void
tk::fixes_init(Tcl_Interp*)
{
    // force linkage
#ifdef FIX_TK_POINTER_EVENTS
    {
	int (*func)(XEvent *, TkWindow *) = TkPointerEvent;
	if (func)
	    ;
    }
#endif
#ifdef FIX_TK_GRAB_STATE
    {
	int (*func)(TkWindow *) = TkGrabState;
	if (func)
	    ;
    }
#endif
}

// vi:set ts=8 sw=4:
