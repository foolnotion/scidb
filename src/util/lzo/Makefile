#
# a very simple Makefile for miniLZO
#

include ../../../Makefile.in

.SUFFIXES: .c

SOURCES	= minilzo.c
OBJS		= $(SOURCES:.c=.o)

# Make sure that minilzo.h, lzoconf.h and lzodefs.h are in the
# current dircectory. Otherwise you may want to adjust CPPFLAGS.
##CPPFLAGS = -I../include/lzo -I.

CFLAGS = -s -Wall -O2 -fomit-frame-pointer

LIB = liblzo


all: $(LIB).a


#
# gcc (generic)
#

$(LIB).a: minilzo.o
	@echo "Building $(LIB).a"
	@$(AR) $(ARFLAGS) $(LIB).a $(OBJS)

minilzo.o: minilzo.c
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(CFLAGS:  = )]"
	@gcc -c $(CFLAGS) $(EXTRA_CFLAGS) $(SOURCES)


#
# other targets
#

clean:
	@echo "Clean `pwd`"
	@rm -f $(PROGRAM) $(PROGRAM).exe $(PROGRAM).map $(PROGRAM).tds
	@rm -f *.err *.o *.obj

depend:
	# do nothing

# vi:set ts=3 sw=3:
