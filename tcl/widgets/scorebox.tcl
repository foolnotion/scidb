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
# Copyright: (C) 2010-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source score-input-box

proc scorebox {w args} {
	return [::scorebox::Build $w {*}$args]
}

namespace eval scorebox {

namespace import ::tcl::mathfunc::max

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Type ""
	variable ${w}::Score 0

	array set opts {
		-textvar {}
		-textvariable {}
		-width 0
	}
	array set opts $args

	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) $opts(-textvar)
	}
	if {[llength $opts(-textvariable)] == 0} {
		set opts(-textvariable) [namespace current]::${w}::Score
	}

	ttk::frame $w -borderwidth 0 -takefocus 0
	bind $w <FocusIn> { focus [tk_focusNext %W] }
	::ttk::spinbox $w.__w__ \
		-from 0 \
		-to 4000 \
		-width 5 \
		-exportselection false \
		-justify right \
		-textvariable $opts(-textvariable) \
		-command [namespace code [list Focus $w.__w__]] \
		;
	::validate::spinboxInt $w.__w__
	::theme::configureSpinbox $w.__w__
	pack $w.__w__ -side left

	bind $w <Destroy> [list catch [list namespace delete [namespace current]::${w}]]

	catch { rename ::$w $w.__scorebox__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		cget {
			if {[lindex $args 0] eq "-takefocus"} {
				return 0
			}
		}

		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"scorebox bind <tag> ?<sequence>? ?<script?>\""
			}
			bind $w.__w__ {*}$args
			return
		}

		value {
			set score [$w.__w__ get]
			if {[llength $score] == 0 || $score == 0} { return "" }
			return $score
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			set [$w.__w__ cget -textvariable] [lindex $args 0]
			return $w
		}

		focus {
			return [focus $w.__w__]
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"scorebox $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__w__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc Focus {w} {
	if {[focus] ne $w} {
		focus $w
		update idletasks
		$w selection clear
	}
}

} ;# namespace scorebox

# vi:set ts=3 sw=3:
