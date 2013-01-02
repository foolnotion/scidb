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
# Copyright: (C) 2010-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source date-selection-box

proc datebox {w args} { return [datebox::Build $w {*}$args] }

namespace eval datebox {
namespace eval mc {

set Today		"Today"
set Calendar	"Calendar..."
set Year			"Year"
set Month		"Month"
set Day			"Day"

} ;# namespace mc


bind DateBoxFrame <Configure> [namespace code { Configure %W }]
bind DateBoxFrame <Destroy>	[list namespace delete [namespace current]::%W]
bind DateBoxFrame <Destroy>	[list rename %W {}]


proc validate {y m d {minYear 0} {maxYear 9999}} {
	set error ""
	set result ""

	if {[llength $y]} { append result $y } else { append result "????" }
	if {[llength $m]} { append result ".[Format $m]" } else { append result ".??" }
	if {[llength $d]} { append result ".[Format $d]" } else { append result ".??" }

	if {[llength $y]} {
		if {$y < $minYear || $maxYear < $y} {
			set error InvalidYear
		} elseif {[llength $m]} {
			if {$m < 1 || 12 < $m} {
				set error InvalidMonth
			} elseif {[llength $d] && $d < 1 || 31 < $d} {
				set error InvalidDay
			}
		} elseif {[llength $d]} {
			set error MissingMonth
		}
	} elseif {[llength $m] || [llength $d]} {
		set error MissingYear
	}

	if {[string length $error] == 0} {
		if {[string first "?" $result] == -1} {
			lassign [split $result .] y m d
			if {![::calendar::validDate? $y $m $d]} {
				set error InvalidDate
			}
		}
	}

	return [list $result $error]
}


proc Build {w args} {
	array set opts [list -minYear [::scidb::misc::minYear] -maxYear [::scidb::misc::maxYear]]
	set opts(-tooltip) [namespace current]::mc::Today
	set opts(-usetoday) 0
	array set opts $args

	ttk::frame $w -borderwidth 0 -takefocus 0 -class DateBoxFrame
	bind $w <FocusIn> { focus [tk_focusNext %W] }

	namespace eval [namespace current]::$w {}
	variable [namespace current]::${w}::Priv

	set Priv(minYear) $opts(-minYear)
	set Priv(maxYear) $opts(-maxYear)
	set Priv(today) [::calendar::today]
	set Priv(init) $Priv(today)
	set Priv(overhang1) {}
	set Priv(overhang2) {}

	ttk::entry $w.y \
		-exportselection no \
		-justify right \
		-width 5 \
		-textvariable [namespace current]::${w}::Priv(y) \
		-validate key \
		-validatecommand [namespace code [list ValidateYear $w %P]] \
		-invalidcommand { bell } \
		;
	ttk::label $w.dot1 \
		-text "." \
		-relief flat
		;
	ttk::entry $w.m \
		-exportselection no \
		-justify right \
		-width 3 \
		-textvariable [namespace current]::${w}::Priv(m) \
		-validate key \
		-validatecommand [namespace code [list ValidateMonth $w %P]] \
		-invalidcommand { bell } \
		-cursor xterm \
		;
	ttk::label $w.dot2 \
		-text "." \
		-relief flat \
		;
	ttk::entry $w.d \
		-exportselection no \
		-justify right \
		-width 3 \
		-textvariable [namespace current]::${w}::Priv(d) \
		-validate key \
		-validatecommand [namespace code [list ValidateDay $w %P]] \
		-invalidcommand { bell } \
		-cursor xterm \
		;
	ttk::button $w.cal \
		-style icon.TButton \
		-image $icon::16x16::calendar \
		-command [namespace code [list Choose $w.cal]] \
		;
	if {$opts(-usetoday)} {
		ttk::button $w.today \
			-style icon.TButton \
			-image $icon::16x16::today \
			-command [namespace code [list Today $w.today]] \
			;
	}
	
	grid $w.y		-row 0 -column 0
	grid $w.dot1	-row 0 -column 1
	grid $w.m		-row 0 -column 2
	grid $w.dot2	-row 0 -column 3
	grid $w.d		-row 0 -column 4
	grid $w.cal		-row 0 -column 6 -sticky ns

	if {$opts(-usetoday)} {
		grid $w.today -row 0 -column 8 -sticky ns
		::tooltip::tooltip $w.today $opts(-tooltip)
	}

	grid columnconfigure $w 5 -minsize 5
	grid columnconfigure $w 7 -minsize 3

	::tooltip::tooltip $w.y		[namespace current]::mc::Year
	::tooltip::tooltip $w.m		[namespace current]::mc::Month
	::tooltip::tooltip $w.d		[namespace current]::mc::Day
	::tooltip::tooltip $w.cal	[namespace current]::mc::Calendar

	rename ::$w $w.__w__
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		overhang1	{ return [set [namespace current]::${w}::Priv(overhang1)] }
		overhang2	{ return [set [namespace current]::${w}::Priv(overhang2)] }
		date			{ return [CheckDate $w] }
		get			{ return [lindex [CheckDate $w] 0] }
		focus			{ return [focus $w.y] }
		result		{ return [Result $w] }
		valid?		{ return [expr {[string length [lindex [CheckDate $w] 1]] == 0}] }

		value	 {
			lassign [CheckDate $w] result error
			if {[string length $error] > 0} { return "????.??.??" }
			return $result
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"datebox bind <tag> ?<sequence>? ?<script?>\""
			}
			foreach attr {y m d} {
				bind $w.$attr {*}$args
			}
			return
		}

		today {
			variable ${w}::Priv
			if {[llength $args] == 0} {
				return $Priv(today)
			}
			set Priv(today) [lindex $args 0]
			if {[llength $Priv(today)] == 0} {
				set Priv(today) $Priv(init)
			}
			return $w
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"databox set YYYY.MM.DD\""
			}
			lassign {0 0 0} y m d
			scan $args "%d.%d.%d" y m d
			SetDate $w [list $y $m $d]
			return $w
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] cget <option>\""
			}
			if {[lindex $args 0] eq "-state"} { return "normal" }
		}

		icursor - selection { return }
	}

	return [$w.__w__ $command {*}$args]
}


proc Configure {w} {
	variable ${w}::Priv

	if {[winfo height $w] > 1} {
		set Priv(overhang1) [winfo y $w.d]
		set Priv(overhang2) [expr {[winfo height $w] - [winfo height $w.d] - [winfo y $w.d]}]
	}
}


proc Result {w} {
	set y [string trim [string trim [$w.y get]] ?]
	set m [Normalize [string trim [string trim [$w.m get]] ?]]
	set d [Normalize [string trim [string trim [$w.d get]] ?]]

	return [list $y $m $d]
}


proc CheckDate {w} {
	variable ${w}::Priv

	return [validate {*}[Result $w] $Priv(minYear) $Priv(maxYear)]
}


proc Choose {w} {
	variable [winfo parent $w]::Priv

	set date [::calendar::popup $w -minYear $Priv(minYear) -maxYear $Priv(maxYear) -weekStart 1]

	if {[llength $date] == 3} {
		SetDate [winfo parent $w] $date
	}
}


proc Today {w} {
	SetDate [winfo parent $w] [set [namespace current]::[winfo parent $w]::Priv(today)]
}


proc SetDate {w date} {
	variable ${w}::Priv

	lassign $date y m d
	set Priv(y) [Format $y]
	set Priv(m) [Format $m]
	set Priv(d) [Format $d]
	event generate $w <<DateChanged>> -when mark
}


proc Format {value} {
	if {[string length $value] == 0 || $value eq "0"} {
		return ""
	}
	if {[string length $value] == 1} {
		return "0$value"
	}
	return $value
}


proc Normalize {v} {
	if {[string length $v] == 2 && [string index $v 0] == "0"} { return [string index $v 1] }
	return $v
}


proc ValidateYear {w value} {
	event generate $w <<DateChanged>> -when tail
	set value [string trim $value]
	if {[string length $value] > 4} { return 0 }
	if {[string length $value] == 0} { return 1 }
	if {![regexp {[1-2?][0-9?]*} $value result]} { return 0 }
	if {[string length [string trim $value ?]] == 0} { return 1 }
	if {[string first ? $value] >= 0} { return 0 }
	if {[string length $value] != [string length $result]} { return 0 }
	return 1
}


proc ValidateMonth {w value} {
	event generate $w <<DateChanged>> -when tail
	set value [string trim $value]
	if {[string length $value] > 2} { return 0 }
	if {![regexp {[0-9?]*} $value result]} { return 0 }
	if {[string trim $value ?] == 0} { return 1 }
	if {[string length [string trim $value ?]] == 0} { return 1 }
	if {[string length $value] != [string length $result]} { return 0 }
	if {$value > 12} { return 0 }
	return 1
}


proc ValidateDay {w value} {
	event generate $w <<DateChanged>> -when tail
	set value [string trim $value]
	if {[string length $value] > 2} { return 0 }
	if {![regexp {[0-9?]*} $value result]} { return 0 }
	if {[string length [string trim $value ?]] == 0} { return 1 }
	if {[string first ? $value] >= 0} { return 0 }
	if {[string length $value] != [string length $result]} { return 0 }
	if {$value > 31} { return 0 }
	return 1
}


namespace eval icon {
namespace eval 16x16 {

set calendar [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABt0lEQVQ4y52Sv2siYRCGnw2L
	HLERr8l2VmlEsFtS2KcXESwFEa7TSggRa4szjdYWioUWgr1/g71NQK3sjCHsfj/mCvc2Bjkh
	N83MO7zzMN/wOQDPvi9iDABiLSIC1p7qSIsxn9oYBPj9+uq47YcH+fX0BCLw12gMovXnkNZY
	rSHKojViLby8iGuVAhEOqxVWqZM5yqIUVilsGGLD8KSj+mehgNGam9Pe8q1hUQoxBkRw4zdd
	Gw7D0+rGIEphPj7Qb2+E7++48viI+D72/h4RwUZHs9Z+qbXWhGFIEAQopfhxd0ew3+NmMhk8
	z8PzPL4buVwuukEU4/EYz/NIp9OMRiMA9vs9iUQCx3FwHOcCciMiseh0Osznc5bLJY1GI4ZW
	KpXTXzjzxoBzsV6v8X2f29vbuDccDplMJqRSKRaLxXUAwPF4pFKp0Gq1AFitVgRBwGw2o9ls
	XgBcpVQstNaUSiXq9Tq1Wu2LsVAosNlsrgO63S7VapVSqRT3stks/X6fw+FAPp+/BJyLwWDA
	breLtYjQbrcpFoskk0mm0+l1wHa7vTCUy2XK5fI//4ID0Ov1hP+IRqPh/AHTGlxIavrgkQAA
	AABJRU5ErkJggg==
}]

set today [image create photo -data {
	iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABMlBMVEUAAACZAACvEAC/EAC/
	EwDGFgDPIADSHQDZIADvMAD/MwCZAACfBQC/FQDKGQDPGwDSHQDZIADaIAD6MAD/MwCaAQC6
	EQDEFQDNGwDXHwDgJAD/MwCaAQDEFQDNGwDXHwDgJAD/MwCfAwChBAChBQCjBQCnFBCoCACs
	CgCuCgCyDAC0DgC3DwC7EQC9ODC+EwDHV1DNJxDQHADUXlDWRTDZLRHbIQDbIgDhJADjJwLk
	KQTlJgDmJwDmZlDnQSLpKADrSyvsLQTtKgDuKwDuVDbwUjDxOQ7xXkDyLQDzTSnzbVD0LQD2
	VjP4LwD4Y0H5MAD9MgD+fV//MwD/NAH/OAX/OQj/PQr/Pg7/QxH/RBX/RBb/Sx//TBv/USX/
	Vy7/iW7/jXD/kHb/ln//m4b/oo7/qZa5XpcHAAAAInRSTlMAEBAQEBAQEBAQEDAwMDAwMDAw
	MDDPz8/Pz8/P7+/v7+/vELj6+gAAANtJREFUGNMtzsV2wgAARNFBirvT4hYguBQL7g7B3f//
	F0gCs7tnNg8AZH+zca9ZLbm04GZwz1/Px/126To1X1+X02GDKkxaDtXHOz376LKjml0IztIB
	lS+L1Ml+xYTZa6mXtjvHbTEjUMbPEYyfUwwYrxe5NMhTGL3HEBRrmo4idAiieW8gz5kmQewJ
	VG8UykXWqQR8Gz9Kl4JOlMkxjvEV3pUHv91JVi1IR8kEXxGo/9sgsbZGSSUbxlkOiC21fpwM
	ET7vx8CPuXI+Hfab1deA0BQJBwm/x8hj8AZLti6NPtss/wAAAABJRU5ErkJggg==
}]

} ;# namespace 16x16
} ;# namespace icon
} ;# namespace datebox

# vi:set ts=3 sw=3:
