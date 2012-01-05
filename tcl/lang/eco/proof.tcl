#!/bin/sh
#
# \
exec tclsh "$0" "$@"

package require Tcl 8.5

set Encoding utf-8
#set Encoding iso8859-1

#################################################################
# from i18n.tcl:
#################################################################

array set EcoTrans {}
set EcoMatch {}
set Trace 0


proc TranslateParen {str} {
	set i1 [string first "(" $str]
	if {$i1 == -1} { return [TranslateColon $str] }
	set i2 [string last ")" $str]
	if {$i2 == -1} { return [TranslateColon $str] }

	set str1 [string range $str 0 [expr {$i1 - 1}]]
	set str2 [string range $str [expr {$i1 + 1}] [expr {$i2 - 1}]]
	set str3 [string range $str [expr {$i2 + 1}] end]

	set spc1 ""
	set spc2 ""

	if {[string index $str1 end] eq " "} {
		set str1 [string trimright $str1]
		set spc1 " "
	}
	if {[string index $str3 end] eq " "} {
		set str3 [string trimleft $str3]
		set spc2 " "
	}

	append result [translateEco $str1]
	append result $spc1
	append result "("
	append result [translateEco $str2]
	append result ")"
	append result $spc2
	append result [translateEco $str3]

	if {$::Trace} { puts "#0 $str --> $result" }

	return $result
}


proc TranslateColon {str} {
	set i [string first ": " $str]
	if {$i == -1} { return [TranslateComma $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 2}] end]

	append result [translateEco $str1]
	append result ": "
	append result [translateEco $str2]

	if {$::Trace} { puts "#1 $str --> $result" }

	return $result
}


proc TranslateComma {str} {
	set i [string first ", " $str]
	if {$i == -1} { return [TranslateAmpersand $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 2}] end]

	append result [translateEco $str1]
	append result ", "
	append result [translateEco $str2]

	if {$::Trace} { puts "#2 $str --> $result" }

	return $result
}


proc TranslateAmpersand {str} {
	set i [string first " & " $str]
	if {$i == -1} { return [TranslateSpace $str] }

	set str1 [string range $str 0 [expr {$i - 1}]]
	set str2 [string range $str [expr {$i + 3}] end]

	append result [translateEco $str1]
	append result " & "
	append result [translateEco $str2]

	if {$::Trace} { puts "#3 $str --> $result" }

	return $result
}


proc TranslateSpace {str} {
	set words [split $str " "]
	if {[llength $words] == 1} { return [TranslateHyphen $str] }
	set n [llength $words]
	set result ""

	for {set i 0} {$i < $n} {} {
		for {set k [expr {$n - 1}]} {$k >= $i} {} {
			set seq [join [lrange $words $i $k] " "]
			set res [TranslateHyphen $seq]

			if {$res ne $seq} {
				if {$i > 0} { append result " " }
				append result $res
				set i [expr {$k + 1}]
				set k [expr {$n - 1}]
			} elseif {$i == $k} {
				if {$i > 0} { append result " " }
				append result $seq
				incr i
				set k [expr {$n  - 1}]
			} elseif {$k == $i} {
				incr i
				set k [expr {$n  - 1}]
			} else {
				incr k -1
			}
		}
	}

	if {$::Trace} { puts "#4 $str --> $result" }

	return $result
}


proc TranslateHyphen {str} {
	set result [TranslateSlash $str]

	if {$result eq $str} {
		set i [string first "-" $str]
		
		if {$i >= 0} {
			set str1 [string range $str 0 [expr {$i - 1}]]
			set str2 [string range $str [expr {$i + 1}] end]

			set result ""
			append result [TranslateSlash $str1]
			append result "-"
			append result [TranslateSpace $str2]
		}
	}

	if {$::Trace} { puts "#6 $str --> $result" }

	return $result
}


proc TranslateSlash {str} {
	set result [TranslateWord $str]

	if {$result eq $str} {
		set i [string first "/" $str]
		
		if {$i >= 0} {
			set str1 [string range $str 0 [expr {$i - 1}]]
			set str2 [string range $str [expr {$i + 1}] end]

			set result ""
			append result [TranslateWord $str1]
			append result "/"
			append result [TranslateSpace $str2]
		}
	}

	if {$::Trace} { puts "#6 $str --> $result" }

	return $result
}


proc TranslateWord {str} {
	variable EcoTrans

	set list EcoTrans([string index $str 0],[string length $str])

	if {[info exists $list]} {
		foreach {key val} [set $list] {
			if {$key eq $str} {
				if {$::Trace} { puts "#7 $str --> $val" }
				return $val
			}
		}
	}

	return $str
}


proc translateEco {str} {
	variable EcoTrans
	variable EcoMatch

	set list EcoTrans([string index $str 0],[string length $str])

	if {[info exists $list]} {
		foreach {key val} [set $list] {
			if {$key eq $str} {
				if {$::Trace} { puts "#8 $str --> $val" }
				return $val
			}
		}
	}

	foreach {key val} $EcoMatch {
		if {[string match $key $str]} {
			if {[string index $key 0] eq "*"} {
				set i [expr {[string last [string range $key 2 end] $str] - 2}]
				set s [translateEco [string range $str 0 $i]]
			} else {
				set i [expr {[string length $key] - 1}]
				set s [translateEco [string range $str $i end]]
			}
			set t [string map [list %1 $s] $val]
			if {$::Trace} { puts "#9 $str --> $t" }
			return $t
		}
	}

	return [TranslateParen $str]
}

#################################################################

proc usage {} {
	puts "Usage: proof ?-in <input-file>? <eco-translation-file> ?string?"
	exit 1
}

if {$argc < 1} { usage }
set ecofile "eco-en"

if {[lindex $argv 0] eq "-in"} {
	if {$argc < 2} { usage }
	set ecofile [lindex $argv 1]
	incr argc -2
	set argv [lreplace $argv 0 1]
	if {$argc < 1} { usage }
}

set filename [lindex $argv 0]
if {![file readable $filename]} { usage }
set fd [open $filename r]
chan configure $fd -encoding $Encoding
set lineno 1
while {[gets $fd line] >= 0} {
	if {[string length $line] > 0 && [string index $line 0] ne "#"} {
		set parts [split $line "\""]
		if {	[llength $parts] < 5
			|| ![string is space [lindex $parts 0]]
			|| ![string is space [lindex $parts 2]]} {

			set msg "syntax error in '$filename' on line $lineno"

			if {	[llength $parts] == 3
				&& [string is space [lindex $parts 0]]
				&& [string is space [lindex $parts 2]]} {
				append msg " (missing translation)"
			} elseif {[llength $parts] % 2 == 0} {
				append msg " (missing quote)"
			}

			puts $msg
			exit 1
		}

		set key [lindex $parts 1]
		set val [lindex $parts 3]

		if {[string range $key 0 1] eq "* " && [string match {*%1*} $val]} {
			lappend EcoMatch $key $val
		} elseif {[string range $key end-1 end] eq " *" && [string match {*%1*} $val]} {
			lappend EcoMatch $key $val
		} else {
			lappend EcoTrans([string index $key 0],[string length $key]) $key $val
		}
	}
	incr lineno
}
close $fd

if {$argc >= 2} {
	set Trace 1
	set str [join [lrange $argv 1 end] " "]
	set result [translateEco $str]
	puts -nonewline "\""
	puts -nonewline $str
	puts -nonewline "\" --> \""
	puts -nonewline $result
	puts "\""
} else {
	set fd [open $ecofile r]
	set list {}

	while {[gets $fd line] >= 0} {
		set i [string first "\"" $line]

		while {$i >= 0} {
			set k [string first "\"" $line [expr {$i + 1}]]

			if {$k > $i} {
				lappend list [string range $line [expr {$i + 1}] [expr {$k - 1}]]
			}

			set i [string first "\"" $line [expr {$k + 1}]]
		}
	}

	close $fd
	set list [lsort -unique $list]

	foreach str $list {
		puts -nonewline "\""
		puts -nonewline $str
		puts -nonewline "\" --> \""
		puts -nonewline [translateEco $str]
		puts "\""
	}
}

# vi:set ts=3 sw=3:
