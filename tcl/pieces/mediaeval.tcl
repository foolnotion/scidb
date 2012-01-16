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

lappend board_PieceSet { Mediaeval truetype {stroke 5} {contour 80} {sampling 100} {overstroke 5} }

set truetype_Mediaeval(wk) "
<g
  scidb:bbox=\"197,139,1854,1870\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1667 649v68h-641h-642v-68q0 -65 64 -68h578h575q66 0 66 68zM1738 649q0 -58 -41.5 -97.5t-96.5 -38.5h-199v-135q55 0 95 -41.5t40 -97.5v-100h-1024v100q0 56 39.5 97t95.5 42v135h-199q-57 0 -96 39.5t-39 94.5l-1 141l-104 576q-11 34 -11 70q0 112 79.5 192 t191.5 80q38 0 78 -12l308 -82q19 30 50 52q-51 33 -51 85q0 50 50 85.5t121 35.5q70 0 120 -35.5t50 -85.5q0 -48 -46 -83q32 -27 49 -54l308 82q39 12 78 12q111 0 191 -80t80 -192q0 -36 -11 -70l-105 -576v-139zM1024 1809q-85 0 -85 -60q0 -61 85 -61q84 0 84 61 q0 60 -84 60zM1667 788l108 583q10 31 10 63q0 84 -59 143.5t-143 59.5q-29 0 -57 -9l-299 -83q6 -26 5 -50l125 31q39 12 75 12q84 0 145 -60.5t61 -145.5q0 -40 -16 -81l-83 -463h128zM1026 788h72l60 672q-1 11 0 19.5t1 17.5q0 54 -39 93t-94 39q-57 0 -95.5 -39 t-38.5 -93q0 -9 0.5 -17.5t0.5 -19.5l60 -672h73zM857 1101q-187 -58 -293 -224l17 -89h300zM1486 873q-104 165 -288 226l-28 -311h300zM549 972q120 145 301 199l-22 243l-150 44q-31 13 -58 13q-58 0 -98.5 -41t-40.5 -98q0 -29 13 -63zM1503 963l54 306q13 34 13 63 q0 57 -40.5 98t-97.5 41q-29 0 -59 -13l-150 -44l-19 -246q182 -56 299 -205zM384 788h128l-83 463q-16 41 -16 81q0 85 60.5 145.5t146.5 60.5q35 0 74 -12l125 -31q-2 24 5 50l-299 83q-29 9 -57 9q-84 0 -143 -59.5t-59 -143.5q0 -32 10 -63zM718 513v-135h612v135h-612z M580 239v-33h888v33q0 71 -67 71h-754q-67 0 -67 -71z\" />
</g>"

set truetype_Mediaeval(wq) "
<g
  scidb:bbox=\"71,135,2005,1888\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1866 1482q-58 0 -98.5 40.5t-40.5 98.5q0 57 40.5 98t98.5 41q57 0 98 -41t41 -98q0 -58 -41 -98.5t-98 -40.5zM1633 749h-1207l16 -66q17 -59 61.5 -92.5t93.5 -23.5h434h426q49 -10 96.5 23.5t65.5 92.5zM1665 885h-1268l15 -69h1238zM1679 952l83 385l-84 -246 q-9 -45 -42.5 -77.5t-83.5 -29.5q-51 3 -84.5 43.5t-28.5 91.5l-18 375l-59 -363q0 -63 -39.5 -107t-94.5 -44q-56 0 -95 42.5t-36 98.5l-70 441l-63 -441q1 -56 -38 -98.5t-93 -42.5q-56 0 -95 44t-39 107l-53 363l-24 -375q3 -51 -30 -91.5t-83 -43.5q-51 -3 -85 29.5 t-42 77.5l-84 246l85 -385h1296zM1030 1681q68 0 68 68t-68 68t-68 -68t68 -68zM1030 1610q-58 0 -98.5 41t-40.5 98t40.5 98t98.5 41q57 0 98 -41t41 -98t-41 -98t-98 -41zM1436 1618q68 0 68 68q0 67 -68 67t-68 -67q0 -68 68 -68zM1436 1546q-58 0 -98.5 41t-40.5 99 q0 57 40.5 98t98.5 41q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM1866 1553q68 0 68 68t-68 68t-68 -68t68 -68zM617 1620q67 0 67 68t-67 68q-68 0 -68 -68t68 -68zM617 1548q-58 0 -99 41t-41 99q0 57 41 98t99 41q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM211 1560 q67 0 67 68t-67 68q-68 0 -68 -68t68 -68zM211 1489q-58 0 -99 41t-41 98t41 98t99 41q57 0 98 -41t41 -98t-41 -98t-98 -41zM718 499v-125h612v125h-612zM512 237q0 57 39.5 97t95.5 40v125h-50q-67 -9 -130.5 34.5t-86.5 130.5l-174 816q43 2 82 26l153 -392q5 -67 65 -63 q62 3 55 70l16 426q22 -4 40 -4q41 0 83 25l62 -433q6 -81 71 -81t67 71l59 502q28 -22 67 -22q46 0 77 25l57 -505q1 -71 68 -71q64 0 70 81l67 428q34 -20 71 -20q14 0 50 6l14 -428q-8 -67 55 -70q59 -4 65 63l156 398q39 -29 86 -33l-181 -815q-24 -87 -90.5 -130.5 t-133.5 -34.5h-56v-125q55 0 95 -40t40 -97v-102h-1024v102zM1468 238q0 68 -67 68h-753q-68 0 -68 -68v-35h888v35z\" />
</g>"

set truetype_Mediaeval(wr) "
<g
  scidb:bbox=\"412,135,1639,1910\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M889 374v272l-251 -1l-26 -153l-113 -118h390zM956 1842v-275h135v275h-135zM1026 1367h307l101 136h-408h-408l100 -136h308zM615 1842v-275h103v275h-103zM1026 203h549v103h-549h-550v-103h550zM1436 1842h-103v-275h103v275zM650 716l239 1q0 55 39 95t96 40 q55 0 95 -40t40 -95l242 -1l-102 594h-273h-274zM1159 646l2 -272h391l-112 118l-27 153zM1504 1842v-339l-135 -208l135 -782l135 -139v-239h-613h-614v239l136 139l135 782l-135 208v339q0 67 68 67h103q67 0 67 -71v-271h103v273q0 69 68 69l69 1l68 -1q68 0 68 -68v-274 h103v275q0 67 69 67h103q67 0 67 -67z\" />
</g>"

set truetype_Mediaeval(wb) "
<g
  scidb:bbox=\"273,135,1798,1890\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1442 665l12.5 10.5l11.5 9.5q172 140 208.5 381t-83.5 442q-84 138 -213.5 201.5t-264.5 45.5q194 -48 324.5 -231t130.5 -425q0 -171 -67 -320q-37 -54 -59 -114zM707 742q140 6 258 104q110 90 167 226.5t55 283.5q-89 -102 -207.5 -155t-250.5 -39q-90 10 -168 50 l-170 19q-61 -224 35 -431q136 -71 281 -58zM580 1284q74 -42 160 -51q126 -13 238 41t193 155q-58 40 -94 47q-187 79 -242 322q-118 -42 -190.5 -186t-64.5 -328zM1300 374q-6 61 5 136q12 91 40.5 151t68.5 130q73 142 73 308q0 246 -149.5 421t-358.5 175q-20 0 -29 -1 q57 -102 147 -146q94 -26 163 -107q18 -185 -45 -362.5t-201 -290.5q-119 -99 -266 -114q-76 -7 -139 0q49 -43 91 -126t57 -174h543zM1433 239q0 67 -68 67h-681q-69 0 -69 -69v-34h818v36zM674 368q-7 97 -66.5 172.5t-103.5 150.5q-78 17 -149 62q-62 128 -72 272t29 279 l189 -20q-12 237 99.5 416t284.5 190q3 -44 21 -119q193 102 407 42t343 -261q142 -225 99 -496t-247 -428q-47 -36 -97 -61l-18 -40t-11 -56q-3 -31 -4 -53t-4 -49q48 3 87 -36t39 -94v-104h-952v104q0 52 38 92.5t88 36.5z\" />
</g>"

set truetype_Mediaeval(wn) "
<g
  scidb:bbox=\"336,135,1688,1896\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1435 238q0 68 -68 68h-682q-68 0 -68 -68v-35h818v35zM1365 374q57 0 97.5 -39.5t40.5 -96.5v-103h-953v103q0 56 36 96t97 40q15 12 15 16q0 102 -59 175q-58 -26 -120 -15q-84 15 -133.5 85t-31.5 155l69 548q-28 39 -45 72q16 182 100 344q-9 86 0 142 q160 -91 324 -114q53 -11 106 -28q74 4 160 -11q88 -16 171 -49.5t173 -81.5q143 -30 188 -148q29 -84 -1 -167q89 -70 89 -183q0 -91 -66 -176q43 -144 -37 -239q-54 -96 -135 -169q-72 -57 -85 -156zM1432 728q-5 -28 -41 -18q-34 8 -25 42q7 20 12 40.5t11 38.5 q9 27 46 20q37 -10 24 -36q-16 -54 -27 -87zM1427 1010q0 19 -1.5 36.5t-1.5 38.5q6 35 42 32q35 -8 28 -35q2 -31 0 -86q-4 -26 -38 -24q-33 1 -29 38zM730 1555q36 -21 -18 -117q-56 -96 -93 -75t19 117q55 97 92 75zM1298 374q20 170 155 249q-117 -23 -205 47 q-31 6 -15 42q16 32 51 16q57 -47 128 -41t117 60q55 68 32 152q-60 -24 -112 -24q-70 0 -133 41q-37 17 -23 49q16 33 51 15q49 -37 105 -37q70 0 120.5 50t50.5 121q0 70 -53 122q-50 -56 -110 -78q-68 -24 -139 -7q-41 6 -35 42q7 33 43 27q54 -18 108 2q66 24 96 88 t6 131q-25 67 -103 107q12 -38 20 -86q-6 -118 -68 -182q-49 -49 -123 -67q-38 -14 -50 21q-13 34 25 46q59 7 100 48q49 49 49.5 120t-46.5 119q-120 79 -258 108q140 -82 244 -208q26 -23 3 -49q-23 -29 -51 -3q-192 231 -483 297q-116 14 -221 60q-25 -32 -46 -74 q-60 -117 -85 -255q13 -29 51 -85l-74 -579q-11 -57 21.5 -104.5t89.5 -57.5q56 -10 103.5 23t57.5 90q4 28 -16 59.5t1 52.5q116 116 216 235.5t141 272.5q8 37 43 31t27 -46q-42 -155 -136.5 -279t-208.5 -235q-18 -18 -7 -47.5t7 -55.5q-12 -69 -63 -115q66 -92 66 -213 q0 -11 -6 -16h542z\" />
</g>"

set truetype_Mediaeval(wp) "
<g
  scidb:bbox=\"547,135,1500,1912\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M754 749h540q-139 126 -181.5 337.5t-53.5 415.5h-71q-12 -202 -54 -414t-180 -339zM1365 678h-682q13 -129 110.5 -218t230.5 -89q132 0 229.5 89t111.5 218zM1433 239q0 67 -68 67h-681q-69 0 -69 -69v-34h818v36zM1024 1841q-57 0 -96 -39.5t-39 -95.5q0 -57 39 -96 t96 -39q55 0 95 39t40 96q0 56 -40 95.5t-95 39.5zM1180 1570h253v-68h-306q12 -216 76 -440t226 -349q0 -102 -51.5 -191.5t-132.5 -146.5l122 -1q54 0 93.5 -40t39.5 -95v-104h-952l-1 102q0 57 40 97t97 40l121 1q-85 58 -139 148.5t-54 189.5q161 125 228 349t81 440 h-306v68h256q-53 57 -53 136q0 85 60 145.5t146 60.5q84 0 145 -60.5t61 -145.5q0 -79 -50 -136z\" />
</g>"

set truetype_Mediaeval(bk) "
<g
  scidb:bbox=\"197,139,1854,1870\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1738 649q0 -58 -41.5 -97.5t-96.5 -38.5h-199v-135q55 0 95 -41.5t40 -97.5v-100h-1024v100q0 56 39.5 97t95.5 42v135h-199q-57 0 -96 39.5t-39 94.5l-1 141l-104 576q-11 34 -11 70q0 112 79.5 192t191.5 80q38 0 78 -12l308 -82q19 30 50 52q-51 33 -51 85 q0 50 50 85.5t121 35.5q70 0 120 -35.5t50 -85.5q0 -48 -46 -83q32 -27 49 -54l308 82q39 12 78 12q111 0 191 -80t80 -192q0 -36 -11 -70l-105 -576v-139zM1023 1675q-98 0 -98 -26t98 -26q97 0 97 26t-97 26zM725 374q-37 0 -37 -34v0q0 -34 37 -34h598q37 0 37 34v0 q0 34 -37 34h-598zM1515 886l59 371q14 38 14 76q0 69 -44.5 118.5t-107.5 49.5q-31 0 -64 -16l-165 -53l-21 -298q199 -66 329 -248zM537 896q135 178 332 240l-25 295l-164 53q-35 16 -65 16q-63 0 -108 -49.5t-45 -118.5q0 -35 15 -76zM418 805q-34 0 -34 -37v0 q0 -38 34 -38h1212q34 0 34 38v0q0 37 -34 37h-1212zM725 578q-37 0 -37 -34v0q0 -34 37 -34h598q37 0 37 34v0q0 34 -37 34h-598z\" />
</g>"

set truetype_Mediaeval(bq) "
<g
  scidb:bbox=\"71,135,2005,1888\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M512 237q0 57 39.5 97t95.5 40v125h-50q-67 -9 -130.5 34.5t-86.5 130.5l-174 816q43 2 82 26l153 -392q5 -67 65 -63q62 3 55 70l16 426q22 -4 40 -4q41 0 83 25l62 -433q6 -81 71 -81t67 71l59 502q28 -22 67 -22q46 0 77 25l57 -505q1 -71 68 -71q64 0 70 81l67 428 q34 -20 71 -20q14 0 50 6l14 -428q-8 -67 55 -70q59 -4 65 63l156 398q39 -29 86 -33l-181 -815q-24 -87 -90.5 -130.5t-133.5 -34.5h-56v-125q55 0 95 -40t40 -97v-102h-1024v102zM211 1489q-58 0 -99 41t-41 98t41 98t99 41q57 0 98 -41t41 -98t-41 -98t-98 -41zM617 1548 q-58 0 -99 41t-41 99q0 57 41 98t99 41q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM1436 1546q-58 0 -98.5 41t-40.5 99q0 57 40.5 98t98.5 41q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM1030 1610q-58 0 -98.5 41t-40.5 98t40.5 98t98.5 41q57 0 98 -41t41 -98t-41 -98 t-98 -41zM1866 1482q-58 0 -98.5 40.5t-40.5 98.5q0 57 40.5 98t98.5 41q57 0 98 -41t41 -98q0 -58 -41 -98.5t-98 -40.5zM728 374q-38 0 -38 -34v0q0 -34 38 -34h597q38 0 38 34v0q0 34 -38 34h-597zM728 557q-38 0 -38 -34v0q0 -34 38 -34h597q38 0 38 34v0q0 34 -38 34 h-597zM481 888q-34 0 -34 -37v0q0 -38 34 -38h1091q34 0 34 38v0q0 37 -34 37h-1091z\" />
</g>"

set truetype_Mediaeval(br) "
<g
  scidb:bbox=\"412,135,1639,1910\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1504 1842v-339l-135 -208l135 -782l135 -139v-239h-613h-614v239l136 139l135 782l-135 208v339q0 67 68 67h103q67 0 67 -71v-271h103v273q0 69 68 69l69 1l68 -1q68 0 68 -68v-274h103v275q0 67 69 67h103q67 0 67 -67zM882 681v-262h284l2 261l199 1q34 0 34 34v0 q0 34 -34 34h-201q0 56 -42 95.5t-100 39.5q-59 0 -100.5 -39.5t-41.5 -95.5h-201q-34 0 -34 -34v0q0 -34 34 -34h201zM581 374q-33 0 -33 -34v0q0 -34 33 -34h892q34 0 34 34v0q0 34 -34 34h-892zM747 1367q-29 0 -29 -29v0q0 -28 29 -28h554q29 0 29 28v0q0 29 -29 29 h-554z\" />
</g>"

set truetype_Mediaeval(bb) "
<g
  scidb:bbox=\"273,135,1798,1890\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1414 645q5 5 25 20q180 139 218.5 380.5t-87.5 441.5q-88 138 -224.5 201.5t-278.5 45.5q204 -48 341.5 -231t137.5 -424q0 -174 -70 -320q-38 -53 -62 -114zM535 1325l-1 -86q66 -33 164 -42q138 -15 263.5 41t221.5 164l-27 72q-83 -104 -202 -160t-251 -42 q-91 9 -168 53zM577 663q72 -4 144 3q153 15 280 119q110 90 176 225l-71 1q-46 -87 -142 -164q-127 -104 -271 -110q-89 -7 -167 14zM727 374q-32 0 -32 -35v-1q0 -35 32 -35h578q32 0 32 35v1q0 35 -32 35h-578zM674 368q-7 97 -66.5 172.5t-103.5 150.5q-78 17 -149 62 q-62 128 -72 272t29 279l189 -20q-12 237 99.5 416t284.5 190q3 -44 21 -119q193 102 407 42t343 -261q142 -225 99 -496t-247 -428q-47 -36 -97 -61l-18 -40t-11 -56q-3 -31 -4 -53t-4 -49q48 3 87 -36t39 -94v-104h-952v104q0 52 38 92.5t88 36.5z\" />
</g>"

set truetype_Mediaeval(bn) "
<g
  scidb:bbox=\"336,135,1688,1896\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M752 374q-34 0 -34 -34v0q0 -34 34 -34h544q34 0 34 34v0q0 34 -34 34h-544zM1365 374q57 0 97.5 -39.5t40.5 -96.5v-103h-953v103q0 56 36 96t97 40q15 12 15 16q0 102 -59 175q-58 -26 -120 -15q-84 15 -133.5 85t-31.5 155l69 548q-28 39 -45 72q16 182 100 344 q-9 86 0 142q160 -91 324 -114q53 -11 106 -28q74 4 160 -11q88 -16 171 -49.5t173 -81.5q143 -30 188 -148q29 -84 -1 -167q89 -70 89 -183q0 -91 -66 -176q43 -144 -37 -239q-54 -96 -135 -169q-72 -57 -85 -156zM1434 723q12 36 30 96q12 27 -27 39q-40 9 -51 -21 q-6 -20 -11.5 -43t-13.5 -45q-9 -38 28 -46q38 -10 45 20zM1422 1006q-5 -40 33 -41q39 -4 44 25q2 40 1 96q7 30 -33 38q-42 5 -48 -35q0 -23 2 -42.5t1 -40.5zM735 1565q-17 9 -47 -15t-54 -67q-26 -44 -32 -82t11 -47q16 -10 46 14t56 68q25 44 31 82t-11 47zM683 599 q57 49 71 119q3 26 -8.5 55.5t7.5 47.5q120 111 207 202.5t131 246.5q11 49 -17 54q-47 8 -54 -25q-43 -153 -137 -247l-216 -210q-22 -21 -0.5 -53t16.5 -59q-9 -50 -55 -85q-33 -31 -3 -55q28 -21 58 9zM1041 1615q136 -80 237 -200q28 -26 51 3q23 26 -3 49 q-106 128 -242 205q-25 18 -48 -8q-22 -28 5 -49zM1374 1247q4 -35 38 -28q37 5 33 33q-8 38 -22 84q0 28 -37 25q-38 -4 -34 -42q5 -19 11 -36t11 -36z\" />
</g>"

set truetype_Mediaeval(bp) "
<g
  scidb:bbox=\"547,135,1500,1912\"
  scidb:scale=\"0.95\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1180 1570h253v-68h-306q12 -216 76 -440t226 -349q0 -102 -51.5 -191.5t-132.5 -146.5l122 -1q54 0 93.5 -40t39.5 -95v-104h-952l-1 102q0 57 40 97t97 40l121 1q-85 58 -139 148.5t-54 189.5q161 125 228 349t81 440h-306v68h256q-53 57 -53 136q0 85 60 145.5 t146 60.5q84 0 145 -60.5t61 -145.5q0 -79 -50 -136zM716 749q-33 0 -33 -34v0q0 -34 33 -34h615q34 0 34 34v0q0 34 -34 34h-615zM869 395q-31 0 -31 -34v0q0 -34 31 -34h310q30 0 30 34v0q0 34 -30 34h-310z\" />
</g>"

set truetype_Mediaeval(wk,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1738 649q0 -58 -41.5 -97.5t-96.5 -38.5h-199v-135q55 0 95 -41.5t40 -97.5v-100h-1024v100q0 56 39.5 97t95.5 42v135h-199q-57 0 -96 39.5t-39 94.5l-1 141l-104 576q-11 34 -11 70q0 112 79.5 192t191.5 80q38 0 78 -12l308 -82q19 30 50 52q-51 33 -51 85 q0 50 50 85.5t121 35.5q70 0 120 -35.5t50 -85.5q0 -48 -46 -83q32 -27 49 -54l308 82q39 12 78 12q111 0 191 -80t80 -192q0 -36 -11 -70l-105 -576v-139zM1023 1675q-98 0 -98 -26t98 -26q97 0 97 26t-97 26zM1515 886l59 371q14 38 14 76q0 69 -44.5 118.5t-107.5 49.5 q-31 0 -64 -16l-165 -53l-21 -298q199 -66 329 -248zM537 896q135 178 332 240l-25 295l-164 53q-35 16 -65 16q-63 0 -108 -49.5t-45 -118.5q0 -35 15 -76z\" />
</g>"

set truetype_Mediaeval(wq,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1866 1482q-58 0 -98.5 40.5t-40.5 98.5q0 57 40.5 98t98.5 41q57 0 98 -41t41 -98q0 -58 -41 -98.5t-98 -40.5zM1030 1610q-58 0 -98.5 41t-40.5 98t40.5 98t98.5 41q57 0 98 -41t41 -98t-41 -98t-98 -41zM1436 1546q-58 0 -98.5 41t-40.5 99q0 57 40.5 98t98.5 41 q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM617 1548q-58 0 -99 41t-41 99q0 57 41 98t99 41q57 0 98 -41t41 -98q0 -58 -41 -99t-98 -41zM211 1489q-58 0 -99 41t-41 98t41 98t99 41q57 0 98 -41t41 -98t-41 -98t-98 -41zM512 237q0 57 39.5 97t95.5 40v125h-50 q-67 -9 -130.5 34.5t-86.5 130.5l-174 816q43 2 82 26l153 -392q5 -67 65 -63q62 3 55 70l16 426q22 -4 40 -4q41 0 83 25l62 -433q6 -81 71 -81t67 71l59 502q28 -22 67 -22q46 0 77 25l57 -505q1 -71 68 -71q64 0 70 81l67 428q34 -20 71 -20q14 0 50 6l14 -428 q-8 -67 55 -70q59 -4 65 63l156 398q39 -29 86 -33l-181 -815q-24 -87 -90.5 -130.5t-133.5 -34.5h-56v-125q55 0 95 -40t40 -97v-102h-1024v102z\" />
</g>"

set truetype_Mediaeval(wr,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1504 1842v-339l-135 -208l135 -782l135 -139v-239h-613h-614v239l136 139l135 782l-135 208v339q0 67 68 67h103q67 0 67 -71v-271h103v273q0 69 68 69l69 1l68 -1q68 0 68 -68v-274h103v275q0 67 69 67h103q67 0 67 -67z\" />
</g>"

set truetype_Mediaeval(wb,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M674 368q-7 97 -66.5 172.5t-103.5 150.5q-78 17 -149 62q-62 128 -72 272t29 279l189 -20q-12 237 99.5 416t284.5 190q3 -44 21 -119q193 102 407 42t343 -261q142 -225 99 -496t-247 -428q-47 -36 -97 -61l-18 -40t-11 -56q-3 -31 -4 -53t-4 -49q48 3 87 -36t39 -94 v-104h-952v104q0 52 38 92.5t88 36.5z\" />
</g>"

set truetype_Mediaeval(wn,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1365 374q57 0 97.5 -39.5t40.5 -96.5v-103h-953v103q0 56 36 96t97 40q15 12 15 16q0 102 -59 175q-58 -26 -120 -15q-84 15 -133.5 85t-31.5 155l69 548q-28 39 -45 72q16 182 100 344q-9 86 0 142q160 -91 324 -114q53 -11 106 -28q74 4 160 -11q88 -16 171 -49.5 t173 -81.5q143 -30 188 -148q29 -84 -1 -167q89 -70 89 -183q0 -91 -66 -176q43 -144 -37 -239q-54 -96 -135 -169q-72 -57 -85 -156z\" />
</g>"

set truetype_Mediaeval(wp,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1180 1570h253v-68h-306q12 -216 76 -440t226 -349q0 -102 -51.5 -191.5t-132.5 -146.5l122 -1q54 0 93.5 -40t39.5 -95v-104h-952l-1 102q0 57 40 97t97 40l121 1q-85 58 -139 148.5t-54 189.5q161 125 228 349t81 440h-306v68h256q-53 57 -53 136q0 85 60 145.5 t146 60.5q84 0 145 -60.5t61 -145.5q0 -79 -50 -136z\" />
</g>"

set truetype_Mediaeval(bk,mask) $truetype_Mediaeval(wk,mask)
set truetype_Mediaeval(bq,mask) $truetype_Mediaeval(wq,mask)
set truetype_Mediaeval(br,mask) $truetype_Mediaeval(wr,mask)
set truetype_Mediaeval(bb,mask) $truetype_Mediaeval(wb,mask)
set truetype_Mediaeval(bn,mask) $truetype_Mediaeval(wn,mask)
set truetype_Mediaeval(bp,mask) $truetype_Mediaeval(wp,mask)

set truetype_Mediaeval(wk,exterior) "
<g>
  <path
    d=\"M718 513v-135h612v135h-612z M580 239v-33h888v33q0 71 -67 71h-754q-67 0 -67 -71z\" />
  <path
    d=\"M384 788h128l-83 463q-16 41 -16 81q0 85 60.5 145.5t146.5 60.5q35 0 74 -12l125 -31q-2 24 5 50l-299 83q-29 9 -57 9q-84 0 -143 -59.5t-59 -143.5q0 -32 10 -63z\" />
  <path
    d=\"M1503 963l54 306q13 34 13 63 q0 57 -40.5 98t-97.5 41q-29 0 -59 -13l-150 -44l-19 -246q182 -56 299 -205z\" />
  <path
    d=\"M549 972q120 145 301 199l-22 243l-150 44q-31 13 -58 13q-58 0 -98.5 -41t-40.5 -98q0 -29 13 -63z\" />
  <path
    d=\"M1486 873q-104 165 -288 226l-28 -311h300z\" />
  <path
    d=\"M857 1101q-187 -58 -293 -224l17 -89h300z\" />
  <path
    d=\"M1026 788h72l60 672q-1 11 0 19.5t1 17.5q0 54 -39 93t-94 39q-57 0 -95.5 -39 t-38.5 -93q0 -9 0.5 -17.5t0.5 -19.5l60 -672h73z\" />
  <path
    d=\"M1667 788l108 583q10 31 10 63q0 84 -59 143.5t-143 59.5q-29 0 -57 -9l-299 -83q6 -26 5 -50l125 31q39 12 75 12q84 0 145 -60.5t61 -145.5q0 -40 -16 -81l-83 -463h128z\" />
  <path
    d=\"M1024 1809q-85 0 -85 -60q0 -61 85 -61q84 0 84 61 q0 60 -84 60z\" />
  <path
    d=\"M1667 649v68h-641h-642v-68q0 -65 64 -68h578h575q66 0 66 68z\" />
</g>"

set truetype_Mediaeval(wq,exterior) "
<g>
  <path
    d=\"M1468 238q0 68 -67 68h-753q-68 0 -68 -68v-35h888v35z\" />
  <path
    d=\"M211 1560 q67 0 67 68t-67 68q-68 0 -68 -68t68 -68z\" />
  <path
    d=\"M617 1620q67 0 67 68t-67 68q-68 0 -68 -68t68 -68z\" />
  <path
    d=\"M1866 1553q68 0 68 68t-68 68t-68 -68t68 -68z\" />
  <path
    d=\"M1436 1618q68 0 68 68q0 67 -68 67t-68 -67q0 -68 68 -68z\" />
  <path
    d=\"M1030 1681q68 0 68 68t-68 68t-68 -68t68 -68z\" />
  <path
    d=\"M1679 952l83 385l-84 -246 q-9 -45 -42.5 -77.5t-83.5 -29.5q-51 3 -84.5 43.5t-28.5 91.5l-18 375l-59 -363q0 -63 -39.5 -107t-94.5 -44q-56 0 -95 42.5t-36 98.5l-70 441l-63 -441q1 -56 -38 -98.5t-93 -42.5q-56 0 -95 44t-39 107l-53 363l-24 -375q3 -51 -30 -91.5t-83 -43.5q-51 -3 -85 29.5 t-42 77.5l-84 246l85 -385h1296z\" />
  <path
    d=\"M1665 885h-1268l15 -69h1238z\" />
  <path
    d=\"M1633 749h-1207l16 -66q17 -59 61.5 -92.5t93.5 -23.5h434h426q49 -10 96.5 23.5t65.5 92.5z\" />
  <path
    d=\"M718 499v-125h612v125h-612z\" />
</g>"

set truetype_Mediaeval(wr,exterior) "
<g>
  <path
    d=\"M1436 1842h-103v-275h103v275z\" />
  <path
    d=\"M615 1842v-275h103v275h-103z\" />
  <path
    d=\"M1026 1367h307l101 136h-408h-408l100 -136h308z\" />
  <path
    d=\"M956 1842v-275h135v275h-135z\" />
  <path
    d=\"M650 716l239 1q0 55 39 95t96 40 q55 0 95 -40t40 -95l242 -1l-102 594h-273h-274z\" />
  <path
    d=\"M1159 646l2 -272h391l-112 118l-27 153z\" />
  <path
    d=\"M889 374v272l-251 -1l-26 -153l-113 -118h390z\" />
  <path
    d=\"M1026 203h549v103h-549h-550v-103h550z\" />
</g>"

set truetype_Mediaeval(wb,exterior) "
<g>
  <path
    d=\"M1433 239q0 67 -68 67h-681q-69 0 -69 -69v-34h818v36z\" />
  <path
    d=\"M1300 374q-6 61 5 136q12 91 40.5 151t68.5 130q73 142 73 308q0 246 -149.5 421t-358.5 175q-20 0 -29 -1 q57 -102 147 -146q94 -26 163 -107q18 -185 -45 -362.5t-201 -290.5q-119 -99 -266 -114q-76 -7 -139 0q49 -43 91 -126t57 -174h543z\" />
  <path
    d=\"M580 1284q74 -42 160 -51q126 -13 238 41t193 155q-58 40 -94 47q-187 79 -242 322q-118 -42 -190.5 -186t-64.5 -328z\" />
  <path
    d=\"M707 742q140 6 258 104q110 90 167 226.5t55 283.5q-89 -102 -207.5 -155t-250.5 -39q-90 10 -168 50 l-170 19q-61 -224 35 -431q136 -71 281 -58z\" />
  <path
    d=\"M1442 665l12.5 10.5l11.5 9.5q172 140 208.5 381t-83.5 442q-84 138 -213.5 201.5t-264.5 45.5q194 -48 324.5 -231t130.5 -425q0 -171 -67 -320q-37 -54 -59 -114z\" />
</g>"

set truetype_Mediaeval(wn,exterior) "
<g>
  <path
    d=\"M1298 374q20 170 155 249q-117 -23 -205 47 q-31 6 -15 42q16 32 51 16q57 -47 128 -41t117 60q55 68 32 152q-60 -24 -112 -24q-70 0 -133 41q-37 17 -23 49q16 33 51 15q49 -37 105 -37q70 0 120.5 50t50.5 121q0 70 -53 122q-50 -56 -110 -78q-68 -24 -139 -7q-41 6 -35 42q7 33 43 27q54 -18 108 2q66 24 96 88 t6 131q-25 67 -103 107q12 -38 20 -86q-6 -118 -68 -182q-49 -49 -123 -67q-38 -14 -50 21q-13 34 25 46q59 7 100 48q49 49 49.5 120t-46.5 119q-120 79 -258 108q140 -82 244 -208q26 -23 3 -49q-23 -29 -51 -3q-192 231 -483 297q-116 14 -221 60q-25 -32 -46 -74 q-60 -117 -85 -255q13 -29 51 -85l-74 -579q-11 -57 21.5 -104.5t89.5 -57.5q56 -10 103.5 23t57.5 90q4 28 -16 59.5t1 52.5q116 116 216 235.5t141 272.5q8 37 43 31t27 -46q-42 -155 -136.5 -279t-208.5 -235q-18 -18 -7 -47.5t7 -55.5q-12 -69 -63 -115q66 -92 66 -213 q0 -11 -6 -16h542z\" />
  <path
    d=\"M730 1555q36 -21 -18 -117q-56 -96 -93 -75t19 117q55 97 92 75z\" />
  <path
    d=\"M1427 1010q0 19 -1.5 36.5t-1.5 38.5q6 35 42 32q35 -8 28 -35q2 -31 0 -86q-4 -26 -38 -24q-33 1 -29 38z\" />
  <path
    d=\"M1432 728q-5 -28 -41 -18q-34 8 -25 42q7 20 12 40.5t11 38.5 q9 27 46 20q37 -10 24 -36q-16 -54 -27 -87z\" />
  <path
    d=\"M1435 238q0 68 -68 68h-682q-68 0 -68 -68v-35h818v35z\" />
</g>"

set truetype_Mediaeval(wp,exterior) "
<g>
  <path
    d=\"M1024 1841q-57 0 -96 -39.5t-39 -95.5q0 -57 39 -96 t96 -39q55 0 95 39t40 96q0 56 -40 95.5t-95 39.5z\" />
  <path
    d=\"M754 749h540q-139 126 -181.5 337.5t-53.5 415.5h-71q-12 -202 -54 -414t-180 -339z\" />
  <path
    d=\"M1365 678h-682q13 -129 110.5 -218t230.5 -89q132 0 229.5 89t111.5 218z\" />
  <path
    d=\"M1433 239q0 67 -68 67h-681q-69 0 -69 -69v-34h818v36z\" />
</g>"

set truetype_Mediaeval(bk,exterior) $truetype_Mediaeval(bk,mask)
set truetype_Mediaeval(bq,exterior) $truetype_Mediaeval(bq,mask)
set truetype_Mediaeval(br,exterior) $truetype_Mediaeval(br,mask)
set truetype_Mediaeval(bb,exterior) $truetype_Mediaeval(bb,mask)
set truetype_Mediaeval(bn,exterior) $truetype_Mediaeval(bn,mask)
set truetype_Mediaeval(bp,exterior) $truetype_Mediaeval(bp,mask)

set truetype_Mediaeval(bk,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M725 578q-37 0 -37 -34v0q0 -34 37 -34h598q37 0 37 34v0q0 34 -37 34h-598z M418 805q-34 0 -34 -37v0 q0 -38 34 -38h1212q34 0 34 38v0q0 37 -34 37h-1212z M537 896q135 178 332 240l-25 295l-164 53q-35 16 -65 16q-63 0 -108 -49.5t-45 -118.5q0 -35 15 -76z M1515 886l59 371q14 38 14 76q0 69 -44.5 118.5t-107.5 49.5q-31 0 -64 -16l-165 -53l-21 -298q199 -66 329 -248z M725 374q-37 0 -37 -34v0q0 -34 37 -34h598q37 0 37 34v0 q0 34 -37 34h-598z M1023 1675q-98 0 -98 -26t98 -26q97 0 97 26t-97 26z\" />
</g>"

set truetype_Mediaeval(bq,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M481 888q-34 0 -34 -37v0q0 -38 34 -38h1091q34 0 34 38v0q0 37 -34 37h-1091z M728 557q-38 0 -38 -34v0q0 -34 38 -34h597q38 0 38 34v0q0 34 -38 34 h-597z M728 374q-38 0 -38 -34v0q0 -34 38 -34h597q38 0 38 34v0q0 34 -38 34h-597z\" />
</g>"

set truetype_Mediaeval(br,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M747 1367q-29 0 -29 -29v0q0 -28 29 -28h554q29 0 29 28v0q0 29 -29 29 h-554z M581 374q-33 0 -33 -34v0q0 -34 33 -34h892q34 0 34 34v0q0 34 -34 34h-892z M882 681v-262h284l2 261l199 1q34 0 34 34v0 q0 34 -34 34h-201q0 56 -42 95.5t-100 39.5q-59 0 -100.5 -39.5t-41.5 -95.5h-201q-34 0 -34 -34v0q0 -34 34 -34h201z\" />
</g>"

set truetype_Mediaeval(bb,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M727 374q-32 0 -32 -35v-1q0 -35 32 -35h578q32 0 32 35v1q0 35 -32 35h-578z M577 663q72 -4 144 3q153 15 280 119q110 90 176 225l-71 1q-46 -87 -142 -164q-127 -104 -271 -110q-89 -7 -167 14z M535 1325l-1 -86q66 -33 164 -42q138 -15 263.5 41t221.5 164l-27 72q-83 -104 -202 -160t-251 -42 q-91 9 -168 53z M1414 645q5 5 25 20q180 139 218.5 380.5t-87.5 441.5q-88 138 -224.5 201.5t-278.5 45.5q204 -48 341.5 -231t137.5 -424q0 -174 -70 -320q-38 -53 -62 -114z\" />
</g>"

set truetype_Mediaeval(bn,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M735 1565q-17 9 -47 -15t-54 -67q-26 -44 -32 -82t11 -47q16 -10 46 14t56 68q25 44 31 82t-11 47z M683 599 q57 49 71 119q3 26 -8.5 55.5t7.5 47.5q120 111 207 202.5t131 246.5q11 49 -17 54q-47 8 -54 -25q-43 -153 -137 -247l-216 -210q-22 -21 -0.5 -53t16.5 -59q-9 -50 -55 -85q-33 -31 -3 -55q28 -21 58 9z M1041 1615q136 -80 237 -200q28 -26 51 3q23 26 -3 49 q-106 128 -242 205q-25 18 -48 -8q-22 -28 5 -49z M1374 1247q4 -35 38 -28q37 5 33 33q-8 38 -22 84q0 28 -37 25q-38 -4 -34 -42q5 -19 11 -36t11 -36z M1422 1006q-5 -40 33 -41q39 -4 44 25q2 40 1 96q7 30 -33 38q-42 5 -48 -35q0 -23 2 -42.5t1 -40.5z M1434 723q12 36 30 96q12 27 -27 39q-40 9 -51 -21 q-6 -20 -11.5 -43t-13.5 -45q-9 -38 28 -46q38 -10 45 20z M752 374q-34 0 -34 -34v0q0 -34 34 -34h544q34 0 34 34v0q0 34 -34 34h-544z\" />
</g>"

set truetype_Mediaeval(bp,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M716 749q-33 0 -33 -34v0q0 -34 33 -34h615q34 0 34 34v0q0 34 -34 34h-615z M869 395q-31 0 -31 -34v0q0 -34 31 -34h310q30 0 30 34v0q0 34 -30 34h-310z\" />
</g>"

set truetype_Mediaeval(sample,24pt,200x34) {
  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
  8xE/AAAAAElFTkSuQmCC
}

# vi:set ts=2 sw=2 et:
