# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
#       Balloon help
#
# Copyright (c) 1996-2007 Jeffrey Hobbs
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# Initiated: 28 October 1996
# ======================================================================

# ======================================================================
# 		   * COPYRIGHT AND LICENSE TERMS *
# 
# (This file blatantly stolen from Tcl/Tk license and adapted - thus assume
# it falls under similar license terms).
# 
# This software is copyrighted by Jeffrey Hobbs <jeff.hobbs@acm.org>.  The
# following terms apply to all files associated with the software unless
# explicitly disclaimed in individual files.
# 
# The authors hereby grant permission to use, copy, modify, distribute, and
# license this software and its documentation for any purpose, provided that
# existing copyright notices are retained in all copies and that this notice
# is included verbatim in any distributions.  No written agreement, license,
# or royalty fee is required for any of the authorized uses.
# 
# IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
# DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
# OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
# EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE IS
# PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO
# OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
# MODIFICATIONS.
# 
# RESTRICTED RIGHTS: Use, duplication or disclosure by the U.S. government
# is subject to the restrictions as set forth in subparagraph (c) (1) (ii)
# of the Rights in Technical Data and Computer Software Clause as DFARS
# 252.227-7013 and FAR 52.227-19.
# 
# SPECIAL NOTES:
# 
# This software is also falls under the bourbon_ware clause:
# 
#   Should you find this software useful in your daily work, you should
#   feel obliged to take the author out for a drink if the opportunity
#   presents itself.  The user may feel exempt from this clause if they are
#   under 21 or think the author has already partaken of too many drinks.
# ======================================================================

# ======================================================================
# Copyright (c) 2008-2018 Gregor Cramer
# Made some enhancements and fixes.
# ======================================================================

#------------------------------------------------------------------------
# PROCEDURE
#	tooltip::tooltip
#
# DESCRIPTION
#	Implements a tooltip (balloon help) system
#
# ARGUMENTS
#	tooltip <option> ?arg?
#
# clear ?pattern?
#	Stops the specified widgets (defaults to all) from showing tooltips
#
# delay ?millisecs?
#	Query or set the delay.  The delay is in milliseconds and must
#	be at least 50.  Returns the delay.
#
# disable OR off
#	Disables all tooltips.
#
# exposure ?millisecs?
#  Query or set the exposure time.  The exposure time is in milliseconds
#  and is unlimited in case of zero value.  Returns the exposure time.
#
# enable OR on
#	Enables tooltips for defined widgets.
#
# <widget> ?-index index? ?-item id? ?message?
#	If -index is specified, then <widget> is assumed to be a menu
#	and the index represents what index into the menu (either the
#	numerical index or the label) to associate the tooltip message with.
#	Tooltips do not appear for disabled menu items.
#	If message is {}, then the tooltip for that widget is removed.
#	The widget must exist prior to calling tooltip.  The current
#	tooltip message for <widget> is returned, if any.
#
# RETURNS: varies (see methods above)
#
# NAMESPACE & STATE
#	The namespace tooltip is used.
#	Control toplevel name via ::tooltip::wname.
#
# EXAMPLE USAGE:
#	tooltip .button "A Button"
#	tooltip .menu -index "Load" "Loads a file"
#
#------------------------------------------------------------------------

# Some Tcl/Tk distributions do provide "tooltip 1.4.4".
# We don't need this.
catch { package forget tooltip }

package require Tk 8.5
package provide tooltip 1.5.0

proc tooltip {args} { return [::tooltip::tooltip {*}$args ] }

namespace eval ::tooltip {

namespace export -clear tooltip show hide init
namespace import ::tcl::mathfunc::int
namespace import ::tcl::mathfunc::max

variable tooltip
variable tooltipvar
variable G

array set G {
	font				TkTooltipFont
	bold				{}
	background		lightyellow
	exposureTime	3500
	delay				500
	delayMenu		250

	highExposureTimeThreshold 70
	highExposureTime 8000

	allowed			{}
	exclude			{}
	init				1
	enabled			1
	fadeId			{}
	exposureId		{}
	afterId			{}
	last				-1
	toplevel			.__tooltip__
}
# original background: lightyellow
# alternative background: #ffffaa
# alternative exposureTime: 4000
# alternative delay: 750-1000

switch [tk windowingsystem] {
	x11	{ array set G { fade 0 fadestep 0.2 } }
	win32	{ array set G { fade 1 fadestep 0.2 } }
	aqua	{ array set G { fade 0 fadestep 0.2 } }
}


# The extra ::hide call in <Enter> is necessary to catch moving to
# child widgets where the <Leave> event won't be generated
bind Tooltip <Enter> [namespace code {
	variable tooltip
	variable tooltipvar
	variable G

	#tooltip::hide
	if {!$G(enabled)} { return }
	set G(last) -1

	if {[info exists tooltipvar(%W)]} {
		showvar %W $tooltipvar(%W)
	} elseif {[info exists tooltip(%W)]} {
		show %W $tooltip(%W)
	}
}]

bind Menu <<MenuSelect>> [namespace code { MenuMotion %W }]
bind Tooltip <Leave> [namespace code { hide 1 }] ;# fade ok
bind Tooltip <Any-KeyPress> [namespace code hide]
bind Tooltip <Any-Button> [namespace code hide]


proc init {} {
	variable G

	if {!$G(init)} { return }

	set b $G(toplevel)
	tk::toplevel $b -class TooltipPopup

	if {[tk windowingsystem] eq "aqua"} {
		::tk::unsupported::MacWindowStyle style $b help none
	} else {
		wm overrideredirect $b 1
	}

	if {[tk windowingsystem] eq "win32"} {
		# avoid the blink issue with 1 to <1 alpha on Windows
		catch { wm attributes $b -alpha 0.99 }
	}
	catch { wm attributes $b -topmost 1 }
	catch { wm attributes $b -type tooltip }
	wm positionfrom $b program
	wm withdraw $b

	pack [tk::frame $b.top -relief solid -borderwidth 1 -background $G(background)]

	for {set i 0} {$i < 5} {incr i} {
		tk::label $b.top.label-$i \
			-highlightthickness 0 \
			-borderwidth 0 \
			-background $G(background) \
			-foreground black \
			;
	}

	pack $b.top.label-0 -ipadx 1 -anchor w

	set G(init) 0
}


proc background	{} { return [set [namespace current]::G(background)] }
proc delay			{} { return [set [namespace current]::G(delay)] }
proc enabled		{} { return [set [namespace current]::G(enabled)] }
proc disabled		{} { return [expr {![set [namespace current]::G(enabled)]}] }
proc font			{} { return [set [namespace current]::G(font)] }


proc bold {{font {}}} {
	if {[llength $font]} {
		set family [::font configure $font -family]
		set size [::font configure $font -size]
		return [::font create -family $family -size $size -weight bold]
	}

	variable G

	if {[llength $G(bold)] == 0} {
		set family [::font configure $G(font) -family]
		set size [::font configure $G(font) -size]
		set G(bold) [::font create -family $family -size $size -weight bold]
	}

	return $G(bold)
}


proc tooltip {w {args {}}} {
	variable tooltip
	variable tooltipvar
	variable G

	init

	switch -- $w {
		clear {
			if {[llength $args] == 0} { set args .* }
			Clear $args
		}

		delay {
			if {[llength $args]} {
				if {![string is integer -strict $args] || $args < 50} {
					return -code error \
						"tooltip delay must be an integer greater than 50 (delay is in millisecs)"
				}
				return [set G(delay) $args]
			} else {
				return $G(delay)
			}
		}

		exposure {
			if {[llength $args] && [string is integer [lindex $args 0]]} {
				set G(exposureTime) [lindex $args 0]
			}
			return $G(exposureTime)
		}

		fade {
			if {[llength $args]} {
				set G(fade) [string is true -strict [lindex $args 0]]
			}
			return $G(fade)
		}

		hide {
			hide
		}

		exclude {
			set w [lindex $args 0]
			if {[llength $args] > 1} {
				set namedItem [lindex $args 1]
				if {![catch { $w find withtag $namedItem } item]} {
					lappend G(exclude,$w) $item
				}
			} else {
				lappend G(exclude) $w
			}
		}

		include {
			set w [lindex $args 0]
			if {$w eq "all"} {
				set G(exclude) {}
			} elseif {[llength $args] > 1} {
				if {[info exists G(exclude,$w)]} {
					set namedItem [lindex $args 1]
					if {![catch { $w find withtag $namedItem } item]} {
						if {[llength $G(exclude,$w)] == 0} {
							unset G(exclude,$w)
						} else {
							set i [lsearch -exact $G(exclude,$w) $item]
							if {$i >= 0} { set G(exclude,$w) [lreplace $G(exclude,$w) $i $i] }
						}
					}
				}
			} else {
				set i [lsearch -exact $G(exclude) $w]
				if {$i >= 0} { set G(exclude) [lreplace $G(exclude) $i $i] }
			}
		}

		off - disable {
			disable
		}

		on - enable {
			enable [lindex $args 0]
		}

		show {
			show {*}$args
		}

		default {
			init
			set i $w

			if {[llength $args]} {
				set i [uplevel 1 [namespace code [list Register $w $args]]]
			}

			if {[info exists tooltipvar($i)]} { return $tooltipvar($i) }
			if {[info exists tooltip($i)]} { return $tooltip($i) }
		}
	}
}


proc show {w msg {i cursor} {font {}}} {
	variable G

	if {$G(enabled)} {
		after cancel $G(afterId)
		after cancel $G(exposureId)

		if {[llength $font] == 0} { set font $G(font) }
		set G(afterId) [after $G(delay) [namespace code [list Show $w {} $msg $i $font]]]
	}
}


proc showvar {w var {i cursor} {font {}}} {
	variable G

	if {$G(enabled)} {
		after cancel $G(afterId)
		after cancel $G(exposureId)

		if {[llength $font] == 0} { set font $G(font) }
		set G(afterId) [after $G(delay) [namespace code [list Show $w $var {} $i $font]]]
	}
}


proc updatePosition {w b} {
	set screenw [winfo screenwidth $w]
	set screenh [winfo screenheight $w]
	set reqw [winfo reqwidth $b]
	set reqh [winfo reqheight $b]

	set py [winfo pointery $w]
	set y [expr {$py + 20}]
	if {$py < $screenh && $y + $reqh > $screenh} {
		# show above if we would be offscreen
		set y [expr {[winfo pointery $w] - $reqh - 5}]
	}

	set x [winfo pointerx $w]
	# only readjust when we would appear right on the screen edge
	if {$x < 0 && ($x + $reqw) > 0} {
		set x 0
	} elseif {($x < $screenw) && ($x + $reqw) > $screenw} {
		set x [expr {$screenw - $reqw}]
	}

	wm geometry $b +${x}+${y}
}


proc popup {w b {at {}}} {
	variable G

	update idletasks

	if {$b ne $G(toplevel)} { tooltip off }

	set screenw [winfo screenwidth $w]
	set screenh [winfo screenheight $w]
	set reqw [winfo reqwidth $b]
	set reqh [winfo reqheight $b]

	# When adjusting for being on the screen boundary, check that we are
	# near the "edge" already, as Tk handles multiple monitors oddly
	if {$at eq "cursor"} {
		set py [winfo pointery $w]
		set y [expr {$py + 20}]
		if {$py < $screenh && $y + $reqh > $screenh} {
			# show above if we would be offscreen
			set y [expr {max(0, [winfo pointery $w] - $reqh - 5)}]
		}
	} elseif {$at ne ""} {
		set rooty [winfo rooty $w]
		set y [expr {$rooty + [winfo vrooty $w] + [$w yposition $at] + 25}]
		if {$rooty < $screenh && $y + $reqh > $screenh} {
			# show above if we would be offscreen
			set y [expr {max(0, [winfo rooty $w] + [$w yposition $at] - $reqh - 5)}]
		}
	} else {
		set rooty [winfo rooty $w]
		set y [expr {$rooty + [winfo vrooty $w] + [winfo height $w] + 5}]
		if {$rooty < $screenh && $y + $reqh > $screenh} {
			# show above if we would be offscreen
			set y [expr {max(0, [winfo rooty $w] - $reqh - 5)}]
		}
	}

	if {$at eq "cursor"} {
		set x [winfo pointerx $w]
	} else {
		set x [expr {[winfo rootx $w] + [winfo vrootx $w] + ([winfo width $w] - $reqw)/2}]
	}

	# only readjust when we would appear right on the screen edge
	if {$x < 0 && ($x + $reqw) > 0} {
		set x 0
	} elseif {($x < $screenw) && ($x + $reqw) > $screenw} {
		set x [expr {$screenw - $reqw}]
	}

	if {[tk windowingsystem] eq "aqua"} {
		set focus [focus]
	}

	# avoid the blink issue with 1 to <1 alpha on Windows, watch half-fading
	catch { wm attributes $b -alpha 0.99 }
	catch { wm attributes $b -type tooltip }
	catch { wm attributes $b -topmost }
	wm geometry $b +$x+$y
	wm deiconify $b
	raise $b

	if {[tk windowingsystem] eq "aqua" && $focus ne ""} {
		# Aqua's help window steals focus on display
		after idle [list focus -force $focus]
	}
}


proc popdown {w} {
	variable G

	if {$w ne $G(toplevel)} { tooltip on }

	if {[winfo exists $w]} {
		update idletasks
		wm withdraw $w
	}
}


proc hide {{fadeOk 0}} {
	variable G

	after cancel $G(afterId)
	after cancel $G(exposureId)
	after cancel $G(fadeId)

	if {$fadeOk && $G(fade)} {
		set w $G(toplevel)
		Fade $w $G(fadestep)
	} else {
		popdown $G(toplevel)
	}
}


proc enable {{allowed {}}} {
	variable G

	set G(enabled) 1
	set G(allowed) $allowed
}


proc disable {{fadeOk 0}} {
	variable G

	set G(enabled) 0
	hide $fadeOk
}


proc wname {{w {}}} {
	variable G

	if {[llength [info level 0]] > 1} {
		# $w specified
		if {$w ne $G(toplevel)} {
			hide
			destroy $G(toplevel)
			set G(toplevel) $w
		}
	}

	return $G(toplevel)
}


proc Register {w arguments} {
	variable tooltip
	variable tooltipvar

	set var ""
	set key [lindex $arguments 0]

	while {[string match -* $key]} {
		switch -- $key {
			-index {
				set index [lindex $arguments 1]
				if {[catch {$w entrycget $index -label}]} {
					return -code error "widget \"$w\" does not seem to be a menu, \
												which is required for the -index switch"
				}
				set arguments [lreplace $arguments 0 1]
			}

			-item {
				set namedItem [lindex $arguments 1]

				if {[catch {$w find withtag $namedItem} item]} {
					return -code error "widget \"$w\" is not a canvas, \
												or item \"$namedItem\" does not exist in the canvas"
				}

				if {[llength $item] > 1} {
					return -code error \
						"item \"$namedItem\" specifies more than one item on the canvas"
				}
				set arguments [lreplace $arguments 0 1]
			}

			-tag {
				set tag [lindex $arguments 1]
				set r [catch {lsearch -exact [$w tag names] $tag} ndx]

				if {$r || $ndx == -1} {
					return -code error \
						"widget \"$w\" is not a text widget or \"$tag\" is not a text tag"
				}

				set arguments [lreplace $arguments 0 1]
			}

			default {
				return -code error \
					"unknown option \"$key\": should be -index, -item, or -tag"
			}
		}

		set key [lindex $arguments 0]
	}

	if {[llength $arguments] != 1} {
		return -code error "wrong # args: should be \"tooltip widget\
									?-index index? ?-item item? ?-tag tag? message\""
	}

	if {$key eq ""} {
		Clear $w
	} else {
		if {![winfo exists $w]} {
			return -code error "bad window path name \"$w\""
		}
		bind [winfo toplevel $w] <Any-KeyPress> +[namespace code { hide }]
		if {[info exists $key]} { set var $key } else { set var {} }

		if {[info exists index]} {
			if {[llength $var]} {
				set tooltipvar($w,$index) $var
			} else {
				set tooltip($w,$index) $key
			}
			return $w,$index
		}
		
		if {[info exists item]} {
			if {[llength $var]} {
				set tooltipvar($w,$item) $var
			} else {
				set tooltip($w,$item) $key
			}
			if {[winfo class $w] eq "Listbox"} {
				EnableListbox $w $item
			} else {
				EnableCanvas $w $item
			}
			return $w,$item
		}

		if {[info exists tag]} {
			if {[llength $var]} {
				set tooltipvar($w,t_$tag) $var
			} else {
				set tooltip($w,t_$tag) $key
			}
			EnableTag $w $tag
			return $w,$tag
		}

		if {[llength $var]} {
			set tooltipvar($w) $key
		} else {
			set tooltip($w) $key
		}
		bindtags $w [linsert [bindtags $w] end "Tooltip"]
		return $w
	}
}


proc Clear {{pattern .*}} {
	variable tooltip
	variable tooltipvar
	variable G

	set i 0
	while {$i >= 0} {
		set i [lsearch -glob $G(exclude) $pattern]
		if {$i >= 0} { set G(exclude) [lreplace $G(exclude) $i $i] }
	}

	# cache the current widget at pointer
	set ptrw [winfo containing {*}[winfo pointerxy .]]

	foreach w [array names tooltip $pattern] {
		catch { unset tooltip($w) }
		catch { unset tooltipvar($w) }

		if {[winfo exists $w]} {
			set tags [bindtags $w]

			if {[set i [lsearch -exact $tags "Tooltip"]] != -1} {
				bindtags $w [lreplace $tags $i $i]
			}

			## We don't remove TooltipMenu because there
			## might be other indices that use it

			# Withdraw the tooltip if we clear the current contained item
			if {$ptrw eq $w} { hide }
		}
	}
}


proc Show {w var msg {i {}} {font {}}} {
	variable G

	if {![winfo exists $w]} { return }
	if {!$G(enabled)} { return }
	if {[llength $G(allowed)] && ![string match $G(allowed)* $w]} { return }
	if {$w in $G(exclude)} { return }

	# Use string match to allow that the help will be shown when
	# the pointer is in any child of the desired widget
	if {[string match bbox* $i]} {
		scan $i "bbox %d %d %d %d %s" x1 y1 x2 y2 item
		if {$item != [$w find withtag current]} { return }
		set topFraction [lindex [$w yview] 0]
		lassign [winfo pointerxy $w] x y
		set rx [winfo rootx $w]; set ry [winfo rooty $w]
		incr x1 $rx; incr x2 $rx; incr y1 $ry; incr y2 $ry
		incr x [int [$w canvasx 0]]; incr y [int [$w canvasy 0]]
		if {$x < $x1 || $x2 < $x || $y < $y1 || $y2 < $y} { return }
		set i cursor
	} elseif {	([winfo class $w] ne "Menu")
				&& ![string match $w* [winfo containing {*}[winfo pointerxy $w]]]} {

		return
	}

	after cancel $G(fadeId)
	after cancel $G(exposureId)
	set b $G(toplevel)

	set labelFont $font
	set txt ""
	if {[llength $labelFont] == 0} { set labelFont $G(font) }
	for {set k 1} {$k < 5} {incr k} { pack forget $b.top.label-$k }

	if {[llength $var]} {
		append txt [set $var]
		$b.top.label-0 configure -textvar $var -justify left -font $labelFont
	} elseif {[string match *<b>* $msg]} {
		set k 0
		foreach line [split $msg "\n"] {
			if {[string match <b>* $line]} {
				set f [bold $font]
				set line [string range $line 3 end]
				append txt [set $var]
			} else {
				set f $labelFont
			}
			$b.top.label-$k configure -textvar {} -text $line -justify left -font $f
			pack $b.top.label-$k -ipadx 1 -anchor w
			incr k
		}
	} else {
		append txt $msg
		$b.top.label-0 configure -textvar {} -text $msg -justify left -font $labelFont
	}

	popup $w $b $i

	if {$G(exposureTime)} {
		set exposureTime $G(exposureTime)
		if {[string length $txt] >= $G(highExposureTimeThreshold)} {
			set exposureTime $G(highExposureTime)
		}
		set G(exposureId) [after $exposureTime [namespace code { hide true }]]
	}
}


proc MenuMotion {w} {
	variable tooltip
	variable tooltipvar
	variable G

	if {!$G(enabled)} { return }

	variable tooltip
	variable tooltipvar

	# Menu events come from a funny path, map to the real path.
#	set m [string map {"#" "."} [winfo name $w]]
	set cur [$w index active]

	# The next two lines (all uses of 'last') are necessary until the
	# <<MenuSelect>> event is properly coded for Unix/(Windows)?
	if {$cur == $G(last)} return
	set G(last) $cur

	# a little inlining - this is :hide
	after cancel $G(afterId)
	after cancel $G(exposureId)
	popdown $G(toplevel)

	if {	![catch {$w entrycget $cur -label}]
		&& $w eq [winfo containing {*}[winfo pointerxy $w]]} {

		set cmd {}
		set lbl [$w entrycget $cur -label]
		if {[info exists tooltipvar($w,$cur)]} {
			set cmd [namespace code [list showvar $w $tooltipvar($w,$cur) $cur]]
		} elseif {[info exists tooltip($w,$cur)]} {
			set cmd [namespace code [list show $w $tooltip($w,$cur) $cur]]
		} elseif {[info exists tooltipvar($w,$lbl)]} {
			set cmd [namespace code [list showvar $w $tooltipvar($w,$lbl) $cur]]
		} elseif {[info exists tooltip($w,$lbl)]} {
			set cmd [namespace code [list show $w $tooltip($w,$lbl) $cur]]
		}
		if {[llength $cmd]} { set G(afterId) [after $G(delayMenu) $cmd] }
	}
}


proc Fade {w step} {
	if {[catch {wm attributes $w -alpha} alpha] || $alpha <= 0.0} {
		popdown $w
		catch { wm attributes $w -alpha 0.99 }
	} else {
		variable G
		wm attributes $w -alpha [expr {$alpha - $step}]
		set G(fadeId) [after 50 [namespace code [list Fade $w $step]]]
	}
}


proc ListItemTip {w x y} {
	variable tooltip
	variable G

	set G(last) -1
	set item [$w index @$x,$y]

	if {$G(enabled) && [info exists tooltip($w,$item)]} {
		set G(afterId) [after $G(delay) [namespace code [list show $w $tooltip($w,$item) cursor]]]
	}
}


proc ListItemMotion {w x y} {
	variable tooltip
	variable G

	if {!$G(enabled)} { return }

	set item [$w index @$x,$y]
	if {$item ne $G(last)} {
		set G(last) $item
		after cancel $G(afterId)
		catch {wm withdraw $G(toplevel)}

		if {[info exists tooltip($w,$item)]} {
			set G(afterId) [after $G(delay) [namespace code [list show $w $tooltip($w,$item) cursor]]]
		}
	}
}


proc ItemTip {w args} {
	variable tooltip
	variable tooltipvar
	variable G

	if {!$G(enabled)} { return }

	set G(last) -1
	set item [$w find withtag current]
	if {[info exists G(exclude,$w)] && $item in $G(exclude,$w)} { return }

	if {[info exists tooltipvar($w,$item)]} {
		showvar $w $tooltipvar($w,$item) "bbox [$w bbox $item] $item"
	} elseif {[info exists tooltip($w,$item)]} {
		show $w $tooltip($w,$item) "bbox [$w bbox $item] $item"
	}
}


proc EnableListbox {w args} {
	if {[string match *listitemTip* [bind $w <Enter>]]} { return }

	bind $w <Enter> +[namespace code [list ListItemTip %W %x %y]]
	bind $w <Motion> +[namespace code [list ListItemMotion %W %x %y]]
	bind $w <Leave> +[namespace code [list hide 1]] ; # fade ok
	bind $w <Any-KeyPress> +[namespace code hide]
	bind $w <Any-Button> +[namespace code hide]
}


proc EnableCanvas {w args} {
	if {[string match *itemTip* [$w bind all <Enter>]]} { return }

	$w bind all <Enter> +[namespace code [list ItemTip $w]]
	$w bind all <Leave> +[namespace code [list hide 1]] ;# fade ok
	$w bind all <Any-KeyPress> +[namespace code hide]
	$w bind all <Any-Button> +[namespace code hide]
}


proc TagTip {w tag} {
	variable tooltip
	variable tooltipvar
	variable G

	if {!$G(enabled)} { return }
	set G(last) -1

	if {[info exists tooltipvar($w,t_$tag)]} {
		after cancel $G(afterId)
		after cancel $G(exposureId)
		showvar $w $tooltipvar($w,t_$tag)
	} elseif {[info exists tooltip($w,t_$tag)]} {
		after cancel $G(afterId)
		after cancel $G(exposureId)
		show $w $tooltip($w,t_$tag)
	}
}


proc EnableTag {w tag} {
	if {[string match *tagTip* [$w tag bind $tag]]} { return }

	$w tag bind $tag <Enter> +[namespace code [list TagTip $w $tag]]
	$w tag bind $tag <Leave> +[namespace code [list hide 1]] ;# fade ok
	$w tag bind $tag <Any-KeyPress> +[namespace code hide]
	$w tag bind $tag <Any-Button> +[namespace code hide]
}

} ;# namespace tooltip

# vi:set ts=3 sw=3:
