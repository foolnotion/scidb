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
# Copyright: (C) 2009-2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

namespace eval progress {
namespace eval mc {

set Progress "Progress"

} ;# namespace mc

proc start {parent cmd args options {close 1}} {
	variable Priv

	set Priv(options) $options
	set Priv(close) $close

	return [eval $cmd [namespace current]::DoCmd $parent $args]
}


proc close {} {
	if {[winfo exists .progress]} {
		::widget::unbusyCursor .progress
		ttk::releaseGrab .progress
		destroy .progress
	}
}


proc DoCmd {cmd parent {value 0}} {
	variable Priv

	switch $cmd {
		open {
			if {![winfo exists .progress]} {
				lappend Priv(options) -variable [namespace current]::Priv(value)
				lappend Priv(options) -maximum $value
				lappend Priv(options) -close no
				lappend Priv(options) -parent $parent
				lappend Priv(options) -title $mc::Progress
				::dialog::progressbar::open .progress {*}$Priv(options)
				focus -force .progress
				ttk::grabWindow .progress
				::widget::busyCursor .progress
				::log::delay
			}
		}

		close {
			if {$Priv(close)} {
				close
			}
		}

		start {
			set Priv(value) 0
			::dialog::progressbar::setMaximum .progress $value
			update
		}

		update - finish {
			set Priv(value) $value
			update
		}

		ticks {
			return $::dialog::progressbar::ticks
		}

		interrupted? {
			return [::dialog::progressbar::interrupted? .progress]
		}
	}
}

} ;# namespace progress

# vi:set ts=3 sw=3:
