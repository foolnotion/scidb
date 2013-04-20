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
# Copyright: (C) 2012-2013 Gregor Cramer
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

proc readTranslationFile {file encoding} {
	set f [open $file r]
	chan configure $f -encoding $encoding

	while {[gets $f line] >= 0} {
		if {[string match *AsciiMapping* $line]} {
			set var [lindex $line 0]
			set value [string map {& {} "..." {}} [lindex $line 1]]
			set ns [join [lrange [split $var ::] 1 end-2] ::]
			if {[llength $ns]} { namespace eval $ns {} }
			set $var $value
		}
	}

	close $f
}

encoding system utf-8
set lang [file tail [pwd]] 
set localizationFile [file join .. .. lang localization.tcl]
source $localizationFile

foreach entry $i18n::languages {
	lassign $entry _ codeName charset translationFile
	if {$codeName eq $lang} { break }
}

if {$codeName ne $lang} {
	puts stderr "Error([info script]):"
	puts stderr "Language \"$lang\" not defined in file \"$file\"."
	puts stderr "You have to edit \"$file\"."
	exit 1
}

set transFile [file join .. .. lang $translationFile]
if {![file readable $transFile]} {
	puts stderr "Error([info script]): Cannot open file \"$transFile\"."
	exit 1
}
readTranslationFile $transFile $charset

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
			lassign [split $item #] wref fragment
			set alph [string map $::mc::AsciiMapping [string toupper [string index $wref 0]]]
			set path [file rootname $file]
			append path .html
			lappend index($alph) [list $wref $path $fragment]
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
		lassign $entry wref path fragment
		puts "      {{$wref} {$path} {$fragment}}"
	}
	puts "    \}"
	puts "  \}"
}
puts "\}"

# vi:set ts=3 sw=3:
