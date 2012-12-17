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

# Font by Armando H. Marroquin
# <http://www.enpassant.dk/chess/fonteng.htm>

lappend board_PieceSet { Motif truetype {stroke 5} {contour 80} {sampling 100} {overstroke 10} }

set truetype_Motif(wk) {
<g
  scidb:bbox="214,203,1834,1878">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M548 342h952v-139h-952v139zM1075 1571h-103v102h-49q-52 0 -52 52v0q0 52 52 52h49v50q0 51 52 51v0q51 0 51 -51v-50h52q51 0 51 -52v0q0 -52 -51 -52h-52v-102zM1695 1014q20 56 20 104q0 113 -92.5 193.5t-221.5 80.5q-131 0 -223 -80.5t-92 -193.5q0 -114 92 -193.5 t221 -79.5q58 0 58 -51v0q0 -52 -58 -52q-120 0 -219 52t-156 137q-58 -85 -157.5 -137t-217.5 -52q-58 0 -58 52v0q0 51 58 51q128 0 220.5 79.5t92.5 193.5q0 113 -93 193.5t-222 80.5q-131 0 -223 -80.5t-92 -193.5q0 -55 25 -105l258 -500h818zM1024 1305q57 85 160 138 q-72 24 -160 24q-85 0 -158 -24q99 -52 158 -138zM1809 988l-309 -578h-952l-309 578q-25 64 -25 130q0 156 126.5 266.5t306.5 110.5q29 0 52 -4q150 79 325 79q174 0 325 -79q22 4 52 4q178 0 305.5 -110.5t127.5 -266.5q0 -62 -25 -130z" />
</g>}

set truetype_Motif(wq) {
<g
  scidb:bbox="184,203,1858,1603">
  scidb:translate="0,10"
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M564 1034l-186 151l244 -672h803l245 672l-185 -152q-64 -45 -132 -45q-126 0 -186 115l-143 300l-141 -299q-59 -116 -185 -116q-69 0 -134 46zM548 342h952v-139h-952v139zM1021 988q33 0 57.5 -50t24.5 -121q0 -72 -24.5 -121.5t-57.5 -49.5q-34 0 -58 49.5t-24 121.5 q0 71 24 121t58 50zM1268 1131q33 -43 85 -43q25 0 49 11l-24 171zM1497 1176l273 229q54 49 73 36q15 -11 -1 -75l-343 -956h-950l-343 955q-22 64 -4 76t74 -35l276 -232l35 254q3 49 24 55t50 -35l171 -217l156 335q18 37 36 37t37 -39l157 -331l168 215q29 41 51 35 q20 -6 24 -55zM645 1100q29 -12 53 -12q49 0 83 40l-111 142z" />
</g>}

set truetype_Motif(wr) {
<g
  scidb:bbox="409,203,1639,1842">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M988 1119h-33q-34 0 -34 34v0q0 34 34 34h33v71q0 36 36 36v0q35 0 35 -36v-71h34q34 0 34 -34v0q0 -34 -34 -34h-34v-65q0 -35 -35 -35v0q-36 0 -36 35v65zM1024 1467h206v-514l-206 -200l-206 200v514h206zM1024 1399h-135v-427l135 -126l135 126v427h-135zM1436 1841 l135 1q68 0 68 -67v-291q0 -67 -68 -67h-103q-3 -192 41 -349.5t130 -318.5v-339h-615h-615v339q85 161 128.5 318.5t42.5 349.5h-103q-68 0 -68 67v290q0 68 68 68h142h99v-100h203v100h206v-100h203v100zM1433 1742v-104h-818v104h-103v-225h171v-100q3 -196 -41.5 -356.5 t-129.5 -325.5v-222h512h512v222q-86 165 -130 325.5t-41 356.5v100h171v225h-103zM409 342h1230v-139h-1230v139z" />
</g>}

set truetype_Motif(wb) {
<g
  scidb:bbox="334,203,1713,1667">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1024 410h-583q-42 55 -62 100q-45 102 -45 207q0 192 135.5 342.5t344.5 206.5q29 20 29 50q0 28 -28 53q-61 51 -61 116q0 75 79 128.5t191 53.5q111 0 190 -53.5t79 -128.5q0 -66 -60 -116q-28 -25 -28 -53q0 -30 29 -50q208 -56 343.5 -206.5t135.5 -342.5 q0 -105 -45 -207q-20 -45 -61 -100h-583zM1271 1151q-16 6 -20 8q-146 50 -146 162q0 59 52 104q35 23 35 55q0 39 -49.5 66.5t-118.5 27.5q-70 0 -119 -27.5t-49 -66.5q0 -33 35 -55q52 -45 52 -104q0 -112 -147 -162q-158 -56 -258 -176.5t-100 -270.5q0 -99 55 -199h531 h531q54 98 54 199q0 224 -212 372l-238 -335q-40 -58 -96 -17v0q-57 40 -17 96zM409 342h1230v-139h-1230v139z" />
</g>}

set truetype_Motif(wn) {
<g
  scidb:bbox="229,203,1804,1846">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1408 1520q-26 53 -84 53q-18 0 -46 13q-51 24 -89.5 34.5l-89.5 25.5q-83 22 -149 25q-27 14 -39.5 17.5t-20.5 8.5q-21 10 -34 10h-21q8 -47 4.5 -82.5t-50.5 -77.5q-21 12 -40.5 22t-65.5 19q10 -30 11 -52.5t-26 -75.5q-72 -71 -99 -129l-22 -41.5t-21 -65.5 q-13 -35 -71 -93l-55.5 -57t-54.5 -75q-13 -24 -18.5 -35.5t1.5 -32.5q13 -40 24 -49.5t44 -35.5q21 -9 38.5 -33.5t39.5 -24.5q49 0 74 15q39 23 63.5 62t46.5 88q18 24 37.5 42t68.5 1q25 -11 81 -11q84 0 143 57.5t57 132.5l-3 44q0 51 51 51v0q52 0 52 -51l3 -42 q1 -108 -72 -196q17 -89 0.5 -125t-52.5 -89q-41 -60 -104.5 -116t-171.5 -138h891q-1 25 -1 66q0 59 31 109q32 30 32 75q0 7 -2 21q-18 23 -28 52q-13 35 -13 70q0 44 21 91q2 10 2 12q0 25 -14 50q-22 18 -35 42q-44 66 -32 144q-5 27 -21 47q-5 5 -9 8q-43 19 -75 56 q-24 29 -35 62q-9 23 -12 58q-3 4 -6 8.5t-6 9.5q-4 4 -28 26zM1471 1604q12 -13 23.5 -23.5t20.5 -20.5q24 -29 36 -63q-4 -43 23 -75q18 -22 48 -31q21 -16 35 -33q41 -49 48 -117q-13 -49 17 -89q2 -2 2 -4q8 -12 20 -19q40 -56 40 -120q0 -26 -7 -48q-16 -28 -16 -55 q0 -42 30 -72q13 -34 13 -71q0 -78 -50 -134q-13 -25 -13 -50q0 -12 -0.5 -30t1.5 -36v-103h-1134q-4 110 80 180q297 239 292 316q-72 -24 -128 -24.5t-121 16.5q-91 -181 -201 -202q-21 -5 -30 -4.5t-33 0.5q-19 -3 -42 10.5t-44 21.5t-26.5 22t-26.5 35 q-23 21 -45.5 39.5t-32.5 32.5q-5 5 -13 39.5t-8 42.5q2 48 22 80t71 97l81 107.5t49 81.5q12 27 13.5 46.5t5.5 27.5q21 41 108 122q-3 3 9.5 16.5t8.5 51.5q-3 22 -33 71q-9 12 -15 27.5t-35 56.5q82 1 136 -16t90 -41q6 35 -20 66q-25 28 -41 50t-83 57q55 10 184 -4.5 t183 -64.5q120 2 188.5 -19t169.5 -75q91 -2 150 -69zM742 1374q85 0 85 -71q0 -72 -85 -72t-85 72q0 71 85 71zM608 342h1134v-139h-1134v139z" />
</g>}

set truetype_Motif(wp) {
<g
  scidb:bbox="445,203,1602,1563"
  scidb:scale="0.9">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M608 513h835q59 110 59 231q0 157 -92 281t-233 173q-83 11 -90 62q-10 56 75 93q32 16 32 40q0 30 -50.5 52t-120.5 22q-72 0 -122 -22t-50 -52q0 -25 40 -47q68 -39 59 -86q-6 -43 -78 -61q-143 -50 -235 -174t-92 -281q0 -119 63 -231zM548 410q-103 143 -103 334 q0 183 103 328.5t265 209.5q-62 50 -62 110q0 70 81.5 120.5t195.5 50.5t196 -50.5t82 -120.5q0 -64 -68 -112q159 -64 261.5 -209t102.5 -327q0 -192 -102 -334h-952zM548 342h952v-139h-952v139z" />
</g>}

set truetype_Motif(bk) {
<g
  scidb:bbox="214,203,1834,1878">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M548 342h952v-139h-952v139zM1075 1571h-103v102h-49q-52 0 -52 52v0q0 52 52 52h49v50q0 51 52 51v0q51 0 51 -51v-50h52q51 0 51 -52v0q0 -52 -51 -52h-52v-102zM1809 988l-309 -578h-952l-309 578q-25 64 -25 130q0 156 126.5 266.5t306.5 110.5q29 0 52 -4 q150 79 325 79q174 0 325 -79q22 4 52 4q178 0 305.5 -110.5t127.5 -266.5q0 -62 -25 -130zM1232 1352q26 14 61 21q56 9 44 60v1q-13 49 -69 40q-56 -10 -90 -30q-97 -56 -154 -139q-57 82 -153 139q-37 20 -92 30q-57 11 -69 -40v0q-13 -50 45 -61q37 -8 64 -22 q143 -90 143 -233q0 -114 -92.5 -193.5t-220.5 -79.5q-58 0 -58 -51v0q0 -52 58 -52q118 0 218 52t157 137q57 -85 156 -137t219 -52q58 0 58 52v0q0 51 -58 51q-129 0 -221 79.5t-92 193.5q0 147 146 234z" />
</g>}

set truetype_Motif(bq) {
<g
  scidb:bbox="184,203,1858,1603">
  scidb:translate="0,10"
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M548 342h952v-139h-952v139zM1021 988q-34 0 -58 -50t-24 -121q0 -72 24 -121.5t58 -49.5q33 0 57.5 49.5t24.5 121.5q0 71 -24.5 121t-57.5 50zM1261 1106q36 -48 94 -48q24 0 54 12l-27 188zM1497 1176l273 229q54 49 73 36q15 -11 -1 -75l-343 -956h-950l-343 955 q-22 64 -4 76t74 -35l276 -232l35 254q3 49 24 55t50 -35l171 -217l156 335q18 37 36 37t37 -39l157 -331l168 215q29 41 51 35q20 -6 24 -55zM638 1072q33 -14 58 -14q53 0 92 44l-123 156z" />
</g>}

set truetype_Motif(br) {
<g
  scidb:bbox="409,203,1639,1842">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1436 1841l135 1q68 0 68 -67v-291q0 -67 -68 -67h-103q-3 -192 41 -349.5t130 -318.5v-339h-615h-615v339q85 161 128.5 318.5t42.5 349.5h-103q-68 0 -68 67v290q0 68 68 68h142h99v-100h203v100h206v-100h203v100zM988 1119v-65q0 -35 36 -35v0q35 0 35 35v65h34 q34 0 34 34v0q0 34 -34 34h-34v71q0 36 -35 36v0q-36 0 -36 -36v-71h-33q-34 0 -34 -34v0q0 -34 34 -34h33zM1024 1467h-206v-514l206 -200l206 200v514h-206zM1024 1399h135v-427l-135 -126l-135 126v427h135zM409 342h1230v-139h-1230v139z" />
</g>}

set truetype_Motif(bb) {
<g
  scidb:bbox="334,203,1713,1667">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M409 342h1230v-139h-1230v139zM1459 1163q117 -81 185.5 -196.5t68.5 -249.5q0 -105 -45 -207q-20 -45 -61 -100h-583h-583q-42 55 -62 100q-45 102 -45 207q0 192 135.5 342.5t344.5 206.5q29 20 29 50q0 28 -28 53q-61 51 -61 116q0 75 79 128.5t191 53.5 q111 0 190 -53.5t79 -128.5q0 -66 -60 -116q-28 -25 -28 -53q0 -30 29 -50q61 -18 100 -35l-288 -412q-40 -58 17 -97v0q55 -40 96 17z" />
</g>}

set truetype_Motif(bn) {
<g
  scidb:bbox="229,203,1804,1846">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M608 342h1134v-139h-1134v139zM681 1381q-94 0 -94 -78q0 -79 94 -79q93 0 93 79q0 78 -93 78zM1137 975q59 104 58 218l-3 46q0 56 -43 56h-1q-43 0 -43 -56l3 -48q1 -76 -39 -141l-19 -27q-31 -40 0 -79v-1q31 -39 63 1zM1471 1604q12 -13 23.5 -23.5t20.5 -20.5 q24 -29 36 -63q-4 -43 23 -75q18 -22 48 -31q21 -16 35 -33q41 -49 48 -117q-13 -49 17 -89q2 -2 2 -4q8 -12 20 -19q40 -56 40 -120q0 -26 -7 -48q-16 -28 -16 -55q0 -42 30 -72q13 -34 13 -71q0 -78 -50 -134q-13 -25 -13 -50q0 -12 -0.5 -30t1.5 -36v-103h-1134 q-4 110 80 180q297 239 292 316q-72 -24 -128 -24.5t-121 16.5q-91 -181 -201 -202q-21 -5 -30 -4.5t-33 0.5q-19 -3 -42 10.5t-44 21.5t-26.5 22t-26.5 35q-23 21 -45.5 39.5t-32.5 32.5q-5 5 -13 39.5t-8 42.5q2 48 22 80t71 97l81 107.5t49 81.5q12 27 13.5 46.5 t5.5 27.5q21 41 108 122q-3 3 9.5 16.5t8.5 51.5q-3 22 -33 71q-9 12 -15 27.5t-35 56.5q82 1 136 -16t90 -41q6 35 -20 66q-25 28 -41 50t-83 57q55 10 184 -4.5t183 -64.5q120 2 188.5 -19t169.5 -75q91 -2 150 -69z" />
</g>}

set truetype_Motif(bp) {
<g
  scidb:bbox="445,203,1602,1563"
  scidb:scale="0.9">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M548 342h952v-139h-952v139zM548 410q-103 143 -103 334q0 183 103 328.5t265 209.5q-62 50 -62 110q0 70 81.5 120.5t195.5 50.5t196 -50.5t82 -120.5q0 -64 -68 -112q159 -64 261.5 -209t102.5 -327q0 -192 -102 -334h-952z" />
</g>}

set truetype_Motif(wk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M548 342h952v-139h-952v139zM1075 1571h-103v102h-49q-52 0 -52 52v0q0 52 52 52h49v50q0 51 52 51v0q51 0 51 -51v-50h52q51 0 51 -52v0q0 -52 -51 -52h-52v-102zM1809 988l-309 -578h-952l-309 578q-25 64 -25 130q0 156 126.5 266.5t306.5 110.5q29 0 52 -4 q150 79 325 79q174 0 325 -79q22 4 52 4q178 0 305.5 -110.5t127.5 -266.5q0 -62 -25 -130z" />
</g>}

set truetype_Motif(wq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M548 342h952v-139h-952v139zM1497 1176l273 229q54 49 73 36q15 -11 -1 -75l-343 -956h-950l-343 955q-22 64 -4 76t74 -35l276 -232l35 254q3 49 24 55t50 -35l171 -217l156 335q18 37 36 37t37 -39l157 -331l168 215q29 41 51 35q20 -6 24 -55z" />
</g>}

set truetype_Motif(wr,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1436 1841l135 1q68 0 68 -67v-291q0 -67 -68 -67h-103q-3 -192 41 -349.5t130 -318.5v-339h-615h-615v339q85 161 128.5 318.5t42.5 349.5h-103q-68 0 -68 67v290q0 68 68 68h142h99v-100h203v100h206v-100h203v100zM409 342h1230v-139h-1230v139z" />
</g>}

set truetype_Motif(wb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1024 410h-583q-42 55 -62 100q-45 102 -45 207q0 192 135.5 342.5t344.5 206.5q29 20 29 50q0 28 -28 53q-61 51 -61 116q0 75 79 128.5t191 53.5q111 0 190 -53.5t79 -128.5q0 -66 -60 -116q-28 -25 -28 -53q0 -30 29 -50q208 -56 343.5 -206.5t135.5 -342.5 q0 -105 -45 -207q-20 -45 -61 -100h-583zM409 342h1230v-139h-1230v139z" />
</g>}

set truetype_Motif(wn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1471 1604q12 -13 23.5 -23.5t20.5 -20.5q24 -29 36 -63q-4 -43 23 -75q18 -22 48 -31q21 -16 35 -33q41 -49 48 -117q-13 -49 17 -89q2 -2 2 -4q8 -12 20 -19q40 -56 40 -120q0 -26 -7 -48q-16 -28 -16 -55q0 -42 30 -72q13 -34 13 -71q0 -78 -50 -134q-13 -25 -13 -50 q0 -12 -0.5 -30t1.5 -36v-103h-1134q-4 110 80 180q297 239 292 316q-72 -24 -128 -24.5t-121 16.5q-91 -181 -201 -202q-21 -5 -30 -4.5t-33 0.5q-19 -3 -42 10.5t-44 21.5t-26.5 22t-26.5 35q-23 21 -45.5 39.5t-32.5 32.5q-5 5 -13 39.5t-8 42.5q2 48 22 80t71 97 l81 107.5t49 81.5q12 27 13.5 46.5t5.5 27.5q21 41 108 122q-3 3 9.5 16.5t8.5 51.5q-3 22 -33 71q-9 12 -15 27.5t-35 56.5q82 1 136 -16t90 -41q6 35 -20 66q-25 28 -41 50t-83 57q55 10 184 -4.5t183 -64.5q120 2 188.5 -19t169.5 -75q91 -2 150 -69zM608 342h1134v-139 h-1134v139z" />
</g>}

set truetype_Motif(wp,mask) {
<g>
  <path
    scidb:scale="0.9"
    style="fill:white;stroke:none"
    d="M548 342h952v-139h-952v139zM548 410q-103 143 -103 334q0 183 103 328.5t265 209.5q-62 50 -62 110q0 70 81.5 120.5t195.5 50.5t196 -50.5t82 -120.5q0 -64 -68 -112q159 -64 261.5 -209t102.5 -327q0 -192 -102 -334h-952z" />
</g>}

set truetype_Motif(bk,mask) $truetype_Motif(wk,mask)
set truetype_Motif(bq,mask) $truetype_Motif(wq,mask)
set truetype_Motif(br,mask) $truetype_Motif(wr,mask)

set truetype_Motif(bb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M409 342h1230v-139h-1230v139zM1459 1163q117 -81 185.5 -196.5t68.5 -249.5q0 -105 -45 -207q-20 -45 -61 -100h-583h-583q-42 55 -62 100q-45 102 -45 207q0 192 135.5 342.5t344.5 206.5q29 20 29 50q0 28 -28 53q-61 51 -61 116q0 75 79 128.5t191 53.5 q111 0 190 -53.5t79 -128.5q0 -66 -60 -116q-28 -25 -28 -53q0 -30 29 -50q61 -18 100 -35l-288 -412q-40 -58 17 -97v0q55 -40 96 17z" />
</g>}

set truetype_Motif(bn,mask) $truetype_Motif(wn,mask)
set truetype_Motif(bp,mask) $truetype_Motif(wp,mask)

set truetype_Motif(wk,exterior) {
<g>
  <path
    d="M1024 1305q57 85 160 138 q-72 24 -160 24q-85 0 -158 -24q99 -52 158 -138z" />
  <path
    d="M1695 1014q20 56 20 104q0 113 -92.5 193.5t-221.5 80.5q-131 0 -223 -80.5t-92 -193.5q0 -114 92 -193.5 t221 -79.5q58 0 58 -51v0q0 -52 -58 -52q-120 0 -219 52t-156 137q-58 -85 -157.5 -137t-217.5 -52q-58 0 -58 52v0q0 51 58 51q128 0 220.5 79.5t92.5 193.5q0 113 -93 193.5t-222 80.5q-131 0 -223 -80.5t-92 -193.5q0 -55 25 -105l258 -500h818z" />
</g>}

set truetype_Motif(wq,exterior) {
<g>
  <path
    d="M645 1100q29 -12 53 -12q49 0 83 40l-111 142z" />
  <path
    d="M1268 1131q33 -43 85 -43q25 0 49 11l-24 171z" />
  <path
    d="M564 1034l-186 151l244 -672h803l245 672l-185 -152q-64 -45 -132 -45q-126 0 -186 115l-143 300l-141 -299q-59 -116 -185 -116q-69 0 -134 46z" />
</g>}

set truetype_Motif(wr,exterior) {
<g>
  <path
    d="M1433 1742v-104h-818v104h-103v-225h171v-100q3 -196 -41.5 -356.5 t-129.5 -325.5v-222h512h512v222q-86 165 -130 325.5t-41 356.5v100h171v225h-103z" />
  <path
    d="M1024 1399h-135v-427l135 -126l135 126v427h-135z" />
</g>}

set truetype_Motif(wb,exterior) {
<g>
  <path
    d="M1271 1151q-16 6 -20 8q-146 50 -146 162q0 59 52 104q35 23 35 55q0 39 -49.5 66.5t-118.5 27.5q-70 0 -119 -27.5t-49 -66.5q0 -33 35 -55q52 -45 52 -104q0 -112 -147 -162q-158 -56 -258 -176.5t-100 -270.5q0 -99 55 -199h531 h531q54 98 54 199q0 224 -212 372l-238 -335q-40 -58 -96 -17v0q-57 40 -17 96z" />
</g>}

set truetype_Motif(wn,exterior) {
<g>
  <path
    d="M1408 1520q-26 53 -84 53q-18 0 -46 13q-51 24 -89.5 34.5l-89.5 25.5q-83 22 -149 25q-27 14 -39.5 17.5t-20.5 8.5q-21 10 -34 10h-21q8 -47 4.5 -82.5t-50.5 -77.5q-21 12 -40.5 22t-65.5 19q10 -30 11 -52.5t-26 -75.5q-72 -71 -99 -129l-22 -41.5t-21 -65.5 q-13 -35 -71 -93l-55.5 -57t-54.5 -75q-13 -24 -18.5 -35.5t1.5 -32.5q13 -40 24 -49.5t44 -35.5q21 -9 38.5 -33.5t39.5 -24.5q49 0 74 15q39 23 63.5 62t46.5 88q18 24 37.5 42t68.5 1q25 -11 81 -11q84 0 143 57.5t57 132.5l-3 44q0 51 51 51v0q52 0 52 -51l3 -42 q1 -108 -72 -196q17 -89 0.5 -125t-52.5 -89q-41 -60 -104.5 -116t-171.5 -138h891q-1 25 -1 66q0 59 31 109q32 30 32 75q0 7 -2 21q-18 23 -28 52q-13 35 -13 70q0 44 21 91q2 10 2 12q0 25 -14 50q-22 18 -35 42q-44 66 -32 144q-5 27 -21 47q-5 5 -9 8q-43 19 -75 56 q-24 29 -35 62q-9 23 -12 58q-3 4 -6 8.5t-6 9.5q-4 4 -28 26z" />
</g>}

set truetype_Motif(wp,exterior) {
<g>
  <path
    d="M608 513h835q59 110 59 231q0 157 -92 281t-233 173q-83 11 -90 62q-10 56 75 93q32 16 32 40q0 30 -50.5 52t-120.5 22q-72 0 -122 -22t-50 -52q0 -25 40 -47q68 -39 59 -86q-6 -43 -78 -61q-143 -50 -235 -174t-92 -281q0 -119 63 -231z" />
</g>}

set truetype_Motif(bk,exterior) $truetype_Motif(bk,mask)
set truetype_Motif(bq,exterior) $truetype_Motif(bq,mask)
set truetype_Motif(br,exterior) $truetype_Motif(br,mask)
set truetype_Motif(bb,exterior) $truetype_Motif(bb,mask)
set truetype_Motif(bn,exterior) $truetype_Motif(bn,mask)
set truetype_Motif(bp,exterior) $truetype_Motif(bp,mask)

set truetype_Motif(bk,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1232 1352q26 14 61 21q56 9 44 60v1q-13 49 -69 40q-56 -10 -90 -30q-97 -56 -154 -139q-57 82 -153 139q-37 20 -92 30q-57 11 -69 -40v0q-13 -50 45 -61q37 -8 64 -22 q143 -90 143 -233q0 -114 -92.5 -193.5t-220.5 -79.5q-58 0 -58 -51v0q0 -52 58 -52q118 0 218 52t157 137q57 -85 156 -137t219 -52q58 0 58 52v0q0 51 -58 51q-129 0 -221 79.5t-92 193.5q0 147 146 234z" />
</g>}

set truetype_Motif(bq,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M638 1072q33 -14 58 -14q53 0 92 44l-123 156z M1261 1106q36 -48 94 -48q24 0 54 12l-27 188z M1021 988q-34 0 -58 -50t-24 -121q0 -72 24 -121.5t58 -49.5q33 0 57.5 49.5t24.5 121.5q0 71 -24.5 121t-57.5 50z" />
</g>}

set truetype_Motif(br,interior) {
<g>
  <path
    style="fill:white;stroke:none;fill-rule:evenodd"
    d="M1024 1399h135v-427l-135 -126l-135 126v427h135z M1024 1467h-206v-514l206 -200l206 200v514h-206z" />
  <path
    style="fill:white;stroke:none"
    d="M988 1119v-65q0 -35 36 -35v0q35 0 35 35v65h34 q34 0 34 34v0q0 34 -34 34h-34v71q0 36 -35 36v0q-36 0 -36 -36v-71h-33q-34 0 -34 -34v0q0 -34 34 -34h33z" />
</g>}

set truetype_Motif(bb,interior) {}

set truetype_Motif(bn,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1137 975q59 104 58 218l-3 46q0 56 -43 56h-1q-43 0 -43 -56l3 -48q1 -76 -39 -141l-19 -27q-31 -40 0 -79v-1q31 -39 63 1z M681 1381q-94 0 -94 -78q0 -79 94 -79q93 0 93 79q0 78 -93 78z" />
</g>}

set truetype_Motif(bp,interior) {}

set truetype_Motif(sample,24pt,200x34) {
  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
}

# vi:set ts=2 sw=2 et nowrap:
