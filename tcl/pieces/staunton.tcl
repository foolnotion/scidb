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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

# chess set "Free Staunton"
# Eran Karu
# http://sites.google.com/site/freestaunton/

# I've modified the piece set a bit for the Antigrain library.

lappend board_PieceSet { {Free Staunton} svg {contour 15} {sampling 60} }

set svg_FreeStaunton(wk) {
<svg
   scidb:translate="0,-3"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient10492">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10484">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10476">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9614">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9604">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9596">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9588">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9580">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.67843139;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient9580"
       id="linearGradient9586"
       x1="196.97609"
       y1="102.16049"
       x2="133.0168"
       y2="71.566544"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9588"
       id="linearGradient9594"
       x1="157.58086"
       y1="183.53535"
       x2="40.110264"
       y2="133.48027"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9596"
       id="linearGradient9602"
       x1="284.10904"
       y1="172.87549"
       x2="190.02399"
       y2="103.81798"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9604"
       id="linearGradient9610"
       x1="236.37131"
       y1="289.20724"
       x2="21.319765"
       y2="225.24794"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9604"
       id="linearGradient9612"
       x1="236.37131"
       y1="289.20724"
       x2="21.319765"
       y2="225.24794"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9614"
       id="linearGradient9620"
       x1="215.97849"
       y1="323.1076"
       x2="97.329361"
       y2="295.69586"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10476"
       id="linearGradient10482"
       x1="100.75392"
       y1="236.17719"
       x2="252.68014"
       y2="236.17719"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10484"
       id="linearGradient10490"
       x1="172.815"
       y1="53.622505"
       x2="180.816"
       y2="53.622505"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10492"
       id="linearGradient10498"
       x1="155.1344"
       y1="48.621905"
       x2="198.4974"
       y2="48.621905"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:none">
    <g>
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.37233,236.17719 C 249.06173,236.17719 249.06173,236.17719 249.06173,236.17719"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.23681688;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <g
         transform="translate(0,10)"
         style="fill:#ffffe6;fill-opacity:1;display:inline">
        <path
           style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           d="M 176.816,66.304005 C 194.4976,66.304005 198.918,70.007073 198.918,83.985605 C 198.918,97.246805 196.32859,111.26643 190.0772,123.7692 C 185.6568,132.61 185.6568,132.61 176.816,154.712" />
        <path
           style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
           d="M 176.51,65.883605 C 158.8284,65.883605 154.408,69.586675 154.408,83.565205 C 154.408,96.826405 156.99741,110.84603 163.2488,123.3488 C 167.6692,132.1896 167.6692,132.1896 176.51,154.2916" />
      </g>
      <path
         d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z"
         style="fill:#ffffe6;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <rect
       style="fill:url(#linearGradient9620);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="fill:url(#linearGradient9610);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:url(#linearGradient9612);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:url(#linearGradient10482);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:7.23681688000000010;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 104.37233,236.17719 C 249.06173,236.17719 249.06173,236.17719 249.06173,236.17719" />
    <path
       style="fill:url(#linearGradient9602);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z" />
    <path
       style="fill:url(#linearGradient10490);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005" />
    <path
       style="fill:url(#linearGradient10498);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405" />
    <g
       style="fill:url(#linearGradient9586);fill-opacity:1.0"
       transform="translate(0,10)">
      <path
         d="M 176.816,66.304005 C 194.4976,66.304005 198.918,70.007073 198.918,83.985605 C 198.918,97.246805 196.32859,111.26643 190.0772,123.7692 C 185.6568,132.61 185.6568,132.61 176.816,154.712"
         style="fill:url(#linearGradient9586);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 176.51,65.883605 C 158.8284,65.883605 154.408,69.586675 154.408,83.565205 C 154.408,96.826405 156.99741,110.84603 163.2488,123.3488 C 167.6692,132.1896 167.6692,132.1896 176.51,154.2916"
         style="fill:url(#linearGradient9586);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038000000090;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
    <path
       style="fill:url(#linearGradient9594);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z" />
  </g>
</svg>
}

set svg_FreeStaunton(wq) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient13608">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient13598">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient13590">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient13580">
      <stop
         style="stop-color:#ffffe6;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12422">
      <stop
         style="stop-color:#ffffff;stop-opacity:0.5234375;"
         offset="0" />
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12348">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12236">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12228">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12220">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12212">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12204">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12196">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient12182">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.671875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6431">
      <stop
         style="stop-color:#faff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#faff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6431"
       id="linearGradient6449"
       gradientUnits="userSpaceOnUse"
       x1="207.7588"
       y1="203.33641"
       x2="150.29359"
       y2="150.29161"
       gradientTransform="translate(35.3632,-0.8407951)" />
    <linearGradient
       xlink:href="#linearGradient6431"
       id="linearGradient6461"
       gradientUnits="userSpaceOnUse"
       x1="207.7588"
       y1="203.33641"
       x2="150.29359"
       y2="150.29161"
       gradientTransform="translate(32,0)" />
    <linearGradient
       xlink:href="#linearGradient12182"
       id="linearGradient12188"
       x1="194.65872"
       y1="262.5914"
       x2="75.567192"
       y2="229.6848"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12182"
       id="linearGradient12190"
       x1="194.65872"
       y1="262.5914"
       x2="75.567192"
       y2="229.6848"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12182"
       id="linearGradient12192"
       x1="194.65872"
       y1="262.5914"
       x2="75.567192"
       y2="229.6848"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12182"
       id="linearGradient12194"
       x1="194.65872"
       y1="262.5914"
       x2="75.567192"
       y2="229.6848"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12196"
       id="linearGradient12202"
       x1="254.44675"
       y1="163.60602"
       x2="231.2731"
       y2="148.3114"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12204"
       id="linearGradient12210"
       x1="222.00365"
       y1="158.50781"
       x2="199.29346"
       y2="143.67667"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12212"
       id="linearGradient12218"
       x1="182.14494"
       y1="161.75214"
       x2="159.55479"
       y2="146.92097"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12220"
       id="linearGradient12226"
       x1="147.84793"
       y1="153.87308"
       x2="115.86829"
       y2="140.89583"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12228"
       id="linearGradient12234"
       x1="114.47787"
       y1="167.3138"
       x2="81.107803"
       y2="155.2635"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient13580"
       id="linearGradient13586"
       x1="104.94064"
       y1="236.17719"
       x2="249.67453"
       y2="236.17719"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient13608"
       id="linearGradient13614"
       x1="44.147346"
       y1="67.764046"
       x2="79.146799"
       y2="83.985605"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12422"
       id="linearGradient14068"
       gradientUnits="userSpaceOnUse"
       x1="163.24971"
       y1="56.115055"
       x2="179.44934"
       y2="64.093803" />
    <linearGradient
       xlink:href="#linearGradient13590"
       id="linearGradient14070"
       gradientUnits="userSpaceOnUse"
       x1="153.08173"
       y1="42.739231"
       x2="200.7078"
       y2="55.253005" />
    <linearGradient
       xlink:href="#linearGradient13598"
       id="linearGradient14072"
       gradientUnits="userSpaceOnUse"
       x1="218.50465"
       y1="39.858681"
       x2="266.28826"
       y2="59.324556" />
    <linearGradient
       xlink:href="#linearGradient12236"
       id="linearGradient14074"
       gradientUnits="userSpaceOnUse"
       x1="115.40482"
       y1="61.178448"
       x2="74.517487"
       y2="50.421593" />
  </defs>
  <g
     style="display:inline">
    <rect
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.05921173;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 108.47025,236.17719 C 246.14492,236.17719 246.14492,236.17719 246.14492,236.17719" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(2.2101956,-8.8407986)" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
    <rect
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="148.82619"
       height="45.887592"
       x="102.4029"
       y="189.6579" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-59.200991,-2.915355)" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-118.98903,19.331356)" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(67.790652,-4.7692476)" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(123.40743,22.112195)" />
  </g>
  <g
     style="display:inline">
    <rect
       style="fill:url(#linearGradient12188);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="fill:url(#linearGradient12190);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:url(#linearGradient12192);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:url(#linearGradient13586);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:7.05921173000000040;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 108.47025,236.17719 C 246.14492,236.17719 246.14492,236.17719 246.14492,236.17719" />
    <path
       style="fill:url(#linearGradient12218);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
    <path
       style="fill:url(#linearGradient12210);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
    <path
       style="fill:url(#linearGradient12202);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
    <path
       style="fill:url(#linearGradient12226);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
    <path
       style="fill:url(#linearGradient12234);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
    <path
       transform="translate(2.2101956,-8.8407986)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(67.580456,-4.071551)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(-119.99164,19.8538926)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(-60.149817,-2.807157)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(122.75824,21.2203934)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(2.2101956,-8.8407986)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:url(#linearGradient14068);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(67.580456,-4.071551)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:url(#linearGradient14068);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(-119.99164,19.8538926)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:url(#linearGradient14068);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(-60.149817,-2.807157)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:url(#linearGradient14068);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <path
       transform="translate(122.75824,21.2203934)"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       style="fill:url(#linearGradient14068);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    <rect
       style="fill:url(#linearGradient12194);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       width="148.82619"
       height="45.887592"
       x="102.4029"
       y="189.6579" />
  </g>
</svg>
}

set svg_FreeStaunton(wr) {
<svg
   scidb:translate="0,17"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient13432">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3709">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3699"
       x1="265.224"
       y1="154.71201"
       x2="190.07719"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3709"
       id="linearGradient3715"
       x1="132.612"
       y1="154.71201"
       x2="57.465199"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3725"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="141.4528"
       y2="75.144806" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3939"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208" />
    <linearGradient
       xlink:href="#linearGradient13432"
       id="linearGradient13438"
       x1="191.87788"
       y1="199.75693"
       x2="68.594025"
       y2="168.70422"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:none">
    <g
       style="fill:#ffffff">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.34883,236.17719 C 249.05143,236.17719 249.05143,236.17719 249.05143,236.17719"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.23714638;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="97.627876"
         x="110.57373"
         height="138.02731"
         width="132.40428"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645653;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g
       style="fill-opacity:1.0;fill:url(#linearGradient13438)">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.34883,236.17719 C 249.05143,236.17719 249.05143,236.17719 249.05143,236.17719"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:7.23714638000000040;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="97.627876"
         x="110.57373"
         height="138.02731"
         width="132.40428"
         style="fill:url(#linearGradient13438);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645652999999930;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(wb) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient8515">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3709">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3699"
       x1="265.224"
       y1="154.71201"
       x2="190.07719"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3709"
       id="linearGradient3715"
       x1="132.612"
       y1="154.71201"
       x2="57.465199"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3725"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="141.4528"
       y2="75.144806" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3939"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8521"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8523"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8525"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8527"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8529"
       x1="197.83067"
       y1="58.432423"
       x2="161.67978"
       y2="42.982845"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8531"
       x1="191.41441"
       y1="152.48267"
       x2="107.98924"
       y2="100.11018"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8533"
       x1="198.3665"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8535"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8515"
       id="linearGradient8537"
       x1="216.44196"
       y1="209.02637"
       x2="80.180855"
       y2="163.60602"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:none">
    <g
       style="fill:#ffffff">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 103.90377,236.17719 C 249.38063,236.17719 249.38063,236.17719 249.38063,236.17719"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.2564826;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         transform="translate(-11.051004,-8.8408007)"
         d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 133.36855,198.814 C 220.12582,198.814 220.12582,198.814 220.12582,198.814"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:6.4707036;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <rect
       style="fill:url(#linearGradient8521);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="fill:url(#linearGradient8523);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:url(#linearGradient8525);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:url(#linearGradient8527);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.25648260000000000;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 103.90377,236.17719 C 249.38063,236.17719 249.38063,236.17719 249.38063,236.17719" />
    <path
       style="fill:url(#linearGradient8529);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
       transform="translate(-11.051004,-8.8408007)" />
    <path
       style="fill:url(#linearGradient8531);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z" />
    <path
       style="fill:url(#linearGradient8533);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z" />
    <path
       style="fill:url(#linearGradient8535);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:6.47070360000000020;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 133.36855,198.814 C 220.12582,198.814 220.12582,198.814 220.12582,198.814" />
    <path
       style="fill:url(#linearGradient8537);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754" />
  </g>
</svg>
}

set svg_FreeStaunton(wn) {
<svg
   scidb:translate="0,10"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient12660">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.67843139;"
         offset="0" />
      <stop
         style="stop-color:#feffff;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10468">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.52156866;"
         offset="0" />
      <stop
         style="stop-color:#000000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9177">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9177"
       id="linearGradient9185"
       x1="243.12199"
       y1="106.08761"
       x2="207.7588"
       y2="88.406006"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient12660"
       id="linearGradient12666"
       x1="216.90543"
       y1="198.3665"
       x2="78.790436"
       y2="156.19044"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="fill:#ffffff">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,287.324 C 185.65681,287.324 176.81601,287.324 79.5672,287.324 C 92.8284,274.0628 110.51001,256.3812 106.08961,238.6996 C 159.13441,238.6996 119.35081,238.6996 176.81601,238.6996 C 234.2812,238.6996 225.4404,238.6996 247.5424,238.6996 C 243.12201,256.3812 260.80361,274.0628 274.0648,287.324 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 101.41648,238.17719 C 251.52859,238.17719 251.52859,238.17719 251.52859,238.17719"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.37118053;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         transform="translate(-77.356994,13.261196)"
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g
       style="fill:url(#linearGradient12666);fill-opacity:1.0">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,287.324 C 185.65681,287.324 176.81601,287.324 79.5672,287.324 C 92.8284,274.0628 110.51001,256.3812 106.08961,238.6996 C 159.13441,238.6996 119.35081,238.6996 176.81601,238.6996 C 234.2812,238.6996 225.4404,238.6996 247.5424,238.6996 C 243.12201,256.3812 260.80361,274.0628 274.0648,287.324 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 101.41648,238.17719 C 251.52859,238.17719 251.52859,238.17719 251.52859,238.17719"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:7.37118053000000020;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         transform="translate(-77.356994,13.261196)"
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
         style="fill:url(#linearGradient12666);fill-opacity:1.0;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(wp) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient11330">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient11312">
      <stop
         style="stop-color:#d7a127;stop-opacity:0.6796875;"
         offset="0" />
      <stop
         style="stop-color:#ffffe6;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9951">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3709">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3699"
       x1="265.224"
       y1="154.71201"
       x2="190.07719"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3709"
       id="linearGradient3715"
       x1="132.612"
       y1="154.71201"
       x2="57.465199"
       y2="101.66721"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,10)" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3725"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="141.4528"
       y2="75.144806" />
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3939"
       gradientUnits="userSpaceOnUse"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208" />
    <linearGradient
       xlink:href="#linearGradient9951"
       id="linearGradient9957"
       x1="172.39661"
       y1="79.993866"
       x2="137.0334"
       y2="53.471466"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11318"
       x1="211.80722"
       y1="255.37369"
       x2="79.717384"
       y2="212.73416"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11320"
       x1="211.80722"
       y1="255.37369"
       x2="79.717384"
       y2="212.73416"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11322"
       x1="211.80722"
       y1="255.37369"
       x2="79.717384"
       y2="212.73416"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11324"
       x1="211.80722"
       y1="255.37369"
       x2="79.717384"
       y2="212.73416"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11326"
       x1="211.80722"
       y1="255.37369"
       x2="79.717384"
       y2="212.73416"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11312"
       id="linearGradient11328"
       x1="201.14734"
       y1="156.19044"
       x2="99.807045"
       y2="175.65631"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient11330"
       id="linearGradient11336"
       x1="191.57007"
       y1="83.810852"
       x2="116.02393"
       y2="59.246769"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="fill:#ffffff">
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.22529,236.17719 C 249.4067,236.17719 249.4067,236.17719 249.4067,236.17719"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.24911022;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         transform="translate(4.0156115,8.4203023)"
         d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 159.15615,119.3488 C 194.72097,119.3488 194.72097,119.3488 194.72097,119.3488"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:5.07404709;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <rect
       style="fill:url(#linearGradient11318);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="fill:url(#linearGradient11320);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:url(#linearGradient11322);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:url(#linearGradient11324);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.24911022000000040;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 104.22529,236.17719 C 249.4067,236.17719 249.4067,236.17719 249.4067,236.17719" />
    <path
       style="fill:url(#linearGradient11336);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
       transform="translate(4.0156115,8.4203023)" />
    <path
       style="fill:url(#linearGradient11326);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:5.07404708999999960;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 159.15615,119.3488 C 194.72097,119.3488 194.72097,119.3488 194.72097,119.3488" />
    <path
       style="fill:url(#linearGradient11328);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z" />
  </g>
</svg>
}

set svg_FreeStaunton(bk) {
<svg
   scidb:translate="0,-3"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient3422">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#000000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3397">
      <stop
         style="stop-color:#000000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#000000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3357">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffffff;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient4013">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient4005">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3997">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3989">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3989"
       id="linearGradient3995"
       x1="269.64441"
       y1="181.23441"
       x2="163.55479"
       y2="83.985603"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3997"
       id="linearGradient4003"
       x1="154.714"
       y1="190.07521"
       x2="22.101999"
       y2="83.985603"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient4005"
       id="linearGradient4011"
       x1="190.07719"
       y1="269.6424"
       x2="79.5672"
       y2="172.3936"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient4013"
       id="linearGradient4019"
       x1="185.6568"
       y1="296.16479"
       x2="22.101999"
       y2="203.33641"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient4013"
       id="linearGradient4021"
       x1="181.2364"
       y1="309.42599"
       x2="4.4204001"
       y2="229.85881"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3357"
       id="linearGradient3363"
       x1="189.28975"
       y1="110.2728"
       x2="124.59103"
       y2="110.2728"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3397"
       id="linearGradient3403"
       x1="150.664"
       y1="120.508"
       x2="202.918"
       y2="120.508"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient3422"
       id="linearGradient3428"
       x1="202.918"
       y1="113.12886"
       x2="95.855705"
       y2="81.149216"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="display:inline;fill:#ffffff">
      <path
         d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <g
         style="fill:#ffffff;fill-opacity:1">
        <path
           style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           d="M 176.816,76.42689 C 194.4976,76.42689 198.918,80.129958 198.918,94.10849 C 198.918,107.36967 196.32859,121.3893 190.0772,133.89207 C 185.6568,142.73287 185.6568,142.73287 176.816,164.83487" />
        <path
           style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038000000090;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
           d="M 176.816,76.303993 C 159.1344,76.303993 154.714,80.007063 154.714,93.985593 C 154.714,107.2468 157.30341,121.26643 163.5548,133.7692 C 167.9752,142.61 167.9752,142.61 176.816,164.712" />
      </g>
      <path
         d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.1276,236.17719 C 249.27265,236.17719 249.27265,236.17719 249.27265,236.17719"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:7.24820231999999990;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g>
      <path
         d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z"
         style="fill:url(#linearGradient3995);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <g
         style="fill:url(#linearGradient3428);fill-opacity:1">
        <path
           style="fill:url(#linearGradient3428);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           d="M 176.816,76.42689 C 194.4976,76.42689 198.918,80.129958 198.918,94.10849 C 198.918,107.36967 196.32859,121.3893 190.0772,133.89207 C 185.6568,142.73287 185.6568,142.73287 176.816,164.83487" />
        <path
           style="fill:url(#linearGradient3428);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
           d="M 176.816,76.303993 C 159.1344,76.303993 154.714,80.007063 154.714,93.985593 C 154.714,107.2468 157.30341,121.26643 163.5548,133.7692 C 167.9752,142.61 167.9752,142.61 176.816,164.712" />
      </g>
      <path
         d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z"
         style="fill:url(#linearGradient4003);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:url(#linearGradient4021);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:url(#linearGradient4019);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient4011);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.1276,236.17719 C 249.27265,236.17719 249.27265,236.17719 249.27265,236.17719"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:7.24820232;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(bq) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient7638">
      <stop
         style="stop-color:#5b0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6811">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6803">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6795">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6775">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6767">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6759">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6751">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6743">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient6573">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6743"
       id="linearGradient6749"
       x1="190.07719"
       y1="154.71201"
       x2="154.714"
       y2="114.92841"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6751"
       id="linearGradient6757"
       x1="225.4404"
       y1="150.29161"
       x2="198.918"
       y2="114.92841"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6759"
       id="linearGradient6765"
       x1="256.38321"
       y1="159.1324"
       x2="247.5424"
       y2="128.18961"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6767"
       id="linearGradient6773"
       x1="141.4528"
       y1="159.1324"
       x2="97.248802"
       y2="128.18961"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6775"
       id="linearGradient6781"
       x1="114.9304"
       y1="163.55281"
       x2="66.306"
       y2="141.45081"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient6793"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6795"
       id="linearGradient6801"
       x1="172.3956"
       y1="225.4384"
       x2="70.726402"
       y2="154.71201"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6803"
       id="linearGradient6809"
       x1="181.2364"
       y1="274.06281"
       x2="35.363201"
       y2="212.1772"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6811"
       id="linearGradient6817"
       x1="172.3956"
       y1="300.58521"
       x2="35.363201"
       y2="203.33641"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6811"
       id="linearGradient6819"
       x1="167.9752"
       y1="313.84641"
       x2="44.203999"
       y2="225.4384"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient7638"
       id="linearGradient7644"
       x1="217.02"
       y1="61.883605"
       x2="264.8036"
       y2="61.883605"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7664"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7668"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7672"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7676"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7680"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
    <linearGradient
       xlink:href="#linearGradient6573"
       id="linearGradient7684"
       gradientUnits="userSpaceOnUse"
       x1="183.44661"
       y1="70.724403"
       x2="152.5038"
       y2="48.622402" />
  </defs>
  <g
     style="display:inline">
    <path
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(2.2101956,-8.8407986)" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
    <rect
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="148.82619"
       height="45.887592"
       x="102.4029"
       y="189.6579" />
    <rect
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.04245234;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 109.00936,236.17719 C 246.03109,236.17719 246.03109,236.17719 246.03109,236.17719" />
    <path
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-61.981829,-1.9884087)" />
    <path
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-118.98903,19.331356)" />
    <path
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(66.400233,-1.5249356)" />
    <path
       style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(125.26132,21.648722)" />
  </g>
  <g
     style="display:inline">
    <path
       style="fill:url(#linearGradient6749);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
    <path
       style="fill:url(#linearGradient6757);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
    <path
       style="fill:url(#linearGradient6765);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
    <path
       style="fill:url(#linearGradient6773);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
    <path
       style="fill:url(#linearGradient6781);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
    <rect
       style="opacity:1;fill:url(#linearGradient6801);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       width="148.82619"
       height="45.887592"
       x="102.4029"
       y="189.6579" />
    <rect
       style="opacity:1;fill:url(#linearGradient6819);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="221.02"
       height="13.2612"
       x="66.305992"
       y="305.84641" />
    <rect
       style="opacity:1;fill:url(#linearGradient6817);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       width="212.1792"
       height="17.681601"
       x="70.726387"
       y="287.74438" />
    <path
       style="fill:url(#linearGradient6809);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
    <path
       style="fill:#5a0000;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.04245234;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 109.00936,236.17719 C 246.03109,236.17719 246.03109,236.17719 246.03109,236.17719" />
    <path
       style="opacity:1;fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(2.2101956,-8.8407986)" />
    <path
       style="opacity:1;fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(124.12076,20.206748)" />
    <path
       style="opacity:1;fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       id="path7678"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(66.191155,-2.2733991)" />
    <path
       style="opacity:1;fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-118.98903,19.331356)" />
    <path
       style="opacity:1;fill:white;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-61.981829,-1.9884087)" />
    <path
       style="opacity:1;fill:url(#linearGradient6793);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(2.2101956,-8.8407986)" />
    <path
       style="opacity:1;fill:url(#linearGradient7684);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(124.12076,20.206748)" />
    <path
       style="opacity:1;fill:url(#linearGradient7680);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       id="path7678"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(66.191155,-2.2733991)" />
    <path
       style="opacity:1;fill:url(#linearGradient7676);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-118.98903,19.331356)" />
    <path
       style="opacity:1;fill:url(#linearGradient7668);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
       transform="translate(-61.981829,-1.9884087)" />
  </g>
</svg>
}

set svg_FreeStaunton(br) {
<svg
   scidb:translate="0,17"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient7601">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient7591">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient7583">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient7569">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         id="stop3651"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient7569"
       id="linearGradient7575"
       x1="176.815"
       y1="160.36171"
       x2="48.624401"
       y2="137.03041"
       gradientUnits="userSpaceOnUse"
       gradientTransform="matrix(1.0039343,0,0,0.88591,-0.6954745,27.115721)" />
    <linearGradient
       xlink:href="#linearGradient7583"
       id="linearGradient7589"
       x1="167.9752"
       y1="265.22202"
       x2="4.4204001"
       y2="181.23441"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient7591"
       id="linearGradient7597"
       x1="154.714"
       y1="296.16479"
       x2="4.4204001"
       y2="198.916"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient7591"
       id="linearGradient7599"
       x1="137.03239"
       y1="313.84641"
       x2="13.2612"
       y2="216.59761"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient7601"
       id="linearGradient7607"
       x1="185.6568"
       y1="70.724403"
       x2="44.203999"
       y2="4.4184051"
       gradientUnits="userSpaceOnUse"
       gradientTransform="translate(0,18)" />
  </defs>
  <g
     style="display:inline">
    <g
       style="display:inline;fill:#ffffff;fill-opacity:1">
      <path
         d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="97.627876"
         x="110.57373"
         height="138.02731"
         width="132.40428"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645652999999930;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.13812,236.17719 C 249.72561,236.17719 249.72561,236.17719 249.72561,236.17719"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:7.25924109999999880;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline;fill-opacity:1" />
    </g>
  </g>
  <g
     style="display:inline">
    <g>
      <path
         d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
         style="fill:url(#linearGradient7607);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="97.627876"
         x="110.57373"
         height="138.02731"
         width="132.40428"
         style="opacity:1;fill:url(#linearGradient7575);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645653;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:url(#linearGradient7599);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:url(#linearGradient7597);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient7589);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.13812,236.17719 C 249.72561,236.17719 249.72561,236.17719 249.72561,236.17719"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:7.2592411;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(bb) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient8399">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient8391">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient8383">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient8375">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient8367">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8367"
       id="linearGradient8373"
       x1="192.2874"
       y1="57.463207"
       x2="179.0262"
       y2="48.622406"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8375"
       id="linearGradient8381"
       x1="190.07719"
       y1="154.71201"
       x2="61.885601"
       y2="92.826408"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8383"
       id="linearGradient8389"
       x1="176.81599"
       y1="225.4384"
       x2="75.146797"
       y2="172.3936"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8391"
       id="linearGradient8397"
       x1="176.81599"
       y1="274.06281"
       x2="22.101999"
       y2="194.49561"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8399"
       id="linearGradient8405"
       x1="172.3956"
       y1="296.16479"
       x2="-17.681601"
       y2="203.33641"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient8399"
       id="linearGradient8407"
       x1="150.29359"
       y1="313.84641"
       x2="8.8408003"
       y2="225.4384"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="display:inline;fill:#ffffff">
      <path
         transform="translate(-11.051004,-8.8408007)"
         d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 132.52635,198.814 C 220.26768,198.814 220.26768,198.814 220.26768,198.814"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:6.50729798999999960;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.39289,236.17719 C 249.7307,236.17719 249.7307,236.17719 249.7307,236.17719"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:7.25301361000000000;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g>
      <path
         transform="translate(-11.051004,-8.8408007)"
         d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
         style="opacity:1;fill:url(#linearGradient8373);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z"
         style="fill:url(#linearGradient8381);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z"
         style="fill:url(#linearGradient8389);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 132.52635,198.814 C 220.26768,198.814 220.26768,198.814 220.26768,198.814"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:6.50729799;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:url(#linearGradient8407);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:url(#linearGradient8405);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient8397);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.39289,236.17719 C 249.7307,236.17719 249.7307,236.17719 249.7307,236.17719"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:7.25301361;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(bn) {
<svg
   scidb:translate="0,10"
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient9261">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9253">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9243">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9235">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient9227">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9227"
       id="linearGradient9233"
       x1="207.7588"
       y1="154.71201"
       x2="8.8408003"
       y2="137.03041"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9235"
       id="linearGradient9241"
       x1="181.2364"
       y1="274.06281"
       x2="13.2612"
       y2="229.85881"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9243"
       id="linearGradient9249"
       x1="167.9752"
       y1="296.16479"
       x2="35.363201"
       y2="238.6996"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9243"
       id="linearGradient9251"
       x1="141.4528"
       y1="313.84641"
       x2="44.203999"
       y2="282.90359"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9253"
       id="linearGradient9259"
       x1="225.4404"
       y1="97.246803"
       x2="207.7588"
       y2="88.406006"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient9261"
       id="linearGradient9267"
       x1="221.02"
       y1="66.304008"
       x2="172.3956"
       y2="39.781605"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="display:inline;fill:#ffffff">
      <path
         d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         transform="translate(-77.356994,13.261196)"
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 101.66872,237.52472 C 252.44883,237.52472 252.44883,237.52472 252.44883,237.52472"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:8.01351546999999980;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g>
      <path
         d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
         style="fill:url(#linearGradient9233);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
         style="fill:url(#linearGradient9259);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
         style="fill:url(#linearGradient9267);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         transform="translate(-77.356994,13.261196)"
         d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:url(#linearGradient9251);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:url(#linearGradient9249);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient9241);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 101.66872,237.52472 C 252.44883,237.52472 252.44883,237.52472 252.44883,237.52472"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:8.01351547;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(bp) {
<svg
   width="353.63"
   height="353.63">
  <defs>
    <linearGradient
       id="linearGradient10057">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10049">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10041">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10033">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient10025">
      <stop
         style="stop-color:#5a0000;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#5a0000;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3693">
      <stop
         style="stop-color:#ffff82;stop-opacity:1;"
         offset="0" />
      <stop
         style="stop-color:#ffff82;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       id="linearGradient3645">
      <stop
         style="stop-color:#ffff23;stop-opacity:0.49803922;"
         offset="0" />
      <stop
         offset="1"
         style="stop-color:#ffff23;stop-opacity:0;" />
    </linearGradient>
    <linearGradient
       id="linearGradient3635">
      <stop
         style="stop-color:#ffff23;stop-opacity:1;"
         offset="0" />
      <stop
         offset="0.5"
         style="stop-color:#ffff23;stop-opacity:0.49803922;" />
      <stop
         style="stop-color:#ffff23;stop-opacity:0;"
         offset="1" />
    </linearGradient>
    <linearGradient
       xlink:href="#linearGradient3693"
       id="linearGradient3721"
       x1="212.1792"
       y1="114.92841"
       x2="145.8732"
       y2="79.565208"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10025"
       id="linearGradient10031"
       x1="194.90239"
       y1="88.406105"
       x2="119.75558"
       y2="39.781704"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10033"
       id="linearGradient10039"
       x1="185.6568"
       y1="212.1772"
       x2="82.034744"
       y2="176.815"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10041"
       id="linearGradient10047"
       x1="181.2364"
       y1="274.06281"
       x2="0"
       y2="190.07521"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10049"
       id="linearGradient10055"
       x1="167.9752"
       y1="296.16479"
       x2="-30.942801"
       y2="198.916"
       gradientUnits="userSpaceOnUse" />
    <linearGradient
       xlink:href="#linearGradient10057"
       id="linearGradient10063"
       x1="137.03239"
       y1="313.84641"
       x2="-22.101999"
       y2="247.54041"
       gradientUnits="userSpaceOnUse" />
  </defs>
  <g
     style="display:inline">
    <g
       style="display:inline;fill:#ffffff">
      <path
         transform="translate(4.0156115,8.4203023)"
         d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 158.85527,118.61 C 194.70553,118.61 194.70553,118.61 194.70553,118.61"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:5.09436892999999990;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.24874,236.17719 C 249.615,236.17719 249.615,236.17719 249.615,236.17719"
         style="fill:#ffffff;fill-rule:evenodd;stroke:#000000;stroke-width:7.25372314000000000;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
  <g
     style="display:inline">
    <g>
      <path
         transform="translate(4.0156115,8.4203023)"
         d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
         style="opacity:1;fill:url(#linearGradient10031);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 158.85527,118.61 C 194.70553,118.61 194.70553,118.61 194.70553,118.61"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:5.09436893;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <path
         d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z"
         style="fill:url(#linearGradient10039);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
      <rect
         y="305.84641"
         x="66.305992"
         height="13.2612"
         width="221.02"
         style="opacity:1;fill:url(#linearGradient10063);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <rect
         y="287.74438"
         x="70.726387"
         height="17.681601"
         width="212.1792"
         style="opacity:1;fill:url(#linearGradient10055);fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
         style="fill:url(#linearGradient10047);fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
      <path
         d="M 104.24874,236.17719 C 249.615,236.17719 249.615,236.17719 249.615,236.17719"
         style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:7.25372314;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
    </g>
  </g>
</svg>
}

set svg_FreeStaunton(wk,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.37233,236.17719 C 249.06173,236.17719 249.06173,236.17719 249.06173,236.17719"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.23681688;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <g
        transform="translate(0,10)"
        style="fill:black;fill-opacity:1;display:inline">
       <path
          style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
          d="M 176.816,66.304005 C 194.4976,66.304005 198.918,70.007073 198.918,83.985605 C 198.918,97.246805 196.32859,111.26643 190.0772,123.7692 C 185.6568,132.61 185.6568,132.61 176.816,154.712" />
       <path
          style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
          d="M 176.51,65.883605 C 158.8284,65.883605 154.408,69.586675 154.408,83.565205 C 154.408,96.826405 156.99741,110.84603 163.2488,123.3488 C 167.6692,132.1896 167.6692,132.1896 176.51,154.2916" />
     </g>
     <path
        d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(wq,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="221.02"
        height="13.2612"
        x="66.305992"
        y="305.84641" />
     <rect
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="212.1792"
        height="17.681601"
        x="70.726387"
        y="287.74438" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.05921173;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 108.47025,236.17719 C 246.14492,236.17719 246.14492,236.17719 246.14492,236.17719" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(2.2101956,-8.8407986)" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
     <rect
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="148.82619"
        height="45.887592"
        x="102.4029"
        y="189.6579" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(-59.200991,-2.915355)" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(-118.98903,19.331356)" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(67.790652,-4.7692476)" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(123.40743,22.112195)" />
   </g>
</svg>
}

set svg_FreeStaunton(wr,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.34883,236.17719 C 249.05143,236.17719 249.05143,236.17719 249.05143,236.17719"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.23714638;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="97.627876"
        x="110.57373"
        height="138.02731"
        width="132.40428"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645653;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(wb,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 103.90377,236.17719 C 249.38063,236.17719 249.38063,236.17719 249.38063,236.17719"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.2564826;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        transform="translate(-11.051004,-8.8408007)"
        d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 133.36855,198.814 C 220.12582,198.814 220.12582,198.814 220.12582,198.814"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:6.4707036;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(wn,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,287.324 C 185.65681,287.324 176.81601,287.324 79.5672,287.324 C 92.8284,274.0628 110.51001,256.3812 106.08961,238.6996 C 159.13441,238.6996 119.35081,238.6996 176.81601,238.6996 C 234.2812,238.6996 225.4404,238.6996 247.5424,238.6996 C 243.12201,256.3812 260.80361,274.0628 274.0648,287.324 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 101.41648,238.17719 C 251.52859,238.17719 251.52859,238.17719 251.52859,238.17719"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.37118053;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        transform="translate(-77.356994,13.261196)"
        d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(wp,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.22529,236.17719 C 249.4067,236.17719 249.4067,236.17719 249.4067,236.17719"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.24911022;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        transform="translate(4.0156115,8.4203023)"
        d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
        style="fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 159.15615,119.3488 C 194.72097,119.3488 194.72097,119.3488 194.72097,119.3488"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:5.07404709;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(bk,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        d="M 176.816,231.018 C 176.816,195.6548 176.816,160.2916 185.6568,142.61 C 194.4976,124.9284 216.5996,93.985605 256.3832,93.985605 C 280.79566,93.985605 318.2688,111.6672 318.2688,151.4508 C 318.2688,162.5018 316.0586,172.4477 311.08565,181.84105 C 306.1127,191.2344 278.4852,217.7568 243.122,226.5976 C 223.94361,231.3922 176.816,231.018 176.816,231.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 176.815,30.941005 C 176.816,66.304005 176.816,76.304005 176.816,76.304005"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 194.4974,48.621405 C 159.1344,48.622405 159.1344,48.622405 159.1344,48.622405"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <g
        style="fill:black;fill-opacity:1">
       <path
          style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
          d="M 176.816,76.42689 C 194.4976,76.42689 198.918,80.129958 198.918,94.10849 C 198.918,107.36967 196.32859,121.3893 190.0772,133.89207 C 185.6568,142.73287 185.6568,142.73287 176.816,164.83487" />
       <path
          style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8.10000038000000090;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
          d="M 176.816,76.303993 C 159.1344,76.303993 154.714,80.007063 154.714,93.985593 C 154.714,107.2468 157.30341,121.26643 163.5548,133.7692 C 167.9752,142.61 167.9752,142.61 176.816,164.712" />
     </g>
     <path
        d="M 176.2936,231.018 C 176.2936,195.6548 176.2936,160.29161 167.4528,142.61001 C 158.612,124.92841 136.51,93.985614 96.7264,93.985614 C 72.31394,93.985614 34.8408,111.66721 34.8408,151.45081 C 34.8408,162.50181 37.051,172.44771 42.02395,181.84105 C 46.9969,191.2344 74.6244,217.7568 109.9876,226.5976 C 129.16599,231.3922 176.2936,231.018 176.2936,231.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.1276,236.17719 C 249.27265,236.17719 249.27265,236.17719 249.27265,236.17719"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:7.24820231999999990;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(bq,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(2.2101956,-8.8407986)" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 176.815,78.458738 C 172.3956,119.3488 167.9752,148.916 163.5548,184.2792 C 172.3956,184.2792 167.9752,184.2792 176.816,184.2792 C 185.6568,184.2792 181.2364,184.2792 190.0772,184.2792 C 185.6568,148.916 181.2364,119.3488 176.815,78.458738 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 238.7016,79.565205 C 225.4404,119.3488 203.3384,148.916 195.37237,183.93422 C 204.21317,183.93422 199.79277,183.93422 208.63357,183.93422 C 217.47437,183.93422 213.05397,183.93422 221.89477,183.93422 C 225.4404,148.916 234.2812,123.7692 238.7016,79.565205 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 291.7464,101.6672 C 269.6444,141.4508 239.122,150.916 222.66218,185.03242 C 231.50298,185.03242 227.08258,185.03242 235.92338,185.03242 C 244.76418,185.03242 240.34378,185.03242 249.18458,185.03242 C 261.224,150.916 278.4852,145.8712 291.7464,101.6672 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 114.9304,79.565205 C 119.3508,123.7692 128.1916,148.916 132.66218,185.03242 C 141.50298,185.03242 137.08258,185.03242 145.92338,185.03242 C 154.76418,185.03242 150.34378,185.03242 159.18458,185.03242 C 145.8732,144.4956 123.7712,119.3488 114.9304,79.565205 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 61.8856,101.6672 C 75.1468,150.2916 92.408,144.4956 104.66218,185.03242 C 113.50298,185.03242 109.08258,185.03242 117.92338,185.03242 C 126.76418,185.03242 122.34378,185.03242 131.18458,185.03242 C 114.51,148.916 79.5672,141.4508 61.8856,101.6672 z" />
     <rect
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:bevel;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="148.82619"
        height="45.887592"
        x="102.4029"
        y="189.6579" />
     <rect
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="221.02"
        height="13.2612"
        x="66.305992"
        y="305.84641" />
     <rect
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        width="212.1792"
        height="17.681601"
        x="70.726387"
        y="287.74438" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z" />
     <path
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:7.04245234;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 109.00936,236.17719 C 246.03109,236.17719 246.03109,236.17719 246.03109,236.17719" />
     <path
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(-61.981829,-1.9884087)" />
     <path
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(-118.98903,19.331356)" />
     <path
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(66.400233,-1.5249356)" />
     <path
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
        d="M 194.4976,64.093803 A 19.8918,19.8918 0 1 1 154.714,64.093803 A 19.8918,19.8918 0 1 1 194.4976,64.093803 z"
        transform="translate(125.26132,21.648722)" />
   </g>
</svg>
}

set svg_FreeStaunton(br,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        d="M 265.224,97.144805 C 225.4404,97.144805 137.0324,97.144805 88.408,97.144805 C 88.408,52.94081 88.408,66.202005 88.408,52.940805 C 106.0896,52.940805 110.51,52.940805 123.7712,52.940805 C 123.7712,66.202005 123.7712,57.361205 123.7712,75.042805 C 141.4528,75.042805 150.2936,75.042805 159.1344,75.042805 C 159.1344,57.361205 159.98626,66.201805 159.1344,52.940805 C 185.6568,52.940805 167.9752,52.940805 194.4976,52.940805 C 194.4976,79.463205 194.4966,59.284718 194.4976,75.042805 C 212.1792,75.042805 212.1792,75.042805 229.8608,75.042805 C 229.8608,52.940805 229.8608,66.202005 229.8608,52.940805 C 260.8036,52.940805 225.4404,52.940805 265.224,52.940805 C 265.224,92.724405 265.224,66.202005 265.224,97.144805 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <rect
        y="97.627876"
        x="110.57373"
        height="138.02731"
        width="132.40428"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8.59645652999999930;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.13812,236.17719 C 249.72561,236.17719 249.72561,236.17719 249.72561,236.17719"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:7.25924109999999880;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline;fill-opacity:1" />
   </g>
</svg>
}

set svg_FreeStaunton(bb,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        transform="translate(-11.051004,-8.8408007)"
        d="M 198.918,55.253006 A 11.051,11.051 0 1 1 176.816,55.253006 A 11.051,11.051 0 1 1 198.918,55.253006 z"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 181.2364,62.304005 C 181.2364,62.304005 187.76674,68.413948 212.1792,92.826405 C 234.2812,114.9284 234.2812,137.0304 234.2812,154.712 C 234.2812,167.9732 229.8608,181.2344 221.02,198.916 C 203.3384,198.91601 150.2936,198.91601 132.612,198.916 C 123.7712,181.2344 119.3508,167.9732 119.3508,152.712 C 119.3508,137.0304 117.73281,117.31108 139.4528,95.246805 C 165.9752,68.304005 172.3956,62.304005 172.3956,62.304005 L 181.2364,62.304005 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 235.122,235.4384 C 213.02,235.4384 198.918,235.4384 176.816,235.4384 C 154.714,235.4384 141.4528,236.6996 119.3508,236.6996 C 137.0324,219.018 132.612,212.1772 132.612,198.916 C 150.2936,198.916 154.715,198.917 176.816,198.916 C 198.919,198.915 203.3384,198.916 221.02,198.916 C 221.02,212.1772 217.4404,217.7568 235.122,235.4384 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 132.52635,198.814 C 220.26768,198.814 220.26768,198.814 220.26768,198.814"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:6.50729798999999960;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 139.98939,97.04459 C 176.89372,136.44754 176.89372,136.44754 176.89372,136.44754"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.39289,236.17719 C 249.7307,236.17719 249.7307,236.17719 249.7307,236.17719"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:7.25301361000000000;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(bn,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        d="M 106.0896,237.018 C 128.1916,237.018 225.4404,237.018 247.5424,237.018 C 247.5424,214.916 246.82751,215.04704 243.122,192.814 C 238.7016,166.29161 247.5424,122.0876 247.5424,99.985605 C 247.5424,64.622405 244.02414,69.91703 239.60374,67.000658 C 234.9152,65.437811 217.13461,66.843932 198.918,69.042805 C 180.70139,71.241677 162.51223,78.172823 156.07961,79.78098 C 138.39801,84.20138 126.10102,87.97814 112.3987,91.144805 C 98.779148,94.292343 95.0558,95.565205 79.5672,99.985605 C 73.540319,101.70566 66.306,101.88752 66.306,108.8264 C 65.921966,111.15296 63.182443,123.07455 66.306,123.7692 C 70.989384,124.81073 89.510128,122.9054 92.8284,128.1896 C 86.845572,127.20643 68.140795,133.71369 70.7264,137.0304 C 75.824604,139.82864 72.744863,145.8712 75.1468,145.8712 C 98.656625,141.4508 90.948777,139.36314 110.51,141.4508 C 131.05827,143.64381 154.714,179.5528 179.57278,144.1896 C 172.3956,173.77473 164.8077,178.45321 160.28144,182.3367 C 154.02228,187.707 134.74719,198.63674 129.82082,203.63472 C 125.40198,208.11779 113.51427,214.916 106.0896,237.018 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 187.98966,82.118838 C 187.36948,81.206008 192.66702,95.694478 198.918,99.985605 C 213.87004,94.076016 243.23409,79.548617 237.85501,73.578499 C 225.54159,74.193215 187.98966,82.118838 187.98966,82.118838 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 181.2364,122.0876 C 186.13768,132.68234 182.89337,137.64877 179.59585,144.1896"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 181.2364,72.037975 C 197.13696,69.042805 210.7321,67.652385 225.4404,66.458892 C 225.4404,60.202005 222.93565,58.382182 221.02,55.781605 C 213.61937,45.73492 194.4976,45.550385 185.6568,51.361205 C 181.2364,58.79418 178.90163,67.012326 181.2364,72.037975 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        transform="translate(-77.356994,13.261196)"
        d="M 159.13439,99.457008 A 2.2102001,2.2102001 0 1 1 154.71399,99.457008 A 2.2102001,2.2102001 0 1 1 159.13439,99.457008 z"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,75.144805 C 265.224,75.144805 265.224,75.144805 265.224,75.144805"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,88.406005 C 265.224,88.406005 265.224,88.406005 265.224,88.406005"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,101.6672 C 265.224,101.6672 265.224,101.6672 265.224,101.6672"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,114.9284 C 265.224,114.9284 265.224,114.9284 265.224,114.9284"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,128.1896 C 265.224,128.1896 265.224,128.1896 265.224,128.1896"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,141.4508 C 260.8036,141.4508 260.8036,141.4508 260.8036,141.4508"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,154.712 C 260.8036,154.712 260.8036,154.712 260.8036,154.712"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,167.9732 C 260.8036,167.9732 260.8036,167.9732 260.8036,167.9732"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,181.2344 C 260.8036,181.2344 260.8036,181.2344 260.8036,181.2344"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 243.122,194.4956 C 260.8036,194.4956 260.8036,194.4956 260.8036,194.4956"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,207.7568 C 265.224,207.7568 265.224,207.7568 265.224,207.7568"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 247.5424,221.018 C 265.224,221.018 265.224,221.018 265.224,221.018"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 101.66872,237.52472 C 252.44883,237.52472 252.44883,237.52472 252.44883,237.52472"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:8.01351546999999980;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(bp,mask) {
<svg
   width="353.63"
   height="353.63">
   <g>
     <path
        transform="translate(4.0156115,8.4203023)"
        d="M 212.1792,70.724503 A 39.581203,39.783501 0 1 1 133.01679,70.724503 A 39.581203,39.783501 0 1 1 212.1792,70.724503 z"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 158.85527,118.61 C 194.70553,118.61 194.70553,118.61 194.70553,118.61"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:5.09436892999999990;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <path
        d="M 114.9304,237.4384 C 132.612,221.018 142.56318,213.26644 150.714,188.814 C 159.1344,163.5528 159.1344,132.61 159.1344,119.3488 C 163.5548,119.3488 190.0772,119.3488 194.4976,119.3488 C 194.4976,132.61 194.4976,163.5528 202.918,188.814 C 211.06882,213.26644 221.02,221.018 238.7016,237.4384 C 198.918,237.4384 190.0772,237.4384 176.816,237.4384 C 163.5548,237.4384 114.9304,237.4384 114.9304,237.4384 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1" />
     <rect
        y="305.84641"
        x="66.305992"
        height="13.2612"
        width="221.02"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <rect
        y="287.74438"
        x="70.726387"
        height="17.681601"
        width="212.1792"
        style="opacity:1;fill:black;fill-opacity:1;fill-rule:nonzero;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 274.0648,286.90359 C 185.6568,286.90359 176.816,286.90359 79.567195,286.90359 C 92.828395,273.64239 110.51,255.96079 106.0896,238.27919 C 159.1344,238.27919 119.3508,238.27919 176.816,238.27919 C 234.2812,238.27919 225.4404,238.27919 247.5424,238.27919 C 243.122,255.96079 260.8036,273.64239 274.0648,286.90359 z"
        style="fill:black;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:8;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
     <path
        d="M 104.24874,236.17719 C 249.615,236.17719 249.615,236.17719 249.615,236.17719"
        style="fill:black;fill-rule:evenodd;stroke:#000000;stroke-width:7.25372314000000000;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline" />
   </g>
</svg>
}

set svg_FreeStaunton(sample,24pt,200x34) {
  iVBORw0KGgoAAAANSUhEUgAAAMgAAAAiCAQAAACwjl7xAAAN8klEQVRo3u2beXRUVbaHv3Mr
  IyEDGYAIAoFAAsQWFHg2hIegPGjWQwERcEBbum0EBCdsxDgxKCgoCiraDTS2drdEu0VUfL4n
  g0vUtZ4g02MeAmEMCSFTVVHDvfv9UTeVqqSGW7L6Ld9anrNu5dSte87ZZ//23mfvfU+U8HP5
  KRXtZxb8tEpc5J8VAFeiRVc+wpWX/080aFEHUUxSKrapGyvNrqb7/9esUH6WXMk4P5b6pl7R
  +2tRx7LxVxJig0RjpJ8Fs5B4OmLz3R9taUHBkIZux1ZEo92VmWcFaGg/Algf5Y83kh+tv0So
  wK9xI7h5TJBozwbSUMwcilBAIQ5Vy3naAIrhzKVXE03hxprCM3QyVfxONnCX2S5gDU9GoTrE
  eIqNyslnKOHHVhjAh8zzSVZMFOBDYQCfcYGPuS4yFdGYrJGuhBy06HD0p7iRz9O0syNFNTAU
  xZFZ8roMEFYAT2llo0XZGQCDzaWFHu159lFoDlZCNXPNdj92sTZGQAAb3hGCF9uPg8IUslSS
  gsXbcn/FXHXmcXlBJotWw8xIkEQjRKO3EoqiA6IggXt4iEwUlfNkiQwXvkBRM1tK5AZhHQrv
  UnlRhgh/GwFpjOWXoccFVrOVrWwldzPcYrZHfwi5Znt1LPK5BN5CWBmrZAfY9QROalWanVVo
  Gu1Jjg2QzurievlY1shSeVDUZXItARLS/G1KKCsW2xn+q7npC6FLu/pLsVBPGttGy0zpLqwQ
  mKQ1FIjycA2Kg2NlunQWnqMNdYPFdpY/hZIWYM+Unc981amWrtkw5U7ZIHcJUzOha4GskSeF
  PdaZugwGK/tdohwMsWa0msp4lrOLqTB8gHwo88Tm5BWuQ8UIyKN3y3/IX2SFzJNZ0ku43wIg
  JgBpjGI+CxlHFooEjCqxS7XgJQlFFuNYyHxGkRa8NOAqdekdmSd5wmjac1p52UOKgGIIQicB
  6ESV0tlOMlNGyB/lIVE66aEBeX7zvg8KqyhjO1UlUi1zhSq2U9ZPdslai4AAJMJAZV8i62Su
  KKcVSHxlArtx4gJFO+7gUNAj63geWwyAvDxNPpS3ZZHMlilSJJSEfzouwMGN53ntwX9P7oNi
  P39vMD6iRClBR2Gz6bnM08aOb90Tg1185jReVyXiadIXVScp26mj3MFpOa86yaesEjsgHAXO
  K4BTbJdvWYBQub++PPUYojBCORoKcKoHdl53s9HFIBdhEoOyvFleEjEsRhQKmMrb/dn0SlIe
  9XRkWtLKL2So+i56/3hKVWkGfRnPRM1+79XDmYPONeyhgrbUTnDu42nLHh7qqx2PDqABO3Ya
  OO3hv6N4WSYNP4yRY+IUu9RLjRyT+6S1INukWn4QpJXcL2fFLg1SJ5dkr4wWthMf5MmMwWUT
  3kMJwBy2m63rEbIByEG4yReQtmtIFHSeDi2x7MmQHLNmS7ZkS5ZkSZZkSqa0kVRLGgJANvZE
  eVJKZZUsk/lyhygnmVH62biexVRybrwsl10yVdZKtcyVztJOesuf5beSLOxBs74fkUDFRJkv
  D8ndUiScJi6qhqBYPK7ve2gY5g/pLKIT89lEd7ageJZZCIZZ2/M26voNi9VsMVcuwnrVWp/O
  ZJQSYAeL6cRJoBOQSRWKJ4CjAKRXxDGRLVRJaHEdUKNxeE2H7og5q27Wozx2isJQehVSSdZM
  bZXJy8yiC27c5HBt0q5l6tcSVkmUopRxEyihB5q5Wh1hBvX0oxiDrSThrIslHBG3+sW6nTm5
  KVyi9hR9xRtdQ5KUu0xcclkcUi+1Ui2Vck5OyUTJkzLpJZPFKQ5Td6qlUirkrHwvmoekZrKQ
  isFiFNAZ4W8o4HGEoQpS0RGSbJDEIcoje27AsR2ii0dc4pA6qZZKOSMnZINwzLLtbo3jC/lc
  fiNJMlMWyGyZKuNE6SRGjFkc8XK3OMUtl8VhWoQqOSpnpFyOyyG5TVKEY5GkPCQtC3vJryRf
  WBD5ycboNa9PfAf/TZ9cCMIcqvk95SwC8774pSaH3nHkNcO3gUXMYQGKc4i6nQ7AtSmQnweP
  tdeowKUn8hU9mCJGdOsbaH58c8eUkbq6Z3I8boYyglU04MaNIkUjN2Kv1R7eY4o5k2/+zxjh
  50wlbkiJOdRPvYHb6QOp1lInrVORIBb42J7KSD5gHFlBdw10DHRaQ+tmLBTmcYYS1qJT1sXG
  KygG58K1x5PVUx1gI8nssA3gGzZZ3xTFb0jFoq0yS1Iabty4uJH7MHDjwkUCpEeYTfiz8uSx
  jmKe4rw56wE6+qk4TQKsQI8xsZidgodkyLEGSMW3JyQIjkbmFwE3BEDRBInO3gtUtLSXDMKI
  u4VP2ZeFGkM3OmTSb8ZaR57Nzoz7etjzehtubhWxCkawkMSkIeIxQfCQabbc0TN4P8hLZWON
  zt/3WLqgW91LHOF9ljHOpECnnlZwMjZCFBQk4CUOCiwAInDGm7s3AIombWgHdGymHz44DmLP
  4EyIMct58uqM3JGMriY/vv8RzZbITubSiUreAOpdMlMuWtcPgoTEOh8EKndeuIzLhMJltuq8
  VEXsp8tTsl7K5QjPSteFr/V3zagUbjKpcNFAOrHoB4AoinJwkw5FkRO1jbKi82jxntoA89Bo
  mDKAnBa6oVPHvSflEdFDcuL1E3oGGpUI32OjHJ0KzlFHAglUuVkTGxxNO4gRm8k6L2kncQfV
  Orw6Zy1Pf1F7mGReHU26Ob8XD3ZItJ71VQAZypuBlxQUZFgARGCl6/u8/SeabesGiUBSM5Ol
  c4qbyi996csOhSgOqTmAQT1HAQ8nAYNDeHDzP/BNRLcvhHYY4fPKkYvOaxup4AJVXOQStdRx
  Dl4Vy/KtYcTxQsIDzwRQoaiOuhMEwxEHN/VL8eLGQ34iw5SVN4Yi6v7Lj/R59sW0O/z+t+HX
  TMNvMnRcrGO+3fMay8LuAxqZa1E4cGDHgdNsOXFQycF8q+/XCLGnGbHZihVb5mxpfm+5dVYa
  3dlcbFud2xqvSUE8qTixSobvXYhXY8kgPHjw0I0jS/lIGRL9Fa6IWqavn11akvvIVTfSEQ3d
  P6+BgQcHx/mSFRXO00ygLPK23Aeoo77ZpVFnkZMp2AN0pMlkSSyGAi7aeBcHNdRQSy2X2Ihe
  q6yNohip/eXdNsPR0f2iocijHOe/WtEz1bh/zIzzFFKHFw/ZJLRxz2S5CsO+uGYu33HV39Vz
  8QeLe8WRTiviUcAkBDcN1OCFw4zlQHQfyYEyNcOnIY3tyxYZOoxPQu4g1jWkLbns7taettRi
  4MWNkzhaUzuI/7Q0QG/tnW/bdPeD0WjGr+IEZFnDtJCDiknq2SVtvHhw48HLwPSvl+oXeD9M
  gl1C4bpOTdBCbloGxucyKqpc2PAMUeDBiwcdD1685udl7IeNAguSlcqZYakZLSKjOr6rpaM0
  WBihN9ewtFuHAmpw4MaNBzd12D08wE7ZGWUEjSMvd73ZH3N5zephLf/4hFV8Ek0oFcBtPMrA
  NFL8KRgdHQ9u+IblUmrh1IlCIdVPMzUgJtcx8KLj5SNeqFcqqn4Yas2R3+SYS2m6BIUHWRxd
  zX/HH9JSUlvhCthJfHqSQkq6PU01WDjBMartS7kYnAiYXyOVlPj61c5n2BmFigfo+li4n1sV
  b9hGdMOnkMTCgf9i6kZj9bVPD6pdaeEYkAIkQ907gawgJ1c3peNmXhyjZ1MZ1W7mz2IIdn/K
  2eFv7eRIXvSl/AF6DOMfQTT4KPAwjU0FkR1X87TMNfdymzmrHTt2k4oG9rG3eySxUgAb8/mo
  RezlReePlJZmo5AIkPh3j3G3MiYkHzT2jlV/pQURWovDKnF8/vvk7iEiZQMhhwcT2KQSVITj
  LvHQT/X0eRXegE+fbLRDPUHbSI5fESWQxLsPtwgNffUe1HskRj5yY4Ou3Docjxl9+OZ3md+z
  0e6ka8TTK4pHxlFIAQUU0IPu5NONrnSlC6NRJevjbueX0beQYjVwlLlu3/7h9vMhB9stTYcQ
  Qu4hChQFvJQ46re2OL930zx29/Ax9VuYxb6WEqaA6byZy4GV6deZ0ujwy6fvewNlnDxOEU4J
  J1uKeL783eDngoymTz59jH2T0q+5GU8oGVfAZN7N4PCinKEB2mEP0JUGTnH0IvnUSLgU/L+p
  ty50SUdMc6f7dxE3bqZd2vY+M1qJI8zRN1NDC9n9XHzPAJfmsr/lCwCOe/kFB4NX0RwQ40YS
  /dNIUMazSU/cbEfiW4Z3ChTzeDC+TU4AiIEt318XHGWhvBMGkF7sIj6q9HnoI/vDAPowj9ty
  25lzE5IGN3KOJbwaQqxSuIc3hqmCFombRgGx87HIWyyhLAIg65hgyZcrlYnhAenJ/r4BvJCg
  q6l6OYj0kx0h/SvvdBICVNMdtJU1fjqo2U3f0FZcTS9649YQWSwD8fspBls5NkPeDMkMjfOT
  c7KD5ncF0NNIkZNLlbRv+RJA/ar3xiEtnIng4NTgFN+9zx1hAbFxcHz+1VFpsFN7lMLAiCYY
  kKEJmzNCns2TZq16Lo+WT0MQUszXlgOFq+RcSEC2xQ/Sgo5/qmbxu88Bd34jxSGZ0YNDlmko
  kMMtRticMLRVlIQOeHC4yBRHGC1vQ1WWJiFO5zRveyFTLoWO1FHH3E9csLqUAyFf56sEUi2Q
  4ZP1MGWnx1qua2+YIwXEkxaWhsBzNt7QNKQl+c8nBnhMzWax4UgIl8YXlFAbU0I7UmB4JUUl
  Wk+7cU50/glFxdPO8sMVTSdn/P0LaWWx9+5wK4jtLHSg6VY//8POT6v8L2JgtOfMlrZaAAAA
  AElFTkSuQmCC
}

# vi:set ts=2 sw=2 et:
