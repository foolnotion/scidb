# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

EXE = stockfish-120903

OBJS = benchmark.o bitbase.o bitboard.o book.o endgame.o evaluate.o main.o  \
       material.o misc.o movegen.o movepick.o notation.o pawns.o position.o \
       search.o thread.o timeman.o tt.o uci.o ucioption.o

.SUFFIXES: .cpp
.PRECIOUS:

#	x86-64          x86 64-bit"
#	x86-64-modern   x86 64-bit with runtime support for popcnt instruction"
#	x86-32          x86 32-bit excluding old hardware without SSE-support"
#	x86-32-old      x86 32-bit including also very old hardware"
#	osx-ppc-64      PPC-Mac OS X 64 bit"
#	osx-ppc-32      PPC-Mac OS X 32 bit"
#	osx-x86-64      x86-Mac OS X 64 bit"
#	osx-x86-32      x86-Mac OS X 32 bit"
#	general-64      unspecified 64-bit"
#	general-32      unspecified 32-bit"

machine	= $(shell uname -m)
bits		= $(shell getconf LONG_BIT)

ifeq ($(machine),i386)
	ARCH = x86-32-old
endif
ifeq ($(machine),i486)
	ARCH = x86-32-old
endif
ifeq ($(machine),i586)
	ARCH = x86-32
endif
ifeq ($(machine),i686)
	ARCH = x86-32
endif
ifeq ($(machine),x86_64)
	ARCH = x86-64
endif
ifeq ($(machine),ia64)
	ARCH = x86-64
endif
ifeq ($(machine),amd64)
	ARCH = x86-64
endif

ifndef ARCH
	ifeq ($bits,32)
		ARCH = general-32
	endif
	ifeq ($bits,64)
		ARCH = general-64
	endif
endif

ifeq ($(ARCH),x86-32)
	ifeq ($(SIMD),)
		ARCH = x86-32-old
	endif
endif

CXXFLAGS = -O3 -Wall -Wcast-qual -fno-exceptions -fno-rtti

ifeq ($(ARCH),general-64)
	arch = any
	os = any
	bits = 64
	prefetch = no
	bsfq = no
	popcnt = no
endif

ifeq ($(ARCH),general-32)
	arch = any
	os = any
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
endif

# x86-section
ifeq ($(ARCH),x86-64)
	arch = x86_64
	os = any
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = no
endif

ifeq ($(ARCH),x86-64-modern)
	arch = x86_64
	os = any
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = yes
endif

ifeq ($(ARCH),x86-32)
	arch = i386
	os = any
	bits = 32
	prefetch = yes
	bsfq = no
	popcnt = no
endif

ifeq ($(ARCH),x86-32-old)
	arch = i386
	os = any
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
endif

# osx-section
ifeq ($(ARCH),osx-ppc-64)
	arch = ppc64
	os = osx
	bits = 64
	prefetch = no
	bsfq = no
	popcnt = no
endif

ifeq ($(ARCH),osx-ppc-32)
	arch = ppc
	os = osx
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
endif

ifeq ($(ARCH),osx-x86-64)
	arch = x86_64
	os = osx
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = no
endif

ifeq ($(ARCH),osx-x86-32)
	arch = i386
	os = osx
	bits = 32
	prefetch = yes
	bsfq = no
	popcnt = no
endif

ifeq ($(os),osx)
	ifeq ($(arch),i386)
		CXXFLAGS += -mdynamic-no-pic
	endif
	ifeq ($(arch),x86_64)
		CXXFLAGS += -mdynamic-no-pic
	endif
endif

ifeq ($(bits),64)
	CXXFLAGS += -DIS_64BIT
endif

ifeq ($(prefetch),yes)
	CXXFLAGS += -msse
	DEPENDFLAGS += -msse
else
	CXXFLAGS += -DNO_PREFETCH
endif

ifeq ($(bsfq),yes)
	CXXFLAGS += -DUSE_BSFQ
endif

ifeq ($(popcnt),yes)
	CXXFLAGS += -msse3 -DUSE_POPCNT
endif

### 3.10 Link Time Optimization, it works since gcc 4.5 but not on mingw.
### This is a mix of compile and link time options because the lto link phase
### needs access to the optimization flags.
GCC_MAJOR := `$(CXX) -dumpversion | cut -f1 -d.`
GCC_MINOR := `$(CXX) -dumpversion | cut -f2 -d.`
ifeq (1,$(shell expr \( $(GCC_MAJOR) \> 4 \) \| \( $(GCC_MAJOR) \= 4 \& $(GCC_MINOR) \>= 5 \)))
	CXXFLAGS += -flto
	LDFLAGS += $(CXXFLAGS)
endif

all: $(EXE)

clean:
	rm -f $(EXE) $(OBJS)

install:
	@install -m 755 -d $(ENGINESDIR)
	@install -m 755 -p $(EXE) $(ENGINESDIR)

uninstall:
	@rm -f $(ENGINESDIR)/$(EXE)

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-16s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c -o $@ $(CXXFLAGS) $(EXTRA_CXXFLAGS) $<

$(EXE): $(OBJS)
	@echo "Building $(EXE)"
	@$(CXX) $(LDFLAGS) -o $@ $(OBJS) -lpthread

# vi:set ts=3 sw=3:
