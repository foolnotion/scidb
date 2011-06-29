// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

// ======================================================================
// Copyright: (C) 2009-2011 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#ifndef _tcl_base_included
#define _tcl_base_included

#include <stdarg.h>

extern "C"
{
	struct Tcl_Interp;
	struct Tcl_Obj;
	struct Tcl_Command_;

	typedef int Tcl_ObjCmdProc(void*, Tcl_Interp*, int, Tcl_Obj *const []);
}

namespace mstl { class string; }

namespace tcl {

Tcl_Interp* interp();

void init(Tcl_Interp* ti);

bool equal(char const* lhs, char const* rhs);

int uniqueMatch(char const* option, char const** options);
int uniqueMatchObj(Tcl_Obj* obj, char const** options);

void
__attribute__((__format__(__printf__, 1, 2)))
appendResult(char const* format, ...);

void setResult(char const* result);
void setResult(Tcl_Obj* obj);
void setResult(int objc, Tcl_Obj* const objv[]);
void setResult(mstl::string const& s);
void setResult(int result);
void setResult(unsigned result);
void setResult(bool result);
void setResult(long result);
void setResult(unsigned long result);

int
__attribute__((__format__(__printf__, 4, 5)))
error(
	char const* cmd, char const* subcmd, char const* subsubcmd,
	char const* format, ...);

int
usage(
	char const* cmd, char const* subcmd, char const* subsubcmd,
	char const** options, char const** args = 0);

int invoke(char const* callee, char const* cmd, ...);
int invoke(char const* callee, Tcl_Obj* cmd, ...);
int invoke(	char const* callee,
				Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2,
				int objc, Tcl_Obj* const objv[]);

Tcl_Obj* call(char const* callee, char const* cmd, ...);
Tcl_Obj* call(char const* callee, Tcl_Obj* cmd, ...);
Tcl_Obj* call(	char const* callee,
					Tcl_Obj* cmd, Tcl_Obj* arg1, Tcl_Obj* arg2,
					int objc, Tcl_Obj* const objv[]);

Tcl_Command_* createCommand(Tcl_Interp* ti, char const* cmdName, Tcl_ObjCmdProc* proc);

char const* stringFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
int intFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
unsigned unsignedFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
long longFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
bool boolFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);
Tcl_Obj* objectFromObj(unsigned objc, Tcl_Obj* const objv[], unsigned index);

} // namespace tcl

#include "tcl_base.ipp"

#endif // _tcl_base_included

// vi:set ts=3 sw=3:
