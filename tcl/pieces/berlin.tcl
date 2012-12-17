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

# Font by Eric Bentzen
# <http://www.enpassant.dk/chess/fonteng.htm>

lappend board_PieceSet { Berlin truetype {stroke 10} {contour 80} {sampling 200} }

set truetype_Berlin(wk) {
<g
  scidb:bbox="203,205,1845,1774">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1332 485q169 0 263.5 82.5t121.5 111.5q37 40 45 76.5q8 35.5 8 36.5v195q0 71 -40.5 138.5t-81.5 102.5q-62 51 -129 79.5t-99 28.5h-207l-151 -613v-162l77 -40.5q77 -40.5 193 -35.5zM1148 1495q-19 -18 -50.5 -36t-73.5 -18q-73 0 -123 54h-9v-81l108 -410h24h24 l108 410v81h-8zM717 488q60 0 109.5 11t85.5 25q35 13 54.5 24.5q18.5 10.5 19.5 11.5v163l-149 613h-214q-6 0 -55 -11.5t-109 -48t-114 -107t-68 -188.5v-189q28 -140 168 -222.5t272 -81.5zM1024 495q-219 -125 -380.5 -80q-160.5 45 -161.5 45v-179h542h542v179 l-162 -45q-162 -45 -380 80zM1178 1543h68v-131h180v0l59 -14q59 -14 133 -57.5t141.5 -125.5t85.5 -218v-202l-22 -86.5q-22 -86.5 -178 -194.5v-309h-621h-621v309q-157 108 -178.5 194.5q-21.5 85.5 -21.5 86.5v202q17 136 84.5 218t142 125.5t133.5 57.5q58 14 59 14v0 h180v131h68q-13 27 -13 60q0 68 48 119.5t119 51.5q70 0 118.5 -51.5t48.5 -119.5q0 -33 -13 -60zM1024 1701q-95 0 -95 -93q0 -94 95 -94t95 94q0 93 -95 93z" />
</g>}

set truetype_Berlin(wq) {
<g
  scidb:bbox="197,205,1851,1823">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1024 1423v0l-171 -770l-228 563l-82 -445q-54 102 -175 192l52.5 -246.5l53.5 -246.5h330q46 0 112 43.5t108 94.5q42 -51 107.5 -94.5t112.5 -43.5h330l106 495q-102 -67 -175 -194l-82 445l-228 -563zM1024 205h-636v314l-191 807q96 -162 161.5 -195t127.5 -129 q32 180 56 281.5t50 241.5l253 -562l179 860l179 -860l253 562l92 -530q54 87 131.5 125t171.5 206l-191 -807v-314h-636zM1024 282h550v110h-151.5h-150.5q-85 2 -150 41.5t-98 79.5q-53 -66 -124.5 -93.5t-123.5 -27.5h-151.5h-150.5v-110h550z" />
</g>}

set truetype_Berlin(wr) {
<g
  scidb:bbox="428,205,1620,1607">
  scidb:scale="0.975"
  scidb:translate="0,50"
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M509 1607h272v-104h107v103h273v-103h99v104h279v-395h-1030v395zM573 1538v-256h891v256h-134v-105h-245v105h-131v-105h-243v105h-138zM641 1212l-115 -729h70l115 729h-70zM1324 1212l128 -729h70l-128 729h-70zM428 483h1192v-278h-1192v278zM492 412v-132h1058v132 h-1058z" />
</g>}

set truetype_Berlin(wb) {
<g
  scidb:bbox="300,205,1748,1856">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M970 566v-267h-419l-251 -94v266l251 95h419zM894 491h-331l-189 -72v-108l158 60h362v120zM1153 489v-115h360l160 -63v108l-186 70h-334zM922 1410l-66 -2.5q-66 -2.5 -145.5 -25t-147 -73.5t-70.5 -148v-185l21.5 -68q21.5 -68 95.5 -159h829l55 82q55 82 68 151v177 q0 36 -28 92l-235 -234l-186 185l187 187q3 1 -50.5 12.5t-122.5 8.5l-101 57zM1027 1856l219 -220l-116 -116l17 -34q120 0 205.5 -32.5q84.5 -32.5 85.5 -32.5l-220 -220l83 -83l238 237q70 -54 83 -124q13 -69 13 -70v-186q-18 -111 -70 -185.5q-51 -73.5 -52 -74.5v-40 h-974v49q-80 95 -100 172q-20 76 -20 77v186q1 126 77 192.5t166 96.5t165 34q74 4 75 4l18 33l-115 115zM1078 566h419l251 -95v-266l-251 94h-419v267zM910 1635l115 -116l116 116l-116 116z" />
</g>}

set truetype_Berlin(wn) {
<g
  scidb:bbox="292,205,1726,1820">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M990 1794l1 26l208 -208q208 -68 316.5 -160t155 -176t51 -142q4.5 -57 4.5 -58v-871h-1329v81q21 78 110.5 120.5t188.5 62t178.5 23q78.5 3.5 79.5 3.5l95 111v93h-80q-102 83 -150 168l-266 -138h-96l-165 152v81l327 311v36h-36v51q43 46 91 90.5t93 70.5 q90 51 156.5 62q65.5 11 66.5 11v200zM828 1432l141 -138h-141v138zM1067 1532l-102.5 -20q-102.5 -20 -153.5 -52q-91 -55 -165 -151h39v-73l-324 -313l139 -133l336 175q40 -49 84 -108.5t86 -84.5h119v-196l-139 -155l-65.5 -2q-65.5 -2 -149.5 -13.5t-165 -35.5 t-112 -68v-18l1148 2v768l-3.5 53q-3.5 53 -45.5 128.5t-140 159.5t-286 146l-100 97v-106z" />
</g>}

set truetype_Berlin(wp) {
<g
  scidb:bbox="469,205,1579,1605">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1026 775q-148 0 -314.5 -102.5t-166.5 -281.5v-40.5v-39.5v-14.5v-6.5l959 1v101q-2 174 -165.5 278.5t-312.5 104.5zM930 1336q-57 46 -57 118q0 63 44 107t107 44q62 0 106.5 -44t44.5 -107q0 -73 -57 -118q88 -27 145.5 -100t57.5 -166q0 -163 -148 -242 q159 -39 273.5 -150t130.5 -253q1 -6 1 -33l1 -53l-1 -134h-1108q-1 0 -1 59.5v80.5v46.5t1 32.5q18 147 133.5 257t275.5 148q-148 81 -148 241q0 93 55 167q54 71 144 99zM1028 865q98 0 159.5 60t61.5 149q0 88 -60 153t-158 65q-99 0 -162 -65t-63 -153q0 -89 61.5 -149 t160.5 -60zM1024 1532q-78 0 -78 -78t78 -78t78 78t-78 78z" />
</g>}

set truetype_Berlin(bk) {
<g
  scidb:bbox="203,205,1845,1774">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1178 1543h68v-131h180v0l59 -14q59 -14 133 -57.5t141.5 -125.5t85.5 -218v-202l-22 -86.5q-22 -86.5 -178 -194.5v-309h-621h-621v309q-157 108 -178.5 194.5q-21.5 85.5 -21.5 86.5v202q17 136 84.5 218t142 125.5t133.5 57.5q58 14 59 14v0h180v131h68q-13 27 -13 60 q0 68 48 119.5t119 51.5q70 0 118.5 -51.5t48.5 -119.5q0 -33 -13 -60zM1148 1495q-19 -18 -50.5 -36t-73.5 -18q-73 0 -123 54h-9v-81l108 -410h24h24l108 410v81h-8zM482 460l161.5 -45q161.5 -45 380.5 80q218 -125 380.5 -80q161.5 45 162.5 45l78 53v56.5v57.5 q-146 -127 -306.5 -121.5t-314.5 100.5q-145 -96 -313.5 -97t-307.5 112v-108q38 -28 79 -53z" />
</g>}

set truetype_Berlin(bq) {
<g
  scidb:bbox="197,205,1851,1823">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1660 482h-416q-47 0 -112.5 43.5t-107.5 94.5q-42 -51 -108 -94.5t-112 -43.5h-416v37l-191 807q96 -162 161.5 -195t127.5 -129q32 180 56 281.5t50 241.5l253 -562l179 860l179 -860l253 562l92 -530q54 87 131.5 125t171.5 206l-191 -807v-37zM1660 384v-179h-636 h-636v179h193.5h194.5q52 0 123.5 27t124.5 93q33 -40 98 -79.5t150 -40.5h193.5h194.5z" />
</g>}

set truetype_Berlin(br) {
<g
  scidb:bbox="428,205,1620,1607">
  scidb:scale="0.975"
  scidb:translate="0,50"
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M527 483v-92h994v92h-994zM1522 483h98v-278h-1192v278h98l115 729v0h-132v395h272v-104h107v103h273v-103h99v104h279v-395h-145zM641 1212h753v96h-753v-96z" />
</g>}

set truetype_Berlin(bb) {
<g
  scidb:bbox="300,205,1748,1856">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M1079 566h418l252 -95v-266l-252 94h-418v267zM1027 1856l220 -220l-116 -116v-34q120 2 214 -31.5q93 -33.5 94 -33.5l-220 -220l83 -83l237 237q70 -54 83.5 -124q13.5 -69 13.5 -70v-186q-18 -111 -70 -185.5q-51 -73.5 -52 -74.5v-40h-975v49q-80 95 -100 172 q-20 76 -20 77v186q1 126 79.5 192.5t172 96.5t171.5 34q77 4 78 4v33l-114 115zM970 566v-267h-419l-251 -94v266l251 95h419zM912 1635l115 -116l116 116l-116 116z" />
</g>}

set truetype_Berlin(bn) {
<g
  scidb:bbox="292,205,1726,1820">
  <path
    transform="translate(0,-2)"
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M817 1444v-158h162zM990 1797l1 25l208 -208q208 -68 316.5 -160t155 -175.5t51 -142q4.5 -57.5 4.5 -58.5v-871h-1329v81q21 78 110.5 121t188.5 62.5t178.5 23q78.5 3.5 79.5 3.5l95 110v93h-80q-102 83 -150 168l-266 -138h-96l-165 153v81l327 311v36h-36v51 q43 45 91 89.5t93 70.5q90 51 156.5 62q65.5 11 66.5 11v201z" />
</g>}

set truetype_Berlin(bp) {
<g
  scidb:bbox="469,205,1579,1605">
  <path
    style="fill:black;stroke:none;fill-rule:evenodd"
    d="M930 1336q-57 46 -57 118q0 63 44 107t107 44q62 0 106.5 -44t44.5 -107q0 -73 -57 -118q88 -27 145.5 -100t57.5 -166q0 -163 -148 -242q159 -39 273.5 -150t130.5 -253q1 -6 1 -33l1 -53l-1 -134h-1108q-1 0 -1 59.5v80.5v46.5t1 32.5q18 147 133.5 257t275.5 148 q-148 81 -148 241q0 93 55 167q54 71 144 99z" />
</g>}

set truetype_Berlin(wk,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1178 1543h68v-131h180v0l59 -14q59 -14 133 -57.5t141.5 -125.5t85.5 -218v-202l-22 -86.5q-22 -86.5 -178 -194.5v-309h-621h-621v309q-157 108 -178.5 194.5q-21.5 85.5 -21.5 86.5v202q17 136 84.5 218t142 125.5t133.5 57.5q58 14 59 14v0h180v131h68q-13 27 -13 60 q0 68 48 119.5t119 51.5q70 0 118.5 -51.5t48.5 -119.5q0 -33 -13 -60z" />
</g>}

set truetype_Berlin(wq,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1024 205h-636v314l-191 807q96 -162 161.5 -195t127.5 -129q32 180 56 281.5t50 241.5l253 -562l179 860l179 -860l253 562l92 -530q54 87 131.5 125t171.5 206l-191 -807v-314h-636z" />
</g>}

set truetype_Berlin(wr,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1521 483h-994zM1522 483h98v-278h-1192v278h98l115 729v0h-132v395h272v-104h107v103h273v-103h99v104h279v-395h-145zM641 1212h753z" />
</g>}

set truetype_Berlin(wb,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M970 566v-267h-419l-251 -94v266l251 95h419zM1027 1856l219 -220l-116 -116l17 -34q120 0 205.5 -32.5q84.5 -32.5 85.5 -32.5l-220 -220l83 -83l238 237q70 -54 83 -124q13 -69 13 -70v-186q-18 -111 -70 -185.5q-51 -73.5 -52 -74.5v-40h-974v49q-80 95 -100 172 q-20 76 -20 77v186q1 126 77 192.5t166 96.5t165 34q74 4 75 4l18 33l-115 115zM1078 566h419l251 -95v-266l-251 94h-419v267z" />
</g>}

set truetype_Berlin(wn,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M990 1794l1 26l208 -208q208 -68 316.5 -160t155 -176t51 -142q4.5 -57 4.5 -58v-871h-1329v81q21 78 110.5 120.5t188.5 62t178.5 23q78.5 3.5 79.5 3.5l95 111v93h-80q-102 83 -150 168l-266 -138h-96l-165 152v81l327 311v36h-36v51q43 46 91 90.5t93 70.5 q90 51 156.5 62q65.5 11 66.5 11v200z" />
</g>}

set truetype_Berlin(wp,mask) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M930 1336q-57 46 -57 118q0 63 44 107t107 44q62 0 106.5 -44t44.5 -107q0 -73 -57 -118q88 -27 145.5 -100t57.5 -166q0 -163 -148 -242q159 -39 273.5 -150t130.5 -253q1 -6 1 -33l1 -53l-1 -134h-1108q-1 0 -1 59.5v80.5v46.5t1 32.5q18 147 133.5 257t275.5 148 q-148 81 -148 241q0 93 55 167q54 71 144 99z" />
</g>}

set truetype_Berlin(bk,mask) $truetype_Berlin(wk,mask)
set truetype_Berlin(bq,mask) $truetype_Berlin(bq)
set truetype_Berlin(br,mask) $truetype_Berlin(wr,mask)
set truetype_Berlin(bb,mask) $truetype_Berlin(wb,mask)
set truetype_Berlin(bn,mask) $truetype_Berlin(wn,mask)
set truetype_Berlin(bp,mask) $truetype_Berlin(wp,mask)

set truetype_Berlin(wk,exterior) {
<g>
  <path
    d="M1332 485q169 0 263.5 82.5t121.5 111.5q37 40 45 76.5q8 35.5 8 36.5v195q0 71 -40.5 138.5t-81.5 102.5q-62 51 -129 79.5t-99 28.5h-207l-151 -613v-162l77 -40.5q77 -40.5 193 -35.5z"/>
  <path
    d="M1148 1495q-19 -18 -50.5 -36t-73.5 -18q-73 0 -123 54h-9v-81l108 -410h24h24 l108 410v81h-8z"/>
  <path
    d="M717 488q60 0 109.5 11t85.5 25q35 13 54.5 24.5q18.5 10.5 19.5 11.5v163l-149 613h-214q-6 0 -55 -11.5t-109 -48t-114 -107t-68 -188.5v-189q28 -140 168 -222.5t272 -81.5z"/>
  <path
    d="M1024 495q-219 -125 -380.5 -80q-160.5 45 -161.5 45v-179h542h542v179 l-162 -45q-162 -45 -380 80z"/>
    <path
    d="M1024 1701q-95 0 -95 -93q0 -94 95 -94t95 94q0 93 -95 93z" />
</g>}

set truetype_Berlin(wq,exterior) {
<g>
  <path
    d="M1024 1423v0l-171 -770l-228 563l-82 -445q-54 102 -175 192l52.5 -246.5l53.5 -246.5h330q46 0 112 43.5t108 94.5q42 -51 107.5 -94.5t112.5 -43.5h330l106 495q-102 -67 -175 -194l-82 445l-228 -563z"/>
  <path
    d="M1024 282h550v110h-151.5h-150.5q-85 2 -150 41.5t-98 79.5q-53 -66 -124.5 -93.5t-123.5 -27.5h-151.5h-150.5v-110h550z" />
</g>}

set truetype_Berlin(wr,exterior) {
<g>
  <path
    d="M573 1538v-256h891v256h-134v-105h-245v105h-131v-105h-243v105h-138z" />
  <path
    original="M 295 1049 L 933 1049 L 1066 290 L 175 290 z"
    d="M709 1215L1337 1215L1470 476L589 476z" />
  <path
    d="M492 412v-132h1058v132 h-1058z" />
</g>}

set truetype_Berlin(wb,exterior) {
<g>
  <path
    d="M894 491h-331l-189 -72v-108l158 60h362v120z" />
  <path
    d="M1153 489v-115h360l160 -63v108l-186 70h-334z" />
  <path
    d="M922 1410l-66 -2.5q-66 -2.5 -145.5 -25t-147 -73.5t-70.5 -148v-185l21.5 -68q21.5 -68 95.5 -159h829l55 82q55 82 68 151v177 q0 36 -28 92l-235 -234l-186 185l187 187q3 1 -50.5 12.5t-122.5 8.5l-101 57z" />
  <path
    d="M910 1635l115 -116l116 116l-116 116z" />
</g>}

set truetype_Berlin(wn,exterior) {
<g>
  <path
    d="M828 1432l141 -138h-141v138zM1067 1532l-102.5 -20q-102.5 -20 -153.5 -52q-91 -55 -165 -151h39v-73l-324 -313l139 -133l336 175q40 -49 84 -108.5t86 -84.5h119v-196l-139 -155l-65.5 -2q-65.5 -2 -149.5 -13.5t-165 -35.5 t-112 -68v-18l1148 2v768l-3.5 53q-3.5 53 -45.5 128.5t-140 159.5t-286 146l-100 97v-106z" />
</g>}

set truetype_Berlin(wp,exterior) {
<g>
  <path
    d="M1026 775q-148 0 -314.5 -102.5t-166.5 -281.5v-40.5v-39.5v-14.5v-6.5l959 1v101q-2 174 -165.5 278.5t-312.5 104.5z"/>
  <path
    d="M1028 865q98 0 159.5 60t61.5 149q0 88 -60 153t-158 65q-99 0 -162 -65t-63 -153q0 -89 61.5 -149 t160.5 -60z"/>
  <path
    d="M1024 1532q-78 0 -78 -78t78 -78t78 78t-78 78z" />
</g>}

set truetype_Berlin(bk,exterior) $truetype_Berlin(bk,mask)
set truetype_Berlin(bq,exterior) $truetype_Berlin(bq,mask)
set truetype_Berlin(br,exterior) $truetype_Berlin(br,mask)
set truetype_Berlin(bb,exterior) $truetype_Berlin(bb,mask)
set truetype_Berlin(bn,exterior) $truetype_Berlin(bn,mask)
set truetype_Berlin(bp,exterior) $truetype_Berlin(bp,mask)

set truetype_Berlin(bk,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M1148 1495q-19 -18 -50.5 -36t-73.5 -18q-73 0 -123 54h-9v-81l108 -410h24h24l108 410v81h-8z" />
  <path
    style="fill:white;stroke:none"
    d="M482 460l161.5 -45q161.5 -45 380.5 80q218 -125 380.5 -80q161.5 45 162.5 45l78 53v56.5v57.5 q-146 -127 -306.5 -121.5t-314.5 100.5q-145 -96 -313.5 -97t-307.5 112v-108q38 -28 79 -53z" />
</g>}

set truetype_Berlin(bq,interior) {}

set truetype_Berlin(br,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M641 1212h753v96h-753v-96z" />
  <path
    style="fill:white;stroke:none"
    d="M527 483v-92h994v92h-994z" />
</g>}

set truetype_Berlin(bb,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M912 1635l115 -116l116 116l-116 116z" />
</g>}

set truetype_Berlin(bn,interior) {
<g>
  <path
    style="fill:white;stroke:none"
    d="M817 1444v-158h162z" />
</g>}

set truetype_Berlin(bp,interior) {}

set truetype_Berlin(sample,24pt,200x34) {
  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
  gg==
}

# vi:set ts=2 sw=2 et nowrap:
