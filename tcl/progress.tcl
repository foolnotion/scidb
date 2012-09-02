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

::util::source progress-dialog

namespace eval progress {
namespace eval mc {

set Progress "Progress"

set Message(preload-namebase)		"Pre-loading namebase data"
set Message(preload-tournament)	"Pre-loading tournament index"
set Message(preload-player)		"Pre-loading player index"
set Message(preload-annotator)	"Pre-loading annotator index"

set Message(read-index)				"Loading index data"
set Message(read-game)				"Loading game data"
set Message(read-namebase)			"Loading namebase data"
set Message(read-tournament)		"Loading tournament data"
set Message(read-player)			"Loading player data"
set Message(read-annotator)		"Loading annotator data"
set Message(read-source)			"Loading source data"
set Message(read-team)				"Loading team data"
set Message(read-init)				"Loading initialization data"

set Message(write-index)			"Writing index data"
set Message(write-game)				"Writing game data"
set Message(write-namebase)		"Writing namebase data"

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
			array set opts $Priv(options)
			if {[info exists opts(-information)]} {
				::dialog::progressbar::setInformation .progress $opts(-information)
			}
			update
		}

		message {
			if {[info exists mc::Message($value)]} { set msg $mc::Message($value) } else { set msg $value }
			::dialog::progressbar::setInformation .progress ${msg}...
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
