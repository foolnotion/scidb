/* ======================================================================
 * Author : $Author$
 * Version: $Revision$
 * Date   : $Date$
 * Url    : $URL$
 * ====================================================================== */

/* ======================================================================
 * Heavily changed to get it work with GNOME.
 * Copyright: (C) 2012-2017 Gregor Cramer
 * ====================================================================== */

/*
 * TkDND_XDND.h -- Tk XDND Drag'n'Drop Protocol Implementation
 *
 *		This file implements the unix portion of the drag&drop mechanism
 *		for the tk toolkit. The protocol in use under unix is the
 *		XDND protocol.
 *
 * This software is copyrighted by:
 * Georgios Petasis, Athens, Greece.
 * e-mail: petasisg@yahoo.gr, petasis@iit.demokritos.gr
 *
 * The following terms apply to all files associated
 * with the software unless explicitly disclaimed in individual files.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 *
 * IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
 * DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.	THIS SOFTWARE
 * IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
 * NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS.
 */

#include "tcl.h"
#include "tk.h"
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/X.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>

#define XDND_VERSION 5

#define GNOME_SUPPORT
#define SUPPORT_EMBEDDED_TOPLEVEL
#define USE_CURSORS

#ifndef GNOME_SUPPORT
# ifdef SUPPORT_EMBEDDED_TOPLEVEL
#	undef SUPPORT_EMBEDDED_TOPLEVEL
# endif
#endif

#ifndef PACKAGE_NAME
# define PACKAGE_NAME "tkDND"
#endif

#ifndef PACKAGE_VERSION
# define PACKAGE_VERSION "3.0"
#endif


#ifdef SUPPORT_EMBEDDED_TOPLEVEL

enum { WrapEnter, WrapLeave, WrapPosition, WrapDrop, WrapInitialize };

struct Wrapper
{
	Window win;
	Tk_Window tkwin;
};

typedef struct Wrapper Wrapper;

struct WrapperList
{
	Wrapper* targets;
	unsigned capacity;
	unsigned size;
};

static struct WrapperList wrapperList;

#endif /* SUPPORT_EMBEDDED_TOPLEVEL */


enum DropAction
{
	ActionCopy,		FirstAction = ActionCopy,
	ActionMove,
	ActionLink,
	ActionAsk,
	ActionPrivate, LastAction = ActionPrivate,
	Refuse_Drop,
	ActionDefault
};

static const char* DropAtomNames[] =
{
	"XdndActionCopy",
	"XdndActionMove",
	"XdndActionLink",
	"XdndActionAsk",
	"XdndActionPrivate",
	"XdndActionCopy",	/* refuse will be assigned with XdndActionCopy in XdndPosition */
	"XdndActionCopy", /* default */
};

static const char *DropActions[] =
{
	"copy", "move", "link", "ask", "private", "refuse_drop", "default", NULL
};


static Tk_Window FindTarget(Tk_Window tkwin, XClientMessageEvent* cm, int state);

#ifdef USE_CURSORS
extern Tk_Cursor TkDND_GetCursor(Tcl_Interp *interp, Tcl_Obj *name);
extern void TkDND_InitialiseCursors(Tcl_Interp *interp);
#endif /* USE_CURSORS */


static Tk_Window
TkDND_TkWin(Tcl_Interp* interp, Tcl_Obj* path)
{
	return Tk_NameToWindow(interp, Tcl_GetString(path), Tk_MainWindow(interp));
}


static int
TkDND_Eval(Tcl_Interp* interp, int objc, Tcl_Obj* const* objv)
{
	int i;
	int status;

	for (i = 0; i < objc; ++i)
		Tcl_IncrRefCount(objv[i]);
	status = Tcl_EvalObjv(interp, objc, objv, TCL_EVAL_GLOBAL);
	if (status != TCL_OK)
		Tk_BackgroundError(interp);
	for (i = 0; i < objc; ++i)
		Tcl_DecrRefCount(objv[i]);
	return status;
}


static KeySym
KeycodeToKeysym(Display* display, KeyCode keycode, int index)
{
	int keysyms_per_keycode_return;
	return *XGetKeyboardMapping(display, keycode, 1, &keysyms_per_keycode_return);
}


#ifdef GNOME_SUPPORT

# include <string.h>

# ifdef USE_TKINT_H
#	include "tkInt.h"
# endif

static Tk_Window
GetWmFrameChild(Tk_Window tkwin)
{
	if (!Tk_PathName(tkwin))
	{
		Window xroot;
		Window parent;
		Window* childs;
		unsigned nchilds;

		if (  XQueryTree(Tk_Display(tkwin), Tk_WindowId(tkwin), &xroot, &parent, &childs, &nchilds)
			&& childs)
		{
			/*
			 * This is GNOME. We have to use the child window.
			 */
			if (nchilds == 1)
			{
				tkwin = Tk_IdToWindow(Tk_Display(tkwin), childs[0]);
			}
			else if (nchilds == 2)
			{
				/*
				 * In this case we have to disqualify the menu bar.
				 */
				Tk_Window win1 = Tk_IdToWindow(Tk_Display(tkwin), childs[0]);
				Tk_Window win2 = Tk_IdToWindow(Tk_Display(tkwin), childs[1]);

				char const* p1 = Tk_PathName(win1);
				char const* p2 = Tk_PathName(win2);

				if (p1 && p2)
				{
					char const* s1 = strchr(p1, '#');
					char const* s2 = strchr(p2, '#');

					if (!s1 != !s2)
						tkwin = s1 ? win2 : win1;
				}
			}

			XFree(childs);
		}
	}

	return tkwin;
}


static Tk_Window
CoordsToWindow(int rootX, int rootY, Tk_Window tkwin)
{
	Tk_Window mouse_tkwin;
	int baseX, baseY;
	int childX, childY;

	if (!tkwin || !Tk_PathName(tkwin))
		return NULL; /* something was going wrong */

	Tk_GetRootCoords(tkwin, &childX, &childY);
	baseX = rootX - childX;
	baseY = rootY - childY;
	mouse_tkwin = tkwin;

	while (tkwin)
	{
		int newBaseX = baseX;
		int newBaseY = baseY;

# ifdef USE_TKINT_H

		TkWindow* winPtr = ((TkWindow*) tkwin)->childList;
		tkwin = NULL;

		for ( ; winPtr; winPtr = winPtr->nextPtr)
		{
			if (!(winPtr->flags & TK_ANONYMOUS_WINDOW))
			{
				Tk_Window child = (Tk_Window) winPtr;

				if (Tk_IsMapped(winPtr))
				{
					int width	= Tk_Width(child);
					int height  = Tk_Height(child);

					if (Tk_IsTopLevel(child))
					{
						Tk_GetRootCoords(child, &childX, &childY);

						if (  childX <= rootX
							&& childY <= rootY
							&& rootX < childX + width
							&& rootY < childY + height)
						{
							tkwin = child;
							mouse_tkwin = child;
							newBaseX = rootX - childX;
							newBaseY = rootY - childY;
							break;
						}
					}
					else
					{
						int x = Tk_X(child);
						int y = Tk_Y(child);

						if (  x <= baseX
							&& y <= baseY
							&& baseX < x + width
							&& baseY < y + height)
						{
							tkwin = child;
							mouse_tkwin = child;
							newBaseX = baseX - x;
							newBaseY = baseY - y;

							if (Tk_TopWinHierarchy(child))
								break;
						}
					}
				}
			}
		}

# else /* USE_TKINT_H */

		Tcl_Interp* interp = Tk_Interp(tkwin);
		Tcl_Obj* objv[3];
		Tcl_Obj* result;
		int length, i;

		objv[0] = Tcl_NewStringObj("winfo", -1);
		objv[1] = Tcl_NewStringObj("children", -1);
		objv[2] = Tcl_NewStringObj(Tk_PathName(tkwin), -1);

		if (TkDND_Eval(interp, 3, objv) != TCL_OK)
			return NULL;

		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		tkwin = NULL;

		if (Tcl_ListObjLength(interp, result, &length) == TCL_OK)
		{
			for (i = 0; i < length; ++i)
			{
				Tcl_Obj* path;
				Tk_Window child;

				if (Tcl_ListObjIndex(interp, result, i, &path) == TCL_OK)
				{
					child = Tk_NameToWindow(interp, Tcl_GetString(path), mouse_tkwin);

					if (child && Tk_IsMapped(child))
					{
						int width = Tk_Width(child);
						int height = Tk_Height(child);

						if (Tk_IsTopLevel(child))
						{
							Tk_GetRootCoords(child, &childX, &childY);

							if (  childX <= rootX
								&& childY <= rootY
								&& rootX < childX + width
								&& rootY < childY + height)
							{
								tkwin = child;
								mouse_tkwin = child;
								newBaseX = rootX - childX;
								newBaseY = rootY - childY;
								break;
							}
						}
						else
						{
							int x = Tk_X(child);
							int y = Tk_Y(child);

							if (  x <= baseX
								&& y <= baseY
								&& baseX < x + width
								&& baseY < y + height)
							{
								tkwin = child;
								mouse_tkwin = child;
								newBaseX = baseX - x;
								newBaseY = baseY - y;

								if (Tk_TopWinHierarchy(child))
									break;
							}
						}
					}
				}
			}
		}

		Tcl_DecrRefCount(result);

# endif /* USE_TKINT_H */

		baseX = newBaseX;
		baseY = newBaseY;
	}

	return mouse_tkwin;
}


static Window
GetWmFrame(Tk_Window path)
{
	Tk_Window toplevel = path;
	Display* display = Tk_Display(path);
	Window xroot;
	Window wmFrame;
	Window* childs;
	unsigned nchilds;

	while (!Tk_IsTopLevel(toplevel))
	{
		if (!(toplevel = Tk_Parent(toplevel)))
			return None;
	}

	if (!Tk_IsMapped(toplevel))
		return None; /* What a pitty, no window manager frame exists. */

	if (XQueryTree(display, Tk_WindowId(toplevel), &xroot, &wmFrame, &childs, &nchilds))
	{
		if (wmFrame == xroot)
			wmFrame = None;
		if (childs)
			XFree(childs);
	}

	return wmFrame;
}


static void
ChangeAwarenessProperty(Tk_Window tkwin, Window win)
{
	Atom version = XDND_VERSION;

	XChangeProperty(
		Tk_Display(tkwin),
		win,
		Tk_InternAtom(tkwin, "XdndAware"),
		XA_ATOM, 32,
		PropModeReplace,
		(unsigned char *) &version, 1);
}


static Window
SetWmFrameAware(Tk_Window path)
{
	Window wmFrame = GetWmFrame(path);

	if (wmFrame != None)
	{
		/* Set XdndAware to window manager frame, otherwise GNOME will not work.*/
		ChangeAwarenessProperty(path, wmFrame);
	}

	return wmFrame;
}


static int
IsXdndAware(Tk_Window tkwin)
{
	int format;
	unsigned long count, a;
	unsigned char* data;
	Atom actual = None;

	XGetWindowProperty(
		Tk_Display(tkwin),
		Tk_WindowId(tkwin),
		Tk_InternAtom(tkwin, "XdndAware"),
		0, 0,
		False,
		AnyPropertyType,
		&actual,
		&format, &count, &a, &data);

	if (data)
		XFree(data);

	return actual == XA_ATOM && format == 32 && count > 0 && data;
}

#endif /* GNOME_SUPPORT */


#ifdef SUPPORT_EMBEDDED_TOPLEVEL

#if 0
static void
SetPossiblyWmFrameUnaware(Tk_Window toplevel)
{
	Window wmFrame = GetWmFrame(toplevel);

	if (wmFrame != None && !IsXdndAware(toplevel))
	{
		/* XXX we have to check all sub-windows, whether all are unaware */
		XDeleteProperty(Tk_Display(toplevel), wmFrame, Tk_InternAtom(toplevel, "XdndAware"));
	}
}
#endif /* 0 */

#endif /* SUPPORT_EMBEDDED_TOPLEVEL */


static void
Dict_PutLong(Tcl_Interp* interp, Tcl_Obj* dict, char const* key, long long value)
{
	Tcl_DictObjPut(interp, dict, Tcl_NewStringObj(key, -1), Tcl_NewWideIntObj(value));
}


static void
Dict_PutInt(Tcl_Interp* interp, Tcl_Obj* dict, char const* key, long value)
{
	Tcl_DictObjPut(interp, dict, Tcl_NewStringObj(key, -1), Tcl_NewLongObj(value));
}


static void
Dict_Put(Tcl_Interp* interp, Tcl_Obj* dict, char const* key, char const* value)
{
	Tcl_DictObjPut(interp, dict, Tcl_NewStringObj(key, -1), Tcl_NewStringObj(value, -1));
}


static int
TkDND_RegisterWrapperObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
#ifdef SUPPORT_EMBEDDED_TOPLEVEL

	Tk_Window tkwin;
	Wrapper* entry;

	if (objc != 3)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path");
		return TCL_ERROR;
	}

	tkwin = TkDND_TkWin(interp, objv[1]);
	if (!Tk_IsTopLevel(tkwin))
		return TCL_ERROR;

	if (wrapperList.size == wrapperList.capacity)
	{
		Wrapper* targets = wrapperList.targets;

		wrapperList.capacity = wrapperList.capacity ? 2*wrapperList.capacity : 1;
		wrapperList.targets = malloc(wrapperList.capacity*sizeof(Wrapper));

		if (targets)
		{
			memcpy(wrapperList.targets, targets, wrapperList.size*sizeof(Wrapper));
			free(targets);
		}
	}

	entry = &wrapperList.targets[wrapperList.size++];
	entry->win = SetWmFrameAware(tkwin);
	entry->tkwin = *Tcl_GetString(objv[2]) ? TkDND_TkWin(interp, objv[2]) : tkwin;

#endif /* SUPPORT_EMBEDDED_TOPLEVEL */

	return TCL_OK;
}


#if 0
static int
TkDND_UnregisterWrapperObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
#ifdef SUPPORT_EMBEDDED_TOPLEVEL

	Tk_Window tkwin;
	Window wmFrame;
	unsigned i;

	if (objc != 2)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path");
		return TCL_ERROR;
	}

	wmFrame = GetWmFrame(TkDND_TkWin(interp, objv[1]));

	for (i = 0; i < wrapperList.size; ++i)
	{
		if (wrapperList.targets[i].win == wmFrame)
		{
			memcpy(
				wrapperList.targets + i*sizeof(Wrapper),
				wrapperList.targets + (i + 1)*sizeof(Wrapper),
				(wrapperList.size - i - 1)*sizeof(Wrapper));
			wrapperList.size -= 1;
			SetPossiblyWmFrameUnaware(tkwin, wmFrame);
		}
	}

#endif /* SUPPORT_EMBEDDED_TOPLEVEL */

	return TCL_OK;
}
#endif /* 0 */


static int
TkDND_RegisterTypesObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
	Tk_Window path;

	if (objc != 4)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path toplevel types-list");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;

	Tk_MakeWindowExist(path);
	ChangeAwarenessProperty(path, Tk_WindowId(path));

#ifdef GNOME_SUPPORT

	/*
	 * For GNOME support we have to set the awareness to the window manager
	 * frame, this requires that the toplevel window is already mapped. We
	 * will not do this mapping implicitly, the TCL side should care about this.
	 * One problem remains: if the user is switching the window manager,
	 * the awareness will get lost. Due to the fact that we cannot catch the
	 * ReparentNotify event - this event is encapsulated inside the Tk library -
	 * we have to live with this. Furthermore GNOME's decision is causing much
	 * superfluous X traffic. GNOME's decision for the window manager frame,
	 * which is not belonging to our own process, is nonsense.
	 */

	SetWmFrameAware(path);

#endif /* GNOME_SUPPORT */

	return TCL_OK;
}


static int
TkDND_HandleXdndEnter(Tk_Window tkwin, Tk_Window target, XClientMessageEvent* cm)
{
	Tcl_Interp* interp = Tk_Interp(tkwin);
	Atom typeListBuf[10];
	Atom* typeList = typeListBuf;
	const long *l = cm->data.l;
	int version = (int)(((unsigned long)(l[1])) >> 24);
	unsigned long itemCount = 0;
	int i;
	Window drag_source;
	Tcl_Obj* objv[4];

	if (!interp)
		return False;
	if (version > XDND_VERSION)
		return False;
	if (version < 3)
		return False;

	drag_source = l[0];

	if (l[1] & 0x1UL) /* XdndTypeList */
	{
		Atom actualType = None;
		int actualFormat;
		unsigned long remainingBytes;
		unsigned char* data;

		/* Get the types from XdndTypeList property. */
		XGetWindowProperty(
			cm->display,
			drag_source,
			Tk_InternAtom(tkwin, "XdndTypeList"), 0,
			0x8000000, False, XA_ATOM, &actualType, &actualFormat,
			&itemCount, &remainingBytes, &data);

		if (	actualType != XA_ATOM
			|| actualFormat != 32
			|| itemCount == 0
			|| !data
			|| (	itemCount >= sizeof(typeListBuf)/sizeof(typeListBuf[0])
				&& !(typeList = (Atom *) Tcl_Alloc(sizeof(Atom)*(itemCount + 1)))))
		{
			itemCount = 0;
		}
		else
		{
			for (i = 0; i < itemCount; i++)
				typeList[i] = ((Atom*) data)[i];
			typeList[itemCount] = None;

			if (data)
				XFree(data);
		}
	}

	if (itemCount == 0)
	{
		typeList[0] = cm->data.l[2];
		typeList[1] = cm->data.l[3];
		typeList[2] = cm->data.l[4];
		typeList[3] = None;
	}

	/* We have all the information we need. Its time to pass it at the Tcl level.*/
	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndEnter", -1);
	objv[1] = Tcl_NewStringObj(Tk_PathName(target ? target : tkwin), -1);
	objv[2] = Tcl_NewLongObj(drag_source);
	objv[3] = Tcl_NewListObj(0, NULL);

	for (i = 0; typeList[i] != None; ++i)
	{
		Tcl_ListObjAppendElement(NULL, objv[3],
			Tcl_NewStringObj(Tk_GetAtomName(tkwin, typeList[i]), -1));
	}

	TkDND_Eval(Tk_Interp(tkwin), 4, objv);

	if (typeList != typeListBuf)
		Tcl_Free((char *) typeList);

	return True;
}


static int
TkDND_HandleXdndPosition(Tk_Window tkwin, Tk_Window target, XClientMessageEvent* cm)
{
	Tcl_Interp *interp = Tk_Interp(tkwin);
	Tcl_Obj* result;
	Tcl_Obj* objv[5];
	const unsigned long *l = (const unsigned long *) cm->data.l;
	int rootX, rootY, status;
	int index = Refuse_Drop;
	XClientMessageEvent response;
	int width = 1, height = 1;

	if (!interp)
		return False;

	rootX = (l[2] & 0xffff0000) >> 16;
	rootY = l[2] & 0x0000ffff;

#ifdef GNOME_SUPPORT

	if (!target && !Tk_PathName(tkwin))
	{
		/*
		 * The GNOME shape is confusing Tk_CoordsToWindow(), because this shape has
		 * the root window as parent. What the hell is GNOME doing?
		 */
		target = CoordsToWindow(rootX, rootY, GetWmFrameChild(tkwin));
	}

#endif /* GNOME_SUPPORT */

	if (!target && !(target = Tk_CoordsToWindow(rootX, rootY, tkwin)))
	{
		int dx, dy;
		Tk_GetRootCoords(tkwin, &dx, &dy);
		target = Tk_CoordsToWindow(rootX + dx, rootY + dy, tkwin);
	}

	/*
	 * Ask the Tk widget whether it will accept the drop...
	 */

	if (target)
	{
		objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndPosition", -1);
		objv[1] = Tcl_NewStringObj(Tk_PathName(target), -1);
		objv[2] = Tcl_NewIntObj(rootX);
		objv[3] = Tcl_NewIntObj(rootY);
		objv[4] = Tcl_NewLongObj(cm->data.l[0]);

		if (TkDND_Eval(Tk_Interp(tkwin), 5, objv) != TCL_OK)
			return False;

		/* Get the returned action... */
		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		status = Tcl_GetIndexFromObj(
			interp, result, (const char **) DropActions, "dropactions", 0, &index);
		Tcl_DecrRefCount(result);
		if (status != TCL_OK)
			index = Refuse_Drop;
		if (index >= sizeof(DropAtomNames)/sizeof(DropAtomNames[0]))
			return False;
	}

	/* Send response */
	memset(&response, 0, sizeof(response));
	response.type			   = ClientMessage;
	response.format			= 32;
	response.window			= cm->data.l[0];
	response.message_type	= Tk_InternAtom(tkwin, "XdndStatus");
	response.data.l[0]		= Tk_WindowId(tkwin);
	response.data.l[1]		= 1; /* yes */
	response.data.l[2]		= (rootX << 16) | (rootY  & 0xFFFFUL); /* x, y */
	response.data.l[3]		= (width << 16) | (height & 0xFFFFUL); /* w, h */
	response.data.l[4]		= index == Refuse_Drop ? None : Tk_InternAtom(tkwin, DropAtomNames[index]);
	XSendEvent(cm->display, response.window, False, NoEventMask, (XEvent*) &response);

	return True;
}


static int
TkDND_HandleXdndLeave(Tk_Window tkwin, Tk_Window target, XClientMessageEvent* cm)
{
	Tcl_Interp* interp = Tk_Interp(tkwin);
	Tcl_Obj* objv[1];

	if (!interp)
		return False;

	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndLeave", -1);
	TkDND_Eval(Tk_Interp(tkwin), 1, objv);

	return True;
}


static int
TkDND_HandleXdndDrop(Tk_Window tkwin, Tk_Window target, XClientMessageEvent* cm)
{
	XClientMessageEvent finished;
	Tcl_Interp *interp = Tk_Interp(tkwin);
	Tcl_Obj* objv[2];
	Time time;

	if (!interp)
		return False;

	time = (sizeof(Time) == 8 && cm->data.l[2] < 0) ? (unsigned) cm->data.l[2] : cm->data.l[2];
	memset(&finished, 0, sizeof(finished));

	finished.type			  = ClientMessage;
	finished.format			= 32;
	finished.window			= cm->data.l[0];
	finished.message_type	= Tk_InternAtom(tkwin, "XdndFinished");
	finished.data.l[0]		= Tk_WindowId(tkwin);
	finished.data.l[1]		= 0; /* Drop canceled. */
	finished.data.l[2]		= None;

	/* Call out Tcl callback. */
	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndDrop", -1);
	objv[1] = Tcl_NewLongObj(time);

	if (TkDND_Eval(Tk_Interp(tkwin), 2, objv) == TCL_OK)
	{
		int status, index;
		Tcl_Obj* result;

		/* Get the returned action... */
		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		status = Tcl_GetIndexFromObj(interp, result, (const char **)DropActions, "dropactions", 0, &index);
		Tcl_DecrRefCount(result);

		if (	status != TCL_OK
			&& index != Refuse_Drop
			&& index < sizeof(DropAtomNames)/sizeof(DropAtomNames[0]))
		{
			finished.data.l[1] = 1;
			finished.data.l[2] = Tk_InternAtom(tkwin, DropAtomNames[index]);
		}
	}

	/* Send XdndFinished. */
	XSendEvent(cm->display, finished.window, False, NoEventMask, (XEvent*)&finished);

	return True;
}


static const char*
GetDropAction(
	Tk_Window tkwin,
	int action)
{
	int i;

	for (i = FirstAction; i <= LastAction; ++i)
	{
		if (action == Tk_InternAtom(tkwin, DropAtomNames[i]))
			return DropActions[i];
	}

	return DropActions[Refuse_Drop];
}


static int
TkDND_HandleXdndStatus(Tk_Window tkwin, XClientMessageEvent* cm)
{
	Tcl_Interp* interp = Tk_Interp(tkwin);
	Tcl_Obj* objv[2];

	if (!interp)
		 return False;

	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndStatus", -1);
	objv[1] = Tcl_NewDictObj();

	/* data.l[0] contains the XID of the target window */
	Dict_PutLong(interp, objv[1], "target", cm->data.l[0]);
	/* data.l[1] bit 0 is set if the current target will accept the drop */
	Dict_PutInt (interp, objv[1], "accept", cm->data.l[1] & 0x1L ? 1 : 0);
	/* data.l[1] bit 1 is set if the target wants XdndPosition messages while
	 * the mouse moves inside the rectangle in data.l[2,3] */
	Dict_PutInt (interp, objv[1], "want_position", cm->data.l[1] & 0x2UL ? 1 : 0);
	/* data.l[4] contains the action accepted by the target */
	Dict_Put    (interp, objv[1], "action", GetDropAction(tkwin, cm->data.l[4]));
	Dict_PutInt (interp, objv[1], "x", cm->data.l[2] >> 16);
	Dict_PutInt (interp, objv[1], "y", cm->data.l[2] & 0xffffL);
	Dict_PutInt (interp, objv[1], "w", cm->data.l[3] >> 16);
	Dict_PutInt (interp, objv[1], "h", cm->data.l[3] & 0xffffL);

	TkDND_Eval(interp, 2, objv);
	return True;
}


static int
TkDND_HandleXdndFinished(Tk_Window tkwin, XClientMessageEvent* cm)
{
	Tcl_Interp* interp = Tk_Interp(tkwin);
	Tcl_Obj* objv[2];

	if (!interp)
		return False;

	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndFinished", -1);
	objv[1] = Tcl_NewDictObj();

	/* data.l[0] contains the XID of the target window */
	Dict_PutLong(interp, objv[1], "target", cm->data.l[0]);
	/* data.l[1] bit 0 is set if the current target accepted the drop and
	 *	successfully performed the accepted drop action */
	Dict_PutInt (interp, objv[1], "accept", cm->data.l[1] & 0x1L ? 1 : 0);
	/* data.l[2] contains the action performed by the target */
	Dict_Put    (interp, objv[1], "action", GetDropAction(tkwin, cm->data.l[2]));

	TkDND_Eval(interp, 2, objv);
	return True;
}


static Tk_Window
FindTarget(Tk_Window tkwin, XClientMessageEvent* cm, int state)
{
#ifdef SUPPORT_EMBEDDED_TOPLEVEL

	static Tk_Window currentTarget = NULL;
	static Tk_Window currentWrapper = NULL;
	static XClientMessageEvent enter;

	if (state == WrapInitialize)
	{
		memset(&enter, 0, sizeof(enter));
		return NULL;
	}

	Window win = Tk_WindowId(tkwin);
	Tk_Window wrapper = NULL;
	unsigned i;

	for (i = 0; i < wrapperList.size; ++i)
	{
		if (wrapperList.targets[i].win == win)
		{
			wrapper = wrapperList.targets[i].tkwin;
			break;
		}
	}
	if (!wrapper)
		return NULL;

	switch (state)
	{
		case WrapEnter:
			currentTarget = NULL;
			currentWrapper = wrapper;
			memcpy(&enter, cm, sizeof(enter));
			break;

		case WrapLeave:
			if (currentTarget)
			{
				TkDND_HandleXdndLeave(tkwin, currentTarget, cm);
				currentTarget = NULL;
			}
			currentWrapper = NULL;
			memset(&enter, 0, sizeof(enter));
			break;

		case WrapPosition:
		{
			if (currentWrapper)
			{
				int rootX = (cm->data.l[2] & 0xffff0000) >> 16;
				int rootY = cm->data.l[2] & 0x0000ffff;

				/* Tk_CoordsToWindow() is not working as expected with GNOME. */
				Tk_Window w = CoordsToWindow(rootX, rootY, wrapper);

				while (w && !Tk_IsTopLevel(w) && !IsXdndAware(w))
					w = Tk_Parent(w);
				if (w == tkwin)
					w = NULL;

				if (currentTarget)
				{
					if (!Tk_IsMapped(currentTarget))
					{
						currentTarget = NULL;
					}
					else if (currentTarget != w)
					{
						TkDND_HandleXdndLeave(tkwin, currentTarget, cm);
						currentTarget = NULL;
					}
				}

				if (w != currentTarget && w && IsXdndAware(w))
					TkDND_HandleXdndEnter(tkwin, currentTarget = w, &enter);
			}
			break;
		}

		case WrapDrop:
		{
			Tk_Window target = currentTarget;

			currentTarget = NULL;
			currentWrapper = NULL;
			memset(&enter, 0, sizeof(enter));
			return target;
		}
	}

	return currentTarget;

#else /* SUPPORT_EMBEDDED_TOPLEVEL */

	return NULL;

#endif /* SUPPORT_EMBEDDED_TOPLEVEL */
}


static int
TkDND_XDNDHandler(Tk_Window tkwin, XEvent* xevent)
{
	XClientMessageEvent* clientMessage;

	if (xevent->type != ClientMessage)
		return False;

	clientMessage = &xevent->xclient;

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndPosition"))
	{
		Tk_Window target = FindTarget(tkwin, clientMessage, WrapPosition);
		return TkDND_HandleXdndPosition(tkwin, target, clientMessage);
	}

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndEnter"))
	{
		Tk_Window target = FindTarget(tkwin, clientMessage, WrapEnter);
		return TkDND_HandleXdndEnter(tkwin, target, clientMessage);
	}

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndStatus"))
		return TkDND_HandleXdndStatus(tkwin, clientMessage);

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndLeave"))
	{
		Tk_Window target = FindTarget(tkwin, clientMessage, WrapLeave);
		return TkDND_HandleXdndLeave(tkwin, target, clientMessage);
	}

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndDrop"))
	{
		Tk_Window target = FindTarget(tkwin, clientMessage, WrapDrop);
		return TkDND_HandleXdndDrop(tkwin, target, clientMessage);
	}

	if (clientMessage->message_type == Tk_InternAtom(tkwin, "XdndFinished"))
		return TkDND_HandleXdndFinished(tkwin, clientMessage);

	return False;
}


#ifdef USE_CURSORS

static int
TkDND_SetPointerCursorObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	Tk_Window path;
	Tk_Cursor cursor;

	if (objc != 3)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path cursor");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;

	Tk_MakeWindowExist(path);

	if ((cursor = TkDND_GetCursor(interp, objv[2])) == None)
	{
		Tcl_SetResult(interp, "invalid cursor name: ", TCL_STATIC);
		Tcl_AppendResult(interp, Tcl_GetString(objv[2]));
		return TCL_ERROR;
	}

	if (XChangeActivePointerGrab(
			Tk_Display(path),
			 ButtonPressMask|ButtonReleaseMask|PointerMotionMask|EnterWindowMask|LeaveWindowMask,
			 (Cursor) cursor,
			 CurrentTime) != GrabSuccess)
	{
#if 0
		Tcl_SetResult(interp, "unable to update mouse pointer", TCL_STATIC);
		return TCL_ERROR;
#endif
	}

	return TCL_OK;
}

#endif /* USE_CURSORS */


static void
TkDND_AddStateInformation(Tcl_Interp* interp, Tcl_Obj* dict, unsigned int state)
{
	Dict_PutInt(interp, dict, "state",		state);
	Dict_PutInt(interp, dict, "1",			!!(state & Button1Mask));
	Dict_PutInt(interp, dict, "2",			!!(state & Button2Mask));
	Dict_PutInt(interp, dict, "3",			!!(state & Button3Mask));
	Dict_PutInt(interp, dict, "4",			!!(state & Button4Mask));
	Dict_PutInt(interp, dict, "5",			!!(state & Button5Mask));
	Dict_PutInt(interp, dict, "Mod1",		!!(state & Mod1Mask));
	Dict_PutInt(interp, dict, "Mod2",		!!(state & Mod2Mask));
	Dict_PutInt(interp, dict, "Mod3",		!!(state & Mod3Mask));
	Dict_PutInt(interp, dict, "Mod4",		!!(state & Mod4Mask));
	Dict_PutInt(interp, dict, "Mod5",		!!(state & Mod5Mask));
	Dict_PutInt(interp, dict, "Alt",			!!(state & Mod1Mask));
	Dict_PutInt(interp, dict, "Shift",		!!(state & ShiftMask));
	Dict_PutInt(interp, dict, "Lock",		!!(state & LockMask));
	Dict_PutInt(interp, dict, "Control",	!!(state & ControlMask));
}


static int
TkDND_HandleGenericEvent(ClientData clientData, XEvent* eventPtr)
{
	Tcl_Interp *interp = (Tcl_Interp *) clientData;
	Tcl_Obj *dict;
	Tcl_Obj *objv[2];
	Tcl_Obj *result;
	int status, i;

	if (!interp)
		return 0;

	dict = Tcl_NewDictObj();

	switch (eventPtr->type)
	{
		case MotionNotify:
			Dict_Put    (interp, dict, "type",		"MotionNotify");
			Dict_PutInt (interp, dict, "x",			eventPtr->xmotion.x);
			Dict_PutInt (interp, dict, "y",			eventPtr->xmotion.y);
			Dict_PutInt (interp, dict, "x_root",	eventPtr->xmotion.x_root);
			Dict_PutInt (interp, dict, "y_root",	eventPtr->xmotion.y_root);
			Dict_PutLong(interp, dict, "time",		eventPtr->xmotion.time);
			TkDND_AddStateInformation(interp, dict, eventPtr->xmotion.state);
			break;

		case ButtonPress:
			Dict_Put    (interp, dict, "type",		"ButtonPress");
			Dict_PutInt (interp, dict, "x",			eventPtr->xbutton.x);
			Dict_PutInt (interp, dict, "y",			eventPtr->xbutton.y);
			Dict_PutInt (interp, dict, "x_root",	eventPtr->xbutton.x_root);
			Dict_PutInt (interp, dict, "y_root",	eventPtr->xbutton.y_root);
			Dict_PutLong(interp, dict, "time",		eventPtr->xbutton.time);
			Dict_PutInt (interp, dict, "button",	eventPtr->xbutton.button);
			TkDND_AddStateInformation(interp, dict, eventPtr->xbutton.state);
			break;

		case ButtonRelease:
			Dict_Put    (interp, dict, "type",		"ButtonRelease");
			Dict_PutInt (interp, dict, "x",			eventPtr->xbutton.x);
			Dict_PutInt (interp, dict, "y",			eventPtr->xbutton.y);
			Dict_PutInt (interp, dict, "x_root",	eventPtr->xbutton.x_root);
			Dict_PutInt (interp, dict, "y_root",	eventPtr->xbutton.y_root);
			Dict_PutLong(interp, dict, "time",		eventPtr->xbutton.time);
			Dict_PutInt (interp, dict, "button",	eventPtr->xbutton.button);
			TkDND_AddStateInformation(interp, dict, eventPtr->xbutton.state);
			break;

		case KeyPress:
		{
			KeySym sym = KeycodeToKeysym(Tk_Display(Tk_MainWindow(interp)), eventPtr->xkey.keycode, 0);

			Dict_Put    (interp, dict, "type",		"KeyPress");
			Dict_PutInt (interp, dict, "x",			eventPtr->xkey.x);
			Dict_PutInt (interp, dict, "y",			eventPtr->xkey.y);
			Dict_PutInt (interp, dict, "x_root",	eventPtr->xkey.x_root);
			Dict_PutInt (interp, dict, "y_root",	eventPtr->xkey.y_root);
			Dict_PutLong(interp, dict, "time",		eventPtr->xkey.time);
			Dict_PutInt (interp, dict, "keycode",	eventPtr->xkey.keycode);
			Dict_Put    (interp, dict, "keysym",	XKeysymToString(sym));
			TkDND_AddStateInformation(interp, dict, eventPtr->xkey.state);
			break;
		}

		case KeyRelease:
		{
			KeySym sym = KeycodeToKeysym(Tk_Display(Tk_MainWindow(interp)), eventPtr->xkey.keycode, 0);

			Dict_Put    (interp, dict, "type",		"KeyRelease");
			Dict_PutInt (interp, dict, "x",			eventPtr->xkey.x);
			Dict_PutInt (interp, dict, "y",			eventPtr->xkey.y);
			Dict_PutInt (interp, dict, "x_root",	eventPtr->xkey.x_root);
			Dict_PutInt (interp, dict, "y_root",	eventPtr->xkey.y_root);
			Dict_PutLong(interp, dict, "time",		eventPtr->xkey.time);
			Dict_PutInt (interp, dict, "keycode",	eventPtr->xkey.keycode);
			Dict_Put    (interp, dict, "keysym",	XKeysymToString(sym));
			TkDND_AddStateInformation(interp, dict, eventPtr->xkey.state);
			break;
		}

		case EnterNotify:
			Dict_Put    (interp, dict, "type", "EnterNotify");
			Dict_PutLong(interp, dict, "time", eventPtr->xcrossing.time);
			break;

		case LeaveNotify:
			Dict_Put    (interp, dict, "type", "LeaveNotify");
			Dict_PutLong(interp, dict, "time", eventPtr->xcrossing.time);
			break;

		case SelectionRequest:
		{
			Tk_Window main_window = Tk_MainWindow(interp);
			const char* sel = Tk_GetAtomName(main_window, eventPtr->xselectionrequest.selection);
			const char* target = Tk_GetAtomName(main_window, eventPtr->xselectionrequest.target);
			const char* prop = Tk_GetAtomName(main_window, eventPtr->xselectionrequest.property);

			Dict_Put    (interp, dict, "type",			"SelectionRequest");
			Dict_PutLong(interp, dict, "time",			eventPtr->xselectionrequest.time);
			Dict_PutLong(interp, dict, "owner",			eventPtr->xselectionrequest.owner);
			Dict_PutLong(interp, dict, "requestor",	eventPtr->xselectionrequest.requestor);
			Dict_Put    (interp, dict, "selection",	sel);
			Dict_Put    (interp, dict, "target",		target);
			Dict_Put    (interp, dict, "property",		prop);
			break;
		}

		default:
			Tcl_DecrRefCount(dict);
			return 0;
	}

	/* Call out Tcl callback. */
	objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_process_drag_events", -1);
	objv[1] = dict;
	status = TkDND_Eval(interp, 2, objv);

	if (status == TCL_OK)
	{
		result = Tcl_GetObjResult(interp);
		Tcl_IncrRefCount(result);
		status = Tcl_GetIntFromObj(interp, result, &i);
		Tcl_DecrRefCount(result);
		if (status == TCL_OK)
			return i;
	}
	else
	{
		/* An error occured, stop the drag action... */
		Tcl_SetVar(interp, "::tkdnd::xdnd::_dragging", "0", TCL_GLOBAL_ONLY);
	}

	return 0;
}


static int
TkDND_RegisterGenericEventHandlerObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj *const objv[])
{
	if (objc != 1)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "");
		return TCL_ERROR;
	}
	Tk_CreateGenericHandler(TkDND_HandleGenericEvent, interp);
	return TCL_OK;
}


static int
TkDND_UnregisterGenericEventHandlerObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj* const objv[])
{
	if (objc != 1)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "");
		return TCL_ERROR;
	}
	Tk_DeleteGenericHandler(TkDND_HandleGenericEvent, interp);
	return TCL_OK;
}


static int
TkDND_AnnounceTypeListObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj* const objv[])
{
	Tk_Window path;
	Tcl_Obj** type;
	int status, i, numTypes;
	Atom typeListBuf[10];
	Atom* typeList = typeListBuf;

	if (objc != 3)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path types-list");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;

	if ((status = Tcl_ListObjGetElements(interp, objv[2], &numTypes, &type)) != TCL_OK)
		return status;

	if (	numTypes > sizeof(typeListBuf)/sizeof(typeListBuf[0])
		&& !(typeList = (Atom *) Tcl_Alloc(numTypes*sizeof(Atom))))
	{
		return TCL_ERROR;
	}

	for (i = 0; i < numTypes; ++i)
		typeList[i] = Tk_InternAtom(path, Tcl_GetString(type[i]));

	XChangeProperty(
		Tk_Display(path),
		Tk_WindowId(path),
		Tk_InternAtom(path, "XdndTypeList"),
		XA_ATOM, 32,
		PropModeReplace,
		(unsigned char*) typeList,
		numTypes);

	if (typeList != typeListBuf)
		Tcl_Free((char *) typeList);

	return TCL_OK;
}


static int
TkDND_AnnounceActionListObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc,
	Tcl_Obj* const objv[])
{
	Tk_Window path;
	Tcl_Obj **action;
	Tcl_Obj **description;
	int status, i, actions, descriptions;
	Atom actionlist[10];
	Atom descriptionlist[10];

	if (objc != 4)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path actions-list descriptions-list");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;

	if ((status = Tcl_ListObjGetElements(interp, objv[2], &actions, &action)) != TCL_OK)
		return status;

	if (actions > 10)
	{
		Tcl_SetResult(interp, "too many actions/descriptions", TCL_STATIC);
		return TCL_ERROR;
	}

	if ((status = Tcl_ListObjGetElements(interp, objv[3], &descriptions, &description)) != TCL_OK)
		return status;

	if (actions != descriptions)
	{
		Tcl_SetResult(interp, "number of actions != number of descriptions", TCL_STATIC);
		return TCL_ERROR;
	}

	for (i = 0; i < actions; ++i)
	{
		actionlist[i] = Tk_InternAtom(path, Tcl_GetString(action[i]));
		descriptionlist[i] = Tk_InternAtom(path, Tcl_GetString(description[i]));
	}

	XChangeProperty(
		Tk_Display(path),
		Tk_WindowId(path),
		Tk_InternAtom(path, "XdndActionList"),
		XA_ATOM, 32,
		PropModeReplace,
		(unsigned char*) actionlist, actions);
	XChangeProperty(
		Tk_Display(path),
		Tk_WindowId(path),
		Tk_InternAtom(path, "XdndActionDescription"),
		XA_ATOM, 32,
		PropModeReplace,
		(unsigned char*) descriptionlist, actions);

	return TCL_OK;
}


static int
TkDND_FetchActionListObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
	Tk_Window tkwin;
	Window source;
	Atom actual_type;
	int actual_format;
	unsigned long nitems, bytes_after;
	unsigned char* data = NULL;
	Tcl_Obj* actionlist[5];
	int count = 0;
	int result;

	if (objc != 2)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path");
		return TCL_ERROR;
	}

	tkwin = Tk_MainWindow(interp);
	source = atoi(Tcl_GetString(objv[1]));
	result = XGetWindowProperty(
		Tk_Display(tkwin),
		source,
		Tk_InternAtom(tkwin, "XdndActionList"),
		0, 4096, False, XA_ATOM,
		&actual_type, &actual_format, &nitems, &bytes_after, &data);

	if (result == Success && actual_type != None && data && actual_format == 32)
	{
		Atom atoms[5];
		int i, k;

		memset(atoms, 0, sizeof(atoms));

		for (i = 0; i < nitems; ++i)
		{
			Atom action = ((Atom*) data)[i];

			for (k = FirstAction; k <= LastAction; ++k)
			{ 
				if (atoms[k] == (Atom) 0)
					atoms[k] = Tk_InternAtom(tkwin, DropAtomNames[k]);
				if (action == atoms[k])
					actionlist[count++] = Tcl_NewStringObj(DropActions[k], -1);
			}
		}
	}

	if (data)
		XFree(data);
	Tcl_SetObjResult(interp, Tcl_NewListObj(count, actionlist));

	return TCL_OK;
}


static int
TkDND_FindDropTargetWindowObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj *const objv[])
{
	int rootx, rooty;
	Tk_Window path;
	Window root, src, t;
	Window target = 0;
	int lx = 0, ly = 0, lx2, ly2;
	Display *display;
	Atom XdndAware;
	Atom type = 0;
	int f;
	unsigned long n, a;
	unsigned char *data = 0;

	if (objc != 4)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path rootx rooty");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[2], &rootx) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[3], &rooty) != TCL_OK)
		return TCL_ERROR;

	root = RootWindowOfScreen(Tk_Screen(path));
	display = Tk_Display(path);

	if (!XTranslateCoordinates(display, root, root, rootx, rooty, &lx, &ly, &target))
		return TCL_ERROR;
	if (target == root)
		return TCL_ERROR;

	src = root;
	XdndAware = Tk_InternAtom(path, "XdndAware");

	while (target)
	{
		if (!XTranslateCoordinates(display, src, target, lx, ly, &lx2, &ly2, &t))
		{
			target = 0;
			break; /* Error... */
		}

		lx = lx2;
		ly = ly2;
		src = target;
		type = 0;
		data = NULL;

		/* Check if we can find the XdndAware property... */
		XGetWindowProperty(
			display, target, XdndAware, 0, 0, False, AnyPropertyType, &type, &f, &n, &a, &data);
		if (data)
			XFree(data);
		if (type)
			break; /* We have found a target! */

		/* Find child at the coordinates... */
		if (!XTranslateCoordinates(display, src, src, lx, ly, &lx2, &ly2, &target))
		{
			target = 0;
			break; /* Error */
		}
	}

	if (target)
		Tcl_SetObjResult(interp, Tcl_NewLongObj(target));
	else
		Tcl_ResetResult(interp);

	return TCL_OK;
}


static int
TkDND_FindDropTargetProxyObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj* const objv[])
{
	Window target, proxy;
	Window* proxy_ptr;
	Atom type = None;
	int f;
	unsigned long n, a;
	unsigned char *retval = NULL;
	Display *display;
	Tk_Window path;

	if (objc != 3)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source target");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;

	display = Tk_Display(path);
	proxy = target;
	XGetWindowProperty(
		display,
		target,
		Tk_InternAtom(path, "XdndProxy"), 0, 1,
		False, XA_WINDOW,
		&type, &f, &n, &a, &retval);
	proxy_ptr = (Window *) retval;

	if (type == XA_WINDOW && proxy_ptr)
	{
		proxy = *proxy_ptr;
		XFree(proxy_ptr);
		proxy_ptr = NULL;
		/* Is the XdndProxy property pointing to the same window? */
		XGetWindowProperty(
			display,
			proxy,
			Tk_InternAtom(path, "XdndProxy"), 0, 1,
			False, XA_WINDOW,
			&type, &f, &n, &a, &retval);
		proxy_ptr = (Window *) retval;
		if (type != XA_WINDOW || !proxy_ptr || *proxy_ptr != proxy)
			proxy = target;
	}

	if (proxy_ptr)
		XFree(proxy_ptr);
	Tcl_SetObjResult(interp, Tcl_NewLongObj(proxy));

	return TCL_OK;
}


static int
TkDND_SendXdndEnterObjCmd(
	ClientData clientData,
	Tcl_Interp* interp,
	int objc, Tcl_Obj *const objv[])
{
	XEvent event;
	Tk_Window source;
	Window target, proxy;
	Display *display;
	int types, r, f, flags, status, i;
	int target_version = XDND_VERSION;
	int* tv;
	Atom t = None;
	unsigned long n, a;
	unsigned char* retval;
	Tcl_Obj** type;

	if (objc != 5)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source target proxy types_len");
		return TCL_ERROR;
	}

	if (!(source = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[3], (long *) &proxy) != TCL_OK)
		return TCL_ERROR;
	if ((status = Tcl_ListObjGetElements(interp, objv[4], &types, &type)) != TCL_OK)
		return status;

	display = Tk_Display(source);

	/* Get the XDND version supported by the target... */
	r = XGetWindowProperty(
		display,
		proxy,
		Tk_InternAtom(source, "XdndAware"), 0, 1,
		False, AnyPropertyType,
		&t, &f, &n, &a, &retval);

	if (r != Success)
	{
		Tcl_SetResult(interp, "cannot retrieve XDND version from target", TCL_STATIC);
		return TCL_ERROR;
	}

	if ((tv = (int *) retval))
	{
		if (*tv < target_version)
			target_version = *tv;
		XFree(tv);
	}

	memset(&event, 0, sizeof(event));
	event.type						= ClientMessage;
	event.xclient.window			= target;
	event.xclient.format			= 32;
	event.xclient.message_type	= Tk_InternAtom(source, "XdndEnter");
	event.xclient.data.l[0]		= Tk_WindowId(source);

	flags = target_version << 24;
	if (types > 3)
		flags |= 0x0001;
	event.xclient.data.l[1] = flags;

	for (i = 0; i < types && i < 3; ++i)
		event.xclient.data.l[2 + i] = Tk_InternAtom(source, Tcl_GetString(type[i]));

	XSendEvent(display, proxy, False, NoEventMask, &event);

	return TCL_OK;
}


static int
TkDND_SendXdndPositionObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[])
{
	XEvent event;
	Tk_Window source;
	Window target, proxy;
	int rootx, rooty, status, index;

	if (objc != 7)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source target proxy rootx rooty action");
		return TCL_ERROR;
	}

	if (!(source = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[3], (long *) &proxy) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[4], &rootx) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[5], &rooty) != TCL_OK)
		return TCL_ERROR;

	status = Tcl_GetIndexFromObj(interp, objv[6], (const char **) DropActions, "dropactions", 0, &index);
	if (status != TCL_OK)
		return status;
	if (index >= sizeof(DropAtomNames)/sizeof(DropAtomNames[0]))
		return TCL_ERROR;

	memset(&event, 0, sizeof(event));
	event.type						= ClientMessage;
	event.xclient.window			= target;
	event.xclient.format			= 32;
	event.xclient.message_type	= Tk_InternAtom(source, "XdndPosition");
	event.xclient.data.l[0]		= Tk_WindowId(source);
	event.xclient.data.l[1]		= 0; /* flags */
	event.xclient.data.l[2]		= (rootx << 16) + rooty;
	event.xclient.data.l[3]		= CurrentTime;
	event.xclient.data.l[4]		= Tk_InternAtom(source, DropAtomNames[index]);
	XSendEvent(Tk_Display(source), proxy, False, NoEventMask, &event);

	return TCL_OK;
}


static int
TkDND_SendXdndLeaveObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	XEvent event;
	Tk_Window source;
	Window target, proxy;

	if (objc != 4)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source target proxy");
		return TCL_ERROR;
	}

	if (!(source = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[3], (long *) &proxy) != TCL_OK)
		return TCL_ERROR;

	memset(&event, 0, sizeof(event));
	event.type						= ClientMessage;
	event.xclient.window			= target;
	event.xclient.format			= 32;
	event.xclient.message_type	= Tk_InternAtom(source, "XdndLeave");
	event.xclient.data.l[0]		= Tk_WindowId(source);
	XSendEvent(Tk_Display(source), proxy, False, NoEventMask, &event);

	return TCL_OK;
}


static int
TkDND_SendXdndDropObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	XEvent event;
	Tk_Window source;
	Window target, proxy;

	if (objc != 4)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source target proxy");
		return TCL_ERROR;
	}

	if (!(source = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[3], (long *) &proxy) != TCL_OK)
		return TCL_ERROR;

	memset(&event, 0, sizeof(event));
	event.type						= ClientMessage;
	event.xclient.window			= target;
	event.xclient.format			= 32;
	event.xclient.message_type	= Tk_InternAtom(source, "XdndDrop");
	event.xclient.data.l[0]		= Tk_WindowId(source);
	event.xclient.data.l[2]		= CurrentTime;
	XSendEvent(Tk_Display(source), proxy, False, NoEventMask, &event);

	Tcl_SetObjResult(interp, Tcl_NewLongObj(event.xclient.data.l[2]));
	return TCL_OK;
}


static int
TkDND_XChangePropertyObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	XEvent event;
	Window target;
	Atom property = None;
	Atom type = None;
	int format, numItems, numFields, i;
	Display* display;
	Tk_Window source;
	Time time;
	unsigned char* data = NULL;
	Tcl_Obj** field;

	if (objc != 9)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "source requestor property type format time data data_items");
		return TCL_ERROR;
	}

	if (!(source = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[2], (long *) &target) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[5], &format) != TCL_OK)
		return TCL_ERROR;
	if (format != 8 && format != 16 && format != 32)
	{
		Tcl_SetResult(interp, "unsupported format: not 8, 16 or 32", TCL_STATIC);
		return TCL_ERROR;
	}
	if (Tcl_GetIntFromObj(interp, objv[5], &format) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetLongFromObj(interp, objv[6], (long *) &time) != TCL_OK)
		return TCL_ERROR;
	if (Tcl_GetIntFromObj(interp, objv[8], &numItems) != TCL_OK)
		return TCL_ERROR;

	if (!time)
		time = CurrentTime;

	switch (format)
	{
		case 8:
			data = (unsigned char *) Tcl_GetString(objv[7]);
			break;

		case 16:
		{
			short* propPtr = (short *) Tcl_Alloc(sizeof(short)*numItems);
			char *dummy;

			data = (unsigned char *) propPtr;
			if (Tcl_ListObjGetElements(interp, objv[7], &numFields, &field) != TCL_OK)
				return TCL_ERROR;
			for (i = 0; i < numItems; i++)
				propPtr[i] = (short) strtol(Tcl_GetString(field[i]), &dummy, 0);
			break;
		}

		case 32:
		{
			long *propPtr = (long *) Tcl_Alloc(sizeof(long)*numItems);
			char *dummy;

			data = (unsigned char *) propPtr;
			if (Tcl_ListObjGetElements(interp, objv[7], &numFields, &field) != TCL_OK)
				return TCL_ERROR;
			for (i = 0; i < numItems; i++)
				propPtr[i] = (short) strtol(Tcl_GetString(field[i]), &dummy, 0);
			break;
		}
	}

	display = Tk_Display(source);
	property = Tk_InternAtom(source, Tcl_GetString(objv[3]));
	type = Tk_InternAtom(source, Tcl_GetString(objv[4]));

	XChangeProperty(
		display,
		target,
		property,
		type,
		format,
		PropModeReplace,
		(unsigned char *) data, numItems);

	if (format > 8 && data)
		Tcl_Free((char *) data);

	/* Send selection notify to requestor... */
	memset(&event, 0, sizeof(event));
	event.xselection.type		= SelectionNotify;
	event.xselection.display	= display;
	event.xselection.requestor	= target;
	event.xselection.selection	= Tk_InternAtom(source, "XdndSelection");
	event.xselection.target		= type;
	event.xselection.property	= property;
	event.xselection.time		= time;
	XSendEvent(display, target, False, NoEventMask, &event);

	return TCL_OK;
}


static int
TkDND_GrabPointerObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	Tk_Window path;
	Tk_Cursor cursor;

	if (objc != 3)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path cursor");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;
	Tk_MakeWindowExist(path);

	if ((cursor = TkDND_GetCursor(interp, objv[2])) == None)
	{
		Tcl_SetResult(interp, "invalid cursor name: ", TCL_STATIC);
		Tcl_AppendResult(interp, Tcl_GetString(objv[2]));
		return TCL_ERROR;
	}

	if (XGrabPointer(
			Tk_Display(path),
			Tk_WindowId(path),
			False,
			ButtonPressMask|ButtonReleaseMask|PointerMotionMask|EnterWindowMask|LeaveWindowMask,
			GrabModeAsync,
			GrabModeAsync,
			None,
			(Cursor) cursor,
			CurrentTime) != GrabSuccess)
	{
		Tcl_SetResult(interp, "unable to grab mouse pointer", TCL_STATIC);
		return TCL_ERROR;
	}

	return TCL_OK;
}


static int
TkDND_UngrabPointerObjCmd(ClientData clientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
	Tk_Window path;

	if (objc != 2)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "path");
		return TCL_ERROR;
	}

	if (!(path = TkDND_TkWin(interp, objv[1])))
		return TCL_ERROR;

	XUngrabPointer(Tk_Display(path), CurrentTime);
	return TCL_OK;
}


/*
 * For C++ compilers, use extern "C"
 */
#ifdef __cplusplus
extern "C"
{
#endif
	int Tkdnd_Init(Tcl_Interp* interp);
	int Tkdnd_SafeInit(Tcl_Interp* interp);
#ifdef __cplusplus
}
#endif


static Bool
CreateCmd(Tcl_Interp* interp, const char *cmd, Tcl_ObjCmdProc* proc)
{
	return !!Tcl_CreateObjCommand(interp, cmd, proc, NULL, NULL);
}


int
Tkdnd_Init(Tcl_Interp* interp)
{
	int major, minor, patchlevel;

#ifdef USE_TCL_STUBS
	if (!Tcl_InitStubs(interp, "8.3", 0))
		return TCL_ERROR;
#else /* USE_TCL_STUBS */
	if (!Tcl_PkgRequire(interp, "Tcl", "8.3", 0))
		return TCL_ERROR;
#endif /* USE_TCL_STUBS */
#ifdef USE_TK_STUBS
	if (!Tk_InitStubs(interp, "8.3", 0))
		return TCL_ERROR;
#else /* USE_TK_STUBS */
	if (!Tcl_PkgRequire(interp, "Tk", "8.3", 0))
		return TCL_ERROR;
#endif /* USE_TK_STUBS */

	/*
	 * Get the version, because we really need 8.3.3+.
	 */
	Tcl_GetVersion(&major, &minor, &patchlevel, NULL);
	if (major == 8 && minor == 3 && patchlevel < 3)
	{
		Tcl_SetResult(interp, "tkdnd requires Tk 8.3.3 or greater", TCL_STATIC);
		return TCL_ERROR;
	}

	/* Register the various commands */
	if (!CreateCmd(interp, "::tkdnd::_register_types", TkDND_RegisterTypesObjCmd))
		return TCL_ERROR;

#ifdef SUPPORT_EMBEDDED_TOPLEVEL

	wrapperList.targets = NULL;
	wrapperList.capacity = 0;
	wrapperList.size = 0;
	FindTarget(NULL, NULL, WrapInitialize);

#endif

	/*
	 * Register a wrapper for embedded toplevel windows, required for GNOME support.
	 */
	if (!CreateCmd(interp, "_register_wrapper", TkDND_RegisterWrapperObjCmd))
		return TCL_ERROR;

# if 0
	if (!CreateCmd(interp, "_unregister_wrapper", TkDND_UnregisterWrapperObjCmd))
		return TCL_ERROR;
# endif

	if (!CreateCmd(interp, "_grab_pointer", TkDND_GrabPointerObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_ungrab_pointer", TkDND_UngrabPointerObjCmd))
		return TCL_ERROR;

#ifdef USE_CURSORS

	if (!CreateCmd(interp, "_set_pointer_cursor", TkDND_SetPointerCursorObjCmd))
		return TCL_ERROR;

#endif

	if (!CreateCmd(interp, "_register_generic_event_handler", TkDND_RegisterGenericEventHandlerObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_unregister_generic_event_handler",TkDND_UnregisterGenericEventHandlerObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_announce_type_list", TkDND_AnnounceTypeListObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_fetch_action_list", TkDND_FetchActionListObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_announce_action_list", TkDND_AnnounceActionListObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_find_drop_target_window", TkDND_FindDropTargetWindowObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_find_drop_target_proxy", TkDND_FindDropTargetProxyObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_send_XdndEnter", TkDND_SendXdndEnterObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_send_XdndPosition", TkDND_SendXdndPositionObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_send_XdndLeave", (Tcl_ObjCmdProc*) TkDND_SendXdndLeaveObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "_send_XdndDrop", TkDND_SendXdndDropObjCmd))
		return TCL_ERROR;

	if (!CreateCmd(interp, "XChangeProperty", TkDND_XChangePropertyObjCmd))
		return TCL_ERROR;

	/* Finally, register the XDND Handler... */
	Tk_CreateClientMessageHandler(&TkDND_XDNDHandler);

#ifdef USE_CURSORS
	TkDND_InitialiseCursors(interp);
#endif /* USE_CURSORS */

	Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION);
	return TCL_OK;
}


int
Tkdnd_SafeInit(Tcl_Interp* interp)
{
	return Tkdnd_Init(interp);
}

/* vi:set ts=3 sw=3: */
