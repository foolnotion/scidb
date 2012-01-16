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

lappend board_PieceSet { Magnetic truetype {stroke 3} {contour 80} {sampling 200} {overstroke 2} }

set truetype_Magnetic(wk) "
<g
  scidb:bbox=\"110,135,1938,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1060 1638h98q71 0 121.5 -50.5t50.5 -120.5v-114l43 75q35 61 103.5 79.5t130.5 -16.5l233 -134q60 -36 79 -105t-17 -129l-203 -353q-55 -93 -163 -89h103q55 0 95 -40t40 -95v-69q0 -56 -40 -95.5t-95 -39.5h-1230q-56 0 -95.5 39.5t-39.5 95.5v69q0 55 39.5 95 t95.5 40h103q-110 -4 -163 90l-203 352q-36 61 -17.5 129.5t79.5 104.5l233 134q60 35 129 16.5t105 -78.5l44 -77l-1 115q0 70 50 120.5t122 50.5h99l-17 86l-83 18v67l83 16l16 85h71l16 -85l84 -16v-67l-84 -18zM1468 563h135v-103h-135v103zM444 563h136v-103h-136v103z M786 563h135v-103h-135v103zM1127 563h135v-103h-135v103zM409 613q-68 0 -68 -67v-68q0 -68 68 -68h1230q67 0 67 68v68q0 67 -67 67h-1230zM1423 810l76 -44q89 -52 141 38l204 353q50 88 -38 141l-233 134q-90 53 -141 -37l-171 -295l1 367q0 103 -103 103h-270 q-103 0 -103 -103v-366l-170 294q-52 89 -141 38l-233 -135q-90 -52 -38 -141l204 -353q51 -90 141 -38l77 45q172 145 398 145q224 0 399 -146zM1452 682q-76 94 -187.5 150t-240.5 56q-130 0 -241 -56t-186 -150h855zM1024 1467v0q103 0 103 -103v-201q0 -103 -103 -103v0 q-103 0 -103 103v201q0 103 103 103zM1638 1275v0q89 -52 37 -140l-100 -174q-52 -90 -141 -38v0q-89 52 -38 141l101 174q50 89 141 37zM410 1276v0q88 50 141 -38l100 -174q52 -89 -37 -141h-1q-90 -51 -140 38l-101 174q-51 88 38 141zM461 135q-48 0 -66.5 52t-46.5 87 h675h677q-28 -35 -47 -87t-66 -52h-565h-561z\" />
</g>"

set truetype_Magnetic(wq) "
<g
  scidb:bbox=\"206,135,1841,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1437 895l-47.5 -89l-46.5 -88h-100h-100l47 88l47 89h99.5h100.5zM611 894h99h101l46 -89l47 -87h-100h-99l-47.5 88zM471 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5t-95.5 -39.5zM471 1455q67 0 67 68 q0 67 -67 67q-68 0 -68 -67q0 -68 68 -68zM1577 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5t-95.5 -39.5zM1577 1455q67 0 67 68q0 67 -67 67q-68 0 -68 -67q0 -68 68 -68zM580 1059q-5 75 -9.5 152l-9.5 155 l259 -169l204 405l102.5 -204.5l102.5 -203.5l257 171q-5 -77 -8.5 -153.5t-7.5 -151.5h185.5h185.5l-135.5 -273.5l-134.5 -273.5h-548h-547l-135.5 273.5l-134.5 273.5q93 -1 186.5 -1h187.5zM1414 1241l-101 -66.5l-106 -72.5l-92 182.5l-91 185.5l-92 -182.5l-92 -181.5 l-105.5 69.5l-100.5 67.5q3 -64 10 -126.5t10 -124.5h-174h-174l102.5 -206l103.5 -205h511h513l102.5 205l103.5 206h-171.5h-169.5q5 137 13 249zM1024 1101l51 -87l52 -85l-52 -86l-51 -85l-52 85l-51 86l51 85zM1024 1706q67 0 67 68t-67 68q-68 0 -68 -68t68 -68z M1024 1638q-57 0 -96.5 39.5t-39.5 96.5q0 56 39.5 96t96.5 40q56 0 95.5 -40t39.5 -96q0 -57 -39.5 -96.5t-95.5 -39.5zM570 135q-39 0 -54 52t-37 87h544.5h545.5q-23 -35 -38 -87t-53 -52h-456h-452zM527 442h994q50 0 50 -50v0q0 -50 -50 -50h-994q-50 0 -50 50v0 q0 50 50 50z\" />
</g>"

set truetype_Magnetic(wr) "
<g
  scidb:bbox=\"346,135,1702,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1516 1567h-492.5h-492.5q-58 0 -59.5 120.5t-1.5 222.5h91h92l64 -136h153l61 136h186l60 -136h154l64 136h182q0 -102 -2 -222.5t-59 -120.5zM1516 1842h-92l-61 -132h-218l-60 132h-122l-61 -132h-217l-61 132h-47h-46q0 -51 3 -131t35 -80h456h457q31 0 32.5 80 t1.5 131zM755 274q54 0 94 39.5t40 95.5v209q0 55 39 95t96 40v0q55 0 95 -40t40 -95v-209q0 -56 39 -95.5t91 -39.5h161h163l-139 137l-177 984l-552 -1l-89 -491.5l-88 -491.5l-70.5 -68.5l-69.5 -68.5h327zM1024 1228v0q67 0 67 -68v-172q0 -67 -67 -67v0q-68 0 -68 67 v172q0 68 68 68zM1702 274q-31 -35 -50.5 -87t-66.5 -52h-563h-559q-48 0 -67 52t-50 87l166 168l172 954h-119q-53 0 -53 53v0q0 54 53 54h917q54 0 54 -54v0q0 -53 -54 -53h-117l171 -954z\" />
</g>"

set truetype_Magnetic(wb) "
<g
  scidb:bbox=\"481,129,1567,1774\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M596 859q38 -62 67.5 -129.5t29.5 -142.5h331h332q12 136 97 273q47 87 47 186q0 177 -140 304t-336 127q-198 0 -337 -127t-139 -304q0 -99 48 -187zM956 688l-35 310l-135 32v136l135 36l35 171h135l36 -171l135 -36v-136l-135 -32l-36 -310h-135zM1026 1708 q-57 0 -57 -33q0 -32 57 -32q56 0 56 32q0 33 -56 33zM1074 1588l-1 -44q207 -17 350.5 -160t143.5 -338q0 -87 -35 -185q-48 -74 -86 -157t-45 -188h-377.5h-376.5q-11 112 -46 185.5t-84 156.5q-36 93 -36 188q0 195 143.5 338t350.5 160l-1 44q-83 32 -83 93 q0 38 38.5 65.5t92.5 27.5t93 -27.5t39 -65.5q0 -63 -80 -93zM1142 135q-45 -5 -48.5 48t-21.5 89q109 1 220.5 1.5t222.5 0.5q-21 -35 -35 -87t-48 -52h-144.5h-145.5zM905 135h-145.5h-144.5q-34 0 -47.5 52t-34.5 87q111 0 221.5 -0.5t221.5 -1.5q-18 -36 -20.5 -89.5 t-50.5 -47.5zM665 442h718q50 0 50 -50v0q0 -50 -50 -50h-718q-50 0 -50 50v0q0 50 50 50z\" />
</g>"

set truetype_Magnetic(wn) "
<g
  scidb:bbox=\"231,135,1760,1881\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1521 513h-957q-59 0 -61 52t67 115q30 35 65 67l68 64q-25 14 -45.5 30.5t-45.5 28.5q-30 -27 -63.5 -49.5t-73.5 -25.5q-10 0 -30 -5t-20 5q-18 -4 -30 2t-30 9q-23 5 -63.5 51.5t-52.5 66.5q-18 75 37 133.5t90 122.5q36 70 83.5 134t58.5 153q69 24 112.5 93.5 t95.5 127.5q13 42 11.5 90t-8.5 92q15 11 43 10t56 -5q15 -3 36 -9q48 -27 90.5 -72t60.5 -102q43 -21 85 -39.5l86 -39.5q125 -55 237 6q-28 -48 -62 -77q-16 -12 -35 -24q114 -107 261 -58q-31 -40 -75 -65q-12 -8 -25 -13.5l-24 -10.5q81 -138 238 -128q-42 -32 -88 -43 q-29 -9 -50 -7q43 -153 197 -183q-50 -19 -97 -19q-23 0 -45 3q0 -11 4 -31q-2 -69 -3 -120q61 -64 141 -79q-50 -19 -97 -19q-17 0 -51 4q-8 -50 -18 -105q60 -67 145 -85q-48 -19 -97 -19q-41 0 -92 16q-13 -22 -29 -43zM734 1578q-33 -48 -72 -97t-87 -64 q-9 -67 -58.5 -152l-82.5 -140q61 -74 132 -135q102 102 183 206t121 225q-21 24 -21 60q0 13 5 17zM764 857l49.5 49.5t46.5 53.5q33 33 34 42l-12.5 -5q-12.5 -5 -11.5 -9l-48.5 -21.5t-52.5 -17.5q-58 8 -107 -30q25 -17 51 -32zM1062 1588l-34 -51q22 -21 22 -56 q0 -100 -101 -100q-3 0 -23 2q-98 -214 -272 -384q21 12 55 19q33 -3 53 0.5t51 27.5q3 0 90.5 17t45.5 -55q-9 -24 -21.5 -53.5t-36.5 -60.5q-22 -40 -56 -68q186 -78 374.5 -82t347.5 56q3 83 -16 187q-35 203 -149 345q-53 69 -116 118q-79 64 -214 138zM393 1059 q-62 -69 -74 -100q18 -29 45 -63t69 -36q21 -9 43.5 0t37.5 21q15 6 41 25q-42 33 -83 73zM1547 716q-174 -57 -377.5 -43.5t-398.5 105.5l-30 -28.5t-34 -35.5q-38 -39 -93.5 -80.5t-20.5 -52.5h891q48 78 63 135zM773 1630l114 -74q23 25 62 25q18 0 28 -4l29 43l-49 25 q-18 53 -26.5 71.5t-38.5 51.5q-18 17 -36.5 30.5t-48.5 12.5q7 -51 5 -88.5t-28 -73.5q-11 -11 -11 -19zM646 1355q42 69 76 50q33 -19 -7 -88q-42 -69 -75 -49q-35 17 6 87zM570 135q-39 0 -54 52t-37 87h544.5h545.5q-23 -35 -38 -87t-53 -52h-456h-452zM1520 442 q50 0 50 -50v0q0 -50 -50 -50h-994q-50 0 -50 50v0q0 50 50 50h994z\" />
</g>"

set truetype_Magnetic(wp) "
<g
  scidb:bbox=\"612,135,1436,1635\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M754 203h268h272q20 0 25.5 26.5t17.5 44.5h-313.5h-312.5q10 -18 16 -44.5t27 -26.5zM754 135q-63 0 -85 77.5t-57 129.5h411h413q-36 -52 -58 -129.5t-84 -77.5h-281.5h-258.5zM1154 1363h78q33 0 33 -34v0q0 -34 -33 -34h-416q-34 0 -34 34v0q0 34 34 34h77 q-37 41 -37 104q0 69 49 118.5t119 49.5q69 0 118.5 -49.5t49.5 -118.5q0 -60 -38 -104zM1024 1570q-104 0 -104 -103q0 -104 104 -104q103 0 103 104q0 103 -103 103zM1202 477h200q34 0 34 -33v0q0 -34 -34 -34h-757q-33 0 -33 34v0q0 33 33 33h199q-91 79 -91 204 q0 43 14 87l122 459h270l121 -459q15 -42 15 -87q0 -121 -93 -204zM1220 732l-111 427h-170l-111 -427q-8 -23 -8 -51q0 -84 60 -144t144 -60t143.5 60t59.5 144q0 27 -7 51z\" />
</g>"

set truetype_Magnetic(bk) "
<g
  scidb:bbox=\"110,135,1938,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M461 135q-48 0 -66.5 52t-46.5 87h675h677q-28 -35 -47 -87t-66 -52h-565h-561zM410 1276q-89 -53 -38 -141l101 -174q50 -89 140 -38h1q89 52 37 141l-100 174q-53 88 -141 38v0zM1638 1275q-91 52 -141 -37l-101 -174q-51 -89 38 -141v0q89 -52 141 38l100 174 q52 88 -37 140v0zM1024 1467q-103 0 -103 -103v-201q0 -103 103 -103v0q103 0 103 103v201q0 103 -103 103v0zM1452 682q-76 94 -187.5 150t-240.5 56q-130 0 -241 -56t-186 -150h855zM1127 563v-103h135v103h-135zM786 563v-103h135v103h-135zM444 563v-103h136v103h-136z M1468 563v-103h135v103h-135zM1060 1638h98q71 0 121.5 -50.5t50.5 -120.5v-114l43 75q35 61 103.5 79.5t130.5 -16.5l233 -134q60 -36 79 -105t-17 -129l-203 -353q-55 -93 -163 -89h103q55 0 95 -40t40 -95v-69q0 -56 -40 -95.5t-95 -39.5h-1230q-56 0 -95.5 39.5 t-39.5 95.5v69q0 55 39.5 95t95.5 40h103q-110 -4 -163 90l-203 352q-36 61 -17.5 129.5t79.5 104.5l233 134q60 35 129 16.5t105 -78.5l44 -77l-1 115q0 70 50 120.5t122 50.5h99l-17 86l-83 18v67l83 16l16 85h71l16 -85l84 -16v-67l-84 -18z\" />
</g>"

set truetype_Magnetic(bq) "
<g
  scidb:bbox=\"206,135,1841,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M527 442h994q50 0 50 -50v0q0 -50 -50 -50h-994q-50 0 -50 50v0q0 50 50 50zM570 135q-39 0 -54 52t-37 87h544.5h545.5q-23 -35 -38 -87t-53 -52h-456h-452zM1024 1638q-57 0 -96.5 39.5t-39.5 96.5q0 56 39.5 96t96.5 40q56 0 95.5 -40t39.5 -96q0 -57 -39.5 -96.5 t-95.5 -39.5zM1024 1101l-52 -87l-51 -85l51 -86l52 -85l51 85l52 86l-52 85zM580 1059q-5 75 -9.5 152l-9.5 155l259 -169l204 405l102.5 -204.5l102.5 -203.5l257 171q-5 -77 -8.5 -153.5t-7.5 -151.5h185.5h185.5l-135.5 -273.5l-134.5 -273.5h-548h-547l-135.5 273.5 l-134.5 273.5q93 -1 186.5 -1h187.5zM1577 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5t-95.5 -39.5zM471 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5 t-95.5 -39.5zM611 894l46.5 -88l47.5 -88h99h100l-47 87l-46 89h-101h-99zM1437 895h-100.5h-99.5l-47 -89l-47 -88h100h100l46.5 88z\" />
</g>"

set truetype_Magnetic(br) "
<g
  scidb:bbox=\"346,135,1702,1910\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1702 274q-31 -35 -50.5 -87t-66.5 -52h-563h-559q-48 0 -67 52t-50 87l166 168l172 954h-119q-53 0 -53 53v0q0 54 53 54h917q54 0 54 -54v0q0 -53 -54 -53h-117l171 -954zM1024 1228q-74 0 -74 -68v-172q0 -67 74 -67v0q75 0 75 67v172q0 68 -75 68v0zM1294 274 q-56 0 -95.5 39.5t-39.5 95.5v209q0 55 -40 95t-95 40v0q-57 0 -96 -40t-39 -95v-209q0 -56 -40.5 -95.5t-96.5 -39.5h542zM1516 1567h-492.5h-492.5q-58 0 -59.5 120.5t-1.5 222.5h91h92l64 -136h153l61 136h186l60 -136h154l64 136h182q0 -102 -2 -222.5t-59 -120.5z\" />
</g>"

set truetype_Magnetic(bb) "
<g
  scidb:bbox=\"481,129,1567,1774\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M665 442h718q50 0 50 -50v0q0 -50 -50 -50h-718q-50 0 -50 50v0q0 50 50 50zM905 135h-145.5h-144.5q-34 0 -47.5 52t-34.5 87q111 0 221.5 -0.5t221.5 -1.5q-18 -36 -20.5 -89.5t-50.5 -47.5zM1142 135q-45 -5 -48.5 48t-21.5 89q109 1 220.5 1.5t222.5 0.5 q-21 -35 -35 -87t-48 -52h-144.5h-145.5zM1074 1588l-1 -44q207 -17 350.5 -160t143.5 -338q0 -87 -35 -185q-48 -74 -86 -157t-45 -188h-377.5h-376.5q-11 112 -46 185.5t-84 156.5q-36 93 -36 188q0 195 143.5 338t350.5 160l-1 44q-83 32 -83 93q0 38 38.5 65.5 t92.5 27.5t93 -27.5t39 -65.5q0 -63 -80 -93zM956 688h135l36 310l135 32v136l-135 36l-36 171h-135l-35 -171l-135 -36v-136l135 -32z\" />
</g>"

set truetype_Magnetic(bn) "
<g
  scidb:bbox=\"240,135,1766,1887\">
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M392 1194q36 66 78.5 130.5t53.5 142.5q54 18 87.5 59t65.5 87l183 -115q-5 -4 -5 -17q0 -36 21 -60q-75 -223 -304 -431q-36 30 -90 82t-90 122zM1555 717q25 12 29 35q5 36 -19 49q-160 -60 -373.5 -55t-418.5 109q22 25 47.5 51t46.5 54q32 34 33 42l-12 -5 q-12 -5 -12 -9l-47.5 -21.5t-52.5 -17.5q-54 8 -111 -26q-31 21 -39 29q216 204 306 431q20 -2 24 -2q100 0 100 100q0 35 -22 56l79 113q45 -20 79 -37q125 -55 237 6q-28 -48 -62 -77q-16 -12 -35 -24q114 -107 261 -58q-31 -40 -74 -65q-15 -9 -50 -24q81 -138 239 -128 q-43 -32 -89 -43q-29 -9 -49 -7q41 -153 196 -183q-50 -19 -97 -19q-23 0 -45 3q0 -11 4 -31q-2 -69 -3 -120q61 -63 141 -79q-50 -19 -97 -19q-17 0 -51 4q-8 -50 -18 -105q60 -68 146 -85q-50 -19 -98 -19q-39 0 -92 16q-11 -18 -28 -43h-957q-60 0 -62 52t67 115 q30 35 65 67l70 62q211 -120 439.5 -134.5t404.5 42.5zM616 870q-29 -27 -62 -49.5t-73 -25.5q-10 0 -30 -5t-20 5q-18 -4 -30 2t-30 9q-22 5 -63 51.5t-53 66.5q-15 60 22 109.5l76 98.5q37 -68 126 -151t137 -111zM715 1670q4 3 17 18q13 42 11.5 90t-8.5 92q23 17 100 5 q14 -3 35 -9q48 -27 90.5 -72t60.5 -102q22 -10 34 -15l-72 -100q-10 4 -27 4q-40 0 -62 -25zM608 1378q-45 -76 -7 -97q38 -22 82 55q44 75 8 97q-39 20 -83 -55zM576 135q-39 0 -54 52t-37 87h545h546q-24 -35 -39 -87t-53 -52h-455.5h-452.5zM1527 442q50 0 50 -50v0 q0 -50 -50 -50h-995q-50 0 -50 50v0q0 50 50 50h995z\" />
</g>"

set truetype_Magnetic(bp) "
<g>
  scidb:bbox=\"612,135,1436,1635\"
  <path
    style=\"fill:black;stroke:none;fill-rule:evenodd\"
    d=\"M1154 1363h78q33 0 33 -34v0q0 -34 -33 -34h-416q-34 0 -34 34v0q0 34 34 34h77q-37 41 -37 104q0 69 49 118.5t119 49.5q69 0 118.5 -49.5t49.5 -118.5q0 -60 -38 -104zM1202 477h200q34 0 34 -33v0q0 -34 -34 -34h-757q-33 0 -33 34v0q0 33 33 33h199q-91 79 -91 204 q0 43 14 87l122 459h270l121 -459q15 -42 15 -87q0 -121 -93 -204zM754 135q-63 0 -85 77.5t-57 129.5h411h413q-36 -52 -58 -129.5t-84 -77.5h-281.5h-258.5z\" />
</g>"

set truetype_Magnetic(wk,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1060 1638h98q71 0 121.5 -50.5t50.5 -120.5v-114l43 75q35 61 103.5 79.5t130.5 -16.5l233 -134q60 -36 79 -105t-17 -129l-203 -353q-55 -93 -163 -89h103q55 0 95 -40t40 -95v-69q0 -56 -40 -95.5t-95 -39.5h-1230q-56 0 -95.5 39.5t-39.5 95.5v69q0 55 39.5 95 t95.5 40h103q-110 -4 -163 90l-203 352q-36 61 -17.5 129.5t79.5 104.5l233 134q60 35 129 16.5t105 -78.5l44 -77l-1 115q0 70 50 120.5t122 50.5h99l-17 86l-83 18v67l83 16l16 85h71l16 -85l84 -16v-67l-84 -18zM461 135q-48 0 -66.5 52t-46.5 87h675h677 q-28 -35 -47 -87t-66 -52h-565h-561z\" />
</g>"

set truetype_Magnetic(wq,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M471 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5t-95.5 -39.5zM1577 1387q-57 0 -96.5 39.5t-39.5 96.5q0 55 39.5 95t96.5 40q56 0 95.5 -40t39.5 -95q0 -57 -39.5 -96.5t-95.5 -39.5zM580 1059q-5 75 -9.5 152 l-9.5 155l259 -169l204 405l102.5 -204.5l102.5 -203.5l257 171q-5 -77 -8.5 -153.5t-7.5 -151.5h185.5h185.5l-135.5 -273.5l-134.5 -273.5h-548h-547l-135.5 273.5l-134.5 273.5q93 -1 186.5 -1h187.5zM1024 1638q-57 0 -96.5 39.5t-39.5 96.5q0 56 39.5 96t96.5 40 q56 0 95.5 -40t39.5 -96q0 -57 -39.5 -96.5t-95.5 -39.5zM570 135q-39 0 -54 52t-37 87h544.5h545.5q-23 -35 -38 -87t-53 -52h-456h-452zM527 442h994q50 0 50 -50v0q0 -50 -50 -50h-994q-50 0 -50 50v0q0 50 50 50z\" />
</g>"

set truetype_Magnetic(wr,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1516 1567h-492.5h-492.5q-58 0 -59.5 120.5t-1.5 222.5h91h92l64 -136h153l61 136h186l60 -136h154l64 136h182q0 -102 -2 -222.5t-59 -120.5zM1297 1395zM1702 274q-31 -35 -50.5 -87t-66.5 -52h-563h-559q-48 0 -67 52t-50 87l166 168l172 954h-119q-53 0 -53 53v0 q0 54 53 54h917q54 0 54 -54v0q0 -53 -54 -53h-117l171 -954z\" />
</g>"

set truetype_Magnetic(wb,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1074 1588l-1 -44q207 -17 350.5 -160t143.5 -338q0 -87 -35 -185q-48 -74 -86 -157t-45 -188h-377.5h-376.5q-11 112 -46 185.5t-84 156.5q-36 93 -36 188q0 195 143.5 338t350.5 160l-1 44q-83 32 -83 93q0 38 38.5 65.5t92.5 27.5t93 -27.5t39 -65.5q0 -63 -80 -93z M1142 135q-45 -5 -48.5 48t-21.5 89q109 1 220.5 1.5t222.5 0.5q-21 -35 -35 -87t-48 -52h-144.5h-145.5zM905 135h-145.5h-144.5q-34 0 -47.5 52t-34.5 87q111 0 221.5 -0.5t221.5 -1.5q-18 -36 -20.5 -89.5t-50.5 -47.5zM665 442h718q50 0 50 -50v0q0 -50 -50 -50h-718 q-50 0 -50 50v0q0 50 50 50z\" />
</g>"

set truetype_Magnetic(wn,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1521 513h-957q-59 0 -61 52t67 115q30 35 65 67l68 64q-25 14 -45.5 30.5t-45.5 28.5q-30 -27 -63.5 -49.5t-73.5 -25.5q-10 0 -30 -5t-20 5q-18 -4 -30 2t-30 9q-23 5 -63.5 51.5t-52.5 66.5q-18 75 37 133.5t90 122.5q36 70 83.5 134t58.5 153q69 24 112.5 93.5 t95.5 127.5q13 42 11.5 90t-8.5 92q15 11 43 10t56 -5q15 -3 36 -9q48 -27 90.5 -72t60.5 -102q43 -21 85 -39.5l86 -39.5q125 -55 237 6q-28 -48 -62 -77q-16 -12 -35 -24q114 -107 261 -58q-31 -40 -75 -65q-12 -8 -25 -13.5l-24 -10.5q81 -138 238 -128q-42 -32 -88 -43 q-29 -9 -50 -7q43 -153 197 -183q-50 -19 -97 -19q-23 0 -45 3q0 -11 4 -31q-2 -69 -3 -120q61 -64 141 -79q-50 -19 -97 -19q-17 0 -51 4q-8 -50 -18 -105q60 -67 145 -85q-48 -19 -97 -19q-41 0 -92 16q-13 -22 -29 -43zM570 135q-39 0 -54 52t-37 87h544.5h545.5 q-23 -35 -38 -87t-53 -52h-456h-452zM1520 442q50 0 50 -50v0q0 -50 -50 -50h-994q-50 0 -50 50v0q0 50 50 50h994z\" />
</g>"

set truetype_Magnetic(wp,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1154 1363h78q33 0 33 -34v0q0 -34 -33 -34h-416q-34 0 -34 34v0q0 34 34 34h77q-37 41 -37 104q0 69 49 118.5t119 49.5q69 0 118.5 -49.5t49.5 -118.5q0 -60 -38 -104zM1202 477h200q34 0 34 -33v0q0 -34 -34 -34h-757q-33 0 -33 34v0q0 33 33 33h199q-91 79 -91 204 q0 43 14 87l122 459h270l121 -459q15 -42 15 -87q0 -121 -93 -204zM754 135q-63 0 -85 77.5t-57 129.5h411h413q-36 -52 -58 -129.5t-84 -77.5h-281.5h-258.5z\" />
</g>"

set truetype_Magnetic(bk,mask) $truetype_Magnetic(wk,mask)
set truetype_Magnetic(bq,mask) $truetype_Magnetic(wq,mask)
set truetype_Magnetic(br,mask) $truetype_Magnetic(wr,mask)
set truetype_Magnetic(bb,mask) $truetype_Magnetic(wb,mask)

set truetype_Magnetic(bn,mask) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M392 1194q36 66 78.5 130.5t53.5 142.5q54 18 87.5 59t65.5 87l183 -115q-5 -4 -5 -17q0 -36 21 -60q-75 -223 -304 -431q-36 30 -90 82t-90 122zM1555 717q25 12 29 35q5 36 -19 49q-160 -60 -373.5 -55t-418.5 109q22 25 47.5 51t46.5 54q32 34 33 42l-12 -5 q-12 -5 -12 -9l-47.5 -21.5t-52.5 -17.5q-54 8 -111 -26q-31 21 -39 29q216 204 306 431q20 -2 24 -2q100 0 100 100q0 35 -22 56l79 113q45 -20 79 -37q125 -55 237 6q-28 -48 -62 -77q-16 -12 -35 -24q114 -107 261 -58q-31 -40 -74 -65q-15 -9 -50 -24q81 -138 239 -128 q-43 -32 -89 -43q-29 -9 -49 -7q41 -153 196 -183q-50 -19 -97 -19q-23 0 -45 3q0 -11 4 -31q-2 -69 -3 -120q61 -63 141 -79q-50 -19 -97 -19q-17 0 -51 4q-8 -50 -18 -105q60 -68 146 -85q-50 -19 -98 -19q-39 0 -92 16q-11 -18 -28 -43h-957q-60 0 -62 52t67 115 q30 35 65 67l70 62q211 -120 439.5 -134.5t404.5 42.5zM616 870q-29 -27 -62 -49.5t-73 -25.5q-10 0 -30 -5t-20 5q-18 -4 -30 2t-30 9q-22 5 -63 51.5t-53 66.5q-15 60 22 109.5l76 98.5q37 -68 126 -151t137 -111zM715 1670q4 3 17 18q13 42 11.5 90t-8.5 92q23 17 100 5 q14 -3 35 -9q48 -27 90.5 -72t60.5 -102q22 -10 34 -15l-72 -100q-10 4 -27 4q-40 0 -62 -25zM576 135q-39 0 -54 52t-37 87h545h546q-24 -35 -39 -87t-53 -52h-455.5h-452.5zM1527 442q50 0 50 -50v0q0 -50 -50 -50h-995q-50 0 -50 50v0q0 50 50 50h995z\" />
</g>"

set truetype_Magnetic(bp,mask) $truetype_Magnetic(wp,mask)

set truetype_Magnetic(wk,exterior) "
<g>
  <path
    d=\"M1423 810l76 -44q89 -52 141 38l204 353q50 88 -38 141l-233 134q-90 53 -141 -37l-171 -295l1 367q0 103 -103 103h-270 q-103 0 -103 -103v-366l-170 294q-52 89 -141 38l-233 -135q-90 -52 -38 -141l204 -353q51 -90 141 -38l77 45q172 145 398 145q224 0 399 -146z\" />
  <path
    d=\"M1452 682q-76 94 -187.5 150t-240.5 56q-130 0 -241 -56t-186 -150h855z\" />
  <path
    d=\"M409 613q-68 0 -68 -67v-68q0 -68 68 -68h1230q67 0 67 68v68q0 67 -67 67h-1230z\" />
  <path
    d=\"M461 135q-48 0 -66.5 52t-46.5 87 h675h677q-28 -35 -47 -87t-66 -52h-565h-561z\" />
</g>"

set truetype_Magnetic(wq,exterior) "
<g>
  <path
    d=\"M1024 1706q67 0 67 68t-67 68q-68 0 -68 -68t68 -68z\" />
  <path
    d=\"M1577 1455q67 0 67 68q0 67 -67 67q-68 0 -68 -67q0 -68 68 -68z\" />
  <path
    d=\"M471 1455q67 0 67 68 q0 67 -67 67q-68 0 -68 -67q0 -68 68 -68z\" />
  <path
    d=\"M1414 1241l-101 -66.5l-106 -72.5l-92 182.5l-91 185.5l-92 -182.5l-92 -181.5 l-105.5 69.5l-100.5 67.5q3 -64 10 -126.5t10 -124.5h-174h-174l102.5 -206l103.5 -205h511h513l102.5 205l103.5 206h-171.5h-169.5q5 137 13 249z\" />
</g>"

set truetype_Magnetic(wr,exterior) "
<g>
  <path
    d=\"M1516 1842h-92l-61 -132h-218l-60 132h-122l-61 -132h-217l-61 132h-47h-46q0 -51 3 -131t35 -80h456h457q31 0 32.5 80 t1.5 131z\" />
  <path
    d=\"M755 274q54 0 94 39.5t40 95.5v209q0 55 39 95t96 40v0q55 0 95 -40t40 -95v-209q0 -56 39 -95.5t91 -39.5h161h163l-139 137l-177 984l-552 -1l-89 -491.5l-88 -491.5l-70.5 -68.5l-69.5 -68.5h327z\" />
</g>"

set truetype_Magnetic(wb,exterior) "
<g>
  <path
    d=\"M1026 1708 q-57 0 -57 -33q0 -32 57 -32q56 0 56 32q0 33 -56 33z\" />
  <path
    d=\"M596 859q38 -62 67.5 -129.5t29.5 -142.5h331h332q12 136 97 273q47 87 47 186q0 177 -140 304t-336 127q-198 0 -337 -127t-139 -304q0 -99 48 -187z\" />
</g>"

set truetype_Magnetic(wn,exterior) "
<g>
  <path
    d=\"M773 1630l114 -74q23 25 62 25q18 0 28 -4l29 43l-49 25 q-18 53 -26.5 71.5t-38.5 51.5q-18 17 -36.5 30.5t-48.5 12.5q7 -51 5 -88.5t-28 -73.5q-11 -11 -11 -19z M1547 716q-174 -57 -377.5 -43.5t-398.5 105.5l-30 -28.5t-34 -35.5q-38 -39 -93.5 -80.5t-20.5 -52.5h891q48 78 63 135z M393 1059 q-62 -69 -74 -100q18 -29 45 -63t69 -36q21 -9 43.5 0t37.5 21q15 6 41 25q-42 33 -83 73z M1062 1588l-34 -51q22 -21 22 -56 q0 -100 -101 -100q-3 0 -23 2q-98 -214 -272 -384q21 12 55 19q33 -3 53 0.5t51 27.5q3 0 90.5 17t45.5 -55q-9 -24 -21.5 -53.5t-36.5 -60.5q-22 -40 -56 -68q186 -78 374.5 -82t347.5 56q3 83 -16 187q-35 203 -149 345q-53 69 -116 118q-79 64 -214 138z M764 857l49.5 49.5t46.5 53.5q33 33 34 42l-12.5 -5q-12.5 -5 -11.5 -9l-48.5 -21.5t-52.5 -17.5q-58 8 -107 -30q25 -17 51 -32z M734 1578q-33 -48 -72 -97t-87 -64 q-9 -67 -58.5 -152l-82.5 -140q61 -74 132 -135q102 102 183 206t121 225q-21 24 -21 60q0 13 5 17z\" />
</g>"

set truetype_Magnetic(wp,exterior) "
<g>
  <path
    d=\"M1024 1570q-104 0 -104 -103q0 -104 104 -104q103 0 103 104q0 103 -103 103z\" />
  <path
    d=\"M1220 732l-111 427h-170l-111 -427q-8 -23 -8 -51q0 -84 60 -144t144 -60t143.5 60t59.5 144q0 27 -7 51z\" />
  <path
    d=\"M754 203h268h272q20 0 25.5 26.5t17.5 44.5h-313.5h-312.5q10 -18 16 -44.5t27 -26.5z\" />
</g>"

set truetype_Magnetic(bk,exterior) $truetype_Magnetic(bk,mask)
set truetype_Magnetic(bq,exterior) $truetype_Magnetic(bq,mask)
set truetype_Magnetic(br,exterior) $truetype_Magnetic(br,mask)
set truetype_Magnetic(bb,exterior) $truetype_Magnetic(bb,mask)
set truetype_Magnetic(bn,exterior) $truetype_Magnetic(bn,mask)
set truetype_Magnetic(bp,exterior) $truetype_Magnetic(bp,mask)

set truetype_Magnetic(bk,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1452 682q-76 94 -187.5 150t-240.5 56q-130 0 -241 -56t-186 -150h855z M1024 1467q-103 0 -103 -103v-201q0 -103 103 -103v0q103 0 103 103v201q0 103 -103 103v0z M1638 1275q-91 52 -141 -37l-101 -174q-51 -89 38 -141v0q89 -52 141 38l100 174 q52 88 -37 140v0z M410 1276q-89 -53 -38 -141l101 -174q50 -89 140 -38h1q89 52 37 141l-100 174q-53 88 -141 38v0z M1127 563v-103h135v103h-135z M786 563v-103h135v103h-135z M444 563v-103h136v103h-136z M1468 563v-103h135v103h-135z\" />
</g>"

set truetype_Magnetic(bq,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1437 895h-100.5h-99.5l-47 -89l-47 -88h100h100l46.5 88z M611 894l46.5 -88l47.5 -88h99h100l-47 87l-46 89h-101h-99z M1024 1101l-52 -87l-51 -85l51 -86l52 -85l51 85l52 86l-52 85z\" />
</g>"

set truetype_Magnetic(br,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M1024 1228q-74 0 -74 -68v-172q0 -67 74 -67v0q75 0 75 67v172q0 68 -75 68v0z M1294 274 q-56 0 -95.5 39.5t-39.5 95.5v209q0 55 -40 95t-95 40v0q-57 0 -96 -40t-39 -95v-209q0 -56 -40.5 -95.5t-96.5 -39.5h542z\" />
</g>"

set truetype_Magnetic(bb,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M956 688h135l36 310l135 32v136l-135 36l-36 171h-135l-35 -171l-135 -36v-136l135 -32z\" />
</g>"

set truetype_Magnetic(bn,interior) "
<g>
  <path
    style=\"fill:white;stroke:none\"
    d=\"M608 1378q-45 -76 -7 -97q38 -22 82 55q44 75 8 97q-39 20 -83 -55z\" />
</g>"

set truetype_Magnetic(bp,interior) ""

set truetype_Magnetic(sample,24pt,200x34) {
  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
}

# vi:set ts=2 sw=2 et:
