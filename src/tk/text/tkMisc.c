/* tkMisc.c
 *
 * Provides some replacement functions to support the integration of
 * the revised text widget in applications/external libraries. Only
 * Tk_FontObjCmd() has not been re-implemented, this means that resolving
 * font names in command "inspect" does not work.
 */

#include "tk.h"
#include "tkInt.h"


typedef struct PixelRep {
    double value;
    int units;
} PixelRep;


#if TK_MAJOR_VERSION > 8 \
	|| (TK_MAJOR_VERSION == 8 \
	    && (TK_MINOR_VERSION > 6 || (TK_MINOR_VERSION == 6 && TK_RELEASE_SERIAL >= 6)))

void
TkSendVirtualEvent(
    Tk_Window target,
    const char *eventName,
    Tcl_Obj *detail)
{
    union {XEvent general; XVirtualEvent virtual;} event;

    memset(&event, 0, sizeof(event));
    event.general.xany.type = VirtualEvent;
    event.general.xany.serial = NextRequest(Tk_Display(target));
    event.general.xany.send_event = False;
    event.general.xany.window = Tk_WindowId(target);
    event.general.xany.display = Tk_Display(target);
    event.virtual.name = Tk_GetUid(eventName);
    event.virtual.user_data = detail;

    Tk_QueueWindowEvent(&event.general, TCL_QUEUE_TAIL);
}

#else

void
TkSendVirtualEvent(
    Tk_Window target,
    const char *eventName)
{
    union {XEvent general; XVirtualEvent virtual;} event;

    memset(&event, 0, sizeof(event));
    event.general.xany.type = VirtualEvent;
    event.general.xany.serial = NextRequest(Tk_Display(target));
    event.general.xany.send_event = False;
    event.general.xany.window = Tk_WindowId(target);
    event.general.xany.display = Tk_Display(target);
    event.virtual.name = Tk_GetUid(eventName);

    Tk_QueueWindowEvent(&event.general, TCL_QUEUE_TAIL);
}

#endif


Tcl_Obj*
TkNewWindowObj(
	Tk_Window tkwin)
{
    return Tcl_NewStringObj(Tk_PathName(tkwin), -1);
}


int
TkpAlwaysShowSelection(
    Tk_Window tkwin)
{
    return ((TkWindow *) tkwin)->mainPtr->alwaysShowSelection;
}


static int
SetPixelFromAny(
    Tcl_Interp *interp,		/* Used for error reporting if not NULL. */
    Tcl_Obj *objPtr,		/* The object to convert. */
    PixelRep *pixelPtr)
{
    const char *string;
    char *rest;
    double d;
    int i, units;

    string = Tcl_GetString(objPtr);

    d = strtod(string, &rest);
    if (rest == string) {
	goto error;
    }
    while ((*rest != '\0') && isspace(UCHAR(*rest))) {
	rest++;
    }

    switch (*rest) {
    case '\0':
	units = -1;
	break;
    case 'm':
	units = 0;
	break;
    case 'c':
	units = 1;
	break;
    case 'i':
	units = 2;
	break;
    case 'p':
	units = 3;
	break;
    default:
	goto error;
    }

    /*
     * Free the old internalRep before setting the new one.
     */

    i = (int) d;
    if ((units < 0) && (i == d)) {
	pixelPtr->value = i;
	pixelPtr->units = -1;
    } else {
	pixelPtr->value = d;
	pixelPtr->units = units;
    }
    return TCL_OK;

  error:
    if (interp != NULL) {
	Tcl_SetObjResult(interp, Tcl_ObjPrintf(
		"bad screen distance \"%.50s\"", string));
	Tcl_SetErrorCode(interp, "TK", "VALUE", "PIXELS", NULL);
    }
    return TCL_ERROR;
}


static int
GetPixelsFromObjEx(
    Tcl_Interp *interp, 	/* Used for error reporting if not NULL. */
    Tk_Window tkwin,
    Tcl_Obj *objPtr,		/* The object from which to get pixels. */
    double *dblPtr)		/* Places to store resulting pixels. */
{
    int result;
    PixelRep pixelRep = { 0.0, -1 };
    double d;
    static const double bias[] = {
	1.0,	10.0,	25.4,	0.35278 /*25.4 / 72.0*/
    };

    result = SetPixelFromAny(interp, objPtr, &pixelRep);
    if (result != TCL_OK) {
	return result;
    }

    d = pixelRep.value;
    if (pixelRep.units >= 0) {
	d *= bias[pixelRep.units] * WidthOfScreen(Tk_Screen(tkwin));
	d /= WidthMMOfScreen(Tk_Screen(tkwin));
    }
    *dblPtr = d;
    return TCL_OK;
}


int
Tk_GetDoublePixelsFromObj(
    Tcl_Interp *interp, 	/* Used for error reporting if not NULL. */
    Tk_Window tkwin,
    Tcl_Obj *objPtr,		/* The object from which to get pixels. */
    double *doublePtr)		/* Place to store resulting pixels. */
{
    double d;
    int result;

    result = GetPixelsFromObjEx(interp, tkwin, objPtr, &d);
    if (result != TCL_OK) {
	return result;
    }
    *doublePtr = d;
    return TCL_OK;
}


int
Tk_FontObjCmd(
    ClientData clientData,	/* Main window associated with interpreter. */
    Tcl_Interp *interp,		/* Current interpreter. */
    int objc,			/* Number of arguments. */
    Tcl_Obj *const objv[])	/* Argument objects. */
{
    return TCL_ERROR; /* not implemented */
}

// vi:set ts=8 sw=4:
