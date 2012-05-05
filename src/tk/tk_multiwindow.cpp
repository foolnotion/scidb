// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2011-2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include "tk_init.h"

#include "tcl_base.h"

#define namespace namespace_	// bug in tcl8.6/tkInt.h
#include "tkInt.h"
#undef namespace

#include "m_types.h"

#include <ctype.h>
#include <assert.h>


#ifndef MAX
# define MIN(a,b)	((a) < (b) ? (a) : (b))
# define MAX(a,b)	((a) < (b) ? (b) : (a))
#endif


// Flag values for "sticky"ness. The 16 combinations subsume the packer's
// notion of anchor and fill.
//
// STICK_NORTH  	This window sticks to the top of its cavity.
// STICK_EAST		This window sticks to the right edge of its cavity.
// STICK_SOUTH		This window sticks to the bottom of its cavity.
// STICK_WEST		This window sticks to the left edge of its cavity.
#define STICK_NORTH		1
#define STICK_EAST		2
#define STICK_SOUTH		4
#define STICK_WEST		8


// forward declaration
struct MultiWindow;

extern "C"
{
	int Tk_MultiWindowObjCmd(ClientData, Tcl_Interp*, int, Tcl_Obj* const []);
}


typedef struct
{
	Tk_OptionTable mwOptions;	// Token for multi window option table.
	Tk_OptionTable slaveOpts;	// Token for slave cget option table.
}
OptionTables;


// One structure of the following type is kept for each window
// managed by a multi window widget.
typedef struct Slave
{
    Tk_Window	tkwin;		// Window being managed.
    int			padx;			// Additional padding requested for slave, in the x dimension.
    int			pady;			// Additional padding requested for slave, in the y dimension.
    Tcl_Obj*	widthObj;	// Tcl_Obj rep's of slave width, to allow for null values.
	 Tcl_Obj*	heightObj;	// Tcl_Obj rep's of slave height, to allow for null values.
    int			width;		// Slave width.
    int			height;		// Slave height.
    int			sticky;		// Sticky string.
    int			hide;			// Controls visibility of pane.
    Tk_Window	after;		// Placeholder for parsing options.
    Tk_Window	before;		// Placeholder for parsing options.

    struct MultiWindow* master; // Multi window managing the window.
}
Slave;


// A data structure of the following type is kept for each multi window widget
// managed by this file:
typedef struct MultiWindow
{
    Tk_Window			tkwin;			// Window that embodies the multi window.
    Tcl_Interp*		interp;			// Interpreter associated with widget.
    Tcl_Command		widgetCmd;		// Token for square's widget command.
    Tk_OptionTable	optionTable;	// Token representing the configuration * specifications.
    Tk_OptionTable	slaveOpts;		// Token for slave cget table.
    Tk_3DBorder		background;		// Background color.
    int					borderWidth;	// Value of -borderwidth option.
    int					relief;			// 3D border effect (TK_RELIEF_RAISED, etc)
    Tcl_Obj*			widthObj;		// Tcl_Obj rep for width.
    Tcl_Obj*			heightObj;		// Tcl_Obj rep for height.
    int					width;			// Width of the widget.
	 int					height;			// Height of the widget.
    Tk_Cursor			cursor;			// Current cursor for window, or None.
    GC					gc;				// Graphics context for copying from off-screen pixmap onto screen.
    Slave**				slaves;			// Pointer to array of Slaves.
    int					numSlaves;		// Number of slaves.
	 int					overlay;			// Overlay flag.
    int					flags;			// Flags for widget; see below.
}
MultiWindow;


// Flags used for multi windows:
//
// REDRAW_PENDING:		Non-zero means a DoWhenIdle handler has been
//				queued to redraw this window.
//
// WIDGET_DELETED:		Non-zero means that the multi window has been,
//				or is in the process of being, deleted.
//
// RESIZE_PENDING:		Non-zero means that the window might need to
//				change its size (or the size of its panes)
//				because of a change in the size of one of its
//				children.
#define REDRAW_PENDING			0x0001
#define WIDGET_DELETED			0x0002
#define REQUESTED_RELAYOUT		0x0004
#define RESIZE_PENDING			0x0008


// declarations
static void MultiWindowReqProc(ClientData, Tk_Window);
static void MultiWindowLostSlaveProc(ClientData, Tk_Window);
static int SetSticky(ClientData, Tcl_Interp*, Tk_Window, Tcl_Obj**, char*, int, char*, int);
static Tcl_Obj* GetSticky(ClientData, Tk_Window, char*, int);
static void RestoreSticky(ClientData, Tk_Window, char*, char*);


static const Tk_GeomMgr multiWindowMgrType =
{
    "multiwindow",				// name
    MultiWindowReqProc,			// requestProc
    MultiWindowLostSlaveProc,	// lostSlaveProc
};


// Information used for objv parsing.
#define GEOMETRY		0x0001


// The following structure contains pointers to functions used for processing
// the custom "-sticky" option for slave windows.
static Tk_ObjCustomOption stickyOption =
{
    "sticky",			/* name */
    SetSticky,			/* setProc */
    GetSticky,			/* getProc */
    RestoreSticky,	/* restoreProc */
    nullptr,			/* freeProc */
    0
};


#if defined(__MacOSX__)
# define NORMAL_BG	"systemWindowBody"
#elif defined(__WIN32__)
# define NORMAL_BG	"SystemButtonFace"
#elif defined(__unix__)
# define NORMAL_BG	"#d9d9d9"
#else
# error "unsupported platform"
#endif

#define DEF_MULTIWINDOW_BG_COLOR		NORMAL_BG
#define DEF_MULTIWINDOW_BG_MONO		"#ffffff"
#define DEF_MULTIWINDOW_BORDERWIDTH	"1"
#define DEF_MULTIWINDOW_OVERLAY		"0"
#define DEF_MULTIWINDOW_CURSOR		""
#define DEF_MULTIWINDOW_HEIGHT		""
#define DEF_MULTIWINDOW_RELIEF		"flat"
#define DEF_MULTIWINDOW_WIDTH			""

static const Tk_OptionSpec optionSpecs[] =
{
    {TK_OPTION_BORDER, "-background", "background", "Background",
	 DEF_MULTIWINDOW_BG_COLOR, -1, Tk_Offset(MultiWindow, background),
	 0, (ClientData)DEF_MULTIWINDOW_BG_MONO},
    {TK_OPTION_SYNONYM, "-bd", nullptr, nullptr,
	 nullptr, 0, -1, 0, (ClientData) "-borderwidth"},
    {TK_OPTION_SYNONYM, "-bg", nullptr, nullptr,
	 nullptr, 0, -1, 0, (ClientData) "-background"},
    {TK_OPTION_PIXELS, "-borderwidth", "borderWidth", "BorderWidth",
	 DEF_MULTIWINDOW_BORDERWIDTH, -1, Tk_Offset(MultiWindow, borderWidth),
	 0, 0, GEOMETRY},
    {TK_OPTION_CURSOR, "-cursor", "cursor", "Cursor",
	 DEF_MULTIWINDOW_CURSOR, -1, Tk_Offset(MultiWindow, cursor),
	 TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_PIXELS, "-height", "height", "Height",
	 DEF_MULTIWINDOW_HEIGHT, Tk_Offset(MultiWindow, heightObj),
	 Tk_Offset(MultiWindow, height), TK_OPTION_NULL_OK, 0, GEOMETRY},
	 {TK_OPTION_BOOLEAN, "-overlay", "overlay", "Overlay",
	 DEF_MULTIWINDOW_OVERLAY, -1, Tk_Offset(MultiWindow, overlay),
	 0, 0, 0},
    {TK_OPTION_RELIEF, "-relief", "relief", "Relief",
	 DEF_MULTIWINDOW_RELIEF, -1, Tk_Offset(MultiWindow, relief), 0, 0, 0},
    {TK_OPTION_PIXELS, "-width", "width", "Width",
	 DEF_MULTIWINDOW_WIDTH, Tk_Offset(MultiWindow, widthObj),
	 Tk_Offset(MultiWindow, width), TK_OPTION_NULL_OK, 0, GEOMETRY},
    {TK_OPTION_END}
};


#define DEF_MULTIWINDOW_PANE_AFTER	""
#define DEF_MULTIWINDOW_PANE_BEFORE	""
#define DEF_MULTIWINDOW_PANE_HEIGHT	""
#define DEF_MULTIWINDOW_PANE_HIDE	"0"
#define DEF_MULTIWINDOW_PANE_PADX	"0"
#define DEF_MULTIWINDOW_PANE_PADY	"0"
#define DEF_MULTIWINDOW_PANE_STICKY	"nsew"
#define DEF_MULTIWINDOW_PANE_WIDTH	""

static const Tk_OptionSpec slaveOptionSpecs[] =
{
    {TK_OPTION_WINDOW, "-after", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_AFTER, -1, Tk_Offset(Slave, after),
	 TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_WINDOW, "-before", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_BEFORE, -1, Tk_Offset(Slave, before),
	 TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_PIXELS, "-height", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_HEIGHT, Tk_Offset(Slave, heightObj),
	 Tk_Offset(Slave, height), TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_BOOLEAN, "-hide", "hide", "Hide",
	 DEF_MULTIWINDOW_PANE_HIDE, -1, Tk_Offset(Slave, hide), 0,0,GEOMETRY},
    {TK_OPTION_PIXELS, "-padx", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_PADX, -1, Tk_Offset(Slave, padx), 0, 0, 0},
    {TK_OPTION_PIXELS, "-pady", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_PADY, -1, Tk_Offset(Slave, pady), 0, 0, 0},
    {TK_OPTION_CUSTOM, "-sticky", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_STICKY, -1, Tk_Offset(Slave, sticky), 0,
	 (ClientData) &stickyOption, 0},
    {TK_OPTION_PIXELS, "-width", nullptr, nullptr,
	 DEF_MULTIWINDOW_PANE_WIDTH, Tk_Offset(Slave, widthObj),
	 Tk_Offset(Slave, width), TK_OPTION_NULL_OK, 0, 0},
    {TK_OPTION_END}
};


//----------------------------------------------------------------------
//
// SendVirtualEvent --
//
// 	Send a virtual event notification to the specified target window.
// 	Equivalent to "event generate $tgtWindow <<$eventName>>"
//
// 	Note that we use Tk_QueueWindowEvent, not Tk_HandleEvent,
// 	so this routine does not reenter the interpreter.
//
//----------------------------------------------------------------------
static void
SendVirtualEvent(Tk_Window tkwin, const char* eventName)
{
    XEvent event;

    memset(&event, 0, sizeof(event));
    event.xany.type = VirtualEvent;
    event.xany.serial = NextRequest(Tk_Display(tkwin));
    event.xany.send_event = False;
    event.xany.window = Tk_WindowId(tkwin);
    event.xany.display = Tk_Display(tkwin);
    ((XVirtualEvent *) &event)->name = Tk_GetUid(eventName);

    Tk_QueueWindowEvent(&event, TCL_QUEUE_TAIL);
}


//----------------------------------------------------------------------
//
// ObjectIsEmpty --
//
//	This function tests whether the string value of an object is empty.
//
// Results:
//	The return value is 1 if the string value of objPtr has length zero,
//	and 0 otherwise.
//
// Side effects:
//	May cause object shimmering, since this function can force a
//	conversion to a string object.
//
//----------------------------------------------------------------------
static int
ObjectIsEmpty(Tcl_Obj* objPtr)	// Object to test, may be nullptr
{
	int length;

	if (objPtr == nullptr)
		return 1;

	if (objPtr->bytes != nullptr)
		return (objPtr->length == 0);

	Tcl_GetStringFromObj(objPtr, &length);
	return length == 0;
}


//----------------------------------------------------------------------
//
// ComputeSlotAddress --
//
//	Given a pointer to the start of a record and the offset of a slot
//	within that record, compute the address of that slot.
//
// Results:
//	If offset is non-negative, returns the computed address; else, returns
//	nullptr.
//
// Side effects:
//	None.
//
//----------------------------------------------------------------------
static char*
ComputeSlotAddress(	char* recordPtr,	// Pointer to the start of a record
							int offset)			// Offset of a slot within that record; may be < 0
{
	return offset >= 0 ? recordPtr + offset : nullptr;
}


//----------------------------------------------------------------------
//
// GetPane --
//
//	Given a token to a Tk window, find the pane that corresponds to that
//	token in a given multi window.
//
// Results:
//	Pointer to the slave structure, or nullptr if the window is not managed
//	by this multi window.
//
// Side effects:
//	None.
//
//----------------------------------------------------------------------
static Slave*
GetPane(	MultiWindow* mw,	// Pointer to the multi window info
			Tk_Window tkwin)		// Window to search for
{
	int i;

	for (i = 0; i < mw->numSlaves; i++)
	{
		if (mw->slaves[i]->tkwin == tkwin)
			return mw->slaves[i];
	}

	return nullptr;
}


//----------------------------------------------------------------------
//
// GetSticky -
//
//	Converts an internal boolean combination of "sticky" bits into a Tcl
//	string obj containing zero or more of n, s, e, or w.
//
// Results:
//	Tcl_Obj containing the string representation of the sticky value.
//
// Side effects:
//	Creates a new Tcl_Obj.
//
//----------------------------------------------------------------------
static Tcl_Obj*
GetSticky(	ClientData clientData,
				Tk_Window tkwin,
				char* recordPtr,			// Pointer to widget record
				int internalOffset)		// Offset within *recordPtr containing the sticky value
{
	char	buffer[5];
	int	sticky		= *(int*)(recordPtr + internalOffset);
	int	count			= 0;

	if (sticky & STICK_NORTH)
		buffer[count++] = 'n';
	if (sticky & STICK_EAST)
		buffer[count++] = 'e';
	if (sticky & STICK_SOUTH)
		buffer[count++] = 's';
	if (sticky & STICK_WEST)
		buffer[count++] = 'w';
	buffer[count] = '\0';

	return Tcl_NewStringObj(buffer, -1);
}


//----------------------------------------------------------------------
//
// SetSticky --
//
//	Converts a Tcl_Obj representing a widgets stickyness into an integer
//	value.
//
// Results:
//	Standard Tcl result.
//
// Side effects:
//	May store the integer value into the internal representation pointer.
//	May change the pointer to the Tcl_Obj to nullptr to indicate that the
//	specified string was empty and that is acceptable.
//
//----------------------------------------------------------------------
static int
SetSticky(	ClientData clientData,
				Tcl_Interp* interp,		// Current interp; may be used for errors
				Tk_Window tkwin,			// Window for which option is being set
				Tcl_Obj** value,			// Pointer to the pointer to the value object.
												// We use a pointer to the pointer because we
												// may need to return a value (nullptr)
				char* recordPtr,			// Pointer to storage for the widget record
				int internalOffset,		// Offset within *recordPtr at which the
												// internal value is to be stored
				char* oldInternalPtr,	// Pointer to storage for the old value
				int flags)					// Flags for the option, set Tk_SetOptions
{
	char* internalPtr	= ComputeSlotAddress(recordPtr, internalOffset);
	int	sticky		= 0;

	if ((flags & TK_OPTION_NULL_OK) && ObjectIsEmpty(*value))
	{
		*value = nullptr;
	}
	else
	{
		// Convert the sticky specifier into an integer value.

		char* string = Tcl_GetString(*value);
		char	c;

		while ((c = toupper(*string++)) != '\0')
		{
			switch (c)
			{
				case 'N': sticky |= STICK_NORTH;	break;
				case 'E': sticky |= STICK_EAST;	break;
				case 'S': sticky |= STICK_SOUTH;	break;
				case 'W': sticky |= STICK_WEST;	break;

				default:
					if (c != ',' && !isspace(c))
					{
						Tcl_ResetResult(interp);
						Tcl_AppendResult(	interp,
												"bad stickyness value \"",
												Tcl_GetString(*value), "\": must be a string ",
												"containing zero or more of n, e, s, and w",
												nullptr);
						return TCL_ERROR;
					}
			}
		}
	}

	if (internalPtr != nullptr)
	{
		*((int*)oldInternalPtr) = *((int*)internalPtr);
		*((int*)internalPtr) = sticky;
	}

	return TCL_OK;
}


//----------------------------------------------------------------------
//
// RestoreSticky --
//
//	Restore a sticky option value from a saved value.
//
// Results:
//	None.
//
// Side effects:
//	Restores the old value.
//
//----------------------------------------------------------------------
static void
RestoreSticky(	ClientData clientData,
					Tk_Window tkwin,
					char* internalPtr,		// Pointer to storage for value
					char* oldInternalPtr)	// Pointer to old value
{
    *(int*)internalPtr = *(int*)oldInternalPtr;
}


//----------------------------------------------------------------------
//
// AdjustForSticky --
//
//	Given the x,y coords of the top-left corner of a pane, the dimensions
//	of that pane, and the dimensions of a slave, compute the x,y coords
//	and actual dimensions of the slave based on the slave's sticky value.
//
// Results:
//	No direct return; sets the x, y, slaveWidth and slaveHeight to correct
//	values.
//
// Side effects:
//	None.
//
//----------------------------------------------------------------------
static void
AdjustForSticky(	int sticky,				// Sticky value; see top of file for definition
						int cavityWidth,		// Width of the cavity
						int cavityHeight,		// Height of the cavity
						int *xPtr,
						int *yPtr,				// Initially, coordinates of the top-left
													// corner of cavity; also return values for
													// actual x, y coords of slave
						int *slaveWidthPtr,	// Slave width
						int *slaveHeightPtr)	// Slave height
{
	int diffx = cavityWidth - *slaveWidthPtr;
	int diffy = cavityHeight - *slaveHeightPtr;

	if ((sticky & STICK_EAST) && (sticky & STICK_WEST))
		*slaveWidthPtr += diffx;

	if ((sticky & STICK_NORTH) && (sticky & STICK_SOUTH))
		*slaveHeightPtr += diffy;

	if (diffx > 0 && !(sticky & STICK_WEST))
		*xPtr += sticky & STICK_EAST ? diffx : diffx/2;

	if (diffy > 0 && !(sticky & STICK_NORTH))
		*yPtr += sticky & STICK_SOUTH ? diffy : diffy/2;
}


//--------------------------------------------------------------
//
// HaveUnhiddenSlave --
//
//	Check if there exists one pane which is not hidden.
//
// Results:
//	Returns whezjer one pane exists which is not hidden.
//
// Side effects:
//	None.
//
//--------------------------------------------------------------
static int
HaveUnhiddenSlave(MultiWindow* mw)
{
	int i;

	for (i = 0; i < mw->numSlaves; ++i)
	{
		if (!mw->slaves[i]->hide)
			return 1;
	}

	return 0;
}


//--------------------------------------------------------------
//
// ArrangePane --
//
//	This function is invoked (using the Tcl_DoWhenIdle mechanism) to
//	re-layout the visible window managed by a multi window. It is
//	invoked at idle time so that a series of pane requests can be
//	merged into a single layout operation.
//
// Results:
//	None.
//
// Side effects:
//	The visible slave of master may get resized or moved.
//
//--------------------------------------------------------------
static void
ArrangePane(ClientData clientData)	// Structure describing parent whose slaves are to be re-layed out
{
	MultiWindow* mw = (MultiWindow*)clientData;

	int doubleBw;
	int paneWidth;
	int paneHeight;
	int slaveWidth;
	int slaveHeight;
	int slaveX;
	int slaveY;

	Slave* slave;

	// If the parent has no slaves anymore, then don't do anything at all:
	// just leave the parent's size as-is. Otherwise there is no way to
	// "relinquish" control over the parent so another geometry manager can
	// take over.

	if (!HaveUnhiddenSlave(mw))
		return;

	Tcl_Preserve((ClientData)mw);

	slave = mw->slaves[0];
	doubleBw = 2*Tk_Changes(slave->tkwin)->border_width;

	slaveX = slave->padx;
	slaveY = slave->pady;
	slaveWidth = slave->width > 0 ? slave->width : Tk_ReqWidth(slave->tkwin) + doubleBw;
	slaveHeight = slave->height > 0 ? slave->height : Tk_ReqHeight(slave->tkwin) + doubleBw;
	paneWidth = (mw->width > 0 ? mw->width : Tk_Width(mw->tkwin)) - 2*slave->padx;
	paneHeight = (mw->height > 0 ? mw->height : Tk_Height(mw->tkwin)) - 2*slave->pady;

	AdjustForSticky(slave->sticky, paneWidth, paneHeight, &slaveX, &slaveY, &slaveWidth, &slaveHeight);

	if (slaveWidth <= 0 || slaveHeight <= 0)
	{
		Tk_UnmaintainGeometry(slave->tkwin, mw->tkwin);
		Tk_UnmapWindow(slave->tkwin);
	}
	else
	{
		Tk_MaintainGeometry(slave->tkwin, mw->tkwin, slaveX, slaveY, slaveWidth, slaveHeight);
	}

	Tcl_Release((ClientData)mw);
}


//----------------------------------------------------------------------
//
// RaiseSlave --
//
// Rotate slaves until wanted slave is at top.
//
//----------------------------------------------------------------------
static void
RaiseSlave(	MultiWindow* mw,	// Information about multi window
				Slave* slave)		// New top slave, use first unhidden slave if zero
{
	int index = 0;
	Slave** slaves;

	if (slave == 0)
	{
		while (index < mw->numSlaves && mw->slaves[index]->hide)
			index++;

		if (index == 0)
			return;
	}
	else
	{
		slave->hide = 0;

		while (mw->slaves[index] != slave)
			index++;
	}

	if (index == mw->numSlaves)
		return;

	slaves = (Slave**)ckalloc(sizeof(Slave*)*mw->numSlaves);
	memcpy(slaves, mw->slaves, sizeof(Slave*)*mw->numSlaves);

	memcpy(mw->slaves, slaves + index, sizeof(Slave*)*(mw->numSlaves - index));
	memcpy(mw->slaves + mw->numSlaves - index, slaves, sizeof(Slave*)*index);

	ckfree((char*)slaves);
}


//----------------------------------------------------------------------
//
// UnmapSlave --
//
// Unmap the specified slave, but leave it managed.
//
//----------------------------------------------------------------------
static void
UnmapSlave(	MultiWindow* mw,	// Information about multi window
				Slave* slave)		// Slave to unmap, use first unhidden slave if zero
{
	if (mw->overlay)
		return;

	if (slave == 0 && mw->numSlaves > 0 && !mw->slaves[0]->hide)
		slave = mw->slaves[0];

	if (slave)
	{
		Tk_UnmaintainGeometry(slave->tkwin, mw->tkwin);
		// Contrary to documentation, Tk_UnmaintainGeometry doesn't always unmap the slave:
		Tk_UnmapWindow(slave->tkwin);
	}
}


//----------------------------------------------------------------------
//
// PlaceSlave --
//
// Set the position and size of a child widget
// based on the current client area and slave options.
//
//----------------------------------------------------------------------
static void
PlaceSlave(	MultiWindow* mw,	// Information about multi window
				Slave* oldSlave)	// Previously mapped slave
{
	if (HaveUnhiddenSlave(mw))
	{
		ArrangePane(mw);

		if (Tk_IsMapped(mw->tkwin))
		{
			Slave* slave = mw->slaves[0];

			Tk_RestackWindow(slave->tkwin, Above, nullptr);
			Tk_MapWindow(slave->tkwin);
		}
	}
}


//--------------------------------------------------------------
//
// DisplayMultiWindow --
//
//	This function redraws the contents of a multi window widget. It is
//	invoked as a do-when-idle handler, so it only runs when there's
//	nothing else for the application to do.
//
// Results:
//	None.
//
// Side effects:
//	Information appears on the screen.
//
//--------------------------------------------------------------
static void
DisplayMultiWindow(ClientData clientData)	// Information about window
{
	MultiWindow*	mw			= (MultiWindow*)clientData;
	Tk_Window		tkwin			= mw->tkwin;
	Pixmap			pixmap;

	mw->flags &= ~REDRAW_PENDING;
	if ((mw->tkwin == nullptr) || !Tk_IsMapped(tkwin))
		return;

	if (mw->flags & REQUESTED_RELAYOUT)
		ArrangePane(clientData);

#ifndef TK_NO_DOUBLE_BUFFERING
	// Create a pixmap for double-buffering, if necessary.
	pixmap = Tk_GetPixmap(	Tk_Display(tkwin),
									Tk_WindowId(tkwin),
									Tk_Width(tkwin),
									Tk_Height(tkwin),
									Tk_Depth(tkwin));
#else
	pixmap = Tk_WindowId(tkwin);
#endif

	// Redraw the widget's background and border.
	Tk_Fill3DRectangle(	tkwin,
								pixmap,
								mw->background,
								0,
								0,
								Tk_Width(tkwin),
								Tk_Height(tkwin),
								mw->borderWidth,
								mw->relief);

#ifndef TK_NO_DOUBLE_BUFFERING
	// Copy the information from the off-screen pixmap onto the screen, then
	// delete the pixmap.

	XCopyArea(	Tk_Display(tkwin),
					pixmap,
					Tk_WindowId(tkwin),
					mw->gc,
					0,
					0,
					(unsigned)Tk_Width(tkwin),
					(unsigned)Tk_Height(tkwin),
					0,
					0);
	Tk_FreePixmap(Tk_Display(tkwin), pixmap);
#endif /* TK_NO_DOUBLE_BUFFERING */
}


//----------------------------------------------------------------------
//
// ComputeGeometry --
//
//	Compute geometry for the multi window, including coordinates of all
//	slave windows and each sash.
//
// Results:
//	None.
//
// Side effects:
//	Recomputes geometry information for a multi window.
//
//----------------------------------------------------------------------
static void
ComputeGeometry(MultiWindow* mw)		// Pointer to the Multi Window structure
{
	int i;
	int clientWidth	= 0;
	int clientHeight	= 0;
	int reqWidth		= 0;
	int reqHeight		= 0;
	int internalBw;

	mw->flags |= REQUESTED_RELAYOUT;

	// Compute max requested size of all slaves:
	for (i = 0; i < mw->numSlaves; i++)
	{
		if (!mw->slaves[i]->hide)
		{
			Tk_Window slaveWindow = mw->slaves[i]->tkwin;

			int doubleBw = 2*Tk_Changes(slaveWindow)->border_width;
			int slaveWidth = Tk_ReqWidth(slaveWindow) + 2*mw->slaves[i]->padx + doubleBw;
			int slaveHeight = Tk_ReqHeight(slaveWindow) + 2*mw->slaves[i]->pady + doubleBw;

			clientWidth = MAX(clientWidth, slaveWidth);
			clientHeight = MAX(clientHeight, slaveHeight);
		}
	}

	// Client width/height overridable by widget options:
	if (mw->widthObj)
		Tcl_GetIntFromObj(nullptr, mw->widthObj, &reqWidth);
	if (mw->heightObj)
		Tcl_GetIntFromObj(nullptr, mw->heightObj, &reqHeight);
	if (reqWidth > 0)
		clientWidth = reqWidth;
	if (reqHeight > 0)
		clientHeight = reqHeight;

	internalBw = Tk_InternalBorderWidth(mw->tkwin);

	clientWidth += internalBw;
	clientHeight += internalBw;

	Tk_GeometryRequest(mw->tkwin, clientWidth, clientHeight);

	if (Tk_IsMapped(mw->tkwin) && !(mw->flags & REDRAW_PENDING))
	{
		mw->flags |= REDRAW_PENDING;
		Tcl_DoWhenIdle(DisplayMultiWindow, (ClientData)mw);
	}
}


//----------------------------------------------------------------------
//
// Unlink --
//
//	Remove a slave from a multi window.
//
// Results:
//	None.
//
// Side effects:
//	The multi window will be scheduled for re-arranging and redrawing.
//
//----------------------------------------------------------------------
static void
Unlink(Slave* slave)		// Window to unlink
{
	MultiWindow *mw = slave->master;
	int i;

	if (mw == nullptr)
		return;

	// Find the specified slave in the multiwindow's list of slaves, then
	// remove it from that list.

	for (i = 0; i < mw->numSlaves; i++)
	{
		if (mw->slaves[i] == slave)
		{
			memmove(mw->slaves + i, mw->slaves + i + 1, sizeof(Slave*)*(mw->numSlaves - i - 1));
			break;
		}
	}

	// Clean out any -after or -before references to this slave

	for (i = 0; i < mw->numSlaves; i++)
	{
		if (mw->slaves[i]->before == slave->tkwin)
			mw->slaves[i]->before = None;

		if (mw->slaves[i]->after == slave->tkwin)
			mw->slaves[i]->after = None;
	}

	mw->flags |= REQUESTED_RELAYOUT;

	if (Tk_IsMapped(mw->tkwin) && !(mw->flags & REDRAW_PENDING))
	{
		mw->flags |= REDRAW_PENDING;
		Tcl_DoWhenIdle(DisplayMultiWindow, (ClientData)mw);
	}

	// Set the slave's master to nullptr, so that we can tell that the slave
	// is no longer attached to any multiwindow.

	slave->master = nullptr;
	mw->numSlaves--;
}


//--------------------------------------------------------------
//
// SlaveStructureProc --
//
//	This function is invoked whenever StructureNotify events occur for a
//	window that's managed by a multi window. This function's only purpose
//	is to clean up when windows are deleted.
//
// Results:
//	None.
//
// Side effects:
//	The multi window slave structure associated with the window
//	is freed, and the slave is disassociated from the multi
//	window which managed it.
//
//--------------------------------------------------------------
static void
SlaveStructureProc(	ClientData clientData,	// Pointer to record describing window item
							XEvent* eventPtr)			// Describes what just happened
{
	Slave*			slave	= (Slave*)clientData;
	MultiWindow*	mw		= slave->master;

	if (eventPtr->type == DestroyNotify)
	{
		Unlink(slave);
		slave->tkwin = nullptr;
		ckfree((char*)slave);
		ComputeGeometry(mw);
	}
}


