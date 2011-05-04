// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

#ifndef __XmuColormap_included
#define __XmuColormap_included

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#ifdef __cplusplus
extern "C" {
#endif

Status
XmuLookupStandardColormap(	Display* dpy,
									int screen,
									VisualID visualid,
									unsigned depth,
									Atom property,
									Bool replace,
									Bool retain);

Status XmuCreateColormap(Display* dpy, XStandardColormap* colormap);
void XmuDeleteStandardColormap(Display* dpy, int screen, Atom property);

XStandardColormap*
XmuStandardColormap(	Display* dpy,
							int screen,
							VisualID visualid,
							unsigned depth,
							Atom property,
							Colormap cmap,
							unsigned long red_max,
							unsigned long green_max,
							unsigned long blue_max);

Status
XmuGetColormapAllocation(	XVisualInfo* vinfo,
									Atom property,
									unsigned long* red_max,
									unsigned long* green_max,
									unsigned long* blue_max);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // __XmuColormap_included

// vi:set ts=3 sw=3:
