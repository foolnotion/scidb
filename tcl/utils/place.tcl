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

# This implementation is adopted from BWidget/utils.tcl, but heavily
# modified.

# Due to centering problems on windows, see http://wiki.tcl.tk/20773

package provide place 2.0

namespace eval util {

proc place {path args} {
	set geometry [place::geometry $path {*}$args]
	lassign $geometry x y w h
	wm geometry $path "${x}${y}"
	return $geometry
}


namespace eval place {

variable mainWindow	.

variable PlaceList	{	"at" "center" "top-center" "left" "right"
								"above" "below" "above-or-below" "left-or-right" }
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
proc geometry {path args} {
	variable PlaceList
	variable ShiftLeft

	array set opts {
		-parent ""
		-position at
		-x 0 -y 0
		-width 0 -height 0
		-type normal
		-shift 0
	}
	array set opts $args

	update idletasks
	set windowingsystem [tk windowingsystem]
	set w $opts(-width)
	set h $opts(-height)
	# This is not correct in every case, sometimes 'reqheight' is too large.
	# But sometimes 'height' is too small, and then we need 'reqheight'.
	# No way to find an optimal solution.
	# Currently only one window (in Scidb) is known where the placement is
	# (mathematically) incorrect: the Tip-of-the-Day window.
	if {$w <= 0} { set w [expr {max([winfo reqwidth  $path], [winfo width  $path])}] }
	if {$h <= 0} { set h [expr {max([winfo reqheight $path], [winfo height $path])}] }
	set isPopup 0
	set frameless 0
	set cls [winfo class $path]
	if {	$cls eq "Menu"
		|| $cls eq "OptionMenu"
		|| $opts(-type) eq "popup"
		|| [wm overrideredirect $path]} {
		set isPopup 1
	}
	if {$isPopup || $opts(-type) eq "frameless"} { set frameless 1 }
	if {$isPopup} {
		set sx 0
		set sy 0
		set sw [winfo screenwidth  $path]
		set sh [winfo screenheight $path]
	} else {
		lassign [winfo workarea $path] sx sy sw sh
	}

	set where $opts(-position)
	if {$where ni $PlaceList} {
		set last [lindex $PlaceList end]
		set list [lreplace $PlaceList end end]
		return -code error "bad position \"$where\": must be [join $list ", "], or $last"
	}
	if {$where eq "at"} {
		set err [catch { set x [expr {int($opts(-x))}]; set y [expr {int($opts(-y))}] }]
		if {$err} {
			return -code error "[namespace current]::geometry: incorrect position"
		}
		if {$isPopup} {
			set x [expr {max($x, $sx)}]
			set y [expr {max($y, $sy)}]
		}
		if {$windowingsystem eq "win32"} {
			# handle windows multi-screen. -100 != +-100
			if {[string index $opts(-x) 0] ne "-"} { set x "+$x" }
			if {[string index $opts(-y) 0] ne "-"} { set y "+$y" }                    
		} else {
			if {$x >= 0} { set x "+$x" }
			if {$y >= 0} { set y "+$y" }
		}
	} else {
		set parent $opts(-parent)
		if {[string length $parent] && ![winfo exists $parent]} {
			return -code error "[namespace current]::geometry: \"$parent\" does not exist"
		}
		if {$frameless} {
			lassign {0 0 0 0} el er et eb
		} else {
			lassign [winfo extents $path] el er et eb
		}
		if {$where eq "top-center"} {
			if {[string length $parent]} {
				# center to parent
				set x0 [expr {[winfo rootx $parent] + $sx + ([winfo width $parent] - ($w + $el + $er))/2}]
			} else {
				# center to screen/desktop
				set x0 [expr {($sw - ($w + $el + $er))/2 - [winfo vrootx $path] - $sx}]
			}
			set x "+$x0"
			set y "+$opts(-shift)"
			if {$windowingsystem ne "win32"} {
				if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
				if {$x0 < 0}			{ set x "+0" }
			}
		} elseif {$where eq "center"} {
			if {[string length $parent]} {
				# center to parent
				set x0 [expr {[winfo rootx $parent] + $sx + ([winfo width  $parent] - ($w + $el + $er))/2}]
				set y0 [expr {[winfo rooty $parent] + $sy + ([winfo height $parent] - ($h + $et + $eb))/2}]
			} else {
				# center to screen/desktop
				set x0 [expr {($sw - ($w + $el + $er))/2 - [winfo vrootx $path] - $sx}]
				set y0 [expr {($sh - ($h + $et + $eb))/2 - [winfo vrooty $path] - $sy}]
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
			if {[string length $parent] == 0} {
				set x0 [expr {[winfo vrootx $path] + $sx}]
				set y0 [expr {[winfo vrooty $path] + $sy}]
				set x1 [expr {$x0 + $sw}]
				set y1 [expr {$y0 + $sh}]
			} else {
				set x0 [winfo rootx $parent]
				set y0 [winfo rooty $parent]
				set x1 [expr {$x0 + [winfo width  $parent]}]
				set y1 [expr {$y0 + [winfo height $parent]}]
				if {[winfo toplevel $parent] eq $parent} {
					lassign [winfo extents $parent] pl pr pt pb
					set x0 [expr {$x0 - $pl}]
					set x1 [expr {$x1 + $pr}]
					set y0 [expr {$y0 - $pr}]
					set y1 [expr {$y1 + $pb}]
				}
			}
			set offs $opts(-shift)
			if {$where eq "above-or-below"} {
				if {[string length $parent] == 0 || $y0 - $sy >= $sy + $sh - $h} {
					set where "above"
				} else {
					set where "below"
				}
			} elseif {$where eq "left-or-right"} {
				if {[string length $parent] == 0 || $x0 - $sx >= $sx + $sw - $w} {
					set where "left"
				} else {
					set where "right"
				}
			}
			if {$where eq "left" || $where eq "right"} {
				set y "+$y0"
				if {$windowingsystem ne "win32"} {
					if {$y0 + $h > $sh}	{ set y "-0"; set y0 [expr {$sh - $h}] }
					if {$y0 < 0}			{ set y "+0" }
				}
				if {$where eq "left"} {
					# try left, then right if out, then 0 if out
					if {$x0 >= $w + $el + $er + $offs} {
						set x +[expr {$x0 - $w - $el - $er - $offs}]
					} elseif {$x1 + $w + $el + $er + $offs <= $sw} {
						set x +[expr {$x1 + $offs}]
					} else {
						set x "+0"
					}
				} else {
					# try right, then left if out, then 0 if out
					if {$x1 + $w + $el + $er + $offs <= $sw} {
						set x +[expr {$x1 + $offs}]
					} elseif {$x0 >= $w + $el + $er + $offs} {
						set x +[expr {$x0 - $w - $el - $er - $offs}]
					} else {
						set x "-0"
					}
				}
			} else { ;# if {$where eq "below" || $where eq "above"}
				set x "+$x0"
				if {$windowingsystem ne "win32"} {
					if {$x0 + $w > $sw}	{ set x "-0"; set x0 [expr {$sw - $w}] }
					if {$x0 < 0}	      { set x "+0" }
				}
				if {$where eq "above"} {
					# try top, then bottom, then 0
					if {$h + $et + $eb + $offs <= $y0} {
						set y +[expr {$y0 - $h - $et - $eb - $offs}]
					} elseif {$y1 + $h + $et + $eb + $offs <= $sh} {
						set y +[expr {$y1 + $offs}]
					} else {
						set y "+0"
					}
				} else {
					# try bottom, then top, then 0
					if {$y1 + $h + $et + $eb + $offs <= $sh} {
						set y +[expr {$y1 + $offs}]
					} elseif {$y0 >= $h + $et + $eb + $offs} {
						set y +[expr {$y0 - $h - $et - $eb - $offs}]
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

	return [list $x $y $w $h]
}


proc position {path args} {
	lassign [geometry $path {*}$args] x y _ _
	wm geometry $path "${x}${y}"
}


proc size {path} {
	lassign [geometry $path {*}$args] _ _ w h
	wm geometry $path "${w}x${h}"
}


proc getWmFrameExtents {w} {
	return -code error "[namespace current]::getWmFrameExtents is not implemented"
}


proc getWmWorkArea {w} {
	return -code error "[namespace current]::getWmWorkArea is not implemented"
}

} ;# namespace place
} ;# namespace util


rename winfo __place_winfo_orig

proc winfo {args} {
	if {[llength $args] > 0} {
		set cmd [lindex $args 0]
		if {$cmd eq "extents"} {
			if {[llength $args] < 2} {
				return -code error "wrong # args: should be \"winfo extents window\""
			}
			set extents [::util::place::getWmFrameExtents [lindex $args 1]]
			if {[llength $extents] == 0} { set extents {6 6 30 6} }
			return $extents
		} elseif {[string match workarea* $cmd]} {
			variable util::place::mainWindow
			set window .
			lassign $args cmd window
			if {[winfo exists $mainWindow]} {
				set workarea [::util::place::getWmWorkArea $mainWindow]
			} else {
				set workarea [::util::place::getWmWorkArea $window]
			}
			if {[llength $workarea] == 0} {
				set w [__place_winfo_orig screenwidth $window]
				set h [__place_winfo_orig screenheight $window]
				if {$cmd eq "workarea"} { return [list 0 0 $w $h] }
				set x 0
				set y 0
			} else {
				if {$cmd eq "workarea"} { return $workarea }
				lassign $workarea x y w h
			}
			switch $cmd {
				workareawidth 	{ return $w }
				workareaheight	{ return $h }
				workareax		{ return $x }
				workareay		{ return $y }
			}
		}
	}

	return [uplevel 1 __place_winfo_orig $args]
}

# vi:set ts=3 sw=3:
