# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

EXE		= crafty-scidb
CFLAGS	= -O3 -fomit-frame-pointer -DNOEGTB -DCPUS=$(CPUS) -DSKILL $(NO_UNUSED_RESULT)

OBJS = search.o thread.o repeat.o next.o killer.o quiesce.o evaluate.o        \
       movgen.o make.o unmake.o hash.o  attacks.o swap.o boolean.o utility.o  \
       book.o data.o drawn.o edit.o epd.o epdglue.o init.o input.o probe.o    \
       interupt.o iterate.o main.o option.o output.o ponder.o resign.o root.o \
		 learn.o setboard.o test.o time.o validate.o annotate.o analyze.o       \
		 evtest.o bench.o

machine	= $(shell uname -m)
bits		= $(shell getconf LONG_BIT)
uname 	= $(shell uname)

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

ifeq ($(ARCH),general-64)
	arch = any
	os = any
	bits = 64
endif

ifeq ($(ARCH),general-32)
	arch = any
	os = any
	bits = 32
endif

# x86-section
ifeq ($(ARCH),x86-64)
	arch = x86_64
	os = any
	bits = 64
endif

ifeq ($(ARCH),x86-64-modern)
	arch = x86_64
	os = any
	bits = 64
endif

ifeq ($(ARCH),x86-32)
	arch = i386
	os = any
	bits = 32
endif

ifeq ($(ARCH),x86-32-old)
	arch = i386
	os = any
	bits = 32
endif

# osx-section
ifeq ($(ARCH),osx-ppc-64)
	arch = ppc64
	os = osx
	bits = 64
endif

ifeq ($(ARCH),osx-ppc-32)
	arch = ppc
	os = osx
	bits = 32
endif

ifeq ($(ARCH),osx-x86-64)
	arch = x86_64
	os = osx
	bits = 64
endif

ifeq ($(ARCH),osx-x86-32)
	arch = i386
	os = osx
	bits = 32
endif

ifeq ($(os),osx)
	ifeq ($(arch),i386)
		CFLAGS += -mdynamic-no-pic
	endif
	ifeq ($(arch),x86_64)
		CFLAGS += -mdynamic-no-pic
	endif
endif

ifeq ($(bits),64)
	CFLAGS += -DINLINE64
endif

ifeq ($(uname), Solaris)
	CFLAGS += -fforce-mem
endif

# From original Maskefile:
# -------------------------------------------------
# darwinG5		-DCPUS=4 -DPOWERPC
# freebsd		-DINLINE32
# linux-amd64	-DINLINE64 -DCPUS=8 -DNUMA -DLIBNUMA
# linux			-DTRACE -DINLINE32 -DCPUS=2
# linux-64		-DINLINE64 -DCPUS=2
# linux-icc		-DINLINE32 -DCPUS=2
# netbsd			-DINLINE32
# solaris-gcc	-fforce-mem

.SUFFIXES: .c
.PRECIOUS:

all: $(EXE)

clean:
	@echo "Clean `pwd`"
	@ rm -f $(EXE) $(OBJS)

install:
	@install -m 755 -d $(ENGINESDIR)
	@install -m 755 -p $(EXE) $(ENGINESDIR)

uninstall:
	@rm -f $(ENGINESDIR)/$(EXE)

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-16s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c -o $@ $(CFLAGS) $(EXTRA_CFLAGS) $<

$(EXE): $(OBJS)
	@echo "Building $(EXE)"
	@$(CC) $(LDFLAGS) -o $@ $(OBJS) -lpthread

# vi:set ts=3 sw=3:
