#!/bin/sh
#
# \
exec tclsh "$0" "$@"

# "ZPS","Mgl-Nr","Status","Spielername","Geschlecht","Spielberechtigung","Geburtsjahr","Letzte-Auswertung","DWZ","Index","FIDE-Elo","FIDE-Titel","FIDE-ID","FIDE-Land"

proc csv2list {str {sepChar ,}} {
	regsub -all {(\A\"|\"\Z)} $str \0 str
	set str [string map {,\"\"\" ,\0\" \ \"\"\", \"\0, \ ,\"\", ,, \ \"\" \" \" \0 } $str]
	set end 0
	while {[regexp -indices -start $end {(\0)[^\0]*(\0)} $str -> start end]} {
		set start [lindex $start 0]
		set end   [lindex $end 0]
		set range [string range $str $start $end]
		set first [string first , $range]
		if {$first >= 0} {
			set str [string replace $str $start $end [string map {, \1} $range]]
		}
		incr end
	}
	set str [string map {, \0 \1 , \0 {}} $str]
	return [split $str \0]
}

proc expand {str len} {
	set length [string length $str]

	if {$length >= $len} { return $str }
	set spaces [string repeat " " [expr {$len - $length}]]
	return [append spaces $str]
}

set fd [open "dwz-ratings.csv"]
gets $fd	;# skip first line

while {[gets $fd line] > 0} {
	set items [csv2list $line]

	set zps		[lindex $items 0]
	set nr		[lindex $items 1]
	set name		[lindex $items 3]
	set gender	[lindex $items 4]
	set birth	[lindex $items 6]
	set rating	[lindex $items 8]
	set fideID	[lindex $items 12]

	if {	[string length $zps] == 5
		&& [string length $nr] > 0
		&& [string length $nr] < 5
		&& [string length $name] > 4
		&& [string length $rating] > 3
		&& [string length $rating] < 5
		&& $rating >= 1800} {

		set name [string map {",Dr." " Dr" "," ", "} $name]
		puts "$zps [expand $nr 4] [expand $fideID 8] [expand $gender 1] [expand $birth 4] [expand $rating 4] $name"
	}
}

close $fd
