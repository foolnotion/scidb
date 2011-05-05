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

INCLUDE	= -Ixmltok -Ixmlparse
DEFINES	= -DXML_NS -DXML_DTD

# Use one of the next two lines; unixfilemap is better if it works.
FILEMAP_OBJ=unixfilemap.o
#FILEMAP_OBJ=xmlwf/readfilemap.o

LIBOBJS =\
	xmltok.o \
	xmlrole.o \
	xmlparse.o \

OBJS =  \
	xmlwf.o \
	xmlfile.o \
	codepage.o \
	$(FILEMAP_OBJ)

LIB = libexpat.a

all: $(LIB)

$(LIB): $(LIBOBJS)
	$(AR) rc $(LIB) $(LIBOBJS)

clean:
	rm -f $(OBJS) $(LIBOBJS) $(LIB)

depend:
	# do nothing

.c.o:
	$(CC) $(CFLAGS) -O2 $(INCLUDE) $(DEFINES) -c -o $@ $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
