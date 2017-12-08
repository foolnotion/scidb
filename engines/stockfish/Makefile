# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

EXE = stockfish-scidb

SRC = benchmark.cpp bitbase.cpp bitboard.cpp endgame.cpp evaluate.cpp main.cpp  \
       material.cpp misc.cpp movegen.cpp movepick.cpp pawns.cpp position.cpp \
       search.cpp thread.cpp timeman.cpp tt.cpp uci.cpp ucioption.cpp

OBJS = $(SRC:.cpp=.o)

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

CXXFLAGS = $(SYS_CXXFLAGS) -O3 -Wall -Wcast-qual -fno-exceptions -fno-rtti -DSCIDB -DHASHFULL -DTHREECHECK -DKOTH -DNDEBUG $(SIMD)

ifeq ($(ARCH),general-64)
	arch = any
	os = any
	bits = 64
	prefetch = no
	bsfq = no
	popcnt = no
	sse = no
endif

ifeq ($(ARCH),general-32)
	arch = any
	os = any
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
	sse = no
endif

# x86-section
ifeq ($(ARCH),x86-64)
	arch = x86_64
	os = any
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = no
	sse = no
endif

ifeq ($(ARCH),x86-64-modern)
	arch = x86_64
	os = any
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = yes
	sse = yes
endif

ifeq ($(ARCH),x86-32)
	arch = i386
	os = any
	bits = 32
	prefetch = yes
	bsfq = no
	popcnt = no
	sse = yes
endif

ifeq ($(ARCH),x86-32-old)
	arch = i386
	os = any
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
	sse = no
endif

# arm section
ifeq ($(ARCH),armv7)
	arch = armv7
	os = any
	bits = 32
	prefetch = yes
	bsfq = yes
	popcnt = no
	sse = no
endif

# osx-section
ifeq ($(ARCH),osx-ppc-64)
	arch = ppc64
	os = osx
	bits = 64
	prefetch = no
	bsfq = no
	popcnt = no
	sse = no
endif

ifeq ($(ARCH),osx-ppc-32)
	arch = ppc
	os = osx
	bits = 32
	prefetch = no
	bsfq = no
	popcnt = no
	sse = no
endif

ifeq ($(ARCH),osx-x86-64)
	arch = x86_64
	os = osx
	bits = 64
	prefetch = yes
	bsfq = yes
	popcnt = no
	sse = yes
endif

ifeq ($(ARCH),osx-x86-32)
	arch = i386
	os = osx
	bits = 32
	prefetch = yes
	bsfq = no
	popcnt = no
	sse = yes
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
#	ifeq ($(sse),yes)
#		CXXFLAGS += -msse
#		DEPENDFLAGS += -msse
#	endif
else
	CXXFLAGS += -DNO_PREFETCH
endif

ifeq ($(bsfq),yes)
	CXXFLAGS += -DUSE_BSFQ
endif

ifeq ($(popcnt),yes)
	CXXFLAGS += -msse4.2 -DUSE_POPCNT
endif

### 3.10 Link Time Optimization, it works since gcc 4.5 but not on mingw.
### This is a mix of compile and link time options because the lto link phase
### needs access to the optimization flags.
GCC_MAJOR := `$(CXX) -dumpversion | cut -f1 -d.`
GCC_MINOR := `$(CXX) -dumpversion | cut -f2 -d.`
ifeq (1,$(shell expr \( $(GCC_MAJOR) \> 4 \) \| \( $(GCC_MAJOR) \= 4 \& $(GCC_MINOR) \>= 5 \)))
	# on some systems LTO is disabled (but why?)
	DISABLE_LTO := `$(CXX) -v 2>&1 | grep disable-lto`
	ifeq (1,$(shell expr "$(DISABLE_LTO)" == ""))
		CXXFLAGS += -flto
		LDFLAGS += $(CXXFLAGS)
	endif
endif

LDFLAGS += $(SYS_LDFLAGS)

all: $(EXE)

clean:
	@echo "Clean `pwd`"
	@rm -f $(EXE) $(OBJS)

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

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

# vi:set ts=3 sw=3:
# DO NOT DELETE

benchmark.o: misc.h
benchmark.o: types.h
benchmark.o: platform.h
benchmark.o: position.h
benchmark.o: bitboard.h
benchmark.o: search.h
benchmark.o: thread.h
benchmark.o: material.h
benchmark.o: endgame.h
benchmark.o: movepick.h
benchmark.o: movegen.h
benchmark.o: pawns.h
benchmark.o: tt.h
benchmark.o: ucioption.h
bitbase.o: bitboard.h
bitbase.o: types.h
bitbase.o: platform.h
bitboard.o: bitboard.h
bitboard.o: types.h
bitboard.o: platform.h
bitboard.o: bitcount.h
bitboard.o: misc.h
bitboard.o: rkiss.h
endgame.o: bitboard.h
endgame.o: types.h
endgame.o: platform.h
endgame.o: bitcount.h
endgame.o: endgame.h
endgame.o: position.h
endgame.o: movegen.h
evaluate.o: bitcount.h
evaluate.o: types.h
evaluate.o: platform.h
evaluate.o: evaluate.h
evaluate.o: material.h
evaluate.o: endgame.h
evaluate.o: position.h
evaluate.o: bitboard.h
evaluate.o: misc.h
evaluate.o: pawns.h
evaluate.o: thread.h
evaluate.o: movepick.h
evaluate.o: movegen.h
evaluate.o: search.h
evaluate.o: ucioption.h
main.o: bitboard.h
main.o: types.h
main.o: platform.h
main.o: evaluate.h
main.o: position.h
main.o: search.h
main.o: misc.h
main.o: thread.h
main.o: material.h
main.o: endgame.h
main.o: movepick.h
main.o: movegen.h
main.o: pawns.h
main.o: tt.h
main.o: ucioption.h
material.o: material.h
material.o: endgame.h
material.o: position.h
material.o: bitboard.h
material.o: types.h
material.o: platform.h
material.o: misc.h
misc.o: misc.h
misc.o: types.h
misc.o: platform.h
misc.o: thread.h
misc.o: material.h
misc.o: endgame.h
misc.o: position.h
misc.o: bitboard.h
misc.o: movepick.h
misc.o: movegen.h
misc.o: search.h
misc.o: pawns.h
movegen.o: movegen.h
movegen.o: types.h
movegen.o: platform.h
movegen.o: position.h
movegen.o: bitboard.h
movepick.o: movepick.h
movepick.o: movegen.h
movepick.o: types.h
movepick.o: platform.h
movepick.o: position.h
movepick.o: bitboard.h
movepick.o: search.h
movepick.o: misc.h
movepick.o: thread.h
movepick.o: material.h
movepick.o: endgame.h
movepick.o: pawns.h
pawns.o: bitboard.h
pawns.o: types.h
pawns.o: platform.h
pawns.o: bitcount.h
pawns.o: pawns.h
pawns.o: misc.h
pawns.o: position.h
position.o: bitcount.h
position.o: types.h
position.o: platform.h
position.o: movegen.h
position.o: position.h
position.o: bitboard.h
position.o: psqtab.h
position.o: rkiss.h
position.o: thread.h
position.o: material.h
position.o: endgame.h
position.o: misc.h
position.o: movepick.h
position.o: search.h
position.o: pawns.h
position.o: tt.h
search.o: position.h
search.o: bitboard.h
search.o: types.h
search.o: platform.h
search.o: rkiss.h
search.o: evaluate.h
search.o: movegen.h
search.o: movepick.h
search.o: search.h
search.o: misc.h
search.o: timeman.h
search.o: thread.h
search.o: material.h
search.o: endgame.h
search.o: pawns.h
search.o: tt.h
search.o: ucioption.h
thread.o: movegen.h
thread.o: types.h
thread.o: platform.h
thread.o: search.h
thread.o: misc.h
thread.o: position.h
thread.o: bitboard.h
thread.o: thread.h
thread.o: material.h
thread.o: endgame.h
thread.o: movepick.h
thread.o: pawns.h
thread.o: ucioption.h
timeman.o: search.h
timeman.o: misc.h
timeman.o: types.h
timeman.o: platform.h
timeman.o: position.h
timeman.o: bitboard.h
timeman.o: timeman.h
timeman.o: ucioption.h
tt.o: bitboard.h
tt.o: types.h
tt.o: platform.h
tt.o: tt.h
tt.o: misc.h
uci.o: evaluate.h
uci.o: types.h
uci.o: platform.h
uci.o: position.h
uci.o: bitboard.h
uci.o: search.h
uci.o: misc.h
uci.o: thread.h
uci.o: material.h
uci.o: endgame.h
uci.o: movepick.h
uci.o: movegen.h
uci.o: pawns.h
uci.o: tt.h
uci.o: ucioption.h
ucioption.o: evaluate.h
ucioption.o: types.h
ucioption.o: platform.h
ucioption.o: misc.h
ucioption.o: thread.h
ucioption.o: material.h
ucioption.o: endgame.h
ucioption.o: position.h
ucioption.o: bitboard.h
ucioption.o: movepick.h
ucioption.o: movegen.h
ucioption.o: search.h
ucioption.o: pawns.h
ucioption.o: tt.h
ucioption.o: ucioption.h
