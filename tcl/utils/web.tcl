# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

namespace eval web {
namespace eval mc {
	set CannotFindBrowser			"Couldn't find a suitable web browser."
	set CannotFindBrowserDetail	"Set the BROWSER environment variable to your desired browser."
}

variable Browsers {google-chrome iceweasel firefox iexplorer opera konqueror epiphany galeon mosaic amaya browsex}
variable Excluded {}


proc open {parent url} {
	regsub -all " " $url "%20" url

	::widget::busyCursor on

	switch -- [tk windowingsystem] {
		"aqua" {
			catch {exec open $url &}
		}

		"win32" {
			if {$::tcl_platform(os) eq "Windows NT"} {
				catch {exec $::env(COMSPEC) /c start $url &}
			} else {
				catch {exec start $url &}
			}
		}

		"x11" {
			variable DefaultBrowser
			variable Excluded

			if {![info exists DefaultBrowser]} {
				set DefaultBrowser [FindDefaultBrowser]
			}
			while {[llength $DefaultBrowser]} {
				if {![catch {exec /bin/sh -c "$DefaultBrowser '$url'" &}]} { break }
				lappend Excluded $DefaultBrowser
				set DefaultBrowser [FindDefaultBrowser]
			}
			if {[llength $DefaultBrowser] == 0} {
				::dialog::error \
					-parent $parent \
					-message $mc::CannotFindBrowser \
					-detail $mc::CannotFindBrowserDetail \
					;
			}
		}
	}

	::widget::busyCursor off
}


proc FindDefaultBrowser {} {
	global env
	variable Browsers

	if {[info exists env(BROWSER)]} {
		foreach browser [split $env(BROWSER) :] {
			set browser [auto_execok $browser]
			if {![IsExcluded $browser] && [IsX11Browser $browser]} { return $browser }
		}
	}

	set browser [auto_execok x-www-browser]
	if {[llength $browser] && ![IsExcluded $browser]} { return $browser }

	set htmlviewrc [file join $::scidb::dir::home .htmlviewrc]
	if {[file readable $htmlviewrc]} {
		set chan [::open $htmlviewrc]

		while {[gets $chan line] >= 0} {
			if {[string range $line 0 9] eq "X11BROWSER"} {
				set browser [auto_execok [string trim [lindex [split $line =] 1]]]
				if {[llength $browser] && ![IsExcluded $browser]} { return $browser }
			}
		}

		close $chan
	}

	foreach browser $Browsers {
		set browser [auto_execok $browser]
		if {[llength $browser] && ![IsExcluded $browser]} { return $browser }
	}

	return ""
}


proc IsX11Browser {browser} {
	variable Browsers

	if {[llength $browser]} {
		foreach b $Browsers {
			if {[string match [list *$b*] $browser]} { return 1 }
		}
	}

	return 0
}


proc IsExcluded {browser} {
	variable Excluded

	return [expr {[lsearch $Excluded $browser] >= 0}]
}

} ;# namespace web

# vi:set ts=3 sw=3:
