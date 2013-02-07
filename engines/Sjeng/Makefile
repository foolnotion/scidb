# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

EXE = sjeng-scidb

CFLAGS = -O2 -Wall -Wno-uninitialized $(NO_UNUSED_RESULT) # -DHAVE_GETTIMEOFDAY -DHAVE_SELECT -DHAVE_SYS_TIMEB_H -DHAVE_LIBGDBM -DVERSION=\"11.2\"

SRC = attacks.c crazy.c epd.c learn.c partner.c seval.c ttable.c book.c ecache.c eval.c \
	moves.c search.c sjeng.c utils.c newbook.c proof.c neval.c rcfile.c leval.c draw.c see.c \
	probe.c segtb.c

OBJS = $(SRC:.c=.o)

.SUFFIXES: .c
.PRECIOUS:

all: $(EXE)

clean:
	@echo "Clean `pwd`"
	@rm -f $(EXE) $(OBJS)

install:
	@install -m 755 -d $(ENGINESDIR)
	@install -m 755 -p $(EXE) $(ENGINESDIR)
	@install -m 755 -d $(SHAREDIR)/engines
	@install -m 755 -d $(SHAREDIR)/engines/$(EXE)
	@install -m 644 -p books/* $(SHAREDIR)/engines/$(EXE)

uninstall:
	@rm -f $(ENGINESDIR)/$(EXE)
	@if [ -d $(SHAREDIR)/engines ]; then                                    \
		dir=$(SHAREDIR)/engines/$(EXE);                                      \
		if [ -d $$dir ]; then                                                \
			for file in `ls books/*`; do rm -f $$dir/`basename $$file`; done; \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then      \
				rmdir $$dir;                                                   \
			fi;                                                               \
		fi;                                                                  \
		dir=$(SHAREDIR)/engines;                                             \
		if [ -d $$dir ]; then                                                \
			if [ "`find $$dir -type d -empty`" = "`ls -d $$dir`" ]; then      \
				rmdir $$dir;                                                   \
			fi;                                                               \
		fi;                                                                  \
	fi

.c.o:
	@echo "Compiling `awk 'BEGIN { printf "%-16s", "$<" }'`  [$(CFLAGS:  = )]"
	@$(CC) -c -o $@ $(GDBM_INC) $(CFLAGS) $(EXTRA_CFLAGS) $<

$(EXE): $(OBJS)
	@echo "Building $(EXE)"
	@$(CC) $(LDFLAGS) -o $@ $(OBJS) $(GDBM_LIB) -lm

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak; \
		mv Makefile.bak Makefile; \
	fi

# vi:set ts=3 sw=3:
# DO NOT DELETE

attacks.o: sjeng.h
attacks.o: config.h
attacks.o: extvars.h
crazy.o: sjeng.h
crazy.o: config.h
crazy.o: protos.h
crazy.o: extvars.h
epd.o: sjeng.h
epd.o: config.h
epd.o: protos.h
epd.o: extvars.h
learn.o: sjeng.h
learn.o: config.h
learn.o: protos.h
learn.o: extvars.h
partner.o: sjeng.h
partner.o: config.h
partner.o: protos.h
partner.o: extvars.h
seval.o: sjeng.h
seval.o: config.h
seval.o: extvars.h
seval.o: protos.h
ttable.o: sjeng.h
ttable.o: config.h
ttable.o: protos.h
ttable.o: extvars.h
book.o: sjeng.h
book.o: config.h
book.o: protos.h
book.o: extvars.h
ecache.o: sjeng.h
ecache.o: config.h
ecache.o: protos.h
ecache.o: extvars.h
eval.o: sjeng.h
eval.o: config.h
eval.o: extvars.h
eval.o: protos.h
eval.o: squares.h
moves.o: sjeng.h
moves.o: config.h
moves.o: extvars.h
moves.o: protos.h
search.o: sjeng.h
search.o: config.h
search.o: extvars.h
search.o: protos.h
sjeng.o: sjeng.h
sjeng.o: config.h
sjeng.o: protos.h
sjeng.o: extvars.h
utils.o: config.h
utils.o: sjeng.h
utils.o: extvars.h
utils.o: protos.h
newbook.o: sjeng.h
newbook.o: config.h
newbook.o: protos.h
newbook.o: extvars.h
proof.o: sjeng.h
proof.o: config.h
proof.o: extvars.h
proof.o: protos.h
neval.o: sjeng.h
neval.o: config.h
neval.o: extvars.h
neval.o: protos.h
neval.o: squares.h
rcfile.o: sjeng.h
rcfile.o: config.h
rcfile.o: protos.h
rcfile.o: extvars.h
leval.o: sjeng.h
leval.o: config.h
leval.o: extvars.h
leval.o: protos.h
draw.o: config.h
draw.o: sjeng.h
draw.o: extvars.h
draw.o: protos.h
see.o: sjeng.h
see.o: config.h
see.o: extvars.h
probe.o: sjeng.h
probe.o: config.h
probe.o: protos.h
probe.o: extvars.h
segtb.o: sjeng.h
segtb.o: config.h
segtb.o: extvars.h
segtb.o: protos.h
segtb.o: squares.h
