# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2013 Gregor Cramer
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

array set Options { foreground "" background "" activebackground "" activeforeground "" }
array set Icons {}


proc activebackground {} {
	variable Options
	InitActiveColors
	return $Options(arrowactivebackground)
}


proc activeforeground {} {
	variable Options
	InitActiveColors
	return $Options(arrowactiveforeground)
}


proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Priv
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
		-takefocus ""
		-arrowrelief raised
		-arrowborderwidth 1
		-state normal
	}
	array set opts $args

	tk::frame $w -borderwidth 0 -takefocus 0 -class DropdownButton
	bind $w <FocusIn> { focus [tk_focusNext %W] }

	InitActiveColors

	foreach opt {activebackground activeforeground background foreground} {
		if {[string length $opts(-arrow$opt)] == 0} {
			set opts(-arrow$opt) $Options(arrow$opt)
		}
	}

	tk::button $w.b
	tk::menubutton $w.m -padx 0 -pady 0

	bind $w.m <Enter> [namespace code [list EnterArrow $w]]
	bind $w.m <Leave> [namespace code [list LeaveArrow $w]]
	bind $w.m <<MenuWillPost>> [namespace code [list BuildMenu $w]]
	bind $w.m <<MenuWillUnpost>> [namespace code [list ReleaseMenu $w]]

	grid $w.b -row 0 -column 0 -sticky ns
	grid $w.m -row 0 -column 1 -sticky ns

	set Priv(arrow:size) 0
	set Priv(arrow:locked) 0
	set Priv(arrow:state) normal
	foreach opt {menucmd tooltip tooltipvar arrowttip arrowttipvar} { set Priv($opt) "" }

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

	switch -- $command {
		cget { return [$w.b cget {*}$args] }
		bind { return [bind $w.b {*}$args] }

		configure {
			if {$Priv(arrow:locked)} { return $w }

			array set opts $args

			if {[info exists opts(-menucmd)]} {
				set Priv(menucmd) $opts(-menucmd)
				array unset opts -menucmd
			}

			foreach opt {state background takefocus} {
				if {[info exists opts(-$opt)]} {
					set opts(-arrow$opt) $opts(-$opt)
				}
			}

			foreach entry [$w.b configure] {
				set opt [lindex $entry 0]
				if {[info exists opts($opt)] && [llength $opts($opt)] > 0} {
					$w.b configure $opt $opts($opt)
					array unset opts $opt
				}
			}

			foreach opt [array names opts] {
				if {[string match -arrow* $opt] && ![string match *ttip* $opt]} {
					$w.m configure -[string range $opt 6 end] $opts($opt)
				}
			}

			foreach opt {menucmd tooltip tooltipvar arrowttip arrowttipvar} {
				if {[info exists opts(-$opt)]} {
					set Priv($opt) $opts(-$opt)
				}
			}

			set Priv(relief) [$w.b cget -relief]
			set Priv(overrelief) [$w.b cget -overrelief]
			set Priv(background) [$w.b cget -background]
			set Priv(activebackground) [$w.b cget -activebackground]
			set Priv(arrowactivebackground) [$w.m cget -activebackground]
			set Priv(arrowactiveforeground) [$w.m cget -activeforeground]
			set Priv(arrowforeground) [$w.m cget -foreground]
			set Priv(arrowbackground) [$w.m cget -background]

			SetTooltips $w
			return $w
		}
	}

	return [$w.b $command {*}$args]
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
		foreach {state attr} {normal foreground active activeforeground} {
			set img [image create photo -height $size -width [expr {$size + 1}]]
			set svg [string map [list FILL $Priv(arrow$attr)] $svg::arrow]
			::scidb::tk::image create svg $img
			set Icons($size:$state) $img
		}
	}

	set Priv(arrow:icon:normal) $Icons($size:normal)
	set Priv(arrow:icon:active) $Icons($size:active)
	$w.m configure -image $Icons($size:normal)
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


proc Popdown {w} {
	variable ${w}::Priv

	if {[string length $Priv(menucmd)] == 0} { return }

	set m $w.b.m
	catch { destroy $m }
	menu $m -tearoff 0
	eval $Priv(menucmd) $w $m
	tk_popdown $m $w
}


proc BuildMenu {w} {
	variable ${w}::Priv

	set m $w.m.__dropdownbutton__
	catch { destroy $m }
	menu $m -tearoff 0

	if {[string length $Priv(menucmd)]} {
		eval $Priv(menucmd) $w $m
	}

	$w.m configure \
		-background $Priv(arrowactivebackground) \
		-activebackground $Priv(arrowactivebackground) \
		-image $Priv(arrow:icon:active) \
		-menu $m \
		-direction below \
		;

	set Priv(arrow:locked) 1
}


proc ReleaseMenu {w} {
	variable ${w}::Priv

	$w.m configure \
		-background $Priv(arrowbackground) \
		-activebackground $Priv(arrowactivebackground) \
		-image $Priv(arrow:icon:normal) \
		;
	set Priv(arrow:locked) 0

	if {$Priv(arrow:state) eq "normal"} {
		LeaveArrow $w
	} else {
		EnterArrow $w
	}
}


proc EnterArrow {w} {
	variable ${w}::Priv

	if {[$w.m cget -state] eq "disabled"} { return }

	set Priv(arrow:state) active

	if {!$Priv(arrow:locked)} {
		set relief $Priv(overrelief)
		$w.b configure -relief $relief -overrelief $relief -background $Priv(activebackground)
		$w.m configure -image $Priv(arrow:icon:active)

		if {[string length $Priv(arrowttip)] || [string length $Priv(arrowttipvar)]} {
			Tooltip show $w $w.m arrowttip
		}
	}
}


proc LeaveArrow {w} {
	variable ${w}::Priv

	if {[$w.m cget -state] eq "disabled"} { return }

	set Priv(arrow:state) normal

	if {!$Priv(arrow:locked)} {
		$w.b configure -relief $Priv(relief) -background $Priv(background)
		$w.m configure -image $Priv(arrow:icon:normal)

		if {[string length $Priv(arrowttip)] || [string length $Priv(arrowttipvar)]} {
			Tooltip hide $w $w.m arrowttip
		}
	}
}


proc InitActiveColors {} {
	variable Options

	if {[string length $Options(activebackground)] == 0} {
		set m ".__dropdownbutton__[clock milliseconds]"
		menu $m
		foreach opt {activebackground activeforeground background foreground} {
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
