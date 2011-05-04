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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

# Font by Armando H. Marroquin
# <http://www.enpassant.dk/chess/fonteng.htm>

lappend board_PieceSet { Maya truetype {stroke 1} {contour 80} {sampling 100} {overstroke 10} }

set truetype_Maya(wk) "
<g
  scidb:bbox=\"270,136,1777,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1184 819l-156 -78l-160 78l160 79zM1394 750l-137 69l160 79l22 -13l14.5 36l13.5 33l-877 -1q13 -49 22 -71l27 16l156 -79l-137 -68l10.5 -36.5l11.5 -37.5l691 1q13 46 23 72zM1506 1022q31 54 64 91l69 76q24 29 45.5 52.5t21.5 52.5v0q0 70 -69 70h-1226 q-70 0 -70 -70v0q0 -29 20.5 -52.5t50.5 -52.5l71.5 -75.5t64.5 -92.5zM1022 1499q-57 0 -97 -11t-40 -26q0 -16 40 -27t97 -11q56 0 96.5 11t40.5 27q0 15 -40.5 26t-96.5 11zM853 1669v137l119 -17l-16 121h135l-16 -121l119 17v-137l-119 18v-123h-103v123zM614 611 q-66 0 -66 -66v-1q0 -66 66 -66h820q66 0 66 66v1q0 66 -66 66h-820zM445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158zM494 478q-18 31 -18 65v0q0 55 40 94.5t97 36.5q-55 183 -89 257t-112 158q-64 72 -103 109.5t-39 93.5v1 q0 55 39.5 95t96.5 40h429q-17 20 -17 36v0q0 100 100 100h212q100 0 100 -100v0q0 -17 -18 -36h430q55 0 95 -40t40 -95v-1q0 -56 -41.5 -91.5t-107.5 -107.5q-72 -89 -108 -167t-84 -252q55 3 95 -36.5t40 -94.5v0q0 -34 -15 -65h50q70 0 120.5 -50.5t50.5 -120.5v0 q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h52z\" />
</g>"

set truetype_Maya(wq) "
<g
  scidb:bbox=\"221,136,1827,1814\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1024 1742q-79 0 -79 -78q0 -79 79 -79q78 0 78 79q0 78 -78 78zM1252 1309q-6 86 -72 145.5t-156 59.5q-91 0 -154.5 -59.5t-56.5 -145.5q85 -2 130.5 33.5t80.5 92.5q33 -59 93 -95.5t135 -30.5zM1140 1568q82 -33 134 -101t53 -153q46 15 78 47t62 74 q34 -132 150 -132q54 0 114 34t96 91l-391 -749q53 -4 94 -42.5t41 -93.5v0q0 -31 -18 -65h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h49q-15 20 -15 65v0q0 55 41 93.5t95 41.5l-391 750 q85 -125 207 -125q118 0 153 131q53 -84 144 -119q-2 84 49 152t133 101q-33 44 -33 96q0 62 43.5 106t106.5 44q62 0 106 -44t44 -106q0 -53 -34 -96zM618 987l135 68l138 -68l-138 -68zM1156 987l135 68l139 -68l-139 -68zM889 912l135 68l138 -68l-138 -68zM889 1076 l135 68l138 -68l-138 -68zM445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158zM1365 678l306 575q-35 -17 -73 -18q-73 -5 -130 86q-24 -39 -99 -68t-148 -18q-63 8 -115 27t-82 58q-70 -87 -198 -85q-185 0 -243 93 q-50 -82 -133 -93q-27 -5 -73 18l306 -575h682zM615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0q0 68 -68 68h-817z\" />
</g>"

set truetype_Maya(wr) "
<g
  scidb:bbox=\"270,136,1777,1907\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158zM1520 511l86 -33q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5l90 33q43 232 56 435l27 418v136h-138 v407h273v-200h139v200h270v-200h139v200h273v-407h-138v-69v-67q7 -225 23.5 -423t63.5 -430zM671 1167l47 1v153h-35zM652 935l201 1v156l-188 -1zM635 707h83v152h-71zM615 478h238v153l-225 -1zM1377 1168l-11 153h-36v-153h47zM1399 936l-14 156h-191v-156h205z M1417 707l-15 152h-72v-152h87zM1433 478l-13 153h-226v-153h239zM786 1321v-153h202v153h-202zM1059 1321v-153h203v153h-203zM786 859v-152h202v152h-202zM1059 859v-152h203v152h-203zM921 1092v-156h206v156h-206zM921 631v-153h206v153h-206zM683 1396h682v168h135v278 h-135v-207h-274v207h-135v-207h-273v207h-135v-278h135v-168z\" />
</g>"

set truetype_Maya(wb) "
<g
  scidb:bbox=\"270,136,1777,1914\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1024 1642q100 0 100 100q0 101 -100 101t-100 -101q0 -100 100 -100zM615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0q0 68 -68 68h-817zM441 407q-100 0 -100 -100v0q0 -100 100 -100h1165q100 0 100 100v0q0 100 -100 100h-1165zM1113 1131l194 221 q32 -31 66 -88q28 -45 54 -100q26 -56 40 -107q-9 -106 -66 -208t-147 -165l180 -2q57 0 97 -40.5t40 -96.5v-1q0 -26 -18 -66h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h56q-21 25 -21 66v1 q0 56 40 96.5t97 40.5h175q-94 57 -151 156t-56 219q59 187 149.5 324.5t125.5 182.5q13 40 47 61q-52 44 -52 117q0 71 50 121.5t122 50.5q70 0 120.5 -50.5t50.5 -121.5q0 -65 -49 -128q20 -40 24 -47q31 -44 81 -140l-212 -235q-34 -34 7 -66q37 -33 67 5zM1151 1085 q-29 -30 -76.5 -29.5t-68.5 20.5t-30.5 61.5t17.5 76.5l191 225q3 3 -11.5 15.5t-21.5 22.5q-13 21 -29.5 50.5t-34.5 53.5q-34 -10 -63 -10q-35 0 -65 13q-48 -32 -88 -113q-158 -203 -216 -417q-26 -138 105.5 -256t263.5 -118t258.5 125.5t116.5 255.5q-15 45 -42 99.5 l-49 96.5z\" />
</g>"

set truetype_Maya(wn) "
<g
  scidb:bbox=\"274,136,1774,1914\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M851 1631q64 37 83 7q18 -31 -47 -69q-64 -37 -82 -6q-19 31 46 68zM862 761q-59 98 46 279q40 68 79 104q-18 -13 11 -2t29 -35q-10 -11 -27 -40l-26 -45q-39 -67 -38.5 -135t21.5 -116q-16 -26 -44 -22.5t-51 12.5zM1161 1422q14 -28 -31 -75.5t-117 -57.5 q-21 -3 -32.5 -9t-24.5 -7q-8 -6 -23.5 -12.5t-36.5 -17.5q-55 -29 -99.5 -79t-77.5 -107q-23 -71 -32.5 -189t-3.5 -190h340.5h341.5q-4 22 -7.5 44.5t-6.5 45.5q-43 48 -70.5 133t-26.5 156q12 74 56.5 170.5l68.5 150.5q3 40 0 86t-42 89q-22 40 -89.5 99t-163.5 65 q14 67 -35 104q-7 -44 -70 -84t-129 -45q-57 -67 -155.5 -91l-196.5 -48q-30 -51 1.5 -72t37.5 -53q26 -19 21.5 -32.5t81.5 0.5q57 26 87 20t94 -16q20 -15 33 -18q53 -45 141 -29q108 18 123 104q37 0 43 -35zM615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0 q0 68 -68 68h-817zM1299 407h-547h-307q-104 0 -104 -103v0q0 -104 104 -104h1158q103 0 103 104v0q0 103 -103 103h-304zM1443 678q47 -7 87.5 -43.5t40.5 -91.5v0q0 -34 -15 -65h46q71 0 121.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-121.5 -50h-1157q-71 0 -121 50 t-50 121v0q0 70 50 120.5t121 50.5h47q-16 33 -16 65v0q0 55 40.5 96t100.5 47q-5 93 -3 186t31 180q57 121 119 176t143 82q-67 3 -75.5 4t-56.5 28q-48 13 -64 14t-85 -20q-75 -12 -111 -8t-38 72l-62.5 90.5t26.5 116.5q159 50 230.5 55t149.5 80q99 21 140 53.5 t41 118.5q54 -11 95 -47.5t41 -95.5q111 -27 148.5 -65.5t92.5 -84.5q69 -91 71.5 -159t-7.5 -137q-31 -67 -63 -124.5t-48 -147.5q0 -87 27 -157t71 -128z\" />
</g>"

set truetype_Maya(wp) "
<g
  scidb:bbox=\"270,136,1777,1914\">
  scidb:scale=\"0.9\"
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158zM1223 1093h-405q-20 -212 -74 -376.5t-126 -238.5h815q-77 75 -136.5 239.5t-73.5 375.5zM615 1292q-67 0 -67 -67v0q0 -68 67 -68h817q68 0 68 68v0q0 67 -68 67h-817z M1298 1093q7 -258 90 -436.5t192 -178.5h26q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h29q106 0 189.5 178.5t93.5 436.5h-142q-57 0 -96.5 39t-39.5 96v0q0 56 39.5 96t96.5 40h215 q-114 92 -114 239q0 128 91 219.5t220 91.5q128 0 219 -91.5t91 -219.5q0 -146 -112 -239h214q55 0 95 -40t40 -96v0q0 -57 -40 -96t-95 -39h-138zM1024 1842q-99 0 -169 -70t-70 -169t70 -169t169 -70q98 0 168.5 70t70.5 169t-70.5 169t-168.5 70z\" />
</g>"

set truetype_Maya(bk) "
<g
  scidb:bbox=\"270,136,1777,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1184 819l-156 79l-160 -79l160 -78zM654 748l141 71l-156 79l-31 -16zM1404 746l43 131l-30 21l-160 -79zM681 679q-34 0 -34 -34v0q0 -34 34 -34h686q34 0 34 34v0q0 34 -34 34h-686zM546 477q-34 0 -34 -36v0q0 -37 34 -37h956q34 0 34 37v0q0 36 -34 36h-956z M887 1432q-34 0 -34 -34v0q0 -34 34 -34h274q33 0 33 34v0q0 34 -33 34h-274zM853 1669v137l119 -17l-16 121h135l-16 -121l119 17v-137l-119 18v-123h-103v123zM494 478q-18 31 -18 65v0q0 55 40 94.5t97 36.5q-55 183 -89 257t-112 158q-64 72 -103 109.5t-39 93.5v1 q0 55 39.5 95t96.5 40h429q-17 20 -17 36v0q0 100 100 100h212q100 0 100 -100v0q0 -17 -18 -36h430q55 0 95 -40t40 -95v-1q0 -56 -41.5 -91.5t-107.5 -107.5q-72 -89 -108 -167t-84 -252q55 3 95 -36.5t40 -94.5v0q0 -34 -15 -65h50q70 0 120.5 -50.5t50.5 -120.5v0 q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h52zM581 1021q-33 0 -33 -34v0q0 -34 33 -34h885q34 0 34 34v0q0 34 -34 34h-885z\" />
</g>"

set truetype_Maya(bq) "
<g
  scidb:bbox=\"221,136,1827,1814\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M766 1338l-13 -78q41 -5 73 -5q130 0 198 86q30 -39 82 -58.5t115 -27.5q40 -6 76 3l-17 80q-75 -19 -149 19.5t-107 97.5q-35 -56 -103 -94.5t-155 -22.5zM876 1088l148 -78l152 78l-152 78zM876 900l148 -78l152 78l-152 78zM1170 985l148 -77l153 77l-153 79zM577 985 l149 -77l152 77l-152 79zM1140 1568q82 -33 134 -101t53 -153q46 15 78 47t62 74q34 -132 150 -132q54 0 114 34t96 91l-391 -749q53 -4 94 -42.5t41 -93.5v0q0 -31 -18 -65h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0 q0 70 50 120.5t122 50.5h49q-15 20 -15 65v0q0 55 41 93.5t95 41.5l-391 750q85 -125 207 -125q118 0 153 131q53 -84 144 -119q-2 84 49 152t133 101q-33 44 -33 96q0 62 43.5 106t106.5 44q62 0 106 -44t44 -106q0 -53 -34 -96zM1135 1533l-33 54q-34 -30 -78 -30 q-41 0 -71 27l-43 -51q47 -44 114 -44t111 44zM664 738q-35 0 -35 -37v0q0 -37 35 -37h720q35 0 35 37v0q0 37 -35 37h-720zM549 494q-37 0 -37 -41v0q0 -42 37 -42h949q38 0 38 42v0q0 41 -38 41h-949z\" />
</g>"

set truetype_Maya(br) "
<g
  scidb:bbox=\"270,136,1777,1907\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1518 511l88 -33q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5l92 33q42 232 54.5 435l26.5 418v136h-138v407h273v-200h139v200h270v-200h139v200h273v-407h-138v-69v-67q12 -225 26 -423 t59 -430zM921 680h206v-159h-206v159zM921 1123h206v-154h-206v154zM1059 902h203v-154h-203v154zM786 902h202v-154h-202v154zM1059 1346h203v-153h-203v153zM786 1346h202v-153h-202v153zM1369 1346v68h-686l-2 -68h37v-153h-51l-2 -70h53h135v-154h-199l-5 -67h69v-154 h-83l-4 -68h222v-159h-277v-78h896v78h-278v159h230l-7 68h-87v154h72l-5 67h-203v154h189v70h-53v153h39z\" />
</g>"

set truetype_Maya(bb) "
<g
  scidb:bbox=\"270,136,1777,1914\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1041 1196q-42 -41 -1 -81q38 -41 86 3l196 221q20 -19 28 -35t23 -40q28 -45 54 -100q26 -56 40 -107q-9 -106 -66 -208t-147 -165l180 -2q57 0 97 -40.5t40 -96.5v-1q0 -26 -18 -66h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164 q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h56q-21 25 -21 66v1q0 56 40 96.5t97 40.5h175q-94 57 -151 156t-56 219q59 187 149.5 324.5t125.5 182.5q13 40 47 61q-52 44 -52 117q0 71 50 121.5t122 50.5q70 0 120.5 -50.5t50.5 -121.5q0 -65 -49 -128q20 -40 24 -47 q31 -44 81 -140zM1116 1558l-35 70q-21 -18 -57 -18q-29 0 -52 15l-44 -67q46 -27 96 -27q52 0 92 27zM852 721q-34 0 -34 -37v0q0 -38 34 -38h344q34 0 34 38v0q0 37 -34 37h-344zM581 493q-33 0 -33 -37v0q0 -37 33 -37h885q34 0 34 37v0q0 37 -34 37h-885z\" />
</g>"

set truetype_Maya(bn) "
<g
  scidb:bbox=\"274,136,1774,1914\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M833 816q26 -9 58.5 -13t50.5 23q-24 51 -25 120.5t44 138.5q10 18 30 47.5t31 41.5q0 48 -33 36t-13 2q-46 -39 -90 -108q-60 -92 -76.5 -160.5t23.5 -127.5zM828 1656q-75 -42 -53 -78q20 -36 94 7q73 43 54 79q-22 36 -95 -8zM681 738q-34 0 -34 -37v0q0 -37 34 -37 h686q34 0 34 37v0q0 37 -34 37h-686zM548 494q-36 0 -36 -40v0q0 -39 36 -39h952q36 0 36 39v0q0 40 -36 40h-952zM1443 678q47 -7 87.5 -43.5t40.5 -91.5v0q0 -34 -15 -65h46q71 0 121.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-121.5 -50h-1157q-71 0 -121 50t-50 121v0 q0 70 50 120.5t121 50.5h47q-16 33 -16 65v0q0 55 40.5 96t100.5 47q-5 93 -3 186t31 180q57 121 119 176t143 82q-67 3 -75.5 4t-56.5 28q-48 13 -64 14t-85 -20q-75 -12 -111 -8t-38 72l-62.5 90.5t26.5 116.5q159 50 230.5 55t149.5 80q99 21 140 53.5t41 118.5 q54 -11 95 -47.5t41 -95.5q111 -27 148.5 -65.5t92.5 -84.5q69 -91 71.5 -159t-7.5 -137q-31 -67 -63 -124.5t-48 -147.5q0 -87 27 -157t71 -128zM960 1289q12 0 22 -1.5t31 1.5q72 10 119.5 58t33.5 76q-6 37 -51 37q-17 -98 -116 -114q-16 -3 -25 -5t-28 -8 q-45 -30 14 -44z\" />
</g>"

set truetype_Maya(bp) "
<g>
  scidb:bbox=\"270,136,1777,1914\"
  <path
    scidb:scale=\"0.9\"
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1018 1378q-80 0 -136 -11.5t-56 -27.5q0 -17 56 -28t136 -11q78 0 135 11t57 28q0 16 -57 27.5t-135 11.5zM1298 1093q7 -258 90 -436.5t192 -178.5h26q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5 t122 50.5h29q106 0 189.5 178.5t93.5 436.5h-142q-57 0 -96.5 39t-39.5 96v0q0 56 39.5 96t96.5 40h215q-114 92 -114 239q0 128 91 219.5t220 91.5q128 0 219 -91.5t91 -219.5q0 -146 -112 -239h214q55 0 95 -40t40 -96v0q0 -57 -40 -96t-95 -39h-138zM820 1108 q-34 0 -34 -38v0q0 -37 34 -37h408q34 0 34 37v0q0 38 -34 38h-408zM615 514q-35 0 -35 -39v0q0 -39 35 -39h818q35 0 35 39v0q0 39 -35 39h-818z\" />
</g>"

set truetype_Maya(wk,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M853 1669v137l119 -17l-16 121h135l-16 -121l119 17v-137l-119 18v-123h-103v123zM494 478q-18 31 -18 65v0q0 55 40 94.5t97 36.5q-55 183 -89 257t-112 158q-64 72 -103 109.5t-39 93.5v1q0 55 39.5 95t96.5 40h429q-17 20 -17 36v0q0 100 100 100h212q100 0 100 -100 v0q0 -17 -18 -36h430q55 0 95 -40t40 -95v-1q0 -56 -41.5 -91.5t-107.5 -107.5q-72 -89 -108 -167t-84 -252q55 3 95 -36.5t40 -94.5v0q0 -34 -15 -65h50q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5 t122 50.5h52z\" />
</g>"

set truetype_Maya(wq,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1140 1568q82 -33 134 -101t53 -153q46 15 78 47t62 74q34 -132 150 -132q54 0 114 34t96 91l-391 -749q53 -4 94 -42.5t41 -93.5v0q0 -31 -18 -65h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5 t122 50.5h49q-15 20 -15 65v0q0 55 41 93.5t95 41.5l-391 750q85 -125 207 -125q118 0 153 131q53 -84 144 -119q-2 84 49 152t133 101q-33 44 -33 96q0 62 43.5 106t106.5 44q62 0 106 -44t44 -106q0 -53 -34 -96z\" />
</g>"

set truetype_Maya(wr,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1520 511l86 -33q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5l90 33q43 232 56 435l27 418v136h-138v407h273v-200h139v200h270v-200h139v200h273v-407h-138v-69v-67q7 -225 23.5 -423t63.5 -430 z\" />
</g>"

set truetype_Maya(wb,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1113 1131l194 221q32 -31 66 -88q28 -45 54 -100q26 -56 40 -107q-9 -106 -66 -208t-147 -165l180 -2q57 0 97 -40.5t40 -96.5v-1q0 -26 -18 -66h53q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5 h56q-21 25 -21 66v1q0 56 40 96.5t97 40.5h175q-94 57 -151 156t-56 219q59 187 149.5 324.5t125.5 182.5q13 40 47 61q-52 44 -52 117q0 71 50 121.5t122 50.5q70 0 120.5 -50.5t50.5 -121.5q0 -65 -49 -128q20 -40 24 -47q31 -44 81 -140l-212 -235q-34 -34 7 -66 q37 -33 67 5z\" />
</g>"

set truetype_Maya(wn,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1443 678q47 -7 87.5 -43.5t40.5 -91.5v0q0 -34 -15 -65h46q71 0 121.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-121.5 -50h-1157q-71 0 -121 50t-50 121v0q0 70 50 120.5t121 50.5h47q-16 33 -16 65v0q0 55 40.5 96t100.5 47q-5 93 -3 186t31 180q57 121 119 176t143 82 q-67 3 -75.5 4t-56.5 28q-48 13 -64 14t-85 -20q-75 -12 -111 -8t-38 72l-62.5 90.5t26.5 116.5q159 50 230.5 55t149.5 80q99 21 140 53.5t41 118.5q54 -11 95 -47.5t41 -95.5q111 -27 148.5 -65.5t92.5 -84.5q69 -91 71.5 -159t-7.5 -137q-31 -67 -63 -124.5t-48 -147.5 q0 -87 27 -157t71 -128z\" />
</g>"

set truetype_Maya(wp,mask) "
<g>
  <path
    scidb:scale=\"0.9\"
    style=\"fill:white;stroke:none\"
    d=\"M1298 1093q7 -258 90 -436.5t192 -178.5h26q70 0 120.5 -50.5t50.5 -120.5v0q0 -71 -50.5 -121t-120.5 -50h-1164q-72 0 -122 50t-50 121v0q0 70 50 120.5t122 50.5h29q106 0 189.5 178.5t93.5 436.5h-142q-57 0 -96.5 39t-39.5 96v0q0 56 39.5 96t96.5 40h215 q-114 92 -114 239q0 128 91 219.5t220 91.5q128 0 219 -91.5t91 -219.5q0 -146 -112 -239h214q55 0 95 -40t40 -96v0q0 -57 -40 -96t-95 -39h-138z\" />
</g>"

set truetype_Maya(bk,mask) $truetype_Maya(wk,mask)
set truetype_Maya(bq,mask) $truetype_Maya(wq,mask)
set truetype_Maya(br,mask) $truetype_Maya(wr,mask)
set truetype_Maya(bb,mask) $truetype_Maya(wb,mask)
set truetype_Maya(bn,mask) $truetype_Maya(wn,mask)
set truetype_Maya(bp,mask) $truetype_Maya(wp,mask)

set truetype_Maya(wk,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1022 1499q-57 0 -97 -11t-40 -26q0 -16 40 -27t97 -11q56 0 96.5 11t40.5 27q0 15 -40.5 26t-96.5 11z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1506 1022q31 54 64 91l69 76q24 29 45.5 52.5t21.5 52.5v0q0 70 -69 70h-1226 q-70 0 -70 -70v0q0 -29 20.5 -52.5t50.5 -52.5l71.5 -75.5t64.5 -92.5z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1394 750l-137 69l160 79l22 -13l14.5 36l13.5 33l-877 -1q13 -49 22 -71l27 16l156 -79l-137 -68l10.5 -36.5l11.5 -37.5l691 1q13 46 23 72z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M614 611 q-66 0 -66 -66v-1q0 -66 66 -66h820q66 0 66 66v1q0 66 -66 66h-820z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158z\" />
</g>"

set truetype_Maya(wq,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1024 1742q-79 0 -79 -78q0 -79 79 -79q78 0 78 79q0 78 -78 78z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1252 1309q-6 86 -72 145.5t-156 59.5q-91 0 -154.5 -59.5t-56.5 -145.5q85 -2 130.5 33.5t80.5 92.5q33 -59 93 -95.5t135 -30.5z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1365 678l306 575q-35 -17 -73 -18q-73 -5 -130 86q-24 -39 -99 -68t-148 -18q-63 8 -115 27t-82 58q-70 -87 -198 -85q-185 0 -243 93 q-50 -82 -133 -93q-27 -5 -73 18l306 -575h682z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0q0 68 -68 68h-817z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158z\" />
</g>"

set truetype_Maya(wr,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M683 1396h682v168h135v278 h-135v-207h-274v207h-135v-207h-273v207h-135v-278h135v-168z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M671 1167l47 1v153h-35z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M652 935l201 1v156l-188 -1z\"/>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M635 707h83v152h-71z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M615 478h238v153l-225 -1z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1377 1168l-11 153h-36v-153h47z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1399 936l-14 156h-191v-156h205z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1417 707l-15 152h-72v-152h87z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1433 478l-13 153h-226v-153h239z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M786 1321v-153h202v153h-202z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1059 1321v-153h203v153h-203z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M786 859v-152h202v152h-202z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1059 859v-152h203v152h-203z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M921 1092v-156h206v156h-206z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M921 631v-153h206v153h-206z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158z\" />
</g>"

set truetype_Maya(wb,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1024 1642q100 0 100 100q0 101 -100 101t-100 -101q0 -100 100 -100z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1151 1085 q-29 -30 -76.5 -29.5t-68.5 20.5t-30.5 61.5t17.5 76.5l191 225q3 3 -11.5 15.5t-21.5 22.5q-13 21 -29.5 50.5t-34.5 53.5q-34 -10 -63 -10q-35 0 -65 13q-48 -32 -88 -113q-158 -203 -216 -417q-26 -138 105.5 -256t263.5 -118t258.5 125.5t116.5 255.5q-15 45 -42 99.5 l-49 96.5z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0q0 68 -68 68h-817z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M441 407q-100 0 -100 -100v0q0 -100 100 -100h1165q100 0 100 100v0q0 100 -100 100h-1165z\" />
</g>"

set truetype_Maya(wn,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1161 1422q14 -28 -31 -75.5t-117 -57.5 q-21 -3 -32.5 -9t-24.5 -7q-8 -6 -23.5 -12.5t-36.5 -17.5q-55 -29 -99.5 -79t-77.5 -107q-23 -71 -32.5 -189t-3.5 -190h340.5h341.5q-4 22 -7.5 44.5t-6.5 45.5q-43 48 -70.5 133t-26.5 156q12 74 56.5 170.5l68.5 150.5q3 40 0 86t-42 89q-22 40 -89.5 99t-163.5 65 q14 67 -35 104q-7 -44 -70 -84t-129 -45q-57 -67 -155.5 -91l-196.5 -48q-30 -51 1.5 -72t37.5 -53q26 -19 21.5 -32.5t81.5 0.5q57 26 87 20t94 -16q20 -15 33 -18q53 -45 141 -29q108 18 123 104q37 0 43 -35z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M615 614q-67 0 -67 -68v0q0 -68 67 -68h817q68 0 68 68v0 q0 68 -68 68h-817z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1299 407h-547h-307q-104 0 -104 -103v0q0 -104 104 -104h1158q103 0 103 104v0q0 103 -103 103h-304z\" />
</g>"

set truetype_Maya(wp,exterior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1024 1842q-99 0 -169 -70t-70 -169t70 -169t169 -70q98 0 168.5 70t70.5 169t-70.5 169t-168.5 70z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M615 1292q-67 0 -67 -67v0q0 -68 67 -68h817q68 0 68 68v0q0 67 -68 67h-817z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1223 1093h-405q-20 -212 -74 -376.5t-126 -238.5h815q-77 75 -136.5 239.5t-73.5 375.5z\" />
  <path
    style=\"fill:white;stroke:none\"
    d=\"M445 407q-104 0 -104 -103v-1q0 -103 104 -103h1158q103 0 103 103v1q0 103 -103 103h-1158z\" />
</g>"

set truetype_Maya(bk,exterior) $truetype_Maya(bk,mask)
set truetype_Maya(bq,exterior) $truetype_Maya(bq,mask)
set truetype_Maya(br,exterior) $truetype_Maya(br,mask)
set truetype_Maya(bb,exterior) $truetype_Maya(bb,mask)
set truetype_Maya(bn,exterior) $truetype_Maya(bn,mask)
set truetype_Maya(bp,exterior) $truetype_Maya(bp,mask)

set truetype_Maya(bk,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1184 819l-156 79l-160 -79l160 -78zM654 748l141 71l-156 79l-31 -16zM1404 746l43 131l-30 21l-160 -79zM681 679q-34 0 -34 -34v0q0 -34 34 -34h686q34 0 34 34v0q0 34 -34 34h-686zM546 477q-34 0 -34 -36v0q0 -37 34 -37h956q34 0 34 37v0q0 36 -34 36h-956z M887 1432q-34 0 -34 -34v0q0 -34 34 -34h274q33 0 33 34v0q0 34 -33 34h-274zM581 1021q-33 0 -33 -34v0q0 -34 33 -34h885q34 0 34 34v0q0 34 -34 34h-885z\" />
</g>"

set truetype_Maya(bq,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1135 1533l-33 54q-34 -30 -78 -30 q-41 0 -71 27l-43 -51q47 -44 114 -44t111 44zM664 738q-35 0 -35 -37v0q0 -37 35 -37h720q35 0 35 37v0q0 37 -35 37h-720zM549 494q-37 0 -37 -41v0q0 -42 37 -42h949q38 0 38 42v0q0 41 -38 41h-949z M766 1338l-13 -78q41 -5 73 -5q130 0 198 86q30 -39 82 -58.5t115 -27.5q40 -6 76 3l-17 80q-75 -19 -149 19.5t-107 97.5q-35 -56 -103 -94.5t-155 -22.5z M876 1088l148 -78l152 78l-152 78zM876 900l148 -78l152 78l-152 78zM1170 985l148 -77l153 77l-153 79zM577 985 l149 -77l152 77l-152 79z\" />
</g>"

set truetype_Maya(br,interior) "
<g>
  <path
    style=\"fill:white;stroke:none;fill-rule:evenodd\"
    d=\"M921 680h206v-159h-206v159zM921 1123h206v-154h-206v154zM1059 902h203v-154h-203v154zM786 902h202v-154h-202v154zM1059 1346h203v-153h-203v153zM786 1346h202v-153h-202v153zM1369 1346v68h-686l-2 -68h37v-153h-51l-2 -70h53h135v-154h-199l-5 -67h69v-154 h-83l-4 -68h222v-159h-277v-78h896v78h-278v159h230l-7 68h-87v154h72l-5 67h-203v154h189v70h-53v153h39z\" />
</g>"

set truetype_Maya(bb,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1116 1558l-35 70q-21 -18 -57 -18q-29 0 -52 15l-44 -67q46 -27 96 -27q52 0 92 27zM852 721q-34 0 -34 -37v0q0 -38 34 -38h344q34 0 34 38v0q0 37 -34 37h-344zM581 493q-33 0 -33 -37v0q0 -37 33 -37h885q34 0 34 37v0q0 37 -34 37h-885z\" />
</g>"

set truetype_Maya(bn,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M833 816q26 -9 58.5 -13t50.5 23q-24 51 -25 120.5t44 138.5q10 18 30 47.5t31 41.5q0 48 -33 36t-13 2q-46 -39 -90 -108q-60 -92 -76.5 -160.5t23.5 -127.5z M828 1656q-75 -42 -53 -78q20 -36 94 7q73 43 54 79q-22 36 -95 -8z M681 738q-34 0 -34 -37v0q0 -37 34 -37 h686q34 0 34 37v0q0 37 -34 37h-686z M548 494q-36 0 -36 -40v0q0 -39 36 -39h952q36 0 36 39v0q0 40 -36 40h-952z M960 1289q12 0 22 -1.5t31 1.5q72 10 119.5 58t33.5 76q-6 37 -51 37q-17 -98 -116 -114q-16 -3 -25 -5t-28 -8 q-45 -30 14 -44z\" />
</g>"

set truetype_Maya(bp,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
   d=\"M820 1108 q-34 0 -34 -38v0q0 -37 34 -37h408q34 0 34 37v0q0 38 -34 38h-408zM615 514q-35 0 -35 -39v0q0 -39 35 -39h818q35 0 35 39v0q0 39 -35 39h-818z M1018 1378q-80 0 -136 -11.5t-56 -27.5q0 -17 56 -28t136 -11q78 0 135 11t57 28q0 16 -57 27.5t-135 11.5z\" />
</g>"

set truetype_Maya(sample,24pt,200x34) {
  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
}

# vi:set ts=2 sw=2 et:
