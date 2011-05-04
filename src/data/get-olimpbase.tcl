#!/bin/sh
#
# \
exec tclsh "$0" "$@"

package require http

proc httpCallback {socket token} {
	global out
	global line

	set data [read $socket 1000]
	set id [lindex [regexp -line -inline {Most recent ID:</td> <td><a href=\"http://ratings.fide.com/card.phtml\?event=([0-9]+)} $data] 1]
	if {[llength $id]} {
		set result "[string repeat " " [expr {8 - [string length $id]}]]$id $line"
		puts $result
	}
}

set fd [open "olimpbase.txt"]

while {[gets $fd line] >= 0} {
	if {[string index $line 0] ne "#"} {
		set name [string map {" " "%20" [ "%5B" ] "%5D" | "%5C"} $line]
		::http::cleanup [::http::geturl "http://www.olimpbase.org/Elo/player/$name.html" -handler httpCallback]
	}
}

close fd
