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
# Copyright: (C) 2009-2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval progress {

proc start {path cmd args options {close 1}} {
	variable Priv

	set Priv(options) $options
	set Priv(close) $close

	return [eval $cmd [namespace current]::DoCmd $path $args]
}


proc close {path} {
	if {[winfo exists $path]} {
		::widget::unbusyCursor $path
		ttk::releaseGrab $path
		destroy $path
	}
}


proc DoCmd {cmd path {value 0}} {
	variable Priv

	switch $cmd {
		open {
			if {![winfo exists $path]} {
				lappend Priv(options) -variable [namespace current]::Priv(value)
				lappend Priv(options) -maximum $value
				::dialog::progressbar::open $path {*}$Priv(options) -close no
				ttk::grabWindow $path
				::widget::busyCursor $path
				::log::delay
			}
		}

		close {
			if {$Priv(close)} {
				close $path
			}
		}

		start {
			set Priv(value) 0
			::dialog::progressbar::setMaximum $path $value
			update
		}

		update {
			set Priv(value) $value
			update
		}

		finish {
			set Priv(value) $value
			update
		}

		ticks {
			return $::dialog::progressbar::ticks
		}

		interrupted? {
			return [::dialog::progressbar::interrupted? $path]
		}
	}
}

} ;# namespace progress

# vi:set ts=3 sw=3:
