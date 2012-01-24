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

if {$argc != 1} {
	puts stderr "Usage: [info script] <contents-file>"
	exit 1
}

set contentsFile [lindex $argv 0]
if {![file readable $contentsFile]} {
	puts stderr "Error([info script]): '$contentsFile' is not readable"
	exit 1
}

encoding system utf-8
set lang [file tail [pwd]] 
set file [file join .. .. lang localization.tcl]
source $file

foreach entry $i18n::languages {
	lassign $entry _ codeName charset langFile
	if {$codeName eq $lang} { break }
}

if {$codeName ne $lang} {
	puts stderr "Error([info script]):"
	puts stderr "Language \"$lang\" not defined in file \"$file\"."
	puts stderr "You have to edit \"$file\"."
	exit 1
}

set translationFile [file join .. .. lang $langFile]
if {![file readable $translationFile]} {
	puts stderr "Error([info script]): Cannot open file \"$translationFile\"."
	exit 1
}
set f [open $translationFile r]
chan configure $f -encoding $charset
while {[gets $f line] >= 0} {
	if {[string length $line] > 0 && [string index $line 0] ne "#"} {
		if {[string match ::help::mc::Overview* $line]} {
			set var [lindex $line 0]
			set value [string map {& {} "..." {}} [lindex $line 1]]
			set ns [join [lrange [split $var ::] 1 end-2] ::]
			if {[llength $ns]} { namespace eval $ns {} }
			set title $value
		}
	}
}
close $f

if {![info exists title]} {
	puts stderr "Error([info script]): \
		missing entry '::help::mc::Overview' in language file '$translationFile'"
	exit 1
}

set file "[file rootname $contentsFile].html"
set src [open $contentsFile r]
chan configure $src -encoding $charset
set close 0

puts "set Contents \{"
puts "  \{"
puts "     {{{$title} {$file}}}"

while {[gets $src line] >= 0} {
	if {[regexp {<h[1-6] name=\"(.*)\">(.*)</h[1-6]>} $line _ href section]} {
		puts "  \}"
		puts "  \{"
		puts "    {{{$section} {$file} {$href}}}"
	} elseif {[regexp {<a href=\"(.*)\">(.*)</a>} $line _ href title]} {
		puts "    {{{$title} {$href}}}"
	}
}

puts "  \}"
puts "\}"
puts "\nset UnixOnly \{\n  How-To-Set-Default-Browser.html\n\}"
close $src

# vi:set ts=3 sw=3:
