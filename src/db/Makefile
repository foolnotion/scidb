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

include ../../Makefile.in

.SUFFIXES: .cpp
.PRECIOUS:

INCLUDE	= -I. -Isci -Isi3 -Icbh -I../mstl -I../util -I../util/libTeXt -I../sys
CXXFLAGS	= $(CXXFLAGS) $(CXX_DEBUG) $(OPTIMIZE) $(PROFILING)

SRC_CXX = \
	db_annotation.cpp \
	db_board.cpp \
	db_board_base.cpp \
	db_comment.cpp \
	db_common.cpp \
	db_consumer.cpp \
	db_database.cpp \
	db_database_content.cpp \
	db_database_codec.cpp \
	db_date.cpp \
	db_eco.cpp \
	db_edit_key.cpp \
	db_edit_node.cpp \
	db_exception.cpp \
	db_filter.cpp \
	db_game.cpp \
	db_game_data.cpp \
	db_game_info.cpp \
	db_guess.cpp \
	db_guess_eval.cpp \
	db_home_pawns.cpp \
	db_html_writer.cpp \
	db_line.cpp \
	db_log.cpp \
	db_mark.cpp \
	db_mark_set.cpp \
	db_namebase.cpp \
	db_namebase_entry.cpp \
	db_namebases.cpp \
	db_move.cpp \
	db_move_list.cpp \
	db_move_node.cpp \
	db_pgn_reader.cpp \
	db_pgn_writer.cpp \
	db_player.cpp \
	db_probe.cpp \
	db_producer.cpp \
	db_provider.cpp \
	db_query.cpp \
	db_search.cpp \
	db_selector.cpp \
	db_signature.cpp \
	db_site.cpp \
	db_statistic.cpp \
	db_tablebase.cpp \
	db_tag_set.cpp \
	db_tournament_table.cpp \
	db_tree.cpp \
	db_tree_info.cpp \
	db_tree_cache.cpp \
	db_time.cpp \
	db_var_consumer.cpp \
	db_writer.cpp \
	sci/sci_codec.cpp \
	sci/sci_consumer.cpp \
	sci/sci_decoder.cpp \
	sci/sci_decoder_position.cpp \
	sci/sci_encoder.cpp \
	sci/sci_encoder_position.cpp \
	si3/si3_codec.cpp \
	si3/si3_consumer.cpp \
	si3/si3_decoder.cpp \
	si3/si3_decoder_position.cpp \
	si3/si3_encoder.cpp \
	si3/si3_encoder_position.cpp \
	si3/si3_name_list.cpp \
	si3/si3_stored_line.cpp \
	cbh/cbh_codec.cpp \
	cbh/cbh_decoder.cpp \
	cbh/cbh_decoder_position.cpp \

SRC	= $(SRC_CXX)
OBJS	= $(SRC_CXX:.cpp=.o)
LIB	= libdb

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS) db_eco_table.o db_eco_table_stubs.o

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) db_eco_table.cpp db_eco_table_stubs.cpp  2>/dev/null

$(LIB).a: $(OBJS) db_eco_table.o
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS) db_eco_table.o
	$(RANLIB) $(LIB).a

$(LIB)stubs.a: $(OBJS) db_eco_table_stubs.o
	$(AR) $(ARFLAGS) $(LIB)stubs.a $(OBJS) db_eco_table_stubs.o
	$(RANLIB) $(LIB)stubs.a

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(INCLUDE) $*.cpp

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
