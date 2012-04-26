#!/bin/sh
#
# \
exec tclsh "$0" "$@"

# ID;Country;Title;Name;Games;Rating;Gender;

proc expand {str len {align right}} {
	set length [string length $str]

	if {$length >= $len} { return $str }
	set spaces [string repeat " " [expr {$len - $length}]]

	if {$align eq "left"} {
		return [append str $spaces]
	}

	return [append spaces $str]
}

set fd [open "iccf-ratings.csv"]

while {[gets $fd line] > 0} {
	set items [split $line ";"]

	set id		[lindex $items 0]
	set country	[lindex $items 1]
	set title	[lindex $items 2]
	set name		[lindex $items 3]
	set rating	[lindex $items 5]
	set gender	[lindex $items 6]

	if {	[string length $id] <= 6
		&& [string length $name] > 4
		&& [string length $rating] > 3
		&& [string length $rating] < 5} {

		# Prof. Mgr. <name> --> <name> Prof Mag
		# Prof. <name> --> <name> Prof
		# map: Dr. <name> --> <name> Dr
		set n [string first " Prof. Mgr. " $name]
		if {$n >= 0} {
			set s [string range $name 0 $n]
			append s [string range $name [expr {$n + 12}] end]
			append s " Prof Mag"
			set name $s
		} else {
			set n [string first " Prof. " $name]
			if {$n > 0} {
				set s [string range $name 0 $n]
				append s [string range $name [expr {$n + 7}] end]
				append s " Prof"
				set name $s
			} else {
				set n [string first " Dr. " $name]
				if {$n > 0} {
					set s [string range $name 0 $n]
					append s [string range $name [expr {$n + 5}] end]
					append s " Dr"
					set name $s
				}
			}
		}

		# map: Van <lower> --> Van <upper>
		set n [string first "Van " $name]
		if {$n == 0} {
			if {	[string is lower [string index $name 4]]
				&& [string first " de " $name] != 3
				&& [string first " den" $name] != 3
			} {
				set s [string range $name 0 3]
				append s [string toupper [string index $name 4]]
				append s [string range $name 5 end]
				set name $s
			}
		}

		puts "[expand $id 6] $country [expand $title 3 left] [expand $rating 4] [expand $gender 1] $name"
	}
}

close $fd
