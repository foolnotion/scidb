# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

# This implementation is adopted from BWidget/utils.tcl.

# Due to centering problems on window, see http://wiki.tcl.tk/20773

package provide place 1.0

namespace eval util {

proc place {path args} { return [place::place $path {*}$args] }


namespace eval place {

variable PlaceList	{"at" "center" "left" "right" "above" "below"}
variable ShiftLeft	8


# Notes:
#  For Windows systems with more than one monitor the available screen area may
#  have negative positions. Geometry settings with negative numbers are used
#  under X to place wrt the right or bottom of the screen. On windows, Tk
#  continues to do this. However, a geometry such as 100x100+-200-100 can be
#  used to place a window onto a secondary monitor. Passing the + gets Tk
#  to pass the remainder unchanged so the Windows manager then handles -200
#  which is a position on the left hand monitor.
#  I've tested this for left, right, above and below the primary monitor.
#  Currently there is no way to ask Tk the extent of the Windows desktop in 
#  a multi monitor system. Nor what the legal co-ordinate range might be.
#
proc geometry {path w h args} {
	variable PlaceList
	variable ShiftLeft

	update idletasks
	set windowingsystem [tk windowingsystem]
	set arglen [llength $args]
	set posOnly [expr {$w <= 0 && $arglen > 0}]
	set sizeOnly [expr {$arglen == 0}]
	set shiftLeft 0
	if {$w <= 0} { set w [winfo reqwidth $path] }
	if {$h <= 0} { set h [winfo reqheight $path] }

	if {$arglen > 4} {
		return -code error "[namespace current]::geometry: bad number of argument"
	}

	if {$arglen > 0} {
		set where [lindex $args 0]
		set idx   [lsearch -exact $PlaceList $where]

		if {$idx == -1} {
			set last [lindex $PlaceList end]
			set list [lreplace $PlaceList end end]
			return -code error "bad position \"$where\": must be [join $list ", "], or $last"
		}
		if {$idx == 0} {
			set err [catch {
							set x [expr {int([lindex $args 1])}]
							set y [expr {int([lindex $args 2])}]
							}]
			if {$err} {
				return -code error "[namespace current]::geometry: incorrect position"
			}
			if {$windowingsystem eq "win32"} {
				# handle windows multi-screen. -100 != +-100
				if {[string index [lindex $args 1] 0] ne "-"} { set x "+$x" }
				if {[string index [lindex $args 2] 0] ne "-"} { set y "+$y" }                    
			} else {
				if {$x >= 0} { set x "+$x" }
				if {$y >= 0} { set y "+$y" }
			}
		} else {
			if {$arglen >= 2} {
				set widget [lindex $args 1]
				if {![winfo exists $widget]} {
					return -code error "[namespace current]::geometry: \"$widget\" does not exist"
				}
			} else {
				set widget .
			}
			if {$arglen == 3 && [lindex $args 2]} { set shiftLeft $ShiftLeft }
			set sw [winfo screenwidth  $path]
			set sh [winfo screenheight $path]
			if {$idx == 1} {
				if {$arglen >= 2 && $widget ne "."} {
					# center to widget
					set x0 [expr {[winfo rootx $widget] + ([winfo width  $widget] - $w)/2}]
					set y0 [expr {[winfo rooty $widget] + ([winfo height $widget] - $h)/2}]
				} else {
					# center to screen
					set x0 [expr {($sw - $w)/2 - [winfo vrootx $path]}]
					set y0 [expr {($sh - $h)/2 - [winfo vrooty $path]}]
				}
				set x "+$x0"
				set y "+$y0"
				if {$windowingsystem ne "win32"} {
					if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
					if {$x0 < 0}			{ set x "+0" }
					if {$y0 + $h > $sh}	{ set y "-0"; set y0 [expr {$sh - $h}] }
					if {$y0 < 0}			{ set y "+0" }
				}
			} else {
				if {$widget eq "."} {
					set x0 [winfo vrootx $path]
					set y0 [winfo vrooty $path]
					set x1 [expr {$x0 + $sw}]
					set y1 [expr {$y0 + $sh}]
				} else {
					set x0 [winfo rootx $widget]
					set y0 [winfo rooty $widget]
					set x1 [expr {$x0 + [winfo width  $widget]}]
					set y1 [expr {$y0 + [winfo height $widget]}]
				}
				if {$idx == 2 || $idx == 3} {
					set y "+$y0"
					if {$windowingsystem ne "win32"} {
						if {$y0 + $h > $sh}	{ set y "-0"; set y0 [expr {$sh - $h}] }
						if {$y0 < 0}			{ set y "+0" }
					}
					if {$idx == 2} {
						# try left, then right if out, then 0 if out
						if {$x0 >= $w + $shiftLeft} {
							set x +[expr {$x0 - $w - $shiftLeft}]
						} elseif {$x1 + $w <= $sw} {
							set x "+$x1"
						} else {
							set x "+0"
						}
					} else {
						# try right, then left if out, then 0 if out
						if {$x1 + $w <= $sw} {
							set x "+$x1"
						} elseif {$x0 >= $w + $shiftLeft} {
							set x +[expr {$x0 - $w - $shiftLeft}]
						} else {
							set x "-0"
						}
					}
				} else {
				set x "+$x0"
					if {$windowingsystem ne "win32"} {
						if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
						if {$x0 < 0}	      { set x "+0" }
					}
					if {$idx == 4} {
						# try top, then bottom, then 0
						if {$h <= $y0} {
							set y +[expr {$y0 - $sh}]
						} elseif {$y1 + $h <= $sh} {
							set y "+$y1"
						} else {
							set y "+0"
						}
					} else {
						# try bottom, then top, then 0
						if {$y1 + $h <= $sh} {
							set y "+$y1"
						} elseif {$y0 >= $h} {
							set y +[expr {$y0 - $h}]
						} else {
							set y "-0"
						}
					}
				}
			}
		}
		if {$windowingsystem eq "aqua"} {
			# Avoid the native menu bar which sits on top of everything.
			scan $y "%d" y0
			if {0 <= $y0 && $y0 < 22} { set y "+22" }
		}
	}
	if {$sizeOnly} {
		return "${w}x${h}"
	}
	if {$posOnly} {
		return "${x}${y}"
	}
	return "${w}x${h}${x}${y}"
}


proc position {path args} {
	return [geometry $path 0 0 {*}$args]
}


proc size {path} {
	return [geometry $path 0 0]
}


proc place {path args} {
	wm geometry $path [geometry $path 0 0 {*}$args]
}

} ;# namespace place
} ;# namespace util

# vi:set ts=3 sw=3:
