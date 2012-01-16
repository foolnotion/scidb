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
# Copyright: (C) 2011-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package provide entrybuttonbox 1.0

namespace eval ttk {

proc entrybuttonbox {w args} {
	return [entrybuttonbox::Build $w {*}$args]
}

namespace eval entrybuttonbox {

proc Build {w args} {
	namespace eval [namespace current]::${w} {}
	variable ${w}::Vars

	array set opts { -state readonly }
	array set opts $args

	foreach option [array names opts] {
		switch -- $option {
			-invalidcommand   -
			-postcommand      -
			-readonly         -
			-show             -
			-validate         -
			-validatecommand  -
			-values           -
			-xscrollincrement {
				error "invalid option \"$option\""
			}

			-command {
				set Vars($option) $opts($option)
				array unset opts $option
			}

			-state {
				if {$opts($option) eq "disabled"} {
					set opts($option) disabled
				}
			}
		}
	}

	ttk::combobox $w -class TEntryButtonBox {*}[array get opts]
	bind $w <<ComboboxSelected>> [namespace code [list ComboboxSelected $w]]
	catch { rename ::$w $w.__w__ }
	proc ::$w {command args} "[namespace current]::WidgetProc $w \$command {*}\$args"

	return $w
}


proc WidgetProc {w command args} {
	switch -- $command {
		set {
			if {[llength $args] != 1} {
				error "wrong # args: should be \"[namespace current] set <value>\""
			}
			$w.__w__ delete 0 end
			return [$w.__w__ insert 0 [lindex $args 0]]
		}

		current - validate {
			error "invalid command \"$command\""
		}

		configure {
			if {[llength $args] % 2 == 1} {
				error "value for \"[lindex $args end]\" missing"
			}
			array set opts $args
			if {[info exists opts(-state)]} {
				if {$opts(-state) eq "normal"} { set opts(-state) readonly }
			}
			set args [array get opts]
		}

		instate {
			if {[llength $args] != 1 && [llength $args] != 2} {
				error "wrong # args: should be \"[namespace current] $command <statespec> ?<script>?\""
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

} ;# namespace entrybuttonbox
} ;# namespace ttk

ttk::copyBindings TEntry TEntryButtonBox

bind TEntryButtonBox <KeyPress-Down>	{ {*}[set ttk::entrybuttonbox::%W::Vars(-command)] }
bind TEntryButtonBox <<TraverseIn>>		{ ttk::combobox::TraverseIn %W  }

bind TEntryButtonBox <ButtonPress-1> {
	if {[%W cget -state] ne "disabled"} {
		{*}[set ttk::entrybuttonbox::%W::Vars(-command)]
	}
}

# vi:set ts=3 sw=3:
