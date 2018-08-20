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
# Copyright: (C) 2010-2018 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source entry-box

proc entrybox {w args} {
	return [::entrybox::Build $w {*}$args]
}

namespace eval entrybox {

proc Build {w args} {
	array set opts $args
	set skipSpace 0
	if {[info exists opts(-skipspace)]} {
		set skipSpace 1
		array unset opts -skipspace
	}
	if {![info exists opts(-exportselection)]} {
		set opts(-exportselection) no
	}
	ttk::entry $w {*}[array get opts]
	if {$skipSpace} {
		bind $w <Key-space> [list after idle [namespace code { SkipSpace %W }]]
	}
	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"
	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		bind {
			if {1 > [llength $args] || [llength $args] > 3} {
				error "wrong # args: should be \"[namespace curent] bind <tag> ?<sequence>? ?<script?>\""
			}
			return [bind $w {*}$args]
		}

		value {
			return [string trim [$w.__w__ get {*}$args]]
		}

		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			$w.__w__ delete 0 end
			$w.__w__ insert 0 [lindex $args 0]
			return $w
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace curent] $command <statespec> ?<script>?\""
			}
			if {[llength $args] == 2} {
				if {[$w.__w__ instate [lindex $args 0]]} {
					return [uplevel 2 [lindex $args 1]]
				}
			}
		}

		focus {
			return [focus $w]
		}
	}

	return [$w.__w__ $command {*}$args]
}


proc SkipSpace {w} {
	if {[$w get] == " " || [string length [$w get]] == 0} {
		$w delete 0 end
		tk::TabToWindow [tk_focusNext $w]
	}
}

} ;# namespace entrybox

# vi:set ts=3 sw=3:
