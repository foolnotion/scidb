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

#include "tcl_base.h"

#include "m_assert.h"
#include "m_utility.h"

#include <tcl.h>
#include <zlib.h>
#include <string.h>

using namespace tcl;


static int
cmdZlibInflate(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	enum { ChunkSize = 16384 };

	Tcl_Channel srcChan = Tcl_GetChannel(ti, stringFromObj(objc, objv, 1), 0);
	Tcl_Channel dstChan = Tcl_GetChannel(ti, stringFromObj(objc, objv, 2), 0);

	if (!srcChan)
	{
		Tcl_ResetResult(ti);
		Tcl_AppendResult(ti, "invalid source channel '%s'", stringFromObj(objc, objv, 1), nullptr);
		return TCL_ERROR;
	}

	if (!dstChan)
	{
		Tcl_ResetResult(ti);
		Tcl_AppendResult(ti, "invalid destination channel '%s'", stringFromObj(objc, objv, 2), nullptr);
		return TCL_ERROR;
	}

	int remaining;

	if (Tcl_GetIntFromObj(ti, objv[3], &remaining) != TCL_OK)
	{
		Tcl_ResetResult(ti);
		Tcl_AppendResult(ti, "invalid file size given: '%s'", stringFromObj(objc, objv, 3), nullptr);
		return TCL_ERROR;
	}

	if (objc < 6)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<source chan> <dest chan> <progress-cmd> <arg>");
		return TCL_ERROR;
	}

	z_stream strm;

	strm.zalloc = 0;
	strm.zfree = 0;
	strm.opaque = 0;

	if (inflateInit(&strm) != Z_OK)
	{
		if (strm.msg)
			Tcl_SetResult(ti, strm.msg, TCL_VOLATILE);
		else
			Tcl_SetResult(ti, const_cast<char*>("zlib initialization failed"), TCL_STATIC);

		return TCL_ERROR;
	}

	Tcl_Obj* objs[3];
	int ret;
	unsigned crc = 0;

	objs[0] = objv[4];
	objs[1] = objv[5];

	do
	{
		char inBuf[ChunkSize];
		char outBuf[ChunkSize];

		int avail = Tcl_Read(srcChan, inBuf, mstl::min(remaining, int(ChunkSize)));
		if (avail < 0)
		{
			deflateEnd(&strm);
			Tcl_SetResult(ti, const_cast<char*>("read failed"), TCL_STATIC);
			return TCL_ERROR;
		}

		remaining -= avail;
		strm.avail_in = avail;
		strm.next_in = reinterpret_cast<Bytef*>(inBuf);
		crc = crc32(crc, reinterpret_cast<Bytef*>(inBuf), avail);
		int total = 0;

		do
		{
			strm.avail_out = ChunkSize;
			strm.next_out = reinterpret_cast<Bytef*>(outBuf);

			ret = inflate(&strm, Z_NO_FLUSH);

			switch (ret)
			{
				case Z_NEED_DICT:
				case Z_DATA_ERROR:
				case Z_MEM_ERROR:
					inflateEnd(&strm);
					if (strm.msg)
						Tcl_SetResult(ti, strm.msg, TCL_VOLATILE);
					else
						Tcl_SetResult(ti, const_cast<char*>("zlib::inflate failed"), TCL_STATIC);
					return TCL_ERROR;

				case Z_STREAM_ERROR:
					M_RAISE("zlib: inflate() failed");
			}

			int have = ChunkSize - strm.avail_out;
			total += have;

			if (Tcl_Write(dstChan, outBuf, have) != have)
			{
				inflateEnd(&strm);
				Tcl_SetResult(ti, const_cast<char*>("write failed"), TCL_STATIC);
				return TCL_ERROR;
			}
		}
		while (strm.avail_out == 0);

		objs[2] = Tcl_NewLongObj(total);
		Tcl_IncrRefCount(objs[2]);
		Tcl_EvalObjv(ti, 3, objs, TCL_EVAL_GLOBAL);
		Tcl_DecrRefCount(objs[2]);
	}
	while (remaining > 0 && ret != Z_STREAM_END);

	inflateEnd(&strm);

	if (remaining > 0)
	{
		Tcl_SetResult(ti, const_cast<char*>("zlib::inflate failed"), TCL_STATIC);
		return TCL_ERROR;
	}

	objs[0] = Tcl_NewLongObj(strm.total_out);
	objs[1] = Tcl_NewLongObj(crc);
	Tcl_SetObjResult(ti, Tcl_NewListObj(2, objs));

	return TCL_OK;
}


static int
cmdZlibDeflate(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	enum { ChunkSize = 16384 };

	Tcl_Channel srcChan = Tcl_GetChannel(ti, stringFromObj(objc, objv, 1), 0);
	Tcl_Channel dstChan = Tcl_GetChannel(ti, stringFromObj(objc, objv, 2), 0);

	if (!srcChan)
	{
		Tcl_ResetResult(ti);
		Tcl_AppendResult(ti, "invalid source channel '%s'", stringFromObj(objc, objv, 1), nullptr);
		return TCL_ERROR;
	}

	if (!dstChan)
	{
		Tcl_ResetResult(ti);
		Tcl_AppendResult(ti, "invalid destination channel '%s'", stringFromObj(objc, objv, 2), nullptr);
		return TCL_ERROR;
	}

	if (objc < 5)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "<source chan> <dest chan> <progress-cmd> <arg>");
		return TCL_ERROR;
	}

	z_stream strm;

	strm.zalloc = 0;
	strm.zfree = 0;
	strm.opaque = 0;

	if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) != Z_OK)
	{
		if (strm.msg)
			Tcl_SetResult(ti, strm.msg, TCL_VOLATILE);
		else
			Tcl_SetResult(ti, const_cast<char*>("zlib initialization failed"), TCL_STATIC);

		return TCL_ERROR;
	}

	Tcl_Obj* objs[3];
	int flush;
	unsigned crc = 0;

	objs[0] = objv[3];
	objs[1] = objv[4];

	do
	{
		char inBuf[ChunkSize];
		char outBuf[ChunkSize];

		int avail = Tcl_Read(srcChan, inBuf, ChunkSize);
		if (avail < 0)
		{
			deflateEnd(&strm);
			Tcl_SetResult(ti, const_cast<char*>("read failed"), TCL_STATIC);
			return TCL_ERROR;
		}

		strm.avail_in = avail;
		flush = Tcl_Eof(srcChan) ? Z_FINISH : Z_NO_FLUSH;
		strm.next_in = reinterpret_cast<Bytef*>(inBuf);

		do
		{
			strm.avail_out = ChunkSize;
			strm.next_out = reinterpret_cast<Bytef*>(outBuf);

			if (deflate(&strm, flush) == Z_STREAM_ERROR)
				M_RAISE("zlib: deflate() failed");

			int have = ChunkSize - strm.avail_out;

			if (Tcl_Write(dstChan, outBuf, have) != have)
			{
				deflateEnd(&strm);
				Tcl_SetResult(ti, const_cast<char*>("write failed"), TCL_STATIC);
				return TCL_ERROR;
			}

			crc = crc32(crc, reinterpret_cast<Bytef*>(outBuf), have);
		}
		while (strm.avail_out == 0);

		M_ASSERT(strm.avail_in == 0);

		objs[2] = Tcl_NewLongObj(avail);
		Tcl_IncrRefCount(objs[2]);
		Tcl_EvalObjv(ti, 3, objs, TCL_EVAL_GLOBAL);
		Tcl_DecrRefCount(objs[2]);
	}
	while (flush != Z_FINISH);

	deflateEnd(&strm);

	objs[0] = Tcl_NewLongObj(strm.total_out);
	objs[1] = Tcl_NewLongObj(crc);
	Tcl_SetObjResult(ti, Tcl_NewListObj(2, objs));

	return TCL_OK;
}


static int
cmdZlibCrc(ClientData clientData, Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	if (objc < 2)
	{
		Tcl_WrongNumArgs(ti, 1, objv, "data ?crc?");
		return TCL_ERROR;
	}

	int len;
	char const* data = Tcl_GetStringFromObj(objv[1], &len);
	unsigned crc = 0;

	if (objc > 2)
	{
		Tcl_WideInt icrc;

		if (Tcl_GetWideIntFromObj(ti, objv[2], &icrc) != TCL_OK)
		{
			Tcl_SetResult(ti, const_cast<char*>("Invalid checksum argument"), TCL_STATIC);
			return TCL_ERROR;
		}

		crc = icrc;
	}

	Tcl_SetObjResult(ti, Tcl_NewWideIntObj(crc32(crc, reinterpret_cast<Bytef const*>(data), len)));
	return TCL_OK;
}

namespace tcl {
namespace zlib {

void
init(Tcl_Interp* ti)
{
	createCommand(ti, "::zlib::crc",			cmdZlibCrc);
	createCommand(ti, "::zlib::deflate",	cmdZlibDeflate);
	createCommand(ti, "::zlib::inflate",	cmdZlibInflate);
}

} // namespace zlib
} // namespace tcl

// vi:set ts=3 sw=3:
