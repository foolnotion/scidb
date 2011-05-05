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

GCC_CFLAGS = -s -Wall -O2 -fomit-frame-pointer


all: liblzo.a


#
# gcc (generic)
#

liblzo.a: minilzo.o
	$(AR) $(ARFLAGS) liblzo.a $(OBJS)

minilzo.o:
	gcc -c $(GCC_CFLAGS) $(SOURCES)


#
# other targets
#

clean:
	rm -f $(PROGRAM) $(PROGRAM).exe $(PROGRAM).map $(PROGRAM).tds
	rm -f *.err *.o *.obj

depend:
	# do nothing

# vi:set ts=3 sw=3:
