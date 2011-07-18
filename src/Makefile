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

INCLUDE			= -I. -Imstl -Iutil -Idb -Idb/si3 -Iapp -Itcl -Itk -Isys
ALL_INCLUDE		= $(INCLUDE) $(TCL_INCLUDE) $(TK_INCLUDE) $(X_INCLUDE)
ALL_CXXFLAGS	= $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)
MINIZIP_LIB		= -Lutil/minizip -lminizip

MAKEFLAGS += --no-print-directory

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
	util/libTeXt/libTeXt.a \
	mstl/libmstl.a \
	tk/jpeg/libjpegd.a \
	tk/treectrl/libtreectrl.a \
	tk/html/libTkhtml3.a \

SRC = \
	best_move.cpp \
	cbh2si4.cpp \
	code2eco.cpp \
	dump_eco.cpp \
	eco2code.cpp \
	extend_eco.cpp \
	permute_eco.cpp \
	pgn_split_eco.cpp \
	tkscidb.cpp \

ALL_LIBS = $(LIBS) $(X_LIBRARY) $(TK_LIBRARY) $(TCL_LIBRARY) $(ZZIPLIB_LIB) $(MINIZIP_LIB) $(ZLIB_LIB) $(EXPAT_LIB) -lpthread

SUBDIRS = db app mstl sys tcl tk/jpeg tk/svg/agg tk/svg tk/treectrl tk/html tk util util/minizip util/libTeXt $(LIB_SUBDIRS)

TARGETS = extend_eco dump_eco permute_eco code2eco eco2code best_move guess_move pawn_progress cbh2si4 $(PROGRAM)

all: recursive cbh2si4 $(PROGRAM)

install: recursive cbh2si4 $(PROGRAM)
	install -m 755 -d $(BINDIR)
	install -m 755 -d $(SHAREDIR)
	install -m 755 -d $(SHAREDIR)/data
	install -m 755 -d $(SHAREDIR)/scripts
	install -m 755 -p $(PROGRAM) $(BINDIR)
	install -m 755 -p cbh2si4 $(BINDIR)
	install -m 644 -p data/eco.bin $(SHAREDIR)/data
	install -m 644 -p data/*.* $(SHAREDIR)/data
	install -m 644 -p util/libTeXt/plain.eXt $(SHAREDIR)/scripts

uninstall:
	rm -f $(BINDIR)/$(PROGRAM)
	rm -f $(BINDIR)/cbh2si4
	rm -f $(SHAREDIR)/scripts/plain.eXt
	rm -f $(SHAREDIR)/data/eco.bin
	for f in `ls data/*.*`; do rm -f $(SHAREDIR)/$$f; done
	for d in `find $(SHAREDIR) -type d -empty`; do rmdir $$d; done
	if [ ! -z "`find $(SHAREDIR) -type d -empty`" ]; then rmdir $(SHAREDIR); fi

clean:
	rm -f $(TARGETS) Makefile.bak
	rm -f $(SRC:.cpp=.o)
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null
	@if [ -h Makefile.bak ]; then \
		cp Makefile Makefile.bak;  \
		mv Makefile.bak Makefile;  \
	fi
	@for dir in $(SUBDIRS); do  \
		$(MAKE) -C $$dir depend; \
	done

recursive:
	@for dir in $(SUBDIRS); do           \
		$(MAKE) -C $$dir;                 \
		if [ $$? != 0 ]; then exit 1; fi; \
	done

mstl/libmstl.a:
	$(MAKE) -C mstl

sys/libsys.a:
	$(MAKE) -C sys

util/libutil.a:
	$(MAKE) -C util

util/minizip/libminizip.a:
	$(MAKE) -C util/libminizip

util/zzip/libzzip.a:
	$(MAKE) -C util/zzip

util/libharu/libharu.a:
	$(MAKE) -C util/libharu

util/libTeXt/libTeXt.a:
	$(MAKE) -C util/libTeXt

tcl/libtcl.a:
	$(MAKE) -C tcl

tk/libtk.a:
	$(MAKE) -C tk

tk/jpeg/libjpegd.a:
	$(MAKE) -C tk/jpeg

tk/svg/libsvg.a:
	$(MAKE) -C tk/svg

tk/svg/agg/libagg.a:
	$(MAKE) -C tk/svg/agg

tk/treectrl/libtreectrl.a:
	$(MAKE) -C tk/treectrl

tk/html/libTkhtml3.a:
	$(MAKE) -C tk/html

db/libapp.a:
	$(MAKE) -C app

db/libdb.a:
	$(MAKE) -C db

db/libdbstubs.a:
	$(MAKE) -C db libdbstubs.a

permute_eco: permute_eco.o $(LIBS)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(LIBS_BASE)

extend_eco: extend_eco.o $(LIBS_BASE)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(LIBS_BASE)

dump_eco: dump_eco.o $(LIBS_BASE)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) -Idb/si3 $(LIBS_BASE)

eco2code: eco2code.o $(LIBS_BASE)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(LIBS_BASE)

code2eco: code2eco.o $(LIBS_BASE)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(LIBS_BASE)

pawn_progress: pawn_progress.o $(LIBS_BASE)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(LIBS_BASE)

best_move: best_move.o $(LIBS)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(ALL_LIBS)

pgn_split_eco: pgn_split_eco.o $(LIBS)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(ALL_LIBS)

cbh2si4: cbh2si4.o $(LIBS)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(ALL_LIBS)

$(PROGRAM): tkscidb.o $(LIBS)
	@echo "Building $@"
	@$(CXX) -o $@ $< $(LDFLAGS) $(ALL_LIBS)

.cpp.o:
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(ALL_CXXFLAGS:  = )]"
	@$(CXX) -c $(ALL_CXXFLAGS) $(EXTRA_CXXFLAGS) $(EXTRA_CFLAGS) $(EXTRA_DEBUG_FLAGS) $(ALL_INCLUDE) $<

cbh2si4.o: cbh2si4.cpp
	@echo "Compiling `awk 'BEGIN { printf "%-30s", "$<" }'`  [$(ALL_CXXFLAGS:  = )]"
	@$(CXX) -c $(ALL_CXXFLAGS) $(EXTRA_CXXFLAGS) $(EXTRA_CFLAGS) $(EXTRA_DEBUG_FLAGS) $(ALL_INCLUDE) -DSHAREDIR=\"$(SHAREDIR)\" $<

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.

best_move.o: db/db_board.h
best_move.o: db/db_move_list.h
best_move.o: db/db_move.h
best_move.o: db/db_common.h
best_move.o: util/u_base.h
best_move.o: mstl/m_types.h
best_move.o: db/db_common.ipp
best_move.o: mstl/m_assert.h
best_move.o: mstl/m_exception.h
best_move.o: mstl/m_backtrace.h
best_move.o: mstl/m_exception.ipp
best_move.o: mstl/m_utility.h
best_move.o: mstl/m_type_traits.h
best_move.o: mstl/m_type_traits.ipp
best_move.o: mstl/m_utility.ipp
best_move.o: mstl/m_limits.h
best_move.o: mstl/m_bit_functions.h
best_move.o: mstl/m_bit_functions.ipp
best_move.o: util/u_crc.h
best_move.o: util/u_crc.ipp
best_move.o: mstl/m_byte_order.h
best_move.o: mstl/m_byte_order.ipp
best_move.o: mstl/m_string.h
best_move.o: mstl/m_string.ipp
best_move.o: db/db_move.ipp
best_move.o: db/db_move_list.ipp
best_move.o: db/db_signature.h
best_move.o: db/db_signature.ipp
best_move.o: db/db_board.ipp
best_move.o: db/db_guess.h
best_move.o: db/db_guess.ipp
best_move.o: db/db_eco_table.h
best_move.o: db/db_eco.h
best_move.o: db/db_eco.ipp
best_move.o: db/db_line.h
best_move.o: db/db_line.ipp
best_move.o: db/db_home_pawns.h
best_move.o: db/db_home_pawns.ipp
best_move.o: mstl/m_map.h
best_move.o: mstl/m_vector.h
best_move.o: mstl/m_memblock.h
best_move.o: mstl/m_memblock.ipp
best_move.o: mstl/m_vector.ipp
best_move.o: mstl/m_uninitialized.h
best_move.o: mstl/m_uninitialized.ipp
best_move.o: mstl/m_algobase.h
best_move.o: mstl/m_algobase.ipp
best_move.o: mstl/m_construct.h
best_move.o: mstl/m_construct.ipp
best_move.o: mstl/m_pair.h
best_move.o: mstl/m_pair.ipp
best_move.o: mstl/m_map.ipp
best_move.o: mstl/m_hash.h
best_move.o: mstl/m_hash.ipp
best_move.o: mstl/m_bitset.h
best_move.o: mstl/m_bitset_iterator.h
best_move.o: mstl/m_bitfield.h
best_move.o: mstl/m_bitfield.ipp
best_move.o: mstl/m_bitset_iterator.ipp
best_move.o: mstl/m_bitset.ipp
best_move.o: mstl/m_chunk_allocator.h
best_move.o: mstl/m_stack.h
best_move.o: mstl/m_stack.ipp
best_move.o: mstl/m_chunk_allocator.ipp
best_move.o: db/db_eco_table.ipp
best_move.o: tk/tk_init.h
best_move.o: tcl/tcl_base.h
best_move.o: tcl/tcl_base.ipp
best_move.o: util/u_zstream.h
best_move.o: mstl/m_istream.h
best_move.o: mstl/m_ios.h
best_move.o: mstl/m_ios.ipp
best_move.o: mstl/m_istream.ipp
best_move.o: mstl/m_ostream.h
best_move.o: mstl/m_ostream.ipp
best_move.o: mstl/m_ifstream.h
best_move.o: mstl/m_file.h
best_move.o: mstl/m_file.ipp
best_move.o: mstl/m_ifstream.ipp
cbh2si4.o: db/db_eco_table.h
cbh2si4.o: db/db_eco.h
cbh2si4.o: util/u_base.h
cbh2si4.o: mstl/m_types.h
cbh2si4.o: mstl/m_string.h
cbh2si4.o: mstl/m_string.ipp
cbh2si4.o: mstl/m_utility.h
cbh2si4.o: mstl/m_type_traits.h
cbh2si4.o: mstl/m_type_traits.ipp
cbh2si4.o: mstl/m_utility.ipp
cbh2si4.o: mstl/m_limits.h
cbh2si4.o: mstl/m_bit_functions.h
cbh2si4.o: mstl/m_bit_functions.ipp
cbh2si4.o: mstl/m_assert.h
cbh2si4.o: mstl/m_exception.h
cbh2si4.o: mstl/m_backtrace.h
cbh2si4.o: mstl/m_exception.ipp
cbh2si4.o: db/db_eco.ipp
cbh2si4.o: db/db_line.h
cbh2si4.o: db/db_line.ipp
cbh2si4.o: db/db_home_pawns.h
cbh2si4.o: db/db_common.h
cbh2si4.o: db/db_common.ipp
cbh2si4.o: db/db_home_pawns.ipp
cbh2si4.o: mstl/m_map.h
cbh2si4.o: mstl/m_vector.h
cbh2si4.o: mstl/m_memblock.h
cbh2si4.o: mstl/m_memblock.ipp
cbh2si4.o: mstl/m_vector.ipp
cbh2si4.o: mstl/m_uninitialized.h
cbh2si4.o: mstl/m_uninitialized.ipp
cbh2si4.o: mstl/m_algobase.h
cbh2si4.o: mstl/m_algobase.ipp
cbh2si4.o: mstl/m_construct.h
cbh2si4.o: mstl/m_construct.ipp
cbh2si4.o: mstl/m_pair.h
cbh2si4.o: mstl/m_pair.ipp
cbh2si4.o: mstl/m_map.ipp
cbh2si4.o: mstl/m_hash.h
cbh2si4.o: mstl/m_hash.ipp
cbh2si4.o: mstl/m_bitset.h
cbh2si4.o: mstl/m_bitset_iterator.h
cbh2si4.o: mstl/m_bitfield.h
cbh2si4.o: mstl/m_bitfield.ipp
cbh2si4.o: mstl/m_bitset_iterator.ipp
cbh2si4.o: mstl/m_bitset.ipp
cbh2si4.o: mstl/m_chunk_allocator.h
cbh2si4.o: mstl/m_stack.h
cbh2si4.o: mstl/m_stack.ipp
cbh2si4.o: mstl/m_chunk_allocator.ipp
cbh2si4.o: db/db_eco_table.ipp
cbh2si4.o: db/db_database.h
cbh2si4.o: db/db_database_content.h
cbh2si4.o: db/db_namebases.h
cbh2si4.o: db/db_namebase.h
cbh2si4.o: db/db_namebase_entry.h
cbh2si4.o: db/db_date.h
cbh2si4.o: db/db_date.ipp
cbh2si4.o: db/db_namebase_entry.ipp
cbh2si4.o: db/db_player.h
cbh2si4.o: mstl/m_list.h
cbh2si4.o: mstl/m_pointer_iterator.h
cbh2si4.o: mstl/m_pointer_iterator.ipp
cbh2si4.o: mstl/m_list.ipp
cbh2si4.o: db/db_player.ipp
cbh2si4.o: db/db_namebase.ipp
cbh2si4.o: db/db_namebases.ipp
cbh2si4.o: db/db_game_info.h
cbh2si4.o: db/db_signature.h
cbh2si4.o: db/db_signature.ipp
cbh2si4.o: util/u_crc.h
cbh2si4.o: util/u_crc.ipp
cbh2si4.o: mstl/m_byte_order.h
cbh2si4.o: mstl/m_byte_order.ipp
cbh2si4.o: db/db_game_info.ipp
cbh2si4.o: db/db_move.h
cbh2si4.o: db/db_move.ipp
cbh2si4.o: db/db_statistic.h
cbh2si4.o: db/db_time.h
cbh2si4.o: sys/sys_time.h
cbh2si4.o: db/db_time.ipp
cbh2si4.o: db/db_database_content.ipp
cbh2si4.o: db/db_tree_cache.h
cbh2si4.o: db/db_board.h
cbh2si4.o: db/db_move_list.h
cbh2si4.o: db/db_move_list.ipp
cbh2si4.o: db/db_board.ipp
cbh2si4.o: db/db_tree_cache.ipp
cbh2si4.o: db/db_database.ipp
cbh2si4.o: db/db_database_codec.h
cbh2si4.o: db/db_database_codec.ipp
cbh2si4.o: db/db_log.h
cbh2si4.o: db/si3/si3_consumer.h
cbh2si4.o: db/si3/si3_encoder.h
cbh2si4.o: db/si3/si3_encoder_position.h
cbh2si4.o: db/si3/si3_encoder_position.ipp
cbh2si4.o: db/si3/si3_common.h
cbh2si4.o: db/db_consumer.h
cbh2si4.o: db/db_provider.h
cbh2si4.o: db/db_provider.ipp
cbh2si4.o: db/db_consumer.ipp
cbh2si4.o: util/u_byte_stream.h
cbh2si4.o: util/u_byte_stream.ipp
cbh2si4.o: db/si3/si3_codec.h
cbh2si4.o: mstl/m_fstream.h
cbh2si4.o: mstl/m_ifstream.h
cbh2si4.o: mstl/m_istream.h
cbh2si4.o: mstl/m_ios.h
cbh2si4.o: mstl/m_ios.ipp
cbh2si4.o: mstl/m_istream.ipp
cbh2si4.o: mstl/m_file.h
cbh2si4.o: mstl/m_file.ipp
cbh2si4.o: mstl/m_ifstream.ipp
cbh2si4.o: mstl/m_ofstream.h
cbh2si4.o: mstl/m_ostream.h
cbh2si4.o: mstl/m_ostream.ipp
cbh2si4.o: mstl/m_ofstream.ipp
cbh2si4.o: db/si3/si3_codec.ipp
cbh2si4.o: util/u_progress.h
cbh2si4.o: util/u_progress.ipp
cbh2si4.o: sys/sys_utf8_codec.h
cbh2si4.o: sys/sys_utf8_codec.ipp
cbh2si4.o: tcl/tcl_base.h
cbh2si4.o: tcl/tcl_base.ipp
code2eco.o: db/db_eco.h
code2eco.o: util/u_base.h
code2eco.o: mstl/m_types.h
code2eco.o: mstl/m_string.h
code2eco.o: mstl/m_string.ipp
code2eco.o: mstl/m_utility.h
code2eco.o: mstl/m_type_traits.h
code2eco.o: mstl/m_type_traits.ipp
code2eco.o: mstl/m_utility.ipp
code2eco.o: mstl/m_limits.h
code2eco.o: mstl/m_bit_functions.h
code2eco.o: mstl/m_bit_functions.ipp
code2eco.o: mstl/m_assert.h
code2eco.o: mstl/m_exception.h
code2eco.o: mstl/m_backtrace.h
code2eco.o: mstl/m_exception.ipp
code2eco.o: db/db_eco.ipp
dump_eco.o: db/db_board.h
dump_eco.o: db/db_move_list.h
dump_eco.o: db/db_move.h
dump_eco.o: db/db_common.h
dump_eco.o: util/u_base.h
dump_eco.o: mstl/m_types.h
dump_eco.o: db/db_common.ipp
dump_eco.o: mstl/m_assert.h
dump_eco.o: mstl/m_exception.h
dump_eco.o: mstl/m_backtrace.h
dump_eco.o: mstl/m_exception.ipp
dump_eco.o: mstl/m_utility.h
dump_eco.o: mstl/m_type_traits.h
dump_eco.o: mstl/m_type_traits.ipp
dump_eco.o: mstl/m_utility.ipp
dump_eco.o: mstl/m_limits.h
dump_eco.o: mstl/m_bit_functions.h
dump_eco.o: mstl/m_bit_functions.ipp
dump_eco.o: util/u_crc.h
dump_eco.o: util/u_crc.ipp
dump_eco.o: mstl/m_byte_order.h
dump_eco.o: mstl/m_byte_order.ipp
dump_eco.o: mstl/m_string.h
dump_eco.o: mstl/m_string.ipp
dump_eco.o: db/db_move.ipp
dump_eco.o: db/db_move_list.ipp
dump_eco.o: db/db_signature.h
dump_eco.o: db/db_signature.ipp
dump_eco.o: db/db_board.ipp
dump_eco.o: db/db_line.h
dump_eco.o: db/db_line.ipp
dump_eco.o: db/db_eco.h
dump_eco.o: db/db_eco.ipp
dump_eco.o: db/db_eco_table.h
dump_eco.o: db/db_home_pawns.h
dump_eco.o: db/db_home_pawns.ipp
dump_eco.o: mstl/m_map.h
dump_eco.o: mstl/m_vector.h
dump_eco.o: mstl/m_memblock.h
dump_eco.o: mstl/m_memblock.ipp
dump_eco.o: mstl/m_vector.ipp
dump_eco.o: mstl/m_uninitialized.h
dump_eco.o: mstl/m_uninitialized.ipp
dump_eco.o: mstl/m_algobase.h
dump_eco.o: mstl/m_algobase.ipp
dump_eco.o: mstl/m_construct.h
dump_eco.o: mstl/m_construct.ipp
dump_eco.o: mstl/m_pair.h
dump_eco.o: mstl/m_pair.ipp
dump_eco.o: mstl/m_map.ipp
dump_eco.o: mstl/m_hash.h
dump_eco.o: mstl/m_hash.ipp
dump_eco.o: mstl/m_bitset.h
dump_eco.o: mstl/m_bitset_iterator.h
dump_eco.o: mstl/m_bitfield.h
dump_eco.o: mstl/m_bitfield.ipp
dump_eco.o: mstl/m_bitset_iterator.ipp
dump_eco.o: mstl/m_bitset.ipp
dump_eco.o: mstl/m_chunk_allocator.h
dump_eco.o: mstl/m_stack.h
dump_eco.o: mstl/m_stack.ipp
dump_eco.o: mstl/m_chunk_allocator.ipp
dump_eco.o: db/db_eco_table.ipp
dump_eco.o: db/si3/si3_stored_line.h
dump_eco.o: db/si3/si3_stored_line.ipp
dump_eco.o: util/u_byte_stream.h
dump_eco.o: util/u_byte_stream.ipp
dump_eco.o: mstl/m_ifstream.h
dump_eco.o: mstl/m_istream.h
dump_eco.o: mstl/m_ios.h
dump_eco.o: mstl/m_ios.ipp
dump_eco.o: mstl/m_istream.ipp
dump_eco.o: mstl/m_file.h
dump_eco.o: mstl/m_file.ipp
dump_eco.o: mstl/m_ifstream.ipp
dump_eco.o: mstl/m_ofstream.h
dump_eco.o: mstl/m_ostream.h
dump_eco.o: mstl/m_ostream.ipp
dump_eco.o: mstl/m_ofstream.ipp
eco2code.o: db/db_eco.h
eco2code.o: util/u_base.h
eco2code.o: mstl/m_types.h
eco2code.o: mstl/m_string.h
eco2code.o: mstl/m_string.ipp
eco2code.o: mstl/m_utility.h
eco2code.o: mstl/m_type_traits.h
eco2code.o: mstl/m_type_traits.ipp
eco2code.o: mstl/m_utility.ipp
eco2code.o: mstl/m_limits.h
eco2code.o: mstl/m_bit_functions.h
eco2code.o: mstl/m_bit_functions.ipp
eco2code.o: mstl/m_assert.h
eco2code.o: mstl/m_exception.h
eco2code.o: mstl/m_backtrace.h
eco2code.o: mstl/m_exception.ipp
eco2code.o: db/db_eco.ipp
extend_eco.o: db/db_board.h
extend_eco.o: db/db_move_list.h
extend_eco.o: db/db_move.h
extend_eco.o: db/db_common.h
extend_eco.o: util/u_base.h
extend_eco.o: mstl/m_types.h
extend_eco.o: db/db_common.ipp
extend_eco.o: mstl/m_assert.h
extend_eco.o: mstl/m_exception.h
extend_eco.o: mstl/m_backtrace.h
extend_eco.o: mstl/m_exception.ipp
extend_eco.o: mstl/m_utility.h
extend_eco.o: mstl/m_type_traits.h
extend_eco.o: mstl/m_type_traits.ipp
extend_eco.o: mstl/m_utility.ipp
extend_eco.o: mstl/m_limits.h
extend_eco.o: mstl/m_bit_functions.h
extend_eco.o: mstl/m_bit_functions.ipp
extend_eco.o: util/u_crc.h
extend_eco.o: util/u_crc.ipp
extend_eco.o: mstl/m_byte_order.h
extend_eco.o: mstl/m_byte_order.ipp
extend_eco.o: mstl/m_string.h
extend_eco.o: mstl/m_string.ipp
extend_eco.o: db/db_move.ipp
extend_eco.o: db/db_move_list.ipp
extend_eco.o: db/db_signature.h
extend_eco.o: db/db_signature.ipp
extend_eco.o: db/db_board.ipp
extend_eco.o: db/db_eco.h
extend_eco.o: db/db_eco.ipp
extend_eco.o: mstl/m_map.h
extend_eco.o: mstl/m_vector.h
extend_eco.o: mstl/m_memblock.h
extend_eco.o: mstl/m_memblock.ipp
extend_eco.o: mstl/m_vector.ipp
extend_eco.o: mstl/m_uninitialized.h
extend_eco.o: mstl/m_uninitialized.ipp
extend_eco.o: mstl/m_algobase.h
extend_eco.o: mstl/m_algobase.ipp
extend_eco.o: mstl/m_construct.h
extend_eco.o: mstl/m_construct.ipp
extend_eco.o: mstl/m_pair.h
extend_eco.o: mstl/m_pair.ipp
extend_eco.o: mstl/m_map.ipp
extend_eco.o: mstl/m_set.h
extend_eco.o: mstl/m_set.ipp
extend_eco.o: mstl/m_algorithm.h
extend_eco.o: mstl/m_algorithm.ipp
extend_eco.o: mstl/m_ifstream.h
extend_eco.o: mstl/m_istream.h
extend_eco.o: mstl/m_ios.h
extend_eco.o: mstl/m_ios.ipp
extend_eco.o: mstl/m_istream.ipp
extend_eco.o: mstl/m_file.h
extend_eco.o: mstl/m_file.ipp
extend_eco.o: mstl/m_ifstream.ipp
extend_eco.o: mstl/m_bitset.h
extend_eco.o: mstl/m_bitset_iterator.h
extend_eco.o: mstl/m_bitfield.h
extend_eco.o: mstl/m_bitfield.ipp
extend_eco.o: mstl/m_bitset_iterator.ipp
extend_eco.o: mstl/m_bitset.ipp
extend_eco.o: mstl/m_chunk_allocator.h
extend_eco.o: mstl/m_stack.h
extend_eco.o: mstl/m_stack.ipp
extend_eco.o: mstl/m_chunk_allocator.ipp
extend_eco.o: guess/guess.h
permute_eco.o: db/db_move_list.h
permute_eco.o: db/db_move.h
permute_eco.o: db/db_common.h
permute_eco.o: util/u_base.h
permute_eco.o: mstl/m_types.h
permute_eco.o: db/db_common.ipp
permute_eco.o: mstl/m_assert.h
permute_eco.o: mstl/m_exception.h
permute_eco.o: mstl/m_backtrace.h
permute_eco.o: mstl/m_exception.ipp
permute_eco.o: mstl/m_utility.h
permute_eco.o: mstl/m_type_traits.h
permute_eco.o: mstl/m_type_traits.ipp
permute_eco.o: mstl/m_utility.ipp
permute_eco.o: mstl/m_limits.h
permute_eco.o: mstl/m_bit_functions.h
permute_eco.o: mstl/m_bit_functions.ipp
permute_eco.o: util/u_crc.h
permute_eco.o: util/u_crc.ipp
permute_eco.o: mstl/m_byte_order.h
permute_eco.o: mstl/m_byte_order.ipp
permute_eco.o: mstl/m_string.h
permute_eco.o: mstl/m_string.ipp
permute_eco.o: db/db_move.ipp
permute_eco.o: db/db_move_list.ipp
permute_eco.o: db/db_eco.h
permute_eco.o: db/db_eco.ipp
permute_eco.o: mstl/m_map.h
permute_eco.o: mstl/m_vector.h
permute_eco.o: mstl/m_memblock.h
permute_eco.o: mstl/m_memblock.ipp
permute_eco.o: mstl/m_vector.ipp
permute_eco.o: mstl/m_uninitialized.h
permute_eco.o: mstl/m_uninitialized.ipp
permute_eco.o: mstl/m_algobase.h
permute_eco.o: mstl/m_algobase.ipp
permute_eco.o: mstl/m_construct.h
permute_eco.o: mstl/m_construct.ipp
permute_eco.o: mstl/m_pair.h
permute_eco.o: mstl/m_pair.ipp
permute_eco.o: mstl/m_map.ipp
permute_eco.o: mstl/m_ifstream.h
permute_eco.o: mstl/m_istream.h
permute_eco.o: mstl/m_ios.h
permute_eco.o: mstl/m_ios.ipp
permute_eco.o: mstl/m_istream.ipp
permute_eco.o: mstl/m_file.h
permute_eco.o: mstl/m_file.ipp
permute_eco.o: mstl/m_ifstream.ipp
permute_eco.o: guess/guess.h
pgn_split_eco.o: tcl/tcl_base.h
pgn_split_eco.o: tcl/tcl_base.ipp
pgn_split_eco.o: db/db_pgn_reader.h
pgn_split_eco.o: db/db_reader.h
pgn_split_eco.o: db/db_producer.h
pgn_split_eco.o: db/db_common.h
pgn_split_eco.o: util/u_base.h
pgn_split_eco.o: mstl/m_types.h
pgn_split_eco.o: db/db_common.ipp
pgn_split_eco.o: mstl/m_assert.h
pgn_split_eco.o: mstl/m_exception.h
pgn_split_eco.o: mstl/m_backtrace.h
pgn_split_eco.o: mstl/m_exception.ipp
pgn_split_eco.o: mstl/m_utility.h
pgn_split_eco.o: mstl/m_type_traits.h
pgn_split_eco.o: mstl/m_type_traits.ipp
pgn_split_eco.o: mstl/m_utility.ipp
pgn_split_eco.o: mstl/m_limits.h
pgn_split_eco.o: mstl/m_bit_functions.h
pgn_split_eco.o: mstl/m_bit_functions.ipp
pgn_split_eco.o: db/db_producer.ipp
pgn_split_eco.o: db/db_consumer.h
pgn_split_eco.o: db/db_provider.h
pgn_split_eco.o: db/db_provider.ipp
pgn_split_eco.o: db/db_board.h
pgn_split_eco.o: db/db_move_list.h
pgn_split_eco.o: db/db_move.h
pgn_split_eco.o: util/u_crc.h
pgn_split_eco.o: util/u_crc.ipp
pgn_split_eco.o: mstl/m_byte_order.h
pgn_split_eco.o: mstl/m_byte_order.ipp
pgn_split_eco.o: mstl/m_string.h
pgn_split_eco.o: mstl/m_string.ipp
pgn_split_eco.o: db/db_move.ipp
pgn_split_eco.o: db/db_move_list.ipp
pgn_split_eco.o: db/db_signature.h
pgn_split_eco.o: db/db_signature.ipp
pgn_split_eco.o: db/db_board.ipp
pgn_split_eco.o: db/db_line.h
pgn_split_eco.o: db/db_line.ipp
pgn_split_eco.o: db/db_home_pawns.h
pgn_split_eco.o: db/db_home_pawns.ipp
pgn_split_eco.o: mstl/m_stack.h
pgn_split_eco.o: mstl/m_memblock.h
pgn_split_eco.o: mstl/m_memblock.ipp
pgn_split_eco.o: mstl/m_stack.ipp
pgn_split_eco.o: mstl/m_uninitialized.h
pgn_split_eco.o: mstl/m_uninitialized.ipp
pgn_split_eco.o: mstl/m_algobase.h
pgn_split_eco.o: mstl/m_algobase.ipp
pgn_split_eco.o: mstl/m_construct.h
pgn_split_eco.o: mstl/m_construct.ipp
pgn_split_eco.o: db/db_consumer.ipp
pgn_split_eco.o: db/db_reader.ipp
pgn_split_eco.o: db/db_annotation.h
pgn_split_eco.o: db/db_annotation.ipp
pgn_split_eco.o: db/db_tag_set.h
pgn_split_eco.o: mstl/m_vector.h
pgn_split_eco.o: mstl/m_vector.ipp
pgn_split_eco.o: mstl/m_bitfield.h
pgn_split_eco.o: mstl/m_bitfield.ipp
pgn_split_eco.o: db/db_tag_set.ipp
pgn_split_eco.o: db/db_mark_set.h
pgn_split_eco.o: db/db_mark.h
pgn_split_eco.o: db/db_mark.ipp
pgn_split_eco.o: db/db_mark_set.ipp
pgn_split_eco.o: db/db_comment.h
pgn_split_eco.o: mstl/m_map.h
pgn_split_eco.o: mstl/m_pair.h
pgn_split_eco.o: mstl/m_pair.ipp
pgn_split_eco.o: mstl/m_map.ipp
pgn_split_eco.o: db/db_comment.ipp
pgn_split_eco.o: db/db_pgn_writer.h
pgn_split_eco.o: db/db_writer.h
pgn_split_eco.o: db/db_writer.ipp
pgn_split_eco.o: db/db_eco_table.h
pgn_split_eco.o: db/db_eco.h
pgn_split_eco.o: db/db_eco.ipp
pgn_split_eco.o: mstl/m_hash.h
pgn_split_eco.o: mstl/m_hash.ipp
pgn_split_eco.o: mstl/m_bitset.h
pgn_split_eco.o: mstl/m_bitset_iterator.h
pgn_split_eco.o: mstl/m_bitset_iterator.ipp
pgn_split_eco.o: mstl/m_bitset.ipp
pgn_split_eco.o: mstl/m_chunk_allocator.h
pgn_split_eco.o: mstl/m_chunk_allocator.ipp
pgn_split_eco.o: db/db_eco_table.ipp
pgn_split_eco.o: util/u_zstream.h
pgn_split_eco.o: mstl/m_istream.h
pgn_split_eco.o: mstl/m_ios.h
pgn_split_eco.o: mstl/m_ios.ipp
pgn_split_eco.o: mstl/m_istream.ipp
pgn_split_eco.o: mstl/m_ostream.h
pgn_split_eco.o: mstl/m_ostream.ipp
pgn_split_eco.o: util/u_progress.h
pgn_split_eco.o: util/u_progress.ipp
pgn_split_eco.o: sys/sys_utf8_codec.h
pgn_split_eco.o: mstl/m_list.h
pgn_split_eco.o: mstl/m_pointer_iterator.h
pgn_split_eco.o: mstl/m_pointer_iterator.ipp
pgn_split_eco.o: mstl/m_list.ipp
pgn_split_eco.o: sys/sys_utf8_codec.ipp
pgn_split_eco.o: mstl/m_ifstream.h
pgn_split_eco.o: mstl/m_file.h
pgn_split_eco.o: mstl/m_file.ipp
pgn_split_eco.o: mstl/m_ifstream.ipp
pgn_split_eco.o: mstl/m_ofstream.h
pgn_split_eco.o: mstl/m_ofstream.ipp
pgn_split_eco.o: mstl/m_sstream.h
tkscidb.o: tk/tk_init.h
tkscidb.o: tcl/tcl_base.h
tkscidb.o: tcl/tcl_base.ipp
tkscidb.o: util/u_zstream.h
tkscidb.o: mstl/m_istream.h
tkscidb.o: mstl/m_ios.h
tkscidb.o: mstl/m_exception.h
tkscidb.o: mstl/m_backtrace.h
tkscidb.o: mstl/m_types.h
tkscidb.o: mstl/m_exception.ipp
tkscidb.o: mstl/m_ios.ipp
tkscidb.o: mstl/m_istream.ipp
tkscidb.o: mstl/m_ostream.h
tkscidb.o: mstl/m_ostream.ipp
tkscidb.o: mstl/m_vector.h
tkscidb.o: mstl/m_type_traits.h
tkscidb.o: mstl/m_type_traits.ipp
tkscidb.o: mstl/m_memblock.h
tkscidb.o: mstl/m_memblock.ipp
tkscidb.o: mstl/m_utility.h
tkscidb.o: mstl/m_utility.ipp
tkscidb.o: mstl/m_limits.h
tkscidb.o: mstl/m_bit_functions.h
tkscidb.o: mstl/m_bit_functions.ipp
tkscidb.o: mstl/m_assert.h
tkscidb.o: mstl/m_vector.ipp
tkscidb.o: mstl/m_uninitialized.h
tkscidb.o: mstl/m_uninitialized.ipp
tkscidb.o: mstl/m_algobase.h
tkscidb.o: mstl/m_algobase.ipp
tkscidb.o: mstl/m_construct.h
tkscidb.o: mstl/m_construct.ipp
tkscidb.o: mstl/m_string.h
tkscidb.o: mstl/m_string.ipp