//----------------------------------------------------------------------
//
// ConfigureSlaves --
//
//	Add or alter the configuration options of a slave in a multi window.
//
// Results:
//	Standard Tcl result.
//
// Side effects:
//	Depends on options; may add a slave to the multi window, may alter the
//	geometry management options of a slave.
//
//----------------------------------------------------------------------
static int
ConfigureSlaves(	MultiWindow* mw,		// Information about multi window
						Tcl_Interp* interp,		// Current interpreter
						int objc,					// Number of arguments
						Tcl_Obj* const objv[])	// Argument objects
{
	int i, j;
	int firstOptionArg;
	int found;
	int index;
	int numNewSlaves;
	int haveLoc;
	int insertIndex;

	Tk_Window	tkwin = nullptr;
	Tk_Window	ancestor;
	Tk_Window	parent;
	Slave**		inserts;
	Slave**		newSlaves;
	Slave			options;

	// Find the non-window name arguments; these are the configure options for
	// the slaves. Also validate that the window names given are legitimate
	// (ie, they are real windows, they are not the multiwindow itself, etc.).

	for (i = 2; i < objc; i++)
	{
		char* arg = Tcl_GetString(objv[i]);

		if (arg[0] == '-')
			break;

		tkwin = Tk_NameToWindow(interp, arg, mw->tkwin);

		if (tkwin == nullptr)
		{
			// Just a plain old bad window;
			// Tk_NameToWindow filled in an error message for us.
			return TCL_ERROR;
		}

		if (tkwin == mw->tkwin)
		{
			// A multiwindow cannot manage itself.
			Tcl_ResetResult(interp);
			Tcl_AppendResult(interp, "can't add ", arg, " to itself", nullptr);
			return TCL_ERROR;
		}

		if (Tk_IsTopLevel(tkwin))
		{
			// A multiwindow cannot manage a toplevel.
			Tcl_ResetResult(interp);
			Tcl_AppendResult(	interp,
									"can't add toplevel ",
									arg,
									" to ",
									Tk_PathName(mw->tkwin),
									nullptr);
			return TCL_ERROR;
		}

		// Make sure the multiwindow is the parent of the slave,
		// or a descendant of the slave's parent.

		parent = Tk_Parent(tkwin);

		for (ancestor = mw->tkwin; ancestor != parent; ancestor = Tk_Parent(ancestor))
		{
			if (Tk_IsTopLevel(ancestor))
			{
				Tcl_ResetResult(interp);
				Tcl_AppendResult(interp, "can't add ", arg, " to ", Tk_PathName(mw->tkwin), nullptr);
				return TCL_ERROR;
			}
		}
	}

	firstOptionArg = i;

	// Pre-parse the configuration options, to get the before/after specifiers
	// into an easy-to-find location (a local variable). Also, check the
	// return from Tk_SetOptions once, here, so we can save a little bit of
	// extra testing in the for loop below.

	memset(&options, 0, sizeof(Slave));

	if (Tk_SetOptions(interp,
							(char*)&options,
							mw->slaveOpts,
							objc - firstOptionArg,
							objv + firstOptionArg,
							mw->tkwin,
							nullptr,
							nullptr) != TCL_OK)
	{
		return TCL_ERROR;
	}

	// If either -after or -before was given, find the numerical index that
	// corresponds to the given window. If both -after and -before are given,
	// the option precedence is: -after, then -before.

	index = -1;
	haveLoc = 0;

	if (options.after != None)
	{
		tkwin = options.after;
		haveLoc = 1;

		for (i = 0; i < mw->numSlaves; i++)
		{
			if (options.after == mw->slaves[i]->tkwin)
			{
				index = i + 1;
				break;
			}
		}
	}
	else if (options.before != None)
	{
		tkwin = options.before;
		haveLoc = 1;

		for (i = 0; i < mw->numSlaves; i++)
		{
			if (options.before == mw->slaves[i]->tkwin)
			{
				index = i;
				break;
			}
		}
	}

	// If a window was given for -after/-before, but it's not a window managed
	// by the multiwindow, throw an error

	if (haveLoc && index == -1)
	{
		Tcl_ResetResult(interp);
		Tcl_AppendResult(	interp,
								"window \"",
								Tk_PathName(tkwin),
								"\" is not managed by ",
								Tk_PathName(mw->tkwin),
								nullptr);
		Tk_FreeConfigOptions((char*)&options, mw->slaveOpts, mw->tkwin);
		return TCL_ERROR;
	}

	// Allocate an array to hold, in order, the pointers to the slave
	// structures corresponding to the windows specified. Some of those
	// structures may already have existed, some may be new.

	inserts = (Slave**)ckalloc(sizeof(Slave*)*(firstOptionArg - 2));
	insertIndex = 0;

	// Populate the inserts array, creating new slave structures as necessary,
	// applying the options to each structure as we go, and, if necessary,
	// marking the spot in the original slaves array as empty (for
	// pre-existing slave structures).

	for (i = 0, numNewSlaves = 0; i < firstOptionArg - 2; i++)
	{
		// We don't check that tkwin is nullptr here, because the pre-pass above
		// guarantees that the input at this stage is good.

		tkwin = Tk_NameToWindow(interp, Tcl_GetString(objv[i + 2]), mw->tkwin);
		found = 0;

		for (j = 0; j < mw->numSlaves; j++)
		{
			if (mw->slaves[j] != nullptr && mw->slaves[j]->tkwin == tkwin)
			{
				Tk_SetOptions(	interp,
									(char*)mw->slaves[j],
									mw->slaveOpts,
									objc - firstOptionArg,
									objv + firstOptionArg,
									mw->tkwin,
									nullptr,
									nullptr);

				found = 1;

				// If the slave is supposed to move, add it to the inserts
				// array now; otherwise, leave it where it is.

				if (index != -1)
				{
					inserts[insertIndex++] = mw->slaves[j];
					mw->slaves[j] = nullptr;
				}
				break;
			}
		}

		// Make sure this slave wasn't already put into the inserts array,
		// i.e., when the user specifies the same window multiple times in a
		// single add commaned.

		for (j = 0; j < insertIndex && !found; j++)
		{
			if (inserts[j]->tkwin == tkwin)
				found = 1;
		}

		if (!found)
		{
			// Create a new slave structure and initialize it. All slaves start
			// out with their "natural" dimensions.

			Slave* slave = (Slave*)ckalloc(sizeof(Slave));
			memset(slave, 0, sizeof(Slave));
			Tk_InitOptions(interp, (char *)slave, mw->slaveOpts, mw->tkwin);
			Tk_SetOptions(	interp,
								(char*)slave,
								mw->slaveOpts,
								objc - firstOptionArg,
								objv + firstOptionArg,
								mw->tkwin,
								nullptr,
								nullptr);
			slave->tkwin = tkwin;
			slave->master = mw;

			// Set up the geometry management callbacks for this slave.

			Tk_CreateEventHandler(	slave->tkwin,
											StructureNotifyMask,
											SlaveStructureProc,
											(ClientData)slave);
			Tk_ManageGeometry(slave->tkwin, &multiWindowMgrType, (ClientData)slave);
			inserts[insertIndex++] = slave;
			numNewSlaves++;
		}
	}

	// Allocate the new slaves array, then copy the slaves into it, in order.

	i = sizeof(Slave*)*(mw->numSlaves + numNewSlaves);
	newSlaves = (Slave**)ckalloc((unsigned)i);
	memset(newSlaves, 0, (size_t)i);

	if (index == -1)
	{
		// If none of the existing slaves have to be moved, just copy the old
		// and append the new.
		memcpy(newSlaves, mw->slaves, sizeof(Slave*)*mw->numSlaves);
		memcpy(newSlaves + mw->numSlaves, inserts, sizeof(Slave*)*numNewSlaves);
	}
	else
	{
		// If some of the existing slaves were moved, the old slaves array
		// will be partially populated, with some valid and some invalid
		// entries. Walk through it, copying valid entries to the new slaves
		// array as we go; when we get to the insert location for the new
		// slaves, copy the inserts array over, then finish off the old slaves
		// array.

		for (i = 0, j = 0; i < index; i++)
		{
			if (mw->slaves[i] != nullptr)
			{
				newSlaves[j] = mw->slaves[i];
				j++;
			}
		}

		memcpy(newSlaves + j, inserts, sizeof(Slave*)*insertIndex);
		j += firstOptionArg - 2;

		for (i = index; i < mw->numSlaves; i++)
		{
			if (mw->slaves[i] != nullptr)
			{
				newSlaves[j] = mw->slaves[i];
				j++;
			}
		}
	}

	// Make the new slaves array the multi window's slave array, and clean up.

	ckfree((char*)mw->slaves);
	ckfree((char*)inserts);
	mw->slaves = newSlaves;

	// Set the multi window's slave count to the new value.

	mw->numSlaves += numNewSlaves;
	Tk_FreeConfigOptions((char*)&options, mw->slaveOpts, mw->tkwin);
	ComputeGeometry(mw);

	return TCL_OK;
}


//----------------------------------------------------------------------
//
// MultiWindowWorldChanged --
//
//	This function is invoked anytime a multi window's world has changed in
//	some way that causes the widget to have to recompute graphics contexts
//	and geometry.
//
// Results:
//	None.
//
// Side effects:
//	Multi window will be relayed out and redisplayed.
//
//----------------------------------------------------------------------
static void
MultiWindowWorldChanged(ClientData instanceData)	// Information about the multi window
{
	XGCValues		gcValues;
	GC					newGC;
	MultiWindow*	mw = (MultiWindow*)instanceData;

	// Allocated a graphics context for drawing the multi window widget
	// elements (background, sashes, etc.) and set the window background.

	gcValues.background = Tk_3DBorderColor(mw->background)->pixel;
	newGC = Tk_GetGC(mw->tkwin, GCBackground, &gcValues);
	if (mw->gc != None)
		Tk_FreeGC(Tk_Display(mw->tkwin), mw->gc);
	mw->gc = newGC;
	Tk_SetWindowBackground(mw->tkwin, gcValues.background);

	// Issue geometry size requests to Tk.

	Tk_SetInternalBorder(mw->tkwin, mw->borderWidth);
	if (mw->width > 0 && mw->height > 0)
		Tk_GeometryRequest(mw->tkwin, mw->width, mw->height);

	// Arrange for the window to be redrawn, if neccessary.

	if (Tk_IsMapped(mw->tkwin) && !(mw->flags & REDRAW_PENDING))
	{
		Tcl_DoWhenIdle(DisplayMultiWindow, (ClientData)mw);
		mw->flags |= REDRAW_PENDING;
	}
}


//----------------------------------------------------------------------
//
// ConfigureMultiWindow --
//
//	This function is called to process an argv/argc list in conjunction
//	with the Tk option database to configure (or reconfigure) a multi
//	window widget.
//
// Results:
//	The return value is a standard Tcl result. If TCL_ERROR is returned,
//	then the interp's result contains an error message.
//
// Side effects:
//	Configuration information, such as colors, border width, etc. get set
//	for mw; old resources get freed, if there were any.
//
//----------------------------------------------------------------------
static int
ConfigureMultiWindow(	Tcl_Interp* interp,		// Used for error reporting
								MultiWindow* mw,		// Information about widget
								int objc,					// Number of arguments
								Tcl_Obj* const objv[])	// Argument values
{
	Tk_SavedOptions savedOptions;
	int typemask = 0;

	if (Tk_SetOptions(interp,
							(char*)mw,
							mw->optionTable,
							objc,
							objv,
							mw->tkwin,
							&savedOptions,
							&typemask) != TCL_OK)
	{
		Tk_RestoreSavedOptions(&savedOptions);
		return TCL_ERROR;
	}

	Tk_FreeSavedOptions(&savedOptions);
	MultiWindowWorldChanged((ClientData)mw);

	// If an option that affects geometry has changed, make a re-layout request.

	if (typemask & GEOMETRY)
		ComputeGeometry(mw);

	return TCL_OK;
}


//--------------------------------------------------------------
//
// MultiWindowWidgetObjCmd --
//
//	This function is invoked to process the Tcl command that corresponds
//	to a widget managed by this module. See the user documentation for
//	details on what it does.
//
// Results:
//	A standard Tcl result.
//
// Side effects:
//	See the user documentation.
//
//--------------------------------------------------------------
static int
MultiWindowWidgetObjCmd(ClientData clientData,	// Information about square widget
								Tcl_Interp* interp,		// Current interpreter
								int objc,					// Number of arguments
								Tcl_Obj* const objv[])	// Argument objects
{
	static const char *optionStrings[] =
	{
		"add", "cget", "configure", "forget", "panecget",
		"paneconfigure", "panes", "raise", "unmap", nullptr,
	};
	enum options
	{
		MW_ADD, MW_CGET, MW_CONFIGURE, MW_FORGET, MW_PANECGET,
		MW_PANECONFIGURE, MW_PANES, MW_RAISE, MW_UNMAP,
	};

	MultiWindow*	mw			= (MultiWindow*)clientData;
	int				result		= TCL_OK;
	Tcl_Obj*			resultObj;
	int				index;
	int				i;

	if (objc < 2)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "option ?arg arg...?");
		return TCL_ERROR;
	}

	if (Tcl_GetIndexFromObj(interp, objv[1], optionStrings, "command", 0, &index) != TCL_OK)
		return TCL_ERROR;

	Tcl_Preserve((ClientData)mw);

	switch ((enum options)index)
	{
		case MW_ADD:
			if (objc < 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "widget ?widget ...?");
				result = TCL_ERROR;
			}
			else
			{
				result = ConfigureSlaves(mw, interp, objc, objv);
			}
			break;

		case MW_CGET:
			if (objc != 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "option");
				result = TCL_ERROR;
			}
			else
			{
				resultObj = Tk_GetOptionValue(	interp,
															(char*)mw,
															mw->optionTable,
															objv[2],
															mw->tkwin);
				if (resultObj == nullptr)
					result = TCL_ERROR;
				else
					Tcl_SetObjResult(interp, resultObj);
			}
			break;

		case MW_CONFIGURE:
			resultObj = nullptr;
			if (objc <= 3)
			{
				resultObj = Tk_GetOptionInfo(	interp,
														(char*)mw,
														mw->optionTable,
														objc == 3 ? objv[2] : nullptr,
														mw->tkwin);
				if (resultObj == nullptr)
					result = TCL_ERROR;
				else
					Tcl_SetObjResult(interp, resultObj);
			}
			else
			{
				result = ConfigureMultiWindow(interp, mw, objc - 2, objv + 2);
			}
			break;

		case MW_FORGET:
			if (objc < 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "widget ?widget ...?");
				result = TCL_ERROR;
			}
			else
			{
				int i;

				// Map successor window if required.
				if (mw->numSlaves > 0)
				{
					for (i = 2; i < objc; i++)
					{
						Tk_Window slaveWindow = Tk_NameToWindow(interp, Tcl_GetString(objv[i]), mw->tkwin);

						if (slaveWindow)
						{
							Slave* slave = GetPane(mw, slaveWindow);

							if (slave == mw->slaves[0])
							{
								int nextVisible = 1;

								while (nextVisible < mw->numSlaves && mw->slaves[nextVisible]->hide)
									++nextVisible;

								if (nextVisible < mw->numSlaves)
								{
									RaiseSlave(mw, mw->slaves[nextVisible]);
									PlaceSlave(mw, slave);
									SendVirtualEvent(mw->tkwin, "MultiwindowPaneRaised");
								}
							}
						}
					}
				}

				// Clean up each window named in the arg list.
				for (i = 2; i < objc; i++)
				{
					Tk_Window slaveWindow = Tk_NameToWindow(interp, Tcl_GetString(objv[i]), mw->tkwin);

					if (slaveWindow)
					{
						Slave* slave = GetPane(mw, slaveWindow);

						if (slave && slave->master)
						{
							Tk_ManageGeometry(slaveWindow, nullptr, (ClientData)nullptr);
							Tk_UnmaintainGeometry(slave->tkwin, mw->tkwin);
							Tk_DeleteEventHandler(	slave->tkwin,
															StructureNotifyMask,
															SlaveStructureProc,
															(ClientData)slave);
							Tk_UnmapWindow(slave->tkwin);
							Unlink(slave);
						}
					}
				}
			}
			break;

			case MW_PANECGET:
				if (objc != 4)
				{
					Tcl_WrongNumArgs(interp, 2, objv, "pane option");
					result = TCL_ERROR;
				}
				else
				{
					Tk_Window tkwin = Tk_NameToWindow(interp, Tcl_GetString(objv[2]), mw->tkwin);

					if (tkwin == nullptr)
					{
						result = TCL_ERROR;
					}
					else
					{
						resultObj = nullptr;

						for (i = 0; i < mw->numSlaves; i++)
						{
							if (mw->slaves[i]->tkwin == tkwin)
							{
								resultObj = Tk_GetOptionValue(interp,
																		(char*)mw->slaves[i],
																		mw->slaveOpts,
																		objv[3],
																		tkwin);
							}
						}

						if (i == mw->numSlaves)
							Tcl_SetResult(interp, const_cast<char*>("not managed by this window"), TCL_STATIC);

						if (resultObj == nullptr)
							result = TCL_ERROR;
						else
							Tcl_SetObjResult(interp, resultObj);
					}
				}
				break;

		case MW_PANECONFIGURE:
			if (objc < 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "pane ?option? ?value option value ...?");
				result = TCL_ERROR;
			}
			else
			{
				resultObj = nullptr;

				if (objc <= 4)
				{
					Tk_Window tkwin = Tk_NameToWindow(interp, Tcl_GetString(objv[2]), mw->tkwin);

					for (i = 0; i < mw->numSlaves; i++)
					{
						if (mw->slaves[i]->tkwin == tkwin)
						{
							resultObj = Tk_GetOptionInfo(	interp,
																	(char*)mw->slaves[i],
																	mw->slaveOpts,
																	objc == 4 ? objv[3] : nullptr,
																	mw->tkwin);
							if (resultObj == nullptr)
								result = TCL_ERROR;
							else
								Tcl_SetObjResult(interp, resultObj);

							break;
						}
					}
				}
				else
				{
					result = ConfigureSlaves(mw, interp, objc, objv);
				}
			}
			break;

		case MW_PANES:
			resultObj = Tcl_NewObj();
			Tcl_IncrRefCount(resultObj);

			for (i = 0; i < mw->numSlaves; i++)
			{
				Tcl_ListObjAppendElement(interp, resultObj,
				Tcl_NewStringObj(Tk_PathName(mw->slaves[i]->tkwin),-1));
			}

			Tcl_SetObjResult(interp, resultObj);
			Tcl_DecrRefCount(resultObj);
			break;

		case MW_RAISE:
			if (objc != 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "widget");
				result = TCL_ERROR;
			}
			else
			{
				Tk_Window tkwin = Tk_NameToWindow(interp, Tcl_GetString(objv[2]), mw->tkwin);

				if (mw->numSlaves > 0 && mw->slaves[0]->tkwin != tkwin)
				{
					Slave* slave	= mw->slaves[0];
					Slave* visible	= GetPane(mw, tkwin);

					if (visible)
					{
						RaiseSlave(mw, visible);
						PlaceSlave(mw, slave);
						UnmapSlave(mw, slave);
						SendVirtualEvent(mw->tkwin, "MultiwindowPaneRaised");
					}
				}
			}
			break;

		case MW_UNMAP:
			if (objc < 3)
			{
				Tcl_WrongNumArgs(interp, 2, objv, "widget ?widget ...?");
				result = TCL_ERROR;
			}
			else
			{
				int i;

				for (i = 2; i < objc; i++)
				{
					Tk_Window slaveWindow = Tk_NameToWindow(interp, Tcl_GetString(objv[i]), mw->tkwin);

					if (slaveWindow)
					{
						Slave* slave = GetPane(mw, slaveWindow);

						if (slave && Tk_IsMapped(slave->tkwin))
						{
							Tk_UnmaintainGeometry(slave->tkwin, mw->tkwin);
							Tk_UnmapWindow(slave->tkwin);
						}
					}
				}
			}
			break;
	}

	Tcl_Release((ClientData)mw);
	return result;
}


//----------------------------------------------------------------------
//
// DestroyMultiWindow --
//
//	This function is invoked by MultiWindowEventProc to free the internal
//	structure of a multi window.
//
// Results:
//	None.
//
// Side effects:
//	Everything associated with the multi window is freed up.
//
//----------------------------------------------------------------------
static void
DestroyMultiWindow(MultiWindow* mw)		// Info about multi window widget
{
	int i;

	// First mark the widget as in the process of being deleted, so that any
	// code that causes calls to other multi window functions will abort.

	mw->flags |= WIDGET_DELETED;

	// Cancel idle callbacks for redrawing the widget and for rearranging the panes.

	if (mw->flags & REDRAW_PENDING)
		Tcl_CancelIdleCall(DisplayMultiWindow, (ClientData)mw);

	if (mw->flags & RESIZE_PENDING)
		Tcl_CancelIdleCall(ArrangePane, (ClientData)mw);

	if (mw->gc)
		Tk_FreeGC(Tk_Display(mw->tkwin), mw->gc);

	// Clean up the slave list; foreach slave:
	//  o  Cancel the slave's structure notification callback
	//  o  Cancel geometry management for the slave.
	//  o  Free memory for the slave

	for (i = 0; i < mw->numSlaves; i++)
	{
		Tk_DeleteEventHandler(	mw->slaves[i]->tkwin,
										StructureNotifyMask,
										SlaveStructureProc,
										(ClientData)mw->slaves[i]);
		Tk_ManageGeometry(mw->slaves[i]->tkwin, nullptr, nullptr);
		Tk_FreeConfigOptions((char*)mw->slaves[i], mw->slaveOpts, mw->tkwin);
		ckfree((char*)mw->slaves[i]);
		mw->slaves[i] = nullptr;
	}

	if (mw->slaves)
		ckfree((char*)mw->slaves);

	// Remove the widget command from the interpreter.
	Tcl_DeleteCommandFromToken(mw->interp, mw->widgetCmd);

	// Let Tk_FreeConfigOptions clean up the rest.

	Tk_FreeConfigOptions((char*)mw, mw->optionTable, mw->tkwin);
	Tcl_Release((ClientData)mw->tkwin);
	mw->tkwin = nullptr;
	Tcl_EventuallyFree((ClientData)mw, TCL_DYNAMIC);
}


//--------------------------------------------------------------
//
// MultiWindowEventProc --
//
//	This function is invoked by the Tk dispatcher for various events on
//	multi windows.
//
// Results:
//	None.
//
// Side effects:
//	When the window gets deleted, internal structures get cleaned up. When
//	it gets exposed, it is redisplayed.
//
//--------------------------------------------------------------
static void
MultiWindowEventProc(ClientData clientData,	// Information about window
    						XEvent* eventPtr)			// Information about event
{
	MultiWindow* mw = (MultiWindow*)clientData;

	switch (eventPtr->type)
	{
		case ConfigureNotify:
			mw->flags |= REQUESTED_RELAYOUT;
			// fallthru

		case Expose:
			if (mw->tkwin != nullptr && !(mw->flags & REDRAW_PENDING))
			{
				Tcl_DoWhenIdle(DisplayMultiWindow, (ClientData)mw);
				mw->flags |= REDRAW_PENDING;
			}
			break;

		case DestroyNotify:
			DestroyMultiWindow(mw);
			break;

		case MapNotify:
			RaiseSlave(mw, 0);
			PlaceSlave(mw, 0);
			break;

		case UnmapNotify:
			UnmapSlave(mw, 0);
			break;
	}
}


//----------------------------------------------------------------------
//
// MultiWindowCmdDeletedProc --
//
//	This function is invoked when a widget command is deleted. If the
//	widget isn't already in the process of being destroyed, this command
//	destroys it.
//
// Results:
//	None.
//
// Side effects:
//	The widget is destroyed.
//
//----------------------------------------------------------------------
static void
MultiWindowCmdDeletedProc(ClientData clientData)	// Pointer to widget record for widget
{
	MultiWindow* mw = (MultiWindow*)clientData;

	// This function could be invoked either because the window was destroyed
	// and the command was then deleted or because the command was deleted,
	// and then this function destroys the widget. The WIDGET_DELETED flag
	// distinguishes these cases.

	if (!(mw->flags & WIDGET_DELETED))
		Tk_DestroyWindow(mw->tkwin);
}


//----------------------------------------------------------------------
//
// DestroyOptionTables --
//
//	This function is registered as an exit callback when the multi window
//	command is first called. It cleans up the OptionTables structure
//	allocated by that command.
//
// Results:
//	None.
//
// Side effects:
//	Frees memory.
//
//----------------------------------------------------------------------
static void
DestroyOptionTables(	ClientData clientData,	// Pointer to the OptionTables struct
							Tcl_Interp* interp)		// Pointer to the calling interp
{
	ckfree((char*)clientData);
}


//--------------------------------------------------------------
//
// MultiWindowReqProc --
//
//	This function is invoked by Tk_GeometryRequest for windows managed by
//	a multi window.
//
// Results:
//	None.
//
// Side effects:
//	Arranges for tkwin, and all its managed siblings, to be re-arranged at
//	the next idle point.
//
//--------------------------------------------------------------
static void
MultiWindowReqProc(	ClientData clientData,	// Multi window's information about window
				 											// that got new preferred geometry
							Tk_Window tkwin)			// Other Tk-related information about the window
{
	Slave*			slave	= (Slave*)clientData;
	MultiWindow*	mw		= (MultiWindow*)slave->master;

	if (Tk_IsMapped(mw->tkwin))
	{
		if (!(mw->flags & RESIZE_PENDING))
		{
			mw->flags |= RESIZE_PENDING;
			Tcl_DoWhenIdle(ArrangePane, (ClientData)mw);
		}
	}
	else
	{
		ComputeGeometry(mw);
	}
}


//--------------------------------------------------------------
//
// MultiWindowLostSlaveProc --
//
//	This function is invoked by Tk whenever some other geometry claims
//	control over a slave that used to be managed by us.
//
// Results:
//	None.
//
// Side effects:
//	Forgets all information about the slave. Causes geometry to be
//	recomputed for the multiwindow.
//
//--------------------------------------------------------------
static void
MultiWindowLostSlaveProc(	ClientData clientData,	// Grid structure for slave window that was
				 													// stolen away
									Tk_Window tkwin)			// Tk's handle for the slave window
{
    Slave*			slave	= (Slave*)clientData;
    MultiWindow*	mw		= (MultiWindow*)slave->master;

    if (mw->tkwin != Tk_Parent(slave->tkwin))
		Tk_UnmaintainGeometry(slave->tkwin, mw->tkwin);

    Unlink(slave);
    Tk_DeleteEventHandler(	slave->tkwin,
	 								StructureNotifyMask,
									SlaveStructureProc,
									(ClientData)slave);
    Tk_UnmapWindow(slave->tkwin);
    slave->tkwin = nullptr;
    ckfree((char*)slave);
    ComputeGeometry(mw);
}


//--------------------------------------------------------------
//
// Tk_MultiWindowObjCmd --
//
//	This function is invoked to process the "multiwindow" Tcl command. It
//	creates a new "multiwindow" widget.
//
// Results:
//	A standard Tcl result.
//
// Side effects:
//	A new widget is created and configured.
//
//--------------------------------------------------------------
int
Tk_MultiWindowObjCmd(	ClientData clientData,	// nullptr
    							Tcl_Interp* interp,		// Current interpreter
    							int objc,					// Number of arguments
    							Tcl_Obj* const objv[])	// Argument objects
{
	MultiWindow*	mw;
	Tk_Window		tkwin;
	OptionTables*	mwOpts;

	if (objc < 2)
	{
		Tcl_WrongNumArgs(interp, 1, objv, "pathName ?options?");
		return TCL_ERROR;
	}

	tkwin = Tk_CreateWindowFromPath(interp, Tk_MainWindow(interp), Tcl_GetString(objv[1]), nullptr);
	if (tkwin == nullptr)
		return TCL_ERROR;

	mwOpts = (OptionTables*)Tcl_GetAssocData(interp, "MultiWindowOptionTables", nullptr);
	if (mwOpts == nullptr)
	{
		// The first time this function is invoked, the option tables will be
		// nullptr. We then create the option tables from the templates and store
		// a pointer to the tables as the command's clinical so we'll have
		// easy access to it in the future.

		mwOpts = (OptionTables*)ckalloc(sizeof(OptionTables));

		// Set up an exit handler to free the optionTables struct.
		Tcl_SetAssocData(interp, "MultiWindowOptionTables", DestroyOptionTables, (ClientData)mwOpts);

		// Create the multi window option tables.
		mwOpts->mwOptions = Tk_CreateOptionTable(interp, optionSpecs);
		mwOpts->slaveOpts = Tk_CreateOptionTable(interp, slaveOptionSpecs);
	}

	Tk_SetClass(tkwin, "Multiwindow");

	// Allocate and initialize the widget record.
	mw = (MultiWindow*)ckalloc(sizeof(MultiWindow));
	memset((void*)mw, 0, sizeof(MultiWindow));
	mw->tkwin = tkwin;
	mw->interp = interp;
	mw->widgetCmd = Tcl_CreateObjCommand(
								interp,
								Tk_PathName(mw->tkwin),
								MultiWindowWidgetObjCmd,
								(ClientData)mw,
								MultiWindowCmdDeletedProc);
	mw->optionTable = mwOpts->mwOptions;
	mw->slaveOpts = mwOpts->slaveOpts;
	mw->relief = TK_RELIEF_RAISED;
	mw->gc = None;
	mw->cursor = None;
	mw->overlay = 0;

	// Keep a hold of the associated tkwin until we destroy the widget,
	// otherwise Tk might free it while we still need it.

	Tcl_Preserve((ClientData)mw->tkwin);

	if (Tk_InitOptions(interp, (char*)mw, mwOpts->mwOptions, tkwin) != TCL_OK)
	{
		Tk_DestroyWindow(mw->tkwin);
		return TCL_ERROR;
	}

	Tk_CreateEventHandler(	mw->tkwin,
									ExposureMask|StructureNotifyMask,
									MultiWindowEventProc,
									(ClientData)mw);

	if (ConfigureMultiWindow(interp, mw, objc - 2, objv + 2) != TCL_OK)
	{
		Tk_DestroyWindow(mw->tkwin);
		return TCL_ERROR;
	}

	Tcl_SetStringObj(Tcl_GetObjResult(interp), Tk_PathName(mw->tkwin), -1);
	return TCL_OK;
}


//----------------------------------------------------------------------
//
// Initialization
//
//----------------------------------------------------------------------
void
tk::multiwindow_init(Tcl_Interp *interp)
{
	Tcl_PkgProvide(interp, "tkmultiwindow", "1.0");
	::tcl::createCommand(interp, "::tk::multiwindow", Tk_MultiWindowObjCmd);
}

// vi:set ts=3 sw=3:
