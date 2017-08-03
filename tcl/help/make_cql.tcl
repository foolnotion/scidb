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
# Copyright: (C) 2013 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tcl 8.5


encoding system utf-8
set lang [file tail [pwd]] 
array set index {}

foreach type {match position relation} {
	set file "CQL-[string toupper $type 0 0]-List.txt"
	if {[file readable $file]} {
		set htmlfile "CQL-[string toupper $type 0 0]-List.html"
		set src [open $file r]
		chan configure $src -encoding utf-8
		set re "<h3 id=\"$type:(\[a-z0-9\]*_?)\""
		while {[gets $src line] >= 0} {
			if {[regexp $re $line _ keyword]} {
				set alph [string toupper [string index $keyword 0]]
				set key [string map {_ *} $keyword]
				lappend index($alph) [list "$key : $type" $htmlfile "$type:$keyword"]
			}
		}
		close $src
	}
}

set alphabet [lsort -dictionary [array names index]]

puts "set Index \{"
foreach alph $alphabet {
	puts "  \{ $alph"
	puts "    \{"
	foreach entry [lsort -index 0 -dictionary $index($alph)] {
		lassign $entry wref path fragment
		puts "      {{$wref} {$path} {$fragment}}"
	}
	puts "    \}"
	puts "  \}"
}
puts "\}"

# vi:set ts=3 sw=3:
