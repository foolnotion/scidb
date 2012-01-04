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
# Copyright: (C) 2011 Gregor Cramer
# ======================================================================

# ======================================================================
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# ======================================================================

package require Tcl 8.5


set HtmlDocType {\
<!DOCTYPE html PUBLIC "-//W3C//DTD DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
}

set HtmlHead {\
<head>
  <meta http-equiv="content-type"
           content="text/html; charset=utf-8" />
  <link  rel="icon"
        href="http://scidb.sourceforge.net/images/scidb.ico"
        type="image/x-icon" />
  <link  rel="shortcut icon"
        href="http://scidb.sourceforge.net/images/scidb.ico" />
  <link   rel="stylesheet"
         type="text/css"
        media="screen"
         href="../styles/help.css" />

  <title>%HELP%: %TITLE%</title>
</head>
}

set HtmlH1 {\
<div class="title">
  <h1 class="title">%TITLE%</h1>
</div>
}


proc print {chan source title body} {
	set headerMap [list %TITLE% $title %HELP% $::help::mc::Help]

	puts $chan $::HtmlDocType
	puts $chan "<!-- Generated from $source -->"
	puts $chan ""
	puts $chan "<html>"
	puts $chan [string map $headerMap $::HtmlHead]
	puts $chan "<body>"
	puts $chan ""
	puts $chan "<div class=\"title\">"
	puts $chan "  <h1 class=\"title\">$title</h1>"
	puts $chan "</div>"
	puts $chan ""
	foreach line $body { puts $chan $line }
	puts $chan ""
	puts $chan "</body>"
	puts $chan "</html>"
}


proc readTranslationFile {file nagFile encoding} {
	foreach fileName [list $file $nagFile] {
		set f [open $fileName r]
		chan configure $f -encoding $encoding

		while {[gets $f line] >= 0} {
			if {[string length $line] > 0 && [string index $line 0] ne "#"} {
				set var [lindex $line 0]
				set value [string map {& {} "..." {}} [lindex $line 1]]
				set ns [join [lrange [split $var ::] 1 end-2] ::]
				if {[llength $ns]} { namespace eval $ns {} }
				set $var $value
			}
		}

		close $f
	}
}


proc example {chan} {
	puts $chan "Example usage:"
	puts $chan ""
	puts $chan "CHARSET iso-8859-1"
	puts $chan "TITLE   Clipbase"
	puts $chan ""
	puts $chan "BEGIN"
	puts $chan ""
	puts $chan "<p>...</p>"
	puts $chan ""
	puts $chan "END"

	exit 1
}


proc getArg {line} {
	set n 0
	while {$n < [string length $line] && ![string is space [string index $line $n]]} { incr n }
	while {$n < [string length $line] && [string is space [string index $line $n]]} { incr n }
	return [string range $line $n end]
}


if {$argc != 1} {
	puts "Usage: [info nameofexecutable] <input-file> <output-file>"
	exit 1
}


set lang [file tail [pwd]] 
set file [file join .. .. lang localization.tcl]
source $file

foreach entry $i18n::languages {
	lassign $entry langName codeName charsetName translationFile

	if {$codeName eq $lang} { break }
}

if {$codeName ne $lang} {
	puts stderr "Language \"$lang\" not defined in file \"$file\"."
	puts stderr "You have to edit \"$file\"."
	exit 1
}

set srcfile [lindex $argv 0]
set dstfile "[file rootname $srcfile].html"

set src [open $srcfile r]
chan configure $src -encoding $charsetName
set title ""

while {[gets $src line] >= 0} {
	if {[string match TITLE* $line]} {
		set title [getArg $line]
		break
	}
	if {[string match CHARSET* $line]} {
		set charset [getArg $line]
		chan configure $src -encoding $charset
	}
}

if {![string match TITLE* $line]} {
	puts stderr "Missing mandatory TITLE."
	example stderr
}

set contents {}

while {[gets $src line] >= 0} {
	if {[string match END* $line]} { break }
	lappend contents $line
}

if {![string match END* $line]} {
	puts stderr "Missing mandatory END."
	example stderr
}

close $src

while {[llength $contents] > 0 && [string length [lindex $contents 0]] == 0} {
	set contents [lreplace $contents 0 0]
}

while {[llength $contents] > 0 && [string length [lindex $contents end]] == 0} {
	set contents [lreplace $contents end end]
}

set transFile [file join .. .. lang $translationFile]
set nagFile [file join .. .. lang nag $translationFile]

if {![file readable $transFile]} {
	puts stderr "Cannot open file \"$transFile\"."
	exit 1
}
if {![file readable $nagFile]} {
	puts stderr "Cannot open file \"$nagFile\"."
	exit 1
}

readTranslationFile $transFile $nagFile $charsetName

set body {}
foreach line $contents {
	while {[regexp {%(::)?[a-zA-Z_:]*([(].*[)])?%} $line pattern]} {
		set var [string range $pattern 1 end-1]
		if {[info exists $var]} {
			set line [string map [list $pattern [set $var]] $line]
		} else {
			puts stderr "Warning: couldn't substitute $var"
			set line [string map [list $pattern $var] $line]
		}
	}
	lappend body $line
}

set dst [open $dstfile w]
print $dst [file join tcl help de $srcfile] $title $body
close $dst

# vi:set ts=3 sw=3:
