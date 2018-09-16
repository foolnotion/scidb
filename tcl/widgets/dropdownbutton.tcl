# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2013-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

proc dropdownbutton {w args} {
	return [::dropdownbutton::Build $w {*}$args]
}


namespace eval dropdownbutton {

array set Options {
	foreground ""
	background ""
	activebackground ""
	activeforeground ""
	disabledforeground ""
}
array set Icons {}

set Locked 0
set Active ""


proc background			{} { return [GetColor background] }
proc foreground			{} { return [GetColor foreground] }
proc activebackground	{} { return [GetColor activebackground] }
proc activeforeground	{} { return [GetColor activeforeground] }
proc disabledforeground	{} { return [GetColor disabledforeground] }


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Priv
	variable ${w}::Rem
	variable Options

	array set opts {
		-menucmd ""
		-tooltip ""
		-tooltipvar ""
		-arrowttip ""
		-arrowttipvar ""
		-arrowbackground ""
		-arrowforeground ""
		-arrowactivebackground ""
		-arrowactiveforeground ""
		-arrowdisabledforeground ""
		-takefocus ""
		-arrowrelief flat
		-arrowoverrelief raised
		-arrowborderwidth 1
		-state normal
		-arrowstate normal
	}
	array set opts $args

	tk::frame $w -borderwidth 0 -takefocus 0 -class DropdownButton
	bind $w <FocusIn> { focus [tk_focusNext %W] }

	InitColors

	foreach opt {activebackground activeforeground background foreground disabledforeground state} {
		if {[string length $opts(-arrow$opt)] == 0} {
			set opts(-arrow$opt) $Options(arrow$opt)
		}
	}
	foreach opt {background arrowbackground activebackground \
					arrowactivebackground arrowactiveforeground} {
		set Priv($opt) $opts(-$opt)
	}
	set Rem(background) $Priv(background)
	set Rem(arrowactivebackground) $Priv(arrowactivebackground)

	tk::button $w.b -overrelief flat
	tk::menubutton $w.m -padx 0 -pady 0

	if {[string length $opts(-background)] == 0} {
		set opts(-background) [$w.b cget -background]
	}
	if {[string length $opts(-arrowbackground)] == 0} {
		set opts(-arrowbackground) [$w.m cget -background]
	}

	bind $w.m <Enter> [namespace code [list EnterArrow $w]]
	bind $w.m <Leave> [namespace code [list LeaveArrow $w]]
	bind $w.m <<MenuWillPost>> [namespace code [list BuildMenu $w]]
	bind $w.m <<MenuWillUnpost>> [namespace code [list ReleaseMenu $w 0]]
	bind $w.m <<MenuAlreadyPosted>> [namespace code [list ReleaseMenu $w 1]]

	grid $w.b -row 0 -column 0 -sticky ns
	grid $w.m -row 0 -column 1 -sticky ns

	array set Priv {
		command				{}
		button1				{}
		arrow:size			0
		arrow:state			normal
		menucmd				{}
		tooltip				""
		tooltipvar			""
		arrowttip			""
		arrowttipvar		""
		arrowrelief			""
		arrowoverrelief	""
	}

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]
	bind $w.b <Configure> [namespace code [list SetIcon $w %h]]

	catch { rename ::$w $w.__dropdownbutton__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	foreach opt [array names opts] {
		if {[string length $opts($opt)] == 0} { array unset opts $opt }
	}
	$w configure {*}[array get opts]
	SetTooltips $w
	return $w
}


proc WidgetProc {w command args} {
	variable ${w}::Priv
	variable ${w}::Rem
	variable Locked

	switch -- $command {
		cget { return [$w.b cget {*}$args] }

		bind {
			if {[llength $args] >= 2} {
				set action [lindex $args 0]
				if {$action in {"<1>" "<Button-1>" "<ButtonPress-1>"}} {
					set Priv(button1) [lindex $args 1]
				}
			}
			return [bind $w.b {*}$args]
		}

		configure {
			if {$Locked} { return $w }

			array set opts $args

			if {[info exists opts(-menucmd)]} {
				set Priv(menucmd) $opts(-menucmd)
				array unset opts -menucmd
			}

			if {[info exists opts(-command)]} {
				set Priv(command) $opts(-command)
				$w.b configure -command $Priv(command)
				array unset opts -command
			}

			if {[info exists opts(-background)]} {
				set background $opts(-background)
				if {[string length $background] == 0} { set background $Priv(background) }
				$w.b configure -background $background
				set rem(-background) $background
				array unset opts -background
			}

			if {[info exists opts(-arrowbackground)]} {
				set background $opts(-arrowbackground)
				if {[string length $background] == 0} { set background $Priv(arrowbackground) }
				$w.m configure -background $background
				array unset opts -arrowbackground
			}

			if {[info exists opts(-arrowforeground)]} {
				set foreground $opts(-arrowforeground)
				if {[string length $foreground] == 0} { set foreground $Priv(arrowforeground) }
				$w.m configure -foreground $foreground
				array unset opts -arrowforeground
			}

			if {[info exists opts(-activebackground)]} {
				set background $opts(-activebackground)
				if {[string length $background] == 0} { set background $Priv(activebackground) }
				$w.b configure -activebackground $background
				array unset opts -activebackground
			}

			if {[info exists opts(-arrowactivebackground)]} {
				if {$Priv(arrow:state) eq "normal"} {
					set background $opts(-arrowactivebackground)
					if {[string length $background] == 0} { set background $Priv(arrowactivebackground) }
				} else {
					set background $Priv(background)
				}
				$w.m configure -activebackground $background
				set rem(-arrowactivebackground) $background
				array unset opts -arrowactivebackground
			}

			if {[info exists opts(-arrowactiveforeground)]} {
				set foreground $opts(-arrowactiveforeground)
				if {[string length $foreground] == 0} { set foreground $Priv(arrowactiveforeground) }
				$w.b configure -activeforeground $foreground
				array unset opts -arrowactiveforeground
			}

			if {[info exists opts(-arrowstate)]} {
				set Priv(arrow:state) $opts(-arrowstate)
				if {[info exists Priv(arrow:icon:$Priv(arrow:state))]} {
					$w.m configure -image $Priv(arrow:icon:$Priv(arrow:state))
				}
				if {$Priv(arrow:state) eq "disabled"} {
					set pref ""
					$w.b configure -command {}
					bind $w.b <ButtonPress-1> { break }
				} else {
					set pref "arrowactive"
					$w.b configure -command $Priv(command)
					bind $w.b <ButtonPress-1> $Priv(button1)
				}
				set background ""
				if {[info exists rem(-${pref}background)]} { set background $rem(-${pref}background) }
				if {[string length $background] == 0} { set background $Rem(${pref}background) }
				$w.m configure -activebackground $background
				array unset opts -arrowstate
			}

			foreach entry [$w.b configure] {
				set opt [lindex $entry 0]
				if {[info exists opts($opt)] && [llength $opts($opt)] > 0} {
					$w.b configure $opt $opts($opt)
					array unset opts $opt
				}
			}

			foreach opt [array names opts] {
				if {	[string match -arrow* $opt]
					&& ![string match *ttip* $opt]
					&& ![string match *overrelief $opt]} {
					$w.m configure -[string range $opt 6 end] $opts($opt)
				}
			}

			foreach opt {menucmd tooltip tooltipvar arrowttip arrowttipvar arrowrelief arrowoverrelief} {
				if {[info exists opts(-$opt)]} {
					set Priv($opt) $opts(-$opt)
				}
			}

			Setup $w
			return $w
		}

		clone {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace curent] clone <path>\""
			}
			set v [lindex $args 0]
			Build $v -menucmd $Priv(menucmd)
			foreach option [$w.m configure] {
				set spec [lindex $option 0]
				catch { $v.m configure $spec [$w.m cget $spec] }
			}
			foreach option [$w.b configure] {
				set spec [lindex $option 0]
				catch { $v.b configure $spec [$w.b cget $spec] }
			}
			Setup $v
			return $v
		}
	}

	return [$w.b $command {*}$args]
}


proc Setup {w} {
	variable ${w}::Priv
	variable ${w}::Rem

	set Priv(relief) [$w.b cget -relief]
	set Priv(overrelief) [$w.b cget -overrelief]
	set Priv(background) [$w.b cget -background]
	set Priv(activebackground) [$w.b cget -activebackground]
	set Priv(arrowactiveforeground) [$w.m cget -activeforeground]
	set Priv(arrowactivebackground) [$w.m cget -activebackground]
	set Priv(arrowdisabledforeground) [$w.m cget -disabledforeground]
	set Priv(arrowforeground) [$w.m cget -foreground]
	set Priv(arrowbackground) [$w.m cget -background]

	if {$Priv(arrow:state) eq "normal"} {
		set Rem(arrowactivebackground) $Priv(arrowactivebackground)
	}
	set Rem(background) $Priv(background)

	SetTooltips $w
}


proc GetColor {type} {
	variable Options
	InitColors
	return $Options(arrow$type)
}


proc SetIcon {w height} {
	variable ${w}::Priv
	variable Icons

	if {$height <= 1} { return }
	if {$Priv(arrow:size) == $height} { return }

	set img [$w.b cget -image]
	if {[string length $img]} {
		set size [image height $img]
	} else {
		set size [expr {-[font configure [$w.b cget -font] -size]}]
	}

	set size [expr {max(1, $size/2)}]

	if {![info exists Icons($size:)]} {
		foreach {state attr} {normal foreground active activeforeground disabled disabledforeground} {
			set img [image create photo -height $size -width [expr {$size + 1}]]
			set svg [string map [list FILL $Priv(arrow$attr)] $svg::arrow]
			::scidb::tk::image create svg $img
			set Icons($size:$state) $img
		}
	}

	set Priv(arrow:icon:normal) $Icons($size:normal)
	set Priv(arrow:icon:active) $Icons($size:active)
	set Priv(arrow:icon:disabled) $Icons($size:disabled)

	$w.m configure -image $Icons($size:$Priv(arrow:state))
}


proc SetTooltips {w} {
	variable ${w}::Priv

	if {[string length $Priv(tooltip)] || [string length $Priv(tooltipvar)]} {
		bind $w.b <Enter> [namespace code [list Tooltip show $w $w.b tooltip]]
		bind $w.b <Leave> [namespace code [list Tooltip hide $w $w.b tooltip]]
	} else {
		bind $w.b <Enter> {#}
		bind $w.b <Leave> {#}
	}
}


proc Tooltip {mode w btn attr} {
	variable ${w}::Priv
	variable Active

	if {[$btn cget -state] eq "disabled"} { return }

	switch $mode {
		show {
			if {[string length $Priv(${attr}var)]} {
				::tooltip::showvar $btn $Priv(${attr}var)
			} elseif {[string length $Priv($attr)]} {
				::tooltip::show $w $Priv($attr)
			}
		}

		hide {
			::tooltip::hide true
		}
	}
}


proc BuildMenu {w} {
	variable ${w}::Priv
	variable Locked
	variable Active

	set m $w.m.__dropdownbutton__
	catch { destroy $m }
	$w.m configure -menu ""
	if {$Priv(arrow:state) eq "disabled"} { return }
	menu $m -tearoff 0

	if {[string length $Priv(menucmd)]} {
		eval $Priv(menucmd) $w $m
	}

	if {[$w.m cget -state] eq "normal"} {
		set background $Priv(arrowactivebackground)
	} else {
		set background $Priv(arrowbackground)
	}

	$w.m configure \
		-background $background \
		-activebackground $background \
		-image $Priv(arrow:icon:active) \
		-menu $m \
		-direction below \
		;

	if {[string length $Active] && $Active ne $w && [winfo exists $Active]} {
		LeaveArrow $Active
	}

	if {$Active ne $w} {
		EnterArrow $w ;# probably we entered while another menu button is active
	}

	set Active $w
	incr Locked 1
	::tooltip::disable
}


proc ReleaseMenu {w unpost} {
	variable ${w}::Priv
	variable Locked
	variable Active

	# TODO: this only works with X11, so we need a platform independent proc.
	if {$unpost} { ::tk::MenuUnpost $w.m.__dropdownbutton__ }

	if {[$w.m cget -state] eq "normal"} {
		set attr arrowactivebackground
	} else {
		set attr arrowbackground
	}

	$w.m configure \
		-background $Priv(arrowbackground) \
		-activebackground $Priv($attr) \
		-image $Priv(arrow:icon:normal) \
		;
	if {$Locked == 0 || [incr Locked -1] == 0} {
		set Active ""
		::tooltip::enable
	}

	if {$Priv(arrow:state) eq "normal"} {
		after 10 [namespace code [list LeaveArrow $w 1]]
	} else {
		EnterArrow $w
	}
}


proc EnterArrow {w} {
	variable ${w}::Priv
	variable Locked
	variable Active

	if {$Priv(arrow:state) eq "disabled"} { return }

	set Priv(arrow:state) active

	if {$w ne $Active} {
		$w.m configure -image $Priv(arrow:icon:active) -relief $Priv(arrowoverrelief)

		if {[string length $Priv(arrowttip)] || [string length $Priv(arrowttipvar)]} {
			Tooltip show $w $w.m arrowttip
		}
	}

	if {!$Locked} {
		set relief $Priv(overrelief)
		$w.b configure -relief $relief -overrelief $relief -background $Priv(activebackground)
	}
}


proc LeaveArrow {w {force 0}} {
	variable ${w}::Priv
	variable Locked
	variable Active

	if {$Priv(arrow:state) eq "disabled"} { return }

	set Priv(arrow:state) normal

	if {$w ne $Active} {
		$w.m configure -image $Priv(arrow:icon:normal) -relief $Priv(arrowrelief)
	}

	if {[string length $Priv(arrowttip)] || [string length $Priv(arrowttipvar)]} {
		Tooltip hide $w $w.m arrowttip
	}

	if {$force || !$Locked} {
		$w.b configure -relief $Priv(relief) -background $Priv(background)
	}

	if {!$Locked && [winfo containing -displayof $w {*}[winfo pointerxy $w]] eq "$w.b"} {
		$w.b configure -relief $Priv(overrelief)
	}
}


proc InitColors {} {
	variable Options

	if {[string length $Options(activebackground)] == 0} {
		set m ".__dropdownbutton__[clock milliseconds]"
		menu $m
		foreach opt {activebackground activeforeground background foreground disabledforeground} {
			set Options(arrow$opt) [$m cget -$opt]
		}
		destroy $m
	}
}


namespace eval svg {

set arrow {
	<svg>
		<polygon points="0,10.021 18.007,37.979 36,10.021 "/> 
		<polygon fill="FILL" points="0,10.021 18.007,37.979 36,10.021 "/> 
	</svg> 
}

} ;# namespace svg
} ;# namespace dropdownbutton


rename ::tk::PostOverPoint ::tk::_PostOverPoint_dropdownbutton

proc ::tk::PostOverPoint {menu x y {entry {}}} {
	if {[string match "*.m.__dropdownbutton__" $menu]} {
		set w [winfo parent [winfo parent $menu]]
		set x [winfo rootx $w]
		set y [expr {[winfo rooty $w] + [winfo height $w]}]
		set mh [winfo reqheight $menu]
		if {($y + $mh) > [winfo screenheight $w]} {
			set y [expr {[winfo rooty $w] - $mh}]
		}
	}

	::tk::_PostOverPoint_dropdownbutton $menu $x $y $entry
}

# vi:set ts=3 sw=3:
