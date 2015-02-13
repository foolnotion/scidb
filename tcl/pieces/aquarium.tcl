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
# Copyright: (C) 2015 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

# Font from <http://gorgonian.weebly.com/babaschess.html>

lappend board_PieceSet { Aquarium truetype {stroke {2 0}} {contour 20} {overstroke 2} {sampling 200} {scale 0.48} }

set truetype_Aquarium(wk) {
<g scidb:bbox="110,-147,865,613" scidb:scale="1.1">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M486 613h3q5 -1 5 -5v-64h63q5 -1 5 -6v-2q0 -6 -5 -6h-63v-80q78 -15 78 -67q-3 -32 -10 -68q64 60 139 60h14q122 0 147 -113q3 -18 3 -35q0 -68 -75 -129q-62 -36 -61 -65q-14 -44 -14 -55q4 0 32 -33v-24q-21 -36 -89 -51q-70 -17 -153 -16h-37q-213 0 -239 64l-3 6 v13q0 15 35 48v3q-20 83 -40 83q-110 67 -111 172q0 134 157 134q83 0 155 -75v-2h3v2q-21 41 -22 59v19q0 48 73 70h5v80h-70q-5 0 -5 6v2q0 6 5 6h70v64q0 5 5 5zM417 364q0 -29 69 -139h3q67 79 68 158q0 46 -74 54q-44 0 -66 -54v-19zM124 240q0 -103 123 -166 q80 34 116 34v3q-5 0 -41 38q-91 52 -91 88v11q1 9 22 9h14q45 0 90 -68q54 -61 54 -72q10 2 70 5v78q0 15 -91 115q-65 49 -129 49q-137 0 -137 -124zM497 205v-83l67 -8q54 89 108 134q25 6 40 6h6q21 0 26 -14v-3q0 -34 -89 -86q-43 -39 -43 -45l121 -32q115 75 116 142 q3 11 3 19q0 77 -68 110q-31 17 -72 16h-8q-114 0 -193 -139q-4 0 -14 -17zM253 61q24 -73 24 -82q-38 -34 -38 -40v-7q62 43 226 43h49q152 0 216 -49h3v6q0 12 -35 46v1q21 73 22 82q-135 46 -239 45h-8q-119 1 -220 -45zM247 -90q51 -43 239 -43h8q154 0 224 40v8 q-15 35 -229 46q-242 -8 -242 -51z" />
</g>}

set truetype_Aquarium(wq) {
<g scidb:bbox="80,-146,900,590" scidb:translate="0,27">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M485 590h9q48 -7 48 -49v-5q0 -36 -43 -49q49 -290 57 -300l5 -3q18 12 78 220q2 0 21 62q-35 15 -35 49q8 47 49 47h5q49 -7 49 -47q-10 -52 -46 -52h-5q6 -292 18 -292q19 31 123 233q-23 17 -23 43v5q0 40 54 52q51 -10 50 -49v-11q0 -44 -59 -48h-8 q-55 -328 -69 -328q-46 -41 -46 -58v-17q0 -15 35 -72v-6q0 -49 -226 -61h-38q-201 0 -255 48l-3 13q38 73 39 81q-6 21 -71 91l-61 307q-57 5 -57 50q9 51 51 51h3q43 0 49 -56v-2q0 -14 -28 -41l137 -236h3q6 17 6 24v274h-6q-40 0 -48 51q0 51 45 51h11q49 0 49 -56 q0 -20 -33 -46q86 -264 100 -276q12 0 48 227q2 3 16 78q-43 12 -43 40v20q0 37 45 43zM453 547v-14q0 -27 38 -32q37 8 37 37q0 38 -43 38q-32 -6 -32 -29zM478 562h21q19 -11 19 -32q-9 -24 -27 -24h-6q-25 0 -26 35q5 15 19 21zM642 520v-11q0 -12 15 -27l6 2h5 q0 -8 20 -7q26 14 26 40q-10 32 -35 32h-5q-32 -7 -32 -29zM263 520v-16q8 -32 32 -32h3v2q-19 0 -25 27v5q0 21 30 27q27 -8 27 -27v-5q0 -10 -11 -22h3q13 14 13 25v13q-6 30 -32 30h-5q-35 -4 -35 -27zM679 541q16 -5 21 -19v-18q-12 -20 -29 -20q-24 10 -25 28v3 q1 23 33 26zM808 447q14 26 32 27q30 -4 30 -30q0 -29 -35 -29v-3h19q32 7 32 38v5q-7 32 -32 32h-11q-29 0 -35 -40zM97 450v-11q0 -17 12 -21l-2 13v6q5 26 27 26h3q26 0 26 -32h3l3 13q-9 38 -35 38h-5q-32 -7 -32 -32zM488 450q-48 -293 -64 -293q-29 15 -72 166 q-8 11 -33 95h-3v-221q-10 -69 -18 -69q-15 17 -135 227h-2v-1q45 -246 54 -264q18 -21 21 -22q136 32 252 33q109 0 253 -33q22 19 32 78q0 11 38 208v1h-3q-90 -185 -119 -214h-1q-21 32 -22 257q-3 0 -3 28h-3q-73 -250 -89 -250q-9 -16 -12 -16q-22 0 -49 194 q-3 1 -19 96h-3zM247 55q34 -41 34 -59q0 -12 -18 -51h3q71 26 230 27q138 0 226 -27q-21 37 -22 59q0 21 28 51q-124 30 -232 30h-21q-104 0 -228 -30zM244 -90q75 -43 244 -43q225 9 247 43v3q-15 32 -219 43h-22q-250 -10 -250 -46z" />
</g>}

set truetype_Aquarium(wr) {
<g scidb:bbox="163,-146,814,581" scidb:translate="0,15">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M228 581h107q4 0 8 -8v-56h84v56q0 4 8 8h104q4 0 8 -8v-56h92v56q0 4 7 8h105q4 0 9 -8v-142q0 -3 -89 -65q-3 -15 -3 -23v-256q72 -58 72 -134v-21h68q6 -1 5 -6v-65q0 -4 -8 -7h-634q-4 0 -8 7v65q1 6 6 6h69v7q0 93 75 148v267q0 18 -67 55l-26 25v139q0 4 8 8z M235 565v-126l84 -62q67 -2 99 -2h135q39 0 107 2l83 60v128h-89v-45q0 -14 -8 -16h-107q-5 0 -5 5v56h-92v-53q0 -4 -7 -8h-100q-5 0 -5 5v43l-3 13h-92zM327 361v-274h69v274h-69zM416 361v-274h142v274h-142zM577 361v-274h77v274h-77zM252 -68h476v3q0 98 -71 139h-327 q-26 0 -62 -62q-11 -18 -16 -80zM180 -82v-48h620v48h-620z" />
</g>}

set truetype_Aquarium(wb) {
<g scidb:bbox="80,-147,896,659" scidb:scale="1.1" scidb:translate="0,10">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M485 659h14q40 0 57 -58q0 -32 -40 -63q80 -37 172 -109q29 -35 29 -92q0 -97 -75 -175q0 -5 40 -97q-32 -40 -59 -40h-41v-3q15 -66 43 -66l81 37q26 6 46 6q84 0 144 -54q-36 -61 -50 -78q-47 32 -97 32q-51 0 -104 -40q-21 -6 -28 -5q-63 0 -123 93q0 -32 -62 -86 q-21 -8 -35 -7q-19 0 -105 42q-19 3 -29 3h-30q-44 0 -93 -32q-3 0 -60 72v3q60 59 164 59q44 0 126 -37h8q21 0 24 51v10h-37q-44 0 -62 40v6q0 4 41 91q-75 83 -75 178q0 111 187 193q0 5 11 5q-37 28 -37 63q10 58 55 58zM456 601q6 -41 35 -41h3q23 0 34 35 q-12 35 -37 35h-3q-22 0 -32 -29zM295 334q0 -76 72 -158q57 17 108 16h35q50 0 110 -19q0 6 37 54q24 43 28 56l-3 6q8 13 7 54q0 69 -90 115q-21 16 -105 62q-25 0 -159 -91q-40 -39 -40 -95zM485 426h6q5 -1 5 -6v-65h46q6 -1 6 -4v-3q0 -5 -6 -5h-46v-68q0 -6 -5 -5h-6 q-5 0 -5 5v68h-50q-6 0 -6 5v3q1 5 6 4h50v65q1 6 5 6zM333 68q13 -16 26 -15h62q6 -14 41 -20q13 0 32 -8q66 11 75 25l33 3h34q27 6 27 21q-35 83 -46 83q-63 21 -129 22q-121 -8 -121 -30q-34 -72 -34 -81zM430 22v-21q0 -47 -46 -64h-11q-17 0 -81 30q-27 5 -54 8 q-72 0 -120 -38q23 -28 24 -35q54 23 81 24h46q39 0 115 -43q6 0 11 -2q47 0 88 104q2 0 2 3v24q-36 11 -53 10h-2zM502 12v-24q13 -13 32 -53q48 -54 83 -54q21 3 62 32q36 13 70 13t91 -22v3l19 28v4q-49 32 -110 33q-45 0 -100 -37l-18 -6h-14q-41 0 -61 89v3 q-8 0 -54 -9z" />
</g>}

set truetype_Aquarium(wn) {
<g scidb:bbox="125,-146,851,584" scidb:translate="0,23">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M439 584q30 -27 57 -94q20 11 43 11h2q121 0 247 -226q49 -109 49 -242q3 0 14 -177l-6 -2h-499q-4 0 -9 7q5 64 35 124q137 142 137 180v17l-2 18h-3q-21 -22 -135 -75q-66 -39 -66 -78q-15 -31 -28 -37h-7q-34 0 -49 18l-5 -3h-17q-33 0 -58 43q-14 27 -14 49v11 q0 17 94 209q0 46 19 57q0 5 45 75q-19 61 -18 93v19h3q29 -11 104 -94q25 0 29 33q22 56 38 64zM437 560q-19 -34 -30 -76q-33 -13 -40 -12q-59 67 -86 83v-3q0 -23 19 -83v-3q-67 -102 -68 -115q0 -35 -35 -92q-59 -121 -58 -142q17 -75 58 -75q3 0 3 -3q14 0 38 37h5 q6 -1 6 -5v-6q-20 -27 -20 -29q12 -11 43 -11q13 24 33 71q40 36 174 101q40 41 41 94q-2 5 -2 11v16q0 5 4 5h3q4 0 8 -8v-26q0 -51 -18 -73q11 -19 10 -48q0 -46 -118 -167q-38 -34 -51 -107l-2 -24h185q0 11 45 56l57 64h3q8 -81 7 -120h183q-16 321 -48 370 q-26 78 -127 189q-62 56 -115 55h-16q-20 0 -38 -15q-4 0 -32 69q-16 21 -19 22h-2zM332 386q5 -3 8 -3v-8q-37 -49 -51 -49l-6 8v3q30 27 46 49h3zM163 114h2q4 0 9 -8v-2q0 -4 -14 -14h-3q-4 0 -8 8q9 16 14 16z" />
</g>}

set truetype_Aquarium(wp) {
<g scidb:bbox="241,-127,735,582">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
  d="M488 582q92 -14 92 -83q0 -49 -49 -72v-6q51 0 105 -72q11 -25 10 -54q0 -53 -69 -100q77 -30 132 -115q26 -64 26 -161v-32q0 -12 -78 -14h-338q-78 0 -78 17q0 193 65 241q62 59 91 61v3q-70 40 -70 100v14q0 81 121 115v3q-51 22 -51 75q0 65 91 80zM413 493 q12 -62 72 -61h14q64 15 64 59v16q0 49 -72 59h-6q-57 0 -72 -59v-14zM341 295q0 -60 91 -100v-5q-77 -21 -126 -81q-48 -52 -48 -176v-36q0 -11 91 -10h279q92 0 92 10v48q0 188 -175 247v3q75 39 80 76q4 0 9 29q0 79 -116 110q-26 3 -40 3q-83 0 -132 -78q-5 -25 -5 -40z
" />
</g>}

set truetype_Aquarium(bk) {
<g scidb:bbox="113,-146,863,616" scidb:scale="1.1">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M489 616h3q5 -1 5 -5v-64h65q6 -1 5 -6v-3q0 -5 -5 -5h-65v-81q56 0 75 -54q3 -11 3 -18q0 -30 -18 -80q64 72 150 72h14q89 0 129 -75q13 -33 12 -60q0 -92 -120 -166l-24 -89q4 0 32 -32v-29q-49 -67 -258 -67q-237 0 -258 64q-4 0 -7 17q0 18 37 55l-25 73 q-126 73 -126 174v14q0 85 75 118q35 11 68 11h18q73 0 148 -69v1q-19 41 -19 65q21 75 76 75h5v81h-73q-5 0 -5 5v3q1 6 5 6h68q6 0 5 5v59q0 5 5 5zM234 243q0 -39 89 -89l43 -40q14 3 24 3q1 -6 6 -6h4l-2 6v2h13q6 0 6 6q-103 126 -118 126q-25 8 -38 8q-27 0 -27 -16z M567 119v-2q17 0 19 -9l6 3h5l18 -3q47 51 116 97q16 14 16 35v6q0 9 -35 13q-55 0 -105 -83q-3 -2 -40 -57z" />
</g>}

set truetype_Aquarium(bq) {
<g scidb:bbox="61,-155,915,644" scidb:translate="0,27">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M117 535q24 0 41 -16.5t17 -40.5q0 -34 -31 -49l135 -223v303q-19 5 -31.5 20t-12.5 35q0 23 17 40.5t40 17.5q24 0 41.5 -17t17.5 -41q0 -20 -12.5 -34.5t-29.5 -19.5l103 -290l62 311q-19 5 -31 20t-12 35q0 23 16.5 40.5t41.5 17.5q22 0 39 -17.5t17 -40.5 q0 -20 -12 -35t-32 -20l62 -311l104 290q-18 5 -30 20t-12 34q0 23 17 40.5t41 17.5t40.5 -17t16.5 -41q0 -21 -12.5 -35.5t-32.5 -19.5v-303l137 223q-14 8 -22.5 20t-8.5 29q0 24 17 40.5t40 16.5q22 0 39.5 -16.5t17.5 -40.5q0 -22 -17 -39t-40 -17h-2q-2 -8 -4.5 -19 t-8.5 -29l-34 -126q-20 -70 -31.5 -109.5t-17.5 -59.5t-8.5 -25.5t-3.5 -7.5q-21 -29 -20 -60q0 -9 3 -14.5t9 -12.5q6 -9 12.5 -21.5t6.5 -34.5q0 -15 -17 -24.5t-43 -16t-58.5 -10t-62 -5t-54 -2t-35.5 -0.5q-12 0 -36 0.5t-54.5 2.5t-62.5 5t-58.5 9.5t-43.5 16.5t-17 24 q0 21 6 34t13 22q5 7 8.5 13t3.5 14q0 29 -19 60q-3 5 -10.5 28.5t-18 57.5t-22 75t-22.5 81t-21 75.5t-16 58.5h-2q-22 0 -39 16.5t-17 39.5q0 24 17 40.5t39 16.5zM249 -72q-7 -11 -7 -31q6 9 66.5 22t180.5 13q118 0 178.5 -13t65.5 -22q0 20 -6 31q-23 10 -58.5 15 t-71 8t-65.5 3.5t-43 0.5q-14 0 -44.5 -0.5t-66 -3.5t-71 -8t-58.5 -15zM486 15q79 0 133.5 -9t84.5 -31v5q0 5 0.5 10t1.5 12q-34 22 -88 29.5t-132 7.5q-76 0 -129 -7.5t-87 -29.5q1 -6 1 -11.5v-10.5v-5q30 22 83.5 31t131.5 9zM489 89q32 0 68 -1.5t68.5 -6t59 -13 t38.5 -23.5q2 2 5 8q0 2 5 15q-26 23 -85 34t-159 11q-102 0 -161 -10.5t-85 -34.5q2 -7 3.5 -11t2.5 -6l3 -6q13 15 39 23.5t59 13t69.5 6t69.5 1.5z" />
</g>}

set truetype_Aquarium(br) {
<g scidb:bbox="163,-146,814,581" scidb:translate="0,15">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M228 581h110q5 -1 5 -5v-59h84v48q1 16 8 16h107q5 -1 5 -5v-59h92v56q0 4 7 8h108q6 -1 6 -5v-145q0 -3 -89 -65v-270q0 -3 -3 -3q0 -9 35 -35q37 -53 37 -105v-16q1 -5 6 -5h62q6 -1 5 -6v-65q0 -5 -5 -5h-620q-6 0 -11 -2q-13 5 -14 10v62q0 3 11 9l14 -3h45 q5 0 11 58q17 58 69 97v274q-17 18 -93 70v142q0 4 8 8zM435 361v-271h18v271h-18zM531 361v-271h16v271h-16z" />
</g>}

set truetype_Aquarium(bb) {
<g scidb:bbox="80,-147,896,659" scidb:scale="1.1" scidb:translate="0,10">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M485 659h14q40 0 57 -58q0 -32 -40 -63q80 -37 172 -109q29 -35 29 -92q0 -97 -75 -175q0 -5 40 -97q-32 -40 -59 -40h-41v-3q14 -66 43 -66l81 37q26 6 46 6q83 0 144 -54q-37 -62 -50 -78q-45 32 -100 32q-48 0 -101 -40q-21 -6 -28 -5q-63 0 -123 93q0 -36 -64 -86 q-15 -8 -33 -7q-19 0 -105 42q-19 3 -29 3h-30q-44 0 -93 -32q-3 0 -60 72v3q60 59 164 59q44 0 126 -37h8q21 0 24 51v10h-37q-44 0 -62 40v6q0 4 41 91q-75 83 -75 178q0 111 187 193q0 5 11 5q-37 28 -37 63q10 58 55 58zM483 426v-65q0 -6 -5 -6h-51v-12h51q6 -1 5 -6 v-67h13v67q1 6 6 6h46v12h-46q-6 0 -6 6v65h-13z" />
</g>}

set truetype_Aquarium(bn) {
<g scidb:bbox="125,-146,851,581" scidb:translate="0,23">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M454 220q-1 -7 -46 -48l11 -8q48 35 48 56h-13zM439 581q30 -27 57 -94q20 11 43 11h2q121 0 247 -226q49 -110 49 -241q3 -1 14 -175l-6 -2h-502q-6 0 -6 5q8 88 49 140q123 125 123 163v17l-2 18h-3q-14 -18 -140 -78q-62 -38 -61 -75q-17 -34 -28 -37h-13 q-25 0 -43 18l-13 -3h-3q-52 0 -75 71q-3 10 -3 21v11q0 17 94 209q0 47 19 57q0 5 45 75q-19 62 -18 99v14h6q37 -21 101 -95q25 0 29 33q22 57 38 64zM326 383q0 -9 -43 -51q0 -4 9 -9q38 30 48 52q0 4 -14 8zM149 96l11 -9l14 17q0 4 -9 7q-4 1 -16 -15zM238 96 q-24 -35 -38 -60h6q7 0 32 38h2q6 -3 9 -3q0 -8 -20 -38l9 -5l30 46v2q-21 20 -30 20zM541 -128v-5h110q-8 83 -7 118h-3z" />
</g>}

set truetype_Aquarium(bp) {
<g scidb:bbox="241,-146,736,562">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M491 562q89 -14 89 -83q0 -50 -49 -72q0 -5 38 -16q77 -43 77 -108v-3q0 -63 -69 -101q46 -24 65 -40q94 -65 93 -237v-35q0 -12 -78 -13h-338q-78 0 -78 16q0 191 65 241q59 57 91 62v3q-70 44 -70 94v19q0 81 121 115v3q-51 22 -51 75q0 52 65 76q13 4 29 4z" />
</g>}

set truetype_Aquarium(wk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M486 613h3q5 -1 5 -5v-64h63q5 -1 5 -6v-2q0 -6 -5 -6h-63v-80q78 -15 78 -67q-3 -32 -10 -68q64 60 139 60h14q122 0 147 -113q3 -18 3 -35q0 -68 -75 -129q-62 -36 -61 -65q-14 -44 -14 -55q4 0 32 -33v-24q-21 -36 -89 -51q-70 -17 -153 -16h-37q-213 0 -239 64l-3 6 v13q0 15 35 48v3q-20 83 -40 83q-110 67 -111 172q0 134 157 134q83 0 155 -75v-2h3v2q-21 41 -22 59v19q0 48 73 70h5v80h-70q-5 0 -5 6v2q0 6 5 6h70v64q0 5 5 5zM849 216z" />
</g>}

set truetype_Aquarium(wq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M485 590h9q48 -7 48 -49v-5q0 -36 -43 -49q49 -290 57 -300l5 -3q18 12 78 220q2 0 21 62q-35 15 -35 49q8 47 49 47h5q49 -7 49 -47q-10 -52 -46 -52h-5q6 -292 18 -292q19 31 123 233q-23 17 -23 43v5q0 40 54 52q51 -10 50 -49v-11q0 -44 -59 -48h-8 q-55 -328 -69 -328q-46 -41 -46 -58v-17q0 -15 35 -72v-6q0 -49 -226 -61h-38q-201 0 -255 48l-3 13q38 73 39 81q-6 21 -71 91l-61 307q-57 5 -57 50q9 51 51 51h3q43 0 49 -56v-2q0 -14 -28 -41l137 -236h3q6 17 6 24v274h-6q-40 0 -48 51q0 51 45 51h11q49 0 49 -56 q0 -20 -33 -46q86 -264 100 -276q12 0 48 227q2 3 16 78q-43 12 -43 40v20q0 37 45 43zM266 -55zM244 -90zM735 -87z" />
</g>}

set truetype_Aquarium(wr,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M228 581h107q4 0 8 -8v-56h84v56q0 4 8 8h104q4 0 8 -8v-56h92v56q0 4 7 8h105q4 0 9 -8v-142q0 -3 -89 -65q-3 -15 -3 -23v-256q72 -58 72 -134v-21h68q6 -1 5 -6v-65q0 -4 -8 -7h-634q-4 0 -8 7v65q1 6 6 6h69v7q0 93 75 148v267q0 18 -67 55l-26 25v139q0 4 8 8z" />
</g>}

set truetype_Aquarium(wb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M485 659h14q40 0 57 -58q0 -32 -40 -63q80 -37 172 -109q29 -35 29 -92q0 -97 -75 -175q0 -5 40 -97q-32 -40 -59 -40h-41v-3q15 -66 43 -66l81 37q26 6 46 6q84 0 144 -54q-36 -61 -50 -78q-47 32 -97 32q-51 0 -104 -40q-21 -6 -28 -5q-63 0 -123 93q0 -32 -62 -86 q-21 -8 -35 -7q-19 0 -105 42q-19 3 -29 3h-30q-44 0 -93 -32q-3 0 -60 72v3q60 59 164 59q44 0 126 -37h8q21 0 24 51v10h-37q-44 0 -62 40v6q0 4 41 91q-75 83 -75 178q0 111 187 193q0 5 11 5q-37 28 -37 63q10 58 55 58z" />
</g>}

set truetype_Aquarium(wn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M439 584q30 -27 57 -94q20 11 43 11h2q121 0 247 -226q49 -109 49 -242q3 0 14 -177l-6 -2h-499q-4 0 -9 7q5 64 35 124q137 142 137 180v17l-2 18h-3q-21 -22 -135 -75q-66 -39 -66 -78q-15 -31 -28 -37h-7q-34 0 -49 18l-5 -3h-17q-33 0 -58 43q-14 27 -14 49v11 q0 17 94 209q0 46 19 57q0 5 45 75q-19 61 -18 93v19h3q29 -11 104 -94q25 0 29 33q22 56 38 64z" />
</g>}

set truetype_Aquarium(wp,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M488 582q92 -14 92 -83q0 -49 -49 -72v-6q51 0 105 -72q11 -25 10 -54q0 -53 -69 -100q77 -30 132 -115q26 -64 26 -161v-32q0 -12 -78 -14h-338q-78 0 -78 17q0 193 65 241q62 59 91 61v3q-70 40 -70 100v14q0 81 121 115v3q-51 22 -51 75q0 65 91 80z" />
</g>}

set truetype_Aquarium(bk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M489 616h3q5 -1 5 -5v-64h65q6 -1 5 -6v-3q0 -5 -5 -5h-65v-81q56 0 75 -54q3 -11 3 -18q0 -30 -18 -80q64 72 150 72h14q89 0 129 -75q13 -33 12 -60q0 -92 -120 -166l-24 -89q4 0 32 -32v-29q-49 -67 -258 -67q-237 0 -258 64q-4 0 -7 17q0 18 37 55l-25 73 q-126 73 -126 174v14q0 85 75 118q35 11 68 11h18q73 0 148 -69v1q-19 41 -19 65q21 75 76 75h5v81h-73q-5 0 -5 5v3q1 6 5 6h68q6 0 5 5v59q0 5 5 5z" />
</g>}

set truetype_Aquarium(bq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M117 535q24 0 41 -16.5t17 -40.5q0 -34 -31 -49l135 -223v303q-19 5 -31.5 20t-12.5 35q0 23 17 40.5t40 17.5q24 0 41.5 -17t17.5 -41q0 -20 -12.5 -34.5t-29.5 -19.5l103 -290l62 311q-19 5 -31 20t-12 35q0 23 16.5 40.5t41.5 17.5q22 0 39 -17.5t17 -40.5 q0 -20 -12 -35t-32 -20l62 -311l104 290q-18 5 -30 20t-12 34q0 23 17 40.5t41 17.5t40.5 -17t16.5 -41q0 -21 -12.5 -35.5t-32.5 -19.5v-303l137 223q-14 8 -22.5 20t-8.5 29q0 24 17 40.5t40 16.5q22 0 39.5 -16.5t17.5 -40.5q0 -22 -17 -39t-40 -17h-2q-2 -8 -4.5 -19 t-8.5 -29l-34 -126q-20 -70 -31.5 -109.5t-17.5 -59.5t-8.5 -25.5t-3.5 -7.5q-21 -29 -20 -60q0 -9 3 -14.5t9 -12.5q6 -9 12.5 -21.5t6.5 -34.5q0 -15 -17 -24.5t-43 -16t-58.5 -10t-62 -5t-54 -2t-35.5 -0.5q-12 0 -36 0.5t-54.5 2.5t-62.5 5t-58.5 9.5t-43.5 16.5t-17 24 q0 21 6 34t13 22q5 7 8.5 13t3.5 14q0 29 -19 60q-3 5 -10.5 28.5t-18 57.5t-22 75t-22.5 81t-21 75.5t-16 58.5h-2q-22 0 -39 16.5t-17 39.5q0 24 17 40.5t39 16.5z" />
</g>}

set truetype_Aquarium(br,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M228 581h110q5 -1 5 -5v-59h84v48q1 16 8 16h107q5 -1 5 -5v-59h92v56q0 4 7 8h108q6 -1 6 -5v-145q0 -3 -89 -65v-270q0 -3 -3 -3q0 -9 35 -35q37 -53 37 -105v-16q1 -5 6 -5h62q6 -1 5 -6v-65q0 -5 -5 -5h-620q-6 0 -11 -2q-13 5 -14 10v62q0 3 11 9l14 -3h45 q5 0 11 58q17 58 69 97v274q-17 18 -93 70v142q0 4 8 8z" />
</g>}

set truetype_Aquarium(bb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M485 659h14q40 0 57 -58q0 -32 -40 -63q80 -37 172 -109q29 -35 29 -92q0 -97 -75 -175q0 -5 40 -97q-32 -40 -59 -40h-41v-3q14 -66 43 -66l81 37q26 6 46 6q83 0 144 -54q-37 -62 -50 -78q-45 32 -100 32q-48 0 -101 -40q-21 -6 -28 -5q-63 0 -123 93q0 -36 -64 -86 q-15 -8 -33 -7q-19 0 -105 42q-19 3 -29 3h-30q-44 0 -93 -32q-3 0 -60 72v3q60 59 164 59q44 0 126 -37h8q21 0 24 51v10h-37q-44 0 -62 40v6q0 4 41 91q-75 83 -75 178q0 111 187 193q0 5 11 5q-37 28 -37 63q10 58 55 58z" />
</g>}

set truetype_Aquarium(bn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M439 581q30 -27 57 -94q20 11 43 11h2q121 0 247 -226q49 -110 49 -241q3 -1 14 -175l-6 -2h-502q-6 0 -6 5q8 88 49 140q123 125 123 163v17l-2 18h-3q-14 -18 -140 -78q-62 -38 -61 -75q-17 -34 -28 -37h-13q-25 0 -43 18l-13 -3h-3q-52 0 -75 71q-3 10 -3 21v11 q0 17 94 209q0 47 19 57q0 5 45 75q-19 62 -18 99v14h6q37 -21 101 -95q25 0 29 33q22 57 38 64z" />
</g>}

set truetype_Aquarium(bp,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M491 562q89 -14 89 -83q0 -50 -49 -72q0 -5 38 -16q77 -43 77 -108v-3q0 -63 -69 -101q46 -24 65 -40q94 -65 93 -237v-35q0 -12 -78 -13h-338q-78 0 -78 16q0 191 65 241q59 57 91 62v3q-70 44 -70 94v19q0 81 121 115v3q-51 22 -51 75q0 52 65 76q13 4 29 4z" />
</g>}

set truetype_Aquarium(wk,exterior) {
<g>
  <path
    d="M417 364q0 -29 69 -139h3q67 79 68 158q0 46 -74 54q-44 0 -66 -54v-19z" />
  <path
    d="M124 240q0 -103 123 -166q80 34 116 34v3q-5 0 -41 38q-91 52 -91 88v11q1 9 22 9h14q45 0 90 -68q54 -61 54 -72q10 2 70 5v78q0 15 -91 115q-65 49 -129 49q-137 0 -137 -124z" />
  <path
    d="M497 205v-83l67 -8 q54 89 108 134q25 6 40 6h6q21 0 26 -14v-3q0 -34 -89 -86q-43 -39 -43 -45l121 -32q115 75 116 142q3 11 3 19q0 77 -68 110q-31 17 -72 16h-8q-114 0 -193 -139q-4 0 -14 -17z" />
  <path
    d="M253 61q24 -73 24 -82q-38 -34 -38 -40v-7q62 43 226 43h49q152 0 216 -49h3v6q0 12 -35 46v1 q21 73 22 82q-135 46 -239 45h-8q-119 1 -220 -45z" />
  <path
    d="M247 -90q51 -43 239 -43h8q154 0 224 40v8q-15 35 -229 46q-242 -8 -242 -51z" />
</g>}

set truetype_Aquarium(wq,exterior) {
<g>
  <path
    d="M453 547v-14q0 -27 38 -32q37 8 37 37q0 38 -43 38q-32 -6 -32 -29z" />
  <path
    d="M478 562h21q19 -11 19 -32q-9 -24 -27 -24h-6q-25 0 -26 35q5 15 19 21z" />
  <path
    d="M642 520v-11q0 -12 15 -27l6 2h5q0 -8 20 -7q26 14 26 40q-10 32 -35 32h-5q-32 -7 -32 -29z" />
  <path
    d="M263 520v-16q8 -32 32 -32h3v2 q-19 0 -25 27v5q0 21 30 27q27 -8 27 -27v-5q0 -10 -11 -22h3q13 14 13 25v13q-6 30 -32 30h-5q-35 -4 -35 -27z" />
  <path
    d="M679 541q16 -5 21 -19v-18q-12 -20 -29 -20q-24 10 -25 28v3q1 23 33 26z" />
  <path
    d="M808 447q14 26 32 27q30 -4 30 -30q0 -29 -35 -29v-3h19q32 7 32 38v5q-7 32 -32 32 h-11q-29 0 -35 -40z" />
  <path
    d="M97 450v-11q0 -17 12 -21l-2 13v6q5 26 27 26h3q26 0 26 -32h3l3 13q-9 38 -35 38h-5q-32 -7 -32 -32z" />
  <path
    d="M488 450q-48 -293 -64 -293q-29 15 -72 166q-8 11 -33 95h-3v-221q-10 -69 -18 -69q-15 17 -135 227h-2v-1q45 -246 54 -264q18 -21 21 -22 q136 32 252 33q109 0 253 -33q22 19 32 78q0 11 38 208v1h-3q-90 -185 -119 -214h-1q-21 32 -22 257q-3 0 -3 28h-3q-73 -250 -89 -250q-9 -16 -12 -16q-22 0 -49 194q-3 1 -19 96h-3z" />
  <path
    d="M247 55q34 -41 34 -59q0 -12 -18 -51h3q71 26 230 27q138 0 226 -27q-21 37 -22 59 q0 21 28 51q-124 30 -232 30h-21q-104 0 -228 -30z" />
  <path
    d="M244 -90q75 -43 244 -43q225 9 247 43v3q-15 32 -219 43h-22q-250 -10 -250 -46z" />
</g>}

set truetype_Aquarium(wr,exterior) {
<g>
  <path
    d="M235 565v-126l84 -62q67 -2 99 -2h135q39 0 107 2l83 60v128h-89v-45q0 -14 -8 -16h-107q-5 0 -5 5v56h-92v-53q0 -4 -7 -8h-100q-5 0 -5 5v43l-3 13h-92z" />
  <path
    d="M327 361v-274h69v274h-69z" />
  <path
    d="M416 361v-274h142v274h-142z" />
  <path
    d="M577 361v-274h77v274h-77z" />
  <path
    d="M252 -68h476v3 q0 98 -71 139h-327q-26 0 -62 -62q-11 -18 -16 -80z" />
  <path
    d="M180 -82v-48h620v48h-620z" />
</g>}

set truetype_Aquarium(wb,exterior) {
<g>
  <path
    d="M456 601q6 -41 35 -41h3q23 0 34 35q-12 35 -37 35h-3q-22 0 -32 -29z" />
  <path
    d="M295 334q0 -76 72 -158q57 17 108 16h35q50 0 110 -19q0 6 37 54q24 43 28 56l-3 6q8 13 7 54q0 69 -90 115q-21 16 -105 62q-25 0 -159 -91q-40 -39 -40 -95z" />
  <path
    d="M333 68q13 -16 26 -15h62q6 -14 41 -20 q13 0 32 -8q66 11 75 25l33 3h34q27 6 27 21q-35 83 -46 83q-63 21 -129 22q-121 -8 -121 -30q-34 -72 -34 -81z" />
  <path
    d="M430 22v-21q0 -47 -46 -64h-11q-17 0 -81 30q-27 5 -54 8q-72 0 -120 -38q23 -28 24 -35q54 23 81 24h46q39 0 115 -43q6 0 11 -2q47 0 88 104q2 0 2 3v24 q-36 11 -53 10h-2z" />
  <path
    d="M502 12v-24q13 -13 32 -53q48 -54 83 -54q21 3 62 32q36 13 70 13t91 -22v3l19 28v4q-49 32 -110 33q-45 0 -100 -37l-18 -6h-14q-41 0 -61 89v3q-8 0 -54 -9z" />
</g>}

set truetype_Aquarium(wn,exterior) {
<g>
  <path
    d="M437 560q-19 -34 -30 -76q-33 -13 -40 -12q-59 67 -86 83v-3q0 -23 19 -83v-3q-67 -102 -68 -115q0 -35 -35 -92q-59 -121 -58 -142q17 -75 58 -75q3 0 3 -3q14 0 38 37h5q6 -1 6 -5v-6q-20 -27 -20 -29q12 -11 43 -11q13 24 33 71q40 36 174 101q40 41 41 94q-2 5 -2 11 v16q0 5 4 5h3q4 0 8 -8v-26q0 -51 -18 -73q11 -19 10 -48q0 -46 -118 -167q-38 -34 -51 -107l-2 -24h185q0 11 45 56l57 64h3q8 -81 7 -120h183q-16 321 -48 370q-26 78 -127 189q-62 56 -115 55h-16q-20 0 -38 -15q-4 0 -32 69q-16 21 -19 22h-2z" />
</g>}

set truetype_Aquarium(wp,exterior) {
<g>
  <path
    d="M413 493q12 -62 72 -61h14q64 15 64 59v16q0 49 -72 59h-6q-57 0 -72 -59v-14z" />
  <path
    d="M341 295q0 -60 91 -100v-5q-77 -21 -126 -81q-48 -52 -48 -176v-36q0 -11 91 -10h279q92 0 92 10v48q0 188 -175 247v3q75 39 80 76q4 0 9 29q0 79 -116 110q-26 3 -40 3q-83 0 -132 -78 q-5 -25 -5 -40z" />
</g>}

set truetype_Aquarium(bk,exterior) $truetype_Aquarium(bk,mask)
set truetype_Aquarium(bq,exterior) $truetype_Aquarium(bq,mask)
set truetype_Aquarium(br,exterior) $truetype_Aquarium(br,mask)
set truetype_Aquarium(bb,exterior) $truetype_Aquarium(bb,mask)
set truetype_Aquarium(bn,exterior) $truetype_Aquarium(bn,mask)
set truetype_Aquarium(bp,exterior) $truetype_Aquarium(bp,mask)

set truetype_Aquarium(bk,interior) {
<g>
  <path
    style="fill:white;stroke:none;fill-rule:evenodd"
    d="M234 243q0 -39 89 -89l43 -40q14 3 24 3q1 -6 6 -6h4l-2 6v2h13q6 0 6 6q-103 126 -118 126q-25 8 -38 8q-27 0 -27 -16z" />
  <path
    style="fill:white;stroke:none"
    d="M567 119v-2q17 0 19 -9l6 3h5l18 -3q47 51 116 97q16 14 16 35v6q0 9 -35 13q-55 0 -105 -83q-3 -2 -40 -57z" />
</g>}

set truetype_Aquarium(bq,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M249 -72q-7 -11 -7 -31q6 9 66.5 22t180.5 13q118 0 178.5 -13t65.5 -22q0 20 -6 31q-23 10 -58.5 15t-71 8t-65.5 3.5t-43 0.5q-14 0 -44.5 -0.5t-66 -3.5t-71 -8t-58.5 -15z" />
  <path
    style="fill:white;stroke:none"
    d="M486 15q79 0 133.5 -9t84.5 -31v5q0 5 0.5 10t1.5 12q-34 22 -88 29.5t-132 7.5 q-76 0 -129 -7.5t-87 -29.5q1 -6 1 -11.5v-10.5v-5q30 22 83.5 31t131.5 9z" />
  <path
    style="fill:white;stroke:none"
    d="M489 89q32 0 68 -1.5t68.5 -6t59 -13t38.5 -23.5q2 2 5 8q0 2 5 15q-26 23 -85 34t-159 11q-102 0 -161 -10.5t-85 -34.5q2 -7 3.5 -11t2.5 -6l3 -6q13 15 39 23.5t59 13t69.5 6t69.5 1.5z" />
</g>}

set truetype_Aquarium(br,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M435 361v-271h18v271h-18z" />
  <path
    style="fill:white;stroke:none"
    d="M531 361v-271h16v271h-16z" />
</g>}

set truetype_Aquarium(bb,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M483 426v-65q0 -6 -5 -6h-51v-12h51q6 -1 5 -6v-67h13v67q1 6 6 6h46v12h-46q-6 0 -6 6v65h-13z" />
</g>}

set truetype_Aquarium(bn,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M454 220q-1 -7 -46 -48l11 -8q48 35 48 56h-13z" />
  <path
    style="fill:white;stroke:none"
    d="M326 383q0 -9 -43 -51q0 -4 9 -9q38 30 48 52q0 4 -14 8z" />
  <path
    style="fill:white;stroke:none"
    d="M149 96l11 -9l14 17q0 4 -9 7q-4 1 -16 -15z" />
  <path
    style="fill:white;stroke:none"
    d="M238 96q-24 -35 -38 -60h6q7 0 32 38h2q6 -3 9 -3q0 -8 -20 -38l9 -5l30 46v2q-21 20 -30 20z" />
  <path
    style="fill:white;stroke:none"
    d="M541 -128v-5h110 q-8 83 -7 118h-3z" />
</g>}

set truetype_Aquarium(bp,interior) {}

set truetype_Aquarium(sample,24pt,200x34) {
  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
  EK8WLpyyAAAAAElFTkSuQmCC
}

# vi:set ts=2 sw=2 et nowrap:
