#!/bin/sh
#\
exec tclsh "$0" "$@"
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
# Copyright: (C) 2012 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tcl 8.5


proc getArg {line} {
	set n 0
	while {$n < [string length $line] && ![string is space [string index $line $n]]} { incr n }
	while {$n < [string length $line] && [string is space [string index $line $n]]} { incr n }
	return [string range $line $n end]
}


set lang [file tail [pwd]] 
set file [file join .. .. lang localization.tcl]
source $file

foreach entry $i18n::languages {
	lassign $entry _ codeName charset _
	if {$codeName eq $lang} { break }
}

if {$codeName ne $lang} {
	puts stderr "Error([info script]):"
	puts stderr "Language \"$lang\" not defined in file \"$file\"."
	puts stderr "You have to edit \"$file\"."
	exit 1
}


array set index {}

foreach file [glob *.txt] {
	set src [open $file r]
	chan configure $src -encoding $charset
	while {[gets $src line] >= 0} {
		if {[string match CHARSET* $line]} {
			set charset [getArg $line]
			chan configure $src -encoding $charset
		}
		if {[string match INDEX* $line]} {
			set item [getArg $line]
			set alph [string toupper [string index $item 0]]
			set path [file rootname $file]
			append path .html
			lappend index($alph) [list $item $path]
		}
	}
	close $src
}


set alphabet [lsort -dictionary [array names index]]

puts "set Index \{"
foreach alph $alphabet {
	puts "  \{ $alph"
	puts "    \{"
	foreach entry [lsort -index 0 -dictionary $index($alph)] {
		puts "      {{[lindex $entry 0]} {[lindex $entry 1]}}"
	}
	puts "    \}"
	puts "  \}"
}
puts "\}"

# vi:set ts=3 sw=3:
