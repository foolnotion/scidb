#!/bin/sh
#
# \
exec tclsh "$0" "$@"

# "REF","NAME","SEX","AGE","CATEGORY","GRADE","GRADELAST","GRADEGAMES","RAPIDCAT","RAPID","RAPIDLAST","RAPIDGAMES","CLUBNAM1","CLUBNAM2","CLUBNAM3","CLUBNAM4","CLUBNAM5","CLUBNAM6","FIDECODE","NATION",

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

set fd [open "ecf-ratings.csv"]
gets $fd	;# skip first line

while {[gets $fd line] > 0} {
	set items [csv2list $line]

	set id		[lindex $items 0]
	set name		[lindex $items 1]
	set gender	[lindex $items 2]
	set rating	[lindex $items 5]
	set fideID	[lindex $items 18]

	if {	[string length $id] == 7
		&& [string length $name] > 4
		&& [string length $rating] > 1
		&& [string length $rating] < 4
		&& $rating >= 110} {

		puts "$id [expand $fideID 8] [expand $gender 1] [expand $rating 3] $name"
	}
}

close $fd
