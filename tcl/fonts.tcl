# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

# ======================================================================
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source font-management

namespace eval font {
namespace eval mc {

set ChessBaseFontsInstalled				"ChessBase fonts successfully installed."
set ChessBaseFontsInstallationFailed	"Installation of ChessBase fonts failed."
set NoChessBaseFontFound					"No ChessBase font found in folder '%s'."
set ChessBaseFontsAlreadyInstalled		"ChessBase fonts already installed. Install anyway?"

} ;# namespace mc

namespace import ::tcl::mathfunc::int

array set SymbolUtfEncoding {
	  1 "!"
	  2 "?"
	  3 "\u203c"
	  4 "\u2047"
	  5 "\u2049"
	  6 "\u2048"
	  7 "\u25a0"
	  8 "\u25a1"
	 10 "="
	 11 "=="
	 12 "=\u223c"
	 13 "\u221e"
	 14 "+/="
	 15 "=/+"
	 16 "+/\u2212"
	 17 "\u2212/+"
	 18 "+\u2212"
	 19 "\u2212+"
	 20 "+\u2212\u2212"
	 21 "\u2212\u2212+"
	 22 "\u2299"
	 23 "\u2299"
	 26 "\u25ef"
	 27 "\u25ef"
	 28 "\u25ef\u25ef"
	 29 "\u25ef\u25ef"
	 32 "\u27f3"
	 33 "\u27f3"
	 34 "\u21bb\u21bb"
	 35 "\u21ba\u21ba"
	 36 "\u2191"
	 37 "\u2193"
	 38 "\u21d1"
	 39 "\u21d3"
	 40 "\u2192"
	 41 "\u2190"
	 42 "\u223c/\u2212"
	 43 "\u223c/+"
	 44 "\u223c/="
	 45 "=/\u223c"
	 46 "+/\u223c"
	 47 "\u2212/\u223c"
	 50 "\u229e"
	 51 "\u229e"
	 52 "\u229e\u229e"
	 53 "\u229e\u229e"
	 54 "\u27e9"
	 55 "\u27e9"
	 56 "\u27eb"
	 57 "\u27eb"
	 58 "\u22d9"
	 59 "\u22d9"
	 60 "\u27e8"
	 61 "\u27e8"
	 62 "\u27ea"
	 63 "\u27ea"
	 64 "\u22d8"
	 65 "\u22d8"
	 92 "\u2197"
	 93 "\u2197"
	 96 "\u21c8"
	 97 "\u21ca"
	132 "\u21c4"
	133 "\u21c6"
	134 "\u21c4\u21c4"
	135 "\u21c6\u21c6"
	136 "\u2295"
	137 "\u2296"
	138 "\u2295\u2295"
	139 "\u2296\u2296"
	140 "\u25b3"
	141 "\u25bd"
	142 "\u2313"
	143 "\u2264"
	144 "="
	145 "RR"
	146 "N"
	147 "\u2715"
	148 "\u22a5"
	149 "\u27fa"
	150 "\u21d7"
	151 "\u25eb"
	152 "\u25eb"
	153 "\u25e8"
	154 "^="
	155 "D"
	156 "D'"
	157 "\u26af"
	158 "oo"
	159 "\u26ae"
	160 "\u26a8"
	165 "\u230a"
	166 "\u230b"
	167 "\u229e"
	170 "\u2014"
	171 "R"
	173 "\u25ef"
	174 "\u2295"
	175 "\u27f3"
	176 "\u2299"
	178 "\u2192"
	179 "\u2191"
	180 "\u21c6"
	181 "\u223c/="
	182 "\u25eb"
	183 "\u27eb"
	184 "\u27ea"
}

# Some alternatives for UTF encoding:
# ------------------------------------
#  14: 2A72		not working
#  15: 2A71		--"--
#  22: u2299	does not look good
#  23: u2299	--"--
#  26: u25cb	smaller circle
#  27: u25cb	smaller circle
#  28: u25cb	smaller circle
#  29: u25cb	smaller circle
#  32: u21ba	probably this looks better?
#  33: u21ba	--"__
# 141: u22c1	probably this looks better?
# 141: u2228	probably this looks better?
# 173: u25cb	smaller circle
# 183: u226b	probably this looks better?
# 184: u226a	probably this looks better?

array set mapCodeToNag {}
foreach {nag code} [array get SymbolUtfEncoding] {
	set mapCodeToNag($code) $nag
}

array set SymbolDefaultEncoding {
	  8 "\u00f4"
	 10 "\u003d"
	 11 "=="
	 13 "\u02c7"
	 14 "\u00a4"
	 15 "\u00b4"
	 16 "\u2264"
	 17 "\u220f"
	 18 "+-"
	 19 "-+"
	 22 "\u00e1"
	 23 "\u00e1"
	 36 "\u00cf"
	 37 "\u00cf"
	 40 "\u00d5"
	 41 "\u00d5"
	 42 "\u00b1"
	 43 "\u00b1"
	 44 "\u2260"
	 45 "\u2260"
	132 "\u00d8"
	132 "\u00d8"
	140 "\u00e0"
	142 "\u00a9"
	144 "="
	145 "qq"
	146 "\u0069"
	147 "\u0153"
	148 "\u0141"
	150 "\u00ec"
	151 "\u00d6"
	153 "\u221a"
	154 "\u00ae"
	157 "\u00d1"
	159 "\u00d3"
	160 "\u00fb"
	164 "\u00df"
	165 "\u00a7"
	166 "\u00b8"
	167 "\u00a3"
	168 "\u00f1"
	169 "\u00e9"
	170 "\u00f3"
	173 "\u00df"
	174 "\u00ee"
	175 "\u00e2"
	176 "\u00e1"
	177 "\u00aa"
	182 "\u0192"
	183 "\u203a"
	184 "\u221e"
}

array set ScidbSymbolTravellerEncoding {
	  8 "\uf008"
	 10 "="
	 11 "=="
	 13 "\u00c4"
	 14 "\uf00e"
	 15 "\uf00f"
	 16 "\uf010"
	 17 "\uf011"
	 18 "+-"
	 19 "-+"
	 22 "\uf016"
	 23 "\uf017"
	 36 "\u00c9"
	 37 "\u00c9"
	 40 "\u00c8"
	 41 "\u00c8"
	 44 "\u00c5"
	 45 "\u00c5"
	140 "\u00cd"
	142 "\u00cf"
	144 "="
	149 "\u00d0"
	150 "\u00d1"
	154 "\u00d9"
	157 "\u00db"
	158 "\u00dc"
	159 "\u00da"
	160 "\u00dd"
	164 "\u00de"
	165 "\u00e0"
	166 "\u00e1"
	167 "\u00d2"
	170 "\u00e3"
	172 "\u00e2"
	176 "\uf016"
	181 "\u00c5"
}

array set ScidbSymbolOleEncoding {
	  8 "V"
	 10 "="
	 11 "=="
	 13 "5"
	 14 "1"
	 15 "2"
	 16 "0"
	 17 "4"
	 18 "+-"
	 19 "-+"
	 22 "J"
	 23 "J"
	 32 "E"
	 33 "E"
	 36 "I"
	 37 "I"
	 40 "H"
	 41 "H"
	 44 "6"
	 45 "6"
	132 "G"
	133 "G"
	140 "U"
	142 "W"
	144 "="
	147 "X"
	148 "Y"
	149 ":"
	150 ";"
	151 "7"
	152 "7"
	153 "8"
	154 "9"
	157 "Q"
	159 "R"
	164 "F"
	165 "\""
	166 "$"
	167 "Z"
	172 "%"
	176 "J"
	177 "!"
	183 ">"
	184 "<"
}
# unused: "4"

array set FigurineSymbolChessBaseEncoding {
	  8 "\u2122"
	 10 " \u008f"
	 11 " \u008f\u008f"
	 13 " \u00f7"
	 14 " \u00b2"
	 15 " \u00b3"
	 16 " \u00b1"
	 17 " \u00b5"
	 18 "+-"
	 19 "-+"
	 22 "\u2021"
	 23 "\u2021"
	 26 "\u2020"
	 27 "\u2020"
	 28 "\u2020\u2020"
	 29 "\u2020\u2020"
	 32 "\u2030"
	 33 "\u2030"
	 36 "\u0192"
	 37 "\u0192"
	 39 "\u0129"
	 40 "\u201a"
	 41 "\u201a"
	 42 "\u00b0"
	 43 "\u00b0"
	 44 "\u00a9"
	132 "\u201e"
	133 "\u201e"
	140 "\u2026"
	141 "\u0081"
	142 "\u00b9"
	143 "\u2039"
	144 "\u008f"
	145 "qq"
	147 "\u00d7"
	148 "\u00ac"
	150 "\u2019"
	151 "\u00ad"
	153 "\u00ae"
	154 "\u00af"
	158 "\u00de"
	160 "\u00fe"
	164 "\u2020"
	165 "\u00aa"
	166 "\u00ba"
	168 "\u2018"
	167 "\u201d"
	170 "\u2014"
	173 "\u2020"
	176 "\u2021"
	177 "\u201c"
	183 "\u00bb"
	184 "\u00ab"
}

array set DiagramMarroquinEncoding {
	lite				"\u002a"
	dark				"\u002b"

	lite,wk			"\u006b"
	lite,wq			"\u0071"
	lite,wr			"\u0072"
	lite,wb			"\u0062"
	lite,wn			"\u006e"
	lite,wp			"\u0070"

	lite,bk			"\u006c"
	lite,bq			"\u0077"
	lite,br			"\u0074"
	lite,bb			"\u0076"
	lite,bn			"\u006d"
	lite,bp			"\u006f"

	dark,wk			"\u004b"
	dark,wq			"\u0051"
	dark,wr			"\u0052"
	dark,wb			"\u0042"
	dark,wn			"\u004e"
	dark,wp			"\u0050"

	dark,bk			"\u004c"
	dark,bq			"\u0057"
	dark,br			"\u0054"
	dark,bb			"\u0056"
	dark,bn			"\u004d"
	dark,bp			"\u004f"

	thin,1			"\u0024"
	thin,2			"\u0024"
	thin,3			"\u0024"
	thin,4			"\u0024"
	thin,5			"\u0024"
	thin,6			"\u0024"
	thin,7			"\u0024"
	thin,8			"\u0024"
	thin,a			"\u0022"
	thin,b			"\u0022"
	thin,c			"\u0022"
	thin,d			"\u0022"
	thin,e			"\u0022"
	thin,f			"\u0022"
	thin,g			"\u0022"
	thin,h			"\u0022"
	thin,n			"\u0025"
	thin,e			"\u0028"

	thick,1			"\u0034"
	thick,2			"\u0034"
	thick,3			"\u0034"
	thick,4			"\u0034"
	thick,5			"\u0034"
	thick,6			"\u0034"
	thick,7			"\u0034"
	thick,8			"\u0034"
	thick,a			"\u0032"
	thick,b			"\u0032"
	thick,c			"\u0032"
	thick,d			"\u0032"
	thick,e			"\u0032"
	thick,f			"\u0032"
	thick,g			"\u0032"
	thick,h			"\u0032"
	thick,n			"\u0035"
	thick,e			"\u0038"

	thin,coords,1	"\u00c0"
	thin,coords,2	"\u00c1"
	thin,coords,3	"\u00c2"
	thin,coords,4	"\u00c3"
	thin,coords,5	"\u00c4"
	thin,coords,6	"\u00c5"
	thin,coords,7	"\u00c6"
	thin,coords,8	"\u00c7"
	thin,coords,a	"\u00c8"
	thin,coords,b	"\u00c9"
	thin,coords,c	"\u00ca"
	thin,coords,d	"\u00cb"
	thin,coords,e	"\u00cc"
	thin,coords,f	"\u00cd"
	thin,coords,g	"\u00ce"
	thin,coords,h	"\u00cf"
	thin,coords,n	"\u0025"
	thin,coords,e	"\u0028"

	thick,coords,1	"\u00e0"
	thick,coords,2	"\u00e1"
	thick,coords,3	"\u00e2"
	thick,coords,4	"\u00e3"
	thick,coords,5	"\u00e4"
	thick,coords,6	"\u00e5"
	thick,coords,7	"\u00e6"
	thick,coords,8	"\u00e7"
	thick,coords,a	"\u00e8"
	thick,coords,b	"\u00e9"
	thick,coords,c	"\u00ea"
	thick,coords,d	"\u00eb"
	thick,coords,e	"\u00ec"
	thick,coords,f	"\u00ed"
	thick,coords,g	"\u00ee"
	thick,coords,h	"\u00ef"
	thick,coords,n	"\u0035"
	thick,coords,e	"\u0038"

	thin,edge,nw	"\u0031"
	thin,edge,ne	"\u0033"
	thin,edge,sw	"\u0039"
	thin,edge,se	"\u0037"

	thick,edge,nw	"\u0021"
	thick,edge,ne	"\u0023"
	thick,edge,sw	"\u0029"
	thick,edge,se	"\u002f"
}

array set ScidbDiagramAlphaEncoding {
	lite				"\u0020"
	dark				"\uf02b"

	lite,wk			"\uf06b"
	lite,wq			"\uf071"
	lite,wr			"\u00a0"
	lite,wb			"\uf062"
	lite,wn			"\uf068"
	lite,wp			"\uf070"

	lite,bk			"\uf06c"
	lite,bq			"\uf077"
	lite,br			"\uf074"
	lite,bb			"\uf06e"
	lite,bn			"\uf06a"
	lite,bp			"\uf06f"

	dark,wk			"\uf04b"
	dark,wq			"\uf051"
	dark,wr			"\uf052"
	dark,wb			"\uf042"
	dark,wn			"\uf048"
	dark,wp			"\uf050"

	dark,bk			"\uf04c"
	dark,bq			"\uf057"
	dark,br			"\uf054"
	dark,bb			"\uf04e"
	dark,bn			"\uf04a"
	dark,bp			"\uf04f"

	thin,1			"\uf024"
	thin,2			"\uf024"
	thin,3			"\uf024"
	thin,4			"\uf024"
	thin,5			"\uf024"
	thin,6			"\uf024"
	thin,7			"\uf024"
	thin,8			"\uf024"
	thin,a			"\uf027"
	thin,b			"\uf027"
	thin,c			"\uf027"
	thin,d			"\uf027"
	thin,e			"\uf027"
	thin,f			"\uf027"
	thin,g			"\uf027"
	thin,h			"\uf027"
	thin,n			"\uf022"
	thin,e			"\uf025"

	thick,1			"\uf034"
	thick,2			"\uf034"
	thick,3			"\uf034"
	thick,4			"\uf034"
	thick,5			"\uf034"
	thick,6			"\uf034"
	thick,7			"\uf034"
	thick,8			"\uf034"
	thick,a			"\uf037"
	thick,b			"\uf037"
	thick,c			"\uf037"
	thick,d			"\uf037"
	thick,e			"\uf037"
	thick,f			"\uf037"
	thick,g			"\uf037"
	thick,h			"\uf037"
	thick,n			"\uf032"
	thick,e			"\uf035"

	thin,coords,1	"\uf0e0"
	thin,coords,2	"\uf0e1"
	thin,coords,3	"\uf0e2"
	thin,coords,4	"\uf0e3"
	thin,coords,5	"\uf0e4"
	thin,coords,6	"\uf0e5"
	thin,coords,7	"\uf0e6"
	thin,coords,8	"\uf0e7"
	thin,coords,a	"\uf0e8"
	thin,coords,b	"\uf0e9"
	thin,coords,c	"\uf0ea"
	thin,coords,d	"\uf0eb"
	thin,coords,e	"\uf0ec"
	thin,coords,f	"\uf0ed"
	thin,coords,g	"\uf0ee"
	thin,coords,h	"\uf0ef"
	thin,coords,n	"\uf022"
	thin,coords,e	"\uf025"

	thick,coords,1	"\uf0c0"
	thick,coords,2	"\uf0c1"
	thick,coords,3	"\uf0c2"
	thick,coords,4	"\uf0c3"
	thick,coords,5	"\uf0c4"
	thick,coords,6	"\uf0c5"
	thick,coords,7	"\uf0c6"
	thick,coords,8	"\uf0c7"
	thick,coords,a	"\uf0c8"
	thick,coords,b	"\uf0c9"
	thick,coords,c	"\uf0ca"
	thick,coords,d	"\uf0cb"
	thick,coords,e	"\uf0cc"
	thick,coords,f	"\uf0cd"
	thick,coords,g	"\uf0ce"
	thick,coords,h	"\uf0cf"
	thick,coords,n	"\uf032"
	thick,coords,e	"\uf035"

	thin,edge,nw	"\uf021"
	thin,edge,ne	"\uf023"
	thin,edge,sw	"\uf026"
	thin,edge,se	"\uf028"

	thick,edge,nw	"\uf031"
	thick,edge,ne	"\uf033"
	thick,edge,sw	"\uf036"
	thick,edge,se	"\uf038"
}

array set ScidbDiagramBerlinEncoding {
	lite				"\u0020"
	dark				"\uf02b"

	lite,wk			"\u006b"
	lite,wq			"\u0071"
	lite,wr			"\u00a0"
	lite,wb			"\u0062"
	lite,wn			"\u0068"
	lite,wp			"\u0070"

	lite,bk			"\u006c"
	lite,bq			"\u0077"
	lite,br			"\u0074"
	lite,bb			"\u006e"
	lite,bn			"\u006a"
	lite,bp			"\u006f"

	dark,wk			"\u004b"
	dark,wq			"\u0051"
	dark,wr			"\u0052"
	dark,wb			"\u0042"
	dark,wn			"\u0048"
	dark,wp			"\u0050"

	dark,bk			"\u004c"
	dark,bq			"\u0057"
	dark,br			"\u0054"
	dark,bb			"\u004e"
	dark,bn			"\u004a"
	dark,bp			"\u004f"

	thin,1			"\u0034"
	thin,2			"\u0034"
	thin,3			"\u0034"
	thin,4			"\u0034"
	thin,5			"\u0034"
	thin,6			"\u0034"
	thin,7			"\u0034"
	thin,8			"\u0034"
	thin,a			"\u0037"
	thin,b			"\u0037"
	thin,c			"\u0037"
	thin,d			"\u0037"
	thin,e			"\u0037"
	thin,f			"\u0037"
	thin,g			"\u0037"
	thin,h			"\u0037"
	thin,n			"\u0032"
	thin,e			"\u0035"

	thick,1			"\uf034"
	thick,2			"\uf034"
	thick,3			"\uf034"
	thick,4			"\uf034"
	thick,5			"\uf034"
	thick,6			"\uf034"
	thick,7			"\uf034"
	thick,8			"\uf034"
	thick,a			"\uf037"
	thick,b			"\uf037"
	thick,c			"\uf037"
	thick,d			"\uf037"
	thick,e			"\uf037"
	thick,f			"\uf037"
	thick,g			"\uf037"
	thick,h			"\uf037"
	thick,n			"\uf032"
	thick,e			"\uf035"

	thin,coords,1	"\u0034"
	thin,coords,2	"\u0034"
	thin,coords,3	"\u0034"
	thin,coords,4	"\u0034"
	thin,coords,5	"\u0034"
	thin,coords,6	"\u0034"
	thin,coords,7	"\u0034"
	thin,coords,8	"\u0034"
	thin,coords,a	"\u0037"
	thin,coords,b	"\u0037"
	thin,coords,c	"\u0037"
	thin,coords,d	"\u0037"
	thin,coords,e	"\u0037"
	thin,coords,f	"\u0037"
	thin,coords,g	"\u0037"
	thin,coords,h	"\u0037"
	thin,coords,n	"\u0032"
	thin,coords,e	"\u0035"

	thick,coords,1	"\u0034"
	thick,coords,2	"\u0034"
	thick,coords,3	"\u0034"
	thick,coords,4	"\u0034"
	thick,coords,5	"\u0034"
	thick,coords,6	"\u0034"
	thick,coords,7	"\u0034"
	thick,coords,8	"\u0034"
	thick,coords,a	"\u0037"
	thick,coords,b	"\u0037"
	thick,coords,c	"\u0037"
	thick,coords,d	"\u0037"
	thick,coords,e	"\u0037"
	thick,coords,f	"\u0037"
	thick,coords,g	"\u0037"
	thick,coords,h	"\u0037"
	thick,coords,e	"\u0032"
	thick,coords,n	"\u0035"

	thin,edge,nw	"\u0031"
	thin,edge,ne	"\u0033"
	thin,edge,sw	"\u0036"
	thin,edge,se	"\u0038"

	thick,edge,nw	"\u0031"
	thick,edge,ne	"\u0033"
	thick,edge,sw	"\u0036"
	thick,edge,se	"\u0038"
}

# TODO
#	ScidbDiagramCheqEncoding
#	ScidbDiagramPhoenixEncoding
#	ScidbDiagramSmartEncoding
#	ScidbDiagramUSCFEncoding
#	ScidbDiagramUsualEncoding
#	ScidbDiagramWinboardEncoding
#	ScidbDiagramGoodCompanionEncoding

array set DiagramChessBaseEncoding {
	lite				"\u002a"
	dark				"\u002b"

	lite,wk			"\u004b"
	lite,wq			"\u0051"
	lite,wr			"\u0052"
	lite,wb			"\u004c"
	lite,wn			"\u004e"
	lite,wp			"\u0050"

	lite,bk			"\u006b"
	lite,bq			"\u0071"
	lite,br			"\u0072"
	lite,bb			"\u006c"
	lite,bn			"\u006e"
	lite,bp			"\u0070"

	dark,mk			"\u006d"
	dark,mq			"\u0077"
	dark,mr			"\u0074"
	dark,mb			"\u0076"
	dark,mn			"\u0073"
	dark,mp			"\u007a"

	thin,1			"\u0024"
	thin,2			"\u0024"
	thin,3			"\u0024"
	thin,4			"\u0024"
	thin,5			"\u0024"
	thin,6			"\u0024"
	thin,7			"\u0024"
	thin,8			"\u0024"
	thin,a			"\u0022"
	thin,b			"\u0022"
	thin,c			"\u0022"
	thin,d			"\u0022"
	thin,e			"\u0022"
	thin,f			"\u0022"
	thin,g			"\u0022"
	thin,h			"\u0022"
	thin,n			"\u0025"
	thin,e			"\u0028"

	thick,1			"\u0034"
	thick,2			"\u0034"
	thick,3			"\u0034"
	thick,4			"\u0034"
	thick,5			"\u0034"
	thick,6			"\u0034"
	thick,7			"\u0034"
	thick,8			"\u0034"
	thick,a			"\u0032"
	thick,b			"\u0032"
	thick,c			"\u0032"
	thick,d			"\u0032"
	thick,e			"\u0032"
	thick,f			"\u0032"
	thick,g			"\u0032"
	thick,h			"\u0032"
	thick,n			"\u0035"
	thick,e			"\u0038"

	thin,coords,1	"\u00c0"
	thin,coords,2	"\u00c1"
	thin,coords,3	"\u00c2"
	thin,coords,4	"\u00c3"
	thin,coords,5	"\u00c4"
	thin,coords,6	"\u00c5"
	thin,coords,7	"\u00c6"
	thin,coords,8	"\u00c7"
	thin,coords,a	"\u00c8"
	thin,coords,b	"\u00c9"
	thin,coords,c	"\u00ca"
	thin,coords,d	"\u00cb"
	thin,coords,e	"\u00cc"
	thin,coords,f	"\u00cd"
	thin,coords,g	"\u00ce"
	thin,coords,h	"\u00cf"
	thin,coords,n	"\u0025"
	thin,coords,e	"\u0028"

	thick,coords,1	"\u00e0"
	thick,coords,2	"\u00e1"
	thick,coords,3	"\u00e2"
	thick,coords,4	"\u00e3"
	thick,coords,5	"\u00e4"
	thick,coords,6	"\u00e5"
	thick,coords,7	"\u00e6"
	thick,coords,8	"\u00e7"
	thick,coords,a	"\u00e8"
	thick,coords,b	"\u00e9"
	thick,coords,c	"\u00ea"
	thick,coords,d	"\u00eb"
	thick,coords,e	"\u00ec"
	thick,coords,f	"\u00ed"
	thick,coords,g	"\u00ee"
	thick,coords,h	"\u00ef"
	thick,coords,n	"\u0035"
	thick,coords,e	"\u0038"

	thin,edge,nw	"\u0031"
	thin,edge,ne	"\u0033"
	thin,edge,sw	"\u0039"
	thin,edge,se	"\u0037"

	thick,edge,nw	"\u0021"
	thick,edge,ne	"\u0023"
	thick,edge,sw	"\u0029"
	thick,edge,se	"\u002f"
}

set FigurineChessBaseEncoding {"\u2654" K "\u2655" Q "\u2656" R "\u2657" L "\u2658" N "\u2659" P}


proc SetupChessBaseFonts {} {
	variable fonts
	variable FigurineChessBaseEncoding
	variable FigurineSymbolChessBaseEncoding
	variable DiagramChessBaseEncoding
	variable chessFigurineFonts
	variable chessFigurineFontsMap
	variable chessSymbolFonts
	variable chessSymbolFontsMap
	variable chessDiagramFonts
	variable chessDiagramFontsMap

	# Chess figurine fonts:
	foreach font {DiagramTTCrystals DiagramTTFritz DiagramTTHabsburg DiagramTTOldstyle DiagramTTUSCF} {
		if {$font in $fonts} {
			lappend chessFigurineFonts $font
			set chessFigurineFontsMap($font) $FigurineChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessFigurineFonts $font
				set chessFigurineFontsMap($font) $FigurineChessBaseEncoding
			}
		}
	}

	# Chess symbol fonts:
	foreach font {{FigurineCB AriesSP} {FigurineCB LetterSP} {FigurineCB TimeSP}} {
		if {$font in $fonts} {
			lappend chessSymbolFonts $font
			set chessSymbolFontsMap($font) FigurineSymbolChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessSymbolFonts $font
				set chessSymbolFontsMap($font) FigurineSymbolChessBaseEncoding
			}
		}
	}

	# Chess diagram fonts
	foreach font {DiagramTTCrystals DiagramTTFritz DiagramTTHabsburg DiagramTTOldstyle DiagramTTUSCF} {
		if {$font in $fonts} {
			lappend chessDiagramFonts $font
			set chessDiagramFontsMap($font) DiagramChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessDiagramFonts $font
				set chessDiagramFontsMap($font) DiagramChessBaseEncoding
			}
		}
	}
}


# Chess figurine fonts:
set fonts [::dialog::choosefont::fontFamilies]
set chessFigurineFonts {}
foreach font $fonts {
	if {[string match -nocase {Scidb Chess *} $font]} {
		lappend chessFigurineFonts $font
		set chessFigurineFontsMap($font) {}
	}
}

# Chess symbol fonts:
#   1. family name
#   2. encoding map
set chessSymbolFonts {}
foreach font $fonts {
	if {[string match -nocase {Scidb Symbol *} $font]} {
		set enc ScidbSymbol
		append enc [lindex [split $font " "] 2] Encoding
		if {![info exists $enc]} { set enc SymbolDefaultEncoding }
		lappend chessSymbolFonts $font
		set chessSymbolFontsMap($font) $enc
	}
}

# Chess diagram fonts
set chessDiagramFonts {}
foreach font $fonts {
	if {[string match -nocase {Scidb Diagram *} $font]} {
		set enc Diagram
		append enc [lindex [split $font " "] 2] Encoding
		if {![info exists $enc]} { set enc DiagramMarroquinEncoding }
		lappend chessDiagramFonts $font
		set chessDiagramFontsMap($font) $enc
	}
}

SetupChessBaseFonts


variable defaultFigurineFont {Scidb Chess Traveller}
variable defaultDiagramFont  {Scidb Diagram Merida}
variable defaultSymbolFont   {Scidb Symbol Traveller}

if {$defaultFigurineFont ni $fonts} { set defaultFigurineFont [string tolower $defaultFigurineFont] }
if {$defaultDiagramFont  ni $fonts} { set defaultDiagramFont  [string tolower $defaultDiagramFont ] }
if {$defaultSymbolFont   ni $fonts} { set defaultSymbolFont   [string tolower $defaultSymbolFont  ] }

# Sources:
# 	http://en.wikipedia.org/wiki/Algebraic_chess_notation
# 	http://www.geocities.com/timessquare/metro/9154/nap-pieces.htm
#
# Alternatives:
#	ru	{K F L S N P}
#	sr	{K D T L S P}
#	he	{mele malkah tseriya rats para ragl}
array set figurines {
	graphic	{\u2654 \u2655 \u2656 \u2657 \u2658 \u2659}
	az			{S V T F A P}
	bg			{\u0426 \u0414 \u0422 \u041e \u041a \u041f}
	ca			{R D T A C P}
	cs			{K D V S J P}
	cy			{T B C E M G}
	da			{K D T L S B}
	de			{K D T L S B}
	el			{\u03a1 \u0392 \u03a0 \u0391 \u0399 \u03a3}
	en			{K Q R B N P}
	eo			{R D T K C \u0108}
	es			{R D T A C P}
	et			{K L V O R E}
	eu			{E D G Z S P}
	fi			{K D T L R S}
	fr			{R D T F C P}
	ga			{R B C E D F}
	gl			{R D T B C P}
	he			{\u05de "\u05d4\u05de" \u05e6 \u05e8 \u05e4 "\u05d9\u05dc\u05d2\u05e8"}
	hr			{K D T L S P}
	hu			{K V B F H G}
	ia			{R G T E C P}
	is			{K D H B R P}
	it			{R D T A C P}
	la			{K G T E Q P}
	lb			{K D T L P B}
	lt			{K V B R \u017d P}
	lv			{K D T L Z B}
	ms			{R M T K G A}
	nl			{K D T L P O}
	no			{K D T L S B}
	pl			{K H W G S P}
	pt			{R D T B C P}
	ro			{R D T N C P}
	ru			{\u0420 \u0424 \u041b \u0421 \u041a \u041f}
	sk			{K D V S J P}
	sl			{K D T L S P}
	sr			{\u041a \u0414 \u0422 \u041b \u0421 \u041f}
	sv			{K D T L S B}
	tr			{\u015e V K F A P}
	uk			{\u0420 \u0424T \u0421 \u041a \u041f}
}
# TODO ------------------------------------------
#	sq			------	Albanian			Mbret	Mbretëreshë Top  	Oficier  	Kal  	 	Pion
#	br			------	Breton			roue 	rouanez 		tour 	marc'heg 	furlukin	pezh-gwerin
#	gl			------	Galician			rei 	raíña 		torre cabalo 		bispo 	peón
#	ku			------	Kurdish			ah 	abanî 		birc 	metran 		siwar 	piyon
#	se			------	Sami
#	gd			------	Scotish
#	dsb		------	Lower Sorbian	kral 	dama 			torm 	bga 			kónik 	burik
#	hsb		------	Upper Sorbian	kral 	dama 			wa 	bhar 			konik 	burik
# Auxiliary -------------------------------------
#	af			KDTLRP
#	FI			KDTSNP
#	fy			KDSFHB
#	hi			RVHOGP
# -----------------------------------------------

variable UnicodeMap {
	"\u2654" "&*\u2654&" \
	"\u2655" "&*\u2655&" \
	"\u2656" "&*\u2656&" \
	"\u2657" "&*\u2657&" \
	"\u2658" "&*\u2658&" \
	"\u2659" "&*\u2659&" \
}

variable GraphicMap
variable LangMap

variable pieceMap {
	K "\u2654"
	Q "\u2655"
	R "\u2656"
	B "\u2657"
	N "\u2658"
	P "\u2659"
}

set UseSymbols		[expr {[info exists chessSymbolFontsMap($defaultSymbolFont)]}]
set UseFigurines	[expr {[info exists chessFigurineFontsMap($defaultFigurineFont)]}]

variable langFigurine en

if {$UseSymbols} {
	set symbol [font create ::font::symbol \
						-family $defaultSymbolFont \
						-size [font configure TkTextFont -size]]
	set symbolb [font create ::font::symbolb \
						-family $defaultSymbolFont \
						-size [font configure TkTextFont -size] \
						-weight bold]
	set symbolEncoding $chessSymbolFontsMap($defaultSymbolFont)
} else {
	set symbol TkTextFont
	set symbolb TkTextFont
}


proc useLanguage {lang} {
	variable figurines
	variable GraphicMap

	set langFigurine $lang
	set GraphicMap {}
	set graphic $figurines(graphic)
	set figurine $figurines($lang)

	for {set i 0} {$i < 5} {incr i} {
		lappend GraphicMap [string index $graphic $i] [string index $figurine $i]
	}

	lappend GraphicMap [string index $graphic $i] ""
}


proc useFigurines {{flag 1}} {
	variable UseFigurines
	variable defaultFigurineFont
	variable chessFigurineFontsMap
	variable figurine
	variable figurineSmall
	variable figurineEncoding

	set UseFigurines $flag

	if {$UseFigurines} {
		set figurine [font create ::font::figurine \
							-family $defaultFigurineFont \
							-size [font configure TkTextFont -size]]
		set figurineSmall [font create ::font::figurineSmall \
							-family $defaultFigurineFont \
							-size [font configure TkTooltipFont -size]]
		set figurineEncoding $chessFigurineFontsMap($defaultFigurineFont)
	} else {
		set figurine TkTextFont
		set figurineSmall TkTooltipFont
	}
}


proc translate {move} {
	variable UseFigurines

	if {$UseFigurines} { return $move }

	variable GraphicMap
	return [string map $GraphicMap $move]
}


proc splitMoves {text} {
	variable UseFigurines

	if {$UseFigurines} {
		variable UnicodeMap
		variable figurineEncoding

		set moves [split [string map $UnicodeMap $text] &]
		set result {}

		foreach m $moves {
			if {[string index $m 0] == "*"} {
				lappend result [string range $m 1 end] figurine
			} else {
#				if we like to use Oh's, not zeroes, uncomment this:
				if {[llength $figurineEncoding]} { set m [string map $figurineEncoding $m] }
#				lappend result [string map {O 0} $m] {}
				lappend result $m {}
			}
		}
	} else {
		variable GraphicMap
		set result [list [string map $GraphicMap $text] {}]
	}

	return $result
}


proc mapNagToSymbol {nag} {
	variable SymbolUtfEncoding

	if {![info exists SymbolUtfEncoding($nag)]} { return $nag }
	return $SymbolUtfEncoding($nag)
}


proc splitAnnotation {text} {
	variable UseSymbols

	if {$UseSymbols} {
		variable symbolEncoding
		upvar 0 [namespace current]::$symbolEncoding enc
	}

	set result {}

	foreach nag $text {
		if {[string index $nag 0] eq "$"} {
			set value [int [string range $nag 1 end]]
		} else {
			set value $nag
		}
		if {[info exists enc($value)]} {
			lappend result $value $enc($value) symbol
		} else {
			set sym [mapNagToSymbol $value]
			if {$value eq $sym} {
				lappend result $value $nag {}
			} else {
				lappend result $value $sym {}
			}
		}
	}

	return $result
}


if {$tcl_platform(platform) ne "windows"} {

	proc installChessBaseFonts {parent {windowsFontDir /c/WINDOWS/Fonts}} {
		global tcl_platform
		variable fonts

		if {{FigurineCB AriesSP} in $fonts} {
			set msg $mc::ChessBaseFontsAlreadyInstalled
			set reply [::dialog::question -parent $parent -message $msg]
			if {$reply eq "no"} { return }
		}

		if {![file isdirectory $windowsFontDir]} {
			::dialog::error -parent $parent -message [format $mc::CannotFindDirectory $windowsFontDir]
			return 0
		}

		if {$tcl_platform(os) eq "Darwin"} {
			set fontDir /Library/Fonts/
		} else {
			set fontDir [file join $::scidb::dir::home .fonts]
		}
		if {![file isdirectory $fontDir]} {
			if {[catch { file mkdir $fontDir }]} {
				::dialog::error -parent $parent -message [format $mc::CannotCreateDirectory $fontDir]
				return 0
			}
		}

		set count 0

		::widget::busyCursor on
		foreach font {	DiaTTCry DiaTTFri DiaTTHab DiaTTOld DiaTTUSA Diablindall
							SpArFgBI SpArFgBd SpArFgIt SpArFgRg SpLtFgBI SpLtFgBd
							SpLtFgIt SpLtFgRg SpTmFgBI SpTmFgBd SpTmFgIt SpTmFgRg} {
			set file [file join $windowsFontDir $font.ttf]
			if {[file readable $file]} {
				file copy -force $file $fontDir
				incr count
			}
		}

		if {$count == 0} {
			::dialog::info -parent $parent -message [format $mc::NoChessBaseFontFound $windowsFontDir]
		} else {
			if {$tcl_platform(platform) eq "unix"} {
				catch { exec fc-cache -f $fontDir }
			}

			::dialog::choosefont::resetFonts
			set fonts [::dialog::choosefont::fontFamilies]

			if {{FigurineCB AriesSP} in $fonts} {
				SetupChessBaseFonts
				::dialog::info -parent $parent -message $mc::ChessBaseFontsInstalled
			} else {
				::dialog::error -parent $parent -message $mc::ChessBaseFontsInstallationFailed
			}
		}

		::widget::busyCursor off
		return $count
	}

}

# setup ###############################################################################

if {$UseFigurines && [::tk windowingsystem] eq "x11"} {
	set UseFigurines 0
	catch { if {[::tk::pkgconfig get fontsystem] eq "xft"} { set UseFigurines 1 } }
}

useFigurines $UseFigurines
useLanguage $langFigurine

} ;# namespace font

# vi:set ts=3 sw=3:
