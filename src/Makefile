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

include ../Makefile.in

.SUFFIXES: .cpp

INCLUDE	= -I. -Imstl -Iutil -Idb -Iapp -Itcl -Itk -Isys
CXXFLAGS = $(CXXFLAGS) $(OPTIMIZE) $(CXX_DEBUG) $(PROFILING)

LIBS_BASE = \
	db/libdbstubs.a \
	util/libutil.a \
	util/libTeXt/libTeXt.a \
	mstl/libmstl.a \

LIBS = \
	tk/libtk.a \
	tcl/libtcl.a \
	app/libapp.a \
	db/libdb.a \
	sys/libsys.a \
	tk/svg/libsvg.a \
	tk/svg/agg/libagg.a \
	util/libutil.a \
	util/lzo/liblzo.a \
	util/libharu/libharu.a \
	util/libTeXt/libTeXt.a \
	mstl/libmstl.a \
	tk/jpeg/libjpegd.a \
	tk/treectrl/libtreectrl.a \
	tk/html/libTkhtml3.a \

SRC = \
	best_move.cpp \
	code2eco.cpp \
	dump_eco.cpp \
	eco2code.cpp \
	extend_eco.cpp \
	permute_eco.cpp \
	pgn_split_eco.cpp \
	tkscidb.cpp \

SUBDIRS = db app mstl sys tcl tk/jpeg tk/svg/agg tk/svg tk/treectrl tk/html tk util util/lzo util/minizip util/libharu util/libTeXt $(SUBDIRS)

TARGETS = extend_eco dump_eco permute_eco code2eco eco2code best_move guess_move $(PROGRAM)

all: recursive $(PROGRAM)

install: $(PROGRAM)
	install -m 755 -d $(BINDIR)
	install -m 755 -d $(SHAREDIR)/data
	install -m 755 -p $(PROGRAM) $(BINDIR)
	install -m 644 -p data/eco.bin $(SHAREDIR)/data
	install -m 644 -p data/*.* $(SHAREDIR)/data

uninstall:
	rm -f $(BINDIR)/$(PROGRAM)
	rm -f $(SHAREDIR)/data/eco.bin
	for i in `ls data/*.*`; do
		rm -f $(SHAREDIR)/data/$f
	done
	/bin/sh -e 'find $(BINDIR) -type d -empty -exec rmdir {} \; 2>/dev/null'
	/bin/sh -e 'find $(SHAREDIR) -type d -empty -exec rmdir {} \; 2>/dev/null'

clean:
	rm -f $(TARGETS)
	for dir in $(SUBDIRS); do
		(cd $dir && make clean)
	done

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	for dir in $(SUBDIRS); do
		(cd $dir && make depend)
	done

recursive:
	for dir in $(SUBDIRS); do
		(cd $dir && make)
	done

mstl/libmstl.a:
	(cd mstl && make)

sys/libsys.a:
	(cd sys && make)

util/libutil.a:
	(cd util && make)

util/lzo/liblzo.a:
	(cd util/lzo && make)

util/minizip/libminizip.a:
	(cd util/libminizip && make)

util/zzip/libzzip.a:
	(cd util/zzip && make)

util/libharu/libharu.a:
	(cd util/libharu && make)

util/libTeXt/libTeXt.a:
	(cd util/libTeXt && make)

tcl/libtcl.a:
	(cd tcl && make)

tk/libtk.a:
	(cd tk && make)

tk/jpeg/libjpegd.a:
	(cd tk/jpeg && make)

tk/svg/libsvg.a:
	(cd tk/svg && make)

tk/svg/agg/libagg.a:
	(cd tk/svg/agg && make)

tk/treectrl/libtreectrl.a:
	(cd tk/treectrl && make)

tk/html/libTkhtml3.a:
	(cd tk/html && make)

db/libapp.a:
	(cd app && make)

db/libdb.a:
	(cd db && make)

permute_eco: permute_eco.cpp $(LIBS)
	$(CXX) -o permute_eco permute_eco.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

extend_eco: extend_eco.cpp $(LIBS_BASE)
	$(CXX) -o extend_eco extend_eco.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

dump_eco: dump_eco.cpp $(LIBS_BASE)
	$(CXX) -o dump_eco dump_eco.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

eco2code: eco2code.cpp $(LIBS_BASE)
	$(CXX) -o eco2code eco2code.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

code2eco: code2eco.cpp $(LIBS_BASE)
	$(CXX) -o code2eco code2eco.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

pawn_progress: pawn_progress.cpp $(LIBS_BASE)
	$(CXX) -o pawn_progress pawn_progress.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS_BASE)

best_move: best_move.cpp $(LIBS)
	$(CXX) -o best_move best_move.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS) $(X_LIBRARY) $(TK_LIBRARY) -$(TCL_LIBRARY) $(ZZIPLIB_LIB) -lminizip $(ZLIB_LIB) -lpthread

pgn_split_eco: pgn_split_eco.cpp $(LIBS)
	$(CXX) -o pgn_split_eco pgn_split_eco.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS) $(X_LIBRARY) -l$(TK_LIBRARY) -l$(TCL_LIBRARY) $(ZZIPLIB_LIB) -lminizip $(ZLIB_LIB) -lpthread

$(PROGRAM): tkscidb.cpp $(LIBS)
	$(CXX) -o $(PROGRAM) tkscidb.cpp $(CXXFLAGS) $(INCLUDE) $(LDFLAGS) $(LIBS) $(X_LIBRARY) -l$(TK_LIBRARY) -l$(TCL_LIBRARY) $(ZZIPLIB_LIB) -lminizip $(ZLIB_LIB) -lpthread $(EXPAT_LIBRARY)

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CXX_DEBUG) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
