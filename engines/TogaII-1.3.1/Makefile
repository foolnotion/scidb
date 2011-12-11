# ======================================================================
# Makefile for Scidb for Unix operating systems
# ======================================================================

include ../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

EXE = fruit

OBJS = attack.o board.o book.o eval.o fen.o hash.o list.o main.o material.o \
       move.o move_check.o move_do.o move_evasion.o move_gen.o move_legal.o \
       option.o pawn.o piece.o posix.o protocol.o pst.o pv.o random.o recog.o \
       search.o search_full.o see.o sort.o square.o trans.o util.o value.o \
       vector.o

all: $(EXE)

clean:
	rm -f *.o $(EXE)

install:
	@install -m 755 -d $(ENGINESDIR)
	@install -m 755 -p $(EXE) $(ENGINESDIR)

uninstall:
	@rm -f $(ENGINESDIR)/$(EXE)

# general

LDFLAGS  = -lm

# C++

CXXFLAGS = -fno-exceptions -fno-rtti

# optimisation

CXXFLAGS += -O3 -fstrict-aliasing
CXXFLAGS += -fomit-frame-pointer
# CXXFLAGS += -march=athlon-xp # SELECT ME

# strip

LDFLAGS += -s

# dependencies

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-16s", "$<" }'`  [$(CXXFLAGS:  = )]"
	@$(CXX) -c -o $@ $(CXXFLAGS) $(EXTRA_CFLAGS) $<

$(EXE): $(OBJS)
	@echo "Building $(EXE)"
	@$(CXX) $(LDFLAGS) -o $@ $(OBJS)

### DEPENDENCIES #######################################################

attack.o: attack.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h move.h
board.o: board.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h fen.h hash.h list.h move.h move_do.h move_evasion.h move_gen.h \
  move_legal.h pawn.h pst.h value.h
book.o: book.cpp board.h colour.h util.h piece.h square.h book.h move.h \
  move_gen.h attack.h vector.h list.h
eval.o: eval.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h eval.h material.h move.h option.h pawn.h see.h value.h
fen.o: fen.cpp board.h colour.h util.h piece.h square.h fen.h
hash.o: hash.cpp board.h colour.h util.h piece.h square.h hash.h random.h
list.o: list.cpp board.h colour.h util.h piece.h square.h list.h move.h \
  value.h
main.o: main.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h book.h hash.h move_do.h option.h pawn.h protocol.h random.h \
  trans.h value.h
material.o: material.cpp board.h colour.h util.h piece.h square.h hash.h \
  material.h option.h protocol.h
move.o: move.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h list.h move.h move_do.h move_gen.h
move_check.o: move_check.cpp attack.h board.h colour.h util.h piece.h \
  square.h vector.h fen.h list.h move.h move_check.h move_do.h move_gen.h
move_do.o: move_do.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h hash.h move.h move_do.h pawn.h pst.h random.h value.h
move_evasion.o: move_evasion.cpp attack.h board.h colour.h util.h piece.h \
  square.h vector.h list.h move.h move_evasion.h move_gen.h
move_gen.o: move_gen.cpp attack.h board.h colour.h util.h piece.h \
  square.h vector.h list.h move.h move_evasion.h move_gen.h move_legal.h
move_legal.o: move_legal.cpp attack.h board.h colour.h util.h piece.h \
  square.h vector.h fen.h list.h move.h move_do.h move_gen.h move_legal.h
option.o: option.cpp option.h util.h protocol.h
pawn.o: pawn.cpp board.h colour.h util.h piece.h square.h hash.h option.h \
  pawn.h protocol.h
piece.o: piece.cpp colour.h util.h piece.h
posix.o: posix.cpp posix.h util.h
protocol.o: protocol.cpp board.h colour.h util.h piece.h square.h book.h \
  eval.h fen.h material.h move.h move_do.h move_legal.h list.h option.h \
  pawn.h posix.h protocol.h pst.h search.h trans.h
pst.o: pst.cpp option.h util.h piece.h colour.h pst.h
pv.o: pv.cpp board.h colour.h util.h piece.h square.h move.h move_do.h \
  pv.h
random.o: random.cpp random.h util.h
recog.o: recog.cpp board.h colour.h util.h piece.h square.h material.h \
  recog.h vector.h
search.o: search.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h book.h list.h material.h move.h move_do.h move_gen.h option.h \
  pawn.h protocol.h pv.h search.h search_full.h sort.h trans.h value.h
search_full.o: search_full.cpp attack.h board.h colour.h util.h piece.h \
  square.h vector.h eval.h list.h move.h move_check.h move_do.h option.h \
  pst.h pv.h recog.h search.h search_full.h see.h sort.h trans.h value.h
see.o: see.cpp attack.h board.h colour.h util.h piece.h square.h vector.h \
  move.h see.h value.h
sort.o: sort.cpp attack.h board.h colour.h util.h piece.h square.h \
  vector.h list.h move.h move_check.h move_evasion.h move_gen.h \
  move_legal.h search.h see.h sort.h value.h
square.o: square.cpp colour.h util.h square.h
trans.o: trans.cpp hash.h board.h colour.h util.h piece.h square.h move.h \
  option.h protocol.h trans.h value.h
util.o: util.cpp posix.h util.h
value.o: value.cpp piece.h colour.h util.h search.h board.h square.h \
  list.h move.h value.h
vector.o: vector.cpp piece.h colour.h util.h square.h vector.h

# vi:set ts=3 sw=3:
