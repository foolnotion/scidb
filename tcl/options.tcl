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
# Copyright: (C) 2009-2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

::util::source options

namespace eval options {

namespace import ::tcl::mathfunc::max

array set Callbacks {}


proc hookWriter {callback {file options}} {
	variable Callbacks

	if {![info exists Callbacks($file)]} {
		set i -1
	} else {
		set i [lsearch -exact $Callbacks($file) $callback]
	}
	if {$i == -1} { lappend Callbacks($file) $callback }
}


proc unhookWriter {callback {file options}} {
	variable Callbacks

	if {[info exists Callbacks($file)]} {
		set i [lsearch -exact $Callbacks($file) $callback]
		if {$i >= 0} { set Callbacks($file) [lreplace $Callbacks($file) $i $i] }
	}
}


proc writeHeader {chan file} {
	puts $chan "# Scidb $file file"
	puts $chan "# Version: $::scidb::version"
	puts $chan "# Syntax: Tcl language format"
	puts $chan ""
}


proc write {} {
	variable Callbacks

	foreach file [array names Callbacks] {
		if {$file eq "options" || [llength $Callbacks($file)] > 0} {
			set filename [set ::scidb::file::$file]
			set chan [open $filename.tmp w]
			fconfigure $chan -encoding utf-8
			writeHeader $chan $file

			foreach callback $Callbacks($file) { $callback $chan }

			if {$file eq "options"} {
				foreach dialog [::toolbar::toolbarDialogs] {
					puts $chan "::toolbar::setOptions $dialog {"
					::options::writeArray $chan [::toolbar::getOptions $dialog]
					puts $chan "}"
				}
			}

			close $chan
			file rename -force $filename.tmp $filename
		}
	}
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
		set length [string length $key]
		if {[llength $key] > 1} { incr length 2 }
		set maxlength [max $maxlength $length]
	}
	set lst {}
	foreach {key val} $arr { lappend lst [list $key $val] }
	foreach elem [lsort -index 0 $lst] {
		lassign $elem key val
		if {!$lowercaseOnly || ![string is upper [string index $key 0]]} {
			if {[llength $key] > 1} { set key [list $key] }
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
