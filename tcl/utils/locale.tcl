# ======================================================================
# Author : $Author$
# Version: $Revision$
# Date   : $Date$
# Url    : $URL$
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

::util::source local

namespace eval locale {

namespace import ::tcl::mathfunc::int


array set Pattern {
	decimalPoint	"."
	thousandsSep	","
	dateY				"Y"
	dateM				"M Y"
	dateD				"M D, Y"
	time				"M D, Y, h:m"
	normal:dateY	"Y"
	normal:dateM	"M/Y"
	normal:dateD	"M/D/Y"
}


proc decimalPoint {} { return [set [namespace current]::Pattern(decimalPoint)] }


proc formatNumber {n {format ""}} {
	variable Pattern

	set unit ""

	if {$format eq "kilo"} {
		if {$n >= 1000000} {
			set decimalPart [format "%02d" [expr {(int($n/10000)) % 100}]]
			set n [expr {int($n)/1000000}]
			set unit "${Pattern(decimalPoint)}${decimalPart} M"
		} elseif {$n >= 100000} {
			set unit " K"
			set n [expr {int($n/1000)} ]
		}
	}

	if {$Pattern(thousandsSep) == ""} { return "$n$unit" }
	while {[regsub {^([-+]?[0-9]+)([0-9][0-9][0-9])} $n "\\1$Pattern(thousandsSep)\\2" n]} {}

	return "$n$unit"
}


proc formatDouble {v {prec 2}} {
	variable Pattern

	set s [format "%0.${prec}f" $v]
	lassign [split $s .] dec frac
	return "[formatNumber $dec]${Pattern(decimalPoint)}${frac}"
}


proc formatSpinboxDouble {v} {
	variable Pattern

	if {[info tclversion] < "8.6"} { return $v }
	return [string map [list . $Pattern(decimalPoint)] $v]
}


proc formatFileSize {size} {
	if {$size >= 1073741824} {
		set size [expr {($size + 536870912)/1073741824}]
		set unit GB
	} elseif {$size >= 1048576} {
		set size [expr {($size + 524288)/1048576}]
		set unit MB
	} elseif {$size >= 1024} {
		set size [expr {($size + 512)/1024}]
		set unit KB
	} else {
		set unit Byte
	}
	return "[formatNumber $size false] $unit"
}


proc formatByteCount {size {prec 2}} {
	if {$size >= 536870912} {
		set size [expr {$size/1073741824.0}]
		set unit GB
	} elseif {$size >= 524288} {
		set size [expr {$size/1048576.0}]
		set unit MB
	} else {
		set size [expr {$size/1024.0}]
		set unit KB
	}
	return "[formatDouble $size $prec] $unit"
}


proc formatNormalDate {date} {
	variable Pattern

	lassign {???? ?? ??} y m d
	lassign [split $date "."] y m d

	if {[string length $y] != 4} { set y "????" }
	if {[string length $m] != 2} { set m "??" }
	if {[string length $d] != 2} { set d "??" }

	if {$y eq "????"} {
		return ""
	}
	set y [string trimleft $y "0"]
	if {$m eq "??"} {
		return [string map [list "Y" [format "%04u" $y]] $Pattern(normal:dateY)]
	}
	set m [string trimleft $m "0"]
	if {$d eq "??"} {
		return [string map [list "Y" [format "%04u" $y] "M" [format "%02u" $m]] $Pattern(normal:dateM)]
	}
	set d [string trimleft $d "0"]
	return [string map \
				[list "Y" [format "%04u" $y] "M" [format "%02u" $m] "D" [format "%02u" $d]] \
				$Pattern(normal:dateD) \
			]
}


proc formatDate {date} {
	variable ::calendar::mc::MonthName
	variable Pattern

	lassign {? ? ?} yer mon day
	lassign [split $date "."] yer mon day
	lassign {0 0 0} y m d

	if {[string index $mon 0] eq "0"} { set mon [string index $mon 1] }
	if {[string index $day 0] eq "0"} { set day [string index $day 1] }

	if {[string is integer -strict $yer]} { set y [int $yer] }
	if {[string is integer -strict $mon]} { set m [int $mon] }
	if {[string is integer -strict $day]} { set d [int $day] }

	if {$y == 0} { return "" }

	if {$m == 0} {
		return [string map [list "Y" $y] $Pattern(dateY)]
	}

	if {$d == 0} {
		return [string map [list "Y" $y "M" $MonthName($m)] $Pattern(dateM)]
	}
	
	return [string map [list "Y" $y "M" $MonthName($m) "D" $d] $Pattern(dateD)]
}


proc formatTime {time} {
	variable ::calendar::mc::MonthName
	variable Pattern

	scan $time "%d.%d.%d %d:%d:%d" year mon day hour min sec
	if {[string length $min] == 1} { set min "0$min" }
	if {[string length $sec] == 1} { set sec "0$sec" }

	return [string map \
				[list "Y" $year "M" $MonthName($mon) "D" $day "h" $hour "m" $min "s" $sec] \
				$Pattern(time)]
}


proc timestampToTime {timestamp} {
	return [clock format $timestamp -format "%Y.%m.%d %H:%M:%S"]
}


proc currentTime {} {
	return [timestampToTime [clock seconds]]
}


proc toNumber {formattedValue} {
	variable Pattern
	set mapping [list $Pattern(decimalPoint) "" $Pattern(thousandsSep) ""]
	return [string trim [string map $mapping $formattedValue]]
}


proc toDouble {formattedValue} {
	variable Pattern
	return [string map [list $Pattern(decimalPoint) .] $formattedValue]
}

} ;# namespace locale

# vi:set ts=3 sw=3:
