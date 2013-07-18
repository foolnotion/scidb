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
OPTIMIZE	= -O2
CFLAGS	+= $(OPTIMIZE) $(SYS_CFLAGS) $(DEFINES)

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

LIB = libexpat

all: $(LIB).a

$(LIB).a: $(LIBOBJS)
	@echo "Building $(LIB).a"
	@$(AR) rc $(LIB).a $(LIBOBJS)
	@$(RANLIB) $(LIB).a

clean:
	@echo "Clean `pwd`"
	@rm -f $(OBJS) $(LIBOBJS) $(LIB).a

depend:
	# do nothing

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c $(CFLAGS) $(EXTRA_CFLAGS) $(INCLUDE) -o $@ $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
