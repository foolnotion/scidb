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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tk 8.5
package require Ttk

proc scrolledframe {path args} {
	array set opts $args
	set myOpts {}
	foreach key [array names opts] {
		switch -- $key {
			-background {
			}
			-width - -height {
				lappend myOpts $key $opts($key)
			}
			-class - -style - -borderwidth - -relief - -padding {
				lappend myOpts $key $opts($key)
				array unset opts($key)
			}
		}
	}
	set parent [::ttk::frame $path {*}$myOpts]
	set f $parent.__scrolledframe__
	set h $parent.__vs__
	set v $parent.__hs__
	::scrolledframe::scrolledframe $f \
		{*}[array get opts] \
		-xscrollcommand [list ::scrolledframe::sbset $h] \
		-yscrollcommand [list ::scrolledframe::sbset $v] \
		-borderwidth 0 \
		;
	::ttk::scrollbar $v -command [list $f yview] -orient vertical
	::ttk::scrollbar $h -command [list $f xview] -orient horizontal
	grid $f -row 0 -column 0 -sticky nsew
	grid $v -row 0 -column 1 -sticky ns
	grid $h -row 1 -column 0 -sticky ew
	grid rowconfigure $parent 0 -weight 1
	grid columnconfigure $parent 0 -weight 1
	return $f.scrolled
}

namespace eval scrolledframe {

proc sbset {w first last} { $w set $first $last }

# ==============================
#
# scrolledframe
set version 0.9.1
set (debug,place) 0
#
# a scrolled frame
#
# (C) 2003, ulis
#
# NOL licence (No Obligation Licence)
#
# Changes (C) 2004, KJN
#
# NOL licence (No Obligation Licence)
# ==============================
#
# Hacked package, no documentation, sorry
# See example at bottom
#
# ------------------------------
# v 0.9.1
#	automatic scroll on resize
# ==============================

package provide scrolledframe $version

# --------------
#
# create a scrolled frame
#
# --------------
# parm1: widget name
# parm2: options key/value list
# --------------
proc scrolledframe {w args} {
	variable {}
	# create a scrolled frame
	tk::frame $w
	# trap the reference
	rename $w ::scrolledframe::_$w
	# redirect to dispatch
	interp alias {} $w {} ::scrolledframe::Dispatch $w
	# create scrollable internal frame
	tk::frame $w.scrolled
	# place it
	place $w.scrolled -in $w -x 0 -y 0
	if {$(debug,place)} { puts "place $w.scrolled -in $w -x 0 -y 0" }
	# init internal data
	set ($w:vheight) 0
	set ($w:vwidth) 0
	set ($w:vtop) 0
	set ($w:vleft) 0
	set ($w:xscroll) ""
	set ($w:yscroll) ""
	set ($w:width) 0
	set ($w:height) 0
	set ($w:fillx) 0
	set ($w:filly) 0
	# configure
	if {$args != ""} { uplevel 1 ::scrolledframe::Config $w $args }
	# bind <Configure>
	bind $w <Configure> [namespace code [list resize $w]]
	bind $w.scrolled <Configure> [namespace code [list resize $w]]
	# return widget ref
	return $w
}

# --------------
#
# dispatch the trapped command
#
# --------------
# parm1: widget name
# parm2: operation
# parm2: operation args
# --------------
proc Dispatch {w cmd args} {
	variable {}
	switch -- $cmd {
		configure   { uplevel 1 [linsert $args 0 ::scrolledframe::Config $w] }
		xview       { uplevel 1 [linsert $args 0 ::scrolledframe::Xview $w] }
		yview       { uplevel 1 [linsert $args 0 ::scrolledframe::Yview $w] }
		default     { uplevel 1 [linsert $args 0 ::scrolledframe::_$w $cmd] }
	}
}

# --------------
# configure operation
#
# configure the widget
# --------------
# parm1: widget name
# parm2: options
# --------------
proc Config {w args} {
	variable {}
	set options {}
	set flag 0
	foreach {key value} $args {
		switch -- $key {
			-fill {
				# new fill option: what should the scrolled object do if it is
				# smaller than the viewing window?
				if {$value == "none"} {
					 set ($w:fillx) 0
					 set ($w:filly) 0
				} elseif {$value == "x"} {
					 set ($w:fillx) 1
					 set ($w:filly) 0
				} elseif {$value == "y"} {
					 set ($w:fillx) 0
					 set ($w:filly) 1
				} elseif {$value == "both"} {
					 set ($w:fillx) 1
					 set ($w:filly) 1
				} else {
					 error "invalid value: should be \"$w configure -fill value\", where \"value\" is \"x\", \"y\", \"none\", or \"both\""
				}
				resize $w force
				set flag 1
			}
			-xscrollcommand {
				# new xscroll option
				set ($w:xscroll) $value
				set flag 1
			}
			-yscrollcommand {
				# new yscroll option
				set ($w:yscroll) $value
				set flag 1
			}
			-background {
				$w.scrolled configure -background $value
			}
			default { lappend options $key $value }
		}
	}
	# check if needed
	if {!$flag || $options != ""} {
		# call frame config
		uplevel 1 [linsert $options 0 ::scrolledframe::_$w configure]
	}
}

# --------------
# Resize proc
#
# Update the scrollbars if necessary, in response to a change in either the viewing window
# or the scrolled object.
# Replaces the old resize and the old vresize
# A <Configure> call may mean any change to the viewing window or the scrolled object.
# We only need to resize the scrollbars if the size of one of these objects has changed.
# Usually the window sizes have not changed, and so the proc will not resize the scrollbars.
# --------------
# parm1: widget name
# parm2: pass anything to force resize even if dimensions are unchanged
# --------------
proc resize {w {force {}}} {
	variable {}
	set force [llength $force]

	if {![string match *.__scrolledframe__ $w]} {
		set w $w.__scrolledframe__
	}

	set _vheight      $($w:vheight)
	set _vwidth       $($w:vwidth)
	# compute new height & width
	set ($w:vheight)  [winfo reqheight $w.scrolled]
	set ($w:vwidth)	[winfo reqwidth  $w.scrolled]

	# The size may have changed, e.g. by manual resizing of the window
	set _height		   $($w:height)
	set _width			$($w:width)
	set ($w:height)   [winfo height $w] ;# gives the actual height of the viewing window
	set ($w:width)    [winfo width  $w] ;# gives the actual width of the viewing window

	if {$force || $($w:vheight) != $_vheight || $($w:height) != $_height} {
		# resize the vertical scroll bar
		Yview $w scroll 0 unit
		# Yset $w
	}

	if {$force || $($w:vwidth) != $_vwidth || $($w:width) != $_width} {
		# resize the horizontal scroll bar
		Xview $w scroll 0 unit
		# Xset $w
	}
} ;# end proc resize

# --------------
# Xset proc
#
# resize the visible part
# --------------
# parm1: widget name
# --------------
proc Xset {w} {
	variable {}
	# call the xscroll command
	set cmd $($w:xscroll)
	if {$cmd != ""} { catch { eval $cmd [Xview $w] } }
}

# --------------
# Yset proc
#
# resize the visible part
# --------------
# parm1: widget name
# --------------
proc Yset {w} {
	variable {}
	# call the yscroll command
	set cmd $($w:yscroll)
	if {$cmd != ""} { catch { eval $cmd [Yview $w] } }
}

# -------------
# Xview
#
# called on horizontal scrolling
# -------------
# parm1: widget path
# parm2: optional moveto or scroll
# parm3: fraction if parm2 == moveto, count unit if parm2 == scroll
# -------------
# return: scrolling info if parm2 is empty
# -------------
proc Xview {w {cmd ""} args} {
	variable {}
	# check args
	set len [llength $args]
	switch -- $cmd {
		""			{ set args {} }
		moveto   { if {$len != 1} { error "wrong # args: should be \"$w xview moveto fraction\"" } }
		scroll   { if {$len != 2} { error "wrong # args: should be \"$w xview scroll count unit\"" } }
		default  { error "unknown operation \"$cmd\": should be empty, moveto or scroll" }
	}
	# save old values:
	set _vleft  $($w:vleft)
	set _vwidth $($w:vwidth)
	set _width  $($w:width)
	# compute new vleft
	set count ""
	switch $len {
		0 {
			# return fractions
			if {$_vwidth == 0} { return {0 1} }
			set first [expr {double($_vleft)/$_vwidth}]
			set last [expr {double($_vleft + $_width)/$_vwidth}]
			if {$last > 1.0} { return {0 1} }
			return [list $first $last]
		}

		1 {
			# absolute movement
			set vleft [expr {int(double($args)*$_vwidth)}]
	 	}

		2 {
			# relative movement
			foreach {count unit} $args break
			if {[string match p* $unit]} { set count [expr {$count*9}] }
			set vleft [expr {$_vleft + $count*0.1*$_width}]
		}
	}
	if {$vleft + $_width > $_vwidth} { set vleft [expr {$_vwidth - $_width}] }
	if {$vleft < 0} { set vleft 0 }
	if {$vleft != $_vleft || $count == 0} {
		set ($w:vleft) $vleft
		Xset $w
		if {$($w:fillx) && ($_vwidth < $_width || $($w:xscroll) == "") } {
			# "scrolled object" is not scrolled, because it is too small
			# or because no scrollbar was requested.
			# fillx means that, in these cases, we must tell the object what its width should be
			place $w.scrolled -in $w -x [expr {-$vleft}] -width $_width
			if {$(debug,place)} { puts "place $w.scrolled -in $w -x [expr {-$vleft}] -width $_width" }
		} else {
			place $w.scrolled -in $w -x [expr {-$vleft}] -width {}
			if {$(debug,place)} { puts "place $w.scrolled -in $w -x [expr {-$vleft}] -width {}" }
		}

	}
}

# -------------
# Yview
#
# called on vertical scrolling
# -------------
# parm1: widget path
# parm2: optional moveto or scroll
# parm3: fraction if parm2 == moveto, count unit if parm2 == scroll
# -------------
# return: scrolling info if parm2 is empty
# -------------
proc Yview {w {cmd ""} args} {
	variable {}
	# check args
	set len [llength $args]
	switch -- $cmd {
		""			{set args {}}
		moveto	{ if {$len != 1} { error "wrong # args: should be \"$w yview moveto fraction\"" } }
		scroll	{ if {$len != 2} { error "wrong # args: should be \"$w yview scroll count unit\"" } }
		default	{ error "unknown operation \"$cmd\": should be empty, moveto or scroll" }
	}
	# save old values
	set _vtop $($w:vtop)
	set _vheight $($w:vheight)
#	set _height [winfo height $w]
	set _height $($w:height)
	# compute new vtop
	set count ""
	switch $len {
		0 {
			# return fractions
			if {$_vheight == 0} { return {0 1} }
			set first [expr {double($_vtop)/$_vheight}]
			set last [expr {double($_vtop + $_height)/$_vheight}]
			if {$last > 1.0} { return {0 1} }
			return [list $first $last]
		}

		1 {
			# absolute movement
			set vtop [expr {int(double($args)*$_vheight)}]
		}

		2 {
			# relative movement
			foreach {count unit} $args break
			if {[string match p* $unit]} { set count [expr {$count*9}] }
			set vtop [expr {$_vtop + $count*0.1*$_height}]
		}
	}
	if {$vtop + $_height > $_vheight} { set vtop [expr {$_vheight - $_height}] }
	if {$vtop < 0} { set vtop 0 }
	if {$vtop != $_vtop || $count == 0} {
		set ($w:vtop) $vtop
		Yset $w
		if {$($w:filly) && ($_vheight < $_height || $($w:yscroll) == "")} {
			# "scrolled object" is not scrolled, because it is too small
			# or because no scrollbar was requested.
			# filly means that, in these cases, we must tell the object what its height should be
			place $w.scrolled -in $w -y [expr {-$vtop}] -height $_height
			if {$(debug,place)} { puts "place $w.scrolled -in $w -y [expr {-$vtop}] -height $_height" }
		} else {
			place $w.scrolled -in $w -y [expr {-$vtop}] -height {}
			if {$(debug,place)} { puts "place $w.scrolled -in $w -y [expr {-$vtop}] -height {}" }
		}
	}
}

} ;# namesspace scrolledframe

# vi:set ts=3 sw=3:
