// ======================================================================
// Author : $Author$
// Version: $Revision$
// Date   : $Date$
// Url    : $URL$
// ======================================================================

/*

TODO:

clearerr
fclose
fdopen
feof
ferror
fflush
fgetc
fgetpos
fgets
fileno
flockfile
fmemopen
fopen
fopencookie
fprintf
fputc
fputs
fread
freopen
fscanf
fseek
fseeko
fsetpos
ftell
ftello
ftrylockfile
funlockfile
fwrite
getc
getc_unlocked
getdelim
getline
getw
open_memstream
pclose
popen
putc
putc_unlocked
putw
rewind
setbuf
setbuffer
setlinebuf
setvbuf
tmpfile
ungetc
vfprintf
vfscanf

*/

#ifndef __unix__

#ifndef MTSAFE
# define __SINGLE_THREAD__
#endif

#include "m_stdio.h"

#define register

// ### HEADERS ##################################################################################

/*
 * Copyright (c) 1990, 2007 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 *	%W% (UofMD/Berkeley) %G%
 */

/*
 * Information local to this implementation of stdio,
 * in particular, macros and private variables.
 */

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#ifdef __SCLE
# include <io.h>
#endif
#endif


extern u_char *_EXFUN(__sccl, (char *, u_char *fmt));
extern int    _EXFUN(__svfscanf_r,(struct _reent *,FILE *, _CONST char *,va_list));
extern int    _EXFUN(__ssvfscanf_r,(struct _reent *,FILE *, _CONST char *,va_list));
extern int    _EXFUN(__svfiscanf_r,(struct _reent *,FILE *, _CONST char *,va_list));
extern int    _EXFUN(__ssvfiscanf_r,(struct _reent *,FILE *, _CONST char *,va_list));
extern int    _EXFUN(__svfwscanf_r,(struct _reent *,FILE *, _CONST wchar_t *,va_list));
extern int    _EXFUN(__ssvfwscanf_r,(struct _reent *,FILE *, _CONST wchar_t *,va_list));
extern int    _EXFUN(__svfiwscanf_r,(struct _reent *,FILE *, _CONST wchar_t *,va_list));
extern int    _EXFUN(__ssvfiwscanf_r,(struct _reent *,FILE *, _CONST wchar_t *,va_list));
int	      _EXFUN(_svfprintf_r,(struct _reent *, FILE *, const char *,
				  va_list)
               			_ATTRIBUTE ((__format__ (__printf__, 3, 0))));
int	      _EXFUN(_svfiprintf_r,(struct _reent *, FILE *, const char *,
				  va_list)
               			_ATTRIBUTE ((__format__ (__printf__, 3, 0))));
int	      _EXFUN(_svfwprintf_r,(struct _reent *, FILE *, const wchar_t *,
				  va_list));
int	      _EXFUN(_svfiwprintf_r,(struct _reent *, FILE *, const wchar_t *,
				  va_list));
extern FILE  *_EXFUN(__sfp,(struct _reent *));
extern int    _EXFUN(__sflags,(struct _reent *,_CONST char*, int*));
extern int    _EXFUN(__srefill_r,(struct _reent *,FILE *));
extern _READ_WRITE_RETURN_TYPE _EXFUN(__sread,(struct _reent *, void *, char *,
					       int));
extern _READ_WRITE_RETURN_TYPE _EXFUN(__seofread,(struct _reent *, void *,
						  char *, int));
extern _READ_WRITE_RETURN_TYPE _EXFUN(__swrite,(struct _reent *, void *,
						const char *, int));
extern _fpos_t _EXFUN(__sseek,(struct _reent *, void *, _fpos_t, int));
extern int    _EXFUN(__sclose,(struct _reent *, void *));
extern int    _EXFUN(__stextmode,(int));
extern _VOID   _EXFUN(__sinit,(struct _reent *));
extern _VOID   _EXFUN(_cleanup_r,(struct _reent *));
extern _VOID   _EXFUN(__smakebuf_r,(struct _reent *, FILE *));
extern int    _EXFUN(_fwalk,(struct _reent *, int (*)(FILE *)));
extern int    _EXFUN(_fwalk_reent,(struct _reent *, int (*)(struct _reent *, FILE *)));
struct _glue * _EXFUN(__sfmoreglue,(struct _reent *,int n));
extern int _EXFUN(__submore, (struct _reent *, FILE *));

#ifdef __LARGE64_FILES
extern _fpos64_t _EXFUN(__sseek64,(struct _reent *, void *, _fpos64_t, int));
extern _READ_WRITE_RETURN_TYPE _EXFUN(__swrite64,(struct _reent *, void *,
						  const char *, int));
#endif

/* Called by the main entry point fns to ensure stdio has been initialized.  */

#ifdef _REENT_SMALL
#define CHECK_INIT(ptr, fp) \
  do						\
    {						\
      if ((ptr) && !(ptr)->__sdidinit)		\
	__sinit (ptr);				\
      if ((fp) == (FILE *)&__sf_fake_stdin)	\
	(fp) = _stdin_r(ptr);			\
      else if ((fp) == (FILE *)&__sf_fake_stdout) \
	(fp) = _stdout_r(ptr);			\
      else if ((fp) == (FILE *)&__sf_fake_stderr) \
	(fp) = _stderr_r(ptr);			\
    }						\
  while (0)
#else /* !_REENT_SMALL   */
#define CHECK_INIT(ptr, fp) \
  do						\
    {						\
      if ((ptr) && !(ptr)->__sdidinit)		\
	__sinit (ptr);				\
    }						\
  while (0)
#endif /* !_REENT_SMALL  */

#define CHECK_STD_INIT(ptr) \
  do						\
    {						\
      if ((ptr) && !(ptr)->__sdidinit)		\
	__sinit (ptr);				\
    }						\
  while (0)

/* Return true iff the given FILE cannot be written now.  */

#define	cantwrite(ptr, fp)                                     \
  ((((fp)->_flags & __SWR) == 0 || (fp)->_bf._base == NULL) && \
   __swsetup_r(ptr, fp))

/* Test whether the given stdio file has an active ungetc buffer;
   release such a buffer, without restoring ordinary unread data.  */

#define	HASUB(fp) ((fp)->_ub._base != NULL)
#define	FREEUB(ptr, fp) {                    \
	if ((fp)->_ub._base != (fp)->_ubuf) \
		_free_r(ptr, (char *)(fp)->_ub._base); \
	(fp)->_ub._base = NULL; \
}

/* Test for an fgetline() buffer.  */

#define	HASLB(fp) ((fp)->_lb._base != NULL)
#define	FREELB(ptr, fp) { _free_r(ptr,(char *)(fp)->_lb._base); \
      (fp)->_lb._base = NULL; }

/*
 * Set the orientation for a stream. If o > 0, the stream has wide-
 * orientation. If o < 0, the stream has byte-orientation.
 */
#define ORIENT(fp,ori)					\
  do								\
    {								\
      if (!((fp)->_flags & __SORD))	\
	{							\
	  (fp)->_flags |= __SORD;				\
	  if (ori > 0)						\
	    (fp)->_flags2 |= __SWID;				\
	  else							\
	    (fp)->_flags2 &= ~__SWID;				\
	}							\
    }								\
  while (0)

/* WARNING: _dcvt is defined in the stdlib directory, not here!  */

char *_EXFUN(_dcvt,(struct _reent *, char *, double, int, int, char, int));
char *_EXFUN(_sicvt,(char *, short, char));
char *_EXFUN(_icvt,(char *, int, char));
char *_EXFUN(_licvt,(char *, long, char));
#ifdef __GNUC__
char *_EXFUN(_llicvt,(char *, long long, char));
#endif

#define CVT_BUF_SIZE 128

#define	NDYNAMIC 4	/* add four more whenever necessary */

#ifdef __SINGLE_THREAD__
#define __sfp_lock_acquire()
#define __sfp_lock_release()
#define __sinit_lock_acquire()
#define __sinit_lock_release()
#else
_VOID _EXFUN(__sfp_lock_acquire,(_VOID));
_VOID _EXFUN(__sfp_lock_release,(_VOID));
_VOID _EXFUN(__sinit_lock_acquire,(_VOID));
_VOID _EXFUN(__sinit_lock_release,(_VOID));
#endif

/* Types used in positional argument support in vfprinf/vfwprintf.
   The implementation is char/wchar_t dependent but the class and state
   tables are only defined once in vfprintf.c. */
typedef enum {
  ZERO,   /* '0' */
  DIGIT,  /* '1-9' */
  DOLLAR, /* '$' */
  MODFR,  /* spec modifier */
  SPEC,   /* format specifier */
  DOT,    /* '.' */
  STAR,   /* '*' */
  FLAG,   /* format flag */
  OTHER,  /* all other chars */
  MAX_CH_CLASS /* place-holder */
} __CH_CLASS;

typedef enum {
  START,  /* start */
  SFLAG,  /* seen a flag */
  WDIG,   /* seen digits in width area */
  WIDTH,  /* processed width */
  SMOD,   /* seen spec modifier */
  SDOT,   /* seen dot */
  VARW,   /* have variable width specifier */
  VARP,   /* have variable precision specifier */
  PREC,   /* processed precision */
  VWDIG,  /* have digits in variable width specification */
  VPDIG,  /* have digits in variable precision specification */
  DONE,   /* done */
  MAX_STATE, /* place-holder */
} __STATE;

typedef enum {
  NOOP,  /* do nothing */
  NUMBER, /* build a number from digits */
  SKIPNUM, /* skip over digits */
  GETMOD,  /* get and process format modifier */
  GETARG,  /* get and process argument */
  GETPW,   /* get variable precision or width */
  GETPWB,  /* get variable precision or width and pushback fmt char */
  GETPOS,  /* get positional parameter value */
  PWPOS,   /* get positional parameter value for variable width or precision */
} __ACTION;

extern _CONST __CH_CLASS __chclass[256];
extern _CONST __STATE __state_table[MAX_STATE][MAX_CH_CLASS];
extern _CONST __ACTION __action_table[MAX_STATE][MAX_CH_CLASS];

// ### SOURCES ##################################################################################

/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fclose>>---close a file

INDEX
	fclose
INDEX
	_fclose_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fclose(FILE *<[fp]>);
	int _fclose_r(struct _reent *<[reent]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int fclose(<[fp]>)
	FILE *<[fp]>;

	int fclose(<[fp]>)
        struct _reent *<[reent]>
	FILE *<[fp]>;

DESCRIPTION
If the file or stream identified by <[fp]> is open, <<fclose>> closes
it, after first ensuring that any pending data is written (by calling
<<fflush(<[fp]>)>>).

The alternate function <<_fclose_r>> is a reentrant version.
The extra argument <[reent]> is a pointer to a reentrancy structure.

RETURNS
<<fclose>> returns <<0>> if successful (including when <[fp]> is
<<NULL>> or not an open file); otherwise, it returns <<EOF>>.

PORTABILITY
<<fclose>> is required by ANSI C.

Required OS subroutines: <<close>>, <<fstat>>, <<isatty>>, <<lseek>>,
<<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/lock.h>
#include "local.h"
#endif

int
_DEFUN(_fclose_r, (rptr, fp),
      struct _reent *rptr _AND
      register FILE * fp)
{
  int r;

  if (fp == NULL)
    return (0);			/* on NULL */

  __sfp_lock_acquire ();

  CHECK_INIT (rptr, fp);

  _flockfile (fp);

  if (fp->_flags == 0)		/* not open! */
    {
      _funlockfile (fp);
      __sfp_lock_release ();
      return (0);
    }
  /* Unconditionally flush to allow special handling for seekable read
     files to reposition file to last byte processed as opposed to
     last byte read ahead into the buffer.  */
  r = _fflush_r (rptr, fp);
  if (fp->_close != NULL && fp->_close (rptr, fp->_cookie) < 0)
    r = EOF;
  if (fp->_flags & __SMBF)
    _free_r (rptr, (char *) fp->_bf._base);
  if (HASUB (fp))
    FREEUB (rptr, fp);
  if (HASLB (fp))
    FREELB (rptr, fp);
  fp->_flags = 0;		/* release this FILE for reuse */
  _funlockfile (fp);
#ifndef __SINGLE_THREAD__
  __lock_close_recursive (fp->_lock);
#endif

  __sfp_lock_release ();

  return (r);
}

#ifndef _REENT_ONLY

int
_DEFUN(fclose, (fp),
       register FILE * fp)
{
  return _fclose_r(_REENT, fp);
}

#endif
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<feof>>---test for end of file

INDEX
	feof

ANSI_SYNOPSIS
	#include <stdio.h>
	int feof(FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int feof(<[fp]>)
	FILE *<[fp]>;

DESCRIPTION
<<feof>> tests whether or not the end of the file identified by <[fp]>
has been reached.

RETURNS
<<feof>> returns <<0>> if the end of file has not yet been reached; if
at end of file, the result is nonzero.

PORTABILITY
<<feof>> is required by ANSI C.

No supporting OS subroutines are required.
*/

#include <stdio.h>
#include "local.h"

/* A subroutine version of the macro feof.  */

#undef feof

int
_DEFUN(feof, (fp),
       FILE * fp)
{
  int result;
  CHECK_INIT(_REENT, fp);
  _flockfile (fp);
  result = __sfeof (fp);
  _funlockfile (fp);
  return result;
}
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fflush>>---flush buffered file output

INDEX
	fflush
INDEX
	_fflush_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fflush(FILE *<[fp]>);

	int _fflush_r(struct _reent *<[reent]>, FILE *<[fp]>);

DESCRIPTION
The <<stdio>> output functions can buffer output before delivering it
to the host system, in order to minimize the overhead of system calls.

Use <<fflush>> to deliver any such pending output (for the file
or stream identified by <[fp]>) to the host system.

If <[fp]> is <<NULL>>, <<fflush>> delivers pending output from all
open files.

Additionally, if <[fp]> is a seekable input stream visiting a file
descriptor, set the position of the file descriptor to match next
unread byte, useful for obeying POSIX semantics when ending a process
without consuming all input from the stream.

The alternate function <<_fflush_r>> is a reentrant version, where the
extra argument <[reent]> is a pointer to a reentrancy structure, and
<[fp]> must not be NULL.

RETURNS
<<fflush>> returns <<0>> unless it encounters a write error; in that
situation, it returns <<EOF>>.

PORTABILITY
ANSI C requires <<fflush>>.  The behavior on input streams is only
specified by POSIX, and not all implementations follow POSIX rules.

No supporting OS subroutines are required.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include <errno.h>
#include "local.h"
#endif

/* Flush a single file, or (if fp is NULL) all files.  */

int
_DEFUN(_fflush_r, (ptr, fp),
       struct _reent *ptr _AND
       register FILE * fp)
{
  register unsigned char *p;
  register int n, t;

#ifdef _REENT_SMALL
  /* For REENT_SMALL platforms, it is possible we are being
     called for the first time on a std stream.  This std
     stream can belong to a reentrant struct that is not
     _REENT.  If CHECK_INIT gets called below based on _REENT,
     we will end up changing said file pointers to the equivalent
     std stream off of _REENT.  This causes unexpected behavior if
     there is any data to flush on the _REENT std stream.  There
     are two alternatives to fix this:  1) make a reentrant fflush
     or 2) simply recognize that this file has nothing to flush
     and return immediately before performing a CHECK_INIT.  Choice
     2 is implemented here due to its simplicity.  */
  if (fp->_bf._base == NULL)
    return 0;
#endif /* _REENT_SMALL  */

  CHECK_INIT (ptr, fp);

  _flockfile (fp);

  t = fp->_flags;
  if ((t & __SWR) == 0)
    {
      /* For a read stream, an fflush causes the next seek to be
         unoptimized (i.e. forces a system-level seek).  This conforms
         to the POSIX and SUSv3 standards.  */
      fp->_flags |= __SNPT;

      /* For a seekable stream with buffered read characters, we will attempt
         a seek to the current position now.  A subsequent read will then get
         the next byte from the file rather than the buffer.  This conforms
         to the POSIX and SUSv3 standards.  Note that the standards allow
         this seek to be deferred until necessary, but we choose to do it here
         to make the change simpler, more contained, and less likely
         to miss a code scenario.  */
      if ((fp->_r > 0 || fp->_ur > 0) && fp->_seek != NULL)
	{
	  int tmp;
#ifdef __LARGE64_FILES
	  _fpos64_t curoff;
#else
	  _fpos_t curoff;
#endif

	  /* Get the physical position we are at in the file.  */
	  if (fp->_flags & __SOFF)
	    curoff = fp->_offset;
	  else
	    {
	      /* We don't know current physical offset, so ask for it.
		 Only ESPIPE is ignorable.  */
#ifdef __LARGE64_FILES
	      if (fp->_flags & __SL64)
		curoff = fp->_seek64 (ptr, fp->_cookie, 0, SEEK_CUR);
	      else
#endif
		curoff = fp->_seek (ptr, fp->_cookie, 0, SEEK_CUR);
	      if (curoff == -1L)
		{
		  int result = EOF;
		  if (ptr->_errno == ESPIPE)
		    result = 0;
		  else
		    fp->_flags |= __SERR;
		  _funlockfile (fp);
		  return result;
		}
            }
          if (fp->_flags & __SRD)
            {
              /* Current offset is at end of buffer.  Compensate for
                 characters not yet read.  */
              curoff -= fp->_r;
              if (HASUB (fp))
                curoff -= fp->_ur;
            }
	  /* Now physically seek to after byte last read.  */
#ifdef __LARGE64_FILES
	  if (fp->_flags & __SL64)
	    tmp = (fp->_seek64 (ptr, fp->_cookie, curoff, SEEK_SET) == curoff);
	  else
#endif
	    tmp = (fp->_seek (ptr, fp->_cookie, curoff, SEEK_SET) == curoff);
	  if (tmp)
	    {
	      /* Seek successful.  We can clear read buffer now.  */
	      fp->_flags &= ~__SNPT;
	      fp->_r = 0;
	      fp->_p = fp->_bf._base;
	      if (fp->_flags & __SOFF)
		fp->_offset = curoff;
	      if (HASUB (fp))
		FREEUB (ptr, fp);
	    }
	  else
	    {
	      fp->_flags |= __SERR;
	      _funlockfile (fp);
	      return EOF;
	    }
	}
      _funlockfile (fp);
      return 0;
    }
  if ((p = fp->_bf._base) == NULL)
    {
      /* Nothing to flush.  */
      _funlockfile (fp);
      return 0;
    }
  n = fp->_p - p;		/* write this much */

  /*
   * Set these immediately to avoid problems with longjmp
   * and to allow exchange buffering (via setvbuf) in user
   * write function.
   */
  fp->_p = p;
  fp->_w = t & (__SLBF | __SNBF) ? 0 : fp->_bf._size;

  while (n > 0)
    {
      t = fp->_write (ptr, fp->_cookie, (char *) p, n);
      if (t <= 0)
	{
          fp->_flags |= __SERR;
          _funlockfile (fp);
          return EOF;
	}
      p += t;
      n -= t;
    }
  _funlockfile (fp);
  return 0;
}

#ifndef _REENT_ONLY

int
_DEFUN(fflush, (fp),
       register FILE * fp)
{
  if (fp == NULL)
    return _fwalk_reent (_GLOBAL_REENT, _fflush_r);

  return _fflush_r (_REENT, fp);
}

#endif /* _REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fgetc>>---get a character from a file or stream

INDEX
	fgetc
INDEX
	_fgetc_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fgetc(FILE *<[fp]>);

	#include <stdio.h>
	int _fgetc_r(struct _reent *<[ptr]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int fgetc(<[fp]>)
	FILE *<[fp]>;

	#include <stdio.h>
	int _fgetc_r(<[ptr]>, <[fp]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;

DESCRIPTION
Use <<fgetc>> to get the next single character from the file or stream
identified by <[fp]>.  As a side effect, <<fgetc>> advances the file's
current position indicator.

For a macro version of this function, see <<getc>>.

The function <<_fgetc_r>> is simply a reentrant version of
<<fgetc>> that is passed the additional reentrant structure
pointer argument: <[ptr]>.

RETURNS
The next character (read as an <<unsigned char>>, and cast to
<<int>>), unless there is no more data, or the host system reports a
read error; in either of these situations, <<fgetc>> returns <<EOF>>.

You can distinguish the two situations that cause an <<EOF>> result by
using the <<ferror>> and <<feof>> functions.

PORTABILITY
ANSI C requires <<fgetc>>.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include "local.h"
#endif

int
_DEFUN(_fgetc_r, (ptr, fp),
       struct _reent * ptr _AND
       FILE * fp)
{
  int result;
  CHECK_INIT(ptr, fp);
  _flockfile (fp);
  result = __sgetc_r (ptr, fp);
  _funlockfile (fp);
  return result;
}

#ifndef _REENT_ONLY

int
_DEFUN(fgetc, (fp),
       FILE * fp)
{
#if !defined(PREFER_SIZE_OVER_SPEED) && !defined(__OPTIMIZE_SIZE__)
  int result;
  CHECK_INIT(_REENT, fp);
  __sfp_lock_acquire ();
  _flockfile (fp);
  result = __sgetc_r (_REENT, fp);
  _funlockfile (fp);
  __sfp_lock_release ();
  return result;
#else
  return _fgetc_r (_REENT, fp);
#endif
}

#endif /* !_REENT_ONLY */

/* Copyright (C) 2007 Eric Blake
 * Permission to use, copy, modify, and distribute this software
 * is freely granted, provided that this notice is preserved.
 */

/*
FUNCTION
<<fmemopen>>---open a stream around a fixed-length string

INDEX
	fmemopen

ANSI_SYNOPSIS
	#include <stdio.h>
	FILE *fmemopen(void *restrict <[buf]>, size_t <[size]>,
		       const char *restrict <[mode]>);

DESCRIPTION
<<fmemopen>> creates a seekable <<FILE>> stream that wraps a
fixed-length buffer of <[size]> bytes starting at <[buf]>.  The stream
is opened with <[mode]> treated as in <<fopen>>, where append mode
starts writing at the first NUL byte.  If <[buf]> is NULL, then
<[size]> bytes are automatically provided as if by <<malloc>>, with
the initial size of 0, and <[mode]> must contain <<+>> so that data
can be read after it is written.

The stream maintains a current position, which moves according to
bytes read or written, and which can be one past the end of the array.
The stream also maintains a current file size, which is never greater
than <[size]>.  If <[mode]> starts with <<r>>, the position starts at
<<0>>, and file size starts at <[size]> if <[buf]> was provided.  If
<[mode]> starts with <<w>>, the position and file size start at <<0>>,
and if <[buf]> was provided, the first byte is set to NUL.  If
<[mode]> starts with <<a>>, the position and file size start at the
location of the first NUL byte, or else <[size]> if <[buf]> was
provided.

When reading, NUL bytes have no significance, and reads cannot exceed
the current file size.  When writing, the file size can increase up to
<[size]> as needed, and NUL bytes may be embedded in the stream (see
<<open_memstream>> for an alternative that automatically enlarges the
buffer).  When the stream is flushed or closed after a write that
changed the file size, a NUL byte is written at the current position
if there is still room; if the stream is not also open for reading, a
NUL byte is additionally written at the last byte of <[buf]> when the
stream has exceeded <[size]>, so that a write-only <[buf]> is always
NUL-terminated when the stream is flushed or closed (and the initial
<[size]> should take this into account).  It is not possible to seek
outside the bounds of <[size]>.  A NUL byte written during a flush is
restored to its previous value when seeking elsewhere in the string.

RETURNS
The return value is an open FILE pointer on success.  On error,
<<NULL>> is returned, and <<errno>> will be set to EINVAL if <[size]>
is zero or <[mode]> is invalid, ENOMEM if <[buf]> was NULL and memory
could not be allocated, or EMFILE if too many streams are already
open.

PORTABILITY
This function is being added to POSIX 200x, but is not in POSIX 2001.

Supporting OS subroutines required: <<sbrk>>.
*/

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/lock.h>
#include "local.h"

/* Describe details of an open memstream.  */
typedef struct fmemcookie {
  void *storage; /* storage to free on close */
  char *buf; /* buffer start */
  size_t pos; /* current position */
  size_t eof; /* current file size */
  size_t max; /* maximum file size */
  char append; /* nonzero if appending */
  char writeonly; /* 1 if write-only */
  char saved; /* saved character that lived at pos before write-only NUL */
} fmemcookie;

/* Read up to non-zero N bytes into BUF from stream described by
   COOKIE; return number of bytes read (0 on EOF).  */
static _READ_WRITE_RETURN_TYPE
_DEFUN(fmemreader, (ptr, cookie, buf, n),
       struct _reent *ptr _AND
       void *cookie _AND
       char *buf _AND
       int n)
{
  fmemcookie *c = (fmemcookie *) cookie;
  /* Can't read beyond current size, but EOF condition is not an error.  */
  if (c->pos > c->eof)
    return 0;
  if (n >= c->eof - c->pos)
    n = c->eof - c->pos;
  memcpy (buf, c->buf + c->pos, n);
  c->pos += n;
  return n;
}

/* Write up to non-zero N bytes of BUF into the stream described by COOKIE,
   returning the number of bytes written or EOF on failure.  */
static _READ_WRITE_RETURN_TYPE
_DEFUN(fmemwriter, (ptr, cookie, buf, n),
       struct _reent *ptr _AND
       void *cookie _AND
       const char *buf _AND
       int n)
{
  fmemcookie *c = (fmemcookie *) cookie;
  int adjust = 0; /* true if at EOF, but still need to write NUL.  */

  /* Append always seeks to eof; otherwise, if we have previously done
     a seek beyond eof, ensure all intermediate bytes are NUL.  */
  if (c->append)
    c->pos = c->eof;
  else if (c->pos > c->eof)
    memset (c->buf + c->eof, '\0', c->pos - c->eof);
  /* Do not write beyond EOF; saving room for NUL on write-only stream.  */
  if (c->pos + n > c->max - c->writeonly)
    {
      adjust = c->writeonly;
      n = c->max - c->pos;
    }
  /* Now n is the number of bytes being modified, and adjust is 1 if
     the last byte is NUL instead of from buf.  Write a NUL if
     write-only; or if read-write, eof changed, and there is still
     room.  When we are within the file contents, remember what we
     overwrite so we can restore it if we seek elsewhere later.  */
  if (c->pos + n > c->eof)
    {
      c->eof = c->pos + n;
      if (c->eof - adjust < c->max)
	c->saved = c->buf[c->eof - adjust] = '\0';
    }
  else if (c->writeonly)
    {
      if (n)
	{
	  c->saved = c->buf[c->pos + n - adjust];
	  c->buf[c->pos + n - adjust] = '\0';
	}
      else
	adjust = 0;
    }
  c->pos += n;
  if (n - adjust)
    memcpy (c->buf + c->pos - n, buf, n - adjust);
  else
    {
      ptr->_errno = ENOSPC;
      return EOF;
    }
  return n;
}

/* Seek to position POS relative to WHENCE within stream described by
   COOKIE; return resulting position or fail with EOF.  */
static _fpos_t
_DEFUN(fmemseeker, (ptr, cookie, pos, whence),
       struct _reent *ptr _AND
       void *cookie _AND
       _fpos_t pos _AND
       int whence)
{
  fmemcookie *c = (fmemcookie *) cookie;
#ifndef __LARGE64_FILES
  off_t offset = (off_t) pos;
#else /* __LARGE64_FILES */
  _off64_t offset = (_off64_t) pos;
#endif /* __LARGE64_FILES */

  if (whence == SEEK_CUR)
    offset += c->pos;
  else if (whence == SEEK_END)
    offset += c->eof;
  if (offset < 0)
    {
      ptr->_errno = EINVAL;
      offset = -1;
    }
  else if (offset > c->max)
    {
      ptr->_errno = ENOSPC;
      offset = -1;
    }
#ifdef __LARGE64_FILES
  else if ((_fpos_t) offset != offset)
    {
      ptr->_errno = EOVERFLOW;
      offset = -1;
    }
#endif /* __LARGE64_FILES */
  else
    {
      if (c->writeonly && c->pos < c->eof)
	{
	  c->buf[c->pos] = c->saved;
	  c->saved = '\0';
	}
      c->pos = offset;
      if (c->writeonly && c->pos < c->eof)
	{
	  c->saved = c->buf[c->pos];
	  c->buf[c->pos] = '\0';
	}
    }
  return (_fpos_t) offset;
}

/* Seek to position POS relative to WHENCE within stream described by
   COOKIE; return resulting position or fail with EOF.  */
#ifdef __LARGE64_FILES
static _fpos64_t
_DEFUN(fmemseeker64, (ptr, cookie, pos, whence),
       struct _reent *ptr _AND
       void *cookie _AND
       _fpos64_t pos _AND
       int whence)
{
  _off64_t offset = (_off64_t) pos;
  fmemcookie *c = (fmemcookie *) cookie;
  if (whence == SEEK_CUR)
    offset += c->pos;
  else if (whence == SEEK_END)
    offset += c->eof;
  if (offset < 0)
    {
      ptr->_errno = EINVAL;
      offset = -1;
    }
  else if (offset > c->max)
    {
      ptr->_errno = ENOSPC;
      offset = -1;
    }
  else
    {
      if (c->writeonly && c->pos < c->eof)
	{
	  c->buf[c->pos] = c->saved;
	  c->saved = '\0';
	}
      c->pos = offset;
      if (c->writeonly && c->pos < c->eof)
	{
	  c->saved = c->buf[c->pos];
	  c->buf[c->pos] = '\0';
	}
    }
  return (_fpos64_t) offset;
}
#endif /* __LARGE64_FILES */

/* Reclaim resources used by stream described by COOKIE.  */
static int
_DEFUN(fmemcloser, (ptr, cookie),
       struct _reent *ptr _AND
       void *cookie)
{
  fmemcookie *c = (fmemcookie *) cookie;
  _free_r (ptr, c->storage);
  return 0;
}

/* Open a memstream around buffer BUF of SIZE bytes, using MODE.
   Return the new stream, or fail with NULL.  */
FILE *
_DEFUN(_fmemopen_r, (ptr, buf, size, mode),
       struct _reent *ptr _AND
       void *buf _AND
       size_t size _AND
       const char *mode)
{
  FILE *fp;
  fmemcookie *c;
  int flags;
  int dummy;

  if ((flags = __sflags (ptr, mode, &dummy)) == 0)
    return NULL;
  if (!size || !(buf || flags & __SAPP))
    {
      ptr->_errno = EINVAL;
      return NULL;
    }
  if ((fp = __sfp (ptr)) == NULL)
    return NULL;
  if ((c = (fmemcookie *) _malloc_r (ptr, sizeof *c + (buf ? 0 : size)))
      == NULL)
    {
      __sfp_lock_acquire ();
      fp->_flags = 0;		/* release */
#ifndef __SINGLE_THREAD__
      __lock_close_recursive (fp->_lock);
#endif
      __sfp_lock_release ();
      return NULL;
    }

  c->storage = c;
  c->max = size;
  /* 9 modes to worry about.  */
  /* w/a, buf or no buf: Guarantee a NUL after any file writes.  */
  c->writeonly = (flags & __SWR) != 0;
  c->saved = '\0';
  if (!buf)
    {
      /* r+/w+/a+, and no buf: file starts empty.  */
      c->buf = (char *) (c + 1);
      *(char *) buf = '\0';
      c->pos = c->eof = 0;
      c->append = (flags & __SAPP) != 0;
    }
  else
    {
      c->buf = (char *) buf;
      switch (*mode)
	{
	case 'a':
	  /* a/a+ and buf: position and size at first NUL.  */
	  buf = memchr (c->buf, '\0', size);
	  c->eof = c->pos = buf ? (char *) buf - c->buf : size;
	  if (!buf && c->writeonly)
	    /* a: guarantee a NUL within size even if no writes.  */
	    c->buf[size - 1] = '\0';
	  c->append = 1;
	  break;
	case 'r':
	  /* r/r+ and buf: read at beginning, full size available.  */
	  c->pos = c->append = 0;
	  c->eof = size;
	  break;
	case 'w':
	  /* w/w+ and buf: write at beginning, truncate to empty.  */
	  c->pos = c->append = c->eof = 0;
	  *c->buf = '\0';
	  break;
	default:
	  abort ();
	}
    }

  _flockfile (fp);
  fp->_file = -1;
  fp->_flags = flags;
  fp->_cookie = c;
  fp->_read = flags & (__SRD | __SRW) ? fmemreader : NULL;
  fp->_write = flags & (__SWR | __SRW) ? fmemwriter : NULL;
  fp->_seek = fmemseeker;
#ifdef __LARGE64_FILES
  fp->_seek64 = fmemseeker64;
  fp->_flags |= __SL64;
#endif
  fp->_close = fmemcloser;
  _funlockfile (fp);
  return fp;
}

#ifndef _REENT_ONLY
FILE *
_DEFUN(fmemopen, (buf, size, mode),
       void *buf _AND
       size_t size _AND
       const char *mode)
{
  return _fmemopen_r (_REENT, buf, size, mode);
}
#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fopen>>---open a file

INDEX
	fopen
INDEX
	_fopen_r

ANSI_SYNOPSIS
	#include <stdio.h>
	FILE *fopen(const char *<[file]>, const char *<[mode]>);

	FILE *_fopen_r(struct _reent *<[reent]>,
                       const char *<[file]>, const char *<[mode]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	FILE *fopen(<[file]>, <[mode]>)
	char *<[file]>;
	char *<[mode]>;

	FILE *_fopen_r(<[reent]>, <[file]>, <[mode]>)
	struct _reent *<[reent]>;
	char *<[file]>;
	char *<[mode]>;

DESCRIPTION
<<fopen>> initializes the data structures needed to read or write a
file.  Specify the file's name as the string at <[file]>, and the kind
of access you need to the file with the string at <[mode]>.

The alternate function <<_fopen_r>> is a reentrant version.
The extra argument <[reent]> is a pointer to a reentrancy structure.

Three fundamental kinds of access are available: read, write, and append.
<<*<[mode]>>> must begin with one of the three characters `<<r>>',
`<<w>>', or `<<a>>', to select one of these:

o+
o r
Open the file for reading; the operation will fail if the file does
not exist, or if the host system does not permit you to read it.

o w
Open the file for writing @emph{from the beginning} of the file:
effectively, this always creates a new file.  If the file whose name you
specified already existed, its old contents are discarded.

o a
Open the file for appending data, that is writing from the end of
file.  When you open a file this way, all data always goes to the
current end of file; you cannot change this using <<fseek>>.
o-

Some host systems distinguish between ``binary'' and ``text'' files.
Such systems may perform data transformations on data written to, or
read from, files opened as ``text''.
If your system is one of these, then you can append a `<<b>>' to any
of the three modes above, to specify that you are opening the file as
a binary file (the default is to open the file as a text file).

`<<rb>>', then, means ``read binary''; `<<wb>>', ``write binary''; and
`<<ab>>', ``append binary''.

To make C programs more portable, the `<<b>>' is accepted on all
systems, whether or not it makes a difference.

Finally, you might need to both read and write from the same file.
You can also append a `<<+>>' to any of the three modes, to permit
this.  (If you want to append both `<<b>>' and `<<+>>', you can do it
in either order: for example, <<"rb+">> means the same thing as
<<"r+b">> when used as a mode string.)

Use <<"r+">> (or <<"rb+">>) to permit reading and writing anywhere in
an existing file, without discarding any data; <<"w+">> (or <<"wb+">>)
to create a new file (or begin by discarding all data from an old one)
that permits reading and writing anywhere in it; and <<"a+">> (or
<<"ab+">>) to permit reading anywhere in an existing file, but writing
only at the end.

RETURNS
<<fopen>> returns a file pointer which you can use for other file
operations, unless the file you requested could not be opened; in that
situation, the result is <<NULL>>.  If the reason for failure was an
invalid string at <[mode]>, <<errno>> is set to <<EINVAL>>.

PORTABILITY
<<fopen>> is required by ANSI C.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<open>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "%W% (Berkeley) %G%";
#endif /* LIBC_SCCS and not lint */

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdio.h>
#include <errno.h>
#include <sys/lock.h>
#ifdef __CYGWIN__
#include <fcntl.h>
#endif
#include "local.h"
#endif

FILE *
_DEFUN(_fopen_r, (ptr, file, mode),
       struct _reent *ptr _AND
       _CONST char *file _AND
       _CONST char *mode)
{
  register FILE *fp;
  register int f;
  int flags, oflags;

  if ((flags = __sflags (ptr, mode, &oflags)) == 0)
    return NULL;
  if ((fp = __sfp (ptr)) == NULL)
    return NULL;

  if ((f = _open_r (ptr, file, oflags, 0666)) < 0)
    {
      __sfp_lock_acquire ();
      fp->_flags = 0;		/* release */
#ifndef __SINGLE_THREAD__
      __lock_close_recursive (fp->_lock);
#endif
      __sfp_lock_release ();
      return NULL;
    }

  _flockfile (fp);

  fp->_file = f;
  fp->_flags = flags;
  fp->_cookie = (_PTR) fp;
  fp->_read = __sread;
  fp->_write = __swrite;
  fp->_seek = __sseek;
  fp->_close = __sclose;

  if (fp->_flags & __SAPP)
    _fseek_r (ptr, fp, 0, SEEK_END);

#ifdef __SCLE
  if (__stextmode (fp->_file))
    fp->_flags |= __SCLE;
#endif

  _funlockfile (fp);
  return fp;
}

#ifndef _REENT_ONLY

FILE *
_DEFUN(fopen, (file, mode),
       _CONST char *file _AND
       _CONST char *mode)
{
  return _fopen_r (_REENT, file, mode);
}

#endif
/* Copyright (C) 2007 Eric Blake
 * Permission to use, copy, modify, and distribute this software
 * is freely granted, provided that this notice is preserved.
 */

/*
FUNCTION
<<fopencookie>>---open a stream with custom callbacks

INDEX
	fopencookie

ANSI_SYNOPSIS
	#include <stdio.h>
	FILE *fopencookie(const void *<[cookie]>, const char *<[mode]>,
			  cookie_io_functions_t <[functions]>);

DESCRIPTION
<<fopencookie>> creates a <<FILE>> stream where I/O is performed using
custom callbacks.  The callbacks are registered via the structure:

	typedef ssize_t (*cookie_read_function_t)(void *_cookie, char *_buf,
						  size_t _n);
	typedef ssize_t (*cookie_write_function_t)(void *_cookie,
						   const char *_buf, size_t _n);
	typedef int (*cookie_seek_function_t)(void *_cookie, off_t *_off,
					      int _whence);
	typedef int (*cookie_close_function_t)(void *_cookie);

.	typedef struct
.	{
.		cookie_read_function_t	*read;
.		cookie_write_function_t *write;
.		cookie_seek_function_t	*seek;
.		cookie_close_function_t *close;
.	} cookie_io_functions_t;

The stream is opened with <[mode]> treated as in <<fopen>>.  The
callbacks <[functions.read]> and <[functions.write]> may only be NULL
when <[mode]> does not require them.

<[functions.read]> should return -1 on failure, or else the number of
bytes read (0 on EOF).  It is similar to <<read>>, except that
<[cookie]> will be passed as the first argument.

<[functions.write]> should return -1 on failure, or else the number of
bytes written.  It is similar to <<write>>, except that <[cookie]>
will be passed as the first argument.

<[functions.seek]> should return -1 on failure, and 0 on success, with
*<[_off]> set to the current file position.  It is a cross between
<<lseek>> and <<fseek>>, with the <[_whence]> argument interpreted in
the same manner.  A NULL <[functions.seek]> makes the stream behave
similarly to a pipe in relation to stdio functions that require
positioning.

<[functions.close]> should return -1 on failure, or 0 on success.  It
is similar to <<close>>, except that <[cookie]> will be passed as the
first argument.  A NULL <[functions.close]> merely flushes all data
then lets <<fclose>> succeed.  A failed close will still invalidate
the stream.

Read and write I/O functions are allowed to change the underlying
buffer on fully buffered or line buffered streams by calling
<<setvbuf>>.  They are also not required to completely fill or empty
the buffer.  They are not, however, allowed to change streams from
unbuffered to buffered or to change the state of the line buffering
flag.  They must also be prepared to have read or write calls occur on
buffers other than the one most recently specified.

RETURNS
The return value is an open FILE pointer on success.  On error,
<<NULL>> is returned, and <<errno>> will be set to EINVAL if a
function pointer is missing or <[mode]> is invalid, ENOMEM if the
stream cannot be created, or EMFILE if too many streams are already
open.

PORTABILITY
This function is a newlib extension, copying the prototype from Linux.
It is not portable.  See also the <<funopen>> interface from BSD.

Supporting OS subroutines required: <<sbrk>>.
*/

#include <stdio.h>
#include <errno.h>
#include <sys/lock.h>
#include "local.h"

typedef struct fccookie {
  void *cookie;
  FILE *fp;
  cookie_read_function_t *readfn;
  cookie_write_function_t *writefn;
  cookie_seek_function_t *seekfn;
  cookie_close_function_t *closefn;
} fccookie;

static _READ_WRITE_RETURN_TYPE
_DEFUN(fcreader, (ptr, cookie, buf, n),
       struct _reent *ptr _AND
       void *cookie _AND
       char *buf _AND
       int n)
{
  int result;
  fccookie *c = (fccookie *) cookie;
  errno = 0;
  if ((result = c->readfn (c->cookie, buf, n)) < 0 && errno)
    ptr->_errno = errno;
  return result;
}

static _READ_WRITE_RETURN_TYPE
_DEFUN(fcwriter, (ptr, cookie, buf, n),
       struct _reent *ptr _AND
       void *cookie _AND
       const char *buf _AND
       int n)
{
  int result;
  fccookie *c = (fccookie *) cookie;
  if (c->fp->_flags & __SAPP && c->fp->_seek)
    {
#ifdef __LARGE64_FILES
      c->fp->_seek64 (ptr, cookie, 0, SEEK_END);
#else
      c->fp->_seek (ptr, cookie, 0, SEEK_END);
#endif
    }
  errno = 0;
  if ((result = c->writefn (c->cookie, buf, n)) < 0 && errno)
    ptr->_errno = errno;
  return result;
}

static _fpos_t
_DEFUN(fcseeker, (ptr, cookie, pos, whence),
       struct _reent *ptr _AND
       void *cookie _AND
       _fpos_t pos _AND
       int whence)
{
  fccookie *c = (fccookie *) cookie;
#ifndef __LARGE64_FILES
  off_t offset = (off_t) pos;
#else /* __LARGE64_FILES */
  _off64_t offset = (_off64_t) pos;
#endif /* __LARGE64_FILES */

  errno = 0;
  if (c->seekfn (c->cookie, &offset, whence) < 0 && errno)
    ptr->_errno = errno;
#ifdef __LARGE64_FILES
  else if ((_fpos_t)offset != offset)
    {
      ptr->_errno = EOVERFLOW;
      offset = -1;
    }
#endif /* __LARGE64_FILES */
  return (_fpos_t) offset;
}

#ifdef __LARGE64_FILES
static _fpos64_t
_DEFUN(fcseeker64, (ptr, cookie, pos, whence),
       struct _reent *ptr _AND
       void *cookie _AND
       _fpos64_t pos _AND
       int whence)
{
  _off64_t offset;
  fccookie *c = (fccookie *) cookie;
  errno = 0;
  if (c->seekfn (c->cookie, &offset, whence) < 0 && errno)
    ptr->_errno = errno;
  return (_fpos64_t) offset;
}
#endif /* __LARGE64_FILES */

static int
_DEFUN(fccloser, (ptr, cookie),
       struct _reent *ptr _AND
       void *cookie)
{
  int result = 0;
  fccookie *c = (fccookie *) cookie;
  if (c->closefn)
    {
      errno = 0;
      if ((result = c->closefn (c->cookie)) < 0 && errno)
	ptr->_errno = errno;
    }
  _free_r (ptr, c);
  return result;
}

FILE *
_DEFUN(_fopencookie_r, (ptr, cookie, mode, functions),
       struct _reent *ptr _AND
       void *cookie _AND
       const char *mode _AND
       cookie_io_functions_t functions)
{
  FILE *fp;
  fccookie *c;
  int flags;
  int dummy;

  if ((flags = __sflags (ptr, mode, &dummy)) == 0)
    return NULL;
  if (((flags & (__SRD | __SRW)) && !functions.read)
      || ((flags & (__SWR | __SRW)) && !functions.write))
    {
      ptr->_errno = EINVAL;
      return NULL;
    }
  if ((fp = __sfp (ptr)) == NULL)
    return NULL;
  if ((c = (fccookie *) _malloc_r (ptr, sizeof *c)) == NULL)
    {
      __sfp_lock_acquire ();
      fp->_flags = 0;		/* release */
#ifndef __SINGLE_THREAD__
      __lock_close_recursive (fp->_lock);
#endif
      __sfp_lock_release ();
      return NULL;
    }

  _flockfile (fp);
  fp->_file = -1;
  fp->_flags = flags;
  c->cookie = cookie;
  c->fp = fp;
  fp->_cookie = c;
  c->readfn = functions.read;
  fp->_read = fcreader;
  c->writefn = functions.write;
  fp->_write = fcwriter;
  c->seekfn = functions.seek;
  fp->_seek = functions.seek ? fcseeker : NULL;
#ifdef __LARGE64_FILES
  fp->_seek64 = functions.seek ? fcseeker64 : NULL;
  fp->_flags |= __SL64;
#endif
  c->closefn = functions.close;
  fp->_close = fccloser;
  _funlockfile (fp);
  return fp;
}

#ifndef _REENT_ONLY
FILE *
_DEFUN(fopencookie, (cookie, mode, functions),
       void *cookie _AND
       const char *mode _AND
       cookie_io_functions_t functions)
{
  return _fopencookie_r (_REENT, cookie, mode, functions);
}
#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fgetc>>---get a character from a file or stream

INDEX
	fgetc
INDEX
	_fgetc_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fgetc(FILE *<[fp]>);

	#include <stdio.h>
	int _fgetc_r(struct _reent *<[ptr]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int fgetc(<[fp]>)
	FILE *<[fp]>;

	#include <stdio.h>
	int _fgetc_r(<[ptr]>, <[fp]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;

DESCRIPTION
Use <<fgetc>> to get the next single character from the file or stream
identified by <[fp]>.  As a side effect, <<fgetc>> advances the file's
current position indicator.

For a macro version of this function, see <<getc>>.

The function <<_fgetc_r>> is simply a reentrant version of
<<fgetc>> that is passed the additional reentrant structure
pointer argument: <[ptr]>.

RETURNS
The next character (read as an <<unsigned char>>, and cast to
<<int>>), unless there is no more data, or the host system reports a
read error; in either of these situations, <<fgetc>> returns <<EOF>>.

You can distinguish the two situations that cause an <<EOF>> result by
using the <<ferror>> and <<feof>> functions.

PORTABILITY
ANSI C requires <<fgetc>>.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include "local.h"
#endif

int
_DEFUN(_fgetc_r, (ptr, fp),
       struct _reent * ptr _AND
       FILE * fp)
{
  int result;
  CHECK_INIT(ptr, fp);
  _flockfile (fp);
  result = __sgetc_r (ptr, fp);
  _funlockfile (fp);
  return result;
}

#ifndef _REENT_ONLY

int
_DEFUN(fgetc, (fp),
       FILE * fp)
{
#if !defined(PREFER_SIZE_OVER_SPEED) && !defined(__OPTIMIZE_SIZE__)
  int result;
  CHECK_INIT(_REENT, fp);
  __sfp_lock_acquire ();
  _flockfile (fp);
  result = __sgetc_r (_REENT, fp);
  _funlockfile (fp);
  __sfp_lock_release ();
  return result;
#else
  return _fgetc_r (_REENT, fp);
#endif
}

#endif /* !_REENT_ONLY */

/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fgets>>---get character string from a file or stream

INDEX
	fgets
INDEX
	_fgets_r

ANSI_SYNOPSIS
        #include <stdio.h>
	char *fgets(char *<[buf]>, int <[n]>, FILE *<[fp]>);

        #include <stdio.h>
	char *_fgets_r(struct _reent *<[ptr]>, char *<[buf]>, int <[n]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	char *fgets(<[buf]>,<[n]>,<[fp]>)
        char *<[buf]>;
	int <[n]>;
	FILE *<[fp]>;

	#include <stdio.h>
	char *_fgets_r(<[ptr]>, <[buf]>,<[n]>,<[fp]>)
	struct _reent *<[ptr]>;
        char *<[buf]>;
	int <[n]>;
	FILE *<[fp]>;

DESCRIPTION
	Reads at most <[n-1]> characters from <[fp]> until a newline
	is found. The characters including to the newline are stored
	in <[buf]>. The buffer is terminated with a 0.

	The <<_fgets_r>> function is simply the reentrant version of
	<<fgets>> and is passed an additional reentrancy structure
	pointer: <[ptr]>.

RETURNS
	<<fgets>> returns the buffer passed to it, with the data
	filled in. If end of file occurs with some data already
	accumulated, the data is returned with no other indication. If
	no data are read, NULL is returned instead.

PORTABILITY
	<<fgets>> should replace all uses of <<gets>>. Note however
	that <<fgets>> returns all of the data, while <<gets>> removes
	the trailing newline (with no indication that it has done so.)

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include <string.h>
#include "local.h"
#endif

/*
 * Read at most n-1 characters from the given file.
 * Stop when a newline has been read, or the count runs out.
 * Return first argument, or NULL if no characters were read.
 */

char *
_DEFUN(_fgets_r, (ptr, buf, n, fp),
       struct _reent * ptr _AND
       char *buf _AND
       int n     _AND
       FILE * fp)
{
  size_t len;
  char *s;
  unsigned char *p, *t;

  if (n < 2)			/* sanity check */
    return 0;

  s = buf;

  CHECK_INIT(ptr, fp);

  __sfp_lock_acquire ();
  _flockfile (fp);
#ifdef __SCLE
  if (fp->_flags & __SCLE)
    {
      int c;
      /* Sorry, have to do it the slow way */
      while (--n > 0 && (c = __sgetc_r (ptr, fp)) != EOF)
	{
	  *s++ = c;
	  if (c == '\n')
	    break;
	}
      if (c == EOF && s == buf)
        {
          _funlockfile (fp);
	  __sfp_lock_release ();
          return NULL;
        }
      *s = 0;
      _funlockfile (fp);
      __sfp_lock_release ();
      return buf;
    }
#endif

  n--;				/* leave space for NUL */
  do
    {
      /*
       * If the buffer is empty, refill it.
       */
      if ((len = fp->_r) <= 0)
	{
	  if (__srefill_r (ptr, fp))
	    {
	      /* EOF: stop with partial or no line */
	      if (s == buf)
                {
                  _funlockfile (fp);
		  __sfp_lock_release ();
                  return 0;
                }
	      break;
	    }
	  len = fp->_r;
	}
      p = fp->_p;

      /*
       * Scan through at most n bytes of the current buffer,
       * looking for '\n'.  If found, copy up to and including
       * newline, and stop.  Otherwise, copy entire chunk
       * and loop.
       */
      if (len > n)
	len = n;
      t = (unsigned char *) memchr ((_PTR) p, '\n', len);
      if (t != 0)
	{
	  len = ++t - p;
	  fp->_r -= len;
	  fp->_p = t;
	  _CAST_VOID memcpy ((_PTR) s, (_PTR) p, len);
	  s[len] = 0;
          _funlockfile (fp);
	  __sfp_lock_release ();
	  return (buf);
	}
      fp->_r -= len;
      fp->_p += len;
      _CAST_VOID memcpy ((_PTR) s, (_PTR) p, len);
      s += len;
    }
  while ((n -= len) != 0);
  *s = 0;
  _funlockfile (fp);
  __sfp_lock_release ();
  return buf;
}

#ifndef _REENT_ONLY

char *
_DEFUN(fgets, (buf, n, fp),
       char *buf _AND
       int n     _AND
       FILE * fp)
{
  return _fgets_r (_REENT, buf, n, fp);
}

#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fileno>>---return file descriptor associated with stream

INDEX
	fileno

ANSI_SYNOPSIS
	#include <stdio.h>
	int fileno(FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int fileno(<[fp]>)
	FILE *<[fp]>;

DESCRIPTION
You can use <<fileno>> to return the file descriptor identified by <[fp]>.

RETURNS
<<fileno>> returns a non-negative integer when successful.
If <[fp]> is not an open stream, <<fileno>> returns -1.

PORTABILITY
<<fileno>> is not part of ANSI C.
POSIX requires <<fileno>>.

Supporting OS subroutines required: none.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include "local.h"
#endif

int
_DEFUN(fileno, (f),
       FILE * f)
{
  int result;
  CHECK_INIT (_REENT, f);
  _flockfile (f);
  result = __sfileno (f);
  _funlockfile (f);
  return result;
}
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fputc>>---write a character on a stream or file

INDEX
	fputc
INDEX
	_fputc_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fputc(int <[ch]>, FILE *<[fp]>);

	#include <stdio.h>
	int _fputc_r(struct _rent *<[ptr]>, int <[ch]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int fputc(<[ch]>, <[fp]>)
	int <[ch]>;
	FILE *<[fp]>;

	#include <stdio.h>
	int _fputc_r(<[ptr]>, <[ch]>, <[fp]>)
	struct _reent *<[ptr]>;
	int <[ch]>;
	FILE *<[fp]>;

DESCRIPTION
<<fputc>> converts the argument <[ch]> from an <<int>> to an
<<unsigned char>>, then writes it to the file or stream identified by
<[fp]>.

If the file was opened with append mode (or if the stream cannot
support positioning), then the new character goes at the end of the
file or stream.  Otherwise, the new character is written at the
current value of the position indicator, and the position indicator
oadvances by one.

For a macro version of this function, see <<putc>>.

The <<_fputc_r>> function is simply a reentrant version of <<fputc>>
that takes an additional reentrant structure argument: <[ptr]>.

RETURNS
If successful, <<fputc>> returns its argument <[ch]>.  If an error
intervenes, the result is <<EOF>>.  You can use `<<ferror(<[fp]>)>>' to
query for errors.

PORTABILITY
<<fputc>> is required by ANSI C.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include "local.h"
#endif

int
_DEFUN(_fputc_r, (ptr, ch, file),
       struct _reent *ptr _AND
       int ch _AND
       FILE * file)
{
  int result;
  CHECK_INIT(ptr, file);
   _flockfile (file);
  result = _putc_r (ptr, ch, file);
  _funlockfile (file);
  return result;
}

#ifndef _REENT_ONLY
int
_DEFUN(fputc, (ch, file),
       int ch _AND
       FILE * file)
{
#if !defined(__OPTIMIZE_SIZE__) && !defined(PREFER_SIZE_OVER_SPEED)
  int result;
  CHECK_INIT(_REENT, file);
   _flockfile (file);
  result = _putc_r (_REENT, ch, file);
  _funlockfile (file);
  return result;
#else
  return _fputc_r (_REENT, ch, file);
#endif
}
#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990, 2007 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fread>>---read array elements from a file

INDEX
	fread
INDEX
	_fread_r

ANSI_SYNOPSIS
	#include <stdio.h>
	size_t fread(void *<[buf]>, size_t <[size]>, size_t <[count]>,
		     FILE *<[fp]>);

	#include <stdio.h>
	size_t _fread_r(struct _reent *<[ptr]>, void *<[buf]>,
	                size_t <[size]>, size_t <[count]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	size_t fread(<[buf]>, <[size]>, <[count]>, <[fp]>)
	char *<[buf]>;
	size_t <[size]>;
	size_t <[count]>;
	FILE *<[fp]>;

	#include <stdio.h>
	size_t _fread_r(<[ptr]>, <[buf]>, <[size]>, <[count]>, <[fp]>)
	struct _reent *<[ptr]>;
	char *<[buf]>;
	size_t <[size]>;
	size_t <[count]>;
	FILE *<[fp]>;

DESCRIPTION
<<fread>> attempts to copy, from the file or stream identified by
<[fp]>, <[count]> elements (each of size <[size]>) into memory,
starting at <[buf]>.   <<fread>> may copy fewer elements than
<[count]> if an error, or end of file, intervenes.

<<fread>> also advances the file position indicator (if any) for
<[fp]> by the number of @emph{characters} actually read.

<<_fread_r>> is simply the reentrant version of <<fread>> that
takes an additional reentrant structure pointer argument: <[ptr]>.

RETURNS
The result of <<fread>> is the number of elements it succeeded in
reading.

PORTABILITY
ANSI C requires <<fread>>.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "local.h"
#endif

#ifdef __SCLE
static size_t
_DEFUN(crlf_r, (ptr, fp, buf, count, eof),
       struct _reent * ptr _AND
       FILE * fp _AND
       char * buf _AND
       size_t count _AND
       int eof)
{
  int r;
  char *s, *d, *e;

  if (count == 0)
    return 0;

  e = buf + count;
  for (s=d=buf; s<e-1; s++)
    {
      if (*s == '\r' && s[1] == '\n')
        s++;
      *d++ = *s;
    }
  if (s < e)
    {
      if (*s == '\r')
        {
          int c = __sgetc_raw_r (ptr, fp);
          if (c == '\n')
            *s = '\n';
          else
            ungetc (c, fp);
        }
      *d++ = *s++;
    }


  while (d < e)
    {
      r = _getc_r (ptr, fp);
      if (r == EOF)
        return count - (e-d);
      *d++ = r;
    }

  return count;

}

#endif

size_t
_DEFUN(_fread_r, (ptr, buf, size, count, fp),
       struct _reent * ptr _AND
       _PTR buf _AND
       size_t size _AND
       size_t count _AND
       FILE * fp)
{
  register size_t resid;
  register char *p;
  register int r;
  size_t total;

  if ((resid = count * size) == 0)
    return 0;

  CHECK_INIT(ptr, fp);

  __sfp_lock_acquire ();
  _flockfile (fp);
  ORIENT (fp, -1);
  if (fp->_r < 0)
    fp->_r = 0;
  total = resid;
  p = buf;

#if !defined(PREFER_SIZE_OVER_SPEED) && !defined(__OPTIMIZE_SIZE__)

  /* Optimize unbuffered I/O.  */
  if (fp->_flags & __SNBF)
    {
      /* First copy any available characters from ungetc buffer.  */
      int copy_size = resid > fp->_r ? fp->_r : resid;
      _CAST_VOID memcpy ((_PTR) p, (_PTR) fp->_p, (size_t) copy_size);
      fp->_p += copy_size;
      fp->_r -= copy_size;
      p += copy_size;
      resid -= copy_size;

      /* If still more data needed, free any allocated ungetc buffer.  */
      if (HASUB (fp) && resid > 0)
	FREEUB (ptr, fp);

      /* Finally read directly into user's buffer if needed.  */
      while (resid > 0)
	{
	  int rc = 0;
	  /* save fp buffering state */
	  void *old_base = fp->_bf._base;
	  void * old_p = fp->_p;
	  int old_size = fp->_bf._size;
	  /* allow __refill to use user's buffer */
	  fp->_bf._base = (unsigned char *) p;
	  fp->_bf._size = resid;
	  fp->_p = (unsigned char *) p;
	  rc = __srefill_r (ptr, fp);
	  /* restore fp buffering back to original state */
	  fp->_bf._base = old_base;
	  fp->_bf._size = old_size;
	  fp->_p = old_p;
	  resid -= fp->_r;
	  p += fp->_r;
	  fp->_r = 0;
	  if (rc)
	    {
#ifdef __SCLE
              if (fp->_flags & __SCLE)
	        {
	          _funlockfile (fp);
		  __sfp_lock_release ();
	          return crlf_r (ptr, fp, buf, total-resid, 1) / size;
	        }
#endif
	      _funlockfile (fp);
	      __sfp_lock_release ();
	      return (total - resid) / size;
	    }
	}
    }
  else
#endif /* !PREFER_SIZE_OVER_SPEED && !__OPTIMIZE_SIZE__ */
    {
      while (resid > (r = fp->_r))
	{
	  _CAST_VOID memcpy ((_PTR) p, (_PTR) fp->_p, (size_t) r);
	  fp->_p += r;
	  /* fp->_r = 0 ... done in __srefill */
	  p += r;
	  resid -= r;
	  if (__srefill_r (ptr, fp))
	    {
	      /* no more input: return partial result */
#ifdef __SCLE
	      if (fp->_flags & __SCLE)
		{
		  _funlockfile (fp);
		  __sfp_lock_release ();
		  return crlf_r (ptr, fp, buf, total-resid, 1) / size;
		}
#endif
	      _funlockfile (fp);
	      __sfp_lock_release ();
	      return (total - resid) / size;
	    }
	}
      _CAST_VOID memcpy ((_PTR) p, (_PTR) fp->_p, resid);
      fp->_r -= resid;
      fp->_p += resid;
    }

  /* Perform any CR/LF clean-up if necessary.  */
#ifdef __SCLE
  if (fp->_flags & __SCLE)
    {
      _funlockfile (fp);
      __sfp_lock_release ();
      return crlf_r(ptr, fp, buf, total, 0) / size;
    }
#endif
  _funlockfile (fp);
  __sfp_lock_release ();
  return count;
}

#ifndef _REENT_ONLY
size_t
_DEFUN(fread, (buf, size, count, fp),
       _PTR buf _AND
       size_t size _AND
       size_t count _AND
       FILE * fp)
{
   return _fread_r (_REENT, buf, size, count, fp);
}
#endif
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fseek>>, <<fseeko>>---set file position

INDEX
	fseek
INDEX
	fseeko
INDEX
	_fseek_r
INDEX
	_fseeko_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int fseek(FILE *<[fp]>, long <[offset]>, int <[whence]>)
	int fseeko(FILE *<[fp]>, off_t <[offset]>, int <[whence]>)
	int _fseek_r(struct _reent *<[ptr]>, FILE *<[fp]>,
	             long <[offset]>, int <[whence]>)
	int _fseeko_r(struct _reent *<[ptr]>, FILE *<[fp]>,
	             off_t <[offset]>, int <[whence]>)

TRAD_SYNOPSIS
	#include <stdio.h>
	int fseek(<[fp]>, <[offset]>, <[whence]>)
	FILE *<[fp]>;
	long <[offset]>;
	int <[whence]>;

	int fseeko(<[fp]>, <[offset]>, <[whence]>)
	FILE *<[fp]>;
	off_t <[offset]>;
	int <[whence]>;

	int _fseek_r(<[ptr]>, <[fp]>, <[offset]>, <[whence]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;
	long <[offset]>;
	int <[whence]>;

	int _fseeko_r(<[ptr]>, <[fp]>, <[offset]>, <[whence]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;
	off_t <[offset]>;
	int <[whence]>;

DESCRIPTION
Objects of type <<FILE>> can have a ``position'' that records how much
of the file your program has already read.  Many of the <<stdio>> functions
depend on this position, and many change it as a side effect.

You can use <<fseek>>/<<fseeko>> to set the position for the file identified by
<[fp]>.  The value of <[offset]> determines the new position, in one
of three ways selected by the value of <[whence]> (defined as macros
in `<<stdio.h>>'):

<<SEEK_SET>>---<[offset]> is the absolute file position (an offset
from the beginning of the file) desired.  <[offset]> must be positive.

<<SEEK_CUR>>---<[offset]> is relative to the current file position.
<[offset]> can meaningfully be either positive or negative.

<<SEEK_END>>---<[offset]> is relative to the current end of file.
<[offset]> can meaningfully be either positive (to increase the size
of the file) or negative.

See <<ftell>>/<<ftello>> to determine the current file position.

RETURNS
<<fseek>>/<<fseeko>> return <<0>> when successful.  On failure, the
result is <<EOF>>.  The reason for failure is indicated in <<errno>>:
either <<ESPIPE>> (the stream identified by <[fp]> doesn't support
repositioning) or <<EINVAL>> (invalid file position).

PORTABILITY
ANSI C requires <<fseek>>.

<<fseeko>> is defined by the Single Unix specification.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <fcntl.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/stat.h>
#include "local.h"
#endif

#define	POS_ERR	(-(_fpos_t)1)

/*
 * Seek the given file to the given offset.
 * `Whence' must be one of the three SEEK_* macros.
 */

int
_DEFUN(_fseek_r, (ptr, fp, offset, whence),
       struct _reent *ptr _AND
       register FILE *fp  _AND
       long offset        _AND
       int whence)
{
  _fpos_t _EXFUN((*seekfn), (struct _reent *, _PTR, _fpos_t, int));
  _fpos_t target;
  _fpos_t curoff = 0;
  size_t n;
#ifdef __USE_INTERNAL_STAT64
  struct stat64 st;
#else
  struct stat st;
#endif
  int havepos;

  /* Make sure stdio is set up.  */

  CHECK_INIT (ptr, fp);

  __sfp_lock_acquire ();
  _flockfile (fp);

  /* If we've been doing some writing, and we're in append mode
     then we don't really know where the filepos is.  */

  if (fp->_flags & __SAPP && fp->_flags & __SWR)
    {
      /* So flush the buffer and seek to the end.  */
      _fflush_r (ptr, fp);
    }

  /* Have to be able to seek.  */

  if ((seekfn = fp->_seek) == NULL)
    {
      ptr->_errno = ESPIPE;	/* ??? */
      _funlockfile (fp);
      __sfp_lock_release ();
      return EOF;
    }

  /*
   * Change any SEEK_CUR to SEEK_SET, and check `whence' argument.
   * After this, whence is either SEEK_SET or SEEK_END.
   */

  switch (whence)
    {
    case SEEK_CUR:
      /*
       * In order to seek relative to the current stream offset,
       * we have to first find the current stream offset a la
       * ftell (see ftell for details).
       */
      _fflush_r (ptr, fp);   /* may adjust seek offset on append stream */
      if (fp->_flags & __SOFF)
	curoff = fp->_offset;
      else
	{
	  curoff = seekfn (ptr, fp->_cookie, (_fpos_t) 0, SEEK_CUR);
	  if (curoff == -1L)
	    {
	      _funlockfile (fp);
	      __sfp_lock_release ();
	      return EOF;
	    }
	}
      if (fp->_flags & __SRD)
	{
	  curoff -= fp->_r;
	  if (HASUB (fp))
	    curoff -= fp->_ur;
	}
      else if (fp->_flags & __SWR && fp->_p != NULL)
	curoff += fp->_p - fp->_bf._base;

      offset += curoff;
      whence = SEEK_SET;
      havepos = 1;
      break;

    case SEEK_SET:
    case SEEK_END:
      havepos = 0;
      break;

    default:
      ptr->_errno = EINVAL;
      _funlockfile (fp);
      __sfp_lock_release ();
      return (EOF);
    }

  /*
   * Can only optimise if:
   *	reading (and not reading-and-writing);
   *	not unbuffered; and
   *	this is a `regular' Unix file (and hence seekfn==__sseek).
   * We must check __NBF first, because it is possible to have __NBF
   * and __SOPT both set.
   */

  if (fp->_bf._base == NULL)
    __smakebuf_r (ptr, fp);
  if (fp->_flags & (__SWR | __SRW | __SNBF | __SNPT))
    goto dumb;
  if ((fp->_flags & __SOPT) == 0)
    {
      if (seekfn != __sseek
	  || fp->_file < 0
#ifdef __USE_INTERNAL_STAT64
	  || _fstat64_r (ptr, fp->_file, &st)
#else
	  || _fstat_r (ptr, fp->_file, &st)
#endif
	  || (st.st_mode & S_IFMT) != S_IFREG)
	{
	  fp->_flags |= __SNPT;
	  goto dumb;
	}
#ifdef	HAVE_BLKSIZE
      fp->_blksize = st.st_blksize;
#else
      fp->_blksize = 1024;
#endif
      fp->_flags |= __SOPT;
    }

  /*
   * We are reading; we can try to optimise.
   * Figure out where we are going and where we are now.
   */

  if (whence == SEEK_SET)
    target = offset;
  else
    {
#ifdef __USE_INTERNAL_STAT64
      if (_fstat64_r (ptr, fp->_file, &st))
#else
      if (_fstat_r (ptr, fp->_file, &st))
#endif
	goto dumb;
      target = st.st_size + offset;
    }
  if ((long)target != target)
    {
      ptr->_errno = EOVERFLOW;
      _funlockfile (fp);
      __sfp_lock_release ();
      return EOF;
    }

  if (!havepos)
    {
      if (fp->_flags & __SOFF)
	curoff = fp->_offset;
      else
	{
	  curoff = seekfn (ptr, fp->_cookie, 0L, SEEK_CUR);
	  if (curoff == POS_ERR)
	    goto dumb;
	}
      curoff -= fp->_r;
      if (HASUB (fp))
	curoff -= fp->_ur;
    }

  /*
   * Compute the number of bytes in the input buffer (pretending
   * that any ungetc() input has been discarded).  Adjust current
   * offset backwards by this count so that it represents the
   * file offset for the first byte in the current input buffer.
   */

  if (HASUB (fp))
    {
      curoff += fp->_r;       /* kill off ungetc */
      n = fp->_up - fp->_bf._base;
      curoff -= n;
      n += fp->_ur;
    }
  else
    {
      n = fp->_p - fp->_bf._base;
      curoff -= n;
      n += fp->_r;
    }

  /*
   * If the target offset is within the current buffer,
   * simply adjust the pointers, clear EOF, undo ungetc(),
   * and return.
   */

  if (target >= curoff && target < curoff + n)
    {
      register int o = target - curoff;

      fp->_p = fp->_bf._base + o;
      fp->_r = n - o;
      if (HASUB (fp))
	FREEUB (ptr, fp);
      fp->_flags &= ~__SEOF;
      memset (&fp->_mbstate, 0, sizeof (_mbstate_t));
      _funlockfile (fp);
      __sfp_lock_release ();
      return 0;
    }

  /*
   * The place we want to get to is not within the current buffer,
   * but we can still be kind to the kernel copyout mechanism.
   * By aligning the file offset to a block boundary, we can let
   * the kernel use the VM hardware to map pages instead of
   * copying bytes laboriously.  Using a block boundary also
   * ensures that we only read one block, rather than two.
   */

  curoff = target & ~(fp->_blksize - 1);
  if (seekfn (ptr, fp->_cookie, curoff, SEEK_SET) == POS_ERR)
    goto dumb;
  fp->_r = 0;
  fp->_p = fp->_bf._base;
  if (HASUB (fp))
    FREEUB (ptr, fp);
  fp->_flags &= ~__SEOF;
  n = target - curoff;
  if (n)
    {
      if (__srefill_r (ptr, fp) || fp->_r < n)
	goto dumb;
      fp->_p += n;
      fp->_r -= n;
    }
  memset (&fp->_mbstate, 0, sizeof (_mbstate_t));
  _funlockfile (fp);
  __sfp_lock_release ();
  return 0;

  /*
   * We get here if we cannot optimise the seek ... just
   * do it.  Allow the seek function to change fp->_bf._base.
   */

dumb:
  if (_fflush_r (ptr, fp)
      || seekfn (ptr, fp->_cookie, offset, whence) == POS_ERR)
    {
      _funlockfile (fp);
      __sfp_lock_release ();
      return EOF;
    }
  /* success: clear EOF indicator and discard ungetc() data */
  if (HASUB (fp))
    FREEUB (ptr, fp);
  fp->_p = fp->_bf._base;
  fp->_r = 0;
  /* fp->_w = 0; *//* unnecessary (I think...) */
  fp->_flags &= ~__SEOF;
  /* Reset no-optimization flag after successful seek.  The
     no-optimization flag may be set in the case of a read
     stream that is flushed which by POSIX/SUSv3 standards,
     means that a corresponding seek must not optimize.  The
     optimization is then allowed if no subsequent flush
     is performed.  */
  fp->_flags &= ~__SNPT;
  memset (&fp->_mbstate, 0, sizeof (_mbstate_t));
  _funlockfile (fp);
  __sfp_lock_release ();
  return 0;
}

#ifndef _REENT_ONLY

int
_DEFUN(fseek, (fp, offset, whence),
       register FILE *fp _AND
       long offset       _AND
       int whence)
{
  return _fseek_r (_REENT, fp, offset, whence);
}

#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<ftell>>, <<ftello>>---return position in a stream or file

INDEX
	ftell
INDEX
	ftello
INDEX
	_ftell_r
INDEX
	_ftello_r

ANSI_SYNOPSIS
	#include <stdio.h>
	long ftell(FILE *<[fp]>);
	off_t ftello(FILE *<[fp]>);
	long _ftell_r(struct _reent *<[ptr]>, FILE *<[fp]>);
	off_t _ftello_r(struct _reent *<[ptr]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	long ftell(<[fp]>)
	FILE *<[fp]>;

	off_t ftello(<[fp]>)
	FILE *<[fp]>;

	long _ftell_r(<[ptr]>, <[fp]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;

	off_t _ftello_r(<[ptr]>, <[fp]>)
	struct _reent *<[ptr]>;
	FILE *<[fp]>;

DESCRIPTION
Objects of type <<FILE>> can have a ``position'' that records how much
of the file your program has already read.  Many of the <<stdio>> functions
depend on this position, and many change it as a side effect.

The result of <<ftell>>/<<ftello>> is the current position for a file
identified by <[fp]>.  If you record this result, you can later
use it with <<fseek>>/<<fseeko>> to return the file to this
position.  The difference between <<ftell>> and <<ftello>> is that
<<ftell>> returns <<long>> and <<ftello>> returns <<off_t>>.

In the current implementation, <<ftell>>/<<ftello>> simply uses a character
count to represent the file position; this is the same number that
would be recorded by <<fgetpos>>.

RETURNS
<<ftell>>/<<ftello>> return the file position, if possible.  If they cannot do
this, they return <<-1L>>.  Failure occurs on streams that do not support
positioning; the global <<errno>> indicates this condition with the
value <<ESPIPE>>.

PORTABILITY
<<ftell>> is required by the ANSI C standard, but the meaning of its
result (when successful) is not specified beyond requiring that it be
acceptable as an argument to <<fseek>>.  In particular, other
conforming C implementations may return a different result from
<<ftell>> than what <<fgetpos>> records.

<<ftello>> is defined by the Single Unix specification.

No supporting OS subroutines are required.
*/

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "%W% (Berkeley) %G%";
#endif /* LIBC_SCCS and not lint */

/*
 * ftell: return current offset.
 */

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdio.h>
#include <errno.h>
#include "local.h"
#endif

long
_DEFUN(_ftell_r, (ptr, fp),
       struct _reent *ptr _AND
       register FILE * fp)
{
  _fpos_t pos;

  /* Ensure stdio is set up.  */

  CHECK_INIT (ptr, fp);

  _flockfile (fp);

  if (fp->_seek == NULL)
    {
      ptr->_errno = ESPIPE;
      _funlockfile (fp);
      return -1L;
    }

  /* Find offset of underlying I/O object, then adjust for buffered
     bytes.  Flush a write stream, since the offset may be altered if
     the stream is appending.  Do not flush a read stream, since we
     must not lose the ungetc buffer.  */
  if (fp->_flags & __SWR)
    _fflush_r (ptr, fp);
  if (fp->_flags & __SOFF)
    pos = fp->_offset;
  else
    {
      pos = fp->_seek (ptr, fp->_cookie, (_fpos_t) 0, SEEK_CUR);
      if (pos == -1L)
        {
          _funlockfile (fp);
          return pos;
        }
    }
  if (fp->_flags & __SRD)
    {
      /*
       * Reading.  Any unread characters (including
       * those from ungetc) cause the position to be
       * smaller than that in the underlying object.
       */
      pos -= fp->_r;
      if (HASUB (fp))
	pos -= fp->_ur;
    }
  else if ((fp->_flags & __SWR) && fp->_p != NULL)
    {
      /*
       * Writing.  Any buffered characters cause the
       * position to be greater than that in the
       * underlying object.
       */
      pos += fp->_p - fp->_bf._base;
    }

  _funlockfile (fp);
  if ((long)pos != pos)
    {
      pos = -1;
      ptr->_errno = EOVERFLOW;
    }
  return pos;
}

#ifndef _REENT_ONLY

long
_DEFUN(ftell, (fp),
       register FILE * fp)
{
  return _ftell_r (_REENT, fp);
}

#endif /* !_REENT_ONLY */
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<fwrite>>---write array elements

INDEX
	fwrite
INDEX
	_fwrite_r

ANSI_SYNOPSIS
	#include <stdio.h>
	size_t fwrite(const void *<[buf]>, size_t <[size]>,
		      size_t <[count]>, FILE *<[fp]>);

	#include <stdio.h>
	size_t _fwrite_r(struct _reent *<[ptr]>, const void *<[buf]>, size_t <[size]>,
		      size_t <[count]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	size_t fwrite(<[buf]>, <[size]>, <[count]>, <[fp]>)
	char *<[buf]>;
	size_t <[size]>;
	size_t <[count]>;
	FILE *<[fp]>;

	#include <stdio.h>
	size_t _fwrite_r(<[ptr]>, <[buf]>, <[size]>, <[count]>, <[fp]>)
	struct _reent *<[ptr]>;
	char *<[buf]>;
	size_t <[size]>;
	size_t <[count]>;
	FILE *<[fp]>;

DESCRIPTION
<<fwrite>> attempts to copy, starting from the memory location
<[buf]>, <[count]> elements (each of size <[size]>) into the file or
stream identified by <[fp]>.  <<fwrite>> may copy fewer elements than
<[count]> if an error intervenes.

<<fwrite>> also advances the file position indicator (if any) for
<[fp]> by the number of @emph{characters} actually written.

<<_fwrite_r>> is simply the reentrant version of <<fwrite>> that
takes an additional reentrant structure argument: <[ptr]>.

RETURNS
If <<fwrite>> succeeds in writing all the elements you specify, the
result is the same as the argument <[count]>.  In any event, the
result is the number of complete elements that <<fwrite>> copied to
the file.

PORTABILITY
ANSI C requires <<fwrite>>.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "%W% (Berkeley) %G%";
#endif /* LIBC_SCCS and not lint */

#if 0
#include <_ansi.h>
#include <stdio.h>
#include <string.h>
#if 0
#include <sys/stdc.h>
#endif
#include "local.h"
#if 1
#include "fvwrite.h"
#endif
#endif

/*
 * Write `count' objects (each size `size') from memory to the given file.
 * Return the number of whole objects written.
 */

size_t
_DEFUN(_fwrite_r, (ptr, buf, size, count, fp),
       struct _reent * ptr _AND
       _CONST _PTR buf _AND
       size_t size     _AND
       size_t count    _AND
       FILE * fp)
{
  size_t n;
  struct __suio uio;
  struct __siov iov;

  iov.iov_base = buf;
  uio.uio_resid = iov.iov_len = n = count * size;
  uio.uio_iov = &iov;
  uio.uio_iovcnt = 1;

  /*
   * The usual case is success (__sfvwrite_r returns 0);
   * skip the divide if this happens, since divides are
   * generally slow and since this occurs whenever size==0.
   */

  CHECK_INIT(ptr, fp);

  _flockfile (fp);
  ORIENT (fp, -1);
  if (__sfvwrite_r (ptr, fp, &uio) == 0)
    {
      _funlockfile (fp);
      return count;
    }
  _funlockfile (fp);
  return (n - uio.uio_resid) / size;
}

#ifndef _REENT_ONLY
size_t
_DEFUN(fwrite, (buf, size, count, fp),
       _CONST _PTR buf _AND
       size_t size     _AND
       size_t count    _AND
       FILE * fp)
{
  return _fwrite_r (_REENT, buf, size, count, fp);
}
#endif
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
FUNCTION
<<setvbuf>>---specify file or stream buffering

INDEX
	setvbuf

ANSI_SYNOPSIS
	#include <stdio.h>
	int setvbuf(FILE *<[fp]>, char *<[buf]>,
	            int <[mode]>, size_t <[size]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int setvbuf(<[fp]>, <[buf]>, <[mode]>, <[size]>)
	FILE *<[fp]>;
	char *<[buf]>;
	int <[mode]>;
	size_t <[size]>;

DESCRIPTION
Use <<setvbuf>> to specify what kind of buffering you want for the
file or stream identified by <[fp]>, by using one of the following
values (from <<stdio.h>>) as the <[mode]> argument:

o+
o _IONBF
Do not use a buffer: send output directly to the host system for the
file or stream identified by <[fp]>.

o _IOFBF
Use full output buffering: output will be passed on to the host system
only when the buffer is full, or when an input operation intervenes.

o _IOLBF
Use line buffering: pass on output to the host system at every
newline, as well as when the buffer is full, or when an input
operation intervenes.
o-

Use the <[size]> argument to specify how large a buffer you wish.  You
can supply the buffer itself, if you wish, by passing a pointer to a
suitable area of memory as <[buf]>.  Otherwise, you may pass <<NULL>>
as the <[buf]> argument, and <<setvbuf>> will allocate the buffer.

WARNINGS
You may only use <<setvbuf>> before performing any file operation other
than opening the file.

If you supply a non-null <[buf]>, you must ensure that the associated
storage continues to be available until you close the stream
identified by <[fp]>.

RETURNS
A <<0>> result indicates success, <<EOF>> failure (invalid <[mode]> or
<[size]> can cause failure).

PORTABILITY
Both ANSI C and the System V Interface Definition (Issue 2) require
<<setvbuf>>. However, they differ on the meaning of a <<NULL>> buffer
pointer: the SVID issue 2 specification says that a <<NULL>> buffer
pointer requests unbuffered output.  For maximum portability, avoid
<<NULL>> buffer pointers.

Both specifications describe the result on failure only as a
nonzero value.

Supporting OS subroutines required: <<close>>, <<fstat>>, <<isatty>>,
<<lseek>>, <<read>>, <<sbrk>>, <<write>>.
*/

#if 0
#include <_ansi.h>
#include <stdio.h>
#include <stdlib.h>
#include "local.h"
#endif

/*
 * Set one of the three kinds of buffering, optionally including a buffer.
 */

int
_DEFUN(setvbuf, (fp, buf, mode, size),
       register FILE * fp _AND
       char *buf          _AND
       register int mode  _AND
       register size_t size)
{
  int ret = 0;

  CHECK_INIT (_REENT, fp);

  _flockfile (fp);

  /*
   * Verify arguments.  The `int' limit on `size' is due to this
   * particular implementation.
   */

  if ((mode != _IOFBF && mode != _IOLBF && mode != _IONBF) || (int)(_POINTER_INT) size < 0)
    {
      _funlockfile (fp);
      return (EOF);
    }

  /*
   * Write current buffer, if any; drop read count, if any.
   * Make sure putc() will not think fp is line buffered.
   * Free old buffer if it was from malloc().  Clear line and
   * non buffer flags, and clear malloc flag.
   */

  _fflush_r (_REENT, fp);
  fp->_r = 0;
  fp->_lbfsize = 0;
  if (fp->_flags & __SMBF)
    _free_r (_REENT, (_PTR) fp->_bf._base);
  fp->_flags &= ~(__SLBF | __SNBF | __SMBF);

  if (mode == _IONBF)
    goto nbf;

  /*
   * Allocate buffer if needed. */
  if (buf == NULL)
    {
      /* we need this here because malloc() may return a pointer
	 even if size == 0 */
      if (!size) size = BUFSIZ;
      if ((buf = malloc (size)) == NULL)
	{
	  ret = EOF;
	  /* Try another size... */
	  buf = malloc (BUFSIZ);
	  size = BUFSIZ;
	}
      if (buf == NULL)
        {
          /* Can't allocate it, let's try another approach */
nbf:
          fp->_flags |= __SNBF;
          fp->_w = 0;
          fp->_bf._base = fp->_p = fp->_nbuf;
          fp->_bf._size = 1;
          _funlockfile (fp);
          return (ret);
        }
      fp->_flags |= __SMBF;
    }
  /*
   * Now put back whichever flag is needed, and fix _lbfsize
   * if line buffered.  Ensure output flush on exit if the
   * stream will be buffered at all.
   * If buf is NULL then make _lbfsize 0 to force the buffer
   * to be flushed and hence malloced on first use
   */

  switch (mode)
    {
    case _IOLBF:
      fp->_flags |= __SLBF;
      fp->_lbfsize = buf ? -size : 0;
      /* FALLTHROUGH */

    case _IOFBF:
      /* no flag */
      _REENT->__cleanup = _cleanup_r;
      fp->_bf._base = fp->_p = (unsigned char *) buf;
      fp->_bf._size = size;
      break;
    }

  /*
   * Patch up write count if necessary.
   */

  if (fp->_flags & __SWR)
    fp->_w = fp->_flags & (__SLBF | __SNBF) ? 0 : size;

  _funlockfile (fp);
  return 0;
}
/*
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms are permitted
 * provided that the above copyright notice and this paragraph are
 * duplicated in all such forms and that any documentation,
 * advertising materials, and other materials related to such
 * distribution and use acknowledge that the software was developed
 * by the University of California, Berkeley.  The name of the
 * University may not be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */
/*
FUNCTION
<<ungetc>>---push data back into a stream

INDEX
	ungetc
INDEX
	_ungetc_r

ANSI_SYNOPSIS
	#include <stdio.h>
	int ungetc(int <[c]>, FILE *<[stream]>);

	int _ungetc_r(struct _reent *<[reent]>, int <[c]>, FILE *<[stream]>);

DESCRIPTION
<<ungetc>> is used to return bytes back to <[stream]> to be read again.
If <[c]> is EOF, the stream is unchanged.  Otherwise, the unsigned
char <[c]> is put back on the stream, and subsequent reads will see
the bytes pushed back in reverse order.  Pushed byes are lost if the
stream is repositioned, such as by <<fseek>>, <<fsetpos>>, or
<<rewind>>.

The underlying file is not changed, but it is possible to push back
something different than what was originally read.  Ungetting a
character will clear the end-of-stream marker, and decrement the file
position indicator.  Pushing back beyond the beginning of a file gives
unspecified behavior.

The alternate function <<_ungetc_r>> is a reentrant version.  The
extra argument <[reent]> is a pointer to a reentrancy structure.

RETURNS
The character pushed back, or <<EOF>> on error.

PORTABILITY
ANSI C requires <<ungetc>>, but only requires a pushback buffer of one
byte; although this implementation can handle multiple bytes, not all
can.  Pushing back a signed char is a common application bug.

Supporting OS subroutines required: <<sbrk>>.
*/

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "%W% (Berkeley) %G%";
#endif /* LIBC_SCCS and not lint */

#if 0
#include <_ansi.h>
#include <reent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "local.h"
#endif

/*
 * Expand the ungetc buffer `in place'.  That is, adjust fp->_p when
 * the buffer moves, so that it points the same distance from the end,
 * and move the bytes in the buffer around as necessary so that they
 * are all at the end (stack-style).
 */

/*static*/
int
_DEFUN(__submore, (rptr, fp),
       struct _reent *rptr _AND
       register FILE *fp)
{
  register int i;
  register unsigned char *p;

  if (fp->_ub._base == fp->_ubuf)
    {
      /*
       * Get a new buffer (rather than expanding the old one).
       */
      if ((p = (unsigned char *) _malloc_r (rptr, (size_t) BUFSIZ)) == NULL)
	return EOF;
      fp->_ub._base = p;
      fp->_ub._size = BUFSIZ;
      p += BUFSIZ - sizeof (fp->_ubuf);
      for (i = sizeof (fp->_ubuf); --i >= 0;)
	p[i] = fp->_ubuf[i];
      fp->_p = p;
      return 0;
    }
  i = fp->_ub._size;
  p = (unsigned char *) _realloc_r (rptr, (_PTR) (fp->_ub._base), i << 1);
  if (p == NULL)
    return EOF;
  _CAST_VOID memcpy ((_PTR) (p + i), (_PTR) p, (size_t) i);
  fp->_p = p + i;
  fp->_ub._base = p;
  fp->_ub._size = i << 1;
  return 0;
}

int
_DEFUN(_ungetc_r, (rptr, c, fp),
       struct _reent *rptr _AND
       int c               _AND
       register FILE *fp)
{
  if (c == EOF)
    return (EOF);

  /* Ensure stdio has been initialized.
     ??? Might be able to remove this as some other stdio routine should
     have already been called to get the char we are un-getting.  */

  CHECK_INIT (rptr, fp);

  _flockfile (fp);

  ORIENT (fp, -1);

  /* After ungetc, we won't be at eof anymore */
  fp->_flags &= ~__SEOF;

  if ((fp->_flags & __SRD) == 0)
    {
      /*
       * Not already reading: no good unless reading-and-writing.
       * Otherwise, flush any current write stuff.
       */
      if ((fp->_flags & __SRW) == 0)
        {
          _funlockfile (fp);
          return EOF;
        }
      if (fp->_flags & __SWR)
	{
	  if (_fflush_r (rptr, fp))
            {
              _funlockfile (fp);
              return EOF;
            }
	  fp->_flags &= ~__SWR;
	  fp->_w = 0;
	  fp->_lbfsize = 0;
	}
      fp->_flags |= __SRD;
    }
  c = (unsigned char) c;

  /*
   * If we are in the middle of ungetc'ing, just continue.
   * This may require expanding the current ungetc buffer.
   */

  if (HASUB (fp))
    {
      if (fp->_r >= fp->_ub._size && __submore (rptr, fp))
        {
          _funlockfile (fp);
          return EOF;
        }
      *--fp->_p = c;
      fp->_r++;
      _funlockfile (fp);
      return c;
    }

  /*
   * If we can handle this by simply backing up, do so,
   * but never replace the original character.
   * (This makes sscanf() work when scanning `const' data.)
   */

  if (fp->_bf._base != NULL && fp->_p > fp->_bf._base && fp->_p[-1] == c)
    {
      fp->_p--;
      fp->_r++;
      _funlockfile (fp);
      return c;
    }

  /*
   * Create an ungetc buffer.
   * Initially, we will use the `reserve' buffer.
   */

  fp->_ur = fp->_r;
  fp->_up = fp->_p;
  fp->_ub._base = fp->_ubuf;
  fp->_ub._size = sizeof (fp->_ubuf);
  fp->_ubuf[sizeof (fp->_ubuf) - 1] = c;
  fp->_p = &fp->_ubuf[sizeof (fp->_ubuf) - 1];
  fp->_r = 1;
  _funlockfile (fp);
  return c;
}

#ifndef _REENT_ONLY
int
_DEFUN(ungetc, (c, fp),
       int c               _AND
       register FILE *fp)
{
  return _ungetc_r (_REENT, c, fp);
}
#endif /* !_REENT_ONLY */

/* Copyright 2002, Red Hat Inc. - all rights reserved */
/*
FUNCTION
<<getline>>---read a line from a file

INDEX
        getline

ANSI_SYNOPSIS
        #include <stdio.h>
        ssize_t getline(char **<[bufptr]>, size_t *<[n]>, FILE *<[fp]>);

TRAD_SYNOPSIS
        #include <stdio.h>
        ssize_t getline(<[bufptr]>, <[n]>, <[fp]>)
        char **<[bufptr]>;
        size_t *<[n]>;
        FILE *<[fp]>;

DESCRIPTION
<<getline>> reads a file <[fp]> up to and possibly including the
newline character.  The line is read into a buffer pointed to
by <[bufptr]> and designated with size *<[n]>.  If the buffer is
not large enough, it will be dynamically grown by <<getdelim>>.
As the buffer is grown, the pointer to the size <[n]> will be
updated.

<<getline>> is equivalent to getdelim(bufptr, n, '\n', fp);

RETURNS
<<getline>> returns <<-1>> if no characters were successfully read,
otherwise, it returns the number of bytes successfully read.
at end of file, the result is nonzero.

PORTABILITY
<<getline>> is a glibc extension.

No supporting OS subroutines are directly required.
*/

#include <_ansi.h>
#include <stdio.h>

extern ssize_t _EXFUN(__getdelim, (char **, size_t *, int, FILE *));

ssize_t
_DEFUN(__getline, (lptr, n, fp),
       char **lptr _AND
       size_t *n   _AND
       FILE *fp)
{
  return __getdelim (lptr, n, '\n', fp);
}

/* Copyright 2002, Red Hat Inc. - all rights reserved */
/*
FUNCTION
<<getdelim>>---read a line up to a specified line delimiter

INDEX
	getdelim

ANSI_SYNOPSIS
	#include <stdio.h>
	int getdelim(char **<[bufptr]>, size_t *<[n]>,
                     int <[delim]>, FILE *<[fp]>);

TRAD_SYNOPSIS
	#include <stdio.h>
	int getdelim(<[bufptr]>, <[n]>, <[delim]>, <[fp]>)
	char **<[bufptr]>;
	size_t *<[n]>;
	int <[delim]>;
	FILE *<[fp]>;

DESCRIPTION
<<getdelim>> reads a file <[fp]> up to and possibly including a specified
delimiter <[delim]>.  The line is read into a buffer pointed to
by <[bufptr]> and designated with size *<[n]>.  If the buffer is
not large enough, it will be dynamically grown by <<getdelim>>.
As the buffer is grown, the pointer to the size <[n]> will be
updated.

RETURNS
<<getdelim>> returns <<-1>> if no characters were successfully read;
otherwise, it returns the number of bytes successfully read.
At end of file, the result is nonzero.

PORTABILITY
<<getdelim>> is a glibc extension.

No supporting OS subroutines are directly required.
*/

#include <_ansi.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "local.h"

#define MIN_LINE_SIZE 4
#define DEFAULT_LINE_SIZE 128

ssize_t
_DEFUN(__getdelim, (bufptr, n, delim, fp),
       char **bufptr _AND
       size_t *n     _AND
       int delim     _AND
       FILE *fp)
{
  char *buf;
  char *ptr;
  size_t newsize, numbytes;
  int pos;
  int ch;
  int cont;

  if (fp == NULL || bufptr == NULL || n == NULL)
    {
      errno = EINVAL;
      return -1;
    }

  buf = *bufptr;
  if (buf == NULL || *n < MIN_LINE_SIZE)
    {
      buf = (char *)realloc (*bufptr, DEFAULT_LINE_SIZE);
      if (buf == NULL)
        {
	  return -1;
        }
      *bufptr = buf;
      *n = DEFAULT_LINE_SIZE;
    }

  CHECK_INIT (_REENT, fp);

  __sfp_lock_acquire ();
  _flockfile (fp);

  numbytes = *n;
  ptr = buf;

  cont = 1;

  while (cont)
    {
      /* fill buffer - leaving room for nul-terminator */
      while (--numbytes > 0)
        {
          if ((ch = getc_unlocked (fp)) == EOF)
            {
	      cont = 0;
              break;
            }
	  else
            {
              *ptr++ = ch;
              if (ch == delim)
                {
                  cont = 0;
                  break;
                }
            }
        }

      if (cont)
        {
          /* Buffer is too small so reallocate a larger buffer.  */
          pos = ptr - buf;
          newsize = (*n << 1);
          buf = realloc (buf, newsize);
          if (buf == NULL)
            {
              cont = 0;
              break;
            }

          /* After reallocating, continue in new buffer */
          *bufptr = buf;
          *n = newsize;
          ptr = buf + pos;
          numbytes = newsize - pos;
        }
    }

  _funlockfile (fp);
  __sfp_lock_release ();

  /* if no input data, return failure */
  if (ptr == buf)
    return -1;

  /* otherwise, nul-terminate and return number of bytes read */
  *ptr = '\0';
  return (ssize_t)(ptr - buf);
}

#endif // __unix__

// vi:set ts=8 sw=8:
