# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
# ======================================================================

# ======================================================================
# Copyright: (C) 2010-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Ttk
package require Tk 8.5
if {[catch { package require tkpng }]} { package require Img }
package require place
package provide calendar 1.0

namespace eval calendar {
namespace eval mc {

set OneMonthForward	"One month forward (Shift-Right)"
set OneMonthBackward	"One month backward (Shift-Left)"
set OneYearForward	"One year forward (Ctrl-Right)"
set OneYearBackward	"One year backward (Ctrl-Left)"

set Su "Su"
set Mo "Mo"
set Tu "Tu"
set We "We"
set Th "Th"
set Fr "Fr"
set Sa "Sa"

set Jan "Jan"
set Feb "Feb"
set Mar "Mar"
set Apr "Apr"
set May "May"
set Jun "Jun"
set Jul "Jul"
set Aug "Aug"
set Sep "Sep"
set Oct "Oct"
set Nov "Nov"
set Dec "Dec"

set MonthName(1)  "January"
set MonthName(2)  "February"
set MonthName(3)  "March"
set MonthName(4)  "April"
set MonthName(5)  "May"
set MonthName(6)  "June"
set MonthName(7)  "July"
set MonthName(8)  "August"
set MonthName(9)  "September"
set MonthName(10) "October"
set MonthName(11) "November"
set MonthName(12) "December"

set WeekdayName(0) "Sunday"
set WeekdayName(1) "Monday"
set WeekdayName(2) "Tuesday"
set WeekdayName(3) "Wednesday"
set WeekdayName(4) "Thursday"
set WeekdayName(5) "Friday"
set WeekdayName(6) "Saturday"

}

namespace import ::tcl::mathfunc::abs
namespace import ::tcl::mathfunc::min

array set Days {
	 1 31
	 2 28
	 3 31
	 4 30
	 5 31
	 6 30
	 7 31
	 8 31
	 9 30
	10 31
	11 30
	12 31
}

variable FontSizes {8 9 10 11 12 14 16 18 20 22 24 26 28}
variable Priv

array set colors {
	label:background	white
	label:foreground	black
	active:background	#ffdd76
	active:foreground	black
	hilite:foreground	darkRed
}

array set options {
	repeat:delay		300
	repeat:interval	100
}

set minYear		1902
set maxYear		2037
set weekStart	0
set useGrab		true


proc popup {parent args} {
	variable FontSizes
	variable Priv
	variable icon::12x10::PrevYear
	variable icon::12x10::NextYear
	variable icon::12x10::PrevMonth
	variable icon::12x10::NextMonth
	variable useGrab
	variable colors
	variable minYear
	variable maxYear
	variable weekStart
	variable options

	if {![winfo exists $parent]} {
		return -code error "parent \"$parent\": window does not exist"
	}

	set disableParent false
	set Priv(weekStart) $weekStart
	set Priv(minYear) $minYear
	set Priv(maxYear) $maxYear

	if {!$useGrab && [catch {$parent cget -state}]} { set disableParent true }
	set key [lindex $args 0]
	set date {}

	while {$key != ""} {
		if {[llength $args] <= 1} {
			return -code error "no value given to option \"$key\""
		}

		set value [lindex $args 1]
		set args [lreplace $args 0 1]

		switch $key {
			-weekStart - -minYear - -maxYear {
				if {![string is integer -strict $value]} {
					return -code error "option \"$key\": value should be integer"
				}
				set Priv([string range $key 1 end]) $value
			}

			-date {
				if {$value ne "today" && $value ne "now"} {
					if {[llength $value] != 3} {
						return -code error \
							"option \"$key\": value should be 'now', 'today', or {Year Month Day}"
					}
					lassign $value y m d
					if {![string is integer -strict $y]} {
						return -code error "option \"$key\": invalid year '$y'"
					}
					if {![string is integer -strict $m] || 1 > $m || $m > 12} {
						return -code error "option \"$key\": invalid month '$m'"
					}
					if {![string is integer -strict $d] || 1 > $d || $d > 31} {
						return -code error "option \"$key\": invalid day '$d'"
					}
					if {![validDate? $y $m $d]} {
						return -code error "option \"$key\": invalid date '$y.$m.$d'"
					}
					set date [list $y [Normalize $m] [Normalize $d]]
				}
			}

			default {
				return -code error "option \"$key\": unknown option"
			}
		}

		set key [lindex $args 0]
	}

	set point [expr {[winfo toplevel $parent] == "." ? "" : "."}]
	set top [winfo toplevel $parent]${point}__calendar__
	if {[winfo exists $top]} { return }

	if {[llength $date] == 0} { set date [today] }
	lassign $date Priv(y) Priv(m) Priv(d)
	set Priv(m:start) $Priv(m)
	set Priv(y:start) $Priv(y)
	set Priv(d:start) $Priv(d)
	set Priv(day) $Priv(d)
	set Priv(daysInMonth) [daysInMonth $Priv(m) $Priv(y)]
	set Priv(active) {}

	menu $top
	wm withdraw $top
	bind $top <Destroy> [namespace code [list ClearTooltips $top %W]]
	bind $top <ButtonRelease-1> [namespace code [list Unpost $top %X %Y]]
	bind $top <ButtonRelease-2> [namespace code [list Unpost $top %X %Y]]
	bind $top <ButtonRelease-3> [namespace code [list Unpost $top %X %Y]]
	bind $top <Deactivate> [namespace code Exit]
	if {!$useGrab} { bind $top <FocusOut> [namespace code Exit] }

	tk::frame $top.calendar -relief raised -borderwidth 2 -takefocus 0
	tk::frame $top.calendar.header -takefocus 0
	pack $top.calendar
	set Priv(background) [$top.calendar cget -background]

	bind $top.calendar <Escape> [namespace code Exit]

	tk::label $top.calendar.header.month -padx 0 -anchor e
	set font [$top.calendar.header.month cget -font]
	set size [abs [font configure $font -size]]
	set n [lsearch -integer $FontSizes $size]
	if {$n < 1} {
		incr size 1
	} else {
		set size [lindex $FontSizes [incr n -1]]
	}
	set boldFont [list [font configure $font -family] $size bold]
	$top.calendar.header.month configure -font $boldFont
	tooltip $top.calendar.header.month [Tr MonthName($Priv(m))]

	tk::label $top.calendar.header.year -font $boldFont -padx 0 -anchor center

	tk::frame $top.calendar.header.left -takefocus 0
	tk::frame $top.calendar.header.right -takefocus 0

	tk::button $top.calendar.header.left.year   -image $PrevYear
	tk::button $top.calendar.header.left.month  -image $PrevMonth
	tk::button $top.calendar.header.right.year  -image $NextYear
	tk::button $top.calendar.header.right.month -image $NextMonth

	foreach which {left.year left.month right.year right.month} {
		$top.calendar.header.$which configure \
			-relief flat \
			-overrelief raised \
			-repeatdelay $options(repeat:delay) \
			-repeatinterval $options(repeat:interval) \
			-background $Priv(background) \
			;
		bind $top.calendar.header.$which <ButtonRelease-1> \
			[list after idle [namespace code { ButtonEnter %W }]]
	}

	tooltip $top.calendar.header.left.year		[namespace current]::mc::OneYearBackward
	tooltip $top.calendar.header.right.year	[namespace current]::mc::OneYearForward
	tooltip $top.calendar.header.left.month	[namespace current]::mc::OneMonthBackward
	tooltip $top.calendar.header.right.month	[namespace current]::mc::OneMonthForward

#	tk::frame $top.calendar.sep -height 2 -background black -borderwidth 0
	ttk::separator $top.calendar.sep

	pack $top.calendar.header.left.year -side left -padx 2
	pack $top.calendar.header.left.month -side left
	pack $top.calendar.header.right.year -side right -padx 2
	pack $top.calendar.header.right.month -side right

	pack $top.calendar.header.left -side left
	pack $top.calendar.header.month -side left -expand yes -fill x -padx 2
	pack $top.calendar.header.year -side left -expand yes -fill x -padx 2
	pack $top.calendar.header.right -side left

	$top.calendar.header.left.year configure   -command [namespace code [list SetYear  $top -1]]
	$top.calendar.header.right.year configure  -command [namespace code [list SetYear  $top +1]]
	$top.calendar.header.left.month configure  -command [namespace code [list SetMonth $top -1]]
	$top.calendar.header.right.month configure -command [namespace code [list SetMonth $top +1]]

	grid $top.calendar.header -columnspan 7 -sticky ew
	grid $top.calendar.sep -columnspan 7 -sticky ew -padx 2

	set rowData {}
	set day 0

	foreach dayName [nameOfDays $Priv(weekStart)] {
		if {((7 - $day) % 7) == $Priv(weekStart)} {
			set foreground $colors(hilite:foreground)
		} else {
			set foreground black
		}
		tk::label $top.calendar.days:$dayName \
			-text $dayName \
			-font TkFixedFont \
			-borderwidth 1 \
			-width 0 \
			-foreground $foreground \
			;
		tooltip $top.calendar.days:$dayName [Tr WeekdayName([expr {($day + $Priv(weekStart)) % 7}])] 
		lappend rowData $top.calendar.days:$dayName
		incr day
	}

	grid {*}$rowData -sticky e

	set cmd-Up					[namespace code [list Focus $top -7]]
	set cmd-Down				[namespace code [list Focus $top +7]]
	set cmd-Left				[namespace code [list Focus $top -1]]
	set cmd-Right				[namespace code [list Focus $top +1]]
	set cmd-Escape				[namespace code Exit]
	set cmd-Shift-Left		[namespace code [list SetMonth $top -1]]
	set cmd-Shift-Right		[namespace code [list SetMonth $top +1]]
	set cmd-Control-Left		[namespace code [list SetYear  $top -1]]
	set cmd-Control-Right	[namespace code [list SetYear  $top +1]]
	set cmd-Home				[namespace code [list Focus $top first]]
	set cmd-End					[namespace code [list Focus $top last]]
	set cmd-Control-Home		[namespace code "SetMonth $top first; Focus $top first"]
	set cmd-Control-End		[namespace code "SetMonth $top last; Focus $top last"]

	for {set row 1} {$row < 7} {incr row} {
		set rowData {}

		for {set col 1} {$col < 8} {incr col} {
			set lbl [tk::label $top.calendar.$row:$col \
							-borderwidth 1 \
							-width 2 \
							-highlightthickness 1 \
							-relief flat \
							-anchor e \
							-takefocus 1 \
						]
			foreach key {	Up Down Left Right \
								Shift-Left Shift-Right Control-Left Control-Right \
								Home End \
								Control-Home Control-End \
								Escape} {
				bind $lbl <$key> [set cmd-$key]
			}
			lappend rowData $lbl
		}

		grid {*}$rowData -sticky ew -ipadx 1 -ipady 1
	}

	Update $top

	tooltip on $top*
	wm transient $top [winfo toplevel [winfo parent $parent]]
	util::place $top below $parent
	wm deiconify $top
	raise $top
	focus $top
	if {[tk windowingsystem] == "x11"} {
		tkwait visibility $top
		update
	}
	if {$useGrab} { ttk::globalGrab $top.calendar }
	focus -force $top.calendar.$Priv(widget:$Priv(day))
	vwait [namespace current]::Priv(d)
	if {$useGrab} { ttk::releaseGrab $top.calendar }
	destroy [winfo toplevel $top]
	tooltip on
	update idletasks

	if {$Priv(d) eq "none"} { return {} }
	return [list $Priv(y) $Priv(m) $Priv(d)]
}


proc mc {tok} { return [tk::msgcat::mc [set $tok]] }


proc daysInMonth {month year} {
	variable Days

	set day [clock format [clock add [clock scan 28/02/${year} -format "%d/%m/%Y"] 1 day] -format %d]
	set month [Normalize $month]
	if {$month == 2 && $day == 29} { return 29 }
	return $Days($month)
}


proc nameOfDays {weekStart} {
	set weekend [expr {$weekStart + 6}]
	set daynames {}

	for {set day [expr {$weekStart - 1}]} {$day < $weekend} {incr day} {
		set name [string range [clock format [clock add 1220223600 $day day] -format %a] 0 1]
		lappend daynames [Tr $name]
	}

	return $daynames
}


proc validDate? {y m d} {
	set d [Normalize $d]
	set m [Normalize $m]
	if {1 > $m || $m > 12} { return 0 }
	set daysInMonth [daysInMonth $m $y]
	if {1 > $d || $d > $daysInMonth} { return 0 }
	return 1
}


proc compare {lhs rhs} {
	lassign {0 0 0 0 0 0} y1 m1 d1 y2 m2 d2
	scan $lhs "%d.%d.%d" y1 m1 d1
	scan $rhs "%d.%d.%d" y2 m2 d2

	if {$y1 == 0} {
		if {$y2 == 0} { return 0 }
		return {}
	}
	if {$y2 == 0} {
		if {$y1 == 0} { return 0 }
		return {}
	}
	if {$y1 < $y2} { return -1 }
	if {$y2 < $y1} { return +1 }
	if {$m1 == 0} {
		if {$m2 == 0} { return 0 }
		return {}
	}
	if {$m2 == 0} {
		if {$m1 == 0} { return 0 }
		return {}
	}
	if {$m1 < $m2} { return -1 }
	if {$m2 < $m1} { return +1 }
	if {$d1 == 0} {
		if {$d2 == 0} { return 0 }
		return {}
	}
	if {$d2 == 0} {
		if {$d1 == 0} { return 0 }
		return {}
	}
	if {$d1 < $d2} { return -1 }
	if {$d2 < $d1} { return +1 }
	return 0
}


proc today {} {
	lassign [clock format [clock seconds] -format "%d %m %Y"] d m y
	return [list $y [Normalize $m] [Normalize $d]]
}


proc tooltip {args} {}


proc Tr {tok} { return [mc mc::${tok}] }


proc Normalize {m} {
	if {[string index $m 0] eq "0"} { return [string index $m 1] }
	return $m
}


proc SetMonth {top incr} {
	variable Priv

	switch -- $incr {
		first		{ set month 1 }
		last		{ set month 12 }
		default	{ set month [expr {$Priv(m) + $incr}] }
	}

	if {$month == 0} {
		if {$Priv(y) == $Priv(minYear)} { return }
		set month 12
		incr Priv(y) -1
	} elseif {$month == 13} {
		if {$Priv(y) == $Priv(maxYear)} { return }
		set month 1
		incr Priv(y)
	}

	set Priv(m) $month
	tooltip $top.calendar.header.month [Tr MonthName($Priv(m))]
	set Priv(daysInMonth) [daysInMonth $Priv(m) $Priv(y)]
	set Priv(day) [min $Priv(day) $Priv(daysInMonth)]

	Update $top
	focus $top.calendar.$Priv(widget:$Priv(day))
}


proc SetYear {top incr} {
	variable Priv

	set year [expr {$Priv(y) + $incr}]
	if {$year < $Priv(minYear) || $Priv(maxYear) < $year} { return }
	set Priv(y) $year
	set Priv(daysInMonth) [daysInMonth $Priv(m) $Priv(y)]
	set Priv(day) [min $Priv(day) $Priv(daysInMonth)]
	Update $top
	focus $top.calendar.$Priv(widget:$Priv(day))
}


proc Focus {top incr} {
	variable Priv

	switch -- $incr {
		first		{ set day 1 }
		last		{ set day $Priv(daysInMonth) }
		default	{ set day [expr {$Priv(day) + $incr}] }
	}

	if {$day <= 0} {
		if {$Priv(m) == 1} {
			if {$Priv(y) == $Priv(minYear)} { return }
			incr Priv(y) -1
			set Priv(m) 12
		} else {
			incr Priv(m) -1
		}

		tooltip $top.calendar.header.month [Tr MonthName($Priv(m))]
		set Priv(daysInMonth) [daysInMonth $Priv(m) $Priv(y)]
		set Priv(day) [expr {$Priv(daysInMonth) + $day}]
	} elseif {$day > $Priv(daysInMonth)} {
		if {$Priv(m) == 12} {
			if {$Priv(y) == $Priv(maxYear)} { return }
			incr Priv(y)
			set Priv(m) 1
		} else {
			incr Priv(m)
		}

		tooltip $top.calendar.header.month [Tr MonthName($Priv(m))]
		set Priv(day) [expr {$day - $Priv(daysInMonth)}]
		set Priv(daysInMonth) [daysInMonth $Priv(m) $Priv(y)]
	} else {
		set Priv(day) $day
	}

	Update $top
	focus $top.calendar.$Priv(widget:$Priv(day))
}


proc Update {top} {
	variable Priv
	variable colors

	set monthStart [clock scan 01/$Priv(m)/$Priv(y) -format %d/%m/%Y]
	lassign [clock format $monthStart -format "%b %u"] monthName startDay

	$top.calendar.header.month configure -text [Tr $monthName]
	$top.calendar.header.year configure -text $Priv(y)
	ConfigureButtons $top

	set day [expr {($startDay - $Priv(weekStart) + 6) % 7}]
	set day [expr {$day == 6 ? 1 : -$day}]
	set Priv(current) {}

	for {set row 1} {$row < 7} {incr row} {
		for {set col 1} {$col < 8} {incr col} {
			set lbl $top.calendar.$row:$col
			set Priv(widget:$day) $row:$col

			if {1 <= $day && $day <= $Priv(daysInMonth)} {
				if {$lbl eq $Priv(active)} { set which active } else { set which label }
				$lbl configure \
					-text $day \
					-background $colors($which:background) \
					-foreground $colors($which:foreground) \
					;
				set cmd [namespace code [list set Priv(d) $day]]
				foreach key {ButtonRelease-1 space Return} {
					bind $lbl <$key> $cmd
				}
				foreach {key state} {Leave off Enter on} {
					bind $lbl <$key> [namespace code [list Hilite $lbl $state]]
				}
				if {$Priv(y) == $Priv(y:start) && $Priv(m) == $Priv(m:start) && $day == $Priv(d:start)} {
					if {$lbl ne $Priv(active)} {
						$lbl configure -foreground $colors(hilite:foreground)
					}
					set Priv(current) $lbl
				}
			} else {
				$lbl configure -text "" -background $Priv(background)
				foreach key {ButtonRelease-1 Leave Enter space Return} {
					bind $lbl <$key> {}
				}
			}

			incr day
		}
	}
}


proc ConfigureButtons {top} {
	variable Priv

	if {$Priv(y) == $Priv(minYear)} {
		$top.calendar.header.left.year configure -state disabled
	} else {
		$top.calendar.header.left.year configure -state normal
	}
	if {$Priv(y) == $Priv(maxYear)} {
		$top.calendar.header.right.year configure -state disabled
	} else {
		$top.calendar.header.right.year configure -state normal
	}
	if {$Priv(y) == $Priv(minYear) && $Priv(m) == 1} {
		$top.calendar.header.left.month configure -state disabled
	} else {
		$top.calendar.header.left.month configure -state normal
	}
	if {$Priv(y) == $Priv(maxYear) && $Priv(m) == 12} {
		$top.calendar.header.right.month configure -state disabled
	} else {
		$top.calendar.header.right.month configure -state normal
	}
}


proc Hilite {lbl state} {
	variable Priv
	variable colors

	switch $state {
		on {
			set background $colors(active:background)
			set foreground $colors(active:foreground)
			set Priv(active) $lbl
		}

		off {
			if {$Priv(current) eq $lbl} {
				set foreground $colors(hilite:foreground)
			} else {
				set foreground $colors(label:foreground)
			}
			set background $colors(label:background)
			set Priv(active) {}
		}
	}

	$lbl configure -background $background -foreground $foreground
}


proc ClearTooltips {menu w} {
	if {$menu eq $w} {
		tooltip clear $w.*
	}
}


proc Exit {} {
	set [namespace current]::Priv(d) none
}


proc Unpost {menu x y} {
    set w [winfo containing $x $y]
	 if {![string match $menu.* $w]} { Exit }
}


proc ButtonEnter {w} {
	set ptrw [winfo containing {*}[winfo pointerxy .]]
	if {$ptrw eq $w} { ::tk::ButtonEnter $w }
}


namespace eval icon {
namespace eval 12x10 {

set PrevYear [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAQAAAAqJXdxAAAAAmJLR0QA/4ePzL8AAAEFSURB
	VAgdAfoABf8AAAAPAAAFJEckeCZ8MzUBChtWH3sqezoxACMAMgAnPSbZIP8l3zNBGlMf5SD/
	LNM/OABgAF4qOcse/yLzF2I7OyrYHP8a4xlNAAEApCRfwCX/Iv9ApSAjM7Yh/yT9H3wABAsA
	AFSUMP8e/yrBLCglfBv0Iv8wtS4aQAAHAAAvhST/IP8ppU8iT8Eg/yX/L5kACA0AAAAAWS08
	xyD/G+oWYDw7LNQe/xzlGlKwABkAADgAMDgj1x3/Id4nQh9QHOYc/yfVMzc0AAAIAAAAFVoZ
	5xv/MtJKNSN7JP4d/z/GZSoAJQAXABkOGGsalSiWPzs7HiqGGpYulkk5+L1O9ctSLDcAAAAA
	SUVORK5CYII=
}]

set NextYear [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAQAAAAqJXdxAAAAAmJLR0QA/4ePzL8AAAEFSURB
	VAgdAfoABf8AOjEqex97G1YBCjM1JnwkeCRHAAUPAAAAAD84LNMg/x/lGlMzQSXfIP8m2Sc9
	MgAjAAAAARlNGuMc/yrYOzsXYiLzHv85y14qYAAACwAABB98JP0h/zO2ICNApSL/Jf9fwKQk
	AAcAQAAuGjC1Iv8b9CV8LCgqwR7/MP9UlAAAAA0AAAgvmSX/IP9PwU8iKaUg/yT/L4UAGQCw
	ABpSHOUe/yzUPDsWYBvqIP88x1ktADQAMzcn1Rz/HOYfUCdCId4d/yPXMDg4AABlKj/GHf8k
	/iN7SjUy0hv/GecVWgAACAAASTkulhqWKoY7Hj87KJYalRhrGQ4XACUAykFO9TOzMOoAAAAA
	SUVORK5CYII=
}]

set PrevMonth [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAQAAAAqJXdxAAAAAmJLR0QA/4ePzL8AAACuSURB
	VAjXY2CAglkMIgwGRroLgtWNGX4wwMENBgEGE02RIxz/1bZUC+bDhOcwSDAYa4ocZfvP/Vt3
	UhtXIUQ4i0EKLqwzsZwnFqbemsFdUewY23/O/9pTm7gTEOb7MEQoygMlOP7LT/XmtkRIrGPQ
	YAjSlAMaxflbdqIPD5LUQQZNhkCwFMdv+Un5XHEIqW8MSiBdR7j+629pF6xiQAJ/GWQZfI0c
	FuSp+zL8B/IBIloy4ydujn8AAAAASUVORK5CYII=
}]

set NextMonth [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAQAAAAqJXdxAAAAAmJLR0QA/4ePzL8AAACpSURB
	VAjXY2BguM3AwBDr7Dm7SiqDAQXEM+TqKF/l+W+ytF00k+E/QiKPoVZT7yLbf+5/JsvaRLMR
	Um8ZZBhqjfUusIOl2oFScPCJQZqh3kj7EitIaukEvjqYxH8Gd4YUabX9bP/Z/8ktzeNLhAnb
	McTKKG/mAApLLrMXNYKpD2FIllLeAhM2QFjuzxCjIXOF47/kUkdRXYbHCKuPAbGbs/ZsCyl9
	JN8BAESuN0MpiEZWAAAAAElFTkSuQmCC
}]

} ;# namespace 12x10
} ;# namespace icon
} ;# namespace calendar

# vi:set ts=3 sw=3:
