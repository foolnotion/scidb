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

namespace eval options {

namespace import ::tcl::mathfunc::max

variable Callbacks {}


proc hookWriter {callback} {
	variable Callbacks
	lappend Callbacks $callback
}


proc write {} {
	variable Callbacks

	set chan [open $::scidb::file::options.tmp w]
	fconfigure $chan -encoding utf-8

	puts $chan "# Scidb options file"
	puts $chan "# Version: $::scidb::version"
	puts $chan "# Syntax: Tcl language format"
	puts $chan ""

	foreach callback $Callbacks { $callback $chan }

	foreach dialog [::toolbar::toolbarDialogs] {
		puts $chan "::toolbar::setOptions $dialog {"
		::options::writeArray $chan [::toolbar::getOptions $dialog]
		puts $chan "}"
	}

	close $chan
	file rename -force $::scidb::file::options.tmp $::scidb::file::options
}


proc writeItem {chan var {lowercaseOnly 1}} {
	if {[array exists $var]} {
		puts $chan "array set $var {"
		writeArray $chan [array get $var] $lowercaseOnly
		puts $chan "}"
	} else {
		switch [llength [set $var]] {
			0			{ puts $chan "set $var {}" }
			1			{ puts $chan "set $var [set $var]" }
			default	{ puts $chan "set $var {[set $var]}" }
		}
	}
}


proc writeList {chan var} {
	if {[llength [set $var]] == 0} {
		puts $chan "set $var {}"
	} else {
		puts $chan "set $var {[set $var]}"
	}
}


proc writeArray {chan arr {lowercaseOnly 1}} {
	set maxlength 0
	foreach {key val} $arr {
		set maxlength [max $maxlength [string length $key]]
	}
	set lst {}
	foreach {key val} $arr { lappend lst [list $key $val] }
	foreach elem [lsort -index 0 $lst] {
		lassign $elem key val
		if {!$lowercaseOnly || ![string is upper [string index $key 0]]} {
			set spaces [string repeat " " [expr {$maxlength - [string length $key] + 1}]]
			if {[llength $val] == 0} {
				puts $chan "  $key$spaces{}"
			} else {
				puts $chan "  $key$spaces{$val}"
			}
		}
	}
}

} ;# namespace options

# vi:set ts=3 sw=3:
