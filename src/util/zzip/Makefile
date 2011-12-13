# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

include ../../../Makefile.in

.SUFFIXES: .c
.PRECIOUS:

INCLUDE	= -I..
OPTIMIZE	= -O2 -fomit-frame-pointer
C_DEBUG	= -DNDEBUG -Wno-strict-aliasing
DEFINES	= -D_USE_MMAP -DZZIP_HAVE_STDINT_H
CFLAGS	+= $(C_DEBUG) $(OPTIMIZE) $(DEFINES)

SRC_C = \
	zzcat.c \
	zzdir.c \
	zzip-dir.c \
	zzip-err.c \
	zzip-file.c \
	zzip-info.c \
	zzip-io.c \
	zzip-stat.c \
	zzip-zip.c \
	zzipwrap-mem.c \
	zzipwrap.c \
	zzxorcat.c \
	zzxorcopy.c \
	zzxordir.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libzzip

all: $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(LIB).a $(OBJS) Makefile.bak

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

$(LIB).a: $(OBJS)
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	@$(RANLIB) $(LIB).a

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

zzcat.o: ../zzip/lib.h
zzcat.o: ../zzip/conf.h
zzcat.o: ../zzip/_config.h
zzdir.o: ../zzip/lib.h
zzdir.o: ../zzip/conf.h
zzdir.o: ../zzip/_config.h
zzip-dir.o: ../zzip/zzip.h
zzip-dir.o: ../zzip/plugin.h
zzip-dir.o: ../zzip/lib.h
zzip-dir.o: ../zzip/conf.h
zzip-dir.o: ../zzip/_config.h
zzip-dir.o: ../zzip/stdint.h
zzip-dir.o: ../zzip/file.h
zzip-dir.o: __dirent.h
zzip-err.o: ../zzip/zzip.h
zzip-err.o: ../zzip/plugin.h
zzip-err.o: ../zzip/lib.h
zzip-err.o: ../zzip/conf.h
zzip-err.o: ../zzip/_config.h
zzip-err.o: ../zzip/stdint.h
zzip-err.o: ../zzip/file.h
zzip-file.o: ../zzip/zzip.h
zzip-file.o: ../zzip/plugin.h
zzip-file.o: ../zzip/lib.h
zzip-file.o: ../zzip/conf.h
zzip-file.o: ../zzip/_config.h
zzip-file.o: ../zzip/stdint.h
zzip-file.o: ../zzip/file.h
zzip-file.o: ../zzip/format.h
zzip-file.o: ../zzip/__debug.h
zzip-file.o: __hints.h
zzip-info.o: ../zzip/zzip.h
zzip-info.o: ../zzip/plugin.h
zzip-info.o: ../zzip/lib.h
zzip-info.o: ../zzip/conf.h
zzip-info.o: ../zzip/_config.h
zzip-info.o: ../zzip/stdint.h
zzip-info.o: ../zzip/file.h
zzip-info.o: ../zzip/format.h
zzip-io.o: ../zzip/zzip.h
zzip-io.o: ../zzip/plugin.h
zzip-io.o: ../zzip/lib.h
zzip-io.o: ../zzip/conf.h
zzip-io.o: ../zzip/_config.h
zzip-io.o: ../zzip/stdint.h
zzip-io.o: ../zzip/file.h
zzip-io.o: ../zzip/format.h
zzip-stat.o: ../zzip/zzip.h
zzip-stat.o: ../zzip/plugin.h
zzip-stat.o: ../zzip/lib.h
zzip-stat.o: ../zzip/conf.h
zzip-stat.o: ../zzip/_config.h
zzip-stat.o: ../zzip/stdint.h
zzip-zip.o: ../zzip/zzip.h
zzip-zip.o: ../zzip/plugin.h
zzip-zip.o: ../zzip/lib.h
zzip-zip.o: ../zzip/conf.h
zzip-zip.o: ../zzip/_config.h
zzip-zip.o: ../zzip/stdint.h
zzip-zip.o: ../zzip/file.h
zzip-zip.o: ../zzip/format.h
zzip-zip.o: __mmap.h
zzip-zip.o: __debug.h
zzip-zip.o: __hints.h
zzipwrap-mem.o: ../zzip/conf.h
zzipwrap-mem.o: ../zzip/_config.h
zzipwrap-mem.o: ../zzip/plugin.h
zzipwrap-mem.o: ../zzip/zzip.h
zzipwrap-mem.o: ../zzip/stdint.h
zzipwrap-mem.o: ../zzip/lib.h
zzipwrap-mem.o: ../zzip/wrap.h
zzipwrap.o: ../zzip/lib.h
zzipwrap.o: ../zzip/conf.h
zzipwrap.o: ../zzip/_config.h
zzipwrap.o: ../zzip/wrap.h
zzxorcat.o: ../zzip/lib.h
zzxorcat.o: ../zzip/conf.h
zzxorcat.o: ../zzip/_config.h
zzxorcat.o: ../zzip/plugin.h
zzxorcat.o: ../zzip/zzip.h
zzxorcat.o: ../zzip/stdint.h
zzxordir.o: ../zzip/lib.h
zzxordir.o: ../zzip/conf.h
zzxordir.o: ../zzip/_config.h
zzxordir.o: ../zzip/plugin.h
zzxordir.o: ../zzip/zzip.h
zzxordir.o: ../zzip/stdint.h
