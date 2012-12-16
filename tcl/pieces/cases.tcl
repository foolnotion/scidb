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

# Font by Matthieu Leschemelle
# <http://www.enpassant.dk/chess/fonteng.htm>

lappend board_PieceSet { Cases truetype {stroke 0} {contour 40} {sampling 100} {overstroke 6} }

set truetype_Cases(wk) {
<g
  scidb:bbox="124,93,882,915"
  scidb:scale="1.05"
  scidb:translate="0,-20">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M503 93q-249 0 -253 84q-4 92 -24 144q-14 35 -53 87q-27 36 -35 54q-14 28 -14 62q0 47 28 85.5t72 54.5q31 11 56 10q65 -1 123 -48l1 -1q0 34 3 57q0 9 8 23q10 25 58 58v30l-51 30v45h46l16 47h38l16 -47h46v-45l-51 -30v-30q45 -30 59 -58q7 -16 7.5 -24.5t1.5 -27 t1 -28.5l1 1q57 47 123 48q44 1 84.5 -24t58.5 -66q13 -28 13 -60q0 -53 -48 -116q-21 -28 -30 -42q-15 -22 -23 -45q-22 -54 -25 -144q-2 -84 -253 -84zM503 514q1 2 8 13q17 24 27 43t15 37q3 27 3 36q0 74 -52 74q-54 0 -54 -74q0 -13 3 -36q10 -35 42 -80q8 -11 8 -13z M837 516q0 56 -38 87q-32 26 -73 26q-55 0 -117 -55q-74 -64 -83 -173q0 -9 46 -19q39 -8 131 -10q16 -1 29 -1h4h18q5 8 14.5 19.5l23.5 28.5q27 39 38 65q7 19 7 32zM503 348q-25 -11 -90 -17q-34 -2 -102 -7l-37 -3q13 -49 17 -105q87 28 212 28q126 0 213 -28 q3 61 16 105l-36 3q-35 2 -103 7q-36 4 -46 5q-26 4 -44 12zM169 516q0 -25 26 -67q13 -20 21 -30l10 -14q13 -14 26 -34h22q52 0 131 8q76 7 76 22q-10 109 -84 173q-61 55 -117 55q-17 0 -37 -7q-43 -11 -63 -55q-11 -23 -11 -51zM503 138q62 0 123 8q51 6 51 16 q0 16 -46 23q-67 9 -127 9q-61 0 -128 -9q-47 -7 -47 -23q0 -14 107 -22q31 -2 67 -2z" />
</g>}

set truetype_Cases(wq) {
<g
  scidb:bbox="69,95,936,903">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M502 376h14q2 0 7 1h7q5 0 45 -2q14 0 62 -4q39 -3 62 -3t23 6q0 1 -1 3v1v1q0 27 -99 42q-66 9 -119 9t-119 -9q-98 -14 -98 -42v-2q-2 -1 -2 -3q0 -6 23 -6q6 0 63 4q67 5 105 5h7q5 -1 7 -1h13zM706 320q-103 13 -203 13q-93 0 -158 -8q-24 -2 -44 -5q15 -12 15 -49 q0 -22 -8 -28q83 14 195 14q113 0 195 -14q-7 6 -7 28q0 37 15 49zM503 213q-72 0 -142 -7q-62 -5 -62 -28q0 -31 204 -31t204 31q0 10 -16 18q-32 12 -109 15q-41 2 -79 2zM503 867q-31 0 -31 -31q0 -32 31 -32q30 0 30 32q0 31 -30 31zM503 903q29 0 49 -20.5t20 -49.5 q0 -9 -10 -32q-11 -28 -12 -34q-5 -20 -5 -54q0 -25 7 -78q5 -41 20 -103q67 142 67 214q0 17 -5 38q-2 11 -2 16q0 29 20.5 49.5t48.5 20.5q29 0 50 -20.5t21 -49.5q0 -33 -22 -51q-27 -17 -33 -61q-2 -19 -2 -49q0 -39 6 -105q81 82 81 136q0 8 -4 28q-2 15 -2 21 q0 28 20.5 49t48.5 21q29 0 50 -21t21 -49q0 -51 -58 -77q-2 -36 -11 -83q-5 -29 -26 -110l-8 -33q0 -18 -40 -59q-53 -54 -53 -84q0 -12 12 -37l18 -37q5 -14 5 -34q0 -3 -1 -8.5t-1 -8.5v-2l1 -1q0 -31 -128 -43q-56 -5 -89 -6q-37 -1 -55 -1q-3 0 -19 1q-19 1 -35 1 q-115 3 -179 20q-38 11 -38 28l1 1v2q0 1 -1 4v5v8q0 28 19 67q14 29 14 41q0 21 -21 47l-61 70q-10 14 -10 26l-28 112q-14 65 -17 114q-58 26 -58 77q0 28 21 49t49 21q29 0 49.5 -21t20.5 -49q0 -5 -2 -21q-4 -20 -4 -28q0 -54 80 -136q7 66 7 105q0 59 -11 82 q-5 10 -11 17q-4 4 -13 12q-13 8 -17 19q-6 8 -6 31q0 29 21 49.5t50 20.5t49.5 -20.5t20.5 -49.5q0 -4 -2 -16q-5 -21 -5 -38q0 -71 67 -214q27 114 27 181q0 49 -19 95q-8 17 -8 25q0 29 21 49.5t49 20.5zM865 749q-12 0 -21 -9t-9 -21q0 -13 9 -22.5t21 -9.5q31 0 31 32 q0 30 -31 30zM701 829q-12 0 -21 -9.5t-9 -21.5q0 -13 9 -22.5t21 -9.5q32 0 32 32q0 31 -32 31zM303 829q-31 0 -31 -31q0 -32 31 -32q30 0 30 32q0 31 -30 31zM139 749q-31 0 -31 -30q0 -32 31 -32q30 0 30 32q0 12 -9 21t-21 9zM503 669q-4 -24 -9 -45l-8 -36 q-12 -49 -28 -78q-3 -6 -10 -15t-9 -16q-2 3 -12 15l-19.5 22.5t-19.5 27.5q-30 54 -57 134q2 -14 2 -36t-7 -93q-1 -11 -5 -33l-9 -56q-67 39 -131 128q12 -63 22 -103q9 -35 10 -38q8 -25 19 -29q104 59 271 59q168 0 271 -59q19 6 41 118l6 30l4 22q-64 -89 -130 -128 l-4 19q-18 104 -18 152q0 25 3 47q-27 -80 -58 -134q-12 -21 -39 -50q-10 -12 -12 -15q-6 11 -19 31q-5 9 -12.5 27.5t-23.5 87.5q-4 21 -9 44z" />
</g>}

set truetype_Cases(wr) {
<g
  scidb:bbox="186,100,814,833">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M357 585v-222h285v222h-285zM210 100l-24 24v86l128 129v250l-110 96v113l36 35h112l22 -21v-32h36v32l21 21h138l21 -21v-32h35v32l22 21h113l36 -35v-113l-110 -96v-250l128 -129v-86l-24 -24h-580zM230 198v-48h540v48h-540zM352 322l-82 -80h460l-82 80h-296z M452 781v-32l-18 -18h-81l-19 18v34h-70l-16 -17v-70l85 -69h334l85 69v70l-16 17h-70v-34l-19 -18h-81l-18 18v32h-96z" />
</g>}

set truetype_Cases(wb) {
<g
  scidb:bbox="96,63,904,930">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M500 431q-63 0 -110 5q-15 1 -26 3q8 -15 8 -31q0 -17 -7 -31q21 7 89 11q21 1 46 1q99 0 135 -12q-8 14 -8 31q0 15 8 31q-58 -8 -135 -8zM500 884q-16 0 -27.5 -11.5t-11.5 -25.5q0 -16 11.5 -26.5t27.5 -10.5q15 0 27 10.5t12 26.5q0 15 -12 26t-27 11zM500 352 q-41 0 -123 -8q-24 -5 -24 -24q0 -16 68 -19q-14 1 79 1q146 0 146 18q0 23 -46 29q-8 1 -63 2q-10 0 -27 1h-10zM499 467q139 0 171 26q22 17 31 87q-5 62 -81 120q-72 55 -122 61q-48 -6 -119 -61q-75 -58 -80 -120q5 -37 9 -51q9 -29 29 -41q34 -21 162 -21zM477 528v56 h-42v48h42v54h46v-54h42v-48h-42v-56h-46zM498 274q-8 0 -33 -19l-34 -25t-33 -14q-37 -13 -92 -18q-8 0 -40 -2q-48 -2 -60 -4q-40 -9 -40 -34q5 -25 26 -25q5 0 28 4q29 6 39 6q60 0 136 18q80 20 105 67q15 -29 56 -49q48 -23 119 -31l33 -4q17 -1 32 -1q11 0 40 -6 q22 -4 27 -4q22 0 27 25q0 25 -40 34q-13 2 -60 4q-23 1 -74 6q-26 3 -58 14q-16 3 -32 13q-10 5 -33 23q-27 22 -39 22zM500 165q-48 -50 -148 -60q-47 -4 -140 -18q-26 -6 -29 -24q-33 14 -61 63q-14 23 -26 39q42 79 103 79q12 0 36.5 -2t36.5 -2q56 0 120 24 q-88 10 -88 53q0 13 12.5 47.5t12.5 50.5q-75 82 -75 155q0 82 81 150q71 60 105 63q-27 33 -27 71q0 36 26 57q23 19 61 19q37 0 61.5 -20.5t24.5 -55.5q0 -38 -26 -71q36 -4 106 -64q80 -67 80 -149q0 -72 -75 -155q0 -16 12.5 -50.5t12.5 -47.5q0 -43 -89 -53 q64 -24 120 -24q13 0 37 2t37 2q61 0 103 -79l-37 -58q-21 -31 -50 -44q-4 21 -48 29q-10 2 -62 7q-156 14 -207 66z" />
</g>}

set truetype_Cases(wn) {
<g
  scidb:bbox="118,100,865,839">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M208 395q18 0 18 -24q0 -31 -31 -31q2 0 -4 1h-4q-5 5 -5 19q0 35 26 35zM291 548q-10 7 -10 21q0 23 24 43t48 20q13 0 25 -7q4 -5 4 -10q0 -21 -30 -44.5t-54 -23.5h-1q-2 1 -3 1h-2h-1zM308 782q5 -12 5 -23q0 -4 -3 -20h1q7 1 31 10q11 2 22 10q-19 11 -27 14t-28 9 h-1zM160 353q5 -20 24 -34.5t39 -14.5h3q5 0 26 14q10 6 14 6q1 -1 4 -1l1 -1q6 0 6 -6q0 -2 -3.5 -11t-3.5 -13q0 -11 17 -11q3 1 31 44q37 55 88 90q30 22 69 39q1 11 9 37q15 49 40 81q11 14 20 14q3 0 7.5 -3t4.5 -13t-12 -42q-19 -49 -19 -72q0 -7 2 -16 q0 -89 -75 -186q-49 -65 -55 -108h412q5 44 5 85q0 201 -99 340q-26 37 -62 71q-49 46 -79 46q-1 -1 -2 -1h-3q-25 3 -28 3q-9 0 -16 -2q-2 0 -6 -1h-7h-6q-5 1 -7 1q-9 3 -15 26q-3 17 -11 49q-3 11 -12 20q-16 -47 -93 -70q-42 -13 -57 -26q-13 -43 -82 -177 q-11 -21 -48 -101q-18 -37 -21 -56zM860 100h-524q3 55 23 99q16 33 56 85q31 40 41 57q18 31 21 67q-59 -26 -89 -56.5t-55 -72.5q-13 -22 -20 -31q-10 -9 -20 -9q-50 5 -55 35q-11 -6 -25 -6q-58 0 -95 74q8 47 47 131q9 20 29 61q35 72 44 92q24 53 35 96q3 18 3 31 q0 7 -8 69h2h3h4l1 1q55 0 116 -34q13 -8 13 -9q34 59 56 59q27 -14 44 -36q12 -19 25 -65q10 2 21 2q101 0 198 -128q114 -149 114 -407q0 -52 -5 -105z" />
</g>}

set truetype_Cases(wp) {
<g
  scidb:bbox="233,101,770,837">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M725 151q0 106 -44 167q-27 38 -86 72q-49 29 -49 53q0 9 5.5 14t19.5 13q27 16 38 32t11 46q0 55 -59 90q-16 10 -22.5 15.5t-6.5 14.5q0 23 13 39q8 12 10 17.5t2 18.5q0 21 -17.5 36t-39.5 15q-21 0 -38 -15t-17 -36q0 -19 12.5 -35.5t12.5 -39.5q0 -9 -7 -15.5 t-22 -14.5q-58 -35 -58 -90q0 -49 49 -78q10 -6 17 -13t7 -14q0 -24 -49 -53q-60 -36 -86 -73q-43 -61 -43 -166h447zM234 101q-1 23 -1 58q0 92 32 158q36 71 135 121q-33 10 -52 44q-18 30 -18 67q0 85 85 120q-21 37 -21 71q0 43 32.5 70t75.5 27t75 -27.5t32 -69.5 q0 -34 -22 -71q86 -35 86 -120q0 -35 -18 -67q-21 -34 -53 -44q100 -51 136 -122q32 -64 32 -157q0 -32 -2 -58h-534z" />
</g>}

set truetype_Cases(bk) {
<g
  scidb:bbox="123,93,882,913"
  scidb:scale="1.05"
  scidb:translate="0,-20">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M535 405q0 -22 -32 -22q-35 0 -35 22q0 106 -69 169q-59 55 -118 55q-51 0 -81 -27t-30 -77q0 -35 44 -99q34 -50 63 -74q19 -16 66 -16q49 0 158 18q110 -18 159 -18q48 0 66 16q34 30 67 79q40 59 40 94q0 50 -30 77t-81 27q-57 0 -118 -56q-69 -62 -69 -168zM806 526 q0 -38 -44 -91q-40 -47 -70 -62q-25 -4 -50 -4q-78 0 -77 31q1 96 57 151q46 47 98 47q36 0 59 -18q27 -19 27 -54zM687 208q0 19 -69 27q-63 6 -115 6q-50 0 -88 -4l-30 -3q-68 -9 -68 -25q0 -18 34 -18q14 0 55 4q74 8 96 8q25 0 75 -6t75 -6q35 0 35 17zM757 178 q-2 -85 -255 -85q-251 0 -253.5 84.5t-24.5 142.5q-13 34 -52 87q-49 65 -49 117q0 63 46 106t109 43q65 0 124 -48q0 29 3 56q1 9 8 23q10 26 58 58v29l-51 31v45h46l15 46h42l17 -46h45v-45l-51 -31v-29q48 -35 58 -58q6 -13 9 -36l3 -43q58 48 122 48q62 0 109 -42 t47 -107q0 -52 -49 -118l-29 -41q-29 -45 -40 -106q-6 -31 -7 -81zM198 526q0 34 25 53t59 19q53 0 100 -48q54 -54 56 -150q1 -16 -20.5 -23.5t-55.5 -7.5q-26 0 -51 4q-33 16 -71 63q-42 53 -42 90z" />
</g>}

set truetype_Cases(bq) {
<g
  scidb:bbox="65,93,933,901">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M293 224q0 -19 28 -19q16 0 45.5 3t41.5 3l75 3q11 1 19 1q28 0 73 -4l73 -4q4 0 14.5 -1t15.5 -1q28 0 28 20t-64 31q-38 7 -103 9h-39q-137 0 -189 -22q-18 -8 -18 -19zM136 747q-13 0 -22 -9t-9 -22t9 -22.5t22 -9.5q30 0 30 32q0 31 -30 31zM300 826q-32 0 -32 -31 q0 -32 32 -32q30 0 30 32q0 31 -30 31zM699 826q-12 0 -21 -9.5t-9 -21.5q0 -32 30 -32q31 0 31 32q0 31 -31 31zM862 747q-30 0 -30 -31q0 -32 30 -32q31 0 31 32q0 13 -9 22t-22 9zM771 150q0 -36 -128 -49q-57 -5 -89 -7l-33 -1h-22q-151 0 -233 26q-38 12 -38 31 q0 39 20 82q13 26 13 39q0 27 -59 95q-34 40 -34.5 47t-7.5 34l-16 63q-7 27 -11 48q-7 41 -10 81q-58 26 -58 77q0 29 21 49.5t50 20.5q28 0 49 -20.5t21 -49.5q0 -5 -3 -20q-3 -20 -3 -28q0 -54 80 -137q7 61 7 107q0 56 -11 81q-8 19 -24 29q-23 14 -23 49 q0 29 20.5 49.5t50.5 20.5q28 0 49 -20.5t21 -49.5q0 -7 -4 -25t-4 -29q0 -73 68 -214q8 35 21 104q6 46 6 77q0 52 -19 96q-8 17 -8 25q0 29 20.5 49.5t49.5 20.5q28 0 48 -20.5t20 -49.5q0 -10 -9 -32q-11 -27 -13 -34q-4 -20 -4 -55q0 -55 14 -125q5 -26 12 -56 q67 143 67 214q0 10 -3.5 27.5t-3.5 26.5q0 30 20.5 50t50.5 20q29 0 49.5 -21t20.5 -49q0 -35 -23 -50q-27 -18 -32 -61q-3 -20 -3 -49q0 -44 7 -106q80 83 80 137q0 6 -3 28q-3 16 -3 20q0 29 21 49.5t49 20.5q29 0 50 -20.5t21 -49.5q0 -50 -58 -77q-3 -38 -11 -82 q-9 -50 -31 -129q-2 -8 -2.5 -15t-19.5 -29l-15 -18q-59 -70 -59 -95q0 -11 12 -38q14 -32 17 -40q5 -18 5 -43zM500 864q-13 0 -22 -9t-9 -22q0 -12 9 -21.5t22 -9.5q30 0 30 31q0 13 -9 22t-21 9zM725 377q0 22 -69 32q-59 8 -156 8t-157 -9q-69 -11 -69 -32q0 -18 32 -18 q17 0 47 2q34 3 47 4l81 3h21q43 0 132 -6q16 0 48 -2q9 -1 13 -1q30 0 30 19z" />
</g>}

set truetype_Cases(br) {
<g
  scidb:bbox="194,103,821,832">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M218 103l-24 24v88l127 125v249l-98 96v112l35 35h89l22 -22v-31h48v31l21 22h139l21 -22v-31h48v31l21 22h90l35 -35v-112l-98 -96v-249l127 -125v-88l-25 -24h-578zM366 369v-42h283v42h-283zM366 594v-42h283v42h-283z" />
</g>}

set truetype_Cases(bb) {
<g
  scidb:bbox="95,59,905,929">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M439 385q-64 0 -64 -20q0 -18 56 -21q-2 0 69 0q125 0 125 21q0 20 -64 20h-122zM439 463q-32 0 -48 -3.5t-16 -16.5q0 -15 26 -17q33 -3 99 -3t100 3q25 2 25 17q0 20 -64 20h-122zM671 409q0 -10 12 -46q4 -11 8.5 -27.5t4.5 -22.5q0 -43 -89 -52q41 -15 64 -19 q31 -5 58 -5q11 0 42.5 1.5t30.5 1.5q37 0 63 -23q19 -17 40 -57l-37 -57q-21 -32 -50 -44q-5 21 -48 29q-10 2 -62 6q-156 14 -208 66q-49 -50 -149 -59q-20 -2 -59 -7q-48 -4 -61 -6q-45 -9 -49 -29q-32 14 -61 63q-13 22 -26 38q21 41 40 57q25 23 63 23q-1 0 30.5 -1.5 t42.5 -1.5q59 0 121 24q-88 9 -88 52q0 14 13 45.5t13 45.5q-76 94 -76 164q0 82 81 150q71 60 105 65q-27 32 -27 70q0 37 24.5 56.5t62.5 19.5q37 0 62 -20t25 -56q0 -37 -27 -70q23 -6 71 -39q60 -42 91 -94q24 -39 24 -82q0 -73 -75 -159zM523 525v58h43v47h-43v54h-46 v-54h-43v-47h43v-58h46zM500 878q-13 0 -23 -9t-10 -21q0 -13 10 -22t23 -9q31 0 31 31q0 30 -31 30z" />
</g>}

set truetype_Cases(bn) {
<g
  scidb:bbox="125,100,876,838">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M201 382q-17 0 -29.5 -11t-12.5 -28q0 -6 4 -13q16 0 28.5 10.5t12.5 26.5q0 5 -3 15zM814 189q1 45 1 46q0 204 -104 334q-89 113 -163 113q-5 0 -12 -2q-1 0 -2 1h-3h-2q-17 0 -17 -13q0 -6 8 -13q67 -5 147 -96q102 -119 102 -340q0 -2 -1 -8v-9v-10v-7q1 -13 8 -21 t17 -8q8 0 14 8.5t7 24.5zM291 548h1h2q2 0 3 -1h1q25 0 54.5 25t29.5 43q0 5 -4 10q-12 7 -25 7q-24 0 -48 -19.5t-24 -43.5q0 -14 10 -21zM871 100l-527 2q2 59 22.5 98t55.5 83q31 39 42 57q18 31 22 67q-62 -25 -98 -64q-17 -19 -26 -33q-13 -23 -41 -65q-8 -9 -18 -10 q-32 0 -32 39q-13 -16 -29 -16q-2 0 -24 6q-39 10 -57.5 25.5t-35.5 52.5q7 46 47 130l56 117q38 76 53 131q2 17 2 33q0 7 -7 67h2h3q2 0 3 1h2q56 0 123 -37q7 -4 7 -5q36 59 55 59q31 -16 45 -36q11 -17 26 -66q9 3 21 3q103 0 200 -129q113 -149 113 -405q0 -52 -5 -105 z" />
</g>}

set truetype_Cases(bp) {
<g
  scidb:bbox="232,101,769,836">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M234 101q-2 22 -2 58q0 92 33 157q35 71 135 121q-33 10 -53 44q-18 31 -18 68q0 84 86 119q-22 37 -22 71q0 43 34 71q31 26 74 26t75 -27.5t32 -69.5q0 -34 -22 -71q46 -18 66 -50t20 -69q0 -36 -19 -69t-51 -43q100 -51 135 -122q32 -63 32 -156q0 -36 -2 -58h-533z" />
</g>}

set truetype_Cases(wk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M503 93q-249 0 -253 84q-4 92 -24 144q-14 35 -53 87q-27 36 -35 54q-14 28 -14 62q0 47 28 85.5t72 54.5q31 11 56 10q65 -1 123 -48l1 -1q0 34 3 57q0 9 8 23q10 25 58 58v30l-51 30v45h46l16 47h38l16 -47h46v-45l-51 -30v-30q45 -30 59 -58q7 -16 7.5 -24.5t1.5 -27 t1 -28.5l1 1q57 47 123 48q44 1 84.5 -24t58.5 -66q13 -28 13 -60q0 -53 -48 -116q-21 -28 -30 -42q-15 -22 -23 -45q-22 -54 -25 -144q-2 -84 -253 -84z" />
</g>}

set truetype_Cases(wq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M503 903q29 0 49 -20.5t20 -49.5q0 -9 -10 -32q-11 -28 -12 -34q-5 -20 -5 -54q0 -25 7 -78q5 -41 20 -103q67 142 67 214q0 17 -5 38q-2 11 -2 16q0 29 20.5 49.5t48.5 20.5q29 0 50 -20.5t21 -49.5q0 -33 -22 -51q-27 -17 -33 -61q-2 -19 -2 -49q0 -39 6 -105 q81 82 81 136q0 8 -4 28q-2 15 -2 21q0 28 20.5 49t48.5 21q29 0 50 -21t21 -49q0 -51 -58 -77q-2 -36 -11 -83q-5 -29 -26 -110l-8 -33q0 -18 -40 -59q-53 -54 -53 -84q0 -12 12 -37l18 -37q5 -14 5 -34q0 -3 -1 -8.5t-1 -8.5v-2l1 -1q0 -31 -128 -43q-56 -5 -89 -6 q-37 -1 -55 -1q-3 0 -19 1q-19 1 -35 1q-115 3 -179 20q-38 11 -38 28l1 1v2q0 1 -1 4v5v8q0 28 19 67q14 29 14 41q0 21 -21 47l-61 70q-10 14 -10 26l-28 112q-14 65 -17 114q-58 26 -58 77q0 28 21 49t49 21q29 0 49.5 -21t20.5 -49q0 -5 -2 -21q-4 -20 -4 -28 q0 -54 80 -136q7 66 7 105q0 59 -11 82q-5 10 -11 17q-4 4 -13 12q-13 8 -17 19q-6 8 -6 31q0 29 21 49.5t50 20.5t49.5 -20.5t20.5 -49.5q0 -4 -2 -16q-5 -21 -5 -38q0 -71 67 -214q27 114 27 181q0 49 -19 95q-8 17 -8 25q0 29 21 49.5t49 20.5z" />
</g>}

set truetype_Cases(wr,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M210 100l-24 24v86l128 129v250l-110 96v113l36 35h112l22 -21v-32h36v32l21 21h138l21 -21v-32h35v32l22 21h113l36 -35v-113l-110 -96v-250l128 -129v-86l-24 -24h-580z" />
</g>}

set truetype_Cases(wb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M500 165q-48 -50 -148 -60q-47 -4 -140 -18q-26 -6 -29 -24q-33 14 -61 63q-14 23 -26 39q42 79 103 79q12 0 36.5 -2t36.5 -2q56 0 120 24q-88 10 -88 53q0 13 12.5 47.5t12.5 50.5q-75 82 -75 155q0 82 81 150q71 60 105 63q-27 33 -27 71q0 36 26 57q23 19 61 19 q37 0 61.5 -20.5t24.5 -55.5q0 -38 -26 -71q36 -4 106 -64q80 -67 80 -149q0 -72 -75 -155q0 -16 12.5 -50.5t12.5 -47.5q0 -43 -89 -53q64 -24 120 -24q13 0 37 2t37 2q61 0 103 -79l-37 -58q-21 -31 -50 -44q-4 21 -48 29q-10 2 -62 7q-156 14 -207 66z" />
</g>}

set truetype_Cases(wn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M860 100h-524q3 55 23 99q16 33 56 85q31 40 41 57q18 31 21 67q-59 -26 -89 -56.5t-55 -72.5q-13 -22 -20 -31q-10 -9 -20 -9q-50 5 -55 35q-11 -6 -25 -6q-58 0 -95 74q8 47 47 131q9 20 29 61q35 72 44 92q24 53 35 96q3 18 3 31q0 7 -8 69h2h3h4l1 1q55 0 116 -34 q13 -8 13 -9q34 59 56 59q27 -14 44 -36q12 -19 25 -65q10 2 21 2q101 0 198 -128q114 -149 114 -407q0 -52 -5 -105z" />
</g>}

set truetype_Cases(wp,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M234 101q-1 23 -1 58q0 92 32 158q36 71 135 121q-33 10 -52 44q-18 30 -18 67q0 85 85 120q-21 37 -21 71q0 43 32.5 70t75.5 27t75 -27.5t32 -69.5q0 -34 -22 -71q86 -35 86 -120q0 -35 -18 -67q-21 -34 -53 -44q100 -51 136 -122q32 -64 32 -157q0 -32 -2 -58h-534z" />
</g>}

set truetype_Cases(bk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M757 178q-2 -85 -255 -85q-251 0 -253.5 84.5t-24.5 142.5q-13 34 -52 87q-49 65 -49 117q0 63 46 106t109 43q65 0 124 -48q0 29 3 56q1 9 8 23q10 26 58 58v29l-51 31v45h46l15 46h42l17 -46h45v-45l-51 -31v-29q48 -35 58 -58q6 -13 9 -36l3 -43q58 48 122 48 q62 0 109 -42t47 -107q0 -52 -49 -118l-29 -41q-29 -45 -40 -106q-6 -31 -7 -81z" />
</g>}

set truetype_Cases(bq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M771 150q0 -36 -128 -49q-57 -5 -89 -7l-33 -1h-22q-151 0 -233 26q-38 12 -38 31q0 39 20 82q13 26 13 39q0 27 -59 95q-34 40 -34.5 47t-7.5 34l-16 63q-7 27 -11 48q-7 41 -10 81q-58 26 -58 77q0 29 21 49.5t50 20.5q28 0 49 -20.5t21 -49.5q0 -5 -3 -20 q-3 -20 -3 -28q0 -54 80 -137q7 61 7 107q0 56 -11 81q-8 19 -24 29q-23 14 -23 49q0 29 20.5 49.5t50.5 20.5q28 0 49 -20.5t21 -49.5q0 -7 -4 -25t-4 -29q0 -73 68 -214q8 35 21 104q6 46 6 77q0 52 -19 96q-8 17 -8 25q0 29 20.5 49.5t49.5 20.5q28 0 48 -20.5t20 -49.5 q0 -10 -9 -32q-11 -27 -13 -34q-4 -20 -4 -55q0 -55 14 -125q5 -26 12 -56q67 143 67 214q0 10 -3.5 27.5t-3.5 26.5q0 30 20.5 50t50.5 20q29 0 49.5 -21t20.5 -49q0 -35 -23 -50q-27 -18 -32 -61q-3 -20 -3 -49q0 -44 7 -106q80 83 80 137q0 6 -3 28q-3 16 -3 20 q0 29 21 49.5t49 20.5q29 0 50 -20.5t21 -49.5q0 -50 -58 -77q-3 -38 -11 -82q-9 -50 -31 -129q-2 -8 -2.5 -15t-19.5 -29l-15 -18q-59 -70 -59 -95q0 -11 12 -38q14 -32 17 -40q5 -18 5 -43z" />
</g>}

set truetype_Cases(br,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M218 103l-24 24v88l127 125v249l-98 96v112l35 35h89l22 -22v-31h48v31l21 22h139l21 -22v-31h48v31l21 22h90l35 -35v-112l-98 -96v-249l127 -125v-88l-25 -24h-578z" />
</g>}

set truetype_Cases(bb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M671 409q0 -10 12 -46q4 -11 8.5 -27.5t4.5 -22.5q0 -43 -89 -52q41 -15 64 -19q31 -5 58 -5q11 0 42.5 1.5t30.5 1.5q37 0 63 -23q19 -17 40 -57l-37 -57q-21 -32 -50 -44q-5 21 -48 29q-10 2 -62 6q-156 14 -208 66q-49 -50 -149 -59q-20 -2 -59 -7q-48 -4 -61 -6 q-45 -9 -49 -29q-32 14 -61 63q-13 22 -26 38q21 41 40 57q25 23 63 23q-1 0 30.5 -1.5t42.5 -1.5q59 0 121 24q-88 9 -88 52q0 14 13 45.5t13 45.5q-76 94 -76 164q0 82 81 150q71 60 105 65q-27 32 -27 70q0 37 24.5 56.5t62.5 19.5q37 0 62 -20t25 -56q0 -37 -27 -70 q23 -6 71 -39q60 -42 91 -94q24 -39 24 -82q0 -73 -75 -159z" />
</g>}

set truetype_Cases(bn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M871 100l-527 2q2 59 22.5 98t55.5 83q31 39 42 57q18 31 22 67q-62 -25 -98 -64q-17 -19 -26 -33q-13 -23 -41 -65q-8 -9 -18 -10q-32 0 -32 39q-13 -16 -29 -16q-2 0 -24 6q-39 10 -57.5 25.5t-35.5 52.5q7 46 47 130l56 117q38 76 53 131q2 17 2 33q0 7 -7 67h2h3 q2 0 3 1h2q56 0 123 -37q7 -4 7 -5q36 59 55 59q31 -16 45 -36q11 -17 26 -66q9 3 21 3q103 0 200 -129q113 -149 113 -405q0 -52 -5 -105z" />
</g>}

set truetype_Cases(bp,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M234 101q-2 22 -2 58q0 92 33 157q35 71 135 121q-33 10 -53 44q-18 31 -18 68q0 84 86 119q-22 37 -22 71q0 43 34 71q31 26 74 26t75 -27.5t32 -69.5q0 -34 -22 -71q46 -18 66 -50t20 -69q0 -36 -19 -69t-51 -43q100 -51 135 -122q32 -63 32 -156q0 -36 -2 -58h-533z" />
</g>}

set truetype_Cases(wk,exterior) {
<g>
  <path
    d="M503 514q1 2 8 13q17 24 27 43t15 37q3 27 3 36q0 74 -52 74q-54 0 -54 -74q0 -13 3 -36q10 -35 42 -80q8 -11 8 -13z M837 516q0 56 -38 87q-32 26 -73 26q-55 0 -117 -55q-74 -64 -83 -173q0 -9 46 -19q39 -8 131 -10q16 -1 29 -1h4h18q5 8 14.5 19.5l23.5 28.5q27 39 38 65q7 19 7 32zM503 348q-25 -11 -90 -17q-34 -2 -102 -7l-37 -3q13 -49 17 -105q87 28 212 28q126 0 213 -28 q3 61 16 105l-36 3q-35 2 -103 7q-36 4 -46 5q-26 4 -44 12zM169 516q0 -25 26 -67q13 -20 21 -30l10 -14q13 -14 26 -34h22q52 0 131 8q76 7 76 22q-10 109 -84 173q-61 55 -117 55q-17 0 -37 -7q-43 -11 -63 -55q-11 -23 -11 -51zM503 138q62 0 123 8q51 6 51 16 q0 16 -46 23q-67 9 -127 9q-61 0 -128 -9q-47 -7 -47 -23q0 -14 107 -22q31 -2 67 -2z" />
</g>}

set truetype_Cases(wq,exterior) {
<g>
  <path
    d="M139 749q-31 0 -31 -30q0 -32 31 -32q30 0 30 32q0 12 -9 21t-21 9z" />
  <path
    d="M303 829q-31 0 -31 -31q0 -32 31 -32q30 0 30 32q0 31 -30 31z" />
  <path
    d="M701 829q-12 0 -21 -9.5t-9 -21.5q0 -13 9 -22.5t21 -9.5q32 0 32 32q0 31 -32 31z" />
  <path
    d="M865 749q-12 0 -21 -9t-9 -21q0 -13 9 -22.5t21 -9.5q31 0 31 32 q0 30 -31 30z" />
  <path
    d="M503 867q-31 0 -31 -31q0 -32 31 -32q30 0 30 32q0 31 -30 31z" />
  <path
    d="M503 669q-4 -24 -9 -45l-8 -36 q-12 -49 -28 -78q-3 -6 -10 -15t-9 -16q-2 3 -12 15l-19.5 22.5t-19.5 27.5q-30 54 -57 134q2 -14 2 -36t-7 -93q-1 -11 -5 -33l-9 -56q-67 39 -131 128q12 -63 22 -103q9 -35 10 -38q8 -25 19 -29q104 59 271 59q168 0 271 -59q19 6 41 118l6 30l4 22q-64 -89 -130 -128 l-4 19q-18 104 -18 152q0 25 3 47q-27 -80 -58 -134q-12 -21 -39 -50q-10 -12 -12 -15q-6 11 -19 31q-5 9 -12.5 27.5t-23.5 87.5q-4 21 -9 44z" />
  <path
    d="M706 320q-103 13 -203 13q-93 0 -158 -8q-24 -2 -44 -5q15 -12 15 -49 q0 -22 -8 -28q83 14 195 14q113 0 195 -14q-7 6 -7 28q0 37 15 49z" />
  <path
    d="M502 376h14q2 0 7 1h7q5 0 45 -2q14 0 62 -4q39 -3 62 -3t23 6q0 1 -1 3v1v1q0 27 -99 42q-66 9 -119 9t-119 -9q-98 -14 -98 -42v-2q-2 -1 -2 -3q0 -6 23 -6q6 0 63 4q67 5 105 5h7q5 -1 7 -1h13z" />
  <path
    d="M503 213q-72 0 -142 -7q-62 -5 -62 -28q0 -31 204 -31t204 31q0 10 -16 18q-32 12 -109 15q-41 2 -79 2z" />
</g>}

set truetype_Cases(wr,exterior) {
<g>
  <path
    d="M357 585v-222h285v222h-285z" />
  <path
    d="M452 781v-32l-18 -18h-81l-19 18v34h-70l-16 -17v-70l85 -69h334l85 69v70l-16 17h-70v-34l-19 -18h-81l-18 18v32h-96z" />
  <path
    d="M352 322l-82 -80h460l-82 80h-296z" />
  <path
    d="M230 198v-48h540v48h-540z" />
</g>}

set truetype_Cases(wb,exterior) {
<g>
  <path
    d="M500 431q-63 0 -110 5q-15 1 -26 3q8 -15 8 -31q0 -17 -7 -31q21 7 89 11q21 1 46 1q99 0 135 -12q-8 14 -8 31q0 15 8 31q-58 -8 -135 -8z" />
  <path
    d="M499 467q139 0 171 26q22 17 31 87q-5 62 -81 120q-72 55 -122 61q-48 -6 -119 -61q-75 -58 -80 -120q5 -37 9 -51q9 -29 29 -41q34 -21 162 -21z" />
  <path
    d="M500 884q-16 0 -27.5 -11.5t-11.5 -25.5q0 -16 11.5 -26.5t27.5 -10.5q15 0 27 10.5t12 26.5q0 15 -12 26t-27 11z" />
  <path
    d="M500 352 q-41 0 -123 -8q-24 -5 -24 -24q0 -16 68 -19q-14 1 79 1q146 0 146 18q0 23 -46 29q-8 1 -63 2q-10 0 -27 1h-10z" />
  <path
    d="M498 274q-8 0 -33 -19l-34 -25t-33 -14q-37 -13 -92 -18q-8 0 -40 -2q-48 -2 -60 -4q-40 -9 -40 -34q5 -25 26 -25q5 0 28 4q29 6 39 6q60 0 136 18q80 20 105 67q15 -29 56 -49q48 -23 119 -31l33 -4q17 -1 32 -1q11 0 40 -6 q22 -4 27 -4q22 0 27 25q0 25 -40 34q-13 2 -60 4q-23 1 -74 6q-26 3 -58 14q-16 3 -32 13q-10 5 -33 23q-27 22 -39 22z" />
</g>}

set truetype_Cases(wn,exterior) {
<g>
  <path
    d="M160 353q5 -20 24 -34.5t39 -14.5h3q5 0 26 14q10 6 14 6q1 -1 4 -1l1 -1q6 0 6 -6q0 -2 -3.5 -11t-3.5 -13q0 -11 17 -11q3 1 31 44q37 55 88 90q30 22 69 39q1 11 9 37q15 49 40 81q11 14 20 14q3 0 7.5 -3t4.5 -13t-12 -42q-19 -49 -19 -72q0 -7 2 -16 q0 -89 -75 -186q-49 -65 -55 -108h412q5 44 5 85q0 201 -99 340q-26 37 -62 71q-49 46 -79 46q-1 -1 -2 -1h-3q-25 3 -28 3q-9 0 -16 -2q-2 0 -6 -1h-7h-6q-5 1 -7 1q-9 3 -15 26q-3 17 -11 49q-3 11 -12 20q-16 -47 -93 -70q-42 -13 -57 -26q-13 -43 -82 -177 q-11 -21 -48 -101q-18 -37 -21 -56z M308 782q5 -12 5 -23q0 -4 -3 -20h1q7 1 31 10q11 2 22 10q-19 11 -27 14t-28 9 h-1z M291 548q-10 7 -10 21q0 23 24 43t48 20q13 0 25 -7q4 -5 4 -10q0 -21 -30 -44.5t-54 -23.5h-1q-2 1 -3 1h-2h-1z" />
</g>}

set truetype_Cases(wp,exterior) {
<g>
  <path
    d="M725 151q0 106 -44 167q-27 38 -86 72q-49 29 -49 53q0 9 5.5 14t19.5 13q27 16 38 32t11 46q0 55 -59 90q-16 10 -22.5 15.5t-6.5 14.5q0 23 13 39q8 12 10 17.5t2 18.5q0 21 -17.5 36t-39.5 15q-21 0 -38 -15t-17 -36q0 -19 12.5 -35.5t12.5 -39.5q0 -9 -7 -15.5 t-22 -14.5q-58 -35 -58 -90q0 -49 49 -78q10 -6 17 -13t7 -14q0 -24 -49 -53q-60 -36 -86 -73q-43 -61 -43 -166h447z" />
</g>}

set truetype_Cases(bk,exterior) $truetype_Cases(bk,mask)
set truetype_Cases(bq,exterior) $truetype_Cases(bq,mask)
set truetype_Cases(br,exterior) $truetype_Cases(br,mask)
set truetype_Cases(bb,exterior) $truetype_Cases(bb,mask)
set truetype_Cases(bn,exterior) $truetype_Cases(bn,mask)
set truetype_Cases(bp,exterior) $truetype_Cases(bp,mask)

set truetype_Cases(bk,interior) {
<g>
  <path
    style="fill:white;stroke:none;fill-rule:evenodd"
    d="M535 405q0 -22 -32 -22q-35 0 -35 22q0 106 -69 169q-59 55 -118 55q-51 0 -81 -27t-30 -77q0 -35 44 -99q34 -50 63 -74q19 -16 66 -16q49 0 158 18q110 -18 159 -18q48 0 66 16q34 30 67 79q40 59 40 94q0 50 -30 77t-81 27q-57 0 -118 -56q-69 -62 -69 -168z M198 526q0 34 25 53t59 19q53 0 100 -48q54 -54 56 -150q1 -16 -20.5 -23.5t-55.5 -7.5q-26 0 -51 4q-33 16 -71 63q-42 53 -42 90z M806 526 q0 -38 -44 -91q-40 -47 -70 -62q-25 -4 -50 -4q-78 0 -77 31q1 96 57 151q46 47 98 47q36 0 59 -18q27 -19 27 -54z M687 208q0 19 -69 27q-63 6 -115 6q-50 0 -88 -4l-30 -3q-68 -9 -68 -25q0 -18 34 -18q14 0 55 4q74 8 96 8q25 0 75 -6t75 -6q35 0 35 17z" />
</g>}

set truetype_Cases(bq,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M293 224q0 -19 28 -19q16 0 45.5 3t41.5 3l75 3q11 1 19 1q28 0 73 -4l73 -4q4 0 14.5 -1t15.5 -1q28 0 28 20t-64 31q-38 7 -103 9h-39q-137 0 -189 -22q-18 -8 -18 -19z M136 747q-13 0 -22 -9t-9 -22t9 -22.5t22 -9.5q30 0 30 32q0 31 -30 31z M300 826q-32 0 -32 -31 q0 -32 32 -32q30 0 30 32q0 31 -30 31zM699 826q-12 0 -21 -9.5t-9 -21.5q0 -32 30 -32q31 0 31 32q0 31 -31 31zM862 747q-30 0 -30 -31q0 -32 30 -32q31 0 31 32q0 13 -9 22t-22 9z M500 864q-13 0 -22 -9t-9 -22q0 -12 9 -21.5t22 -9.5q30 0 30 31q0 13 -9 22t-21 9zM725 377q0 22 -69 32q-59 8 -156 8t-157 -9q-69 -11 -69 -32q0 -18 32 -18 q17 0 47 2q34 3 47 4l81 3h21q43 0 132 -6q16 0 48 -2q9 -1 13 -1q30 0 30 19z" />
</g>}

set truetype_Cases(br,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M366 369v-42h283v42h-283zM366 594v-42h283v42h-283z" />
</g>}

set truetype_Cases(bb,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M523 525v58h43v47h-43v54h-46 v-54h-43v-47h43v-58h46z M500 878q-13 0 -23 -9t-10 -21q0 -13 10 -22t23 -9q31 0 31 31q0 30 -31 30z M439 385q-64 0 -64 -20q0 -18 56 -21q-2 0 69 0q125 0 125 21q0 20 -64 20h-122z M439 463q-32 0 -48 -3.5t-16 -16.5q0 -15 26 -17q33 -3 99 -3t100 3q25 2 25 17q0 20 -64 20h-122z" />
</g>}

set truetype_Cases(bn,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M291 548h1h2q2 0 3 -1h1q25 0 54.5 25t29.5 43q0 5 -4 10q-12 7 -25 7q-24 0 -48 -19.5t-24 -43.5q0 -14 10 -21z M814 189q1 45 1 46q0 204 -104 334q-89 113 -163 113q-5 0 -12 -2q-1 0 -2 1h-3h-2q-17 0 -17 -13q0 -6 8 -13q67 -5 147 -96q102 -119 102 -340q0 -2 -1 -8v-9v-10v-7q1 -13 8 -21 t17 -8q8 0 14 8.5t7 24.5z M201 382q-17 0 -29.5 -11t-12.5 -28q0 -6 4 -13q16 0 28.5 10.5t12.5 26.5q0 5 -3 15z" />
</g>}

set truetype_Cases(bp,interior) {}

set truetype_Cases(sample,24pt,200x34) {
  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
  QmCC
}

# vi:set ts=2 sw=2 et:
