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

#include "m_assert.h"
#include "m_string.h"

#ifdef override
# undef override
#endif

#include <tcl.h>
#include <tk.h>
#include <string.h>


#if defined(__WIN32__) || (defined(__unix__) && !defined(__MacOSX__))

extern "C" { int TclRenameCommand(Tcl_Interp* ti, char const* oldName, char const* newName); }

static Tcl_Obj* m_renamedCmd = 0;

static int
invokeTkSelection(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* objs[objc];
	memcpy(objs, objv, objc*sizeof(Tcl_Obj*));
	objs[0] = m_renamedCmd;
	return Tcl_EvalObjv(ti, objc, objs, 0);
}

# if defined(__WIN32__)

#  include <windows.h>

#  ifndef XA_STRING
#   define XA_STRING CF_TEXT
#  endif

static bool
selectionGet(Tcl_Interp* ti, Tk_Window tkwin, Atom selection, Atom target, unsigned long)
{
	bool rc = false;

	if (OpenClipboard(0))
	{
		if (target == Tk_InternAtom(tkwin, "CF_HDROP"))
		{
			if (IsClipboardFormatAvailable(CF_HDROP))
			{
				HGLOBAL handle = GetClipboardData(CF_HDROP);

				if (handle)
				{
					// This stuff should work due to the Windows specification,
					// but for any reasons it isn't working. Only Microsoft
					// knows why.
					//
					// It seems that DragQueryFileW(hdrop, 0, ...) gives a space
					// separated list of file names, which are bracketed in curly
					// spaces iff the file name contains a space; e.g:
					// "{fst file.pgn} snd-file.pgn".
					//
					// Probably it is possible to interpret hdrop as a file list:
					// Tcl_UniChar const* files = static_cast<Tcl_UniChar const*>(GlobalLock(handle));

					HDROP hdrop = static_cast<HDROP>(GlobalLock(handle));
					int count = DragQueryFileW(hdrop, static_cast<unsigned>(-1), 0, 0);
					mstl::string result;

					result.reserve(count*50);

					for (int i = 0; i < count; ++i)
					{
						Tcl_UniChar buffer[1024];

						if (int len = DragQueryFileW(	hdrop,
																i,
																reinterpret_cast<TCHAR*>(buffer),
																sizeof(buffer)/sizeof(buffer[0])))
						{
							Tcl_UniChar const* s = buffer;
							Tcl_UniChar const* e = s + len;

							for ( ; s < e; ++s)
							{
								char buf[6];
								result.append(buf, Tcl_UniCharToUtf(*s, buf));
							}

							result.append('\n'); // should we use "\r\n"?
						}
					}

					Tcl_SetObjResult(ti, Tcl_NewStringObj(result, result.size()));
					GlobalUnlock(handle);
					rc = true;
				}
			}
		}

		CloseClipboard();
	}
	else
	{
		Tcl_AppendResult(	ti,
								Tk_GetAtomName(tkwin, selection),
								" selection doesn't exist or form \"",
								Tk_GetAtomName(tkwin, target), "\" not defined",
								nullptr);
	}

	return rc;
}

# endif // __WIN32__

# if defined(__unix__)

#  include "m_utility.h"

#  include <X11/Xatom.h>
#  include <ctype.h>
#  include <stdlib.h>


static bool m_selectionRetrieved = false;
static bool m_timeOut = true;


inline unsigned
valToXDigit(unsigned v)
{
	return v + (v < 10 ? unsigned('0') : unsigned('A' - 10));
}


inline unsigned
xdigitToVal(unsigned char c)
{
	return isdigit(c) ? c - '0' : toupper(c) - 'A' + 10;
}


static char*
mapToUnixNewline(char* s, char const* e)
{
	char const* p = s;

	while (p < e)
	{
		if (p[0] == '\r' && p + 1 < e && p[1] == '\n')
		{
			*s++ = '\n';
			p += 2;
		}
		else
		{
			*s++ = *p++;
		}
	}

	return s;
}


static unsigned
quoteChars(char* src, char const* end, char* dst)
{
	char* buf = dst;

	for ( ; src < end; ++src)
	{
		switch (char c = *src)
		{
			case '\r':
			case '\n':
				*dst ++= c;
				break;

			default:
				if (0x20 <= c && c < 0x80 && c != '%')
				{
					*dst++ = c;
				}
				else
				{
					*dst++ = '%';
					*dst++ = valToXDigit(c >> 4);
					*dst++ = valToXDigit(c & 0xf0);
				}
				break;
		}
	}

	return dst - buf;
}


static char*
unquoteChars(char* s, char const* e)
{
	char* p = s;

	while (s < e)
	{
		if (*s != '%')
		{
			*p++ = *s++;
		}
		else if (isxdigit(s[1]) && isxdigit(s[2]))
		{
			*p++ = (xdigitToVal(s[1]) << 4) + xdigitToVal(s[2]);
			s += 3;
		}
		else
		{
			// Ooops, this shouldn't happen.
			*p++ = *s++;
		}
	}

	return p;
}


static int
selEventProc(Tk_Window tkwin, XEvent* eventPtr)
{
	char*	propInfo	= 0;
	Atom	type;
	int	format;

	unsigned long numItems = 0;
	unsigned long bytesAfter;

	if (m_timeOut)
		return 1; // we don't expect a selection

	if (eventPtr->xselection.property == None)
		return 0; // this may happen sporadically

	int result = XGetWindowProperty(	eventPtr->xselection.display,
												eventPtr->xselection.requestor,
												eventPtr->xselection.property,
												0,
												100000,
												False,
												AnyPropertyType,
												&type,
												&format,
												&numItems,
												&bytesAfter,
												reinterpret_cast<unsigned char**>(&propInfo));

	int done = 0;

	if (result == Success && propInfo != 0 && type != None && bytesAfter == 0 && format == 8)
	{
		Atom xaPlainTextUtf8		= 0;
		Atom xaPlainTextLatin1	= 0;
		Atom xaUriList				= 0;
		Atom xaQIconList			= 0;
		Atom xaHtmlUtf8			= 0;
		Atom xaHtmlLatin1			= 0;

		if (	type == Tk_InternAtom(tkwin, "text/plain")
			|| type == Tk_InternAtom(tkwin, "text/html")
			|| type == Tk_InternAtom(tkwin, "text/x-moz-url")
			|| type == (xaHtmlUtf8			= Tk_InternAtom(tkwin, "text/html;charset=UTF-8"))
			|| type == (xaHtmlLatin1		= Tk_InternAtom(tkwin, "text/html;charset=ISO-8859-1"))
			|| type == (xaPlainTextUtf8	= Tk_InternAtom(tkwin, "text/plain;charset=UTF-8"))
			|| type == (xaPlainTextLatin1	= Tk_InternAtom(tkwin, "text/plain;charset=ISO-8859-1"))
			|| type == (xaUriList			= Tk_InternAtom(tkwin, "text/uri-list"))
			|| type == (xaQIconList			= Tk_InternAtom(tkwin, "application/x-qiconlist")))
		{
			while (numItems > 0 && propInfo[numItems - 1] == '\0')
				--numItems;

			numItems = mapToUnixNewline(propInfo, propInfo + numItems) - propInfo;

			if (type == xaPlainTextUtf8 || type == xaHtmlUtf8)
			{
				Tcl_SetObjResult(Tk_Interp(tkwin), Tcl_NewStringObj(propInfo, numItems));
			}
			else if (type == xaPlainTextLatin1 || type == xaPlainTextLatin1 || type == xaQIconList)
			{
				Tcl_DString ds;
				Tcl_Encoding encoding = Tcl_GetEncoding(Tk_Interp(tkwin), "iso8859-1");

				Tcl_ExternalToUtfDString(encoding, propInfo, numItems, &ds);
				Tcl_DStringResult(Tk_Interp(tkwin), &ds);
				Tcl_DStringFree(&ds);
				Tcl_FreeEncoding(encoding);
			}
			else
			{
				Tcl_DString ds;

				if (type == xaUriList)
					numItems = unquoteChars(propInfo, propInfo + numItems) - propInfo;

				Tcl_ExternalToUtfDString(0, propInfo, numItems, &ds);
				Tcl_DStringResult(Tk_Interp(tkwin), &ds);
				Tcl_DStringFree(&ds);
			}

			done = 1;
			m_selectionRetrieved = true;
			m_timeOut = true;
		}
	}
	else if (bytesAfter != 0)
	{
	    Tcl_SetResult(Tk_Interp(tkwin), const_cast<char*>("selection property too large"), TCL_STATIC);
	}

	if (propInfo)
		XFree(propInfo);

	return done;
}


static void
selTimeoutProc(ClientData clientData)
{
	m_timeOut = true;
	Tcl_SetResult(	static_cast<Tcl_Interp*>(clientData),
						const_cast<char*>("selection owner didn't respond"),
						TCL_STATIC);
}


static int
handleSelection(ClientData clientData, XEvent* eventPtr)
{
	if (eventPtr->type == SelectionNotify)
		return selEventProc(Tk_IdToWindow(eventPtr->xany.display, eventPtr->xany.window), eventPtr);

	return 0;
}


static bool
selectionGet(Tcl_Interp* ti, Tk_Window tkwin, Atom selection, Atom target, unsigned long timestamp)
{
	XConvertSelection(Tk_Display(tkwin), selection, target, selection, Tk_WindowId(tkwin), timestamp);
	Tk_CreateGenericHandler(handleSelection, 0);

	Tcl_TimerToken timeout = Tcl_CreateTimerHandler(500, selTimeoutProc, ti);
	m_selectionRetrieved = m_timeOut = false;
	while (!m_timeOut)
		Tcl_DoOneEvent(0);
	Tcl_DeleteTimerHandler(timeout);
	m_timeOut = true;

	Tk_DeleteGenericHandler(handleSelection, 0);
	return m_selectionRetrieved;
}


static int
selectionSend(	Tcl_Interp* ti,
					Tk_Window source,
					Window target,
					Atom selection,
					Atom type,
					Time time,
					Tcl_Obj* data)
{
	int format	= 32;
	int success	= TCL_ERROR;

	Tcl_Encoding encoding = 0;

	if (type == Tk_InternAtom(source, "COMPOUND_TEXT"))
	{
		format = 8;
		encoding = Tcl_GetEncoding(0, "iso2022");
	}
	else if (	type == Tk_InternAtom(source, "text/uri-list")
				|| type == Tk_InternAtom(source, "text/x-moz-url")
				|| type == Tk_InternAtom(source, "text/plain")
				|| type == Tk_InternAtom(source, "text/html"))
	{
		format = 8;
	}
	else if (	type == Tk_InternAtom(source, "STRING")
				|| type == Tk_InternAtom(source, "application/x-qiconlist")
				|| type == Tk_InternAtom(source, "text/plain;charset=ISO-8859-1")
				|| type == Tk_InternAtom(source, "text/html;charset=ISO-8859-1"))
	{
		format = 8;
		encoding = Tcl_GetEncoding(0, "iso8859-1");
	}
	else if (	type == Tk_InternAtom(source, "UTF8_STRING")
				|| type == Tk_InternAtom(source, "text/plain;charset=UTF-8")
				|| type == Tk_InternAtom(source, "text/html;charset=UTF-8"))
	{
		format = 8;
		encoding = Tcl_GetEncoding(0, "utf-8");
	}
	else if (type == Tk_InternAtom(source, "application/x-color"))
	{
		format = 16;
	}

	if (format)
	{
		Tcl_Preserve(ti);

		switch (format)
		{
			case 8:
				{
					int	srcLen;
					char*	src		= Tcl_GetStringFromObj(data, &srcLen);

					Tcl_DString ds;
					Tcl_DStringInit(&ds);

					if (type == Tk_InternAtom(source, "text/uri-list"))
					{
						Tcl_DString buf;

						Tcl_UtfToExternalDString(0, src, srcLen, &buf);
						Tcl_DStringSetLength(&ds, 3*Tcl_DStringLength(&buf));
						Tcl_DStringSetLength(
							&ds,
							quoteChars(
								Tcl_DStringValue(&buf),
								Tcl_DStringValue(&buf) + Tcl_DStringLength(&buf),
								Tcl_DStringValue(&ds)));
						Tcl_DStringFree(&buf);
					}
					else if (encoding == 0 || strcmp(Tcl_GetEncodingName(encoding), "utf-8") != 0)
					{
						Tcl_UtfToExternalDString(encoding, src, srcLen, &ds);
					}

					if (Tcl_DStringLength(&ds) > 0)
					{
						src = Tcl_DStringValue(&ds);
						srcLen = Tcl_DStringLength(&ds);
					}

					XChangeProperty(	
						Tk_Display(source),
						target,
						selection,
						type,
						format,
						PropModeReplace,
						reinterpret_cast<unsigned char*>(src),
						srcLen);

					Tcl_DStringFree(&ds);
					success = TCL_OK;
				}
				break;

			case 16:
				{
					int nfields;
					Tcl_Obj** field;

					if ((success = Tcl_ListObjGetElements(ti, data, &nfields, &field)))
					{
						uint16_t* props = reinterpret_cast<uint16_t*>(ckalloc(sizeof(uint16_t)*nfields));

						for (int i = 0; i< nfields; ++i)
							props[i] = strtol(Tcl_GetString(field[i]), 0, 0);

						XChangeProperty(	
							Tk_Display(source),
							target,
							selection,
							type,
							format,
							PropModeReplace,
							reinterpret_cast<unsigned char*>(props),
							nfields);

						ckfree(reinterpret_cast<char*>(props));
					}
				}
				break;

			case 32:
				{
					int nfields;
					Tcl_Obj** field;

					if ((success = Tcl_ListObjGetElements(ti, data, &nfields, &field)))
					{
						uint32_t* props = reinterpret_cast<uint32_t*>(ckalloc(sizeof(uint32_t)*nfields));

						for (int i = 0; i< nfields; ++i)
							props[i] = strtol(Tcl_GetString(field[i]), 0, 0);

						XChangeProperty(	
							Tk_Display(source),
							target,
							selection,
							type,
							format,
							PropModeReplace,
							reinterpret_cast<unsigned char*>(props),
							nfields);

						ckfree(reinterpret_cast<char*>(props));
					}
				}
				break;
		}

		if (success == TCL_OK)
		{
			XEvent event;

			event.xselection.type		= SelectionNotify;
			event.xselection.display	= Tk_Display(source);
			event.xselection.requestor	= target;
			event.xselection.selection	= Tk_InternAtom(source, "XdndSelection");
			event.xselection.target		= type;
			event.xselection.property	= selection;
			event.xselection.time		= time ? time : CurrentTime;

			XSendEvent(event.xselection.display, event.xselection.requestor, False, NoEventMask, &event);
		}

		Tcl_Release(ti);
	}

	if (encoding)
		Tcl_FreeEncoding(encoding);

	return success;
}

# endif // __unix__

static int
selGet(Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* const* objs = objv + 2;
	int count = objc - 2;

	char const* path			= 0;
	char const* selName		= 0;
	char const* targetName	= 0;
	long			timestamp	= CurrentTime;
	Tcl_Obj*		used[6]		= {  0, 0, 0, 0, 0, 0 };
	Tcl_Obj*		args[8]		= { objv[0], objv[1] };
	int			nargs			= 2;

	for ( ; count > 0; count -= 2, objs += 2)
	{
		static char const* OptionStrings[] = { "-displayof", "-selection", "-type", "-time", 0 };
		enum { GET_DISPLAYOF, GET_SELECTION, GET_TYPE, GET_TIME };

		char const* string = Tcl_GetString(objs[0]);

		if (string[0] != '-')
			break;

		if (count < 2)
		{
			Tcl_AppendResult(ti, "value for \"", string, "\" missing", nullptr);
			return TCL_ERROR;
		}

		int index;

		if (Tcl_GetIndexFromObj(ti, objs[0], OptionStrings, "option", 0, &index) != TCL_OK)
			return TCL_ERROR;

		switch (index)
		{
			case GET_DISPLAYOF:	path = Tcl_GetString(objs[1]); break;
			case GET_SELECTION:	selName = Tcl_GetString(objs[1]); break;
			case GET_TYPE:			targetName = Tcl_GetString(objs[1]); break;

			case GET_TIME:
				// implementing TIP 370 <www.tcl.tk/cgi-bin/tct/tip/370.html>
				if (Tcl_GetLongFromObj(ti, objs[1], &timestamp) != TCL_OK)
				{
					Tcl_AppendResult(ti, "wrong time value \"", Tcl_GetString(objs[1]), nullptr);
					return TCL_ERROR;
				}
				break;
		}

		if (index != GET_TIME)
		{
			used[2*index    ] = objs[0];
			used[2*index + 1] = objs[1];
		}
	}

	if (count > 1)
	{
		Tcl_WrongNumArgs(ti, 2, objv, "?options?");
		return TCL_ERROR;
	}

	if (selName && strcmp(selName, "XdndSelection") == 0)
	{
		Tk_Window tkwin = Tk_MainWindow(ti);

		if (path && tkwin)
			tkwin = Tk_NameToWindow(ti, path, tkwin);

		if (tkwin)
		{
			if (count == 1)
				targetName = Tcl_GetString(objs[0]);

			if (targetName)
			{
				Atom target		= Tk_InternAtom(tkwin, targetName);
				Atom selection	= Tk_InternAtom(tkwin, selName);

				if (	target != None
					&& selection != None
					&& selectionGet(ti, tkwin, selection, target, timestamp))
				{
					return TCL_OK;
				}
			}
		}
	}

	// strip "-time" from objv (to be sure)
	for (unsigned i = 0; i < 6; ++i)
	{
		if (used[i])
			args[nargs++] = used[i];
	}

	return invokeTkSelection(ti, nargs, args);
}


static int
selSend(Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc != 8)
	{
		Tcl_WrongNumArgs(ti, 2, objv, "source target selection type time data");
		return TCL_ERROR;
	}

	Tk_Window source = Tk_NameToWindow(ti, Tcl_GetString(objv[2]), Tk_MainWindow(ti));

	if (!source)
	{
		Tcl_AppendResult(ti, "value for \"source\" should be a valid window name", nullptr);
		return TCL_ERROR;
	}

	Window target = None;

	{
		long t;

		if (Tcl_GetLongFromObj(ti, objv[3], &t) != TCL_OK)
		{
			Tcl_AppendResult(ti, "value for \"target\" should be window id", nullptr);
			return TCL_ERROR;
		}

		target = t;
	}

	Atom selection	= Tk_InternAtom(source, Tcl_GetString(objv[4]));
	Atom type		= Tk_InternAtom(source, Tcl_GetString(objv[5]));

	if (selection == None || type == None)
		return TCL_ERROR;

	Time time;

	{
		long t;

		if (Tcl_GetLongFromObj(ti, objv[6], &t) != TCL_OK)
		{
			Tcl_AppendResult(ti, "invalid value for \"time\"", nullptr);
			return TCL_ERROR;
		}

		time = t;
	}

	return selectionSend(ti, source, target, selection, type, time, objv[7]);
}


static int
selCmd(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (objc >= 2)
	{ 
		if (strcmp(Tcl_GetString(objv[1]), "get") == 0)
			return selGet(ti, objc, objv);
#ifdef __unix__
		else if (strcmp(Tcl_GetString(objv[1]), "send") == 0)
			return selSend(ti, objc, objv);
#endif
	}

	return invokeTkSelection(ti, objc, objv);
}


void
tk::selection_init(Tcl_Interp* ti)
{
	// Poor Tk library cannot handle the most common types "text/plain", and "text/uri-list".
	// This means we have to do our own selection handling.
	Tcl_IncrRefCount(m_renamedCmd = Tcl_NewStringObj("__selection__x11_", -1));
	TclRenameCommand(ti, "selection", Tcl_GetString(m_renamedCmd));
	Tcl_CreateObjCommand(ti, "selection", selCmd, 0, 0);
}

#else

void tk::selection_init(Tcl_Interp* ti) {}

#endif

// vi:set ts=3 sw=3:
