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

include ../../../Makefile.in

.SUFFIXES: .c

INCLUDE	= -I. -I../../mstl
DEFINES	= -DHPDF_NOPNGLIB

SRC_C = \
	hpdf_annotation.c \
	hpdf_array.c \
	hpdf_binary.c \
	hpdf_boolean.c \
	hpdf_catalog.c \
	hpdf_destination.c \
	hpdf_dict.c \
	hpdf_doc.c \
	hpdf_doc_png.c \
	hpdf_encoder.c \
	hpdf_encoder_cns.c \
	hpdf_encoder_cnt.c \
	hpdf_encoder_jp.c \
	hpdf_encoder_kr.c \
	hpdf_encrypt.c \
	hpdf_encryptdict.c \
	hpdf_error.c \
	hpdf_ext_gstate.c \
	hpdf_font.c \
	hpdf_font_cid.c \
	hpdf_font_tt.c \
	hpdf_font_type1.c \
	hpdf_fontdef.c \
	hpdf_fontdef_base14.c \
	hpdf_fontdef_cid.c \
	hpdf_fontdef_cns.c \
	hpdf_fontdef_cnt.c \
	hpdf_fontdef_jp.c \
	hpdf_fontdef_kr.c \
	hpdf_fontdef_tt.c \
	hpdf_fontdef_type1.c \
	hpdf_gstate.c \
	hpdf_image.c \
	hpdf_image_png.c \
	hpdf_info.c \
	hpdf_list.c \
	hpdf_mmgr.c \
	hpdf_name.c \
	hpdf_null.c \
	hpdf_number.c \
	hpdf_objects.c \
	hpdf_outline.c \
	hpdf_page_label.c \
	hpdf_page_operator.c \
	hpdf_pages.c \
	hpdf_real.c \
	hpdf_streams.c \
	hpdf_string.c \
	hpdf_utils.c \
	hpdf_xref.c \

SRC	= $(SRC_C)
OBJS	= $(SRC_C:.c=.o)
LIB	= libharu

all: $(LIB).a

clean:
	rm -f $(LIB).a $(OBJS)

depend:
	makedepend -fMakefile -Y -- $(INCLUDE) -- -w1 $(SRC) 2>/dev/null

$(LIB).a: $(OBJS)
	$(AR) $(ARFLAGS) $(LIB).a $(OBJS)
	$(RANLIB) $(LIB).a

.c.o:
	$(CC) -c $(CFLAGS) $(OPTIMIZE) $(INCLUDE) $(DEFINES) $*.c

# vi:set ts=3 sw=3:
# DO NOT DELETE THIS LINE -- make depend depends on it.
