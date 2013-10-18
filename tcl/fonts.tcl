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
# Copyright: (C) 2009-2013 Gregor Cramer
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
set ChooseMountPoint							"Mount point of Windows installation partition"
set CopyingChessBaseFonts					"Copying ChessBase fonts"
set CopyFile									"Copy file %s"
set UpdateFontCache							"Updating font cache"

set ChooseFigurineFont						"Choose figurine font"
set ChooseSymbolFont							"Choose symbol font"
set IncreaseFontSize							"Increase Font Size"
set DecreaseFontSize							"Decrease Font Size"
set DefaultFont								"Default font"

} ;# namespace mc

namespace import ::tcl::mathfunc::int

array set mapCodeToNag {
	"\u203c"				3
	"\u2047"				4
	"\u2049"				5
	"\u2048"				6
	"\u25a0"				7
	"\u25a1"				8
	"=="					11
	"=\u223c"			12
	"\u221e"				13
	"\u2a72"				14
	"\u2a71"				15
	"\u00b1"				16
	"\u2213"				17
	"+\u2212"			18
	"\u2212+"			19
	"+\u2212\u2212"	20
	"\u2212\u2212+"	21
	"\u21d1"				38
	"\u21d3"				39
	"\u223c/\u2212"	42
	"\u223c/+"			43
	"\u223c/="			44
	"=/\u223c"			45
	"+/\u223c"			46
	"\u2212/\u223c"	47
	"\u21c8"				96
	"\u21ca"				97
	"\u21c4\u21c4"		134
	"\u21c6\u21c6"		135
	"\u2295\u2295"		138
	"\u2296\u2296"		139
	"\u25b3"				140
	"\u2206"				140
	"\u20e4"				140
	"\u22c1"				141
	"\u2228"				141
	"\u2313"				142
	"\u2264"				143
	"\u2715"				147
	"\u22a5"				148
	"\u27fa"				149
	"\u21d4"				149
	"\u21d7"				150
	"\u25e8"				153
	"\u2b12"				155
	"\u2b13"				156
	"\u26af"				157
	"\u26ae"				159
	"\u26a8"				160
	"\u230a"				165
	"\u230b"				166
	"\u229e"				167
	"\u2014"				170
	"\u25dd"				173
	"\u25ef"				173
	"\u3007"				173
	"\u2295"				174
	"\u21bb"				175
	"\u2299"				176
	"\u2192"				178
	"\u2191"				179
	"\u21c6"				180
	"\u221e="			181
	"\u25eb"				182
	"\u00bb"				183
	"\u27eb"				183
	"\u226b"				183
	"\u300b"				183
	"\u00ab"				184
	"\u27ea"				184
	"\u226a"				184
	"\u300a"				184
}

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
	 16 "\u00b1"
	 17 "\u2213"
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
	 32 "\u21bb"
	 33 "\u21bb"
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
	149 "\u21d4"
	150 "\u21d7"
	151 "\u25eb"
	152 "\u25eb"
	153 "\u25e8"
	154 "^="
	155 "\u2b12"
	156 "\u2b13"
	157 "\u26af"
	158 "oo"
	159 "\u26ae"
	160 "\u26a8"
	165 "\u230a"
	166 "\u230b"
	167 "\u229e"
	168 "||"
	170 "\u2014"
	171 "R"
	173 "\u25ef"
	174 "\u2295"
	175 "\u21bb"
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
#  22: 2299		does not look good
#  23: 2299		--"--
#  32: 21ba		probably this looks better?
#  33: 21ba		--"__
# 141: 22c1		probably this looks better?
# 141: 2228		probably this looks better?
# 173: 25dd		fat circle
# 183: 226b		probably this looks better?
# 184: 226a		probably this looks better?

array set SymbolDefaultEncoding {
	  8 "\u00f4"
	 10 "="
	 11 "=="
	 13 "\u02c7"
	 14 "\u00a4"
	 15 "\u00b4"
	 16 "\u2264"
	 17 "\u220f"
	 18 "+\u2212"
	 19 "\u2212+"
	 20 "+\u2212\u2212"
	 21 "\u2212\u2212+"
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

# E000 - F8FE
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
	 20 "+--"
	 21 "--+"
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
	151 "\u00d7"
	152 "\u00d7"
	153 "\u00d8"
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

array set SymbolInformantEncoding {
	  7 "\u00f3"
	  8 "\u00ec"
	 10 "\u003d"
	 11 "\u003d\u003d"
	 13 "\u00d5"
	 14 "\u00a2"
	 15 "\u00a3"
	 16 "\u00a5"
	 17 "\u00a4"
	 18 "+\u2212"
	 19 "\u2212+"
	 20 "+\u2212\u2212"
	 21 "\u2212\u2212+"
	 32 "\u00b6"
	 33 "\u00b6"
	 36 "\u00ef"
	 37 "\u00ef"
	 40 "\u00ee"
	 41 "\u00ee"
	 44 "\u00a7"
	 45 "\u00a7"
	140 "\u00c5"
	142 "\u00c4"
	147 "\u005e"
	148 "\u00cf"
	150 "\u005c"
	151 "\u00d2"
	152 "\u00d2"
	153 "\u00d3"
	154 "\u00d4"
	157 "\u00db"
	158 "\u00da"
	159 "\u00d9"
	160 "\u003c"
	164 "\u00c1"
	165 "\u00b4"
	166 "\u005f"
	167 "\u00bf"
	169 "\u007e"
	170 "\u00d1"
	171 "\u00df"
	173 "\u00c1"
	174 "\u00b0"
	175 "\u00b6"
	176 "\u00c2"
	178 "\u00ee"
	179 "\u00ef"
	180 "\u007c"
	181 "\u00a7"
	182 "\u00d2"
	183 "\u007d"
	184 "\u007b"
}
# unused: \u00f5, \u00fa

array set ScidbSymbolOleEncoding {
	  8 "V"
	 10 "="
	 11 "=="
	 13 "5"
	 14 "1"
	 15 "2"
	 16 "0"
	 17 "4"
	 18 "+\u2212"
	 19 "\u2212+"
	 20 "+\u2212\u2212"
	 21 "\u2212\u2212+"
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
	 18 "+\u2212"
	 19 "\u2212+"
	 20 "+\u2212\u2212"
	 21 "\u2212\u2212+"
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
	variable FigurineChessBaseEncoding
	variable FigurineSymbolChessBaseEncoding
	variable DiagramChessBaseEncoding
	variable chessFigurineFonts
	variable chessFigurineFontsMap
	variable chessSymbolFonts
	variable chessSymbolFontsMap
	variable chessDiagramFonts
	variable chessDiagramFontsMap

	set fonts [::dialog::choosefont::fontFamilies]

	# Chess figurine fonts:
	foreach font {DiagramTTCrystals DiagramTTFritz DiagramTTHabsburg DiagramTTOldstyle DiagramTTUSCF} {
		if {$font in $fonts} {
			lappend chessFigurineFonts $font
			set chessFigurineFontsMap([string tolower $font]) $FigurineChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessFigurineFonts $font
				set chessFigurineFontsMap([string tolower $font]) $FigurineChessBaseEncoding
			}
		}
	}

	# Chess symbol fonts:
	foreach font {{FigurineCB AriesSP} {FigurineCB LetterSP} {FigurineCB TimeSP}} {
		if {$font in $fonts} {
			lappend chessSymbolFonts $font
			set chessSymbolFontsMap([string tolower $font]) FigurineSymbolChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessSymbolFonts $font
				set chessSymbolFontsMap([string tolower $font]) FigurineSymbolChessBaseEncoding
			}
		}
	}

	# Chess diagram fonts
	foreach font {DiagramTTCrystals DiagramTTFritz DiagramTTHabsburg DiagramTTOldstyle DiagramTTUSCF} {
		if {$font in $fonts} {
			lappend chessDiagramFonts $font
			set chessDiagramFontsMap([string tolower $font]) DiagramChessBaseEncoding
		} else {
			set font [string tolower $font]
			if {$font in $fonts} {
				lappend chessDiagramFonts $font
				set chessDiagramFontsMap([string tolower $font]) DiagramChessBaseEncoding
			}
		}
	}
}

proc AddFigurineFont {font} {
	lappend [namespace current]::chessFigurineFonts $font
	set [namespace current]::chessFigurineFontsMap([string tolower $font]) {}
	::dialog::::choosefont::addFontFamily $font
}

proc AddSymbolFont {font} {
	lappend [namespace current]::chessSymbolFonts $font
	set enc ScidbSymbol
	append enc [lindex [split $font " "] 2] Encoding
	if {![info exists [namespace current]::$enc]} { set enc SymbolDefaultEncoding }
	set [namespace current]::chessSymbolFontsMap([string tolower $font]) $enc
	::dialog::::choosefont::addFontFamily $font
}

proc AddDiagramFont {font} {
	lappend [namespace current]::chessDiagramFonts $font
	set enc Diagram
	append enc [lindex [split $font " "] 2] Encoding
	if {![info exists [namespace current]::$enc]} { set enc DiagramMarroquinEncoding }
	set [namespace current]::chessDiagramFontsMap([string tolower $font]) $enc
	::dialog::::choosefont::addFontFamily $font
}

proc FindOle!Fonts {} {
	variable chessFigurineFonts
	variable chessSymbolFonts

	set reset 0

	if {[lsearch -exact -nocase $chessFigurineFonts {Scidb Chess Ole!}] == -1} {
		array set opts [font actual {{Scidb Chess Ole!} -12}]
		if {[string compare -nocase $opts(-family) {Scidb Chess Ole!}] == 0} {
			AddFigurineFont $opts(-family)
			set reset 1
		}
	}

	if {[lsearch -exact -nocase $chessSymbolFonts {Scidb Symbol Ole!}] == -1} {
		array set opts [font actual {{Scidb Symbol Ole!} -12}]
		if {[string compare -nocase $opts(-family) {Scidb Symbol Ole!}] == 0} {
			AddSymbolFont $opts(-family)
			set reset 1
		}
	}

	if {$reset} { ::dialog::choosefont::resetFonts }
}

set chessFigurineFonts {}
foreach font [::dialog::choosefont::fontFamilies] {
	if {[string match -nocase {Scidb Chess *} $font]} { AddFigurineFont $font }
}

set chessSymbolFonts {}
foreach font [::dialog::choosefont::fontFamilies] {
	if {[string match -nocase {Scidb Symbol *} $font]} { AddSymbolFont $font }
}

set chessDiagramFonts {}
foreach font [::dialog::choosefont::fontFamilies] {
	if {[string match -nocase {Scidb Diagram *} $font]} { AddDiagramFont $font }
}

FindOle!Fonts ;# Tk has problems with the Ole! fonts
SetupChessBaseFonts

# -------------------------
# some good figurine fonts:
# -------------------------
# {Scidb Chess Alpha} bold
# {Scidb Chess Cases} bold
# {Scidb Chess Good Companion} bold
# {Scidb Chess Informant} bold
# {Scidb Chess Merida} bold
# {Scidb Chess Motif} bold
# {Scidb Chess Standard} bold
# {Scidb Chess Traveller} normal
# ----------------------------------

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

variable UseSymbols		0
variable UseFigurines	0
variable ContextList		{text}

array set DefaultOptions {
	figurine:use				1
	figurine:lang				{}

	symbol:family				{Scidb Symbol Traveller}
	symbol:weight				normal

	diagram:family				{Scidb Diagram Merida}

	figurine:family:normal	{Scidb Chess Traveller}
	figurine:weight:normal	normal

	figurine:family:bold		{Scidb Chess Standard}
	figurine:weight:bold		bold
}

array set Options [array get DefaultOptions]


proc setupChessFonts {} {
	variable chessSymbolFontsMap
	variable chessFigurineFontsMap
	variable symbol
	variable symbolEncoding
	variable UseSymbols
	variable UseFigurines
	variable Options

	set UseSymbols [expr {[info exists chessSymbolFontsMap([string tolower $Options(symbol:family)])]}]
	set UseFigurines 0

	set fonts [::dialog::choosefont::fontFamilies]

	foreach attr {figurine:family:normal figurine:family:bold symbol:family diagram:family} {
		if {$Options($attr) ni $fonts} { set Options($attr) [string tolower $Options($attr)] }
	}

	if {	[info exists chessFigurineFontsMap([string tolower $Options(figurine:family:normal)])]
		&&	[info exists chessFigurineFontsMap([string tolower $Options(figurine:family:bold)])]} {
		set UseFigurines 1
	}

	registerTextFonts text {normal bold}
	registerSymbolFonts text

	if {$UseSymbols} {
		set symbolEncoding $chessSymbolFontsMap([string tolower $Options(symbol:family)])
	}

	if {![truetypeSupport?]} {
		set UseFigurines 0
		set UseSymbols 0
	}

	UseFigurines [expr {$UseFigurines && $Options(figurine:use)}]
}


proc truetypeSupport? {} {
	if {[::tk windowingsystem] ne "x11"} { return 1 }
	set truetypeSupport 0
	catch { if {[::tk::pkgconfig get fontsystem] eq "xft"} { set truetypeSupport 1 } }
	return $truetypeSupport
}


proc useLanguage {lang} {
	variable ::figurines::langSet
	variable GraphicMap

	if {$lang eq "graphic"} {
		useFigurines yes
	} else {
		set GraphicMap {}
		set graphic $langSet(graphic)
		set figurine $langSet($lang)

		for {set i 0} {$i < 5} {incr i} {
			lappend GraphicMap [lindex $graphic $i] [lindex $figurine $i]
		}

		lappend GraphicMap [lindex $graphic $i] ""
	}
}


proc useFigurines {flag {force 0}} {
	variable Options

	if {!$force && $Options(figurine:use) == $flag} { return }
	set Options(figurine:use) $flag
	UseFigurines $flag
}


proc useFigurines? {} {
	variable UseFigurines
	variable Options

	return [expr {$UseFigurines && $Options(figurine:use)}]
}


proc haveFigurines? {} {
	return [set [namespace current]::UseFigurines]
}


proc haveSymbols? {} {
	return [set [namespace current]::UseSymbols]
}


proc currentFontSize {context} {
	variable Options
	return [expr {-$Options($context:size)}]
}


proc registerTextFonts {context {styles {normal}}} {
	variable Options
	variable figurine
	variable symbol
	variable text

	set style [lindex $styles 0]
	if {[info exists text($context:$style)]} { return }

	if {![info exists Options($context:size)]} {
		array set fopts [font actual TkTextFont]
		set family $fopts(-family)
		set size $fopts(-size)
		set Options($context:family) $family
		set Options($context:slant) [Slant $style]
		set Options($context:size) [expr {abs($size)}]
	} else {
		set family $Options($context:family)
		set slant $Options($context:slant)
		set size [expr {-($Options($context:size))}]
	}

	foreach style $styles {
		set text($context:$style) [font create ::font::text($context:$style) \
			-family $family -weight [Weight $style] -slant [Slant $style] -size $size]
	}
}


proc unregisterTextFonts {context} {
	variable text

	set styles {}
	foreach style [array names text $context:*] {
		lappend styles [lindex [split $style :] 1]
		DeleteFont text($style)
	}
	array unset text $context:*
	return $styles
}


proc resetTextFonts {context} {
	variable Options
	variable text

	set styles [unregisterTextFonts $context]
	array unset Options $context:*
	registerTextFonts $context $styles
}


proc registerSymbolFonts {context} {
	variable UseSymbols
	variable Options
	variable symbol
	variable text

	if {[info exists symbol($context:normal)]} { return }
	set size [expr {-($Options($context:size))}]

	if {$UseSymbols} {
		set ascent [font metrics $text($context:normal) -ascent]
		set symbol($context:normal) [font create ::font::symbol($context:normal) \
			-family $Options(symbol:family) \
			-weight $Options(symbol:weight) \
			-size $size \
		]
		while {[font metrics $symbol($context:normal) -ascent] > $ascent} {
			incr size
			font delete $symbol($context:normal)
			set symbol($context:normal) [font create ::font::symbol($context:normal) \
				-family $Options(symbol:family) \
				-weight $Options(symbol:weight) \
				-size $size \
			]
		}
		set symbol($context:bold) [font create ::font::symbol($context:bold) \
			-family $Options(symbol:family) \
			-weight bold \
			-size $size \
		]
	} else {
		set symbol($context:normal) $text($context:normal)
		set symbol($context:bold) $text($context:bold)
	}
}


proc unregisterSymbolFonts {context} {
	variable symbol

	foreach style [array names symbol $context:*] {
		if {![string match text(* $symbol($style)] && ![string match Tk* $symbol($style)]} {
			DeleteFont symbol($style)
		}
	}

	array unset symbol $context:*
}


proc resetSymbolFonts {context} {
	variable Options
	variable DefaultOptions

	unregisterSymbolFonts $context
	set Options(symbol:family) $DefaultOptions(symbol:family)
	set Options(symbol:weight) $DefaultOptions(symbol:weight)
	registerSymbolFonts $context
}


proc registerFigurineFonts {context} {
	variable UseFigurines
	variable Options
	variable figurine
	variable text

	if {[info exists figurine($context:normal)]} { return }
	set size [expr {-$Options($context:size)}]

	if {$UseFigurines} {
		set ascent [font metrics $text($context:normal) -ascent]
		set figurine($context:normal) [font create ::font::figurine($context:normal) \
			-family $Options(figurine:family:normal) \
			-weight $Options(figurine:weight:normal) \
			-size $size \
		]
		while {[font metrics $figurine($context:normal) -ascent] > $ascent} {
			incr size
			font delete $figurine($context:normal)
			set figurine($context:normal) [font create ::font::figurine($context:normal) \
				-family $Options(figurine:family:normal) \
				-weight $Options(figurine:weight:normal) \
				-size $size \
			]
		}
		set figurine($context:bold) [font create ::font::figurine($context:bold) \
			-family $Options(figurine:family:bold) \
			-weight $Options(figurine:weight:bold) \
			-size $size \
		]
		if {$context eq "text"} {
			set figurine(small:normal) [font create ::font::figurine(small:normal) \
				-family $Options(figurine:family:normal) \
				-weight $Options(figurine:weight:normal) \
				-size [font configure TkTooltipFont -size] \
			]
		}
	} else {
		set figurine($context:normal) $text($context:normal)
		set figurine($context:bold) $text($context:bold)
		if {$context eq "text"} {
			set figurine(small:normal) TkTooltipFont
		}
	}
}


proc unregisterFigurineFonts {context} {
	variable figurine

	foreach style [array names figurine $context:*] {
		if {![string match text(* $figurine($style)] && ![string match Tk* $figurine($style)]} {
			DeleteFont figurine($style)
		}
	}
	if {$context eq "text"} {
		DeleteFont figurine(small:normal)
	}
	array unset figurine $context:*
}


proc resetFigurineFonts {context} {
	variable Options
	variable DefaultOptions

	unregisterFigurineFonts $context
	set Options(figurine:family:normal) $DefaultOptions(figurine:family:normal)
	set Options(figurine:family:bold) $DefaultOptions(figurine:family:bold)
	set Options(figurine:weight:normal) $DefaultOptions(figurine:weight:normal)
	set Options(figurine:weight:bold) $DefaultOptions(figurine:weight:bold)
	registerFigurineFonts $context
}


proc resetFonts {context} {
	resetTextFonts $context
	if {[info exists figurine($context:normal)]} { resetFigurineFonts $context }
	if {[info exists symbol($context:normal)]} { resetSymbolFonts $context }
}


proc increaseSize {context} {
	changeSize $context +1
}


proc decreaseSize {context} {
	changeSize $context -1
}


proc changeSize {context incr} {
	variable Options
	variable figurine
	variable symbol

	set size [expr {$Options($context:size) + $incr}]
	if {8 > $size || $size > 20} { return 0 }

	set Options($context:size) $size

	set styles [unregisterTextFonts $context]
	registerTextFonts $context $styles

	if {[info exists figurine($context:normal)]} {
		unregisterFigurineFonts $context
		registerFigurineFonts $context
	}
	if {[info exists symbol($context:normal)]} {
		unregisterSymbolFonts $context
		registerSymbolFonts $context
	}

	return 1
}


proc copyFonts {fromContext toContext} {
	variable Options
	variable figurine
	variable symbol
	variable text

	foreach attr [array names Options $fromContext:*] {
		lassign [split $attr :] pref suff
		set Options($toContext:$suff) $Options($attr)
	}

	set styles {}
	foreach style [array names text $fromContext:*] {
		lappend styles [lindex [split $style :] 1]
	}
	registerTextFonts $toContext $styles

	if {[info exists figurine($fromContext:normal)]} {
		registerFigurineFonts $toContext
	}

	if {[info exists symbol($fromContext:normal)]} {
		registerSymbolFonts $toContext
	}
}


proc deleteFonts {context} {
	variable Options

	unregisterTextFonts $context
	unregisterFigurineFonts $context
	unregisterSymbolFonts $context
	array unset Options $context:*
}


proc translate {move} {
	variable UseFigurines
	variable Options

	if {$UseFigurines && $Options(figurine:use)} { return $move }

	variable GraphicMap
	return [string map $GraphicMap $move]
}


proc splitMoves {text {tag figurine}} {
	variable UseFigurines
	variable Options

	if {$UseFigurines && $Options(figurine:use)} {
		variable UnicodeMap
		variable figurineEncoding

		set moves [split [string map $UnicodeMap $text] &]
		set result {}
		if {$tag eq "figurineb"} {
			set encoding $figurineEncoding(bold)
		} else {
			set encoding $figurineEncoding(normal)
		}

		foreach m $moves {
			if {[string index $m 0] == "*"} {
				lappend result [string range $m 1 end] $tag
			} else {
				if {[llength $encoding]} {
					set m [string map $encoding $m]
				}
#				if we like to use Oh's, not zeroes, uncomment this:
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
	variable UseSymbols

	if {$UseSymbols} {
		variable symbolEncoding
		upvar 0 [namespace current]::$symbolEncoding enc
		if {[info exists enc($nag)]} { return $enc($nag) }
	}

	return [mapNagToUtfSymbol $nag]
}


proc mapNagToUtfSymbol {nag} {
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
			set sym [mapNagToUtfSymbol $value]
			if {$value eq $sym} {
				lappend result $value $nag {}
			} else {
				lappend result $value $sym {}
			}
		}
	}

	return $result
}


proc makeBoldFont {font} {
	set family [font configure $font -family]
	set size [font configure $font -size]
	return [list $family $size bold]
}


proc getFontFamilyName {font} {
	array set opts [font actual [list $font]]
	return $opts(-family)
}


proc addChangeFontSizeBindings {context w {cmd {}}} {
	bind $w <Control-plus>			[namespace code [list ChangeFontSize $context $cmd +1]]
	bind $w <Control-KP_Add>		[namespace code [list ChangeFontSize $context $cmd +1]]
	bind $w <Control-minus>			[namespace code [list ChangeFontSize $context $cmd -1]]
	bind $w <Control-KP_Subtract>	[namespace code [list ChangeFontSize $context $cmd -1]]
}


proc addChangeFontSizeToMenu {context m {cmd {}} {stateIncr normal} {stateDecr normal}} {
	if {$context eq "__HTML__"} {
		set incrCmd [namespace code [list {*}$cmd +1]]
		set decrCmd [namespace code [list {*}$cmd -1]]
	} else {
		set incrCmd [namespace code [list ChangeFontSize $context $cmd +1]]
		set decrCmd [namespace code [list ChangeFontSize $context $cmd -1]]
	}
	$m add command \
		-command $incrCmd \
		-label " $mc::IncreaseFontSize" \
		-image $::icon::16x16::font(incr) \
		-compound left \
		-accel "$::mc::Key(Ctrl) +" \
		-state $stateIncr \
		;
	$m add command \
		-command $decrCmd \
		-label " $mc::DecreaseFontSize" \
		-image $::icon::16x16::font(decr) \
		-compound left \
		-accel "$::mc::Key(Ctrl) \u2212" \
		-state $stateDecr \
		;
}


proc ChangeFontSize {context cmd incr} {
	if {[changeSize $context $incr]} {
		if {[llength $cmd]} { {*}$cmd }
	}
}

namespace export getFontFamilyName

namespace eval html {

set DefaultFixedFamilies {
	{Arial Monospaced} Arial {Nimbus Mono L} {DejaVu Sans Mono } {Bitstream Vera Sans Mono} TkFixedFont {Lucida Typewriter}
}
set DefaultTextFamilies {
	Arial {Nimbus Sans L} {DejaVu Sans} {Bitstream Vera Sans} TkTextFont {Helvetica Neue} {Helvetica Neue LT Std} Verdana {Lucida Grande} Lucida
} 
variable DefaultFonts {}


namespace import [namespace parent]::getFontFamilyName

proc setupFonts {context {font ""}} {
	variable [namespace parent]::Options

	if {![info exists Options($context:html:family)]} {
		set Options($context:html:family) ""
		set Options($context:html:user) {"" ""}
		set Options($context:html:size) 11
	}

	set defaultFonts [defaultFonts]

	if {[string length $font]} {
		if {$font in $defaultFonts} {
			set Options($context:html:family) $font
		} else {
			set Options($context:html:family) ""
			lset Options($context:html:user) 0 $font
		}
	}

	if {[lindex $Options($context:html:user) 0] in $defaultFonts} {
		set Options($context:html:family) [lindex $Options($context:html:user) 0]
		lset Options($context:html:user) 0 ""
	} elseif {	[string length [lindex $Options($context:html:user) 0]] == 0
				&& $Options($context:html:family) ni $defaultFonts} {
		set Options($context:html:family) [lindex $defaultFonts 0]
	}
}


proc setupFixedFont {context {font ""}} {
	variable [namespace parent]::Options
	lset Options($context:html:user) 1 $font
}


proc setupFontSize {context size} {
	variable [namespace parent]::Options
	set Options($context:html:size) $size
}


proc saveFonts {context} {
	variable [namespace parent]::Options
	variable HtmlSave_

	foreach attr [array names Options $context:html:*] {
		set HtmlSave_($attr) $Options($attr)
	}
}


proc restoreFonts {context} {
	variable [namespace parent]::Options
	variable HtmlSave_

	array set Options [array get HtmlSave_]
}


proc textFont {context} {
	variable [namespace parent]::Options

	if {[string length $Options($context:html:family)]} {
		return $Options($context:html:family)
	}
	return [lindex $Options($context:html:user) 0]
}


proc fixedFont {context} {
	variable [namespace parent]::Options

	if {[string length $Options($context:html:family)]} {
		return [lindex [lookupFixedFonts $Options($context:html:family)] 0]
	}
	return [lindex $Options($context:html:user) 1]
}


proc userTextFont {context} {
	variable [namespace parent]::Options
	return [lindex $Options($context:html:user) 0]
}


proc userFixedFont {context} {
	variable [namespace parent]::Options
	return [lindex $Options($context:html:user) 1]
}


proc fontSize {context} {
	variable [namespace parent]::Options
	return $Options($context:html:size)
}


proc defaultFonts {} {
	variable DefaultFonts

	if {[string length $DefaultFonts] == 0} {
		set families [::dialog::choosefont::fontFamilies no]
		if {"arial" in $families} {
			lappend DefaultFonts "Arial"
		} elseif {"nimbus sans l" in $families && "nimbus mono l" in $families} {
			lappend DefaultFonts "Nimbus Sans L"
		}
		if {"abel" in $families && "abell cond bold" in $families} {
			lappend DefaultFonts "Abel"
		}
		set fam [getFontFamilyName TkTextFont]
		if {$fam ni $DefaultFonts} {
			lappend DefaultFonts $fam
		}
		if {	"DejaVu Sans" ni $DefaultFonts
			&& "DejaVu Sans" in $families
			&& "DejaVu Sans Mono" in $families} {
			lappend DefaultFonts "DejaVu Sans"
		}
		if {	"DejaVu Sans" ni $DefaultFonts
			&& "Bitstream Vera Sans" ni $DefaultFonts
			&& "bitstream vera sans" in $families
			&& "bitstream vera sans mono" in $families} {
			lappend DefaultFonts "Bitstream Vera Sans"
		}
	}

	return $DefaultFonts
}


proc defaultTextFonts {context} {
	variable [namespace parent]::Options

	set fonts {}

	if {	[llength $Options($context:html:family)] == 0
		&& [string length [lindex $Options($context:html:user) 0]]} {
		lappend fonts [lindex $Options($context:html:user) 0]
	} else {
		lappend fonts $Options($context:html:family)
	}

	if {[llength $fonts]} {
		if {[lindex $fonts 0] eq "Abel"} {
			lappend fonts {Abell Cond Bold}
		}
	}

	foreach fam [textFonts] {
		if {[string match Tk* $fam]} { set fam [getFontFamilyName $fam] }
		if {$fam ni $fonts} { lappend fonts $fam }
	}

	return $fonts
}


proc defaultFixedFonts {context} {
	variable [namespace parent]::Options

	if {	[llength $Options($context:html:family)] == 0
		&& [string length [lindex $Options($context:html:user) 1]]} {
		set fonts [list [lindex $Options($context:html:user) 1]]
	} else {
		set fonts [lookupFixedFonts $Options($context:html:family)]
	}

	foreach fam [fixedFonts] {
		if {[string match Tk* $fam]} { set fam [getFontFamilyName $fam] }
		if {$fam ni $fonts} { lappend fonts $fam }
	}

	return $fonts
}


proc lookupFixedFonts {textfont} {
	switch $textfont {
		"Arial"						{ lappend fonts {Arial Monospaced} Arial }
		"Nimbus Sans L"			{ lappend fonts {Nimbus Mono L} }
		"Abel"						{ lappend fonts Fonotone {Ubuntu Mono} \
												{Courier New} {Nimbus Mono L} {Arial Monospaced} Arial }
		"DejaVu Sans"				{ lappend fonts {DejaVu Sans Mono} }
		"Bitstream Vera Sans"	{ lappend fonts {Bitstream Vera Sans Mono} }
		default						{ lappend fonts [getFontFamilyName TkFixedFont] }
	}

	return $fonts
}


proc fixedFonts {} {
	variable DefaultFixedFamilies
	variable MonoFamilies_

	if {![info exists MonoFamilies_]} {
		set MonoFamilies_ {}
		foreach fam $DefaultFixedFamilies {
			set f [getFontFamilyName $fam]
			if {($f eq $fam || [string match Tk* $fam]) && $f ni $MonoFamilies_} {
				lappend MonoFamilies_ $f
			}
		}
		foreach fam {Monospace Fixed} {
			set fam [getFontFamilyName $fam]
			if {$fam ni $MonoFamilies_} { lappend MonoFamilies_ $fam }
		}
	}

	return $MonoFamilies_
}


proc textFonts {} {
	variable DefaultTextFamilies
	variable TextFamilies_

	if {![info exists TextFamilies_]} {
		set TextFamilies_ {}
		foreach fam $DefaultTextFamilies {
			set f [getFontFamilyName $fam]
			if {($f eq $fam || [string match Tk* $fam]) && $f ni $TextFamilies_} {
				lappend TextFamilies_ $f
			}
			foreach fam {Sans-Serif {Sans Serif} Helvetica} {
				set fam [getFontFamilyName $fam]
				if {$fam ni $TextFamilies_} { lappend TextFamilies_ $fam }
			}
		}
	}

	return $TextFamilies_
}


proc addChangeFontSizeBindings {context w {cmd {}}} {
	bind $w <Control-plus>			[namespace code [list ChangeFontSize $context $cmd +1]]
	bind $w <Control-KP_Add>		[namespace code [list ChangeFontSize $context $cmd +1]]
	bind $w <Control-minus>			[namespace code [list ChangeFontSize $context $cmd -1]]
	bind $w <Control-KP_Subtract>	[namespace code [list ChangeFontSize $context $cmd -1]]
}


proc addChangeFontSizeToMenu {context m cmd {min 1} {max 64}} {
	set cmd [list [namespace current]::ChangeFontSize $context $cmd]
	set size [fontSize $context]
	set stateIncr [expr {$size < $max ? "normal" : "disabled"}]
	set stateDecr [expr {$size > $min ? "normal" : "disabled"}]
	[namespace parent]::addChangeFontSizeToMenu __HTML__ $m $cmd $stateIncr $stateDecr
}


proc addChangeFontToMenu {context m applycmd {textFontOnly no}} {
	set menu $m
	set defaultFonts [defaultFonts]
	set userFont [userTextFont $context]
	if {[llength $defaultFonts] > 0 || [string length $userFont] > 0} {
		variable Family_
		set Family_ [textFont $context]
		set menu $m.fonts
		$m add cascade \
			-menu [menu $menu] \
			-label " [set [namespace parent]::mc::DefaultFont]" \
			-compound left \
			-image $::icon::16x16::fonts \
			;
		foreach fam $defaultFonts {
			$menu add radiobutton \
				-compound left \
				-label $fam \
				-variable [namespace current]::Family_ \
				-value $fam \
				-command [namespace code [list SetFont $context $applycmd $fam]] \
				;
			::theme::configureRadioEntry $menu
		}
		if {[string length $userFont] > 0} {
			$menu add radiobutton \
				-compound left \
				-label $userFont \
				-variable [namespace current]::Family_ \
				-value $userFont \
				-command [namespace code [list SetFont $context $applycmd $userFont]] \
				;
			::theme::configureRadioEntry $menu
		}
		$menu add separator
		set options {}
		set space ""
	} else {
		set options -compound left -image $::icon::16x16::fonts
		set space " "
	}
	if {$userFont ne [textFont $context]} { set textFontOnly 1 }
	if {$textFontOnly} {
		set dlg [winfo toplevel $m]
		$menu add command \
			-label "$space$::dialog::choosefont::mc::FontSelection..." \
			-command [namespace code [list SelectFont $context $dlg 0 $applycmd]] \
			{*}$options \
			;
	} else {
		$menu add cascade \
			-menu [menu $menu.sub] \
			-label "$space$::dialog::choosefont::mc::FontSelection..." \
			{*}$options \
			;
		set dlg [winfo toplevel $m]
		$menu.sub add command \
			-label $::mc::Normal \
			-command [namespace code [list SelectFont $context $dlg 0 $applycmd]] \
			;
		$menu.sub add command \
			-label $::mc::Monospaced \
			-command [namespace code [list SelectFont $context $dlg 1 $applycmd]] \
			;
	}
}


proc ChangeFontSize {context cmd incr} {
	set size [expr {[::font::html::fontSize $context] + $incr}]
	if {[llength $cmd]} { set size [{*}$cmd $size] }
	setupFontSize $context $size
}


proc SetFont {context cmd font} {
	::font::html::setupFonts $context $font
	{*}$cmd
}


proc SelectFont {context parent monospaced applycmd} {
	saveFonts $context
	catch { font delete [namespace current]::Font_ }
	if {$monospaced} {
		set font [userFixedFont $context]
		if {[string length $font] == 0} {
			set font [getFontFamilyName TkTextFont]
		}
	} else {
		set font [userTextFont $context]
		if {[string length $font] == 0} {
			set font [getFontFamilyName TkFixedFont]
		}
	}
	font create [namespace current]::Font_ \
		-family $font \
		-size [fontSize $context] \
		;
	::dialog::choosefont [namespace current]::Font_ \
		-parent $parent \
		-monospaced $monospaced \
		-fixedsize $monospaced \
		-sizelist {8 9 10 11 12 13 14} \
		-usestyle no \
		-applycmd [namespace code [list ApplyFont $context $monospaced $applycmd]] \
		;
}


proc ApplyFont {context monospaced applycmd font} {
	if {[llength $font] == 0} {
		restoreFonts $context
	} else {
		set fam [font configure [namespace current]::Font_ -family]
		if {$monospaced} {
			setupFixedFont $context $fam
		} else {
			setupFonts $context $fam
		}
		setupFontSize $context [expr {-[font configure [namespace current]::Font_ -size]}]
	}
	{*}$applycmd
}

} ;# namespace html


if {$tcl_platform(platform) ne "windows"} {

	proc installChessBaseFonts {parent {windowsFontDirs {/c/Windows/Fonts /c/WINDOWS/Fonts}}} {
		variable _Count

		set fonts [::dialog::choosefont::fontFamilies]
		set windowsFontDir [lindex $windowsFontDirs 0]

		if {{FigurineCB AriesSP} in $fonts} {
			set msg $mc::ChessBaseFontsAlreadyInstalled
			set reply [::dialog::question -parent $parent -message $msg]
			if {$reply eq "no"} { return }
		}

		foreach dir $windowsFontDirs {
			if {[file isdirectory $dir]} {
				set windowsFontDir $dir
				break
			}
		}

		if {![file isdirectory $windowsFontDir]} {
			set result [::dialog::chooseDir \
				-parent $parent \
				-geometry last \
				-title $mc::ChooseMountPoint \
				-initialdir [::fsbox::fileSeparator] \
				-actions {} \
			]
			lassign $result windowsFontDir
			if {[string length $windowsFontDir] == 0} { return }
			if {	![string match */Windows/Fonts $windowsFontDir]
				&& ![string match */WINDOWS/Fonts $windowsFontDir]} {
				append windowsFontDir /Windows/Fonts
			}
			if {![file isdirectory $windowsFontDir]} {
				set msg [format $::fsbox::mc::DirectoryDoesNotExist $windowsFontDir]
				::dialog::error -parent $parent -message $msg
				return 0
			}
		}

		if {$::tcl_platform(os) eq "Darwin"} {
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

		set fonts {	DiaTTCry DiaTTFri DiaTTHab DiaTTOld DiaTTUSA Diablindall
						SpArFgBI SpArFgBd SpArFgIt SpArFgRg SpLtFgBI SpLtFgBd
						SpLtFgIt SpLtFgRg SpTmFgBI SpTmFgBd SpTmFgIt SpTmFgRg}

		set _Count 0
		::dialog::progressBar $parent.progress \
			-title $::dialog::choosefont::mc::Wait \
			-message "$mc::CopyingChessBaseFonts..." \
			-maximum [llength $fonts] \
			-variable [namespace current]::_Count \
			-command [namespace code [list CopyChessBaseFonts $parent $windowsFontDir $fontDir $fonts]] \
			-close no \
			;

		return $_Count
	}

	proc CopyChessBaseFonts {parent srcDir dstDir fonts} {
		variable _Count

		foreach font $fonts {
			set file [file join $srcDir $font.ttf]
			if {[file readable $file]} {
				incr _Count
				update idletasks
				set msg [format $mc::CopyFile [file tail $file]]
				::dialog::progressbar::setInformation $parent.progress ${msg}...
				update idletasks
				catch { file copy -force $file $dstDir }
			}
		}

		if {$_Count == 0} {
			destroy $parent.progress
			::dialog::info -parent $parent -message [format $mc::NoChessBaseFontFound $srcDir]
		} else {
			if {$::tcl_platform(platform) eq "unix"} {
				::dialog::progressbar::setInformation $parent.progress ${mc::UpdateFontCache}...
				update idletasks
				catch { exec fc-cache -f $dstDir }
			}

			::dialog::choosefont::resetFonts
			set fonts [::dialog::choosefont::fontFamilies]

			if {{FigurineCB AriesSP} in $fonts} {
				SetupChessBaseFonts
				destroy $parent.progress
				::dialog::info -parent $parent -message $mc::ChessBaseFontsInstalled
			} else {
				destroy $parent.progress
				::dialog::error -parent $parent -message $mc::ChessBaseFontsInstallationFailed
			}
		}
	}

}


proc UseFigurines {flag} {
	variable Options
	variable UseFigurines
	variable figurineEncoding
	variable chessFigurineFontsMap

	unregisterFigurineFonts text
	registerFigurineFonts text

	if {$UseFigurines} {
		set figurineEncoding(normal) \
			$chessFigurineFontsMap([string tolower $Options(figurine:family:normal)])
		set figurineEncoding(bold) \
			$chessFigurineFontsMap([string tolower $Options(figurine:family:bold)])
	}
}


proc DeleteFont {fontvar} {
	set fontvar [namespace current]::$fontvar
	if {[info exists $fontvar] && ![string match Tk* [set $fontvar]]} {
		catch { font delete [set $fontvar] }
	}
}


proc Weight {style} {
	if {[string match bold* $style]} { return bold }
	return normal
}


proc Slant {style} {
	if {[string match *italic $style]} { return italic }
	return roman
}


proc WriteOptions {chan} {
	::options::writeItem $chan [namespace current]::Options
}

::options::hookWriter [namespace current]::WriteOptions

} ;# namespace font

# vi:set ts=3 sw=3:
