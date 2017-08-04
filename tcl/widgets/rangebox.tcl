# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $HeadURL$
# ======================================================================

# ======================================================================
#    _/|            __
#   // o\         /    )           ,        /    /
#   || ._)    ----\---------__----------__-/----/__-
#   //__\          \      /   '  /    /   /    /   )
#   )___(     _(____/____(___ __/____(___/____(___/_
# ======================================================================

# ======================================================================
# Copyright: (C) 2014-2017 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source range-selection-box

proc rangebox {w args} {
	return [::rangebox::Build $w {*}$args]
}


namespace eval rangebox {
namespace eval mc {

set RangeOfYears "Range of years"

}

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set Vars { min 0 max 0 lock 0 }

	array set opts {
		-textvar			{}
		-textvariable	{}
		-from				0
		-to				4000
		-increment		1
		-width			5
		-justify			right
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Vars(textvar)
	}

	set Vars(textvar) $opts(-textvariable)
	set Vars(lock) 0

	set args {}
	if {$opts(-to) eq "unlimited"} {
		lappend args -unlimited 1
		set opts(-to) 9999999
	}

	ttk::frame $w -borderwidth 0
	set minvar [namespace current]::${w}::Vars(min)
	set maxvar [namespace current]::${w}::Vars(max)

	if {[llength [set $Vars(textvar)]]} {
		lassign [set $Vars(textvar)] Vars(min) Vars(max)
	}

	ttk::spinbox $w.min \
		-from $opts(-from) \
		-to $opts(-to) \
		-textvar $minvar \
		-width $opts(-width) \
		-justify $opts(-justify) \
		-command [namespace code [list UpdateRange $w]] \
		;
	::theme::configureSpinbox $w.min
	::validate::spinboxInt $w.min
	ttk::label $w.delim -text "\u2212"
	ttk::spinbox $w.max \
		-from $opts(-from) \
		-to $opts(-to) \
		-textvar $maxvar \
		-width $opts(-width) \
		-justify $opts(-justify) \
		-command [namespace code [list UpdateRange $w]] \
		;
	::theme::configureSpinbox $w.max
	::validate::spinboxInt $w.max {*}$args
	grid $w.min   -row 0 -column 0
	grid $w.delim -row 0 -column 1
	grid $w.max   -row 0 -column 2

	set args [list variable $minvar write [namespace code [list ContentChanged $w]]]
	trace add {*}$args
	bind $w <Destroy> +[list catch [list namespace delete [namespace current]::${w}]]

	set args [list variable $maxvar write [namespace code [list ContentChanged $w]]]
	trace add {*}$args
	bind $w <Destroy> +[list catch [list namespace delete [namespace current]::${w}]]

	bind $w <Destroy> +[list trace remove {*}$args]

	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		value {
			variable ${w}::Vars
			return [set $Vars(textvar)]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <range>\""
			}
			variable ${w}::Vars
			set value [lindex $args 0]
			if {[string length $value] == 0} {
				set Vars(min) 0
				set Vars(max) 0
			} else {
				lassign [split $value -] Vars(min) Vars(max)
			}
			UpdateRange $w
			return $w
		}

		cget {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] cget <option>\""
			}
			variable ${w}::Vars
			set arg [lindex $args 0]
			switch -- $arg {
				-from			{ return [$w.min cget -from] }
				-to			{ return [$w.min cget -to] }
				-increment	{ return [$w.min cget -increment] }
				-text			{ return $Vars(textvar) }

				-textvar {
					if {$Vars(textvar) eq "[namespace current]::${w}::Vars(textvar)"} { return "" }
					return $Vars(textvar)
				}
			}
		}

		configure {
			if {[llength $args] == 0} { return [$w.min configure] }
			foreach entry [$w.min configure] {
				set opt [lindex $entry 0]
				if {[info exists opts($opt)]} {
					$w.min configure $opt $opts($opt)
					$w.max configure $opt $opts($opt)
					array unset opts $opt
				}
			}
			set args [array get opts]
			if {[llength $args] == 0} { return "" }
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc UpdateRange {w} {
	variable ${w}::Vars

	set Vars(lock) 1
	set max $Vars(max)
	if {$max eq "\u221e"} { set max "unlimited" }
	set $Vars(textvar) [list $Vars(min) $max]
	set Vars(lock) 0
}


proc ContentChanged {w args} {
	variable ${w}::Vars

	if {$Vars(lock)} { return }

	set Vars(min) [$w.min get]
	set Vars(max) [$w.max get]
	set max $Vars(max)
	if {$max eq "\u221e"} { set max "unlimited" }
	set $Vars(textvar) [list $Vars(min) $max]
}

} ;# namespace rangebox

# vi:set ts=3 sw=3:
