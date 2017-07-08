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
# Copyright: (C) 2008-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source color-cube

package require tkscidb

namespace eval dialog {
namespace eval choosecolor {

set Methods [lreplace $Methods [lsearch -exact $Methods circle] [lsearch -exact $Methods circle] cube]
set AdjustWidth -10

namespace eval cube {

namespace import [namespace parent]::hsv2rgb
namespace import [namespace parent]::rgb2hsv
namespace import ::tcl::mathfunc::*


proc ComputeWidth {height} {
	set vbarSize [expr {round(0.067*$height) + 11}]
	return [expr {round((($height - $vbarSize)*511.0)/443.0) - 16}]
}


proc Icon {} { return [[namespace parent]::circle::Icon] }


proc MakeFrame {container} {
	variable Vars

	set width 225
	set height 195
	
	set cchoose1 [tk::canvas $container.hs \
		-width $width \
		-height $height \
		-borderwidth 2 \
		-relief sunken \
		-highlightthickness 1 \
	]
	set cchoose2 [tk::canvas $container.v \
		-width $width \
		-height 15 \
		-borderwidth 2 \
		-relief sunken \
	]
	
	place $cchoose1 -x 0 -y 0
	place $cchoose2 -x 0 -y 226

	bind $cchoose1 <Up>					[namespace code { MoveHS 0 +1 }]
	bind $cchoose1 <Down>				[namespace code { MoveHS 0 -1 }]
	bind $cchoose1 <Left>				[namespace code { MoveHS -1 0 }]
	bind $cchoose1 <Right>				[namespace code { MoveHS +1 0 }]
	bind $cchoose1 <Control-Up>		[namespace code { MoveHS 0 +1 10 }]
	bind $cchoose1 <Control-Down>		[namespace code { MoveHS 0 -1 10 }]
	bind $cchoose1 <Control-Left>		[namespace code { MoveHS -1 0 10 }]
	bind $cchoose1 <Control-Right>	[namespace code { MoveHS +1 0 10 }]
	bind $cchoose1 <ButtonPress-1>	[namespace code { SelectHS %x %y }]
	bind $cchoose1 <B1-Motion>			[namespace code { SelectHS %x %y }]
	bind $cchoose1 <ButtonRelease-1>	+[list focus $cchoose1]

	bind $cchoose2 <Left>				[namespace code { MoveV -1 }]
	bind $cchoose2 <Right>				[namespace code { MoveV +1 }]
	bind $cchoose2 <Control-Left>		[namespace code { MoveV -10 }]
	bind $cchoose2 <Control-Right>	[namespace code { MoveV +10 }]
	bind $cchoose2 <Home>				[namespace code { MoveV -9999 }]
	bind $cchoose2 <End>					[namespace code { MoveV +9999 }]
	bind $cchoose2 <ButtonPress-1>	[namespace code { SelectV %x %y }]
	bind $cchoose2 <B1-Motion>			[namespace code { SelectV %x %y }]
	bind $cchoose2 <ButtonRelease-1>	+[list focus $cchoose2]

	set Vars(widget:hs) $cchoose1
	set Vars(widget:v) $cchoose2
	set Vars(after) {}
	set Vars(size) -1
}


proc Configure {width height} {
	variable [namespace parent]::icon::11x11::ArrowUp
	variable [namespace parent]::icon::11x11::ActiveArrowUp
	variable Vars

	incr height -17
	incr width -6

	set vbarSize [expr {round(0.067*$height)}]
	set ysize [expr {$height - $vbarSize}]
	set xsize [expr {round($width*(443.0/511.0))}]
	if {$ysize > $xsize} {
		set ysize $xsize
		set vbarSize [expr {round((0.067*$ysize)/(1.0 - 0.067))}]
		set xsize $width
	} else {
		set xsize [expr {round($ysize*(511.0/443.0))}]
	}
	if {$Vars(size) == $ysize} { return }
	set Vars(size) $ysize

	### setup Value window ###########################
	$Vars(widget:v) configure -height $vbarSize
	$Vars(widget:v) configure -width $xsize
	$Vars(widget:v) xview moveto 0
	$Vars(widget:v) yview moveto 0
#	place forget $Vars(widget:v)
	place $Vars(widget:v) -x 0 -y [expr {$ysize + 12}]

	if {[llength [$Vars(widget:v) find withtag all]] == 0} {
		for {set i 1} {$i <= 255} {incr i} {
			$Vars(widget:v) create rectangle 0 0 0 0 -width 0 -tags val[expr {255 - $i}]
		}

		$Vars(widget:v) create image 0 0 -anchor n -image $ArrowUp -tags target
		$Vars(widget:v) create image 0 0 -anchor n -image $ActiveArrowUp -tags active
		$Vars(widget:v) itemconfigure active -state hidden

		bind $Vars(widget:v) <FocusIn> "
			$Vars(widget:v) itemconfigure target -state hidden
			$Vars(widget:v) itemconfigure active -state normal
		"
		bind $Vars(widget:v) <FocusOut> "
			$Vars(widget:v) itemconfigure target -state normal
			$Vars(widget:v) itemconfigure active -state hidden
		"
	}

	set ncells	[min $xsize 255]
	set step		[expr {double($xsize)/double($ncells)}]
	set height	[$Vars(widget:v) cget -height]
	set x0		0

	for {set i 1} {$i <= $ncells} {incr i} {
		set x1 [expr {round($i*$step)}]
		$Vars(widget:v) coords val[expr {$ncells - $i}] $x0 0 $x1 $height
		set x0 $x1
	}
	for {} {$i <= 255} {incr i} {
		$Vars(widget:v) coords val[expr {$ncells - $i}] 0 0 0 0
	}

	set Vars(y0) [expr {$height - 12}]
	$Vars(widget:hs) raise crosshair1
	$Vars(widget:hs) raise crosshair2

	### setup Hue-Saturation window ##################
	$Vars(widget:hs) configure -height $ysize
	$Vars(widget:hs) configure -width $xsize
	$Vars(widget:hs) xview moveto 0
	$Vars(widget:hs) yview moveto 0
	$Vars(widget:hs) delete cube
	after idle [namespace code [list MakeCubeImage $xsize $ysize]]

	if {[llength [$Vars(widget:hs) find withtag crosshair1]] == 0} {
		[namespace parent]::circle::MakeCrossHair $Vars(widget:hs)
		$Vars(widget:hs) itemconfigure crosshair1 -state hidden
		$Vars(widget:hs) itemconfigure crosshair2 -state hidden
	}

	$Vars(widget:hs) raise crosshair1
	$Vars(widget:hs) raise crosshair2
}


proc Update {r g b afterResize} {
	variable Vars

	set Vars(hsv) [rgb2hsv $r $g $b]
	lassign $Vars(hsv) h s v

	eval Reflect [hsv2rgb $h $s 1.0]
	DrawValues
	set x [expr {round((1.0 - $v)*([$Vars(widget:v) cget -width] - 1))}]
	$Vars(widget:v) coords target $x $Vars(y0)
	$Vars(widget:v) coords active $x $Vars(y0)
}


proc Reflect {r g b} {
	variable Vars

	set w		[expr {[$Vars(widget:hs) cget -width] - 1}]
	set s		[expr {511.0/$w}]
	set xc	[expr {$r - ($g + $b)/2.0}]
	set yc	[expr {0.8660254038*($g - $b)}]	;# (sqrt(3)/2)*(g - b)
	set x		[expr {round(($xc + 255.0)/$s)}]
	set y		[expr {round((221.0 - $yc)/$s)}]

	[namespace parent]::circle::DrawCrosshair $Vars(widget:hs) $x $y [list $r $g $b]
}


proc SelectHS {x y} {
	variable Vars

	set x		[expr {$x - 3}]
	set y		[expr {$y - 3}]
	set w		[$Vars(widget:hs) cget -width]
	set sc	[expr {511.0/$w}]
	set xt	[expr {$sc*$x - 255}]
	set yt	[expr {221 - $sc*$y}]

	lassign [DetermineColor $xt $yt true] h s

	set s		[expr {(255.0 - $s)/255.0}]
	set h		[expr {$s == 0 ? 0 : $h}]
	set v		[lindex $Vars(hsv) 2]

	set Vars(hsv)	[list $h $s $v]
	eval Reflect [hsv2rgb $h $s 1.0]
	[namespace parent]::SetRGB [hsv2rgb $h $s $v]

	after cancel $Vars(after)
	set Vars(after) [after 30 [namespace code { DrawValues }]]
}


proc MoveHS {xdir ydir {repeat 1}} {
	variable Vars

	lassign [[namespace parent]::circle::CrosshairCoords $Vars(widget:hs)] x y

	set x		[expr {$x + $repeat*$xdir}]
	set y		[expr {$y - $repeat*$ydir}]
	set w		[$Vars(widget:hs) cget -width]
	set sc	[expr {511.0/$w}]

	for {} {$repeat > 0} {incr repeat -1} {
		set xt [expr {$sc*$x - 255}]
		set yt [expr {221 - $sc*$y}]
		set hs [DetermineColor $xt $yt false]

		if {[llength $hs]} { break }

		set x [expr {$x - $xdir}]
		set y [expr {$y + $ydir}]
	}

	if {$hs == ""} { return }
	lassign $hs h s
	
	set s [expr {(255.0 - $s)/255.0}]
	set h [expr {$s == 0 ? 0 : $h}]
	set v [lindex $Vars(hsv) 2]

	set Vars(hsv) [list $h $s $v]
	[namespace parent]::SetRGB [hsv2rgb $h $s $v]
	[namespace parent]::circle::DrawCrosshair $Vars(widget:hs) $x $y [hsv2rgb $h $s 1.0]

	after cancel $Vars(after)
	set Vars(after) [after idle [namespace code { DrawValues }]]
}


proc SelectV {x y} {
	variable Vars

	set width [$Vars(widget:v) cget -width]
	set x [[namespace parent]::Clip $x 0 [expr {$width - 1}]]
	$Vars(widget:v) coords target $x $Vars(y0)
	$Vars(widget:v) coords active $x $Vars(y0)
	set v [expr {1.0 - double($x*$width)/double($width*($width - 1))}]
	set Vars(hsv) [lreplace $Vars(hsv) 2 2 $v]
	[namespace parent]::SetRGB [eval hsv2rgb $Vars(hsv)]
}


proc MoveV {xdir} {
	variable Vars

	lassign [$Vars(widget:v) coords target] x y
	SelectV [expr {round($x + $xdir)}] [expr {round($y)}]
}


proc DrawValues {} {
	variable Vars

	lassign $Vars(hsv) hue sat

	set width	[$Vars(widget:v) cget -width]
	set ncells	[min $width 255]
	set step		[expr {1.0/($ncells - 1)}]

	for {set i 0} {$i < $ncells} {incr i} {
		set rgb [hsv2rgb $hue $sat [expr {$i*$step}]]
		$Vars(widget:v) itemconfigure val$i -fill [eval format "\#%02x%02x%02x" $rgb]
	}
}


proc DetermineColor {x y clip} {
	# ---------------------------------------------------------------------
	# Converting from RGB to Color Circle Location
	# ---------------------------------------------------------------------
	# The (x,y) coordinates of a particular color in color circle space is
	# calculated by first locating the RGB values along the red, green, and
	# blue axes, and then doing a simple addition of the three resulting
	# vectors. Mathematically, this is equal to:
 	#	x = R*cos(0) + G*cos(120) + B*cos(240)
 	#	y = R*sin(0) + G*sin(120) + B*sin(240)
	# or more concisely,
 	#	x = R - (G + B)/2
 	#	y = sqrt(3)*(G - B)/2
	# ---------------------------------------------------------------------
	# ("Number by Colors" by B. Forthner and T. E. Meyer, p. 144)
	# ---------------------------------------------------------------------

	set h [expr {57.295779513082*atan2($y,$x)}]	;# 180/PI*atan2(y,x)
	if {$h < 0} { set h [expr {$h + 360.0}] }

	set y3 [expr {$y/1.732050808}]		;# y/sqrt(3)

	if {$h < 60.0 || $h >= 300.0} {
		set a [expr {$y3 + 255.0 - $x}]	;# green
		set b [expr {255.0 - $x - $y3}]	;# blue
	} elseif {$h < 180.0} {
		set a [expr {$x + 255.0 - $y3}]	;# red
		set b [expr {255.0 - 2.0*$y3}]	;# blue
	} else {
		set a [expr {$x + 255.0 + $y3}]	;# red
		set b [expr {2.0*$y3 + 255.0}]	;# green
	}

	set a [expr {round($a)}]
	set b [expr {round($b)}]

	if {$clip} {
		set a [[namespace parent]::Clip $a 0 255]
		set b [[namespace parent]::Clip $b 0 255]
	} elseif {$a < 0 || $b < 0 || 255 < $a || 255 < $b} {
		return {}
	}

	return [list $h [min $a $b]]
}


proc MakeCubeImage {width height} {
	variable HugeColorCube
	variable ColorCube
	variable Vars

	if {[info exists ColorCube]} { image delete $ColorCube }
	set ColorCube [image create photo -width $width -height $height]
	::scidb::tk::image colorcube $ColorCube 36 12
	
	$Vars(widget:hs) create image 0 0 -anchor nw -image $ColorCube -tags cube
	$Vars(widget:hs) lower cube
	$Vars(widget:hs) itemconfigure crosshair1 -state normal
	$Vars(widget:hs) itemconfigure crosshair2 -state normal
}


# proc MakeCube {width {sectors 360} {rings 255}} {
# 	variable ColorCube
# 
# 	set height		[expr {round($width*(443.0/511.0))}]
# 	set xscale		[expr {510.0/($width - 1)}]
# 	set yscale		[expr {442.0/($height - 1)}]
# 	set cdist		[expr {255.0/$rings}]
# 	set cdistinc	[expr {$cdist/2.0}]
# 	set cdist2		[expr {$cdist + $cdistinc/$rings}]
# 	set cdist255	[expr {$cdist/255.0}]
# 	set hdist		[expr {360.0/$sectors}]
# 	set ColorCube	[image create photo -width $width -height $height]
# 
# 	for {set y 0} {$y < $height} {incr y} {
# 		for {set x 0} {$x < $width} {incr x} {
# 			set xt [expr {$xscale*$x - 255}]
# 			set yt [expr {221 - $yscale*$y}]
# 			set hs [DetermineColor $xt $yt false]
# 
# 			if {[llength $hs]} {
# 				lassign $hs h t
# 				set s [floor [expr {(255.0 - $t + $cdistinc)/$cdist2}]]
# 
# 				if {$s == 0} {
# 					set h 0.0
# 				} else {
# 					set h [expr {int($h/$hdist)*$hdist}]
# 					set s [expr {$s*$cdist255}]
# 				}
# 
# 				set c [hsv2rgb $h $s 1]
# 				$ColorCube put [eval format "#%02x%02x%02x" $c] -to $x $y [expr {$x + 1}] [expr {$y + 1}]
# 			}
# 		}
# 	}
# }

} ;# namespace cube
} ;# namespace choosecolor
} ;# namespace dialog

# vi:set ts=3 sw=3:
