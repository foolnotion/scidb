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
	set width [expr {$height - round(0.067*($height - 6)) - 11}]
	return [expr {round(($width*511.0)/443.0) - 16}]
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

	catch { image delete $ColorCube }

	if {[makeImage]} {
		set ColorCube [image create photo -width $width -height $height]
		::scidb::tk::image copy $HugeColorCube $ColorCube
	} else {
		MakeCube $width 36 12
	}
	
	$Vars(widget:hs) create image 0 0 -anchor nw -image $ColorCube -tags cube
	$Vars(widget:hs) lower cube
	$Vars(widget:hs) itemconfigure crosshair1 -state normal
	$Vars(widget:hs) itemconfigure crosshair2 -state normal
}


proc MakeCube {width {sectors 360} {rings 255}} {
	variable ColorCube

	set height		[expr {round($width*(443.0/511.0))}]
	set xscale		[expr {510.0/($width - 1)}]
	set yscale		[expr {442.0/($height - 1)}]
	set cdist		[expr {255.0/$rings}]
	set cdistinc	[expr {$cdist/2.0}]
	set cdist2		[expr {$cdist + $cdistinc/$rings}]
	set cdist255	[expr {$cdist/255.0}]
	set hdist		[expr {360.0/$sectors}]
	set ColorCube	[image create photo -width $width -height $height]

	for {set y 0} {$y < $height} {incr y} {
		for {set x 0} {$x < $width} {incr x} {
			set xt [expr {$xscale*$x - 255}]
			set yt [expr {221 - $yscale*$y}]
			set hs [DetermineColor $xt $yt false]

			if {[llength $hs]} {
				lassign $hs h t
				set s [floor [expr {(255.0 - $t + $cdistinc)/$cdist2}]]

				if {$s == 0} {
					set h 0
				} else {
					set h [expr {int($h/$hdist)*$hdist}]
					set s [expr {$s*$cdist255}]
				}

				set c [hsv2rgb $h $s 1]
				$ColorCube put [eval format "#%02x%02x%02x" $c] -to $x $y [expr {$x + 1}] [expr {$y + 1}]
			}
		}
	}
}


proc makeImage {} {
	variable HugeColorCube

	if {![info exists HugeColorCube]} {
		set HugeColorCube [image create photo photo_ColorCube(1022x886) -data {
			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
			nAAAAABJRU5ErkJggg==
		}]
	}

	return 1
}

} ;# namespace cube
} ;# namespace choosecolor
} ;# namespace dialog

# vi:set ts=3 sw=3:
